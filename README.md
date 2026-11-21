# PCgamer

Instalador post-formateo para mi PC gamer. Analiza la PC, me deja elegir paso a paso que reinstalar con **winget** y, si quiero, optimiza Windows para juegos.

## Uso rapido

### Opcion A: directo desde GitHub (recomendado, PC recien formateada)
Abre **PowerShell** (no hace falta como administrador) y pega:

```powershell
irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex
```

Si no tiene permisos de administrador, el script abre solo una ventana nueva como administrador.

### Opcion B: sin internet, desde el USB o la carpeta descargada
1. Copia `INSTALAR.bat` e `instalar.ps1` a la misma carpeta.
2. Doble clic en `INSTALAR.bat` y acepta el permiso de administrador.

## Como funciona

Funciona como un asistente: **no instala nada al arrancar**.

1. **Analiza la PC** (solo lee): version de Windows, winget, tarjeta grafica, perifericos USB
   conectados (Corsair, Logitech, Razer, SteelSeries) y que apps ya estan instaladas.
2. **Pasos en orden fijo**, en cada uno eliges que instalar
   (`Enter` = lo sugerido, numeros como `1,3` = esas, `0` = ninguna):

| Paso | Que eliges | Enter = |
|------|------------|---------|
| 1 | Launchers: Steam, EA, Epic, GOG, Ubisoft, Battle.net, Xbox, Playnite | todos los que faltan |
| 2 | Utilidades: Chrome, WinRAR, Transmission, VirtualBox, iTunes, PC Manager, Terminal, FanControl, Dolby Access | todos los que faltan |
| 3 | Perifericos: iCUE, G HUB, Synapse, SteelSeries GG | los detectados conectados |
| 4 | Abrir la pagina del driver de la GPU detectada (AMD/NVIDIA) | si |
| 5 | Optimizar: Modo Juego, plan Alto rendimiento, HAGS y WinUtil preset **Standard** | no |

3. **Resumen**: muestra todo lo elegido y pide confirmar. Si dices N, no se cambia nada.
4. **Instala todo de corrido** y al final muestra que se instalo, que ya estaba y que fallo.

## Agregar o quitar apps
Edita las listas al inicio de `instalar.ps1`:
- Quitar: pon `#` al inicio de la linea.
- Agregar: busca el ID con `winget search nombre` y copia una linea cambiando `Nombre` e `Id`, y `Detectar`: el nombre con que aparece en *Agregar o quitar programas* (o el nombre del paquete de la Store, se ve con `Get-AppxPackage *nombre*`). Asi el script sabe si ya esta instalada aunque la hayas instalado desde su web o la Store.
- Perifericos de otra marca: agrega tambien `Marca` y `Vid` (ID de fabricante USB, se ve en Administrador de dispositivos > Detalles > Id. de hardware).
- Apps de Microsoft Store: agrega `Fuente = "msstore"`.

## Documentacion
- [docs/apps.md](docs/apps.md): inventario completo de mis apps y como se reinstala cada una.
- [docs/antes-de-formatear.md](docs/antes-de-formatear.md): checklist de respaldo.
- [docs/optimizacion.md](docs/optimizacion.md): que optimiza el paso 5 y que hacer en la BIOS.
