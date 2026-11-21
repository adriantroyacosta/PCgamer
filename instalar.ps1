# =====================================================
#  Instalador post-formateo - PC gamer de Adrian
#  Usa winget (incluido en Windows 10/11)
#  Para quitar una app: pon # al inicio de su linea
#  Para agregar una: busca su ID con  winget search nombre
# =====================================================

# ---------- LISTAS DE APPS ----------

$launchers = @(
    @{ Nombre = "Steam";            Id = "Valve.Steam" },
    @{ Nombre = "EA app";           Id = "ElectronicArts.EADesktop" },
    @{ Nombre = "Epic Games";       Id = "EpicGames.EpicGamesLauncher" },
    @{ Nombre = "GOG Galaxy";       Id = "GOG.Galaxy" },
    @{ Nombre = "Ubisoft Connect";  Id = "Ubisoft.Connect" },
    @{ Nombre = "Battle.net";       Id = "Blizzard.BattleNet" },
    @{ Nombre = "Xbox";             Id = "9MV0B5HZVK9Z"; Fuente = "msstore" },
    @{ Nombre = "Playnite";         Id = "Playnite.Playnite" }
)

$utilidades = @(
    @{ Nombre = "Google Chrome";    Id = "Google.Chrome" },
    @{ Nombre = "WinRAR";           Id = "RARLab.WinRAR" },
    @{ Nombre = "Transmission";     Id = "Transmission.Transmission" },
    @{ Nombre = "VirtualBox";       Id = "Oracle.VirtualBox" },
    @{ Nombre = "iTunes";           Id = "9PB2MZ1ZMB1S"; Fuente = "msstore" },
    @{ Nombre = "PC Manager";       Id = "9PM860492SZD"; Fuente = "msstore" },
    @{ Nombre = "Terminal Windows"; Id = "Microsoft.WindowsTerminal" },
    @{ Nombre = "FanControl";       Id = "Rem0o.FanControl" },
    @{ Nombre = "Dolby Access";     Id = "9N0866FS04W8"; Fuente = "msstore" }
)

$perifericos = [ordered]@{
    "1" = @{ Nombre = "Corsair iCUE 5";   Id = "Corsair.iCUE.5" }
    "2" = @{ Nombre = "Logitech G HUB";   Id = "Logitech.GHUB" }
    "3" = @{ Nombre = "Razer Synapse";    Id = "RazerInc.RazerInstaller" }
    "4" = @{ Nombre = "SteelSeries GG";   Id = "SteelSeries.GG" }
}

# ---------- FUNCIONES ----------

$script:ok = @(); $script:yaEstaba = @(); $script:fallo = @()

function Instalar($app) {
    Write-Host "  -> $($app.Nombre) ..." -ForegroundColor Yellow
    $wargs = @("install", "--id", $app.Id, "-e", "--silent",
              "--accept-package-agreements", "--accept-source-agreements")
    if ($app.Fuente) { $wargs += @("--source", $app.Fuente) }
    & winget @wargs | Out-Host
    switch ($LASTEXITCODE) {
        0           { $script:ok += $app.Nombre }
        -1978335189 { $script:yaEstaba += $app.Nombre }   # ya instalado / sin cambios
        -1978335135 { $script:yaEstaba += $app.Nombre }   # ya instalado
        default     { $script:fallo += $app.Nombre }
    }
}

function Titulo($texto) {
    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host "  $texto" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
}

# ---------- INICIO ----------

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "No se encontro winget. Actualiza 'App Installer' desde la Microsoft Store y vuelve a correr esto." -ForegroundColor Red
    Read-Host "Enter para cerrar"; exit
}

# PASO 1 - Tarjeta grafica
Titulo "PASO 1 de 5 - Tarjeta grafica"
$gpus = (Get-CimInstance Win32_VideoController).Name
Write-Host "Detectado: $($gpus -join ', ')"
if ($gpus -match "AMD|Radeon") {
    Write-Host "Tarjeta AMD: se abrira la pagina de drivers de AMD (Adrenalin)." -ForegroundColor Green
    Start-Process "https://www.amd.com/es/support/download/drivers.html"
} elseif ($gpus -match "NVIDIA|GeForce|RTX|GTX") {
    Write-Host "Tarjeta NVIDIA: se abrira la pagina de la NVIDIA App." -ForegroundColor Green
    Start-Process "https://www.nvidia.com/es-la/software/nvidia-app/"
} else {
    Write-Host "No se reconocio la marca. Instala el driver a mano despues." -ForegroundColor Red
}
Write-Host "(Descargalo e instalalo cuando termine este script.)"

# PASO 2 - Perifericos
Titulo "PASO 2 de 5 - Perifericos"
foreach ($k in $perifericos.Keys) { Write-Host "  $k) $($perifericos[$k].Nombre)" }
Write-Host "  0) Ninguno"
$sel = Read-Host "`nEscribe los numeros separados por coma (ej: 1,2). Enter = solo Corsair"
if ([string]::IsNullOrWhiteSpace($sel)) { $sel = "1" }
foreach ($n in ($sel -split "," | ForEach-Object { $_.Trim() })) {
    if ($perifericos.Contains($n)) { Instalar $perifericos[$n] }
}

# PASO 3 - Launchers
Titulo "PASO 3 de 5 - Launchers de juegos"
foreach ($app in $launchers) { Instalar $app }

# PASO 4 - Utilidades
Titulo "PASO 4 de 5 - Utilidades"
foreach ($app in $utilidades) { Instalar $app }

# PASO 5 - Optimizar para juegos (opcional)
Titulo "PASO 5 de 5 - Optimizar Windows para juegos"
Write-Host "Esto hace:"
Write-Host "  - Activa el Modo Juego de Windows"
Write-Host "  - Pone el plan de energia en Alto rendimiento"
Write-Host "  - Activa la programacion de GPU acelerada por hardware (HAGS)"
Write-Host "  - Corre WinUtil con el preset STANDARD (crea punto de restauracion,"
Write-Host "    baja telemetria y servicios de fondo, limpia temporales)."
Write-Host "    No toca Xbox, Store ni OneDrive."
$opt = Read-Host "`nOptimizar ahora? (S/N)"
$optimizado = $false
if ($opt -match '^[sS]') {
    # Modo Juego
    reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode   /t REG_DWORD /d 1 /f | Out-Null
    # Plan de energia: Alto rendimiento
    powercfg /setactive SCHEME_MIN
    # HAGS (necesita reiniciar)
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f | Out-Null
    Write-Host "Ajustes de juego aplicados." -ForegroundColor Green

    # WinUtil preset Standard (en otra ventana, espera a que termine)
    Write-Host "Abriendo WinUtil (preset Standard)... espera a que termine." -ForegroundColor Yellow
    $cmd = '& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Preset Standard'
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc" -Wait
    $optimizado = $true
}

# ---------- RESUMEN ----------
Titulo "RESUMEN"
Write-Host "Instaladas ($($ok.Count)): $($ok -join ', ')" -ForegroundColor Green
if ($yaEstaba.Count) { Write-Host "Ya estaban ($($yaEstaba.Count)): $($yaEstaba -join ', ')" -ForegroundColor Gray }
if ($fallo.Count)    { Write-Host "Fallaron ($($fallo.Count)): $($fallo -join ', ')" -ForegroundColor Red
                       Write-Host "  -> Vuelve a correr el script o instalalas a mano." -ForegroundColor Red }

Write-Host "`nPENDIENTE A MANO:" -ForegroundColor Yellow
Write-Host "  - Driver de la tarjeta grafica (la pagina ya se abrio)"
Write-Host "  - Black Myth Wukong"
Write-Host "  - Juegos: descargalos desde cada launcher (inicia sesion en cada uno)"
Write-Host "  - Importar perfiles de iCUE y configuracion de FanControl"
if ($optimizado) { Write-Host "`nREINICIA la PC para que se apliquen los ajustes de juego." -ForegroundColor Cyan }

Read-Host "`nPresiona Enter para cerrar"
