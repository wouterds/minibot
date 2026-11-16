#include "battery.h"
#include "config.h"

namespace battery
{

static const uint32_t SAMPLE_INTERVAL_MS = 100;

static bool s_present = false;
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
  analogSetPinAttenuation(config::BATTERY_SENSE, ADC_11db);
  s_millivolts = read();

  // Without the divider the pin reads close to zero, which must not count as an empty cell.
  s_present = s_millivolts > config::BATTERY_PRESENT_MV;
  if (s_present)
  {
    Serial.printf("Battery: %.2f V\n", s_millivolts / 1000);
  }
  else
  {
    Serial.println("Battery sense not wired, low-voltage cutoff is off");
  }
}

void update()
{
  if (!s_present || s_low) return;

  const uint32_t now = millis();
  if (now - s_sampledAt < SAMPLE_INTERVAL_MS) return;
  s_sampledAt = now;

  s_millivolts += (read() - s_millivolts) * 0.1f;

  // Motor load pulls the voltage down for a moment, so only a lasting dip counts.
  if (s_millivolts > config::BATTERY_LOW_MV)
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

} // namespace battery
