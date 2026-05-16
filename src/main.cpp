#include <Arduino.h>

static constexpr uint8_t LED_PIN = 19;

void setup()
{
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
}

void loop()
{
  static uint32_t count = 0;
  digitalWrite(LED_PIN, HIGH);
  Serial.printf("tick %lu\n", count++);
  delay(500);
  digitalWrite(LED_PIN, LOW);
  delay(500);
}
