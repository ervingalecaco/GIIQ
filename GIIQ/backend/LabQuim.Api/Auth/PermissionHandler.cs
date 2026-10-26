using Microsoft.AspNetCore.Authorization;

namespace LabQuim.Api.Auth;

public sealed class PermissionHandler : AuthorizationHandler<PermissionRequirement>
{
    private const string AdminRol = "Administrador";

    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context, PermissionRequirement requirement)
    {
        // El Administrador tiene todos los permisos por definición.
        if (context.User.IsInRole(AdminRol) ||
            context.User.HasClaim("permiso", requirement.Permission))
        {
            context.Succeed(requirement);
        }
        return Task.CompletedTask;
    }
}
