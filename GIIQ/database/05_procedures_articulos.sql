-- =============================================================================
-- GIIQ — Stored Procedures de Artículos (CRUD)
-- Archivo: 05_procedures_articulos.sql
-- Ejecutar DESPUÉS de 01_schema.sql
-- =============================================================================
USE labquim;

DROP PROCEDURE IF EXISTS sp_nfpa_validar;
DROP PROCEDURE IF EXISTS sp_articulo_crear;
DROP PROCEDURE IF EXISTS sp_articulo_editar;
DROP PROCEDURE IF EXISTS sp_articulo_estado;
DROP PROCEDURE IF EXISTS sp_cristaleria_importar;
DROP PROCEDURE IF EXISTS sp_articulo_imagen_guardar;
DROP PROCEDURE IF EXISTS sp_articulo_imagen_quitar;

DELIMITER $$

-- =============================================================================
-- sp_articulo_crear
-- Crea un artículo (REACTIVO o CRISTALERIA). Si es REACTIVO, además su ficha 1:1.
-- Los campos p_cas..p_condiciones solo aplican a REACTIVO (se ignoran en CRISTALERIA).
-- =============================================================================
-- =============================================================================
-- sp_nfpa_validar  (auxiliar)
-- Rombo de seguridad NFPA 704 de un reactivo: salud (azul), inflamabilidad
-- (rojo) y reactividad (amarillo) son obligatorios, de 0 a 4. El riesgo
-- específico (blanco) es opcional: uno o varios códigos separados por coma.
-- =============================================================================
CREATE PROCEDURE sp_nfpa_validar (
    IN p_salud TINYINT, IN p_inflamabilidad TINYINT, IN p_reactividad TINYINT,
    IN p_especial VARCHAR(60)
)
BEGIN
    IF p_salud IS NULL OR p_inflamabilidad IS NULL OR p_reactividad IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
            'El rombo de seguridad es obligatorio: indica salud, inflamabilidad y reactividad (0 a 4).';
    END IF;
    IF p_salud NOT BETWEEN 0 AND 4 OR p_inflamabilidad NOT BETWEEN 0 AND 4 OR p_reactividad NOT BETWEEN 0 AND 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los niveles del rombo de seguridad van de 0 a 4.';
    END IF;
    IF COALESCE(p_especial, '') <> ''
       AND NOT REGEXP_LIKE(p_especial, '^(ACID|ALC|BIO|COR|CRYO|OX|R|W|XN)(,(ACID|ALC|BIO|COR|CRYO|OX|R|W|XN))*$', 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Riesgo específico no válido (usa R, COR, BIO, CRYO, XN, ALC, W, OX o ACID).';
    END IF;
END$$

CREATE PROCEDURE sp_articulo_crear (
    IN p_usuario_id     INT UNSIGNED,
    IN p_tipo           VARCHAR(12),
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
    IN p_condiciones_almacenamiento VARCHAR(255),
    IN p_nfpa_salud          TINYINT,
    IN p_nfpa_inflamabilidad TINYINT,
    IN p_nfpa_reactividad    TINYINT,
    IN p_nfpa_especial       VARCHAR(60)
)
BEGIN
    DECLARE v_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_tipo NOT IN ('REACTIVO', 'CRISTALERIA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo debe ser REACTIVO o CRISTALERIA.';
    END IF;
    IF EXISTS (SELECT 1 FROM articulos WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un artículo con ese código.';
    END IF;
    IF p_tipo = 'REACTIVO' THEN
        CALL sp_nfpa_validar(p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, p_nfpa_especial);
    END IF;

    START TRANSACTION;

    INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
    VALUES (p_tipo, p_codigo, p_nombre, p_categoria_id, p_unidad_id, COALESCE(p_stock_minimo, 0));
    SET v_id = LAST_INSERT_ID();

    IF p_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento,
             nfpa_salud, nfpa_inflamabilidad, nfpa_reactividad, nfpa_especial)
        VALUES
            (v_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento,
             p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, NULLIF(p_nfpa_especial, ''));
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
    IN p_condiciones_almacenamiento VARCHAR(255),
    IN p_nfpa_salud          TINYINT,
    IN p_nfpa_inflamabilidad TINYINT,
    IN p_nfpa_reactividad    TINYINT,
    IN p_nfpa_especial       VARCHAR(60)
)
BEGIN
    DECLARE v_tipo VARCHAR(12);
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
    IF v_tipo = 'REACTIVO' THEN
        CALL sp_nfpa_validar(p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, p_nfpa_especial);
    END IF;

    START TRANSACTION;

    UPDATE articulos
       SET nombre = p_nombre, categoria_id = p_categoria_id,
           unidad_id = p_unidad_id, stock_minimo = COALESCE(p_stock_minimo, 0)
     WHERE id = p_articulo_id;

    IF v_tipo = 'REACTIVO' THEN
        INSERT INTO reactivo_ficha
            (articulo_id, cas, formula, clasificacion_peligro, estado_fisico,
             concentracion, condiciones_almacenamiento,
             nfpa_salud, nfpa_inflamabilidad, nfpa_reactividad, nfpa_especial)
        VALUES
            (p_articulo_id, p_cas, p_formula, p_clasificacion_peligro,
             NULLIF(p_estado_fisico, ''), p_concentracion, p_condiciones_almacenamiento,
             p_nfpa_salud, p_nfpa_inflamabilidad, p_nfpa_reactividad, NULLIF(p_nfpa_especial, ''))
        ON DUPLICATE KEY UPDATE
            cas = VALUES(cas), formula = VALUES(formula),
            clasificacion_peligro = VALUES(clasificacion_peligro),
            estado_fisico = VALUES(estado_fisico),
            concentracion = VALUES(concentracion),
            condiciones_almacenamiento = VALUES(condiciones_almacenamiento),
            nfpa_salud = VALUES(nfpa_salud),
            nfpa_inflamabilidad = VALUES(nfpa_inflamabilidad),
            nfpa_reactividad = VALUES(nfpa_reactividad),
            nfpa_especial = VALUES(nfpa_especial);
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

-- =============================================================================
-- sp_cristaleria_importar
-- Carga masiva de cristalería (importación desde Excel), todo o nada.
-- p_filas es un arreglo JSON:
--   [{"codigo":"CR-001","nombre":"Beaker 250 mL","categoria":"Cristalería general",
--     "ubicacion":"Bodega de cristalería","unidad":"ud","cantidad":34}, ...]
-- Por cada fila crea el artículo CRISTALERIA y, si cantidad > 0, su lote inicial.
-- Todas las existencias entran en UN movimiento ENTRADA (un solo asiento en el kardex).
-- Las categorías y ubicaciones que no existan se crean. Los códigos que ya
-- existen se omiten (así volver a importar el mismo Excel no duplica nada).
-- =============================================================================
CREATE PROCEDURE sp_cristaleria_importar (
    IN p_usuario_id INT UNSIGNED,
    IN p_filas      JSON
)
BEGIN
    DECLARE v_n, v_i       INT DEFAULT 0;
    DECLARE v_creados      INT DEFAULT 0;
    DECLARE v_omitidos     INT DEFAULT 0;
    DECLARE v_codigo       VARCHAR(40);
    DECLARE v_nombre       VARCHAR(150);
    DECLARE v_categoria    VARCHAR(80);
    DECLARE v_ubicacion    VARCHAR(80);
    DECLARE v_unidad       VARCHAR(10);
    DECLARE v_cantidad     DECIMAL(14,3);
    DECLARE v_categoria_id, v_ubicacion_id, v_unidad_id, v_articulo_id, v_lote_id INT UNSIGNED;
    DECLARE v_mov_id       INT UNSIGNED DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_filas IS NULL OR JSON_TYPE(p_filas) <> 'ARRAY' OR JSON_LENGTH(p_filas) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay filas para importar.';
    END IF;
    SET v_n = JSON_LENGTH(p_filas);

    START TRANSACTION;

    WHILE v_i < v_n DO
        SET v_codigo    = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].codigo'))));
        SET v_nombre    = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].nombre'))));
        SET v_categoria = NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].categoria')))), '');
        SET v_ubicacion = NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].ubicacion')))), '');
        SET v_unidad    = COALESCE(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].unidad')))), ''), 'ud');
        SET v_cantidad  = COALESCE(JSON_EXTRACT(p_filas, CONCAT('$[', v_i, '].cantidad')), 0);

        IF v_codigo IS NULL OR v_codigo = '' OR v_nombre IS NULL OR v_nombre = '' THEN
            SET @msg = CONCAT('Fila ', v_i + 1, ': el código y el nombre son obligatorios.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        END IF;
        IF v_cantidad < 0 THEN
            SET @msg = CONCAT('Fila ', v_i + 1, ' (', v_nombre, '): la cantidad no puede ser negativa.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        END IF;

        IF EXISTS (SELECT 1 FROM articulos WHERE codigo = v_codigo) THEN
            SET v_omitidos = v_omitidos + 1;
        ELSE
            -- Unidad (debe existir en el catálogo)
            SET v_unidad_id = NULL;
            SELECT id INTO v_unidad_id FROM unidades_medida WHERE abreviatura = v_unidad;
            IF v_unidad_id IS NULL THEN
                SET @msg = CONCAT('Fila ', v_i + 1, ': la unidad "', v_unidad, '" no existe en el catálogo.');
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
            END IF;

            -- Categoría (se crea si no existe)
            SET v_categoria = COALESCE(v_categoria, 'Cristalería general');
            SET v_categoria_id = NULL;
            SELECT id INTO v_categoria_id FROM categorias WHERE nombre = v_categoria;
            IF v_categoria_id IS NULL THEN
                INSERT INTO categorias (nombre) VALUES (v_categoria);
                SET v_categoria_id = LAST_INSERT_ID();
                INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
                VALUES (p_usuario_id, 'categorias', v_categoria_id, 'CREAR',
                        JSON_OBJECT('nombre', v_categoria, 'origen', 'importacion'));
            END IF;

            -- Ubicación (opcional; se crea si no existe)
            SET v_ubicacion_id = NULL;
            IF v_ubicacion IS NOT NULL THEN
                SELECT id INTO v_ubicacion_id FROM ubicaciones WHERE nombre = v_ubicacion;
                IF v_ubicacion_id IS NULL THEN
                    INSERT INTO ubicaciones (nombre) VALUES (v_ubicacion);
                    SET v_ubicacion_id = LAST_INSERT_ID();
                    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
                    VALUES (p_usuario_id, 'ubicaciones', v_ubicacion_id, 'CREAR',
                            JSON_OBJECT('nombre', v_ubicacion, 'origen', 'importacion'));
                END IF;
            END IF;

            INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
            VALUES ('CRISTALERIA', v_codigo, v_nombre, v_categoria_id, v_unidad_id, 0);
            SET v_articulo_id = LAST_INSERT_ID();

            INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
            VALUES (p_usuario_id, 'articulos', v_articulo_id, 'CREAR',
                    JSON_OBJECT('tipo', 'CRISTALERIA', 'codigo', v_codigo, 'nombre', v_nombre,
                                'origen', 'importacion'));

            IF v_cantidad > 0 THEN
                IF v_mov_id IS NULL THEN
                    INSERT INTO movimientos (tipo, usuario_id, motivo)
                    VALUES ('ENTRADA', p_usuario_id, 'Importación de cristalería desde Excel');
                    SET v_mov_id = LAST_INSERT_ID();
                END IF;

                INSERT INTO lotes (articulo_id, cantidad_actual, ubicacion_id, fecha_ingreso)
                VALUES (v_articulo_id, v_cantidad, v_ubicacion_id, CURRENT_DATE);
                SET v_lote_id = LAST_INSERT_ID();

                INSERT INTO movimiento_detalle (movimiento_id, lote_id, cantidad)
                VALUES (v_mov_id, v_lote_id, v_cantidad);

                INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
                VALUES (p_usuario_id, 'lotes', v_lote_id, 'ENTRADA',
                        JSON_OBJECT('articulo_id', v_articulo_id, 'cantidad', v_cantidad,
                                    'lote', v_lote_id, 'origen', 'importacion'));
            END IF;

            SET v_creados = v_creados + 1;
        END IF;

        SET v_i = v_i + 1;
    END WHILE;

    COMMIT;

    SELECT v_creados AS creados, v_omitidos AS omitidos, v_mov_id AS movimiento_id;
END$$

-- =============================================================================
-- sp_articulo_imagen_guardar
-- Pone o reemplaza la foto de referencia de un artículo de cristalería.
-- La auditoría guarda el formato y el tamaño, no la imagen.
-- =============================================================================
CREATE PROCEDURE sp_articulo_imagen_guardar (
    IN p_usuario_id  INT UNSIGNED,
    IN p_articulo_id INT UNSIGNED,
    IN p_contenido   MEDIUMBLOB,
    IN p_tipo_mime   VARCHAR(30)
)
BEGIN
    DECLARE v_tipo VARCHAR(20);
    DECLARE v_antes JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT tipo INTO v_tipo FROM articulos WHERE id = p_articulo_id;
    IF v_tipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artículo no existe.';
    END IF;
    IF v_tipo <> 'CRISTALERIA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo la cristalería lleva imagen de referencia.';
    END IF;
    IF p_tipo_mime NOT IN ('image/jpeg', 'image/png', 'image/webp') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La imagen debe ser JPG, PNG o WebP.';
    END IF;

    SELECT JSON_OBJECT('tipo_mime', tipo_mime, 'tamano_bytes', tamano_bytes) INTO v_antes
    FROM articulo_imagen WHERE articulo_id = p_articulo_id;

    START TRANSACTION;

    INSERT INTO articulo_imagen (articulo_id, contenido, tipo_mime, tamano_bytes)
    VALUES (p_articulo_id, p_contenido, p_tipo_mime, LENGTH(p_contenido))
    ON DUPLICATE KEY UPDATE contenido = VALUES(contenido), tipo_mime = VALUES(tipo_mime),
                            tamano_bytes = VALUES(tamano_bytes), actualizado_en = CURRENT_TIMESTAMP;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_usuario_id, 'articulo_imagen', p_articulo_id, IF(v_antes IS NULL, 'CREAR', 'EDITAR'),
            v_antes, JSON_OBJECT('tipo_mime', p_tipo_mime, 'tamano_bytes', LENGTH(p_contenido)));

    COMMIT;
END$$

-- =============================================================================
-- sp_articulo_imagen_quitar
-- Quita la foto de referencia de un artículo (si no tiene, no hace nada).
-- =============================================================================
CREATE PROCEDURE sp_articulo_imagen_quitar (
    IN p_usuario_id  INT UNSIGNED,
    IN p_articulo_id INT UNSIGNED
)
BEGIN
    DECLARE v_antes JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT JSON_OBJECT('tipo_mime', tipo_mime, 'tamano_bytes', tamano_bytes) INTO v_antes
    FROM articulo_imagen WHERE articulo_id = p_articulo_id;

    IF v_antes IS NOT NULL THEN
        START TRANSACTION;
        DELETE FROM articulo_imagen WHERE articulo_id = p_articulo_id;
        INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
        VALUES (p_usuario_id, 'articulo_imagen', p_articulo_id, 'ELIMINAR', v_antes, NULL);
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- =============================================================================
-- Fin de SP de artículos.
-- =============================================================================
