# PCgamer

Instalador post-formateo para mi PC gamer. Una ventana estilo WinUtil: analiza la PC, recomienda apps y ajustes segun el hardware y los perifericos conectados, y yo marco lo que quiero instalar (con **winget**) u optimizar.

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

Se abre una ventana con tres pestanas. **Nada se instala ni cambia hasta que presionas un boton** y confirmas.

| Pestana | Que tiene |
|---------|-----------|
| **Mi PC** | Aviso de conectar todos los perifericos y boton *Volver a escanear*. Muestra Windows, tipo (escritorio/laptop), procesador, grafica, RAM, disco y perifericos conectados (Corsair, Logitech, Razer, SteelSeries). Recomendaciones: driver de la grafica (si falta, boton para abrir su pagina), programas de perifericos y consejos de BIOS (EXPO/XMP, Resizable BAR). |
| **Instalar** | Launchers, utilidades y programas de perifericos con casillas. Lo que falta y los perifericos conectados vienen marcados; lo instalado sale como *(ya instalado)*. Botones *Marcar recomendados*, *Desmarcar todo* e *Instalar seleccionados*. |
| **Optimizar** | Ajustes con casillas y explicacion al pasar el mouse. Vienen marcados los recomendados para tu PC (por ejemplo, Alto rendimiento solo en escritorio). Botones *Aplicar*, *Revertir* y *Abrir WinUtil (opcional)*. Detalle en [docs/optimizacion.md](docs/optimizacion.md). |

Abajo hay un registro con lo que va haciendo y el resultado (instaladas / ya estaban / fallaron).

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
