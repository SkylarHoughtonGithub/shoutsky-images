// 1. First, let's create a simple ASP.NET Core Web API app
// Program.cs
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
// Since we're using minimal APIs, we don't need controllers
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Ensure we're listening on the container port
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(80);
});

var app = builder.Build();

// Configure the HTTP request pipeline
// Always enable Swagger in container for testing
app.UseSwagger();
app.UseSwaggerUI();

// Add a simple endpoint using minimal API approach
app.MapGet("/", () => "Hello from containerized ASP.NET Core!");

// Add a weather forecast endpoint
app.MapGet("/weatherforecast", () =>
{
    var summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();

    return forecast;
});

app.Run();

// Weather forecast model
record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}