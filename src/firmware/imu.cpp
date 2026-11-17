#include "imu.h"
#include "config.h"
#include <Arduino.h>
#include <Wire.h>

namespace imu
{

// MPU-6050 registers
static const int ADDRESS = 0x68;
static const uint8_t REG_CONFIG = 0x1A;
static const uint8_t REG_ACCEL_CONFIG = 0x1C;
static const uint8_t REG_MOT_THR = 0x1F;
static const uint8_t REG_MOT_DUR = 0x20;
static const uint8_t REG_INT_PIN_CFG = 0x37;
static const uint8_t REG_INT_ENABLE = 0x38;
static const uint8_t REG_INT_STATUS = 0x3A;
static const uint8_t REG_ACCEL_ZOUT_H = 0x3F;
static const uint8_t REG_SIGNAL_PATH_RESET = 0x68;
static const uint8_t REG_MOT_DETECT_CTRL = 0x69;
static const uint8_t REG_PWR_MGMT_1 = 0x6B;
static const uint8_t REG_PWR_MGMT_2 = 0x6C;

static const int16_t ONE_G = 16384; // at the default ±2 g range

static bool s_present = false;
static bool s_flipped = false;
static uint32_t s_agreedAt = 0;

static bool writeRegister(uint8_t reg, uint8_t value)
{
  Wire.beginTransmission(ADDRESS);
  Wire.write(reg);
  Wire.write(value);
  return Wire.endTransmission() == 0;
}

static bool readAccelZ(int16_t &z)
{
  Wire.beginTransmission(ADDRESS);
  Wire.write(REG_ACCEL_ZOUT_H);
  Wire.endTransmission(false); // only queues the address, errors show up in the read
  if (Wire.requestFrom(ADDRESS, 2) != 2) return false;

  const uint8_t high = Wire.read();
  const uint8_t low = Wire.read();
  z = (int16_t)((high << 8) | low) * config::IMU_Z_SIGN;
  return true;
}

void begin()
{
  Wire.begin(config::IMU_SDA, config::IMU_SCL, 400000);
  Wire.setTimeOut(10);

  // The chip keeps its settings while the ESP32 sleeps, so undo what armWake() set: everything
  // awake, no interrupt, no high-pass filter. Then turn on the 5 Hz low-pass, so motor vibration
  // and bumps do not reach the orientation check.
  s_present = writeRegister(REG_PWR_MGMT_1, 0x00) && writeRegister(REG_PWR_MGMT_2, 0x00) &&
              writeRegister(REG_INT_ENABLE, 0x00) && writeRegister(REG_ACCEL_CONFIG, 0x00) &&
              writeRegister(REG_CONFIG, 0x06);
  Serial.println(s_present ? "IMU ready" : "IMU not found, flip detection and wake-up are off");
}

void update()
{
  if (!s_present) return;

  int16_t z;
  if (!readAccelZ(z)) return;

  // Between the two thresholds (on its side, in free fall) the last known orientation stands.
  const int16_t threshold = ONE_G / 2;
  const bool flipped = z < -threshold ? true : z > threshold ? false : s_flipped;

  const uint32_t now = millis();
  if (flipped == s_flipped)
  {
    s_agreedAt = now;
    return;
  }

  if (now - s_agreedAt >= config::FLIP_HOLD_MS)
  {
    s_flipped = flipped;
    s_agreedAt = now;
    Serial.println(s_flipped ? "Flipped: on its back" : "Flipped: upright");
  }
}

bool isFlipped()
{
  return s_flipped;
}

bool isPresent()
{
  return s_present;
}

// Motion detection on the accelerometer alone: gyros and thermometer off, which brings the chip
// down to about 0.5 mA. Not its cycle mode, which draws less but is reported not to fire the
// motion interrupt.
bool armWake()
{
  if (!s_present) return false;

  const bool armed = writeRegister(REG_PWR_MGMT_1, 0x08) &&        // awake, thermometer off
                     writeRegister(REG_PWR_MGMT_2, 0x07) &&        // gyros on standby
                     writeRegister(REG_SIGNAL_PATH_RESET, 0x07) && // clear the filters
                     writeRegister(REG_CONFIG, 0x00) &&            // no low-pass, a nudge is short
                     writeRegister(REG_INT_PIN_CFG, 0x20) &&       // INT stays HIGH until read
                     writeRegister(REG_ACCEL_CONFIG, 0x01) && // 5 Hz high-pass: gravity drops out
                     writeRegister(REG_MOT_THR, config::WAKE_THRESHOLD) &&
                     writeRegister(REG_MOT_DUR, config::WAKE_DURATION_MS) &&
                     writeRegister(REG_MOT_DETECT_CTRL, 0x15) &&
                     writeRegister(REG_INT_ENABLE, 0x40); // motion only
  if (!armed) return false;

  // Reading the status clears an interrupt left over from before, which would wake us at once.
  delay(50);
  Wire.beginTransmission(ADDRESS);
  Wire.write(REG_INT_STATUS);
  Wire.endTransmission(false);
  Wire.requestFrom(ADDRESS, 1);
  Wire.read();
  return true;
}

} // namespace imu
