using AI_Derma;
using AI_Derma.Core.Interfaces;
using AI_Derma.Core.Models;
using AI_Derma.Infrastructure.Data;
using AI_Derma.Infrastructure.Repos;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddEndpointsApiExplorer();

//Add Swagger for API documentation
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<DermaDbContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddMemoryCache();

builder.Services.AddScoped<IKBMetadata, KBMetadataRepository>();
builder.Services.AddScoped<IUnitofWork, UnitofWork>();
var expertSystemBaseUrl = builder.Configuration["ExpertSystem:BaseUrl"] ?? "http://127.0.0.1:8000";

builder.Services.AddHttpClient<IFastAPIService, FastAPIService>(client =>
{
    client.BaseAddress = new Uri(expertSystemBaseUrl);
    client.Timeout = TimeSpan.FromSeconds(30);
});

builder.Services.AddHttpClient<IChatService, ChatService>();

builder.Services.AddIdentity<ApplicationUser,IdentityRole>().AddEntityFrameworkStores<DermaDbContext>();

builder.Services.Configure<IdentityOptions>(options =>
{
    options.Password.RequiredLength = 6;
    options.Password.RequireDigit = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireLowercase = false;
    options.Password.RequireNonAlphanumeric = false;
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:5175", "http://localhost:4200")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

builder.Services.AddAuthentication(options => {
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme; 
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;    
    options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;             
})
.AddJwtBearer(options => {
    options.SaveToken = true; 
    options.RequireHttpsMetadata = false; 
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidIssuer = builder.Configuration["JWT:IssuerIP"],

        ValidateAudience = false,
        ValidAudience = builder.Configuration["JWT:AudienceIP"],

        ValidateLifetime = true, 
        ClockSkew = TimeSpan.Zero, 

        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["JWT:SecretKey"]))
    };
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowFrontend");

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
