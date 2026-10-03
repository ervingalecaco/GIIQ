using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

public sealed class CrearArticuloRequest
{
    [Required, RegularExpression("REACTIVO|MATERIAL")]
    public string Tipo { get; set; } = "";
    [Required, MaxLength(40)] public string Codigo { get; set; } = "";
    [Required, MaxLength(150)] public string Nombre { get; set; } = "";
    [Required] public int CategoriaId { get; set; }
    [Required] public int UnidadId { get; set; }
    [Range(0.0, double.MaxValue)] public decimal StockMinimo { get; set; }

    // Ficha (solo REACTIVO)
    public string? Cas { get; set; }
    public string? Formula { get; set; }
    public string? ClasificacionPeligro { get; set; }
    public string? EstadoFisico { get; set; }
    public string? Concentracion { get; set; }
    public string? CondicionesAlmacenamiento { get; set; }
}

public sealed class EditarArticuloRequest
{
    [Required, MaxLength(150)] public string Nombre { get; set; } = "";
    [Required] public int CategoriaId { get; set; }
    [Required] public int UnidadId { get; set; }
    [Range(0.0, double.MaxValue)] public decimal StockMinimo { get; set; }

    public string? Cas { get; set; }
    public string? Formula { get; set; }
    public string? ClasificacionPeligro { get; set; }
    public string? EstadoFisico { get; set; }
    public string? Concentracion { get; set; }
    public string? CondicionesAlmacenamiento { get; set; }
}

public sealed record EstadoArticuloRequest(bool Activo);

public sealed class CrearArticuloResult
{
    public int ArticuloId { get; set; }
}

public sealed class ArticuloDetalleDto
{
    public int Id { get; set; }
    public string Tipo { get; set; } = "";
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public int CategoriaId { get; set; }
    public string? Categoria { get; set; }
    public int UnidadId { get; set; }
    public string? Unidad { get; set; }
    public decimal StockMinimo { get; set; }
    public bool Activo { get; set; }
    // Ficha (null si es MATERIAL)
    public string? Cas { get; set; }
    public string? Formula { get; set; }
    public string? ClasificacionPeligro { get; set; }
    public string? EstadoFisico { get; set; }
    public string? Concentracion { get; set; }
    public string? CondicionesAlmacenamiento { get; set; }
}
