using LabQuim.Api.Auth;
using LabQuim.Api.Models;
using LabQuim.Api.Repositories;
using LabQuim.Api.Services;
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

    /// <summary>Lista artículos; filtra por tipo (REACTIVO | CRISTALERIA).</summary>
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

    /// <summary>
    /// Paso 1 de la importación: lee el Excel (hoja "cristaleria") y devuelve las filas
    /// propuestas, ya corregidas, para revisarlas. No guarda nada.
    /// </summary>
    [HttpPost("importar/cristaleria/previsualizar")]
    [Authorize(Policy = "articulos.crear")]
    [RequestSizeLimit(10_000_000)] // 10 MB
    public async Task<ActionResult<List<FilaImportacionDto>>> PrevisualizarImportacion(
        [FromForm] IFormFile archivo, CancellationToken ct)
    {
        if (archivo is null || archivo.Length == 0)
            return Problem(detail: "Sube el archivo de Excel.", statusCode: 400);
        if (!archivo.FileName.EndsWith(".xlsx", StringComparison.OrdinalIgnoreCase))
            return Problem(detail: "El archivo debe ser un Excel .xlsx.", statusCode: 400);

        var codigos = await _repo.CodigosAsync(ct);
        try
        {
            await using var stream = archivo.OpenReadStream();
            return Ok(ImportadorCristaleria.Leer(stream, codigos));
        }
        catch (Exception ex) when (ex is InvalidOperationException or ArgumentException or IOException)
        {
            return Problem(detail: $"No se pudo leer el Excel: {ex.Message}", statusCode: 400);
        }
    }

    /// <summary>
    /// Paso 2: crea los artículos de cristalería revisados y registra su existencia inicial
    /// (un solo movimiento ENTRADA). Los códigos que ya existen se omiten.
    /// </summary>
    [HttpPost("importar/cristaleria")]
    [Authorize(Policy = "articulos.crear")]
    public async Task<ActionResult<ImportarResult>> ImportarCristaleria(
        ImportarCristaleriaRequest req, CancellationToken ct)
    {
        // Cargar existencias es una entrada de stock: también hace falta ese permiso.
        if (!User.IsInRole("Administrador") && !User.HasClaim("permiso", "entrada.registrar"))
            return Forbid();
        return Ok(await _repo.ImportarCristaleriaAsync(User.GetUserId(), req.Filas, ct));
    }

    /// <summary>Foto de referencia (cristalería). El cliente agrega ?v=fecha, así que se puede guardar en caché.</summary>
    [HttpGet("{id:int}/imagen")]
    [Authorize(Policy = "articulos.ver")]
    public async Task<IActionResult> Imagen(int id, CancellationToken ct)
    {
        var img = await _repo.ImagenAsync(id, ct);
        if (img is null) return NotFound();
        Response.Headers.CacheControl = "private, max-age=31536000, immutable";
        return File(img.Contenido, img.TipoMime);
    }

    /// <summary>Pone o reemplaza la foto de referencia. El navegador ya la reduce antes de subirla.</summary>
    [HttpPut("{id:int}/imagen")]
    [Authorize(Policy = "articulos.editar")]
    [RequestSizeLimit(4_000_000)]
    public async Task<IActionResult> GuardarImagen(int id, [FromForm] IFormFile archivo, CancellationToken ct)
    {
        if (archivo is null || archivo.Length == 0)
            return Problem(detail: "Sube una imagen.", statusCode: 400);
        if (archivo.Length > MaxImagenBytes)
            return Problem(detail: "La imagen no debe pasar de 2 MB.", statusCode: 400);

        using var ms = new MemoryStream();
        await archivo.CopyToAsync(ms, ct);
        var bytes = ms.ToArray();
        // El tipo se decide por el contenido, no por la extensión ni lo que diga el navegador.
        var mime = TipoImagen(bytes);
        if (mime is null)
            return Problem(detail: "La imagen debe ser JPG, PNG o WebP.", statusCode: 400);

        await _repo.GuardarImagenAsync(User.GetUserId(), id, bytes, mime, ct);
        return NoContent();
    }

    [HttpDelete("{id:int}/imagen")]
    [Authorize(Policy = "articulos.editar")]
    public async Task<IActionResult> QuitarImagen(int id, CancellationToken ct)
    {
        await _repo.QuitarImagenAsync(User.GetUserId(), id, ct);
        return NoContent();
    }

    private const int MaxImagenBytes = 2 * 1024 * 1024;

    /// <summary>Reconoce JPG, PNG y WebP por su firma (primeros bytes).</summary>
    private static string? TipoImagen(byte[] b)
    {
        if (b.Length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return "image/jpeg";
        if (b.Length >= 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return "image/png";
        if (b.Length >= 12 && b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46
            && b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) return "image/webp";
        return null;
    }

    [HttpPost("{id:int}/estado")]
    [Authorize(Policy = "articulos.eliminar")]
    public async Task<IActionResult> CambiarEstado(int id, EstadoArticuloRequest req, CancellationToken ct)
    {
        await _repo.CambiarEstadoAsync(User.GetUserId(), id, req.Activo, ct);
        return NoContent();
    }
}
