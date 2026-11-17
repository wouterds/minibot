#pragma once

namespace imu
{

void begin();
void update();

// True while the bot lies on its back. Stays false when no IMU answers.
bool isFlipped();

bool isPresent();

// Sets the chip up to raise its INT pin when the bot is moved. False when no IMU answers.
bool armWake();

} // namespace imu
