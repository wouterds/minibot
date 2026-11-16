#include "controller.h"
#include "battery.h"
#include "config.h"
#include "imu.h"
#include "motors.h"
#include "status_led.h"
#include <Arduino.h>
#include <Ps3Controller.h>
#include <esp_sleep.h>

namespace controller
{

static volatile uint32_t s_lastPacketAt = 0;
static uint32_t s_lowSince = 0;
static int s_left = 0;
static int s_right = 0;

static void onConnect()
{
  Serial.println("PS3 connected");
  s_lastPacketAt = millis();
}

static void onNotify()
{
  // The library lights the controller's player LED on the first connection only.
  if (millis() - s_lastPacketAt >= config::LINK_TIMEOUT_MS) Ps3.setPlayer(1);
  s_lastPacketAt = millis();
}

// Stick axis (-128..127) to a signed speed (-255..255): dead zone around the centre, then a squared
// curve so small deflections give fine control.
static int16_t shape(int8_t raw)
{
  const int magnitude = abs((int)raw);
  if (magnitude <= config::STICK_DEAD_ZONE) return 0;

  const float x =
      min(1.0f, (magnitude - config::STICK_DEAD_ZONE) / (127.0f - config::STICK_DEAD_ZONE));
  const int16_t speed = lroundf(x * x * 255.0f);
  return raw < 0 ? -speed : speed;
}

// The controller streams reports continuously, so a gap means the link is gone. The library
// never reports a disconnect, which makes this the only way to tell.
static bool linkAlive()
{
  const uint32_t last = s_lastPacketAt; // before millis(), or a packet in between reads as ancient
  return Ps3.isConnected() && millis() - last < config::LINK_TIMEOUT_MS;
}

static void halt()
{
  s_left = 0;
  s_right = 0;
  motors::stop();
}

static int approach(int current, int target)
{
  return current + constrain(target - current, -config::SLEW_STEP, config::SLEW_STEP);
}

void begin()
{
  Ps3.attach(onNotify);
  Ps3.attachOnConnect(onConnect);
  Ps3.begin(config::HOST_MAC);

  Serial.printf("Waiting for PS3 controller on %s ...\n", config::HOST_MAC);
}

void update()
{
  if (battery::isLow())
  {
    status_led::set(status_led::LOW_BATTERY);
    halt();

    // Bluetooth alone would still run the cell down to the protection board's cutoff.
    if (s_lowSince == 0) s_lowSince = millis() | 1;
    if (millis() - s_lowSince >= config::BATTERY_LOW_SLEEP_MS) esp_deep_sleep_start();
    return;
  }

  const bool alive = linkAlive();
  status_led::set(alive ? status_led::CONNECTED : status_led::WAITING);
  if (!alive)
  {
    halt();
    return;
  }

  // Left stick up/down is throttle (up reads negative), right stick left/right steers.
  // On its back the wheels touch the floor with their other side, which reverses the direction
  // of travel. Steering needs no change: the sides swap and reverse at the same time.
  const int forward = imu::isFlipped() ? -1 : 1;
  const int throttle = -shape(Ps3.data.analog.stick.ly) * forward;
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

  // Stepping towards the target keeps a slammed stick, or a flip with the stick held, from
  // throwing the motors from full ahead to full astern in one go.
  s_left = approach(s_left, left);
  s_right = approach(s_right, right);
  motors::drive(s_left, s_right);
}

} // namespace controller
