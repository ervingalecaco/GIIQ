-- =============================================================================
-- GIIQ — Stored Procedures de Catálogos (CRUD)
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
DROP PROCEDURE IF EXISTS sp_clase_guardar;
DROP PROCEDURE IF EXISTS sp_clase_estado;
DROP PROCEDURE IF EXISTS sp_practica_guardar;
DROP PROCEDURE IF EXISTS sp_practica_estado;

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

-- ============================ CLASES ============================
-- p_profesores_json: lista de ids de usuarios con rol Profesor, ej. '[2,7]'.
-- Reemplaza por completo los profesores asignados a la clase.
CREATE PROCEDURE sp_clase_guardar (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_anio TINYINT UNSIGNED,
    IN p_nombre VARCHAR(120), IN p_descripcion VARCHAR(255), IN p_profesores_json JSON)
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF p_anio IS NULL OR p_anio NOT BETWEEN 1 AND 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El año debe estar entre primero y quinto.';
    END IF;
    IF EXISTS (SELECT 1 FROM clases WHERE anio = p_anio AND nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una clase con ese nombre en ese año.';
    END IF;
    IF p_profesores_json IS NULL OR JSON_LENGTH(p_profesores_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Asigna al menos un profesor a la clase.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM JSON_TABLE(p_profesores_json, '$[*]' COLUMNS (pid INT UNSIGNED PATH '$')) jt
        WHERE NOT EXISTS (SELECT 1 FROM usuarios u JOIN roles r ON r.id = u.rol_id
                          WHERE u.id = jt.pid AND r.nombre = 'Profesor')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden asignar usuarios con rol Profesor.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO clases (anio, nombre, descripcion) VALUES (p_anio, p_nombre, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE clases SET anio = p_anio, nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    DELETE FROM clase_profesor WHERE clase_id = v_id;
    INSERT INTO clase_profesor (clase_id, profesor_id)
    SELECT DISTINCT v_id, jt.pid
    FROM JSON_TABLE(p_profesores_json, '$[*]' COLUMNS (pid INT UNSIGNED PATH '$')) jt;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'clases', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'),
            JSON_OBJECT('anio', p_anio, 'nombre', p_nombre, 'profesores', p_profesores_json));
    COMMIT;
    SELECT v_id AS id;
END$$
CREATE PROCEDURE sp_clase_estado (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE clases SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'clases', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END$$

-- ============================ PRÁCTICAS ============================
CREATE PROCEDURE sp_practica_guardar (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_clase_id INT UNSIGNED,
    IN p_nombre VARCHAR(150), IN p_laboratorio_id INT UNSIGNED, IN p_descripcion VARCHAR(255))
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF NOT EXISTS (SELECT 1 FROM clases WHERE id = p_clase_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige la clase de la práctica.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM laboratorios WHERE id = p_laboratorio_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elige el laboratorio de la práctica.';
    END IF;
    IF EXISTS (SELECT 1 FROM practicas WHERE clase_id = p_clase_id AND nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esa clase ya tiene una práctica con ese nombre.';
    END IF;
    START TRANSACTION;
    IF p_id = 0 THEN
        INSERT INTO practicas (clase_id, nombre, laboratorio_id, descripcion)
        VALUES (p_clase_id, p_nombre, p_laboratorio_id, p_descripcion);
        SET v_id = LAST_INSERT_ID();
    ELSE
        UPDATE practicas
           SET clase_id = p_clase_id, nombre = p_nombre, laboratorio_id = p_laboratorio_id, descripcion = p_descripcion
         WHERE id = p_id;
        SET v_id = p_id;
    END IF;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'practicas', v_id, IF(p_id = 0, 'CREAR', 'EDITAR'),
            JSON_OBJECT('nombre', p_nombre, 'clase_id', p_clase_id, 'laboratorio_id', p_laboratorio_id));
    COMMIT;
    SELECT v_id AS id;
END$$
CREATE PROCEDURE sp_practica_estado (
    IN p_actor_id INT UNSIGNED, IN p_id INT UNSIGNED, IN p_activo TINYINT)
BEGIN
    UPDATE practicas SET activo = p_activo WHERE id = p_id;
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'practicas', p_id, IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'), JSON_OBJECT('activo', p_activo));
END$$

DELIMITER ;

-- =============================================================================
-- Fin de SP de catálogos.
-- =============================================================================
