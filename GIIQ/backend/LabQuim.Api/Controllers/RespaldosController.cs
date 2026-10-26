using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/respaldos")]
[Authorize(Policy = "respaldo.gestionar")]
public sealed class RespaldosController : ControllerBase
{
    private readonly BackupService _backup;
    public RespaldosController(BackupService backup) => _backup = backup;

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<RespaldoDto>>> List(CancellationToken ct)
        => Ok(await _backup.ListAsync(ct));

    [HttpPost]
    public async Task<ActionResult<RespaldoDto>> Crear(CancellationToken ct)
    {
        try { return Ok(await _backup.CrearAsync(User.GetUserId(), ct)); }
        catch (Exception ex) { return BadRequest(new { detail = $"No se pudo crear el respaldo: {ex.Message}" }); }
    }

    [HttpGet("{id:int}/download")]
    public async Task<IActionResult> Download(int id, CancellationToken ct)
    {
        var archivo = await _backup.ArchivoAsync(id, ct);
        if (archivo is null) return NotFound(new { detail = "El archivo de respaldo no existe." });
        var bytes = await System.IO.File.ReadAllBytesAsync(archivo.Value.Ruta, ct);
        return File(bytes, "application/sql", archivo.Value.Nombre);
    }

    [HttpPost("restore")]
    [RequestSizeLimit(100_000_000)] // 100 MB
    public async Task<IActionResult> Restore([FromForm] IFormFile archivo, CancellationToken ct)
    {
        if (archivo is null || archivo.Length == 0)
            return BadRequest(new { detail = "Debes subir un archivo .sql." });
        if (!archivo.FileName.EndsWith(".sql", StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { detail = "El archivo debe tener extensión .sql." });

        try
        {
            await using var stream = archivo.OpenReadStream();
            await _backup.RestoreAsync(stream, ct);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { detail = $"No se pudo restaurar: {ex.Message}" });
        }
    }
}
