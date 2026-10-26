using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

/// <summary>Fila leída del Excel, ya corregida, para revisarla antes de importar.</summary>
public sealed class FilaImportacionDto
{
    /// <summary>Número de fila en la hoja (para ubicarla en el Excel).</summary>
    public int Fila { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    /// <summary>Nombre tal como venía en el Excel (si se corrigió, para mostrar la diferencia).</summary>
    public string NombreOriginal { get; set; } = "";
    public string Categoria { get; set; } = "";
    public string? Ubicacion { get; set; }
    public string Unidad { get; set; } = "ud";
    public decimal Cantidad { get; set; }
    /// <summary>Ya hay un artículo con ese código: no se importará.</summary>
    public bool Existe { get; set; }
    public List<string> Avisos { get; set; } = new();
}

/// <summary>Fila confirmada por el usuario para importar.</summary>
public sealed class FilaImportarRequest
{
    [Required, MaxLength(40)] public string Codigo { get; set; } = "";
    [Required, MaxLength(150)] public string Nombre { get; set; } = "";
    [Required, MaxLength(80)] public string Categoria { get; set; } = "";
    [MaxLength(80)] public string? Ubicacion { get; set; }
    [Required, MaxLength(10)] public string Unidad { get; set; } = "ud";
    [Range(0.0, 1_000_000.0)] public decimal Cantidad { get; set; }
}

public sealed class ImportarCristaleriaRequest
{
    [Required, MinLength(1)] public List<FilaImportarRequest> Filas { get; set; } = new();
}

public sealed class ImportarResult
{
    public int Creados { get; set; }
    public int Omitidos { get; set; }
    public int? MovimientoId { get; set; }
}
