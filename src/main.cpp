#include "OpenKNX.h"
//#include "Logic.h"
#include "InternetWeatherModule.h"
#ifdef ARDUINO_ARCH_ESP32
#include "WLANModule.h"

#endif
#include "SIPModule.h"
#ifdef NET_ModuleVersion
#include "NetworkModule.h"
#endif
#ifdef ARDUINO_ARCH_RP2040
#include "UsbExchangeModule.h"
#include "FileTransferModule.h"
#endif
#include "Logic.h"
#ifdef USE_AUTO_CONNECT
#include <AutoConnect.h>
#include <WebServer.h>
WebServer webServer(80);
AutoConnect Portal(webServer);    
AutoConnectConfig config;
#endif

#include "HTTPClient.h"



void setup()
{
    const uint8_t firmwareRevision = 1;
    openknx.init(firmwareRevision);
#ifdef WLAN_WifiSSID    
    openknx.addModule(1, openknxWLANModule);
#endif
#ifdef NET_ModuleVersion
    openknx.addModule(1, openknxNetwork);
#endif    
  openknx.addModule(2, openknxLogic);
  openknx.addModule(3, openknxInternetWeatherModule);
#ifdef ARDUINO_ARCH_ESP32    
 //   openknx.addModule(4, openknxOTAUpdateModule);
 openknx.addModule(7, openknxSIPModule);
#endif
#ifdef ARDUINO_ARCH_RP2040
    openknx.addModule(5, openknxUsbExchangeModule);
    openknx.addModule(6, openknxFileTransferModule);
#endif
    openknx.setup();
#ifdef USE_AUTO_CONNECT
    config.apid ="OpenKNX";
    config.password = "12345678";
    Portal.config(config);
    Portal.begin();
#endif

}

void loop()
{
#ifdef USE_AUTO_CONNECT
    Portal.handleClient();
#endif
   openknx.loop();
}

#ifdef OPENKNX_DUALCORE
void setup1()
{
    openknx.setup1();
}

void loop1()
{
    openknx.loop1();
}
#endif