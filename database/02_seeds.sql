-- =============================================================================
-- LabQuim — Datos iniciales (seeds)
-- Archivo: 02_seeds.sql
-- Ejecutar DESPUÉS de 01_schema.sql
-- =============================================================================
USE labquim;

-- -----------------------------------------------------------------------------
-- Roles (5)
-- -----------------------------------------------------------------------------
INSERT INTO roles (nombre, descripcion) VALUES
  ('Administrador', 'Control total del sistema'),
  ('Supervisor',    'Aprueba o rechaza solicitudes; ve reportes e inventario'),
  ('Profesor',      'Crea solicitudes de préstamo de reactivos y materiales'),
  ('Bodega',        'Prepara, entrega y recibe devoluciones; gestiona lotes'),
  ('Estudiante',    'Solo visualización de existencias y reportes');

-- -----------------------------------------------------------------------------
-- Permisos
-- -----------------------------------------------------------------------------
INSERT INTO permisos (codigo, descripcion, modulo) VALUES
  -- Seguridad
  ('usuarios.ver',        'Ver usuarios',                 'seguridad'),
  ('usuarios.crear',      'Crear usuarios',               'seguridad'),
  ('usuarios.editar',     'Editar usuarios',              'seguridad'),
  ('usuarios.eliminar',   'Desactivar/eliminar usuarios', 'seguridad'),
  ('roles.gestionar',     'Gestionar roles y permisos',   'seguridad'),
  -- Catálogos
  ('catalogos.ver',       'Ver catálogos',                'catalogos'),
  ('catalogos.gestionar', 'Gestionar catálogos',          'catalogos'),
  -- Artículos
  ('articulos.ver',       'Ver artículos',                'articulos'),
  ('articulos.crear',     'Crear artículos',              'articulos'),
  ('articulos.editar',    'Editar artículos',             'articulos'),
  ('articulos.eliminar',  'Desactivar/eliminar artículos','articulos'),
  -- Inventario
  ('inventario.ver',      'Ver existencias/inventario',   'inventario'),
  ('lotes.ver',           'Ver lotes',                    'inventario'),
  ('entrada.registrar',   'Registrar entradas de stock',  'inventario'),
  ('ajuste.registrar',    'Registrar ajustes de stock',   'inventario'),
  -- Solicitudes (flujo)
  ('solicitud.crear',     'Crear solicitudes',            'solicitudes'),
  ('solicitud.ver',       'Ver solicitudes',              'solicitudes'),
  ('solicitud.aprobar',   'Aprobar/rechazar solicitudes', 'solicitudes'),
  ('solicitud.preparar',  'Preparar solicitudes',         'solicitudes'),
  ('solicitud.entregar',  'Entregar solicitudes',         'solicitudes'),
  ('solicitud.devolver',  'Registrar devoluciones',       'solicitudes'),
  -- Reportes
  ('reporte.ver',         'Ver/exportar reportes',        'reportes'),
  ('dashboard.ver',       'Ver dashboard',                'reportes'),
  -- Sistema
  ('respaldo.gestionar',  'Respaldar/restaurar la BD',    'sistema'),
  ('auditoria.ver',       'Ver bitácora de auditoría',    'sistema');

-- -----------------------------------------------------------------------------
-- Mapeo rol → permisos
-- -----------------------------------------------------------------------------

-- Administrador: TODOS los permisos
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r CROSS JOIN permisos p
WHERE r.nombre = 'Administrador';

-- Supervisor
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r JOIN permisos p
WHERE r.nombre = 'Supervisor'
  AND p.codigo IN (
    'solicitud.ver','solicitud.aprobar',
    'inventario.ver','lotes.ver','articulos.ver','catalogos.ver',
    'reporte.ver','dashboard.ver','auditoria.ver');

-- Profesor
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r JOIN permisos p
WHERE r.nombre = 'Profesor'
  AND p.codigo IN (
    'solicitud.crear','solicitud.ver',
    'inventario.ver','articulos.ver','catalogos.ver','dashboard.ver');

-- Bodega
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r JOIN permisos p
WHERE r.nombre = 'Bodega'
  AND p.codigo IN (
    'solicitud.ver','solicitud.preparar','solicitud.entregar','solicitud.devolver',
    'inventario.ver','lotes.ver','entrada.registrar','ajuste.registrar',
    'articulos.ver','articulos.crear','articulos.editar',
    'catalogos.ver','catalogos.gestionar',
    'reporte.ver','dashboard.ver');

-- Estudiante (solo lectura)
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r JOIN permisos p
WHERE r.nombre = 'Estudiante'
  AND p.codigo IN (
    'inventario.ver','articulos.ver','catalogos.ver','dashboard.ver');

-- -----------------------------------------------------------------------------
-- Catálogos base
-- -----------------------------------------------------------------------------
INSERT INTO unidades_medida (nombre, abreviatura) VALUES
  ('Gramo','g'), ('Miligramo','mg'), ('Kilogramo','kg'),
  ('Mililitro','mL'), ('Litro','L'), ('Mol','mol'),
  ('Unidad','ud'), ('Caja','caja');

INSERT INTO categorias (nombre, descripcion) VALUES
  ('Ácido',              'Reactivos ácidos'),
  ('Base',               'Reactivos básicos/álcalis'),
  ('Solvente',           'Disolventes orgánicos e inorgánicos'),
  ('Sal',                'Sales inorgánicas'),
  ('Indicador',          'Indicadores de pH y colorimétricos'),
  ('Material volumétrico','Cristalería de medición (buretas, pipetas, matraces)'),
  ('Equipo',             'Equipo e instrumental de laboratorio');

INSERT INTO ubicaciones (nombre, descripcion, condiciones) VALUES
  ('Gabinete A', 'Gabinete general de reactivos', 'ventilado'),
  ('Refrigerador 1', 'Reactivos termosensibles', 'refrigerado 2-8°C'),
  ('Gabinete Inflamables', 'Solventes inflamables', 'antichispa, ventilado'),
  ('Estante Cristalería', 'Material volumétrico y equipo', 'ambiente');

-- -----------------------------------------------------------------------------
-- Usuario administrador inicial
-- IMPORTANTE: reemplazar el password_hash por un BCrypt real generado por el
-- backend (.NET: BCrypt.Net.BCrypt.HashPassword("TuClave")). El valor de abajo
-- es un PLACEHOLDER inválido para forzar el cambio antes de producción.
-- -----------------------------------------------------------------------------
INSERT INTO usuarios (nombre_completo, usuario, password_hash, email, rol_id)
SELECT 'Administrador del Sistema', 'admin',
       '$2a$11$REEMPLAZAR_ESTE_HASH_POR_UNO_BCRYPT_REAL_GENERADO_EN_BACKEND',
       'admin@labquim.local', r.id
FROM roles r WHERE r.nombre = 'Administrador';

-- =============================================================================
-- Fin de seeds.
-- =============================================================================
