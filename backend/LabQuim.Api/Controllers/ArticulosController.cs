using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/articulos")]
[Authorize]
public sealed class ArticulosController : ControllerBase
{
    private readonly ArticuloRepository _repo;
    public ArticulosController(ArticuloRepository repo) => _repo = repo;

    /// <summary>Lista artículos; filtra por tipo (REACTIVO | MATERIAL).</summary>
    [HttpGet]
    [Authorize(Policy = "articulos.ver")]
    public async Task<ActionResult<IReadOnlyList<ArticuloDto>>> List(
        [FromQuery] string? tipo, CancellationToken ct)
        => Ok(await _repo.ListAsync(tipo, ct));

    [HttpGet("{id:int}")]
    [Authorize(Policy = "articulos.ver")]
    public async Task<ActionResult<ArticuloDetalleDto>> GetById(int id, CancellationToken ct)
    {
        var dto = await _repo.GetByIdAsync(id, ct);
        return dto is null ? NotFound() : Ok(dto);
    }

    [HttpPost]
    [Authorize(Policy = "articulos.crear")]
    public async Task<ActionResult<CrearArticuloResult>> Crear(CrearArticuloRequest req, CancellationToken ct)
    {
        var result = await _repo.CrearAsync(User.GetUserId(), req, ct);
        return CreatedAtAction(nameof(GetById), new { id = result.ArticuloId }, result);
    }

    [HttpPut("{id:int}")]
    [Authorize(Policy = "articulos.editar")]
    public async Task<IActionResult> Editar(int id, EditarArticuloRequest req, CancellationToken ct)
    {
        await _repo.EditarAsync(User.GetUserId(), id, req, ct);
        return NoContent();
    }

    [HttpPost("{id:int}/estado")]
    [Authorize(Policy = "articulos.eliminar")]
    public async Task<IActionResult> CambiarEstado(int id, EstadoArticuloRequest req, CancellationToken ct)
    {
        await _repo.CambiarEstadoAsync(User.GetUserId(), id, req.Activo, ct);
        return NoContent();
    }
}
