/*
SQLyog Community
MySQL - 10.4.24-MariaDB : Database - atencionesfsa
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*Table structure for table `reseteo_clave` */

DROP TABLE IF EXISTS reseteo_clave;

CREATE TABLE `reseteo_clave` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `usuario` VARCHAR(255) NOT NULL COMMENT 'Referencia al campo usuario (no correo)',
  `token` VARCHAR(255) NOT NULL,
  `nueva_clave` VARCHAR(255) NOT NULL COMMENT 'Campo agregado para almacenar la nueva contraseña hasheada',
  `fecha_expira` TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL 24 HOUR),
  `utilizado` TINYINT(1) DEFAULT 0,
  fecha_utilizado TIMESTAMP NULL DEFAULT NULL,
  `usu_alta` VARCHAR(50) NOT NULL,
  `fecha_alta` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_token` (`token`),
  KEY `idx_usuario` (`usuario`)
) ENGINE=INNODB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `reseteo_clave` */


DROP TABLE IF EXISTS reseteo_clave_hist;
-- Tabla reseteo_clave_hist (CORREGIDA)
CREATE TABLE `reseteo_clave_hist` (
  `id` INT(11) NOT NULL,
  `usuario` VARCHAR(255) NOT NULL COMMENT 'Referencia al campo usuario (no correo)',
  `token` VARCHAR(255) NOT NULL,
  `nueva_clave` VARCHAR(255) NOT NULL COMMENT 'Campo agregado para almacenar la nueva contraseña hasheada',
  `fecha_expira` TIMESTAMP NOT NULL,
  `utilizado` TINYINT(1) DEFAULT 0,
  `fecha_utilizado` TIMESTAMP NULL DEFAULT NULL,
  `usu_alta` VARCHAR(50) NOT NULL,
  `fecha_alta` TIMESTAMP NULL DEFAULT NULL,
  `usu_mod` VARCHAR(50) NOT NULL,
  `fecha_mod` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `idx_token_hist` (`token`),
  KEY `idx_usuario_hist` (`usuario`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;



DROP TABLE IF EXISTS usuarios;
/*Table structure for table `usuarios` */
CREATE TABLE `usuarios` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `usuario` VARCHAR(255) NOT NULL COMMENT 'Campo usuario agregado (ej: polielb)',
  `correo` VARCHAR(255) NOT NULL COMMENT 'Correo completo (ej: polielb@gmail.com)',
  `clave` VARCHAR(255) NOT NULL,
  `apellidos` VARCHAR(255) NOT NULL,
  `nombres` VARCHAR(255) NOT NULL,
  `dni` VARCHAR(20) NOT NULL,
  `mobil` VARCHAR(20) NOT NULL,
  `activo` TINYINT(1) DEFAULT 1,
  `usu_alta` VARCHAR(50) NOT NULL,
  `fecha_alta` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario` (`usuario`),
  UNIQUE KEY `correo` (`correo`),
  KEY `idx_usuario` (`usuario`),
  KEY `idx_correo` (`correo`)
) ENGINE=INNODB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `usuarios` */

INSERT  INTO `usuarios`(`id`,`usuario`,`correo`,`clave`,`apellidos`,`nombres`,`dni`,`mobil`,`activo`,`usu_alta`,`fecha_alta`) VALUES 
(1,'test','test@example.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Prueba','Usuario','12345678','123456789',1,'','2025-08-05 12:46:36'),
(2,'admin','admin@atencionesfsa.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Administrador','Sistema','87654321','987654321',1,'','2025-08-05 12:46:36'),
(3,'polielb','polielb@gmail.com','$2y$10$.3pgR87FXIWg5pmD8F94K.9AJKuY/XDwA8Z3Jt32O7xGvmSb1AZVy','Beltran','Polidoro','11223344','1234567890',1,'','2025-08-05 12:46:36'),
(4,'romina','romina@clinica.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Garcia','Romina','22334455','2345678901',1,'','2025-08-05 12:46:36'),
(5,'juana','juana@clinica.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Martinez','Juana','33445566','3456789012',1,'','2025-08-05 12:46:36');

DROP TABLE IF EXISTS usuarios_hist;

CREATE TABLE `usuarios_hist` (
  `id` INT(11) NOT NULL,
  `usuario` VARCHAR(255) NOT NULL COMMENT 'Campo usuario agregado (ej: polielb)',
  `correo` VARCHAR(255) NOT NULL COMMENT 'Correo completo (ej: polielb@gmail.com)',
  `clave` VARCHAR(255) NOT NULL,
  `apellidos` VARCHAR(255) NOT NULL,
  `nombres` VARCHAR(255) NOT NULL,
  `dni` VARCHAR(20) NOT NULL,
  `mobil` VARCHAR(20) NOT NULL,
  `activo` TINYINT(1) DEFAULT 1,
  `usu_alta` VARCHAR(50) NOT NULL,
  `fecha_alta` TIMESTAMP NOT NULL,
  `usu_mod` VARCHAR(50) NOT NULL,
  `fecha_mod` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  KEY `id` (`id`),
  KEY `idx_usuario` (`usuario`),
  KEY `idx_correo` (`correo`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;



DROP TABLE IF EXISTS usuarios_relacionados;
/*Table structure for table `usuarios_relacionados` */
CREATE TABLE `usuarios_relacionados` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `usuario_admin` VARCHAR(255) NOT NULL COMMENT 'Usuario que da permisos (ej: ''romina'')',
  `usuario_permitido` VARCHAR(255) NOT NULL COMMENT 'Usuario que recibe permisos (ej: ''juana'')',
  `activo` TINYINT(1) DEFAULT 1,
  `usu_alta` VARCHAR(50) NOT NULL,
  `fecha_alta` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_relation` (`usuario_admin`,`usuario_permitido`),
  KEY `idx_admin` (`usuario_admin`),
  KEY `idx_permitido` (`usuario_permitido`)
) ENGINE=INNODB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `usuarios_relacionados` */

INSERT  INTO `usuarios_relacionados`(`id`,`usuario_admin`,`usuario_permitido`,`activo`,`usu_alta`,`fecha_alta`) VALUES 
(1,'romina','juana',1,'system','2025-08-05 12:46:36'),
(2,'polielb','admin',1,'system','2025-08-05 12:46:36');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
