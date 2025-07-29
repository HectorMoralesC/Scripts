# Pausa inicial para evitar que la ventana se cierre
Read-Host -Prompt "Presiona Enter para comenzar a hacer la copia de seguridad y desinstalar Linphone"

# Obtener el nombre de usuario actual y construir la ruta a friends.db
$userProfile = [System.Environment]::GetFolderPath('UserProfile')
$friendsDbPath = Join-Path -Path $userProfile -ChildPath "AppData\Local\linphone\friends.db"

# Crear la ruta de destino para la copia de seguridad
$backupPath = Join-Path -Path $userProfile -ChildPath "AppData\Local\friends.db"

# Verificar si el archivo friends.db existe
Write-Host "Verificando si friends.db existe en: $friendsDbPath"
if (Test-Path $friendsDbPath) {
    Write-Host "El archivo friends.db existe. Comenzando a hacer la copia de seguridad..."

    try {
        # Intentar detener el proceso de Linphone si está en ejecución
        $linphoneProcess = Get-Process -Name "linphone" -ErrorAction SilentlyContinue
        if ($linphoneProcess) {
            Write-Host "Linphone está en ejecución, cerrándolo..."
            Stop-Process -Name "linphone" -Force
            Write-Host "Linphone cerrado con éxito."
        }

        # Copiar el archivo friends.db a la ubicación de backup
        Copy-Item -Path $friendsDbPath -Destination $backupPath -Force
        Write-Host "Copia de seguridad de friends.db realizada con éxito en: $backupPath"
    } catch {
        Write-Host "Hubo un error al crear la copia de seguridad." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
} else {
    Write-Host "No se encontró el archivo friends.db para hacer la copia de seguridad." -ForegroundColor Red
}

# Ruta del desinstalador
$uninstallerPath = "C:\Program Files\Linphone\Uninstall.exe"

if (Test-Path $uninstallerPath) {
    Write-Host "Ejecutando desinstalador de Linphone..."
    Start-Process -FilePath $uninstallerPath -Wait
    Write-Host "Proceso de desinstalación completado."

    # Eliminar carpeta en Program Files
    $linphoneFolderProgramFiles = "C:\Program Files\Linphone"
    if (Test-Path $linphoneFolderProgramFiles) {
        try {
            Remove-Item -Path $linphoneFolderProgramFiles -Recurse -Force -ErrorAction Stop
            Write-Host "Carpeta de Linphone en Program Files eliminada con éxito."
        } catch {
            Write-Host "Error al eliminar carpeta en Program Files." -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }

    # Eliminar carpeta en AppData\Local
    $linphoneFolderAppData = Join-Path -Path $userProfile -ChildPath "AppData\Local\linphone"
    if (Test-Path $linphoneFolderAppData) {
        try {
            Remove-Item -Path $linphoneFolderAppData -Recurse -Force -ErrorAction Stop
            Write-Host "Carpeta de Linphone en AppData\Local eliminada con éxito."
        } catch {
            Write-Host "Error al eliminar carpeta en AppData\Local." -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }

    # Eliminar clave de registro
    $registryKeyPath = "HKCU:\Software\Linphone"
    if (Test-Path $registryKeyPath) {
        try {
            Remove-Item -Path $registryKeyPath -Recurse -Force
            Write-Host "Clave del registro eliminada con éxito."
        } catch {
            Write-Host "Error al eliminar clave del registro." -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }
    # Ejecutar el instalador desde la misma carpeta del script
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $installerPath = Join-Path -Path $scriptDirectory -ChildPath "Linphone-5.2.4-win64.exe"

    if (Test-Path $installerPath) {
        Write-Host "Iniciando instalación de Linphone desde: $installerPath"
        Start-Process -FilePath $installerPath
        Write-Host "Instalador lanzado. Esperando a que se complete la instalación..."

    # Esperar a que se cree la carpeta linphone (máx 5 minutos = 60 intentos x 5 segundos)
    $targetFolder = Join-Path -Path $userProfile -ChildPath "AppData\Local\linphone"
    $retries = 0
    $maxRetries = 60

    Write-Host "Esperando a que se complete la instalación de Linphone (hasta 5 minutos)..."

    while (!(Test-Path $targetFolder) -and ($retries -lt $maxRetries)) {
        Start-Sleep -Seconds 5
        $retries++
        Write-Host "Esperando... ($($retries * 5) segundos)"
    }

    if (Test-Path $targetFolder) {
        Write-Host "Instalación detectada. Procediendo a restaurar friends.db."
    } else {
        Write-Host "No se detectó la instalación de Linphone tras 5 minutos." -ForegroundColor Red
    }


    } else {
        Write-Host "No se encontró el instalador en la carpeta del script." -ForegroundColor Red
    }

    # Esperar un momento para que Linphone cree su carpeta y archivo
    Start-Sleep -Seconds 10

    # Reemplazar friends.db en la nueva instalación
    $restoredDbPath = Join-Path -Path $userProfile -ChildPath "AppData\Local\linphone\friends.db"

    if (Test-Path $backupPath) {
        try {
            # Esperar si no existe aún la carpeta linphone
            $targetFolder = Join-Path -Path $userProfile -ChildPath "AppData\Local\linphone"
            $retries = 0
            while (!(Test-Path $targetFolder) -and ($retries -lt 10)) {
                Start-Sleep -Seconds 2
                $retries++
            }

            # Copiar el archivo de backup al nuevo destino
            Copy-Item -Path $backupPath -Destination $restoredDbPath -Force
            Write-Host "Archivo friends.db restaurado con éxito."
        } catch {
            Write-Host "Error al restaurar el archivo friends.db" -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    } 

    else {
        Write-Host "No se encontró el archivo de copia de seguridad de friends.db para restaurar." -ForegroundColor Red
    }

} else {
    Write-Host "No se encontró el desinstalador. Procediendo a limpiar carpetas y registros..."
}


# Pausa final para evitar que la ventana se cierre automáticamente
Read-Host -Prompt "Presiona Enter para cerrar el script"
