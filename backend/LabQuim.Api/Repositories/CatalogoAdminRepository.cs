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

    // ---------- Clases ----------
    public Task<IReadOnlyList<ClaseDto>> ClasesAsync(CancellationToken ct) =>
        QueryAsync<ClaseDto>(@"
            SELECT c.id, c.anio, c.nombre, c.descripcion, c.activo,
                   GROUP_CONCAT(u.nombre_completo ORDER BY u.nombre_completo SEPARATOR ', ') AS profesores,
                   GROUP_CONCAT(u.id ORDER BY u.nombre_completo) AS profesor_ids,
                   (SELECT COUNT(*) FROM practicas p WHERE p.clase_id = c.id) AS practicas
            FROM clases c
            LEFT JOIN clase_profesor cp ON cp.clase_id = c.id
            LEFT JOIN usuarios u        ON u.id = cp.profesor_id
            GROUP BY c.id, c.anio, c.nombre, c.descripcion, c.activo
            ORDER BY c.anio, c.nombre", ct);
    public Task<int> GuardarClaseAsync(int actor, int id, ClaseRequest r, CancellationToken ct)
    {
        var p = new DynamicParameters();
        p.Add("p_actor_id", actor); p.Add("p_id", id); p.Add("p_anio", r.Anio);
        p.Add("p_nombre", r.Nombre); p.Add("p_descripcion", r.Descripcion);
        p.Add("p_profesores_json", System.Text.Json.JsonSerializer.Serialize(r.ProfesorIds));
        return GuardarAsync("sp_clase_guardar", p, ct);
    }
    public Task EstadoClaseAsync(int actor, int id, bool activo, CancellationToken ct) =>
        EstadoAsync("sp_clase_estado", actor, id, activo, ct);

    // ---------- Prácticas ----------
    public Task<IReadOnlyList<PracticaDto>> PracticasAsync(CancellationToken ct) =>
        QueryAsync<PracticaDto>(@"
            SELECT p.id, p.clase_id, c.nombre AS clase, c.anio AS clase_anio, p.nombre, p.laboratorio_id,
                   l.nombre AS laboratorio, p.descripcion, p.activo
            FROM practicas p
            JOIN clases c       ON c.id = p.clase_id
            JOIN laboratorios l ON l.id = p.laboratorio_id
            ORDER BY c.anio, c.nombre, p.nombre", ct);
    public Task<int> GuardarPracticaAsync(int actor, int id, PracticaRequest r, CancellationToken ct)
    {
        var p = new DynamicParameters();
        p.Add("p_actor_id", actor); p.Add("p_id", id); p.Add("p_clase_id", r.ClaseId);
        p.Add("p_nombre", r.Nombre); p.Add("p_laboratorio_id", r.LaboratorioId); p.Add("p_descripcion", r.Descripcion);
        return GuardarAsync("sp_practica_guardar", p, ct);
    }
    public Task EstadoPracticaAsync(int actor, int id, bool activo, CancellationToken ct) =>
        EstadoAsync("sp_practica_estado", actor, id, activo, ct);
}
