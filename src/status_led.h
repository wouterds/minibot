#pragma once

namespace status_led
{

enum Mode
{
  WAITING,
  CONNECTED,
};

void begin();
void set(Mode mode);
void update();

} // namespace status_led
