using System.Data;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

/// <summary>Bajas de cristalería, cuentas de estudiantes (piezas por reponer) y constancias de solvencia.</summary>
public sealed class BajaRepository
{
    private readonly IDbConnectionFactory _factory;
    public BajaRepository(IDbConnectionFactory factory) => _factory = factory;

    public async Task<IReadOnlyList<BajaDto>> ListAsync(DateOnly desde, DateOnly hasta, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT b.id, b.fecha, b.articulo_id, a.codigo, a.nombre AS articulo, um.abreviatura AS unidad,
                   b.cantidad, b.causa, b.solicitud_id, b.estudiante_id,
                   e.nombre_completo AS estudiante, e.codigo AS estudiante_codigo,
                   r.nombre_completo AS registrado_por, b.observacion, c.estado AS estado_cargo
            FROM bajas b
            JOIN articulos a          ON a.id = b.articulo_id
            JOIN unidades_medida um   ON um.id = a.unidad_id
            JOIN usuarios r           ON r.id = b.registrado_por
            LEFT JOIN usuarios e      ON e.id = b.estudiante_id
            LEFT JOIN cargos_estudiante c ON c.baja_id = b.id
            WHERE b.fecha >= @desde AND b.fecha < @hasta
            ORDER BY b.fecha DESC, b.id DESC";
        var rows = await con.QueryAsync<BajaDto>(new CommandDefinition(sql,
            new { desde = desde.ToDateTime(TimeOnly.MinValue), hasta = hasta.AddDays(1).ToDateTime(TimeOnly.MinValue) },
            cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<int> RegistrarAsync(int usuarioId, RegistrarBajaRequest req, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_articulo_id", req.ArticuloId);
        p.Add("p_cantidad", req.Cantidad);
        p.Add("p_causa", req.Causa);
        p.Add("p_estudiante_id", req.EstudianteId);
        p.Add("p_observacion", req.Observacion);
        return await con.QueryFirstAsync<int>(new CommandDefinition("sp_baja_registrar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    // ---------- Cuentas ----------

    private const string SelectResumen = @"
            SELECT u.id AS estudiante_id, u.codigo, u.nombre_completo AS estudiante, u.activo,
                   COUNT(CASE WHEN c.estado = 'PENDIENTE' THEN 1 END) AS cargos_pendientes,
                   COALESCE(SUM(CASE WHEN c.estado = 'PENDIENTE' THEN c.cantidad - c.cantidad_repuesta END), 0) AS piezas_pendientes,
                   COUNT(c.id) AS cargos_totales,
                   MAX(c.fecha) AS ultima_baja
            FROM usuarios u
            JOIN roles ro ON ro.id = u.rol_id AND ro.nombre = 'Estudiante'
            LEFT JOIN cargos_estudiante c ON c.estudiante_id = u.id";

    /// <summary>Estudiantes que tienen o tuvieron cargos, los que deben primero.</summary>
    public async Task<IReadOnlyList<CuentaResumenDto>> CuentasAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var rows = await con.QueryAsync<CuentaResumenDto>(new CommandDefinition(
            SelectResumen + @"
            GROUP BY u.id, u.codigo, u.nombre_completo, u.activo
            HAVING cargos_totales > 0
            ORDER BY piezas_pendientes DESC, estudiante", cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<CuentaDetalleDto?> CuentaAsync(int estudianteId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var resumen = await con.QueryFirstOrDefaultAsync<CuentaResumenDto>(new CommandDefinition(
            SelectResumen + @"
            WHERE u.id = @estudianteId
            GROUP BY u.id, u.codigo, u.nombre_completo, u.activo",
            new { estudianteId }, cancellationToken: ct));
        if (resumen is null) return null;

        var cargos = await con.QueryAsync<CargoDto>(new CommandDefinition(@"
            SELECT c.id, c.baja_id, c.fecha, c.articulo_id, a.codigo, a.nombre AS articulo, um.abreviatura AS unidad,
                   c.cantidad, c.cantidad_repuesta, c.estado, c.saldado_en,
                   b.causa, b.solicitud_id, b.observacion, ai.actualizado_en AS imagen_actualizada
            FROM cargos_estudiante c
            JOIN bajas b              ON b.id = c.baja_id
            JOIN articulos a          ON a.id = c.articulo_id
            JOIN unidades_medida um   ON um.id = a.unidad_id
            LEFT JOIN articulo_imagen ai ON ai.articulo_id = a.id
            WHERE c.estudiante_id = @estudianteId
            ORDER BY c.estado = 'PENDIENTE' DESC, c.fecha DESC",
            new { estudianteId }, cancellationToken: ct));

        var reposiciones = await con.QueryAsync<ReposicionDto>(new CommandDefinition(@"
            SELECT rp.id, rp.cargo_id, rp.fecha, a.nombre AS articulo, rp.cantidad,
                   u.nombre_completo AS recibido_por, rp.observacion
            FROM reposiciones rp
            JOIN cargos_estudiante c ON c.id = rp.cargo_id
            JOIN articulos a         ON a.id = c.articulo_id
            JOIN usuarios u          ON u.id = rp.recibido_por
            WHERE c.estudiante_id = @estudianteId
            ORDER BY rp.fecha DESC",
            new { estudianteId }, cancellationToken: ct));

        return new CuentaDetalleDto { Resumen = resumen, Cargos = cargos.AsList(), Reposiciones = reposiciones.AsList() };
    }

    public async Task ReponerAsync(int usuarioId, int cargoId, RegistrarReposicionRequest req, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_cargo_id", cargoId);
        p.Add("p_cantidad", req.Cantidad);
        p.Add("p_observacion", req.Observacion);
        await con.ExecuteAsync(new CommandDefinition("sp_reposicion_registrar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    /// <summary>Estudiantes activos, para elegir al responsable de una baja.</summary>
    public async Task<IReadOnlyList<EstudianteOpcionDto>> EstudiantesAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var rows = await con.QueryAsync<EstudianteOpcionDto>(new CommandDefinition(@"
            SELECT u.id, u.codigo, u.nombre_completo AS nombre
            FROM usuarios u JOIN roles r ON r.id = u.rol_id
            WHERE r.nombre = 'Estudiante' AND u.activo = 1
            ORDER BY u.nombre_completo", cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<ConstanciaDto> EmitirConstanciaAsync(int usuarioId, int estudianteId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_estudiante_id", estudianteId);
        var folio = await con.QueryFirstAsync<(int Folio, DateTime Fecha)>(new CommandDefinition(
            "sp_constancia_emitir", p, commandType: CommandType.StoredProcedure, cancellationToken: ct));
        return (await ConstanciaAsync(folio.Folio, ct))!;
    }

    /// <summary>Constancia ya emitida (para imprimirla o reimprimirla).</summary>
    public async Task<ConstanciaDto?> ConstanciaAsync(int folio, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        return await con.QueryFirstOrDefaultAsync<ConstanciaDto>(new CommandDefinition(@"
            SELECT k.id AS folio, k.fecha, e.nombre_completo AS estudiante, e.codigo, b.nombre_completo AS emitida_por
            FROM constancias_solvencia k
            JOIN usuarios e ON e.id = k.estudiante_id
            JOIN usuarios b ON b.id = k.emitida_por
            WHERE k.id = @folio", new { folio }, cancellationToken: ct));
    }
}
