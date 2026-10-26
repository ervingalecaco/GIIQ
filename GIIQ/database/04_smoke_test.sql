-- =============================================================================
-- GIIQ — Smoke test del flujo completo
-- Archivo: 04_smoke_test.sql
-- Ejecutar sobre una BD recién cargada (01 -> 02 -> 03 -> 04).
-- Prueba: FEFO en preparación, reingreso de material en devolución, y la
-- máquina de estados crear -> aprobar -> preparar -> entregar -> devolver.
-- Deja datos de demostración en la BD.
-- =============================================================================
USE labquim;

-- ---------------------------------------------------------------------------
-- Usuarios de prueba (profesor, supervisor, bodega). Hash placeholder.
-- ---------------------------------------------------------------------------
INSERT INTO usuarios (nombres, apellidos, codigo, usuario, password_hash, rol_id)
SELECT 'PROFESOR', 'DEMO', 'PROF-001', 'profe', '$2a$11$PLACEHOLDER', id FROM roles WHERE nombre='Profesor';
SET @profesor := LAST_INSERT_ID();

INSERT INTO usuarios (nombres, apellidos, usuario, password_hash, rol_id)
SELECT 'SUPERVISOR', 'DEMO', 'super', '$2a$11$PLACEHOLDER', id FROM roles WHERE nombre='Supervisor';
SET @supervisor := LAST_INSERT_ID();

INSERT INTO usuarios (nombres, apellidos, usuario, password_hash, rol_id)
SELECT 'BODEGA', 'DEMO', 'bode', '$2a$11$PLACEHOLDER', id FROM roles WHERE nombre='Bodega';
SET @bodega := LAST_INSERT_ID();

-- ---------------------------------------------------------------------------
-- Catálogos ya sembrados: capturamos ids que necesitamos.
-- ---------------------------------------------------------------------------
SET @ug     := (SELECT id FROM unidades_medida WHERE abreviatura='g');
SET @uu     := (SELECT id FROM unidades_medida WHERE abreviatura='ud');
SET @cat_ac := (SELECT id FROM categorias WHERE nombre='Ácido');
SET @cat_mv := (SELECT id FROM categorias WHERE nombre='Material volumétrico');

-- ---------------------------------------------------------------------------
-- Artículos: 1 reactivo + 1 material.
-- ---------------------------------------------------------------------------
INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
VALUES ('REACTIVO', 'RX-001', 'Ácido clorhídrico', @cat_ac, @ug, 20);
SET @rx := LAST_INSERT_ID();
INSERT INTO reactivo_ficha (articulo_id, cas, formula, clasificacion_peligro, estado_fisico, concentracion,
                            nfpa_salud, nfpa_inflamabilidad, nfpa_reactividad, nfpa_especial)
VALUES (@rx, '7647-01-0', 'HCl', 'Corrosivo', 'LIQUIDO', '37%', 3, 0, 1, 'COR');

INSERT INTO articulos (tipo, codigo, nombre, categoria_id, unidad_id, stock_minimo)
VALUES ('CRISTALERIA', 'MT-001', 'Bureta 50 mL', @cat_mv, @uu, 2);
SET @mt := LAST_INSERT_ID();

-- ---------------------------------------------------------------------------
-- Laboratorio destino.
-- ---------------------------------------------------------------------------
INSERT INTO laboratorios (nombre) VALUES ('Práctica de Química General');
SET @lab := LAST_INSERT_ID();

-- Clase que imparte el profesor y su práctica (en ese laboratorio).
INSERT INTO clases (anio, nombre) VALUES (1, 'Química General');
SET @clase := LAST_INSERT_ID();
INSERT INTO clase_profesor (clase_id, profesor_id) VALUES (@clase, @profesor);
INSERT INTO practicas (clase_id, nombre, laboratorio_id) VALUES (@clase, 'Práctica 1: Titulación', @lab);
SET @practica := LAST_INSERT_ID();

-- ---------------------------------------------------------------------------
-- Entradas de stock:
--   Reactivo: 2 lotes con vencimiento distinto (para probar FEFO).
--   Material: 1 lote sin vencimiento.
-- ---------------------------------------------------------------------------
CALL sp_entrada_registrar(@bodega, @rx, 'RX-L-A', '2026-01-01', 50, NULL, NULL, 'Lote que vence antes');
SET @loteA := (SELECT id FROM lotes WHERE codigo_lote='RX-L-A');
CALL sp_entrada_registrar(@bodega, @rx, 'RX-L-B', '2027-01-01', 80, NULL, NULL, 'Lote que vence después');
SET @loteB := (SELECT id FROM lotes WHERE codigo_lote='RX-L-B');
CALL sp_entrada_registrar(@bodega, @mt, 'MT-L-1', NULL, 10, NULL, NULL, 'Buretas');
SET @loteM := (SELECT id FROM lotes WHERE codigo_lote='MT-L-1');

SELECT '=== 0) Stock inicial (A=50, B=80, Material=10) ===' AS etapa;
SELECT codigo_lote, fecha_vencimiento, cantidad_actual FROM lotes ORDER BY id;

-- ---------------------------------------------------------------------------
-- 1) Profesor crea DOS solicitudes (una por tipo; no se mezclan):
--    A) Reactivos: 70 g (cruza los lotes A+B por FEFO).
--    B) Cristalería: 4 buretas (préstamo con devolución).
-- ---------------------------------------------------------------------------
SET @jsonR := CAST(CONCAT('[{"articulo_id":', @rx, ',"unidad_id":', @ug, ',"cantidad":70}]') AS JSON);
SET @jsonC := CAST(CONCAT('[{"articulo_id":', @mt, ',"unidad_id":', @uu, ',"cantidad":4}]') AS JSON);
CALL sp_solicitud_crear(@profesor, NULL, 'REACTIVO', @practica, '2026-10-01', 'Titulación: reactivos', @jsonR);
SET @solR := (SELECT MAX(id) FROM solicitudes);
CALL sp_solicitud_crear(@profesor, NULL, 'CRISTALERIA', @practica, '2026-10-01', 'Titulación: cristalería', @jsonC);
SET @solC := (SELECT MAX(id) FROM solicitudes);

SELECT '=== 1) Creadas (esperado: REACTIVO y CRISTALERIA, ambas PENDIENTE) ===' AS etapa;
SELECT id, tipo, estado FROM solicitudes WHERE id IN (@solR, @solC);

-- ---------------------------------------------------------------------------
-- 2) Supervisor aprueba ambas.
-- ---------------------------------------------------------------------------
CALL sp_solicitud_aprobar(@solR, @supervisor);
CALL sp_solicitud_aprobar(@solC, @supervisor);
SELECT '=== 2) Aprobadas (esperado: APROBADA) ===' AS etapa;
SELECT id, tipo, estado, supervisor_id FROM solicitudes WHERE id IN (@solR, @solC);

-- ---------------------------------------------------------------------------
-- 3) Bodega prepara -> FEFO: consume 50 de A (vence antes) + 20 de B.
--    Esperado: A=0, B=60, Material=6.
-- ---------------------------------------------------------------------------
CALL sp_solicitud_preparar(@solR, @bodega);
CALL sp_solicitud_preparar(@solC, @bodega);
SELECT '=== 3) Preparadas — FEFO (esperado A=0, B=60, Material=6) ===' AS etapa;
SELECT codigo_lote, cantidad_actual FROM lotes ORDER BY id;
SELECT '--- Detalle de las SALIDAS (lote -> cantidad) ---' AS detalle_salida;
SELECT m.solicitud_id, l.codigo_lote, md.cantidad
FROM movimientos m
JOIN movimiento_detalle md ON md.movimiento_id=m.id
JOIN lotes l ON l.id=md.lote_id
WHERE m.solicitud_id IN (@solR, @solC) AND m.tipo='SALIDA'
ORDER BY md.id;

-- ---------------------------------------------------------------------------
-- 4) Bodega entrega.
--    Reactivos: se cierra al entregar (CERRADA). Cristalería: queda ENTREGADA.
-- ---------------------------------------------------------------------------
CALL sp_solicitud_entregar(@solR, @bodega);
CALL sp_solicitud_entregar(@solC, @bodega);
SELECT '=== 4) Entregadas (esperado: reactivos CERRADA, cristalería ENTREGADA) ===' AS etapa;
SELECT id, tipo, estado, fecha_entrega FROM solicitudes WHERE id IN (@solR, @solC);

-- ---------------------------------------------------------------------------
-- 5) Bodega registra la devolución de la cristalería -> reingresa al stock.
--    Esperado: Material vuelve a 10; reactivo sigue A=0, B=60. Estado CERRADA.
-- ---------------------------------------------------------------------------
CALL sp_solicitud_devolver(@solC, @bodega, NULL);   -- NULL: se devolvió todo, sin piezas quebradas
SELECT '=== 5) Devuelta (esperado Material=10, A=0, B=60; estado CERRADA) ===' AS etapa;
SELECT codigo_lote, cantidad_actual FROM lotes ORDER BY id;
SELECT id, tipo, estado, fecha_devolucion FROM solicitudes WHERE id IN (@solR, @solC);
SELECT '--- cantidad_devuelta por línea (cristalería esperado=4) ---' AS devoluciones;
SELECT a.tipo, a.codigo, sd.cantidad_preparada, sd.cantidad_devuelta
FROM solicitud_detalle sd JOIN articulos a ON a.id=sd.articulo_id
WHERE sd.solicitud_id IN (@solR, @solC);

-- ---------------------------------------------------------------------------
-- 6) Auditoría acumulada del flujo.
-- ---------------------------------------------------------------------------
SELECT '=== 6) Auditoría de las solicitudes ===' AS etapa;
SELECT entidad_id AS solicitud, accion, valores_antes, valores_despues, fecha
FROM auditoria WHERE entidad='solicitudes' AND entidad_id IN (@solR, @solC) ORDER BY id;