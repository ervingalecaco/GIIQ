-- =============================================================================
-- LabQuim — Stored Procedures de Catálogos (CRUD)
-- Archivo: 07_procedures_catalogos.sql
-- Ejecutar DESPUÉS de 01_schema.sql
-- Patrón: sp_<tabla>_guardar (id=0 inserta, si no actualiza) + sp_<tabla>_estado.
-- =============================================================================
USE labquim;

DROP PROCEDURE IF EXISTS sp_categoria_guardar;
DROP PROCEDURE IF EXISTS sp_categoria_estado;
DROP PROCEDURE IF EXISTS sp_unidad_guardar;
DROP PROCEDURE IF EXISTS sp_unidad_estado;
DROP PROCEDURE IF EXISTS sp_proveedor_guardar;
DROP PROCEDURE IF EXISTS sp_proveedor_estado;
DROP PROCEDURE IF EXISTS sp_ubicacion_guardar;
DROP PROCEDURE IF EXISTS sp_ubicacion_estado;
DROP PROCEDURE IF EXISTS sp_laboratorio_guardar;
DROP PROCEDURE IF EXISTS sp_laboratorio_estado;

DELIMITER $$

-- ============================ CATEGORIAS ============================
CREATE PROCEDURE sp_categoria_guardar (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(80), IN p_descripcion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM categorias WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una categoría con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO categorias (nombre, descripcion) VALUES (p_nombre, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE categorias SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'categorias', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END$$
CREATE PROCEDURE sp_categoria_estado (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE categorias SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'categorias', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END$$

-- ============================ UNIDADES ============================
CREATE PROCEDURE sp_unidad_guardar (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(40), IN p_abreviatura VARCHAR(10))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM unidades_medida WHERE abreviatura = p_abreviatura AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una unidad con esa abreviatura.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO unidades_medida (nombre, abreviatura) VALUES (p_nombre, p_abreviatura);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE unidades_medida SET nombre = p_nombre, abreviatura = p_abreviatura WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'unidades_medida', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('abreviatura', p_abreviatura));
    COMMIT;
    SELECT v_id AS id;
END$$
CREATE PROCEDURE sp_unidad_estado (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE unidades_medida SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'unidades_medida', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END$$

-- ============================ PROVEEDORES ============================
CREATE PROCEDURE sp_proveedor_guardar (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(120), IN p_contacto VARCHAR(120), IN p_telefono VARCHAR(40),
    IN p_email VARCHAR(120), IN p_direccion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM proveedores WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un proveedor con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO proveedores (nombre, contacto, telefono, email, direccion)
        VALUES (p_nombre, p_contacto, p_telefono, p_email, p_direccion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE proveedores SET nombre = p_nombre, contacto = p_contacto, telefono = p_telefono,
               email = p_email, direccion = p_direccion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'proveedores', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END$$
CREATE PROCEDURE sp_proveedor_estado (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE proveedores SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'proveedores', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END$$

-- ============================ UBICACIONES ============================
CREATE PROCEDURE sp_ubicacion_guardar (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(80), IN p_descripcion VARCHAR(255), IN p_condiciones VARCHAR(120))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM ubicaciones WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una ubicación con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO ubicaciones (nombre, descripcion, condiciones) VALUES (p_nombre, p_descripcion, p_condiciones);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE ubicaciones SET nombre = p_nombre, descripcion = p_descripcion, condiciones = p_condiciones WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'ubicaciones', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END$$
CREATE PROCEDURE sp_ubicacion_estado (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE ubicaciones SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'ubicaciones', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END$$

-- ============================ LABORATORIOS ============================
CREATE PROCEDURE sp_laboratorio_guardar (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED,
    IN p_nombre VARCHAR(120), IN p_descripcion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM laboratorios WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un laboratorio con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO laboratorios (nombre, descripcion) VALUES (p_nombre, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE laboratorios SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'laboratorios', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'), JSON_OBJECT('nombre', p_nombre));
    COMMIT;
    SELECT v_id AS id;
END$$
CREATE PROCEDURE sp_laboratorio_estado (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE laboratorios SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'laboratorios', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END$$

DELIMITER ;

-- =============================================================================
-- Fin de SP de catálogos.
-- =============================================================================
