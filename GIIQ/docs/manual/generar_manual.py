"""
Genera «GIIQ — Manual de instalación» en PDF.

Uso (desde la carpeta GIIQ):
    pip install reportlab
    python docs/manual/generar_manual.py

Salida: GIIQ/docs/manual/GIIQ_Manual_Instalacion.pdf
Usa las fuentes de Windows (Calibri y Consolas).
"""
from datetime import date
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import (CondPageBreak, KeepTogether, PageBreak, Paragraph,
                                Preformatted, SimpleDocTemplate, Spacer, Table, TableStyle)

SALIDA = Path(__file__).resolve().parent / "GIIQ_Manual_Instalacion.pdf"

# ---------------------------------------------------------------- Datos de portada
ESTUDIANTE = "[Nombre del estudiante] — [Carné]"
CARRERA = "[Carrera]"
VERSION = "0.2.0"
MESES = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto",
         "septiembre", "octubre", "noviembre", "diciembre"]
HOY = date.today()
FECHA = f"{HOY.day} de {MESES[HOY.month - 1]} de {HOY.year}"

# ---------------------------------------------------------------- Colores (marca GIIQ)
MARINO = colors.HexColor("#0A335F")    # azul marino de la marca
ACERO = colors.HexColor("#3474A2")     # mano
PALIDO = colors.HexColor("#DDEAFD")    # vidrio del matraz
CELESTE = colors.HexColor("#85DDEB")   # círculo
GRIS_TXT = colors.HexColor("#374151")
GRIS_SUAVE = colors.HexColor("#6B7280")
FONDO_CODIGO = colors.HexColor("#F3F5F8")
FILA_ALTERNA = colors.HexColor("#F4F8FD")
CODIGO_INLINE = "#9A3412"

# ---------------------------------------------------------------- Fuentes
FUENTES = Path("C:/Windows/Fonts")
pdfmetrics.registerFont(TTFont("Calibri", str(FUENTES / "calibri.ttf")))
pdfmetrics.registerFont(TTFont("Calibri-Bold", str(FUENTES / "calibrib.ttf")))
pdfmetrics.registerFont(TTFont("Calibri-Italic", str(FUENTES / "calibrii.ttf")))
pdfmetrics.registerFont(TTFont("Calibri-BoldItalic", str(FUENTES / "calibriz.ttf")))
pdfmetrics.registerFont(TTFont("Consolas", str(FUENTES / "consola.ttf")))
pdfmetrics.registerFont(TTFont("Consolas-Bold", str(FUENTES / "consolab.ttf")))
pdfmetrics.registerFontFamily("Calibri", normal="Calibri", bold="Calibri-Bold",
                              italic="Calibri-Italic", boldItalic="Calibri-BoldItalic")

# ---------------------------------------------------------------- Estilos
E = {
    "cuerpo": ParagraphStyle("cuerpo", fontName="Calibri", fontSize=10.5, leading=15,
                             textColor=GRIS_TXT, spaceAfter=6),
    "h1": ParagraphStyle("h1", fontName="Calibri-Bold", fontSize=20, leading=24,
                         textColor=MARINO, spaceBefore=4, spaceAfter=10),
    # keepWithNext: un subtítulo nunca queda solo al pie de la página.
    "h2": ParagraphStyle("h2", fontName="Calibri-Bold", fontSize=13.5, leading=17,
                         textColor=MARINO, spaceBefore=12, spaceAfter=6, keepWithNext=1),
    "celda": ParagraphStyle("celda", fontName="Calibri", fontSize=9.5, leading=12.5, textColor=GRIS_TXT),
    "celda_cab": ParagraphStyle("celda_cab", fontName="Calibri-Bold", fontSize=9.5, leading=12.5,
                                textColor=colors.white),
    "vineta": ParagraphStyle("vineta", fontName="Calibri", fontSize=10.5, leading=15, textColor=GRIS_TXT,
                             leftIndent=14, bulletIndent=3, spaceAfter=3),
    "codigo": ParagraphStyle("codigo", fontName="Consolas", fontSize=8.8, leading=11.6,
                             textColor=colors.HexColor("#1F2937")),
    "etiqueta": ParagraphStyle("etiqueta", fontName="Consolas-Bold", fontSize=7.5, leading=10,
                               textColor=ACERO),
}


def c(texto: str) -> str:
    """Código en línea (rojizo, Consolas)."""
    return f'<font name="Consolas" color="{CODIGO_INLINE}" size="9.5">{texto}</font>'


def P(texto: str):
    return Paragraph(texto, E["cuerpo"])


def H1(numero: str, titulo: str):
    return Paragraph(f'<font color="#3474A2">{numero}</font>&nbsp;&nbsp;{titulo}', E["h1"])


def H2(titulo: str):
    return Paragraph(titulo, E["h2"])


def vinetas(items: list[str]):
    return [Paragraph(t, E["vineta"], bulletText="•") for t in items]


def pasos(items: list[str], desde: int = 1):
    """Lista numerada; `desde` continúa una numeración cortada por un bloque de código."""
    return [Paragraph(t, E["vineta"], bulletText=f"{i}.") for i, t in enumerate(items, start=desde)]


def codigo(texto: str, etiqueta: str | None = None):
    """Bloque de comandos o de archivo: fondo gris y barra lateral azul."""
    filas = []
    if etiqueta:
        filas.append([Paragraph(etiqueta.upper(), E["etiqueta"])])
    # Las líneas que no caben se parten y siguen sangradas en la línea de abajo.
    filas.append([Preformatted(texto.strip("\n"), E["codigo"], maxLineLength=92, newLineChars="    ")])
    t = Table(filas, colWidths=[17 * cm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), FONDO_CODIGO),
        ("LINEBEFORE", (0, 0), (0, -1), 3, ACERO),
        ("LEFTPADDING", (0, 0), (-1, -1), 10),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    # Sin KeepTogether: así el subtítulo anterior (keepWithNext) puede amarrarse a este bloque.
    t.spaceAfter = 8
    return t


AVISOS = {
    "NOTA": (colors.HexColor("#E8F1FB"), ACERO),
    "OJO": (colors.HexColor("#FEF6E4"), colors.HexColor("#C2780C")),
    "IMPORTANTE": (colors.HexColor("#FDECEC"), colors.HexColor("#C81E1E")),
}


def aviso(tipo: str, titulo: str, texto: str):
    fondo, borde = AVISOS[tipo]
    cab = Paragraph(f'<font name="Calibri-Bold" color="{borde.hexval()}" size="8">{tipo}</font>'
                    f'<font color="#9CA3AF"> · </font>'
                    f'<font name="Calibri-Bold" color="#111827">{titulo}</font>', E["cuerpo"])
    t = Table([[cab], [Paragraph(texto, E["cuerpo"])]], colWidths=[17 * cm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), fondo),
        ("LINEBEFORE", (0, 0), (0, -1), 3, borde),
        ("LEFTPADDING", (0, 0), (-1, -1), 10),
        ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (0, 0), 7),
        ("BOTTOMPADDING", (0, -1), (-1, -1), 4),
        ("TOPPADDING", (0, 1), (-1, -1), 0),
    ]))
    t.spaceBefore, t.spaceAfter = 4, 10
    return t


def tabla(cabecera: list[str], filas: list[list[str]], anchos: list[float]):
    datos = [[Paragraph(h, E["celda_cab"]) for h in cabecera]]
    datos += [[Paragraph(str(v), E["celda"]) for v in fila] for fila in filas]
    t = Table(datos, colWidths=[a * cm for a in anchos], repeatRows=1)
    estilo = [
        ("BACKGROUND", (0, 0), (-1, 0), ACERO),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LINEBELOW", (0, 0), (-1, -1), 0.4, colors.HexColor("#E5E7EB")),
        ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]
    for i in range(1, len(datos)):
        if i % 2 == 0:
            estilo.append(("BACKGROUND", (0, i), (-1, i), FILA_ALTERNA))
    t.setStyle(TableStyle(estilo))
    t.spaceAfter = 10
    return t


# ---------------------------------------------------------------- Encabezado y pie
class LienzoNumerado(canvas.Canvas):
    """Dibuja encabezado y «Página X de N» (necesita conocer el total al final)."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._paginas = []

    def showPage(self):
        self._paginas.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        total = len(self._paginas)
        for estado in self._paginas:
            self.__dict__.update(estado)
            if self._pageNumber > 1:
                self._decorar(total)
            super().showPage()
        super().save()

    def _decorar(self, total: int):
        ancho, alto = letter
        self.saveState()
        self.setFont("Calibri-Bold", 10)
        self.setFillColor(MARINO)
        self.drawString(2 * cm, alto - 1.25 * cm, "GIIQ")
        self.setFont("Calibri", 9)
        self.setFillColor(GRIS_SUAVE)
        self.drawRightString(ancho - 2 * cm, alto - 1.25 * cm, "Manual de instalación")
        self.setStrokeColor(colors.HexColor("#D1D5DB"))
        self.setLineWidth(0.5)
        self.line(2 * cm, alto - 1.75 * cm, ancho - 2 * cm, alto - 1.75 * cm)
        self.setFont("Calibri", 9)
        self.setFillColor(GRIS_SUAVE)
        texto = f"Página {self._pageNumber} de {total}"
        self.drawCentredString(ancho / 2, 1.2 * cm, texto)
        self.restoreState()


# ---------------------------------------------------------------- Contenido
def portada():
    h = []
    h.append(Spacer(1, 1.2 * cm))
    h.append(Spacer(1, 2.5 * cm))
    h.append(Paragraph("GIIQ", ParagraphStyle("marca", fontName="Calibri-Bold", fontSize=64, leading=72,
                                              textColor=MARINO, alignment=TA_CENTER)))
    h.append(Spacer(1, 0.3 * cm))
    h.append(Paragraph("G E S T I Ó N &nbsp; I N T E G R A L &nbsp; D E L &nbsp; I N V E N T A R I O"
                       " &nbsp; D E &nbsp; Q U Í M I C A",
                       ParagraphStyle("sub", fontName="Calibri", fontSize=8.5, leading=12,
                                      textColor=GRIS_SUAVE, alignment=TA_CENTER)))
    h.append(Spacer(1, 0.5 * cm))
    linea = Table([[""]], colWidths=[17 * cm], rowHeights=[2])
    linea.setStyle(TableStyle([("LINEABOVE", (0, 0), (-1, 0), 1.2, MARINO)]))
    h.append(linea)
    h.append(Spacer(1, 0.4 * cm))
    h.append(Paragraph("Manual de instalación",
                       ParagraphStyle("man", fontName="Calibri-Bold", fontSize=22, leading=28,
                                      textColor=ACERO, alignment=TA_CENTER)))
    h.append(Paragraph("<i>Instalación en desarrollo · aplicación Android (APK) · despliegue en producción</i>",
                       ParagraphStyle("lema", fontName="Calibri", fontSize=10.5, leading=14,
                                      textColor=GRIS_SUAVE, alignment=TA_CENTER)))
    h.append(Spacer(1, 0.7 * cm))
    h.append(tabla(["Dato", "Detalle"], [
        ["Sistema", "GIIQ — Gestión Integral del Inventario de Química: reactivos y cristalería del laboratorio "
                    "(el código conserva el nombre técnico <b>LabQuim</b>)"],
        ["Estudiante", ESTUDIANTE],
        ["Carrera", CARRERA],
        ["Documento", "Manual de instalación · Examen de Grado"],
        ["Versión del sistema", VERSION],
        ["Fecha", FECHA],
    ], [5, 12]))
    h.append(PageBreak())
    return h


def contenido():
    h = [H1("", "Contenido")]
    h.append(tabla(["Capítulo", "Qué resuelve"], [
        ["1. El sistema en una página", "Qué es GIIQ, qué módulos trae y las formas de usarlo"],
        ["2. Arquitectura y tecnologías", "Cómo se reparten base de datos, API, interfaz web y app Android"],
        ["3. Requisitos previos", "Programas y versiones que hay que tener antes de empezar"],
        ["4. Obtener el código", "Copiar la carpeta del proyecto (ZIP o Git) y limpiarla"],
        ["5. Base de datos", "Crear la base «labquim» con todos los datos o desde los scripts"],
        ["6. Instalación del backend", "API .NET 10: conexión a MySQL, llave JWT y arranque"],
        ["7. Instalación del frontend", "React + Vite: dependencias, dirección de la API y arranque"],
        ["8. Primer acceso y datos iniciales", "Usuarios de arranque, datos de la institución y orden de carga"],
        ["9. Aplicación Android (APK)", "API en la red Wi-Fi, generar e instalar la APK"],
        ["10. Despliegue en producción", "Servidor, configuración de producción, HTTPS y comprobación"],
        ["11. Problemas frecuentes", "Síntoma, causa y solución de los fallos ya vistos"],
        ["12. Anexos", "Configuración, comandos útiles y estructura de carpetas"],
    ], [6.3, 10.7]))
    h.append(aviso("NOTA", "Cómo leer este manual",
                   "Los capítulos <b>3 a 8</b> instalan el sistema en una computadora de trabajo: es el camino "
                   "corto (MySQL más dos terminales). El capítulo <b>9</b> solo hace falta para la aplicación "
                   "del teléfono, y el <b>10</b> es el servidor real. Cada bloque gris es un comando tal como se "
                   "escribe en la terminal (PowerShell de Windows); las líneas que empiezan con " + c("#") +
                   " son comentarios y no se escriben."))
    h.append(PageBreak())
    return h


def cap1():
    h = [H1("1", "El sistema en una página")]
    h.append(P("GIIQ controla el inventario del laboratorio de química: los <b>reactivos</b> (se consumen, "
               "caducan y se controlan por lote, despachando primero el que vence antes — FEFO) y la "
               "<b>cristalería</b> (material de vidrio que se presta en las prácticas y se devuelve). Las "
               "existencias no se editan a mano: todo cambio entra como un movimiento (entrada, salida, "
               "ajuste, devolución, baja o reposición) registrado en un procedimiento almacenado y en la "
               "bitácora de auditoría."))
    h.append(H2("Qué trae instalado"))
    h.append(tabla(["Módulo", "Para qué sirve"], [
        ["Seguridad", "Inicio de sesión con contraseña cifrada (BCrypt), usuarios con nombres, apellidos y "
                      "código de estudiante/profesor, cinco roles y permisos editables por rol"],
        ["Catálogos", "Categorías, unidades, proveedores, ubicaciones, laboratorios, clases por año "
                      "(con sus profesores) y prácticas"],
        ["Reactivos", "Catálogo con ficha química y <b>rombo de seguridad NFPA 704</b> obligatorio; "
                      "existencias por lote y filtros por clasificación de riesgo"],
        ["Cristalería", "Catálogo del material de vidrio con su existencia y una <b>foto de referencia</b> "
                        "por pieza"],
        ["Inventario", "Existencias actuales, ingreso de stock por lote y alertas de stock mínimo"],
        ["Solicitudes de reactivos", "Profesor o estudiante pide → profesor avala (si la pidió un "
                                     "estudiante) → supervisor aprueba → bodega prepara y entrega (se cierra)"],
        ["Solicitudes de cristalería", "El mismo flujo, pero queda «entregada» hasta que bodega registra "
                                       "la devolución, indicando las piezas quebradas y quién las quebró"],
        ["Bajas y cuentas de estudiantes", "Bodega da de baja la cristalería quebrada, extraviada o deteriorada; "
                                           "la pieza se carga a la cuenta del estudiante responsable hasta que la "
                                           "<b>reponga físicamente</b>. Sin deuda se imprime la <b>constancia de "
                                           "solvencia</b> para culminar estudios"],
        ["Notificaciones", "Campana en la barra superior: avisa a cada usuario lo que le toca o le afecta "
                           "(solicitud nueva, avalada, aprobada, rechazada con su motivo, lista, entregada, "
                           "devuelta, piezas cargadas o repuestas)"],
        ["Reportes", "Existencias, próximos a vencer, consumo por laboratorio y kardex: tablas con orden, "
                     "filtros y búsqueda, detalle lateral al tocar una fila y exportación a Excel"],
        ["Dashboard", "Indicadores, alertas que requieren acción y gráficos del estado del inventario"],
        ["Respaldos", "Copia y restauración de la base de datos desde la propia interfaz"],
    ], [4.3, 12.7]))
    h.append(H2("Dos maneras de usarlo"))
    h += vinetas([
        "<b>En el navegador</b> — la forma normal. Basta la base de datos, el backend y el frontend "
        "(capítulos 5 a 7).",
        "<b>Como aplicación de Android</b> — una APK instalable, generada con Capacitor a partir de la misma "
        "interfaz (capítulo 9).",
    ])
    h.append(aviso("OJO", "El servidor siempre es el mismo",
                   "La APK no lleva la base de datos dentro: es la misma interfaz empaquetada y habla con la API "
                   "por la red. Sin la API corriendo y alcanzable desde el teléfono, la aplicación no muestra datos."))
    h.append(PageBreak())
    return h


def cap2():
    h = [H1("2", "Arquitectura y tecnologías")]
    h.append(P("GIIQ está separado en tres piezas independientes: la <b>base de datos</b> guarda los datos y "
               "contiene toda la lógica del negocio en procedimientos almacenados; la <b>API</b> solo valida, "
               "autentica y llama a esos procedimientos; y la <b>interfaz</b> solo consume la API. Por eso pueden "
               "vivir en máquinas distintas."))
    h.append(tabla(["Pieza", "Tecnología", "Qué hace"], [
        ["Base de datos", "MySQL 8 (utf8mb4)", "27 tablas y 44 procedimientos almacenados: inventario por "
                                               "lote, flujo de solicitudes, bajas y cuentas, notificaciones, "
                                               "auditoría"],
        ["Backend (API)", ".NET 10 · ASP.NET Core Web API", "Rutas REST " + c("/api/*") + ", permisos por "
                                                           "política, documentación Swagger"],
        ["Acceso a datos", "Dapper + MySqlConnector", "Llama a los procedimientos y a consultas de lectura"],
        ["Autenticación", "JWT (tokens Bearer) + BCrypt", "Al iniciar sesión entrega un token con el rol y los "
                                                         "permisos; la interfaz lo envía en cada petición"],
        ["Excel", "ClosedXML", "Genera los reportes, bajas y cuentas exportables"],
        ["Frontend", "React 19 + Vite 6 + TypeScript", "Toda la interfaz en una sola página (SPA)"],
        ["Estilos", "Tailwind CSS 4 + Flowbite React", "Componentes y paleta de la marca GIIQ"],
        ["Datos y gráficos", "TanStack Query · axios · Recharts", "Caché de consultas, llamadas a la API y "
                                                                 "gráficos del dashboard"],
        ["Tablas de reportes", "AG Grid Community 36", "Orden, filtros por columna, búsqueda y paginación "
                                                       "en los reportes (versión gratuita, sin licencia)"],
        ["App Android", "Capacitor 8", "Empaqueta la interfaz como APK"],
    ], [3.3, 5.2, 8.5]))
    h.append(H2("Cómo se hablan las piezas"))
    h.append(codigo(r"""
   [ Navegador ]                      [ App Android (APK) ]
  localhost:5173                       http://IP-de-la-PC
        |                                      |
        +------------------+-------------------+
                           |  HTTP/JSON + token Bearer (JWT)
                           v
             +-----------------------------+
             |  API .NET 10 (puerto 5099)  |
             |  rutas /api/*  · /swagger   |
             +-----------------------------+
                           |  Dapper -> procedimientos almacenados
              +------------+-------------+
              |                          |
         [ MySQL 8 ]             [ backups/*.sql ]
       base «labquim»         copias generadas con mysqldump
""", "Mapa de despliegue"))
    h.append(H2("Decisiones que conviene conocer antes de instalar"))
    h += vinetas([
        "<b>La lógica vive en la base de datos.</b> Crear una solicitud, preparar por FEFO, devolver "
        "cristalería o validar el rombo NFPA lo hacen procedimientos almacenados, de forma transaccional. "
        "Por eso la base se crea con scripts y no con migraciones de código.",
        "<b>Las notificaciones también nacen en la base.</b> Cada procedimiento del flujo (crear, avalar, "
        "aprobar, rechazar, preparar, entregar, devolver, dar de baja, reponer) escribe los avisos en la misma "
        "transacción; la interfaz consulta la campana cada 30 segundos.",
        "<b>Las fotos de la cristalería se guardan en la base</b> (columna MEDIUMBLOB, reducidas a 1000 px en el "
        "navegador antes de subirlas). Así un respaldo de la base lleva también las fotos, sin carpetas aparte.",
        "<b>Permisos dentro del token.</b> Al cambiar los permisos de un rol, el usuario debe cerrar sesión y "
        "volver a entrar para recibirlos.",
        "<b>Zona horaria fija.</b> La API fija " + c("time_zone = '-06:00'") + " (Nicaragua) en cada conexión; "
        "para eso la cadena de conexión lleva " + c("AllowUserVariables=true") + ".",
        "<b>Respaldos con las herramientas de MySQL.</b> La API ejecuta " + c("mysqldump.exe") + " y " +
        c("mysql.exe") + ", así que la máquina de la API necesita esos programas (capítulo 10).",
    ])
    h.append(PageBreak())
    return h


def cap3():
    h = [H1("3", "Requisitos previos")]
    h.append(H2("3.1  Para instalar y usar el sistema (obligatorio)"))
    h.append(tabla(["Programa", "Versión", "Para qué", "Cómo obtenerlo"], [
        ["MySQL Server", "8.0", "Base de datos (incluye mysql.exe y mysqldump.exe)",
         "dev.mysql.com/downloads/installer (incluye MySQL Workbench)"],
        [".NET SDK", "10", "Compilar y ejecutar la API", "dotnet.microsoft.com/download/dotnet/10.0"],
        ["Node.js", "20 o superior (probado con 24)", "Instalar y ejecutar el frontend", "nodejs.org (versión LTS)"],
        ["Git", "Cualquiera reciente", "Solo si se trae el código con Git", "git-scm.com"],
    ], [3.0, 3.4, 5.1, 5.5]))
    h.append(P("Para comprobar que quedaron instalados, en una terminal nueva:"))
    h.append(codigo("""
dotnet --version
node --version
npm --version
"""))
    h.append(H2("3.2  Solo si se va a generar la APK de Android"))
    h.append(tabla(["Programa", "Detalle"], [
        ["Java (JDK)", "21. Por ejemplo Eclipse Temurin (adoptium.net). La variable " + c("JAVA_HOME") +
         " debe apuntar a su carpeta."],
        ["Android Studio", "Trae el SDK de Android y sus herramientas de compilación."],
        ["SDK de Android", "Plataforma 36 (Android 16). La APK funciona en teléfonos desde Android 7.0. "
                           "La variable " + c("ANDROID_HOME") + " debe apuntar al SDK, normalmente " +
         c("C:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\Sdk") + "."],
    ], [3.5, 13.5]))
    h.append(aviso("NOTA", "Gradle se descarga solo",
                   "La primera compilación de la APK descarga Gradle y las dependencias de Android "
                   "(varios cientos de MB) y tarda varios minutos; las siguientes son mucho más rápidas."))
    h.append(PageBreak())
    return h


def cap4():
    h = [H1("4", "Obtener el código")]
    h.append(P("Todo lo necesario para instalar y hacer funcionar el sistema está en una sola carpeta, " +
               c("GIIQ") + ": dentro están " + c("database") + ", " + c("backend") + ", " + c("frontend") +
               " (con el proyecto Android) y " + c("docs") + " (este manual). Es lo único que hay que llevar "
               "a la otra computadora."))
    h.append(H2("Método A — copiar la carpeta o descomprimir el ZIP"))
    h += pasos([
        "Copiar la carpeta " + c("GIIQ") + " (o descomprimir el ZIP) en una ruta sin caracteres raros, por "
        "ejemplo " + c("C:\\Proyectos\\GIIQ\\") + ".",
        "Verificar que dentro estén " + c("database\\") + ", " + c("backend\\LabQuim.Api\\") + " y " +
        c("frontend\\") + " directamente (no dentro de una subcarpeta extra).",
    ])
    h.append(H2("Método B — con Git"))
    h.append(codigo(r"""
git clone URL_DEL_REPOSITORIO giiq-repositorio
# La aplicación es la carpeta GIIQ del repositorio; se puede usar ahí mismo o copiarla aparte
Copy-Item -Recurse giiq-repositorio\GIIQ C:\Proyectos\GIIQ
cd C:\Proyectos\GIIQ
"""))
    h.append(P("El repositorio guarda además, fuera de " + c("GIIQ") + ", documentos de análisis del proyecto "
               "(carpeta " + c("documentacion") + "); no se necesitan para instalar."))
    h.append(H2("Limpiar lo que viene de otra computadora"))
    h.append(P("Si la carpeta se copió de otra máquina, conviene borrar estas carpetas generadas; se vuelven a "
               "crear solas al compilar:"))
    h.append(codigo(r"""
# Desde la carpeta GIIQ
Remove-Item -Recurse -Force frontend\node_modules, frontend\dist, `
  backend\LabQuim.Api\bin, backend\LabQuim.Api\obj -ErrorAction SilentlyContinue
"""))
    h.append(aviso("IMPORTANTE", "Copiar la carpeta NO copia la base de datos",
                   "Los datos de MySQL viven en el directorio interno de MySQL, no en el proyecto. En la "
                   "computadora nueva hay que crear la base con el capítulo 5; si no, la API arranca pero no "
                   "puede trabajar."))
    h.append(PageBreak())
    return h


def cap5():
    mysql = '$mysql = "C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe"'
    h = [H1("5", "Base de datos")]
    h.append(P("Todo este capítulo se hace en una terminal abierta en la carpeta " + c("database\\") +
               ". Hay dos caminos: la base completa con datos (A) o la base vacía desde los scripts (B)."))
    h.append(aviso("IMPORTANTE", "Siempre con " + c("--default-character-set=utf8mb4"),
                   "Los nombres de reactivos y de personas llevan tildes y ñ. Si los scripts se cargan sin ese "
                   "parámetro, quedan guardados corruptos (por ejemplo «Ã¡cido» en vez de «ácido») y hay que "
                   "volver a cargarlos."))
    h.append(H2("5.1  Opción A (recomendada) — base completa en un solo archivo"))
    h.append(P(c("labquim_completo.sql") + " contiene la base entera: estructura, datos, usuarios con sus "
               "contraseñas y procedimientos. Crea la base " + c("labquim") + " desde cero (la borra si ya "
               "existía):"))
    h.append(codigo(f"""
cd C:\\Proyectos\\GIIQ\\database
{mysql}
& $mysql --default-character-set=utf8mb4 -u root -p -e "source labquim_completo.sql;"
"""))
    h.append(P("Pide la contraseña de " + c("root") + " de MySQL. Con esto ya está la base; se puede saltar "
               "la opción B."))
    h.append(H2("5.2  Opción B — base vacía desde los scripts"))
    h.append(P("Para empezar sin datos de ejemplo (o reconstruir paso a paso). El orden importa:"))
    h.append(codigo(f"""
{mysql}
& $mysql --default-character-set=utf8mb4 -u root -p -e "source 01_schema.sql; source 02_seeds.sql; source 03_procedures.sql; source 05_procedures_articulos.sql; source 06_procedures_usuarios.sql; source 07_procedures_catalogos.sql;"
"""))
    h.append(tabla(["Script", "Qué crea"], [
        ["01_schema.sql", "La base " + c("labquim") + " y sus 27 tablas"],
        ["02_seeds.sql", "Roles, permisos (incluidos los de bajas y cuentas), catálogos base (unidades, "
                         "categorías, ubicaciones) y el usuario " + c("admin")],
        ["03_procedures.sql", "Inventario y flujo de solicitudes (crear, avalar, aprobar, preparar, entregar, "
                              "devolver), bajas, reposiciones, constancias de solvencia y notificaciones"],
        ["05_procedures_articulos.sql", "Alta y edición de reactivos y cristalería, con validación del rombo NFPA"],
        ["06_procedures_usuarios.sql", "Usuarios (nombres, apellidos, código único) y permisos por rol"],
        ["07_procedures_catalogos.sql", "Catálogos, clases (con sus profesores) y prácticas"],
        ["04_smoke_test.sql (opcional)", "Datos de demostración y una prueba de los dos flujos de solicitud"],
    ], [5.6, 11.4]))
    h.append(P("Para cargar además los datos de demostración:"))
    h.append(codigo("""
& $mysql --default-character-set=utf8mb4 -u root -p labquim -e "source 04_smoke_test.sql;"
"""))
    h.append(aviso("NOTA", "Los scripts 08 a 16 son solo para bases antiguas",
                   "Los archivos " + c("08_migracion_*.sql") + " a " + c("16_migracion_*.sql") + " actualizan "
                   "una base creada con una versión anterior del sistema sin perder sus datos. En una "
                   "instalación nueva <b>no</b> se ejecutan: los scripts 01 a 07 ya incluyen esos cambios."))
    h.append(H2("Actualizar una base de una versión anterior"))
    h.append(P("Si ya hay una base " + c("labquim") + " en uso, se aplican en orden solo las migraciones que le "
               "falten (cada script indica al inicio qué agrega). Las tres más recientes son:"))
    h.append(tabla(["Script", "Qué agrega"], [
        ["14_migracion_imagenes_cristaleria.sql", "Tabla de fotos de referencia de la cristalería"],
        ["15_migracion_bajas_cuentas.sql", "Bajas, cuentas de estudiantes, reposiciones, constancias de solvencia y "
                                          "sus permisos; los movimientos BAJA y REPOSICION"],
        ["16_migracion_notificaciones.sql", "Tabla de notificaciones"],
    ], [6.6, 10.4]))
    h.append(codigo("""
& $mysql --default-character-set=utf8mb4 -u root -p labquim -e "source 14_migracion_imagenes_cristaleria.sql; source 15_migracion_bajas_cuentas.sql; source 16_migracion_notificaciones.sql;"
& $mysql --default-character-set=utf8mb4 -u root -p -e "source 03_procedures.sql;"
"""))
    h.append(P("La segunda línea vuelve a cargar los procedimientos, que en esta versión cambiaron (la devolución "
               "registra piezas quebradas y todo el flujo genera notificaciones). Antes de migrar conviene sacar "
               "un respaldo."))
    h.append(H2("5.3  Comprobar"))
    h.append(codigo("""
& $mysql -u root -p labquim -e "SELECT COUNT(*) AS tablas FROM information_schema.tables WHERE table_schema='labquim';"
"""))
    h.append(P("Debe responder <b>27</b>."))
    h.append(PageBreak())
    return h


def cap6():
    h = [H1("6", "Instalación del backend (API .NET)")]
    h.append(P("Todo este capítulo se hace dentro de " + c("backend\\LabQuim.Api\\") + "."))
    h.append(H2("6.1  Crear la configuración local"))
    h.append(P("La API lee la conexión a MySQL y la llave de los tokens de " + c("appsettings.Development.json") +
               ". Ese archivo contiene contraseñas, por eso <b>no se sube al repositorio</b>: si no existe "
               "(por ejemplo al clonar con Git), hay que crearlo con este contenido:"))
    h.append(codigo("""
{
  "Logging": {
    "LogLevel": { "Default": "Information", "Microsoft.AspNetCore": "Information" }
  },
  "ConnectionStrings": {
    "Default": "Server=localhost;Port=3306;Database=labquim;User Id=root;Password=TU_CONTRASEÑA;AllowUserVariables=true;"
  },
  "Jwt": {
    "Issuer": "LabQuim.Api",
    "Audience": "LabQuim.Client",
    "Key": "una-clave-larga-y-secreta-de-al-menos-32-caracteres",
    "ExpMinutes": 480
  }
}
""", "backend/LabQuim.Api/appsettings.Development.json"))
    h += vinetas([
        "Reemplazar " + c("TU_CONTRASEÑA") + " por la contraseña de " + c("root") + " de MySQL de esa "
        "computadora.",
        "No quitar " + c("AllowUserVariables=true") + ": la API lo necesita para fijar la zona horaria.",
        "La llave JWT debe tener al menos 32 caracteres; si se cambia, las sesiones abiertas se cierran.",
    ])
    h.append(H2("6.2  Configuración general"))
    h.append(P(c("appsettings.json") + " ya viene listo. Solo hay que revisar dos cosas:"))
    h.append(codigo(r"""
"Cors": {
  "Origins": [ "http://localhost:5173", "http://localhost", "https://localhost", "capacitor://localhost" ]
},
"Backup": {
  "Directory": "backups",
  "MySqlBinDir": "C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin"
}
""", "backend/LabQuim.Api/appsettings.json (fragmento)"))
    h += vinetas([
        c("Cors:Origins") + ": desde dónde se permite usar la API. El primero es el frontend web; los "
        "demás son la app Android.",
        c("Backup:MySqlBinDir") + ": carpeta donde están " + c("mysqldump.exe") + " y " + c("mysql.exe") +
        ". Si MySQL se instaló en otra ruta o versión, hay que corregirla o los respaldos fallarán.",
    ])
    h.append(H2("6.3  Levantar la API"))
    h.append(codigo(r"""
cd C:\Proyectos\GIIQ\backend\LabQuim.Api
dotnet run

# Para que un teléfono de la misma red Wi-Fi pueda alcanzarla (capítulo 9):
dotnet run --launch-profile red-local
"""))
    h.append(P("La primera vez restaura los paquetes y compila. Queda escuchando en <b>http://localhost:5099</b> "
               "y la documentación interactiva de la API está en <b>http://localhost:5099/swagger</b>. "
               "Hay que dejar esta terminal abierta."))
    h.append(aviso("NOTA", "Contraseñas de desarrollo automáticas",
                   "En modo desarrollo, al arrancar, la API asigna la contraseña " + c("Clave123") +
                   " a los usuarios cuya contraseña es un marcador inválido (los que crean los scripts 02 y 04). "
                   "Esto <b>nunca</b> ocurre en producción."))
    h.append(PageBreak())
    return h


def cap7():
    h = [H1("7", "Instalación del frontend (React + Vite)")]
    h.append(P("Ahora en la carpeta " + c("frontend\\") + ", en una <b>segunda terminal</b> (la primera "
               "sigue con la API corriendo)."))
    h.append(H2("7.1  Instalar las dependencias"))
    h.append(codigo(r"""
cd C:\Proyectos\GIIQ\frontend
npm install
"""))
    h.append(P("Descarga React, Flowbite, Capacitor y el resto en " + c("node_modules\\") +
               ", que no viene en el proyecto."))
    h.append(H2("7.2  Indicar dónde está la API"))
    h.append(P("El archivo " + c("frontend\\.env.development") + " ya viene con la dirección de la API local:"))
    h.append(codigo("VITE_API_URL=http://localhost:5099", "frontend/.env.development"))
    h.append(P("Solo se cambia si la API corre en otro puerto u otra máquina."))
    h.append(H2("7.3  Arrancar en modo desarrollo"))
    h.append(codigo("npm run dev"))
    h.append(P("La aplicación queda en <b>http://localhost:5173</b>. La primera vez que se abre una pantalla "
               "puede tardar un poco mientras Vite la prepara."))
    h.append(H2("7.4  Generar la versión de producción"))
    h.append(codigo("""
npm run build

# Para revisar el resultado antes de publicarlo
npm run preview
"""))
    h.append(P("Deja los archivos estáticos en " + c("frontend\\dist\\") + ". Eso es lo que se publica en el "
               "servidor (capítulo 10) y lo que Capacitor mete dentro de la APK (capítulo 9)."))
    h.append(PageBreak())
    return h


def cap8():
    h = [H1("8", "Primer acceso y datos iniciales")]
    h.append(H2("8.1  Usuarios de arranque"))
    h.append(P("Con la API corriendo en desarrollo, todos estos usuarios entran con la contraseña " +
               c("Clave123") + ":"))
    h.append(tabla(["Usuario", "Rol", "Qué puede hacer"], [
        ["admin", "Administrador", "Todo: usuarios, roles y permisos, catálogos, inventario, reportes y respaldos"],
        ["super", "Supervisor", "Aprobar o rechazar solicitudes; ver inventario, reportes y cuentas de estudiantes"],
        ["profe", "Profesor", "Crear solicitudes y avalar las de sus estudiantes"],
        ["bode", "Bodega", "Preparar, entregar y recibir devoluciones; ingresar stock; editar artículos; registrar "
                           "bajas y reposiciones; emitir constancias de solvencia"],
        ["ana", "Estudiante", "Crear solicitudes (las avala su profesor), consultar existencias y ver su propia "
                              "cuenta de cristalería (<b>Mi cuenta</b>)"],
    ], [2.5, 3.2, 11.3]))
    h.append(P("Con la opción B del capítulo 5 solo existe " + c("admin") + " (más " + c("super") + ", " +
               c("profe") + " y " + c("bode") + " si se cargó el script 04); el resto se crea desde " +
               "<b>Usuarios</b>."))
    h.append(aviso("IMPORTANTE", "Cambiar esas contraseñas antes de usarlo de verdad",
                   "Son contraseñas de demostración, iguales para todos y publicadas en este manual. Al instalar "
                   "el sistema en el laboratorio hay que asignar contraseñas propias desde <b>Usuarios → Clave</b>, "
                   "o crear cuentas nuevas y desactivar estas. Los usuarios no se borran: se desactivan, para que "
                   "los movimientos sigan apuntando a quien los registró."))
    h.append(H2("8.2  Datos de la institución para la constancia"))
    h.append(P("La constancia de solvencia se imprime con el nombre de la institución y la ciudad. Vienen como "
               "marcadores entre corchetes y se completan una sola vez en " + c("frontend\\src\\institucion.ts") +
               " antes de compilar el frontend:"))
    h.append(codigo("""
export const INSTITUCION = {
  nombre: '[Nombre de la institución]',
  dependencia: 'Laboratorio de Química',
  ciudad: '[Ciudad]',
  cargoFirma: 'Responsable de bodega del laboratorio',
}
""", "frontend/src/institucion.ts"))
    h.append(P("Si se dejan así, la constancia sale con los corchetes. Después de cambiarlo hay que volver a "
               "generar el frontend (" + c("npm run build") + ") y, si se usa, la APK."))
    h.append(H2("8.3  Orden para cargar el laboratorio"))
    h.append(P("Varias pantallas dependen de otras, así que conviene cargar los datos en este orden:"))
    h += pasos([
        "<b>Catálogos → Categorías, Unidades, Proveedores, Ubicaciones y Laboratorios.</b>",
        "<b>Usuarios:</b> profesores y estudiantes con su <b>código único</b> (obligatorio para esos dos roles). "
        "Nombres y apellidos se guardan en mayúsculas y solo admiten letras.",
        "<b>Catálogos → Clases:</b> cada clase con su <b>año</b> (primero a quinto) y los profesores que la imparten.",
        "<b>Catálogos → Prácticas:</b> cada práctica pertenece a una clase y se realiza en un laboratorio.",
        "<b>Reactivos:</b> cada uno con su ficha y su <b>rombo de seguridad NFPA 704</b> (salud, inflamabilidad "
        "y reactividad de 0 a 4, obligatorios; riesgo específico opcional).",
        "<b>Cristalería:</b> el material de vidrio, con una foto de referencia opcional (JPG, PNG o WebP de "
        "hasta 2 MB; el sistema la reduce antes de guardarla).",
        "<b>Ingresar stock</b> (botón «Ingresar» en cada artículo): crea los lotes, con vencimiento en los reactivos.",
    ])
    h.append(aviso("OJO", "Sin clases y prácticas no se pueden crear solicitudes",
                   "Al pedir material se elige profesor → clase → práctica. Si un profesor no tiene clases "
                   "asignadas, el formulario lo indica y no deja continuar."))
    h.append(H2("8.4  Comprobar que todo quedó bien"))
    h += vinetas([
        "Entrar con " + c("admin") + " y revisar que el menú lateral muestre todos los módulos.",
        "Abrir <b>Reactivos</b> y <b>Cristalería</b>: deben listar los artículos con su existencia.",
        "Crear una solicitud de prueba y llevarla hasta «Cerrada» con los roles correspondientes. En cada paso, "
        "la campana del siguiente rol debe mostrar el aviso (tarda hasta 30 segundos).",
        "En una devolución de cristalería, marcar una pieza quebrada: debe aparecer en <b>Bajas</b> y en la cuenta "
        "del estudiante; al registrar la reposición, la cuenta queda saldada y se puede imprimir la constancia.",
        "Abrir <b>Respaldos</b> y crear uno: si falla, revisar " + c("Backup:MySqlBinDir") + " (capítulo 6.2).",
        "Exportar a Excel un reporte, las <b>Bajas</b> y las <b>Cuentas de estudiantes</b>.",
    ])
    h.append(PageBreak())
    return h


def cap9():
    h = [H1("9", "Aplicación Android (APK)")]
    h.append(P("La APK es la misma interfaz empaquetada con <b>Capacitor</b>. El proyecto de Android ya está "
               "generado en " + c("frontend\\android\\") + "; la aplicación se identifica como " +
               c("com.bioq.inventario") + " y se llama <b>GIIQ</b> en el teléfono."))
    h.append(H2("9.1  Hacer que el teléfono alcance la API"))
    h.append(P("El " + c("localhost") + " del teléfono es el propio teléfono, así que la APK necesita la "
               "<b>dirección IP de la computadora</b> en la red Wi-Fi."))
    h += pasos([
        "Averiguar la IP de la computadora con " + c("ipconfig") + " (línea «Dirección IPv4» del adaptador "
        "Wi-Fi), por ejemplo " + c("192.168.1.239") + ".",
        "Escribirla en " + c("frontend\\.env.movil") + ":",
    ])
    h.append(codigo("VITE_API_URL=http://192.168.1.239:5099", "frontend/.env.movil"))
    h += pasos([
        "Permitir el puerto 5099 en el firewall de Windows (una sola vez, en PowerShell <b>como "
        "administrador</b>):",
    ], desde=3)
    h.append(codigo("""
New-NetFirewallRule -DisplayName "GIIQ API 5099" -Direction Inbound -Protocol TCP -LocalPort 5099 -Action Allow -Profile Private
"""))
    h += pasos([
        "Levantar la API escuchando en la red: " + c("dotnet run --launch-profile red-local") + ".",
    ], desde=4)
    h.append(aviso("OJO", "La red Wi-Fi debe estar marcada como «privada»",
                   "La regla anterior aplica a redes privadas. Si Windows tiene la red Wi-Fi como pública, el "
                   "teléfono no llega a la API aunque todo lo demás esté bien. Se cambia en Configuración → "
                   "Red e Internet → Wi-Fi → (la red) → Tipo de perfil de red."))
    h.append(H2("9.2  Generar la APK de prueba (debug)"))
    h.append(codigo(r"""
cd C:\Proyectos\GIIQ\frontend
npm run apk
"""))
    h.append(P("El comando compila la interfaz con la dirección de " + c(".env.movil") + ", la copia al proyecto "
               "de Android y ejecuta Gradle. Al terminar debe mostrar <b>BUILD SUCCESSFUL</b> y el archivo "
               "queda en:"))
    h.append(codigo(r"frontend\android\app\build\outputs\apk\debug\app-debug.apk"))
    h.append(aviso("OJO", "Leer siempre el final de la salida",
                   "Si falta " + c("JAVA_HOME") + " o " + c("ANDROID_HOME") + ", Gradle falla antes de compilar y "
                   "en la carpeta de salida sigue estando la APK de la vez anterior: parece que «no tomó los "
                   "cambios», cuando en realidad nunca compiló."))
    h.append(H2("9.3  Instalarla en el teléfono"))
    h += pasos([
        "Copiar " + c("app-debug.apk") + " al teléfono (cable, correo o nube) y abrirlo.",
        "Android pedirá permitir «instalar apps de fuentes desconocidas»: aceptar.",
        "Con el teléfono en la <b>misma red Wi-Fi</b> que la computadora y la API corriendo, abrir GIIQ "
        "e iniciar sesión.",
    ])
    h.append(H2("9.4  Ícono y pantalla de inicio"))
    h.append(P("Salen de " + c("icon-only.png") + ", " + c("icon-foreground.png") + ", " +
               c("icon-background.png") + " y " + c("splash.png") + " en " + c("frontend\\assets-app\\") +
               ". En esta versión todavía tienen el logo anterior: para usar el de GIIQ se reemplazan esos cuatro "
               "archivos (conviene una versión del logo <b>solo con el emblema</b>, sin letras, porque el ícono es "
               "pequeño y redondo) y se regeneran con:"))
    h.append(codigo("""
npx @capacitor/assets generate --android --assetPath assets-app --iconBackgroundColor "#ffffff" --splashBackgroundColor "#ffffff"
"""))
    h.append(H2("9.5  APK firmada para distribuir (release)"))
    h.append(P("La APK de prueba basta para usarla y para la defensa. Para publicarla en Play Store o "
               "distribuirla oficialmente se firma con un certificado propio:"))
    h.append(codigo(r"""
# 1. Crear el certificado (keytool viene con el JDK)
keytool -genkeypair -v -keystore giiq.jks -keyalg RSA -keysize 2048 -validity 10000 -alias giiq

# 2. Abrir el proyecto en Android Studio
npx cap open android
# Menú Build > Generate Signed App Bundle / APK > APK > elegir giiq.jks > release
"""))
    h.append(aviso("IMPORTANTE", "Si se pierde el certificado, no hay actualizaciones",
                   "Android exige que todas las versiones de una aplicación estén firmadas con el mismo "
                   "certificado. El archivo " + c(".jks") + " y sus contraseñas se guardan fuera del proyecto, "
                   "con copia, y no se suben al repositorio."))
    h.append(H2("9.6  Qué no funciona dentro de la APK"))
    h += vinetas([
        "<b>Exportar a Excel, descargar respaldos e imprimir la constancia de solvencia</b>: usan la descarga "
        "y la impresión del navegador, que el WebView de Android no ejecuta. Se hacen desde la versión web.",
        "Al cambiar de red Wi-Fi cambia la IP de la computadora: hay que editar " + c(".env.movil") +
        " y volver a generar la APK.",
    ])
    h.append(PageBreak())
    return h


def cap10():
    h = [H1("10", "Despliegue en producción")]
    h.append(P("Publicar el sistema es poner tres cosas en un servidor: la base de datos MySQL, la API y los "
               "archivos estáticos del frontend. El servidor debe ser una máquina donde se puedan ejecutar "
               "programas (un VPS o un equipo del laboratorio)."))
    h.append(aviso("IMPORTANTE", "Los respaldos necesitan mysqldump y mysql en el servidor",
                   "El módulo de respaldos y restauración ejecuta esas dos herramientas. Muchos hostings "
                   "compartidos no lo permiten; si ese es el caso, el resto del sistema funciona, pero los "
                   "respaldos desde la interfaz no."))
    h.append(H2("10.1  Base de datos"))
    h.append(P("Igual que en el capítulo 5 (opción A para llevar los datos actuales, opción B para empezar "
               "vacío). En producción conviene crear un usuario de MySQL propio en vez de usar " + c("root") + "."))
    h.append(aviso("OJO", "La contraseña del administrador en una base nueva",
                   "En producción la API no asigna " + c("Clave123") + ". Con la opción B el usuario " + c("admin") +
                   " queda sin una contraseña válida. Solución: arrancar la API una vez en desarrollo contra esa "
                   "base (asigna " + c("Clave123") + "), entrar y cambiar la contraseña desde Usuarios; o usar la "
                   "opción A, que trae las contraseñas actuales."))
    h.append(H2("10.2  Publicar la API"))
    h.append(codigo(r"""
cd C:\Proyectos\GIIQ\backend\LabQuim.Api
dotnet publish -c Release -o C:\publicar\giiq-api
"""))
    h.append(P("En la carpeta publicada se crea " + c("appsettings.Production.json") + " con los valores reales "
               "(tampoco se sube al repositorio):"))
    h.append(codigo("""
{
  "ConnectionStrings": {
    "Default": "Server=localhost;Port=3306;Database=labquim;User Id=giiq;Password=UNA_CONTRASEÑA_LARGA;AllowUserVariables=true;"
  },
  "Jwt": { "Key": "otra-clave-larga-y-secreta-solo-para-produccion-32+" },
  "Cors": { "Origins": [ "https://giiq.midominio.com" ] },
  "Backup": { "MySqlBinDir": "C:\\\\Program Files\\\\MySQL\\\\MySQL Server 8.0\\\\bin" }
}
""", "appsettings.Production.json"))
    h.append(P("Y se ejecuta en modo producción (o se aloja en IIS con el «ASP.NET Core Hosting Bundle» de .NET 10):"))
    h.append(codigo(r"""
$env:ASPNETCORE_ENVIRONMENT = "Production"
cd C:\publicar\giiq-api
dotnet LabQuim.Api.dll --urls http://0.0.0.0:5099
"""))
    h.append(aviso("OJO", "Cors:Origins es imprescindible en producción",
                   "Debe contener la dirección exacta desde donde se abre el frontend (y, si se usa la APK, " +
                   c("http://localhost") + "). Si falta, el navegador bloquea las peticiones y todo parece caído "
                   "sin un error claro. En producción tampoco se publica Swagger."))
    h.append(H2("10.3  Publicar el frontend"))
    h.append(codigo(r"""
cd C:\Proyectos\GIIQ\frontend
Set-Content .env.production "VITE_API_URL=https://api.midominio.com"
npm run build
# Se publica el contenido de frontend\dist en el servidor web
"""))
    h.append(P("Es una aplicación de una sola página: el servidor web debe responder " + c("index.html") +
               " para cualquier ruta que no sea un archivo (por ejemplo " + c("/reactivos") + "). En IIS se "
               "hace con una regla de reescritura en " + c("web.config") + ":"))
    h.append(codigo("""
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="SPA" stopProcessing="true">
          <match url=".*" />
          <conditions>
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
""", "frontend/dist/web.config (IIS)"))
    h.append(H2("10.4  HTTPS"))
    h.append(P("Las contraseñas y el token viajan en cada petición: en un servidor real la API y el frontend "
               "deben servirse por <b>https://</b>, con un certificado válido (por ejemplo Let's Encrypt)."))
    h.append(H2("10.5  Lista de comprobación antes de darlo por publicado"))
    h.append(tabla(["Comprobar", "Cómo"], [
        ["La API responde", "Abrir https://api.midominio.com/api/catalogos/categorias: debe pedir autenticación (401)"],
        ["El frontend carga y se puede entrar", "Abrir el dominio e iniciar sesión con admin"],
        ["El certificado es válido", "El candado del navegador, sin advertencias"],
        ["Los respaldos funcionan", "Crear uno desde Respaldos y descargarlo"],
        ["La restauración funciona", "Probarla en una copia, nunca por primera vez en producción"],
        ["Las contraseñas de demostración ya no existen", "Usuarios con contraseñas nuevas o desactivados"],
        ["La llave JWT es propia", "Distinta a la de desarrollo"],
        ["La constancia lleva los datos reales", "Imprimir una de prueba: sin corchetes en el nombre ni la ciudad"],
        ["Las notificaciones llegan", "Crear una solicitud y ver el aviso en la campana del profesor o supervisor"],
    ], [6.5, 10.5]))
    h.append(PageBreak())
    return h


def cap11():
    h = [H1("11", "Problemas frecuentes")]
    h.append(P("Todos estos ocurrieron durante el desarrollo; están con la causa real, no con la aparente."))
    h.append(H2("11.1  Base de datos y backend"))
    h.append(tabla(["Síntoma", "Causa", "Solución"], [
        ["Tildes corruptas («Ã¡cido»)", "Los scripts se cargaron sin utf8mb4",
         "Volver a cargarlos con --default-character-set=utf8mb4"],
        ["La API no conecta a la base", "Contraseña de root incorrecta o el servicio de MySQL detenido",
         "Corregir appsettings.Development.json; iniciar el servicio MySQL80"],
        ["«Credenciales incorrectas» con Clave123", "La API no ha arrancado en modo desarrollo sobre esa base",
         "Arrancar dotnet run una vez (asigna la clave) y volver a intentar"],
        ["Las fechas salen con una hora de diferencia", "Falta AllowUserVariables=true en la conexión",
         "Agregarlo a la cadena de conexión"],
        ["Crear un respaldo falla", "Backup:MySqlBinDir no apunta a mysqldump.exe",
         "Corregir la ruta en appsettings.json"],
        ["Error de CORS en el navegador", "El origen del frontend no está en Cors:Origins",
         "Agregar la dirección exacta y reiniciar la API"],
        ["Un usuario no ve un módulo tras darle el permiso", "Los permisos viajan dentro del token",
         "Cerrar sesión y volver a entrar"],
        ["Tras actualizar, la devolución falla con «Incorrect number of arguments»",
         "Se aplicaron las migraciones pero no los procedimientos nuevos",
         "Volver a cargar 03_procedures.sql (capítulo 5)"],
    ], [5.0, 5.8, 6.2]))
    h.append(H2("11.2  Frontend y uso"))
    h.append(tabla(["Síntoma", "Causa", "Solución"], [
        ["Pantalla en blanco con un error que no está en el código", "El servidor de desarrollo de Vite quedó "
                                                                   "sirviendo una versión vieja de un archivo",
         "Detener npm run dev y volver a arrancarlo"],
        ["npm run dev falla al iniciar", "node_modules copiado de otra máquina o incompleto",
         "Borrar frontend\\node_modules y ejecutar npm install"],
        ["«Este profesor no tiene clases asignadas»", "No hay clases con ese profesor",
         "Registrarlas en Catálogos → Clases y Prácticas"],
        ["No se puede guardar un reactivo", "Falta el rombo de seguridad NFPA",
         "Completar salud, inflamabilidad y reactividad (0 a 4)"],
        ["No se puede crear un estudiante o profesor", "Falta el código o ya lo tiene otro usuario",
         "Asignar un código único (letras, números y guion)"],
        ["La foto de la cristalería no se guarda", "El archivo no es JPG, PNG o WebP, o pasa de 2 MB",
         "Usar una foto en esos formatos; el artículo sí queda guardado"],
        ["Una notificación no aparece al instante", "La campana consulta cada 30 segundos",
         "Esperar o recargar la página"],
        ["No deja emitir la constancia de solvencia", "El estudiante tiene piezas pendientes de reponer",
         "Registrar la reposición en su cuenta; luego emitirla"],
        ["La constancia sale con «[Nombre de la institución]»", "No se completó institucion.ts",
         "Capítulo 8.2 y volver a compilar el frontend"],
    ], [5.0, 5.8, 6.2]))
    h.append(H2("11.3  Aplicación Android"))
    h.append(tabla(["Síntoma", "Causa", "Solución"], [
        ["En el teléfono no carga ningún dato", "La API no está en red, falta la regla del firewall, la red "
                                               "es pública o la IP cambió",
         c("dotnet run --launch-profile red-local") + ", regla del capítulo 9.1, red privada y revisar " +
         c(".env.movil")],
        ["La APK parece no tomar los cambios", "Gradle no llegó a compilar (falta JAVA_HOME o ANDROID_HOME)",
         "Definir las variables y volver a ejecutar npm run apk leyendo el final"],
        ["«No se instaló la app»", "Hay instalada una versión firmada con otro certificado",
         "Desinstalar la versión anterior antes de instalar la nueva"],
        ["Exportar a Excel o imprimir no hace nada en el teléfono", "El WebView de Android no ejecuta "
                                                                     "descargas ni impresión",
         "Hacerlo desde la versión web"],
        ["La primera compilación tarda mucho", "Gradle descarga sus dependencias", "Esperar; las siguientes son rápidas"],
    ], [5.0, 5.8, 6.2]))
    h.append(PageBreak())
    return h


def cap12():
    h = [H1("12", "Anexos")]
    h.append(H2("12.1  Configuración"))
    h.append(tabla(["Archivo y clave", "Ejemplo", "Para qué"], [
        ["appsettings.*.json · ConnectionStrings:Default", "Server=localhost;Database=labquim;…",
         "Conexión a MySQL"],
        ["appsettings.*.json · Jwt:Key", "(32 caracteres o más)", "Firma de los tokens de sesión"],
        ["appsettings.*.json · Jwt:ExpMinutes", "480", "Duración de la sesión (8 horas)"],
        ["appsettings.json · Cors:Origins", "http://localhost:5173", "Orígenes autorizados a usar la API"],
        ["appsettings.json · Backup:MySqlBinDir", "C:\\Program Files\\MySQL\\…\\bin",
         "Carpeta de mysqldump.exe y mysql.exe"],
        ["frontend/.env.development · VITE_API_URL", "http://localhost:5099", "API para la versión web en desarrollo"],
        ["frontend/.env.production · VITE_API_URL", "https://api.midominio.com", "API para la versión publicada"],
        ["frontend/.env.movil · VITE_API_URL", "http://192.168.1.239:5099", "API para la APK"],
        ["frontend/src/institucion.ts", "nombre, ciudad, cargoFirma", "Datos impresos en la constancia de solvencia"],
    ], [6.2, 4.8, 6.0]))
    h.append(H2("12.2  Comandos útiles"))
    h.append(tabla(["Comando", "Qué hace"], [
        [c("dotnet run"), "Levanta la API en http://localhost:5099 (desarrollo)"],
        [c("dotnet run --launch-profile red-local"), "La expone a la red local (para el teléfono)"],
        [c("dotnet publish -c Release -o carpeta"), "Compila la API para producción"],
        [c("npm install"), "Instala las dependencias del frontend"],
        [c("npm run dev"), "Frontend en modo desarrollo (http://localhost:5173)"],
        [c("npm run build"), "Compila el frontend a frontend\\dist"],
        [c("npm run apk"), "Genera la APK de prueba"],
        [c("npx cap open android"), "Abre el proyecto Android en Android Studio"],
        [c("mysql … -e \"source labquim_completo.sql;\""), "Crea la base completa"],
        [c("mysqldump … --routines --hex-blob --databases labquim"),
         "Exporta la base completa (procedimientos y fotos incluidos)"],
    ], [7.0, 10.0]))
    h.append(H2("12.3  Estructura del proyecto"))
    h.append(codigo(r"""
GIIQ/                            La aplicación completa (lo único que hay que copiar)
|-- README.md                    Guía rápida de instalación
|-- database/
|   |-- 01_schema.sql ... 07_*   Esquema, datos base y procedimientos (instalación nueva)
|   |-- 08_ ... 16_migracion_*   Actualizan bases de versiones anteriores
|   |-- labquim_completo.sql     Base completa (estructura + datos + procedimientos + fotos)
|   \-- ER_diagrama.md           Diagrama entidad-relación (Mermaid)
|-- backend/LabQuim.Api/         API .NET 10
|   |-- Controllers/             Un controlador por módulo
|   |-- Repositories/            Acceso a datos con Dapper (llaman a los procedimientos)
|   |-- Models/                  Peticiones y respuestas, con sus validaciones
|   |-- Auth/                    JWT y permisos por política
|   |-- Services/                Respaldos, Excel y semilla de desarrollo
|   \-- appsettings*.json        Configuración
|-- frontend/                    Interfaz React + Vite
|   |-- src/pages/               Una pantalla por módulo
|   |-- src/components/          Componentes propios (tablas, formularios, rombo NFPA, campana)
|   |-- src/api/                 Llamadas a la API
|   |-- src/institucion.ts       Datos de la institución para la constancia
|   |-- assets-app/              Logos de GIIQ, ícono y pantalla de inicio de la APK
|   |-- android/                 Proyecto Android de Capacitor
|   \-- capacitor.config.ts      Nombre e identificador de la app
\-- docs/manual/                 Este manual y su generador
"""))
    return h


def main():
    doc = SimpleDocTemplate(str(SALIDA), pagesize=letter, leftMargin=2 * cm, rightMargin=2 * cm,
                            topMargin=2.4 * cm, bottomMargin=2 * cm,
                            title="GIIQ — Manual de instalación", author="GIIQ",
                            subject="Manual de instalación · Examen de Grado")
    historia = []
    for parte in (portada, contenido, cap1, cap2, cap3, cap4, cap5, cap6, cap7, cap8, cap9, cap10, cap11, cap12):
        historia += parte()
    doc.build(historia, canvasmaker=LienzoNumerado)
    print(f"Generado: {SALIDA}")


if __name__ == "__main__":
    main()
