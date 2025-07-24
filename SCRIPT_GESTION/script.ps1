# Mostrar mensaje inicial
Write-Host "=== INICIANDO DESCOMPRESIÓN DE GESTIOVISITESONLINE ===" -ForegroundColor Cyan

# 1. Ruta al ZIP (en la misma carpeta que el script)
$zipPath = Join-Path $PSScriptRoot "GestioVisitesOnline.zip"

# 2. Ruta de destino
$destinationPath = "C:\"

# 3. Verificar si el archivo ZIP existe
if (!(Test-Path $zipPath)) {
    Write-Host "❌ No se encontró el archivo GestioVisitesOnline.zip en la ruta: $zipPath" -ForegroundColor Red
    Pause
    exit
}

# 4. Descomprimir ZIP
Write-Host "→ Descomprimiendo GestioVisitesOnline.zip en C:\..." -ForegroundColor Cyan

try {
    Expand-Archive -Path $zipPath -DestinationPath $destinationPath -Force
    Write-Host "✅ Descompresión completada exitosamente." -ForegroundColor Green
} catch {
    Write-Host "❌ Error durante la descompresión: $_" -ForegroundColor Red
}

# 8. Crear accesos directos en el escritorio
Write-Host "→ Creando acceso directo en el escritorio..." -ForegroundColor Cyan

# Obtener ruta del escritorio del usuario actual
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Crear objeto COM para acceso directo
$shell = New-Object -ComObject WScript.Shell

# Crear acceso directo para visorpendientes.exe
$shortcut1 = $shell.CreateShortcut("$desktopPath\GestioVisites.lnk")
$shortcut1.TargetPath = "C:\GestioVisitesOnline\GestioVisites.exe"
$shortcut1.WorkingDirectory = "C:\GestioVisitesOnline"
$shortcut1.IconLocation = "C:\GestioVisitesOnline\GestioVisites.exe, 0"
$shortcut1.Save()
Write-Host "✅ Acceso directo creado: GestioVisites" -ForegroundColor Green


# Fin
Write-Host "=== PROCESO FINALIZADO ===" -ForegroundColor Cyan
Pause
