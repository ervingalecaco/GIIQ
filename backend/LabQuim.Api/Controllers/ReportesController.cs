using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using LabQuim.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabQuim.Api.Controllers;

[ApiController]
[Route("api/reportes")]
[Authorize(Policy = "reporte.ver")]
public sealed class ReportesController : ControllerBase
{
    private readonly ReporteRepository _repo;
    public ReportesController(ReporteRepository repo) => _repo = repo;

    private static DateOnly Hoy => DateOnly.FromDateTime(DateTime.Now);

    // ------------------------------------------------------------------ JSON
    [HttpGet("existencias")]
    public async Task<IActionResult> Existencias([FromQuery] bool bajoMinimo, CancellationToken ct)
        => Ok(await _repo.ExistenciasAsync(bajoMinimo, ct));

    [HttpGet("proximos-vencer")]
    public async Task<IActionResult> ProximosVencer([FromQuery] int dias = 30, CancellationToken ct = default)
        => Ok(await _repo.ProximosAVencerAsync(dias, ct));

    [HttpGet("lotes-vencidos")]
    public async Task<IActionResult> LotesVencidos(CancellationToken ct)
        => Ok(await _repo.LotesVencidosAsync(ct));

    [HttpGet("consumo-laboratorio")]
    public async Task<IActionResult> ConsumoLaboratorio(
        [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
        => Ok(await _repo.ConsumoLaboratorioAsync(desde ?? Hoy.AddDays(-30), hasta ?? Hoy, ct));

    [HttpGet("existencias/{articuloId:int}/lotes")]
    public async Task<IActionResult> LotesArticulo(int articuloId, CancellationToken ct)
        => Ok(await _repo.LotesArticuloAsync(articuloId, ct));

    [HttpGet("consumo-laboratorio/{laboratorioId:int}")]
    public async Task<IActionResult> ConsumoLaboratorioDetalle(
        int laboratorioId, [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
        => Ok(await _repo.ConsumoLaboratorioDetalleAsync(laboratorioId, desde ?? Hoy.AddDays(-30), hasta ?? Hoy, ct));

    [HttpGet("entradas-proveedor")]
    public async Task<IActionResult> EntradasProveedor(
        [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
        => Ok(await _repo.EntradasProveedorAsync(desde ?? Hoy.AddDays(-30), hasta ?? Hoy, ct));

    [HttpGet("kardex")]
    public async Task<IActionResult> Kardex(
        [FromQuery] int articuloId, [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
        => Ok(await _repo.KardexAsync(articuloId, desde ?? Hoy.AddDays(-90), hasta ?? Hoy, ct));

    // ------------------------------------------------------------------ Excel
    [HttpGet("existencias/excel")]
    public async Task<IActionResult> ExistenciasExcel([FromQuery] bool bajoMinimo, CancellationToken ct)
    {
        var datos = await _repo.ExistenciasAsync(bajoMinimo, ct);
        var bytes = ExcelExporter.Build("Existencias",
            new[] { "Código", "Artículo", "Tipo", "Unidad", "Existencia", "Stock mínimo", "Bajo mínimo" },
            datos.Select(e => new object?[]
            {
                e.Codigo, e.Nombre, e.Tipo, e.Unidad, e.Existencia, e.StockMinimo, e.BajoMinimo ? "Sí" : "No"
            }));
        return Xlsx(bytes, "existencias");
    }

    [HttpGet("proximos-vencer/excel")]
    public async Task<IActionResult> ProximosVencerExcel([FromQuery] int dias = 30, CancellationToken ct = default)
    {
        var datos = await _repo.ProximosAVencerAsync(dias, ct);
        var bytes = ExcelExporter.Build("Proximos a vencer",
            new[] { "Código", "Artículo", "Lote", "Vencimiento", "Días restantes", "Cantidad", "Ubicación" },
            datos.Select(d => new object?[]
            {
                d.Codigo, d.Nombre, d.CodigoLote,
                d.FechaVencimiento?.ToString("yyyy-MM-dd"), d.DiasRestantes, d.CantidadActual, d.Ubicacion
            }));
        return Xlsx(bytes, "proximos_a_vencer");
    }

    [HttpGet("consumo-laboratorio/excel")]
    public async Task<IActionResult> ConsumoLaboratorioExcel(
        [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
    {
        var datos = await _repo.ConsumoLaboratorioAsync(desde ?? Hoy.AddDays(-30), hasta ?? Hoy, ct);
        var bytes = ExcelExporter.Build("Consumo por laboratorio",
            new[] { "Laboratorio", "Despachos", "Líneas" },
            datos.Select(d => new object?[] { d.Laboratorio, d.Despachos, d.Lineas }));
        return Xlsx(bytes, "consumo_laboratorio");
    }

    [HttpGet("kardex/excel")]
    public async Task<IActionResult> KardexExcel(
        [FromQuery] int articuloId, [FromQuery] DateOnly? desde, [FromQuery] DateOnly? hasta, CancellationToken ct)
    {
        var datos = await _repo.KardexAsync(articuloId, desde ?? Hoy.AddDays(-90), hasta ?? Hoy, ct);
        var bytes = ExcelExporter.Build("Kardex",
            new[] { "Fecha", "Tipo", "Cantidad", "Lote", "Motivo" },
            datos.Select(k => new object?[]
            {
                k.Fecha.ToString("yyyy-MM-dd HH:mm"), k.Tipo, k.Cantidad, k.CodigoLote, k.Motivo
            }));
        return Xlsx(bytes, $"kardex_{articuloId}");
    }

    private FileContentResult Xlsx(byte[] bytes, string nombre)
        => File(bytes, ExcelExporter.ContentType, $"{nombre}_{Hoy:yyyyMMdd}.xlsx");
}
