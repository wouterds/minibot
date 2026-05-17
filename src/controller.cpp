#include "controller.h"
#include "buzzer.h"
#include "config.h"
#include "rgb.h"
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
  rgb::off();
  buzzer::off();
}

static void onNotify()
{
  // Preset selection — sets the RGB output to that colour.
  if (Ps3.event.button_down.triangle)
  {
    rgb::activate(rgb::GREEN);
    Serial.println("△ green");
  }
  if (Ps3.event.button_down.circle)
  {
    rgb::activate(rgb::RED);
    Serial.println("○ red");
  }
  if (Ps3.event.button_down.square)
  {
    rgb::activate(rgb::PINK);
    Serial.println("□ pink");
  }
  if (Ps3.event.button_down.cross)
  {
    rgb::activate(rgb::BLUE);
    Serial.println("✕ blue");
  }

  // Buzzer while any shoulder button is held.
  const bool shoulder = Ps3.data.button.l1 || Ps3.data.button.l2 || Ps3.data.button.r1 ||
                        Ps3.data.button.r2;
  if (shoulder)
  {
    buzzer::on();
  }
  else
  {
    buzzer::off();
  }
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

  // Right stick Y → global brightness scale (up = brighter)
  const int8_t ry = Ps3.data.analog.stick.ry;
  if (abs(ry) > config::STICK_DEAD_ZONE)
  {
    const int delta = -ry / config::RAMP_SCALE;
    const int next = constrain((int)rgb::brightness() + delta, 0, 255);
    if (next != (int)rgb::brightness())
    {
      rgb::setBrightness((uint8_t)next);
    }
  }

  // Left stick Y + held face button → tweak that preset's channels
  const int8_t ly = Ps3.data.analog.stick.ly;
  if (abs(ly) > config::STICK_DEAD_ZONE)
  {
    const int delta = -ly / config::RAMP_SCALE;
    if (Ps3.data.button.triangle) rgb::adjustPreset(rgb::GREEN, delta);
    if (Ps3.data.button.circle)   rgb::adjustPreset(rgb::RED, delta);
    if (Ps3.data.button.square)   rgb::adjustPreset(rgb::PINK, delta);
    if (Ps3.data.button.cross)    rgb::adjustPreset(rgb::BLUE, delta);
  }

  delay(20);
}

} // namespace controller
