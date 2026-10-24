using System.Text;
using Dapper;
using LabQuim.Api.Auth;
using LabQuim.Api.Data;
using LabQuim.Api.Middleware;
using LabQuim.Api.Repositories;
using LabQuim.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Dapper: mapear columnas snake_case (solicitud_id) a propiedades PascalCase (SolicitudId).
DefaultTypeMap.MatchNamesWithUnderscores = true;
// MySQL DATE -> DateOnly (MySqlConnector las entrega como DateTime).
SqlMapper.AddTypeHandler(new LabQuim.Api.Data.DateOnlyTypeHandler());

// ---- Configuración ----
var jwt = builder.Configuration.GetSection("Jwt").Get<JwtSettings>()
          ?? throw new InvalidOperationException("Falta la sección 'Jwt'.");
builder.Services.AddSingleton(jwt);

// ---- Datos + repositorios ----
builder.Services.AddSingleton<IDbConnectionFactory, MySqlConnectionFactory>();
builder.Services.AddScoped<UsuarioRepository>();
builder.Services.AddScoped<SolicitudRepository>();
builder.Services.AddScoped<InventarioRepository>();
builder.Services.AddScoped<ArticuloRepository>();
builder.Services.AddScoped<CatalogoRepository>();
builder.Services.AddScoped<RolRepository>();
builder.Services.AddScoped<CatalogoAdminRepository>();
builder.Services.AddScoped<ReporteRepository>();
builder.Services.AddScoped<BajaRepository>();
builder.Services.AddScoped<BackupService>();

// ---- Autenticación JWT ----
builder.Services.AddSingleton<JwtTokenService>();
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwt.Issuer,
            ValidateAudience = true,
            ValidAudience = jwt.Audience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Key)),
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

// ---- Autorización por permisos ----
builder.Services.AddAuthorization();
builder.Services.AddSingleton<IAuthorizationPolicyProvider, PermissionPolicyProvider>();
builder.Services.AddSingleton<IAuthorizationHandler, PermissionHandler>();

// ---- CORS (frontend React en dev) ----
const string CorsPolicy = "frontend";
var origins = builder.Configuration.GetSection("Cors:Origins").Get<string[]>()
              ?? ["http://localhost:5173"];
builder.Services.AddCors(o => o.AddPolicy(CorsPolicy, p =>
    p.WithOrigins(origins).AllowAnyHeader().AllowAnyMethod()));

// ---- Controllers + Swagger ----
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "LabQuim API", Version = "v1" });
    var scheme = new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Pega el token JWT (sin la palabra 'Bearer').",
        Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
    };
    c.AddSecurityDefinition("Bearer", scheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement { [scheme] = Array.Empty<string>() });
});

var app = builder.Build();

// ---- Pipeline ----
app.UseMiddleware<BusinessExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "LabQuim API v1"));

    // Asigna clave usable a los usuarios con hash placeholder (solo local).
    await DevSeeder.SeedAsync(app.Services, app.Logger);
}

app.UseCors(CorsPolicy);
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
