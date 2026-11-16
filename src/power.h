#pragma once

namespace power
{

// Powers down until the IMU feels the bot move. Without an IMU only a reset wakes it again.
void sleep();

} // namespace power
