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

// MPU-6050 on I2C. GPIO 21, the usual SDA, is not broken out on the LOLIN32 Lite.
constexpr uint8_t IMU_SDA = 19;
constexpr uint8_t IMU_SCL = 23;
constexpr int8_t IMU_Z_SIGN = 1;       // -1 when the IMU board is mounted component side down
constexpr uint32_t FLIP_HOLD_MS = 300; // a new orientation has to last this long to count

// Battery voltage through a 100k/100k divider. Set BATTERY_SENSE_FITTED once it is soldered in;
// the pin floats without it and would read as an empty cell.
constexpr bool BATTERY_SENSE_FITTED = false;
constexpr uint8_t BATTERY_SENSE = 35;
constexpr float BATTERY_DIVIDER = 2.0f;       // correct this against a multimeter
constexpr float BATTERY_LOW_MV = 3300;        // the protection board only cuts at 2.4 V, too late
constexpr float BATTERY_LOW_LOADED_MV = 3000; // the motors pull the voltage down while they run
constexpr uint32_t BATTERY_LOW_HOLD_MS = 3000;
constexpr uint32_t BATTERY_LOW_SLEEP_MS = 30000; // blink this long, then power down

constexpr uint8_t STICK_DEAD_ZONE = 16;
constexpr uint8_t STEER_PERCENT = 70;     // steering authority relative to throttle
constexpr uint32_t LINK_TIMEOUT_MS = 500; // stop when the controller goes quiet for this long

constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

} // namespace config
