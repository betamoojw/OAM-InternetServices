#include "OpenKNX.h"

#ifdef NET_ModuleVersion
#include "NetworkModule.h"
#endif
#ifdef ARDUINO_ARCH_RP2040
#include "UsbExchangeModule.h"
#endif
#include "FileTransferModule.h"
#include "Logic.h"
#include "InternetWeatherModule.h"
#include "SIPModule.h"
#include "FunctionBlocksModule.h"
#include "NetworkBridgeModule.h"
#include "EnergyPriceModule.h"
#include "PVForecastModule.h"
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
    openknx.init();
#ifdef WLAN_WifiSSID    
    openknx.addModule(1, openknxWLANModule);
#endif
#ifdef NET_ModuleVersion
    openknx.addModule(2, openknxNetwork);
#endif    
    openknx.addModule(1, openknxLogic);
#ifdef ARDUINO_ARCH_RP2040
    openknx.addModule(5, openknxUsbExchangeModule);
#endif
    openknx.addModule(6, openknxFileTransferModule);
    openknx.addModule(7, openknxInternetWeatherModule);
    openknx.addModule(8, openknxSIPModule);
    openknx.addModule(9, openknxFunctionBlocksModule);
    openknx.addModule(10, openknxEnergyPriceModule);
    openknx.addModule(11, openknxPVForecastModule);
    openknx.addModule(12, openknxNetworkBridgeModule);
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