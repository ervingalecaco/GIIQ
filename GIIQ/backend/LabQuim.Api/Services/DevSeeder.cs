using Dapper;
using LabQuim.Api.Data;

namespace LabQuim.Api.Services;

/// <summary>
/// Solo en Development: a los usuarios cuyo hash es un placeholder inválido
/// (los que dejaron los seeds/smoke test) les asigna una clave BCrypt usable,
/// para poder probar el login end-to-end. NUNCA se ejecuta en producción.
/// </summary>
public static class DevSeeder
{
    public const string ClaveDev = "Clave123";

    public static async Task SeedAsync(IServiceProvider services, ILogger logger)
    {
        var factory = services.GetRequiredService<IDbConnectionFactory>();
        await using var con = await factory.CreateOpenConnectionAsync();

        var usuarios = (await con.QueryAsync<(int Id, string Usuario, string Hash)>(
            "SELECT id, usuario, password_hash FROM usuarios")).AsList();

        var arreglados = new List<string>();
        foreach (var u in usuarios)
        {
            if (EsHashValido(u.Hash)) continue;
            var nuevo = BCrypt.Net.BCrypt.HashPassword(ClaveDev);
            await con.ExecuteAsync(
                "UPDATE usuarios SET password_hash = @nuevo WHERE id = @id",
                new { nuevo, id = u.Id });
            arreglados.Add(u.Usuario);
        }

        if (arreglados.Count > 0)
            logger.LogWarning("DevSeeder: clave '{Clave}' asignada a: {Usuarios}",
                ClaveDev, string.Join(", ", arreglados));
    }

    private static bool EsHashValido(string hash)
    {
        if (string.IsNullOrWhiteSpace(hash) || hash.Length is < 59 or > 61) return false;
        try
        {
            // Verifica que el hash sea parseable por BCrypt (no un placeholder).
            BCrypt.Net.BCrypt.Verify("probe", hash);
            return true;
        }
        catch
        {
            return false;
        }
    }
}
