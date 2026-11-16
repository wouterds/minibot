#include "imu.h"
#include "config.h"
#include <Arduino.h>
#include <Wire.h>

namespace imu
{

// MPU-6050 registers
static const int ADDRESS = 0x68;
static const uint8_t REG_CONFIG = 0x1A;
static const uint8_t REG_ACCEL_ZOUT_H = 0x3F;
static const uint8_t REG_PWR_MGMT_1 = 0x6B;

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
  if (Wire.endTransmission(false) != 0) return false;
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

  // The chip boots asleep. Wake it, then turn on its 5 Hz low-pass so motor vibration and bumps
  // do not reach the orientation check.
  s_present = writeRegister(REG_PWR_MGMT_1, 0x00) && writeRegister(REG_CONFIG, 0x06);
  Serial.println(s_present ? "IMU ready" : "IMU not found, flip detection is off");
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

} // namespace imu
