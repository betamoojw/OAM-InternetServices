
# Applikationsbeschreibung Internetr Services

## Wichtige Hinweise

* Diese KNXprod wird nicht von der KNX Association offiziell unterstützt!
* Die Erzeugung der KNXprod geschieht auf Eure eigene Verantwortung!

## Module

Die Smart Home Bridge besteht aus folgenden Modulen:

- [OpenKNX Applikationsbeschreibung](https://github.com/OpenKNX/OGM-Common/blob/v1/doc/Applikationsbeschreibung-Common.md)
- [Konfigurationstransfer](https://github.com/OpenKNX/OFM-ConfigTransfer/blob/v1/doc/Applikationsbeschreibung-ConfigTransfer.md)
- [Internet Wetter](https://github.com/OpenKNX/OFM-InternetWeatherModule)
- [SIP Client](https://github.com/OpenKNX/OFM-SIPClientModule)
- [Logikmodule](https://github.com/OpenKNX/OFM-LogicModule/blob/v1/doc/Applikationsbeschreibung-Logik.md)
- [Funktionsblöcke](https://github.com/mgeramb/OFM-FunctionBlocks/blob/v1/doc/Applikationsbeschreibung-FunctionBlocks.md)

## Architekturhinweis Internet Wetter

Das InternetWeather-Modul arbeitet im aktuellen Stand kanalbasiert mit einem einzelnen Zielwert pro Kanal.
Die interne Provider-Anfrage erfolgt über eine Request-Liste der benötigten Werte, damit nur erforderliche Wetterdaten angefragt und befüllt werden.