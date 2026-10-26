using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/inventario")]
[Authorize]
public sealed class InventarioController : ControllerBase
{
    private readonly InventarioRepository _repo;
    public InventarioController(InventarioRepository repo) => _repo = repo;

    [HttpGet("existencias")]
    [Authorize(Policy = "inventario.ver")]
    public async Task<ActionResult<IReadOnlyList<ExistenciaDto>>> Existencias(CancellationToken ct)
        => Ok(await _repo.GetExistenciasAsync(ct));

    [HttpGet("articulos/{articuloId:int}/lotes")]
    [Authorize(Policy = "lotes.ver")]
    public async Task<ActionResult<IReadOnlyList<LoteDto>>> Lotes(int articuloId, CancellationToken ct)
        => Ok(await _repo.GetLotesAsync(articuloId, ct));

    [HttpPost("entradas")]
    [Authorize(Policy = "entrada.registrar")]
    public async Task<ActionResult<EntradaResult>> Entrada(EntradaRequest req, CancellationToken ct)
        => Ok(await _repo.RegistrarEntradaAsync(User.GetUserId(), req, ct));

    [HttpPost("ajustes")]
    [Authorize(Policy = "ajuste.registrar")]
    public async Task<ActionResult<AjusteResult>> Ajuste(AjusteRequest req, CancellationToken ct)
        => Ok(await _repo.RegistrarAjusteAsync(User.GetUserId(), req, ct));
}
