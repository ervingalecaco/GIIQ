using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize(Policy = "dashboard.ver")]
public sealed class DashboardController : ControllerBase
{
    private readonly ReporteRepository _repo;
    public DashboardController(ReporteRepository repo) => _repo = repo;

    [HttpGet]
    public async Task<ActionResult<DashboardDto>> Get(CancellationToken ct)
        => Ok(await _repo.DashboardAsync(ct));
}
