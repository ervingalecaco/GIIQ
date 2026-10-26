using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

/// <summary>
/// Notificaciones del usuario. Las crean los procedimientos del flujo (solicitudes,
/// bajas, reposiciones); aquí solo se leen y se marcan como leídas, siempre las del propio usuario.
/// </summary>
public sealed class NotificacionRepository
{
    private readonly IDbConnectionFactory _factory;
    public NotificacionRepository(IDbConnectionFactory factory) => _factory = factory;

    public async Task<int> NoLeidasAsync(int usuarioId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        return await con.ExecuteScalarAsync<int>(new CommandDefinition(
            "SELECT COUNT(*) FROM notificaciones WHERE usuario_id = @usuarioId AND leida = 0",
            new { usuarioId }, cancellationToken: ct));
    }

    /// <summary>Las más recientes primero; con <paramref name="soloNoLeidas"/>, solo las pendientes.</summary>
    public async Task<NotificacionesDto> ListAsync(int usuarioId, bool soloNoLeidas, int limite, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var items = await con.QueryAsync<NotificacionDto>(new CommandDefinition(@"
            SELECT id, tipo, titulo, mensaje, enlace, solicitud_id, leida, creada_en
            FROM notificaciones
            WHERE usuario_id = @usuarioId AND (@soloNoLeidas = 0 OR leida = 0)
            ORDER BY creada_en DESC, id DESC
            LIMIT @limite",
            new { usuarioId, soloNoLeidas, limite }, cancellationToken: ct));
        return new NotificacionesDto { NoLeidas = await NoLeidasAsync(usuarioId, ct), Items = items.AsList() };
    }

    public async Task MarcarLeidaAsync(int usuarioId, long id, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        await con.ExecuteAsync(new CommandDefinition(@"
            UPDATE notificaciones SET leida = 1, leida_en = NOW()
            WHERE id = @id AND usuario_id = @usuarioId AND leida = 0",
            new { id, usuarioId }, cancellationToken: ct));
    }

    public async Task MarcarTodasAsync(int usuarioId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        await con.ExecuteAsync(new CommandDefinition(@"
            UPDATE notificaciones SET leida = 1, leida_en = NOW()
            WHERE usuario_id = @usuarioId AND leida = 0",
            new { usuarioId }, cancellationToken: ct));
    }
}
