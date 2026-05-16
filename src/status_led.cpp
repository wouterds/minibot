#include "status_led.h"
#include "config.h"

namespace status_led
{

static bool s_connected = false;

void begin()
{
  pinMode(config::STATUS_LED, OUTPUT);
  digitalWrite(config::STATUS_LED, LOW);
}

void setConnected(bool connected)
{
  s_connected = connected;
  digitalWrite(config::STATUS_LED, connected ? HIGH : LOW);
}

void blinkWhileWaiting()
{
  if (!s_connected)
  {
    digitalWrite(config::STATUS_LED, (millis() / 250) % 2);
  }
}

} // namespace status_led
