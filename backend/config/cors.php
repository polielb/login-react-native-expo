<?php
// ================================================================================
// CORS BÁSICO - config/cors.php
// ================================================================================

// Headers CORS básicos
//header("Access-Control-Allow-Origin: http://localhost:8081");
header("Access-Control-Allow-Origin: http://192.168.16.20:8081");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json; charset=UTF-8");

// Manejar peticiones OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Respuesta exitosa para preflight
    http_response_code(200);
    exit(0);
}
?>