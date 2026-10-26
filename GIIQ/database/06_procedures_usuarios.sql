-- =============================================================================
-- GIIQ — Stored Procedures de Usuarios, Roles y Permisos
-- Archivo: 06_procedures_usuarios.sql
-- Ejecutar DESPUÉS de 01_schema.sql
-- Nota: el hash BCrypt se calcula en el backend (.NET) y se pasa ya listo.
-- =============================================================================
USE labquim;

DROP PROCEDURE IF EXISTS sp_usuario_validar;
DROP PROCEDURE IF EXISTS sp_usuario_crear;
DROP PROCEDURE IF EXISTS sp_usuario_editar;
DROP PROCEDURE IF EXISTS sp_usuario_estado;
DROP PROCEDURE IF EXISTS sp_usuario_password;
DROP PROCEDURE IF EXISTS sp_rol_permisos_set;

DELIMITER $$

-- =============================================================================
-- sp_usuario_validar  (auxiliar de crear/editar)
-- Normaliza y valida los datos personales. Devuelve en los OUT los valores ya
-- normalizados: nombres/apellidos en MAYÚSCULAS con espacios simples y el código
-- en mayúsculas (NULL si el rol no usa código).
--   * Nombres y apellidos: solo letras (con tildes y Ñ), espacio, apóstrofo y guion.
--     Así se rechazan emojis, números y símbolos.
--   * Código: obligatorio y único para Profesor y Estudiante; letras, números y guion.
-- =============================================================================
CREATE PROCEDURE sp_usuario_validar (
    IN  p_usuario_id INT UNSIGNED,          -- 0 al crear (para excluirse al editar)
    IN  p_nombres    VARCHAR(60),
    IN  p_apellidos  VARCHAR(60),
    IN  p_codigo     VARCHAR(20),
    IN  p_rol_id     INT UNSIGNED,
    OUT o_nombres    VARCHAR(60),
    OUT o_apellidos  VARCHAR(60),
    OUT o_codigo     VARCHAR(20)
)
BEGIN
    DECLARE v_rol VARCHAR(40);
    DECLARE c_nombre VARCHAR(80) DEFAULT '^[A-ZÁÉÍÓÚÜÑ]+([ ''-][A-ZÁÉÍÓÚÜÑ]+)*$';

    SELECT nombre INTO v_rol FROM roles WHERE id = p_rol_id;
    IF v_rol IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe.';
    END IF;

    SET o_nombres   = UPPER(REGEXP_REPLACE(TRIM(COALESCE(p_nombres, '')), ' +', ' '));
    SET o_apellidos = UPPER(REGEXP_REPLACE(TRIM(COALESCE(p_apellidos, '')), ' +', ' '));
    IF o_nombres = '' OR o_apellidos = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los nombres y los apellidos son obligatorios.';
    END IF;
    IF NOT REGEXP_LIKE(o_nombres, c_nombre, 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los nombres solo pueden tener letras, espacios, apóstrofo o guion.';
    END IF;
    IF NOT REGEXP_LIKE(o_apellidos, c_nombre, 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los apellidos solo pueden tener letras, espacios, apóstrofo o guion.';
    END IF;

    IF v_rol IN ('Profesor', 'Estudiante') THEN
        SET o_codigo = UPPER(TRIM(COALESCE(p_codigo, '')));
        IF o_codigo = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El código es obligatorio para profesores y estudiantes.';
        END IF;
        IF CHAR_LENGTH(o_codigo) NOT BETWEEN 3 AND 20
           OR NOT REGEXP_LIKE(o_codigo, '^[A-Z0-9]+(-[A-Z0-9]+)*$', 'c') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El código debe tener de 3 a 20 letras o números (puede llevar guion).';
        END IF;
        IF EXISTS (SELECT 1 FROM usuarios WHERE codigo = o_codigo AND id <> p_usuario_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese código ya está asignado a otro usuario.';
        END IF;
    ELSE
        SET o_codigo = NULL;
    END IF;
END$$

-- =============================================================================
-- sp_usuario_crear
-- =============================================================================
CREATE PROCEDURE sp_usuario_crear (
    IN p_actor_id       INT UNSIGNED,
    IN p_nombres        VARCHAR(60),
    IN p_apellidos      VARCHAR(60),
    IN p_codigo         VARCHAR(20),
    IN p_usuario        VARCHAR(50),
    IN p_password_hash  VARCHAR(100),
    IN p_email          VARCHAR(120),
    IN p_rol_id         INT UNSIGNED
)
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE v_nombres, v_apellidos VARCHAR(60);
    DECLARE v_codigo VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT REGEXP_LIKE(COALESCE(p_usuario, ''), '^[A-Za-z0-9._-]{3,50}$', 'c') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario debe tener de 3 a 50 letras, números, punto, guion o guion bajo.';
    END IF;
    IF EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un usuario con ese nombre de usuario.';
    END IF;
    CALL sp_usuario_validar(0, p_nombres, p_apellidos, p_codigo, p_rol_id, v_nombres, v_apellidos, v_codigo);

    START TRANSACTION;

    INSERT INTO usuarios (nombres, apellidos, codigo, usuario, password_hash, email, rol_id)
    VALUES (v_nombres, v_apellidos, v_codigo, p_usuario, p_password_hash, p_email, p_rol_id);
    SET v_id = LAST_INSERT_ID();

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_despues)
    VALUES (p_actor_id, 'usuarios', v_id, 'CREAR',
            JSON_OBJECT('usuario', p_usuario, 'codigo', v_codigo, 'rol_id', p_rol_id));

    COMMIT;

    SELECT v_id AS usuario_id;
END$$

-- =============================================================================
-- sp_usuario_editar  (no cambia usuario ni contraseña)
-- =============================================================================
CREATE PROCEDURE sp_usuario_editar (
    IN p_actor_id        INT UNSIGNED,
    IN p_usuario_id      INT UNSIGNED,
    IN p_nombres         VARCHAR(60),
    IN p_apellidos       VARCHAR(60),
    IN p_codigo          VARCHAR(20),
    IN p_email           VARCHAR(120),
    IN p_rol_id          INT UNSIGNED
)
BEGIN
    DECLARE v_rol_ant INT UNSIGNED;
    DECLARE v_nombres, v_apellidos VARCHAR(60);
    DECLARE v_codigo VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT rol_id INTO v_rol_ant FROM usuarios WHERE id = p_usuario_id;
    IF v_rol_ant IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    CALL sp_usuario_validar(p_usuario_id, p_nombres, p_apellidos, p_codigo, p_rol_id, v_nombres, v_apellidos, v_codigo);

    START TRANSACTION;

    UPDATE usuarios
       SET nombres = v_nombres, apellidos = v_apellidos, codigo = v_codigo,
           email = p_email, rol_id = p_rol_id
     WHERE id = p_usuario_id;

    INSERT INTO auditoria (usuario_id, entidad, entidad_id, accion, valores_antes, valores_despues)
    VALUES (p_actor_id, 'usuarios', p_usuario_id, 'EDITAR',
            JSON_OBJECT('rol_id', v_rol_ant),
            JSON_OBJECT('nombres', v_nombres, 'apellidos', v_apellidos, 'codigo', v_codigo, 'rol_id', p_rol_id));

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
