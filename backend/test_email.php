<?php
require_once 'config/email.php';

$emailService = new EmailService();
$ok = $emailService->sendPasswordResetEmail('britezedgardoluis@gmail.com', 'tokendeprueba123');

if ($ok) {
    echo "✅ Email enviado correctamente";
} else {
    echo "❌ Error al enviar email. Revisar logs.";
}
?>
