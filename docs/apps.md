# Inventario de apps

Leyenda: 🟢 lo instala el script · 🟡 se baja desde su launcher · 🔴 a mano

## 1. Drivers y hardware
| App | Como | ID winget |
|-----|------|-----------|
| AMD Software (Adrenalin) | 🔴 web de AMD (el script abre la pagina) | - |
| Corsair iCUE 5 | 🟢 paso 3 (recomendado si hay Corsair conectado) | `Corsair.iCUE.5` |
| FanControl | 🟢 | `Rem0o.FanControl` |
| Dolby Access | 🟢 Store | `9N0866FS04W8` |

## 2. Launchers
| App | ID winget |
|-----|-----------|
| Steam | `Valve.Steam` |
| EA app | `ElectronicArts.EADesktop` |
| Epic Games Launcher | `EpicGames.EpicGamesLauncher` |
| GOG Galaxy | `GOG.Galaxy` |
| Ubisoft Connect | `Ubisoft.Connect` |
| Battle.net | `Blizzard.BattleNet` |
| Xbox | `9MV0B5HZVK9Z` (Store) |
| Playnite | `Playnite.Playnite` |
| Riot Games (opcional, submenu) | Valorant `RiotGames.Valorant.<region>` (LATAM, NA, BR, EU, KR) y League of Legends + TFT `RiotGames.LeagueOfLegends.<region>` (LA1=LAN, LA2=LAS, NA, BR, EUW, EUNE, KR). Region por defecto segun el pais de Windows |

## 3. Juegos (🟡 desde su launcher)
| Juego | Launcher |
|-------|----------|
| Battlefield 6 | EA |
| Call of Duty, MW, MW2, MW3 | Battle.net / Xbox |
| Diablo IV | Battle.net |
| Overwatch | Battle.net |
| Cyberpunk 2077 + Phantom Liberty | GOG |
| The Witcher 3 GOTY | GOG |
| Devil May Cry 5 | Steam |
| Halo: Campaign Evolved | Xbox |
| Indiana Jones and the Great Circle (DLC) | Xbox |
| Ghost Recon Wildlands | Ubisoft |
| Black Myth Wukong | 🔴 a mano |

## 4. Personalizacion
| App | Como |
|-----|------|
| Wallpaper Engine | 🟡 Steam |

## 5. Utilidades (🟢)
| App | ID winget |
|-----|-----------|
| Google Chrome | `Google.Chrome` |
| WinRAR | `RARLab.WinRAR` |
| Transmission | `Transmission.Transmission` |
| VirtualBox | `Oracle.VirtualBox` |
| VLC | `VideoLAN.VLC` |
| iTunes | `9PB2MZ1ZMB1S` (Store) |
| PC Manager | `9PM860492SZD` (Store) |
| Terminal Windows | `Microsoft.WindowsTerminal` |

## 6. Extras para gamers (opcionales, no vienen marcados)
| App | ID winget |
|-----|-----------|
| Discord | `Discord.Discord` |
| OBS Studio | `OBSProject.OBSStudio` |
| MSI Afterburner | `Guru3D.Afterburner` |
| HWiNFO | `REALiX.HWiNFO` |

## 7. Perifericos (se recomiendan si se detectan conectados por USB)
| Programa | ID winget | VID USB |
|----------|-----------|---------|
| Corsair iCUE 5 | `Corsair.iCUE.5` | 1B1C |
| Logitech G HUB | `Logitech.GHUB` | 046D |
| Razer Synapse 4 | `RazerInc.RazerInstaller.Synapse4` | 1532 |
| SteelSeries GG | `SteelSeries.GG` | 1038 |
| Turtle Beach Audio Hub | `TurtleBeach.AudioHub` | 10F5 |
| ROCCAT Swarm II | `TurtleBeach.ROCCATSwarm` | 1E7D |
| Elgato Stream Deck | `Elgato.StreamDeck` | 0FD9 |
| ASUS Armoury Crate | `Asus.ArmouryCrate` | 0B05 (solo si el nombre parece periferico ROG/TUF, por el adaptador Bluetooth ASUS) |

## 8. Drivers de video
| Marca | Como |
|-------|------|
| AMD Software (Adrenalin) | 🔴 pagina oficial (no esta en winget) |
| NVIDIA App | 🔴 pagina oficial (no esta en winget) |
| Intel Driver & Support Assistant | 🟢 `Intel.IntelDriverAndSupportAssistant` |

IDs verificados en el catalogo oficial https://github.com/microsoft/winget-pkgs (2026-11-21).

## Excluido a proposito
- Driver Bluetooth ASUS USB-BT500
- Librerias: Visual C++, DirectX, .NET, GameInput (los juegos/launchers las instalan)
- Apps que ya trae Windows (Bloc de notas, Paint, Fotos, Edge, OneDrive, Store, Game Bar, extensiones de video, etc.)
