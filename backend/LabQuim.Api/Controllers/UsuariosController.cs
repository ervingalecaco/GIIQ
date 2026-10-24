using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/usuarios")]
[Authorize]
public sealed class UsuariosController : ControllerBase
{
    private readonly UsuarioRepository _repo;
    public UsuariosController(UsuarioRepository repo) => _repo = repo;

    [HttpGet]
    [Authorize(Policy = "usuarios.ver")]
    public async Task<ActionResult<IReadOnlyList<UsuarioListDto>>> List(CancellationToken ct)
        => Ok(await _repo.ListAsync(ct));

    /// <summary>Verificación previa en el formulario: ¿el usuario y el código están libres?</summary>
    [HttpGet("disponibilidad")]
    [Authorize(Policy = "usuarios.ver")]
    public async Task<ActionResult<DisponibilidadDto>> Disponibilidad(
        [FromQuery] string? usuario, [FromQuery] string? codigo, [FromQuery] int? excluirId, CancellationToken ct)
        => Ok(await _repo.DisponibilidadAsync(usuario, codigo, excluirId, ct));

    [HttpGet("{id:int}")]
    [Authorize(Policy = "usuarios.ver")]
    public async Task<ActionResult<UsuarioListDto>> GetById(int id, CancellationToken ct)
    {
        var dto = await _repo.GetByIdAsync(id, ct);
        return dto is null ? NotFound() : Ok(dto);
    }

    [HttpPost]
    [Authorize(Policy = "usuarios.crear")]
    public async Task<ActionResult<CrearUsuarioResult>> Crear(CrearUsuarioRequest req, CancellationToken ct)
    {
        var hash = BCrypt.Net.BCrypt.HashPassword(req.Password);
        var result = await _repo.CrearAsync(User.GetUserId(), req, hash, ct);
        return CreatedAtAction(nameof(GetById), new { id = result.UsuarioId }, result);
    }

    [HttpPut("{id:int}")]
    [Authorize(Policy = "usuarios.editar")]
    public async Task<IActionResult> Editar(int id, EditarUsuarioRequest req, CancellationToken ct)
    {
        await _repo.EditarAsync(User.GetUserId(), id, req, ct);
        return NoContent();
    }

    [HttpPost("{id:int}/estado")]
    [Authorize(Policy = "usuarios.eliminar")]
    public async Task<IActionResult> CambiarEstado(int id, EstadoUsuarioRequest req, CancellationToken ct)
    {
        await _repo.CambiarEstadoAsync(User.GetUserId(), id, req.Activo, ct);
        return NoContent();
    }

    [HttpPost("{id:int}/password")]
    [Authorize(Policy = "usuarios.editar")]
    public async Task<IActionResult> CambiarPassword(int id, PasswordUsuarioRequest req, CancellationToken ct)
    {
        var hash = BCrypt.Net.BCrypt.HashPassword(req.Password);
        await _repo.CambiarPasswordAsync(User.GetUserId(), id, hash, ct);
        return NoContent();
    }
}
