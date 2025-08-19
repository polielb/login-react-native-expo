<?php
// ================================================================================
// ARCHIVO: backend/test.php
// ================================================================================

require_once 'config/database.php';
require_once 'config/email.php';

echo "<h2>🧪 Test de conexiones - AtencionesFSA</h2>";
echo "<style>
body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
.success { color: #4CAF50; font-weight: bold; }
.error { color: #f44336; font-weight: bold; }
.info { background: #e3f2fd; padding: 10px; border-radius: 5px; margin: 10px 0; }
.warning { background: #fff3e0; padding: 10px; border-radius: 5px; margin: 10px 0; }
</style>";

// Test base de datos
echo "<h3>1. 🗄️ Test Base de Datos:</h3>";
try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        echo "<span class='success'>✅ Conexión a base de datos: EXITOSA</span><br>";
        
        // Test tabla usuarios
        $query = "SELECT COUNT(*) as total FROM usuarios";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "<span class='success'>✅ Usuarios en base de datos: " . $result['total'] . "</span><br>";
        
        // Mostrar usuarios
        $query = "SELECT id, usuario, correo, nombres, apellidos FROM usuarios LIMIT 3";
        $stmt = $db->prepare($query);
        $stmt->execute();
        echo "<div class='info'><strong>Usuarios de prueba:</strong><br>";
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "• ID: {$row['id']} | Usuario: {$row['usuario']} | Email: {$row['correo']} | Nombre: {$row['nombres']} {$row['apellidos']}<br>";
        }
        echo "</div>";
        
        // Test tabla reseteo_clave
        $query = "SELECT COUNT(*) as total FROM reseteo_clave";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "<span class='success'>✅ Tokens de reseteo en BD: " . $result['total'] . "</span><br>";
        
    }
} catch (Exception $e) {
    echo "<span class='error'>❌ Error base de datos: " . $e->getMessage() . "</span><br>";
}

// Test PHPMailer
echo "<h3>2. 📧 Test PHPMailer:</h3>";
try {
    $emailService = new EmailService();
    echo "<span class='success'>✅ PHPMailer cargado correctamente</span><br>";
} catch (Exception $e) {
    echo "<span class='error'>❌ Error PHPMailer: " . $e->getMessage() . "</span><br>";
}

// Test archivos .env
echo "<h3>3. ⚙️ Test variables .env:</h3>";
echo "<div class='info'>";
echo "<strong>Configuración actual:</strong><br>";
echo "DB_HOST: " . ($_ENV['DB_HOST'] ?? 'NO CONFIGURADO') . "<br>";
echo "DB_NAME: " . ($_ENV['DB_NAME'] ?? 'NO CONFIGURADO') . "<br>";
echo "SMTP_HOST: " . ($_ENV['SMTP_HOST'] ?? 'NO CONFIGURADO') . "<br>";
echo "FRONTEND_URL: " . ($_ENV['FRONTEND_URL'] ?? 'NO CONFIGURADO') . "<br>";
echo "</div>";

// Test APIs
echo "<h3>4. 🔗 Test APIs:</h3>";
echo "<div class='warning'>";
echo "<strong>Enlaces para probar APIs:</strong><br>";
echo "<a href='api/login.php' target='_blank'>🔐 Test Login API</a><br>";
echo "<a href='api/request-password-reset.php' target='_blank'>🔑 Test Password Reset API</a><br>";
echo "<a href='api/verify-reset-token.php?token=test' target='_blank'>✅ Test Reset Token API</a><br>";
echo "</div>";

// Instrucciones para el primer test
echo "<h3>5. 🚀 Instrucciones para el Primer Test:</h3>";
echo "<div class='info'>";
echo "<strong>Pasos para probar el sistema:</strong><br>";
echo "1. Verificar que este test muestre todo en verde ✅<br>";
echo "2. Configurar email real en el .env<br>";
echo "3. Iniciar React Native: <code>npm start -- --clear</code><br>";
echo "4. Abrir http://localhost:8081 en el navegador<br>";
echo "5. Login con: test@example.com / 12345<br>";
echo "6. Seguir el proceso de reseteo de contraseña<br>";
echo "</div>";

// Test de conectividad de email (opcional)
echo "<h3>6. 📤 Test Email (Opcional):</h3>";
if (isset($_GET['test_email']) && $_GET['test_email'] === 'true') {
    try {
        $emailService = new EmailService();
        $testResult = $emailService->sendPasswordResetEmail('test@example.com', 'TOKEN_DE_PRUEBA');
        if ($testResult) {
            echo "<span class='success'>✅ Email de prueba enviado correctamente</span><br>";
        } else {
            echo "<span class='error'>❌ No se pudo enviar el email de prueba</span><br>";
        }
    } catch (Exception $e) {
        echo "<span class='error'>❌ Error enviando email: " . $e->getMessage() . "</span><br>";
    }
} else {
    echo "<a href='?test_email=true'>🧪 Hacer test de envío de email</a><br>";
    echo "<small>(Asegúrate de configurar correctamente el SMTP en .env antes)</small>";
}

echo "<hr>";
echo "<h3>✨ Sistema AtencionesFSA - Test Completado</h3>";
echo "<p>Si todo está en verde, el backend está listo para funcionar!</p>";
?>