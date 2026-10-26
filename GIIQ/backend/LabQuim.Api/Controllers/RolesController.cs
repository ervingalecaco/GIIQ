using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api")]
[Authorize]
public sealed class RolesController : ControllerBase
{
    private readonly RolRepository _repo;
    public RolesController(RolRepository repo) => _repo = repo;

    /// <summary>Lista de roles (para selección); accesible a cualquier autenticado.</summary>
    [HttpGet("roles")]
    public async Task<ActionResult<IReadOnlyList<RolConPermisosDto>>> Roles(CancellationToken ct)
        => Ok(await _repo.ListRolesAsync(ct));

    [HttpGet("permisos")]
    [Authorize(Policy = "roles.gestionar")]
    public async Task<ActionResult<IReadOnlyList<PermisoDto>>> Permisos(CancellationToken ct)
        => Ok(await _repo.ListPermisosAsync(ct));

    [HttpPut("roles/{id:int}/permisos")]
    [Authorize(Policy = "roles.gestionar")]
    public async Task<IActionResult> SetPermisos(int id, SetPermisosRequest req, CancellationToken ct)
    {
        await _repo.SetPermisosAsync(User.GetUserId(), id, req.Permisos, ct);
        return NoContent();
    }
}
