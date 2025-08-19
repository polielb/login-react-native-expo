<?php
// Forzar que se muestren errores en el navegador (solo para pruebas)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Incluir el servicio de email del proyecto
require_once __DIR__ . '/config/email.php';

// Crear una instancia de EmailService
$emailService = new EmailService();

// Email y token de prueba
$destinatario = 'britezedgardoluis@gmail.com'; // cámbialo si quieres probar con otro
$token = bin2hex(random_bytes(16)); // genera un token aleatorio

// Enviar el correo
$enviado = $emailService->sendPasswordResetEmail($destinatario, $token);

if ($enviado) {
    echo "<p style='color:green;font-weight:bold;'>✅ Correo de prueba enviado correctamente a {$destinatario}</p>";
} else {
    echo "<p style='color:red;font-weight:bold;'>❌ Error al enviar el correo. Revisa los logs en error_log o activa SMTPDebug en config/email.php</p>";
}
