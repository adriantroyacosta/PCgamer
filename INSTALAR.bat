@echo off
:: Doble clic aqui. Pide permisos de administrador y abre el instalador.
:: Usa instalar.ps1 de esta carpeta si existe; si no, la ultima version de GitHub.
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
if exist "%~dp0instalar.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex"
)
