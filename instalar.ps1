# =====================================================
#  Instalador post-formateo - PC gamer de Adrian
#  Ventana con pestanas: Mi PC (analisis), Instalar, Optimizar.
#  Recomienda segun tu PC y tus dispositivos; tu marcas lo que quieras.
#  Usa winget (Windows 10/11).
#
#  Uso (PowerShell, no hace falta abrirlo como administrador):
#    irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex
#
#  Para quitar una app: pon # al inicio de su linea
#  Para agregar una: busca su ID con  winget search nombre
#  Detectar = nombre de la app en Windows (Agregar o quitar programas, o nombre del
#  paquete de la Store). Sirve aunque la app se haya instalado desde su web o la Store.
# =====================================================

$UrlScript = "https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1"

# ---------- LISTAS DE APPS ----------

$script:launchers = @(
    @{ Nombre = "Steam"; Web = "steampowered.com";            Id = "Valve.Steam";                 Detectar = '^Steam$' },
    @{ Nombre = "EA app"; Web = "ea.com";           Id = "ElectronicArts.EADesktop";    Detectar = '^EA app$' },
    @{ Nombre = "Epic Games"; Web = "epicgames.com";       Id = "EpicGames.EpicGamesLauncher"; Alternativa = "XP99VR1BPSBQJ2"; Detectar = 'Epic Games Launcher' },
    @{ Nombre = "GOG Galaxy"; Web = "gog.com";       Id = "GOG.Galaxy";                  Alternativa = "XPFFXW40W60KCF"; Detectar = 'GOG GALAXY' },
    @{ Nombre = "Ubisoft Connect"; Web = "ubisoft.com";  Id = "Ubisoft.Connect";             Detectar = 'Ubisoft Connect' },
    @{ Nombre = "Battle.net"; Web = "battle.net";       Id = "Blizzard.BattleNet";          Detectar = '^Battle\.net$' },
    @{ Nombre = "Xbox"; Web = "xbox.com";             Id = "9MV0B5HZVK9Z"; Fuente = "msstore"; Detectar = '^Microsoft\.GamingApp$' },
    @{ Nombre = "Playnite"; Web = "playnite.link";         Id = "Playnite.Playnite";           Detectar = '^Playnite' },
    # Riot: al marcarlo se eligen los juegos y la region (cada juego trae Riot Client)
    @{ Nombre = "Riot Games"; Web = "riotgames.com"; Opcional = $true; Sub = @(
        @{ Nombre = "Valorant";                Web = "playvalorant.com";    Base = "RiotGames.Valorant";        Clave = "Val"; Detectar = '^VALORANT$' },
        @{ Nombre = "League of Legends + TFT"; Web = "leagueoflegends.com"; Base = "RiotGames.LeagueOfLegends"; Clave = "Lol"; Detectar = '^League of Legends$' }
    ) }
)

# Regiones de Riot: sufijo del ID de winget de cada juego (verificado en winget-pkgs)
$script:regiones = @(
    @{ Nombre = "Latinoamerica Norte (LAN)";    Lol = "LA1";  Val = "LATAM" },
    @{ Nombre = "Latinoamerica Sur (LAS)";      Lol = "LA2";  Val = "LATAM" },
    @{ Nombre = "Norteamerica (NA)";            Lol = "NA";   Val = "NA" },
    @{ Nombre = "Brasil (BR)";                  Lol = "BR";   Val = "BR" },
    @{ Nombre = "Europa Oeste (EUW)";           Lol = "EUW";  Val = "EU" },
    @{ Nombre = "Europa Nordica y Este (EUNE)"; Lol = "EUNE"; Val = "EU" },
    @{ Nombre = "Corea (KR)";                   Lol = "KR";   Val = "KR" }
)

$script:utilidades = @(
    @{ Nombre = "Google Chrome"; Web = "chrome.com";    Id = "Google.Chrome";               Detectar = '^Google Chrome$' },
    @{ Nombre = "WinRAR"; Web = "win-rar.com";           Id = "RARLab.WinRAR";               Detectar = '^WinRAR' },
    @{ Nombre = "Transmission"; Web = "transmissionbt.com";     Id = "Transmission.Transmission";   Detectar = '^Transmission' },
    @{ Nombre = "VirtualBox"; Web = "virtualbox.org";       Id = "Oracle.VirtualBox";           Detectar = 'VirtualBox' },
    @{ Nombre = "VLC";              Web = "videolan.org";        Id = "VideoLAN.VLC";                Detectar = '^VLC media player' },
    @{ Nombre = "iTunes"; Web = "apple.com";           Id = "9PB2MZ1ZMB1S"; Fuente = "msstore"; Detectar = '^iTunes$|^AppleInc\.iTunes$' },
    @{ Nombre = "PC Manager"; Web = "pcmanager.microsoft.com";       Id = "9PM860492SZD"; Fuente = "msstore"; Detectar = '^PC Manager$|^Microsoft\.MicrosoftPCManager$' },
    @{ Nombre = "Terminal Windows"; Web = "microsoft.com"; Id = "Microsoft.WindowsTerminal";   Detectar = '^Microsoft\.WindowsTerminal$' },
    @{ Nombre = "FanControl"; Web = "getfancontrol.com";       Id = "Rem0o.FanControl";            Detectar = '^Fan ?Control' },
    @{ Nombre = "Dolby Access"; Web = "dolby.com";     Id = "9N0866FS04W8"; Fuente = "msstore"; Detectar = '^Dolby Access$|^DolbyLaboratories\.DolbyAccess$' }
)

# Extras para gamers: opcionales, no vienen marcados
$script:extras = @(
    @{ Nombre = "Discord";         Web = "discord.com";    Id = "Discord.Discord";        Opcional = $true; Detectar = '^Discord$' },
    @{ Nombre = "OBS Studio";      Web = "obsproject.com"; Id = "OBSProject.OBSStudio";   Opcional = $true; Detectar = '^OBS Studio' },
    @{ Nombre = "MSI Afterburner"; Web = "msi.com";        Id = "Guru3D.Afterburner";     Opcional = $true; Detectar = '^MSI Afterburner' },
    @{ Nombre = "HWiNFO";          Web = "hwinfo.com";     Id = "REALiX.HWiNFO";          Opcional = $true; Detectar = '^HWiNFO' }
)

# Web = dominio oficial, solo para mostrar su icono en la ventana
# Alternativa = ID de la Microsoft Store que se prueba si la instalacion normal falla
# Vid = ID de fabricante USB, para detectar si hay un periferico de esa marca conectado
$script:perifericos = @(
    @{ Nombre = "Corsair iCUE 5"; Web = "corsair.com";   Id = "Corsair.iCUE.5";          Marca = "Corsair";     Vid = "1B1C"; Detectar = '^iCUE|^Corsair iCUE ?5? ?Software' },
    @{ Nombre = "Logitech G HUB"; Web = "logitechg.com";   Id = "Logitech.GHUB";           Marca = "Logitech";    Vid = "046D"; Detectar = 'Logitech G HUB' },
    @{ Nombre = "Razer Synapse 4"; Web = "razer.com";  Id = "RazerInc.RazerInstaller.Synapse4"; Marca = "Razer"; Vid = "1532"; Detectar = 'Razer Synapse' },
    @{ Nombre = "SteelSeries GG"; Web = "steelseries.com";   Id = "SteelSeries.GG";          Marca = "SteelSeries"; Vid = "1038"; Detectar = 'SteelSeries GG' },
    @{ Nombre = "Turtle Beach Audio Hub"; Web = "turtlebeach.com"; Id = "TurtleBeach.AudioHub"; Marca = "Turtle Beach"; Vid = "10F5"; Detectar = 'Turtle Beach Audio Hub|^Audio Hub' },
    @{ Nombre = "ROCCAT Swarm II"; Web = "roccat.com";  Id = "TurtleBeach.ROCCATSwarm"; Marca = "ROCCAT";       Vid = "1E7D"; Detectar = 'ROCCAT Swarm' },
    @{ Nombre = "Elgato Stream Deck"; Web = "elgato.com"; Id = "Elgato.StreamDeck";     Marca = "Elgato";       Vid = "0FD9"; Detectar = 'Stream Deck' },
    # ASUS usa el mismo VID en placas madre y adaptadores Bluetooth: solo cuenta si el nombre parece periferico
    @{ Nombre = "ASUS Armoury Crate"; Web = "asus.com"; Id = "Asus.ArmouryCrate";      Marca = "ASUS ROG";     Vid = "0B05"; Filtro = 'ROG|TUF|Keyboard|Mouse|Headset|Teclado|Auricular'; Detectar = '^Armoury Crate' }
)

# Drivers de GPU. Id = ID de winget. AMD Adrenalin y NVIDIA App no estan en winget (verificado en
# winget-pkgs), por eso su Id esta vacio y se abre la pagina oficial.
# Si la instalacion con winget falla, tambien se abre la pagina oficial.
$script:drivers = @{
    AMD    = @{ Nombre = "AMD Software (Adrenalin)"; Web = "amd.com";        Id = ""; Url = "https://www.amd.com/es/support/download/drivers.html";               Detectar = '^AMD Software|^AMD Radeon Software' }
    NVIDIA = @{ Nombre = "NVIDIA App"; Web = "nvidia.com";                      Id = ""; Url = "https://www.nvidia.com/es-la/software/nvidia-app/";                  Detectar = '^NVIDIA app|^NVIDIA Graphics Driver' }
    Intel  = @{ Nombre = "Intel Driver & Support Assistant"; Web = "intel.com"; Id = "Intel.IntelDriverAndSupportAssistant"; Url = "https://www.intel.la/content/www/xl/es/support/detect.html";        Detectar = '^Intel.*Driver.*Support Assistant' }
}

# Descripcion corta de cada app (se muestra en su tarjeta)
$script:info = @{
    "Steam"                   = "La tienda y biblioteca de juegos de PC mas grande."
    "EA app"                  = "Battlefield, EA Sports FC y los juegos de EA."
    "Epic Games"              = "Fortnite y juegos gratis cada semana."
    "GOG Galaxy"              = "Juegos sin DRM, como Cyberpunk 2077 y The Witcher 3."
    "Ubisoft Connect"         = "Assassin's Creed, Far Cry y los juegos de Ubisoft."
    "Battle.net"              = "Call of Duty, Diablo, Overwatch y World of Warcraft."
    "Xbox"                    = "Game Pass, Call of Duty y Halo desde la Microsoft Store."
    "Playnite"                = "Todas tus bibliotecas de juegos en un solo lugar."
    "Riot Games"              = "Valorant y League of Legends. Al marcarlo eliges los juegos y tu region."
    "Valorant"                = "Shooter tactico 5 contra 5. Incluye Riot Client."
    "League of Legends + TFT" = "MOBA 5 contra 5 y Teamfight Tactics. Incluye Riot Client."
    "Google Chrome"           = "El navegador web de Google."
    "WinRAR"                  = "Abre y crea archivos .rar y .zip."
    "Transmission"            = "Descargas por torrent, ligero y sin anuncios."
    "VirtualBox"              = "Maquinas virtuales para probar otros sistemas."
    "VLC"                     = "Reproduce cualquier video o audio."
    "iTunes"                  = "Musica y respaldo de tu iPhone."
    "PC Manager"              = "Limpieza y mantenimiento de Windows, de Microsoft."
    "Terminal Windows"        = "Consola moderna para PowerShell y CMD."
    "FanControl"              = "Controla los ventiladores segun la temperatura."
    "Dolby Access"            = "Sonido envolvente Dolby Atmos para audifonos."
    "Discord"                 = "Chat de voz y texto con tus amigos mientras juegas."
    "OBS Studio"              = "Graba y transmite tus partidas."
    "MSI Afterburner"         = "FPS y temperaturas en pantalla mientras juegas."
    "HWiNFO"                  = "Sensores y temperaturas de todo tu hardware."
    "Corsair iCUE 5"          = "RGB, macros y ventiladores de Corsair."
    "Logitech G HUB"          = "Configura tu mouse, teclado y audifonos Logitech G."
    "Razer Synapse 4"         = "Configura tus perifericos Razer."
    "SteelSeries GG"          = "Configura tus perifericos SteelSeries."
    "Turtle Beach Audio Hub"  = "Configura tus audifonos Turtle Beach."
    "ROCCAT Swarm II"         = "Configura tus perifericos ROCCAT."
    "Elgato Stream Deck"      = "Botones para streaming y atajos."
    "ASUS Armoury Crate"      = "RGB y perifericos ASUS ROG y TUF."
}

# ---------- AJUSTES (todos reversibles salvo los que lo dicen) ----------
# Recomendar recibe la info de la PC y devuelve si se marca por defecto.

function Set-Reg($ruta, $nombre, $valor, $tipo = "DWord") {
    if (-not (Test-Path $ruta)) { New-Item -Path $ruta -Force | Out-Null }
    New-ItemProperty -Path $ruta -Name $nombre -Value $valor -PropertyType $tipo -Force | Out-Null
}
function Remove-Reg($ruta, $nombre) {
    Remove-ItemProperty -Path $ruta -Name $nombre -ErrorAction SilentlyContinue
}

$script:ajustes = @(
    @{ Nombre = "Punto de restauracion - Crear"
       Desc = "Crea un punto de restauracion antes de aplicar los demas ajustes, para poder volver atras desde 'Crear un punto de restauracion > Restaurar sistema'."
       Recomendar = { param($pc) $true }
       Aplicar = {
           Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
           Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" 0
           Checkpoint-Computer -Description "PCgamer" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
       }
       Revertir = $null },

    @{ Nombre = "Modo Juego - Activar"
       Desc = "Windows prioriza el juego que esta abierto y evita actualizaciones en segundo plano mientras juegas."
       Recomendar = { param($pc) $true }
       Aplicar  = { Set-Reg "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 1; Set-Reg "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1 }
       Revertir = { Set-Reg "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 0; Set-Reg "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 0 } },

    @{ Nombre = "Plan de energia - Alto rendimiento"
       Desc = "El procesador no baja su velocidad para ahorrar energia. Recomendado en PC de escritorio; en laptop gasta mas bateria. Revertir vuelve al plan Equilibrado."
       Recomendar = { param($pc) -not $pc.EsLaptop }
       Aplicar  = { powercfg /setactive SCHEME_MIN | Out-Null }
       Revertir = { powercfg /setactive SCHEME_BALANCED | Out-Null } },

    @{ Nombre = "GPU acelerada por hardware (HAGS) - Activar"
       Desc = "La tarjeta grafica administra su propia memoria. Mejora un poco la latencia. Necesita Windows 10 2004 o mas nuevo y reiniciar."
       Recomendar = { param($pc) $pc.Build -ge 19041 }
       Aplicar  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 2 }
       Revertir = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 1 } },

    @{ Nombre = "Aceleracion del mouse - Desactivar"
       Desc = "El puntero se mueve siempre igual sin importar la velocidad del movimiento. Mejor punteria en juegos. Se aplica al cerrar sesion."
       Recomendar = { param($pc) $true }
       Aplicar  = { $m = "HKCU:\Control Panel\Mouse"; Set-Reg $m "MouseSpeed" "0" "String"; Set-Reg $m "MouseThreshold1" "0" "String"; Set-Reg $m "MouseThreshold2" "0" "String" }
       Revertir = { $m = "HKCU:\Control Panel\Mouse"; Set-Reg $m "MouseSpeed" "1" "String"; Set-Reg $m "MouseThreshold1" "6" "String"; Set-Reg $m "MouseThreshold2" "10" "String" } },

    @{ Nombre = "Telemetria - Reducir"
       Desc = "Envia menos datos de diagnostico a Microsoft (en Windows Home queda en el minimo permitido). No afecta Xbox ni la Store."
       Recomendar = { param($pc) $true }
       Aplicar  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0 }
       Revertir = { Remove-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" } },

    @{ Nombre = "Historial de actividad - Desactivar"
       Desc = "Windows deja de guardar y enviar que apps y archivos abres."
       Recomendar = { param($pc) $true }
       Aplicar  = { $r = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Set-Reg $r "EnableActivityFeed" 0; Set-Reg $r "PublishUserActivities" 0; Set-Reg $r "UploadUserActivities" 0 }
       Revertir = { $r = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Remove-Reg $r "EnableActivityFeed"; Remove-Reg $r "PublishUserActivities"; Remove-Reg $r "UploadUserActivities" } },

    @{ Nombre = "Efectos visuales - Mejor rendimiento"
       Desc = "Quita animaciones y sombras de Windows. Recomendado si tienes menos de 16 GB de RAM. Se aplica al cerrar sesion."
       Recomendar = { param($pc) $pc.RamGB -gt 0 -and $pc.RamGB -lt 16 }
       Aplicar  = { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 2 }
       Revertir = { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 0 } },

    @{ Nombre = "Hibernacion - Desactivar"
       Desc = "Libera varios GB del disco (el archivo hiberfil.sys) y desactiva el inicio rapido. Recomendado en PC de escritorio; en laptop la hibernacion es util."
       Recomendar = { param($pc) -not $pc.EsLaptop }
       Aplicar  = { powercfg /hibernate off | Out-Null }
       Revertir = { powercfg /hibernate on | Out-Null } },

    @{ Nombre = "Archivos temporales - Limpiar"
       Desc = "Borra los archivos temporales de Windows y de tu usuario. No se puede revertir, pero no borra nada importante."
       Recomendar = { param($pc) $true }
       Aplicar  = { Remove-Item "$env:TEMP\*", "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue }
       Revertir = $null }
)

# ---------- DETECCION ----------

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
        # Se ejecuto con irm | iex: la ventana nueva lo vuelve a descargar (con un archivo
        # temporal y no -EncodedCommand, que el antivirus puede bloquear)
        $archivo = Join-Path $env:TEMP "pcgamer-lanzador.ps1"
        Set-Content -Path $archivo -Value "irm '$UrlScript' | iex" -Encoding ASCII
        $argumentos = "-NoProfile -ExecutionPolicy Bypass -File `"$archivo`""
    }
    try {
        # Oculta: solo se ve la ventana del instalador
        Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList $argumentos -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Nombres de todo lo instalado: programas (Agregar o quitar programas) y apps de la Store
function Get-NombresInstalados {
    $rutas = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $nombres = @(Get-ItemProperty $rutas -ErrorAction SilentlyContinue |
        ForEach-Object { $_.DisplayName } | Where-Object { $_ })
    $nombres += @(Get-AppxPackage -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    return $nombres
}

# IDs de winget de todo lo instalado (vacio si no se pudo leer)
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

function Todas-Apps { $script:launchers + $script:utilidades + $script:extras + $script:perifericos }

# Region de Riot por defecto segun el pais de Windows (indice en $regiones)
function Get-RegionRiot {
    $pais = ""
    try { $pais = [System.Globalization.RegionInfo]::CurrentRegion.TwoLetterISORegionName } catch { }
    switch -regex ($pais) {
        '^(AR|CL|UY|PY|BO)$'                        { return 1 }
        '^(US|CA)$'                                 { return 2 }
        '^BR$'                                      { return 3 }
        '^(ES|FR|DE|IT|PT|GB|IE|NL|BE|CH|AT)$'      { return 4 }
        '^(PL|CZ|SE|NO|DK|FI|GR|RO|HU)$'            { return 5 }
        '^KR$'                                      { return 6 }
        default                                     { return 0 }
    }
}

function Get-InfoPC {
    $pc = @{ Avisos = @() }

    $os = Get-CimInstance Win32_OperatingSystem
    $cv = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue
    $pc.Windows = ($os.Caption -replace "^Microsoft\s+", "")
    $pc.Version = $cv.DisplayVersion
    if (-not $pc.Version) { $pc.Version = $cv.ReleaseId }
    $pc.Build = [int]$os.BuildNumber

    try { $pc.CPU = ((Get-CimInstance Win32_Processor | Select-Object -First 1).Name).Trim() } catch { $pc.CPU = "?" }
    $pc.GPUs = @((Get-CimInstance Win32_VideoController).Name)

    $pc.RamGB = 0; $pc.RamTipo = ""; $pc.RamMhz = 0
    try {
        $pc.RamGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        $mem = @(Get-CimInstance Win32_PhysicalMemory)
        switch ([int]$mem[0].SMBIOSMemoryType) { 34 { $pc.RamTipo = "DDR5" } 26 { $pc.RamTipo = "DDR4" } }
        $pc.RamMhz = [int](($mem | Measure-Object -Property ConfiguredClockSpeed -Minimum).Minimum)
    } catch { }

    $pc.Disco = "?"
    try {
        $part = Get-Partition -DriveLetter $env:SystemDrive.Substring(0, 1) -ErrorAction Stop
        $fisico = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq [string]$part.DiskNumber } | Select-Object -First 1
        if ($fisico.MediaType -and "$($fisico.MediaType)" -ne "Unspecified") { $pc.Disco = "$($fisico.MediaType)" }
    } catch { }

    $pc.EsLaptop = @(Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue).Count -gt 0

    $pc.Winget = $null
    if (Get-Command winget -ErrorAction SilentlyContinue) { $pc.Winget = (& winget --version) | Select-Object -First 1 }

    # Instalado: por ID de winget o por nombre en Windows
    $ids = @(); if ($pc.Winget) { $ids = @(Get-AppsInstaladas) }
    $nombres = @(Get-NombresInstalados)
    foreach ($app in (Todas-Apps)) {
        if ($app.Sub) {
            foreach ($sub in $app.Sub) {
                $sub.Instalado = (@($ids -match "^$([regex]::Escape($sub.Base))\.").Count -gt 0) -or (@($nombres -match $sub.Detectar).Count -gt 0)
            }
            $app.Instalado = @($app.Sub | Where-Object { $_.Instalado }).Count -gt 0
        } else {
            $app.Instalado = ($ids -contains $app.Id) -or (@($nombres -match $app.Detectar).Count -gt 0)
        }
    }

    # Driver de GPU
    $pc.Driver = $null
    if ($pc.GPUs -match "AMD|Radeon")                { $pc.Driver = $script:drivers.AMD }
    elseif ($pc.GPUs -match "NVIDIA|GeForce|RTX|GTX") { $pc.Driver = $script:drivers.NVIDIA }
    elseif ($pc.GPUs -match "Intel")                  { $pc.Driver = $script:drivers.Intel }
    $pc.DriverInstalado = $false
    if ($pc.Driver) { $pc.DriverInstalado = @($nombres -match $pc.Driver.Detectar).Count -gt 0 }

    # Perifericos conectados
    $dispositivos = @(Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
        Where-Object { $_.InstanceId -match '^(USB|HID)\\VID_' })
    foreach ($p in $script:perifericos) {
        $suyos = @($dispositivos | Where-Object { $_.InstanceId -match "VID_$($p.Vid)" })
        if ($p.Filtro) { $suyos = @($suyos | Where-Object { $_.FriendlyName -match $p.Filtro }) }
        $p.Conectado = $suyos.Count -gt 0
        $p.Cantidad = $suyos.Count
        # Windows suele dar nombres genericos ("Dispositivo de entrada USB"): esos no se muestran
        $generico = 'Dispositivo|Device|USB Input|HID|compatible|Composite|compuesto|Concentrador|Hub|Controlador|Controller|Raiz|Root'
        $p.Dispositivos = @($suyos | Where-Object { $_.FriendlyName -and $_.FriendlyName -notmatch $generico } |
            Select-Object -ExpandProperty FriendlyName -Unique | Select-Object -First 3)
    }

    # Recomendaciones de apps
    foreach ($app in ($script:launchers + $script:utilidades + $script:extras)) { $app.Recomendado = -not $app.Instalado -and -not $app.Opcional }
    foreach ($p in $script:perifericos) { $p.Recomendado = $p.Conectado -and -not $p.Instalado }
    foreach ($aj in $script:ajustes) { $aj.Recomendado = [bool](& $aj.Recomendar $pc) }

    return $pc
}

# ---------- VENTANA ----------
# Estilo de la bienvenida de Windows 11: una pagina a la vez, titulo y explicacion a la izquierda,
# tarjetas con icono y casilla a la derecha, y flechas abajo para avanzar o volver.

$script:xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PC Gamer" Width="1280" Height="800" MinWidth="1000" MinHeight="640"
        WindowStartupLocation="CenterScreen" WindowState="Maximized" Background="#FAFAFA"
        FontFamily="Segoe UI Variable Text, Segoe UI" FontSize="14" Foreground="#1B1B1B">
  <Window.Resources>
    <Style x:Key="Primario" TargetType="Button">
      <Setter Property="Background" Value="#0067C0"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Padding" Value="28,8"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="HorizontalAlignment" Value="Left"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Background" Value="#1975C5"/></Trigger>
              <Trigger Property="IsPressed" Value="True"><Setter TargetName="b" Property="Background" Value="#005A9E"/></Trigger>
              <Trigger Property="IsEnabled" Value="False"><Setter TargetName="b" Property="Opacity" Value="0.4"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="Enlace" TargetType="Button">
      <Setter Property="Foreground" Value="#0067C0"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="HorizontalAlignment" Value="Left"/>
      <Setter Property="Margin" Value="0,6,0,0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <TextBlock x:Name="t" Text="{Binding Content, RelativeSource={RelativeSource TemplatedParent}}" Foreground="{TemplateBinding Foreground}"/>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="t" Property="TextDecorations" Value="Underline"/></Trigger>
              <Trigger Property="IsEnabled" Value="False"><Setter TargetName="t" Property="Opacity" Value="0.4"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="Nav" TargetType="Button">
      <Setter Property="FontFamily" Value="Segoe Fluent Icons, Segoe MDL2 Assets"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Width" Value="36"/>
      <Setter Property="Height" Value="32"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="White" BorderBrush="#E5E5E5" BorderThickness="1" CornerRadius="4">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Background" Value="#F3F3F3"/></Trigger>
              <Trigger Property="IsEnabled" Value="False"><Setter TargetName="b" Property="Opacity" Value="0.35"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="Titulo" TargetType="TextBlock">
      <Setter Property="FontFamily" Value="Segoe UI Variable Display, Segoe UI"/>
      <Setter Property="FontSize" Value="40"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="TextWrapping" Value="Wrap"/>
      <Setter Property="Margin" Value="0,0,0,20"/>
    </Style>
    <Style x:Key="Desc" TargetType="TextBlock">
      <Setter Property="FontSize" Value="16"/>
      <Setter Property="Foreground" Value="#5F5F5F"/>
      <Setter Property="TextWrapping" Value="Wrap"/>
      <Setter Property="LineHeight" Value="24"/>
      <Setter Property="Margin" Value="0,0,0,24"/>
    </Style>
    <Style x:Key="Izq" TargetType="StackPanel">
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="Margin" Value="56,0,40,0"/>
    </Style>
    <Style x:Key="Der" TargetType="ScrollViewer">
      <Setter Property="Grid.Column" Value="1"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="VerticalScrollBarVisibility" Value="Auto"/>
      <Setter Property="Margin" Value="0,40,48,16"/>
      <Setter Property="Padding" Value="0,0,8,0"/>
    </Style>
  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <Grid>
      <!-- 0. Inicio -->
      <Grid x:Name="PagInicio">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock x:Name="TxtHola" Style="{StaticResource Titulo}" Text="Hola"/>
          <TextBlock Style="{StaticResource Desc}" Text="Vamos a dejar tu PC lista para jugar: driver de video, programas y optimizacion de Windows, con un solo reinicio al final. Antes de empezar, conecta tus perifericos (teclado, mouse, audifonos) para que se detecten."/>
          <Button x:Name="BtnComenzar" Style="{StaticResource Primario}" Content="Comenzar"/>
        </StackPanel>
        <Border Grid.Column="1" Margin="40,64,0,64" CornerRadius="12,0,0,12">
          <Border.Background>
            <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
              <GradientStop Color="#0B1F4D" Offset="0"/>
              <GradientStop Color="#0067C0" Offset="0.55"/>
              <GradientStop Color="#7C3AED" Offset="1"/>
            </LinearGradientBrush>
          </Border.Background>
          <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
            <TextBlock Text="&#xE7FC;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="150" Foreground="White" HorizontalAlignment="Center"/>
            <TextBlock Text="PC Gamer" FontSize="40" FontWeight="SemiBold" Foreground="White" HorizontalAlignment="Center" Margin="0,20,0,0"/>
            <TextBlock Text="Driver   -   Programas   -   Optimizacion" FontSize="16" Foreground="#DBEAFE" HorizontalAlignment="Center" Margin="0,8,0,0"/>
          </StackPanel>
        </Border>
      </Grid>

      <!-- 1. Tu PC -->
      <Grid x:Name="PagMiPC" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Esta es tu PC"/>
          <TextBlock Style="{StaticResource Desc}" Text="Revisamos tu hardware, tus perifericos y lo que ya tienes instalado. Con esto, en los siguientes pasos ya viene marcado lo recomendado para ti. Nada se instala hasta el final."/>
          <Button x:Name="BtnEscanear" Style="{StaticResource Enlace}" Content="Volver a analizar (si conectaste algo nuevo)"/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlInfo"/></ScrollViewer>
      </Grid>

      <!-- 2. Driver -->
      <Grid x:Name="PagDriver" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Driver de video"/>
          <TextBlock x:Name="TxtDriver" Style="{StaticResource Desc}"/>
          <Button x:Name="BtnDriverPagina" Style="{StaticResource Enlace}" Content="Abrir la pagina oficial del driver"/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlDriver"/></ScrollViewer>
      </Grid>

      <!-- 3. Launchers -->
      <Grid x:Name="PagLaunchers" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Tus launchers de juegos"/>
          <TextBlock Style="{StaticResource Desc}" Text="Las tiendas donde estan tus juegos. Lo que te falta viene marcado y lo que ya tienes lleva un check verde. Marca o desmarca lo que quieras: haz clic en cualquier parte de la tarjeta."/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlLaunchers"/></ScrollViewer>
      </Grid>

      <!-- 4. Utilidades -->
      <Grid x:Name="PagUtilidades" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Agrega aplicaciones utiles"/>
          <TextBlock Style="{StaticResource Desc}" Text="Programas para el dia a dia: navegador, archivos comprimidos, videos y mantenimiento de tu PC."/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlUtilidades"/></ScrollViewer>
      </Grid>

      <!-- 5. Extras -->
      <Grid x:Name="PagExtras" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Extras para gamers"/>
          <TextBlock Style="{StaticResource Desc}" Text="Los mas populares para chatear, grabar tus partidas y ver tus FPS y temperaturas. Vienen sin marcar para no llenar tu PC: elige solo lo que vayas a usar."/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlExtras"/></ScrollViewer>
      </Grid>

      <!-- 6. Perifericos -->
      <Grid x:Name="PagPerifericos" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Tus perifericos"/>
          <TextBlock x:Name="TxtPerif" Style="{StaticResource Desc}"/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlPerifericos"/></ScrollViewer>
      </Grid>

      <!-- 7. Optimizar -->
      <Grid x:Name="PagOptimizar" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Optimiza Windows para jugar"/>
          <TextBlock Style="{StaticResource Desc}" Text="Ajustes recomendados segun tu PC (escritorio o laptop, RAM y version de Windows). Todos se pueden revertir, menos la limpieza de temporales. Ninguno toca Xbox, la Store ni OneDrive."/>
          <Button x:Name="BtnAjRec" Style="{StaticResource Enlace}" Content="Marcar solo los recomendados"/>
          <Button x:Name="BtnAjNada" Style="{StaticResource Enlace}" Content="Desmarcar todos"/>
          <Button x:Name="BtnRevertir" Style="{StaticResource Enlace}" Content="Revertir ahora los ajustes marcados"/>
          <Button x:Name="BtnWinUtil" Style="{StaticResource Enlace}" Content="Abrir WinUtil (opcional, para usuarios avanzados)"/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlAjustes"/></ScrollViewer>
      </Grid>

      <!-- 8. Resumen -->
      <Grid x:Name="PagResumen" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Todo listo para empezar"/>
          <TextBlock x:Name="TxtResumenDesc" Style="{StaticResource Desc}" Text="Esto es lo que se va a hacer, en este orden. Puedes dejar la PC sola mientras se instala. Si quieres cambiar algo, vuelve con la flecha."/>
          <Button x:Name="BtnInstalar" Style="{StaticResource Primario}" Content="Instalar y optimizar"/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlResumen"/></ScrollViewer>
      </Grid>

      <!-- 9. Progreso -->
      <Grid x:Name="PagProgreso" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock Style="{StaticResource Titulo}" Text="Preparando tu PC"/>
          <TextBlock x:Name="TxtProgreso" Style="{StaticResource Desc}" Text="Empezando..."/>
          <ProgressBar x:Name="BarProgreso" Height="6" Minimum="0" Maximum="1" Value="0" Foreground="#0067C0" Background="#E5E5E5" BorderThickness="0" Margin="0,0,0,20"/>
          <Button x:Name="BtnSaltar" Style="{StaticResource Enlace}" Content="Saltar este programa (si se quedo pegado)"/>
          <Button x:Name="BtnDetalles" Style="{StaticResource Enlace}" Content="Ver detalles"/>
          <TextBox x:Name="Log" Visibility="Collapsed" Height="200" Margin="0,16,0,0" IsReadOnly="True" TextWrapping="Wrap"
                   VerticalScrollBarVisibility="Auto" Background="#1B1B1B" Foreground="#D1FAE5" FontFamily="Consolas"
                   FontSize="12" BorderThickness="0" Padding="8"/>
        </StackPanel>
        <ScrollViewer Style="{StaticResource Der}"><StackPanel x:Name="PnlProgreso"/></ScrollViewer>
      </Grid>

      <!-- 10. Final -->
      <Grid x:Name="PagFinal" Visibility="Collapsed">
        <Grid.ColumnDefinitions><ColumnDefinition Width="5*"/><ColumnDefinition Width="6*"/></Grid.ColumnDefinitions>
        <StackPanel Style="{StaticResource Izq}">
          <TextBlock x:Name="TxtFinalTitulo" Style="{StaticResource Titulo}" Text="Todo listo"/>
          <TextBlock x:Name="TxtResumen" Style="{StaticResource Desc}"/>
          <Button x:Name="BtnReiniciar" Style="{StaticResource Primario}" Content="Reiniciar ahora"/>
          <Button x:Name="BtnVolver" Style="{StaticResource Enlace}" Content="Volver al inicio" Margin="0,16,0,0"/>
        </StackPanel>
        <Border Grid.Column="1" Margin="40,64,0,64" CornerRadius="12,0,0,12">
          <Border.Background>
            <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
              <GradientStop Color="#065F46" Offset="0"/>
              <GradientStop Color="#0067C0" Offset="0.6"/>
              <GradientStop Color="#7C3AED" Offset="1"/>
            </LinearGradientBrush>
          </Border.Background>
          <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
            <TextBlock Text="&#xE73E;" FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets" FontSize="150" Foreground="White" HorizontalAlignment="Center"/>
            <TextBlock Text="Tu PC esta lista para jugar" FontSize="32" FontWeight="SemiBold" Foreground="White" HorizontalAlignment="Center" Margin="0,20,0,0"/>
          </StackPanel>
        </Border>
      </Grid>
    </Grid>

    <!-- Barra de abajo: inicio, paso actual, estado y flechas -->
    <Grid Grid.Row="1" Margin="12,8,12,12">
      <StackPanel Orientation="Horizontal" HorizontalAlignment="Left">
        <Button x:Name="BtnHome" Style="{StaticResource Nav}" Content="&#xE80F;" ToolTip="Inicio"/>
        <TextBlock x:Name="TxtPaso" VerticalAlignment="Center" Margin="12,0,0,0" Foreground="#5F5F5F"/>
      </StackPanel>
      <TextBlock x:Name="TxtEstado" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#8A8A8A"
                 FontSize="12" TextTrimming="CharacterEllipsis" MaxWidth="640"/>
      <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
        <Button x:Name="BtnAtras" Style="{StaticResource Nav}" Content="&#xE76B;" ToolTip="Atras" Margin="0,0,8,0"/>
        <Button x:Name="BtnSiguiente" Style="{StaticResource Nav}" Content="&#xE76C;" ToolTip="Siguiente"/>
      </StackPanel>
    </Grid>
  </Grid>
</Window>
'@

# Paginas en orden. Del 1 al 8 son los pasos que se recorren con las flechas.
$script:paginas = @("PagInicio", "PagMiPC", "PagDriver", "PagLaunchers", "PagUtilidades", "PagExtras",
                    "PagPerifericos", "PagOptimizar", "PagResumen", "PagProgreso", "PagFinal")
$script:pag = 0
$script:ocupado = $false
$script:escaneado = $false
$script:pc = @{}

function Pump {
    $script:window.Dispatcher.Invoke([Action]{}, [Windows.Threading.DispatcherPriority]::Background)
}

function Log($texto) {
    $script:ui.Log.AppendText("$texto`r`n")
    $script:ui.Log.ScrollToEnd()
    $script:ui.TxtEstado.Text = "$texto".Trim()
    Pump
}

function Ir($i) {
    for ($k = 0; $k -lt $script:paginas.Count; $k++) {
        $script:ui[$script:paginas[$k]].Visibility = if ($k -eq $i) { "Visible" } else { "Collapsed" }
    }
    $script:pag = $i
    if ($script:paginas[$i] -eq "PagResumen") { Llenar-Resumen }
    Actualizar-Nav
}

function Actualizar-Nav {
    $ui = $script:ui; $i = $script:pag; $libre = -not $script:ocupado
    $ui.BtnAtras.IsEnabled     = $libre -and $i -ge 1 -and $i -le 8
    $ui.BtnSiguiente.IsEnabled = $libre -and $i -ge 1 -and $i -le 7
    $ui.BtnHome.IsEnabled      = $libre -and $i -ne 0 -and $i -ne 9
    $ui.TxtPaso.Text = if ($i -ge 1 -and $i -le 8) { "Paso $i de 8" } else { "" }
}

function Bloquear($si) {
    $script:ocupado = $si
    foreach ($b in "BtnComenzar", "BtnEscanear", "BtnDriverPagina", "BtnInstalar", "BtnRevertir", "BtnWinUtil", "BtnAjRec", "BtnAjNada") {
        $script:ui[$b].IsEnabled = -not $si
    }
    if (-not $si -and -not $script:pc.Driver) { $script:ui.BtnDriverPagina.IsEnabled = $false }
    Actualizar-Nav
    Pump
}

function Pincel($hex) { (New-Object System.Windows.Media.BrushConverter).ConvertFromString($hex) }

# Icono oficial de la app (favicon de su sitio, se descarga en segundo plano). Sin internet queda vacio.
$script:iconos = @{}
function Nuevo-Icono($web, $tam) {
    $img = New-Object System.Windows.Controls.Image
    $img.Width = $tam; $img.Height = $tam
    $img.VerticalAlignment = "Center"
    if ($web) {
        if (-not $script:iconos.ContainsKey($web)) {
            $script:iconos[$web] = $null
            try {
                $bi = New-Object System.Windows.Media.Imaging.BitmapImage
                $bi.BeginInit()
                $bi.UriSource = New-Object System.Uri "https://www.google.com/s2/favicons?domain=$web&sz=64"
                $bi.DecodePixelWidth = 64
                $bi.EndInit()
                $script:iconos[$web] = $bi
            } catch { }
        }
        $img.Source = $script:iconos[$web]
    }
    return $img
}

# Icono de Windows (fuente de simbolos), para lo que no tiene sitio web
function Nuevo-Glifo($codigo, $tam, $color) {
    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = [string][char]$codigo
    $t.FontFamily = New-Object System.Windows.Media.FontFamily "Segoe Fluent Icons, Segoe MDL2 Assets"
    $t.FontSize = $tam
    $t.Foreground = Pincel $color
    $t.VerticalAlignment = "Center"
    $t.HorizontalAlignment = "Center"
    return $t
}

function Agregar-Run($tb, $texto, $color) {
    $sep = if ($tb.Inlines.Count) { "    " } else { "" }
    $r = New-Object System.Windows.Documents.Run "$sep$texto"
    $r.Foreground = Pincel $color
    $r.FontWeight = [System.Windows.FontWeights]::SemiBold
    [void]$tb.Inlines.Add($r)
}

# Tarjeta como las de la bienvenida de Windows: icono, titulo, descripcion y casilla a la derecha.
# Devuelve @{ Borde; Check; Estado } (Estado = la linea de descripcion, se usa para el progreso).
function Nueva-Tarjeta($titulo, $desc, $web, $glifo, $conCasilla, $instalado, $nota) {
    $borde = New-Object System.Windows.Controls.Border
    $borde.Background = [Windows.Media.Brushes]::White
    $borde.BorderBrush = Pincel "#E5E5E5"
    $borde.BorderThickness = New-Object System.Windows.Thickness 1
    $borde.CornerRadius = New-Object System.Windows.CornerRadius 6
    $borde.Padding = New-Object System.Windows.Thickness 18, 14, 18, 14
    $borde.Margin = New-Object System.Windows.Thickness 0, 0, 0, 10
    $dock = New-Object System.Windows.Controls.DockPanel

    $caja = New-Object System.Windows.Controls.Border
    $caja.Width = 40; $caja.Height = 40
    $caja.Margin = New-Object System.Windows.Thickness 0, 0, 16, 0
    if ($web) { $caja.Child = Nuevo-Icono $web 34 }
    elseif ($glifo) { $caja.Child = Nuevo-Glifo $glifo 24 "#0067C0" }
    [System.Windows.Controls.DockPanel]::SetDock($caja, "Left")
    [void]$dock.Children.Add($caja)

    $cb = $null
    if ($conCasilla) {
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.VerticalAlignment = "Center"
        $cb.Margin = New-Object System.Windows.Thickness 16, 0, 0, 0
        $cb.LayoutTransform = New-Object System.Windows.Media.ScaleTransform 1.4, 1.4
        [System.Windows.Controls.DockPanel]::SetDock($cb, "Right")
        [void]$dock.Children.Add($cb)
        # Clic en cualquier parte de la tarjeta marca o desmarca
        $borde.Cursor = [System.Windows.Input.Cursors]::Hand
        $borde.Tag = $cb
        $borde.Add_MouseLeftButtonUp({ if ($this.Tag.IsEnabled) { $this.Tag.IsChecked = -not $this.Tag.IsChecked } })
    }

    $textos = New-Object System.Windows.Controls.StackPanel
    $textos.VerticalAlignment = "Center"
    $t1 = New-Object System.Windows.Controls.TextBlock
    $t1.Text = $titulo
    $t1.FontSize = 15
    $t1.FontWeight = [System.Windows.FontWeights]::SemiBold
    $t1.TextWrapping = "Wrap"
    $t2 = New-Object System.Windows.Controls.TextBlock
    $t2.FontSize = 13
    $t2.Foreground = Pincel "#5F5F5F"
    $t2.TextWrapping = "Wrap"
    $t2.Margin = New-Object System.Windows.Thickness 0, 3, 0, 0
    if ($desc) { [void]$t2.Inlines.Add((New-Object System.Windows.Documents.Run "$desc")) }
    if ($instalado) { Agregar-Run $t2 "$($script:ok) Ya instalado" "#16A34A" }
    elseif ($nota)  { Agregar-Run $t2 $nota "#0067C0" }
    [void]$textos.Children.Add($t1)
    [void]$textos.Children.Add($t2)
    [void]$dock.Children.Add($textos)
    $borde.Child = $dock
    return @{ Borde = $borde; Check = $cb; Estado = $t2 }
}

function Nuevo-Encabezado($panel, $texto) {
    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = $texto
    $t.FontSize = 14
    $t.FontWeight = [System.Windows.FontWeights]::SemiBold
    $t.Foreground = Pincel "#5F5F5F"
    $t.Margin = New-Object System.Windows.Thickness 2, 14, 0, 8
    [void]$panel.Children.Add($t)
}

function Agregar-Tarjeta($panel, $titulo, $desc, $web, $glifo) {
    $t = Nueva-Tarjeta $titulo $desc $web $glifo $false $false $null
    [void]$panel.Children.Add($t.Borde)
    return $t
}

function Llenar-Panel($panel, $items) {
    $panel.Children.Clear()
    foreach ($it in $items) {
        $nota = $null
        if ($it.Conectado) { $nota = "Conectado - recomendado" }
        elseif ($it.Aplicar -and $it.Recomendado) { $nota = "Recomendado para tu PC" }
        $desc  = if ($it.Aplicar) { $it.Desc } else { $script:info[$it.Nombre] }
        $glifo = if ($it.Aplicar) { 0xE713 } else { 0xE74C }
        $t = Nueva-Tarjeta $it.Nombre $desc $it.Web $glifo $true $it.Instalado $nota
        $t.Check.IsChecked = [bool]$it.Recomendado
        $it.Check = $t.Check
        [void]$panel.Children.Add($t.Borde)
        if ($it.Sub) { [void]$panel.Children.Add((Nuevo-Submenu $it $t.Check)) }
    }
}

# Juegos de Riot y region, debajo de su tarjeta. Solo se ve si la tarjeta esta marcada.
function Nuevo-Submenu($it, $cb) {
    $caja = New-Object System.Windows.Controls.StackPanel
    $caja.Margin = New-Object System.Windows.Thickness 56, 0, 0, 10
    foreach ($sub in $it.Sub) {
        $t = Nueva-Tarjeta $sub.Nombre $script:info[$sub.Nombre] $sub.Web $null $true $sub.Instalado $null
        $t.Check.IsChecked = $false
        $sub.Check = $t.Check
        [void]$caja.Children.Add($t.Borde)
    }
    $fila = New-Object System.Windows.Controls.DockPanel
    $fila.Margin = New-Object System.Windows.Thickness 4, 2, 0, 0
    $txt = New-Object System.Windows.Controls.TextBlock
    $txt.Text = "Region de tu cuenta:"
    $txt.VerticalAlignment = "Center"
    $txt.Margin = New-Object System.Windows.Thickness 0, 0, 10, 0
    $combo = New-Object System.Windows.Controls.ComboBox
    $combo.Width = 260
    $combo.HorizontalAlignment = "Left"
    foreach ($r in $script:regiones) { [void]$combo.Items.Add($r.Nombre) }
    $combo.SelectedIndex = Get-RegionRiot
    $combo.ToolTip = "Despues se puede cambiar desde Riot Client."
    [void]$fila.Children.Add($txt); [void]$fila.Children.Add($combo)
    [void]$caja.Children.Add($fila)
    $it.Region = $combo

    $caja.Visibility = if ($cb.IsChecked) { "Visible" } else { "Collapsed" }
    $cb.Tag = $caja
    $cb.Add_Checked({ $this.Tag.Visibility = "Visible" })
    $cb.Add_Unchecked({ $this.Tag.Visibility = "Collapsed" })
    return $caja
}

function Marcar($items, $soloRecomendados) {
    foreach ($it in $items) {
        $it.Check.IsChecked = $soloRecomendados -and [bool]$it.Recomendado
        if ($it.Sub -and -not $soloRecomendados) { foreach ($sub in $it.Sub) { $sub.Check.IsChecked = $false } }
    }
}

# Pagina "Esta es tu PC": hardware, perifericos y recomendaciones, en tarjetas
function Mostrar-InfoPC {
    $pc = $script:pc
    $p = $script:ui.PnlInfo
    $p.Children.Clear()

    $tipo = if ($pc.EsLaptop) { "Laptop" } else { "PC de escritorio" }
    $ram = "$($pc.RamGB) GB"
    if ($pc.RamTipo) { $ram += " $($pc.RamTipo)" }
    if ($pc.RamMhz)  { $ram += " a $($pc.RamMhz) MHz" }
    $cpuWeb = if ($pc.CPU -match "AMD|Ryzen") { "amd.com" } elseif ($pc.CPU -match "Intel") { "intel.com" } else { $null }
    $gpuWeb = if ($pc.Driver) { $pc.Driver.Web } else { $null }
    $wg = if ($pc.Winget) { "Instalado ($($pc.Winget))" } else { "No encontrado" }

    Nuevo-Encabezado $p "Tu PC"
    [void](Agregar-Tarjeta $p "$($pc.Windows) $($pc.Version)" "Sistema - build $($pc.Build) - $tipo" "microsoft.com" $null)
    [void](Agregar-Tarjeta $p $pc.CPU "Procesador" $cpuWeb 0xE770)
    [void](Agregar-Tarjeta $p ($pc.GPUs -join ', ') "Tarjeta de video" $gpuWeb 0xE770)
    [void](Agregar-Tarjeta $p $ram "Memoria RAM" $null 0xE770)
    [void](Agregar-Tarjeta $p $pc.Disco "Disco de Windows (C:)" $null 0xE770)
    [void](Agregar-Tarjeta $p $wg "winget, el instalador de programas de Windows" $null 0xE896)

    Nuevo-Encabezado $p "Perifericos conectados"
    $conectados = @($script:perifericos | Where-Object { $_.Conectado })
    foreach ($per in $conectados) {
        $det = if ($per.Dispositivos.Count) { $per.Dispositivos -join ', ' } else { "$($per.Cantidad) dispositivo(s)" }
        [void](Agregar-Tarjeta $p $per.Marca $det $per.Web $null)
    }
    if (-not $conectados.Count) {
        [void](Agregar-Tarjeta $p "Ninguno con programa propio" "Si tienes uno, conectalo y presiona 'Volver a analizar'." $null 0xE946)
    }

    # Recomendaciones: titulo y explicacion
    $r = @()
    if (-not $pc.Winget) {
        if ($script:sinInternet) { $r += ,@("Sin internet y falta winget", "Conectate a internet y vuelve a analizar: winget se instala solo.") }
        else { $r += ,@("No se pudo instalar winget", "Abre la Microsoft Store, actualiza 'Instalador de aplicacion' (App Installer) y vuelve a analizar.") }
    } elseif ($script:sinInternet) {
        $r += ,@("Sin conexion a internet", "Conectate y vuelve a analizar antes de instalar.")
    }
    if ($pc.Build -lt 19041) {
        $r += ,@("Actualiza Windows", "Tu Windows es anterior a Windows 10 2004. HAGS no esta disponible.")
    } elseif ($pc.Build -lt 22000) {
        $r += ,@("Tienes Windows 10", "Todo funciona, pero Windows 11 tiene mejor soporte para juegos (DirectStorage, Auto HDR).")
    }
    if ($pc.Driver) {
        if ($pc.DriverInstalado) { $r += ,@("Driver de video instalado", "$($pc.Driver.Nombre) ya esta instalado. Actualizalo desde su propia app.") }
        else { $r += ,@("Falta el driver de video", "$($pc.Driver.Nombre) viene marcado en el paso Driver.") }
    } else {
        $r += ,@("Grafica no reconocida", "Instala su driver a mano desde la pagina del fabricante.")
    }
    foreach ($per in $conectados) {
        if (-not $per.Instalado) { $r += ,@("Instala $($per.Nombre)", "Tienes $($per.Marca) conectado: viene marcado en el paso Perifericos.") }
    }
    if ($pc.EsLaptop) {
        $r += ,@("Laptop: juega con el cargador", "El plan Alto rendimiento y desactivar la hibernacion no se recomiendan por la bateria.")
    }
    if (($pc.RamTipo -eq "DDR5" -and $pc.RamMhz -gt 0 -and $pc.RamMhz -le 4800) -or
        ($pc.RamTipo -eq "DDR4" -and $pc.RamMhz -gt 0 -and $pc.RamMhz -le 2667)) {
        $perfil = if ($pc.RamTipo -eq "DDR5") { "EXPO/XMP" } else { "XMP (DOCP en placas ASUS)" }
        $r += ,@("Activa $perfil en la BIOS", "Tu RAM corre a $($pc.RamMhz) MHz, la velocidad basica de $($pc.RamTipo). Si tu memoria es mas rapida (mira la etiqueta, ej. 3200 o 3600), activalo para que corra a su velocidad real. Algunas placas economicas no lo permiten.")
    }
    if ($pc.GPUs -match "AMD|Radeon") {
        $r += ,@("Activa Smart Access Memory en la BIOS", "Above 4G Decoding + Re-Size BAR. Puedes verificarlo en AMD Software > Rendimiento.")
    } elseif ($pc.GPUs -match "NVIDIA|GeForce|RTX|GTX") {
        $r += ,@("Activa Resizable BAR en la BIOS", "Above 4G Decoding + Re-Size BAR.")
    }
    if ($pc.Disco -eq "HDD") {
        $r += ,@("Windows esta en un disco HDD", "Si tienes un SSD, instala ahi Windows y tus juegos: cargan mucho mas rapido.")
    }
    if ($pc.RamGB -gt 0 -and $pc.RamGB -lt 16) {
        $r += ,@("Poca RAM para juegos actuales", "Tienes $($pc.RamGB) GB; se recomiendan 16 GB o mas. En Optimizar viene marcado 'Efectos visuales - Mejor rendimiento'.")
    }
    Nuevo-Encabezado $p "Recomendaciones"
    foreach ($rec in $r) { [void](Agregar-Tarjeta $p $rec[0] $rec[1] $null 0xE946) }

    # Texto de la pagina de perifericos
    $script:ui.TxtPerif.Text = if ($conectados.Count) {
        "Detectamos conectado: $(($conectados | ForEach-Object { $_.Marca }) -join ', '). Su programa viene marcado. Si tienes otra marca de la lista, marcala tu."
    } else {
        "No detectamos perifericos con programa propio. Si tienes alguno de estas marcas, marcalo tu, o conectalo y vuelve a analizar desde 'Esta es tu PC'."
    }
}

function Llenar-Driver {
    $pc = $script:pc; $ui = $script:ui
    $p = $ui.PnlDriver
    $p.Children.Clear()
    $ui.ChkDriver = $null
    $gpus = $pc.GPUs -join ', '
    if (-not $pc.Driver) {
        $ui.TxtDriver.Text = "No reconocimos la marca de tu tarjeta de video. Instala su driver a mano desde la pagina del fabricante."
        [void](Agregar-Tarjeta $p $gpus "Marca no reconocida" $null 0xE770)
        return
    }
    $como = if ($pc.Driver.Id) { "Se instala automaticamente." }
            else { "Como AMD y NVIDIA no estan en winget, se abre su pagina oficial para que lo descargues e instales; el instalador te guia." }
    $ui.TxtDriver.Text = "Va primero: los juegos y algunos ajustes de Windows dependen de el. Tu tarjeta es $gpus. $como"
    $nota = if ($pc.DriverInstalado) { $null } else { "Recomendado" }
    $t = Nueva-Tarjeta $pc.Driver.Nombre "Driver de $gpus" $pc.Driver.Web $null $true $pc.DriverInstalado $nota
    $t.Check.IsChecked = -not $pc.DriverInstalado
    $ui.ChkDriver = $t.Check
    [void]$p.Children.Add($t.Borde)
}

function Test-Winget { [bool](Get-Command winget -ErrorAction SilentlyContinue) }
function Test-Internet {
    try {
        Invoke-WebRequest "https://github.com" -Method Head -UseBasicParsing -TimeoutSec 10 | Out-Null
        return $true
    } catch {
        return [bool]$_.Exception.Response   # respondio con error HTTP: igual hay internet
    }
}
# Descarga un archivo sin congelar la ventana
function Descargar($url, $destino) {
    $wc = New-Object System.Net.WebClient
    $tarea = $wc.DownloadFileTaskAsync($url, $destino)
    while (-not $tarea.IsCompleted) { Pump; Start-Sleep -Milliseconds 200 }
    if ($tarea.IsFaulted) { throw $tarea.Exception.InnerException }
}
# Instala winget (App Installer) si falta. Devuelve $true si quedo listo.
function Instalar-Winget {
    # 1. En una PC recien formateada suele venir pero sin activar: registrarlo es instantaneo
    Log "Activando winget (App Installer)..."
    try { Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop } catch { }
    if (Test-Winget) { Log "  OK"; return $true }

    # 2. Descargarlo de la pagina oficial de Microsoft en GitHub, con sus dependencias
    $base = "https://github.com/microsoft/winget-cli/releases/latest/download"
    $dir  = Join-Path $env:TEMP "pcgamer-winget"
    $arq  = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    try {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Log "Descargando winget desde Microsoft (unos 60 MB, puede tardar un par de minutos)..."
        Descargar "$base/DesktopAppInstaller_Dependencies.zip" "$dir\deps.zip"
        Descargar "$base/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "$dir\winget.msixbundle"
        Expand-Archive -Path "$dir\deps.zip" -DestinationPath "$dir\deps" -Force
        foreach ($dep in (Get-ChildItem "$dir\deps\$arq" -Filter *.appx)) {
            Log "  Instalando $($dep.Name)..."
            try { Add-AppxPackage -Path $dep.FullName -ErrorAction Stop }
            catch { Log "    (ya estaba o hay una version mas nueva, se sigue)" }
            Pump
        }
        Log "  Instalando winget..."
        Add-AppxPackage -Path "$dir\winget.msixbundle" -ErrorAction Stop
    } catch {
        Log "  No se pudo instalar winget: $($_.Exception.Message)"
    } finally {
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
    # La carpeta de winget puede no estar todavia en el PATH de esta ventana
    $apps = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps"
    if ($env:Path -notlike "*$apps*") { $env:Path += ";$apps" }
    if (Test-Winget) { Log "  winget instalado."; return $true }
    return $false
}

# Analiza la PC y llena todas las paginas. $irA = pagina a mostrar al terminar (-1 = quedarse).
function Escanear($irA = 1) {
    Bloquear $true
    $script:ui.BtnComenzar.Content = "Analizando..."
    $script:sinInternet = -not (Test-Internet)
    if ($script:sinInternet) { Log "AVISO: no hay conexion a internet. Se puede ver el analisis, pero no instalar." }
    if (-not (Test-Winget)) {
        if ($script:sinInternet) { Log "Falta winget y sin internet no se puede instalar." }
        elseif (-not (Instalar-Winget)) { Log "No se pudo instalar winget: mira las recomendaciones." }
    }
    Log "Analizando tu PC (Windows, hardware, perifericos y apps instaladas)..."
    $script:pc = Get-InfoPC
    Mostrar-InfoPC
    Llenar-Driver
    Llenar-Panel $script:ui.PnlLaunchers   $script:launchers
    Llenar-Panel $script:ui.PnlUtilidades  $script:utilidades
    Llenar-Panel $script:ui.PnlExtras      $script:extras
    Llenar-Panel $script:ui.PnlPerifericos $script:perifericos
    Llenar-Panel $script:ui.PnlAjustes     $script:ajustes
    $script:escaneado = $true
    $script:ui.BtnComenzar.Content = "Continuar"
    Log "Analisis listo."
    Bloquear $false
    if ($irA -ge 0) { Ir $irA }
}

$script:limiteMinutos = 20   # si un programa tarda mas, se cancela y se sigue con el siguiente

function Formato-Tiempo($ts) { "{0}:{1:00}" -f [int][Math]::Floor($ts.TotalMinutes), $ts.Seconds }
# Explicacion corta de los codigos de error de winget mas comunes
function Texto-Error($codigo) {
    switch ($codigo) {
        -1978335159 { "fallo el instalador (MSI)" }
        -1978335212 { "winget no encontro el paquete" }
        -1978334975 { "la app esta abierta: cierrala y reintenta" }
        -1978334974 { "habia otra instalacion en curso" }
        -1978334973 { "un archivo esta en uso" }
        -1978334972 { "falta una dependencia" }
        -1978334971 { "no hay espacio en el disco" }
        -1978334969 { "sin conexion a internet" }
        default     { "codigo $codigo" }
    }
}
# Corre un winget install sin congelar la ventana, mostrando el tiempo.
# Devuelve el codigo de salida, o "saltado" / "tiempo".
function Ejecutar-Winget($app, $id, $fuente) {
    $wargs = @("install", "--id", $id, "-e", "--silent",
               "--accept-package-agreements", "--accept-source-agreements")
    if ($fuente) { $wargs += @("--source", $fuente) }
    try {
        $p = Start-Process winget -ArgumentList $wargs -WindowStyle Hidden -PassThru -ErrorAction Stop
    } catch {
        # Si Windows no deja abrir el proceso aparte, se instala aqui (la ventana se congela un rato)
        & winget @wargs | Out-Null
        return $LASTEXITCODE
    }
    $null = $p.Handle   # necesario para leer ExitCode en PowerShell 5.1
    $ultimo = -1
    while (-not $p.HasExited) {
        Pump
        Start-Sleep -Milliseconds 250
        $t = (Get-Date) - $script:inicioItem
        if ([int]$t.TotalSeconds -ne $ultimo) {
            $ultimo = [int]$t.TotalSeconds
            $reloj = Formato-Tiempo $t
            Set-Estado $app "Instalando... $reloj" "#2563EB"
            $pr = $script:progreso
            $script:ui.TxtProgreso.Text = "Instalando $($pr.Hechos + 1) de $($pr.Total): $($app.Nombre)  ($reloj)"
        }
        if ($script:saltar -or $t.TotalMinutes -ge $script:limiteMinutos) {
            # Corta winget y el instalador que haya abierto
            & taskkill /PID $p.Id /T /F 2>&1 | Out-Null
            if ($script:saltar) { return "saltado" } else { return "tiempo" }
        }
    }
    $p.WaitForExit()
    return $p.ExitCode
}
# Instala una app. Devuelve ok, yaEstaba, fallo, saltado o tiempo.
# Si falla: reintenta una vez si habia otra instalacion en curso, y prueba la version de la Store si la tiene.
function Instalar-App($app) {
    Log "Instalando $($app.Nombre)..."
    $script:inicioItem = Get-Date
    $script:saltar = $false
    $intentos = @(@{ Id = $app.Id; Fuente = $app.Fuente })
    if ($app.Alternativa) { $intentos += @{ Id = $app.Alternativa; Fuente = "msstore"; Store = $true } }

    foreach ($in in $intentos) {
        if ($in.Store) { Log "  Probando desde la Microsoft Store..." }
        $codigo = Ejecutar-Winget $app $in.Id $in.Fuente
        if ($codigo -eq -1978334974) {
            Log "  Habia otra instalacion en curso. Esperando 30 segundos y reintentando..."
            $fin = (Get-Date).AddSeconds(30)
            while ((Get-Date) -lt $fin -and -not $script:saltar) { Pump; Start-Sleep -Milliseconds 250 }
            if (-not $script:saltar) { $codigo = Ejecutar-Winget $app $in.Id $in.Fuente }
        }
        $app.Duracion = Formato-Tiempo ((Get-Date) - $script:inicioItem)
        switch ($codigo) {
            0            { Log "  OK ($($app.Duracion))"; return "ok" }
            -1978334967  { Log "  OK, pide reiniciar ($($app.Duracion))"; return "ok" }
            -1978335189  { Log "  Ya estaba"; return "yaEstaba" }
            -1978335135  { Log "  Ya estaba"; return "yaEstaba" }
            "saltado"    { Log "  Saltado por el usuario ($($app.Duracion))"; return "saltado" }
            "tiempo"     { Log "  Cancelado: tardo mas de $($script:limiteMinutos) minutos"; return "tiempo" }
        }
        $app.Error = Texto-Error $codigo
        Log "  FALLO: $($app.Error)"
    }
    return "fallo"
}
function Confirmar($texto) {
    $r = [System.Windows.MessageBox]::Show($texto, "PC Gamer", "YesNo", "Question")
    return $r -eq "Yes"
}
function Abrir-PaginaDriver {
    $d = $script:pc.Driver
    Log "Abriendo la pagina oficial de $($d.Nombre)..."
    try { Start-Process $d.Url } catch { Log "  No se pudo abrir, entra a mano: $($d.Url)" }
}

# ---------- PROGRESO ----------

$script:ok   = [string][char]0x2714
$script:mal  = [string][char]0x2716

# Lo marcado en todos los pasos
function Seleccion {
    @{
        Driver = [bool]($script:pc.Driver -and $script:ui.ChkDriver -and $script:ui.ChkDriver.IsChecked)
        Apps   = @(Apps-Marcadas)
        Ajs    = @(Ajustes-Marcados)
    }
}

# Pagina de resumen antes de instalar
function Llenar-Resumen {
    $p = $script:ui.PnlResumen
    $p.Children.Clear()
    $s = Seleccion
    Nuevo-Encabezado $p "1. Driver de video"
    if ($s.Driver) { [void](Agregar-Tarjeta $p $script:pc.Driver.Nombre "Se instala, o se abre su pagina oficial" $script:pc.Driver.Web $null) }
    else { [void](Agregar-Tarjeta $p "Nada" "No se instala ningun driver" $null 0xE73E) }
    Nuevo-Encabezado $p "2. Programas ($($s.Apps.Count))"
    foreach ($a in $s.Apps) { [void](Agregar-Tarjeta $p $a.Nombre $script:info[$a.Nombre] $a.Web 0xE74C) }
    if (-not $s.Apps.Count) { [void](Agregar-Tarjeta $p "Nada" "No marcaste programas" $null 0xE73E) }
    Nuevo-Encabezado $p "3. Optimizar ($($s.Ajs.Count))"
    foreach ($a in $s.Ajs) { [void](Agregar-Tarjeta $p $a.Nombre $a.Desc $null 0xE713) }
    if (-not $s.Ajs.Count) { [void](Agregar-Tarjeta $p "Nada" "No marcaste ajustes" $null 0xE73E) }

    $hayAlgo = $s.Driver -or $s.Apps.Count -or $s.Ajs.Count
    $faltaWinget = $s.Apps.Count -and -not $script:pc.Winget
    $script:ui.BtnInstalar.IsEnabled = $hayAlgo -and -not $faltaWinget -and -not $script:ocupado
    $script:ui.TxtResumenDesc.Text = if (-not $hayAlgo) {
        "No marcaste nada. Vuelve con la flecha y elige que instalar u optimizar."
    } elseif ($faltaWinget) {
        "Falta winget, asi que no se pueden instalar programas. Mira las recomendaciones en 'Esta es tu PC'."
    } else {
        "Esto es lo que se va a hacer, en este orden. Puedes dejar la PC sola mientras se instala. Si quieres cambiar algo, vuelve con la flecha."
    }
}

# Prepara la pagina de progreso con una tarjeta por tarea y la muestra
function Iniciar-Progreso($items, $titulo) {
    $ui = $script:ui
    $ui.PnlProgreso.Children.Clear()
    foreach ($it in $items) {
        $glifo = if ($it.Aplicar) { 0xE713 } else { 0xE74C }
        $t = Agregar-Tarjeta $ui.PnlProgreso $it.Nombre "En espera" $it.Web $glifo
        $t.Estado.Foreground = [Windows.Media.Brushes]::Gray
        $it.Fila = $t.Estado
        $it.Duracion = $null; $it.Error = $null
    }
    $ui.BarProgreso.Maximum = [Math]::Max(1, $items.Count)
    $ui.BarProgreso.Value = 0
    $ui.TxtProgreso.Text = $titulo
    $ui.TxtResumen.Text = ""
    $ui.BtnSaltar.Visibility = "Visible"
    $ui.BtnSaltar.IsEnabled = $true
    $script:progreso = @{ Total = $items.Count; Hechos = 0; ok = @(); yaEstaba = @(); aplicado = @(); fallo = @(); manual = @(); saltado = @(); Inicio = Get-Date }
    Ir 9
    Pump
}

function Set-Estado($it, $texto, $color) {
    if ($it.Fila) { $it.Fila.Text = $texto; $it.Fila.Foreground = Pincel $color }
    Pump
}
function Empezar-Item($it, $verbo) {
    $p = $script:progreso
    $script:ui.TxtProgreso.Text = "$verbo $($p.Hechos + 1) de $($p.Total): $($it.Nombre)"
    Set-Estado $it "$verbo..." "#2563EB"
}
# resultado: ok, yaEstaba, aplicado, revertido, manual, saltado, tiempo o fallo
function Terminar-Item($it, $resultado) {
    $p = $script:progreso
    switch ($resultado) {
        "ok"        { Set-Estado $it "$($script:ok) Instalado ($($it.Duracion))" "#16A34A"; $p.ok += $it.Nombre }
        "yaEstaba"  { Set-Estado $it "$($script:ok) Ya estaba instalado"  "#16A34A"; $p.yaEstaba += $it.Nombre }
        "aplicado"  { Set-Estado $it "$($script:ok) Aplicado"             "#16A34A"; $p.aplicado += $it.Nombre }
        "revertido" { Set-Estado $it "$($script:ok) Revertido"            "#16A34A"; $p.aplicado += $it.Nombre }
        "manual"    { Set-Estado $it "Instalar a mano (se abrio su pagina)" "#D97706"; $p.manual += $it.Nombre }
        "saltado"   { Set-Estado $it "Saltado ($($it.Duracion))"         "#D97706"; $p.saltado += $it.Nombre }
        "tiempo"    { Set-Estado $it "$($script:mal) Tardo demasiado ($($script:limiteMinutos) min)" "#DC2626"; $p.fallo += $it.Nombre }
        default     {
            $motivo = if ($it.Error) { ": $($it.Error)" } else { "" }
            Set-Estado $it "$($script:mal) Fallo$motivo" "#DC2626"; $p.fallo += $it.Nombre
        }
    }
    $p.Hechos++
    $script:ui.BarProgreso.Value = $p.Hechos
    Pump
}

function Terminar-Progreso {
    $p = $script:progreso
    $ui = $script:ui
    $ui.BarProgreso.Value = $ui.BarProgreso.Maximum
    $ui.BtnSaltar.Visibility = "Collapsed"
    $total = Formato-Tiempo ((Get-Date) - $p.Inicio)
    $ui.TxtProgreso.Text = "Terminado en $total."
    $ui.TxtFinalTitulo.Text = if ($p.fallo.Count) { "Casi listo" } else { "Todo listo" }
    $r = @("Terminado en $total.")
    if ($p.ok.Count)       { $r += "Instalados ($($p.ok.Count)): $($p.ok -join ', ')." }
    if ($p.yaEstaba.Count) { $r += "Ya estaban ($($p.yaEstaba.Count)): $($p.yaEstaba -join ', ')." }
    if ($p.aplicado.Count) { $r += "Ajustes aplicados ($($p.aplicado.Count))." }
    if ($p.manual.Count)   { $r += "Instalar a mano: $($p.manual -join ', ') (se abrio su pagina)." }
    if ($p.saltado.Count)  { $r += "Saltados: $($p.saltado -join ', ')." }
    if ($p.fallo.Count)    { $r += "Fallaron: $($p.fallo -join ', '). Vuelve a intentarlo desde el inicio o instalalos a mano." }
    $r += "Pendiente: inicia sesion en cada launcher y descarga tus juegos."
    $ui.TxtResumen.Text = $r -join "`n"
    foreach ($linea in $r) { Log $linea }
}

# Fase 1. Devuelve $true si el driver quedo para instalar a mano desde la pagina.
function Fase-Driver {
    $d = $script:pc.Driver
    Log "===== FASE 1: DRIVER DE VIDEO ====="
    Empezar-Item $d "Instalando"
    if ($d.Id) {
        $r = Instalar-App $d
        if ($r -ne "fallo") { Terminar-Item $d $r; return $false }
        Log "  No se pudo con winget."
    }
    Abrir-PaginaDriver
    Terminar-Item $d "manual"
    return $true
}
function Fase-Programas($sel) {
    Log "===== FASE 2: PROGRAMAS ====="
    foreach ($app in $sel) {
        Empezar-Item $app "Instalando"
        Terminar-Item $app (Instalar-App $app)
    }
}
function Fase-Optimizar($sel) {
    Log "===== FASE 3: OPTIMIZAR ====="
    foreach ($aj in $sel) {
        Empezar-Item $aj "Aplicando"
        Log "Aplicando: $($aj.Nombre)..."
        try { & $aj.Aplicar; Log "  OK"; Terminar-Item $aj "aplicado" }
        catch { Log "  ERROR: $($_.Exception.Message)"; Terminar-Item $aj "fallo" }
    }
}
# Apps marcadas para instalar. Riot se reemplaza por sus juegos marcados, con el ID de la region elegida.
function Apps-Marcadas {
    $sel = @()
    foreach ($it in (Todas-Apps)) {
        if (-not $it.Check.IsChecked) { continue }
        if ($it.Sub) {
            $reg = $script:regiones[[Math]::Max(0, $it.Region.SelectedIndex)]
            foreach ($sub in $it.Sub) {
                if ($sub.Check.IsChecked) { $sub.Id = "$($sub.Base).$($reg[$sub.Clave])"; $sel += $sub }
            }
        } else {
            $sel += $it
        }
    }
    return $sel
}
function Ajustes-Marcados { @($script:ajustes | Where-Object { $_.Check.IsChecked }) }
function Lista($items) { ($items | ForEach-Object { "  - $($_.Nombre)" }) -join "`n" }
function Aviso($texto) { [System.Windows.MessageBox]::Show($texto, "PC Gamer") | Out-Null }

function Conectar-Eventos {
    $ui = $script:ui

    $ui.BtnComenzar.Add_Click({ if ($script:escaneado) { Ir 1 } else { Escanear 1 } })
    $ui.BtnEscanear.Add_Click({ Escanear 1 })
    $ui.BtnHome.Add_Click({ Ir 0 })
    $ui.BtnAtras.Add_Click({ Ir ($script:pag - 1) })
    $ui.BtnSiguiente.Add_Click({ Ir ($script:pag + 1) })
    $ui.BtnVolver.Add_Click({ Ir 0 })
    $ui.BtnDriverPagina.Add_Click({ if ($script:pc.Driver) { Abrir-PaginaDriver } })
    $ui.BtnAjRec.Add_Click({ Marcar $script:ajustes $true })
    $ui.BtnAjNada.Add_Click({ Marcar $script:ajustes $false })

    $ui.BtnSaltar.Add_Click({
        $script:saltar = $true
        $script:ui.BtnSaltar.IsEnabled = $false
        Log "  Saltando..."
    })
    $ui.BtnDetalles.Add_Click({
        $log = $script:ui.Log
        if ($log.Visibility -eq "Visible") { $log.Visibility = "Collapsed"; $script:ui.BtnDetalles.Content = "Ver detalles" }
        else { $log.Visibility = "Visible"; $script:ui.BtnDetalles.Content = "Ocultar detalles" }
    })

    $ui.BtnInstalar.Add_Click({
        $s = Seleccion
        if (-not $s.Driver -and -not $s.Apps.Count -and -not $s.Ajs.Count) { Aviso "No marcaste nada para instalar u optimizar."; return }
        Bloquear $true
        $tareas = @()
        if ($s.Driver) { $tareas += $script:pc.Driver }
        Iniciar-Progreso ($tareas + $s.Apps + $s.Ajs) "Empezando..."
        if ($s.Driver) {
            if (Fase-Driver) {
                Aviso "Se abrio la pagina oficial de $($script:pc.Driver.Nombre).`n`nDescarga e instala el driver (si pide reiniciar, elige 'mas tarde').`nCuando termine, presiona Aceptar para seguir con los programas."
            }
        }
        if ($s.Apps.Count) { Fase-Programas $s.Apps }
        if ($s.Ajs.Count)  { Fase-Optimizar $s.Ajs }
        Terminar-Progreso
        $reiniciar = $s.Driver -or $s.Ajs.Count -gt 0
        $script:ui.BtnReiniciar.Visibility = if ($reiniciar) { "Visible" } else { "Collapsed" }
        Bloquear $false
        Ir 10
        # Se vuelve a analizar para que los pasos muestren lo recien instalado
        Escanear -1
    })

    $ui.BtnReiniciar.Add_Click({
        if (Confirmar "Para terminar hay que reiniciar la PC.`n`nGuarda lo que tengas abierto. Reiniciar ahora?") {
            Log "Reiniciando..."
            Restart-Computer -Force
        }
    })

    $ui.BtnRevertir.Add_Click({
        $sel = @($script:ajustes | Where-Object { $_.Check.IsChecked -and $_.Revertir })
        if (-not $sel.Count) { Aviso "No marcaste ningun ajuste que se pueda revertir."; return }
        if (-not (Confirmar "Se van a revertir (volver a como viene Windows) $($sel.Count) ajustes:`n`n$(Lista $sel)`n`nContinuar?")) { return }
        Bloquear $true
        foreach ($aj in $sel) {
            Log "Revirtiendo: $($aj.Nombre)..."
            try { & $aj.Revertir; Log "  OK" } catch { Log "  ERROR: $($_.Exception.Message)" }
        }
        Bloquear $false
        Aviso "Listo. Reinicia la PC para que todo vuelva a como viene Windows."
    })

    $ui.BtnWinUtil.Add_Click({
        if (-not (Confirmar "Se abrira WinUtil de Chris Titus en otra ventana.`n`nSi usas sus Tweaks, elige el preset Standard. NUNCA Advanced: quita OneDrive, la busqueda de la Store y mas.`n`nAbrir WinUtil?")) { return }
        $archivo = Join-Path $env:TEMP "pcgamer-winutil.ps1"
        Set-Content -Path $archivo -Value 'irm "https://christitus.com/win" | iex' -Encoding ASCII
        try {
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$archivo`"" -ErrorAction Stop
            Log "WinUtil se esta abriendo en otra ventana."
        } catch {
            Log "No se pudo abrir WinUtil: $($_.Exception.Message)"
            Aviso "No se pudo abrir WinUtil. Abrelo a mano: PowerShell como administrador y pega  irm https://christitus.com/win | iex"
        }
    })
}

# ---------- PROGRAMA ----------

function Main {
    if (-not (Test-Admin)) {
        Write-Host "Se necesitan permisos de administrador. Abriendo una ventana nueva..." -ForegroundColor Yellow
        if (Abrir-ComoAdmin) {
            Write-Host "Listo: en unos segundos se abre la ventana del instalador. Esta ya se puede cerrar." -ForegroundColor Green
        } else {
            Write-Host "No se dieron los permisos de administrador. No se hizo ningun cambio." -ForegroundColor Red
        }
        return
    }

    Write-Host "Abriendo el instalador... (no cierres esta ventana)" -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
    try {
        Abrir-Ventana
    } catch {
        [System.Windows.MessageBox]::Show("El instalador encontro un error y se cerro:`n`n$($_.Exception.Message)`n`nVuelve a intentarlo. Si se repite, manda una captura de este mensaje.", "PC Gamer", "OK", "Error") | Out-Null
    }
}

function Abrir-Ventana {
    [xml]$x = $script:xaml
    $script:window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $x))
    # Todos los controles con nombre del XAML quedan en $script:ui
    $script:ui = @{}
    foreach ($m in [regex]::Matches($script:xaml, 'x:Name="(\w+)"')) {
        $n = $m.Groups[1].Value
        $script:ui[$n] = $script:window.FindName($n)
    }
    $script:ui.ChkDriver = $null
    $script:ui.TxtHola.Text = "Hola, $env:USERNAME"

    Conectar-Eventos
    # Cualquier error inesperado va al registro en vez de cerrar la ventana
    $script:window.Dispatcher.Add_UnhandledException({
        param($sender, $e)
        try { Log "ERROR inesperado: $($e.Exception.Message)"; Bloquear $false } catch { }
        $e.Handled = $true
    })
    Ir 0
    [void]$script:window.ShowDialog()
}

Main
