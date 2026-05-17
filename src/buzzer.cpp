#include "buzzer.h"
#include "config.h"
#include <Arduino.h>

namespace buzzer
{

static bool s_on = false;

void begin()
{
  ledcSetup(config::CH_BUZZER, config::BUZZER_FREQ, config::PWM_RES_BITS);
  ledcAttachPin(config::BUZZER, config::CH_BUZZER);
  ledcWrite(config::CH_BUZZER, 0);
}

void on()
{
  if (s_on) return;
  s_on = true;
  ledcWrite(config::CH_BUZZER, 128); // 50% duty cycle
}

void off()
{
  if (!s_on) return;
  s_on = false;
  ledcWrite(config::CH_BUZZER, 0);
}

} // namespace buzzer
