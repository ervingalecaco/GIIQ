# Sistema POS — Distribuidora Rivera

Documento de contexto del sistema actual. Sirve como base para arrancar un
proyecto nuevo con el conocimiento de lo que ya existe, cómo está armado y
qué lecciones dejó.

---

## 1. Qué es

Sistema de **facturación e inventario para distribución puerta a puerta**.
Un vendedor sale con mercadería cargada en un camión y factura a clientes en
la calle, muchas veces **sin conexión a internet**. Un administrador gestiona
productos, precios, inventario y reportes desde una web.

- **Cliente:** Distribuidora Rivera (Nicaragua)
- **Moneda:** Córdobas (C$)
- **Usuarios reales:** 1 administrador + 1 vendedor (José Luis)

---

## 2. Stack tecnológico

| Capa | Tecnología |
|---|---|
| Panel web (admin) | React 19 + Vite + Tailwind CSS |
| App móvil (vendedor) | Tauri 2 (WebView + Rust) → APK Android |
| Backend | .NET 10 (ASP.NET Core Web API) |
| Base de datos | MySQL 8 — **toda la lógica en stored procedures** |
| Almacenamiento offline (móvil) | IndexedDB |
| Imágenes de productos | Cloudflare R2 (S3-compatible) |
| Impresión de recibos | Térmica Bluetooth (ESC/POS) vía bridge nativo Kotlin |

El frontend web y el frontend móvil **comparten el mismo código React**. El
móvil es ese mismo build empaquetado con Tauri, con un par de ramas para
detectar si corre en Tauri (`location.hostname === 'tauri.localhost'`).

---

## 3. Infraestructura

- **API + web:** hosting compartido SmarterASP.NET (IIS). La web se sirve en
  `/admin/` sobre el mismo sitio de la API.
- **Base de datos:** MySQL en site4now (servidor separado del de la app).
- **Imágenes:** bucket en Cloudflare R2, servidas por su CDN pública.
- La API y la base están en **servidores distintos** — uno puede caerse sin
  el otro.

**Autenticación:**
- Login usuario/contraseña, hash **BCrypt**, roles `admin` / `salesperson`.
- Cada request lleva un header `X-Api-Key` (clave compartida) + Basic Auth del
  hosting. No hay tokens de sesión por usuario en la base.
- Un header `X-User-Id` viaja para que la auditoría sepa quién hizo cada cambio.

---

## 4. Modelo de datos

Tablas principales (MySQL):

| Tabla | Para qué |
|---|---|
| `categories` | Categorías de producto |
| `units` | Unidades de medida (ud, Lb, Caja, Doc, Disp…) |
| `suppliers` | Proveedores |
| `products` | Productos: código único, precios costo/venta/mayoreo, **stock (bodega)**, imagen |
| `customers` | Clientes: número auto de 5 dígitos, RUC/cédula opcional, zona, ubicación GPS |
| `users` | Usuarios (admin / vendedor) |
| `sales` | Cabecera de venta (subtotal, descuento, total, estado, fechas) |
| `sale_details` | Líneas de venta (producto, cantidad, precio, total línea) |
| `route_inventory` | **Inventario del camión** por vendedor |
| `route_movements` | Cargas y descargas bodega ↔ camión |
| `route_movement_details` | Líneas de cada movimiento |
| `sale_corrections` | Correcciones y anulaciones de ventas |
| `error_logs` | Errores de la API |
| `stock_audit` | Auditoría de cambios de stock de bodega |
| `price_audit` | Auditoría de cambios de precio |
| `daily_inventory_snapshot` | Foto diaria de bodega y camión (cierre) |

### Concepto clave: Bodega vs Ruta

Es la decisión de arquitectura central del sistema:

- **Bodega (warehouse)** = `products.stock`. Lo que está en el local.
- **Ruta / camión (route)** = `route_inventory`. Lo que anda cargado el vendedor.
- **Cargar ruta** mueve mercadería bodega → camión (baja `stock`, sube `route_inventory`).
- **Descargar ruta** mueve camión → bodega (lo inverso). No se hace todos los días.
- **Las ventas se descuentan del CAMIÓN, no de la bodega.** El vendedor solo
  puede facturar lo que trae cargado.
- **Total** de un producto = bodega + camión.

---

## 5. Módulos — Panel web (admin)

- **Productos:** CRUD completo (código único, categoría, unidad, proveedor,
  precio costo/venta/mayoreo, imagen en R2, stock).
- **Inventario:** vista de 3 columnas **Bodega | Ruta | Total**, KPIs
  clickeables (activos, en ruta, stock bajo, agotados), ingreso de mercadería,
  ajuste de stock, edición rápida de precios, **valorización** del inventario
  a costo y a precio de venta.
- **Ventas:** reporte con filtros por fecha (hoy/ayer/semana/mes/personalizado),
  vendedor y zona. Muestra descuentos y ahorro mayorista. Las anuladas se ven
  pero no suman.
- **Clientes:** CRUD con número de cliente automático, RUC/cédula, zona
  (departamento + municipio), ubicación Google Maps.
- **Proveedores:** CRUD + contador de productos.
- **Categorías y unidades de medida.**
- **Correcciones:** bandeja de aprobación de correcciones/anulaciones con vista
  antes/después.
- **Usuarios:** gestión (admin / vendedor).

---

## 6. Módulos — App móvil (vendedor)

- **Facturar (POS):** selección de cliente, carrito, descuento %, factura
  **contra la ruta**. Bloquea cobro si no hay cliente válido seleccionado.
- **Clientes:** crear/editar con captura de GPS y RUC/cédula.
- **Inventario de ruta:** cargar y descargar mercadería.
- **Ventas del día:** historial, reimpresión, corrección de la última factura.
- **Impresión Bluetooth** del recibo (ESC/POS).
- **Modo offline:** todo funciona sin señal; las ventas y clientes se encolan
  y sincronizan al recuperar conexión.

---

## 7. Reglas de negocio clave

- **Descuento** permitido: 0 % a 50 %.
- **Número de cliente:** 5 dígitos, autogenerado y correlativo (00001, 00002…),
  no editable.
- **Cantidades decimales:** se puede vender 0.25, 0.5, 1.25 (paso 0.25). El
  stock también es decimal.
- **Precios:** cada producto tiene precio de **detalle** (D) y **mayoreo** (M);
  en el recibo se marca cuál se aplicó.
- **Corrección de venta (vendedor):** solo puede corregir **su última** venta y
  **del mismo día**. Fuera de eso, lo hace el admin desde la bandeja.
- **Anulación:** devuelve la mercadería a ruta o bodega según se elija; queda
  registrada, visible, y no suma en los totales.
- **Recibo:** encabezado "DISTRIBUIDORA RIVERA", número de cliente, RUC/cédula
  si existe, líneas con marca D/M, descuento si aplica, total.

---

## 8. Sincronización offline (lo más delicado)

El vendedor trabaja sin señal. La app guarda en IndexedDB:

- **Ventas pendientes:** se crean localmente, descuentan la ruta local, y se
  suben al servidor cuando hay conexión.
- **Clientes creados offline:** llevan un **ID temporal negativo**; al
  sincronizar se canjean por el ID real buscándolos por nombre.

**Regla de oro aprendida a los golpes:** una venta que el servidor rechaza
**NUNCA se borra**. Se **aparta** (marca `failed`) y se muestra un aviso rojo
persistente en la app ("X venta no se registró") con un botón "Ya la rehice".
La mercadería ya salió del camión y el cliente ya tiene su recibo — borrarla en
silencio hace desaparecer ventas reales (nos pasó dos veces antes de este fix).

---

## 9. Auditoría

- **Movimientos bodega ↔ camión:** siempre registrados (`route_movements`).
- **Cambios de stock de bodega y de precios:** auditados en `stock_audit` /
  `price_audit`, **escritos desde los stored procedures** (no desde triggers,
  porque el hosting compartido **niega el privilegio `CREATE TRIGGER`**).
- **Limitación:** lo editado directo en la base (SQL manual) **no** queda
  auditado. Y el stocking inicial (previo a activar la auditoría) no tiene
  bitácora — no se puede reconstruir la bodega histórica con exactitud.
- **Cierre diario:** `daily_inventory_snapshot` guarda una foto real de bodega
  y camión por día (vía `sp_take_daily_snapshot`), porque reconstruir hacia
  atrás no es confiable para bodega.

---

## 10. Zona horaria

El servidor de hosting está en **UTC-7**; Nicaragua es **UTC-6** (sin horario
de verano). Sin corregirlo, las fechas quedaban una hora atrás y el corte por
día caía mal. **Solución:** la fábrica de conexiones fija
`SET time_zone = '-06:00'` en cada conexión, y el connection string usa
`AllowUserVariables=true`. Ojo: consultas hechas por SQL directo (mysqlsh,
phpMyAdmin) **no** fijan la zona y muestran la hora del servidor.

---

## 11. Impresión térmica

- Builder **ESC/POS en JavaScript** (`escpos.js`) arma los bytes del recibo.
- Un **bridge nativo Android en Kotlin** (`BluetoothPrinterBridge`) expone
  `window.BluetoothPrinter` al WebView: buscar impresora, permisos, imprimir.
- Modal de selección de impresora; la elegida se guarda.

---

## 12. Imágenes de producto (Cloudflare R2)

- Servicio S3-compatible (`AWSSDK.S3`) apuntando al endpoint de R2, con
  `ForcePathStyle = true` y `DisablePayloadSigning = true`.
- Endpoint `POST /api/imagen/upload` (valida tipo y tamaño ≤ 5 MB) y
  `DELETE /api/imagen`.
- La URL pública se guarda en `products.image_path`; las imágenes se sirven
  desde la CDN de R2, no desde el servidor de la app.

---

## 13. Despliegue

- **API:** `dotnet publish -c Release`.
- **Web:** `npx vite build --base=/admin/` (¡el `--base` es obligatorio!).
- Se empaqueta un ZIP con los archivos del API en la raíz + carpeta `admin/`
  con el build web, y se sube al File Manager de SmarterASP para extraer.
- **APK:** `npx tauri android build --apk`, luego **`zipalign` + `apksigner`**
  (no `jarsigner`).

**Trampa importante del empaquetado:** `tauri android build` corre su propio
`npm run build` **sin** `--base=/admin/`, y sobrescribe `dist/`. Por eso el
orden correcto es: **1) publicar API → 2) build APK → 3) build web con
`--base=/admin/` → 4) armar ZIP**. Al revés, el ZIP sale con rutas rotas.
Verificar siempre que el `index.html` dentro del ZIP apunte a `/admin/assets/…`.

---

## 14. Problemas conocidos y lecciones aprendidas

- **Ventas perdidas (resuelto):** clientes creados con señal intermitente
  perdían su ID y la venta se rechazaba y **se borraba en silencio**. Fix:
  no borrar nunca (apartar + aviso rojo), bloquear cobro sin cliente válido,
  y resolver el ID temporal contra el servidor antes de enviar.
- **Ventas duplicadas por dedazo (operativo):** el vendedor factura lo mismo a
  dos clientes seguidos. Difícil de bloquear por software sin estorbar; se
  detecta con una consulta de "mismo cliente/carrito, segundos de diferencia"
  y se anula la sobrante.
- **Números de factura "quemados":** cuando una venta falla, MySQL no devuelve
  el número consumido (queda un hueco). Es cosmético, no afecta totales.
- **El hosting niega TRIGGER** → auditar desde procedimientos.
- **Bodega histórica no reconstruible** antes de la auditoría → snapshots diarios.
- **App pool se detiene** en hosting compartido → se reinicia desde el panel de
  SmarterASP (no cambiar la versión del pool, corre bien como está).

---

## 15. Configuración (referencia)

Los secretos **no van en este documento ni en git**. Se manejan en:

- `appsettings.Production.json` (API): connection string, API key, sección R2
  (AccountId, AccessKeyId, SecretAccessKey, Bucket, PublicUrl, endpoint S3).
- `.env.production` (web): `VITE_API_KEY`, `VITE_BASIC_AUTH`.
- Keystore de firma del APK.

El repositorio git es **solo del frontend** (`web/`), no de la API.

---

## 16. Qué reusar / repensar en el proyecto nuevo

Ideas que funcionaron y conviene mantener:
- Separación **bodega / ruta** con ventas contra la ruta.
- **Offline-first real** con cola de sincronización.
- **Nunca borrar** una operación rechazada: apartar y avisar.
- Toda la lógica de negocio en **stored procedures** (transaccional, atómico).
- Auditoría de stock y precios.
- Snapshots diarios en vez de reconstruir historia.

Cosas a repensar:
- Tokens de sesión por usuario (hoy es API key compartida).
- Auditoría por **triggers** si el hosting nuevo lo permite (más robusta que
  escribir desde procedimientos).
- Prevención/aviso de ventas duplicadas.
- Notificar al panel del admin cuando una venta queda apartada en un teléfono
  (hoy el aviso vive solo en el móvil).
- Reportes de cierre (camión + bodega + plata) unificados.
