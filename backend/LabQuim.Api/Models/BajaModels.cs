using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

/// <summary>Pieza que no volvió en una devolución: se da de baja y, con responsable, se carga al estudiante.</summary>
public sealed class PiezaQuebradaRequest
{
    [Range(1, int.MaxValue)] public int ArticuloId { get; set; }
    [Range(0.001, double.MaxValue)] public decimal Cantidad { get; set; }
    /// <summary>Estudiante responsable; null = la baja no genera cargo.</summary>
    public int? EstudianteId { get; set; }
    public string Causa { get; set; } = "QUEBRADO";
    [MaxLength(255)] public string? Observacion { get; set; }
}

public sealed class DevolverRequest
{
    public List<PiezaQuebradaRequest> Quebradas { get; set; } = [];
}

/// <summary>Baja fuera de una devolución (bodega, laboratorio).</summary>
public sealed class RegistrarBajaRequest
{
    [Range(1, int.MaxValue)] public int ArticuloId { get; set; }
    [Range(0.001, double.MaxValue)] public decimal Cantidad { get; set; }
    [Required] public string Causa { get; set; } = "QUEBRADO";
    public int? EstudianteId { get; set; }
    [MaxLength(255)] public string? Observacion { get; set; }
}

public sealed class BajaDto
{
    public int Id { get; set; }
    public DateTime Fecha { get; set; }
    public int ArticuloId { get; set; }
    public string Codigo { get; set; } = "";
    public string Articulo { get; set; } = "";
    public string? Unidad { get; set; }
    public decimal Cantidad { get; set; }
    public string Causa { get; set; } = "";
    public int? SolicitudId { get; set; }
    public int? EstudianteId { get; set; }
    public string? Estudiante { get; set; }
    public string? EstudianteCodigo { get; set; }
    public string? RegistradoPor { get; set; }
    public string? Observacion { get; set; }
    /// <summary>Estado del cargo que generó (null si no hubo responsable).</summary>
    public string? EstadoCargo { get; set; }
}

/// <summary>Resumen de la cuenta de un estudiante: piezas que debe reponer.</summary>
public sealed class CuentaResumenDto
{
    public int EstudianteId { get; set; }
    public string? Codigo { get; set; }
    public string Estudiante { get; set; } = "";
    public bool Activo { get; set; }
    public int CargosPendientes { get; set; }
    public decimal PiezasPendientes { get; set; }
    public int CargosTotales { get; set; }
    public DateTime? UltimaBaja { get; set; }
}

public sealed class CargoDto
{
    public int Id { get; set; }
    public int BajaId { get; set; }
    public DateTime Fecha { get; set; }
    public int ArticuloId { get; set; }
    public string Codigo { get; set; } = "";
    public string Articulo { get; set; } = "";
    public string? Unidad { get; set; }
    public decimal Cantidad { get; set; }
    public decimal CantidadRepuesta { get; set; }
    public string Estado { get; set; } = "";
    public DateTime? SaldadoEn { get; set; }
    public string Causa { get; set; } = "";
    public int? SolicitudId { get; set; }
    public string? Observacion { get; set; }
    public DateTime? ImagenActualizada { get; set; }
}

public sealed class ReposicionDto
{
    public int Id { get; set; }
    public int CargoId { get; set; }
    public DateTime Fecha { get; set; }
    public string Articulo { get; set; } = "";
    public decimal Cantidad { get; set; }
    public string? RecibidoPor { get; set; }
    public string? Observacion { get; set; }
}

public sealed class CuentaDetalleDto
{
    public CuentaResumenDto Resumen { get; set; } = new();
    public List<CargoDto> Cargos { get; set; } = [];
    public List<ReposicionDto> Reposiciones { get; set; } = [];
}

public sealed class RegistrarReposicionRequest
{
    [Range(0.001, double.MaxValue)] public decimal Cantidad { get; set; }
    [MaxLength(255)] public string? Observacion { get; set; }
}

public sealed class EstudianteOpcionDto
{
    public int Id { get; set; }
    public string? Codigo { get; set; }
    public string Nombre { get; set; } = "";
}

/// <summary>Datos para imprimir la constancia de solvencia.</summary>
public sealed class ConstanciaDto
{
    public int Folio { get; set; }
    public DateTime Fecha { get; set; }
    public string Estudiante { get; set; } = "";
    public string? Codigo { get; set; }
    public string? EmitidaPor { get; set; }
}
