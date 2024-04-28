#include "WLANModule.h"
#ifdef ARDUINO_ARCH_ESP32
#include <Preferences.h>
#endif

WLANModule::WLANModule()
{

}

const std::string WLANModule::name()
{
    return "WLAN";
}

const std::string WLANModule::version()
{
    // hides the module in the version output on the console, because the firmware version is sufficient.
    return "";
}

void WLANModule::showInformations()
{
    if (connected())
        openknx.logger.logWithPrefixAndValues("WLAN", "Connected (%s)", WiFi.localIP().toString().c_str());
    else
        openknx.logger.logWithPrefix("WLAN", "Not connected");
}

void WLANModule::showHelp()
{
    openknx.console.printHelpLine("wlan", "Show IP address if connected");
}

bool WLANModule::processCommand(const std::string cmd, bool diagnoseKo)
{
    if (cmd == "wlan")
    {
        if (!wlanConfigured)
        {
            logInfoP("WiFi configuration missing");
            return true;
        }
        auto state = WiFi.status();
        switch(state)
        {
            case WL_NO_SHIELD:
                logInfoP("State: no shield");
                break;
            case WL_IDLE_STATUS:
                logInfoP("State: idle");
                break;
            case WL_NO_SSID_AVAIL:
                logInfoP("State: no ssid available");
                break;
            case WL_SCAN_COMPLETED:
                logInfoP("State: scan complete");
                break;
            case WL_CONNECTED:
                logInfoP("State: connected");
                break;
            case WL_CONNECT_FAILED:
                logInfoP("State: connection failed");
                break;
            case WL_CONNECTION_LOST:
                logInfoP("State: connection lost");
                break;
            case WL_DISCONNECTED:
                logInfoP("State: disconnected");
                break;
            default:
                logInfoP("State: unknown");
                break;
        }
        if (usingSavedConfiguration)
            logInfoP("SSID (KNX config missing, using fallback from flash): {%s}", WiFi.SSID().c_str());
        else
            logInfoP("SSID: {%s}", WiFi.SSID().c_str());
        if (state == WL_CONNECTED)
        {
            logInfoP("IP: {%s}", WiFi.localIP().toString().c_str());
            logInfoP("Gateway-IP: {%s}", WiFi.localIP().toString().c_str());
        }
        return true;
    }
    return false;
}

bool WLANModule::connected()
{
    return WiFi.status() == WL_CONNECTED;
}


void WLANModule::setup(bool configured)
{
#if ARDUINO_ARCH_ESP32     
    Preferences preferences;
    if (!configured)
    {
        if (preferences.begin("WLAN", true))
        {
            auto ssid = preferences.getString("SSID");
            auto password = preferences.getString("PWD");
            if (ssid.length() > 0)
            {
                wlanConfigured = true;
                usingSavedConfiguration = true;
                WiFi.mode(WIFI_STA);
                WiFi.begin(ssid, password);
            }
        }
    }
    else
    {
        KoWLAN_WLANState.value(false, DPT_Switch);
        if (strlen((const char *)ParamWLAN_WifiSSID) > 0)
        {
            wlanConfigured = true;
            WiFi.mode(WIFI_STA);
            WiFi.begin((const char *)ParamWLAN_WifiSSID, (const char *)ParamWLAN_WifiPassword);
            bool needSave = true;
            if (preferences.begin("WLAN", true))
            {
                auto ssid = preferences.getString("SSID");
                auto password = preferences.getString("PWD");
                if (ssid == (const char *)ParamWLAN_WifiSSID && password == (const char *)ParamWLAN_WifiPassword)
                    needSave = false;
                preferences.end();
            }
            if (needSave)
            {
                preferences.begin("WLAN", false);
                preferences.putString("SSID", (const char *)ParamWLAN_WifiSSID);
                preferences.putString("PWD", (const char *)ParamWLAN_WifiPassword);
            }
        }
    }

#endif
    // Do not call baseclass, baseclass will be called after first WiFi connection
}

void WLANModule::loop()
{
#if ARDUINO_ARCH_ESP32 
    bool isConnected = connected();   
    if ((bool)KoWLAN_WLANState.value(DPT_Switch) != isConnected)
    {
        KoWLAN_WLANState.value(isConnected, DPT_Switch);
    }
#endif
}


WLANModule openknxWLANModule;