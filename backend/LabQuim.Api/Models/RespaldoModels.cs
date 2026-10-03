namespace LabQuim.Api.Models;

public sealed class RespaldoDto
{
    public int Id { get; set; }
    public string Archivo { get; set; } = "";
    public long? TamanoBytes { get; set; }
    public DateTime Fecha { get; set; }
    public string? Usuario { get; set; }
    public string? Observacion { get; set; }
}
