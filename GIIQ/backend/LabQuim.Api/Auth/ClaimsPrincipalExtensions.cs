using System.Security.Claims;

namespace LabQuim.Api.Auth;

public static class ClaimsPrincipalExtensions
{
    public static int GetUserId(this ClaimsPrincipal user)
    {
        var value = user.FindFirstValue(ClaimTypes.NameIdentifier)
                    ?? user.FindFirstValue("sub");
        return int.TryParse(value, out var id) ? id : 0;
    }
}
