using System.Data;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

public sealed class InventarioRepository
{
    private readonly IDbConnectionFactory _factory;
    public InventarioRepository(IDbConnectionFactory factory) => _factory = factory;

    public async Task<IReadOnlyList<ExistenciaDto>> GetExistenciasAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT a.id AS articulo_id, a.codigo, a.nombre, a.tipo,
                   um.abreviatura AS unidad, a.stock_minimo,
                   COALESCE(SUM(l.cantidad_actual), 0) AS existencia,
                   (COALESCE(SUM(l.cantidad_actual), 0) < a.stock_minimo) AS bajo_minimo
            FROM articulos a
            JOIN unidades_medida um ON um.id = a.unidad_id
            LEFT JOIN lotes l ON l.articulo_id = a.id AND l.activo = 1
            WHERE a.activo = 1
            GROUP BY a.id, a.codigo, a.nombre, a.tipo, um.abreviatura, a.stock_minimo
            ORDER BY a.nombre";
        var rows = await con.QueryAsync<ExistenciaDto>(new CommandDefinition(sql, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<IReadOnlyList<LoteDto>> GetLotesAsync(int articuloId, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT l.id, l.codigo_lote, l.fecha_vencimiento, l.cantidad_actual,
                   pr.nombre AS proveedor, ub.nombre AS ubicacion, l.fecha_ingreso
            FROM lotes l
            LEFT JOIN proveedores pr ON pr.id = l.proveedor_id
            LEFT JOIN ubicaciones ub ON ub.id = l.ubicacion_id
            WHERE l.articulo_id = @articuloId AND l.activo = 1
            ORDER BY (l.fecha_vencimiento IS NULL), l.fecha_vencimiento, l.id";
        var rows = await con.QueryAsync<LoteDto>(
            new CommandDefinition(sql, new { articuloId }, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<EntradaResult> RegistrarEntradaAsync(
        int usuarioId, EntradaRequest req, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_articulo_id", req.ArticuloId);
        p.Add("p_codigo_lote", req.CodigoLote);
        p.Add("p_fecha_vencimiento", req.FechaVencimiento?.ToDateTime(TimeOnly.MinValue));
        p.Add("p_cantidad", req.Cantidad);
        p.Add("p_proveedor_id", req.ProveedorId);
        p.Add("p_ubicacion_id", req.UbicacionId);
        p.Add("p_motivo", req.Motivo);
        return await con.QueryFirstAsync<EntradaResult>(
            new CommandDefinition("sp_entrada_registrar", p,
                commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task<AjusteResult> RegistrarAjusteAsync(
        int usuarioId, AjusteRequest req, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_lote_id", req.LoteId);
        p.Add("p_nueva_cantidad", req.NuevaCantidad);
        p.Add("p_motivo", req.Motivo);
        return await con.QueryFirstAsync<AjusteResult>(
            new CommandDefinition("sp_ajuste_registrar", p,
                commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }
}
