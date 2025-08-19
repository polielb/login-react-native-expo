/*
SQLyog Community v13.2.1 (64 bit)
MySQL - 10.4.32-MariaDB : Database - atencionesfsa
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`atencionesfsa` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `atencionesfsa`;

/*Table structure for table `reseteo_clave` */

DROP TABLE IF EXISTS `reseteo_clave`;

CREATE TABLE `reseteo_clave` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(255) NOT NULL COMMENT 'Referencia al campo usuario (no correo)',
  `token` varchar(255) NOT NULL,
  `nueva_clave` varchar(255) NOT NULL COMMENT 'Campo agregado para almacenar la nueva contraseña hasheada',
  `fecha_expira` timestamp NOT NULL DEFAULT (current_timestamp() + interval 24 hour),
  `utilizado` tinyint(1) DEFAULT 0,
  `fecha_utilizado` timestamp NULL DEFAULT NULL,
  `usu_alta` varchar(50) NOT NULL,
  `fecha_alta` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_token` (`token`),
  KEY `idx_usuario` (`usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `reseteo_clave` */

/*Table structure for table `reseteo_clave_hist` */

DROP TABLE IF EXISTS `reseteo_clave_hist`;

CREATE TABLE `reseteo_clave_hist` (
  `id` int(11) NOT NULL,
  `usuario` varchar(255) NOT NULL COMMENT 'Referencia al campo usuario (no correo)',
  `token` varchar(255) NOT NULL,
  `nueva_clave` varchar(255) NOT NULL COMMENT 'Campo agregado para almacenar la nueva contraseña hasheada',
  `fecha_expira` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `utilizado` tinyint(1) DEFAULT 0,
  `fecha_utilizado` timestamp NULL DEFAULT NULL,
  `usu_alta` varchar(50) NOT NULL,
  `fecha_alta` timestamp NULL DEFAULT NULL,
  `usu_mod` varchar(50) NOT NULL,
  `fecha_mod` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_token_hist` (`token`),
  KEY `idx_usuario_hist` (`usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `reseteo_clave_hist` */

/*Table structure for table `sesiones` */

DROP TABLE IF EXISTS `sesiones`;

CREATE TABLE `sesiones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL COMMENT 'ID del usuario desde tabla usuarios',
  `token` varchar(255) NOT NULL COMMENT 'Token único de sesión',
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_expiracion` timestamp NOT NULL DEFAULT (current_timestamp() + interval 24 hour),
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'IP del cliente',
  `user_agent` text DEFAULT NULL COMMENT 'Información del navegador/app',
  `activa` tinyint(1) DEFAULT 1 COMMENT '1=activa, 0=cerrada',
  `fecha_ultimo_acceso` timestamp NULL DEFAULT NULL,
  `dispositivo` varchar(50) DEFAULT NULL COMMENT 'web, android, ios',
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_unique` (`token`),
  KEY `idx_usuario_id` (`usuario_id`),
  KEY `idx_token` (`token`),
  KEY `idx_activa` (`activa`),
  KEY `idx_expiracion` (`fecha_expiracion`),
  KEY `idx_sesiones_usuario_activa` (`usuario_id`,`activa`),
  KEY `idx_sesiones_expiracion_activa` (`fecha_expiracion`,`activa`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `sesiones` */

/*Table structure for table `sesiones_hist` */

DROP TABLE IF EXISTS `sesiones_hist`;

CREATE TABLE `sesiones_hist` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_expiracion` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `activa` tinyint(1) DEFAULT 1,
  `fecha_ultimo_acceso` timestamp NULL DEFAULT NULL,
  `dispositivo` varchar(50) DEFAULT NULL,
  `fecha_cierre` timestamp NOT NULL DEFAULT current_timestamp(),
  `motivo_cierre` varchar(100) DEFAULT NULL COMMENT 'logout, expired, forced',
  KEY `idx_usuario_id_hist` (`usuario_id`),
  KEY `idx_token_hist` (`token`),
  KEY `idx_fecha_cierre` (`fecha_cierre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `sesiones_hist` */

/*Table structure for table `usuarios` */

DROP TABLE IF EXISTS `usuarios`;

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(255) NOT NULL COMMENT 'Campo usuario agregado (ej: polielb)',
  `correo` varchar(255) NOT NULL COMMENT 'Correo completo (ej: polielb@gmail.com)',
  `clave` varchar(255) NOT NULL,
  `apellidos` varchar(255) NOT NULL,
  `nombres` varchar(255) NOT NULL,
  `dni` varchar(20) NOT NULL,
  `mobil` varchar(20) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `usu_alta` varchar(50) NOT NULL,
  `fecha_alta` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario` (`usuario`),
  UNIQUE KEY `correo` (`correo`),
  KEY `idx_usuario` (`usuario`),
  KEY `idx_correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `usuarios` */

insert  into `usuarios`(`id`,`usuario`,`correo`,`clave`,`apellidos`,`nombres`,`dni`,`mobil`,`activo`,`usu_alta`,`fecha_alta`) values 
(1,'test','test@example.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Prueba','Usuario','12345678','123456789',1,'','2025-08-05 12:46:36'),
(2,'admin','admin@atencionesfsa.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Administrador','Sistema','87654321','987654321',1,'','2025-08-05 12:46:36'),
(3,'polielb','polielb@gmail.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Beltran','Polidoro','11223344','1234567890',1,'','2025-08-05 12:46:36'),
(4,'romina','romina@clinica.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Garcia','Romina','22334455','2345678901',1,'','2025-08-05 12:46:36'),
(5,'juana','juana@clinica.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Martinez','Juana','33445566','3456789012',1,'','2025-08-05 12:46:36');

/*Table structure for table `usuarios_hist` */

DROP TABLE IF EXISTS `usuarios_hist`;

CREATE TABLE `usuarios_hist` (
  `id` int(11) NOT NULL,
  `usuario` varchar(255) NOT NULL COMMENT 'Campo usuario agregado (ej: polielb)',
  `correo` varchar(255) NOT NULL COMMENT 'Correo completo (ej: polielb@gmail.com)',
  `clave` varchar(255) NOT NULL,
  `apellidos` varchar(255) NOT NULL,
  `nombres` varchar(255) NOT NULL,
  `dni` varchar(20) NOT NULL,
  `mobil` varchar(20) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `usu_alta` varchar(50) NOT NULL,
  `fecha_alta` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `usu_mod` varchar(50) NOT NULL,
  `fecha_mod` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `id` (`id`),
  KEY `idx_usuario` (`usuario`),
  KEY `idx_correo` (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `usuarios_hist` */

/*Table structure for table `usuarios_relacionados` */

DROP TABLE IF EXISTS `usuarios_relacionados`;

CREATE TABLE `usuarios_relacionados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_admin` varchar(255) NOT NULL COMMENT 'Usuario que da permisos (ej: ''romina'')',
  `usuario_permitido` varchar(255) NOT NULL COMMENT 'Usuario que recibe permisos (ej: ''juana'')',
  `activo` tinyint(1) DEFAULT 1,
  `usu_alta` varchar(50) NOT NULL,
  `fecha_alta` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_relation` (`usuario_admin`,`usuario_permitido`),
  KEY `idx_admin` (`usuario_admin`),
  KEY `idx_permitido` (`usuario_permitido`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `usuarios_relacionados` */

insert  into `usuarios_relacionados`(`id`,`usuario_admin`,`usuario_permitido`,`activo`,`usu_alta`,`fecha_alta`) values 
(1,'romina','juana',1,'system','2025-08-05 12:46:36'),
(2,'polielb','admin',1,'system','2025-08-05 12:46:36');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
