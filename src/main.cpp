#include "controller.h"
#include "leds.h"
#include "status_led.h"
#include <Arduino.h>

void setup()
{
  Serial.begin(115200);

  status_led::begin();
  leds::begin();
  controller::begin();
}

void loop()
{
  controller::update();
}
