#include "controller.h"
#include "config.h"
#include "status_led.h"
#include <Arduino.h>
#include <Ps3Controller.h>

namespace controller
{

static void onConnect()
{
  Serial.println("PS3 connected");
  Ps3.setPlayer(1);
  status_led::set(status_led::CONNECTED);
}

static void onDisconnect()
{
  Serial.println("PS3 disconnected");
  status_led::set(status_led::WAITING);
}

void begin()
{
  Ps3.attachOnConnect(onConnect);
  Ps3.attachOnDisconnect(onDisconnect);
  Ps3.begin(config::HOST_MAC);

  Serial.printf("Waiting for PS3 controller on %s ...\n", config::HOST_MAC);
}

void update()
{
}

} // namespace controller
