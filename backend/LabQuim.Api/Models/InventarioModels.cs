using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

public sealed class ArticuloDto
{
    public int Id { get; set; }
    public string Tipo { get; set; } = "";
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string? Categoria { get; set; }
    public int UnidadId { get; set; }
    public string? Unidad { get; set; }
    public decimal StockMinimo { get; set; }
    public bool Activo { get; set; }
}

public sealed class ExistenciaDto
{
    public int ArticuloId { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Tipo { get; set; } = "";
    public string? Unidad { get; set; }
    public decimal StockMinimo { get; set; }
    public decimal Existencia { get; set; }
    public bool BajoMinimo { get; set; }
}

public sealed class LoteDto
{
    public int Id { get; set; }
    public string? CodigoLote { get; set; }
    public DateOnly? FechaVencimiento { get; set; }
    public decimal CantidadActual { get; set; }
    public string? Proveedor { get; set; }
    public string? Ubicacion { get; set; }
    public DateOnly FechaIngreso { get; set; }
}

public sealed class EntradaRequest
{
    [Required] public int ArticuloId { get; set; }
    public string? CodigoLote { get; set; }
    public DateOnly? FechaVencimiento { get; set; }
    [Range(0.0001, double.MaxValue)] public decimal Cantidad { get; set; }
    public int? ProveedorId { get; set; }
    public int? UbicacionId { get; set; }
    public string? Motivo { get; set; }
}

public sealed class EntradaResult
{
    public int LoteId { get; set; }
    public int MovimientoId { get; set; }
}

public sealed class AjusteRequest
{
    [Required] public int LoteId { get; set; }
    [Range(0.0, double.MaxValue)] public decimal NuevaCantidad { get; set; }
    public string? Motivo { get; set; }
}

public sealed class AjusteResult
{
    public int MovimientoId { get; set; }
    public decimal Delta { get; set; }
}
