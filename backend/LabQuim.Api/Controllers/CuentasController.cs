using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

/// <summary>
/// Cuentas de estudiantes: piezas de cristalería por reponer. La deuda se salda
/// reponiendo la misma pieza; sin saldo se emite la constancia de solvencia.
/// </summary>
[ApiController]
[Route("api/cuentas")]
[Authorize]
public sealed class CuentasController : ControllerBase
{
    private readonly BajaRepository _repo;
    public CuentasController(BajaRepository repo) => _repo = repo;

    [HttpGet]
    [Authorize(Policy = "cuentas.ver")]
    public async Task<ActionResult<IReadOnlyList<CuentaResumenDto>>> List(CancellationToken ct)
        => Ok(await _repo.CuentasAsync(ct));

    [HttpGet("{estudianteId:int}")]
    [Authorize(Policy = "cuentas.ver")]
    public async Task<ActionResult<CuentaDetalleDto>> Detalle(int estudianteId, CancellationToken ct)
    {
        var dto = await _repo.CuentaAsync(estudianteId, ct);
        return dto is null ? NotFound() : Ok(dto);
    }

    /// <summary>La cuenta del estudiante que inició sesión.</summary>
    [HttpGet("mia")]
    [Authorize(Policy = "cuenta.propia")]
    public async Task<ActionResult<CuentaDetalleDto>> Mia(CancellationToken ct)
    {
        var dto = await _repo.CuentaAsync(User.GetUserId(), ct);
        return dto is null ? NotFound() : Ok(dto);
    }

    /// <summary>Estudiantes activos, para elegir al responsable de una baja.</summary>
    [HttpGet("estudiantes")]
    [Authorize(Policy = "baja.registrar")]
    public async Task<ActionResult<IReadOnlyList<EstudianteOpcionDto>>> Estudiantes(CancellationToken ct)
        => Ok(await _repo.EstudiantesAsync(ct));

    [HttpPost("cargos/{cargoId:int}/reposicion")]
    [Authorize(Policy = "reposicion.registrar")]
    public async Task<IActionResult> Reponer(int cargoId, RegistrarReposicionRequest req, CancellationToken ct)
    {
        await _repo.ReponerAsync(User.GetUserId(), cargoId, req, ct);
        return NoContent();
    }

    /// <summary>Emite la constancia de solvencia (solo sin piezas pendientes) y devuelve los datos para imprimirla.</summary>
    [HttpPost("{estudianteId:int}/constancia")]
    [Authorize(Policy = "solvencia.emitir")]
    public async Task<ActionResult<ConstanciaDto>> Constancia(int estudianteId, CancellationToken ct)
        => Ok(await _repo.EmitirConstanciaAsync(User.GetUserId(), estudianteId, ct));

    [HttpGet("constancias/{folio:int}")]
    [Authorize(Policy = "solvencia.emitir")]
    public async Task<ActionResult<ConstanciaDto>> VerConstancia(int folio, CancellationToken ct)
    {
        var dto = await _repo.ConstanciaAsync(folio, ct);
        return dto is null ? NotFound() : Ok(dto);
    }
}
