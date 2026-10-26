using System.Data;
using System.Text.Json;
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
        int profesorId, int? estudianteId, string tipo, int practicaId, DateOnly? fechaRequerida,
        string? observaciones, string detalleJson, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_profesor_id", profesorId);
        p.Add("p_estudiante_id", estudianteId);
        p.Add("p_tipo", tipo);
        p.Add("p_practica_id", practicaId);
        p.Add("p_fecha_requerida", fechaRequerida?.ToDateTime(TimeOnly.MinValue));
        p.Add("p_observaciones", observaciones);
        p.Add("p_detalle_json", detalleJson);
        return await con.QueryFirstAsync<CrearSolicitudResult>(
            new CommandDefinition("sp_solicitud_crear", p,
                commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task AvalarAsync(int solicitudId, int usuarioId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_usuario_id", usuarioId);
        await con.ExecuteAsync(new CommandDefinition("sp_solicitud_avalar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task RechazarProfesorAsync(int solicitudId, int usuarioId, string motivo, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_motivo", motivo);
        await con.ExecuteAsync(new CommandDefinition("sp_solicitud_rechazar_profesor", p,
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

    /// <summary>Cierra la devolución; las piezas quebradas se dan de baja y se cargan a su responsable.</summary>
    public async Task DevolverAsync(int solicitudId, int bodegaId, IReadOnlyList<PiezaQuebradaRequest> quebradas,
        CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_solicitud_id", solicitudId);
        p.Add("p_bodega_id", bodegaId);
        p.Add("p_quebradas", JsonSerializer.Serialize(quebradas.Select(q => new
        {
            articulo_id = q.ArticuloId,
            cantidad = q.Cantidad,
            estudiante_id = q.EstudianteId,
            causa = q.Causa,
            observacion = string.IsNullOrWhiteSpace(q.Observacion) ? null : q.Observacion.Trim(),
        })));
        await con.ExecuteAsync(new CommandDefinition("sp_solicitud_devolver", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    // ---------- Lecturas ----------

    private const string SelectHeader = @"
            SELECT s.id, s.tipo, s.estado, s.profesor_id, pu.nombre_completo AS profesor,
                   s.estudiante_id, eu.nombre_completo AS estudiante, s.fecha_aval_profesor,
                   s.supervisor_id, s.bodega_id,
                   s.practica_id, pr.nombre AS practica, pr.clase_id, c.nombre AS clase, c.anio AS clase_anio,
                   s.laboratorio_id, l.nombre AS laboratorio,
                   s.fecha_solicitud, s.fecha_requerida, s.motivo_rechazo, s.observaciones
            FROM solicitudes s
            JOIN usuarios pu       ON pu.id = s.profesor_id
            LEFT JOIN usuarios eu  ON eu.id = s.estudiante_id
            LEFT JOIN practicas pr ON pr.id = s.practica_id
            LEFT JOIN clases c     ON c.id = pr.clase_id
            JOIN laboratorios l    ON l.id = s.laboratorio_id";

    /// <param name="profesorId">Si viene, solo las de ese profesor responsable (incluye las de sus estudiantes).</param>
    /// <param name="estudianteId">Si viene, solo las creadas por ese estudiante.</param>
    /// <param name="desde">Fecha de solicitud mínima (incluida).</param>
    /// <param name="hasta">Fecha de solicitud máxima (incluido todo ese día).</param>
    public async Task<IReadOnlyList<SolicitudHeader>> ListAsync(
        string? tipo, string? estado, int? profesorId, int? estudianteId,
        DateOnly? desde, DateOnly? hasta, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = SelectHeader + @"
            WHERE (@tipo IS NULL OR s.tipo = @tipo)
              AND (@estado IS NULL OR s.estado = @estado)
              AND (@profesorId IS NULL OR s.profesor_id = @profesorId)
              AND (@estudianteId IS NULL OR s.estudiante_id = @estudianteId)
              AND (@desde IS NULL OR s.fecha_solicitud >= @desde)
              AND (@hastaExcl IS NULL OR s.fecha_solicitud < @hastaExcl)
            ORDER BY s.id DESC";
        var rows = await con.QueryAsync<SolicitudHeader>(new CommandDefinition(sql, new
        {
            tipo, estado, profesorId, estudianteId,
            desde = desde?.ToDateTime(TimeOnly.MinValue),
            // "hasta" incluye todo ese día: se compara con el inicio del día siguiente.
            hastaExcl = hasta?.AddDays(1).ToDateTime(TimeOnly.MinValue),
        }, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<SolicitudDetalleDto?> GetByIdAsync(int id, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);

        const string sqlHeader = SelectHeader + " WHERE s.id = @id";
        var header = await con.QueryFirstOrDefaultAsync<SolicitudHeader>(
            new CommandDefinition(sqlHeader, new { id }, cancellationToken: ct));
        if (header is null) return null;

        const string sqlLineas = @"
            SELECT sd.id, sd.articulo_id, a.nombre AS articulo, a.tipo,
                   um.abreviatura AS unidad,
                   sd.cantidad_solicitada AS cant_solicitada,
                   sd.cantidad_preparada  AS cant_preparada,
                   sd.cantidad_devuelta   AS cant_devuelta,
                   sd.cantidad_quebrada   AS cant_quebrada,
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
