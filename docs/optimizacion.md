# Optimizacion (paso 5)

El paso 5 es opcional: el script pregunta S/N (Enter = no). Los cambios se aplican recien despues de
confirmar el resumen final. Si Windows es anterior a 10 2004 (build 19041), HAGS se omite.

## Ajustes propios
| Ajuste | Como | Revertir |
|--------|------|----------|
| Modo Juego | `HKCU\Software\Microsoft\GameBar` AutoGameModeEnabled=1 | Configuracion > Juegos > Modo de juego |
| Plan Alto rendimiento | `powercfg /setactive SCHEME_MIN` | Panel de control > Opciones de energia > Equilibrado |
| HAGS (GPU por hardware) | `HKLM\...\GraphicsDrivers` HwSchMode=2 (requiere reiniciar) | Configuracion > Pantalla > Graficos > Cambiar config. predeterminada |

## WinUtil preset Standard
Se ejecuta: `& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Preset Standard`

Incluye: punto de restauracion, desactiva historial de actividad, apps sugeridas, ubicacion y telemetria,
servicios de fondo en manual, Delivery Optimization, limpieza de disco y temporales, "Finalizar tarea" en la barra.

Detalle oficial: https://github.com/ChrisTitusTech/winutil/blob/main/config/preset.json

**No usar Advanced**: quita OneDrive, desactiva la busqueda de la Store, cambia el menu Inicio y desactiva Windows AI.

Revertir: restaurar desde el punto de restauracion que crea WinUtil.

## En la BIOS (a mano, es lo que mas FPS da)
- **EXPO / XMP**: la RAM corre a su velocidad real.
- **Smart Access Memory / Resizable BAR**: mejora el rendimiento con GPU AMD.
