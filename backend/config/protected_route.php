<?php
// ================================================================================
// MIDDLEWARE PARA RUTAS PROTEGIDAS - backend/config/protected_route.php
// ================================================================================

require_once 'auth.php';

/**
 * Función para verificar autenticación en rutas protegidas
 * Debe incluirse al inicio de cualquier archivo PHP que requiera autenticación
 */
function requireAuth() {
    // Manejar CORS
    if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
        http_response_code(200);
        exit();
    }
    
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
        
        // También verificar en el body para compatibilidad con algunos clientes
        if (!$token && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $input = json_decode(file_get_contents("php://input"), true);
            if (isset($input['token'])) {
                $token = $input['token'];
            }
        }
        
        // También verificar en GET params como último recurso
        if (!$token && isset($_GET['token'])) {
            $token = $_GET['token'];
        }
        
        if (!$token) {
            http_response_code(401);
            header('Content-Type: application/json');
            echo json_encode([
                'error' => 'Token de autorización requerido',
                'code' => 'NO_TOKEN'
            ]);
            exit();
        }
        
        // Validar token
        $result = $auth->validateToken($token);
        
        if (!$result['valid']) {
            http_response_code(401);
            header('Content-Type: application/json');
            echo json_encode([
                'error' => $result['error'],
                'code' => 'INVALID_TOKEN'
            ]);
            exit();
        }
        
        // Token válido - retornar información del usuario
        return $result;
        
    } catch (Exception $e) {
        http_response_code(500);
        header('Content-Type: application/json');
        echo json_encode([
            'error' => 'Error interno del servidor',
            'code' => 'SERVER_ERROR'
        ]);
        exit();
    }
}

/**
 * Función para obtener información del usuario autenticado
 * (solo usar después de requireAuth())
 */
function getCurrentUser() {
    return $_SESSION['auth_user'] ?? null;
}

/**
 * Función para verificar roles/permisos específicos
 */
function requireRole($required_roles = []) {
    $auth_data = requireAuth();
    $user = $auth_data['user'];
    
    // Aquí puedes agregar lógica de roles si tienes una tabla de roles
    // Por ahora, todos los usuarios autenticados tienen acceso
    
    return $user;
}

/**
 * Función para verificar si un usuario puede acceder a datos de otro usuario
 */
function canAccessUser($target_user_id) {
    $auth_data = requireAuth();
    $current_user = $auth_data['user'];
    
    // El usuario puede acceder a sus propios datos
    if ($current_user['id'] == $target_user_id) {
        return true;
    }
    
    // Verificar en la tabla usuarios_relacionados si tiene permisos
    try {
        $database = new Database();
        $db = $database->getConnection();
        
        $query = "SELECT COUNT(*) as tiene_permiso 
                 FROM usuarios_relacionados 
                 WHERE (usuario_admin = :current_user OR usuario_permitido = :current_user)
                 AND (usuario_admin = (SELECT usuario FROM usuarios WHERE id = :target_user) 
                      OR usuario_permitido = (SELECT usuario FROM usuarios WHERE id = :target_user))
                 AND activo = 1";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':current_user', $current_user['usuario']);
        $stmt->bindParam(':target_user', $target_user_id);
        $stmt->execute();
        
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['tiene_permiso'] > 0;
        
    } catch (Exception $e) {
        error_log("Error checking user access: " . $e->getMessage());
        return false;
    }
}
?>