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

$script:xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PC Gamer - Instalador" Width="1000" Height="720" MinWidth="760" MinHeight="520"
        WindowStartupLocation="CenterScreen" Background="#F3F4F6" FontFamily="Segoe UI" FontSize="13">
  <Window.Resources>
    <Style TargetType="Button">
      <Setter Property="Padding" Value="14,6"/>
      <Setter Property="Margin" Value="4"/>
      <Setter Property="Background" Value="#2563EB"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
    </Style>
    <Style x:Key="Secundario" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
      <Setter Property="Background" Value="#E5E7EB"/>
      <Setter Property="Foreground" Value="#111827"/>
    </Style>
    <Style TargetType="CheckBox">
      <Setter Property="Margin" Value="2,4"/>
    </Style>
    <Style TargetType="GroupBox">
      <Setter Property="Margin" Value="6"/>
      <Setter Property="Padding" Value="8"/>
      <Setter Property="Background" Value="White"/>
      <Setter Property="BorderBrush" Value="#D1D5DB"/>
    </Style>
  </Window.Resources>

  <DockPanel>
    <TextBox x:Name="Log" DockPanel.Dock="Bottom" Height="130" IsReadOnly="True" TextWrapping="Wrap"
             VerticalScrollBarVisibility="Auto" Background="#111827" Foreground="#D1FAE5"
             FontFamily="Consolas" FontSize="12" BorderThickness="0" Padding="8"/>

    <TabControl x:Name="Tabs" Margin="8" Padding="4">
      <TabItem Header="  Mi PC  ">
        <ScrollViewer VerticalScrollBarVisibility="Auto">
          <StackPanel Margin="6">
            <Border Background="#FEF3C7" BorderBrush="#F59E0B" BorderThickness="1" CornerRadius="4" Padding="10" Margin="6">
              <TextBlock TextWrapping="Wrap">
                <Bold>Bienvenido.</Bold> Antes de empezar, conecta todos tus perifericos (teclado, mouse, headset, control)
                para que se detecten y se recomiende su programa. Luego presiona <Bold>Comenzar analisis</Bold>: revisa tu PC
                sin instalar ni cambiar nada (si falta winget, el instalador lo instala solo).
                Despues el orden es <Bold>1. Driver</Bold>, <Bold>2. Programas</Bold> y <Bold>3. Optimizar</Bold>, con un solo reinicio al final.
                Lo recomendado ya viene marcado en cada pestana, pero puedes marcar o desmarcar lo que quieras.
                Usa <Bold>Hacer todo lo recomendado</Bold> para correr las 3 fases seguidas, o ve pestana por pestana.
                Nada se instala ni cambia hasta que confirmes.
              </TextBlock>
            </Border>
            <WrapPanel Margin="2">
              <Button x:Name="BtnComenzar" Content="Comenzar analisis" FontWeight="Bold" FontSize="16" Padding="28,12"/>
              <Button x:Name="BtnTodo" Content="Hacer todo lo recomendado (1 &gt; 2 &gt; 3)" FontWeight="Bold" Padding="18,8" Visibility="Collapsed"/>
              <Button x:Name="BtnEscanear" Content="Volver a escanear" Style="{StaticResource Secundario}" Visibility="Collapsed"/>
            </WrapPanel>
            <GroupBox x:Name="GrpInfo" Header="Tu PC" Visibility="Collapsed">
              <TextBlock x:Name="TxtInfo" FontFamily="Consolas" TextWrapping="Wrap" Text="Escaneando..."/>
            </GroupBox>
            <GroupBox x:Name="GrpRecom" Header="Recomendaciones para tu PC" Visibility="Collapsed">
              <TextBlock x:Name="TxtRecom" TextWrapping="Wrap" LineHeight="22"/>
            </GroupBox>
          </StackPanel>
        </ScrollViewer>
      </TabItem>

      <TabItem x:Name="TabDriver" Header="  1. Driver  " IsEnabled="False">
        <DockPanel Margin="4">
          <DockPanel DockPanel.Dock="Bottom" LastChildFill="False">
            <Button x:Name="BtnDriverPagina" DockPanel.Dock="Left" Content="Abrir pagina oficial" Style="{StaticResource Secundario}"/>
            <Button x:Name="BtnDriverInstalar" DockPanel.Dock="Right" Content="Instalar driver"/>
          </DockPanel>
          <StackPanel>
            <TextBlock Margin="8,4" Foreground="#4B5563" TextWrapping="Wrap"
                       Text="Va primero: los juegos y algunos ajustes de Optimizar (como HAGS) dependen del driver de la tarjeta de video."/>
            <GroupBox Header="Tarjeta de video">
              <StackPanel>
                <TextBlock x:Name="TxtDriver" TextWrapping="Wrap" LineHeight="22"/>
                <CheckBox x:Name="ChkDriver" Margin="2,10,2,2" FontWeight="Bold"/>
              </StackPanel>
            </GroupBox>
          </StackPanel>
        </DockPanel>
      </TabItem>

      <TabItem x:Name="TabProgramas" Header="  2. Programas  " IsEnabled="False">
        <DockPanel Margin="4">
          <WrapPanel DockPanel.Dock="Top">
            <TextBlock Text="Selecciones:" VerticalAlignment="Center" Margin="4,0,8,0"/>
            <Button x:Name="BtnAppsRec" Content="Marcar recomendados" Style="{StaticResource Secundario}"/>
            <Button x:Name="BtnAppsNada" Content="Desmarcar todo" Style="{StaticResource Secundario}"/>
          </WrapPanel>
          <DockPanel DockPanel.Dock="Bottom" LastChildFill="False">
            <TextBlock DockPanel.Dock="Left" VerticalAlignment="Center" Margin="6,0" Foreground="#4B5563"
                       Text="&#x2714; verde = ya esta instalado en tu PC.   Marcado = recomendado (falta o se detecto conectado)."/>
            <Button x:Name="BtnInstalar" DockPanel.Dock="Right" Content="Instalar seleccionados"/>
          </DockPanel>
          <ScrollViewer VerticalScrollBarVisibility="Auto">
            <WrapPanel>
              <GroupBox Header="Launchers de juegos" Width="300"><StackPanel x:Name="PnlLaunchers"/></GroupBox>
              <GroupBox Header="Utilidades" Width="300"><StackPanel x:Name="PnlUtilidades"/></GroupBox>
              <GroupBox Header="Extras para gamers (opcional)" Width="300"><StackPanel x:Name="PnlExtras"/></GroupBox>
              <GroupBox Header="Perifericos" Width="300"><StackPanel x:Name="PnlPerifericos"/></GroupBox>
            </WrapPanel>
          </ScrollViewer>
        </DockPanel>
      </TabItem>

      <TabItem x:Name="TabOptimizar" Header="  3. Optimizar  " IsEnabled="False">
        <DockPanel Margin="4">
          <WrapPanel DockPanel.Dock="Top">
            <TextBlock Text="Selecciones:" VerticalAlignment="Center" Margin="4,0,8,0"/>
            <Button x:Name="BtnAjRec" Content="Marcar recomendados" Style="{StaticResource Secundario}"/>
            <Button x:Name="BtnAjNada" Content="Desmarcar todo" Style="{StaticResource Secundario}"/>
          </WrapPanel>
          <DockPanel DockPanel.Dock="Bottom" LastChildFill="False">
            <Button x:Name="BtnWinUtil" DockPanel.Dock="Left" Content="Abrir WinUtil (opcional)" Style="{StaticResource Secundario}"/>
            <Button x:Name="BtnAplicar" DockPanel.Dock="Right" Content="Aplicar seleccionados"/>
            <Button x:Name="BtnRevertir" DockPanel.Dock="Right" Content="Revertir seleccionados" Style="{StaticResource Secundario}"/>
          </DockPanel>
          <ScrollViewer VerticalScrollBarVisibility="Auto">
            <StackPanel>
              <TextBlock Margin="8,4" Foreground="#4B5563" TextWrapping="Wrap"
                         Text="Pasa el mouse sobre cada ajuste para ver que hace. Lo recomendado depende de tu PC (escritorio o laptop, RAM, version de Windows). Ninguno toca Xbox, la Store ni OneDrive."/>
              <GroupBox Header="Ajustes para juegos y privacidad"><StackPanel x:Name="PnlAjustes"/></GroupBox>
            </StackPanel>
          </ScrollViewer>
        </DockPanel>
      </TabItem>
      <TabItem x:Name="TabProgreso" Header="  Progreso  " IsEnabled="False">
        <DockPanel Margin="8">
          <StackPanel DockPanel.Dock="Top">
            <DockPanel>
              <Button x:Name="BtnSaltar" DockPanel.Dock="Right" Content="Saltar este programa" Visibility="Collapsed"
                      Style="{StaticResource Secundario}" ToolTip="Cancela el programa que se esta instalando y sigue con el siguiente"/>
              <TextBlock x:Name="TxtProgreso" FontSize="18" FontWeight="Bold" VerticalAlignment="Center" TextWrapping="Wrap"
                         Text="Todavia no se ha instalado ni aplicado nada."/>
            </DockPanel>
            <ProgressBar x:Name="BarProgreso" Height="18" Margin="0,10" Minimum="0" Maximum="1" Value="0"/>
            <TextBlock x:Name="TxtResumen" TextWrapping="Wrap" FontSize="14" Margin="0,0,0,8"/>
          </StackPanel>
          <Border Background="White" BorderBrush="#D1D5DB" BorderThickness="1" Padding="6">
            <ScrollViewer VerticalScrollBarVisibility="Auto">
              <StackPanel x:Name="PnlProgreso"/>
            </ScrollViewer>
          </Border>
        </DockPanel>
      </TabItem>
    </TabControl>
  </DockPanel>
</Window>
'@

function Pump {
    $script:window.Dispatcher.Invoke([Action]{}, [Windows.Threading.DispatcherPriority]::Background)
}

function Log($texto) {
    $script:ui.Log.AppendText("$texto`r`n")
    $script:ui.Log.ScrollToEnd()
    Pump
}

function Bloquear($si) {
    foreach ($b in "BtnComenzar", "BtnTodo", "BtnEscanear", "BtnDriverPagina", "BtnDriverInstalar", "BtnAppsRec", "BtnAppsNada",
                   "BtnInstalar", "BtnAjRec", "BtnAjNada", "BtnAplicar", "BtnRevertir", "BtnWinUtil") {
        $script:ui[$b].IsEnabled = -not $si
    }
    if (-not $si -and -not $script:pc.Winget) { $script:ui.BtnInstalar.IsEnabled = $false; $script:ui.BtnTodo.IsEnabled = $false }
    if (-not $si -and -not $script:pc.Driver) { $script:ui.BtnDriverPagina.IsEnabled = $false; $script:ui.BtnDriverInstalar.IsEnabled = $false }
    Pump
}

# Contenido de una casilla: nombre + check verde si ya esta instalado, o una nota gris
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

function Nuevo-Contenido($nombre, $instalado, $nota, $web) {
    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Orientation = "Horizontal"
    if ($web) {
        $ico = Nuevo-Icono $web 18
        $ico.Margin = New-Object System.Windows.Thickness 0, 0, 6, 0
        [void]$sp.Children.Add($ico)
    }
    $t = New-Object System.Windows.Controls.TextBlock
    $t.VerticalAlignment = "Center"
    $t.Text = $nombre
    [void]$sp.Children.Add($t)
    if ($instalado) {
        $ok = New-Object System.Windows.Controls.TextBlock
        $ok.Text = [string][char]0x2714
        $ok.Foreground = Pincel "#16A34A"
        $ok.FontWeight = [System.Windows.FontWeights]::Bold
        $ok.Margin = New-Object System.Windows.Thickness 8, 0, 0, 0
        $ok.ToolTip = "Ya instalado"
        [void]$sp.Children.Add($ok)
    } elseif ($nota) {
        $n = New-Object System.Windows.Controls.TextBlock
        $n.Text = $nota
        $n.Foreground = [Windows.Media.Brushes]::Gray
        $n.Margin = New-Object System.Windows.Thickness 8, 0, 0, 0
        [void]$sp.Children.Add($n)
    }
    return $sp
}

function Llenar-Panel($panel, $items) {
    $panel.Children.Clear()
    foreach ($it in $items) {
        $cb = New-Object System.Windows.Controls.CheckBox
        $nota = $null
        if ($it.Conectado) { $nota = "(conectado - recomendado)" }
        elseif ($it.Recomendado -and $it.Aplicar) { $nota = "(recomendado)" }
        $cb.Content = Nuevo-Contenido $it.Nombre $it.Instalado $nota $it.Web
        $cb.IsChecked = [bool]$it.Recomendado
        if ($it.Desc) { $cb.ToolTip = $it.Desc } elseif ($it.Instalado) { $cb.ToolTip = "Ya instalado" }
        $it.Check = $cb
        [void]$panel.Children.Add($cb)
        if ($it.Sub) { [void]$panel.Children.Add((Nuevo-Submenu $it $cb)) }
    }
}

# Juegos de Riot y region, debajo de su casilla. Solo se ve si la casilla esta marcada.
function Nuevo-Submenu($it, $cb) {
    $caja = New-Object System.Windows.Controls.StackPanel
    $caja.Margin = New-Object System.Windows.Thickness 26, 0, 0, 6
    foreach ($sub in $it.Sub) {
        $scb = New-Object System.Windows.Controls.CheckBox
        $scb.Content = Nuevo-Contenido $sub.Nombre $sub.Instalado $null $sub.Web
        $scb.IsChecked = $false
        if ($sub.Instalado) { $scb.ToolTip = "Ya instalado" }
        $sub.Check = $scb
        [void]$caja.Children.Add($scb)
    }
    $fila = New-Object System.Windows.Controls.StackPanel
    $fila.Orientation = "Horizontal"
    $fila.Margin = New-Object System.Windows.Thickness 0, 4, 0, 0
    $txt = New-Object System.Windows.Controls.TextBlock
    $txt.Text = "Region:"
    $txt.VerticalAlignment = "Center"
    $txt.Margin = New-Object System.Windows.Thickness 0, 0, 6, 0
    $combo = New-Object System.Windows.Controls.ComboBox
    $combo.Width = 200
    foreach ($r in $script:regiones) { [void]$combo.Items.Add($r.Nombre) }
    $combo.SelectedIndex = Get-RegionRiot
    $combo.ToolTip = "La region de tu cuenta. Despues se puede cambiar desde Riot Client."
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

function Mostrar-InfoPC {
    $pc = $script:pc
    $ram = "$($pc.RamGB) GB"
    if ($pc.RamTipo) { $ram += " $($pc.RamTipo)" }
    if ($pc.RamMhz)  { $ram += " a $($pc.RamMhz) MHz" }
    $tipo = if ($pc.EsLaptop) { "Laptop" } else { "PC de escritorio" }
    $wg = if ($pc.Winget) { "instalado ($($pc.Winget))" } else { "NO ENCONTRADO" }

    $perif = @()
    foreach ($p in $script:perifericos) {
        if ($p.Conectado) {
            if ($p.Dispositivos.Count) { $perif += "$($p.Marca) ($($p.Dispositivos -join ', '))" }
            else { $perif += "$($p.Marca) ($($p.Cantidad) dispositivo(s) conectado(s))" }
        }
    }
    if (-not $perif.Count) { $perif = @("ninguno de las marcas con programa propio") }

    $lineas = @(
        ("Windows:      {0} {1} (build {2})" -f $pc.Windows, $pc.Version, $pc.Build),
        "Tipo:         $tipo",
        "Procesador:   $($pc.CPU)",
        "Grafica:      $($pc.GPUs -join ', ')",
        "RAM:          $ram",
        "Disco de C:   $($pc.Disco)",
        "winget:       $wg",
        "Perifericos:  $($perif -join "`n              ")"
    )
    $script:ui.TxtInfo.Text = $lineas -join "`n"

    # Recomendaciones
    $r = @()
    if (-not $pc.Winget) {
        if ($script:sinInternet) {
            $r += "- No hay internet y falta winget: conectate a internet y presiona 'Volver a escanear' (winget se instala solo)."
        } else {
            $r += "- No se pudo instalar winget automaticamente. Abre la Microsoft Store, busca 'Instalador de aplicacion' (App Installer), actualizalo y presiona 'Volver a escanear'."
        }
    } elseif ($script:sinInternet) {
        $r += "- No hay conexion a internet: conectate y presiona 'Volver a escanear' antes de instalar."
    }
    if ($pc.Build -lt 19041) {
        $r += "- Tu Windows es anterior a Windows 10 2004: conviene actualizarlo. HAGS no esta disponible."
    } elseif ($pc.Build -lt 22000) {
        $r += "- Tienes Windows 10: todo funciona, pero Windows 11 tiene mejor soporte para juegos (DirectStorage, Auto HDR)."
    }
    if ($pc.Driver) {
        if ($pc.DriverInstalado) { $r += "- Driver de la grafica: $($pc.Driver.Nombre) ya esta instalado. Actualizalo desde su propia app." }
        else { $r += "- Driver de la grafica: falta $($pc.Driver.Nombre). Esta marcado en la pestana 1. Driver." }
    } else {
        $r += "- No se reconocio la marca de la grafica: instala su driver a mano."
    }
    $conectados = @($script:perifericos | Where-Object { $_.Conectado })
    if ($conectados.Count) {
        foreach ($p in $conectados) {
            if ($p.Instalado) { $r += "- $($p.Marca) conectado: $($p.Nombre) ya esta instalado." }
            else { $r += "- $($p.Marca) conectado: se recomienda $($p.Nombre) (ya viene marcado en Instalar)." }
        }
    } else {
        $r += "- No se detectaron perifericos con programa propio. Si tienes, conectalos y presiona 'Volver a escanear'."
    }
    if ($pc.EsLaptop) {
        $r += "- Laptop: juega con el cargador conectado. El plan Alto rendimiento y desactivar la hibernacion no se recomiendan por la bateria."
    }
    if (($pc.RamTipo -eq "DDR5" -and $pc.RamMhz -gt 0 -and $pc.RamMhz -le 4800) -or
        ($pc.RamTipo -eq "DDR4" -and $pc.RamMhz -gt 0 -and $pc.RamMhz -le 2667)) {
        $perfil = if ($pc.RamTipo -eq "DDR5") { "EXPO/XMP" } else { "XMP (DOCP en placas ASUS)" }
        $r += "- BIOS: tu RAM corre a $($pc.RamMhz) MHz, la velocidad basica de $($pc.RamTipo). Si tu memoria es mas rapida (mira la etiqueta, ej. 3200 o 3600), activa $perfil en la BIOS para que corra a su velocidad real. Algunas placas madre economicas no lo permiten."
    }
    if ($pc.GPUs -match "AMD|Radeon") {
        $r += "- BIOS: activa Smart Access Memory / Resizable BAR (Above 4G Decoding + Re-Size BAR). Puedes verificarlo en AMD Software > Rendimiento."
    } elseif ($pc.GPUs -match "NVIDIA|GeForce|RTX|GTX") {
        $r += "- BIOS: activa Resizable BAR (Above 4G Decoding + Re-Size BAR)."
    }
    if ($pc.Disco -eq "HDD") {
        $r += "- Windows esta en un disco HDD: si tienes un SSD, instala ahi Windows y tus juegos, carga mucho mas rapido."
    }
    if ($pc.RamGB -gt 0 -and $pc.RamGB -lt 16) {
        $r += "- Tienes $($pc.RamGB) GB de RAM: para juegos actuales se recomiendan 16 GB o mas. En Optimizar se marca 'Efectos visuales - Mejor rendimiento'."
    }
    $script:ui.TxtRecom.Text = $r -join "`n"
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

function Escanear {
    Bloquear $true
    $script:ui.TxtInfo.Text = "Escaneando..."
    $script:sinInternet = -not (Test-Internet)
    if ($script:sinInternet) { Log "AVISO: no hay conexion a internet. Se puede ver el analisis, pero no instalar." }
    if (-not (Test-Winget)) {
        if ($script:sinInternet) { Log "Falta winget y sin internet no se puede instalar." }
        elseif (-not (Instalar-Winget)) { Log "No se pudo instalar winget: mira las recomendaciones en Mi PC." }
    }
    Log "Escaneando la PC (Windows, hardware, perifericos y apps instaladas). Puede tardar unos segundos..."
    $script:pc = Get-InfoPC
    Mostrar-InfoPC
    Llenar-Driver
    Llenar-Panel $script:ui.PnlLaunchers   $script:launchers
    Llenar-Panel $script:ui.PnlUtilidades  $script:utilidades
    Llenar-Panel $script:ui.PnlExtras      $script:extras
    Llenar-Panel $script:ui.PnlPerifericos $script:perifericos
    Llenar-Panel $script:ui.PnlAjustes     $script:ajustes
    # Despues del primer analisis se muestra todo
    $ui = $script:ui
    $ui.BtnComenzar.Visibility = "Collapsed"
    foreach ($c in "BtnTodo", "BtnEscanear", "GrpInfo", "GrpRecom") { $ui[$c].Visibility = "Visible" }
    foreach ($t in "TabDriver", "TabProgramas", "TabOptimizar", "TabProgreso") { $ui[$t].IsEnabled = $true }
    Log "Listo. Revisa las pestanas 1. Driver, 2. Programas y 3. Optimizar, o usa 'Hacer todo lo recomendado'."
    Bloquear $false
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

function Llenar-Driver {
    $pc = $script:pc; $ui = $script:ui
    $gpus = $pc.GPUs -join ', '
    if (-not $pc.Driver) {
        $ui.TxtDriver.Text = "Tarjeta de video: $gpus`nNo se reconocio la marca (AMD, NVIDIA o Intel). Instala su driver a mano desde la pagina del fabricante."
        $ui.ChkDriver.Content = "Sin driver para instalar"
        $ui.ChkDriver.IsChecked = $false
        $ui.ChkDriver.IsEnabled = $false
        return
    }
    $estado = if ($pc.DriverInstalado) { "ya instalado. Para actualizarlo usa su propia app." } else { "NO instalado." }
    $como = if ($pc.Driver.Id) { "Se instala automaticamente con winget; si falla, se abre su pagina oficial." }
            else { "Se abre su pagina oficial para descargarlo e instalarlo (el instalador te guia)." }
    $ui.TxtDriver.Text = "Tarjeta de video: $gpus`nDriver recomendado: $($pc.Driver.Nombre)`nEstado: $estado`n$como"
    $nota = if ($pc.DriverInstalado) { $null } else { "(recomendado)" }
    $ui.ChkDriver.Content = Nuevo-Contenido "Instalar $($pc.Driver.Nombre)" $pc.DriverInstalado $nota $pc.Driver.Web
    $ui.ChkDriver.IsChecked = -not $pc.DriverInstalado
    $ui.ChkDriver.IsEnabled = $true
}

function Abrir-PaginaDriver {
    $d = $script:pc.Driver
    Log "Abriendo la pagina oficial de $($d.Nombre)..."
    try { Start-Process $d.Url } catch { Log "  No se pudo abrir, entra a mano: $($d.Url)" }
}

# ---------- PROGRESO ----------

$script:ok   = [string][char]0x2714
$script:mal  = [string][char]0x2716

# Prepara la pestana Progreso con una fila por tarea y la muestra
function Iniciar-Progreso($items, $titulo) {
    $ui = $script:ui
    $ui.PnlProgreso.Children.Clear()
    foreach ($it in $items) {
        $fila = New-Object System.Windows.Controls.DockPanel
        $fila.Margin = New-Object System.Windows.Thickness 4, 4, 4, 4
        $ico = Nuevo-Icono $it.Web 24
        $ico.Margin = New-Object System.Windows.Thickness 0, 0, 10, 0
        [System.Windows.Controls.DockPanel]::SetDock($ico, "Left")
        $est = New-Object System.Windows.Controls.TextBlock
        $est.Text = "En espera"
        $est.Foreground = [Windows.Media.Brushes]::Gray
        $est.Width = 260
        $est.FontSize = 14
        $est.VerticalAlignment = "Center"
        [System.Windows.Controls.DockPanel]::SetDock($est, "Right")
        $nom = New-Object System.Windows.Controls.TextBlock
        $nom.Text = $it.Nombre
        $nom.FontSize = 14
        $nom.VerticalAlignment = "Center"
        [void]$fila.Children.Add($ico); [void]$fila.Children.Add($est); [void]$fila.Children.Add($nom)
        $it.Fila = $est
        [void]$ui.PnlProgreso.Children.Add($fila)
    }
    $ui.BarProgreso.Maximum = [Math]::Max(1, $items.Count)
    $ui.BarProgreso.Value = 0
    $ui.TxtProgreso.Text = $titulo
    $ui.TxtResumen.Text = ""
    $ui.Tabs.SelectedItem = $ui.TabProgreso
    foreach ($it in $items) { $it.Duracion = $null; $it.Error = $null }
    $script:progreso = @{ Total = $items.Count; Hechos = 0; ok = @(); yaEstaba = @(); aplicado = @(); fallo = @(); manual = @(); saltado = @(); Inicio = Get-Date }
    $ui.BtnSaltar.Visibility = "Visible"
    $ui.BtnSaltar.IsEnabled = $true
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

# resultado: ok, yaEstaba, aplicado, revertido, manual o fallo
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
    $ui.TxtProgreso.Text = if ($p.fallo.Count) { "Terminado en $total, con $($p.fallo.Count) error(es)" } else { "$($script:ok) Terminado en $total" }
    $r = @()
    if ($p.ok.Count)       { $r += "Instalados ($($p.ok.Count)): $($p.ok -join ', ')" }
    if ($p.yaEstaba.Count) { $r += "Ya estaban ($($p.yaEstaba.Count)): $($p.yaEstaba -join ', ')" }
    if ($p.aplicado.Count) { $r += "Ajustes ($($p.aplicado.Count)): $($p.aplicado -join ', ')" }
    if ($p.manual.Count)   { $r += "A mano ($($p.manual.Count)): $($p.manual -join ', ')" }
    if ($p.saltado.Count)  { $r += "Saltados ($($p.saltado.Count)): $($p.saltado -join ', ')" }
    if ($p.fallo.Count)    { $r += "Fallaron ($($p.fallo.Count)): $($p.fallo -join ', ') -> vuelve a intentar o instalalos a mano." }
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

function Ofrecer-Reinicio {
    if (Confirmar "Para terminar hay que REINICIAR la PC.`n`nGuarda lo que tengas abierto. Reiniciar ahora?") {
        Log "Reiniciando..."
        Restart-Computer -Force
    } else {
        Log "Recuerda reiniciar la PC para que todo tenga efecto."
    }
}

function Conectar-Eventos {
    $ui = $script:ui

    $ui.BtnEscanear.Add_Click({ Escanear })
    $ui.BtnDriverPagina.Add_Click({ if ($script:pc.Driver) { Abrir-PaginaDriver } })

    $ui.BtnAppsRec.Add_Click({ Marcar (Todas-Apps) $true })
    $ui.BtnAppsNada.Add_Click({ Marcar (Todas-Apps) $false })
    $ui.BtnAjRec.Add_Click({ Marcar $script:ajustes $true })
    $ui.BtnAjNada.Add_Click({ Marcar $script:ajustes $false })

    $ui.BtnTodo.Add_Click({
        $driver = $script:pc.Driver -and $script:ui.ChkDriver.IsChecked
        $apps = @(Apps-Marcadas)
        $ajs = @(Ajustes-Marcados)
        if (-not $driver -and -not $apps.Count -and -not $ajs.Count) { Aviso "No hay nada marcado en las pestanas 1, 2 y 3."; return }
        $t = "Se va a hacer, en este orden:`n`n"
        $t += "1. DRIVER: " + $(if ($driver) { $script:pc.Driver.Nombre } else { "nada" }) + "`n`n"
        $t += "2. PROGRAMAS ($($apps.Count)):" + $(if ($apps.Count) { "`n" + (Lista $apps) } else { " nada" }) + "`n`n"
        $t += "3. OPTIMIZAR ($($ajs.Count)):" + $(if ($ajs.Count) { "`n" + (Lista $ajs) } else { " nada" }) + "`n`n"
        $t += "Puedes dejar la PC sola mientras instala. Continuar?"
        if (-not (Confirmar $t)) { return }

        Bloquear $true
        $tareas = @()
        if ($driver) { $tareas += $script:pc.Driver }
        Iniciar-Progreso ($tareas + $apps + $ajs) "Empezando..."
        if ($driver) {
            if (Fase-Driver) {
                Aviso "Se abrio la pagina oficial de $($script:pc.Driver.Nombre).`n`nDescarga e instala el driver (si pide reiniciar, elige 'mas tarde').`nCuando termine, presiona Aceptar para seguir con los programas."
            }
        }
        if ($apps.Count) { Fase-Programas $apps }
        if ($ajs.Count)  { Fase-Optimizar $ajs }
        Terminar-Progreso
        Log "Pendiente a mano: juegos desde cada launcher, Black Myth Wukong, perfiles de iCUE y FanControl."
        Bloquear $false
        Escanear
        if ($driver -or $ajs.Count) { Ofrecer-Reinicio }
    })

    $ui.BtnDriverInstalar.Add_Click({
        if (-not $script:ui.ChkDriver.IsChecked) { Aviso "Marca la casilla del driver para instalarlo."; return }
        if (-not (Confirmar "Instalar $($script:pc.Driver.Nombre)?")) { return }
        Bloquear $true
        Iniciar-Progreso @($script:pc.Driver) "Empezando..."
        if (Fase-Driver) { Log "Descarga e instala el driver desde la pagina que se abrio, y luego sigue con 2. Programas." }
        Terminar-Progreso
        Bloquear $false
        Escanear
    })

    $ui.BtnInstalar.Add_Click({
        $sel = @(Apps-Marcadas)
        if (-not $sel.Count) { Aviso "No marcaste ninguna app (si marcaste Riot Games, elige tambien un juego)."; return }
        if (-not (Confirmar "Se van a instalar $($sel.Count) apps:`n`n$(Lista $sel)`n`nPuedes dejar la PC sola mientras instala. Continuar?")) { return }
        Bloquear $true
        Iniciar-Progreso $sel "Empezando..."
        Fase-Programas $sel
        Terminar-Progreso
        Log "Pendiente a mano: juegos desde cada launcher, Black Myth Wukong, perfiles de iCUE y FanControl."
        Bloquear $false
        Escanear
    })

    $ui.BtnAplicar.Add_Click({
        $sel = @(Ajustes-Marcados)
        if (-not $sel.Count) { Aviso "No marcaste ningun ajuste."; return }
        if (-not (Confirmar "Se van a aplicar $($sel.Count) ajustes:`n`n$(Lista $sel)`n`nContinuar?")) { return }
        Bloquear $true
        Iniciar-Progreso $sel "Empezando..."
        Fase-Optimizar $sel
        Terminar-Progreso
        Bloquear $false
        Ofrecer-Reinicio
    })

    $ui.BtnRevertir.Add_Click({
        $sel = @($script:ajustes | Where-Object { $_.Check.IsChecked -and $_.Revertir })
        if (-not $sel.Count) { Aviso "No marcaste ningun ajuste que se pueda revertir."; return }
        if (-not (Confirmar "Se van a revertir (volver a como viene Windows) $($sel.Count) ajustes:`n`n$(Lista $sel)`n`nContinuar?")) { return }
        Bloquear $true
        Iniciar-Progreso $sel "Empezando..."
        foreach ($aj in $sel) {
            Empezar-Item $aj "Revirtiendo"
            Log "Revirtiendo: $($aj.Nombre)..."
            try { & $aj.Revertir; Log "  OK"; Terminar-Item $aj "revertido" }
            catch { Log "  ERROR: $($_.Exception.Message)"; Terminar-Item $aj "fallo" }
        }
        Terminar-Progreso
        Bloquear $false
        Ofrecer-Reinicio
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
            Log "Abrelo a mano: PowerShell como administrador y pega  irm https://christitus.com/win | iex"
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
    $script:ui = @{}
    foreach ($n in "BtnSaltar", "Tabs", "TabProgreso", "TabDriver", "TabProgramas", "TabOptimizar", "GrpInfo", "GrpRecom", "BtnComenzar", "TxtProgreso", "BarProgreso", "TxtResumen", "PnlProgreso", "Log", "TxtInfo", "TxtRecom", "TxtDriver", "ChkDriver", "PnlLaunchers", "PnlUtilidades", "PnlExtras", "PnlPerifericos", "PnlAjustes",
                   "BtnTodo", "BtnEscanear", "BtnDriverPagina", "BtnDriverInstalar", "BtnAppsRec", "BtnAppsNada", "BtnInstalar",
                   "BtnAjRec", "BtnAjNada", "BtnAplicar", "BtnRevertir", "BtnWinUtil") {
        $script:ui[$n] = $script:window.FindName($n)
    }
    $script:pc = @{}

    Conectar-Eventos
    $script:ui.BtnComenzar.Add_Click({ Escanear })
    $script:ui.BtnSaltar.Add_Click({
        $script:saltar = $true
        $script:ui.BtnSaltar.IsEnabled = $false
        Log "  Saltando..."
    })
    # Cualquier error inesperado va al registro en vez de cerrar la ventana
    $script:window.Dispatcher.Add_UnhandledException({
        param($sender, $e)
        try { Log "ERROR inesperado: $($e.Exception.Message)"; Bloquear $false } catch { }
        $e.Handled = $true
    })
    [void]$script:window.ShowDialog()
}

Main
