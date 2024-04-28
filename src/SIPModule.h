#pragma once
#ifdef ARDUINO_ARCH_ESP32
#include "OpenKNX.h"

class SIPModule : public OpenKNX::Module
{
  public:
    SIPModule();

    void setup(bool configured) override;
    void loop() override;

    const std::string name() override;
    const std::string version() override;
    void showInformations() override;
    void showHelp() override;
    bool connected();
    bool processCommand(const std::string cmd, bool diagnoseKo) override;

};

extern SIPModule openknxSIPModule;

#endif