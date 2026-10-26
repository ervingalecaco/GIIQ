namespace LabQuim.Api.Auth;

public sealed class JwtSettings
{
    public string Issuer { get; set; } = "";
    public string Audience { get; set; } = "";
    public string Key { get; set; } = "";
    public int ExpMinutes { get; set; } = 480;
}
