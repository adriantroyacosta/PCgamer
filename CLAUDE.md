# Contexto para Claude Code

## Que es este proyecto
Instalador post-formateo para la PC gamer personal de Adrian (Windows 11). Despues de formatear,
un solo script reinstala sus apps con winget y opcionalmente optimiza Windows para juegos.
Proyecto personal: no tiene relacion con trabajo.

## Archivos
- `instalar.ps1`: script principal (PowerShell 5.1). Listas de apps al inicio, luego 5 pasos y un resumen.
- `INSTALAR.bat`: lanzador; pide administrador y ejecuta `instalar.ps1` con ExecutionPolicy Bypass.
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
- WinUtil: usar solo el preset **Standard**. Nunca Advanced (quita OneDrive, desactiva busqueda de la Store, etc.).
- No incluir: driver Bluetooth ASUS USB-BT500 ni librerias (Visual C++, DirectX, .NET): el usuario decidio dejarlas fuera.
- Cualquier ajuste del sistema debe ser reversible y estar explicado en `docs/optimizacion.md`.
- Al cambiar la lista de apps, actualizar tambien `README.md` y `docs/apps.md`.

## Como probar
En la PC actual (con todo instalado) correr `INSTALAR.bat`: casi todo debe salir en "Ya estaban".
Cualquier app en "Fallaron" indica un ID incorrecto o un problema de la fuente.

## Ideas pendientes
- Respaldar/restaurar automaticamente la config de FanControl y perfiles de iCUE.
- Exportar `winget export` como respaldo adicional.
- Agregar mas perifericos al menu si cambia el hardware.
