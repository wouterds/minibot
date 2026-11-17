#include "battery.h"
#include "config.h"

namespace battery
{

static const uint32_t SAMPLE_INTERVAL_MS = 100;

static bool s_low = false;
static float s_millivolts = 0;
static uint32_t s_sampledAt = 0;
static uint32_t s_healthyAt = 0;

static float read()
{
  return analogReadMilliVolts(config::BATTERY_SENSE) * config::BATTERY_DIVIDER;
}

void begin()
{
  if (!config::BATTERY_SENSE_FITTED)
  {
    Serial.println("Battery sense not fitted, low-voltage cutoff is off");
    return;
  }

  analogSetPinAttenuation(config::BATTERY_SENSE, ADC_11db);
  s_millivolts = read();
  Serial.printf("Battery: %.2f V\n", s_millivolts / 1000);
}

void update(bool loaded)
{
  if (!config::BATTERY_SENSE_FITTED || s_low) return;

  const uint32_t now = millis();
  if (now - s_sampledAt < SAMPLE_INTERVAL_MS) return;
  s_sampledAt = now;

  s_millivolts += (read() - s_millivolts) * 0.1f;

  // Only a lasting dip counts: a motor starting pulls the voltage down for a moment.
  const float threshold = loaded ? config::BATTERY_LOW_LOADED_MV : config::BATTERY_LOW_MV;
  if (s_millivolts > threshold)
  {
    s_healthyAt = now;
  }
  else if (now - s_healthyAt >= config::BATTERY_LOW_HOLD_MS)
  {
    s_low = true;
    Serial.printf("Battery low: %.2f V, motors disabled\n", s_millivolts / 1000);
  }
}

bool isLow()
{
  return s_low;
}

float millivolts()
{
  return s_millivolts;
}

} // namespace battery
