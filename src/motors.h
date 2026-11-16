#pragma once

#include <Arduino.h>

namespace motors
{

void begin();

// Signed speed per side, -255 (full reverse) to 255 (full forward).
void drive(int16_t left, int16_t right);
void stop();
bool isStopped();

// Puts the driver to sleep and keeps it there while the ESP32 sleeps.
void sleep();

} // namespace motors
