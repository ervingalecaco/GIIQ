using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

public sealed record CatalogoEstadoRequest(bool Activo);

// ---- Categorías ----
public sealed class CategoriaDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
    public bool Activo { get; set; }
}
public sealed class CategoriaRequest
{
    [Required, MaxLength(80)] public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
}

// ---- Unidades ----
public sealed class UnidadFullDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string Abreviatura { get; set; } = "";
    public bool Activo { get; set; }
}
public sealed class UnidadRequest
{
    [Required, MaxLength(40)] public string Nombre { get; set; } = "";
    [Required, MaxLength(10)] public string Abreviatura { get; set; } = "";
}

// ---- Proveedores ----
public sealed class ProveedorDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string? Contacto { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Direccion { get; set; }
    public bool Activo { get; set; }
}
public sealed class ProveedorRequest
{
    [Required, MaxLength(120)] public string Nombre { get; set; } = "";
    public string? Contacto { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Direccion { get; set; }
}

// ---- Ubicaciones ----
public sealed class UbicacionFullDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
    public string? Condiciones { get; set; }
    public bool Activo { get; set; }
}
public sealed class UbicacionRequest
{
    [Required, MaxLength(80)] public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
    public string? Condiciones { get; set; }
}

// ---- Laboratorios ----
public sealed class LaboratorioFullDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
    public bool Activo { get; set; }
}
public sealed class LaboratorioRequest
{
    [Required, MaxLength(120)] public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
}

public sealed class GuardarResult
{
    public int Id { get; set; }
}
