# Diagrama Entidad-Relación — LabQuim

Modelo relacional del sistema de inventario de reactivos y materiales de
laboratorio de química (18 tablas, MySQL 8). Corresponde a `01_schema.sql`.

```mermaid
erDiagram
    %% ===================== SEGURIDAD =====================
    roles {
        int id PK
        string nombre UK
        string descripcion
        bool activo
    }
    permisos {
        int id PK
        string codigo UK
        string modulo
        string descripcion
    }
    rol_permiso {
        int rol_id PK,FK
        int permiso_id PK,FK
    }
    usuarios {
        int id PK
        string usuario UK
        string password_hash
        string email
        int rol_id FK
        bool activo
    }

    %% ===================== CATALOGOS =====================
    categorias {
        int id PK
        string nombre UK
        string descripcion
    }
    unidades_medida {
        int id PK
        string nombre
        string abreviatura UK
    }
    proveedores {
        int id PK
        string nombre UK
        string contacto
    }
    ubicaciones {
        int id PK
        string nombre UK
        string condiciones
    }
    laboratorios {
        int id PK
        string nombre UK
    }

    %% ================ ARTICULOS E INVENTARIO ================
    articulos {
        int id PK
        enum tipo "REACTIVO|MATERIAL"
        string codigo UK
        string nombre
        int categoria_id FK
        int unidad_id FK
        decimal stock_minimo
        bool activo
    }
    reactivo_ficha {
        int articulo_id PK,FK
        string cas
        string formula
        string clasificacion_peligro
        enum estado_fisico
        string concentracion
    }
    lotes {
        int id PK
        int articulo_id FK
        string codigo_lote
        date fecha_vencimiento
        decimal cantidad_actual
        int proveedor_id FK
        int ubicacion_id FK
        date fecha_ingreso
    }

    %% ================ SOLICITUDES (FLUJO) ================
    solicitudes {
        int id PK
        int profesor_id FK
        int supervisor_id FK
        int bodega_id FK
        int laboratorio_id FK
        enum estado "PENDIENTE..CERRADA"
        date fecha_requerida
    }
    solicitud_detalle {
        int id PK
        int solicitud_id FK
        int articulo_id FK
        int unidad_id FK
        int lote_id FK
        decimal cantidad_solicitada
        decimal cantidad_preparada
        decimal cantidad_devuelta
    }

    %% ================ MOVIMIENTOS ================
    movimientos {
        int id PK
        enum tipo "ENTRADA|SALIDA|AJUSTE|DEVOLUCION"
        int usuario_id FK
        int laboratorio_id FK
        int solicitud_id FK
        datetime fecha
    }
    movimiento_detalle {
        int id PK
        int movimiento_id FK
        int lote_id FK
        decimal cantidad
    }

    %% ================ ADMINISTRACION ================
    auditoria {
        bigint id PK
        int usuario_id FK
        string entidad
        string accion
        json valores_antes
        json valores_despues
    }
    respaldos {
        int id PK
        int usuario_id FK
        string archivo
        datetime fecha
    }

    %% ===================== RELACIONES =====================
    roles           ||--o{ usuarios          : "tiene"
    roles           ||--o{ rol_permiso        : "asigna"
    permisos        ||--o{ rol_permiso        : "incluye"

    categorias      ||--o{ articulos          : "clasifica"
    unidades_medida ||--o{ articulos          : "mide"
    articulos       ||--|| reactivo_ficha     : "ficha 1:1"
    articulos       ||--o{ lotes              : "existe en"
    proveedores     ||--o{ lotes              : "provee"
    ubicaciones     ||--o{ lotes              : "almacena"

    usuarios        ||--o{ solicitudes        : "profesor crea"
    usuarios        ||--o{ solicitudes        : "supervisor aprueba"
    usuarios        ||--o{ solicitudes        : "bodega prepara"
    laboratorios    ||--o{ solicitudes        : "destino"
    solicitudes     ||--o{ solicitud_detalle  : "contiene"
    articulos       ||--o{ solicitud_detalle  : "pedido de"
    unidades_medida ||--o{ solicitud_detalle  : "unidad"
    lotes           ||--o{ solicitud_detalle  : "asignado FEFO"

    usuarios        ||--o{ movimientos        : "registra"
    laboratorios    ||--o{ movimientos        : "destino"
    solicitudes     ||--o{ movimientos        : "origina"
    movimientos     ||--o{ movimiento_detalle : "detalla"
    lotes           ||--o{ movimiento_detalle : "afecta"

    usuarios        ||--o{ auditoria          : "audita"
    usuarios        ||--o{ respaldos          : "genera"
```

## Notas de lectura

- **Existencia solo en `lotes`.** `articulos` es el maestro; la cantidad real
  vive repartida en sus lotes. Total de un artículo = suma de `cantidad_actual`
  de sus lotes activos. Índice `(articulo_id, fecha_vencimiento)` soporta **FEFO**.
- **`reactivo_ficha` es 1:1 con `articulos`** y solo aplica a reactivos (CAS,
  fórmula, peligro GHS, estado físico).
- **`solicitudes` referencia a `usuarios` tres veces**: profesor (crea),
  supervisor (aprueba) y bodega (prepara/entrega).
- **`movimientos` ↔ `movimiento_detalle`** es el maestro-detalle de inventario;
  cada línea afecta un `lote`. Una SALIDA por FEFO puede tener varias líneas
  (varios lotes) para una sola línea de solicitud.
- **`solicitud_detalle.lote_id`** se asigna al preparar (FEFO); `cantidad_devuelta`
  solo se usa en materiales/cristalería (préstamo con devolución).
