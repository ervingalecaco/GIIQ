using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace LabQuim.Api.Auth;

public sealed class JwtTokenService
{
    private readonly JwtSettings _settings;

    public JwtTokenService(JwtSettings settings) => _settings = settings;

    public (string Token, DateTime ExpiraEn) Create(
        int usuarioId, string usuario, string nombre, string rol, IEnumerable<string> permisos)
    {
        var expira = DateTime.UtcNow.AddMinutes(_settings.ExpMinutes);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, usuarioId.ToString()),
            new(ClaimTypes.NameIdentifier, usuarioId.ToString()),
            new(ClaimTypes.Name, usuario),
            new("nombre", nombre),
            new(ClaimTypes.Role, rol),
        };
        // Un claim "permiso" por cada permiso del rol → autorización por permiso.
        claims.AddRange(permisos.Select(p => new Claim("permiso", p)));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Key));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: expira,
            signingCredentials: creds);

        return (new JwtSecurityTokenHandler().WriteToken(token), expira);
    }
}
