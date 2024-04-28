#ifdef ARDUINO_ARCH_ESP32

#include "SIPModule.h"
#include "WiFi.h"
#include "lwip/ip_addr.h"

#include "sip_client/lwip_udp_client.h"
#include "sip_client/mbedtls_md5.h"
#include "sip_client/sip_client.h"

using SipClientT = SipClient<LwipUdpClient, MbedtlsMd5>;

SipClientT* sipClient = nullptr;

SIPModule::SIPModule()
{

}

const std::string SIPModule::name()
{
    return "SIP";
}

const std::string SIPModule::version()
{
    // hides the module in the version output on the console, because the firmware version is sufficient.
    return "";
}

void SIPModule::showInformations()
{
    // if (connected())
    //     openknx.logger.logWithPrefixAndValues("SIP", "Connected (%s)", WiFi.localIP().toString().c_str());
    // else
    //     openknx.logger.logWithPrefix("SIP", "Not connected");
}

void SIPModule::showHelp()
{
    openknx.console.printHelpLine("sip", "make sip call");
}

bool SIPModule::processCommand(const std::string cmd, bool diagnoseKo)
{
    if (cmd == "sip")
    {
        sipClient->request_ring("06803125021", "555");
        return true;
    }
    return false;
}


void SIPModule::setup(bool configured)
{

}

void SIPModule::loop()
{
#if ARDUINO_ARCH_ESP32 
    if (sipClient != nullptr)
    {
        sipClient->run();
    }
    else if (WiFi.status() == WL_CONNECTED)
    {
         auto user = std::string("OpenKNXSIP");
        auto pwd = std::string("");
        auto server_ip = std::string("192.168.0.1");
         auto server_port = std::string("5060");
        auto local_ip = std::string(WiFi.localIP().toString().c_str());

         sipClient = new SipClientT(user, pwd, server_ip, server_port, local_ip);
         bool x = sipClient->init();
         Serial.println("############## SIP ##########");
         Serial.println(x);
    }

#endif
}


SIPModule openknxSIPModule;

#endif