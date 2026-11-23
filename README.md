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

Se abre una ventana con pestanas en el orden logico para dejar la PC lista para jugar, con **un solo reinicio al final**.
**Nada se instala ni cambia hasta que confirmas.**

| Pestana | Que tiene |
|---------|-----------|
| **Mi PC** | Pantalla de inicio: pide conectar todos los perifericos y presionar **Comenzar analisis** (las demas pestanas se activan despues). Si falta winget lo instala solo (primero lo activa; si no, lo descarga de Microsoft). Si no hay internet, avisa. Muestra Windows, tipo (escritorio/laptop), procesador, grafica, RAM, disco y perifericos conectados. Recomendaciones y consejos de BIOS (EXPO/XMP, Resizable BAR). Boton **Hacer todo lo recomendado** que corre las fases 1, 2 y 3 seguidas. |
| **1. Driver** | Detecta la tarjeta de video (AMD, NVIDIA o Intel) y si su driver ya esta instalado. Si falta, viene marcado: Intel se instala con winget; AMD y NVIDIA no estan en winget, asi que se abre su pagina oficial. Va primero porque los juegos y ajustes como HAGS dependen de el. |
| **2. Programas** | Launchers (con Riot Games: al marcarlo eliges Valorant y/o League of Legends y la region), utilidades, extras para gamers opcionales (Discord, OBS, MSI Afterburner, HWiNFO) y programas de perifericos (Corsair, Logitech, Razer, SteelSeries, Turtle Beach, ROCCAT, Elgato, ASUS ROG) con casillas. Lo que falta y los perifericos conectados vienen marcados; lo instalado sale como *(ya instalado)*. |
| **3. Optimizar** | Ajustes con casillas y explicacion al pasar el mouse, recomendados segun tu PC. Va al final para que el punto de restauracion guarde la PC con todo instalado. Botones *Aplicar*, *Revertir* y *Abrir WinUtil (opcional)*. Detalle en [docs/optimizacion.md](docs/optimizacion.md). |

| **Progreso** | Se abre sola al instalar o aplicar: barra de avance, "Instalando 3 de 9: Steam (1:24)" con el tiempo que lleva, y una fila por cada cosa con su icono y estado (En espera, Instalando..., Instalado con su tiempo, Ya estaba, Fallo con el motivo). Boton **Saltar este programa** si uno se queda pegado; ademas, si uno tarda mas de 20 minutos se cancela solo y sigue con el siguiente. Si Epic o GOG fallan, se prueba su version de la Microsoft Store. Al terminar queda el resumen con el tiempo total. |

Cada app muestra el icono de su sitio oficial (se descarga al abrir; sin internet se ve sin icono). Lo que ya esta instalado
lleva un check verde. Abajo hay un registro con el detalle de todo lo que va haciendo.

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
