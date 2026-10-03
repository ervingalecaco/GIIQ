using MySqlConnector;

namespace LabQuim.Api.Data;

public sealed class MySqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;

    public MySqlConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("Default")
            ?? throw new InvalidOperationException("Falta la cadena de conexión 'Default'.");
    }

    public async Task<MySqlConnection> CreateOpenConnectionAsync(CancellationToken ct = default)
    {
        var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(ct);

        // Nicaragua es UTC-6 sin horario de verano. Se fija por conexión para que
        // los cortes por día y las fechas no queden corridos (lección de Rivera).
        await using var cmd = connection.CreateCommand();
        cmd.CommandText = "SET time_zone = '-06:00'";
        await cmd.ExecuteNonQueryAsync(ct);

        return connection;
    }
}
