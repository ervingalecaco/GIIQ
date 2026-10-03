-- =============================================================================
-- LabQuim — Stored Procedures (lógica de negocio)
-- Archivo: 03_procedures.sql
-- Ejecutar DESPUÉS de 01_schema.sql (y 02_seeds.sql)
-- =============================================================================
-- Principios (lecciones de Rivera):
--   * Toda operación de existencias es TRANSACCIONAL y ATÓMICA.
--   * La auditoría se escribe DESDE el SP (el hosting niega CREATE TRIGGER).
--   * FEFO: al despachar se consume primero el lote más próximo a vencer.
--   * REACTIVO se consume; MATERIAL/cristalería se presta y se reingresa.
-- =============================================================================
USE labquim;

-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_entrada_registrar;
DROP PROCEDURE IF EXISTS sp_ajuste_registrar;
DROP PROCEDURE IF EXISTS sp_solicitud_crear;
DROP PROCEDURE IF EXISTS sp_solicitud_aprobar;
DROP PROCEDURE IF EXISTS sp_solicitud_rechazar;
DROP PROCEDURE IF EXISTS sp_solicitud_preparar;
DROP PROCEDURE IF EXISTS sp_solicitud_entregar;
DROP PROCEDURE IF EXISTS sp_solicitud_devolver;
-- -----------------------------------------------------------------------------

DELIMITER $$

-- =============================================================================
-- sp_entrada_registrar
-- Ingresa un nuevo lote (compra/entrada) y registra el movimiento ENTRADA.
-- =============================================================================
CREATE PROCEDURE sp_entrada_registrar (
    IN p_usuario_id       INT UNSIGNED,
    IN p_articulo_id      INT UNSIGNED,
    IN p_codigo_lote      VARCHAR(50),
    IN p_fecha_vencimiento DATE,
    IN p_cantidad         DECIMAL(14,3),
    IN p_proveedor_id     INT UNSIGNED,
    IN p_ubicacion_id     INT UNSIGNED,
    IN p_motivo           VARCHAR(255)
)
BEGIN
    DECLARE v_lote_id INT UNSIGNED;
    DECLARE v_mov_id  INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de entrada debe ser mayor que cero.';
    END IF;

    START TRANSACTION;

    INSERT INTO lotes (articulo_id, codigo_lote, fecha_vencimiento, cantidad_actual,
                       proveedor_id, ubicacion_id, fecha_ingreso)
    VALUES (p_articulo_id, p_codigo_lote, p_fecha_vencimiento, p_cantidad,
            p_proveedor_id, p_ubicacion_id, CURRENT_DATE);
    SET v_lote_id = LAST_INSERT_ID();

    INSERT INTO movimientos (tipo, usuario_id, motivo)
    VALUES ('ENTRADA', p_usuario_id, COALESCE(p_motivo, 'Entrada de mercadería'));
    SET v_mov_id = LAST_INSERT_ID();

    INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
    VALUES (v_mov_id, v_lote_id, p_cantidad);

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_usuario_id, 'lotes', v_lote_id, 'ENTRADA',
            JSON_OBJECT('articulo_id', p_articulo_id, 'cantidad', p_cantidad,
                        'lote', v_lote_id, 'vencimiento', p_fecha_vencimiento));

    COMMIT;

    SELECT v_lote_id AS lote_id, v_mov_id AS movimiento_id;
END$$

-- =============================================================================
-- sp_ajuste_registrar
-- Ajusta la cantidad de un lote (merma, corrección, rotura) y audita antes/después.
-- =============================================================================
CREATE PROCEDURE sp_ajuste_registrar (
    IN p_usuario_id    INT UNSIGNED,
    IN p_lote_id       INT UNSIGNED,
    IN p_nueva_cantidad DECIMAL(14,3),
    IN p_motivo        VARCHAR(255)
)
BEGIN
    DECLARE v_actual DECIMAL(14,3);
    DECLARE v_delta  DECIMAL(14,3);
    DECLARE v_mov_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_nueva_cantidad IS NULL OR p_nueva_cantidad < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nueva cantidad no puede ser negativa.';
    END IF;

    START TRANSACTION;

    SELECT cantidad_actual INTO v_actual FROM lotes WHERE id = p_lote_id FOR UPDATE;
    IF v_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lote indicado no existe.';
    END IF;

    SET v_delta = p_nueva_cantidad - v_actual;

    UPDATE lotes SET cantidad_actual = p_nueva_cantidad WHERE id = p_lote_id;

    INSERT INTO movimientos (tipo, usuario_id, motivo)
    VALUES ('AJUSTE', p_usuario_id, COALESCE(p_motivo, 'Ajuste de inventario'));
    SET v_mov_id = LAST_INSERT_ID();

    INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
    VALUES (v_mov_id, p_lote_id, v_delta);

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'lotes', p_lote_id, 'AJUSTE',
            JSON_OBJECT('cantidad', v_actual),
            JSON_OBJECT('cantidad', p_nueva_cantidad, 'delta', v_delta, 'motivo', p_motivo));

    COMMIT;

    SELECT v_mov_id AS movimiento_id, v_delta AS delta;
END$$

-- =============================================================================
-- sp_solicitud_crear  (rol Profesor)
-- Crea la cabecera + las líneas a partir de un JSON:
--   '[{"articulo_id":1,"unidad_id":1,"cantidad":5.5}, ...]'
-- =============================================================================
CREATE PROCEDURE sp_solicitud_crear (
    IN p_profesor_id     INT UNSIGNED,
    IN p_laboratorio_id  INT UNSIGNED,
    IN p_fecha_requerida DATE,
    IN p_observaciones   VARCHAR(255),
    IN p_detalle_json    JSON
)
BEGIN
    DECLARE v_sol_id INT UNSIGNED;
    DECLARE v_lineas INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_detalle_json IS NULL OR JSON_LENGTH(p_detalle_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud debe tener al menos una línea.';
    END IF;

    START TRANSACTION;

    INSERT INTO solicitudes (profesor_id, laboratorio_id, estado, fecha_requerida, observaciones)
    VALUES (p_profesor_id, p_laboratorio_id, 'PENDIENTE', p_fecha_requerida, p_observaciones);
    SET v_sol_id = LAST_INSERT_ID();

    INSERT INTO solicitud_detalle (solicitud_id, articulo_id, unidad_id, cantidad_solicitada)
    SELECT v_sol_id, jt.articulo_id, jt.unidad_id, jt.cantidad
    FROM JSON_TABLE(p_detalle_json, '$[*]'
         COLUMNS (
             articulo_id INT UNSIGNED  PATH '$.articulo_id',
             unidad_id   INT UNSIGNED  PATH '$.unidad_id',
             cantidad    DECIMAL(14,3) PATH '$.cantidad'
         )) AS jt;

    SET v_lineas = ROW_COUNT();

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_profesor_id, 'solicitudes', v_sol_id, 'CREAR',
            JSON_OBJECT('laboratorio_id', p_laboratorio_id, 'lineas', v_lineas,
                        'estado', 'PENDIENTE'));

    COMMIT;

    SELECT v_sol_id AS solicitud_id, v_lineas AS lineas;
END$$

-- =============================================================================
-- sp_solicitud_aprobar  (rol Supervisor)   PENDIENTE -> APROBADA
-- =============================================================================
CREATE PROCEDURE sp_solicitud_aprobar (
    IN p_solicitud_id  INT UNSIGNED,
    IN p_supervisor_id INT UNSIGNED
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se aprueban solicitudes en estado PENDIENTE.';
    END IF;

    UPDATE solicitudes
       SET estado = 'APROBADA', supervisor_id = p_supervisor_id, fecha_aprobacion = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_supervisor_id, 'solicitudes', p_solicitud_id, 'APROBAR',
            JSON_OBJECT('estado', v_estado), JSON_OBJECT('estado', 'APROBADA'));

    COMMIT;
END$$

-- =============================================================================
-- sp_solicitud_rechazar  (rol Supervisor)  PENDIENTE -> RECHAZADA
-- =============================================================================
CREATE PROCEDURE sp_solicitud_rechazar (
    IN p_solicitud_id  INT UNSIGNED,
    IN p_supervisor_id INT UNSIGNED,
    IN p_motivo        VARCHAR(255)
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_motivo IS NULL OR CHAR_LENGTH(TRIM(p_motivo)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el motivo del rechazo.';
    END IF;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se rechazan solicitudes en estado PENDIENTE.';
    END IF;

    UPDATE solicitudes
       SET estado = 'RECHAZADA', supervisor_id = p_supervisor_id,
           fecha_aprobacion = NOW(), motivo_rechazo = p_motivo
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_supervisor_id, 'solicitudes', p_solicitud_id, 'RECHAZAR',
            JSON_OBJECT('estado', v_estado),
            JSON_OBJECT('estado', 'RECHAZADA', 'motivo', p_motivo));

    COMMIT;
END$$

-- =============================================================================
-- sp_solicitud_preparar  (rol Bodega)   APROBADA -> PREPARADA
-- Asigna lotes por FEFO, descuenta existencias y registra el movimiento SALIDA.
-- Si un artículo no tiene stock suficiente, aborta toda la operación.
-- =============================================================================
CREATE PROCEDURE sp_solicitud_preparar (
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED
)
BEGIN
    DECLARE v_estado    VARCHAR(20);
    DECLARE v_mov_id    INT UNSIGNED;
    DECLARE v_lab_id    INT UNSIGNED;
    DECLARE v_done      INT DEFAULT 0;

    -- variables de línea
    DECLARE v_det_id    INT UNSIGNED;
    DECLARE v_art_id    INT UNSIGNED;
    DECLARE v_cant      DECIMAL(14,3);
    DECLARE v_total     DECIMAL(14,3);
    DECLARE v_rem       DECIMAL(14,3);
    DECLARE v_take      DECIMAL(14,3);
    DECLARE v_lote      INT UNSIGNED;
    DECLARE v_disp      DECIMAL(14,3);
    DECLARE v_first_lote INT UNSIGNED;

    DECLARE cur CURSOR FOR
        SELECT id, articulo_id, cantidad_solicitada
        FROM solicitud_detalle WHERE solicitud_id = p_solicitud_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validación de estado
    SELECT estado, laboratorio_id INTO v_estado, v_lab_id
    FROM solicitudes WHERE id = p_solicitud_id;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'APROBADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se preparan solicitudes APROBADAS.';
    END IF;

    START TRANSACTION;

    INSERT INTO movimientos (tipo, usuario_id, laboratorio_id, solicitud_id, motivo)
    VALUES ('SALIDA', p_bodega_id, v_lab_id, p_solicitud_id,
            CONCAT('Preparación de solicitud #', p_solicitud_id));
    SET v_mov_id = LAST_INSERT_ID();

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_det_id, v_art_id, v_cant;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- ¿Hay stock total suficiente para esta línea?
        SELECT COALESCE(SUM(cantidad_actual), 0) INTO v_total
        FROM lotes WHERE articulo_id = v_art_id AND activo = 1;

        IF v_total < v_cant THEN
            SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = 'Stock insuficiente para preparar la solicitud.';
        END IF;

        SET v_rem = v_cant;
        SET v_first_lote = NULL;

        -- Consumo por FEFO: vencimiento más próximo primero (NULL al final)
        fefo_loop: WHILE v_rem > 0 DO
            SELECT id, cantidad_actual INTO v_lote, v_disp
            FROM lotes
            WHERE articulo_id = v_art_id AND activo = 1 AND cantidad_actual > 0
            ORDER BY (fecha_vencimiento IS NULL), fecha_vencimiento, id
            LIMIT 1
            FOR UPDATE;

            SET v_take = LEAST(v_disp, v_rem);

            UPDATE lotes SET cantidad_actual = cantidad_actual - v_take WHERE id = v_lote;

            INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
            VALUES (v_mov_id, v_lote, v_take);

            IF v_first_lote IS NULL THEN
                SET v_first_lote = v_lote;
            END IF;

            SET v_rem = v_rem - v_take;
        END WHILE;

        UPDATE solicitud_detalle
           SET cantidad_preparada = v_cant, lote_id = v_first_lote
         WHERE id = v_det_id;
    END LOOP;
    CLOSE cur;

    UPDATE solicitudes
       SET estado = 'PREPARADA', bodega_id = p_bodega_id
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'PREPARAR',
            JSON_OBJECT('estado', 'APROBADA'),
            JSON_OBJECT('estado', 'PREPARADA', 'movimiento_id', v_mov_id));

    COMMIT;

    SELECT v_mov_id AS movimiento_id;
END$$

-- =============================================================================
-- sp_solicitud_entregar  (rol Bodega)   PREPARADA -> ENTREGADA
-- =============================================================================
CREATE PROCEDURE sp_solicitud_entregar (
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PREPARADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se entregan solicitudes PREPARADAS.';
    END IF;

    UPDATE solicitudes
       SET estado = 'ENTREGADA', bodega_id = p_bodega_id, fecha_entrega = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'ENTREGAR',
            JSON_OBJECT('estado', 'PREPARADA'), JSON_OBJECT('estado', 'ENTREGADA'));

    COMMIT;
END$$

-- =============================================================================
-- sp_solicitud_devolver  (rol Bodega)   ENTREGADA -> CERRADA
-- Reingresa a stock la cristalería/material prestado (tipo = MATERIAL),
-- basándose en lo que salió en el movimiento SALIDA de la solicitud.
-- Los reactivos quedan consumidos (no se reingresan).
-- =============================================================================
CREATE PROCEDURE sp_solicitud_devolver (
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_mat    INT DEFAULT 0;
    DECLARE v_dev_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se registran devoluciones de solicitudes ENTREGADAS.';
    END IF;

    -- ¿Hubo materiales prestados en la salida de esta solicitud?
    SELECT COUNT(*) INTO v_mat
    FROM movimiento_detalle md
    JOIN movimientos m ON m.id = md.movimiento_id
    JOIN lotes lo      ON lo.id = md.lote_id
    JOIN articulos a   ON a.id = lo.articulo_id
    WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'MATERIAL';

    IF v_mat > 0 THEN
        INSERT INTO movimientos (tipo, usuario_id, solicitud_id, motivo)
        VALUES ('DEVOLUCION', p_bodega_id, p_solicitud_id,
                CONCAT('Devolución de material — solicitud #', p_solicitud_id));
        SET v_dev_id = LAST_INSERT_ID();

        -- Detalle de la devolución (cantidad por lote que salió como material)
        INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
        SELECT v_dev_id, md.lote_id, SUM(md.cantidad)
        FROM movimiento_detalle md
        JOIN movimientos m ON m.id = md.movimiento_id
        JOIN lotes lo      ON lo.id = md.lote_id
        JOIN articulos a   ON a.id = lo.articulo_id
        WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'MATERIAL'
        GROUP BY md.lote_id;

        -- Reingreso real a los lotes
        UPDATE lotes l
        JOIN (
            SELECT md.lote_id, SUM(md.cantidad) AS qty
            FROM movimiento_detalle md
            JOIN movimientos m ON m.id = md.movimiento_id
            JOIN lotes lo      ON lo.id = md.lote_id
            JOIN articulos a   ON a.id = lo.articulo_id
            WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'MATERIAL'
            GROUP BY md.lote_id
        ) x ON x.lote_id = l.id
        SET l.cantidad_actual = l.cantidad_actual + x.qty;

        -- Marca lo devuelto en el detalle de la solicitud (materiales)
        UPDATE solicitud_detalle sd
        JOIN articulos a ON a.id = sd.articulo_id
        SET sd.cantidad_devuelta = sd.cantidad_preparada
        WHERE sd.solicitud_id = p_solicitud_id AND a.tipo = 'MATERIAL';
    END IF;

    UPDATE solicitudes
       SET estado = 'CERRADA', fecha_devolucion = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'DEVOLVER',
            JSON_OBJECT('estado', 'ENTREGADA'),
            JSON_OBJECT('estado', 'CERRADA', 'materiales_reingresados', v_mat));

    COMMIT;
END$$

DELIMITER ;

-- =============================================================================
-- Fin de stored procedures.
-- =============================================================================
