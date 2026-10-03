namespace LabQuim.Api.Models;

public sealed class CatalogoItemDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
}

public sealed class UnidadDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string Abreviatura { get; set; } = "";
}
