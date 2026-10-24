using System.ComponentModel.DataAnnotations;

namespace LabQuim.Api.Models;

/// <summary>Patrones de validación compartidos (los mismos que aplican los SP).</summary>
public static class UsuarioReglas
{
    /// <summary>Solo letras (con tildes y Ñ), espacio, apóstrofo y guion: sin emojis, números ni símbolos.</summary>
    public const string Nombre = @"^\s*[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+([ '-]+[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*\s*$";
    public const string NombreMensaje = "Solo se permiten letras, espacios, apóstrofo o guion (sin emojis, números ni símbolos).";
    public const string Usuario = @"^[A-Za-z0-9._-]{3,50}$";
    public const string UsuarioMensaje = "El usuario debe tener de 3 a 50 letras, números, punto, guion o guion bajo.";
    public const string Codigo = @"^\s*[A-Za-z0-9]+(-[A-Za-z0-9]+)*\s*$";
    public const string CodigoMensaje = "El código solo puede tener letras, números y guion.";
}

public sealed class UsuarioListDto
{
    public int Id { get; set; }
    public string Nombres { get; set; } = "";
    public string Apellidos { get; set; } = "";
    public string NombreCompleto { get; set; } = "";
    public string? Codigo { get; set; }
    public string Usuario { get; set; } = "";
    public string? Email { get; set; }
    public int RolId { get; set; }
    public string Rol { get; set; } = "";
    public bool Activo { get; set; }
}

public sealed class CrearUsuarioRequest
{
    [Required, MaxLength(60), RegularExpression(UsuarioReglas.Nombre, ErrorMessage = UsuarioReglas.NombreMensaje)]
    public string Nombres { get; set; } = "";
    [Required, MaxLength(60), RegularExpression(UsuarioReglas.Nombre, ErrorMessage = UsuarioReglas.NombreMensaje)]
    public string Apellidos { get; set; } = "";
    /// <summary>Código de estudiante o de profesor (obligatorio para esos roles; lo valida el SP).</summary>
    [MaxLength(20), RegularExpression(UsuarioReglas.Codigo, ErrorMessage = UsuarioReglas.CodigoMensaje)]
    public string? Codigo { get; set; }
    [Required, RegularExpression(UsuarioReglas.Usuario, ErrorMessage = UsuarioReglas.UsuarioMensaje)]
    public string Usuario { get; set; } = "";
    [Required, MinLength(6)] public string Password { get; set; } = "";
    [EmailAddress] public string? Email { get; set; }
    [Required] public int RolId { get; set; }
}

public sealed class EditarUsuarioRequest
{
    [Required, MaxLength(60), RegularExpression(UsuarioReglas.Nombre, ErrorMessage = UsuarioReglas.NombreMensaje)]
    public string Nombres { get; set; } = "";
    [Required, MaxLength(60), RegularExpression(UsuarioReglas.Nombre, ErrorMessage = UsuarioReglas.NombreMensaje)]
    public string Apellidos { get; set; } = "";
    [MaxLength(20), RegularExpression(UsuarioReglas.Codigo, ErrorMessage = UsuarioReglas.CodigoMensaje)]
    public string? Codigo { get; set; }
    [EmailAddress] public string? Email { get; set; }
    [Required] public int RolId { get; set; }
}

/// <summary>Respuesta de la verificación previa de usuario/código.</summary>
public sealed class DisponibilidadDto
{
    public bool UsuarioDisponible { get; set; } = true;
    public bool CodigoDisponible { get; set; } = true;
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
