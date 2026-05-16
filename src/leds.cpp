#include "leds.h"
#include "config.h"

namespace leds
{

static bool s_state[4] = {false, false, false, false};
static uint8_t s_brightness = 128;

static void refresh()
{
  for (int i = 0; i < 4; i++)
  {
    ledcWrite(config::LED_CHANNELS[i], s_state[i] ? s_brightness : 0);
  }
}

void begin()
{
  for (int i = 0; i < 4; i++)
  {
    ledcSetup(config::LED_CHANNELS[i], config::PWM_FREQ, config::PWM_RES_BITS);
    ledcAttachPin(config::LED_PINS[i], config::LED_CHANNELS[i]);
    ledcWrite(config::LED_CHANNELS[i], 0);
  }
}

void toggle(Index idx)
{
  s_state[idx] = !s_state[idx];
  refresh();
}

void setBrightness(uint8_t value)
{
  if (s_brightness == value) return;
  s_brightness = value;
  refresh();
}

uint8_t brightness()
{
  return s_brightness;
}

void allOff()
{
  for (int i = 0; i < 4; i++) s_state[i] = false;
  refresh();
}

} // namespace leds
