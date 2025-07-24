@echo off
:: Verificar privilegios de administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando privilegios de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Ejecutar el script PowerShell desde el BAT
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0script.ps1"

