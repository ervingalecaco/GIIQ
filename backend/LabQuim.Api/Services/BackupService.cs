using System.Diagnostics;
using Dapper;
using LabQuim.Api.Data;
using LabQuim.Api.Models;
using MySqlConnector;

namespace LabQuim.Api.Services;

/// <summary>
/// Respaldo y restauración de la base de datos invocando mysqldump / mysql.
/// El respaldo incluye rutinas (stored procedures) y se registra en la tabla `respaldos`.
/// </summary>
public sealed class BackupService
{
    private readonly IDbConnectionFactory _factory;
    private readonly string _connectionString;
    private readonly string _directory;
    private readonly string _binDir;
    private readonly ILogger<BackupService> _logger;

    public BackupService(IDbConnectionFactory factory, IConfiguration cfg, ILogger<BackupService> logger)
    {
        _factory = factory;
        _logger = logger;
        _connectionString = cfg.GetConnectionString("Default")!;
        _directory = Path.GetFullPath(cfg["Backup:Directory"] ?? "backups");
        _binDir = cfg["Backup:MySqlBinDir"] ?? "";
        Directory.CreateDirectory(_directory);
    }

    private MySqlConnectionStringBuilder Cs => new(_connectionString);
    private string Tool(string exe) => string.IsNullOrEmpty(_binDir) ? exe : Path.Combine(_binDir, exe);

    public async Task<RespaldoDto> CrearAsync(int usuarioId, CancellationToken ct = default)
    {
        var cs = Cs;
        var nombre = $"labquim_{DateTime.Now:yyyyMMdd_HHmmss}.sql";
        var ruta = Path.Combine(_directory, nombre);

        var args = new List<string>
        {
            $"--host={cs.Server}", $"--port={cs.Port}", $"--user={cs.UserID}",
            "--default-character-set=utf8mb4", "--routines", "--single-transaction",
            cs.Database, $"--result-file={ruta}",
        };

        await RunAsync(Tool("mysqldump.exe"), args, cs.Password, input: null, ct);

        var tamano = new FileInfo(ruta).Length;
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var id = await con.ExecuteScalarAsync<int>(new CommandDefinition(@"
            INSERT INTO respaldos (usuario_id, archivo, tamano_bytes, observacion)
            VALUES (@usuarioId, @archivo, @tamano, 'Respaldo manual');
            SELECT LAST_INSERT_ID();",
            new { usuarioId, archivo = nombre, tamano }, cancellationToken: ct));

        _logger.LogInformation("Respaldo creado: {Archivo} ({Bytes} bytes)", nombre, tamano);
        return new RespaldoDto { Id = id, Archivo = nombre, TamanoBytes = tamano, Fecha = DateTime.Now };
    }

    public async Task<IReadOnlyList<RespaldoDto>> ListAsync(CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        const string sql = @"
            SELECT r.id, r.archivo, r.tamano_bytes, r.fecha, u.nombre_completo AS usuario, r.observacion
            FROM respaldos r LEFT JOIN usuarios u ON u.id = r.usuario_id
            ORDER BY r.id DESC";
        return (await con.QueryAsync<RespaldoDto>(new CommandDefinition(sql, cancellationToken: ct))).AsList();
    }

    public async Task<(string Ruta, string Nombre)?> ArchivoAsync(int id, CancellationToken ct = default)
    {
        await using var con = await _factory.CreateOpenConnectionAsync(ct);
        var nombre = await con.ExecuteScalarAsync<string?>(new CommandDefinition(
            "SELECT archivo FROM respaldos WHERE id = @id", new { id }, cancellationToken: ct));
        if (nombre is null) return null;
        var ruta = Path.Combine(_directory, nombre);
        return File.Exists(ruta) ? (ruta, nombre) : null;
    }

    /// <summary>Restaura la base desde un archivo .sql (reemplaza los datos actuales).</summary>
    public async Task RestoreAsync(Stream sqlStream, CancellationToken ct = default)
    {
        var cs = Cs;
        // Se guarda a un archivo temporal y se alimenta a `mysql` por stdin.
        var temp = Path.Combine(Path.GetTempPath(), $"restore_{Guid.NewGuid():N}.sql");
        try
        {
            await using (var fs = File.Create(temp))
                await sqlStream.CopyToAsync(fs, ct);

            var args = new List<string>
            {
                $"--host={cs.Server}", $"--port={cs.Port}", $"--user={cs.UserID}",
                "--default-character-set=utf8mb4", cs.Database,
            };

            await using var input = File.OpenRead(temp);
            await RunAsync(Tool("mysql.exe"), args, cs.Password, input, ct);
            _logger.LogWarning("Base restaurada desde archivo subido ({Bytes} bytes)", new FileInfo(temp).Length);
        }
        finally
        {
            if (File.Exists(temp)) File.Delete(temp);
        }
    }

    private static async Task RunAsync(string exe, IEnumerable<string> args, string? password, Stream? input, CancellationToken ct)
    {
        var psi = new ProcessStartInfo
        {
            FileName = exe,
            RedirectStandardInput = input is not null,
            RedirectStandardError = true,
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true,
        };
        foreach (var a in args) psi.ArgumentList.Add(a);
        // Clave por variable de entorno para no exponerla en la línea de comandos.
        if (!string.IsNullOrEmpty(password)) psi.Environment["MYSQL_PWD"] = password;

        using var proc = new Process { StartInfo = psi };
        if (!proc.Start())
            throw new InvalidOperationException($"No se pudo iniciar {exe}.");

        if (input is not null)
        {
            await input.CopyToAsync(proc.StandardInput.BaseStream, ct);
            proc.StandardInput.Close();
        }

        var stderr = await proc.StandardError.ReadToEndAsync(ct);
        await proc.WaitForExitAsync(ct);

        if (proc.ExitCode != 0)
            throw new InvalidOperationException(
                $"{Path.GetFileName(exe)} falló (código {proc.ExitCode}): {stderr}");
    }
}
