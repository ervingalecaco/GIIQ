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

    public async Task<IReadOnlyList<UnidadDto>> UnidadesAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = "SELECT id, nombre, abreviatura FROM unidades_medida WHERE activo = 1 ORDER BY nombre";
        var rows = await con.QueryAsync<UnidadDto>(new CommandDefinition(sql, cancellationToken: ct));
        return rows.AsList();
    }
}
