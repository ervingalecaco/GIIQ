using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

public sealed class UsuarioListDto
{
    public int Id { get; set; }
    public string NombreCompleto { get; set; } = "";
    public string Usuario { get; set; } = "";
    public string? Email { get; set; }
    public int RolId { get; set; }
    public string Rol { get; set; } = "";
    public bool Activo { get; set; }
}

public sealed class CrearUsuarioRequest
{
    [Required, MaxLength(120)] public string NombreCompleto { get; set; } = "";
    [Required, MaxLength(50)] public string Usuario { get; set; } = "";
    [Required, MinLength(6)] public string Password { get; set; } = "";
    [EmailAddress] public string? Email { get; set; }
    [Required] public int RolId { get; set; }
}

public sealed class EditarUsuarioRequest
{
    [Required, MaxLength(120)] public string NombreCompleto { get; set; } = "";
    [EmailAddress] public string? Email { get; set; }
    [Required] public int RolId { get; set; }
}

public sealed record EstadoUsuarioRequest(bool Activo);

public sealed class PasswordUsuarioRequest
{
    [Required, MinLength(6)] public string Password { get; set; } = "";
}

public sealed class CrearUsuarioResult
{
    public int UsuarioId { get; set; }
}

// ---- Roles y permisos ----
public sealed class PermisoDto
{
    public int Id { get; set; }
    public string Codigo { get; set; } = "";
    public string? Descripcion { get; set; }
    public string? Modulo { get; set; }
}

public sealed class RolConPermisosDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }
    public IReadOnlyList<string> Permisos { get; set; } = new List<string>();
}

public sealed class SetPermisosRequest
{
    [Required] public List<string> Permisos { get; set; } = new();
}
