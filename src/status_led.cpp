#include "status_led.h"
#include "battery.h"
#include "config.h"
#include "imu.h"

namespace status_led
{

static const uint8_t RED_CHANNEL = 4;
static const uint8_t GREEN_CHANNEL = 5;
static const uint8_t BLUE_CHANNEL = 6;
static const uint32_t PWM_FREQ = 5000;
static const uint8_t PWM_RES_BITS = 8;

static const uint8_t IDLE_BRIGHTNESS = 40;  // connected and standing still
static const float BATTERY_FULL_MV = 4000;  // green from here up
static const float BATTERY_EMPTY_MV = 3400; // red from here down

static Mode s_mode = WAITING;
static uint8_t s_level = 0;

static void onboard(bool on)
{
  digitalWrite(config::STATUS_LED, on ? LOW : HIGH);
}

static void channel(uint8_t channel, uint8_t value, uint8_t brightness)
{
  const uint8_t duty = value * brightness / 255;
  ledcWrite(channel, config::RGB_COMMON_ANODE ? 255 - duty : duty);
}

static void rgb(uint8_t red, uint8_t green, uint8_t blue, uint8_t brightness)
{
  channel(RED_CHANNEL, red, brightness);
  channel(GREEN_CHANNEL, green, brightness);
  channel(BLUE_CHANNEL, blue, brightness);
}

// Green on a full cell, through yellow, to red on an empty one. Plain green without the divider.
static void battery(uint8_t brightness)
{
  if (!config::BATTERY_SENSE_FITTED) return rgb(0, 255, 0, brightness);

  const float span = BATTERY_FULL_MV - BATTERY_EMPTY_MV;
  const float charge = constrain((battery::millivolts() - BATTERY_EMPTY_MV) / span, 0.0f, 1.0f);
  rgb(255 * min(1.0f, 2 - 2 * charge), 255 * min(1.0f, 2 * charge), 0, brightness);
}

void begin()
{
  pinMode(config::STATUS_LED, OUTPUT);
  onboard(false);

  const uint8_t pins[] = {config::RGB_RED, config::RGB_GREEN, config::RGB_BLUE};
  const uint8_t channels[] = {RED_CHANNEL, GREEN_CHANNEL, BLUE_CHANNEL};
  for (uint8_t i = 0; i < 3; i++)
  {
    ledcSetup(channels[i], PWM_FREQ, PWM_RES_BITS);
    ledcAttachPin(pins[i], channels[i]);
  }
  rgb(0, 0, 0, 0);
}

void set(Mode mode)
{
  s_mode = mode;
}

void setLevel(uint8_t level)
{
  s_level = level;
}

void update()
{
  switch (s_mode)
  {
    case WAITING:
    {
      onboard((millis() / 250) % 2);
      const int phase = (millis() / 6) % 510; // up and down once in three seconds
      rgb(0, 0, 255, abs(phase - 255));
      break;
    }
    case CONNECTED:
    {
      onboard(true);
      const uint8_t brightness = IDLE_BRIGHTNESS + s_level * (255 - IDLE_BRIGHTNESS) / 255;
      if (imu::isFlipped())
        rgb(255, 0, 255, brightness);
      else
        battery(brightness);
      break;
    }
    case LOW_BATTERY:
    {
      const bool on = (millis() / 60) % 2;
      onboard(on);
      rgb(255, 0, 0, on ? 255 : 0);
      break;
    }
  }
}

} // namespace status_led
