-- =============================================================================
-- GIIQ — Migración: imagen de referencia de la cristalería
-- Archivo: 14_migracion_imagenes_cristaleria.sql
--
-- Cada artículo de cristalería puede tener UNA foto de referencia, para que
-- estudiantes y bodega identifiquen el material (matraz, bureta, pipeta…).
-- Se guarda en la base (no en disco) para que entre en los respaldos.
-- El navegador la reduce antes de subirla (~1000 px, ~100 KB).
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql ya la trae).
-- Después hay que recargar los procedimientos:  source 05_procedures_articulos.sql;
-- =============================================================================
USE labquim;

CREATE TABLE IF NOT EXISTS articulo_imagen (
  articulo_id    INT UNSIGNED NOT NULL,
  contenido      MEDIUMBLOB   NOT NULL,
  tipo_mime      VARCHAR(30)  NOT NULL,          -- image/jpeg | image/png | image/webp
  tamano_bytes   INT UNSIGNED NOT NULL,
  actualizado_en DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (articulo_id),
  CONSTRAINT fk_imagen_articulo FOREIGN KEY (articulo_id) REFERENCES articulos (id) ON DELETE CASCADE
) ENGINE=InnoDB;
