# OpenKNX InternetServices Applikation

Die Anwendung stellt Daten aus dem Internet auf dem KNX Bus zur Verfügung:

- Internet Wetter Dienst
- Anruf eine Rufnummer über SIP (keine Audioverbindung)
- Aktuellen Strompreis 
- PV-Ertragsprognose

## Anwendungsdokumentation

Die detaillierte Beschreibungen der Anwendung ist in folgenden Abschnitten zu finden:

- [OpenKNX Applikationsbeschreibung](https://github.com/OpenKNX/OGM-Common/blob/v1/doc/Applikationsbeschreibung-Common.md)
- [Konfigurationstransfer](https://github.com/OpenKNX/OFM-ConfigTransfer/blob/v1/doc/Applikationsbeschreibung-ConfigTransfer.md)
- [Internet Wetter](https://github.com/OpenKNX/OFM-InternetWeatherModule) - Bereitstellung von Wetterdaten aus dem Internet
- [Strompreis](https://github.com/OpenKNX/OFM-EnergyPriceModule/blob/v1/doc/Applikationsbeschreibung-EnergyPrice.md) - Liefert den aktuellen Strompreis
- [PV-Prognose](https://github.com/OpenKNX/OFM-PVForecastModule/blob/v1dev/doc/Applikationsbeschreibung-PVForecast.md) - Liefert eine solarbasierte Ertragsprognose 
- [SIP Client](https://github.com/OpenKNX/OFM-SIPClientModule) - Auslösen von Telefonanrufen (ohne Sprachverbindung)
- [Logikmodule](https://github.com/OpenKNX/OFM-LogicModule/blob/v1/doc/Applikationsbeschreibung-Logik.md)
- [Funktionsblöcke](https://github.com/mgeramb/OFM-FunctionBlocks/blob/v1/doc/Applikationsbeschreibung-FunctionBlocks.md)

## Firmware

Eine vorkomplierte Firmware ist [hier](https://github.com/OpenKNX/OAM-InternetServices/releases) zu finden. ZIP Datei herunterladen, entpacken und der Anleitung im Readme folgen.

## Hardware

Als Hardware kann jede OpenKNX oder OpenKNX-Ready Hardware mit LAN oder WLAN verwendet werden.
Die vorkompilierte Firmware unterstützt:

- [REG1-LAN-TP-Base](https://github.com/OpenKNX/OpenKNX/wiki/REG1-LAN-TP-Base)
- [OpenKNX Reg1-ETH V1](https://github.com/OpenKNX/OpenKNX/wiki/REG1-Eth)
- [Adafruit ESP32 Feather V2](https://github.com/OpenKNX/OpenKNX/wiki/Adafruit-ESP32-Feather-V2)

## Lizenz

Diese Software steht unter der [GNU GPL v3](LICENSE).

## Release Notes Workflow

### Modul Release Notes

Jedes Projekt unter `lib/` enthaelt eine `release_notes.md` im maschinenlesbaren Format:

- `## <version>`
- `### Breaking Changes`
- `### Feature`
- `### Bug`

Die Reihenfolge innerhalb jedes Versionskapitels ist verbindlich: zuerst `Breaking Changes`, dann `Feature`, dann `Bug`.

### Dependencies mit Modulversion

Das Script `lib/OGM-Common/scripts/setup/reusable/Build-Dependencies.ps1` schreibt zusaetzlich die Modulversion aus `library.json` in jede Zeile der `dependencies.txt`.

### Aggregierte Gesamtrelease Notes

Das Script `scripts/Generate-Aggregated-ReleaseNotes.ps1` erzeugt Gesamtrelease Notes aus zwei Snapshots der `dependencies.txt`:

```powershell
pwsh scripts/Generate-Aggregated-ReleaseNotes.ps1 \
	-OldDependenciesFile dependencies_old.txt \
	-NewDependenciesFile dependencies_new.txt
```

Standardausgabe:

- `release/release_notes.md`
- `RELEASE_NOTES.md`

Die vollstaendige Historie dieses Repositories liegt in [RELEASE_NOTES.md](RELEASE_NOTES.md).
