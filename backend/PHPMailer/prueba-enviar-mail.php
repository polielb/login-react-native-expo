<?php
require __DIR__ . '/src/Exception.php';
require __DIR__ . '/src/PHPMailer.php';
require __DIR__ . '/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$mail = new PHPMailer(true);

try {
    // Opcional: ver logs de SMTP
    // $mail->SMTPDebug = 2; // o 3 para más verboso
    // $mail->Debugoutput = 'error_log';

    // Configuración del servidor SMTP
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;

    // Tu email y contraseña de aplicación (no la contraseña normal)
    $mail->Username = 'correo@gmail.com';
    $mail->Password = 'claveapp';

    // TLS por 587 (o SSL por 465 si preferís)
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS; // para 587
    $mail->Port = 587;

    $mail->CharSet = 'UTF-8';

    // Remitente y destinatario
    $mail->setFrom('correo@gmail.com', 'Prueba PHPMailer');
    $mail->addAddress('correo@gmail.com');

    // Contenido
    $mail->isHTML(true);
    $mail->Subject = 'Correo de prueba desde PHPMailer';
    $mail->Body = '<h1>¡Éxito!</h1><p>Este es un correo de prueba enviado con PHPMailer + Gmail.</p>';
    $mail->AltBody = 'Este es un correo de prueba enviado con PHPMailer + Gmail.';

    // Enviar
    $mail->send();
    echo '✅ Correo enviado correctamente';
} catch (Exception $e) {
    echo "❌ Error al enviar el correo: {$mail->ErrorInfo}";
}
?>
