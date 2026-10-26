using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using ClosedXML.Excel;
using LabQuim.Api.Models;

namespace LabQuim.Api.Services;

/// <summary>
/// Lee el Excel de cristalería del laboratorio (hoja "cristaleria") y propone,
/// por cada fila, el artículo a crear: nombre corregido + capacidad + material,
/// cantidad numérica, categoría y ubicación. No escribe nada en la base.
///
/// Columnas que reconoce (por su encabezado, sin importar el orden):
/// ID_Equipo, Nombre_Tecnico, Tipo_Cristaleria, Capacidad, Unidad_Medida,
/// Material, Cantidad_Stock, Unidad_Paquete, Ubicacion_Laboratorio.
/// </summary>
public static partial class ImportadorCristaleria
{
    public const string CategoriaGeneral = "Cristalería general";
    public const string CategoriaDestilacion = "Destilación";

    public static List<FilaImportacionDto> Leer(Stream archivo, ISet<string> codigosExistentes)
    {
        using var wb = new XLWorkbook(archivo);
        var ws = wb.Worksheets.FirstOrDefault(h => Clave(h.Name).Contains("cristal"))
                 ?? wb.Worksheets.First();

        var (filaEncabezado, col) = BuscarEncabezados(ws);
        if (!col.ContainsKey("nombre"))
            throw new InvalidOperationException(
                $"La hoja \"{ws.Name}\" no tiene la columna Nombre_Tecnico (o Nombre).");

        var filas = new List<FilaImportacionDto>();
        var ultima = ws.LastRowUsed()?.RowNumber() ?? filaEncabezado;
        for (var r = filaEncabezado + 1; r <= ultima; r++)
        {
            string? Celda(string campo) =>
                col.TryGetValue(campo, out var c) ? Texto(ws.Cell(r, c)) : null;

            var nombreOriginal = Celda("nombre");
            if (string.IsNullOrWhiteSpace(nombreOriginal)) continue;

            var fila = new FilaImportacionDto { Fila = r, NombreOriginal = Espacios(nombreOriginal) };

            // Código estable a partir del ID del Excel: volver a importar no duplica.
            var id = Celda("id");
            fila.Codigo = int.TryParse(id, NumberStyles.Integer, CultureInfo.InvariantCulture, out var n)
                ? $"CR-{n:000}"
                : $"CR-F{r:000}";
            fila.Existe = codigosExistentes.Contains(fila.Codigo);

            fila.Nombre = ArmarNombre(nombreOriginal, Celda("capacidad"), Celda("unidad_medida"), Celda("material"));
            fila.Categoria = Categoria(Celda("tipo"), fila.Nombre);

            var ubicacion = Celda("ubicacion");
            fila.Ubicacion = string.IsNullOrWhiteSpace(ubicacion) ? null : Capitalizar(Corregir(ubicacion));

            // Cantidad: viene como número o como texto ("34 unidades", "1 caja").
            var stock = Celda("stock");
            if (string.IsNullOrWhiteSpace(stock))
            {
                fila.Avisos.Add("Sin cantidad en el Excel: se importa con 0.");
            }
            else
            {
                var m = NumeroRegex().Match(stock);
                if (m.Success)
                    fila.Cantidad = decimal.Parse(m.Value.Replace(',', '.'), CultureInfo.InvariantCulture);
                else
                    fila.Avisos.Add($"No se pudo leer la cantidad \"{stock.Trim()}\": se importa con 0.");
                if (Clave(stock).Contains("caja")) fila.Unidad = "caja";
            }

            var paquete = Celda("paquete");
            if (!string.IsNullOrWhiteSpace(paquete))
                fila.Avisos.Add($"Unidad_Paquete = {paquete} (no se importa; revisa si la cantidad son paquetes).");

            filas.Add(fila);
        }

        if (filas.Count == 0)
            throw new InvalidOperationException($"La hoja \"{ws.Name}\" no tiene filas con nombre.");
        return filas;
    }

    /// <summary>Busca en las primeras filas la de encabezados y devuelve campo → columna.</summary>
    private static (int fila, Dictionary<string, int> col) BuscarEncabezados(IXLWorksheet ws)
    {
        for (var r = 1; r <= 15; r++)
        {
            var col = new Dictionary<string, int>();
            foreach (var cell in ws.Row(r).CellsUsed())
            {
                var campo = Clave(cell.GetString()).Replace(" ", "_") switch
                {
                    "id_equipo" or "id" => "id",
                    "nombre_tecnico" or "nombre" => "nombre",
                    "tipo_cristaleria" or "tipo" => "tipo",
                    "capacidad" => "capacidad",
                    "unidad_medida" => "unidad_medida",
                    "material" => "material",
                    "cantidad_stock" or "cantidad" or "stock" => "stock",
                    "unidad_paquete" => "paquete",
                    "ubicacion_laboratorio" or "ubicacion" => "ubicacion",
                    _ => null,
                };
                if (campo is not null) col.TryAdd(campo, cell.Address.ColumnNumber);
            }
            if (col.ContainsKey("nombre")) return (r, col);
        }
        return (1, new Dictionary<string, int>());
    }

    /// <summary>"Beaker" + 250 + "mL" + "borocilicato" → "Beaker 250 mL"; el plástico se indica.</summary>
    public static string ArmarNombre(string nombre, string? capacidad, string? unidad, string? material)
    {
        var sb = new StringBuilder(Capitalizar(Corregir(nombre)));

        if (!string.IsNullOrWhiteSpace(capacidad))
        {
            sb.Append(' ').Append(Corregir(capacidad));
            if (!string.IsNullOrWhiteSpace(unidad)) sb.Append(' ').Append(NormalizarUnidad(unidad));
        }

        // El borosilicato es el material por defecto de la cristalería; otro material se aclara.
        if (!string.IsNullOrWhiteSpace(material) && !Clave(material).Contains("borosilicato")
            && !Clave(material).Contains("borocilicato"))
            sb.Append(" de ").Append(Corregir(material));

        return sb.ToString();
    }

    private static string Categoria(string? tipo, string nombre)
    {
        var t = Clave($"{tipo} {nombre}");
        string[] destilacion = ["destil", "condensador", "soxhlet", "dean-stark", "snyder", "allihn", "liebig"];
        return destilacion.Any(t.Contains) ? CategoriaDestilacion : CategoriaGeneral;
    }

    private static string NormalizarUnidad(string u) => Clave(u) switch
    {
        "ml" => "mL",
        "l" => "L",
        "mm" => "mm",
        "cm" => "cm",
        "g" => "g",
        _ => u.Trim(),
    };

    // ---------------- Corrección de texto ----------------

    /// <summary>Frases que se corrigen antes que las palabras sueltas.</summary>
    private static readonly (Regex re, string por)[] Frases =
    [
        (new Regex(@"\bigualaci[oó]n\s+presi[oó]n\b", RegexOptions.IgnoreCase), "igualación de presión"),
        (new Regex(@"\bconjunta\b", RegexOptions.IgnoreCase), "de junta"),
        (new Regex(@"\bdos\s+entrada\b", RegexOptions.IgnoreCase), "dos entradas"),
    ];

    /// <summary>Errores de escritura y tildes frecuentes en el inventario (clave sin tildes, en minúsculas).</summary>
    private static readonly Dictionary<string, string> Palabras = new()
    {
        ["condesandor"] = "condensador",
        ["condesador"] = "condensador",
        ["matras"] = "matraz",
        ["borocilicato"] = "borosilicato",
        ["precepitado"] = "precipitado",
        ["descador"] = "desecador",
        ["platico"] = "plástico",
        ["platicos"] = "plástico",
        ["plastico"] = "plástico",
        ["plasticos"] = "plástico",
        ["labotorio"] = "laboratorio",
        ["cristaleria"] = "cristalería",
        ["destilacion"] = "destilación",
        ["decantacion"] = "decantación",
        ["adicion"] = "adición",
        ["igualacion"] = "igualación",
        ["presion"] = "presión",
        ["ignicion"] = "ignición",
        ["par"] = "para",
        ["cromatografia"] = "cromatografía",
        ["densimetro"] = "densímetro",
        ["viscosimetro"] = "viscosímetro",
        ["balon"] = "balón",
        ["camara"] = "cámara",
        ["recoleccion"] = "recolección",
        ["boquinas"] = "bocas",
        ["boquiñas"] = "bocas",
        ["vacio"] = "vacío",
        ["multiples"] = "múltiples",
        ["vidrios"] = "vidrio",
        ["dean-stark"] = "Dean-Stark",
    };

    /// <summary>Corrige frases y palabras conocidas, y deja un solo espacio entre palabras.</summary>
    public static string Corregir(string texto)
    {
        var s = Espacios(texto);
        foreach (var (re, por) in Frases) s = re.Replace(s, por);

        var palabras = s.Split(' ');
        for (var i = 0; i < palabras.Length; i++)
        {
            // Separa signos alrededor de la palabra, ej. "(cromatografia)".
            var m = BordesRegex().Match(palabras[i]);
            var p = m.Groups[2].Value;
            if (p.Length == 0 || !Palabras.TryGetValue(Clave(p), out var por)) continue;
            // Respeta la mayúscula inicial que traía la palabra.
            if (char.IsUpper(p[0])) por = char.ToUpper(por[0]) + por[1..];
            palabras[i] = m.Groups[1].Value + por + m.Groups[3].Value;
        }
        return string.Join(' ', palabras);
    }

    public static string Capitalizar(string s) =>
        s.Length == 0 ? s : char.ToUpper(s[0], CultureInfo.GetCultureInfo("es")) + s[1..];

    private static string Espacios(string s) => EspaciosRegex().Replace(s.Trim(), " ");

    /// <summary>Minúsculas y sin tildes (la ñ se conserva), para comparar.</summary>
    private static string Clave(string s)
    {
        var sb = new StringBuilder();
        foreach (var ch in s.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD))
        {
            if (ch == '̃' && sb.Length > 0 && sb[^1] == 'n') { sb[^1] = 'ñ'; continue; }
            if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark) sb.Append(ch);
        }
        return sb.ToString();
    }

    private static string? Texto(IXLCell c)
    {
        if (c.IsEmpty()) return null;
        return c.DataType == XLDataType.Number
            ? c.GetDouble().ToString(CultureInfo.InvariantCulture)
            : c.GetFormattedString();
    }

    [GeneratedRegex(@"\d+(?:[.,]\d+)?")] private static partial Regex NumeroRegex();
    [GeneratedRegex(@"\s+")] private static partial Regex EspaciosRegex();
    [GeneratedRegex(@"^([^\p{L}\d]*)(.*?)([^\p{L}\d]*)$")] private static partial Regex BordesRegex();
}
