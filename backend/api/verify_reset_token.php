<?php
// ================================================================================
// API VERIFY TOKEN CORREGIDA - backend/api/verify_reset_token.php
// ================================================================================

define('RESPONSE_CONTENT_TYPE', 'html');
// require_once '../config/cors.php';
require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

$token = $_GET['token'] ?? '';

if (empty($token)) {
    http_response_code(400);
    echo json_encode(["error" => "Token requerido"]);
    exit;
}

// Buscar el token y obtener la nueva contraseña
$query = "SELECT r.*, u.correo FROM reseteo_clave r 
          JOIN usuarios u ON r.usuario = u.usuario 
          WHERE r.token = :token AND r.utilizado = 0 AND r.fecha_expira > NOW()";
$stmt = $db->prepare($query);
$stmt->bindParam(":token", $token);
$stmt->execute();

if ($stmt->rowCount() == 0) {
    // Redirigir a una página de error o mostrar mensaje
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Token Inválido - AtencionesFSA</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            .error { color: #f44336; }
            .container { max-width: 500px; margin: 0 auto; }
        </style>
    </head>
    <body>
        <div class="container">
            <h2 class="error">Token Inválido o Expirado</h2>
            <p>El enlace de reseteo de contraseña no es válido o ha expirado.</p>
            <p>Por favor, solicita un nuevo reseteo de contraseña.</p>
            <a href="<?php echo $_ENV['FRONTEND_URL']; ?>">Volver al Login</a>
        </div>
    </body>
    </html>
    <?php
    exit;
}

$resetData = $stmt->fetch(PDO::FETCH_ASSOC);

try {
    $db->beginTransaction();
    
    // ================================================================================
    // 🔥 AUDITORÍA 1: ANTES DE ACTUALIZAR USUARIOS - GRABAR EN usuarios_hist
    // ================================================================================
    $queryUsuarioActual = "SELECT * FROM usuarios WHERE usuario = :usuario";
    $stmtUsuarioActual = $db->prepare($queryUsuarioActual);
    $stmtUsuarioActual->bindParam(":usuario", $resetData['usuario']);
    $stmtUsuarioActual->execute();
    
    if ($stmtUsuarioActual->rowCount() > 0) {
        $usuarioActual = $stmtUsuarioActual->fetch(PDO::FETCH_ASSOC);
        
        // Insertar en usuarios_hist ANTES del UPDATE
        $insertUsuarioHistQuery = "INSERT INTO usuarios_hist 
            (id, usuario, correo, clave, apellidos, nombres, dni, mobil, activo, usu_alta, fecha_alta, usu_mod) 
            VALUES (:id, :usuario, :correo, :clave, :apellidos, :nombres, :dni, :mobil, :activo, :usu_alta, :fecha_alta, :usu_mod)";
        $stmtUsuarioHist = $db->prepare($insertUsuarioHistQuery);
        $stmtUsuarioHist->bindParam(":id", $usuarioActual['id']);
        $stmtUsuarioHist->bindParam(":usuario", $usuarioActual['usuario']);
        $stmtUsuarioHist->bindParam(":correo", $usuarioActual['correo']);
        $stmtUsuarioHist->bindParam(":clave", $usuarioActual['clave']);
        $stmtUsuarioHist->bindParam(":apellidos", $usuarioActual['apellidos']);
        $stmtUsuarioHist->bindParam(":nombres", $usuarioActual['nombres']);
        $stmtUsuarioHist->bindParam(":dni", $usuarioActual['dni']);
        $stmtUsuarioHist->bindParam(":mobil", $usuarioActual['mobil']);
        $stmtUsuarioHist->bindParam(":activo", $usuarioActual['activo']);
        $stmtUsuarioHist->bindParam(":usu_alta", $usuarioActual['usu_alta']);
        $stmtUsuarioHist->bindParam(":fecha_alta", $usuarioActual['fecha_alta']);
        $stmtUsuarioHist->bindParam(":usu_mod", $resetData['usuario']); // Usuario que ejecuta el cambio
        $stmtUsuarioHist->execute();
    }
    
    // 1. Actualizar la contraseña del usuario (AHORA SÍ)
    $updateUserQuery = "UPDATE usuarios SET clave = :nueva_clave WHERE usuario = :usuario";
    $updateUserStmt = $db->prepare($updateUserQuery);
    $updateUserStmt->bindParam(":nueva_clave", $resetData['nueva_clave']);
    $updateUserStmt->bindParam(":usuario", $resetData['usuario']);
    $updateUserStmt->execute();
    
    // ================================================================================
    // 🔥 AUDITORÍA 2: ANTES DE ACTUALIZAR reseteo_clave - GRABAR EN reseteo_clave_hist
    // ================================================================================
    $queryReseteoActual = "SELECT * FROM reseteo_clave WHERE token = :token";
    $stmtReseteoActual = $db->prepare($queryReseteoActual);
    $stmtReseteoActual->bindParam(":token", $token);
    $stmtReseteoActual->execute();
    
    if ($stmtReseteoActual->rowCount() > 0) {
        $reseteoActual = $stmtReseteoActual->fetch(PDO::FETCH_ASSOC);
        
        // Insertar en reseteo_clave_hist ANTES del UPDATE
        $insertReseteoHistQuery = "INSERT INTO reseteo_clave_hist 
            (id, usuario, token, nueva_clave, fecha_expira, utilizado, fecha_utilizado, usu_alta, fecha_alta, usu_mod) 
            VALUES (:id, :usuario, :token, :nueva_clave, :fecha_expira, :utilizado, :fecha_utilizado, :usu_alta, :fecha_alta, :usu_mod)";
        $stmtReseteoHist = $db->prepare($insertReseteoHistQuery);
        $stmtReseteoHist->bindParam(":id", $reseteoActual['id']);
        $stmtReseteoHist->bindParam(":usuario", $reseteoActual['usuario']);
        $stmtReseteoHist->bindParam(":token", $reseteoActual['token']);
        $stmtReseteoHist->bindParam(":nueva_clave", $reseteoActual['nueva_clave']);
        $stmtReseteoHist->bindParam(":fecha_expira", $reseteoActual['fecha_expira']);
        $stmtReseteoHist->bindParam(":utilizado", $reseteoActual['utilizado']);
        $stmtReseteoHist->bindParam(":fecha_utilizado", $reseteoActual['fecha_utilizado']);
        $stmtReseteoHist->bindParam(":usu_alta", $reseteoActual['usu_alta']);
        $stmtReseteoHist->bindParam(":fecha_alta", $reseteoActual['fecha_alta']);
        $stmtReseteoHist->bindParam(":usu_mod", $resetData['usuario']); // Usuario que ejecuta el cambio
        $stmtReseteoHist->execute();
    }
    
    // 2. Marcar token como utilizado (AHORA SÍ)
    $updateTokenQuery = "UPDATE reseteo_clave SET utilizado = 1, fecha_utilizado = NOW() WHERE token = :token";
    $updateTokenStmt = $db->prepare($updateTokenQuery);
    $updateTokenStmt->bindParam(":token", $token);
	$updateTokenStmt->execute();
	if ($updateTokenStmt->rowCount() === 0) {
		throw new Exception('No se actualizó la clave del usuario.');
	}

	$db->commit();
    
    // Redirigir al login con mensaje de éxito
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Contraseña Actualizada - AtencionesFSA</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            .success { color: #4CAF50; }
            .container { max-width: 500px; margin: 0 auto; }
            .login-btn { 
                display: inline-block; 
                padding: 10px 20px; 
                background: #2196F3; 
                color: white; 
                text-decoration: none; 
                border-radius: 5px; 
                margin-top: 20px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h2 class="success">¡Contraseña Actualizada Exitosamente!</h2>
            <p>Tu contraseña ha sido cambiada correctamente.</p>
            <p>Ya puedes iniciar sesión con tu nueva contraseña.</p>
            <p><strong>Usuario:</strong> <?php echo htmlspecialchars($resetData['correo']); ?></p>
            <a href="<?php echo $_ENV['FRONTEND_URL']; ?>" class="login-btn">Ir al Login</a>
        </div>
        <script>
            // Auto-redireccionar después de 5 segundos
            setTimeout(function() {
                window.location.href = '<?php echo $_ENV['FRONTEND_URL']; ?>';
            }, 5000);
        </script>
    </body>
    </html>
    <?php
    
} catch (Exception $e) {
    $db->rollback();
    http_response_code(500);
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Error - AtencionesFSA</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            .error { color: #f44336; }
            .container { max-width: 500px; margin: 0 auto; }
        </style>
    </head>
    <body>
        <div class="container">
            <h2 class="error">Error del Servidor</h2>
            <p>Ocurrió un error al procesar tu solicitud.</p>
            <p>Por favor, intenta nuevamente más tarde.</p>
            <a href="<?php echo $_ENV['FRONTEND_URL']; ?>">Volver al Login</a>
        </div>
    </body>
    </html>
    <?php
}
?>