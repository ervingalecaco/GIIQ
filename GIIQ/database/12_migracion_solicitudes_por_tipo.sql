-- =============================================================================
-- GIIQ — Migración: solicitudes de reactivos y solicitudes de cristalería
-- Archivo: 12_migracion_solicitudes_por_tipo.sql
--
--  * Nueva columna solicitudes.tipo (REACTIVO | CRISTALERIA). Una solicitud ya
--    no mezcla tipos.
--  * Las solicitudes existentes se clasifican así: si incluyen alguna línea de
--    cristalería -> CRISTALERIA (implicaron préstamo y devolución); si no -> REACTIVO.
--  * Las de reactivos que estén en ENTREGADA se cierran (ya no esperan devolución).
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql ya lo trae).
-- Después hay que recargar los procedimientos:  source 03_procedures.sql;
-- =============================================================================
USE labquim;

ALTER TABLE solicitudes
  ADD COLUMN tipo ENUM('REACTIVO','CRISTALERIA') NOT NULL DEFAULT 'REACTIVO' AFTER id;

UPDATE solicitudes s
   SET s.tipo = IF(EXISTS (SELECT 1 FROM solicitud_detalle sd JOIN articulos a ON a.id = sd.articulo_id
                           WHERE sd.solicitud_id = s.id AND a.tipo = 'CRISTALERIA'),
                   'CRISTALERIA', 'REACTIVO');

UPDATE solicitudes
   SET estado = 'CERRADA'
 WHERE tipo = 'REACTIVO' AND estado = 'ENTREGADA';

ALTER TABLE solicitudes
  ALTER COLUMN tipo DROP DEFAULT,
  ADD KEY idx_sol_tipo (tipo);
