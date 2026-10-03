-- =============================================================================
-- LabQuim — Stored Procedures de Artículos (CRUD)
-- Archivo: 05_procedures_articulos.sql
-- Ejecutar DESPUÉS de 01_schema.sql
-- =============================================================================
USE labquim;

DROP PROCEDURE IF EXISTS sp_articulo_crear;
DROP PROCEDURE IF EXISTS sp_articulo_editar;
DROP PROCEDURE IF EXISTS sp_articulo_estado;

DELIMITER $$

-- =============================================================================
-- sp_articulo_crear
-- Crea un artículo (REACTIVO o MATERIAL). Si es REACTIVO, además su ficha 1:1.
-- Los campos p_cas..p_condiciones solo aplican a REACTIVO (se ignoran en MATERIAL).
-- =============================================================================
CREATE PROCEDURE sp_articulo_crear (
    IN p_usuario_id     INT UNSIGNED,
    IN p_tipo           VARCHAR(10),
    IN p_codigo         VARCHAR(40),
    IN p_nombre         VARCHAR(150),
    IN p_categoria_id   INT UNSIGNED,
    IN p_unidad_id      INT UNSIGNED,
    IN p_stock_minimo   DECIMAL(14,3),
    IN p_cas            VARCHAR(20),
    IN p_formula        VARCHAR(60),
    IN p_clasificacion_peligro VARCHAR(120),
    IN p_estado_fisico  VARCHAR(10),
    IN p_concentracion  VARCHAR(40),
    IN p_condiciones_almacenamiento VARCHAR(255)
)
BEGIN
    DECLARE v_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_tipo NOT IN ('REACTIVO', 'MATERIAL') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo debe ser REACTIVO o MATERIAL.';
    END IF;
    IF EXISTS (SELECT 1 FROM articulos WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un artículo con ese código.';
    END IF;

    START TRANSACTION;

    INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
    VALUES (p_tipo, p_codigo, p_nombre, p_categoria_id, p_unidad_id, COALESCE(p_stock_minimo, 0));
    SET v_id = LAST_INSERT_ID();

    IF p_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento)
        VALUES
            (v_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento);
    END IF;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_usuario_id, 'articulos', v_id, 'CREAR',
            JSON_OBJECT('tipo', p_tipo, 'codigo', p_codigo, 'nombre', p_nombre));

    COMMIT;

    SELECT v_id AS articulo_id;
END$$

-- =============================================================================
-- sp_articulo_editar
-- Edita datos del artículo (no cambia tipo ni código). Si es REACTIVO,
-- inserta o actualiza su ficha.
-- =============================================================================
CREATE PROCEDURE sp_articulo_editar (
    IN p_usuario_id     INT UNSIGNED,
    IN p_articulo_id    INT UNSIGNED,
    IN p_nombre         VARCHAR(150),
    IN p_categoria_id   INT UNSIGNED,
    IN p_unidad_id      INT UNSIGNED,
    IN p_stock_minimo   DECIMAL(14,3),
    IN p_cas            VARCHAR(20),
    IN p_formula        VARCHAR(60),
    IN p_clasificacion_peligro VARCHAR(120),
    IN p_estado_fisico  VARCHAR(10),
    IN p_concentracion  VARCHAR(40),
    IN p_condiciones_almacenamiento VARCHAR(255)
)
BEGIN
    DECLARE v_tipo VARCHAR(10);
    DECLARE v_nombre_ant VARCHAR(150);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT tipo, nombre INTO v_tipo, v_nombre_ant FROM articulos WHERE id = p_articulo_id;
    IF v_tipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artículo no existe.';
    END IF;

    START TRANSACTION;

    UPDATE articulos
       SET nombre = p_nombre, categoria_id = p_categoria_id,
           unidad_id = p_unidad_id, stock_minimo = COALESCE(p_stock_minimo, 0)
     WHERE id = p_articulo_id;

    IF v_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento)
        VALUES
            (p_articulo_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento)
        ON DUPLICATE KEY UPDATE
            cas = VALUES(cas), formula = VALUES(formula),
            clasificacion_peligro = VALUES(clasificacion_peligro),
            estado_fisico = VALUES(estado_fisico),
            concentracion = VALUES(concentracion),
            condiciones_almacenamiento = VALUES(condiciones_almacenamiento);
    END IF;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'articulos', p_articulo_id, 'EDITAR',
            JSON_OBJECT('nombre', v_nombre_ant),
            JSON_OBJECT('nombre', p_nombre, 'stock_minimo', p_stock_minimo));

    COMMIT;
END$$

-- =============================================================================
-- sp_articulo_estado
-- Activa o desactiva un artículo (borrado lógico).
-- =============================================================================
CREATE PROCEDURE sp_articulo_estado (
    IN p_usuario_id  INT UNSIGNED,
    IN p_articulo_id INT UNSIGNED,
    IN p_activo      TINYINT
)
BEGIN
    DECLARE v_actual TINYINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT activo INTO v_actual FROM articulos WHERE id = p_articulo_id;
    IF v_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artículo no existe.';
    END IF;

    START TRANSACTION;

    UPDATE articulos SET activo = p_activo WHERE id = p_articulo_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'articulos', p_articulo_id,
            IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'),
            JSON_OBJECT('activo', v_actual), JSON_OBJECT('activo', p_activo));

    COMMIT;
END$$

DELIMITER ;

-- =============================================================================
-- Fin de SP de artículos.
-- =============================================================================
