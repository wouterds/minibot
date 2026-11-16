#include "controller.h"
#include "config.h"
#include "motors.h"
#include "status_led.h"
#include <Arduino.h>
#include <Ps3Controller.h>

namespace controller
{

static volatile uint32_t s_lastPacketAt = 0;

static void onConnect()
{
  Serial.println("PS3 connected");
  s_lastPacketAt = millis();
  status_led::set(status_led::CONNECTED);
}

static void onDisconnect()
{
  Serial.println("PS3 disconnected");
  status_led::set(status_led::WAITING);
}

static void onNotify()
{
  s_lastPacketAt = millis();
}

// Stick axis (-128..127) to a signed speed (-255..255): dead zone around the centre, then a squared
// curve so small deflections give fine control.
static int16_t shape(int8_t raw)
{
  const int magnitude = abs((int)raw);
  if (magnitude <= config::STICK_DEAD_ZONE) return 0;

  const float x = min(1.0f, (magnitude - config::STICK_DEAD_ZONE) / (127.0f - config::STICK_DEAD_ZONE));
  const int16_t speed = lroundf(x * x * 255.0f);
  return raw < 0 ? -speed : speed;
}

// The controller streams reports continuously, so a gap means the link is gone even though the
// Bluetooth stack has not noticed yet. Without this the bot keeps driving on the last stick position.
static bool linkAlive()
{
  return Ps3.isConnected() && millis() - s_lastPacketAt < config::LINK_TIMEOUT_MS;
}

void begin()
{
  Ps3.attach(onNotify);
  Ps3.attachOnConnect(onConnect);
  Ps3.attachOnDisconnect(onDisconnect);
  Ps3.begin(config::HOST_MAC);

  Serial.printf("Waiting for PS3 controller on %s ...\n", config::HOST_MAC);
}

void update()
{
  if (!linkAlive())
  {
    motors::stop();
    return;
  }

  // Left stick up/down is throttle (up reads negative), right stick left/right steers.
  const int throttle = -shape(Ps3.data.analog.stick.ly);
  const int steer = shape(Ps3.data.analog.stick.rx) * config::STEER_PERCENT / 100;

  int left = throttle + steer;
  int right = throttle - steer;

  // Scale both sides together when one exceeds full speed, so the turn keeps its shape.
  const int peak = max(abs(left), abs(right));
  if (peak > 255)
  {
    left = left * 255 / peak;
    right = right * 255 / peak;
  }

  motors::drive(left, right);
}

} // namespace controller
