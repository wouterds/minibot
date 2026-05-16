#include <Arduino.h>
#include <Ps3Controller.h>

static constexpr uint8_t STATUS_LED = 19;

static constexpr uint8_t LED_TRIANGLE = 17;
static constexpr uint8_t LED_CIRCLE = 33;
static constexpr uint8_t LED_CROSS = 32;
static constexpr uint8_t LED_SQUARE = 25;

static constexpr uint8_t LED_PINS[4] = {LED_TRIANGLE, LED_CIRCLE, LED_CROSS, LED_SQUARE};
static constexpr uint8_t CHANNELS[4] = {0, 1, 2, 3};

static constexpr uint32_t PWM_FREQ = 5000;
static constexpr uint8_t PWM_RES_BITS = 8;
static constexpr uint8_t STICK_DEAD_ZONE = 16;
static constexpr uint8_t RAMP_SCALE = 32;

static constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

static uint8_t brightness = 128;
static bool ledOn[4] = {false, false, false, false};

static void refreshLeds()
{
  for (int i = 0; i < 4; i++)
  {
    ledcWrite(CHANNELS[i], ledOn[i] ? brightness : 0);
  }
}

static void onConnect()
{
  Serial.println("PS3 connected");
  digitalWrite(STATUS_LED, HIGH);
}

static void onDisconnect()
{
  Serial.println("PS3 disconnected");
  digitalWrite(STATUS_LED, LOW);
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

  pinMode(STATUS_LED, OUTPUT);

  for (int i = 0; i < 4; i++)
  {
    ledcSetup(CHANNELS[i], PWM_FREQ, PWM_RES_BITS);
    ledcAttachPin(LED_PINS[i], CHANNELS[i]);
    ledcWrite(CHANNELS[i], 0);
  }

  Ps3.attach(onNotify);
  Ps3.attachOnConnect(onConnect);
  Ps3.attachOnDisconnect(onDisconnect);
  Ps3.begin(HOST_MAC);

  Serial.printf("Waiting for PS3 controller on %s ...\n", HOST_MAC);
}

void loop()
{
  if (!Ps3.isConnected())
  {
    digitalWrite(STATUS_LED, (millis() / 250) % 2);
    delay(50);
    return;
  }

  int8_t y = Ps3.data.analog.stick.ly;
  if (abs(y) > STICK_DEAD_ZONE)
  {
    int delta = -y / RAMP_SCALE;
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
