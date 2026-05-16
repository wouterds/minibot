#pragma once

#include <Arduino.h>

namespace status_led
{

void begin();
void setConnected(bool connected);
void blinkWhileWaiting();

} // namespace status_led
