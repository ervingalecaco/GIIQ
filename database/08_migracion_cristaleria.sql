-- =============================================================================
-- GIIQ — Migración: el tipo de artículo MATERIAL pasa a llamarse CRISTALERIA
-- Archivo: 08_migracion_cristaleria.sql
--
-- Solo para bases creadas ANTES de este cambio. Una base nueva creada con
-- 01_schema.sql ya trae ENUM('REACTIVO','CRISTALERIA') y no necesita esto.
--
-- Después de este script hay que recargar los procedimientos que usan el tipo:
--   source 03_procedures.sql; source 05_procedures_articulos.sql;
-- =============================================================================
USE labquim;

START TRANSACTION;

-- 1) Ampliar el ENUM para que acepte ambos valores mientras se convierten los datos.
ALTER TABLE articulos MODIFY tipo ENUM('REACTIVO','MATERIAL','CRISTALERIA') NOT NULL;

-- 2) Convertir los artículos existentes.
UPDATE articulos SET tipo = 'CRISTALERIA' WHERE tipo = 'MATERIAL';

-- 3) Dejar el ENUM definitivo.
ALTER TABLE articulos MODIFY tipo ENUM('REACTIVO','CRISTALERIA') NOT NULL;

COMMIT;
