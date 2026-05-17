#pragma once

#include <Arduino.h>

namespace config
{

constexpr uint8_t STATUS_LED = 19;

constexpr uint8_t RGB_R = 25;
constexpr uint8_t RGB_G = 26;
constexpr uint8_t RGB_B = 27;

constexpr uint8_t BUZZER = 32;

constexpr uint8_t CH_R = 0;
constexpr uint8_t CH_G = 1;
constexpr uint8_t CH_B = 2;
constexpr uint8_t CH_BUZZER = 3;

constexpr uint32_t PWM_FREQ = 5000;
constexpr uint32_t BUZZER_FREQ = 1000;
constexpr uint8_t PWM_RES_BITS = 8;

constexpr uint8_t STICK_DEAD_ZONE = 16;
constexpr uint8_t RAMP_SCALE = 32;

constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

} // namespace config
