<?php
// ================================================================================
// EJEMPLO DE API PROTEGIDA - backend/api/user_profile.php
// ================================================================================

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/protected_route.php';

// Esta línea verificará automáticamente la autenticación
$auth_data = requireAuth();
$current_user = $auth_data['user'];

header('Content-Type: application/json');

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // ==================== GET: Obtener perfil del usuario ====================
        
        $user_id = $_GET['user_id'] ?? $current_user['id'];
        
        // Verificar si puede acceder a este usuario
        if (!canAccessUser($user_id)) {
            http_response_code(403);
            echo json_encode([
                'error' => 'No tienes permisos para acceder a este usuario'
            ]);
            exit;
        }
        
        // Obtener información del usuario
        $query = "SELECT id, usuario, correo, nombres, apellidos, dni, mobil, 
                         activo, fecha_alta 
                 FROM usuarios 
                 WHERE id = :user_id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        
        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Usuario no encontrado']);
            exit;
        }
        
        $user_data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Obtener sesiones activas del usuario
        $auth = new AuthMiddleware();
        $active_sessions = $auth->getUserActiveSessions($user_id);
        
        echo json_encode([
            'success' => true,
            'user' => $user_data,
            'active_sessions' => $active_sessions,
            'requested_by' => $current_user['usuario']
        ]);
        
    } elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        // ==================== PUT: Actualizar perfil ====================
        
        $data = json_decode(file_get_contents("php://input"), true);
        $user_id = $data['user_id'] ?? $current_user['id'];
        
        // Solo puede actualizar su propio perfil (por seguridad)
        if ($user_id != $current_user['id']) {
            http_response_code(403);
            echo json_encode([
                'error' => 'Solo puedes actualizar tu propio perfil'
            ]);
            exit;
        }
        
        // Validar datos requeridos
        if (!isset($data['nombres']) || !isset($data['apellidos'])) {
            http_response_code(400);
            echo json_encode([
                'error' => 'Nombres y apellidos son requeridos'
            ]);
            exit;
        }
        
        // Actualizar usuario
        $query = "UPDATE usuarios 
                 SET nombres = :nombres, 
                     apellidos = :apellidos, 
                     dni = :dni, 
                     mobil = :mobil 
                 WHERE id = :user_id";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':nombres', $data['nombres']);
        $stmt->bindParam(':apellidos', $data['apellidos']);
        $stmt->bindParam(':dni', $data['dni']);
        $stmt->bindParam(':mobil', $data['mobil']);
        $stmt->bindParam(':user_id', $user_id);
        
        if ($stmt->execute()) {
            echo json_encode([
                'success' => true,
                'message' => 'Perfil actualizado exitosamente'
            ]);
        } else {
            http_response_code(500);
            echo json_encode([
                'error' => 'Error al actualizar el perfil'
            ]);
        }
        
    } else {
        http_response_code(405);
        echo json_encode([
            'error' => 'Método no permitido'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Error interno del servidor: ' . $e->getMessage()
    ]);
}
?>