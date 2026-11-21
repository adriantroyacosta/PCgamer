# PCgamer

Instalador post-formateo para mi PC gamer. Reinstala mis apps con **winget** en 5 pasos y, si quiero, optimiza Windows para juegos.

## Uso rapido

### Opcion A: desde el USB o la carpeta descargada
1. Copia `INSTALAR.bat` e `instalar.ps1` a la misma carpeta.
2. Doble clic en `INSTALAR.bat` y acepta el permiso de administrador.

### Opcion B: directo desde GitHub (PC recien formateada, sin USB)
Abre **PowerShell como administrador** y pega:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex
```

> La opcion B solo funciona si el repo es **publico**.

## Que hace

| Paso | Que hace |
|------|----------|
| 1 | Detecta la tarjeta grafica (AMD/NVIDIA) y abre la pagina del driver |
| 2 | Menu de perifericos: Corsair, Logitech, Razer, SteelSeries |
| 3 | Launchers: Steam, EA, Epic, GOG, Ubisoft, Battle.net, Xbox, Playnite |
| 4 | Utilidades: Chrome, WinRAR, Transmission, VirtualBox, iTunes, PC Manager, Terminal, FanControl, Dolby Access |
| 5 | (Opcional) Modo Juego, plan Alto rendimiento, HAGS y WinUtil preset **Standard** |

Al final muestra que se instalo, que ya estaba y que fallo.

## Agregar o quitar apps
Edita las listas al inicio de `instalar.ps1`:
- Quitar: pon `#` al inicio de la linea.
- Agregar: busca el ID con `winget search nombre` y copia una linea cambiando `Nombre` e `Id`.
- Apps de Microsoft Store: agrega `Fuente = "msstore"`.

## Documentacion
- [docs/apps.md](docs/apps.md): inventario completo de mis apps y como se reinstala cada una.
- [docs/antes-de-formatear.md](docs/antes-de-formatear.md): checklist de respaldo.
- [docs/optimizacion.md](docs/optimizacion.md): que optimiza el paso 5 y que hacer en la BIOS.
