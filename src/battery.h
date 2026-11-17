#pragma once

#include <Arduino.h>

namespace battery
{

void begin();
// loaded: the motors are running, which pulls the voltage down
void update(bool loaded);

// True once the cell has sagged below the cutoff. Stays true until the next power cycle.
// Always false when no voltage divider is fitted.
bool isLow();

// Smoothed cell voltage. 0 when no voltage divider is fitted.
float millivolts();

} // namespace battery
