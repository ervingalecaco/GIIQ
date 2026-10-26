-- =============================================================================
-- GIIQ — Migración: rombo de seguridad NFPA 704 en los reactivos
-- Archivo: 13_migracion_rombo_nfpa.sql
--
-- Agrega a la ficha del reactivo los 4 cuadrantes del rombo:
--   azul = salud, rojo = inflamabilidad, amarillo = reactividad (0 a 4)
--   blanco = riesgo específico (R, COR, BIO, CRYO, XN, ALC, W, OX, ACID)
-- Los reactivos existentes quedan sin rombo: hay que completarlo al editarlos
-- (es obligatorio para guardar un reactivo).
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql ya lo trae).
-- Después hay que recargar los procedimientos:  source 05_procedures_articulos.sql;
-- =============================================================================
USE labquim;

ALTER TABLE reactivo_ficha
  ADD COLUMN nfpa_salud          TINYINT UNSIGNED NULL,
  ADD COLUMN nfpa_inflamabilidad TINYINT UNSIGNED NULL,
  ADD COLUMN nfpa_reactividad    TINYINT UNSIGNED NULL,
  ADD COLUMN nfpa_especial       SET('ACID','ALC','BIO','COR','CRYO','OX','R','W','XN') NULL,
  ADD CONSTRAINT ck_ficha_nfpa CHECK (
    (nfpa_salud IS NULL OR nfpa_salud <= 4) AND
    (nfpa_inflamabilidad IS NULL OR nfpa_inflamabilidad <= 4) AND
    (nfpa_reactividad IS NULL OR nfpa_reactividad <= 4));
