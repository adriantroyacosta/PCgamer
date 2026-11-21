# Contexto para Claude Code

## Que es este proyecto
Instalador post-formateo para la PC gamer personal de Adrian (Windows 11). Despues de formatear,
un solo script (lanzado con `irm ... | iex`, estilo WinUtil) analiza la PC, deja elegir paso a paso
que reinstalar con winget y opcionalmente optimiza Windows para juegos. No instala nada antes de confirmar.
Proyecto personal: no tiene relacion con trabajo.

## Archivos
- `instalar.ps1`: script principal (PowerShell 5.1). Listas de apps al inicio; `Main` hace: auto-elevacion a
  administrador, analisis de la PC (Windows, winget, GPU, perifericos USB por VID, apps instaladas), 5 pasos
  donde solo se elige, resumen con confirmacion, instalacion y resultado.
  Se publica en GitHub y se ejecuta con `irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex`.
  No usar `exit` (cerraria la ventana del usuario con `iex`): salir de `Main` con `return`.
- `INSTALAR.bat`: lanzador sin internet; pide administrador y ejecuta `instalar.ps1` con ExecutionPolicy Bypass.
- `docs/superpowers/specs/`: documentos de diseno.
- `docs/apps.md`: inventario de las apps actuales y como se reinstala cada una (fuente de verdad de la lista).
- `docs/antes-de-formatear.md`: checklist de respaldo.
- `docs/optimizacion.md`: detalle del paso 5.

## Hardware y apps del usuario
- GPU **AMD** (driver AMD Software / Adrenalin, se instala a mano desde la web de AMD).
- Perifericos: **Corsair** (iCUE 5). FanControl para ventiladores.
- Launchers: Steam, EA app, Epic, GOG Galaxy, Ubisoft Connect, Battle.net, Xbox app, Playnite.
- Usa la app de **Xbox y la Microsoft Store** para Call of Duty y Halo: ninguna optimizacion debe romperlas.

## Reglas al editar
- Mantener `instalar.ps1` compatible con **Windows PowerShell 5.1** (el que trae Windows), no solo PowerShell 7.
- Textos del script **sin tildes ni n con tilde**: PowerShell 5.1 lee .ps1 sin BOM como ANSI y los acentos salen rotos.
- Archivos `.ps1` y `.bat` con finales de linea **CRLF** (ya definido en `.gitattributes`).
- No usar `$args` como nombre de variable (es automatica en PowerShell).
- Verificar IDs de winget con `winget search` o `winget show --id X -e` antes de agregarlos.
- Apps de la Store: `Fuente = "msstore"` con el ID de la Store.
- Cada app lleva `Detectar` (regex sobre DisplayName del registro Uninstall o Name de `Get-AppxPackage`).
  No confiar solo en `winget export`: omite apps instaladas desde la Store o su web (ej. Epic y GOG de la Store
  tienen IDs `XP...`, y Xbox, Chrome, WinRAR, iTunes no salen).
- WinUtil: usar solo el preset **Standard**. Nunca Advanced (quita OneDrive, desactiva busqueda de la Store, etc.).
- No incluir: driver Bluetooth ASUS USB-BT500 ni librerias (Visual C++, DirectX, .NET): el usuario decidio dejarlas fuera.
- Cualquier ajuste del sistema debe ser reversible y estar explicado en `docs/optimizacion.md`.
- Al cambiar la lista de apps, actualizar tambien `README.md` y `docs/apps.md`.

## Como probar
En la PC actual (con todo instalado) correr el one-liner o `INSTALAR.bat`: el analisis debe mostrar Windows 11,
la GPU AMD y Corsair; los pasos deben marcar casi todo como "(ya instalado)". Responder N en el resumen no debe cambiar nada.
Cualquier app en "Fallaron" indica un ID incorrecto o un problema de la fuente.

## Ideas pendientes
- Respaldar/restaurar automaticamente la config de FanControl y perfiles de iCUE.
- Exportar `winget export` como respaldo adicional.
- Agregar mas perifericos al menu si cambia el hardware (con su `Vid` para la deteccion).
