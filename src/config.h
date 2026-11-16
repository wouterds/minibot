#pragma once

#include <Arduino.h>

namespace config
{

// Onboard LED of the LOLIN32 Lite. It lights when the pin is LOW.
constexpr uint8_t STATUS_LED = 22;

// DRV8833 inputs. The A channel drives both left motors, the B channel both right motors.
// None of these pins is driven during boot, so the motors stay still until the firmware runs.
constexpr uint8_t MOTOR_LEFT_IN1 = 32;
constexpr uint8_t MOTOR_LEFT_IN2 = 33;
constexpr uint8_t MOTOR_RIGHT_IN1 = 25;
constexpr uint8_t MOTOR_RIGHT_IN2 = 26;

constexpr uint32_t MOTOR_PWM_FREQ = 20000; // above hearing range
constexpr uint8_t MOTOR_PWM_RES_BITS = 8;

constexpr uint8_t STICK_DEAD_ZONE = 16;
constexpr uint8_t STEER_PERCENT = 70;     // steering authority relative to throttle
constexpr uint32_t LINK_TIMEOUT_MS = 500; // stop when the controller goes quiet for this long

constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

} // namespace config
