-- =============================================================================
-- GIIQ — Migración: los estudiantes también crean solicitudes
-- Archivo: 09_migracion_solicitudes_estudiantes.sql
--
-- Flujo nuevo para solicitudes de estudiante:
--   Estudiante crea (elige profesor responsable) -> PENDIENTE_PROFESOR
--   Profesor avala -> PENDIENTE -> Supervisor aprueba -> APROBADA -> Bodega…
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql y 02_seeds.sql
-- ya lo traen). Después hay que recargar los procedimientos:
--   source 03_procedures.sql;
-- Los usuarios con sesión abierta deben salir y volver a entrar para recibir
-- los permisos nuevos.
-- =============================================================================
USE labquim;

-- 1) Columnas y estado nuevo en solicitudes.
ALTER TABLE solicitudes
  ADD COLUMN estudiante_id INT UNSIGNED NULL AFTER profesor_id,
  ADD COLUMN fecha_aval_profesor DATETIME NULL AFTER fecha_requerida,
  MODIFY estado ENUM('BORRADOR','PENDIENTE_PROFESOR','PENDIENTE','APROBADA','RECHAZADA',
                     'PREPARADA','ENTREGADA','DEVUELTA','CERRADA') NOT NULL DEFAULT 'PENDIENTE',
  ADD KEY idx_sol_estudiante (estudiante_id),
  ADD CONSTRAINT fk_sol_estudiante FOREIGN KEY (estudiante_id) REFERENCES usuarios (id);

-- 2) Permiso nuevo para que el profesor avale las solicitudes de sus estudiantes.
INSERT IGNORE INTO permisos (codigo, descripcion, modulo)
VALUES ('solicitud.avalar', 'Avalar solicitudes de sus estudiantes (profesor)', 'solicitudes');

-- 3) Asignación: Administrador y Profesor avalan; Estudiante crea y ve sus solicitudes.
INSERT IGNORE INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id FROM roles r JOIN permisos p
WHERE (r.nombre IN ('Administrador', 'Profesor') AND p.codigo = 'solicitud.avalar')
   OR (r.nombre = 'Estudiante' AND p.codigo IN ('solicitud.crear', 'solicitud.ver'));

-- 4) Descripciones de los roles.
UPDATE roles SET descripcion = 'Crea solicitudes y avala las de sus estudiantes' WHERE nombre = 'Profesor';
UPDATE roles SET descripcion = 'Crea solicitudes (las avala su profesor) y consulta existencias' WHERE nombre = 'Estudiante';
