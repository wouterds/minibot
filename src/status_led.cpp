#include "status_led.h"
#include "config.h"

namespace status_led
{

static Mode s_mode = WAITING;

static void write(bool on)
{
  digitalWrite(config::STATUS_LED, on ? LOW : HIGH);
}

void begin()
{
  pinMode(config::STATUS_LED, OUTPUT);
  write(false);
}

void set(Mode mode)
{
  s_mode = mode;
}

void update()
{
  switch (s_mode)
  {
    case WAITING:
      write((millis() / 250) % 2);
      break;
    case CONNECTED:
      write(true);
      break;
    case LOW_BATTERY:
      write((millis() / 60) % 2);
      break;
  }
}

} // namespace status_led
