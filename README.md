# PCgamer

## Empezar (copia y pega una linea)

**PowerShell** (clic derecho en Inicio > Terminal, o busca "PowerShell"):

```powershell
irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex
```

**CMD** (busca "cmd" o "Simbolo del sistema"):

```cmd
powershell -c "irm https://raw.githubusercontent.com/adriantroyacosta/PCgamer/main/instalar.ps1 | iex"
```

1. Pega la linea y presiona Enter. No hace falta abrirlo como administrador.
2. Acepta el permiso de administrador que pide Windows.
3. Se abre la ventana del instalador: conecta tus perifericos y presiona **Comenzar analisis**.

La ventana donde pegaste la linea ya se puede cerrar. Si falta winget, el instalador lo instala solo.

---

Instalador post-formateo para mi PC gamer. Una ventana estilo WinUtil: analiza la PC, recomienda apps y ajustes segun el hardware y los perifericos conectados, y yo marco lo que quiero instalar (con **winget**) u optimizar.

## Otras formas de abrirlo

### Con doble clic (USB o carpeta descargada)
1. Copia `INSTALAR.bat` (y si quieres `instalar.ps1`) a una carpeta o USB.
2. Doble clic en `INSTALAR.bat` y acepta el permiso de administrador.

Si `instalar.ps1` esta en la misma carpeta usa esa copia (sirve sin internet para ver el analisis);
si no, descarga la ultima version de GitHub.

## Como funciona

Se navega como la bienvenida de Windows 11: una pagina a la vez, con la explicacion a la izquierda, tarjetas con
icono y casilla a la derecha, y flechas abajo para avanzar o volver (y el boton de inicio). **Nada se instala ni
cambia hasta presionar "Instalar y optimizar" en el resumen.**

| Pagina | Que tiene |
|--------|-----------|
| **Hola** | Bienvenida con tu nombre y boton **Comenzar**, que analiza la PC (si falta winget, lo instala solo). |
| **1. Esta es tu PC** | Windows, procesador, grafica, RAM, disco, winget y perifericos conectados, y recomendaciones (driver, BIOS: XMP/EXPO, Resizable BAR). |
| **2. Driver de video** | AMD, NVIDIA o Intel. Si falta viene marcado: Intel se instala con winget; AMD y NVIDIA abren su pagina oficial. |
| **3. Launchers** | Steam, EA, Epic, GOG, Ubisoft, Battle.net, Xbox, Playnite y Riot Games (al marcarlo eliges Valorant y/o League of Legends y la region). |
| **4. Utilidades** | Chrome, WinRAR, Transmission, VirtualBox, VLC, iTunes, PC Manager, Terminal, FanControl, Dolby Access. |
| **5. Extras para gamers** | Discord, OBS Studio, MSI Afterburner, HWiNFO (opcionales, sin marcar). |
| **6. Perifericos** | Corsair, Logitech, Razer, SteelSeries, Turtle Beach, ROCCAT, Elgato, ASUS ROG; lo conectado viene marcado. |
| **7. Optimizar** | Ajustes recomendados segun tu PC, con su explicacion. Se pueden revertir. Detalle en [docs/optimizacion.md](docs/optimizacion.md). |
| **8. Resumen** | "Todo listo para empezar": lo que se va a hacer, en orden, y el boton **Instalar y optimizar**. |
| **Preparando tu PC** | Una tarjeta por cosa con su icono, estado y tiempo; barra de avance, **Saltar este programa** y **Ver detalles**. Si uno tarda mas de 20 minutos se cancela solo. |
| **Todo listo** | Resumen final (instalados, ya estaban, fallaron) y **Reiniciar ahora**. |

Lo recomendado viene marcado; lo que ya tienes lleva un check verde. Cada app muestra el icono de su sitio oficial.

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
