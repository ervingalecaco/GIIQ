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

// ---- Clases ----
public sealed class ClaseDto
{
    public int Id { get; set; }
    /// <summary>Año de la carrera (1 a 5).</summary>
    public int Anio { get; set; }
    public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
    /// <summary>Nombres de los profesores, separados por coma (para mostrar).</summary>
    public string? Profesores { get; set; }
    /// <summary>Ids de los profesores, separados por coma (para editar).</summary>
    public string? ProfesorIds { get; set; }
    public int Practicas { get; set; }
    public bool Activo { get; set; }
}
public sealed class ClaseRequest
{
    [Range(1, 5, ErrorMessage = "El año debe estar entre primero y quinto.")] public int Anio { get; set; }
    [Required, MaxLength(120)] public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
    [Required, MinLength(1, ErrorMessage = "Asigna al menos un profesor a la clase.")]
    public List<int> ProfesorIds { get; set; } = new();
}

// ---- Prácticas ----
public sealed class PracticaDto
{
    public int Id { get; set; }
    public int ClaseId { get; set; }
    public string? Clase { get; set; }
    public int ClaseAnio { get; set; }
    public string Nombre { get; set; } = "";
    public int LaboratorioId { get; set; }
    public string? Laboratorio { get; set; }
    public string? Descripcion { get; set; }
    public bool Activo { get; set; }
}
public sealed class PracticaRequest
{
    [Required] public int ClaseId { get; set; }
    [Required, MaxLength(150)] public string Nombre { get; set; } = "";
    [Required] public int LaboratorioId { get; set; }
    public string? Descripcion { get; set; }
}

public sealed class GuardarResult
{
    public int Id { get; set; }
}
