<?php
// ================================================================================
// VALIDAR SESIÓN - backend/api/validate_session.php
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
    $auth = new AuthMiddleware();
    
    // Obtener token del header Authorization
    $headers = getallheaders();
    $token = null;
    
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $token = $matches[1];
        }
    }
    
    // También verificar en el body para compatibilidad
    if (!$token) {
        $data = json_decode(file_get_contents("php://input"));
        if (isset($data->token)) {
            $token = $data->token;
        }
    }
    
    if (!$token) {
        http_response_code(401);
        echo json_encode([
            "valid" => false,
            "error" => "Token no proporcionado"
        ]);
        exit;
    }
    
    // Validar token
    $result = $auth->validateToken($token);
    
    if ($result['valid']) {
        echo json_encode([
            "valid" => true,
            "user" => $result['user'],
            "session" => $result['session']
        ]);
    } else {
        http_response_code(401);
        echo json_encode([
            "valid" => false,
            "error" => $result['error']
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "valid" => false,
        "error" => "Error interno del servidor: " . $e->getMessage()
    ]);
}
?>