-- =============================================================================
-- GIIQ — Stored Procedures (lógica de negocio)
-- Archivo: 03_procedures.sql
-- Ejecutar DESPUÉS de 01_schema.sql (y 02_seeds.sql)
-- =============================================================================
-- Principios (lecciones de Rivera):
--   * Toda operación de existencias es TRANSACCIONAL y ATÓMICA.
--   * La auditoría se escribe DESDE el SP (el hosting niega CREATE TRIGGER).
--   * FEFO: al despachar se consume primero el lote más próximo a vencer.
--   * REACTIVO se consume; CRISTALERIA se presta y se reingresa.
-- =============================================================================
USE labquim;

-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_entrada_registrar;
DROP PROCEDURE IF EXISTS sp_ajuste_registrar;
DROP PROCEDURE IF EXISTS sp_solicitud_crear;
DROP PROCEDURE IF EXISTS sp_solicitud_avalar;
DROP PROCEDURE IF EXISTS sp_solicitud_rechazar_profesor;
DROP PROCEDURE IF EXISTS sp_solicitud_aprobar;
DROP PROCEDURE IF EXISTS sp_solicitud_rechazar;
DROP PROCEDURE IF EXISTS sp_solicitud_preparar;
DROP PROCEDURE IF EXISTS sp_solicitud_entregar;
DROP PROCEDURE IF EXISTS sp_solicitud_devolver;
DROP PROCEDURE IF EXISTS sp__baja_aplicar;
DROP PROCEDURE IF EXISTS sp_baja_registrar;
DROP PROCEDURE IF EXISTS sp_reposicion_registrar;
DROP PROCEDURE IF EXISTS sp_constancia_emitir;
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
-- sp_solicitud_crear  (rol Profesor o Estudiante)
-- Crea la cabecera + las líneas a partir de un JSON:
--   '[{"articulo_id":1,"unidad_id":1,"cantidad":5.5}, ...]'
-- Si la crea un estudiante (p_estudiante_id no nulo), p_profesor_id es el
-- profesor responsable que él eligió y la solicitud nace en PENDIENTE_PROFESOR:
-- primero la avala ese profesor y luego la aprueba el Supervisor.
-- La práctica debe pertenecer a una clase que imparte el profesor responsable
-- (salvo que quien la crea sea Administrador); el laboratorio sale de la práctica.
-- =============================================================================
CREATE PROCEDURE sp_solicitud_crear (
    IN p_profesor_id     INT UNSIGNED,
    IN p_estudiante_id   INT UNSIGNED,
    IN p_tipo            VARCHAR(12),       -- REACTIVO | CRISTALERIA: todas las líneas deben ser de ese tipo
    IN p_practica_id     INT UNSIGNED,
    IN p_fecha_requerida DATE,
    IN p_observaciones   VARCHAR(255),
    IN p_detalle_json    JSON
)
BEGIN
    DECLARE v_sol_id INT UNSIGNED;
    DECLARE v_lineas INT;
    DECLARE v_estado VARCHAR(20) DEFAULT 'PENDIENTE';
    DECLARE v_clase  INT UNSIGNED;
    DECLARE v_lab    INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_detalle_json IS NULL OR JSON_LENGTH(p_detalle_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud debe tener al menos una línea.';
    END IF;

    IF p_tipo IS NULL OR p_tipo NOT IN ('REACTIVO', 'CRISTALERIA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de solicitud debe ser REACTIVO o CRISTALERIA.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM JSON_TABLE(p_detalle_json, '$[*]' COLUMNS (articulo_id INT UNSIGNED PATH '$.articulo_id')) jt
        LEFT JOIN articulos a ON a.id = jt.articulo_id
        WHERE a.id IS NULL OR a.tipo <> p_tipo) THEN
        IF p_tipo = 'REACTIVO' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una solicitud de reactivos solo puede incluir reactivos.';
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una solicitud de cristalería solo puede incluir cristalería.';
        END IF;
    END IF;

    IF p_estudiante_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
                       WHERE u.id = p_profesor_id AND u.activo = 1 AND r.nombre = 'Profesor') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige un profesor responsable válido.';
        END IF;
        SET v_estado = 'PENDIENTE_PROFESOR';
    END IF;

    SELECT pr.clase_id, pr.laboratorio_id INTO v_clase, v_lab
    FROM practicas pr JOIN clases c ON c.id = pr.clase_id
    WHERE pr.id = p_practica_id AND pr.activo = 1 AND c.activo = 1;
    IF v_clase IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige una práctica válida.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM clase_profesor WHERE clase_id = v_clase AND profesor_id = p_profesor_id)
       AND NOT EXISTS (SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
                       WHERE u.id = p_profesor_id AND r.nombre = 'Administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La práctica no pertenece a una clase de ese profesor.';
    END IF;

    START TRANSACTION;

    INSERT INTO solicitudes (tipo, profesor_id, estudiante_id, practica_id, laboratorio_id, estado, fecha_requerida, observaciones)
    VALUES (p_tipo, p_profesor_id, p_estudiante_id, p_practica_id, v_lab, v_estado, p_fecha_requerida, p_observaciones);
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
    VALUES (COALESCE(p_estudiante_id, p_profesor_id), 'solicitudes', v_sol_id, 'CREAR',
            JSON_OBJECT('tipo', p_tipo, 'practica_id', p_practica_id, 'laboratorio_id', v_lab, 'lineas', v_lineas,
                        'profesor_id', p_profesor_id, 'estudiante_id', p_estudiante_id,
                        'estado', v_estado));

    COMMIT;

    SELECT v_sol_id AS solicitud_id, v_lineas AS lineas;
END$$

-- =============================================================================
-- sp_solicitud_avalar  (rol Profesor)   PENDIENTE_PROFESOR -> PENDIENTE
-- El profesor responsable da el visto bueno a la solicitud de su estudiante;
-- pasa a la bandeja del Supervisor para la aprobación final.
-- Solo el profesor responsable (o un Administrador) puede avalarla.
-- =============================================================================
CREATE PROCEDURE sp_solicitud_avalar (
    IN p_solicitud_id INT UNSIGNED,
    IN p_usuario_id   INT UNSIGNED
)
BEGIN
    DECLARE v_estado   VARCHAR(20);
    DECLARE v_profesor INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado, profesor_id INTO v_estado, v_profesor
    FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE_PROFESOR' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se avalan solicitudes que esperan al profesor.';
    END IF;
    IF v_profesor <> p_usuario_id AND NOT EXISTS (
        SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
        WHERE u.id = p_usuario_id AND r.nombre = 'Administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el profesor responsable puede avalar esta solicitud.';
    END IF;

    UPDATE solicitudes
       SET estado = 'PENDIENTE', fecha_aval_profesor = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'solicitudes', p_solicitud_id, 'AVALAR',
            JSON_OBJECT('estado', v_estado), JSON_OBJECT('estado', 'PENDIENTE'));

    COMMIT;
END$$

-- =============================================================================
-- sp_solicitud_rechazar_profesor  (rol Profesor)   PENDIENTE_PROFESOR -> RECHAZADA
-- =============================================================================
CREATE PROCEDURE sp_solicitud_rechazar_profesor (
    IN p_solicitud_id INT UNSIGNED,
    IN p_usuario_id   INT UNSIGNED,
    IN p_motivo       VARCHAR(255)
)
BEGIN
    DECLARE v_estado   VARCHAR(20);
    DECLARE v_profesor INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Indica el motivo del rechazo.';
    END IF;

    START TRANSACTION;

    SELECT estado, profesor_id INTO v_estado, v_profesor
    FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE_PROFESOR' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se rechazan aquí solicitudes que esperan al profesor.';
    END IF;
    IF v_profesor <> p_usuario_id AND NOT EXISTS (
        SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
        WHERE u.id = p_usuario_id AND r.nombre = 'Administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el profesor responsable puede rechazar esta solicitud.';
    END IF;

    UPDATE solicitudes
       SET estado = 'RECHAZADA', motivo_rechazo = p_motivo
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'solicitudes', p_solicitud_id, 'RECHAZAR_PROFESOR',
            JSON_OBJECT('estado', v_estado), JSON_OBJECT('estado', 'RECHAZADA', 'motivo', p_motivo));

    COMMIT;
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
-- sp_solicitud_entregar  (rol Bodega)
--   Cristalería: PREPARADA -> ENTREGADA (queda pendiente la devolución).
--   Reactivos:   PREPARADA -> CERRADA   (se consumen; no hay nada que devolver).
-- =============================================================================
CREATE PROCEDURE sp_solicitud_entregar (
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_tipo   VARCHAR(12);
    DECLARE v_nuevo  VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado, tipo INTO v_estado, v_tipo FROM solicitudes WHERE id = p_solicitud_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe.';
    END IF;
    IF v_estado <> 'PREPARADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se entregan solicitudes PREPARADAS.';
    END IF;

    SET v_nuevo = IF(v_tipo = 'REACTIVO', 'CERRADA', 'ENTREGADA');

    UPDATE solicitudes
       SET estado = v_nuevo, bodega_id = p_bodega_id, fecha_entrega = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'ENTREGAR',
            JSON_OBJECT('estado', 'PREPARADA'), JSON_OBJECT('estado', v_nuevo));

    COMMIT;
END$$

-- =============================================================================
-- sp__baja_aplicar  (interno: lo llaman sp_baja_registrar y sp_solicitud_devolver)
-- Saca del stock piezas de cristalería quebradas, extraviadas o deterioradas:
-- movimiento BAJA con su detalle por lote, el registro de la baja y, si hay
-- estudiante responsable, el cargo en su cuenta (piezas por reponer).
-- NO abre ni cierra transacción: corre dentro de la de quien lo llama.
-- Si viene de una solicitud, descuenta primero de los lotes que salieron en ella.
-- =============================================================================
CREATE PROCEDURE sp__baja_aplicar (
    IN  p_usuario_id    INT UNSIGNED,
    IN  p_articulo_id   INT UNSIGNED,
    IN  p_cantidad      DECIMAL(14,3),
    IN  p_causa         VARCHAR(20),
    IN  p_solicitud_id  INT UNSIGNED,
    IN  p_estudiante_id INT UNSIGNED,
    IN  p_observacion   VARCHAR(255),
    OUT p_baja_id       INT UNSIGNED
)
BEGIN
    DECLARE v_tipo   VARCHAR(20);
    DECLARE v_nombre VARCHAR(150);
    DECLARE v_total  DECIMAL(14,3);
    DECLARE v_rem    DECIMAL(14,3);
    DECLARE v_lote   INT UNSIGNED;
    DECLARE v_disp   DECIMAL(14,3);
    DECLARE v_toma   DECIMAL(14,3);
    DECLARE v_mov_id INT UNSIGNED;
    DECLARE v_es_est INT DEFAULT 0;

    SELECT tipo, nombre INTO v_tipo, v_nombre FROM articulos WHERE id = p_articulo_id;
    IF v_tipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artículo no existe.';
    END IF;
    IF v_tipo <> 'CRISTALERIA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se dan de baja artículos de cristalería.';
    END IF;
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de la baja debe ser mayor que cero.';
    END IF;
    IF p_causa NOT IN ('QUEBRADO','EXTRAVIADO','DETERIORADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Causa de baja no válida.';
    END IF;
    IF p_estudiante_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_es_est
        FROM usuarios u JOIN roles r ON r.id = u.rol_id
        WHERE u.id = p_estudiante_id AND r.nombre = 'Estudiante';
        IF v_es_est = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El responsable de la baja debe ser un estudiante.';
        END IF;
    END IF;

    SELECT COALESCE(SUM(cantidad_actual), 0) INTO v_total
    FROM lotes WHERE articulo_id = p_articulo_id AND activo = 1;
    IF v_total < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay existencia suficiente para dar de baja esa cantidad.';
    END IF;

    INSERT INTO movimientos (tipo, usuario_id, solicitud_id, motivo)
    VALUES ('BAJA', p_usuario_id, p_solicitud_id,
            CONCAT('Baja (', LOWER(p_causa), ')',
                   IF(p_solicitud_id IS NULL, '', CONCAT(' — solicitud #', p_solicitud_id))));
    SET v_mov_id = LAST_INSERT_ID();

    -- Descuento por lote: primero los que salieron en la solicitud, luego el de más existencia.
    SET v_rem = p_cantidad;
    WHILE v_rem > 0 DO
        SET v_lote = NULL;
        SELECT l.id, l.cantidad_actual INTO v_lote, v_disp
        FROM lotes l
        WHERE l.articulo_id = p_articulo_id AND l.activo = 1 AND l.cantidad_actual > 0
        ORDER BY EXISTS (
                   SELECT 1 FROM movimiento_detalle md
                   JOIN movimientos m ON m.id = md.movimiento_id
                   WHERE md.lote_id = l.id AND m.tipo = 'SALIDA'
                     AND p_solicitud_id IS NOT NULL AND m.solicitud_id = p_solicitud_id) DESC,
                 l.cantidad_actual DESC
        LIMIT 1
        FOR UPDATE;
        IF v_lote IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay existencia suficiente para dar de baja esa cantidad.';
        END IF;

        SET v_toma = LEAST(v_rem, v_disp);
        UPDATE lotes SET cantidad_actual = cantidad_actual - v_toma WHERE id = v_lote;
        INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad) VALUES (v_mov_id, v_lote, v_toma);
        SET v_rem = v_rem - v_toma;
    END WHILE;

    INSERT INTO bajas (articulo_id, cantidad, causa, solicitud_id, estudiante_id, movimiento_id, registrado_por, observacion)
    VALUES (p_articulo_id, p_cantidad, p_causa, p_solicitud_id, p_estudiante_id, v_mov_id, p_usuario_id,
            NULLIF(TRIM(p_observacion), ''));
    SET p_baja_id = LAST_INSERT_ID();

    IF p_estudiante_id IS NOT NULL THEN
        INSERT INTO cargos_estudiante (baja_id, estudiante_id, articulo_id, cantidad)
        VALUES (p_baja_id, p_estudiante_id, p_articulo_id, p_cantidad);
    END IF;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'bajas', p_baja_id, 'CREAR', NULL,
            JSON_OBJECT('articulo', v_nombre, 'cantidad', p_cantidad, 'causa', p_causa,
                        'solicitud_id', p_solicitud_id, 'estudiante_id', p_estudiante_id));
END$$

-- =============================================================================
-- sp_baja_registrar  (rol Bodega)
-- Baja fuera de una devolución: lo que se quiebra en bodega o en el laboratorio.
-- Con estudiante responsable se le carga a su cuenta; sin él, solo sale del stock.
-- =============================================================================
CREATE PROCEDURE sp_baja_registrar (
    IN p_usuario_id    INT UNSIGNED,
    IN p_articulo_id   INT UNSIGNED,
    IN p_cantidad      DECIMAL(14,3),
    IN p_causa         VARCHAR(20),
    IN p_estudiante_id INT UNSIGNED,
    IN p_observacion   VARCHAR(255)
)
BEGIN
    DECLARE v_baja_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    CALL sp__baja_aplicar(p_usuario_id, p_articulo_id, p_cantidad, p_causa, NULL,
                          p_estudiante_id, p_observacion, v_baja_id);
    COMMIT;

    SELECT v_baja_id AS baja_id;
END$$

-- =============================================================================
-- sp_reposicion_registrar  (rol Bodega)
-- El estudiante entrega piezas iguales a las que quebró: vuelven al stock (al
-- lote de donde salió la baja) y se descuentan de su cargo. Puede ser parcial.
-- =============================================================================
CREATE PROCEDURE sp_reposicion_registrar (
    IN p_usuario_id  INT UNSIGNED,
    IN p_cargo_id    INT UNSIGNED,
    IN p_cantidad    DECIMAL(14,3),
    IN p_observacion VARCHAR(255)
)
BEGIN
    DECLARE v_estado     VARCHAR(20);
    DECLARE v_pendiente  DECIMAL(14,3);
    DECLARE v_estudiante INT UNSIGNED;
    DECLARE v_baja       INT UNSIGNED;
    DECLARE v_lote       INT UNSIGNED;
    DECLARE v_mov_id     INT UNSIGNED;
    DECLARE v_repo_id    INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado, cantidad - cantidad_repuesta, estudiante_id, baja_id
      INTO v_estado, v_pendiente, v_estudiante, v_baja
    FROM cargos_estudiante WHERE id = p_cargo_id FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cargo no existe.';
    END IF;
    IF v_estado <> 'PENDIENTE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este cargo ya está saldado.';
    END IF;
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad repuesta debe ser mayor que cero.';
    END IF;
    IF p_cantidad > v_pendiente THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede reponer más de lo que el estudiante debe.';
    END IF;

    -- La pieza repuesta vuelve al lote del que más salió en la baja.
    SELECT md.lote_id INTO v_lote
    FROM bajas b JOIN movimiento_detalle md ON md.movimiento_id = b.movimiento_id
    WHERE b.id = v_baja
    ORDER BY md.cantidad DESC LIMIT 1;

    INSERT INTO movimientos (tipo, usuario_id, motivo)
    VALUES ('REPOSICION', p_usuario_id, CONCAT('Reposición del estudiante — baja #', v_baja));
    SET v_mov_id = LAST_INSERT_ID();
    INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad) VALUES (v_mov_id, v_lote, p_cantidad);
    UPDATE lotes SET cantidad_actual = cantidad_actual + p_cantidad WHERE id = v_lote;

    INSERT INTO reposiciones (cargo_id, cantidad, movimiento_id, recibido_por, observacion)
    VALUES (p_cargo_id, p_cantidad, v_mov_id, p_usuario_id, NULLIF(TRIM(p_observacion), ''));
    SET v_repo_id = LAST_INSERT_ID();

    UPDATE cargos_estudiante
       SET cantidad_repuesta = cantidad_repuesta + p_cantidad,
           estado     = IF(cantidad_repuesta >= cantidad, 'SALDADO', 'PENDIENTE'),
           saldado_en = IF(cantidad_repuesta >= cantidad, NOW(), NULL)
     WHERE id = p_cargo_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'cargos_estudiante', p_cargo_id, 'REPONER',
            JSON_OBJECT('pendiente', v_pendiente),
            JSON_OBJECT('repuesto', p_cantidad, 'pendiente', v_pendiente - p_cantidad, 'reposicion_id', v_repo_id));

    COMMIT;
END$$

-- =============================================================================
-- sp_constancia_emitir  (rol Bodega)
-- Constancia de solvencia: solo si el estudiante no debe ninguna pieza.
-- Devuelve el folio (id) y la fecha para imprimirla.
-- =============================================================================
CREATE PROCEDURE sp_constancia_emitir (
    IN p_usuario_id    INT UNSIGNED,
    IN p_estudiante_id INT UNSIGNED
)
BEGIN
    DECLARE v_es_est    INT DEFAULT 0;
    DECLARE v_pendiente DECIMAL(14,3);
    DECLARE v_folio     INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO v_es_est
    FROM usuarios u JOIN roles r ON r.id = u.rol_id
    WHERE u.id = p_estudiante_id AND r.nombre = 'Estudiante';
    IF v_es_est = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La constancia solo se emite a estudiantes.';
    END IF;

    SELECT COALESCE(SUM(cantidad - cantidad_repuesta), 0) INTO v_pendiente
    FROM cargos_estudiante WHERE estudiante_id = p_estudiante_id AND estado = 'PENDIENTE';
    IF v_pendiente > 0 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'El estudiante tiene piezas pendientes de reponer: no se puede emitir la constancia.';
    END IF;

    START TRANSACTION;
    INSERT INTO constancias_solvencia (estudiante_id, emitida_por) VALUES (p_estudiante_id, p_usuario_id);
    SET v_folio = LAST_INSERT_ID();
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'constancias_solvencia', v_folio, 'EMITIR', NULL,
            JSON_OBJECT('estudiante_id', p_estudiante_id));
    COMMIT;

    SELECT id AS folio, fecha FROM constancias_solvencia WHERE id = v_folio;
END$$

-- =============================================================================
-- sp_solicitud_devolver  (rol Bodega)   ENTREGADA -> CERRADA
-- Reingresa a stock la cristalería prestada (tipo = CRISTALERIA),
-- basándose en lo que salió en el movimiento SALIDA de la solicitud.
-- Los reactivos quedan consumidos (no se reingresan).
-- p_quebradas: piezas que NO volvieron, en JSON
--   [{"articulo_id":5,"cantidad":1,"estudiante_id":12,"causa":"QUEBRADO","observacion":"…"}]
-- Cada una se da de baja (sp__baja_aplicar) después del reingreso, así el stock
-- queda en lo realmente devuelto y el kardex muestra la devolución y la baja.
-- =============================================================================
CREATE PROCEDURE sp_solicitud_devolver (
    IN p_solicitud_id INT UNSIGNED,
    IN p_bodega_id    INT UNSIGNED,
    IN p_quebradas    JSON
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_mat    INT DEFAULT 0;
    DECLARE v_dev_id INT UNSIGNED;
    DECLARE v_i      INT DEFAULT 0;
    DECLARE v_n      INT DEFAULT 0;
    DECLARE v_art    INT UNSIGNED;
    DECLARE v_cant   DECIMAL(14,3);
    DECLARE v_est    INT UNSIGNED;
    DECLARE v_causa  VARCHAR(20);
    DECLARE v_obs    VARCHAR(255);
    DECLARE v_det    INT UNSIGNED;
    DECLARE v_prep   DECIMAL(14,3);
    DECLARE v_queb   DECIMAL(14,3);
    DECLARE v_baja   INT UNSIGNED;

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
    WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'CRISTALERIA';

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
        WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'CRISTALERIA'
        GROUP BY md.lote_id;

        -- Reingreso real a los lotes
        UPDATE lotes l
        JOIN (
            SELECT md.lote_id, SUM(md.cantidad) AS qty
            FROM movimiento_detalle md
            JOIN movimientos m ON m.id = md.movimiento_id
            JOIN lotes lo      ON lo.id = md.lote_id
            JOIN articulos a   ON a.id = lo.articulo_id
            WHERE m.solicitud_id = p_solicitud_id AND m.tipo = 'SALIDA' AND a.tipo = 'CRISTALERIA'
            GROUP BY md.lote_id
        ) x ON x.lote_id = l.id
        SET l.cantidad_actual = l.cantidad_actual + x.qty;

        -- Marca lo devuelto en el detalle de la solicitud (materiales)
        UPDATE solicitud_detalle sd
        JOIN articulos a ON a.id = sd.articulo_id
        SET sd.cantidad_devuelta = sd.cantidad_preparada
        WHERE sd.solicitud_id = p_solicitud_id AND a.tipo = 'CRISTALERIA';
    END IF;

    -- Piezas quebradas: se dan de baja y, con responsable, se cargan a su cuenta.
    SET v_n = COALESCE(JSON_LENGTH(p_quebradas), 0);
    WHILE v_i < v_n DO
        -- JSON_EXTRACT admite la ruta armada con CONCAT; NULLIF('null') = campo vacío.
        SET v_art   = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_quebradas, CONCAT('$[', v_i, '].articulo_id'))), 'null') AS UNSIGNED);
        SET v_cant  = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_quebradas, CONCAT('$[', v_i, '].cantidad'))), 'null') AS DECIMAL(14,3));
        SET v_est   = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_quebradas, CONCAT('$[', v_i, '].estudiante_id'))), 'null') AS UNSIGNED);
        SET v_causa = COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_quebradas, CONCAT('$[', v_i, '].causa'))), 'null'), 'QUEBRADO');
        SET v_obs   = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_quebradas, CONCAT('$[', v_i, '].observacion'))), 'null');

        -- Debe ser cristalería entregada en esta solicitud y no más de lo que salió.
        SET v_det = NULL;
        SELECT sd.id, sd.cantidad_preparada, sd.cantidad_quebrada INTO v_det, v_prep, v_queb
        FROM solicitud_detalle sd JOIN articulos a ON a.id = sd.articulo_id
        WHERE sd.solicitud_id = p_solicitud_id AND sd.articulo_id = v_art AND a.tipo = 'CRISTALERIA'
        ORDER BY sd.cantidad_preparada DESC LIMIT 1;
        IF v_det IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una pieza quebrada no pertenece a la cristalería de esta solicitud.';
        END IF;
        IF v_cant IS NULL OR v_cant <= 0 OR v_queb + v_cant > v_prep THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden reportar más piezas quebradas de las que se entregaron.';
        END IF;

        UPDATE solicitud_detalle
           SET cantidad_quebrada = cantidad_quebrada + v_cant,
               cantidad_devuelta = cantidad_preparada - cantidad_quebrada
         WHERE id = v_det;

        CALL sp__baja_aplicar(p_bodega_id, v_art, v_cant, v_causa, p_solicitud_id, v_est, v_obs, v_baja);
        SET v_i = v_i + 1;
    END WHILE;

    UPDATE solicitudes
       SET estado = 'CERRADA', fecha_devolucion = NOW()
     WHERE id = p_solicitud_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_bodega_id, 'solicitudes', p_solicitud_id, 'DEVOLVER',
            JSON_OBJECT('estado', 'ENTREGADA'),
            JSON_OBJECT('estado', 'CERRADA', 'materiales_reingresados', v_mat, 'bajas', v_n));

    COMMIT;
END$$

DELIMITER ;

-- =============================================================================
-- Fin de stored procedures.
-- =============================================================================
