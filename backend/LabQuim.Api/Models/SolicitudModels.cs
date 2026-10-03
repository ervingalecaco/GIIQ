using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

// ---- Entrada ----
public sealed class CrearSolicitudRequest
{
    [Required] public int LaboratorioId { get; set; }
    public DateOnly? FechaRequerida { get; set; }
    public string? Observaciones { get; set; }
    [Required, MinLength(1)] public List<LineaSolicitud> Lineas { get; set; } = new();
}

public sealed class LineaSolicitud
{
    [Required] public int ArticuloId { get; set; }
    [Required] public int UnidadId { get; set; }
    [Range(0.0001, double.MaxValue)] public decimal Cantidad { get; set; }
}

public sealed record RechazarRequest([Required] string Motivo);

// ---- Resultados de SP ----
public sealed class CrearSolicitudResult
{
    public int SolicitudId { get; set; }
    public int Lineas { get; set; }
}

public sealed class PrepararResult
{
    public int MovimientoId { get; set; }
}

// ---- Lectura ----
public sealed class SolicitudHeader
{
    public int Id { get; set; }
    public string Estado { get; set; } = "";
    public int ProfesorId { get; set; }
    public string? Profesor { get; set; }
    public int? SupervisorId { get; set; }
    public int? BodegaId { get; set; }
    public int LaboratorioId { get; set; }
    public string? Laboratorio { get; set; }
    public DateTime FechaSolicitud { get; set; }
    public DateOnly? FechaRequerida { get; set; }
    public string? MotivoRechazo { get; set; }
    public string? Observaciones { get; set; }
}

public sealed class SolicitudLineaDto
{
    public int Id { get; set; }
    public int ArticuloId { get; set; }
    public string? Articulo { get; set; }
    public string? Tipo { get; set; }
    public string? Unidad { get; set; }
    public decimal CantSolicitada { get; set; }
    public decimal CantPreparada { get; set; }
    public decimal CantDevuelta { get; set; }
    public int? LoteId { get; set; }
}

public sealed class SolicitudDetalleDto
{
    public SolicitudHeader Cabecera { get; set; } = new();
    public IReadOnlyList<SolicitudLineaDto> Lineas { get; set; } = new List<SolicitudLineaDto>();
}
