<?php
// ================================================================================
// API PASSWORD RESET CORREGIDA - backend/api/reset_password.php
// ================================================================================

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/email.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->correo) || !isset($data->claveActual) || !isset($data->nuevaClave)) {
    http_response_code(400);
    echo json_encode(["error" => "Correo, clave actual y nueva clave son requeridos"]);
    exit;
}

$correo = $data->correo;
$claveActual = $data->claveActual;
$nuevaClave = $data->nuevaClave;

// Extraer usuario del correo
$usuario = substr($correo, 0, strpos($correo, '@'));


try {
    // 🆕 PASO 1: Verificar que el usuario existe Y validar la contraseña actual
    $query = "SELECT id, usuario, correo, clave, nombres, apellidos FROM usuarios WHERE correo = :correo";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":correo", $correo);
    $stmt->execute();

    if ($stmt->rowCount() == 0) {
        http_response_code(404);
        echo json_encode(["error" => "Usuario no encontrado"]);
        exit;
    }

    $userData = $stmt->fetch(PDO::FETCH_ASSOC);

    // 🆕 PASO 2: Validar la contraseña actual (IGUAL QUE EN LOGIN)
    if (!password_verify($claveActual, $userData['clave'])) {
        http_response_code(401);
        echo json_encode(["error" => "La contraseña actual es incorrecta"]);
        exit;
    }

    // 🆕 PASO 3: Validar que la nueva contraseña sea diferente a la actual
    if (password_verify($nuevaClave, $userData['clave'])) {
        http_response_code(400);
        echo json_encode(["error" => "La nueva contraseña debe ser diferente a la actual"]);
        exit;
    }

    // PASO 4: Verificar si ya tiene un token activo
    $queryExisting = "SELECT COUNT(*) as tokens_activos FROM reseteo_clave 
                      WHERE usuario = :usuario AND utilizado = 0 AND fecha_expira > NOW()";
    $stmtExisting = $db->prepare($queryExisting);
    $stmtExisting->bindParam(":usuario", $userData['usuario']);
    $stmtExisting->execute();
    $existingResult = $stmtExisting->fetch(PDO::FETCH_ASSOC);

    if ($existingResult['tokens_activos'] > 0) {
        http_response_code(400);
        echo json_encode(["error" => "Ya tienes un proceso de reseteo activo. Revisa tu email."]);
        exit;
    }

    // PASO 5: Generar token único
    $token = bin2hex(random_bytes(32));
    $fechaExpira = date('Y-m-d H:i:s', strtotime('+24 hours'));

    // Hash de la nueva contraseña (pero NO la guardamos aún en usuarios)
    $nuevaClaveHash = password_hash($nuevaClave, PASSWORD_DEFAULT);

    // PASO 6: Insertar el token con la nueva contraseña hasheada
    $query = "INSERT INTO reseteo_clave (usuario, token, nueva_clave, fecha_expira, usu_alta) 
              VALUES (:usuario, :token, :nueva_clave, :fecha_expira, :usu_alta)";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":usuario", $userData['usuario']);
    $stmt->bindParam(":token", $token);
    $stmt->bindParam(":nueva_clave", $nuevaClaveHash);
    $stmt->bindParam(":fecha_expira", $fechaExpira);
    $stmt->bindParam(":usu_alta", $userData['usuario']);
    $stmt->execute();
    
    // PASO 7: Enviar email con el token
    $emailService = new EmailService();
    $emailSent = $emailService->sendPasswordResetEmail($correo, $token);
    
    if ($emailSent) {
        echo json_encode([
            "success" => true, 
            "message" => "Se ha enviado un email con el enlace de confirmación. Revisa tu bandeja de entrada.",
            "user" => [
                "usuario" => $userData['usuario'],
                "nombres" => $userData['nombres'],
                "apellidos" => $userData['apellidos']
            ]
        ]);
    } else {
        // Si no se puede enviar email, eliminar el token creado
                // ================================================================================
        // 🔥 AUDITORÍA: ANTES DE DELETE (AUNQUE ESTÉ COMENTADO) - GRABAR EN reseteo_clave_hist
        // ================================================================================
        // Si no se puede enviar email, eliminar el token creado
        
        // PRIMERO: Grabar en histórico antes del DELETE
		/*
        $queryTokenParaBorrar = "SELECT * FROM reseteo_clave WHERE token = :token";
        $stmtTokenParaBorrar = $db->prepare($queryTokenParaBorrar);
        $stmtTokenParaBorrar->bindParam(":token", $token);
        $stmtTokenParaBorrar->execute();
        
        if ($stmtTokenParaBorrar->rowCount() > 0) {
            $tokenActual = $stmtTokenParaBorrar->fetch(PDO::FETCH_ASSOC);
            
            // Insertar en reseteo_clave_hist ANTES del DELETE
            $insertReseteoHistQuery = "INSERT INTO reseteo_clave_hist 
                (id, usuario, token, nueva_clave, fecha_expira, utilizado, fecha_utilizado, usu_alta, fecha_alta, usu_mod) 
                VALUES (:id, :usuario, :token, :nueva_clave, :fecha_expira, :utilizado, :fecha_utilizado, :usu_alta, :fecha_alta, :usu_mod)";
            $stmtReseteoHist = $db->prepare($insertReseteoHistQuery);
            $stmtReseteoHist->bindParam(":id", $tokenActual['id']);
            $stmtReseteoHist->bindParam(":usuario", $tokenActual['usuario']);
            $stmtReseteoHist->bindParam(":token", $tokenActual['token']);
            $stmtReseteoHist->bindParam(":nueva_clave", $tokenActual['nueva_clave']);
            $stmtReseteoHist->bindParam(":fecha_expira", $tokenActual['fecha_expira']);
            $stmtReseteoHist->bindParam(":utilizado", $tokenActual['utilizado']);
            $stmtReseteoHist->bindParam(":fecha_utilizado", $tokenActual['fecha_utilizado']);
            $stmtReseteoHist->bindParam(":usu_alta", $tokenActual['usu_alta']);
            $stmtReseteoHist->bindParam(":fecha_alta", $tokenActual['fecha_alta']);
            $stmtReseteoHist->bindParam(":usu_mod", $userData['usuario']); // Usuario que ejecuta el cambio
            $stmtReseteoHist->execute();
        }
        
        // AHORA SÍ: DELETE (aunque esté comentado, preparamos la auditoría)
        
        $deleteQuery = "DELETE FROM reseteo_clave WHERE token = :token";
        $deleteStmt = $db->prepare($deleteQuery);
        $deleteStmt->bindParam(":token", $token);
        $deleteStmt->execute();
        */
        
        http_response_code(500);
        echo json_encode(["error" => "No se pudo enviar el email de confirmación"]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error del servidor: " . $e->getMessage()]);
}
?>

