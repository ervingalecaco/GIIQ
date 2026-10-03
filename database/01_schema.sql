-- =============================================================================
-- LabQuim — Sistema de Control y Gestión de Inventario de Reactivos y
-- Materiales de Laboratorio de Química
-- Archivo: 01_schema.sql  (esquema / DDL)
-- Motor: MySQL 8  |  Charset: utf8mb4  |  Engine: InnoDB
-- =============================================================================
-- NOTA (zona horaria): Nicaragua es UTC-6 sin horario de verano. La fábrica de
-- conexiones del backend debe fijar `SET time_zone = '-06:00'` en cada conexión
-- y usar `AllowUserVariables=true` en el connection string. Las consultas por
-- SQL directo (Workbench, mysqlsh) NO fijan la zona y muestran la del servidor.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS labquim
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE labquim;

-- Reinicio limpio (para desarrollo). Orden inverso por dependencias.
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS respaldos;
DROP TABLE IF EXISTS auditoria;
DROP TABLE IF EXISTS solicitud_detalle;
DROP TABLE IF EXISTS solicitudes;
DROP TABLE IF EXISTS movimiento_detalle;
DROP TABLE IF EXISTS movimientos;
DROP TABLE IF EXISTS lotes;
DROP TABLE IF EXISTS reactivo_ficha;
DROP TABLE IF EXISTS articulos;
DROP TABLE IF EXISTS laboratorios;
DROP TABLE IF EXISTS ubicaciones;
DROP TABLE IF EXISTS proveedores;
DROP TABLE IF EXISTS unidades_medida;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS rol_permiso;
DROP TABLE IF EXISTS permisos;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS roles;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 1) SEGURIDAD Y ACCESOS
-- =============================================================================

CREATE TABLE roles (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(50)  NOT NULL,
  descripcion   VARCHAR(255) NULL,
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  creado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE permisos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo        VARCHAR(60)  NOT NULL,        -- ej. 'solicitud.aprobar'
  descripcion   VARCHAR(255) NULL,
  modulo        VARCHAR(50)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_permisos_codigo (codigo)
) ENGINE=InnoDB;

CREATE TABLE rol_permiso (
  rol_id        INT UNSIGNED NOT NULL,
  permiso_id    INT UNSIGNED NOT NULL,
  PRIMARY KEY (rol_id, permiso_id),
  KEY idx_rp_permiso (permiso_id),
  CONSTRAINT fk_rp_rol     FOREIGN KEY (rol_id)     REFERENCES roles (id)     ON DELETE CASCADE,
  CONSTRAINT fk_rp_permiso FOREIGN KEY (permiso_id) REFERENCES permisos (id)  ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre_completo VARCHAR(120) NOT NULL,
  usuario         VARCHAR(50)  NOT NULL,
  password_hash   VARCHAR(100) NOT NULL,      -- BCrypt (~60 chars)
  email           VARCHAR(120) NULL,
  rol_id          INT UNSIGNED NOT NULL,
  activo          TINYINT(1)   NOT NULL DEFAULT 1,
  creado_en       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en  DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_usuario (usuario),
  KEY idx_usuarios_rol (rol_id),
  CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id) REFERENCES roles (id)
) ENGINE=InnoDB;

-- =============================================================================
-- 2) CATÁLOGOS MAESTROS
-- =============================================================================

CREATE TABLE categorias (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(80)  NOT NULL,        -- ácido, base, solvente, material volumétrico...
  descripcion   VARCHAR(255) NULL,
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categorias_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE unidades_medida (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(40)  NOT NULL,        -- gramo, mililitro, unidad...
  abreviatura   VARCHAR(10)  NOT NULL,        -- g, mL, L, mol, ud...
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_unidades_abreviatura (abreviatura)
) ENGINE=InnoDB;

CREATE TABLE proveedores (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(120) NOT NULL,
  contacto      VARCHAR(120) NULL,
  telefono      VARCHAR(40)  NULL,
  email         VARCHAR(120) NULL,
  direccion     VARCHAR(255) NULL,
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_proveedores_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE ubicaciones (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(80)  NOT NULL,        -- Gabinete A, Estante 3, Refrigerador 1...
  descripcion   VARCHAR(255) NULL,
  condiciones   VARCHAR(120) NULL,            -- refrigerado, ventilado, inflamables...
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ubicaciones_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE laboratorios (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(120) NOT NULL,        -- destino/práctica del despacho
  descripcion   VARCHAR(255) NULL,
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_laboratorios_nombre (nombre)
) ENGINE=InnoDB;

-- =============================================================================
-- 3) ARTÍCULOS E INVENTARIO
-- =============================================================================

-- Maestro común de reactivos y materiales. La existencia NO vive aquí:
-- vive repartida en `lotes` (ver regla FEFO).
CREATE TABLE articulos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo          ENUM('REACTIVO','MATERIAL') NOT NULL,
  codigo        VARCHAR(40)  NOT NULL,
  nombre        VARCHAR(150) NOT NULL,
  categoria_id  INT UNSIGNED NOT NULL,
  unidad_id     INT UNSIGNED NOT NULL,
  stock_minimo  DECIMAL(14,3) NOT NULL DEFAULT 0,
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  creado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME    NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_articulos_codigo (codigo),
  KEY idx_articulos_categoria (categoria_id),
  KEY idx_articulos_unidad (unidad_id),
  KEY idx_articulos_tipo (tipo),
  CONSTRAINT fk_articulos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id),
  CONSTRAINT fk_articulos_unidad    FOREIGN KEY (unidad_id)    REFERENCES unidades_medida (id)
) ENGINE=InnoDB;

-- Extensión 1:1 solo para reactivos (datos químicos y de seguridad).
CREATE TABLE reactivo_ficha (
  articulo_id               INT UNSIGNED NOT NULL,
  cas                       VARCHAR(20)  NULL,   -- número CAS
  formula                   VARCHAR(60)  NULL,
  clasificacion_peligro     VARCHAR(120) NULL,   -- pictogramas GHS (lista)
  estado_fisico             ENUM('SOLIDO','LIQUIDO','GAS') NULL,
  concentracion             VARCHAR(40)  NULL,   -- ej. 37%, 1 M
  condiciones_almacenamiento VARCHAR(255) NULL,
  PRIMARY KEY (articulo_id),
  CONSTRAINT fk_ficha_articulo FOREIGN KEY (articulo_id) REFERENCES articulos (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Existencia real: cada lote de un artículo con su vencimiento y cantidad.
-- Para MATERIALES la fecha_vencimiento suele ser NULL (no caducan).
CREATE TABLE lotes (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  articulo_id     INT UNSIGNED NOT NULL,
  codigo_lote     VARCHAR(50)  NULL,
  fecha_vencimiento DATE       NULL,
  cantidad_actual DECIMAL(14,3) NOT NULL DEFAULT 0,
  proveedor_id    INT UNSIGNED NULL,
  ubicacion_id    INT UNSIGNED NULL,
  fecha_ingreso   DATE         NOT NULL DEFAULT (CURRENT_DATE),
  activo          TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  KEY idx_lotes_articulo (articulo_id),
  KEY idx_lotes_proveedor (proveedor_id),
  KEY idx_lotes_ubicacion (ubicacion_id),
  KEY idx_lotes_fefo (articulo_id, fecha_vencimiento),  -- soporta FEFO
  CONSTRAINT fk_lotes_articulo  FOREIGN KEY (articulo_id)  REFERENCES articulos (id),
  CONSTRAINT fk_lotes_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores (id),
  CONSTRAINT fk_lotes_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones (id),
  CONSTRAINT chk_lotes_cantidad CHECK (cantidad_actual >= 0)
) ENGINE=InnoDB;

-- =============================================================================
-- 4) SOLICITUDES Y PRÉSTAMOS (flujo de aprobación)
--    Se crea antes de `movimientos` porque movimientos.solicitud_id la referencia.
-- =============================================================================

CREATE TABLE solicitudes (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  profesor_id     INT UNSIGNED NOT NULL,       -- quien crea la solicitud
  supervisor_id   INT UNSIGNED NULL,           -- quien aprueba/rechaza
  bodega_id       INT UNSIGNED NULL,           -- quien prepara/entrega
  laboratorio_id  INT UNSIGNED NOT NULL,       -- práctica/laboratorio destino
  estado          ENUM('BORRADOR','PENDIENTE','APROBADA','RECHAZADA',
                       'PREPARADA','ENTREGADA','DEVUELTA','CERRADA')
                    NOT NULL DEFAULT 'PENDIENTE',
  fecha_solicitud DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_requerida DATE         NULL,
  fecha_aprobacion DATETIME    NULL,
  fecha_entrega   DATETIME     NULL,
  fecha_devolucion DATETIME    NULL,
  motivo_rechazo  VARCHAR(255) NULL,
  observaciones   VARCHAR(255) NULL,
  actualizado_en  DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sol_profesor (profesor_id),
  KEY idx_sol_supervisor (supervisor_id),
  KEY idx_sol_bodega (bodega_id),
  KEY idx_sol_laboratorio (laboratorio_id),
  KEY idx_sol_estado (estado),
  CONSTRAINT fk_sol_profesor    FOREIGN KEY (profesor_id)    REFERENCES usuarios (id),
  CONSTRAINT fk_sol_supervisor  FOREIGN KEY (supervisor_id)  REFERENCES usuarios (id),
  CONSTRAINT fk_sol_bodega      FOREIGN KEY (bodega_id)      REFERENCES usuarios (id),
  CONSTRAINT fk_sol_laboratorio FOREIGN KEY (laboratorio_id) REFERENCES laboratorios (id)
) ENGINE=InnoDB;

-- Líneas de la solicitud. El lote se asigna cuando Bodega prepara (FEFO).
CREATE TABLE solicitud_detalle (
  id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  solicitud_id        INT UNSIGNED NOT NULL,
  articulo_id         INT UNSIGNED NOT NULL,
  unidad_id           INT UNSIGNED NOT NULL,
  cantidad_solicitada DECIMAL(14,3) NOT NULL,
  cantidad_preparada  DECIMAL(14,3) NOT NULL DEFAULT 0,
  cantidad_devuelta   DECIMAL(14,3) NOT NULL DEFAULT 0,   -- solo materiales
  lote_id             INT UNSIGNED NULL,                  -- asignado al preparar
  PRIMARY KEY (id),
  KEY idx_sd_solicitud (solicitud_id),
  KEY idx_sd_articulo (articulo_id),
  KEY idx_sd_lote (lote_id),
  CONSTRAINT fk_sd_solicitud FOREIGN KEY (solicitud_id) REFERENCES solicitudes (id) ON DELETE CASCADE,
  CONSTRAINT fk_sd_articulo  FOREIGN KEY (articulo_id)  REFERENCES articulos (id),
  CONSTRAINT fk_sd_unidad    FOREIGN KEY (unidad_id)    REFERENCES unidades_medida (id),
  CONSTRAINT fk_sd_lote      FOREIGN KEY (lote_id)      REFERENCES lotes (id),
  CONSTRAINT chk_sd_cantidad CHECK (cantidad_solicitada > 0)
) ENGINE=InnoDB;

-- =============================================================================
-- 5) MOVIMIENTOS DE INVENTARIO
-- =============================================================================

CREATE TABLE movimientos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo          ENUM('ENTRADA','SALIDA','AJUSTE','DEVOLUCION') NOT NULL,
  fecha         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  usuario_id    INT UNSIGNED NOT NULL,
  laboratorio_id INT UNSIGNED NULL,            -- destino si es SALIDA
  solicitud_id  INT UNSIGNED NULL,             -- si nace de una solicitud
  motivo        VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY idx_mov_tipo (tipo),
  KEY idx_mov_fecha (fecha),
  KEY idx_mov_usuario (usuario_id),
  KEY idx_mov_solicitud (solicitud_id),
  CONSTRAINT fk_mov_usuario     FOREIGN KEY (usuario_id)     REFERENCES usuarios (id),
  CONSTRAINT fk_mov_laboratorio FOREIGN KEY (laboratorio_id) REFERENCES laboratorios (id),
  CONSTRAINT fk_mov_solicitud   FOREIGN KEY (solicitud_id)   REFERENCES solicitudes (id)
) ENGINE=InnoDB;

CREATE TABLE movimiento_detalle (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  movimiento_id INT UNSIGNED NOT NULL,
  lote_id       INT UNSIGNED NOT NULL,
  cantidad      DECIMAL(14,3) NOT NULL,        -- + entra / - sale (o siempre + con el tipo)
  PRIMARY KEY (id),
  KEY idx_md_movimiento (movimiento_id),
  KEY idx_md_lote (lote_id),
  CONSTRAINT fk_md_movimiento FOREIGN KEY (movimiento_id) REFERENCES movimientos (id) ON DELETE CASCADE,
  CONSTRAINT fk_md_lote       FOREIGN KEY (lote_id)       REFERENCES lotes (id)
) ENGINE=InnoDB;

-- =============================================================================
-- 6) ADMINISTRACIÓN
-- =============================================================================

-- Bitácora de auditoría. Se escribe DESDE los stored procedures (el hosting
-- compartido niega CREATE TRIGGER). Guarda estados antes/después en JSON.
CREATE TABLE auditoria (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id      INT UNSIGNED NULL,
  entidad         VARCHAR(60)  NOT NULL,       -- ej. 'articulos', 'lotes', 'solicitudes'
  entidad_id      VARCHAR(40)  NULL,
  accion          VARCHAR(40)  NOT NULL,       -- CREAR, EDITAR, ELIMINAR, APROBAR...
  valores_antes   JSON         NULL,
  valores_despues JSON         NULL,
  fecha           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_aud_entidad (entidad, entidad_id),
  KEY idx_aud_usuario (usuario_id),
  KEY idx_aud_fecha (fecha),
  CONSTRAINT fk_aud_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

CREATE TABLE respaldos (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id    INT UNSIGNED NULL,
  archivo       VARCHAR(255) NOT NULL,
  tamano_bytes  BIGINT UNSIGNED NULL,
  fecha         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacion   VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY idx_resp_usuario (usuario_id),
  CONSTRAINT fk_resp_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

-- =============================================================================
-- Fin del esquema — 18 tablas.
-- Siguiente: 02_seeds.sql (roles, permisos, catálogos base y usuario admin).
-- =============================================================================
