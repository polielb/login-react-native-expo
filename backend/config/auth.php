<?php
// ================================================================================
// MIDDLEWARE DE AUTENTICACIÓN - backend/config/auth.php
// ================================================================================

require_once 'database.php';

class AuthMiddleware {
    
    private $db;
    
    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }
    
    /**
     * Genera un token único para la sesión
     */
    public static function generateToken() {
        return bin2hex(random_bytes(32));
    }
    
    /**
     * Crea una nueva sesión para el usuario
     */
    public function createSession($usuario_id, $ip_address = null, $user_agent = null, $dispositivo = 'web') {
        try {
            // Limpiar sesiones expiradas del usuario
            $this->cleanExpiredSessions($usuario_id);
            
            // Generar nuevo token
            $token = self::generateToken();
            
            // Insertar nueva sesión
            $query = "INSERT INTO sesiones (usuario_id, token, ip_address, user_agent, dispositivo, fecha_ultimo_acceso) 
                     VALUES (:usuario_id, :token, :ip_address, :user_agent, :dispositivo, NOW())";
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':usuario_id', $usuario_id);
            $stmt->bindParam(':token', $token);
            $stmt->bindParam(':ip_address', $ip_address);
            $stmt->bindParam(':user_agent', $user_agent);
            $stmt->bindParam(':dispositivo', $dispositivo);
            
            if ($stmt->execute()) {
                return $token;
            }
            
            return false;
        } catch (Exception $e) {
            error_log("Error creating session: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Valida si un token es válido y está activo
     */
    public function validateToken($token) {
        try {
            $query = "SELECT s.*, u.id as user_id, u.usuario, u.correo, u.nombres, u.apellidos 
                     FROM sesiones s 
                     INNER JOIN usuarios u ON s.usuario_id = u.id 
                     WHERE s.token = :token 
                     AND s.activa = 1 
                     AND s.fecha_expiracion > NOW()";
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':token', $token);
            $stmt->execute();
            
            if ($stmt->rowCount() > 0) {
                $session = $stmt->fetch(PDO::FETCH_ASSOC);
                
                // Actualizar último acceso
                $this->updateLastAccess($token);
                
                return [
                    'valid' => true,
                    'user' => [
                        'id' => $session['user_id'],
                        'usuario' => $session['usuario'],
                        'correo' => $session['correo'],
                        'nombres' => $session['nombres'],
                        'apellidos' => $session['apellidos']
                    ],
                    'session' => [
                        'id' => $session['id'],
                        'token' => $session['token'],
                        'fecha_creacion' => $session['fecha_creacion'],
                        'fecha_expiracion' => $session['fecha_expiracion'],
                        'dispositivo' => $session['dispositivo']
                    ]
                ];
            }
            
            return ['valid' => false, 'error' => 'Token inválido o expirado'];
            
        } catch (Exception $e) {
            error_log("Error validating token: " . $e->getMessage());
            return ['valid' => false, 'error' => 'Error interno del servidor'];
        }
    }
    
    /**
     * Actualiza el último acceso de una sesión
     */
    private function updateLastAccess($token) {
        try {
            $query = "UPDATE sesiones SET fecha_ultimo_acceso = NOW() WHERE token = :token";
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':token', $token);
            $stmt->execute();
        } catch (Exception $e) {
            error_log("Error updating last access: " . $e->getMessage());
        }
    }
    
    /**
     * Cierra una sesión específica
     */
    public function closeSession($token, $motivo = 'logout') {
        try {
            // Mover a histórico
            $this->moveToHistory($token, $motivo);
            
            // Marcar como inactiva
            $query = "UPDATE sesiones SET activa = 0 WHERE token = :token";
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':token', $token);
            
            return $stmt->execute();
        } catch (Exception $e) {
            error_log("Error closing session: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Cierra todas las sesiones de un usuario
     */
    public function closeAllUserSessions($usuario_id, $except_token = null) {
        try {
            $query = "SELECT token FROM sesiones WHERE usuario_id = :usuario_id AND activa = 1";
            if ($except_token) {
                $query .= " AND token != :except_token";
            }
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':usuario_id', $usuario_id);
            if ($except_token) {
                $stmt->bindParam(':except_token', $except_token);
            }
            $stmt->execute();
            
            $tokens = $stmt->fetchAll(PDO::FETCH_COLUMN);
            
            foreach ($tokens as $token) {
                $this->closeSession($token, 'forced');
            }
            
            return true;
        } catch (Exception $e) {
            error_log("Error closing all user sessions: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Limpia sesiones expiradas
     */
    public function cleanExpiredSessions($usuario_id = null) {
        try {
            $query = "SELECT token FROM sesiones WHERE fecha_expiracion <= NOW() AND activa = 1";
            if ($usuario_id) {
                $query .= " AND usuario_id = :usuario_id";
            }
            
            $stmt = $this->db->prepare($query);
            if ($usuario_id) {
                $stmt->bindParam(':usuario_id', $usuario_id);
            }
            $stmt->execute();
            
            $expired_tokens = $stmt->fetchAll(PDO::FETCH_COLUMN);
            
            foreach ($expired_tokens as $token) {
                $this->closeSession($token, 'expired');
            }
            
            return count($expired_tokens);
        } catch (Exception $e) {
            error_log("Error cleaning expired sessions: " . $e->getMessage());
            return 0;
        }
    }
    
    /**
     * Mueve sesión al histórico
     */
    private function moveToHistory($token, $motivo) {
        try {
            $query = "INSERT INTO sesiones_hist (id, usuario_id, token, fecha_creacion, fecha_expiracion, 
                                               ip_address, user_agent, activa, fecha_ultimo_acceso, 
                                               dispositivo, motivo_cierre)
                     SELECT id, usuario_id, token, fecha_creacion, fecha_expiracion, 
                            ip_address, user_agent, activa, fecha_ultimo_acceso, 
                            dispositivo, :motivo
                     FROM sesiones WHERE token = :token";
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':token', $token);
            $stmt->bindParam(':motivo', $motivo);
            $stmt->execute();
        } catch (Exception $e) {
            error_log("Error moving to history: " . $e->getMessage());
        }
    }
    
    /**
     * Renovar sesión (extender tiempo de expiración)
     */
    public function renewSession($token, $hours = 24) {
        try {
            $query = "UPDATE sesiones 
                     SET fecha_expiracion = DATE_ADD(NOW(), INTERVAL :hours HOUR),
                         fecha_ultimo_acceso = NOW() 
                     WHERE token = :token AND activa = 1";
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':token', $token);
            $stmt->bindParam(':hours', $hours);
            
            return $stmt->execute();
        } catch (Exception $e) {
            error_log("Error renewing session: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Obtener información de sesiones activas de un usuario
     */
    public function getUserActiveSessions($usuario_id) {
        try {
            $query = "SELECT id, token, fecha_creacion, fecha_ultimo_acceso, ip_address, dispositivo
                     FROM sesiones 
                     WHERE usuario_id = :usuario_id AND activa = 1 AND fecha_expiracion > NOW()
                     ORDER BY fecha_ultimo_acceso DESC";
            
            $stmt = $this->db->prepare($query);
            $stmt->bindParam(':usuario_id', $usuario_id);
            $stmt->execute();
            
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            error_log("Error getting user sessions: " . $e->getMessage());
            return [];
        }
    }
}
?>