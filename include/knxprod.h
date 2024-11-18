#pragma once
#ifdef BETAXML

// BETA
#if KNX_IP_LAN
#include "knxprodRP2040-Dev.h"
#elif ARDUINO_ARCH_ESP32      
#include "knxprodESP32-Beta.h"
#else
#include "knxprodRP2040-Beta.h"
#endif

#else

// DEV
#if KNX_IP_LAN
#include "knxprodRP2040-Dev.h"
#elif ARDUINO_ARCH_ESP32     
#include "knxprodESP32-Dev.h"
#else
#include "knxprodRP2040-Dev.h"
#endif
#endif