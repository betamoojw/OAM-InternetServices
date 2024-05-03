#pragma once
#ifdef BETAXML

// BETA
#if ARDUINO_ARCH_ESP32     
#include "knxprodESP32-Beta.h"
#else
#include "knxprodRP2040-Beta.h"
#endif

#else

// DEV
#if ARDUINO_ARCH_ESP32     
#include "knxprodESP32-Dev.h"
#else
#include "knxprodRP2040-Dev.h"
#endif
#endif