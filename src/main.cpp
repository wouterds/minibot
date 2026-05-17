#include "buzzer.h"
#include "controller.h"
#include "rgb.h"
#include "status_led.h"
#include <Arduino.h>

void setup()
{
  Serial.begin(115200);

  status_led::begin();
  rgb::begin();
  buzzer::begin();
  controller::begin();
}

void loop()
{
  controller::update();
}
