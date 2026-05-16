#include <Arduino.h>
#include <Ps3Controller.h>

static constexpr uint8_t STATUS_LED = 19;

static constexpr uint8_t LED_TRIANGLE = 17;
static constexpr uint8_t LED_CIRCLE = 33;
static constexpr uint8_t LED_CROSS = 32;
static constexpr uint8_t LED_SQUARE = 25;

static constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

static void allButtonLeds(uint8_t value)
{
  digitalWrite(LED_TRIANGLE, value);
  digitalWrite(LED_CIRCLE, value);
  digitalWrite(LED_CROSS, value);
  digitalWrite(LED_SQUARE, value);
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
  allButtonLeds(LOW);
}

static void onNotify()
{
  digitalWrite(LED_TRIANGLE, Ps3.data.button.triangle);
  digitalWrite(LED_CIRCLE, Ps3.data.button.circle);
  digitalWrite(LED_CROSS, Ps3.data.button.cross);
  digitalWrite(LED_SQUARE, Ps3.data.button.square);

  if (Ps3.event.button_down.triangle) Serial.println("△");
  if (Ps3.event.button_down.circle) Serial.println("○");
  if (Ps3.event.button_down.cross) Serial.println("✕");
  if (Ps3.event.button_down.square) Serial.println("□");
}

void setup()
{
  Serial.begin(115200);

  pinMode(STATUS_LED, OUTPUT);
  pinMode(LED_TRIANGLE, OUTPUT);
  pinMode(LED_CIRCLE, OUTPUT);
  pinMode(LED_CROSS, OUTPUT);
  pinMode(LED_SQUARE, OUTPUT);

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
  }
}
