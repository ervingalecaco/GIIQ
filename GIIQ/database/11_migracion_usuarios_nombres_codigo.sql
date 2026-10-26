-- =============================================================================
-- GIIQ — Migración: nombres y apellidos por separado + código de usuario
-- Archivo: 11_migracion_usuarios_nombres_codigo.sql
--
--  * nombre_completo se divide en nombres y apellidos (en MAYÚSCULAS) y pasa a
--    ser una columna calculada, así las consultas existentes siguen funcionando.
--    Regla de división: la primera mitad de las palabras son nombres y el resto
--    apellidos (4 palabras = 2 + 2, 3 = 1 + 2, 2 = 1 + 1). Revisar después los
--    usuarios con nombres compuestos y corregirlos desde la pantalla Usuarios.
--  * Nueva columna codigo (única): código de estudiante o de profesor. Queda
--    vacía para los usuarios existentes; se pide al editar un profesor/estudiante.
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql ya lo trae).
-- Después hay que recargar los procedimientos:  source 06_procedures_usuarios.sql;
-- =============================================================================
USE labquim;

ALTER TABLE usuarios
  ADD COLUMN nombres   VARCHAR(60) NOT NULL DEFAULT '' AFTER id,
  ADD COLUMN apellidos VARCHAR(60) NOT NULL DEFAULT '' AFTER nombres,
  ADD COLUMN codigo    VARCHAR(20) NULL AFTER nombre_completo;

-- Nombre normalizado: mayúsculas, sin puntos y con espacios simples.
UPDATE usuarios
   SET nombre_completo = UPPER(REGEXP_REPLACE(TRIM(REPLACE(nombre_completo, '.', '')), ' +', ' '));

UPDATE usuarios u
  JOIN (SELECT id, nombre_completo AS nc,
               CHAR_LENGTH(nombre_completo) - CHAR_LENGTH(REPLACE(nombre_completo, ' ', '')) + 1 AS palabras
        FROM usuarios) x ON x.id = u.id
   SET u.nombres   = IF(x.palabras = 1, x.nc, SUBSTRING_INDEX(x.nc, ' ', FLOOR(x.palabras / 2))),
       u.apellidos = IF(x.palabras = 1, '',
                        SUBSTRING(x.nc, CHAR_LENGTH(SUBSTRING_INDEX(x.nc, ' ', FLOOR(x.palabras / 2))) + 2));

ALTER TABLE usuarios
  ALTER COLUMN nombres DROP DEFAULT,
  ALTER COLUMN apellidos DROP DEFAULT,
  DROP COLUMN nombre_completo,
  ADD COLUMN nombre_completo VARCHAR(121)
      GENERATED ALWAYS AS (CONCAT(nombres, ' ', apellidos)) STORED AFTER apellidos,
  ADD UNIQUE KEY uq_usuarios_codigo (codigo);
