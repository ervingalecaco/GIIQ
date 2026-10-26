namespace LabQuim.Api.Models;

public sealed class ConteoDto
{
    public string Etiqueta { get; set; } = "";
    public int Cantidad { get; set; }
}

public sealed class DashboardDto
{
    public int TotalArticulos { get; set; }
    public int BajoMinimo { get; set; }
    public int ProximosAVencer { get; set; }
    public int SolicitudesPendientes { get; set; }
    public IReadOnlyList<ConteoDto> ArticulosPorCategoria { get; set; } = new List<ConteoDto>();
    public IReadOnlyList<ConteoDto> Vencimientos { get; set; } = new List<ConteoDto>();
    public IReadOnlyList<ConteoDto> ConsumoPorMes { get; set; } = new List<ConteoDto>();
}

public sealed class ProximoVencerDto
{
    public int ArticuloId { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string? CodigoLote { get; set; }
    public DateOnly? FechaVencimiento { get; set; }
    public int DiasRestantes { get; set; }
    public decimal CantidadActual { get; set; }
    public string? Ubicacion { get; set; }
}

public sealed class ConsumoLaboratorioDto
{
    public int LaboratorioId { get; set; }
    public string Laboratorio { get; set; } = "";
    public int Despachos { get; set; }
    public int Lineas { get; set; }
}

public sealed class EntradaProveedorDto
{
    public string Proveedor { get; set; } = "";
    public int Entradas { get; set; }
    public decimal Unidades { get; set; }
}

public sealed class KardexDto
{
    public DateTime Fecha { get; set; }
    public string Tipo { get; set; } = "";
    public decimal Cantidad { get; set; }
    public string? CodigoLote { get; set; }
    public string? Motivo { get; set; }
}

// ------------------------------------------------------------------ Detalle de reportes (panel lateral)

/// <summary>Lote con existencia de un artículo (detalle del reporte de existencias).</summary>
public sealed class LoteExistenciaDto
{
    public int Id { get; set; }
    public string? CodigoLote { get; set; }
    public DateOnly? FechaVencimiento { get; set; }
    public int? DiasRestantes { get; set; }
    public decimal CantidadActual { get; set; }
    public string? Ubicacion { get; set; }
    public string? Proveedor { get; set; }
    public DateOnly FechaIngreso { get; set; }
}

/// <summary>Artículo despachado a un laboratorio en el período, sumado.</summary>
public sealed class ConsumoArticuloDto
{
    public int ArticuloId { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Tipo { get; set; } = "";
    public string Unidad { get; set; } = "";
    public decimal Cantidad { get; set; }
    public int Despachos { get; set; }
}

/// <summary>Despacho (salida de bodega) hacia un laboratorio.</summary>
public sealed class ConsumoDespachoDto
{
    public int SolicitudId { get; set; }
    public DateTime Fecha { get; set; }
    public string Tipo { get; set; } = "";
    public string Solicitante { get; set; } = "";
    public string? Practica { get; set; }
    public int Lineas { get; set; }
}

public sealed class ConsumoDetalleDto
{
    public IReadOnlyList<ConsumoArticuloDto> Articulos { get; set; } = new List<ConsumoArticuloDto>();
    public IReadOnlyList<ConsumoDespachoDto> Despachos { get; set; } = new List<ConsumoDespachoDto>();
}
