#include "controller.h"
#include "imu.h"
#include "motors.h"
#include "status_led.h"
#include <Arduino.h>

void setup()
{
  Serial.begin(115200);

  status_led::begin();
  motors::begin();
  imu::begin();
  controller::begin();
}

void loop()
{
  imu::update();
  controller::update();
  status_led::update();
  delay(10);
}
