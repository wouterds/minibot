#include "controller.h"
#include "config.h"
#include "leds.h"
#include "status_led.h"
#include <Arduino.h>
#include <Ps3Controller.h>

namespace controller
{

static void onConnect()
{
  Serial.println("PS3 connected");
  status_led::setConnected(true);
}

static void onDisconnect()
{
  Serial.println("PS3 disconnected");
  status_led::setConnected(false);
  leds::allOff();
}

static void onNotify()
{
  if (Ps3.event.button_down.triangle) { leds::toggle(leds::TRIANGLE); Serial.println("△"); }
  if (Ps3.event.button_down.circle)   { leds::toggle(leds::CIRCLE);   Serial.println("○"); }
  if (Ps3.event.button_down.cross)    { leds::toggle(leds::CROSS);    Serial.println("✕"); }
  if (Ps3.event.button_down.square)   { leds::toggle(leds::SQUARE);   Serial.println("□"); }
}

void begin()
{
  Ps3.attach(onNotify);
  Ps3.attachOnConnect(onConnect);
  Ps3.attachOnDisconnect(onDisconnect);
  Ps3.begin(config::HOST_MAC);

  Serial.printf("Waiting for PS3 controller on %s ...\n", config::HOST_MAC);
}

void update()
{
  if (!Ps3.isConnected())
  {
    status_led::blinkWhileWaiting();
    delay(50);
    return;
  }

  int8_t y = Ps3.data.analog.stick.ly;
  if (abs(y) > config::STICK_DEAD_ZONE)
  {
    int delta = -y / config::RAMP_SCALE;
    int newBrightness = constrain((int)leds::brightness() + delta, 0, 255);
    if (newBrightness != (int)leds::brightness())
    {
      leds::setBrightness((uint8_t)newBrightness);
      Serial.printf("brightness: %u\n", newBrightness);
    }
  }

  delay(20);
}

} // namespace controller
