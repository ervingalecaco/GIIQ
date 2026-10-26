-- =============================================================================
-- GIIQ — Migración: notificaciones dentro de la app
-- Archivo: 16_migracion_notificaciones.sql
--
-- Cada acción del flujo (crear, avalar, aprobar, rechazar, preparar, entregar,
-- devolver) y de las cuentas (baja con cargo, reposición) avisa a quien le toca:
-- el profesor cuando su estudiante pide algo, el supervisor cuando hay algo por
-- aprobar, bodega cuando hay algo por preparar y el solicitante en cada paso.
-- Las notificaciones las escriben los mismos procedimientos, dentro de su
-- transacción: si la acción falla, no queda aviso suelto.
--
-- Solo para bases creadas ANTES de este cambio (01_schema.sql ya la trae).
-- Después hay que recargar los procedimientos:  source 03_procedures.sql;
-- =============================================================================
USE labquim;

CREATE TABLE IF NOT EXISTS notificaciones (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id   INT UNSIGNED NOT NULL,              -- destinatario
  tipo         VARCHAR(30)  NOT NULL,              -- evento: CREADA, APROBADA, CARGO, …
  titulo       VARCHAR(120) NOT NULL,
  mensaje      VARCHAR(500) NOT NULL,
  enlace       VARCHAR(200) NULL,                  -- ruta de la app a la que lleva
  solicitud_id INT UNSIGNED NULL,
  leida        TINYINT(1)   NOT NULL DEFAULT 0,
  creada_en    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  leida_en     DATETIME     NULL,
  PRIMARY KEY (id),
  KEY idx_notif_usuario (usuario_id, leida, creada_en),
  CONSTRAINT fk_notif_usuario   FOREIGN KEY (usuario_id)   REFERENCES usuarios (id) ON DELETE CASCADE,
  CONSTRAINT fk_notif_solicitud FOREIGN KEY (solicitud_id) REFERENCES solicitudes (id) ON DELETE SET NULL
) ENGINE=InnoDB;
