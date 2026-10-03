using System.Data;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

public sealed class ArticuloRepository
{
    private readonly IDbConnectionFactory _factory;
    public ArticuloRepository(IDbConnectionFactory factory) => _factory = factory;

    public async Task<IReadOnlyList<ArticuloDto>> ListAsync(string? tipo, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT a.id, a.tipo, a.codigo, a.nombre,
                   c.nombre AS categoria, a.unidad_id, um.abreviatura AS unidad,
                   a.stock_minimo, a.activo
            FROM articulos a
            JOIN categorias c       ON c.id = a.categoria_id
            JOIN unidades_medida um ON um.id = a.unidad_id
            WHERE (@tipo IS NULL OR a.tipo = @tipo)
            ORDER BY a.nombre";
        var rows = await con.QueryAsync<ArticuloDto>(
            new CommandDefinition(sql, new { tipo }, cancellationToken: ct));
        return rows.AsList();
    }

    public async Task<ArticuloDetalleDto?> GetByIdAsync(int id, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT a.id, a.tipo, a.codigo, a.nombre,
                   a.categoria_id, c.nombre AS categoria,
                   a.unidad_id, um.abreviatura AS unidad,
                   a.stock_minimo, a.activo,
                   f.cas, f.formula, f.clasificacion_peligro,
                   f.estado_fisico, f.concentracion, f.condiciones_almacenamiento
            FROM articulos a
            JOIN categorias c        ON c.id = a.categoria_id
            JOIN unidades_medida um  ON um.id = a.unidad_id
            LEFT JOIN reactivo_ficha f ON f.articulo_id = a.id
            WHERE a.id = @id";
        return await con.QueryFirstOrDefaultAsync<ArticuloDetalleDto>(
            new CommandDefinition(sql, new { id }, cancellationToken: ct));
    }

    public async Task<CrearArticuloResult> CrearAsync(
        int usuarioId, CrearArticuloRequest req, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = Args(usuarioId, req.Nombre, req.CategoriaId, req.UnidadId, req.StockMinimo, req);
        p.Add("p_tipo", req.Tipo);
        p.Add("p_codigo", req.Codigo);
        return await con.QueryFirstAsync<CrearArticuloResult>(
            new CommandDefinition("sp_articulo_crear", p,
                commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task EditarAsync(
        int usuarioId, int articuloId, EditarArticuloRequest req, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = Args(usuarioId, req.Nombre, req.CategoriaId, req.UnidadId, req.StockMinimo, req);
        p.Add("p_articulo_id", articuloId);
        await con.ExecuteAsync(new CommandDefinition("sp_articulo_editar", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    public async Task CambiarEstadoAsync(
        int usuarioId, int articuloId, bool activo, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_articulo_id", articuloId);
        p.Add("p_activo", activo ? 1 : 0);
        await con.ExecuteAsync(new CommandDefinition("sp_articulo_estado", p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    // Parámetros comunes de ficha compartidos por crear/editar.
    private static DynamicParameters Args(
        int usuarioId, string nombre, int categoriaId, int unidadId, decimal stockMinimo, dynamic ficha)
    {
        var p = new DynamicParameters();
        p.Add("p_usuario_id", usuarioId);
        p.Add("p_nombre", nombre);
        p.Add("p_categoria_id", categoriaId);
        p.Add("p_unidad_id", unidadId);
        p.Add("p_stock_minimo", stockMinimo);
        p.Add("p_cas", (string?)ficha.Cas);
        p.Add("p_formula", (string?)ficha.Formula);
        p.Add("p_clasificacion_peligro", (string?)ficha.ClasificacionPeligro);
        p.Add("p_estado_fisico", (string?)ficha.EstadoFisico);
        p.Add("p_concentracion", (string?)ficha.Concentracion);
        p.Add("p_condiciones_almacenamiento", (string?)ficha.CondicionesAlmacenamiento);
        return p;
    }
}
