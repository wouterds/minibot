#pragma once

#include <Arduino.h>

namespace status_led
{

enum Mode
{
  WAITING,     // blue, breathing
  CONNECTED,   // the colour of the battery level, or purple on its back; brighter the harder it
               // drives
  LOW_BATTERY, // red, blinking fast
};

void begin();
void set(Mode mode);
// how hard the bot is driving, 0..255
void setLevel(uint8_t level);
void update();

} // namespace status_led
