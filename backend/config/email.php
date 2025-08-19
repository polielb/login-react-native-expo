<?php
// ================================================================================
// CONFIGURACIÓN DE EMAIL CORREGIDA - backend/config/email.php
// ================================================================================

// Cargar PHPMailer manualmente
require_once __DIR__ . '/../PHPMailer/src/Exception.php';
require_once __DIR__ . '/../PHPMailer/src/PHPMailer.php';
require_once __DIR__ . '/../PHPMailer/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

class EmailService {
    private $mail;

    public function __construct() {
        $this->loadEnv();
        $this->mail = new PHPMailer(true);
        $this->setupSMTP();
    }

    private function loadEnv() {
        $envFile = __DIR__ . '/../.env';
        if (file_exists($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
                    list($key, $value) = explode('=', $line, 2);
                    $_ENV[trim($key)] = trim($value);
                }
            }
        }
    }

    private function setupSMTP() {
        $this->mail->isSMTP();
        $this->mail->Host = $_ENV['SMTP_HOST'];
        $this->mail->SMTPAuth = true;
        $this->mail->Username = $_ENV['SMTP_USER'];
        $this->mail->Password = $_ENV['SMTP_PASS'];
        $this->mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $this->mail->Port = $_ENV['SMTP_PORT'];
        $this->mail->CharSet = 'UTF-8';
        
        // Debug solo en desarrollo
        // $this->mail->SMTPDebug = SMTP::DEBUG_SERVER;
    }

    public function sendPasswordResetEmail($email, $token) {
        try {
            // Limpiar destinatarios previos
            $this->mail->clearAddresses();
            $this->mail->clearReplyTos();
            $this->mail->clearAttachments();

            $this->mail->setFrom($_ENV['SMTP_FROM'], 'AtencionesFSA Sistema');
            $this->mail->addAddress($email);
            
            // Construir el enlace de reseteo
            $resetLink = $_ENV['BACKEND_URL'] . "/backend/api/verify_reset_token.php?token=" . $token;
            
            // Extraer usuario del email para personalizar
            $usuario = substr($email, 0, strpos($email, '@'));
            
            $this->mail->isHTML(true);
            $this->mail->Subject = '🔐 Confirmación de Cambio de Contraseña - AtencionesFSA';
            
            $this->mail->Body = $this->getEmailTemplate($usuario, $resetLink, $token);
            
            // Versión de texto plano
            $this->mail->AltBody = $this->getPlainTextTemplate($usuario, $resetLink);

            $this->mail->send();
            return true;
            
        } catch (Exception $e) {
            error_log("Error enviando email a {$email}: {$this->mail->ErrorInfo}");
            error_log("Exception: " . $e->getMessage());
            return false;
        }
    }

    private function getEmailTemplate($usuario, $resetLink, $token) {
        return "
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title>Confirmación de Cambio de Contraseña</title>
            <style>
                body { 
                    font-family: Arial, sans-serif; 
                    line-height: 1.6; 
                    color: #333; 
                    max-width: 600px; 
                    margin: 0 auto; 
                    padding: 20px;
                    background-color: #f5f5f5;
                }
                .container { 
                    background: white; 
                    padding: 30px; 
                    border-radius: 10px; 
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
                .header { 
                    text-align: center; 
                    margin-bottom: 30px;
                    padding-bottom: 20px;
                    border-bottom: 2px solid #2196F3;
                }
                .logo { 
                    font-size: 28px; 
                    font-weight: bold; 
                    color: #2196F3; 
                    margin-bottom: 10px;
                }
                .subtitle { 
                    color: #666; 
                    font-size: 16px;
                }
                .greeting { 
                    font-size: 18px; 
                    margin-bottom: 20px;
                    color: #2196F3;
                }
                .content { 
                    margin-bottom: 25px; 
                    line-height: 1.7;
                }
                .button-container { 
                    text-align: center; 
                    margin: 30px 0;
                }
                .confirm-button { 
                    display: inline-block; 
                    padding: 15px 30px; 
                    background: #FF9800; 
                    color: white; 
                    text-decoration: none; 
                    border-radius: 8px; 
                    font-size: 16px;
                    font-weight: bold;
                    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
                }
                .confirm-button:hover { 
                    background: #F57C00; 
                }
                .warning-box { 
                    background: #fff3cd; 
                    border: 1px solid #ffeaa7; 
                    border-radius: 5px; 
                    padding: 15px; 
                    margin: 20px 0;
                    border-left: 4px solid #FF9800;
                }
                .warning-title { 
                    font-weight: bold; 
                    color: #856404; 
                    margin-bottom: 10px;
                }
                .warning-text { 
                    color: #856404; 
                    font-size: 14px;
                }
                .info-box { 
                    background: #e8f4fd; 
                    border: 1px solid #b3d9ff; 
                    border-radius: 5px; 
                    padding: 15px; 
                    margin: 20px 0;
                    border-left: 4px solid #2196F3;
                }
                .footer { 
                    text-align: center; 
                    margin-top: 30px; 
                    padding-top: 20px; 
                    border-top: 1px solid #eee; 
                    color: #666; 
                    font-size: 14px;
                }
                .token-info { 
                    background: #f8f9fa; 
                    padding: 10px; 
                    border-radius: 5px; 
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <div class='logo'>🏥 AtencionesFSA</div>
                    <div class='subtitle'>Sistema de Gestión Médica</div>
                </div>
                
                <div class='greeting'>¡Hola {$usuario}!</div>
                
                <div class='content'>
                    <p>Has solicitado cambiar tu contraseña en el sistema AtencionesFSA.</p>
                    <p><strong>Para completar el proceso, debes hacer click en el siguiente botón:</strong></p>
                </div>

                <div class='button-container'>
                    <a href='{$resetLink}' class='confirm-button'>
                        🔐 CONFIRMAR NUEVA CONTRASEÑA
                    </a>
                </div>

                <div class='warning-box'>
                    <div class='warning-title'>⚠️ IMPORTANTE:</div>
                    <div class='warning-text'>
                        �?Este enlace expira en <strong>24 horas</strong><br>
                        �?Solo puedes usarlo <strong>una vez</strong><br>
                        �?Después de hacer click, podrás iniciar sesión con tu nueva contraseña<br>
                        �?Si no solicitaste este cambio, ignora este email
                    </div>
                </div>

                <div class='info-box'>
                    <strong>💡 ¿Qué pasa después de hacer click?</strong><br>
                    1. Se activará tu nueva contraseña<br>
                    2. Se te redirigirá al sistema de login<br>
                    3. Podrás ingresar con tu correo y la nueva contraseña que configuraste
                </div>

                <div class='content'>
                    <p><strong>Si el botón no funciona, copia y pega este enlace en tu navegador:</strong></p>
                    <div class='manual-link'>{$resetLink}</div>
                </div>

                <div class='footer'>
                    <p>
                        <strong>AtencionesFSA - Sistema de Gestión</strong><br>
                        Este email fue enviado automáticamente, no responder.<br>
                        <small>Token: {$token}</small>
                    </p>
                </div>
            </div>
        </body>
        </html>";
    }

    private function getPlainTextTemplate($usuario, $resetLink) {
        return "
ATENCIONESFSA - CONFIRMACIÓN DE CAMBIO DE CONTRASEÑA

Hola {$usuario},

Has solicitado cambiar tu contraseña en el sistema AtencionesFSA.

Para completar el proceso, visita el siguiente enlace:
{$resetLink}

IMPORTANTE:
- Este enlace expira en 24 horas
- Solo puedes usarlo una vez
- Después de hacer click, podrás iniciar sesión con tu nueva contraseña
- Si no solicitaste este cambio, ignora este email

Después de hacer click en el enlace:
1. Se activará tu nueva contraseña
2. Se te redirigirá al sistema de login
3. Podrás ingresar con tu correo y la nueva contraseña que configuraste

AtencionesFSA - Sistema de Gestión
Este email fue enviado automáticamente, no responder.
        ";
    }
}
?>