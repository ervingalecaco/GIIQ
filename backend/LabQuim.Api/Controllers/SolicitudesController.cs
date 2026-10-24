using System.Text.Json;
using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/solicitudes")]
[Authorize]
public sealed class SolicitudesController : ControllerBase
{
    private readonly SolicitudRepository _repo;
    public SolicitudesController(SolicitudRepository repo) => _repo = repo;

    /// <summary>
    /// Crea una solicitud de préstamo. Si la crea un profesor, él es el responsable.
    /// Si la crea un estudiante, indica su profesor responsable, que debe avalarla
    /// antes de que llegue al Supervisor.
    /// </summary>
    [HttpPost]
    [Authorize(Policy = "solicitud.crear")]
    public async Task<ActionResult<CrearSolicitudResult>> Crear(CrearSolicitudRequest req, CancellationToken ct)
    {
        int profesorId;
        int? estudianteId = null;
        if (User.IsInRole("Estudiante"))
        {
            if (req.ProfesorId is not int elegido)
                return Problem(detail: "Elige el profesor responsable de la solicitud.", statusCode: 400);
            profesorId = elegido;
            estudianteId = User.GetUserId();
        }
        else
        {
            profesorId = User.GetUserId();
        }

        var detalle = req.Lineas.Select(l => new
        {
            articulo_id = l.ArticuloId,
            unidad_id = l.UnidadId,
            cantidad = l.Cantidad
        });
        var detalleJson = JsonSerializer.Serialize(detalle);

        var result = await _repo.CrearAsync(
            profesorId, estudianteId, req.Tipo, req.PracticaId, req.FechaRequerida, req.Observaciones, detalleJson, ct);
        return CreatedAtAction(nameof(GetById), new { id = result.SolicitudId }, result);
    }

    [HttpGet]
    [Authorize(Policy = "solicitud.ver")]
    public async Task<ActionResult<IReadOnlyList<SolicitudHeader>>> List(
        [FromQuery] string? tipo, [FromQuery] string? estado,
        [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
    {
        // El profesor ve las suyas y las de sus estudiantes; el estudiante solo las que creó;
        // el resto de roles con permiso ven todas.
        int? profesorId = User.IsInRole("Profesor") ? User.GetUserId() : null;
        int? estudianteId = User.IsInRole("Estudiante") ? User.GetUserId() : null;
        return Ok(await _repo.ListAsync(tipo, estado, profesorId, estudianteId, desde, hasta, ct));
    }

    [HttpGet("{id:int}")]
    [Authorize(Policy = "solicitud.ver")]
    public async Task<ActionResult<SolicitudDetalleDto>> GetById(int id, CancellationToken ct)
    {
        var dto = await _repo.GetByIdAsync(id, ct);
        if (dto is null) return NotFound();
        if (User.IsInRole("Profesor") && dto.Cabecera.ProfesorId != User.GetUserId())
            return Forbid();
        if (User.IsInRole("Estudiante") && dto.Cabecera.EstudianteId != User.GetUserId())
            return Forbid();
        return Ok(dto);
    }

    /// <summary>El profesor responsable avala la solicitud de su estudiante (pasa al Supervisor).</summary>
    [HttpPost("{id:int}/avalar")]
    [Authorize(Policy = "solicitud.avalar")]
    public async Task<IActionResult> Avalar(int id, CancellationToken ct)
    {
        await _repo.AvalarAsync(id, User.GetUserId(), ct);
        return NoContent();
    }

    /// <summary>El profesor responsable rechaza la solicitud de su estudiante.</summary>
    [HttpPost("{id:int}/rechazar-profesor")]
    [Authorize(Policy = "solicitud.avalar")]
    public async Task<IActionResult> RechazarProfesor(int id, RechazarRequest req, CancellationToken ct)
    {
        await _repo.RechazarProfesorAsync(id, User.GetUserId(), req.Motivo, ct);
        return NoContent();
    }

    [HttpPost("{id:int}/aprobar")]
    [Authorize(Policy = "solicitud.aprobar")]
    public async Task<IActionResult> Aprobar(int id, CancellationToken ct)
    {
        await _repo.AprobarAsync(id, User.GetUserId(), ct);
        return NoContent();
    }

    [HttpPost("{id:int}/rechazar")]
    [Authorize(Policy = "solicitud.aprobar")]
    public async Task<IActionResult> Rechazar(int id, RechazarRequest req, CancellationToken ct)
    {
        await _repo.RechazarAsync(id, User.GetUserId(), req.Motivo, ct);
        return NoContent();
    }

    [HttpPost("{id:int}/preparar")]
    [Authorize(Policy = "solicitud.preparar")]
    public async Task<ActionResult<PrepararResult>> Preparar(int id, CancellationToken ct)
    {
        return Ok(await _repo.PrepararAsync(id, User.GetUserId(), ct));
    }

    [HttpPost("{id:int}/entregar")]
    [Authorize(Policy = "solicitud.entregar")]
    public async Task<IActionResult> Entregar(int id, CancellationToken ct)
    {
        await _repo.EntregarAsync(id, User.GetUserId(), ct);
        return NoContent();
    }

    [HttpPost("{id:int}/devolver")]
    [Authorize(Policy = "solicitud.devolver")]
    public async Task<IActionResult> Devolver(int id, [FromBody] DevolverRequest? req, CancellationToken ct)
    {
        // Sin cuerpo = todo volvió completo (como antes de las bajas).
        await _repo.DevolverAsync(id, User.GetUserId(), req?.Quebradas ?? [], ct);
        return NoContent();
    }
}
