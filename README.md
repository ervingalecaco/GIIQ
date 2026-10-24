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
│  ├─ 01_schema.sql          ← las 21 tablas
│  ├─ 02_seeds.sql           ← roles, permisos, catálogos, usuario admin
│  ├─ 03_procedures.sql      ← SP del flujo de solicitudes e inventario
│  ├─ 05_procedures_articulos.sql
│  ├─ 06_procedures_usuarios.sql
│  ├─ 07_procedures_catalogos.sql
│  ├─ 04_smoke_test.sql      ← datos de DEMO + prueba (opcional)
│  ├─ 08_migracion_cristaleria.sql ← solo para bases viejas (MATERIAL → CRISTALERIA)
│  ├─ 09_migracion_solicitudes_estudiantes.sql ← solo para bases viejas (estudiantes crean solicitudes)
│  ├─ 10_migracion_clases_practicas.sql ← solo para bases viejas (clases, profesores y prácticas)
│  ├─ 11_migracion_usuarios_nombres_codigo.sql ← solo para bases viejas (nombres/apellidos y código)
│  ├─ 12_migracion_solicitudes_por_tipo.sql ← solo para bases viejas (solicitudes de reactivos / cristalería)
│  ├─ 13_migracion_rombo_nfpa.sql ← solo para bases viejas (rombo de seguridad NFPA 704)
│  ├─ 14_migracion_imagenes_cristaleria.sql ← solo para bases viejas (foto de referencia de la cristalería)
│  ├─ 15_migracion_bajas_cuentas.sql ← solo para bases viejas (bajas de cristalería y cuenta del estudiante)
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

> 🔁 **Base creada antes del cambio a «Cristalería»:** si tu base todavía tiene
> artículos con tipo `MATERIAL`, conviértela (sin perder datos) con:
> ```powershell
> & $mysql --default-character-set=utf8mb4 -u root -p -e "source 08_migracion_cristaleria.sql; source 03_procedures.sql; source 05_procedures_articulos.sql;"
> ```
>
> 🔁 **Base creada antes de que los estudiantes pudieran crear solicitudes:**
> ```powershell
> & $mysql --default-character-set=utf8mb4 -u root -p -e "source 09_migracion_solicitudes_estudiantes.sql; source 03_procedures.sql;"
> ```
> Luego cada usuario debe cerrar sesión y volver a entrar para recibir los permisos nuevos.
>
> 🔁 **Base creada antes de clases y prácticas:**
> ```powershell
> & $mysql --default-character-set=utf8mb4 -u root -p -e "source 10_migracion_clases_practicas.sql; source 03_procedures.sql; source 07_procedures_catalogos.sql;"
> ```
> Después registra en **Catálogos → Clases** qué profesores imparten cada clase, y en
> **Catálogos → Prácticas** las prácticas de cada clase. Sin eso no se pueden crear solicitudes.
>
> 🔁 **Base creada antes de separar nombres y apellidos:**
> ```powershell
> & $mysql --default-character-set=utf8mb4 -u root -p -e "source 11_migracion_usuarios_nombres_codigo.sql; source 06_procedures_usuarios.sql;"
> ```
> Divide el nombre completo (primera mitad de las palabras = nombres). Revisa en
> **Usuarios** los nombres compuestos y asigna el código a profesores y estudiantes.
>
> 🔁 **Base creada antes de separar solicitudes de reactivos y de cristalería:**
> ```powershell
> & $mysql --default-character-set=utf8mb4 -u root -p -e "source 12_migracion_solicitudes_por_tipo.sql; source 03_procedures.sql;"
> ```
> Las solicitudes que incluían cristalería quedan como de cristalería; el resto, de reactivos.
>
> 🔁 **Base creada antes del rombo de seguridad NFPA 704:**
> ```powershell
> & $mysql --default-character-set=utf8mb4 -u root -p -e "source 13_migracion_rombo_nfpa.sql; source 05_procedures_articulos.sql;"
> ```
> Los reactivos existentes quedan «Sin rombo»: complétalo al editarlos (es obligatorio).

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

## Paso 6b — App Android (APK)

La misma app web se empaqueta como APK con **Capacitor** (carpeta `frontend/android/`).
Requisitos: **JDK 21** y el **SDK de Android** (viene con Android Studio; variable `ANDROID_HOME`).

1. **API accesible desde el celular.** El celular no puede usar `localhost`: la API
   debe escuchar en la red y la APK debe apuntar a la IP de esta PC.
   - Arranca la API con el perfil de red local:
     ```bash
     cd backend/LabQuim.Api
     dotnet run --launch-profile red-local
     ```
   - Permite el puerto 5099 en el firewall de Windows (una sola vez, en PowerShell **como administrador**):
     ```powershell
     New-NetFirewallRule -DisplayName "BioQ API 5099" -Direction Inbound -Protocol TCP -LocalPort 5099 -Action Allow -Profile Private
     ```
   - La IP va en `frontend/.env.movil` (`VITE_API_URL=http://192.168.1.239:5099`).
     Si la IP de la PC cambia, edítala y vuelve a generar la APK. Para ver la IP: `ipconfig`.
2. **Generar la APK** (de prueba, sin firmar):
   ```bash
   cd frontend
   npm run apk
   ```
   Queda en `frontend/android/app/build/outputs/apk/debug/app-debug.apk`.
3. **Instalarla:** copia el archivo al celular y ábrelo (Android pedirá permitir
   «instalar apps de fuentes desconocidas»). El celular debe estar en la **misma red
   Wi-Fi** que la PC, con la API corriendo.

> El ícono y la pantalla de inicio salen del logo (`frontend/assets-app/`). Si cambias
> el logo, regenera con:
> `npx @capacitor/assets generate --android --assetPath assets-app --iconBackgroundColor "#ffffff" --splashBackgroundColor "#ffffff"`

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
| `ana`   | Estudiante | `Clave123` |

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
