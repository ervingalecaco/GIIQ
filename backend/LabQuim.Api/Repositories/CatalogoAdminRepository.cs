using System.Data;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;

namespace LabQuim.Api.Repositories;

/// <summary>CRUD administrativo de los catálogos maestros (vía stored procedures).</summary>
public sealed class CatalogoAdminRepository
{
    private readonly IDbConnectionFactory _factory;
    public CatalogoAdminRepository(IDbConnectionFactory factory) => _factory = factory;

    private async Task<IReadOnlyList<T>> QueryAsync<T>(string sql, CancellationToken ct)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        return (await con.QueryAsync<T>(new CommandDefinition(sql, cancellationToken: ct))).AsList();
    }

    private async Task<int> GuardarAsync(string sp, DynamicParameters p, CancellationToken ct)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var r = await con.QueryFirstAsync<GuardarResult>(
            new CommandDefinition(sp, p, commandType: CommandType.StoredProcedure, cancellationToken: ct));
        return r.Id;
    }

    private async Task EstadoAsync(string sp, int actorId, int id, bool activo, CancellationToken ct)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var p = new DynamicParameters();
        p.Add("p_actor_id", actorId);
        p.Add("p_id", id);
        p.Add("p_activo", activo ? 1 : 0);
        await con.ExecuteAsync(new CommandDefinition(sp, p,
            commandType: CommandType.StoredProcedure, cancellationToken: ct));
    }

    // ---------- Categorías ----------
    public Task<IReadOnlyList<CategoriaDto>> CategoriasAsync(CancellationToken ct) =>
        QueryAsync<CategoriaDto>("SELECT id, nombre, descripcion, activo FROM categorias ORDER BY nombre", ct);
    public Task<int> GuardarCategoriaAsync(int actor, int id, CategoriaRequest r, CancellationToken ct)
    {
        var p = new DynamicParameters();
        p.Add("p_actor_id", actor); p.Add("p_id", id);
        p.Add("p_nombre", r.Nombre); p.Add("p_descripcion", r.Descripcion);
        return GuardarAsync("sp_categoria_guardar", p, ct);
    }
    public Task EstadoCategoriaAsync(int actor, int id, bool activo, CancellationToken ct) =>
        EstadoAsync("sp_categoria_estado", actor, id, activo, ct);

    // ---------- Unidades ----------
    public Task<IReadOnlyList<UnidadFullDto>> UnidadesAsync(CancellationToken ct) =>
        QueryAsync<UnidadFullDto>("SELECT id, nombre, abreviatura, activo FROM unidades_medida ORDER BY nombre", ct);
    public Task<int> GuardarUnidadAsync(int actor, int id, UnidadRequest r, CancellationToken ct)
    {
        var p = new DynamicParameters();
        p.Add("p_actor_id", actor); p.Add("p_id", id);
        p.Add("p_nombre", r.Nombre); p.Add("p_abreviatura", r.Abreviatura);
        return GuardarAsync("sp_unidad_guardar", p, ct);
    }
    public Task EstadoUnidadAsync(int actor, int id, bool activo, CancellationToken ct) =>
        EstadoAsync("sp_unidad_estado", actor, id, activo, ct);

    // ---------- Proveedores ----------
    public Task<IReadOnlyList<ProveedorDto>> ProveedoresAsync(CancellationToken ct) =>
        QueryAsync<ProveedorDto>(
            "SELECT id, nombre, contacto, telefono, email, direccion, activo FROM proveedores ORDER BY nombre", ct);
    public Task<int> GuardarProveedorAsync(int actor, int id, ProveedorRequest r, CancellationToken ct)
    {
        var p = new DynamicParameters();
        p.Add("p_actor_id", actor); p.Add("p_id", id);
        p.Add("p_nombre", r.Nombre); p.Add("p_contacto", r.Contacto); p.Add("p_telefono", r.Telefono);
        p.Add("p_email", r.Email); p.Add("p_direccion", r.Direccion);
        return GuardarAsync("sp_proveedor_guardar", p, ct);
    }
    public Task EstadoProveedorAsync(int actor, int id, bool activo, CancellationToken ct) =>
        EstadoAsync("sp_proveedor_estado", actor, id, activo, ct);

    // ---------- Ubicaciones ----------
    public Task<IReadOnlyList<UbicacionFullDto>> UbicacionesAsync(CancellationToken ct) =>
        QueryAsync<UbicacionFullDto>(
            "SELECT id, nombre, descripcion, condiciones, activo FROM ubicaciones ORDER BY nombre", ct);
    public Task<int> GuardarUbicacionAsync(int actor, int id, UbicacionRequest r, CancellationToken ct)
    {
        var p = new DynamicParameters();
        p.Add("p_actor_id", actor); p.Add("p_id", id);
        p.Add("p_nombre", r.Nombre); p.Add("p_descripcion", r.Descripcion); p.Add("p_condiciones", r.Condiciones);
        return GuardarAsync("sp_ubicacion_guardar", p, ct);
    }
    public Task EstadoUbicacionAsync(int actor, int id, bool activo, CancellationToken ct) =>
        EstadoAsync("sp_ubicacion_estado", actor, id, activo, ct);

    // ---------- Laboratorios ----------
    public Task<IReadOnlyList<LaboratorioFullDto>> LaboratoriosAsync(CancellationToken ct) =>
        QueryAsync<LaboratorioFullDto>("SELECT id, nombre, descripcion, activo FROM laboratorios ORDER BY nombre", ct);
    public Task<int> GuardarLaboratorioAsync(int actor, int id, LaboratorioRequest r, CancellationToken ct)
    {
        var p = new DynamicParameters();
        p.Add("p_actor_id", actor); p.Add("p_id", id);
        p.Add("p_nombre", r.Nombre); p.Add("p_descripcion", r.Descripcion);
        return GuardarAsync("sp_laboratorio_guardar", p, ct);
    }
    public Task EstadoLaboratorioAsync(int actor, int id, bool activo, CancellationToken ct) =>
        EstadoAsync("sp_laboratorio_estado", actor, id, activo, ct);
}
