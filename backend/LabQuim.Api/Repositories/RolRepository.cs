using System.Data;
using System.Text.Json;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

public sealed class RolRepository
{
    private readonly IDbConnectionFactory _factory;
    public RolRepository(IDbConnectionFactory factory) => _factory = factory;

    public async Task<IReadOnlyList<RolConPermisosDto>> ListRolesAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);

        var roles = (await con.QueryAsync<RolConPermisosDto>(new CommandDefinition(
            "SELECT id, nombre, descripcion FROM roles ORDER BY id", cancellationToken: ct))).AsList();

        var mapa = (await con.QueryAsync<(int RolId, string Codigo)>(new CommandDefinition(@"
            SELECT rp.rol_id, p.codigo
            FROM rol_permiso rp JOIN permisos p ON p.id = rp.permiso_id", cancellationToken: ct)))
            .GroupBy(x => x.RolId)
            .ToDictionary(g => g.Key, g => g.Select(x => x.Codigo).ToList());

        foreach (var r in roles)
            r.Permisos = mapa.TryGetValue(r.Id, out var list) ? list : new List<string>();

        return roles;
    }

    public async Task<IReadOnlyList<PermisoDto>> ListPermisosAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = "SELECT id, codigo, descripcion, modulo FROM permisos ORDER BY modulo, codigo";
        var rows = await con.QueryAsync<PermisoDto>(new CommandDefinition(sql, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task SetPermisosAsync(
        int actorId, int rolId, IEnumerable<string> permisos, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_actor_id", actorId);
        p.Add("p_rol_id", rolId);
        p.Add("p_permisos_json", JsonSerializer.Serialize(permisos));
        await con.ExecuteAsync(new CommandDefinition("sp_rol_permisos_set", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }
}
