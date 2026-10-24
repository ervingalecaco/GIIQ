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

    /// <summary>Profesores activos (para que el estudiante elija su profesor responsable).</summary>
    [HttpGet("profesores")]
    public async Task<ActionResult<IReadOnlyList<CatalogoItemDto>>> Profesores(CancellationToken ct)
        => Ok(await _repo.ProfesoresAsync(ct));

    /// <summary>Clases activas que imparte un profesor.</summary>
    [HttpGet("profesores/{profesorId:int}/clases")]
    public async Task<ActionResult<IReadOnlyList<ClaseItemDto>>> ClasesDeProfesor(int profesorId, CancellationToken ct)
        => Ok(await _repo.ClasesAsync(profesorId, ct));

    /// <summary>Todas las clases activas (el Administrador puede crear solicitudes para cualquiera).</summary>
    [HttpGet("clases")]
    public async Task<ActionResult<IReadOnlyList<ClaseItemDto>>> Clases(CancellationToken ct)
        => Ok(await _repo.ClasesAsync(null, ct));

    /// <summary>Prácticas activas de una clase.</summary>
    [HttpGet("clases/{claseId:int}/practicas")]
    public async Task<ActionResult<IReadOnlyList<PracticaItemDto>>> PracticasDeClase(int claseId, CancellationToken ct)
        => Ok(await _repo.PracticasAsync(claseId, ct));

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
