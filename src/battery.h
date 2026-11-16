#pragma once

#include <Arduino.h>

namespace battery
{

void begin();
void update();

// True once the cell has sagged below the cutoff. Stays true until the next power cycle.
// Always false when no voltage divider is wired up.
bool isLow();

} // namespace battery
