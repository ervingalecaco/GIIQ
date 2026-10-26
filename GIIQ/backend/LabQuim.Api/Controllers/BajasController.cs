using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using LabQuim.Api.Services;
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

    private static DateOnly Hoy => DateOnly.FromDateTime(DateTime.Today);
    /// <summary>Límite inferior de "todas las fechas" (anterior a cualquier dato del sistema).</summary>
    private static readonly DateOnly Inicio = new(2000, 1, 1);

    /// <summary>Bajas del período; sin <c>desde</c>, desde el inicio ("todas las fechas").</summary>
    [HttpGet]
    [Authorize(Policy = "cuentas.ver")]
    public async Task<ActionResult<IReadOnlyList<BajaDto>>> List(
        [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
        => Ok(await _repo.ListAsync(desde ?? Inicio, hasta ?? Hoy, ct));

    /// <summary>Las mismas bajas del listado, en Excel.</summary>
    [HttpGet("excel")]
    [Authorize(Policy = "cuentas.ver")]
    public async Task<IActionResult> Excel([FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
    {
        var datos = await _repo.ListAsync(desde ?? Inicio, hasta ?? Hoy, ct);
        var bytes = ExcelExporter.Build("Bajas",
            new[] { "Fecha", "Código", "Artículo", "Cantidad", "Unidad", "Causa", "Cód. estudiante", "Estudiante responsable",
                    "Cargo", "Solicitud", "Registrada por", "Observación" },
            datos.Select(b => new object?[]
            {
                b.Fecha, b.Codigo, b.Articulo, b.Cantidad, b.Unidad, TextoCausa(b.Causa), b.EstudianteCodigo, b.Estudiante,
                b.EstadoCargo switch { "PENDIENTE" => "Pendiente", "SALDADO" => "Saldado", _ => "Sin responsable" },
                b.SolicitudId is { } s ? $"#{s}" : null, b.RegistradoPor, b.Observacion,
            }));
        return File(bytes, ExcelExporter.ContentType, $"bajas_{Hoy:yyyyMMdd}.xlsx");
    }

    private static string TextoCausa(string causa) => causa switch
    {
        "QUEBRADO" => "Quebrado", "EXTRAVIADO" => "Extraviado", "DETERIORADO" => "Deteriorado", _ => causa,
    };

    [HttpPost]
    [Authorize(Policy = "baja.registrar")]
    public async Task<ActionResult<object>> Registrar(RegistrarBajaRequest req, CancellationToken ct)
        => Ok(new { bajaId = await _repo.RegistrarAsync(User.GetUserId(), req, ct) });
}
