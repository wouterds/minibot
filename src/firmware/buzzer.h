#pragma once

#include <Arduino.h>

namespace buzzer
{

void begin();
// Queues this many short beeps.
void beep(uint8_t count);
// Sounds for as long as it is held on.
void horn(bool on);
void update();

} // namespace buzzer
