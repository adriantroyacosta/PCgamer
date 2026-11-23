# Contexto para Claude Code

## Que es este proyecto
Instalador post-formateo para la PC gamer personal de Adrian (Windows 11). Despues de formatear,
un solo script (lanzado con `irm ... | iex`, estilo WinUtil) abre una ventana WPF que analiza la PC, recomienda
apps y ajustes segun hardware y perifericos, y deja marcar que instalar con winget y que optimizar. No cambia nada sin confirmar.
Proyecto personal: no tiene relacion con trabajo.

## Archivos
- `instalar.ps1`: script principal (PowerShell 5.1, ventana WPF con XAML embebido). Partes: listas de apps
  (`$launchers`, `$utilidades`, `$perifericos`, `$drivers`), `$ajustes` (cada uno con Desc, Recomendar, Aplicar,
  Revertir), deteccion (`Get-InfoPC`), ventana (XAML + `Conectar-Eventos`) y `Main` (auto-elevacion y ShowDialog).
  Interfaz estilo bienvenida de Windows 11: paginas (`$paginas`, `Ir`, `Actualizar-Nav`) con texto a la izquierda,
  tarjetas (`Nueva-Tarjeta`) a la derecha y flechas abajo: Inicio, Tu PC, Driver, Launchers, Utilidades, Extras,
  Perifericos, Optimizar, Resumen, Progreso, Final. Nada se escanea hasta "Comenzar" y nada se instala hasta
  "Instalar y optimizar" en el Resumen (`Fase-Driver`, `Fase-Programas`, `Fase-Optimizar`, un solo reinicio al final).
  `$info` tiene la descripcion corta de cada app. Los controles del XAML se cargan solos en `$script:ui` por su x:Name.
  Si falta winget, `Instalar-Winget` lo registra o lo descarga de github.com/microsoft/winget-cli (con dependencias).
  Errores no atrapados de la ventana van al registro (Dispatcher.UnhandledException), no cierran la ventana.
  Pestana Progreso: `Iniciar-Progreso`, `Empezar-Item`, `Terminar-Item`, `Terminar-Progreso`.
  `Ejecutar-Winget` muestra el tiempo, corta con `taskkill /T` si se presiona Saltar o pasan `$limiteMinutos` (20).
  `Instalar-App` reintenta si habia otra instalacion en curso y prueba `Alternativa` (ID de la Store) si falla.
  `Texto-Error` traduce codigos de winget (tabla: winget-cli doc/windows/package-manager/winget/returnCodes.md). Cada app tiene `Web`
  (dominio oficial) para su icono, via el servicio de favicons de Google.
  En `$drivers`, `Id` vacio = ID de winget no verificado todavia (se abre la pagina oficial).
  Se publica en GitHub y se ejecuta con `irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex`.
  No usar `exit` (cerraria la ventana del usuario con `iex`): salir de `Main` con `return`.
  winget se corre con `Start-Process -PassThru` y un bucle que llama `Pump` para que la ventana no se congele.
- `INSTALAR.bat`: lanzador de doble clic; pide administrador y ejecuta `instalar.ps1` de la misma carpeta, o si no
  esta, la version de GitHub.
- `README.md`: empieza con las lineas para PowerShell y CMD; mantenerlas arriba de todo.
- `docs/superpowers/specs/`: documentos de diseno.
- `docs/apps.md`: inventario de las apps actuales y como se reinstala cada una (fuente de verdad de la lista).
- `docs/antes-de-formatear.md`: checklist de respaldo.
- `docs/optimizacion.md`: detalle de la pestana 3. Optimizar.

## Hardware y apps del usuario
- GPU **AMD** (driver AMD Software / Adrenalin, se instala a mano desde la web de AMD).
- Perifericos: **Corsair** (iCUE 5). FanControl para ventiladores.
- Launchers: Steam, EA app, Epic, GOG Galaxy, Ubisoft Connect, Battle.net, Xbox app, Playnite.
- Riot es opcional con submenu (juegos + region, `$regiones`); extras (`$extras`) son opcionales, no vienen marcados.
- Usa la app de **Xbox y la Microsoft Store** para Call of Duty y Halo: ninguna optimizacion debe romperlas.

## Reglas al editar
- Mantener `instalar.ps1` compatible con **Windows PowerShell 5.1** (el que trae Windows), no solo PowerShell 7.
- Textos del script **sin tildes ni n con tilde**: PowerShell 5.1 lee .ps1 sin BOM como ANSI y los acentos salen rotos.
- Archivos `.ps1` y `.bat` con finales de linea **CRLF** (ya definido en `.gitattributes`).
- No usar `$args` como nombre de variable (es automatica en PowerShell).
- Verificar IDs de winget antes de agregarlos: con `winget show --id X -e` en Windows, o en Linux con
  `gh api repos/microsoft/winget-pkgs/contents/manifests/<letra>/<Publisher>/<Paquete>` (ojo: hay paquetes que solo
  tienen subpaquetes, como `RazerInc.RazerInstaller.Synapse4`).
- Apps de la Store: `Fuente = "msstore"` con el ID de la Store.
- Cada app lleva `Detectar` (regex sobre DisplayName del registro Uninstall o Name de `Get-AppxPackage`).
  No confiar solo en `winget export`: omite apps instaladas desde la Store o su web (ej. Epic y GOG de la Store
  tienen IDs `XP...`, y Xbox, Chrome, WinRAR, iTunes no salen).
- Los ajustes los aplica el propio script (lista `$ajustes`), no WinUtil. WinUtil es solo un boton opcional que lo abre
  (via archivo temporal: con `-EncodedCommand` + `-Wait` Windows dio "Acceso denegado", posiblemente el antivirus;
  la auto-elevacion tambien usa archivo temporal). Recomendar siempre su
  preset **Standard**, nunca Advanced (quita OneDrive, desactiva busqueda de la Store, etc.).
- No incluir: driver Bluetooth ASUS USB-BT500 ni librerias (Visual C++, DirectX, .NET): el usuario decidio dejarlas fuera.
- Cualquier ajuste del sistema debe ser reversible y estar explicado en `docs/optimizacion.md`.
- Al cambiar la lista de apps, actualizar tambien `README.md` y `docs/apps.md`.

## Como probar
En la PC actual (con todo instalado) correr el one-liner o `INSTALAR.bat`: Mi PC debe mostrar Windows 11, la GPU AMD
con su driver ya instalado y Corsair conectado; en Launchers y Utilidades casi todo debe salir con check verde y sin marcar.
Cualquier app en "Fallaron" indica un ID incorrecto o un problema de la fuente.

## Ideas pendientes
- Respaldar/restaurar automaticamente la config de FanControl y perfiles de iCUE.
- Exportar `winget export` como respaldo adicional.
- Agregar mas perifericos al menu si cambia el hardware (con su `Vid` para la deteccion).
