#pragma once

#include <Arduino.h>

namespace config
{

// Onboard LED of the LOLIN32 Lite. It lights when the pin is LOW.
constexpr uint8_t STATUS_LED = 22;

constexpr uint8_t STICK_DEAD_ZONE = 16;

constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

} // namespace config
