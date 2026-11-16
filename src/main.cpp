#include "controller.h"
#include "motors.h"
#include "status_led.h"
#include <Arduino.h>

void setup()
{
  Serial.begin(115200);

  status_led::begin();
  motors::begin();
  controller::begin();
}

void loop()
{
  controller::update();
  status_led::update();
  delay(10);
}
