using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize]
public sealed class CatalogosAdminController : ControllerBase
{
    private readonly CatalogoAdminRepository _repo;
    public CatalogosAdminController(CatalogoAdminRepository repo) => _repo = repo;

    private int Actor => User.GetUserId();

    // ===================== CATEGORÍAS =====================
    [HttpGet("categorias"), Authorize(Policy = "catalogos.ver")]
    public async Task<IActionResult> Categorias(CancellationToken ct) => Ok(await _repo.CategoriasAsync(ct));

    [HttpPost("categorias"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> CrearCategoria(CategoriaRequest r, CancellationToken ct)
        => Ok(new GuardarResult { Id = await _repo.GuardarCategoriaAsync(Actor, 0, r, ct) });

    [HttpPut("categorias/{id:int}"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EditarCategoria(int id, CategoriaRequest r, CancellationToken ct)
    { await _repo.GuardarCategoriaAsync(Actor, id, r, ct); return NoContent(); }

    [HttpPost("categorias/{id:int}/estado"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EstadoCategoria(int id, CatalogoEstadoRequest r, CancellationToken ct)
    { await _repo.EstadoCategoriaAsync(Actor, id, r.Activo, ct); return NoContent(); }

    // ===================== UNIDADES =====================
    [HttpGet("unidades"), Authorize(Policy = "catalogos.ver")]
    public async Task<IActionResult> Unidades(CancellationToken ct) => Ok(await _repo.UnidadesAsync(ct));

    [HttpPost("unidades"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> CrearUnidad(UnidadRequest r, CancellationToken ct)
        => Ok(new GuardarResult { Id = await _repo.GuardarUnidadAsync(Actor, 0, r, ct) });

    [HttpPut("unidades/{id:int}"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EditarUnidad(int id, UnidadRequest r, CancellationToken ct)
    { await _repo.GuardarUnidadAsync(Actor, id, r, ct); return NoContent(); }

    [HttpPost("unidades/{id:int}/estado"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EstadoUnidad(int id, CatalogoEstadoRequest r, CancellationToken ct)
    { await _repo.EstadoUnidadAsync(Actor, id, r.Activo, ct); return NoContent(); }

    // ===================== PROVEEDORES =====================
    [HttpGet("proveedores"), Authorize(Policy = "catalogos.ver")]
    public async Task<IActionResult> Proveedores(CancellationToken ct) => Ok(await _repo.ProveedoresAsync(ct));

    [HttpPost("proveedores"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> CrearProveedor(ProveedorRequest r, CancellationToken ct)
        => Ok(new GuardarResult { Id = await _repo.GuardarProveedorAsync(Actor, 0, r, ct) });

    [HttpPut("proveedores/{id:int}"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EditarProveedor(int id, ProveedorRequest r, CancellationToken ct)
    { await _repo.GuardarProveedorAsync(Actor, id, r, ct); return NoContent(); }

    [HttpPost("proveedores/{id:int}/estado"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EstadoProveedor(int id, CatalogoEstadoRequest r, CancellationToken ct)
    { await _repo.EstadoProveedorAsync(Actor, id, r.Activo, ct); return NoContent(); }

    // ===================== UBICACIONES =====================
    [HttpGet("ubicaciones"), Authorize(Policy = "catalogos.ver")]
    public async Task<IActionResult> Ubicaciones(CancellationToken ct) => Ok(await _repo.UbicacionesAsync(ct));

    [HttpPost("ubicaciones"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> CrearUbicacion(UbicacionRequest r, CancellationToken ct)
        => Ok(new GuardarResult { Id = await _repo.GuardarUbicacionAsync(Actor, 0, r, ct) });

    [HttpPut("ubicaciones/{id:int}"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EditarUbicacion(int id, UbicacionRequest r, CancellationToken ct)
    { await _repo.GuardarUbicacionAsync(Actor, id, r, ct); return NoContent(); }

    [HttpPost("ubicaciones/{id:int}/estado"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EstadoUbicacion(int id, CatalogoEstadoRequest r, CancellationToken ct)
    { await _repo.EstadoUbicacionAsync(Actor, id, r.Activo, ct); return NoContent(); }

    // ===================== LABORATORIOS =====================
    [HttpGet("laboratorios"), Authorize(Policy = "catalogos.ver")]
    public async Task<IActionResult> Laboratorios(CancellationToken ct) => Ok(await _repo.LaboratoriosAsync(ct));

    [HttpPost("laboratorios"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> CrearLaboratorio(LaboratorioRequest r, CancellationToken ct)
        => Ok(new GuardarResult { Id = await _repo.GuardarLaboratorioAsync(Actor, 0, r, ct) });

    [HttpPut("laboratorios/{id:int}"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EditarLaboratorio(int id, LaboratorioRequest r, CancellationToken ct)
    { await _repo.GuardarLaboratorioAsync(Actor, id, r, ct); return NoContent(); }

    [HttpPost("laboratorios/{id:int}/estado"), Authorize(Policy = "catalogos.gestionar")]
    public async Task<IActionResult> EstadoLaboratorio(int id, CatalogoEstadoRequest r, CancellationToken ct)
    { await _repo.EstadoLaboratorioAsync(Actor, id, r.Activo, ct); return NoContent(); }
}
