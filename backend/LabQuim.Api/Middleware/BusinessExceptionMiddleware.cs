using System.Text.Json;
using MySqlConnector;

namespace LabQuim.Api.Middleware;

/// <summary>
/// Traduce los errores de negocio lanzados por los stored procedures
/// (SIGNAL SQLSTATE '45000') a respuestas HTTP 400 con el mensaje del SP.
/// El resto de errores de BD caen a 500.
/// </summary>
public sealed class BusinessExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<BusinessExceptionMiddleware> _logger;

    public BusinessExceptionMiddleware(RequestDelegate next, ILogger<BusinessExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (MySqlException ex) when (ex.SqlState == "45000")
        {
            _logger.LogWarning(ex, "Regla de negocio rechazada por el SP");
            await WriteProblem(context, StatusCodes.Status400BadRequest, ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error no controlado");
            await WriteProblem(context, StatusCodes.Status500InternalServerError,
                "Ocurrió un error interno.");
        }
    }

    private static async Task WriteProblem(HttpContext context, int status, string detail)
    {
        if (context.Response.HasStarted) return;
        context.Response.Clear();
        context.Response.StatusCode = status;
        context.Response.ContentType = "application/problem+json";
        var payload = JsonSerializer.Serialize(new
        {
            status,
            title = status == 400 ? "Solicitud inválida" : "Error interno",
            detail
        });
        await context.Response.WriteAsync(payload);
    }
}
