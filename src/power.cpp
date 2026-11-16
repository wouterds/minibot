#include "power.h"
#include "config.h"
#include "imu.h"
#include "motors.h"
#include <Arduino.h>
#include <esp_sleep.h>

namespace power
{

void sleep()
{
  motors::sleep();

  if (imu::armWake())
  {
    Serial.println("Sleeping, move the bot to wake it");
    esp_sleep_enable_ext0_wakeup((gpio_num_t)config::IMU_INT, 1);
  }
  else
  {
    Serial.println("Sleeping, no IMU to wake it: reset to start again");
  }

  Serial.flush();
  esp_deep_sleep_start();
}

} // namespace power
