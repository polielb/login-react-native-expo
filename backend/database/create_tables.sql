-- ================================================================================
-- ESTRUCTURA COMPLETA DE BASE DE DATOS CORREGIDA
-- backend/database/create_tables_corrected.sql
-- ================================================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS atencionesfsa;
USE atencionesfsa;

-- Tabla de usuarios CORREGIDA
DROP TABLE IF EXISTS usuarios;
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(255) NOT NULL UNIQUE COMMENT "Campo usuario agregado (ej: polielb)",
    correo VARCHAR(255) NOT NULL UNIQUE COMMENT "Correo completo (ej: polielb@gmail.com)",
    clave VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255) NOT NULL,
    nombres VARCHAR(255) NOT NULL,
    dni VARCHAR(20) NOT NULL,
    mobil VARCHAR(20) NOT NULL,
    activo TINYINT(1) DEFAULT 1,
    usu_alta VARCHAR(50) NOT NULL,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuario (usuario),
    INDEX idx_correo (correo)
);

-- Tabla de reseteo de clave CORREGIDA
DROP TABLE IF EXISTS reseteo_clave;
CREATE TABLE reseteo_clave (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(255) NOT NULL         COMMENT "Referencia al campo usuario (no correo)",
    token VARCHAR(255) NOT NULL UNIQUE,
    nueva_clave VARCHAR(255) NOT NULL     COMMENT "Campo agregado para almacenar la nueva contraseña hasheada",
    fecha_expira TIMESTAMP NOT NULL,
    utilizado TINYINT(1) DEFAULT 0,
    usu_alta VARCHAR(50) NOT NULL,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_token (token),
    INDEX idx_usuario (usuario)
);

-- Tabla de usuarios relacionados (para permisos)
DROP TABLE IF EXISTS usuarios_relacionados;
CREATE TABLE usuarios_relacionados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_admin VARCHAR(255) NOT NULL  COMMENT "Usuario que da permisos (ej: 'romina')",
    usuario_permitido VARCHAR(255) NOT NULL COMMENT "Usuario que recibe permisos (ej: 'juana')",
    activo TINYINT(1) DEFAULT 1,
    usu_alta VARCHAR(50) NOT NULL,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_relation (usuario_admin, usuario_permitido),
    INDEX idx_admin (usuario_admin),
    INDEX idx_permitido (usuario_permitido)  
);

-- ================================================================================
-- DATOS DE PRUEBA
-- ================================================================================

-- Insertar usuarios de prueba
INSERT INTO usuarios (usuario, correo, clave, apellidos, nombres, dni, mobil) 
VALUES 
    -- Contraseña: "12345" para todos (para testing)
    ('test', 'test@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Prueba', 'Usuario', '12345678', '123456789'),
    ('admin', 'admin@atencionesfsa.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador', 'Sistema', '87654321', '987654321'),
    ('polielb', 'polielb@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Beltran', 'Polidoro', '11223344', '1234567890'),
    ('romina', 'romina@clinica.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Garcia', 'Romina', '22334455', '2345678901'),
    ('juana', 'juana@clinica.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Martinez', 'Juana', '33445566', '3456789012');

-- Insertar relaciones de usuarios (romina permite que juana vea sus datos)
INSERT INTO usuarios_relacionados (usuario_admin, usuario_permitido, usu_alta) 
VALUES 
    ('romina', 'juana', 'system'),
    ('polielb', 'admin', 'system');
