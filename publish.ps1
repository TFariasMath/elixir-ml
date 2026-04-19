# publish.ps1
# Script de automatización para desplegar Elixir-ML

$ErrorActionPreference = "Stop"

Write-Host "--- Iniciando proceso de publicación ---" -ForegroundColor Cyan

# 1. Sincronización inicial
Write-Host "[1/6] Sincronizando con los repositorios remotos..." -ForegroundColor Yellow
git pull --rebase fork main
git pull --rebase origin main

# 2. Limpieza
Write-Host "[2/6] Limpiando carpeta docs/..." -ForegroundColor Yellow
if (Test-Path "docs") {
    Remove-Item -Recurse -Force docs
}

# 3. Construcción del sitio
Write-Host "[3/6] Generando sitio con Antora (esto puede tardar un poco)..." -ForegroundColor Yellow
npx antora antora-playbook.yml --stacktrace

# 4. Evitar Jekyll en GitHub Pages
Write-Host "[4/6] Configurando .nojekyll..." -ForegroundColor Yellow
New-Item -Path "docs/.nojekyll" -ItemType File -Force | Out-Null

# 5. Commit de cambios
Write-Host "[5/6] Preparando commit..." -ForegroundColor Yellow
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm"
git add .
try {
    git commit -m "site: rebuild manual de la web [$fecha]"
} catch {
    Write-Host "No hay cambios nuevos que commitear." -ForegroundColor Gray
}

# 6. Push
Write-Host "[6/6] Subiendo cambios a GitHub..." -ForegroundColor Yellow
git push fork main
git push origin main

Write-Host "--- Proceso completado con éxito ---" -ForegroundColor Green

# 7. Abrir navegador
Write-Host "Abriendo el sitio en el navegador..." -ForegroundColor Cyan
Start-Process "https://elixircl.github.io/elixir-ml"
