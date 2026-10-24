-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: labquim
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `labquim`
--

/*!40000 DROP DATABASE IF EXISTS `labquim`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `labquim` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `labquim`;

--
-- Table structure for table `articulos`
--

DROP TABLE IF EXISTS `articulos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `articulos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `tipo` enum('REACTIVO','CRISTALERIA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `categoria_id` int unsigned NOT NULL,
  `unidad_id` int unsigned NOT NULL,
  `stock_minimo` decimal(14,3) NOT NULL DEFAULT '0.000',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_articulos_codigo` (`codigo`),
  KEY `idx_articulos_categoria` (`categoria_id`),
  KEY `idx_articulos_unidad` (`unidad_id`),
  KEY `idx_articulos_tipo` (`tipo`),
  CONSTRAINT `fk_articulos_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`),
  CONSTRAINT `fk_articulos_unidad` FOREIGN KEY (`unidad_id`) REFERENCES `unidades_medida` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `articulos`
--

LOCK TABLES `articulos` WRITE;
/*!40000 ALTER TABLE `articulos` DISABLE KEYS */;
INSERT INTO `articulos` VALUES (1,'REACTIVO','RX-001','Ácido clorhídrico',1,1,20.000,1,'2026-09-23 09:53:03','2026-10-12 14:06:40'),(2,'CRISTALERIA','MT-001','Bureta 50 mL',6,7,2.000,0,'2026-09-23 09:53:03','2026-10-15 13:36:11'),(3,'REACTIVO','Ro1A1-A.Et-001','ACETATO DE ETILO',4,1,5.000,1,'2026-10-12 14:22:04',NULL),(4,'CRISTALERIA','CR-001','Tubo de vidrio fusible 5 mm',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(5,'CRISTALERIA','CR-002','Tubo de vidrio fusible 10 mm',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(6,'CRISTALERIA','CR-003','Balón redondo de fondo plano 250 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(7,'CRISTALERIA','CR-004','Balón redondo de fondo plano 300 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(8,'CRISTALERIA','CR-005','Beaker 250 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(9,'CRISTALERIA','CR-006','Beaker 200 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(10,'CRISTALERIA','CR-007','Tubos de ensayo mediano',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(11,'CRISTALERIA','CR-008','Tubos de ensayo pequeño',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(12,'CRISTALERIA','CR-009','Viscosímetro capilar',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(13,'CRISTALERIA','CR-010','Matraz de fondo redondo 30 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(14,'CRISTALERIA','CR-011','Matraz de fondo redondo 50 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(15,'CRISTALERIA','CR-012','Tubos de ensayo pequeño de plástico',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(16,'CRISTALERIA','CR-013','Beaker 200 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(17,'CRISTALERIA','CR-014','Beaker 100 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(18,'CRISTALERIA','CR-015','Beaker 50 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(19,'CRISTALERIA','CR-016','Condensador de Liebig',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(20,'CRISTALERIA','CR-017','Adaptador de junta esmerilada',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(21,'CRISTALERIA','CR-018','Extractor Soxhlet',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(22,'CRISTALERIA','CR-019','Columna de destilación Snyder',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(23,'CRISTALERIA','CR-020','Embudo de decantación',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(24,'CRISTALERIA','CR-021','Condensador en espiral',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(25,'CRISTALERIA','CR-022','Destilación combranda',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(26,'CRISTALERIA','CR-023','Adaptador o cabezal de destilación',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(27,'CRISTALERIA','CR-024','Condensador simple',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(28,'CRISTALERIA','CR-025','Condensador de espiral pequeño',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(29,'CRISTALERIA','CR-026','Condensador en espiral mediano',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(30,'CRISTALERIA','CR-027','Trampa de Dean-Stark',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(31,'CRISTALERIA','CR-028','Condensador Allihn',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(32,'CRISTALERIA','CR-029','Embudo de adición con igualación de presión',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(33,'CRISTALERIA','CR-030','Condensador en espiral',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(34,'CRISTALERIA','CR-031','Viscosímetro capilar vidrio Cannon-Fenske',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(35,'CRISTALERIA','CR-032','Llave de pase de vidrio',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(36,'CRISTALERIA','CR-033','Tubo de vidrio fusible 5 mm',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(37,'CRISTALERIA','CR-034','Tubo de vidrio fusible 10 mm',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(38,'CRISTALERIA','CR-035','Balón redondo de fondo redondo 100 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(39,'CRISTALERIA','CR-036','Balón redondo de fondo redondo 50 mL',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(40,'CRISTALERIA','CR-037','Embudo de vacío',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(41,'CRISTALERIA','CR-038','Condensador simple',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(42,'CRISTALERIA','CR-039','Condensador de espiral',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(43,'CRISTALERIA','CR-040','Condensador fraccionado',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(44,'CRISTALERIA','CR-041','Bloque de tubos',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(45,'CRISTALERIA','CR-042','Matraz de destilación múltiples',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(46,'CRISTALERIA','CR-043','Matraz de destilación de 3 bocas',9,7,0.000,1,'2026-10-15 13:39:08',NULL),(47,'CRISTALERIA','CR-044','Embudo de densidades',8,7,0.000,1,'2026-10-15 13:39:08',NULL),(48,'CRISTALERIA','CR-045','Condensador simple pequeño',9,7,0.000,1,'2026-10-15 13:39:09',NULL),(49,'CRISTALERIA','CR-046','Tubo de vidrio para aceites',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(50,'CRISTALERIA','CR-047','Buretas',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(51,'CRISTALERIA','CR-048','Matraz redondo (cromatografía)',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(52,'CRISTALERIA','CR-049','Tubo de vidrio de cuarzo',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(53,'CRISTALERIA','CR-050','Bureta de recolección de aceite',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(54,'CRISTALERIA','CR-051','Columna de vidrio',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(55,'CRISTALERIA','CR-052','Adaptadores',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(56,'CRISTALERIA','CR-053','Bureta de vidrio 50 mL',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(57,'CRISTALERIA','CR-054','Buretas de plástico 50 mL',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(58,'CRISTALERIA','CR-055','Bureta de vidrio 25 mL',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(59,'CRISTALERIA','CR-056','Adaptadores de 4 entradas',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(60,'CRISTALERIA','CR-057','Adaptadores de 3 entradas',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(61,'CRISTALERIA','CR-058','Adaptadores pequeños de 4 entradas',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(62,'CRISTALERIA','CR-059','Adaptadores de dos entradas',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(63,'CRISTALERIA','CR-060','Condensador pequeño fraccionado',9,7,0.000,1,'2026-10-15 13:39:09',NULL),(64,'CRISTALERIA','CR-061','Condensador pequeño simple',9,7,0.000,1,'2026-10-15 13:39:09',NULL),(65,'CRISTALERIA','CR-062','Destilación fraccionada',9,7,0.000,1,'2026-10-15 13:39:09',NULL),(66,'CRISTALERIA','CR-063','Matraz redondo',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(67,'CRISTALERIA','CR-064','Desecador',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(68,'CRISTALERIA','CR-065','Desecador en caja',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(69,'CRISTALERIA','CR-066','Botellas tipo garrafas',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(70,'CRISTALERIA','CR-067','Cucharas para ignición',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(71,'CRISTALERIA','CR-068','Pinzas',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(72,'CRISTALERIA','CR-069','Densímetro 40 a 90',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(73,'CRISTALERIA','CR-070','Densímetro 1000',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(74,'CRISTALERIA','CR-071','Densímetro 1300',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(75,'CRISTALERIA','CR-072','Densímetro 710',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(76,'CRISTALERIA','CR-073','Densímetro 1550',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(77,'CRISTALERIA','CR-074','Densímetro 1030',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(78,'CRISTALERIA','CR-075','Densímetro 1850',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(79,'CRISTALERIA','CR-076','Cámara de gases',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(80,'CRISTALERIA','CR-077','Placa',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(81,'CRISTALERIA','CR-078','Tubo de ensayo No. 9800',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(82,'CRISTALERIA','CR-079','Tubo de ensayo 13 x 100ml',8,7,0.000,1,'2026-10-15 13:39:09',NULL),(83,'CRISTALERIA','CR-080','Cajas con varios paquetes de tubo de ensayo No. 9800',8,8,0.000,1,'2026-10-15 13:39:09',NULL);
/*!40000 ALTER TABLE `articulos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria`
--

DROP TABLE IF EXISTS `auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned DEFAULT NULL,
  `entidad` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entidad_id` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `accion` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `valores_antes` json DEFAULT NULL,
  `valores_despues` json DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_aud_entidad` (`entidad`,`entidad_id`),
  KEY `idx_aud_usuario` (`usuario_id`),
  KEY `idx_aud_fecha` (`fecha`),
  CONSTRAINT `fk_aud_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,4,'lotes','1','ENTRADA',NULL,'{\"lote\": 1, \"cantidad\": 50.0, \"articulo_id\": 1, \"vencimiento\": \"2026-01-01\"}','2026-09-23 09:53:03'),(2,4,'lotes','2','ENTRADA',NULL,'{\"lote\": 2, \"cantidad\": 80.0, \"articulo_id\": 1, \"vencimiento\": \"2027-01-01\"}','2026-09-23 09:53:03'),(3,4,'lotes','3','ENTRADA',NULL,'{\"lote\": 3, \"cantidad\": 10.0, \"articulo_id\": 2, \"vencimiento\": null}','2026-09-23 09:53:03'),(4,2,'solicitudes','1','CREAR',NULL,'{\"estado\": \"PENDIENTE\", \"lineas\": 2, \"laboratorio_id\": 1}','2026-09-23 09:53:03'),(5,3,'solicitudes','1','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-09-23 09:53:03'),(6,4,'solicitudes','1','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 4}','2026-09-23 09:53:03'),(7,4,'solicitudes','1','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"ENTREGADA\"}','2026-09-23 09:53:03'),(8,4,'solicitudes','1','DEVOLVER','{\"estado\": \"ENTREGADA\"}','{\"estado\": \"CERRADA\", \"materiales_reingresados\": 1}','2026-09-23 09:53:03'),(9,1,'usuarios','5','CREAR',NULL,'{\"rol_id\": 5, \"usuario\": \"ana\"}','2026-09-23 10:23:28'),(10,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\", \"reporte.ver\"]}','2026-09-23 10:29:11'),(11,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\"]}','2026-09-23 10:29:12'),(12,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\", \"reporte.ver\"]}','2026-09-23 10:29:32'),(13,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\"]}','2026-09-23 10:29:32'),(14,1,'proveedores','1','CREAR',NULL,'{\"nombre\": \"Química Meléndez S.A.\"}','2026-09-23 13:31:34'),(15,1,'proveedores','1','EDITAR',NULL,'{\"nombre\": \"Química Meléndez S.A.\"}','2026-09-23 13:31:35'),(16,1,'proveedores','1','DESACTIVAR',NULL,'{\"activo\": 0}','2026-09-23 13:31:35'),(17,2,'solicitudes','2','CREAR',NULL,'{\"estado\": \"PENDIENTE\", \"lineas\": 2, \"laboratorio_id\": 1}','2026-10-05 14:18:20'),(18,3,'solicitudes','2','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-10-05 14:32:38'),(19,4,'solicitudes','2','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 6}','2026-10-05 14:33:31'),(20,4,'solicitudes','2','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"ENTREGADA\"}','2026-10-05 14:33:38'),(21,4,'solicitudes','2','DEVOLVER','{\"estado\": \"ENTREGADA\"}','{\"estado\": \"CERRADA\", \"materiales_reingresados\": 1}','2026-10-05 14:34:29'),(22,1,'articulos','1','DESACTIVAR','{\"activo\": 1}','{\"activo\": 0}','2026-10-10 21:13:40'),(23,1,'articulos','1','ACTIVAR','{\"activo\": 0}','{\"activo\": 1}','2026-10-10 21:13:43'),(24,1,'articulos','1','DESACTIVAR','{\"activo\": 1}','{\"activo\": 0}','2026-10-10 21:17:07'),(25,1,'articulos','1','ACTIVAR','{\"activo\": 0}','{\"activo\": 1}','2026-10-10 21:17:10'),(26,1,'usuarios','3','DESACTIVAR','{\"activo\": 1}','{\"activo\": 0}','2026-10-10 21:20:05'),(27,1,'usuarios','3','ACTIVAR','{\"activo\": 0}','{\"activo\": 1}','2026-10-10 21:20:10'),(28,1,'usuarios','6','CREAR',NULL,'{\"rol_id\": 5, \"usuario\": \"clopez\"}','2026-10-10 21:39:54'),(29,1,'laboratorios','2','CREAR',NULL,'{\"nombre\": \"Laboratorio 2do piso \"}','2026-10-10 22:09:07'),(30,1,'usuarios','7','CREAR',NULL,'{\"rol_id\": 3, \"usuario\": \"jorge\"}','2026-10-10 22:10:13'),(31,1,'laboratorios','2','DESACTIVAR',NULL,'{\"activo\": 0}','2026-10-10 22:15:02'),(32,1,'laboratorios','2','ACTIVAR',NULL,'{\"activo\": 1}','2026-10-10 22:15:03'),(33,1,'clases','1','CREAR',NULL,'{\"anio\": 1, \"nombre\": \"Quimica 1\", \"profesores\": [7, 2]}','2026-10-10 22:15:26'),(34,1,'usuarios','2','EDITAR','{\"rol_id\": 3}','{\"codigo\": \"PROF-001\", \"rol_id\": 3, \"nombres\": \"PROF\", \"apellidos\": \"DEMO\"}','2026-10-10 22:20:06'),(35,1,'usuarios','7','EDITAR','{\"rol_id\": 3}','{\"codigo\": \"PROF-002\", \"rol_id\": 3, \"nombres\": \"JORGE\", \"apellidos\": \"CISNE\"}','2026-10-10 22:20:13'),(36,1,'usuarios','5','EDITAR','{\"rol_id\": 5}','{\"codigo\": \"EST-001\", \"rol_id\": 5, \"nombres\": \"ANA\", \"apellidos\": \"ESTUDIANTE\"}','2026-10-10 22:20:25'),(37,1,'usuarios','6','EDITAR','{\"rol_id\": 5}','{\"codigo\": \"EST-002\", \"rol_id\": 5, \"nombres\": \"CRISTEL ALEJANDRA\", \"apellidos\": \"LOPEZ SOLIS\"}','2026-10-10 22:20:37'),(38,1,'practicas','1','CREAR',NULL,'{\"nombre\": \"Principios de Quimica 1\", \"clase_id\": 1, \"laboratorio_id\": 2}','2026-10-10 22:40:50'),(39,5,'solicitudes','3','CREAR',NULL,'{\"tipo\": \"REACTIVO\", \"estado\": \"PENDIENTE_PROFESOR\", \"lineas\": 1, \"practica_id\": 1, \"profesor_id\": 7, \"estudiante_id\": 5, \"laboratorio_id\": 2}','2026-10-10 22:54:10'),(40,1,'usuarios','7','CAMBIAR_PASSWORD',NULL,'{\"cambiado\": true}','2026-10-10 22:55:13'),(41,7,'solicitudes','3','AVALAR','{\"estado\": \"PENDIENTE_PROFESOR\"}','{\"estado\": \"PENDIENTE\"}','2026-10-10 22:55:32'),(42,6,'solicitudes','4','CREAR',NULL,'{\"tipo\": \"REACTIVO\", \"estado\": \"PENDIENTE_PROFESOR\", \"lineas\": 1, \"practica_id\": 1, \"profesor_id\": 7, \"estudiante_id\": 6, \"laboratorio_id\": 2}','2026-10-10 23:21:01'),(43,6,'solicitudes','5','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"estado\": \"PENDIENTE_PROFESOR\", \"lineas\": 1, \"practica_id\": 1, \"profesor_id\": 7, \"estudiante_id\": 6, \"laboratorio_id\": 2}','2026-10-10 23:21:33'),(44,7,'solicitudes','5','RECHAZAR_PROFESOR','{\"estado\": \"PENDIENTE_PROFESOR\"}','{\"estado\": \"RECHAZADA\", \"motivo\": \"solo chiquitos\"}','2026-10-10 23:22:16'),(45,7,'solicitudes','4','AVALAR','{\"estado\": \"PENDIENTE_PROFESOR\"}','{\"estado\": \"PENDIENTE\"}','2026-10-10 23:23:15'),(46,3,'solicitudes','4','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-10-10 23:23:41'),(47,4,'solicitudes','4','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 8}','2026-10-10 23:24:13'),(48,4,'solicitudes','4','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"CERRADA\"}','2026-10-10 23:24:17'),(49,1,'articulos','1','DESACTIVAR','{\"activo\": 1}','{\"activo\": 0}','2026-10-12 14:06:38'),(50,1,'articulos','1','ACTIVAR','{\"activo\": 0}','{\"activo\": 1}','2026-10-12 14:06:40'),(51,1,'clases','2','CREAR',NULL,'{\"anio\": 2, \"nombre\": \"QUIMICA GENERAL 2\", \"profesores\": [7]}','2026-10-12 14:07:50'),(52,1,'practicas','2','CREAR',NULL,'{\"nombre\": \"TERMINACION DE ACIDEZ\", \"clase_id\": 2, \"laboratorio_id\": 1}','2026-10-12 14:08:22'),(53,5,'solicitudes','6','CREAR',NULL,'{\"tipo\": \"REACTIVO\", \"estado\": \"PENDIENTE_PROFESOR\", \"lineas\": 1, \"practica_id\": 2, \"profesor_id\": 7, \"estudiante_id\": 5, \"laboratorio_id\": 1}','2026-10-12 14:09:59'),(54,7,'solicitudes','6','AVALAR','{\"estado\": \"PENDIENTE_PROFESOR\"}','{\"estado\": \"PENDIENTE\"}','2026-10-12 14:10:31'),(55,3,'solicitudes','6','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-10-12 14:10:50'),(56,1,'articulos','3','CREAR',NULL,'{\"tipo\": \"REACTIVO\", \"codigo\": \"Ro1A1-A.Et-001\", \"nombre\": \"ACETATO DE ETILO\"}','2026-10-12 14:22:04'),(57,1,'lotes','4','ENTRADA',NULL,'{\"lote\": 4, \"cantidad\": 90.000, \"articulo_id\": 3, \"vencimiento\": \"2026-10-13\"}','2026-10-12 14:23:01'),(58,5,'solicitudes','7','CREAR',NULL,'{\"tipo\": \"REACTIVO\", \"estado\": \"PENDIENTE_PROFESOR\", \"lineas\": 2, \"practica_id\": 2, \"profesor_id\": 7, \"estudiante_id\": 5, \"laboratorio_id\": 1}','2026-10-12 14:24:43'),(59,7,'solicitudes','7','AVALAR','{\"estado\": \"PENDIENTE_PROFESOR\"}','{\"estado\": \"PENDIENTE\"}','2026-10-12 14:27:13'),(60,3,'solicitudes','7','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-10-12 14:29:17'),(61,4,'solicitudes','7','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 10}','2026-10-12 14:30:28'),(62,4,'solicitudes','7','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"CERRADA\"}','2026-10-12 14:30:35'),(63,1,'articulos','2','EDITAR','{\"nombre\": \"Bureta 50 mL\"}','{\"nombre\": \"Bureta 50 mL\", \"stock_minimo\": 2.000}','2026-10-14 09:56:05'),(64,1,'solicitudes','6','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 11}','2026-10-15 12:50:00'),(65,1,'solicitudes','6','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"CERRADA\"}','2026-10-15 12:50:01'),(66,1,'solicitudes','3','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-10-15 12:50:11'),(67,1,'solicitudes','3','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 12}','2026-10-15 12:50:14'),(68,1,'solicitudes','3','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"CERRADA\"}','2026-10-15 12:50:17'),(69,6,'solicitudes','8','CREAR',NULL,'{\"tipo\": \"REACTIVO\", \"estado\": \"PENDIENTE_PROFESOR\", \"lineas\": 1, \"practica_id\": 2, \"profesor_id\": 7, \"estudiante_id\": 6, \"laboratorio_id\": 1}','2026-10-15 12:58:35'),(70,6,'solicitudes','9','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"estado\": \"PENDIENTE_PROFESOR\", \"lineas\": 1, \"practica_id\": 2, \"profesor_id\": 7, \"estudiante_id\": 6, \"laboratorio_id\": 1}','2026-10-15 12:59:08'),(71,1,'articulos','2','DESACTIVAR','{\"activo\": 1}','{\"activo\": 0}','2026-10-15 13:36:11'),(72,1,'categorias','8','CREAR',NULL,'{\"nombre\": \"Cristalería general\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(73,1,'ubicaciones','5','CREAR',NULL,'{\"nombre\": \"Bodega de cristalería\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(74,1,'articulos','4','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-001\", \"nombre\": \"Tubo de vidrio fusible 5 mm\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(75,1,'lotes','5','ENTRADA',NULL,'{\"lote\": 5, \"origen\": \"importacion\", \"cantidad\": 50.000, \"articulo_id\": 4}','2026-10-15 13:39:08'),(76,1,'articulos','5','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-002\", \"nombre\": \"Tubo de vidrio fusible 10 mm\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(77,1,'lotes','6','ENTRADA',NULL,'{\"lote\": 6, \"origen\": \"importacion\", \"cantidad\": 50.000, \"articulo_id\": 5}','2026-10-15 13:39:08'),(78,1,'articulos','6','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-003\", \"nombre\": \"Balón redondo de fondo plano 250 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(79,1,'lotes','7','ENTRADA',NULL,'{\"lote\": 7, \"origen\": \"importacion\", \"cantidad\": 34.000, \"articulo_id\": 6}','2026-10-15 13:39:08'),(80,1,'articulos','7','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-004\", \"nombre\": \"Balón redondo de fondo plano 300 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(81,1,'lotes','8','ENTRADA',NULL,'{\"lote\": 8, \"origen\": \"importacion\", \"cantidad\": 6.000, \"articulo_id\": 7}','2026-10-15 13:39:08'),(82,1,'articulos','8','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-005\", \"nombre\": \"Beaker 250 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(83,1,'lotes','9','ENTRADA',NULL,'{\"lote\": 9, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 8}','2026-10-15 13:39:08'),(84,1,'articulos','9','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-006\", \"nombre\": \"Beaker 200 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(85,1,'lotes','10','ENTRADA',NULL,'{\"lote\": 10, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 9}','2026-10-15 13:39:08'),(86,1,'articulos','10','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-007\", \"nombre\": \"Tubos de ensayo mediano\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(87,1,'lotes','11','ENTRADA',NULL,'{\"lote\": 11, \"origen\": \"importacion\", \"cantidad\": 3.000, \"articulo_id\": 10}','2026-10-15 13:39:08'),(88,1,'articulos','11','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-008\", \"nombre\": \"Tubos de ensayo pequeño\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(89,1,'lotes','12','ENTRADA',NULL,'{\"lote\": 12, \"origen\": \"importacion\", \"cantidad\": 37.000, \"articulo_id\": 11}','2026-10-15 13:39:08'),(90,1,'articulos','12','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-009\", \"nombre\": \"Viscosímetro capilar\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(91,1,'lotes','13','ENTRADA',NULL,'{\"lote\": 13, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 12}','2026-10-15 13:39:08'),(92,1,'articulos','13','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-010\", \"nombre\": \"Matraz de fondo redondo 30 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(93,1,'lotes','14','ENTRADA',NULL,'{\"lote\": 14, \"origen\": \"importacion\", \"cantidad\": 139.000, \"articulo_id\": 13}','2026-10-15 13:39:08'),(94,1,'articulos','14','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-011\", \"nombre\": \"Matraz de fondo redondo 50 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(95,1,'lotes','15','ENTRADA',NULL,'{\"lote\": 15, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 14}','2026-10-15 13:39:08'),(96,1,'articulos','15','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-012\", \"nombre\": \"Tubos de ensayo pequeño de plástico\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(97,1,'lotes','16','ENTRADA',NULL,'{\"lote\": 16, \"origen\": \"importacion\", \"cantidad\": 22.000, \"articulo_id\": 15}','2026-10-15 13:39:08'),(98,1,'articulos','16','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-013\", \"nombre\": \"Beaker 200 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(99,1,'lotes','17','ENTRADA',NULL,'{\"lote\": 17, \"origen\": \"importacion\", \"cantidad\": 17.000, \"articulo_id\": 16}','2026-10-15 13:39:08'),(100,1,'articulos','17','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-014\", \"nombre\": \"Beaker 100 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(101,1,'lotes','18','ENTRADA',NULL,'{\"lote\": 18, \"origen\": \"importacion\", \"cantidad\": 12.000, \"articulo_id\": 17}','2026-10-15 13:39:08'),(102,1,'articulos','18','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-015\", \"nombre\": \"Beaker 50 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(103,1,'lotes','19','ENTRADA',NULL,'{\"lote\": 19, \"origen\": \"importacion\", \"cantidad\": 17.000, \"articulo_id\": 18}','2026-10-15 13:39:08'),(104,1,'categorias','9','CREAR',NULL,'{\"nombre\": \"Destilación\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(105,1,'articulos','19','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-016\", \"nombre\": \"Condensador de Liebig\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(106,1,'lotes','20','ENTRADA',NULL,'{\"lote\": 20, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 19}','2026-10-15 13:39:08'),(107,1,'articulos','20','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-017\", \"nombre\": \"Adaptador de junta esmerilada\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(108,1,'lotes','21','ENTRADA',NULL,'{\"lote\": 21, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 20}','2026-10-15 13:39:08'),(109,1,'articulos','21','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-018\", \"nombre\": \"Extractor Soxhlet\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(110,1,'lotes','22','ENTRADA',NULL,'{\"lote\": 22, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 21}','2026-10-15 13:39:08'),(111,1,'articulos','22','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-019\", \"nombre\": \"Columna de destilación Snyder\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(112,1,'lotes','23','ENTRADA',NULL,'{\"lote\": 23, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 22}','2026-10-15 13:39:08'),(113,1,'articulos','23','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-020\", \"nombre\": \"Embudo de decantación\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(114,1,'lotes','24','ENTRADA',NULL,'{\"lote\": 24, \"origen\": \"importacion\", \"cantidad\": 3.000, \"articulo_id\": 23}','2026-10-15 13:39:08'),(115,1,'articulos','24','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-021\", \"nombre\": \"Condensador en espiral\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(116,1,'lotes','25','ENTRADA',NULL,'{\"lote\": 25, \"origen\": \"importacion\", \"cantidad\": 4.000, \"articulo_id\": 24}','2026-10-15 13:39:08'),(117,1,'articulos','25','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-022\", \"nombre\": \"Destilación combranda\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(118,1,'lotes','26','ENTRADA',NULL,'{\"lote\": 26, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 25}','2026-10-15 13:39:08'),(119,1,'articulos','26','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-023\", \"nombre\": \"Adaptador o cabezal de destilación\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(120,1,'lotes','27','ENTRADA',NULL,'{\"lote\": 27, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 26}','2026-10-15 13:39:08'),(121,1,'articulos','27','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-024\", \"nombre\": \"Condensador simple\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(122,1,'lotes','28','ENTRADA',NULL,'{\"lote\": 28, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 27}','2026-10-15 13:39:08'),(123,1,'articulos','28','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-025\", \"nombre\": \"Condensador de espiral pequeño\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(124,1,'lotes','29','ENTRADA',NULL,'{\"lote\": 29, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 28}','2026-10-15 13:39:08'),(125,1,'articulos','29','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-026\", \"nombre\": \"Condensador en espiral mediano\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(126,1,'lotes','30','ENTRADA',NULL,'{\"lote\": 30, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 29}','2026-10-15 13:39:08'),(127,1,'articulos','30','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-027\", \"nombre\": \"Trampa de Dean-Stark\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(128,1,'lotes','31','ENTRADA',NULL,'{\"lote\": 31, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 30}','2026-10-15 13:39:08'),(129,1,'articulos','31','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-028\", \"nombre\": \"Condensador Allihn\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(130,1,'lotes','32','ENTRADA',NULL,'{\"lote\": 32, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 31}','2026-10-15 13:39:08'),(131,1,'articulos','32','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-029\", \"nombre\": \"Embudo de adición con igualación de presión\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(132,1,'lotes','33','ENTRADA',NULL,'{\"lote\": 33, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 32}','2026-10-15 13:39:08'),(133,1,'articulos','33','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-030\", \"nombre\": \"Condensador en espiral\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(134,1,'lotes','34','ENTRADA',NULL,'{\"lote\": 34, \"origen\": \"importacion\", \"cantidad\": 4.000, \"articulo_id\": 33}','2026-10-15 13:39:08'),(135,1,'articulos','34','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-031\", \"nombre\": \"Viscosímetro capilar vidrio Cannon-Fenske\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(136,1,'lotes','35','ENTRADA',NULL,'{\"lote\": 35, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 34}','2026-10-15 13:39:08'),(137,1,'articulos','35','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-032\", \"nombre\": \"Llave de pase de vidrio\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(138,1,'lotes','36','ENTRADA',NULL,'{\"lote\": 36, \"origen\": \"importacion\", \"cantidad\": 6.000, \"articulo_id\": 35}','2026-10-15 13:39:08'),(139,1,'articulos','36','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-033\", \"nombre\": \"Tubo de vidrio fusible 5 mm\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(140,1,'lotes','37','ENTRADA',NULL,'{\"lote\": 37, \"origen\": \"importacion\", \"cantidad\": 5.000, \"articulo_id\": 36}','2026-10-15 13:39:08'),(141,1,'articulos','37','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-034\", \"nombre\": \"Tubo de vidrio fusible 10 mm\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(142,1,'lotes','38','ENTRADA',NULL,'{\"lote\": 38, \"origen\": \"importacion\", \"cantidad\": 9.000, \"articulo_id\": 37}','2026-10-15 13:39:08'),(143,1,'articulos','38','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-035\", \"nombre\": \"Balón redondo de fondo redondo 100 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(144,1,'lotes','39','ENTRADA',NULL,'{\"lote\": 39, \"origen\": \"importacion\", \"cantidad\": 71.000, \"articulo_id\": 38}','2026-10-15 13:39:08'),(145,1,'articulos','39','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-036\", \"nombre\": \"Balón redondo de fondo redondo 50 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(146,1,'lotes','40','ENTRADA',NULL,'{\"lote\": 40, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 39}','2026-10-15 13:39:08'),(147,1,'articulos','40','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-037\", \"nombre\": \"Embudo de vacío\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(148,1,'lotes','41','ENTRADA',NULL,'{\"lote\": 41, \"origen\": \"importacion\", \"cantidad\": 20.000, \"articulo_id\": 40}','2026-10-15 13:39:08'),(149,1,'articulos','41','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-038\", \"nombre\": \"Condensador simple\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(150,1,'lotes','42','ENTRADA',NULL,'{\"lote\": 42, \"origen\": \"importacion\", \"cantidad\": 4.000, \"articulo_id\": 41}','2026-10-15 13:39:08'),(151,1,'articulos','42','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-039\", \"nombre\": \"Condensador de espiral\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(152,1,'lotes','43','ENTRADA',NULL,'{\"lote\": 43, \"origen\": \"importacion\", \"cantidad\": 12.000, \"articulo_id\": 42}','2026-10-15 13:39:08'),(153,1,'articulos','43','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-040\", \"nombre\": \"Condensador fraccionado\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(154,1,'lotes','44','ENTRADA',NULL,'{\"lote\": 44, \"origen\": \"importacion\", \"cantidad\": 9.000, \"articulo_id\": 43}','2026-10-15 13:39:08'),(155,1,'articulos','44','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-041\", \"nombre\": \"Bloque de tubos\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(156,1,'lotes','45','ENTRADA',NULL,'{\"lote\": 45, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 44}','2026-10-15 13:39:08'),(157,1,'articulos','45','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-042\", \"nombre\": \"Matraz de destilación múltiples\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(158,1,'lotes','46','ENTRADA',NULL,'{\"lote\": 46, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 45}','2026-10-15 13:39:08'),(159,1,'articulos','46','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-043\", \"nombre\": \"Matraz de destilación de 3 bocas\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(160,1,'lotes','47','ENTRADA',NULL,'{\"lote\": 47, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 46}','2026-10-15 13:39:08'),(161,1,'articulos','47','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-044\", \"nombre\": \"Embudo de densidades\", \"origen\": \"importacion\"}','2026-10-15 13:39:08'),(162,1,'lotes','48','ENTRADA',NULL,'{\"lote\": 48, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 47}','2026-10-15 13:39:08'),(163,1,'articulos','48','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-045\", \"nombre\": \"Condensador simple pequeño\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(164,1,'lotes','49','ENTRADA',NULL,'{\"lote\": 49, \"origen\": \"importacion\", \"cantidad\": 8.000, \"articulo_id\": 48}','2026-10-15 13:39:09'),(165,1,'articulos','49','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-046\", \"nombre\": \"Tubo de vidrio para aceites\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(166,1,'lotes','50','ENTRADA',NULL,'{\"lote\": 50, \"origen\": \"importacion\", \"cantidad\": 8.000, \"articulo_id\": 49}','2026-10-15 13:39:09'),(167,1,'articulos','50','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-047\", \"nombre\": \"Buretas\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(168,1,'lotes','51','ENTRADA',NULL,'{\"lote\": 51, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 50}','2026-10-15 13:39:09'),(169,1,'articulos','51','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-048\", \"nombre\": \"Matraz redondo (cromatografía)\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(170,1,'lotes','52','ENTRADA',NULL,'{\"lote\": 52, \"origen\": \"importacion\", \"cantidad\": 4.000, \"articulo_id\": 51}','2026-10-15 13:39:09'),(171,1,'articulos','52','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-049\", \"nombre\": \"Tubo de vidrio de cuarzo\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(172,1,'lotes','53','ENTRADA',NULL,'{\"lote\": 53, \"origen\": \"importacion\", \"cantidad\": 7.000, \"articulo_id\": 52}','2026-10-15 13:39:09'),(173,1,'articulos','53','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-050\", \"nombre\": \"Bureta de recolección de aceite\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(174,1,'lotes','54','ENTRADA',NULL,'{\"lote\": 54, \"origen\": \"importacion\", \"cantidad\": 3.000, \"articulo_id\": 53}','2026-10-15 13:39:09'),(175,1,'articulos','54','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-051\", \"nombre\": \"Columna de vidrio\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(176,1,'lotes','55','ENTRADA',NULL,'{\"lote\": 55, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 54}','2026-10-15 13:39:09'),(177,1,'articulos','55','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-052\", \"nombre\": \"Adaptadores\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(178,1,'lotes','56','ENTRADA',NULL,'{\"lote\": 56, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 55}','2026-10-15 13:39:09'),(179,1,'articulos','56','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-053\", \"nombre\": \"Bureta de vidrio 50 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(180,1,'lotes','57','ENTRADA',NULL,'{\"lote\": 57, \"origen\": \"importacion\", \"cantidad\": 6.000, \"articulo_id\": 56}','2026-10-15 13:39:09'),(181,1,'articulos','57','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-054\", \"nombre\": \"Buretas de plástico 50 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(182,1,'lotes','58','ENTRADA',NULL,'{\"lote\": 58, \"origen\": \"importacion\", \"cantidad\": 17.000, \"articulo_id\": 57}','2026-10-15 13:39:09'),(183,1,'articulos','58','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-055\", \"nombre\": \"Bureta de vidrio 25 mL\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(184,1,'lotes','59','ENTRADA',NULL,'{\"lote\": 59, \"origen\": \"importacion\", \"cantidad\": 5.000, \"articulo_id\": 58}','2026-10-15 13:39:09'),(185,1,'articulos','59','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-056\", \"nombre\": \"Adaptadores de 4 entradas\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(186,1,'lotes','60','ENTRADA',NULL,'{\"lote\": 60, \"origen\": \"importacion\", \"cantidad\": 3.000, \"articulo_id\": 59}','2026-10-15 13:39:09'),(187,1,'articulos','60','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-057\", \"nombre\": \"Adaptadores de 3 entradas\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(188,1,'lotes','61','ENTRADA',NULL,'{\"lote\": 61, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 60}','2026-10-15 13:39:09'),(189,1,'articulos','61','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-058\", \"nombre\": \"Adaptadores pequeños de 4 entradas\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(190,1,'lotes','62','ENTRADA',NULL,'{\"lote\": 62, \"origen\": \"importacion\", \"cantidad\": 3.000, \"articulo_id\": 61}','2026-10-15 13:39:09'),(191,1,'articulos','62','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-059\", \"nombre\": \"Adaptadores de dos entradas\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(192,1,'lotes','63','ENTRADA',NULL,'{\"lote\": 63, \"origen\": \"importacion\", \"cantidad\": 7.000, \"articulo_id\": 62}','2026-10-15 13:39:09'),(193,1,'articulos','63','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-060\", \"nombre\": \"Condensador pequeño fraccionado\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(194,1,'lotes','64','ENTRADA',NULL,'{\"lote\": 64, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 63}','2026-10-15 13:39:09'),(195,1,'articulos','64','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-061\", \"nombre\": \"Condensador pequeño simple\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(196,1,'lotes','65','ENTRADA',NULL,'{\"lote\": 65, \"origen\": \"importacion\", \"cantidad\": 10.000, \"articulo_id\": 64}','2026-10-15 13:39:09'),(197,1,'articulos','65','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-062\", \"nombre\": \"Destilación fraccionada\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(198,1,'lotes','66','ENTRADA',NULL,'{\"lote\": 66, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 65}','2026-10-15 13:39:09'),(199,1,'articulos','66','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-063\", \"nombre\": \"Matraz redondo\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(200,1,'lotes','67','ENTRADA',NULL,'{\"lote\": 67, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 66}','2026-10-15 13:39:09'),(201,1,'ubicaciones','6','CREAR',NULL,'{\"nombre\": \"Cristalería\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(202,1,'articulos','67','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-064\", \"nombre\": \"Desecador\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(203,1,'lotes','68','ENTRADA',NULL,'{\"lote\": 68, \"origen\": \"importacion\", \"cantidad\": 9.000, \"articulo_id\": 67}','2026-10-15 13:39:09'),(204,1,'ubicaciones','7','CREAR',NULL,'{\"nombre\": \"Laboratorio 3\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(205,1,'articulos','68','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-065\", \"nombre\": \"Desecador en caja\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(206,1,'lotes','69','ENTRADA',NULL,'{\"lote\": 69, \"origen\": \"importacion\", \"cantidad\": 30.000, \"articulo_id\": 68}','2026-10-15 13:39:09'),(207,1,'articulos','69','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-066\", \"nombre\": \"Botellas tipo garrafas\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(208,1,'lotes','70','ENTRADA',NULL,'{\"lote\": 70, \"origen\": \"importacion\", \"cantidad\": 4.000, \"articulo_id\": 69}','2026-10-15 13:39:09'),(209,1,'articulos','70','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-067\", \"nombre\": \"Cucharas para ignición\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(210,1,'lotes','71','ENTRADA',NULL,'{\"lote\": 71, \"origen\": \"importacion\", \"cantidad\": 23.000, \"articulo_id\": 70}','2026-10-15 13:39:09'),(211,1,'articulos','71','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-068\", \"nombre\": \"Pinzas\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(212,1,'lotes','72','ENTRADA',NULL,'{\"lote\": 72, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 71}','2026-10-15 13:39:09'),(213,1,'articulos','72','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-069\", \"nombre\": \"Densímetro 40 a 90\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(214,1,'lotes','73','ENTRADA',NULL,'{\"lote\": 73, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 72}','2026-10-15 13:39:09'),(215,1,'articulos','73','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-070\", \"nombre\": \"Densímetro 1000\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(216,1,'lotes','74','ENTRADA',NULL,'{\"lote\": 74, \"origen\": \"importacion\", \"cantidad\": 2.000, \"articulo_id\": 73}','2026-10-15 13:39:09'),(217,1,'articulos','74','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-071\", \"nombre\": \"Densímetro 1300\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(218,1,'lotes','75','ENTRADA',NULL,'{\"lote\": 75, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 74}','2026-10-15 13:39:09'),(219,1,'articulos','75','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-072\", \"nombre\": \"Densímetro 710\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(220,1,'lotes','76','ENTRADA',NULL,'{\"lote\": 76, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 75}','2026-10-15 13:39:09'),(221,1,'articulos','76','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-073\", \"nombre\": \"Densímetro 1550\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(222,1,'lotes','77','ENTRADA',NULL,'{\"lote\": 77, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 76}','2026-10-15 13:39:09'),(223,1,'articulos','77','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-074\", \"nombre\": \"Densímetro 1030\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(224,1,'lotes','78','ENTRADA',NULL,'{\"lote\": 78, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 77}','2026-10-15 13:39:09'),(225,1,'articulos','78','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-075\", \"nombre\": \"Densímetro 1850\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(226,1,'lotes','79','ENTRADA',NULL,'{\"lote\": 79, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 78}','2026-10-15 13:39:09'),(227,1,'articulos','79','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-076\", \"nombre\": \"Cámara de gases\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(228,1,'lotes','80','ENTRADA',NULL,'{\"lote\": 80, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 79}','2026-10-15 13:39:09'),(229,1,'articulos','80','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-077\", \"nombre\": \"Placa\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(230,1,'lotes','81','ENTRADA',NULL,'{\"lote\": 81, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 80}','2026-10-15 13:39:09'),(231,1,'articulos','81','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-078\", \"nombre\": \"Tubo de ensayo No. 9800\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(232,1,'lotes','82','ENTRADA',NULL,'{\"lote\": 82, \"origen\": \"importacion\", \"cantidad\": 23.000, \"articulo_id\": 81}','2026-10-15 13:39:09'),(233,1,'articulos','82','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-079\", \"nombre\": \"Tubo de ensayo 13 x 100ml\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(234,1,'lotes','83','ENTRADA',NULL,'{\"lote\": 83, \"origen\": \"importacion\", \"cantidad\": 20.000, \"articulo_id\": 82}','2026-10-15 13:39:09'),(235,1,'articulos','83','CREAR',NULL,'{\"tipo\": \"CRISTALERIA\", \"codigo\": \"CR-080\", \"nombre\": \"Cajas con varios paquetes de tubo de ensayo No. 9800\", \"origen\": \"importacion\"}','2026-10-15 13:39:09'),(236,1,'lotes','84','ENTRADA',NULL,'{\"lote\": 84, \"origen\": \"importacion\", \"cantidad\": 1.000, \"articulo_id\": 83}','2026-10-15 13:39:09');
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categorias_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Ácido','Reactivos ácidos',1),(2,'Base','Reactivos básicos/álcalis',1),(3,'Solvente','Disolventes orgánicos e inorgánicos',1),(4,'Sal','Sales inorgánicas',1),(5,'Indicador','Indicadores de pH y colorimétricos',1),(6,'Material volumétrico','Cristalería de medición (buretas, pipetas, matraces)',1),(7,'Equipo','Equipo e instrumental de laboratorio',1),(8,'Cristalería general',NULL,1),(9,'Destilación',NULL,1);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clase_profesor`
--

DROP TABLE IF EXISTS `clase_profesor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clase_profesor` (
  `clase_id` int unsigned NOT NULL,
  `profesor_id` int unsigned NOT NULL,
  PRIMARY KEY (`clase_id`,`profesor_id`),
  KEY `idx_cp_profesor` (`profesor_id`),
  CONSTRAINT `fk_cp_clase` FOREIGN KEY (`clase_id`) REFERENCES `clases` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clase_profesor`
--

LOCK TABLES `clase_profesor` WRITE;
/*!40000 ALTER TABLE `clase_profesor` DISABLE KEYS */;
INSERT INTO `clase_profesor` VALUES (1,2),(1,7),(2,7);
/*!40000 ALTER TABLE `clase_profesor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clases`
--

DROP TABLE IF EXISTS `clases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clases` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `anio` tinyint unsigned NOT NULL,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_clases_anio_nombre` (`anio`,`nombre`),
  CONSTRAINT `ck_clases_anio` CHECK ((`anio` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clases`
--

LOCK TABLES `clases` WRITE;
/*!40000 ALTER TABLE `clases` DISABLE KEYS */;
INSERT INTO `clases` VALUES (1,1,'Quimica 1','Quimica 1',1),(2,2,'QUIMICA GENERAL 2','QUIMICA GENERAL 2',1);
/*!40000 ALTER TABLE `clases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `laboratorios`
--

DROP TABLE IF EXISTS `laboratorios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `laboratorios` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_laboratorios_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `laboratorios`
--

LOCK TABLES `laboratorios` WRITE;
/*!40000 ALTER TABLE `laboratorios` DISABLE KEYS */;
INSERT INTO `laboratorios` VALUES (1,'Práctica de Química General',NULL,1),(2,'Laboratorio 2do piso ','Laboratorio 2do piso',1);
/*!40000 ALTER TABLE `laboratorios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lotes`
--

DROP TABLE IF EXISTS `lotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lotes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `articulo_id` int unsigned NOT NULL,
  `codigo_lote` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `cantidad_actual` decimal(14,3) NOT NULL DEFAULT '0.000',
  `proveedor_id` int unsigned DEFAULT NULL,
  `ubicacion_id` int unsigned DEFAULT NULL,
  `fecha_ingreso` date NOT NULL DEFAULT (curdate()),
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_lotes_articulo` (`articulo_id`),
  KEY `idx_lotes_proveedor` (`proveedor_id`),
  KEY `idx_lotes_ubicacion` (`ubicacion_id`),
  KEY `idx_lotes_fefo` (`articulo_id`,`fecha_vencimiento`),
  CONSTRAINT `fk_lotes_articulo` FOREIGN KEY (`articulo_id`) REFERENCES `articulos` (`id`),
  CONSTRAINT `fk_lotes_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`),
  CONSTRAINT `fk_lotes_ubicacion` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`),
  CONSTRAINT `chk_lotes_cantidad` CHECK ((`cantidad_actual` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lotes`
--

LOCK TABLES `lotes` WRITE;
/*!40000 ALTER TABLE `lotes` DISABLE KEYS */;
INSERT INTO `lotes` VALUES (1,1,'RX-L-A','2026-01-01',0.000,NULL,NULL,'2026-09-23',1),(2,1,'RX-L-B','2027-01-01',19.000,NULL,NULL,'2026-09-23',1),(3,2,'MT-L-1',NULL,10.000,NULL,NULL,'2026-09-23',1),(4,3,'001','2026-10-13',1.000,NULL,4,'2026-10-12',1),(5,4,NULL,NULL,50.000,NULL,5,'2026-10-15',1),(6,5,NULL,NULL,50.000,NULL,5,'2026-10-15',1),(7,6,NULL,NULL,34.000,NULL,5,'2026-10-15',1),(8,7,NULL,NULL,6.000,NULL,5,'2026-10-15',1),(9,8,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(10,9,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(11,10,NULL,NULL,3.000,NULL,5,'2026-10-15',1),(12,11,NULL,NULL,37.000,NULL,5,'2026-10-15',1),(13,12,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(14,13,NULL,NULL,139.000,NULL,5,'2026-10-15',1),(15,14,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(16,15,NULL,NULL,22.000,NULL,5,'2026-10-15',1),(17,16,NULL,NULL,17.000,NULL,5,'2026-10-15',1),(18,17,NULL,NULL,12.000,NULL,5,'2026-10-15',1),(19,18,NULL,NULL,17.000,NULL,5,'2026-10-15',1),(20,19,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(21,20,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(22,21,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(23,22,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(24,23,NULL,NULL,3.000,NULL,5,'2026-10-15',1),(25,24,NULL,NULL,4.000,NULL,5,'2026-10-15',1),(26,25,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(27,26,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(28,27,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(29,28,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(30,29,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(31,30,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(32,31,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(33,32,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(34,33,NULL,NULL,4.000,NULL,5,'2026-10-15',1),(35,34,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(36,35,NULL,NULL,6.000,NULL,5,'2026-10-15',1),(37,36,NULL,NULL,5.000,NULL,5,'2026-10-15',1),(38,37,NULL,NULL,9.000,NULL,5,'2026-10-15',1),(39,38,NULL,NULL,71.000,NULL,5,'2026-10-15',1),(40,39,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(41,40,NULL,NULL,20.000,NULL,5,'2026-10-15',1),(42,41,NULL,NULL,4.000,NULL,5,'2026-10-15',1),(43,42,NULL,NULL,12.000,NULL,5,'2026-10-15',1),(44,43,NULL,NULL,9.000,NULL,5,'2026-10-15',1),(45,44,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(46,45,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(47,46,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(48,47,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(49,48,NULL,NULL,8.000,NULL,5,'2026-10-15',1),(50,49,NULL,NULL,8.000,NULL,5,'2026-10-15',1),(51,50,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(52,51,NULL,NULL,4.000,NULL,5,'2026-10-15',1),(53,52,NULL,NULL,7.000,NULL,5,'2026-10-15',1),(54,53,NULL,NULL,3.000,NULL,5,'2026-10-15',1),(55,54,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(56,55,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(57,56,NULL,NULL,6.000,NULL,5,'2026-10-15',1),(58,57,NULL,NULL,17.000,NULL,5,'2026-10-15',1),(59,58,NULL,NULL,5.000,NULL,5,'2026-10-15',1),(60,59,NULL,NULL,3.000,NULL,5,'2026-10-15',1),(61,60,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(62,61,NULL,NULL,3.000,NULL,5,'2026-10-15',1),(63,62,NULL,NULL,7.000,NULL,5,'2026-10-15',1),(64,63,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(65,64,NULL,NULL,10.000,NULL,5,'2026-10-15',1),(66,65,NULL,NULL,1.000,NULL,5,'2026-10-15',1),(67,66,NULL,NULL,2.000,NULL,5,'2026-10-15',1),(68,67,NULL,NULL,9.000,NULL,6,'2026-10-15',1),(69,68,NULL,NULL,30.000,NULL,7,'2026-10-15',1),(70,69,NULL,NULL,4.000,NULL,7,'2026-10-15',1),(71,70,NULL,NULL,23.000,NULL,6,'2026-10-15',1),(72,71,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(73,72,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(74,73,NULL,NULL,2.000,NULL,6,'2026-10-15',1),(75,74,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(76,75,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(77,76,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(78,77,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(79,78,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(80,79,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(81,80,NULL,NULL,1.000,NULL,6,'2026-10-15',1),(82,81,NULL,NULL,23.000,NULL,6,'2026-10-15',1),(83,82,NULL,NULL,20.000,NULL,6,'2026-10-15',1),(84,83,NULL,NULL,1.000,NULL,6,'2026-10-15',1);
/*!40000 ALTER TABLE `lotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimiento_detalle`
--

DROP TABLE IF EXISTS `movimiento_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimiento_detalle` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `movimiento_id` int unsigned NOT NULL,
  `lote_id` int unsigned NOT NULL,
  `cantidad` decimal(14,3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_md_movimiento` (`movimiento_id`),
  KEY `idx_md_lote` (`lote_id`),
  CONSTRAINT `fk_md_lote` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id`),
  CONSTRAINT `fk_md_movimiento` FOREIGN KEY (`movimiento_id`) REFERENCES `movimientos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimiento_detalle`
--

LOCK TABLES `movimiento_detalle` WRITE;
/*!40000 ALTER TABLE `movimiento_detalle` DISABLE KEYS */;
INSERT INTO `movimiento_detalle` VALUES (1,1,1,50.000),(2,2,2,80.000),(3,3,3,10.000),(4,4,1,50.000),(5,4,2,20.000),(6,4,3,4.000),(7,5,3,4.000),(8,6,2,10.000),(9,6,3,2.000),(10,7,3,2.000),(11,8,2,10.000),(12,9,4,90.000),(13,10,4,89.000),(14,10,2,1.000),(15,11,2,10.000),(16,12,2,10.000),(17,13,5,50.000),(18,13,6,50.000),(19,13,7,34.000),(20,13,8,6.000),(21,13,9,2.000),(22,13,10,1.000),(23,13,11,3.000),(24,13,12,37.000),(25,13,13,1.000),(26,13,14,139.000),(27,13,15,1.000),(28,13,16,22.000),(29,13,17,17.000),(30,13,18,12.000),(31,13,19,17.000),(32,13,20,1.000),(33,13,21,1.000),(34,13,22,1.000),(35,13,23,2.000),(36,13,24,3.000),(37,13,25,4.000),(38,13,26,1.000),(39,13,27,1.000),(40,13,28,1.000),(41,13,29,1.000),(42,13,30,1.000),(43,13,31,1.000),(44,13,32,1.000),(45,13,33,2.000),(46,13,34,4.000),(47,13,35,1.000),(48,13,36,6.000),(49,13,37,5.000),(50,13,38,9.000),(51,13,39,71.000),(52,13,40,2.000),(53,13,41,20.000),(54,13,42,4.000),(55,13,43,12.000),(56,13,44,9.000),(57,13,45,2.000),(58,13,46,1.000),(59,13,47,1.000),(60,13,48,1.000),(61,13,49,8.000),(62,13,50,8.000),(63,13,51,2.000),(64,13,52,4.000),(65,13,53,7.000),(66,13,54,3.000),(67,13,55,2.000),(68,13,56,2.000),(69,13,57,6.000),(70,13,58,17.000),(71,13,59,5.000),(72,13,60,3.000),(73,13,61,2.000),(74,13,62,3.000),(75,13,63,7.000),(76,13,64,2.000),(77,13,65,10.000),(78,13,66,1.000),(79,13,67,2.000),(80,13,68,9.000),(81,13,69,30.000),(82,13,70,4.000),(83,13,71,23.000),(84,13,72,1.000),(85,13,73,1.000),(86,13,74,2.000),(87,13,75,1.000),(88,13,76,1.000),(89,13,77,1.000),(90,13,78,1.000),(91,13,79,1.000),(92,13,80,1.000),(93,13,81,1.000),(94,13,82,23.000),(95,13,83,20.000),(96,13,84,1.000);
/*!40000 ALTER TABLE `movimiento_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimientos`
--

DROP TABLE IF EXISTS `movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimientos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `tipo` enum('ENTRADA','SALIDA','AJUSTE','DEVOLUCION') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int unsigned NOT NULL,
  `laboratorio_id` int unsigned DEFAULT NULL,
  `solicitud_id` int unsigned DEFAULT NULL,
  `motivo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_mov_tipo` (`tipo`),
  KEY `idx_mov_fecha` (`fecha`),
  KEY `idx_mov_usuario` (`usuario_id`),
  KEY `idx_mov_solicitud` (`solicitud_id`),
  KEY `fk_mov_laboratorio` (`laboratorio_id`),
  CONSTRAINT `fk_mov_laboratorio` FOREIGN KEY (`laboratorio_id`) REFERENCES `laboratorios` (`id`),
  CONSTRAINT `fk_mov_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes` (`id`),
  CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientos`
--

LOCK TABLES `movimientos` WRITE;
/*!40000 ALTER TABLE `movimientos` DISABLE KEYS */;
INSERT INTO `movimientos` VALUES (1,'ENTRADA','2026-09-23 09:53:03',4,NULL,NULL,'Lote que vence antes'),(2,'ENTRADA','2026-09-23 09:53:03',4,NULL,NULL,'Lote que vence después'),(3,'ENTRADA','2026-09-23 09:53:03',4,NULL,NULL,'Buretas'),(4,'SALIDA','2026-09-23 09:53:03',4,1,1,'Preparación de solicitud #1'),(5,'DEVOLUCION','2026-09-23 09:53:03',4,NULL,1,'Devolución de material — solicitud #1'),(6,'SALIDA','2026-10-05 14:33:31',4,1,2,'Preparación de solicitud #2'),(7,'DEVOLUCION','2026-10-05 14:34:29',4,NULL,2,'Devolución de material — solicitud #2'),(8,'SALIDA','2026-10-10 23:24:13',4,2,4,'Preparación de solicitud #4'),(9,'ENTRADA','2026-10-12 14:23:01',1,NULL,NULL,'QWERT'),(10,'SALIDA','2026-10-12 14:30:28',4,1,7,'Preparación de solicitud #7'),(11,'SALIDA','2026-10-15 12:50:00',1,1,6,'Preparación de solicitud #6'),(12,'SALIDA','2026-10-15 12:50:14',1,2,3,'Preparación de solicitud #3'),(13,'ENTRADA','2026-10-15 13:39:08',1,NULL,NULL,'Importación de cristalería desde Excel');
/*!40000 ALTER TABLE `movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permisos`
--

DROP TABLE IF EXISTS `permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permisos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modulo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_permisos_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permisos`
--

LOCK TABLES `permisos` WRITE;
/*!40000 ALTER TABLE `permisos` DISABLE KEYS */;
INSERT INTO `permisos` VALUES (1,'usuarios.ver','Ver usuarios','seguridad'),(2,'usuarios.crear','Crear usuarios','seguridad'),(3,'usuarios.editar','Editar usuarios','seguridad'),(4,'usuarios.eliminar','Desactivar/eliminar usuarios','seguridad'),(5,'roles.gestionar','Gestionar roles y permisos','seguridad'),(6,'catalogos.ver','Ver catálogos','catalogos'),(7,'catalogos.gestionar','Gestionar catálogos','catalogos'),(8,'articulos.ver','Ver artículos','articulos'),(9,'articulos.crear','Crear artículos','articulos'),(10,'articulos.editar','Editar artículos','articulos'),(11,'articulos.eliminar','Desactivar/eliminar artículos','articulos'),(12,'inventario.ver','Ver existencias/inventario','inventario'),(13,'lotes.ver','Ver lotes','inventario'),(14,'entrada.registrar','Registrar entradas de stock','inventario'),(15,'ajuste.registrar','Registrar ajustes de stock','inventario'),(16,'solicitud.crear','Crear solicitudes','solicitudes'),(17,'solicitud.ver','Ver solicitudes','solicitudes'),(18,'solicitud.aprobar','Aprobar/rechazar solicitudes','solicitudes'),(19,'solicitud.preparar','Preparar solicitudes','solicitudes'),(20,'solicitud.entregar','Entregar solicitudes','solicitudes'),(21,'solicitud.devolver','Registrar devoluciones','solicitudes'),(22,'reporte.ver','Ver/exportar reportes','reportes'),(23,'dashboard.ver','Ver dashboard','reportes'),(24,'respaldo.gestionar','Respaldar/restaurar la BD','sistema'),(25,'auditoria.ver','Ver bitácora de auditoría','sistema'),(26,'solicitud.avalar','Avalar solicitudes de sus estudiantes (profesor)','solicitudes');
/*!40000 ALTER TABLE `permisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `practicas`
--

DROP TABLE IF EXISTS `practicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practicas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `clase_id` int unsigned NOT NULL,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `laboratorio_id` int unsigned NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_practicas_clase_nombre` (`clase_id`,`nombre`),
  KEY `idx_practicas_laboratorio` (`laboratorio_id`),
  CONSTRAINT `fk_practica_clase` FOREIGN KEY (`clase_id`) REFERENCES `clases` (`id`),
  CONSTRAINT `fk_practica_laboratorio` FOREIGN KEY (`laboratorio_id`) REFERENCES `laboratorios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practicas`
--

LOCK TABLES `practicas` WRITE;
/*!40000 ALTER TABLE `practicas` DISABLE KEYS */;
INSERT INTO `practicas` VALUES (1,1,'Principios de Quimica 1',2,NULL,1),(2,2,'TERMINACION DE ACIDEZ',1,'PRACTICA 2',1);
/*!40000 ALTER TABLE `practicas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedores` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contacto` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_proveedores_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES (1,'Química Meléndez S.A.','Laura M.','2278-1234',NULL,NULL,0);
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reactivo_ficha`
--

DROP TABLE IF EXISTS `reactivo_ficha`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reactivo_ficha` (
  `articulo_id` int unsigned NOT NULL,
  `cas` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `formula` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `clasificacion_peligro` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_fisico` enum('SOLIDO','LIQUIDO','GAS') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `concentracion` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `condiciones_almacenamiento` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nfpa_salud` tinyint unsigned DEFAULT NULL,
  `nfpa_inflamabilidad` tinyint unsigned DEFAULT NULL,
  `nfpa_reactividad` tinyint unsigned DEFAULT NULL,
  `nfpa_especial` set('ACID','ALC','BIO','COR','CRYO','OX','R','W','XN') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`articulo_id`),
  CONSTRAINT `fk_ficha_articulo` FOREIGN KEY (`articulo_id`) REFERENCES `articulos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_ficha_nfpa` CHECK ((((`nfpa_salud` is null) or (`nfpa_salud` <= 4)) and ((`nfpa_inflamabilidad` is null) or (`nfpa_inflamabilidad` <= 4)) and ((`nfpa_reactividad` is null) or (`nfpa_reactividad` <= 4))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reactivo_ficha`
--

LOCK TABLES `reactivo_ficha` WRITE;
/*!40000 ALTER TABLE `reactivo_ficha` DISABLE KEYS */;
INSERT INTO `reactivo_ficha` VALUES (1,'7647-01-0','HCl','Corrosivo','LIQUIDO','37%',NULL,NULL,NULL,NULL,NULL),(3,'141-78-6','asd','TOXICIDAD','SOLIDO',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `reactivo_ficha` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `respaldos`
--

DROP TABLE IF EXISTS `respaldos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `respaldos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned DEFAULT NULL,
  `archivo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tamano_bytes` bigint unsigned DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `observacion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_resp_usuario` (`usuario_id`),
  CONSTRAINT `fk_resp_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `respaldos`
--

LOCK TABLES `respaldos` WRITE;
/*!40000 ALTER TABLE `respaldos` DISABLE KEYS */;
INSERT INTO `respaldos` VALUES (1,1,'labquim_20261003_112310.sql',87398,'2026-10-03 11:23:10','Respaldo manual');
/*!40000 ALTER TABLE `respaldos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol_permiso`
--

DROP TABLE IF EXISTS `rol_permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol_permiso` (
  `rol_id` int unsigned NOT NULL,
  `permiso_id` int unsigned NOT NULL,
  PRIMARY KEY (`rol_id`,`permiso_id`),
  KEY `idx_rp_permiso` (`permiso_id`),
  CONSTRAINT `fk_rp_permiso` FOREIGN KEY (`permiso_id`) REFERENCES `permisos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol_permiso`
--

LOCK TABLES `rol_permiso` WRITE;
/*!40000 ALTER TABLE `rol_permiso` DISABLE KEYS */;
INSERT INTO `rol_permiso` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(2,6),(3,6),(4,6),(5,6),(1,7),(4,7),(1,8),(2,8),(3,8),(4,8),(5,8),(1,9),(4,9),(1,10),(4,10),(1,11),(1,12),(2,12),(3,12),(4,12),(5,12),(1,13),(2,13),(4,13),(1,14),(4,14),(1,15),(4,15),(1,16),(3,16),(5,16),(1,17),(2,17),(3,17),(4,17),(5,17),(1,18),(2,18),(1,19),(4,19),(1,20),(4,20),(1,21),(4,21),(1,22),(2,22),(4,22),(1,23),(2,23),(3,23),(4,23),(5,23),(1,24),(1,25),(2,25),(1,26),(3,26);
/*!40000 ALTER TABLE `rol_permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_roles_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Administrador','Control total del sistema',1,'2026-09-23 09:53:02'),(2,'Supervisor','Aprueba o rechaza solicitudes; ve reportes e inventario',1,'2026-09-23 09:53:02'),(3,'Profesor','Crea solicitudes y avala las de sus estudiantes',1,'2026-09-23 09:53:02'),(4,'Bodega','Prepara, entrega y recibe devoluciones; gestiona lotes',1,'2026-09-23 09:53:02'),(5,'Estudiante','Crea solicitudes (las avala su profesor) y consulta existencias',1,'2026-09-23 09:53:02');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `solicitud_detalle`
--

DROP TABLE IF EXISTS `solicitud_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitud_detalle` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` int unsigned NOT NULL,
  `articulo_id` int unsigned NOT NULL,
  `unidad_id` int unsigned NOT NULL,
  `cantidad_solicitada` decimal(14,3) NOT NULL,
  `cantidad_preparada` decimal(14,3) NOT NULL DEFAULT '0.000',
  `cantidad_devuelta` decimal(14,3) NOT NULL DEFAULT '0.000',
  `lote_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sd_solicitud` (`solicitud_id`),
  KEY `idx_sd_articulo` (`articulo_id`),
  KEY `idx_sd_lote` (`lote_id`),
  KEY `fk_sd_unidad` (`unidad_id`),
  CONSTRAINT `fk_sd_articulo` FOREIGN KEY (`articulo_id`) REFERENCES `articulos` (`id`),
  CONSTRAINT `fk_sd_lote` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id`),
  CONSTRAINT `fk_sd_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sd_unidad` FOREIGN KEY (`unidad_id`) REFERENCES `unidades_medida` (`id`),
  CONSTRAINT `chk_sd_cantidad` CHECK ((`cantidad_solicitada` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitud_detalle`
--

LOCK TABLES `solicitud_detalle` WRITE;
/*!40000 ALTER TABLE `solicitud_detalle` DISABLE KEYS */;
INSERT INTO `solicitud_detalle` VALUES (1,1,1,1,70.000,70.000,0.000,1),(2,1,2,7,4.000,4.000,4.000,3),(3,2,1,1,10.000,10.000,0.000,2),(4,2,2,7,2.000,2.000,2.000,3),(6,3,1,1,10.000,10.000,0.000,2),(7,4,1,1,10.000,10.000,0.000,2),(8,5,2,7,1.985,0.000,0.000,NULL),(9,6,1,1,10.000,10.000,0.000,2),(10,7,3,1,89.000,89.000,0.000,4),(11,7,1,1,1.000,1.000,0.000,2),(12,8,3,1,1.000,0.000,0.000,NULL),(13,9,2,7,2.000,0.000,0.000,NULL);
/*!40000 ALTER TABLE `solicitud_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `solicitudes`
--

DROP TABLE IF EXISTS `solicitudes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitudes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `tipo` enum('REACTIVO','CRISTALERIA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `profesor_id` int unsigned NOT NULL,
  `estudiante_id` int unsigned DEFAULT NULL,
  `practica_id` int unsigned DEFAULT NULL,
  `supervisor_id` int unsigned DEFAULT NULL,
  `bodega_id` int unsigned DEFAULT NULL,
  `laboratorio_id` int unsigned NOT NULL,
  `estado` enum('BORRADOR','PENDIENTE_PROFESOR','PENDIENTE','APROBADA','RECHAZADA','PREPARADA','ENTREGADA','DEVUELTA','CERRADA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `fecha_solicitud` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_requerida` date DEFAULT NULL,
  `fecha_aval_profesor` datetime DEFAULT NULL,
  `fecha_aprobacion` datetime DEFAULT NULL,
  `fecha_entrega` datetime DEFAULT NULL,
  `fecha_devolucion` datetime DEFAULT NULL,
  `motivo_rechazo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observaciones` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `actualizado_en` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sol_profesor` (`profesor_id`),
  KEY `idx_sol_supervisor` (`supervisor_id`),
  KEY `idx_sol_bodega` (`bodega_id`),
  KEY `idx_sol_laboratorio` (`laboratorio_id`),
  KEY `idx_sol_estado` (`estado`),
  KEY `idx_sol_estudiante` (`estudiante_id`),
  KEY `idx_sol_practica` (`practica_id`),
  KEY `idx_sol_tipo` (`tipo`),
  CONSTRAINT `fk_sol_bodega` FOREIGN KEY (`bodega_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `fk_sol_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `fk_sol_laboratorio` FOREIGN KEY (`laboratorio_id`) REFERENCES `laboratorios` (`id`),
  CONSTRAINT `fk_sol_practica` FOREIGN KEY (`practica_id`) REFERENCES `practicas` (`id`),
  CONSTRAINT `fk_sol_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `fk_sol_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitudes`
--

LOCK TABLES `solicitudes` WRITE;
/*!40000 ALTER TABLE `solicitudes` DISABLE KEYS */;
INSERT INTO `solicitudes` VALUES (1,'CRISTALERIA',2,NULL,NULL,3,4,1,'CERRADA','2026-09-23 09:53:03','2026-10-01',NULL,'2026-09-23 09:53:03','2026-09-23 09:53:03','2026-09-23 09:53:03',NULL,'Práctica de titulación','2026-10-10 22:45:11'),(2,'CRISTALERIA',2,NULL,NULL,3,4,1,'CERRADA','2026-10-05 14:18:20','2026-10-06',NULL,'2026-10-05 14:32:38','2026-10-05 14:33:38','2026-10-05 14:34:29',NULL,'SOLICITUD URGENTE PORFA','2026-10-10 22:45:11'),(3,'REACTIVO',7,5,1,1,1,2,'CERRADA','2026-10-10 22:54:10','2026-10-10','2026-10-10 22:55:32','2026-10-15 12:50:11','2026-10-15 12:50:17',NULL,NULL,NULL,'2026-10-15 12:50:17'),(4,'REACTIVO',7,6,1,3,4,2,'CERRADA','2026-10-10 23:21:01','2026-10-10','2026-10-10 23:23:15','2026-10-10 23:23:41','2026-10-10 23:24:17',NULL,NULL,'pene','2026-10-10 23:24:17'),(5,'CRISTALERIA',7,6,1,NULL,NULL,2,'RECHAZADA','2026-10-10 23:21:33','2026-10-10',NULL,NULL,NULL,NULL,'solo chiquitos','GRANDES','2026-10-10 23:22:16'),(6,'REACTIVO',7,5,2,3,1,1,'CERRADA','2026-10-12 14:09:59','2026-10-13','2026-10-12 14:10:31','2026-10-12 14:10:50','2026-10-15 12:50:01',NULL,NULL,'qwe','2026-10-15 12:50:01'),(7,'REACTIVO',7,5,2,3,4,1,'CERRADA','2026-10-12 14:24:43','2026-10-14','2026-10-12 14:27:13','2026-10-12 14:29:17','2026-10-12 14:30:35',NULL,NULL,'qwert','2026-10-12 14:30:35'),(8,'REACTIVO',7,6,2,NULL,NULL,1,'PENDIENTE_PROFESOR','2026-10-15 12:58:35','2026-10-16',NULL,NULL,NULL,NULL,NULL,'POR FAVOR APROBAR',NULL),(9,'CRISTALERIA',7,6,2,NULL,NULL,1,'PENDIENTE_PROFESOR','2026-10-15 12:59:08','2026-10-16',NULL,NULL,NULL,NULL,NULL,'por favor',NULL);
/*!40000 ALTER TABLE `solicitudes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubicaciones`
--

DROP TABLE IF EXISTS `ubicaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubicaciones` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `condiciones` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ubicaciones_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubicaciones`
--

LOCK TABLES `ubicaciones` WRITE;
/*!40000 ALTER TABLE `ubicaciones` DISABLE KEYS */;
INSERT INTO `ubicaciones` VALUES (1,'Gabinete A','Gabinete general de reactivos','ventilado',1),(2,'Refrigerador 1','Reactivos termosensibles','refrigerado 2-8°C',1),(3,'Gabinete Inflamables','Solventes inflamables','antichispa, ventilado',1),(4,'Estante Cristalería','Material volumétrico y equipo','ambiente',1),(5,'Bodega de cristalería',NULL,NULL,1),(6,'Cristalería',NULL,NULL,1),(7,'Laboratorio 3',NULL,NULL,1);
/*!40000 ALTER TABLE `ubicaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unidades_medida`
--

DROP TABLE IF EXISTS `unidades_medida`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unidades_medida` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abreviatura` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_unidades_abreviatura` (`abreviatura`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unidades_medida`
--

LOCK TABLES `unidades_medida` WRITE;
/*!40000 ALTER TABLE `unidades_medida` DISABLE KEYS */;
INSERT INTO `unidades_medida` VALUES (1,'Gramo','g',1),(2,'Miligramo','mg',1),(3,'Kilogramo','kg',1),(4,'Mililitro','mL',1),(5,'Litro','L',1),(6,'Mol','mol',1),(7,'Unidad','ud',1),(8,'Caja','caja',1);
/*!40000 ALTER TABLE `unidades_medida` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombres` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_completo` varchar(121) COLLATE utf8mb4_unicode_ci GENERATED ALWAYS AS (concat(`nombres`,_utf8mb4' ',`apellidos`)) STORED,
  `codigo` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rol_id` int unsigned NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_usuarios_usuario` (`usuario`),
  UNIQUE KEY `uq_usuarios_codigo` (`codigo`),
  KEY `idx_usuarios_rol` (`rol_id`),
  CONSTRAINT `fk_usuarios_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` (`id`, `nombres`, `apellidos`, `codigo`, `usuario`, `password_hash`, `email`, `rol_id`, `activo`, `creado_en`, `actualizado_en`) VALUES (1,'ADMINISTRADOR','DEL SISTEMA',NULL,'admin','$2a$11$0g7VzG.i6X0YpVwWyhfHa.CBnN1aCuJd0DnovQkCZ.5ynwXhiO9TO','admin@labquim.local',1,1,'2026-09-23 09:53:02','2026-10-10 22:15:47'),(2,'PROF','DEMO','PROF-001','profe','$2a$11$4bg7JSKMLyb1iyQyjvS.vu6/ai5xw1UwxJQ7u8TPqag.cZWaNBEAq',NULL,3,1,'2026-09-23 09:53:03','2026-10-10 22:20:06'),(3,'SUPER','DEMO',NULL,'super','$2a$11$hU/LFT9n.B7zYYAM9nyCju2ZoYvhRbbVZxafPqEbwku3m/tTKk5ay',NULL,2,1,'2026-09-23 09:53:03','2026-10-10 22:15:47'),(4,'BODEGA','DEMO',NULL,'bode','$2a$11$6idOccAfi4V4oKKxEsXmgu4asOLUtIgBer2hRS70QCgWk3ySTOCXe',NULL,4,1,'2026-09-23 09:53:03','2026-10-10 22:15:47'),(5,'ANA','ESTUDIANTE','EST-001','ana','$2a$11$hF4XxKwPclENl0PNql7Sye/MeGQE2AGR8kOuZ/CqfCHpsDqZHiub2','ana@labquim.local',5,1,'2026-09-23 10:23:28','2026-10-10 22:20:25'),(6,'CRISTEL ALEJANDRA','LOPEZ SOLIS','EST-002','clopez','$2a$11$Lr9QJl2.LPXV4Zk/FKdGxuuh2gU4f3kBc0lruus.o8pYNXQyS7UIi','cristelopez@gmail.com',5,1,'2026-10-10 21:39:54','2026-10-10 22:20:37'),(7,'JORGE','CISNE','PROF-002','jorge','$2a$11$PaqaPMPZWnzBhBwfOIQldutul8wfnP0gEWEgRwxsv2lbO6msgRCo2',NULL,3,1,'2026-10-10 22:10:13','2026-10-10 22:55:13');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'labquim'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_ajuste_registrar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ajuste_registrar`(
    IN p_usuario_id    INT UNSIGNED,
    IN p_lote_id       INT UNSIGNED,
    IN p_nueva_cantidad DECIMAL(14,3),
    IN p_motivo        VARCHAR(255)
)
BEGIN
    DECLARE v_actual DECIMAL(14,3);
    DECLARE v_delta  DECIMAL(14,3);
    DECLARE v_mov_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_nueva_cantidad IS NULL OR p_nueva_cantidad < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nueva cantidad no puede ser negativa.';
    END IF;

    START TRANSACTION;

    SELECT cantidad_actual INTO v_actual FROM lotes WHERE id = p_lote_id FOR UPDATE;
    IF v_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lote indicado no existe.';
    END IF;

    SET v_delta = p_nueva_cantidad - v_actual;

    UPDATE lotes SET cantidad_actual = p_nueva_cantidad WHERE id = p_lote_id;

    INSERT INTO movimientos (tipo, usuario_id, motivo)
    VALUES ('AJUSTE', p_usuario_id, COALESCE(p_motivo, 'Ajuste de inventario'));
    SET v_mov_id = LAST_INSERT_ID();

    INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
    VALUES (v_mov_id, p_lote_id, v_delta);

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'lotes', p_lote_id, 'AJUSTE',
            JSON_OBJECT('cantidad', v_actual),
            JSON_OBJECT('cantidad', p_nueva_cantidad, 'delta', v_delta, 'motivo', p_motivo));

    COMMIT;

    SELECT v_mov_id AS movimiento_id, v_delta AS delta;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_articulo_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_articulo_crear`(
    IN p_usuario_id     INT UNSIGNED,
    IN p_tipo           VARCHAR(12),
    IN p_codigo         VARCHAR(40),
    IN p_nombre         VARCHAR(150),
    IN p_categoria_id   INT UNSIGNED,
    IN p_unidad_id      INT UNSIGNED,
    IN p_stock_minimo   DECIMAL(14,3),
    IN p_cas            VARCHAR(20),
    IN p_formula        VARCHAR(60),
    IN p_clasificacion_peligro VARCHAR(120),
    IN p_estado_fisico  VARCHAR(10),
    IN p_concentracion  VARCHAR(40),
    IN p_condiciones_almacenamiento VARCHAR(255),
    IN p_nfpa_salud          TINYINT,
    IN p_nfpa_inflamabilidad TINYINT,
    IN p_nfpa_reactividad    TINYINT,
    IN p_nfpa_especial       VARCHAR(60)
)
BEGIN
    DECLARE v_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_tipo NOT IN ('REACTIVO', 'CRISTALERIA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo debe ser REACTIVO o CRISTALERIA.';
    END IF;
    IF EXISTS (SELECT 1 FROM articulos WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un artículo con ese código.';
    END IF;
    IF p_tipo = 'REACTIVO' THEN
        CALL sp_nfpa_validar(p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, p_nfpa_especial);
    END IF;

    START TRANSACTION;

    INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
    VALUES (p_tipo, p_codigo, p_nombre, p_categoria_id, p_unidad_id, COALESCE(p_stock_minimo, 0));
    SET v_id = LAST_INSERT_ID();

    IF p_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento,
             nfpa_salud, nfpa_inflamabilidad, nfpa_reactividad, nfpa_especial)
        VALUES
            (v_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento,
             p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, NULLIF(p_nfpa_especial, ''));
    END IF;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_usuario_id, 'articulos', v_id, 'CREAR',
            JSON_OBJECT('tipo', p_tipo, 'codigo', p_codigo, 'nombre', p_nombre));

    COMMIT;

    SELECT v_id AS articulo_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_articulo_editar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_articulo_editar`(
    IN p_usuario_id     INT UNSIGNED,
    IN p_articulo_id    INT UNSIGNED,
    IN p_nombre         VARCHAR(150),
    IN p_categoria_id   INT UNSIGNED,
    IN p_unidad_id      INT UNSIGNED,
    IN p_stock_minimo   DECIMAL(14,3),
    IN p_cas            VARCHAR(20),
    IN p_formula        VARCHAR(60),
    IN p_clasificacion_peligro VARCHAR(120),
    IN p_estado_fisico  VARCHAR(10),
    IN p_concentracion  VARCHAR(40),
    IN p_condiciones_almacenamiento VARCHAR(255),
    IN p_nfpa_salud          TINYINT,
    IN p_nfpa_inflamabilidad TINYINT,
    IN p_nfpa_reactividad    TINYINT,
    IN p_nfpa_especial       VARCHAR(60)
)
BEGIN
    DECLARE v_tipo VARCHAR(12);
    DECLARE v_nombre_ant VARCHAR(150);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT tipo, nombre INTO v_tipo, v_nombre_ant FROM articulos WHERE id = p_articulo_id;
    IF v_tipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artículo no existe.';
    END IF;
    IF v_tipo = 'REACTIVO' THEN
        CALL sp_nfpa_validar(p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, p_nfpa_especial);
    END IF;

    START TRANSACTION;

    UPDATE articulos
       SET nombre = p_nombre, categoria_id = p_categoria_id,
           unidad_id = p_unidad_id, stock_minimo = COALESCE(p_stock_minimo, 0)
     WHERE id = p_articulo_id;

    IF v_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento,
             nfpa_salud, nfpa_inflamabilidad, nfpa_reactividad, nfpa_especial)
        VALUES
            (p_articulo_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento,
             p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, NULLIF(p_nfpa_especial, ''))
        ON DUPLICATE KEY UPDATE
            cas = VALUES(cas), formula = VALUES(formula),
            clasificacion_peligro = VALUES(clasificacion_peligro),
            estado_fisico = VALUES(estado_fisico),
            concentracion = VALUES(concentracion),
            condiciones_almacenamiento = VALUES(condiciones_almacenamiento),
            nfpa_salud = VALUES(nfpa_salud),
            nfpa_inflamabilidad = VALUES(nfpa_inflamabilidad),
            nfpa_reactividad = VALUES(nfpa_reactividad),
            nfpa_especial = VALUES(nfpa_especial);
    END IF;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'articulos', p_articulo_id, 'EDITAR',
            JSON_OBJECT('nombre', v_nombre_ant),
            JSON_OBJECT('nombre', p_nombre, 'stock_minimo', p_stock_minimo));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_articulo_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_articulo_estado`(
    IN p_usuario_id  INT UNSIGNED,
    IN p_articulo_id INT UNSIGNED,
    IN p_activo      TINYINT
)
BEGIN
    DECLARE v_actual TINYINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT activo INTO v_actual FROM articulos WHERE id = p_articulo_id;
    IF v_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artículo no existe.';
    END IF;

    START TRANSACTION;

    UPDATE articulos SET activo = p_activo WHERE id = p_articulo_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'articulos', p_articulo_id,
            IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'),
            JSON_OBJECT('activo', v_actual), JSON_OBJECT('activo', p_activo));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_categoria_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_categoria_estado`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE categorias SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'categorias', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_categoria_guardar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_categoria_guardar`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(80), IN p_descripcion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM categorias WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una categoría con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO categorias (nombre, descripcion) VALUES (p_nombre, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE categorias SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'categorias', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_clase_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_clase_estado`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE clases SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'clases', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_clase_guardar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_clase_guardar`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_anio TINYINT UNSIGNED,
    IN p_nombre VARCHAR(120), IN p_descripcion VARCHAR(255), IN p_profesores_json JSON)
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF p_anio IS NULL OR p_anio NOT BETWEEN 1 AND 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El año debe estar entre primero y quinto.';
    END IF;
    IF EXISTS (SELECT 1 FROM clases WHERE anio = p_anio AND nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una clase con ese nombre en ese año.';
    END IF;
    IF p_profesores_json IS NULL OR JSON_LENGTH(p_profesores_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Asigna al menos un profesor a la clase.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM JSON_TABLE(p_profesores_json, '$[*]' COLUMNS (pid INT UNSIGNED PATH '$')) jt
        WHERE NOT EXISTS (SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
                          WHERE u.id = jt.pid AND r.nombre = 'Profesor')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden asignar usuarios con rol Profesor.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO clases (anio, nombre, descripcion) VALUES (p_anio, p_nombre, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE clases SET anio = p_anio, nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    DELETE FROM clase_profesor WHERE clase_id = v_id;
    INSERT INTO clase_profesor (clase_id, profesor_id)
    SELECT DISTINCT v_id, jt.pid
    FROM JSON_TABLE(p_profesores_json, '$[*]' COLUMNS (pid INT UNSIGNED PATH '$')) jt;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'clases', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'),
            JSON_OBJECT('anio', p_anio, 'nombre', p_nombre, 'profesores', p_profesores_json));
    COMMIT;
    SELECT v_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cristaleria_importar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cristaleria_importar`(
    IN p_usuario_id INT UNSIGNED,
    IN p_filas      JSON
)
BEGIN
    DECLARE v_n, v_i       INT DEFAULT 0;
    DECLARE v_creados      INT DEFAULT 0;
    DECLARE v_omitidos     INT DEFAULT 0;
    DECLARE v_codigo       VARCHAR(40);
    DECLARE v_nombre       VARCHAR(150);
    DECLARE v_categoria    VARCHAR(80);
    DECLARE v_ubicacion    VARCHAR(80);
    DECLARE v_unidad       VARCHAR(10);
    DECLARE v_cantidad     DECIMAL(14,3);
    DECLARE v_categoria_id, v_ubicacion_id, v_unidad_id, v_articulo_id, v_lote_id INT UNSIGNED;
    DECLARE v_mov_id       INT UNSIGNED DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_filas IS NULL OR JSON_TYPE(p_filas) <> 'ARRAY' OR JSON_LENGTH(p_filas) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay filas para importar.';
    END IF;
    SET v_n = JSON_LENGTH(p_filas);

    START TRANSACTION;

    WHILE v_i < v_n DO
        SET v_codigo    = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].codigo'))));
        SET v_nombre    = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].nombre'))));
        SET v_categoria = NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].categoria')))), '');
        SET v_ubicacion = NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].ubicacion')))), '');
        SET v_unidad    = COALESCE(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].unidad')))), ''), 'ud');
        SET v_cantidad  = COALESCE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].cantidad')), 0);

        IF v_codigo IS NULL OR v_codigo = '' OR v_nombre IS NULL OR v_nombre = '' THEN
            SET @msg = CONCAT('Fila ', v_i + 1, ': el código y el nombre son obligatorios.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        END IF;
        IF v_cantidad < 0 THEN
            SET @msg = CONCAT('Fila ', v_i + 1, ' (', v_nombre, '): la cantidad no puede ser negativa.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        END IF;

        IF EXISTS (SELECT 1 FROM articulos WHERE codigo = v_codigo) THEN
            SET v_omitidos = v_omitidos + 1;
        ELSE
            
            SET v_unidad_id = NULL;
            SELECT id INTO v_unidad_id FROM unidades_medida WHERE abreviatura = v_unidad;
            IF v_unidad_id IS NULL THEN
                SET @msg = CONCAT('Fila ', v_i + 1, ': la unidad "', v_unidad, '" no existe en el catálogo.');
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
            END IF;

            
            SET v_categoria = COALESCE(v_categoria, 'Cristalería general');
            SET v_categoria_id = NULL;
            SELECT id INTO v_categoria_id FROM categorias WHERE nombre = v_categoria;
            IF v_categoria_id IS NULL THEN
                INSERT INTO categorias (nombre) VALUES (v_categoria);
                SET v_categoria_id = LAST_INSERT_ID();
                INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
                VALUES (p_usuario_id, 'categorias', v_categoria_id, 'CREAR',
                        JSON_OBJECT('nombre', v_categoria, 'origen', 'importacion'));
            END IF;

            
            SET v_ubicacion_id = NULL;
            IF v_ubicacion IS NOT NULL THEN
                SELECT id INTO v_ubicacion_id FROM ubicaciones WHERE nombre = v_ubicacion;
                IF v_ubicacion_id IS NULL THEN
                    INSERT INTO ubicaciones (nombre) VALUES (v_ubicacion);
                    SET v_ubicacion_id = LAST_INSERT_ID();
                    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
                    VALUES (p_usuario_id, 'ubicaciones', v_ubicacion_id, 'CREAR',
                            JSON_OBJECT('nombre', v_ubicacion, 'origen', 'importacion'));
                END IF;
            END IF;

            INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
            VALUES ('CRISTALERIA', v_codigo, v_nombre, v_categoria_id, v_unidad_id, 0);
            SET v_articulo_id = LAST_INSERT_ID();

            INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
            VALUES (p_usuario_id, 'articulos', v_articulo_id, 'CREAR',
                    JSON_OBJECT('tipo', 'CRISTALERIA', 'codigo', v_codigo, 'nombre', v_nombre,
                                'origen', 'importacion'));

            IF v_cantidad > 0 THEN
                IF v_mov_id IS NULL THEN
                    INSERT INTO movimientos (tipo, usuario_id, motivo)
                    VALUES ('ENTRADA', p_usuario_id, 'Importación de cristalería desde Excel');
                    SET v_mov_id = LAST_INSERT_ID();
                END IF;

                INSERT INTO lotes (articulo_id, cantidad_actual, ubicacion_id, fecha_ingreso)
                VALUES (v_articulo_id, v_cantidad, v_ubicacion_id, CURRENT_DATE);
                SET v_lote_id = LAST_INSERT_ID();

                INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
                VALUES (v_mov_id, v_lote_id, v_cantidad);

                INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
                VALUES (p_usuario_id, 'lotes', v_lote_id, 'ENTRADA',
                        JSON_OBJECT('articulo_id', v_articulo_id, 'cantidad', v_cantidad,
                                    'lote', v_lote_id, 'origen', 'importacion'));
            END IF;

            SET v_creados = v_creados + 1;
        END IF;

        SET v_i = v_i + 1;
    END WHILE;

    COMMIT;

    SELECT v_creados AS creados, v_omitidos AS omitidos, v_mov_id AS movimiento_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_entrada_registrar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_entrada_registrar`(
    IN p_usuario_id       INT UNSIGNED,
    IN p_articulo_id      INT UNSIGNED,
    IN p_codigo_lote      VARCHAR(50),
    IN p_fecha_vencimiento DATE,
    IN p_cantidad         DECIMAL(14,3),
    IN p_proveedor_id     INT UNSIGNED,
    IN p_ubicacion_id     INT UNSIGNED,
    IN p_motivo           VARCHAR(255)
)
BEGIN
    DECLARE v_lote_id INT UNSIGNED;
    DECLARE v_mov_id  INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de entrada debe ser mayor que cero.';
    END IF;

    START TRANSACTION;

    INSERT INTO lotes (articulo_id, codigo_lote, fecha_vencimiento, cantidad_actual,
                       proveedor_id, ubicacion_id, fecha_ingreso)
    VALUES (p_articulo_id, p_codigo_lote, p_fecha_vencimiento, p_cantidad,
            p_proveedor_id, p_ubicacion_id, CURRENT_DATE);
    SET v_lote_id = LAST_INSERT_ID();

    INSERT INTO movimientos (tipo, usuario_id, motivo)
    VALUES ('ENTRADA', p_usuario_id, COALESCE(p_motivo, 'Entrada de mercadería'));
    SET v_mov_id = LAST_INSERT_ID();

    INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
    VALUES (v_mov_id, v_lote_id, p_cantidad);

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_usuario_id, 'lotes', v_lote_id, 'ENTRADA',
            JSON_OBJECT('articulo_id', p_articulo_id, 'cantidad', p_cantidad,
                        'lote', v_lote_id, 'vencimiento', p_fecha_vencimiento));

    COMMIT;

    SELECT v_lote_id AS lote_id, v_mov_id AS movimiento_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_laboratorio_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_laboratorio_estado`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE laboratorios SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'laboratorios', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_laboratorio_guardar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_laboratorio_guardar`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(120), IN p_descripcion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM laboratorios WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un laboratorio con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO laboratorios (nombre, descripcion) VALUES (p_nombre, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE laboratorios SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'laboratorios', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_nfpa_validar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_nfpa_validar`(
    IN p_salud TINYINT, IN p_inflamabilidad TINYINT, IN p_reactividad TINYINT,
    IN p_especial VARCHAR(60)
)
BEGIN
    IF p_salud IS NULL OR p_inflamabilidad IS NULL OR p_reactividad IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
            'El rombo de seguridad es obligatorio: indica salud, inflamabilidad y reactividad (0 a 4).';
    END IF;
    IF p_salud NOT BETWEEN 0 AND 4 OR p_inflamabilidad NOT BETWEEN 0 AND 4 OR p_reactividad NOT BETWEEN 0 AND 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los niveles del rombo de seguridad van de 0 a 4.';
    END IF;
    IF COALESCE(p_especial, '') <> ''
       AND NOT REGEXP_LIKE(p_especial, '^(ACID|ALC|BIO|COR|CRYO|OX|R|W|XN)(,(ACID|ALC|BIO|COR|CRYO|OX|R|W|XN))*$', 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Riesgo específico no válido (usa R, COR, BIO, CRYO, XN, ALC, W, OX o ACID).';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_practica_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_practica_estado`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE practicas SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'practicas', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_practica_guardar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_practica_guardar`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_clase_id INT UNSIGNED,
    IN p_nombre VARCHAR(150), IN p_laboratorio_id INT UNSIGNED, IN p_descripcion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF NOT EXISTS (SELECT 1 FROM clases WHERE id = p_clase_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige la clase de la práctica.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM laboratorios WHERE id = p_laboratorio_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige el laboratorio de la práctica.';
    END IF;
    IF EXISTS (SELECT 1 FROM practicas WHERE clase_id = p_clase_id AND nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esa clase ya tiene una práctica con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO practicas (clase_id, nombre, laboratorio_id, descripcion)
        VALUES (p_clase_id, p_nombre, p_laboratorio_id, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE practicas
           SET clase_id = p_clase_id, nombre = p_nombre, laboratorio_id = p_laboratorio_id, descripcion = p_descripcion
         WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'practicas', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'),
            JSON_OBJECT('nombre', p_nombre, 'clase_id', p_clase_id, 'laboratorio_id', p_laboratorio_id));
    COMMIT;
    SELECT v_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_proveedor_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proveedor_estado`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE proveedores SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'proveedores', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_proveedor_guardar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proveedor_guardar`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(120), IN p_contacto VARCHAR(120), IN p_telefono VARCHAR(40),
    IN p_email VARCHAR(120), IN p_direccion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM proveedores WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un proveedor con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO proveedores (nombre, contacto, telefono, email, direccion)
        VALUES (p_nombre, p_contacto, p_telefono, p_email, p_direccion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE proveedores SET nombre = p_nombre, contacto = p_contacto, telefono = p_telefono,
               email = p_email, direccion = p_direccion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'proveedores', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_permisos_set` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_permisos_set`(
    IN p_actor_id     INT UNSIGNED,
    IN p_rol_id       INT UNSIGNED,
    IN p_permisos_json JSON
)
BEGIN
    DECLARE v_nombre VARCHAR(50);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT nombre INTO v_nombre FROM roles WHERE id = p_rol_id;
    IF v_nombre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol no existe.';
    END IF;

    START TRANSACTION;

    DELETE FROM rol_permiso WHERE rol_id = p_rol_id;

    INSERT INTO rol_permiso (rol_id, permiso_id)
    SELECT p_rol_id, p.id
    FROM JSON_TABLE(p_permisos_json, '$[*]' COLUMNS (codigo VARCHAR(60) PATH '$')) jt
    JOIN permisos p ON p.codigo = jt.codigo COLLATE utf8mb4_unicode_ci;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'roles', p_rol_id, 'SET_PERMISOS',
            JSON_OBJECT('rol', v_nombre, 'permisos', p_permisos_json));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_aprobar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_aprobar`(
    IN p_solicitud_id  INT UNSIGNED,
    IN p_supervisor_id INT UNSIGNED
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se aprueban solicitudes en estado PENDIENTE.';
    END IF;

    UPDATE solicitudes
       SET estado = 'APROBADA', supervisor_id = p_supervisor_id, fecha_aprobacion = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_supervisor_id, 'solicitudes', p_solicitud_id, 'APROBAR',
            JSON_OBJECT('estado', v_estado), JSON_OBJECT('estado', 'APROBADA'));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_avalar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_avalar`(
    IN p_solicitud_id INT UNSIGNED,
    IN p_usuario_id   INT UNSIGNED
)
BEGIN
    DECLARE v_estado   VARCHAR(20);
    DECLARE v_profesor INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado, profesor_id INTO v_estado, v_profesor
    FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE_PROFESOR' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se avalan solicitudes que esperan al profesor.';
    END IF;
    IF v_profesor <> p_usuario_id AND NOT EXISTS (
        SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
        WHERE u.id = p_usuario_id AND r.nombre = 'Administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el profesor responsable puede avalar esta solicitud.';
    END IF;

    UPDATE solicitudes
       SET estado = 'PENDIENTE', fecha_aval_profesor = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'solicitudes', p_solicitud_id, 'AVALAR',
            JSON_OBJECT('estado', v_estado), JSON_OBJECT('estado', 'PENDIENTE'));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_crear`(
    IN p_profesor_id     INT UNSIGNED,
    IN p_estudiante_id   INT UNSIGNED,
    IN p_tipo            VARCHAR(12),       
    IN p_practica_id     INT UNSIGNED,
    IN p_fecha_requerida DATE,
    IN p_observaciones   VARCHAR(255),
    IN p_detalle_json    JSON
)
BEGIN
    DECLARE v_sol_id INT UNSIGNED;
    DECLARE v_lineas INT;
    DECLARE v_estado VARCHAR(20) DEFAULT 'PENDIENTE';
    DECLARE v_clase  INT UNSIGNED;
    DECLARE v_lab    INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_detalle_json IS NULL OR JSON_LENGTH(p_detalle_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud debe tener al menos una línea.';
    END IF;

    IF p_tipo IS NULL OR p_tipo NOT IN ('REACTIVO', 'CRISTALERIA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de solicitud debe ser REACTIVO o CRISTALERIA.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM JSON_TABLE(p_detalle_json, '$[*]' COLUMNS (articulo_id INT UNSIGNED PATH '$.articulo_id')) jt
        LEFT JOIN articulos a ON a.id = jt.articulo_id
        WHERE a.id IS NULL OR a.tipo <> p_tipo) THEN
        IF p_tipo = 'REACTIVO' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una solicitud de reactivos solo puede incluir reactivos.';
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una solicitud de cristalería solo puede incluir cristalería.';
        END IF;
    END IF;

    IF p_estudiante_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
                       WHERE u.id = p_profesor_id AND u.activo = 1 AND r.nombre = 'Profesor') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige un profesor responsable válido.';
        END IF;
        SET v_estado = 'PENDIENTE_PROFESOR';
    END IF;

    SELECT pr.clase_id, pr.laboratorio_id INTO v_clase, v_lab
    FROM practicas pr JOIN clases c ON c.id = pr.clase_id
    WHERE pr.id = p_practica_id AND pr.activo = 1 AND c.activo = 1;
    IF v_clase IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige una práctica válida.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM clase_profesor WHERE clase_id = v_clase AND profesor_id = p_profesor_id)
       AND NOT EXISTS (SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
                       WHERE u.id = p_profesor_id AND r.nombre = 'Administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La práctica no pertenece a una clase de ese profesor.';
    END IF;

    START TRANSACTION;

    INSERT INTO solicitudes (tipo, profesor_id, estudiante_id, practica_id, laboratorio_id, estado, fecha_requerida, observaciones)
    VALUES (p_tipo, p_profesor_id, p_estudiante_id, p_practica_id, v_lab, v_estado, p_fecha_requerida, p_observaciones);
    SET v_sol_id = LAST_INSERT_ID();

    INSERT INTO solicitud_detalle (solicitud_id, articulo_id, unidad_id, cantidad_solicitada)
    SELECT v_sol_id, jt.articulo_id, jt.unidad_id, jt.cantidad
    FROM JSON_TABLE(p_detalle_json, '$[*]'
         COLUMNS (
             articulo_id INT UNSIGNED  PATH '$.articulo_id',
             unidad_id   INT UNSIGNED  PATH '$.unidad_id',
             cantidad    DECIMAL(14,3) PATH '$.cantidad'
         )) AS jt;

    SET v_lineas = ROW_COUNT();

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (COALESCE(p_estudiante_id, p_profesor_id), 'solicitudes', v_sol_id, 'CREAR',
            JSON_OBJECT('tipo', p_tipo, 'practica_id', p_practica_id, 'laboratorio_id', v_lab, 'lineas', v_lineas,
                        'profesor_id', p_profesor_id, 'estudiante_id', p_estudiante_id,
                        'estado', v_estado));

    COMMIT;

    SELECT v_sol_id AS solicitud_id, v_lineas AS lineas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_devolver` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_devolver`(
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_mat    INT DEFAULT 0;
    DECLARE v_dev_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se registran devoluciones de solicitudes ENTREGADAS.';
    END IF;

    
    SELECT COUNT(*) INTO v_mat
    FROM movimiento_detalle md
    JOIN movimientos m ON m.id = md.movimiento_id
    JOIN lotes lo      ON lo.id = md.lote_id
    JOIN articulos a   ON a.id = lo.articulo_id
    WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'CRISTALERIA';

    IF v_mat > 0 THEN
        INSERT INTO movimientos (tipo, usuario_id, solicitud_id, motivo)
        VALUES ('DEVOLUCION', p_bodega_id, p_solicitud_id,
                CONCAT('Devolución de material — solicitud #', p_solicitud_id));
        SET v_dev_id = LAST_INSERT_ID();

        
        INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
        SELECT v_dev_id, md.lote_id, SUM(md.cantidad)
        FROM movimiento_detalle md
        JOIN movimientos m ON m.id = md.movimiento_id
        JOIN lotes lo      ON lo.id = md.lote_id
        JOIN articulos a   ON a.id = lo.articulo_id
        WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'CRISTALERIA'
        GROUP BY md.lote_id;

        
        UPDATE lotes l
        JOIN (
            SELECT md.lote_id, SUM(md.cantidad) AS qty
            FROM movimiento_detalle md
            JOIN movimientos m ON m.id = md.movimiento_id
            JOIN lotes lo      ON lo.id = md.lote_id
            JOIN articulos a   ON a.id = lo.articulo_id
            WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'CRISTALERIA'
            GROUP BY md.lote_id
        ) x ON x.lote_id = l.id
        SET l.cantidad_actual = l.cantidad_actual + x.qty;

        
        UPDATE solicitud_detalle sd
        JOIN articulos a ON a.id = sd.articulo_id
        SET sd.cantidad_devuelta = sd.cantidad_preparada
        WHERE sd.solicitud_id = p_solicitud_id AND a.tipo = 'CRISTALERIA';
    END IF;

    UPDATE solicitudes
       SET estado = 'CERRADA', fecha_devolucion = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'DEVOLVER',
            JSON_OBJECT('estado', 'ENTREGADA'),
            JSON_OBJECT('estado', 'CERRADA', 'materiales_reingresados', v_mat));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_entregar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_entregar`(
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_tipo   VARCHAR(12);
    DECLARE v_nuevo  VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado, tipo INTO v_estado, v_tipo FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PREPARADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se entregan solicitudes PREPARADAS.';
    END IF;

    SET v_nuevo = IF(v_tipo = 'REACTIVO', 'CERRADA', 'ENTREGADA');

    UPDATE solicitudes
       SET estado = v_nuevo, bodega_id = p_bodega_id, fecha_entrega = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'ENTREGAR',
            JSON_OBJECT('estado', 'PREPARADA'), JSON_OBJECT('estado', v_nuevo));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_preparar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_preparar`(
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED
)
BEGIN
    DECLARE v_estado    VARCHAR(20);
    DECLARE v_mov_id    INT UNSIGNED;
    DECLARE v_lab_id    INT UNSIGNED;
    DECLARE v_done      INT DEFAULT 0;

    
    DECLARE v_det_id    INT UNSIGNED;
    DECLARE v_art_id    INT UNSIGNED;
    DECLARE v_cant      DECIMAL(14,3);
    DECLARE v_total     DECIMAL(14,3);
    DECLARE v_rem       DECIMAL(14,3);
    DECLARE v_take      DECIMAL(14,3);
    DECLARE v_lote      INT UNSIGNED;
    DECLARE v_disp      DECIMAL(14,3);
    DECLARE v_first_lote INT UNSIGNED;

    DECLARE cur CURSOR FOR
        SELECT id, articulo_id, cantidad_solicitada
        FROM solicitud_detalle WHERE solicitud_id = p_solicitud_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    
    SELECT estado, laboratorio_id INTO v_estado, v_lab_id
    FROM solicitudes WHERE id = p_solicitud_id;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'APROBADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se preparan solicitudes APROBADAS.';
    END IF;

    START TRANSACTION;

    INSERT INTO movimientos (tipo, usuario_id, laboratorio_id, solicitud_id, motivo)
    VALUES ('SALIDA', p_bodega_id, v_lab_id, p_solicitud_id,
            CONCAT('Preparación de solicitud #', p_solicitud_id));
    SET v_mov_id = LAST_INSERT_ID();

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_det_id, v_art_id, v_cant;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        
        SELECT COALESCE(SUM(cantidad_actual), 0) INTO v_total
        FROM lotes WHERE articulo_id = v_art_id AND activo = 1;

        IF v_total < v_cant THEN
            SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = 'Stock insuficiente para preparar la solicitud.';
        END IF;

        SET v_rem = v_cant;
        SET v_first_lote = NULL;

        
        fefo_loop: WHILE v_rem > 0 DO
            SELECT id, cantidad_actual INTO v_lote, v_disp
            FROM lotes
            WHERE articulo_id = v_art_id AND activo = 1 AND cantidad_actual > 0
            ORDER BY (fecha_vencimiento IS NULL), fecha_vencimiento, id
            LIMIT 1
            FOR UPDATE;

            SET v_take = LEAST(v_disp, v_rem);

            UPDATE lotes SET cantidad_actual = cantidad_actual - v_take WHERE id = v_lote;

            INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
            VALUES (v_mov_id, v_lote, v_take);

            IF v_first_lote IS NULL THEN
                SET v_first_lote = v_lote;
            END IF;

            SET v_rem = v_rem - v_take;
        END WHILE;

        UPDATE solicitud_detalle
           SET cantidad_preparada = v_cant, lote_id = v_first_lote
         WHERE id = v_det_id;
    END LOOP;
    CLOSE cur;

    UPDATE solicitudes
       SET estado = 'PREPARADA', bodega_id = p_bodega_id
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'PREPARAR',
            JSON_OBJECT('estado', 'APROBADA'),
            JSON_OBJECT('estado', 'PREPARADA', 'movimiento_id', v_mov_id));

    COMMIT;

    SELECT v_mov_id AS movimiento_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_rechazar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_rechazar`(
    IN p_solicitud_id  INT UNSIGNED,
    IN p_supervisor_id INT UNSIGNED,
    IN p_motivo        VARCHAR(255)
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_motivo IS NULL OR CHAR_LENGTH(TRIM(p_motivo)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el motivo del rechazo.';
    END IF;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se rechazan solicitudes en estado PENDIENTE.';
    END IF;

    UPDATE solicitudes
       SET estado = 'RECHAZADA', supervisor_id = p_supervisor_id,
           fecha_aprobacion = NOW(), motivo_rechazo = p_motivo
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_supervisor_id, 'solicitudes', p_solicitud_id, 'RECHAZAR',
            JSON_OBJECT('estado', v_estado),
            JSON_OBJECT('estado', 'RECHAZADA', 'motivo', p_motivo));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_solicitud_rechazar_profesor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_solicitud_rechazar_profesor`(
    IN p_solicitud_id INT UNSIGNED,
    IN p_usuario_id   INT UNSIGNED,
    IN p_motivo       VARCHAR(255)
)
BEGIN
    DECLARE v_estado   VARCHAR(20);
    DECLARE v_profesor INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Indica el motivo del rechazo.';
    END IF;

    START TRANSACTION;

    SELECT estado, profesor_id INTO v_estado, v_profesor
    FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE_PROFESOR' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se rechazan aquí solicitudes que esperan al profesor.';
    END IF;
    IF v_profesor <> p_usuario_id AND NOT EXISTS (
        SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
        WHERE u.id = p_usuario_id AND r.nombre = 'Administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el profesor responsable puede rechazar esta solicitud.';
    END IF;

    UPDATE solicitudes
       SET estado = 'RECHAZADA', motivo_rechazo = p_motivo
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'solicitudes', p_solicitud_id, 'RECHAZAR_PROFESOR',
            JSON_OBJECT('estado', v_estado), JSON_OBJECT('estado', 'RECHAZADA', 'motivo', p_motivo));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ubicacion_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ubicacion_estado`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE ubicaciones SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'ubicaciones', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ubicacion_guardar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ubicacion_guardar`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(80), IN p_descripcion VARCHAR(255), IN p_condiciones VARCHAR(120))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM ubicaciones WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una ubicación con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO ubicaciones (nombre, descripcion, condiciones) VALUES (p_nombre, p_descripcion, p_condiciones);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE ubicaciones SET nombre = p_nombre, descripcion = p_descripcion, condiciones = p_condiciones WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'ubicaciones', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_unidad_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_unidad_estado`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE unidades_medida SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'unidades_medida', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_unidad_guardar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_unidad_guardar`(
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(40), IN p_abreviatura VARCHAR(10))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM unidades_medida WHERE abreviatura = p_abreviatura AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una unidad con esa abreviatura.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO unidades_medida (nombre, abreviatura) VALUES (p_nombre, p_abreviatura);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE unidades_medida SET nombre = p_nombre, abreviatura = p_abreviatura WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'unidades_medida', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('abreviatura', p_abreviatura));
    COMMIT;
    SELECT v_id AS id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_crear`(
    IN p_actor_id       INT UNSIGNED,
    IN p_nombres        VARCHAR(60),
    IN p_apellidos      VARCHAR(60),
    IN p_codigo         VARCHAR(20),
    IN p_usuario        VARCHAR(50),
    IN p_password_hash  VARCHAR(100),
    IN p_email          VARCHAR(120),
    IN p_rol_id         INT UNSIGNED
)
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE v_nombres, v_apellidos VARCHAR(60);
    DECLARE v_codigo VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT REGEXP_LIKE(COALESCE(p_usuario, ''), '^[A-Za-z0-9._-]{3,50}$', 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario debe tener de 3 a 50 letras, números, punto, guion o guion bajo.';
    END IF;
    IF EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un usuario con ese nombre de usuario.';
    END IF;
    CALL sp_usuario_validar(0, p_nombres, p_apellidos, p_codigo, p_rol_id, v_nombres, v_apellidos, v_codigo);

    START TRANSACTION;

    INSERT INTO usuarios (nombres, apellidos, codigo, usuario, password_hash, email, rol_id)
    VALUES (v_nombres, v_apellidos, v_codigo, p_usuario, p_password_hash, p_email, p_rol_id);
    SET v_id = LAST_INSERT_ID();

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'usuarios', v_id, 'CREAR',
            JSON_OBJECT('usuario', p_usuario, 'codigo', v_codigo, 'rol_id', p_rol_id));

    COMMIT;

    SELECT v_id AS usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_editar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_editar`(
    IN p_actor_id        INT UNSIGNED,
    IN p_usuario_id      INT UNSIGNED,
    IN p_nombres         VARCHAR(60),
    IN p_apellidos       VARCHAR(60),
    IN p_codigo          VARCHAR(20),
    IN p_email           VARCHAR(120),
    IN p_rol_id          INT UNSIGNED
)
BEGIN
    DECLARE v_rol_ant INT UNSIGNED;
    DECLARE v_nombres, v_apellidos VARCHAR(60);
    DECLARE v_codigo VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT rol_id INTO v_rol_ant FROM usuarios WHERE id = p_usuario_id;
    IF v_rol_ant IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    CALL sp_usuario_validar(p_usuario_id, p_nombres, p_apellidos, p_codigo, p_rol_id, v_nombres, v_apellidos, v_codigo);

    START TRANSACTION;

    UPDATE usuarios
       SET nombres = v_nombres, apellidos = v_apellidos, codigo = v_codigo,
           email = p_email, rol_id = p_rol_id
     WHERE id = p_usuario_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id, 'EDITAR',
            JSON_OBJECT('rol_id', v_rol_ant),
            JSON_OBJECT('nombres', v_nombres, 'apellidos', v_apellidos, 'codigo', v_codigo, 'rol_id', p_rol_id));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_estado`(
    IN p_actor_id   INT UNSIGNED,
    IN p_usuario_id INT UNSIGNED,
    IN p_activo     TINYINT
)
BEGIN
    DECLARE v_actual TINYINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_actor_id = p_usuario_id AND p_activo = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes desactivar tu propio usuario.';
    END IF;

    SELECT activo INTO v_actual FROM usuarios WHERE id = p_usuario_id;
    IF v_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;

    START TRANSACTION;

    UPDATE usuarios SET activo = p_activo WHERE id = p_usuario_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id,
            IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'),
            JSON_OBJECT('activo', v_actual), JSON_OBJECT('activo', p_activo));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_password`(
    IN p_actor_id      INT UNSIGNED,
    IN p_usuario_id    INT UNSIGNED,
    IN p_password_hash VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;

    START TRANSACTION;

    UPDATE usuarios SET password_hash = p_password_hash WHERE id = p_usuario_id;

    
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id, 'CAMBIAR_PASSWORD',
            JSON_OBJECT('cambiado', TRUE));

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_validar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_validar`(
    IN  p_usuario_id INT UNSIGNED,          
    IN  p_nombres    VARCHAR(60),
    IN  p_apellidos  VARCHAR(60),
    IN  p_codigo     VARCHAR(20),
    IN  p_rol_id     INT UNSIGNED,
    OUT o_nombres    VARCHAR(60),
    OUT o_apellidos  VARCHAR(60),
    OUT o_codigo     VARCHAR(20)
)
BEGIN
    DECLARE v_rol VARCHAR(40);
    DECLARE c_nombre VARCHAR(80) DEFAULT '^[A-ZÁÉÍÓÚÜÑ]+([ ''-][A-ZÁÉÍÓÚÜÑ]+)*$';

    SELECT nombre INTO v_rol FROM roles WHERE id = p_rol_id;
    IF v_rol IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe.';
    END IF;

    SET o_nombres   = UPPER(REGEXP_REPLACE(TRIM(COALESCE(p_nombres, '')), ' +', ' '));
    SET o_apellidos = UPPER(REGEXP_REPLACE(TRIM(COALESCE(p_apellidos, '')), ' +', ' '));
    IF o_nombres = '' OR o_apellidos = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los nombres y los apellidos son obligatorios.';
    END IF;
    IF NOT REGEXP_LIKE(o_nombres, c_nombre, 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los nombres solo pueden tener letras, espacios, apóstrofo o guion.';
    END IF;
    IF NOT REGEXP_LIKE(o_apellidos, c_nombre, 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los apellidos solo pueden tener letras, espacios, apóstrofo o guion.';
    END IF;

    IF v_rol IN ('Profesor', 'Estudiante') THEN
        SET o_codigo = UPPER(TRIM(COALESCE(p_codigo, '')));
        IF o_codigo = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El código es obligatorio para profesores y estudiantes.';
        END IF;
        IF CHAR_LENGTH(o_codigo) NOT BETWEEN 3 AND 20
           OR NOT REGEXP_LIKE(o_codigo, '^[A-Z0-9]+(-[A-Z0-9]+)*$', 'c') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El código debe tener de 3 a 20 letras o números (puede llevar guion).';
        END IF;
        IF EXISTS (SELECT 1 FROM usuarios WHERE codigo = o_codigo AND id <> p_usuario_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese código ya está asignado a otro usuario.';
        END IF;
    ELSE
        SET o_codigo = NULL;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-15 13:39:17
