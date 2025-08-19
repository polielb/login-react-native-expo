<?php
// ================================================================================
// API LOGIN CON SESIONES - backend/api/login.php
// ================================================================================

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';

// Manejar peticiones OPTIONS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json');

try {
    $database = new Database();
    $db = $database->getConnection();
    $auth = new AuthMiddleware();
    
    $data = json_decode(file_get_contents("php://input"));
    
    if (!isset($data->correo) || !isset($data->clave)) {
        http_response_code(400);
        echo json_encode(["error" => "Correo y clave son requeridos"]);
        exit;
    }
    
    $correo = $data->correo;
    $clave = $data->clave;
    
    // Extraer usuario del correo (parte antes del @)
    $usuario = substr($correo, 0, strpos($correo, '@'));
    
    // Verificar si el usuario existe
    $query = "SELECT id, usuario, correo, clave, nombres, apellidos FROM usuarios WHERE correo = :correo";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":correo", $correo);
    $stmt->execute();
    
    if ($stmt->rowCount() == 0) {
        http_response_code(401);
        echo json_encode(["error" => "Usuario no encontrado"]);
        exit;
    }
    
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $usuarioEncontrado = $row['usuario'];
    
    // Verificar si es la clave por defecto para reseteo
    if ($clave === '12345') {
        // Verificar si NO tiene un token activo de reseteo (sin utilizar)
        $queryToken = "SELECT COUNT(*) as tokens_activos FROM reseteo_clave 
                       WHERE usuario = :usuario AND utilizado = 0 AND fecha_expira > NOW()";
        $stmtToken = $db->prepare($queryToken);
        $stmtToken->bindParam(":usuario", $usuarioEncontrado);
        $stmtToken->execute();
        $tokenResult = $stmtToken->fetch(PDO::FETCH_ASSOC);
        
        if ($tokenResult['tokens_activos'] > 0) {
            http_response_code(400);
            echo json_encode([
                "error" => "Ya tienes un proceso de reseteo activo. Revisa tu email o espera a que expire."
            ]);
            exit;
        }
        
        echo json_encode([
            "success" => true, 
            "needsPasswordReset" => true,
            "usuario" => $usuarioEncontrado,
            "correo" => $correo
        ]);
        exit;
    }
    
    // Login normal - verificar contraseña
    if (password_verify($clave, $row['clave'])) {
        // Verificar si tiene tokens de reseteo pendientes
        $queryPendingTokens = "SELECT COUNT(*) as tokens_pendientes FROM reseteo_clave 
                              WHERE usuario = :usuario AND utilizado = 0 AND fecha_expira > NOW()";
        $stmtPending = $db->prepare($queryPendingTokens);
        $stmtPending->bindParam(":usuario", $usuarioEncontrado);
        $stmtPending->execute();
        $pendingResult = $stmtPending->fetch(PDO::FETCH_ASSOC);
        
        if ($pendingResult['tokens_pendientes'] > 0) {
            http_response_code(400);
            echo json_encode([
                "error" => "Tienes un proceso de reseteo de contraseña pendiente. Revisa tu email para completarlo."
            ]);
            exit;
        }
        
        // ============ NUEVA FUNCIONALIDAD: CREAR SESIÓN ============
        
        // Obtener información del cliente
        $ip_address = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'] ?? null;
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? null;
        
        // Detectar tipo de dispositivo basado en User-Agent
        $dispositivo = 'web'; // por defecto
        if (strpos($user_agent, 'Expo') !== false || strpos($user_agent, 'ReactNative') !== false) {
            $dispositivo = strpos($user_agent, 'Android') !== false ? 'android' : 'ios';
        }
        
        // Limpiar sesiones expiradas del usuario antes de crear una nueva
        $auth->cleanExpiredSessions($row['id']);
        
        // Crear nueva sesión
        $token = $auth->createSession(
            $row['id'], 
            $ip_address, 
            $user_agent, 
            $dispositivo
        );
        
        if (!$token) {
            http_response_code(500);
            echo json_encode(["error" => "Error al crear la sesión"]);
            exit;
        }
        
        // Respuesta exitosa con token de sesión
        echo json_encode([
            "success" => true,
            "token" => $token,
            "user" => [
                "id" => $row['id'],
                "usuario" => $row['usuario'],
                "correo" => $row['correo'],
                "nombres" => $row['nombres'],
                "apellidos" => $row['apellidos']
            ],
            "session" => [
                "expires_in" => "24 hours",
                "device" => $dispositivo,
                "created_at" => date('Y-m-d H:i:s')
            ]
        ]);
        
    } else {
        http_response_code(401);
        echo json_encode(["error" => "Credenciales inválidas"]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error interno del servidor: " . $e->getMessage()]);
}
?>