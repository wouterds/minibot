#pragma once

#include <Arduino.h>

namespace config
{

constexpr uint8_t STATUS_LED = 19;

constexpr uint8_t LED_TRIANGLE = 17;
constexpr uint8_t LED_CIRCLE = 33;
constexpr uint8_t LED_CROSS = 32;
constexpr uint8_t LED_SQUARE = 25;

constexpr uint8_t LED_PINS[4] = {LED_TRIANGLE, LED_CIRCLE, LED_CROSS, LED_SQUARE};
constexpr uint8_t LED_CHANNELS[4] = {0, 1, 2, 3};

constexpr uint32_t PWM_FREQ = 5000;
constexpr uint8_t PWM_RES_BITS = 8;
constexpr uint8_t STICK_DEAD_ZONE = 16;
constexpr uint8_t RAMP_SCALE = 32;

constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

} // namespace config
