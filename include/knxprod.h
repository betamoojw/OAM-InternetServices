#pragma once
#ifdef BETAXML

#if ARDUINO_ARCH_ESP32     
#include "knxprodESP32-Beta.h"
#else
#include "knxprodRP2040-Beta.h"
#endif


#else

#if ARDUINO_ARCH_ESP32     
#include "knxprodESP32.h"
#else
#include "knxprodRP2040.h"
#endif

#endif