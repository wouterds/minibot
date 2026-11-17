#include "battery.h"
#include "buzzer.h"
#include "controller.h"
#include "imu.h"
#include "motors.h"
#include "status_led.h"
#include <Arduino.h>

void setup()
{
  motors::begin(); // first, so the driver inputs are defined as early as possible
  Serial.begin(115200);

  status_led::begin();
  buzzer::begin();
  imu::begin();
  battery::begin();
  controller::begin();
}

void loop()
{
  imu::update();
  controller::update();
  battery::update(!motors::isStopped());
  status_led::update();
  buzzer::update();
  delay(10);
}
