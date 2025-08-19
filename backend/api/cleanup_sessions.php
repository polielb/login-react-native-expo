<?php
// ================================================================================
// LIMPIEZA AUTOMÁTICA DE SESIONES - backend/api/cleanup_sessions.php
// ================================================================================

require_once '../config/database.php';
require_once '../config/auth.php';

// Solo permitir ejecución desde línea de comandos o con clave especial
if (php_sapi_name() !== 'cli') {
    $cleanup_key = $_GET['key'] ?? $_POST['key'] ?? null;
    if ($cleanup_key !== 'cleanup_sessions_2025_fsa') {
        http_response_code(403);
        echo json_encode(['error' => 'Acceso denegado']);
        exit;
    }
}

try {
    $auth = new AuthMiddleware();
    
    // Limpiar sesiones expiradas
    $expired_count = $auth->cleanExpiredSessions();
    
    // Estadísticas adicionales
    $database = new Database();
    $db = $database->getConnection();
    
    // Contar sesiones activas
    $query_active = "SELECT COUNT(*) as active_sessions FROM sesiones WHERE activa = 1 AND fecha_expiracion > NOW()";
    $stmt_active = $db->prepare($query_active);
    $stmt_active->execute();
    $active_sessions = $stmt_active->fetch(PDO::FETCH_ASSOC)['active_sessions'];
    
    // Contar sesiones por dispositivo
    $query_devices = "SELECT dispositivo, COUNT(*) as count FROM sesiones WHERE activa = 1 AND fecha_expiracion > NOW() GROUP BY dispositivo";
    $stmt_devices = $db->prepare($query_devices);
    $stmt_devices->execute();
    $device_stats = $stmt_devices->fetchAll(PDO::FETCH_ASSOC);
    
    // Sesiones antiguas (más de 7 días inactivas) para mover definitivamente al histórico
    $query_old = "DELETE FROM sesiones WHERE activa = 0 AND fecha_ultimo_acceso < DATE_SUB(NOW(), INTERVAL 7 DAY)";
    $stmt_old = $db->prepare($query_old);
    $stmt_old->execute();
    $deleted_old = $stmt_old->rowCount();
    
    $result = [
        'success' => true,
        'timestamp' => date('Y-m-d H:i:s'),
        'expired_sessions_cleaned' => $expired_count,
        'old_sessions_deleted' => $deleted_old,
        'active_sessions' => $active_sessions,
        'device_stats' => $device_stats
    ];
    
    // Log del resultado
    error_log("Sessions cleanup: " . json_encode($result));
    
    if (php_sapi_name() === 'cli') {
        echo "Limpieza de sesiones completada:\n";
        echo "- Sesiones expiradas limpiadas: {$expired_count}\n";
        echo "- Sesiones antiguas eliminadas: {$deleted_old}\n";
        echo "- Sesiones activas actuales: {$active_sessions}\n";
        echo "- Estadísticas por dispositivo:\n";
        foreach ($device_stats as $stat) {
            echo "  {$stat['dispositivo']}: {$stat['count']}\n";
        }
    } else {
        header('Content-Type: application/json');
        echo json_encode($result);
    }
    
} catch (Exception $e) {
    $error = [
        'success' => false,
        'error' => 'Error en limpieza de sesiones: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    error_log("Sessions cleanup error: " . json_encode($error));
    
    if (php_sapi_name() === 'cli') {
        echo "Error en limpieza: " . $e->getMessage() . "\n";
        exit(1);
    } else {
        http_response_code(500);
        header('Content-Type: application/json');
        echo json_encode($error);
    }
}
?>