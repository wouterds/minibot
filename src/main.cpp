#include <Arduino.h>
#include <Ps3Controller.h>

static constexpr uint8_t LED_PIN = 19;
static constexpr const char *HOST_MAC = "24:6f:28:b1:f8:b6";

static void onConnect()
{
  Serial.println("PS3 connected");
  digitalWrite(LED_PIN, HIGH);
}

static void onDisconnect()
{
  Serial.println("PS3 disconnected");
  digitalWrite(LED_PIN, LOW);
}

static void onNotify()
{
  if (Ps3.event.button_down.cross) Serial.println("X");
  if (Ps3.event.button_down.circle) Serial.println("O");
  if (Ps3.event.button_down.triangle) Serial.println("△");
  if (Ps3.event.button_down.square) Serial.println("□");

  if (Ps3.event.button_down.up) Serial.println("up");
  if (Ps3.event.button_down.down) Serial.println("down");
  if (Ps3.event.button_down.left) Serial.println("left");
  if (Ps3.event.button_down.right) Serial.println("right");

  if (Ps3.event.analog_changed.stick.lx || Ps3.event.analog_changed.stick.ly)
  {
    Serial.printf("L stick: %4d, %4d\n", Ps3.data.analog.stick.lx, Ps3.data.analog.stick.ly);
  }
  if (Ps3.event.analog_changed.stick.rx || Ps3.event.analog_changed.stick.ry)
  {
    Serial.printf("R stick: %4d, %4d\n", Ps3.data.analog.stick.rx, Ps3.data.analog.stick.ry);
  }
}

void setup()
{
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);

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
    digitalWrite(LED_PIN, (millis() / 250) % 2);
  }
}
