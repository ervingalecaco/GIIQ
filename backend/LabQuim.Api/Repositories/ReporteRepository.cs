using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

public sealed class ReporteRepository
{
    private readonly IDbConnectionFactory _factory;
    public ReporteRepository(IDbConnectionFactory factory) => _factory = factory;

    // ------------------------------------------------------------------ Dashboard
    public async Task<DashboardDto> DashboardAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);

        var total = await con.ExecuteScalarAsync<int>(new CommandDefinition(
            "SELECT COUNT(*) FROM articulos WHERE activo = 1", cancellationToken: ct));

        var bajo = await con.ExecuteScalarAsync<int>(new CommandDefinition(@"
            SELECT COUNT(*) FROM (
                SELECT a.id
                FROM articulos a
                LEFT JOIN lotes l ON l.articulo_id = a.id AND l.activo = 1
                WHERE a.activo = 1
                GROUP BY a.id, a.stock_minimo
                HAVING COALESCE(SUM(l.cantidad_actual), 0) < a.stock_minimo
            ) t", cancellationToken: ct));

        var proximos = await con.ExecuteScalarAsync<int>(new CommandDefinition(@"
            SELECT COUNT(*) FROM lotes
            WHERE activo = 1 AND cantidad_actual > 0 AND fecha_vencimiento IS NOT NULL
              AND fecha_vencimiento BETWEEN CURDATE() AND CURDATE() + INTERVAL 30 DAY",
            cancellationToken: ct));

        var pendientes = await con.ExecuteScalarAsync<int>(new CommandDefinition(
            "SELECT COUNT(*) FROM solicitudes WHERE estado = 'PENDIENTE'", cancellationToken: ct));

        var porCategoria = (await con.QueryAsync<ConteoDto>(new CommandDefinition(@"
            SELECT c.nombre AS etiqueta, COUNT(a.id) AS cantidad
            FROM categorias c
            LEFT JOIN articulos a ON a.categoria_id = c.id AND a.activo = 1
            GROUP BY c.id, c.nombre
            HAVING COUNT(a.id) > 0
            ORDER BY cantidad DESC", cancellationToken: ct))).AsList();

        var vencRaw = (await con.QueryAsync<ConteoDto>(new CommandDefinition(@"
            SELECT CASE
                WHEN fecha_vencimiento < CURDATE() THEN 'Vencido'
                WHEN fecha_vencimiento <= CURDATE() + INTERVAL 30 DAY THEN '≤ 30 días'
                WHEN fecha_vencimiento <= CURDATE() + INTERVAL 90 DAY THEN '31–90 días'
                ELSE '> 90 días' END AS etiqueta,
                COUNT(*) AS cantidad
            FROM lotes
            WHERE activo = 1 AND cantidad_actual > 0 AND fecha_vencimiento IS NOT NULL
            GROUP BY etiqueta", cancellationToken: ct))).AsList();

        // Orden fijo de los buckets de vencimiento.
        var orden = new[] { "Vencido", "≤ 30 días", "31–90 días", "> 90 días" };
        var vencimientos = orden
            .Select(o => vencRaw.FirstOrDefault(v => v.Etiqueta == o) ?? new ConteoDto { Etiqueta = o, Cantidad = 0 })
            .ToList();

        var consumo = (await con.QueryAsync<ConteoDto>(new CommandDefinition(@"
            SELECT DATE_FORMAT(fecha, '%Y-%m') AS etiqueta, COUNT(*) AS cantidad
            FROM movimientos
            WHERE tipo = 'SALIDA' AND fecha >= CURDATE() - INTERVAL 5 MONTH
            GROUP BY etiqueta ORDER BY etiqueta", cancellationToken: ct))).AsList();

        return new DashboardDto
        {
            TotalArticulos = total,
            BajoMinimo = bajo,
            ProximosAVencer = proximos,
            SolicitudesPendientes = pendientes,
            ArticulosPorCategoria = porCategoria,
            Vencimientos = vencimientos,
            ConsumoPorMes = consumo,
        };
    }

    // ------------------------------------------------------------------ Reportes
    public async Task<IReadOnlyList<ExistenciaDto>> ExistenciasAsync(bool soloBajoMinimo, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var sql = @"
            SELECT a.id AS articulo_id, a.codigo, a.nombre, a.tipo,
                   um.abreviatura AS unidad, a.stock_minimo,
                   COALESCE(SUM(l.cantidad_actual), 0) AS existencia,
                   (COALESCE(SUM(l.cantidad_actual), 0) < a.stock_minimo) AS bajo_minimo
            FROM articulos a
            JOIN unidades_medida um ON um.id = a.unidad_id
            LEFT JOIN lotes l ON l.articulo_id = a.id AND l.activo = 1
            WHERE a.activo = 1
            GROUP BY a.id, a.codigo, a.nombre, a.tipo, um.abreviatura, a.stock_minimo"
          + (soloBajoMinimo ? " HAVING existencia < a.stock_minimo" : "")
          + " ORDER BY a.nombre";
        return (await con.QueryAsync<ExistenciaDto>(new CommandDefinition(sql, cancellationToken: ct))).AsList();
    }

    public async Task<IReadOnlyList<ProximoVencerDto>> ProximosAVencerAsync(int dias, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT a.id AS articulo_id, a.codigo, a.nombre, l.codigo_lote,
                   l.fecha_vencimiento, DATEDIFF(l.fecha_vencimiento, CURDATE()) AS dias_restantes,
                   l.cantidad_actual, ub.nombre AS ubicacion
            FROM lotes l
            JOIN articulos a ON a.id = l.articulo_id
            LEFT JOIN ubicaciones ub ON ub.id = l.ubicacion_id
            WHERE l.activo = 1 AND l.cantidad_actual > 0 AND l.fecha_vencimiento IS NOT NULL
              AND l.fecha_vencimiento BETWEEN CURDATE() AND CURDATE() + INTERVAL @dias DAY
            ORDER BY l.fecha_vencimiento";
        return (await con.QueryAsync<ProximoVencerDto>(
            new CommandDefinition(sql, new { dias }, cancellationToken: ct))).AsList();
    }

    public async Task<IReadOnlyList<ProximoVencerDto>> LotesVencidosAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT a.id AS articulo_id, a.codigo, a.nombre, l.codigo_lote,
                   l.fecha_vencimiento, DATEDIFF(l.fecha_vencimiento, CURDATE()) AS dias_restantes,
                   l.cantidad_actual, ub.nombre AS ubicacion
            FROM lotes l
            JOIN articulos a ON a.id = l.articulo_id
            LEFT JOIN ubicaciones ub ON ub.id = l.ubicacion_id
            WHERE l.activo = 1 AND l.cantidad_actual > 0 AND l.fecha_vencimiento IS NOT NULL
              AND l.fecha_vencimiento < CURDATE()
            ORDER BY l.fecha_vencimiento";
        return (await con.QueryAsync<ProximoVencerDto>(new CommandDefinition(sql, cancellationToken: ct))).AsList();
    }

    public async Task<IReadOnlyList<ConsumoLaboratorioDto>> ConsumoLaboratorioAsync(
        DateOnly desde, DateOnly hasta, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT l.nombre AS laboratorio,
                   COUNT(DISTINCT m.id) AS despachos,
                   COUNT(md.id) AS lineas
            FROM movimientos m
            JOIN solicitudes s        ON s.id = m.solicitud_id
            JOIN laboratorios l       ON l.id = s.laboratorio_id
            JOIN movimiento_detalle md ON md.movimiento_id = m.id
            WHERE m.tipo = 'SALIDA' AND m.fecha >= @desde AND m.fecha < @hasta
            GROUP BY l.id, l.nombre
            ORDER BY despachos DESC";
        return (await con.QueryAsync<ConsumoLaboratorioDto>(new CommandDefinition(
            sql, new { desde = desde.ToDateTime(TimeOnly.MinValue), hasta = hasta.AddDays(1).ToDateTime(TimeOnly.MinValue) },
            cancellationToken: ct))).AsList();
    }

    public async Task<IReadOnlyList<EntradaProveedorDto>> EntradasProveedorAsync(
        DateOnly desde, DateOnly hasta, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT pr.nombre AS proveedor,
                   COUNT(DISTINCT m.id) AS entradas,
                   COALESCE(SUM(md.cantidad), 0) AS unidades
            FROM movimientos m
            JOIN movimiento_detalle md ON md.movimiento_id = m.id
            JOIN lotes lo             ON lo.id = md.lote_id
            JOIN proveedores pr       ON pr.id = lo.proveedor_id
            WHERE m.tipo = 'ENTRADA' AND m.fecha >= @desde AND m.fecha < @hasta
            GROUP BY pr.id, pr.nombre
            ORDER BY entradas DESC";
        return (await con.QueryAsync<EntradaProveedorDto>(new CommandDefinition(
            sql, new { desde = desde.ToDateTime(TimeOnly.MinValue), hasta = hasta.AddDays(1).ToDateTime(TimeOnly.MinValue) },
            cancellationToken: ct))).AsList();
    }

    public async Task<IReadOnlyList<KardexDto>> KardexAsync(
        int articuloId, DateOnly desde, DateOnly hasta, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT m.fecha, m.tipo, md.cantidad, l.codigo_lote, m.motivo
            FROM movimientos m
            JOIN movimiento_detalle md ON md.movimiento_id = m.id
            JOIN lotes l              ON l.id = md.lote_id
            WHERE l.articulo_id = @articuloId AND m.fecha >= @desde AND m.fecha < @hasta
            ORDER BY m.fecha, m.id";
        return (await con.QueryAsync<KardexDto>(new CommandDefinition(
            sql, new { articuloId, desde = desde.ToDateTime(TimeOnly.MinValue), hasta = hasta.AddDays(1).ToDateTime(TimeOnly.MinValue) },
            cancellationToken: ct))).AsList();
    }
}
