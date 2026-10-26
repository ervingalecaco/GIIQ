namespace LabQuim.Api.Models;

public sealed class NotificacionDto
{
    public long Id { get; set; }
    public string Tipo { get; set; } = "";
    public string Titulo { get; set; } = "";
    public string Mensaje { get; set; } = "";
    /// <summary>Ruta de la app a la que lleva (p. ej. /solicitudes/reactivos?ver=12).</summary>
    public string? Enlace { get; set; }
    public int? SolicitudId { get; set; }
    public bool Leida { get; set; }
    public DateTime CreadaEn { get; set; }
}

public sealed class NotificacionesDto
{
    public int NoLeidas { get; set; }
    public List<NotificacionDto> Items { get; set; } = [];
}
