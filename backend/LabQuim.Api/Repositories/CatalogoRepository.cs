using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

public sealed class CatalogoRepository
{
    private readonly IDbConnectionFactory _factory;
    public CatalogoRepository(IDbConnectionFactory factory) => _factory = factory;

    private async Task<IReadOnlyList<CatalogoItemDto>> ItemsAsync(string sql, CancellationToken ct)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var rows = await con.QueryAsync<CatalogoItemDto>(new CommandDefinition(sql, cancellationToken: ct));
        return rows.AsList();
    }

    public Task<IReadOnlyList<CatalogoItemDto>> LaboratoriosAsync(CancellationToken ct = default) =>
        ItemsAsync("SELECT id, nombre FROM laboratorios WHERE activo = 1 ORDER BY nombre", ct);

    public Task<IReadOnlyList<CatalogoItemDto>> CategoriasAsync(CancellationToken ct = default) =>
        ItemsAsync("SELECT id, nombre FROM categorias WHERE activo = 1 ORDER BY nombre", ct);

    public Task<IReadOnlyList<CatalogoItemDto>> ProveedoresAsync(CancellationToken ct = default) =>
        ItemsAsync("SELECT id, nombre FROM proveedores WHERE activo = 1 ORDER BY nombre", ct);

    public Task<IReadOnlyList<CatalogoItemDto>> UbicacionesAsync(CancellationToken ct = default) =>
        ItemsAsync("SELECT id, nombre FROM ubicaciones WHERE activo = 1 ORDER BY nombre", ct);

    public Task<IReadOnlyList<CatalogoItemDto>> ProfesoresAsync(CancellationToken ct = default) =>
        ItemsAsync(@"SELECT u.id, u.nombre_completo AS nombre
                     FROM usuarios u JOIN roles r ON r.id = u.rol_id
                     WHERE u.activo = 1 AND r.nombre = 'Profesor'
                     ORDER BY u.nombre_completo", ct);

    /// <summary>Clases activas; si viene profesorId, solo las que imparte ese profesor.</summary>
    public async Task<IReadOnlyList<ClaseItemDto>> ClasesAsync(int? profesorId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT c.id, c.nombre, c.anio FROM clases c
            WHERE c.activo = 1
              AND (@profesorId IS NULL OR EXISTS (
                    SELECT 1 FROM clase_profesor cp WHERE cp.clase_id = c.id AND cp.profesor_id = @profesorId))
            ORDER BY c.anio, c.nombre";
        var rows = await con.QueryAsync<ClaseItemDto>(new CommandDefinition(sql, new { profesorId }, cancellationToken: ct));
        return rows.AsList();
    }

    /// <summary>Prácticas activas de una clase, con su laboratorio.</summary>
    public async Task<IReadOnlyList<PracticaItemDto>> PracticasAsync(int claseId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT p.id, p.nombre, l.nombre AS laboratorio
            FROM practicas p JOIN laboratorios l ON l.id = p.laboratorio_id
            WHERE p.clase_id = @claseId AND p.activo = 1
            ORDER BY p.nombre";
        var rows = await con.QueryAsync<PracticaItemDto>(new CommandDefinition(sql, new { claseId }, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<IReadOnlyList<UnidadDto>> UnidadesAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = "SELECT id, nombre, abreviatura FROM unidades_medida WHERE activo = 1 ORDER BY nombre";
        var rows = await con.QueryAsync<UnidadDto>(new CommandDefinition(sql, cancellationToken: ct));
        return rows.AsList();
    }
}
