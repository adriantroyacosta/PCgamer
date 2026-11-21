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
    @{ Nombre = "Steam";            Id = "Valve.Steam";                 Detectar = '^Steam$' },
    @{ Nombre = "EA app";           Id = "ElectronicArts.EADesktop";    Detectar = '^EA app$' },
    @{ Nombre = "Epic Games";       Id = "EpicGames.EpicGamesLauncher"; Detectar = 'Epic Games Launcher' },
    @{ Nombre = "GOG Galaxy";       Id = "GOG.Galaxy";                  Detectar = 'GOG GALAXY' },
    @{ Nombre = "Ubisoft Connect";  Id = "Ubisoft.Connect";             Detectar = 'Ubisoft Connect' },
    @{ Nombre = "Battle.net";       Id = "Blizzard.BattleNet";          Detectar = '^Battle\.net$' },
    @{ Nombre = "Xbox";             Id = "9MV0B5HZVK9Z"; Fuente = "msstore"; Detectar = '^Microsoft\.GamingApp$' },
    @{ Nombre = "Playnite";         Id = "Playnite.Playnite";           Detectar = '^Playnite' }
)

$script:utilidades = @(
    @{ Nombre = "Google Chrome";    Id = "Google.Chrome";               Detectar = '^Google Chrome$' },
    @{ Nombre = "WinRAR";           Id = "RARLab.WinRAR";               Detectar = '^WinRAR' },
    @{ Nombre = "Transmission";     Id = "Transmission.Transmission";   Detectar = '^Transmission' },
    @{ Nombre = "VirtualBox";       Id = "Oracle.VirtualBox";           Detectar = 'VirtualBox' },
    @{ Nombre = "iTunes";           Id = "9PB2MZ1ZMB1S"; Fuente = "msstore"; Detectar = '^iTunes$|^AppleInc\.iTunes$' },
    @{ Nombre = "PC Manager";       Id = "9PM860492SZD"; Fuente = "msstore"; Detectar = '^PC Manager$|^Microsoft\.MicrosoftPCManager$' },
    @{ Nombre = "Terminal Windows"; Id = "Microsoft.WindowsTerminal";   Detectar = '^Microsoft\.WindowsTerminal$' },
    @{ Nombre = "FanControl";       Id = "Rem0o.FanControl";            Detectar = '^Fan ?Control' },
    @{ Nombre = "Dolby Access";     Id = "9N0866FS04W8"; Fuente = "msstore"; Detectar = '^Dolby Access$|^DolbyLaboratories\.DolbyAccess$' }
)

# Vid = ID de fabricante USB, para detectar si hay un periferico de esa marca conectado
$script:perifericos = @(
    @{ Nombre = "Corsair iCUE 5";   Id = "Corsair.iCUE.5";          Marca = "Corsair";     Vid = "1B1C"; Detectar = '^iCUE|^Corsair iCUE ?5? ?Software' },
    @{ Nombre = "Logitech G HUB";   Id = "Logitech.GHUB";           Marca = "Logitech";    Vid = "046D"; Detectar = 'Logitech G HUB' },
    @{ Nombre = "Razer Synapse";    Id = "RazerInc.RazerInstaller"; Marca = "Razer";       Vid = "1532"; Detectar = 'Razer Synapse' },
    @{ Nombre = "SteelSeries GG";   Id = "SteelSeries.GG";          Marca = "SteelSeries"; Vid = "1038"; Detectar = 'SteelSeries GG' }
)

# Drivers de GPU (se instalan a mano desde su web)
$script:drivers = @{
    AMD    = @{ Nombre = "AMD Software (Adrenalin)"; Url = "https://www.amd.com/es/support/download/drivers.html"; Detectar = '^AMD Software|^AMD Radeon Software' }
    NVIDIA = @{ Nombre = "NVIDIA App";               Url = "https://www.nvidia.com/es-la/software/nvidia-app/";    Detectar = '^NVIDIA app|^NVIDIA Graphics Driver' }
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
        Start-Process powershell -Verb RunAs -ArgumentList $argumentos -ErrorAction Stop
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
    foreach ($app in ($script:launchers + $script:utilidades + $script:perifericos)) {
        $app.Instalado = ($ids -contains $app.Id) -or (@($nombres -match $app.Detectar).Count -gt 0)
    }

    # Driver de GPU
    $pc.Driver = $null
    if ($pc.GPUs -match "AMD|Radeon")                { $pc.Driver = $script:drivers.AMD }
    elseif ($pc.GPUs -match "NVIDIA|GeForce|RTX|GTX") { $pc.Driver = $script:drivers.NVIDIA }
    $pc.DriverInstalado = $false
    if ($pc.Driver) { $pc.DriverInstalado = @($nombres -match $pc.Driver.Detectar).Count -gt 0 }

    # Perifericos conectados
    $dispositivos = @(Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
        Where-Object { $_.InstanceId -match '^(USB|HID)\\VID_' })
    foreach ($p in $script:perifericos) {
        $suyos = @($dispositivos | Where-Object { $_.InstanceId -match "VID_$($p.Vid)" })
        $p.Conectado = $suyos.Count -gt 0
        $p.Dispositivos = @($suyos | Where-Object { $_.FriendlyName } |
            Select-Object -ExpandProperty FriendlyName -Unique | Select-Object -First 3)
    }

    # Recomendaciones de apps
    foreach ($app in ($script:launchers + $script:utilidades)) { $app.Recomendado = -not $app.Instalado }
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

    <TabControl Margin="8" Padding="4">
      <TabItem Header="  Mi PC  ">
        <ScrollViewer VerticalScrollBarVisibility="Auto">
          <StackPanel Margin="6">
            <Border Background="#FEF3C7" BorderBrush="#F59E0B" BorderThickness="1" CornerRadius="4" Padding="10" Margin="6">
              <TextBlock TextWrapping="Wrap">
                <Bold>Antes de empezar:</Bold> conecta todos tus perifericos (teclado, mouse, headset, control)
                y presiona <Bold>Volver a escanear</Bold>, asi se detectan y se recomienda su programa.
                Despues revisa las pestanas <Bold>Instalar</Bold> y <Bold>Optimizar</Bold>: lo recomendado ya viene marcado,
                pero puedes marcar o desmarcar lo que quieras. Nada se instala ni cambia hasta que presiones un boton.
              </TextBlock>
            </Border>
            <WrapPanel Margin="2">
              <Button x:Name="BtnEscanear" Content="Volver a escanear"/>
              <Button x:Name="BtnDriver" Content="Abrir pagina del driver" Style="{StaticResource Secundario}"/>
            </WrapPanel>
            <GroupBox Header="Tu PC">
              <TextBlock x:Name="TxtInfo" FontFamily="Consolas" TextWrapping="Wrap" Text="Escaneando..."/>
            </GroupBox>
            <GroupBox Header="Recomendaciones para tu PC">
              <TextBlock x:Name="TxtRecom" TextWrapping="Wrap" LineHeight="22"/>
            </GroupBox>
          </StackPanel>
        </ScrollViewer>
      </TabItem>

      <TabItem Header="  Instalar  ">
        <DockPanel Margin="4">
          <WrapPanel DockPanel.Dock="Top">
            <TextBlock Text="Selecciones:" VerticalAlignment="Center" Margin="4,0,8,0"/>
            <Button x:Name="BtnAppsRec" Content="Marcar recomendados" Style="{StaticResource Secundario}"/>
            <Button x:Name="BtnAppsNada" Content="Desmarcar todo" Style="{StaticResource Secundario}"/>
          </WrapPanel>
          <DockPanel DockPanel.Dock="Bottom" LastChildFill="False">
            <TextBlock DockPanel.Dock="Left" VerticalAlignment="Center" Margin="6,0" Foreground="#4B5563"
                       Text="(ya instalado) = ya esta en tu PC.  (recomendado) = falta o se detecto conectado."/>
            <Button x:Name="BtnInstalar" DockPanel.Dock="Right" Content="Instalar seleccionados"/>
          </DockPanel>
          <ScrollViewer VerticalScrollBarVisibility="Auto">
            <WrapPanel>
              <GroupBox Header="Launchers de juegos" Width="300"><StackPanel x:Name="PnlLaunchers"/></GroupBox>
              <GroupBox Header="Utilidades" Width="300"><StackPanel x:Name="PnlUtilidades"/></GroupBox>
              <GroupBox Header="Perifericos" Width="300"><StackPanel x:Name="PnlPerifericos"/></GroupBox>
            </WrapPanel>
          </ScrollViewer>
        </DockPanel>
      </TabItem>

      <TabItem Header="  Optimizar  ">
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
    foreach ($b in "BtnEscanear", "BtnDriver", "BtnAppsRec", "BtnAppsNada", "BtnInstalar",
                   "BtnAjRec", "BtnAjNada", "BtnAplicar", "BtnRevertir", "BtnWinUtil") {
        $script:ui[$b].IsEnabled = -not $si
    }
    if (-not $si -and -not $script:pc.Winget) { $script:ui.BtnInstalar.IsEnabled = $false }
    if (-not $si -and -not $script:pc.Driver) { $script:ui.BtnDriver.IsEnabled = $false }
    Pump
}

function Llenar-Panel($panel, $items) {
    $panel.Children.Clear()
    foreach ($it in $items) {
        $cb = New-Object System.Windows.Controls.CheckBox
        $texto = $it.Nombre
        if ($it.Instalado)       { $texto += "   (ya instalado)" }
        elseif ($it.Conectado)   { $texto += "   (conectado - recomendado)" }
        elseif ($it.Recomendado -and $it.Aplicar) { $texto += "   (recomendado)" }
        $cb.Content = $texto
        $cb.IsChecked = [bool]$it.Recomendado
        if ($it.Desc) { $cb.ToolTip = $it.Desc }
        if ($it.Instalado) { $cb.Foreground = [Windows.Media.Brushes]::Gray }
        $it.Check = $cb
        [void]$panel.Children.Add($cb)
    }
}

function Marcar($items, $soloRecomendados) {
    foreach ($it in $items) { $it.Check.IsChecked = $soloRecomendados -and [bool]$it.Recomendado }
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
        if ($p.Conectado) { $perif += "$($p.Marca) ($($p.Dispositivos -join ', '))" }
    }
    if (-not $perif.Count) { $perif = @("ninguno de Corsair, Logitech, Razer o SteelSeries") }

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
        $r += "- winget no esta instalado: actualiza 'App Installer' desde la Microsoft Store y vuelve a abrir el instalador. Sin winget no se puede instalar nada."
    }
    if ($pc.Build -lt 19041) {
        $r += "- Tu Windows es anterior a Windows 10 2004: conviene actualizarlo. HAGS no esta disponible."
    } elseif ($pc.Build -lt 22000) {
        $r += "- Tienes Windows 10: todo funciona, pero Windows 11 tiene mejor soporte para juegos (DirectStorage, Auto HDR)."
    }
    if ($pc.Driver) {
        if ($pc.DriverInstalado) { $r += "- Driver de la grafica: $($pc.Driver.Nombre) ya esta instalado. Actualizalo desde su propia app." }
        else { $r += "- Driver de la grafica: falta $($pc.Driver.Nombre). Usa el boton 'Abrir pagina del driver'." }
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
        ($pc.RamTipo -eq "DDR4" -and $pc.RamMhz -gt 0 -and $pc.RamMhz -le 2666)) {
        $r += "- BIOS: tu RAM corre a $($pc.RamMhz) MHz, la velocidad basica de $($pc.RamTipo). Probablemente EXPO/XMP esta apagado: activalo en la BIOS para que corra a su velocidad real."
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

function Escanear {
    Bloquear $true
    $script:ui.TxtInfo.Text = "Escaneando..."
    Log "Escaneando la PC (Windows, hardware, perifericos y apps instaladas). Puede tardar unos segundos..."
    $script:pc = Get-InfoPC
    Mostrar-InfoPC
    Llenar-Panel $script:ui.PnlLaunchers   $script:launchers
    Llenar-Panel $script:ui.PnlUtilidades  $script:utilidades
    Llenar-Panel $script:ui.PnlPerifericos $script:perifericos
    Llenar-Panel $script:ui.PnlAjustes     $script:ajustes
    Log "Listo. Revisa las pestanas Instalar y Optimizar."
    Bloquear $false
}

# Instala una app con winget sin congelar la ventana. Devuelve ok, yaEstaba o fallo.
function Instalar-App($app) {
    Log "Instalando $($app.Nombre)..."
    $wargs = @("install", "--id", $app.Id, "-e", "--silent",
               "--accept-package-agreements", "--accept-source-agreements")
    if ($app.Fuente) { $wargs += @("--source", $app.Fuente) }
    $codigo = $null
    try {
        $p = Start-Process winget -ArgumentList $wargs -WindowStyle Hidden -PassThru -ErrorAction Stop
        $null = $p.Handle   # necesario para leer ExitCode en PowerShell 5.1
        while (-not $p.HasExited) { Pump; Start-Sleep -Milliseconds 200 }
        $p.WaitForExit()
        $codigo = $p.ExitCode
    } catch {
        # Si Windows no deja abrir el proceso aparte, se instala aqui (la ventana se congela un rato)
        & winget @wargs | Out-Null
        $codigo = $LASTEXITCODE
    }
    switch ($codigo) {
        0           { Log "  OK";            return "ok" }
        -1978335189 { Log "  Ya estaba";     return "yaEstaba" }   # ya instalado / sin cambios
        -1978335135 { Log "  Ya estaba";     return "yaEstaba" }   # ya instalado
        default     { Log "  FALLO (codigo $codigo)"; return "fallo" }
    }
}

function Confirmar($texto) {
    $r = [System.Windows.MessageBox]::Show($texto, "PC Gamer", "YesNo", "Question")
    return $r -eq "Yes"
}

function Conectar-Eventos {
    $ui = $script:ui

    $ui.BtnEscanear.Add_Click({ Escanear })

    $ui.BtnDriver.Add_Click({
        if ($script:pc.Driver) {
            Log "Abriendo la pagina de $($script:pc.Driver.Nombre)..."
            try { Start-Process $script:pc.Driver.Url } catch { Log "  No se pudo abrir: $($script:pc.Driver.Url)" }
        }
    })

    $ui.BtnAppsRec.Add_Click({ Marcar ($script:launchers + $script:utilidades + $script:perifericos) $true })
    $ui.BtnAppsNada.Add_Click({ Marcar ($script:launchers + $script:utilidades + $script:perifericos) $false })
    $ui.BtnAjRec.Add_Click({ Marcar $script:ajustes $true })
    $ui.BtnAjNada.Add_Click({ Marcar $script:ajustes $false })

    $ui.BtnInstalar.Add_Click({
        $sel = @(($script:launchers + $script:utilidades + $script:perifericos) | Where-Object { $_.Check.IsChecked })
        if (-not $sel.Count) { [System.Windows.MessageBox]::Show("No marcaste ninguna app.", "PC Gamer") | Out-Null; return }
        $lista = ($sel | ForEach-Object { "  - $($_.Nombre)" }) -join "`n"
        if (-not (Confirmar "Se van a instalar $($sel.Count) apps:`n`n$lista`n`nPuedes dejar la PC sola mientras instala. Continuar?")) { return }

        Bloquear $true
        $res = @{ ok = @(); yaEstaba = @(); fallo = @() }
        foreach ($app in $sel) { $res[(Instalar-App $app)] += $app.Nombre }
        Log "----- RESULTADO -----"
        Log "Instaladas ($($res.ok.Count)): $($res.ok -join ', ')"
        if ($res.yaEstaba.Count) { Log "Ya estaban ($($res.yaEstaba.Count)): $($res.yaEstaba -join ', ')" }
        if ($res.fallo.Count)    { Log "Fallaron ($($res.fallo.Count)): $($res.fallo -join ', ') -> vuelve a intentar o instalalas a mano." }
        Log "Pendiente a mano: juegos desde cada launcher, Black Myth Wukong, perfiles de iCUE y FanControl."
        Bloquear $false
        Escanear
    })

    $ui.BtnAplicar.Add_Click({
        $sel = @($script:ajustes | Where-Object { $_.Check.IsChecked })
        if (-not $sel.Count) { [System.Windows.MessageBox]::Show("No marcaste ningun ajuste.", "PC Gamer") | Out-Null; return }
        $lista = ($sel | ForEach-Object { "  - $($_.Nombre)" }) -join "`n"
        if (-not (Confirmar "Se van a aplicar $($sel.Count) ajustes:`n`n$lista`n`nContinuar?")) { return }

        Bloquear $true
        foreach ($aj in $sel) {
            Log "Aplicando: $($aj.Nombre)..."
            try { & $aj.Aplicar; Log "  OK" } catch { Log "  ERROR: $($_.Exception.Message)" }
        }
        Log "Ajustes aplicados. REINICIA la PC para que todos tengan efecto."
        Bloquear $false
    })

    $ui.BtnRevertir.Add_Click({
        $sel = @($script:ajustes | Where-Object { $_.Check.IsChecked -and $_.Revertir })
        if (-not $sel.Count) { [System.Windows.MessageBox]::Show("No marcaste ningun ajuste que se pueda revertir.", "PC Gamer") | Out-Null; return }
        $lista = ($sel | ForEach-Object { "  - $($_.Nombre)" }) -join "`n"
        if (-not (Confirmar "Se van a revertir (volver a como viene Windows) $($sel.Count) ajustes:`n`n$lista`n`nContinuar?")) { return }

        Bloquear $true
        foreach ($aj in $sel) {
            Log "Revirtiendo: $($aj.Nombre)..."
            try { & $aj.Revertir; Log "  OK" } catch { Log "  ERROR: $($_.Exception.Message)" }
        }
        Log "Listo. REINICIA la PC para que todo vuelva a la normalidad."
        Bloquear $false
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
            Write-Host "Continua en la ventana nueva. Esta ya se puede cerrar."
        } else {
            Write-Host "No se dieron los permisos de administrador. No se hizo ningun cambio." -ForegroundColor Red
        }
        return
    }

    Write-Host "Abriendo el instalador... (no cierres esta ventana)" -ForegroundColor Cyan
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

    [xml]$x = $script:xaml
    $script:window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $x))
    $script:ui = @{}
    foreach ($n in "Log", "TxtInfo", "TxtRecom", "PnlLaunchers", "PnlUtilidades", "PnlPerifericos", "PnlAjustes",
                   "BtnEscanear", "BtnDriver", "BtnAppsRec", "BtnAppsNada", "BtnInstalar",
                   "BtnAjRec", "BtnAjNada", "BtnAplicar", "BtnRevertir", "BtnWinUtil") {
        $script:ui[$n] = $script:window.FindName($n)
    }
    $script:pc = @{}

    Conectar-Eventos
    $script:window.Add_ContentRendered({ Escanear })
    [void]$script:window.ShowDialog()
}

Main
