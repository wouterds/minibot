#pragma once

#include <Arduino.h>

namespace leds
{

enum Index : uint8_t
{
  TRIANGLE = 0,
  CIRCLE = 1,
  CROSS = 2,
  SQUARE = 3,
};

void begin();
void toggle(Index idx);
void setBrightness(uint8_t value);
uint8_t brightness();
void allOff();

} // namespace leds
