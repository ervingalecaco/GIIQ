using MySqlConnector;

namespace LabQuim.Api.Data;

public interface IDbConnectionFactory
{
    /// <summary>Abre una conexión y fija la zona horaria de Nicaragua (UTC-6).</summary>
    Task<MySqlConnection> CreateOpenConnectionAsync(CancellationToken ct = default);
}
