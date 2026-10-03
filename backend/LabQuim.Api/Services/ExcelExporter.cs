using ClosedXML.Excel;

namespace LabQuim.Api.Services;

public static class ExcelExporter
{
    public const string ContentType =
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

    /// <summary>Genera un .xlsx con una hoja: encabezados en negrita + filas.</summary>
    public static byte[] Build(string hoja, IReadOnlyList<string> headers, IEnumerable<IReadOnlyList<object?>> rows)
    {
        using var wb = new XLWorkbook();
        var ws = wb.Worksheets.Add(Sanitizar(hoja));

        for (var c = 0; c < headers.Count; c++)
            ws.Cell(1, c + 1).Value = headers[c];
        var header = ws.Range(1, 1, 1, headers.Count);
        header.Style.Font.Bold = true;
        header.Style.Fill.BackgroundColor = XLColor.FromHtml("#0f766e");
        header.Style.Font.FontColor = XLColor.White;

        var r = 2;
        foreach (var row in rows)
        {
            for (var c = 0; c < row.Count; c++)
                ws.Cell(r, c + 1).Value = XLCellValue.FromObject(row[c]);
            r++;
        }

        ws.Columns().AdjustToContents();
        ws.SheetView.FreezeRows(1);

        using var ms = new MemoryStream();
        wb.SaveAs(ms);
        return ms.ToArray();
    }

    private static string Sanitizar(string nombre)
    {
        var limpio = nombre.Length > 31 ? nombre[..31] : nombre;
        foreach (var ch in new[] { '\\', '/', '*', '?', ':', '[', ']' })
            limpio = limpio.Replace(ch, ' ');
        return limpio;
    }
}
