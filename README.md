# OpenKNX InternetServices Applikation

Die Anwendung stellt Daten aus dem Internet auf dem KNX Bus zur Verfügung.

Derzeit implementierte Dienste:

- Internet Wetter
- SIP Client (Telefonanruf) (Bisher nur auf ESP32 Hardware getestet)

Geplante künftige Dienste:

- NTP (Zeitserver) (über das Networkmodule)

## Hardware Unterstützung

- [OpenKNX Reg1-ETH V1](https://github.com/OpenKNX/OpenKNX/wiki/REG1-Eth)
- Adafruit ESP32 DevKitC V4 
- Adafruit ESP32 Feather V2

## Build

Derzeit wird das Build über die Power-Shell Skripte nicht unterstüzt und es gibt auch keine offizielles Release.

### .knxprod Datei

Für RP2040 Hardware im Directory src ausführen (Bei Bedarf "-DEV" durch "-Beta" ersetzten):
```
openknxproducer create InternetServicesRP2040-Dev.xml -d -h ../include/knxprodRP2040-Dev.h
```

Für ESP32 Hardware im Directory src ausführen:
```
openknxproducer create InternetServicesESP32-Dev.xml -d -h ../include/knxprodESP32-Dev.h
```

### Firmware

Das Build muss manuell im VS-Code erzeugt werden. 
Dazu die entsprechende Konfiguration mit `_USB`-Endung auswählen und in PlatformIO über `Upload and Monitor` auf die Hardware laden.

Derzeit gibt es noch Probleme beim Bauen der ESP32 Firmware. 
Das OFM-UsbExchange und OFM-FileTransferModule muss aus dem Lib Ordner entfernt werden.

## Lizenz

[GNU GPL v3](LICENSE)

