using System.Data;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

public sealed class UsuarioRepository
{
    private readonly IDbConnectionFactory _factory;
    public UsuarioRepository(IDbConnectionFactory factory) => _factory = factory;

    public async Task<UsuarioAuth?> GetForLoginAsync(string usuario, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT u.id, u.nombre_completo, u.usuario, u.password_hash, r.nombre AS rol, u.activo
            FROM usuarios u
            JOIN roles r ON r.id = u.rol_id
            WHERE u.usuario = @usuario";
        return await con.QueryFirstOrDefaultAsync<UsuarioAuth>(
            new CommandDefinition(sql, new { usuario }, cancellationToken: ct));
    }

    public async Task<IReadOnlyList<string>> GetPermisosAsync(int usuarioId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT p.codigo
            FROM usuarios u
            JOIN rol_permiso rp ON rp.rol_id = u.rol_id
            JOIN permisos p     ON p.id = rp.permiso_id
            WHERE u.id = @id
            ORDER BY p.codigo";
        var permisos = await con.QueryAsync<string>(
            new CommandDefinition(sql, new { id = usuarioId }, cancellationToken: ct));
        return permisos.AsList();
    }

    // ---------- Administración de usuarios ----------

    public async Task<IReadOnlyList<UsuarioListDto>> ListAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT u.id, u.nombre_completo, u.usuario, u.email,
                   u.rol_id, r.nombre AS rol, u.activo
            FROM usuarios u
            JOIN roles r ON r.id = u.rol_id
            ORDER BY u.nombre_completo";
        var rows = await con.QueryAsync<UsuarioListDto>(new CommandDefinition(sql, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<UsuarioListDto?> GetByIdAsync(int id, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT u.id, u.nombre_completo, u.usuario, u.email,
                   u.rol_id, r.nombre AS rol, u.activo
            FROM usuarios u
            JOIN roles r ON r.id = u.rol_id
            WHERE u.id = @id";
        return await con.QueryFirstOrDefaultAsync<UsuarioListDto>(
            new CommandDefinition(sql, new { id }, cancellationToken: ct));
    }

    public async Task<CrearUsuarioResult> CrearAsync(
        int actorId, CrearUsuarioRequest req, string passwordHash, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_actor_id", actorId);
        p.Add("p_nombre_completo", req.NombreCompleto);
        p.Add("p_usuario", req.Usuario);
        p.Add("p_password_hash", passwordHash);
        p.Add("p_email", req.Email);
        p.Add("p_rol_id", req.RolId);
        return await con.QueryFirstAsync<CrearUsuarioResult>(
            new CommandDefinition("sp_usuario_crear", p,
                commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task EditarAsync(
        int actorId, int usuarioId, EditarUsuarioRequest req, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_actor_id", actorId);
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_nombre_completo", req.NombreCompleto);
        p.Add("p_email", req.Email);
        p.Add("p_rol_id", req.RolId);
        await con.ExecuteAsync(new CommandDefinition("sp_usuario_editar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task CambiarEstadoAsync(
        int actorId, int usuarioId, bool activo, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_actor_id", actorId);
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_activo", activo ? 1 : 0);
        await con.ExecuteAsync(new CommandDefinition("sp_usuario_estado", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task CambiarPasswordAsync(
        int actorId, int usuarioId, string passwordHash, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_actor_id", actorId);
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_password_hash", passwordHash);
        await con.ExecuteAsync(new CommandDefinition("sp_usuario_password", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }
}
