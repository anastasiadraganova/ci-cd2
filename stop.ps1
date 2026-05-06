docker stop lab6_app lab6_db 2>$null
docker rm   lab6_app lab6_db 2>$null
docker network rm lab6_network 2>$null
Write-Host "[OK] All containers stopped" -ForegroundColor Green
