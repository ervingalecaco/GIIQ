using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

/// <summary>Notificaciones del usuario que inició sesión (cualquier rol; cada quien ve solo las suyas).</summary>
[ApiController]
[Route("api/notificaciones")]
[Authorize]
public sealed class NotificacionesController : ControllerBase
{
    private readonly NotificacionRepository _repo;
    public NotificacionesController(NotificacionRepository repo) => _repo = repo;

    [HttpGet]
    public async Task<ActionResult<NotificacionesDto>> List(
        [FromQuery] bool soloNoLeidas = false, [FromQuery] int limite = 20, CancellationToken ct = default)
        => Ok(await _repo.ListAsync(User.GetUserId(), soloNoLeidas, Math.Clamp(limite, 1, 500), ct));

    /// <summary>Solo el contador, para la campana (se consulta cada pocos segundos).</summary>
    [HttpGet("no-leidas")]
    public async Task<ActionResult<object>> NoLeidas(CancellationToken ct)
        => Ok(new { noLeidas = await _repo.NoLeidasAsync(User.GetUserId(), ct) });

    [HttpPost("{id:long}/leida")]
    public async Task<IActionResult> MarcarLeida(long id, CancellationToken ct)
    {
        await _repo.MarcarLeidaAsync(User.GetUserId(), id, ct);
        return NoContent();
    }

    [HttpPost("leidas")]
    public async Task<IActionResult> MarcarTodas(CancellationToken ct)
    {
        await _repo.MarcarTodasAsync(User.GetUserId(), ct);
        return NoContent();
    }
}
