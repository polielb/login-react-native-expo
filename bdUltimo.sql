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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `reseteo_clave` */

insert  into `reseteo_clave`(`id`,`usuario`,`token`,`nueva_clave`,`fecha_expira`,`utilizado`,`fecha_utilizado`,`usu_alta`,`fecha_alta`) values 
(14,'polielb','1f92f1df7614272dc2e75bbd9e1f494764f21325558b11933838bd13e1e513f5','$2y$10$LhPTnJYDmGrq9s1Q81ow9.tj8lDuZ2.zlKyJ5Mpek.uvN3/zTVbBq','2025-08-19 17:33:17',1,'2025-08-18 12:33:44','','2025-08-18 12:33:17');

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

insert  into `reseteo_clave_hist`(`id`,`usuario`,`token`,`nueva_clave`,`fecha_expira`,`utilizado`,`fecha_utilizado`,`usu_alta`,`fecha_alta`,`usu_mod`,`fecha_mod`) values 
(14,'polielb','1f92f1df7614272dc2e75bbd9e1f494764f21325558b11933838bd13e1e513f5','$2y$10$LhPTnJYDmGrq9s1Q81ow9.tj8lDuZ2.zlKyJ5Mpek.uvN3/zTVbBq','2025-08-19 17:33:17',0,NULL,'','2025-08-18 12:33:17','polielb','2025-08-18 12:33:44');

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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish2_ci;

/*Data for the table `sesiones` */

insert  into `sesiones`(`id`,`usuario_id`,`token`,`fecha_creacion`,`fecha_expiracion`,`ip_address`,`user_agent`,`activa`,`fecha_ultimo_acceso`,`dispositivo`) values 
(5,3,'d51fb9937fffb5cf7c5d329adc824bca64579e40767d515c5e2aad955a811052','2025-08-18 12:33:58','2025-08-19 12:33:58','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-18 12:37:32','web'),
(6,3,'4d3c8edb7f4fffc218a657abfcebc28e759f1cd51804d1b74a3aadb4af9a63bf','2025-08-18 12:37:46','2025-08-19 12:37:46','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-18 12:41:45','web'),
(7,3,'b41aafaac59ddb4f94ba61283770a2c1b103517c62081e59d3c139640d3ed8fb','2025-08-18 12:42:14','2025-08-19 12:42:14','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 09:28:28','web'),
(8,3,'a5c81d6652a0f88729645e11e8d47b203a8e6dc2fdc243132247a9758adf453f','2025-08-18 12:47:46','2025-08-19 12:47:46','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36',1,'2025-08-18 12:48:13','web'),
(9,3,'8cc780846e97f5b664a2d76554b319fe7f09d3a4290444e965454ba9d1df90ad','2025-08-19 09:19:32','2025-08-20 09:19:32','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 09:19:32','web'),
(10,3,'2be6ae19306c43ac5c83a191ab8898701c103a6a7842783c9e5c8e3c329e40c0','2025-08-19 09:28:45','2025-08-19 09:28:45','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 09:28:45','web'),
(11,3,'fff717652d58d9708e0e424ec76c638fb8215cfa401cd2fa85eafe324246b396','2025-08-19 10:33:59','2025-08-19 10:30:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 10:33:59','web'),
(12,3,'08d18f9ce8caacf76506cc60d4401f7ce791394ab1260f93f9a5f5149ed879ff','2025-08-19 10:36:45','2025-08-20 10:36:45','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 10:36:45','web'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 10:51:07','web'),
(14,3,'8c35e2614e7d54c9a9bd47bc1903e850c5756c2fc35e0b879e71f337477d32b8','2025-08-19 10:51:42','2025-08-20 10:51:42','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 10:51:42','web'),
(15,3,'8c06c3706e96d5078020bf40fb8d56dbcf2b4bc502d1464e7ca4760144ea4e26','2025-08-19 10:51:50','2025-08-20 10:51:50','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 10:54:27','web'),
(16,3,'7b836fbc166758963041ff2a7a87ec2fed2705dc670e4ea18b2a5324c1780336','2025-08-19 10:54:43','2025-08-20 10:54:43','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 10:54:43','web'),
(17,3,'64c86ec52a55444f5fe24355c661d064d18e8464e160a885b3eb2f2f1288fe01','2025-08-19 10:54:59','2025-08-20 10:54:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 10:54:59','web'),
(18,3,'ea91106615bb19e68d3072ee5cd54b60cc4c37c74e8c2af50517d99b9569b7f4','2025-08-19 11:00:04','2025-08-20 11:00:04','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 11:00:05','web'),
(19,3,'0254fee2761d653b731df04c2d517bf7b044ed8d1db5c43ee93b8ccea3aba759','2025-08-19 11:00:15','2025-08-20 11:00:15','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 11:00:15','web'),
(20,3,'2536ce528f51233f3712d9334c76b5d9563f75a7a66a9409c690f2883af3801a','2025-08-19 11:00:28','2025-08-20 11:00:28','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 11:00:28','web'),
(21,3,'94816e28c15d5de9990a5624d4248852948c9560d7aa1eb582627d8a64bfd75f','2025-08-19 11:05:21','2025-08-20 11:05:21','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',0,'2025-08-19 11:05:21','web');

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

insert  into `sesiones_hist`(`id`,`usuario_id`,`token`,`fecha_creacion`,`fecha_expiracion`,`ip_address`,`user_agent`,`activa`,`fecha_ultimo_acceso`,`dispositivo`,`fecha_cierre`,`motivo_cierre`) values 
(5,3,'d51fb9937fffb5cf7c5d329adc824bca64579e40767d515c5e2aad955a811052','2025-08-18 12:33:58','2025-08-19 12:33:58','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-18 12:37:32','web','2025-08-18 12:37:35','logout'),
(6,3,'4d3c8edb7f4fffc218a657abfcebc28e759f1cd51804d1b74a3aadb4af9a63bf','2025-08-18 12:37:46','2025-08-19 12:37:46','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-18 12:41:45','web','2025-08-18 12:41:47','logout'),
(7,3,'b41aafaac59ddb4f94ba61283770a2c1b103517c62081e59d3c139640d3ed8fb','2025-08-18 12:42:14','2025-08-19 12:42:14','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 09:28:28','web','2025-08-19 09:28:39','logout'),
(10,3,'2be6ae19306c43ac5c83a191ab8898701c103a6a7842783c9e5c8e3c329e40c0','2025-08-19 09:28:45','2025-08-19 09:28:45','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 09:28:45','web','2025-08-19 10:33:59','expired'),
(10,3,'2be6ae19306c43ac5c83a191ab8898701c103a6a7842783c9e5c8e3c329e40c0','2025-08-19 09:28:45','2025-08-19 09:28:45','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 09:28:45','web','2025-08-19 10:33:59','session_closed'),
(11,3,'fff717652d58d9708e0e424ec76c638fb8215cfa401cd2fa85eafe324246b396','2025-08-19 10:33:59','2025-08-20 10:33:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:33:59','web','2025-08-19 10:33:59','data_modified'),
(11,3,'fff717652d58d9708e0e424ec76c638fb8215cfa401cd2fa85eafe324246b396','2025-08-19 10:33:59','2025-08-20 10:33:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:33:59','web','2025-08-19 10:35:07','session_renewed'),
(11,3,'fff717652d58d9708e0e424ec76c638fb8215cfa401cd2fa85eafe324246b396','2025-08-19 10:33:59','2025-08-19 10:30:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:33:59','web','2025-08-19 10:36:45','expired'),
(11,3,'fff717652d58d9708e0e424ec76c638fb8215cfa401cd2fa85eafe324246b396','2025-08-19 10:33:59','2025-08-19 10:30:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:33:59','web','2025-08-19 10:36:45','session_closed'),
(12,3,'08d18f9ce8caacf76506cc60d4401f7ce791394ab1260f93f9a5f5149ed879ff','2025-08-19 10:36:45','2025-08-20 10:36:45','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:36:45','web','2025-08-19 10:36:45','data_modified'),
(12,3,'08d18f9ce8caacf76506cc60d4401f7ce791394ab1260f93f9a5f5149ed879ff','2025-08-19 10:36:45','2025-08-20 10:36:45','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:36:45','web','2025-08-19 10:37:44','logout'),
(12,3,'08d18f9ce8caacf76506cc60d4401f7ce791394ab1260f93f9a5f5149ed879ff','2025-08-19 10:36:45','2025-08-20 10:36:45','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:36:45','web','2025-08-19 10:37:44','session_closed'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:38:12','web','2025-08-19 10:38:12','data_modified'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:38:12','web','2025-08-19 10:48:36','access_updated'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:48:36','web','2025-08-19 10:48:36','data_modified'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:48:36','web','2025-08-19 10:51:07','access_updated'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:07','web','2025-08-19 10:51:07','data_modified'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:07','web','2025-08-19 10:51:34','logout'),
(13,3,'f7b96c97407cef564df308c3665a0b5a14fed371752b7faafba21d24ee40abcb','2025-08-19 10:38:12','2025-08-20 10:38:12','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:07','web','2025-08-19 10:51:34','session_closed'),
(14,3,'8c35e2614e7d54c9a9bd47bc1903e850c5756c2fc35e0b879e71f337477d32b8','2025-08-19 10:51:42','2025-08-20 10:51:42','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:42','web','2025-08-19 10:51:42','data_modified'),
(14,3,'8c35e2614e7d54c9a9bd47bc1903e850c5756c2fc35e0b879e71f337477d32b8','2025-08-19 10:51:42','2025-08-20 10:51:42','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:42','web','2025-08-19 10:51:44','logout'),
(14,3,'8c35e2614e7d54c9a9bd47bc1903e850c5756c2fc35e0b879e71f337477d32b8','2025-08-19 10:51:42','2025-08-20 10:51:42','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:42','web','2025-08-19 10:51:44','session_closed'),
(15,3,'8c06c3706e96d5078020bf40fb8d56dbcf2b4bc502d1464e7ca4760144ea4e26','2025-08-19 10:51:50','2025-08-20 10:51:50','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:50','web','2025-08-19 10:51:50','data_modified'),
(15,3,'8c06c3706e96d5078020bf40fb8d56dbcf2b4bc502d1464e7ca4760144ea4e26','2025-08-19 10:51:50','2025-08-20 10:51:50','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:51:50','web','2025-08-19 10:54:27','access_updated'),
(15,3,'8c06c3706e96d5078020bf40fb8d56dbcf2b4bc502d1464e7ca4760144ea4e26','2025-08-19 10:51:50','2025-08-20 10:51:50','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:27','web','2025-08-19 10:54:27','data_modified'),
(15,3,'8c06c3706e96d5078020bf40fb8d56dbcf2b4bc502d1464e7ca4760144ea4e26','2025-08-19 10:51:50','2025-08-20 10:51:50','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:27','web','2025-08-19 10:54:31','logout'),
(15,3,'8c06c3706e96d5078020bf40fb8d56dbcf2b4bc502d1464e7ca4760144ea4e26','2025-08-19 10:51:50','2025-08-20 10:51:50','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:27','web','2025-08-19 10:54:31','session_closed'),
(16,3,'7b836fbc166758963041ff2a7a87ec2fed2705dc670e4ea18b2a5324c1780336','2025-08-19 10:54:43','2025-08-20 10:54:43','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:43','web','2025-08-19 10:54:43','data_modified'),
(16,3,'7b836fbc166758963041ff2a7a87ec2fed2705dc670e4ea18b2a5324c1780336','2025-08-19 10:54:43','2025-08-20 10:54:43','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:43','web','2025-08-19 10:54:44','logout'),
(16,3,'7b836fbc166758963041ff2a7a87ec2fed2705dc670e4ea18b2a5324c1780336','2025-08-19 10:54:43','2025-08-20 10:54:43','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:43','web','2025-08-19 10:54:44','session_closed'),
(17,3,'64c86ec52a55444f5fe24355c661d064d18e8464e160a885b3eb2f2f1288fe01','2025-08-19 10:54:59','2025-08-20 10:54:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:59','web','2025-08-19 10:54:59','data_modified'),
(17,3,'64c86ec52a55444f5fe24355c661d064d18e8464e160a885b3eb2f2f1288fe01','2025-08-19 10:54:59','2025-08-20 10:54:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:59','web','2025-08-19 10:55:04','logout'),
(17,3,'64c86ec52a55444f5fe24355c661d064d18e8464e160a885b3eb2f2f1288fe01','2025-08-19 10:54:59','2025-08-20 10:54:59','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 10:54:59','web','2025-08-19 10:55:04','session_closed'),
(18,3,'ea91106615bb19e68d3072ee5cd54b60cc4c37c74e8c2af50517d99b9569b7f4','2025-08-19 11:00:04','2025-08-20 11:00:04','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:04','web','2025-08-19 11:00:05','access_updated'),
(18,3,'ea91106615bb19e68d3072ee5cd54b60cc4c37c74e8c2af50517d99b9569b7f4','2025-08-19 11:00:04','2025-08-20 11:00:04','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:05','web','2025-08-19 11:00:08','logout'),
(18,3,'ea91106615bb19e68d3072ee5cd54b60cc4c37c74e8c2af50517d99b9569b7f4','2025-08-19 11:00:04','2025-08-20 11:00:04','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:05','web','2025-08-19 11:00:08','session_closed'),
(19,3,'0254fee2761d653b731df04c2d517bf7b044ed8d1db5c43ee93b8ccea3aba759','2025-08-19 11:00:15','2025-08-20 11:00:15','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:15','web','2025-08-19 11:00:15','data_modified'),
(19,3,'0254fee2761d653b731df04c2d517bf7b044ed8d1db5c43ee93b8ccea3aba759','2025-08-19 11:00:15','2025-08-20 11:00:15','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:15','web','2025-08-19 11:00:19','logout'),
(19,3,'0254fee2761d653b731df04c2d517bf7b044ed8d1db5c43ee93b8ccea3aba759','2025-08-19 11:00:15','2025-08-20 11:00:15','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:15','web','2025-08-19 11:00:19','session_closed'),
(20,3,'2536ce528f51233f3712d9334c76b5d9563f75a7a66a9409c690f2883af3801a','2025-08-19 11:00:28','2025-08-20 11:00:28','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:28','web','2025-08-19 11:00:28','data_modified'),
(20,3,'2536ce528f51233f3712d9334c76b5d9563f75a7a66a9409c690f2883af3801a','2025-08-19 11:00:28','2025-08-20 11:00:28','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:28','web','2025-08-19 11:01:56','logout'),
(20,3,'2536ce528f51233f3712d9334c76b5d9563f75a7a66a9409c690f2883af3801a','2025-08-19 11:00:28','2025-08-20 11:00:28','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:00:28','web','2025-08-19 11:01:56','session_closed'),
(21,3,'94816e28c15d5de9990a5624d4248852948c9560d7aa1eb582627d8a64bfd75f','2025-08-19 11:05:21','2025-08-20 11:05:21','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:05:21','web','2025-08-19 11:05:21','data_modified'),
(21,3,'94816e28c15d5de9990a5624d4248852948c9560d7aa1eb582627d8a64bfd75f','2025-08-19 11:05:21','2025-08-20 11:05:21','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:05:21','web','2025-08-19 11:05:29','logout'),
(21,3,'94816e28c15d5de9990a5624d4248852948c9560d7aa1eb582627d8a64bfd75f','2025-08-19 11:05:21','2025-08-20 11:05:21','192.168.16.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',1,'2025-08-19 11:05:21','web','2025-08-19 11:05:29','session_closed');

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
(3,'polielb','polielb@gmail.com','$2y$10$LhPTnJYDmGrq9s1Q81ow9.tj8lDuZ2.zlKyJ5Mpek.uvN3/zTVbBq','Beltran','Polidoro','11223344','1234567890',1,'','2025-08-05 12:46:36'),
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

insert  into `usuarios_hist`(`id`,`usuario`,`correo`,`clave`,`apellidos`,`nombres`,`dni`,`mobil`,`activo`,`usu_alta`,`fecha_alta`,`usu_mod`,`fecha_mod`) values 
(3,'polielb','polielb@gmail.com','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Beltran','Polidoro','11223344','1234567890',1,'','2025-08-05 12:46:36','polielb','2025-08-18 12:33:44');

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
