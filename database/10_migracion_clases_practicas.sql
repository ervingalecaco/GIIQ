-- =============================================================================
-- GIIQ — Migración: clases, profesores por clase y prácticas
-- Archivo: 10_migracion_clases_practicas.sql
--
-- Al crear una solicitud ahora se elige: profesor -> clase -> práctica.
-- El laboratorio de la solicitud sale de la práctica.
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql ya lo trae).
-- Después hay que recargar los procedimientos:
--   source 03_procedures.sql; source 07_procedures_catalogos.sql;
-- Las solicitudes antiguas quedan con practica_id = NULL (siguen mostrando su laboratorio).
-- =============================================================================
USE labquim;

CREATE TABLE clases (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  anio          TINYINT UNSIGNED NOT NULL,    -- año de la carrera: 1 a 5
  nombre        VARCHAR(120) NOT NULL,
  descripcion   VARCHAR(255) NULL,
  activo        TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_clases_anio_nombre (anio, nombre),
  CONSTRAINT ck_clases_anio CHECK (anio BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE clase_profesor (
  clase_id      INT UNSIGNED NOT NULL,
  profesor_id   INT UNSIGNED NOT NULL,
  PRIMARY KEY (clase_id, profesor_id),
  KEY idx_cp_profesor (profesor_id),
  CONSTRAINT fk_cp_clase    FOREIGN KEY (clase_id)    REFERENCES clases (id) ON DELETE CASCADE,
  CONSTRAINT fk_cp_profesor FOREIGN KEY (profesor_id) REFERENCES usuarios (id)
) ENGINE=InnoDB;

CREATE TABLE practicas (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  clase_id        INT UNSIGNED NOT NULL,
  nombre          VARCHAR(150) NOT NULL,
  laboratorio_id  INT UNSIGNED NOT NULL,
  descripcion     VARCHAR(255) NULL,
  activo          TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_practicas_clase_nombre (clase_id, nombre),
  KEY idx_practicas_laboratorio (laboratorio_id),
  CONSTRAINT fk_practica_clase       FOREIGN KEY (clase_id)       REFERENCES clases (id),
  CONSTRAINT fk_practica_laboratorio FOREIGN KEY (laboratorio_id) REFERENCES laboratorios (id)
) ENGINE=InnoDB;

ALTER TABLE solicitudes
  ADD COLUMN practica_id INT UNSIGNED NULL AFTER estudiante_id,
  ADD KEY idx_sol_practica (practica_id),
  ADD CONSTRAINT fk_sol_practica FOREIGN KEY (practica_id) REFERENCES practicas (id);
