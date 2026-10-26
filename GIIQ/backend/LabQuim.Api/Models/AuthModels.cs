namespace LabQuim.Api.Models;

public sealed record LoginRequest(string Usuario, string Password);

public sealed record UsuarioInfo(
    int Id, string Usuario, string Nombre, string Rol, IReadOnlyList<string> Permisos);

public sealed record LoginResponse(string Token, DateTime ExpiraEn, UsuarioInfo Usuario);

/// <summary>Fila de usuarios usada solo para el login.</summary>
public sealed class UsuarioAuth
{
    public int Id { get; set; }
    public string NombreCompleto { get; set; } = "";
    public string Usuario { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string Rol { get; set; } = "";
    public bool Activo { get; set; }
}
