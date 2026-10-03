# Análisis y Diseño — Sistema de Control y Gestión de Inventario de Materiales y Reactivos de Laboratorio de Química

**Proyecto:** Examen de grado
**Stack:** React (frontend) + .NET (API) + MySQL (base de datos relacional)

---

## 1. Introducción

El sistema tiene como propósito **controlar y gestionar el inventario de
reactivos químicos y materiales de un laboratorio de química**, llevando
registro exacto de existencias, lotes, fechas de vencimiento, entradas y
salidas (despachos a prácticas o docentes), y generando reportes y alertas
que apoyen la toma de decisiones y la seguridad del laboratorio.

A diferencia de un inventario común, los reactivos exigen controlar
**vencimiento por lote, clasificación de peligro, condiciones de
almacenamiento y trazabilidad de consumo**, por lo que el modelo se diseña
en torno a esos requisitos.

---

## 2. Objetivos

### Objetivo general
Desarrollar una aplicación web para el control y gestión del inventario de
materiales y reactivos de un laboratorio de química, que permita administrar
existencias, controlar vencimientos, registrar movimientos, gestionar usuarios
por roles y generar reportes.

### Objetivos específicos
- Implementar autenticación con **cinco roles** diferenciados (Administrador,
  Supervisor, Profesor, Bodega, Estudiante) y cifrado de contraseñas.
- Gestionar un **flujo de solicitud → aprobación → preparación (préstamo)** de
  reactivos y materiales, con devolución de la cristalería/material prestado.
- Administrar el catálogo de reactivos y materiales con operaciones CRUD y
  validaciones.
- Controlar existencias **por lote**, con alertas de vencimiento y de stock
  mínimo.
- Registrar entradas, salidas y ajustes de inventario con trazabilidad.
- Generar comprobantes de despacho imprimibles y reportes exportables.
- Ofrecer un dashboard con indicadores y gráficos del estado del inventario.
- Permitir respaldo y restauración de la base de datos desde la interfaz.

---

## 3. Alcance

**Incluye:** gestión de reactivos y materiales, control de lotes y
vencimientos, movimientos de inventario (entradas/salidas/ajustes),
**solicitudes de préstamo con aprobación** (Profesor pide → Supervisor aprueba →
Bodega prepara y entrega) y **devolución** de cristalería/material, despachos
a laboratorios/prácticas con comprobante imprimible, gestión de usuarios/roles/
permisos, reportes, dashboard, alertas, y respaldo/restauración.

**No incluye (por ahora):** compras/órdenes de compra a proveedores,
integración con equipos de laboratorio, ni gestión de residuos peligrosos
(se mencionan como trabajo futuro).

---

## 4. Actores y roles

El sistema gira en torno a un **flujo de solicitud → aprobación → preparación
(préstamo)**. Se definen **5 roles**:

| Rol | Descripción | Privilegios |
|---|---|---|
| **Administrador** | Control total del sistema | Todo: usuarios, roles, permisos, catálogos, movimientos, reportes, respaldos |
| **Supervisor** | Aprueba lo que se va a usar | **Aprueba/rechaza** solicitudes; ve reportes y todo el inventario. No administra usuarios ni respaldos |
| **Profesor** | Docente que pide material para una práctica | **Crea solicitudes** de reactivos/cristalería/materiales; ve el estado de sus solicitudes y el inventario |
| **Bodega** | Encargado operativo del inventario | Ve solicitudes **aprobadas**, **prepara y despacha** (asigna lotes por FEFO), registra entrega y **devolución**, gestiona entradas/lotes y ajustes. No administra usuarios ni respaldos |
| **Estudiante** | Auxiliares/estudiantes que solo verifican | Solo lectura: consultar existencias, disponibilidad, vencimientos y reportes. No modifica nada |

El **Administrador** es el rol con mayores privilegios y acceso total.

### Flujo de préstamo (roles en acción)

```
Profesor            Supervisor              Bodega
   │                    │                     │
 crea          aprueba / rechaza         ve aprobadas,
solicitud  ───────────▶  la     ───────▶  prepara, entrega
de préstamo           solicitud           y recibe devolución
```

- Solo el **Profesor** crea solicitudes; el **Estudiante** únicamente visualiza.
- **Reactivos** solicitados se **consumen** (salida definitiva por FEFO).
- **Cristalería/materiales** son **préstamo**: al devolverlos **reingresan a stock**.

---

## 5. Requerimientos funcionales (funcionalidades)

Se definen **25 funcionalidades** (el examen pide mínimo 15), agrupadas por
módulo. Entre paréntesis, el requisito del examen que cubren.

### Autenticación y seguridad
1. **Inicio de sesión** con usuario y contraseña cifrada (BCrypt). (Req. 2)
2. **Gestión de usuarios** — CRUD de usuarios, activar/desactivar. (Req. 3, 5)
3. **Gestión de roles y permisos** — asignar/modificar/revocar permisos por
   rol. (Req. 3)
4. **Cierre de sesión** y control de acceso por rol en cada pantalla. (Req. 2)

### Catálogos maestros
5. **Gestión de reactivos** — CRUD con CAS, fórmula, clasificación de peligro,
   estado físico, categoría, unidad, stock mínimo. (Req. 5)
6. **Gestión de materiales/equipo** de laboratorio — CRUD. (Req. 5)
7. **Gestión de categorías** (ácidos, bases, solventes, indicadores, sales,
   material volumétrico, equipo…). (Req. 5)
8. **Gestión de unidades de medida** (g, kg, mg, mL, L, mol, unidad, caja…). (Req. 5)
9. **Gestión de proveedores.** (Req. 5)
10. **Gestión de ubicaciones/almacenes** (gabinete, estante, refrigerador) con
    sus condiciones de almacenamiento. (Req. 5)
11. **Gestión de laboratorios/prácticas** — destinos de los despachos. (Req. 5)

### Inventario y movimientos
12. **Registro de entradas** (ingreso de reactivos/materiales por lote, con
    vencimiento, proveedor y ubicación). (Req. 5)
13. **Registro de salidas / despachos** a una práctica o laboratorio, con
    **comprobante imprimible**. (Req. 6)
14. **Ajuste de inventario** (mermas, correcciones, reactivo dañado/derramado). (Req. 5)
15. **Control de existencias por lote** con descuento automático al despachar
    (primero el lote más próximo a vencer — FEFO). (Req. 5)
16. **Alertas automáticas** de vencimiento próximo y de stock bajo el mínimo. (Req. 7)

### Solicitudes y préstamos (flujo)
17. **Crear solicitud** (Profesor): pedir reactivos/cristalería/materiales para
    una práctica/laboratorio, con fecha requerida y líneas por artículo. (Req. 5, 6)
18. **Aprobar/rechazar solicitud** (Supervisor): bandeja de solicitudes
    pendientes con vista de líneas; aprobar o rechazar con motivo. (Req. 5)
19. **Preparar y entregar** (Bodega): ver solicitudes aprobadas, asignar lotes
    por **FEFO**, descontar existencias y marcar como entregada; genera el
    **comprobante de despacho** imprimible. (Req. 5, 6)
20. **Registrar devolución** (Bodega): cristalería/materiales prestados
    **reingresan a stock**; los reactivos quedan como consumidos. (Req. 5)
21. **Seguimiento de solicitud** (Profesor/Estudiante): consultar el estado
    (pendiente/aprobada/preparada/entregada/devuelta/rechazada). (Req. 5)

### Reportes y visualización
22. **Dashboard** con indicadores y **gráficos** (existencias por categoría,
    próximos a vencer, consumo por período). (Req. 7)
23. **Reportes parametrizados y exportables a Excel** (kardex por reactivo,
    consumo por laboratorio, vencimientos, existencias). (Req. 6)
24. **Reporte maestro-detalle** de despachos/solicitudes (cabecera + líneas). (Req. 6)

### Administración del sistema
25. **Respaldo y restauración** de la base de datos desde la interfaz. (Req. 8)

> Todas las funcionalidades se exponen mediante **APIs REST** (Req. 9) y se
> construyen con **React + .NET** (Req. 10).

---

## 6. Requerimientos no funcionales

- **Seguridad:** contraseñas cifradas con BCrypt; control de acceso por rol;
  APIs protegidas por autenticación; validación de datos en frontend y backend.
- **Usabilidad:** interfaz web responsiva, en español, con validaciones claras
  en cada formulario.
- **Rendimiento:** respuestas de la API por debajo de ~2 s en operaciones
  normales; paginación en listados grandes.
- **Confiabilidad / integridad:** operaciones de inventario **transaccionales**
  (una salida descuenta el lote y registra el movimiento de forma atómica).
- **Trazabilidad:** toda entrada, salida y ajuste queda registrada con usuario,
  fecha y motivo (bitácora de auditoría).
- **Mantenibilidad:** lógica de negocio en procedimientos almacenados; código
  organizado por capas (controladores, repositorios, modelos).
- **Respaldo:** posibilidad de generar y restaurar copias de la base desde el
  sistema.
- **Portabilidad:** aplicación web accesible desde cualquier navegador moderno.

---

## 7. Modelo de base de datos

Base **relacional (MySQL)**. Se definen **18 tablas** (el examen pide mínimo 10).

### Seguridad y accesos
| Tabla | Descripción |
|---|---|
| `roles` | Roles del sistema (Administrador, Supervisor, Profesor, Bodega, Estudiante) |
| `permisos` | Permisos individuales (ej. `reactivo.crear`, `despacho.registrar`) |
| `rol_permiso` | Relación N:M entre roles y permisos |
| `usuarios` | Usuarios: nombre, usuario, `password_hash` (BCrypt), rol, estado |

### Catálogos
| Tabla | Descripción |
|---|---|
| `categorias` | Categoría del artículo (ácido, base, solvente, material volumétrico…) |
| `unidades_medida` | Unidades (g, mg, kg, mL, L, mol, unidad, caja…) |
| `proveedores` | Proveedores de reactivos/materiales |
| `ubicaciones` | Almacenes/gabinetes/estantes y sus condiciones (refrigerado, ventilado…) |
| `laboratorios` | Laboratorios/prácticas destino de los despachos |

### Artículos e inventario
| Tabla | Descripción |
|---|---|
| `articulos` | Maestro de reactivos y materiales: `tipo` (REACTIVO/MATERIAL), nombre, categoría, unidad, stock mínimo, estado |
| `reactivo_ficha` | Extensión 1:1 solo para reactivos: `cas`, `formula`, `clasificacion_peligro` (GHS), `estado_fisico`, `concentracion`, `condiciones_almacenamiento` |
| `lotes` | Existencia real: cada lote de un artículo con `codigo_lote`, `fecha_vencimiento`, `cantidad_actual`, proveedor, ubicación, fecha de ingreso |

### Movimientos
| Tabla | Descripción |
|---|---|
| `movimientos` | Cabecera: `tipo` (ENTRADA/SALIDA/AJUSTE/DEVOLUCION), fecha, usuario, laboratorio destino (si es salida), `solicitud_id` (si nace de una solicitud), motivo/observación |
| `movimiento_detalle` | Líneas: lote, cantidad, unidad — el maestro-detalle |

### Solicitudes y préstamos (flujo de aprobación)
| Tabla | Descripción |
|---|---|
| `solicitudes` | Cabecera del préstamo: profesor solicitante, laboratorio/práctica destino, fecha requerida, `estado` (BORRADOR/PENDIENTE/APROBADA/RECHAZADA/PREPARADA/ENTREGADA/DEVUELTA/CERRADA), supervisor que aprobó, bodega que preparó, fechas y observaciones |
| `solicitud_detalle` | Líneas: artículo solicitado, cantidad, unidad; al preparar se registra el **lote asignado** (FEFO) y `cantidad_preparada`; para materiales, `cantidad_devuelta` |

### Administración
| Tabla | Descripción |
|---|---|
| `auditoria` | Bitácora: quién cambió qué y cuándo (stock, precios, datos sensibles) |
| `respaldos` | Registro de copias de seguridad generadas (fecha, usuario, archivo) |

### Relaciones principales
- `usuarios.rol_id` → `roles.id`
- `rol_permiso` conecta `roles` ↔ `permisos` (N:M)
- `articulos.categoria_id` → `categorias.id`; `articulos.unidad_id` → `unidades_medida.id`
- `reactivo_ficha.articulo_id` → `articulos.id` (1:1)
- `lotes.articulo_id` → `articulos.id`; `lotes.proveedor_id` → `proveedores.id`;
  `lotes.ubicacion_id` → `ubicaciones.id`
- `movimientos.usuario_id` → `usuarios.id`; `movimientos.laboratorio_id` → `laboratorios.id`;
  `movimientos.solicitud_id` → `solicitudes.id` (opcional)
- `movimiento_detalle.movimiento_id` → `movimientos.id`; `movimiento_detalle.lote_id` → `lotes.id`
- `solicitudes.profesor_id` / `supervisor_id` / `bodega_id` → `usuarios.id`;
  `solicitudes.laboratorio_id` → `laboratorios.id`
- `solicitud_detalle.solicitud_id` → `solicitudes.id`; `solicitud_detalle.articulo_id` → `articulos.id`;
  `solicitud_detalle.lote_id` → `lotes.id` (asignado al preparar)

### Regla de negocio central: existencias por lote
La existencia de un reactivo **no** vive en el artículo, sino repartida en sus
**lotes** (cada compra es un lote con su vencimiento). Al despachar se descuenta
de los lotes empezando por el **más próximo a vencer (FEFO)**. La existencia
total de un artículo = suma de `cantidad_actual` de sus lotes activos. Esto
permite el control de vencimientos, que es el corazón de un inventario de
reactivos.

### Regla de negocio central: préstamo vs consumo

El `tipo` del artículo decide qué pasa al entregar una solicitud:

- **REACTIVO → se consume.** La salida por FEFO es **definitiva**; no regresa.
- **MATERIAL / cristalería → se presta.** La salida es temporal; al registrar la
  **devolución**, la cantidad devuelta **reingresa a stock** (movimiento
  `DEVOLUCION`). Una solicitud con materiales solo se **CIERRA** cuando todo lo
  prestado fue devuelto (o se ajusta por rotura/pérdida vía `AJUSTE`).

Todo movimiento de existencias (salida al preparar, devolución) se ejecuta de
forma **transaccional** dentro de un stored procedure: descuenta/reingresa el
lote y registra el `movimiento` de forma atómica.

---

## 8. Trazabilidad: cobertura de los 10 requisitos del examen

| Req. | Requisito | Cómo se cubre |
|---|---|---|
| 1 | Análisis y 15+ funcionalidades | Este documento — 25 funcionalidades |
| 2 | Login + 3 roles | `usuarios`, `roles`; 5 roles: Admin/Supervisor/Profesor/Bodega/Estudiante |
| 3 | Roles/permisos + cifrado | `permisos`, `rol_permiso`; BCrypt |
| 4 | BD mínimo 10 tablas | 18 tablas relacionales |
| 5 | CRUD + validaciones | Todos los catálogos y movimientos |
| 6 | 8 reportes (maestro-detalle, factura, parametrizados, Excel) | Despachos, comprobante imprimible, kardex, export Excel |
| 7 | Dashboard con 3 gráficos | Existencias por categoría, próximos a vencer, consumo por período |
| 8 | Backup/restore | Módulo de administración + tabla `respaldos` |
| 9 | Todo por APIs | API REST en .NET |
| 10 | Frameworks | React + .NET + MySQL |

---

## 9. Los 8 reportes propuestos

1. **Kardex por reactivo** (movimientos de entrada/salida de un artículo) — parametrizado.
2. **Comprobante de despacho** imprimible (maestro-detalle, "factura" del examen).
3. **Existencias actuales** por categoría/ubicación — exportable a Excel.
4. **Reactivos próximos a vencer** (parámetro: días) — exportable a Excel.
5. **Reactivos bajo stock mínimo.**
6. **Consumo por laboratorio/práctica** en un período — parametrizado.
7. **Entradas por proveedor** en un período.
8. **Reporte de lotes vencidos** para descarte.

---

## 10. Tecnologías

- **Frontend:** React + Vite + Tailwind CSS.
- **Backend:** .NET (ASP.NET Core Web API), lógica en procedimientos almacenados.
- **Base de datos:** MySQL 8 (relacional).
- **Cifrado:** BCrypt para contraseñas.
- **Reportes Excel:** librería de exportación (ej. ClosedXML / EPPlus en .NET).
- **Gráficos:** librería de charts en React (ej. Recharts / Chart.js).
- **Respaldo:** `mysqldump` / restore invocado desde el backend.
