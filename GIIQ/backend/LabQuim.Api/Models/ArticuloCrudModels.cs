using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

/// <summary>Rombo de seguridad NFPA 704 de un reactivo (obligatorio para reactivos; lo valida el SP).</summary>
public interface IRomboNfpa
{
    int? NfpaSalud { get; }
    int? NfpaInflamabilidad { get; }
    int? NfpaReactividad { get; }
    string? NfpaEspecial { get; }
}

public static class NfpaReglas
{
    /// <summary>Códigos del cuadrante blanco, separados por coma (ej. "OX,COR").</summary>
    public const string Especial = "^((ACID|ALC|BIO|COR|CRYO|OX|R|W|XN)(,(ACID|ALC|BIO|COR|CRYO|OX|R|W|XN))*)?$";
    public const string EspecialMensaje = "Riesgo específico no válido (usa R, COR, BIO, CRYO, XN, ALC, W, OX o ACID).";
}

public sealed class CrearArticuloRequest : IRomboNfpa
{
    [Required, RegularExpression("REACTIVO|CRISTALERIA")]
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

    // Rombo NFPA 704 (solo REACTIVO)
    [Range(0, 4)] public int? NfpaSalud { get; set; }
    [Range(0, 4)] public int? NfpaInflamabilidad { get; set; }
    [Range(0, 4)] public int? NfpaReactividad { get; set; }
    [RegularExpression(NfpaReglas.Especial, ErrorMessage = NfpaReglas.EspecialMensaje)]
    public string? NfpaEspecial { get; set; }
}

public sealed class EditarArticuloRequest : IRomboNfpa
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

    [Range(0, 4)] public int? NfpaSalud { get; set; }
    [Range(0, 4)] public int? NfpaInflamabilidad { get; set; }
    [Range(0, 4)] public int? NfpaReactividad { get; set; }
    [RegularExpression(NfpaReglas.Especial, ErrorMessage = NfpaReglas.EspecialMensaje)]
    public string? NfpaEspecial { get; set; }
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
    // Ficha (null si es CRISTALERIA)
    public string? Cas { get; set; }
    public string? Formula { get; set; }
    public string? ClasificacionPeligro { get; set; }
    public string? EstadoFisico { get; set; }
    public string? Concentracion { get; set; }
    public string? CondicionesAlmacenamiento { get; set; }
    public int? NfpaSalud { get; set; }
    public int? NfpaInflamabilidad { get; set; }
    public int? NfpaReactividad { get; set; }
    public string? NfpaEspecial { get; set; }
    /// <summary>Fecha de la foto de referencia (cristalería); null si no tiene.</summary>
    public DateTime? ImagenActualizada { get; set; }
}

/// <summary>Foto de referencia tal como está guardada.</summary>
public sealed class ImagenArticulo
{
    public byte[] Contenido { get; set; } = [];
    public string TipoMime { get; set; } = "";
}
