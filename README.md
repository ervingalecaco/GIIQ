# LabQuim — Sistema de Inventario de Laboratorio de Química

Guía de **instalación y puesta en marcha** del proyecto en una computadora nueva.
Pensada para el caso de **copiar toda esta carpeta** y hacerlo funcionar desde cero.

> ⚠️ **LO MÁS IMPORTANTE:** copiar esta carpeta **NO copia la base de datos**.
> Los datos de MySQL viven en el directorio interno de MySQL, no aquí. En el PC
> nuevo hay que **recrear la base ejecutando los scripts** de `database/`
> (ver [Paso 3](#paso-3--base-de-datos)). Si no haces esto, el backend no arranca bien.

---

## 1. ¿Qué es?

Aplicación web para el **control y gestión del inventario de reactivos y
materiales de un laboratorio de química**: catálogo por lotes con vencimiento
(FEFO), flujo de solicitud → aprobación → préstamo, roles y permisos, reportes
con exportación a Excel, dashboard con gráficos y respaldo/restauración de la BD.

### Tecnologías
| Capa | Tecnología |
|---|---|
| Frontend | React 19 + Vite + Tailwind CSS 4 (TypeScript) |
| Backend | .NET 10 (ASP.NET Core Web API) + Dapper |
| Base de datos | MySQL 8 — lógica de negocio en *stored procedures* |
| Autenticación | JWT por usuario + contraseñas con BCrypt |

---

## 2. Estructura de la carpeta

```
Examen de Grado/
├─ README.md                 ← este archivo
├─ database/                 ← scripts SQL (esquema, datos, procedimientos)
│  ├─ 01_schema.sql          ← las 18 tablas
│  ├─ 02_seeds.sql           ← roles, permisos, catálogos, usuario admin
│  ├─ 03_procedures.sql      ← SP del flujo de solicitudes e inventario
│  ├─ 05_procedures_articulos.sql
│  ├─ 06_procedures_usuarios.sql
│  ├─ 07_procedures_catalogos.sql
│  ├─ 04_smoke_test.sql      ← datos de DEMO + prueba (opcional)
│  └─ ER_diagrama.md         ← diagrama entidad-relación (Mermaid)
├─ backend/LabQuim.Api/      ← API en .NET 10
└─ frontend/                 ← app React (Vite)
```

---

## 3. Qué instalar en la computadora nueva

Instala estos tres programas (versiones iguales o superiores):

1. **MySQL Server 8.0** (incluye MySQL Workbench) — https://dev.mysql.com/downloads/installer/
2. **.NET SDK 10** — https://dotnet.microsoft.com/download/dotnet/10.0
3. **Node.js 20+** (probado con v24) — https://nodejs.org

Para comprobar que quedaron instalados, abre una terminal y ejecuta:

```bash
dotnet --version
node --version
npm --version
```

---

## 4. Preparar la carpeta copiada

Al copiar la carpeta se arrastran carpetas pesadas y específicas de la máquina
vieja que **conviene borrar y regenerar** (no son necesarias, se recrean solas):

- `frontend/node_modules/`  (se regenera con `npm install`)
- `frontend/dist/`
- `backend/LabQuim.Api/bin/` y `backend/LabQuim.Api/obj/`
- `backend/LabQuim.Api/backups/` (respaldos viejos, opcional)

Puedes borrarlas a mano, o desde la terminal en la raíz del proyecto (PowerShell):

```powershell
Remove-Item -Recurse -Force frontend\node_modules, frontend\dist, backend\LabQuim.Api\bin, backend\LabQuim.Api\obj -ErrorAction SilentlyContinue
```

---

## Paso 3 — Base de datos

Recrea la base en el MySQL del PC nuevo. **Importante: usa siempre
`--default-character-set=utf8mb4`**, si no los acentos se guardan corruptos.

> La ruta de `mysql.exe` suele ser
> `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`. Ajusta si tu versión difiere.

### ✅ Opción A (recomendada) — un solo archivo con TODO

El archivo `database/labquim_completo.sql` contiene **la base completa**:
estructura + datos reales + procedimientos. Crea la base `labquim` desde cero
(incluye el `CREATE DATABASE`). Abre PowerShell en la carpeta `database/`:

```powershell
$mysql = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
& $mysql --default-character-set=utf8mb4 -u root -p -e "source labquim_completo.sql;"
```

Con eso ya tienes todo (incluidos los usuarios con sus contraseñas actuales).
Puedes saltarte la Opción B.

> 🔄 **Para actualizar este archivo** con los datos más recientes antes de migrar,
> ejecútalo en el PC viejo:
> ```powershell
> $dump = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"
> & $dump --default-character-set=utf8mb4 -u root -p --routines --single-transaction --add-drop-database --databases labquim --result-file="labquim_completo.sql"
> ```

### Opción B — reconstruir desde los scripts por separado

Si prefieres crear la base vacía (sin datos de ejemplo) o paso a paso:

Abre PowerShell en la carpeta `database/` y ejecuta (te pedirá la contraseña de `root`):

```powershell
$mysql = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
& $mysql --default-character-set=utf8mb4 -u root -p -e "source 01_schema.sql; source 02_seeds.sql; source 03_procedures.sql; source 05_procedures_articulos.sql; source 06_procedures_usuarios.sql; source 07_procedures_catalogos.sql;"
```

Esto crea la base **`labquim`** con todas las tablas, procedimientos, catálogos
y el usuario administrador.

- **Datos de demostración (opcional):** si quieres artículos/solicitudes de
  ejemplo para ver la app con contenido, ejecuta además:
  ```powershell
  & $mysql --default-character-set=utf8mb4 -u root -p labquim -e "source 04_smoke_test.sql;"
  ```
- Para empezar **vacío** (producción), **no** ejecutes `04_smoke_test.sql`.

---

## Paso 4 — Configurar la conexión

El backend lee la cadena de conexión de
`backend/LabQuim.Api/appsettings.Development.json`. Ese archivo **se copia con la
carpeta**, pero está configurado con la contraseña de MySQL de la máquina vieja:

```json
"ConnectionStrings": {
  "Default": "Server=localhost;Port=3306;Database=labquim;User Id=root;Password=123qwe;AllowUserVariables=true;"
}
```

👉 **Si la contraseña de `root` en el PC nuevo es distinta de `123qwe`, edítala ahí.**
No cambies `AllowUserVariables=true` (es necesario para la zona horaria).

---

## Paso 5 — Levantar el backend (API)

En una terminal:

```bash
cd backend/LabQuim.Api
dotnet run
```

- Queda escuchando en **http://localhost:5099**
- Documentación interactiva (Swagger): **http://localhost:5099/swagger**
- La primera vez, en modo desarrollo, asigna automáticamente la contraseña
  `Clave123` a los usuarios de prueba (ver [sección 7](#7-usuarios-y-contraseñas)).

Déjala corriendo y abre **otra** terminal para el frontend.

---

## Paso 6 — Levantar el frontend (web)

```bash
cd frontend
npm install        # solo la primera vez (regenera node_modules)
npm run dev
```

- Abre la app en **http://localhost:5173**

> El frontend apunta al backend mediante `frontend/.env.development`
> (`VITE_API_URL=http://localhost:5099`). Solo cámbialo si usas otro puerto.

---

## 7. Usuarios y contraseñas

En **desarrollo**, al arrancar el backend por primera vez se asigna la clave
`Clave123` a estos usuarios (todos con rol distinto, útiles para probar):

| Usuario | Rol | Clave (dev) |
|---|---|---|
| `admin` | Administrador | `Clave123` |
| `super` | Supervisor | `Clave123` |
| `profe` | Profesor | `Clave123` |
| `bode`  | Bodega | `Clave123` |

> ⚠️ Son credenciales de **desarrollo**. En un entorno real hay que asignar
> contraseñas propias (se puede desde el módulo **Usuarios** de la app).

---

## 8. Orden de arranque (resumen rápido)

1. Instalar MySQL 8, .NET 10 SDK y Node.js.
2. Borrar `node_modules`, `bin`, `obj` de la carpeta copiada.
3. Crear la BD con los scripts de `database/` (**con `utf8mb4`**).
4. Revisar la contraseña en `appsettings.Development.json`.
5. `cd backend/LabQuim.Api` → `dotnet run`
6. `cd frontend` → `npm install` → `npm run dev`
7. Abrir http://localhost:5173 e iniciar sesión con `admin` / `Clave123`.

---

## 9. Respaldo y restauración (dentro de la app)

La app tiene un módulo **Respaldos** (solo Administrador):

- **Crear respaldo:** genera un `.sql` completo (incluye los procedimientos) en
  `backend/LabQuim.Api/backups/` y lo registra en el historial.
- **Restaurar:** sube un `.sql` y reemplaza todos los datos actuales.

Esto usa `mysqldump.exe` / `mysql.exe`. Si en el PC nuevo están en otra ruta,
ajusta `Backup:MySqlBinDir` en `appsettings.json`.

> 💡 **Alternativa para migrar los datos reales** (no solo la estructura):
> antes de migrar, entra a la app en el PC viejo → **Respaldos** → *Crear
> respaldo* → *Descargar*. En el PC nuevo, tras crear la base vacía, entra a
> **Respaldos** → *Restaurar* y sube ese archivo.

---

## 10. Problemas frecuentes

| Síntoma | Causa / Solución |
|---|---|
| Acentos corruptos (`Ã¡cido`) | La BD se cargó sin `--default-character-set=utf8mb4`. Vuelve a cargar los scripts con ese parámetro. |
| El backend no conecta a la BD | Contraseña de `root` incorrecta en `appsettings.Development.json`, o el servicio de MySQL no está corriendo. |
| `npm run dev` falla | Borra `frontend/node_modules` y corre `npm install` de nuevo. |
| Fechas con una hora de diferencia | El backend fija `time_zone = '-06:00'` (Nicaragua) por conexión; requiere `AllowUserVariables=true` en la cadena de conexión. |
| Login dice credenciales incorrectas | Asegúrate de haber arrancado el backend al menos una vez (asigna las claves de dev), y usa `Clave123`. |

---

## 11. Notas técnicas

- **Toda la lógica de negocio está en stored procedures** (transaccional y
  atómico). El backend solo los invoca con Dapper.
- La auditoría se escribe **desde los procedimientos** (no con triggers).
- El diagrama entidad-relación está en `database/ER_diagrama.md` (formato Mermaid,
  se ve renderizado en GitHub o VS Code con extensión Mermaid).
- El proyecto está bajo **git**. Para ver el historial: `git log --oneline`.
