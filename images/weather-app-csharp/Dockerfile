# Use the official ASP.NET Core runtime as a base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["WebApiSample.csproj", "./"]
RUN dotnet restore "WebApiSample.csproj"

# Copy all files and build
COPY . .
RUN dotnet build "WebApiSample.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "WebApiSample.csproj" -c Release -o /app/publish

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebApiSample.dll"]