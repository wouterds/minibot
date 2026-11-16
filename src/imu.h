#pragma once

namespace imu
{

void begin();
void update();

// True while the bot lies on its back. Stays false when no IMU answers.
bool isFlipped();

} // namespace imu
