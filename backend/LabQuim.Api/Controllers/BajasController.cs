using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

/// <summary>Bajas de cristalería (quebrada, extraviada o deteriorada).</summary>
[ApiController]
[Route("api/bajas")]
[Authorize]
public sealed class BajasController : ControllerBase
{
    private readonly BajaRepository _repo;
    public BajasController(BajaRepository repo) => _repo = repo;

    /// <summary>Bajas del período (por defecto, los últimos 90 días).</summary>
    [HttpGet]
    [Authorize(Policy = "cuentas.ver")]
    public async Task<ActionResult<IReadOnlyList<BajaDto>>> List(
        [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
    {
        var h = hasta ?? DateOnly.FromDateTime(DateTime.Today);
        return Ok(await _repo.ListAsync(desde ?? h.AddDays(-90), h, ct));
    }

    [HttpPost]
    [Authorize(Policy = "baja.registrar")]
    public async Task<ActionResult<object>> Registrar(RegistrarBajaRequest req, CancellationToken ct)
        => Ok(new { bajaId = await _repo.RegistrarAsync(User.GetUserId(), req, ct) });
}
