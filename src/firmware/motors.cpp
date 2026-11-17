#include "motors.h"
#include "config.h"
#include <driver/gpio.h>

namespace motors
{

struct Side
{
  uint8_t pin1;
  uint8_t pin2;
  uint8_t channel1;
  uint8_t channel2;
};

static const Side LEFT = {config::MOTOR_LEFT_IN1, config::MOTOR_LEFT_IN2, 0, 1};
static const Side RIGHT = {config::MOTOR_RIGHT_IN1, config::MOTOR_RIGHT_IN2, 2, 3};

static bool s_stopped = true;

static const int16_t MAX_SPEED = (1 << config::MOTOR_PWM_RES_BITS) - 1;

// Slow decay: one input stays HIGH and the other is pulsed LOW, so the motor is shorted (braked)
// between pulses instead of freewheeling. That keeps torque usable at low speeds, and a speed of
// zero is an active brake.
static void write(const Side &side, int16_t speed)
{
  speed = constrain(speed, -MAX_SPEED, MAX_SPEED);
  const uint8_t held = speed >= 0 ? side.channel1 : side.channel2;
  const uint8_t pulsed = speed >= 0 ? side.channel2 : side.channel1;
  ledcWrite(held, MAX_SPEED);
  ledcWrite(pulsed, MAX_SPEED - abs(speed));
}

static void attach(const Side &side)
{
  ledcSetup(side.channel1, config::MOTOR_PWM_FREQ, config::MOTOR_PWM_RES_BITS);
  ledcSetup(side.channel2, config::MOTOR_PWM_FREQ, config::MOTOR_PWM_RES_BITS);
  ledcAttachPin(side.pin1, side.channel1);
  ledcAttachPin(side.pin2, side.channel2);
}

void begin()
{
  gpio_hold_dis((gpio_num_t)config::MOTOR_SLEEP); // left held LOW by sleep()
  pinMode(config::MOTOR_SLEEP, OUTPUT);
  digitalWrite(config::MOTOR_SLEEP, HIGH);

  attach(LEFT);
  attach(RIGHT);
  stop();
}

void drive(int16_t left, int16_t right)
{
  s_stopped = left == 0 && right == 0;
  write(LEFT, left);
  write(RIGHT, right);
}

void stop()
{
  drive(0, 0);
}

bool isStopped()
{
  return s_stopped;
}

void sleep()
{
  digitalWrite(config::MOTOR_SLEEP, LOW);
  gpio_hold_en((gpio_num_t)config::MOTOR_SLEEP);
  gpio_deep_sleep_hold_en();
}

} // namespace motors
