#include "buzzer.h"
#include "config.h"

namespace buzzer
{

static const uint8_t TONE_CHANNEL = 8; // on a timer of its own, away from the motors and the LED
static const uint32_t BEEP_MS = 60;
static const uint32_t GAP_MS = 80;

static uint8_t s_beeps = 0;
static uint32_t s_beepAt = 0;
static bool s_horn = false;
static bool s_on = false;

static void write(bool on)
{
  if (on == s_on) return;
  s_on = on;

  if (config::BUZZER_ACTIVE)
    digitalWrite(config::BUZZER, on ? HIGH : LOW);
  else
    ledcWriteTone(TONE_CHANNEL, on ? config::BUZZER_TONE_HZ : 0);
}

void begin()
{
  if (config::BUZZER_ACTIVE)
  {
    pinMode(config::BUZZER, OUTPUT);
    digitalWrite(config::BUZZER, LOW);
  }
  else
  {
    ledcSetup(TONE_CHANNEL, config::BUZZER_TONE_HZ, 10);
    ledcAttachPin(config::BUZZER, TONE_CHANNEL);
    ledcWriteTone(TONE_CHANNEL, 0);
  }
}

void beep(uint8_t count)
{
  if (s_beeps == 0) s_beepAt = millis();
  s_beeps += count;
}

void horn(bool on)
{
  s_horn = on;
}

void update()
{
  bool beeping = false;
  if (s_beeps > 0)
  {
    const uint32_t elapsed = millis() - s_beepAt;
    beeping = elapsed < BEEP_MS;
    if (elapsed >= BEEP_MS + GAP_MS)
    {
      s_beeps--;
      s_beepAt = millis();
    }
  }
  write(s_horn || beeping);
}

} // namespace buzzer
