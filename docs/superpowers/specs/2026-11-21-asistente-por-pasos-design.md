# Diseno: instalador como asistente por pasos (estilo WinUtil, en consola)

Fecha: 2026-11-21

## Intencion

Hoy `instalar.ps1` empieza a instalar casi todo apenas se ejecuta: abre la pagina del driver e
instala todos los launchers y utilidades sin preguntar. Adrian quiere que funcione como WinUtil:
se lanza con una linea de PowerShell (`irm ... | iex`), primero muestra informacion de la PC y
no instala nada hasta que el elige que instalar.

## Objetivos
- Se lanza con un one-liner desde GitHub, sin USB ni archivos descargados.
- Al arrancar **no instala nada**: primero analiza la PC y muestra lo que encontro.
- Luego recorre pasos en un orden fijo (siempre se muestran todos, ninguno se salta); en cada
  paso el usuario elige que instalar.
- Recomienda en base a lo detectado: software de perifericos conectados y driver de la GPU.
- Primero se responden todos los pasos, se confirma un resumen, y despues se instala todo de corrido.

## No objetivos
- No es una ventana grafica (WPF) como WinUtil: es un menu en la consola (opcion B elegida).
- No instala drivers de GPU automaticamente (sigue abriendo la pagina de AMD/NVIDIA).
- No respalda/restaura configuraciones de iCUE o FanControl (sigue en ideas pendientes).

## Anti-objetivos (seria un fracaso aunque funcione)
- Que instale o cambie algo antes de que el usuario confirme el resumen.
- Que alguna optimizacion rompa la app de Xbox o la Microsoft Store.
- Que use WinUtil con un preset distinto de Standard.

## Restricciones (de CLAUDE.md)
- Compatible con Windows PowerShell 5.1.
- Textos del script sin tildes ni enie.
- `.ps1` y `.bat` con CRLF.
- No usar `$args` como variable.
- Sin librerias (Visual C++, DirectX, .NET) ni driver Bluetooth ASUS USB-BT500.

## Enfoques considerados
- **A) Ventana grafica con casillas (como WinUtil):** lo mas parecido a WinUtil y se marca app por
  app, pero es mucho mas codigo. Descartado por Adrian.
- **B) Asistente por pasos en la consola:** simple, rapido de hacer y facil de mantener. **Elegido.**
- Dentro de B, dos formas de instalar:
  - Instalar al terminar cada paso: obliga a quedarse mirando entre paso y paso.
  - **Responder todo, confirmar y luego instalar de corrido: elegido**, permite dejar la PC sola.

## Flujo decidido

### 0. Arranque
- One-liner: `irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex`
- Si no es administrador, se vuelve a abrir solo como administrador y cierra la ventana original.
  - Si se ejecuto con `irm | iex` (no hay ruta de archivo), la ventana elevada vuelve a descargar
    el script con la misma URL (fija en el script).
  - Si se ejecuto desde un archivo local (`INSTALAR.bat` o `-File`), la ventana elevada ejecuta ese
    mismo archivo.
- Pantalla de bienvenida. No hace nada hasta continuar.

### 1. Analisis de la PC (solo lee, no cambia nada)
Muestra, por ejemplo:
```
ANALIZANDO TU PC...
  Windows:     Windows 11 Pro 24H2 (build 26100)   OK
  winget:      instalado (v1.9)                    OK
  GPU:         AMD Radeon RX 7800 XT  -> recomendado: AMD Adrenalin
  Perifericos: Corsair (teclado, mouse)  -> recomendado: iCUE 5
               Logitech (headset)        -> recomendado: G HUB
Enter para empezar los pasos...
```
- **Windows:** edicion, version (ej. 24H2) y build. Si es Windows 10 o un build viejo, avisa que
  podria no funcionar (ej. HAGS necesita Windows 10 2004 / build 19041 o mas nuevo).
- **winget:** si falta, avisa que hay que actualizar "App Installer" desde la Store y no continua
  a los pasos (nada se podria instalar).
- **GPU:** AMD/Radeon o NVIDIA/GeForce/RTX/GTX, como hoy.
- **Perifericos:** dispositivos USB conectados, reconocidos por ID de fabricante (VID):
  Corsair `1B1C`, Logitech `046D`, Razer `1532`, SteelSeries `1038`. Solo marcas que tienen
  programa en el menu; al agregar una marca nueva se agrega su VID junto a ella en la lista.
  Muestra los nombres de los dispositivos detectados de cada marca.
- **Apps ya instaladas:** revisa que apps de las listas ya estan instaladas, para marcarlas en
  los pasos como `(ya instalado)`.

### 2. Pasos (solo se elige, no se instala)
Orden fijo:
1. Launchers
2. Utilidades
3. Perifericos
4. Driver de la GPU
5. Optimizar Windows

Pasos 1 a 3 se ven asi:
```
PASO 1 de 5 - Launchers
  1) Steam (ya instalado)   5) Ubisoft Connect
  2) EA app                 6) Battle.net
  3) Epic Games             7) Xbox
  4) GOG Galaxy             8) Playnite
Enter = todos | numeros (ej: 1,3,8) | 0 = ninguno
```
- Launchers y Utilidades: Enter = todos los que no estan instalados.
- Perifericos: Enter = los recomendados por lo que se detecto conectado; si no se detecto nada,
  Enter = ninguno. Los recomendados se marcan en la lista.
- Driver GPU: muestra la recomendacion (AMD Adrenalin / NVIDIA App) y pregunta si abrir la
  pagina al final (S/N, Enter = si). Si no se reconocio la GPU, lo dice y no hay nada que elegir.
- Optimizar Windows: explica lo que hace (igual que hoy) y pregunta S/N.

### 3. Resumen y confirmacion
Lista todo lo elegido (apps a instalar, pagina del driver, optimizacion si/no) y pregunta
"Confirmar? (S/N)". N = salir sin instalar ni cambiar nada.

### 4. Ejecucion
Instala lo elegido con la misma funcion `Instalar` de hoy (winget silencioso), luego aplica la
optimizacion si se eligio (Modo Juego, Alto rendimiento, HAGS, WinUtil Standard, igual que hoy),
y abre la pagina del driver si se eligio.

### 5. Resultado final
Igual que hoy: instaladas / ya estaban / fallaron, lista de pendientes a mano, aviso de reiniciar
si se optimizo.

## Otros cambios
- `INSTALAR.bat` se mantiene como opcion sin internet (repo descargado). Sigue funcionando igual.
- `README.md`: el one-liner pasa a ser la opcion principal; ya no hace falta abrir PowerShell como
  administrador ni el `Set-ExecutionPolicy` (el script se eleva solo). Actualizar la tabla de pasos.
- `docs/apps.md`: actualizar donde menciona "menu de perifericos" si cambia el texto.
- `CLAUDE.md`: actualizar la descripcion de archivos y de los pasos.

## Decisiones dejadas al implementador (marcadas como mias)
- **Deteccion de apps instaladas:** ejecutar `winget list` una sola vez y buscar los IDs en la
  salida (mas rapido que consultar app por app). Las apps de la Store pueden no aparecer con su
  ID; si no se detecta, simplemente no se marca y se intenta instalar (winget devuelve "ya
  instalado" y sale en "Ya estaban").
- **Entrada invalida** (numeros fuera de rango, letras): avisar y volver a preguntar ese paso.
- **Logitech `046D`** tambien cubre webcams y mouses de oficina, asi que puede recomendar G HUB
  de mas; se acepta porque es solo una recomendacion y se ven los nombres de los dispositivos.
- Deteccion USB con `Get-PnpDevice -PresentOnly` filtrando `InstanceId` por `VID_xxxx`
  (disponible en PowerShell 5.1).
- Version de Windows desde `Win32_OperatingSystem` (Caption, BuildNumber) y `DisplayVersion`
  del registro `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion`.

## Como probar
- En Linux: revisar que el script se pueda parsear (si hay `pwsh` disponible) y que no tenga tildes.
- En la PC actual: correr el one-liner. El analisis debe mostrar Windows 11, la GPU AMD y Corsair;
  los pasos deben marcar casi todo como `(ya instalado)`; al confirmar, casi todo sale en
  "Ya estaban". Probar tambien responder N en el resumen y verificar que no se instalo nada.
