# Optimizacion (pestana Optimizar)

Cada ajuste tiene su casilla y su explicacion (al pasar el mouse). Vienen marcados los recomendados para la PC
detectada; se aplican solo al presionar **Aplicar seleccionados** y confirmar. **Revertir seleccionados** los deja
como vienen en Windows. Conviene reiniciar despues.

| Ajuste | Se recomienda | Como | Revertir |
|--------|---------------|------|----------|
| Punto de restauracion | siempre | `Checkpoint-Computer` (activa Restaurar sistema en C: y quita el limite de 1 por dia) | - |
| Modo Juego | siempre | `HKCU\Software\Microsoft\GameBar` AutoGameModeEnabled/AllowAutoGameMode = 1 | = 0 |
| Plan Alto rendimiento | PC de escritorio | `powercfg /setactive SCHEME_MIN` | `SCHEME_BALANCED` (Equilibrado) |
| HAGS (GPU por hardware) | Windows 10 2004+ | `HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers` HwSchMode = 2 | = 1 |
| Aceleracion del mouse off | siempre | `HKCU\Control Panel\Mouse` MouseSpeed/Threshold1/Threshold2 = 0/0/0 | 1/6/10 |
| Telemetria reducida | siempre | `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` AllowTelemetry = 0 | borra el valor |
| Historial de actividad off | siempre | `HKLM\SOFTWARE\Policies\Microsoft\Windows\System` EnableActivityFeed/PublishUserActivities/UploadUserActivities = 0 | borra los valores |
| Efectos visuales: rendimiento | menos de 16 GB de RAM | `HKCU\...\Explorer\VisualEffects` VisualFXSetting = 2 | = 0 |
| Hibernacion off | PC de escritorio | `powercfg /hibernate off` (tambien quita el inicio rapido) | `powercfg /hibernate on` |
| Limpiar temporales | siempre | borra `%TEMP%` y `C:\Windows\Temp` | no aplica |

Ninguno toca Xbox, la Microsoft Store ni OneDrive.

## WinUtil (opcional)
El boton **Abrir WinUtil** abre la herramienta de Chris Titus en otra ventana (`irm https://christitus.com/win | iex`).
Si usas sus Tweaks, elige el preset **Standard**. **No usar Advanced**: quita OneDrive, desactiva la busqueda de la
Store, cambia el menu Inicio y desactiva Windows AI.

La pestana **Mi PC** tambien da consejos de BIOS segun lo detectado (ver abajo).

## En la BIOS (a mano, es lo que mas FPS da)
- **EXPO / XMP**: la RAM corre a su velocidad real.
- **Smart Access Memory / Resizable BAR**: mejora el rendimiento con GPU AMD.
