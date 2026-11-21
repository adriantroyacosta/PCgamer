# =====================================================
#  Instalador post-formateo - PC gamer de Adrian
#  Asistente por pasos: analiza la PC, preguntas paso a paso,
#  resumen, y recien ahi instala. Usa winget (Windows 10/11).
#
#  Uso (PowerShell, no hace falta abrirlo como administrador):
#    irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex
#
#  Para quitar una app: pon # al inicio de su linea
#  Para agregar una: busca su ID con  winget search nombre
# =====================================================

$UrlScript = "https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1"

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

# Vid = ID de fabricante USB, para detectar si hay un periferico de esa marca conectado
$perifericos = @(
    @{ Nombre = "Corsair iCUE 5";   Id = "Corsair.iCUE.5";          Marca = "Corsair";     Vid = "1B1C" },
    @{ Nombre = "Logitech G HUB";   Id = "Logitech.GHUB";           Marca = "Logitech";    Vid = "046D" },
    @{ Nombre = "Razer Synapse";    Id = "RazerInc.RazerInstaller"; Marca = "Razer";       Vid = "1532" },
    @{ Nombre = "SteelSeries GG";   Id = "SteelSeries.GG";          Marca = "SteelSeries"; Vid = "1038" }
)

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

function Test-Admin {
    $yo = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $yo.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Vuelve a abrir el script como administrador. Devuelve $true si lo logro.
function Abrir-ComoAdmin {
    if ($PSCommandPath) {
        # Se ejecuto desde un archivo (INSTALAR.bat o -File)
        $argumentos = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        # Se ejecuto con irm | iex: la ventana nueva lo vuelve a descargar
        $cmd = "irm '$UrlScript' | iex"
        $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
        $argumentos = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc"
    }
    try {
        Start-Process powershell -Verb RunAs -ArgumentList $argumentos -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Get-InfoWindows {
    $os = Get-CimInstance Win32_OperatingSystem
    $cv = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue
    $version = $cv.DisplayVersion
    if (-not $version) { $version = $cv.ReleaseId }
    [pscustomobject]@{
        Nombre  = ($os.Caption -replace "^Microsoft\s+", "")
        Version = $version
        Build   = [int]$os.BuildNumber
    }
}

# Devuelve los IDs de winget de todo lo instalado (vacio si no se pudo leer)
function Get-AppsInstaladas {
    $tmp = Join-Path $env:TEMP "pcgamer-winget-export.json"
    try {
        & winget export -o $tmp --accept-source-agreements 2>&1 | Out-Null
        $json = Get-Content $tmp -Raw | ConvertFrom-Json
        $ids = @()
        foreach ($fuente in $json.Sources) {
            foreach ($paquete in $fuente.Packages) { $ids += $paquete.PackageIdentifier }
        }
        return $ids
    } catch {
        return @()
    } finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

# Muestra un paso con su lista y devuelve las apps elegidas.
# $porDefecto: apps que se eligen con Enter. $textoEnter: como se explica el Enter.
function Elegir($titulo, $apps, $porDefecto, $textoEnter) {
    while ($true) {
        Titulo $titulo
        for ($i = 0; $i -lt $apps.Count; $i++) {
            $marca = ""
            if ($apps[$i].Instalado)       { $marca = " (ya instalado)" }
            elseif ($apps[$i].Recomendado) { $marca = " (recomendado)" }
            Write-Host ("  {0}) {1}{2}" -f ($i + 1), $apps[$i].Nombre, $marca)
        }
        Write-Host "`nEnter = $textoEnter | numeros (ej: 1,3) | 0 = ninguno" -ForegroundColor Gray
        $r = Read-Host "Tu eleccion"

        if ([string]::IsNullOrWhiteSpace($r)) { return @($porDefecto) }
        if ($r.Trim() -eq "0") { return @() }

        $elegidas = @(); $valido = $true
        foreach ($parte in ($r -split ",")) {
            $n = $parte.Trim()
            if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le $apps.Count) {
                $app = $apps[[int]$n - 1]
                if ($elegidas -notcontains $app) { $elegidas += $app }
            } else {
                $valido = $false
            }
        }
        if ($valido) { return $elegidas }
        Write-Host "Respuesta no valida: usa numeros del 1 al $($apps.Count) separados por coma." -ForegroundColor Red
    }
}

function Preguntar-SN($pregunta, $siPorDefecto) {
    $sufijo = if ($siPorDefecto) { "(S/N, Enter = S)" } else { "(S/N, Enter = N)" }
    $r = Read-Host "$pregunta $sufijo"
    if ([string]::IsNullOrWhiteSpace($r)) { return [bool]$siPorDefecto }
    return ($r -match '^[sS]')
}

# ---------- PROGRAMA ----------

function Main {
    # Permisos de administrador
    if (-not (Test-Admin)) {
        Write-Host "Se necesitan permisos de administrador. Abriendo una ventana nueva..." -ForegroundColor Yellow
        if (Abrir-ComoAdmin) {
            Write-Host "Continua en la ventana nueva. Esta ya se puede cerrar."
        } else {
            Write-Host "No se dieron los permisos de administrador. No se hizo ningun cambio." -ForegroundColor Red
        }
        return
    }

    Clear-Host
    Titulo "INSTALADOR PC GAMER"
    Write-Host "Primero se analiza la PC y luego eliges, paso a paso, que instalar."
    Write-Host "No se instala ni se cambia nada hasta que confirmes el resumen final."
    Read-Host "`nPresiona Enter para empezar"

    # ===== ANALISIS (solo lee) =====
    Titulo "ANALIZANDO TU PC..."

    # Windows
    $win = Get-InfoWindows
    $avisos = @()
    $hagsDisponible = $win.Build -ge 19041
    Write-Host ("  Windows:     {0} {1} (build {2})" -f $win.Nombre, $win.Version, $win.Build) -NoNewline
    if ($win.Build -ge 22000) {
        Write-Host "   OK" -ForegroundColor Green
    } elseif ($hagsDisponible) {
        Write-Host "   OK (Windows 10)" -ForegroundColor Yellow
    } else {
        Write-Host "   VIEJO" -ForegroundColor Red
        $avisos += "Windows es anterior a 10 2004: HAGS no esta disponible y winget puede fallar. Conviene actualizar Windows."
    }

    # winget
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "  winget:      NO ENCONTRADO" -ForegroundColor Red
        Write-Host "`nSin winget no se puede instalar nada. Actualiza 'App Installer' desde la" -ForegroundColor Red
        Write-Host "Microsoft Store y vuelve a correr el instalador." -ForegroundColor Red
        Read-Host "`nEnter para cerrar"
        return
    }
    $wingetVersion = (& winget --version) | Select-Object -First 1
    Write-Host "  winget:      instalado ($wingetVersion)" -NoNewline
    Write-Host "   OK" -ForegroundColor Green

    # GPU
    $gpus = @((Get-CimInstance Win32_VideoController).Name)
    $driver = $null
    if ($gpus -match "AMD|Radeon") {
        $driver = @{ Nombre = "AMD Software (Adrenalin)"; Url = "https://www.amd.com/es/support/download/drivers.html" }
    } elseif ($gpus -match "NVIDIA|GeForce|RTX|GTX") {
        $driver = @{ Nombre = "NVIDIA App"; Url = "https://www.nvidia.com/es-la/software/nvidia-app/" }
    }
    Write-Host "  GPU:         $($gpus -join ', ')" -NoNewline
    if ($driver) { Write-Host "  -> recomendado: $($driver.Nombre)" -ForegroundColor Green }
    else         { Write-Host "  -> marca no reconocida, driver a mano" -ForegroundColor Yellow }

    # Perifericos conectados
    $dispositivos = @(Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
        Where-Object { $_.InstanceId -match '^(USB|HID)\\VID_' })
    $hayPerifericos = $false
    foreach ($p in $perifericos) {
        $suyos = @($dispositivos | Where-Object { $_.InstanceId -match "VID_$($p.Vid)" })
        $p.Recomendado = $suyos.Count -gt 0
        if ($p.Recomendado) {
            $nombres = @($suyos | Where-Object { $_.FriendlyName } |
                Select-Object -ExpandProperty FriendlyName -Unique | Select-Object -First 3)
            $etiqueta = if ($hayPerifericos) { "              " } else { "  Perifericos: " }
            Write-Host "$etiqueta$($p.Marca) ($($nombres -join ', '))" -NoNewline
            Write-Host "  -> recomendado: $($p.Nombre)" -ForegroundColor Green
            $hayPerifericos = $true
        }
    }
    if (-not $hayPerifericos) {
        Write-Host "  Perifericos: no se detecto Corsair, Logitech, Razer ni SteelSeries"
    }

    # Apps ya instaladas
    Write-Host "  Revisando apps ya instaladas (puede tardar unos segundos)..." -ForegroundColor Gray
    $instaladas = @(Get-AppsInstaladas)
    foreach ($app in ($launchers + $utilidades + $perifericos)) {
        $app.Instalado = $instaladas -contains $app.Id
    }
    $cuantas = @(($launchers + $utilidades + $perifericos) | Where-Object { $_.Instalado }).Count
    Write-Host "  Apps de la lista ya instaladas: $cuantas"

    foreach ($a in $avisos) { Write-Host "`n  AVISO: $a" -ForegroundColor Yellow }
    Read-Host "`nPresiona Enter para empezar los pasos"

    # ===== PASOS (solo se elige) =====
    $faltan = @($launchers | Where-Object { -not $_.Instalado })
    $selLaunchers = @(Elegir "PASO 1 de 5 - Launchers de juegos" $launchers $faltan "todos los que faltan")

    $faltan = @($utilidades | Where-Object { -not $_.Instalado })
    $selUtilidades = @(Elegir "PASO 2 de 5 - Utilidades" $utilidades $faltan "todos los que faltan")

    $recomendados = @($perifericos | Where-Object { $_.Recomendado -and -not $_.Instalado })
    $textoEnter = if ($recomendados.Count) { "los recomendados" } else { "ninguno" }
    $selPerifericos = @(Elegir "PASO 3 de 5 - Perifericos" $perifericos $recomendados $textoEnter)

    Titulo "PASO 4 de 5 - Driver de la tarjeta grafica"
    $abrirDriver = $false
    if ($driver) {
        Write-Host "Detectado: $($gpus -join ', ')"
        Write-Host "Recomendado: $($driver.Nombre). Se descarga e instala a mano desde su pagina."
        $abrirDriver = Preguntar-SN "Abrir la pagina del driver al terminar?" $true
    } else {
        Write-Host "No se reconocio la marca de la GPU ($($gpus -join ', '))."
        Write-Host "Instala el driver a mano despues."
        Read-Host "Enter para seguir"
    }

    Titulo "PASO 5 de 5 - Optimizar Windows para juegos"
    Write-Host "Esto hace:"
    Write-Host "  - Activa el Modo Juego de Windows"
    Write-Host "  - Pone el plan de energia en Alto rendimiento"
    if ($hagsDisponible) {
        Write-Host "  - Activa la programacion de GPU acelerada por hardware (HAGS)"
    } else {
        Write-Host "  - (HAGS no: tu Windows es muy viejo)" -ForegroundColor Gray
    }
    Write-Host "  - Corre WinUtil con el preset STANDARD (crea punto de restauracion,"
    Write-Host "    baja telemetria y servicios de fondo, limpia temporales)."
    Write-Host "    No toca Xbox, Store ni OneDrive."
    $optimizar = Preguntar-SN "`nOptimizar?" $false

    # ===== RESUMEN Y CONFIRMACION =====
    $aInstalar = @($selLaunchers + $selUtilidades + $selPerifericos)
    Titulo "RESUMEN - esto es lo que se va a hacer"
    if ($aInstalar.Count) {
        Write-Host "Instalar ($($aInstalar.Count)): $(($aInstalar | ForEach-Object { $_.Nombre }) -join ', ')"
    } else {
        Write-Host "Instalar: nada"
    }
    Write-Host "Abrir pagina del driver: $(if ($abrirDriver) { 'si' } else { 'no' })"
    Write-Host "Optimizar Windows: $(if ($optimizar) { 'si' } else { 'no' })"

    if (-not $aInstalar.Count -and -not $abrirDriver -and -not $optimizar) {
        Write-Host "`nNo elegiste nada. No se hizo ningun cambio."
        Read-Host "`nPresiona Enter para cerrar"
        return
    }
    if (-not (Preguntar-SN "`nConfirmar?" $false)) {
        Write-Host "Cancelado. No se instalo ni se cambio nada." -ForegroundColor Yellow
        Read-Host "`nPresiona Enter para cerrar"
        return
    }

    # ===== EJECUCION =====
    if ($aInstalar.Count) {
        Titulo "INSTALANDO (puedes dejar la PC sola)"
        foreach ($app in $aInstalar) { Instalar $app }
    }

    if ($optimizar) {
        Titulo "OPTIMIZANDO WINDOWS"
        # Modo Juego
        reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f | Out-Null
        reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode   /t REG_DWORD /d 1 /f | Out-Null
        # Plan de energia: Alto rendimiento
        powercfg /setactive SCHEME_MIN
        # HAGS (necesita reiniciar)
        if ($hagsDisponible) {
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f | Out-Null
        }
        Write-Host "Ajustes de juego aplicados." -ForegroundColor Green

        # WinUtil preset Standard (en otra ventana, espera a que termine)
        Write-Host "Abriendo WinUtil (preset Standard)... espera a que termine." -ForegroundColor Yellow
        $cmd = '& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Preset Standard'
        $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc" -Wait
    }

    if ($abrirDriver) { Start-Process $driver.Url }

    # ===== RESULTADO =====
    Titulo "RESULTADO"
    if ($aInstalar.Count) {
        Write-Host "Instaladas ($($script:ok.Count)): $($script:ok -join ', ')" -ForegroundColor Green
        if ($script:yaEstaba.Count) { Write-Host "Ya estaban ($($script:yaEstaba.Count)): $($script:yaEstaba -join ', ')" -ForegroundColor Gray }
        if ($script:fallo.Count) {
            Write-Host "Fallaron ($($script:fallo.Count)): $($script:fallo -join ', ')" -ForegroundColor Red
            Write-Host "  -> Vuelve a correr el instalador o instalalas a mano." -ForegroundColor Red
        }
    }

    Write-Host "`nPENDIENTE A MANO:" -ForegroundColor Yellow
    if ($driver) { Write-Host "  - Driver de la tarjeta grafica: $($driver.Nombre)" }
    else         { Write-Host "  - Driver de la tarjeta grafica" }
    Write-Host "  - Black Myth Wukong"
    Write-Host "  - Juegos: descargalos desde cada launcher (inicia sesion en cada uno)"
    Write-Host "  - Importar perfiles de iCUE y configuracion de FanControl"
    if ($optimizar) { Write-Host "`nREINICIA la PC para que se apliquen los ajustes de juego." -ForegroundColor Cyan }

    Read-Host "`nPresiona Enter para cerrar"
}

Main
