using System.Data;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

public sealed class SolicitudRepository
{
    private readonly IDbConnectionFactory _factory;
    public SolicitudRepository(IDbConnectionFactory factory) => _factory = factory;

    // ---------- Escrituras (stored procedures) ----------

    public async Task<CrearSolicitudResult> CrearAsync(
        int profesorId, int laboratorioId, DateOnly? fechaRequerida,
        string? observaciones, string detalleJson, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_profesor_id", profesorId);
        p.Add("p_laboratorio_id", laboratorioId);
        p.Add("p_fecha_requerida", fechaRequerida?.ToDateTime(TimeOnly.MinValue));
        p.Add("p_observaciones", observaciones);
        p.Add("p_detalle_json", detalleJson);
        return await con.QueryFirstAsync<CrearSolicitudResult>(
            new CommandDefinition("sp_solicitud_crear", p,
                commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task AprobarAsync(int solicitudId, int supervisorId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_supervisor_id", supervisorId);
        await con.ExecuteAsync(new CommandDefinition("sp_solicitud_aprobar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task RechazarAsync(int solicitudId, int supervisorId, string motivo, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_supervisor_id", supervisorId);
        p.Add("p_motivo", motivo);
        await con.ExecuteAsync(new CommandDefinition("sp_solicitud_rechazar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task<PrepararResult> PrepararAsync(int solicitudId, int bodegaId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_bodega_id", bodegaId);
        return await con.QueryFirstAsync<PrepararResult>(
            new CommandDefinition("sp_solicitud_preparar", p,
                commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task EntregarAsync(int solicitudId, int bodegaId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_bodega_id", bodegaId);
        await con.ExecuteAsync(new CommandDefinition("sp_solicitud_entregar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task DevolverAsync(int solicitudId, int bodegaId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_bodega_id", bodegaId);
        await con.ExecuteAsync(new CommandDefinition("sp_solicitud_devolver", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    // ---------- Lecturas ----------

    public async Task<IReadOnlyList<SolicitudHeader>> ListAsync(
        string? estado, int? profesorId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT s.id, s.estado, s.profesor_id, pu.nombre_completo AS profesor,
                   s.supervisor_id, s.bodega_id, s.laboratorio_id, l.nombre AS laboratorio,
                   s.fecha_solicitud, s.fecha_requerida, s.motivo_rechazo, s.observaciones
            FROM solicitudes s
            JOIN usuarios pu    ON pu.id = s.profesor_id
            JOIN laboratorios l ON l.id = s.laboratorio_id
            WHERE (@estado IS NULL OR s.estado = @estado)
              AND (@profesorId IS NULL OR s.profesor_id = @profesorId)
            ORDER BY s.id DESC";
        var rows = await con.QueryAsync<SolicitudHeader>(
            new CommandDefinition(sql, new { estado, profesorId }, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<SolicitudDetalleDto?> GetByIdAsync(int id, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);

        const string sqlHeader = @"
            SELECT s.id, s.estado, s.profesor_id, pu.nombre_completo AS profesor,
                   s.supervisor_id, s.bodega_id, s.laboratorio_id, l.nombre AS laboratorio,
                   s.fecha_solicitud, s.fecha_requerida, s.motivo_rechazo, s.observaciones
            FROM solicitudes s
            JOIN usuarios pu    ON pu.id = s.profesor_id
            JOIN laboratorios l ON l.id = s.laboratorio_id
            WHERE s.id = @id";
        var header = await con.QueryFirstOrDefaultAsync<SolicitudHeader>(
            new CommandDefinition(sqlHeader, new { id }, cancellationToken: ct));
        if (header is null) return null;

        const string sqlLineas = @"
            SELECT sd.id, sd.articulo_id, a.nombre AS articulo, a.tipo,
                   um.abreviatura AS unidad,
                   sd.cantidad_solicitada AS cant_solicitada,
                   sd.cantidad_preparada  AS cant_preparada,
                   sd.cantidad_devuelta   AS cant_devuelta,
                   sd.lote_id
            FROM solicitud_detalle sd
            JOIN articulos a        ON a.id = sd.articulo_id
            JOIN unidades_medida um ON um.id = sd.unidad_id
            WHERE sd.solicitud_id = @id
            ORDER BY sd.id";
        var lineas = await con.QueryAsync<SolicitudLineaDto>(
            new CommandDefinition(sqlLineas, new { id }, cancellationToken: ct));

        return new SolicitudDetalleDto { Cabecera = header, Lineas = lineas.AsList() };
    }
}
