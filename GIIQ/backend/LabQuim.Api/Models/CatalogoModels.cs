namespace LabQuim.Api.Models;

public sealed class CatalogoItemDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
}

/// <summary>Clase para el formulario de solicitud (con su año, para agruparlas).</summary>
public sealed class ClaseItemDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public int Anio { get; set; }
}

/// <summary>Práctica para el formulario de solicitud (con el laboratorio donde se realiza).</summary>
public sealed class PracticaItemDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string? Laboratorio { get; set; }
}

public sealed class UnidadDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string Abreviatura { get; set; } = "";
}
