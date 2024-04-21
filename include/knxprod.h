#pragma once

#if ARDUINO_ARCH_ESP32     
#include "knxprodESP32.h"
#else
#include "knxprodRP2040.h"
#endif