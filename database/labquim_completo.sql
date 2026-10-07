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
  `tipo` enum('REACTIVO','MATERIAL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `articulos`
--

LOCK TABLES `articulos` WRITE;
/*!40000 ALTER TABLE `articulos` DISABLE KEYS */;
INSERT INTO `articulos` VALUES (1,'REACTIVO','RX-001','Ácido clorhídrico',1,1,20.000,1,'2026-09-23 09:53:03',NULL),(2,'MATERIAL','MT-001','Bureta 50 mL',6,7,2.000,1,'2026-09-23 09:53:03',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,4,'lotes','1','ENTRADA',NULL,'{\"lote\": 1, \"cantidad\": 50.0, \"articulo_id\": 1, \"vencimiento\": \"2026-01-01\"}','2026-09-23 09:53:03'),(2,4,'lotes','2','ENTRADA',NULL,'{\"lote\": 2, \"cantidad\": 80.0, \"articulo_id\": 1, \"vencimiento\": \"2027-01-01\"}','2026-09-23 09:53:03'),(3,4,'lotes','3','ENTRADA',NULL,'{\"lote\": 3, \"cantidad\": 10.0, \"articulo_id\": 2, \"vencimiento\": null}','2026-09-23 09:53:03'),(4,2,'solicitudes','1','CREAR',NULL,'{\"estado\": \"PENDIENTE\", \"lineas\": 2, \"laboratorio_id\": 1}','2026-09-23 09:53:03'),(5,3,'solicitudes','1','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-09-23 09:53:03'),(6,4,'solicitudes','1','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 4}','2026-09-23 09:53:03'),(7,4,'solicitudes','1','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"ENTREGADA\"}','2026-09-23 09:53:03'),(8,4,'solicitudes','1','DEVOLVER','{\"estado\": \"ENTREGADA\"}','{\"estado\": \"CERRADA\", \"materiales_reingresados\": 1}','2026-09-23 09:53:03'),(9,1,'usuarios','5','CREAR',NULL,'{\"rol_id\": 5, \"usuario\": \"ana\"}','2026-09-23 10:23:28'),(10,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\", \"reporte.ver\"]}','2026-09-23 10:29:11'),(11,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\"]}','2026-09-23 10:29:12'),(12,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\", \"reporte.ver\"]}','2026-09-23 10:29:32'),(13,1,'roles','5','SET_PERMISOS',NULL,'{\"rol\": \"Estudiante\", \"permisos\": [\"inventario.ver\", \"articulos.ver\", \"catalogos.ver\", \"dashboard.ver\"]}','2026-09-23 10:29:32'),(14,1,'proveedores','1','CREAR',NULL,'{\"nombre\": \"Química Meléndez S.A.\"}','2026-09-23 13:31:34'),(15,1,'proveedores','1','EDITAR',NULL,'{\"nombre\": \"Química Meléndez S.A.\"}','2026-09-23 13:31:35'),(16,1,'proveedores','1','DESACTIVAR',NULL,'{\"activo\": 0}','2026-09-23 13:31:35'),(17,2,'solicitudes','2','CREAR',NULL,'{\"estado\": \"PENDIENTE\", \"lineas\": 2, \"laboratorio_id\": 1}','2026-10-05 14:18:20'),(18,3,'solicitudes','2','APROBAR','{\"estado\": \"PENDIENTE\"}','{\"estado\": \"APROBADA\"}','2026-10-05 14:32:38'),(19,4,'solicitudes','2','PREPARAR','{\"estado\": \"APROBADA\"}','{\"estado\": \"PREPARADA\", \"movimiento_id\": 6}','2026-10-05 14:33:31'),(20,4,'solicitudes','2','ENTREGAR','{\"estado\": \"PREPARADA\"}','{\"estado\": \"ENTREGADA\"}','2026-10-05 14:33:38'),(21,4,'solicitudes','2','DEVOLVER','{\"estado\": \"ENTREGADA\"}','{\"estado\": \"CERRADA\", \"materiales_reingresados\": 1}','2026-10-05 14:34:29');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Ácido','Reactivos ácidos',1),(2,'Base','Reactivos básicos/álcalis',1),(3,'Solvente','Disolventes orgánicos e inorgánicos',1),(4,'Sal','Sales inorgánicas',1),(5,'Indicador','Indicadores de pH y colorimétricos',1),(6,'Material volumétrico','Cristalería de medición (buretas, pipetas, matraces)',1),(7,'Equipo','Equipo e instrumental de laboratorio',1);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `laboratorios`
--

LOCK TABLES `laboratorios` WRITE;
/*!40000 ALTER TABLE `laboratorios` DISABLE KEYS */;
INSERT INTO `laboratorios` VALUES (1,'Práctica de Química General',NULL,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lotes`
--

LOCK TABLES `lotes` WRITE;
/*!40000 ALTER TABLE `lotes` DISABLE KEYS */;
INSERT INTO `lotes` VALUES (1,1,'RX-L-A','2026-01-01',0.000,NULL,NULL,'2026-09-23',1),(2,1,'RX-L-B','2027-01-01',50.000,NULL,NULL,'2026-09-23',1),(3,2,'MT-L-1',NULL,10.000,NULL,NULL,'2026-09-23',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimiento_detalle`
--

LOCK TABLES `movimiento_detalle` WRITE;
/*!40000 ALTER TABLE `movimiento_detalle` DISABLE KEYS */;
INSERT INTO `movimiento_detalle` VALUES (1,1,1,50.000),(2,2,2,80.000),(3,3,3,10.000),(4,4,1,50.000),(5,4,2,20.000),(6,4,3,4.000),(7,5,3,4.000),(8,6,2,10.000),(9,6,3,2.000),(10,7,3,2.000);
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientos`
--

LOCK TABLES `movimientos` WRITE;
/*!40000 ALTER TABLE `movimientos` DISABLE KEYS */;
INSERT INTO `movimientos` VALUES (1,'ENTRADA','2026-09-23 09:53:03',4,NULL,NULL,'Lote que vence antes'),(2,'ENTRADA','2026-09-23 09:53:03',4,NULL,NULL,'Lote que vence después'),(3,'ENTRADA','2026-09-23 09:53:03',4,NULL,NULL,'Buretas'),(4,'SALIDA','2026-09-23 09:53:03',4,1,1,'Preparación de solicitud #1'),(5,'DEVOLUCION','2026-09-23 09:53:03',4,NULL,1,'Devolución de material — solicitud #1'),(6,'SALIDA','2026-10-05 14:33:31',4,1,2,'Preparación de solicitud #2'),(7,'DEVOLUCION','2026-10-05 14:34:29',4,NULL,2,'Devolución de material — solicitud #2');
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permisos`
--

LOCK TABLES `permisos` WRITE;
/*!40000 ALTER TABLE `permisos` DISABLE KEYS */;
INSERT INTO `permisos` VALUES (1,'usuarios.ver','Ver usuarios','seguridad'),(2,'usuarios.crear','Crear usuarios','seguridad'),(3,'usuarios.editar','Editar usuarios','seguridad'),(4,'usuarios.eliminar','Desactivar/eliminar usuarios','seguridad'),(5,'roles.gestionar','Gestionar roles y permisos','seguridad'),(6,'catalogos.ver','Ver catálogos','catalogos'),(7,'catalogos.gestionar','Gestionar catálogos','catalogos'),(8,'articulos.ver','Ver artículos','articulos'),(9,'articulos.crear','Crear artículos','articulos'),(10,'articulos.editar','Editar artículos','articulos'),(11,'articulos.eliminar','Desactivar/eliminar artículos','articulos'),(12,'inventario.ver','Ver existencias/inventario','inventario'),(13,'lotes.ver','Ver lotes','inventario'),(14,'entrada.registrar','Registrar entradas de stock','inventario'),(15,'ajuste.registrar','Registrar ajustes de stock','inventario'),(16,'solicitud.crear','Crear solicitudes','solicitudes'),(17,'solicitud.ver','Ver solicitudes','solicitudes'),(18,'solicitud.aprobar','Aprobar/rechazar solicitudes','solicitudes'),(19,'solicitud.preparar','Preparar solicitudes','solicitudes'),(20,'solicitud.entregar','Entregar solicitudes','solicitudes'),(21,'solicitud.devolver','Registrar devoluciones','solicitudes'),(22,'reporte.ver','Ver/exportar reportes','reportes'),(23,'dashboard.ver','Ver dashboard','reportes'),(24,'respaldo.gestionar','Respaldar/restaurar la BD','sistema'),(25,'auditoria.ver','Ver bitácora de auditoría','sistema');
/*!40000 ALTER TABLE `permisos` ENABLE KEYS */;
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
  PRIMARY KEY (`articulo_id`),
  CONSTRAINT `fk_ficha_articulo` FOREIGN KEY (`articulo_id`) REFERENCES `articulos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reactivo_ficha`
--

LOCK TABLES `reactivo_ficha` WRITE;
/*!40000 ALTER TABLE `reactivo_ficha` DISABLE KEYS */;
INSERT INTO `reactivo_ficha` VALUES (1,'7647-01-0','HCl','Corrosivo','LIQUIDO','37%',NULL);
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
INSERT INTO `rol_permiso` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(2,6),(3,6),(4,6),(5,6),(1,7),(4,7),(1,8),(2,8),(3,8),(4,8),(5,8),(1,9),(4,9),(1,10),(4,10),(1,11),(1,12),(2,12),(3,12),(4,12),(5,12),(1,13),(2,13),(4,13),(1,14),(4,14),(1,15),(4,15),(1,16),(3,16),(1,17),(2,17),(3,17),(4,17),(1,18),(2,18),(1,19),(4,19),(1,20),(4,20),(1,21),(4,21),(1,22),(2,22),(4,22),(1,23),(2,23),(3,23),(4,23),(5,23),(1,24),(1,25),(2,25);
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
INSERT INTO `roles` VALUES (1,'Administrador','Control total del sistema',1,'2026-09-23 09:53:02'),(2,'Supervisor','Aprueba o rechaza solicitudes; ve reportes e inventario',1,'2026-09-23 09:53:02'),(3,'Profesor','Crea solicitudes de préstamo de reactivos y materiales',1,'2026-09-23 09:53:02'),(4,'Bodega','Prepara, entrega y recibe devoluciones; gestiona lotes',1,'2026-09-23 09:53:02'),(5,'Estudiante','Solo visualización de existencias y reportes',1,'2026-09-23 09:53:02');
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitud_detalle`
--

LOCK TABLES `solicitud_detalle` WRITE;
/*!40000 ALTER TABLE `solicitud_detalle` DISABLE KEYS */;
INSERT INTO `solicitud_detalle` VALUES (1,1,1,1,70.000,70.000,0.000,1),(2,1,2,7,4.000,4.000,4.000,3),(3,2,1,1,10.000,10.000,0.000,2),(4,2,2,7,2.000,2.000,2.000,3);
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
  `profesor_id` int unsigned NOT NULL,
  `supervisor_id` int unsigned DEFAULT NULL,
  `bodega_id` int unsigned DEFAULT NULL,
  `laboratorio_id` int unsigned NOT NULL,
  `estado` enum('BORRADOR','PENDIENTE','APROBADA','RECHAZADA','PREPARADA','ENTREGADA','DEVUELTA','CERRADA') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `fecha_solicitud` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_requerida` date DEFAULT NULL,
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
  CONSTRAINT `fk_sol_bodega` FOREIGN KEY (`bodega_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `fk_sol_laboratorio` FOREIGN KEY (`laboratorio_id`) REFERENCES `laboratorios` (`id`),
  CONSTRAINT `fk_sol_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `fk_sol_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitudes`
--

LOCK TABLES `solicitudes` WRITE;
/*!40000 ALTER TABLE `solicitudes` DISABLE KEYS */;
INSERT INTO `solicitudes` VALUES (1,2,3,4,1,'CERRADA','2026-09-23 09:53:03','2026-10-01','2026-09-23 09:53:03','2026-09-23 09:53:03','2026-09-23 09:53:03',NULL,'Práctica de titulación','2026-09-23 09:53:03'),(2,2,3,4,1,'CERRADA','2026-10-05 14:18:20','2026-10-06','2026-10-05 14:32:38','2026-10-05 14:33:38','2026-10-05 14:34:29',NULL,'SOLICITUD URGENTE PORFA','2026-10-05 14:34:29');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubicaciones`
--

LOCK TABLES `ubicaciones` WRITE;
/*!40000 ALTER TABLE `ubicaciones` DISABLE KEYS */;
INSERT INTO `ubicaciones` VALUES (1,'Gabinete A','Gabinete general de reactivos','ventilado',1),(2,'Refrigerador 1','Reactivos termosensibles','refrigerado 2-8°C',1),(3,'Gabinete Inflamables','Solventes inflamables','antichispa, ventilado',1),(4,'Estante Cristalería','Material volumétrico y equipo','ambiente',1);
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
  `nombre_completo` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rol_id` int unsigned NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_usuarios_usuario` (`usuario`),
  KEY `idx_usuarios_rol` (`rol_id`),
  CONSTRAINT `fk_usuarios_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador del Sistema','admin','$2a$11$0g7VzG.i6X0YpVwWyhfHa.CBnN1aCuJd0DnovQkCZ.5ynwXhiO9TO','admin@labquim.local',1,1,'2026-09-23 09:53:02','2026-09-23 09:53:28'),(2,'Prof. Demo','profe','$2a$11$4bg7JSKMLyb1iyQyjvS.vu6/ai5xw1UwxJQ7u8TPqag.cZWaNBEAq',NULL,3,1,'2026-09-23 09:53:03','2026-09-23 09:53:29'),(3,'Super Demo','super','$2a$11$hU/LFT9n.B7zYYAM9nyCju2ZoYvhRbbVZxafPqEbwku3m/tTKk5ay',NULL,2,1,'2026-09-23 09:53:03','2026-09-23 09:53:29'),(4,'Bodega Demo','bode','$2a$11$6idOccAfi4V4oKKxEsXmgu4asOLUtIgBer2hRS70QCgWk3ySTOCXe',NULL,4,1,'2026-09-23 09:53:03','2026-09-23 09:53:29'),(5,'Ana Estudiante','ana','$2a$11$hF4XxKwPclENl0PNql7Sye/MeGQE2AGR8kOuZ/CqfCHpsDqZHiub2','ana@labquim.local',5,1,'2026-09-23 10:23:28',NULL);
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
    IN p_tipo           VARCHAR(10),
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
    IN p_condiciones_almacenamiento VARCHAR(255)
)
BEGIN
    DECLARE v_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_tipo NOT IN ('REACTIVO', 'MATERIAL') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo debe ser REACTIVO o MATERIAL.';
    END IF;
    IF EXISTS (SELECT 1 FROM articulos WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un artículo con ese código.';
    END IF;

    START TRANSACTION;

    INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
    VALUES (p_tipo, p_codigo, p_nombre, p_categoria_id, p_unidad_id, COALESCE(p_stock_minimo, 0));
    SET v_id = LAST_INSERT_ID();

    IF p_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento)
        VALUES
            (v_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento);
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
    IN p_condiciones_almacenamiento VARCHAR(255)
)
BEGIN
    DECLARE v_tipo VARCHAR(10);
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

    START TRANSACTION;

    UPDATE articulos
       SET nombre = p_nombre, categoria_id = p_categoria_id,
           unidad_id = p_unidad_id, stock_minimo = COALESCE(p_stock_minimo, 0)
     WHERE id = p_articulo_id;

    IF v_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento)
        VALUES
            (p_articulo_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento)
        ON DUPLICATE KEY UPDATE
            cas = VALUES(cas), formula = VALUES(formula),
            clasificacion_peligro = VALUES(clasificacion_peligro),
            estado_fisico = VALUES(estado_fisico),
            concentracion = VALUES(concentracion),
            condiciones_almacenamiento = VALUES(condiciones_almacenamiento);
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
    IN p_laboratorio_id  INT UNSIGNED,
    IN p_fecha_requerida DATE,
    IN p_observaciones   VARCHAR(255),
    IN p_detalle_json    JSON
)
BEGIN
    DECLARE v_sol_id INT UNSIGNED;
    DECLARE v_lineas INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_detalle_json IS NULL OR JSON_LENGTH(p_detalle_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud debe tener al menos una línea.';
    END IF;

    START TRANSACTION;

    INSERT INTO solicitudes (profesor_id, laboratorio_id, estado, fecha_requerida, observaciones)
    VALUES (p_profesor_id, p_laboratorio_id, 'PENDIENTE', p_fecha_requerida, p_observaciones);
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
    VALUES (p_profesor_id, 'solicitudes', v_sol_id, 'CREAR',
            JSON_OBJECT('laboratorio_id', p_laboratorio_id, 'lineas', v_lineas,
                        'estado', 'PENDIENTE'));

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
    WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'MATERIAL';

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
        WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'MATERIAL'
        GROUP BY md.lote_id;

        
        UPDATE lotes l
        JOIN (
            SELECT md.lote_id, SUM(md.cantidad) AS qty
            FROM movimiento_detalle md
            JOIN movimientos m ON m.id = md.movimiento_id
            JOIN lotes lo      ON lo.id = md.lote_id
            JOIN articulos a   ON a.id = lo.articulo_id
            WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'MATERIAL'
            GROUP BY md.lote_id
        ) x ON x.lote_id = l.id
        SET l.cantidad_actual = l.cantidad_actual + x.qty;

        
        UPDATE solicitud_detalle sd
        JOIN articulos a ON a.id = sd.articulo_id
        SET sd.cantidad_devuelta = sd.cantidad_preparada
        WHERE sd.solicitud_id = p_solicitud_id AND a.tipo = 'MATERIAL';
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
    IF v_estado <> 'PREPARADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se entregan solicitudes PREPARADAS.';
    END IF;

    UPDATE solicitudes
       SET estado = 'ENTREGADA', bodega_id = p_bodega_id, fecha_entrega = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'ENTREGAR',
            JSON_OBJECT('estado', 'PREPARADA'), JSON_OBJECT('estado', 'ENTREGADA'));

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
    IN p_nombre_completo VARCHAR(120),
    IN p_usuario        VARCHAR(50),
    IN p_password_hash  VARCHAR(100),
    IN p_email          VARCHAR(120),
    IN p_rol_id         INT UNSIGNED
)
BEGIN
    DECLARE v_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un usuario con ese nombre de usuario.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM roles WHERE id = p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe.';
    END IF;

    START TRANSACTION;

    INSERT INTO usuarios (nombre_completo, usuario, password_hash, email, rol_id)
    VALUES (p_nombre_completo, p_usuario, p_password_hash, p_email, p_rol_id);
    SET v_id = LAST_INSERT_ID();

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'usuarios', v_id, 'CREAR',
            JSON_OBJECT('usuario', p_usuario, 'rol_id', p_rol_id));

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
    IN p_nombre_completo VARCHAR(120),
    IN p_email           VARCHAR(120),
    IN p_rol_id          INT UNSIGNED
)
BEGIN
    DECLARE v_rol_ant INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT rol_id INTO v_rol_ant FROM usuarios WHERE id = p_usuario_id;
    IF v_rol_ant IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM roles WHERE id = p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe.';
    END IF;

    START TRANSACTION;

    UPDATE usuarios
       SET nombre_completo = p_nombre_completo, email = p_email, rol_id = p_rol_id
     WHERE id = p_usuario_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id, 'EDITAR',
            JSON_OBJECT('rol_id', v_rol_ant),
            JSON_OBJECT('nombre', p_nombre_completo, 'rol_id', p_rol_id));

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-07  0:00:16
