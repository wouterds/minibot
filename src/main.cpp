#include "config.h"
#include <Arduino.h>
#include <Ps3Controller.h>

static uint8_t brightness = 128;
static bool ledOn[4] = {false, false, false, false};

static void refreshLeds()
{
  for (int i = 0; i < 4; i++)
  {
    ledcWrite(config::LED_CHANNELS[i], ledOn[i] ? brightness : 0);
  }
}

static void onConnect()
{
  Serial.println("PS3 connected");
  digitalWrite(config::STATUS_LED, HIGH);
}

static void onDisconnect()
{
  Serial.println("PS3 disconnected");
  digitalWrite(config::STATUS_LED, LOW);
  for (int i = 0; i < 4; i++) ledOn[i] = false;
  refreshLeds();
}

static void onNotify()
{
  bool changed = false;
  if (Ps3.event.button_down.triangle) { ledOn[0] = !ledOn[0]; changed = true; Serial.println("△"); }
  if (Ps3.event.button_down.circle)   { ledOn[1] = !ledOn[1]; changed = true; Serial.println("○"); }
  if (Ps3.event.button_down.cross)    { ledOn[2] = !ledOn[2]; changed = true; Serial.println("✕"); }
  if (Ps3.event.button_down.square)   { ledOn[3] = !ledOn[3]; changed = true; Serial.println("□"); }
  if (changed) refreshLeds();
}

void setup()
{
  Serial.begin(115200);

  pinMode(config::STATUS_LED, OUTPUT);

  for (int i = 0; i < 4; i++)
  {
    ledcSetup(config::LED_CHANNELS[i], config::PWM_FREQ, config::PWM_RES_BITS);
    ledcAttachPin(config::LED_PINS[i], config::LED_CHANNELS[i]);
    ledcWrite(config::LED_CHANNELS[i], 0);
  }

  Ps3.attach(onNotify);
  Ps3.attachOnConnect(onConnect);
  Ps3.attachOnDisconnect(onDisconnect);
  Ps3.begin(config::HOST_MAC);

  Serial.printf("Waiting for PS3 controller on %s ...\n", config::HOST_MAC);
}

void loop()
{
  if (!Ps3.isConnected())
  {
    digitalWrite(config::STATUS_LED, (millis() / 250) % 2);
    delay(50);
    return;
  }

  int8_t y = Ps3.data.analog.stick.ly;
  if (abs(y) > config::STICK_DEAD_ZONE)
  {
    int delta = -y / config::RAMP_SCALE;
    int newBrightness = constrain((int)brightness + delta, 0, 255);
    if (newBrightness != (int)brightness)
    {
      brightness = (uint8_t)newBrightness;
      refreshLeds();
      Serial.printf("brightness: %u\n", brightness);
    }
  }

  delay(20);
}
