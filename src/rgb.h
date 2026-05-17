#pragma once

#include <Arduino.h>

namespace rgb
{

enum Preset : uint8_t
{
  GREEN = 0,
  RED = 1,
  PINK = 2,
  BLUE = 3,
  PRESET_COUNT = 4,
};

void begin();
void activate(Preset p);
void setBrightness(uint8_t value);
uint8_t brightness();
void adjustPreset(Preset p, int delta);
void off();

} // namespace rgb
