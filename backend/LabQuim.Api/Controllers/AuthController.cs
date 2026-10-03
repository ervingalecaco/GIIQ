using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly UsuarioRepository _usuarios;
    private readonly JwtTokenService _jwt;

    public AuthController(UsuarioRepository usuarios, JwtTokenService jwt)
    {
        _usuarios = usuarios;
        _jwt = jwt;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> Login(LoginRequest req, CancellationToken ct)
    {
        var user = await _usuarios.GetForLoginAsync(req.Usuario, ct);
        if (user is null || !user.Activo || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
            return Unauthorized(new { detail = "Usuario o contraseña incorrectos." });

        var permisos = await _usuarios.GetPermisosAsync(user.Id, ct);
        var (token, expira) = _jwt.Create(user.Id, user.Usuario, user.NombreCompleto, user.Rol, permisos);

        var info = new UsuarioInfo(user.Id, user.Usuario, user.NombreCompleto, user.Rol, permisos);
        return Ok(new LoginResponse(token, expira, info));
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<UsuarioInfo>> Me(CancellationToken ct)
    {
        var id = User.GetUserId();
        var permisos = await _usuarios.GetPermisosAsync(id, ct);
        var rol = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value ?? "";
        var nombre = User.FindFirst("nombre")?.Value ?? "";
        var usuario = User.Identity?.Name ?? "";
        return Ok(new UsuarioInfo(id, usuario, nombre, rol, permisos));
    }
}
