Write-Host "=== Starting LAB6 ===" -ForegroundColor Cyan

# Credentials check
# Create network
docker network create lab6_network 2>$null

# Stop old containers
docker stop lab6_db lab6_app 2>$null
docker rm   lab6_db lab6_app 2>$null

# Start PostgreSQL
Write-Host "Starting PostgreSQL..." -ForegroundColor Yellow
docker run -d `
    --name lab6_db `
    --network lab6_network `
    -e POSTGRES_DB=lab6_db `
    -e POSTGRES_USER=postgres `
    -e POSTGRES_PASSWORD=postgres `
    -p 5433:5432 `
    postgres:15-alpine

Start-Sleep -Seconds 5

# Init DB
docker cp db/init.sql lab6_db:/init.sql
docker exec lab6_db psql -U postgres -d lab6_db -f /init.sql

# Build app
docker build -t lab6-app ./app

# Start app
docker run -d `
    --name lab6_app `
    --network lab6_network `
    -p 3000:3000 `
    -e DB_HOST=lab6_db `
    -e DB_PORT=5432 `
    -e DB_NAME=lab6_db `
    -e DB_USER=postgres `
    -e DB_PASSWORD=postgres `
    -e PORT=3000 `
    lab6-app

Start-Sleep -Seconds 2
docker ps --filter "name=lab6_" --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"
Write-Host "`nApp: http://localhost:3000/health" -ForegroundColor Green
Write-Host "Stop: .\stop.ps1" -ForegroundColor Yellow
