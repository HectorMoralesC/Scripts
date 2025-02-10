@echo off
color 0A
REM Rutas de origen y destino predeterminadas
set origen=E:\Scripts
set destino=D:\Scripts

REM Mostrar título y encabezado
cls
echo ===============================================
echo          COPIA DE SEGURIDAD AUTOMATICA
echo ===============================================
echo.
echo Iniciando la copia de seguridad...
echo.
echo Origen: %origen%
echo Destino: %destino%
echo ===============================================

REM Verificar si el directorio de destino existe
if not exist "%destino%" (
    echo.
    echo El directorio de respaldo no existe. Creando el directorio...
    mkdir "%destino%"
    echo Directorio de respaldo creado exitosamente.
    echo ===============================================
)

REM Ejecutar Robocopy sin crear archivo de log
echo Ejecutando Robocopy...
echo ===============================================
robocopy "%origen%" "%destino%" /MIR /R:3 /W:5 /NP /TEE

REM Verificar el estado de la operación
echo.
if %errorlevel% equ 0 (
    echo COPIA COMPLETADA CON EXITO!
    echo ===============================================
) else if %errorlevel% equ 1 (
    echo Advertencia: La copia de seguridad se completó con algunas advertencias.
    echo ===============================================
) else (
    echo ERROR: Hubo un problema durante la copia de seguridad.
    echo ===============================================
)

REM Espera para que el usuario vea el resultado
pause