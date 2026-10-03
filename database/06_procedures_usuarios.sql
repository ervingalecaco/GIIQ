-- =============================================================================
-- LabQuim — Stored Procedures de Usuarios, Roles y Permisos
-- Archivo: 06_procedures_usuarios.sql
-- Ejecutar DESPUÉS de 01_schema.sql
-- Nota: el hash BCrypt se calcula en el backend (.NET) y se pasa ya listo.
-- =============================================================================
USE labquim;

DROP PROCEDURE IF EXISTS sp_usuario_crear;
DROP PROCEDURE IF EXISTS sp_usuario_editar;
DROP PROCEDURE IF EXISTS sp_usuario_estado;
DROP PROCEDURE IF EXISTS sp_usuario_password;
DROP PROCEDURE IF EXISTS sp_rol_permisos_set;

DELIMITER $$

-- =============================================================================
-- sp_usuario_crear
-- =============================================================================
CREATE PROCEDURE sp_usuario_crear (
    IN p_actor_id       INT UNSIGNED,
    IN p_nombre_completo VARCHAR(120),
    IN p_usuario        VARCHAR(50),
    IN p_password_hash  VARCHAR(100),
    IN p_email          VARCHAR(120),
    IN p_rol_id         INT UNSIGNED
)
BEGIN
    DECLARE v_id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un usuario con ese nombre de usuario.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM roles WHERE id = p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe.';
    END IF;

    START TRANSACTION;

    INSERT INTO usuarios (nombre_completo, usuario, password_hash, email, rol_id)
    VALUES (p_nombre_completo, p_usuario, p_password_hash, p_email, p_rol_id);
    SET v_id = LAST_INSERT_ID();

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'usuarios', v_id, 'CREAR',
            JSON_OBJECT('usuario', p_usuario, 'rol_id', p_rol_id));

    COMMIT;

    SELECT v_id AS usuario_id;
END$$

-- =============================================================================
-- sp_usuario_editar  (no cambia usuario ni contraseña)
-- =============================================================================
CREATE PROCEDURE sp_usuario_editar (
    IN p_actor_id        INT UNSIGNED,
    IN p_usuario_id      INT UNSIGNED,
    IN p_nombre_completo VARCHAR(120),
    IN p_email           VARCHAR(120),
    IN p_rol_id          INT UNSIGNED
)
BEGIN
    DECLARE v_rol_ant INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT rol_id INTO v_rol_ant FROM usuarios WHERE id = p_usuario_id;
    IF v_rol_ant IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM roles WHERE id = p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe.';
    END IF;

    START TRANSACTION;

    UPDATE usuarios
       SET nombre_completo = p_nombre_completo, email = p_email, rol_id = p_rol_id
     WHERE id = p_usuario_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id, 'EDITAR',
            JSON_OBJECT('rol_id', v_rol_ant),
            JSON_OBJECT('nombre', p_nombre_completo, 'rol_id', p_rol_id));

    COMMIT;
END$$

-- =============================================================================
-- sp_usuario_estado  (activar / desactivar). No permite auto-desactivarse.
-- =============================================================================
CREATE PROCEDURE sp_usuario_estado (
    IN p_actor_id   INT UNSIGNED,
    IN p_usuario_id INT UNSIGNED,
    IN p_activo     TINYINT
)
BEGIN
    DECLARE v_actual TINYINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_actor_id = p_usuario_id AND p_activo = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes desactivar tu propio usuario.';
    END IF;

    SELECT activo INTO v_actual FROM usuarios WHERE id = p_usuario_id;
    IF v_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;

    START TRANSACTION;

    UPDATE usuarios SET activo = p_activo WHERE id = p_usuario_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id,
            IF(p_activo = 1, 'ACTIVAR', 'DESACTIVAR'),
            JSON_OBJECT('activo', v_actual), JSON_OBJECT('activo', p_activo));

    COMMIT;
END$$

-- =============================================================================
-- sp_usuario_password  (restablece contraseña; recibe el hash ya calculado)
-- =============================================================================
CREATE PROCEDURE sp_usuario_password (
    IN p_actor_id      INT UNSIGNED,
    IN p_usuario_id    INT UNSIGNED,
    IN p_password_hash VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;

    START TRANSACTION;

    UPDATE usuarios SET password_hash = p_password_hash WHERE id = p_usuario_id;

    -- Nunca se guarda el hash en la auditoría.
    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id, 'CAMBIAR_PASSWORD',
            JSON_OBJECT('cambiado', TRUE));

    COMMIT;
END$$

-- =============================================================================
-- sp_rol_permisos_set
-- Reemplaza el conjunto de permisos de un rol a partir de un JSON de códigos:
--   '["solicitud.ver","solicitud.aprobar"]'
-- =============================================================================
CREATE PROCEDURE sp_rol_permisos_set (
    IN p_actor_id     INT UNSIGNED,
    IN p_rol_id       INT UNSIGNED,
    IN p_permisos_json JSON
)
BEGIN
    DECLARE v_nombre VARCHAR(50);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT nombre INTO v_nombre FROM roles WHERE id = p_rol_id;
    IF v_nombre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol no existe.';
    END IF;

    START TRANSACTION;

    DELETE FROM rol_permiso WHERE rol_id = p_rol_id;

    INSERT INTO rol_permiso (rol_id, permiso_id)
    SELECT p_rol_id, p.id
    FROM JSON_TABLE(p_permisos_json, '$[*]' COLUMNS (codigo VARCHAR(60) PATH '$')) jt
    JOIN permisos p ON p.codigo = jt.codigo COLLATE utf8mb4_unicode_ci;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'roles', p_rol_id, 'SET_PERMISOS',
            JSON_OBJECT('rol', v_nombre, 'permisos', p_permisos_json));

    COMMIT;
END$$

DELIMITER ;

-- =============================================================================
-- Fin de SP de usuarios/roles.
-- =============================================================================
