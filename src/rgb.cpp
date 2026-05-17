#include "rgb.h"
#include "config.h"

namespace rgb
{

struct Color
{
  uint8_t r;
  uint8_t g;
  uint8_t b;
};

static Color s_presets[4] = {
    {0, 255, 0},     // GREEN — Triangle
    {255, 0, 0},     // RED — Circle
    {255, 105, 180}, // PINK — Square
    {0, 0, 255},     // BLUE — Cross
};

static int8_t s_active = -1;
static uint8_t s_brightness = 255;

static void write(Color c)
{
  ledcWrite(config::CH_R, (c.r * s_brightness) / 255);
  ledcWrite(config::CH_G, (c.g * s_brightness) / 255);
  ledcWrite(config::CH_B, (c.b * s_brightness) / 255);
}

void begin()
{
  ledcSetup(config::CH_R, config::PWM_FREQ, config::PWM_RES_BITS);
  ledcAttachPin(config::RGB_R, config::CH_R);
  ledcSetup(config::CH_G, config::PWM_FREQ, config::PWM_RES_BITS);
  ledcAttachPin(config::RGB_G, config::CH_G);
  ledcSetup(config::CH_B, config::PWM_FREQ, config::PWM_RES_BITS);
  ledcAttachPin(config::RGB_B, config::CH_B);
  write({0, 0, 0});
}

void activate(Preset p)
{
  if (s_active == (int8_t)p)
  {
    off();
    return;
  }
  s_active = (int8_t)p;
  write(s_presets[p]);
}

void setBrightness(uint8_t value)
{
  if (s_brightness == value) return;
  s_brightness = value;
  if (s_active >= 0) write(s_presets[s_active]);
}

uint8_t brightness()
{
  return s_brightness;
}

static uint8_t clampU8(int v)
{
  return (uint8_t)constrain(v, 0, 255);
}

void adjustPreset(Preset p, int delta)
{
  Color &c = s_presets[p];
  switch (p)
  {
    case GREEN: c.g = clampU8((int)c.g + delta); break;
    case RED:   c.r = clampU8((int)c.r + delta); break;
    case BLUE:  c.b = clampU8((int)c.b + delta); break;
    case PINK:
      c.r = clampU8((int)c.r + delta);
      c.b = clampU8((int)c.b + delta);
      break;
    default: return;
  }
  if (s_active == (int8_t)p) write(c);
}

void off()
{
  s_active = -1;
  write({0, 0, 0});
}

} // namespace rgb
