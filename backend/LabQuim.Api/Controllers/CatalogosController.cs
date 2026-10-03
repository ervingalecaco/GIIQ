using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/catalogos")]
[Authorize(Policy = "catalogos.ver")]
public sealed class CatalogosController : ControllerBase
{
    private readonly CatalogoRepository _repo;
    public CatalogosController(CatalogoRepository repo) => _repo = repo;

    [HttpGet("laboratorios")]
    public async Task<ActionResult<IReadOnlyList<CatalogoItemDto>>> Laboratorios(CancellationToken ct)
        => Ok(await _repo.LaboratoriosAsync(ct));

    [HttpGet("unidades")]
    public async Task<ActionResult<IReadOnlyList<UnidadDto>>> Unidades(CancellationToken ct)
        => Ok(await _repo.UnidadesAsync(ct));

    [HttpGet("categorias")]
    public async Task<ActionResult<IReadOnlyList<CatalogoItemDto>>> Categorias(CancellationToken ct)
        => Ok(await _repo.CategoriasAsync(ct));

    [HttpGet("proveedores")]
    public async Task<ActionResult<IReadOnlyList<CatalogoItemDto>>> Proveedores(CancellationToken ct)
        => Ok(await _repo.ProveedoresAsync(ct));

    [HttpGet("ubicaciones")]
    public async Task<ActionResult<IReadOnlyList<CatalogoItemDto>>> Ubicaciones(CancellationToken ct)
        => Ok(await _repo.UbicacionesAsync(ct));
}
