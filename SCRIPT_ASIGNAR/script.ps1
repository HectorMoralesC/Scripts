# Mostrar mensaje de inicio
Write-Host "=== INICIANDO SCRIPT DE INSTALACIÓN ===" -ForegroundColor Cyan

# 1. Buscar WinRAR en ruta estándar
$winrarPaths = @(
    "$env:ProgramFiles\WinRAR\WinRAR.exe",
    "$env:ProgramFiles(x86)\WinRAR\WinRAR.exe"
)
$winrarPath = $winrarPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $winrarPath) {
    Write-Host "❌ WinRAR no está instalado o no se encontró." -ForegroundColor Red
    Pause
    exit
}

# 2. Rutas principales
$rarFile = Join-Path $PSScriptRoot "asignarinforme.rar"
$destination = "C:\"
$installerPath = "C:\asignarinforme\mysql-connector-odbc-3.51.25-win32.msi"
$dllSource = "C:\asignarinforme\DLL"
$dllDestination = "C:\Windows\SysWOW64"
$vbSendBat = "C:\asignarinforme\DLL\VBsend.bat"

# 3. Verificar archivo RAR
if (!(Test-Path $rarFile)) {
    Write-Host "❌ No se encontró el archivo asignarinforme.rar" -ForegroundColor Red
    Pause
    exit
}

# 4. Extraer .rar con WinRAR
Write-Host "→ Extrayendo asignarinforme.rar..." -ForegroundColor Cyan
$rarArgs = @("x", "-ibck", "-inul", "-o+", "`"$rarFile`"", "`"$destination`"")

$process = Start-Process -FilePath $winrarPath -ArgumentList $rarArgs -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "✅ Extracción completada." -ForegroundColor Green
} else {
    Write-Host "❌ Error al extraer (ExitCode: $($process.ExitCode))." -ForegroundColor Red
    Pause
    exit
}

Start-Sleep -Seconds 2

# 5. Ejecutar instalador MySQL ODBC
if (Test-Path $installerPath) {
    Write-Host "→ Ejecutando instalador MySQL ODBC..." -ForegroundColor Yellow
    Start-Process "$installerPath" -Wait
    Write-Host "✅ Instalador ejecutado." -ForegroundColor Green
} else {
    Write-Host "❌ No se encontró el instalador en $installerPath" -ForegroundColor Red
}

# 6. Copiar DLLs (solo si no existen en destino)
if (Test-Path $dllSource) {
    Write-Host "→ Copiando DLLs (sin sobrescribir existentes)..." -ForegroundColor Cyan

    Get-ChildItem -Path $dllSource -File | ForEach-Object {
        $targetFile = Join-Path $dllDestination $_.Name
        if (-Not (Test-Path $targetFile)) {
            Copy-Item -Path $_.FullName -Destination $targetFile
            Write-Host "✔ Copiado: $($_.Name)" -ForegroundColor Green
        } else {
            Write-Host "⏭ Omitido (ya existe): $($_.Name)" -ForegroundColor Yellow
        }
    }

    Write-Host "✅ Proceso de copia completado." -ForegroundColor Green
} else {
    Write-Host "❌ No se encontró la carpeta DLL: $dllSource" -ForegroundColor Red
}

# 7. Ejecutar VBsend.bat
if (Test-Path $vbSendBat) {
    Write-Host "→ Ejecutando VBsend.bat..." -ForegroundColor Cyan
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$vbSendBat`"" -Wait
    Write-Host "✅ VBsend.bat ejecutado." -ForegroundColor Green
} else {
    Write-Host "❌ No se encontró VBsend.bat en $vbSendBat" -ForegroundColor Red
}

# 8. Crear accesos directos en el escritorio
Write-Host "→ Creando accesos directos en el escritorio..." -ForegroundColor Cyan

# Obtener ruta del escritorio del usuario actual
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Crear objeto COM para acceso directo
$shell = New-Object -ComObject WScript.Shell

# Crear acceso directo para visorpendientes.exe
$shortcut1 = $shell.CreateShortcut("$desktopPath\Visor Pendientes.lnk")
$shortcut1.TargetPath = "C:\asignarinforme\visorpendientes.exe"
$shortcut1.WorkingDirectory = "C:\asignarinforme"
$shortcut1.IconLocation = "C:\asignarinforme\visorpendientes.exe, 0"
$shortcut1.Save()
Write-Host "✅ Acceso directo creado: Visor Pendientes" -ForegroundColor Green

# Crear acceso directo para Asignar informe.exe
$shortcut2 = $shell.CreateShortcut("$desktopPath\Asignar Informe.lnk")
$shortcut2.TargetPath = "C:\asignarinforme\Asignar informe.exe"
$shortcut2.WorkingDirectory = "C:\asignarinforme"
$shortcut2.IconLocation = "C:\asignarinforme\Asignar informe.exe, 0"
$shortcut2.Save()
Write-Host "✅ Acceso directo creado: Asignar Informe" -ForegroundColor Green


# Fin
Write-Host "=== PROCESO FINALIZADO ===" -ForegroundColor Cyan
Pause







