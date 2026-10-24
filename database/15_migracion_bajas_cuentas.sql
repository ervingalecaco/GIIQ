-- =============================================================================
-- LabQuim — Migración: bajas de cristalería y cuenta del estudiante
-- Archivo: 15_migracion_bajas_cuentas.sql
--
-- Cuando un estudiante quiebra (o pierde) cristalería en una práctica, bodega
-- registra la BAJA: la pieza sale del stock y, si hay responsable, se le carga
-- al estudiante. La deuda se lleva EN PIEZAS y se salda REPONIENDO la misma
-- pieza (la reposición vuelve al stock). Sin saldo pendiente, bodega emite la
-- constancia de solvencia que se exige antes de culminar los estudios.
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql y 02_seeds.sql ya
-- lo traen). Después hay que recargar los procedimientos:  source 03_procedures.sql;
-- =============================================================================
USE labquim;

-- Nuevos tipos de movimiento: BAJA (sale del stock) y REPOSICION (vuelve).
ALTER TABLE movimientos
  MODIFY COLUMN tipo ENUM('ENTRADA','SALIDA','AJUSTE','DEVOLUCION','BAJA','REPOSICION') NOT NULL;

-- Lo que se quebró de cada línea al devolver (solo cristalería).
ALTER TABLE solicitud_detalle
  ADD COLUMN cantidad_quebrada DECIMAL(14,3) NOT NULL DEFAULT 0 AFTER cantidad_devuelta;

-- Baja de cristalería. El detalle por lote está en el movimiento BAJA.
CREATE TABLE IF NOT EXISTS bajas (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  articulo_id    INT UNSIGNED NOT NULL,
  cantidad       DECIMAL(14,3) NOT NULL,
  causa          ENUM('QUEBRADO','EXTRAVIADO','DETERIORADO') NOT NULL DEFAULT 'QUEBRADO',
  solicitud_id   INT UNSIGNED NULL,               -- si ocurrió en una práctica
  estudiante_id  INT UNSIGNED NULL,               -- responsable (NULL = sin cargo)
  movimiento_id  INT UNSIGNED NOT NULL,           -- movimiento BAJA con el detalle por lote
  registrado_por INT UNSIGNED NOT NULL,
  observacion    VARCHAR(255) NULL,
  fecha          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_bajas_articulo (articulo_id),
  KEY idx_bajas_estudiante (estudiante_id),
  KEY idx_bajas_fecha (fecha),
  CONSTRAINT ck_bajas_cantidad CHECK (cantidad > 0),
  CONSTRAINT fk_bajas_articulo   FOREIGN KEY (articulo_id)    REFERENCES articulos (id),
  CONSTRAINT fk_bajas_solicitud  FOREIGN KEY (solicitud_id)   REFERENCES solicitudes (id),
  CONSTRAINT fk_bajas_estudiante FOREIGN KEY (estudiante_id)  REFERENCES usuarios (id),
  CONSTRAINT fk_bajas_movimiento FOREIGN KEY (movimiento_id)  REFERENCES movimientos (id),
  CONSTRAINT fk_bajas_usuario    FOREIGN KEY (registrado_por) REFERENCES usuarios (id)
) ENGINE=InnoDB;

-- Cargo en la cuenta del estudiante: piezas que debe reponer por una baja.
CREATE TABLE IF NOT EXISTS cargos_estudiante (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  baja_id           INT UNSIGNED NOT NULL,
  estudiante_id     INT UNSIGNED NOT NULL,
  articulo_id       INT UNSIGNED NOT NULL,
  cantidad          DECIMAL(14,3) NOT NULL,
  cantidad_repuesta DECIMAL(14,3) NOT NULL DEFAULT 0,
  estado            ENUM('PENDIENTE','SALDADO') NOT NULL DEFAULT 'PENDIENTE',
  fecha             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  saldado_en        DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cargo_baja (baja_id),
  KEY idx_cargo_estudiante (estudiante_id, estado),
  CONSTRAINT ck_cargo_cantidades CHECK (cantidad > 0 AND cantidad_repuesta >= 0 AND cantidad_repuesta <= cantidad),
  CONSTRAINT fk_cargo_baja       FOREIGN KEY (baja_id)       REFERENCES bajas (id),
  CONSTRAINT fk_cargo_estudiante FOREIGN KEY (estudiante_id) REFERENCES usuarios (id),
  CONSTRAINT fk_cargo_articulo   FOREIGN KEY (articulo_id)   REFERENCES articulos (id)
) ENGINE=InnoDB;

-- Reposición: el estudiante entrega piezas iguales; vuelven al stock.
CREATE TABLE IF NOT EXISTS reposiciones (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cargo_id      INT UNSIGNED NOT NULL,
  cantidad      DECIMAL(14,3) NOT NULL,
  movimiento_id INT UNSIGNED NOT NULL,            -- movimiento REPOSICION
  recibido_por  INT UNSIGNED NOT NULL,
  observacion   VARCHAR(255) NULL,
  fecha         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_repos_cargo (cargo_id),
  CONSTRAINT ck_repos_cantidad CHECK (cantidad > 0),
  CONSTRAINT fk_repos_cargo      FOREIGN KEY (cargo_id)      REFERENCES cargos_estudiante (id),
  CONSTRAINT fk_repos_movimiento FOREIGN KEY (movimiento_id) REFERENCES movimientos (id),
  CONSTRAINT fk_repos_usuario    FOREIGN KEY (recibido_por)  REFERENCES usuarios (id)
) ENGINE=InnoDB;

-- Constancias de solvencia emitidas: el id es el folio que se imprime.
CREATE TABLE IF NOT EXISTS constancias_solvencia (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  estudiante_id INT UNSIGNED NOT NULL,
  emitida_por   INT UNSIGNED NOT NULL,
  fecha         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_const_estudiante (estudiante_id),
  CONSTRAINT fk_const_estudiante FOREIGN KEY (estudiante_id) REFERENCES usuarios (id),
  CONSTRAINT fk_const_usuario    FOREIGN KEY (emitida_por)   REFERENCES usuarios (id)
) ENGINE=InnoDB;

-- Permisos nuevos.
INSERT IGNORE INTO permisos (codigo, descripcion, modulo) VALUES
  ('baja.registrar',       'Registrar bajas de cristalería',              'inventario'),
  ('cuentas.ver',          'Ver cuentas de estudiantes (piezas por reponer)', 'cuentas'),
  ('reposicion.registrar', 'Registrar reposiciones de estudiantes',        'cuentas'),
  ('solvencia.emitir',     'Emitir constancias de solvencia',              'cuentas'),
  ('cuenta.propia',        'Ver su propia cuenta (estudiante)',            'cuentas');

-- Administrador: todos. Bodega: registra y cobra. Supervisor: consulta. Estudiante: la suya.
INSERT IGNORE INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id FROM roles r JOIN permisos p
WHERE (r.nombre = 'Administrador' AND p.codigo IN ('baja.registrar','cuentas.ver','reposicion.registrar','solvencia.emitir'))
   OR (r.nombre = 'Bodega'        AND p.codigo IN ('baja.registrar','cuentas.ver','reposicion.registrar','solvencia.emitir'))
   OR (r.nombre = 'Supervisor'    AND p.codigo IN ('cuentas.ver'))
   OR (r.nombre = 'Estudiante'    AND p.codigo IN ('cuenta.propia'));
