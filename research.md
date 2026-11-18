# Research notes

Running log of what we learned while building minibot. Updated as we go.

## Hardware

### ESP32 dev board

- **Chip**: ESP32-D0WDQ6 rev v1.0, the original ESP32: dual-core Xtensa LX6 at 240 MHz, WiFi and Bluetooth
- **USB-to-serial**: CH340 (`1a86:7523`), shows up as `/dev/cu.usbserial-*`
- **Base MAC**: `24:6F:28:B1:F8:B4` (WiFi STA)
- **Bluetooth MAC**: `24:6F:28:B1:F8:B6` (base + 2, per ESP32's MAC derivation rule)
- **Board**: WeMos LOLIN32 Lite (or a clone), 49 × 26 mm measured, no headers soldered
- **Onboard**:
  - JST PH2.0 socket for a 1S LiPo, next to the micro-USB. Not used as a socket; its `+` leg is where the battery wire from the charge board is soldered
  - TP4054 charge IC, about 500 mA. Not used: charging goes through the external TP4056 board
  - ME6211 3.3 V regulator
  - Micro-USB, for flashing only
  - LED on GPIO 22, lights when the pin is LOW
  - PCB antenna across the end opposite the USB
- **Power pins**: `3V3` and `GND` on the headers. There is no battery or 5 V pin on the headers
- **Header pins**, antenna end to USB end:
  - JST side: `VP` (36), `VN` (39), `EN`, 34, 35, 32, 33, 25, 26, 27, 14, 12, `GND`
  - USB side: `3V3`, 22, 19, 23, 18, 5, 17, 16, 4, 0, 2, 15, 13
- **Not broken out**: GPIO 21 (the usual I²C SDA), and GPIO 1 and 3 (serial, wired to the CH340 only)

### PS3 controller

- **VID/PID**: `054c:0268` (Sony DualShock 3 / SIXAXIS)
- **Manufacturer string**: `SHANWAN`, so a clone. It pairs and connects like a genuine one.

### Motors

- **Type**: N20 micro metal gear motors, **6 V 400 RPM, long D-shaft**, four of them
- **Measured**: 12 × 10 mm across, 25.6 mm from the brass front face to the end cap, of which 9.4 mm is gearbox. Solder tabs add another millimetre
- **Voltage choice**: 6 V rather than 3 V, because a full LiPo (4.2 V) overvolts a 3 V motor by 40 %. Undervolting a 6 V motor is harmless, it just runs slower
- **Shaft length**: 18.7 mm from the gearbox face. The wheel hubs are hollow, and the motor reaches 3.4 mm into them; from there the shaft spans the rest of the hub to its solid end
- **RPM choice**: 400 RPM was what was in stock; 600 would feel snappier. At 3.7 V under load with ⌀25 mm wheels: about 1 km/h. A 2S battery would nearly double that
- **Current**: about 200 mA cruising and 500–700 mA stalled per motor at 6 V, less at 3.7 V
- **Encoders**: none, so control is open loop

### Wheels

- JS2622 or a clone: metal hub with a 3 mm bore and a set screw, silicone tyre
- **Measured**: ⌀26 mm over the tyre, 22.2 mm wide over the hub's flanges. The hub is a cup, solid at one end

### Motor driver: DRV8833

| Driver | Price | Continuous | Peak | Notes |
|---|---|---|---|---|
| **DRV8833** ✅ | ~€1.50 | 1.5 A / ch | 2 A | MOSFET, 18.4 × 16 mm, runs from 2.7 V, 4 GPIOs |
| TB6612FNG | ~€1.50 | 1.2 A / ch | 3 A | MOSFET, 22 × 22 mm, 6 GPIOs |
| L298N | ~€2 | 2 A / ch | — | BJT, loses about 2 V, hopeless on one cell |
| L9110S / MX1508 | ~€1 | 800 mA / ch | — | Marginal for stalled N20s |

One DRV8833 drives all four motors: the two motors on a side are wired in parallel and treated as one.

The breakout's pads: `IN1`–`IN4`, `VCC`, `GND` on one edge; `EEP` (sleep), `OUT1`–`OUT4`, `ULT` (fault) on the other. On the chip itself the sleep pin is pulled low, so the driver sleeps unless `EEP` is driven high. Some clones add their own pull-up behind a solder jumper. The firmware drives `EEP` from GPIO 27 and holds it low while the ESP32 sleeps, which works either way.

### Charging and protection: TP4056 board

- USB-C in, `B+` / `B−` to the cell, `OUT+` / `OUT−` to the load
- TP4056 charges at 1 A as shipped (1.2 kΩ programming resistor). That is 0.5C for the 2000 mAh cell
- DW01A cuts the output on overcharge (4.3 V), overdischarge (2.4 V), overcurrent (about 3 A) and short circuit
- The load has to hang on `OUT±`, not on `B±`, or the protection does nothing
- Some of these boards lack the two 5.1 kΩ resistors a USB-C to USB-C cable needs to see before it supplies power. Those only charge from a USB-A to USB-C cable

## Software stack

### PlatformIO and the Arduino framework

Considered the Moddable SDK (TypeScript on the ESP) first, but the SDK plus toolchain plus ESP-IDF was a multi-GB, multi-hour setup. PlatformIO handles toolchain, libraries and serial monitor from one command or one VS Code extension.

### Library

- `jvpernis/esp32-ps3`, pulled by git URL. It handles Bluetooth Classic, HID and the controller's reports.
- It never reports a disconnect: nothing in it calls its own disconnect path. The firmware tells from the report stream instead.
- It is unmaintained and reaches into Bluedroid internals, so it only compiles against Arduino core 2.0.x. `platformio.ini` pins the platform (6.12.0, core 2.0.17) and the library commit for that reason. An unpinned platform once resolved to core 3.x and the build broke.
- Bluepad32 is the maintained alternative if this library ever stops working. It supports the DualShock 3 and lists some ShanWan clones.

## PS3 controller pairing

PS3 pairing is not standard Bluetooth pairing. The controller stores one host address and only ever connects to that address. No discovery, no PIN.

1. Plug the controller into a Mac or Linux machine over USB.
2. Write the host address into the controller with HID feature report `0xF5`.
3. Unplug, press the PS button: it connects to that address.

`src/pairing/pair-ps3.py` does step 2. The firmware sets the ESP32's Bluetooth address to `HOST_MAC`, so any address works as long as both sides have the same one.

### Why the `hidapi` package and not `hid`

The ctypes-based `hid` package needs `libhidapi.dylib` on the dyld search path. Homebrew installs it in `/opt/homebrew/lib`, which is not on that path, and SIP strips `DYLD_FALLBACK_LIBRARY_PATH`. The Cython-based `hidapi` package builds its own copy and avoids the problem.

## ESP32 GPIO constraints

### Input only

- **GPIO 34, 35, 36, 39**: no output drivers and no pull-ups. Fine for the battery divider.

### Driven or sampled at boot

- **GPIO 0**: boot mode select, pulses at reset
- **GPIO 2**: has to be low or floating at boot
- **GPIO 5**: high at boot
- **GPIO 12**: flash voltage select, the board will not boot with it high
- **GPIO 14**: pulses at reset
- **GPIO 15**: high at boot

A motor driver input on one of these twitches the motors every time the board resets. The first wiring plan had GPIO 14 on the driver.

### Reserved

- **GPIO 6–11**: the SPI flash
- **GPIO 1, 3**: serial to the CH340

### ADC

- **ADC1** (GPIO 32–39) always works. **ADC2** shares hardware with the radio, so the battery sense sits on ADC1.

### In use

| Pin | Use |
|---|---|
| 22 | Status LED (onboard, active low) |
| 32, 33 | DRV8833 `IN1`, `IN2`: left motors |
| 25, 26 | DRV8833 `IN3`, `IN4`: right motors |
| 27 | DRV8833 `EEP`: wakes the driver |
| 19, 23 | I²C `SCL`, `SDA` to the MPU-6050 |
| 4, 16, 17 | RGB status LED: red, green, blue |
| 13 | Buzzer |
| 34 | MPU-6050 `INT`: wakes the ESP32 from sleep |
| 35 | Battery voltage through a divider |

32, 33, 25 and 26 sit next to each other on the header, are quiet at boot and are outputs. 19 and 23 sit next to `3V3`, which the IMU needs anyway, in the order of the IMU's own pads. 4, 16 and 17 sit next to each other and are quiet at boot, as is 13.

## Motor control

### Why a driver is mandatory

| | ESP32 GPIO | N20 motor |
|---|---|---|
| Voltage | 3.3 V | 3–6 V |
| Current | 12 mA | 200 mA – 1 A |
| Direction | one way | needs its polarity swapped to reverse |
| Back-EMF | kills logic | a spike on every PWM cycle |

### DRV8833 inputs

| `IN1` | `IN2` | Result |
|---|---|---|
| LOW | LOW | Coast |
| PWM | LOW | Forward, fast decay: the motor freewheels between pulses |
| HIGH | PWM | Forward, slow decay: the motor is shorted between pulses |
| LOW | PWM | Reverse, fast decay |
| PWM | HIGH | Reverse, slow decay |
| HIGH | HIGH | Brake |

The firmware uses slow decay at 20 kHz: one input stays HIGH, the other is pulsed LOW. Torque stays usable at low speed, the PWM is above hearing range, and a speed of zero is a brake.

### Stick to motors

The sticks give signed values from −128 to 127. Each goes through a dead zone and a squared curve to a signed speed. Left stick up and down is throttle, right stick left and right is steering:

```
left  = throttle + steer
right = throttle − steer
```

If one side would exceed full speed, both are scaled down together, so the turn keeps its shape.

### Losing the link

The controller streams reports all the time. When they stop for half a second the firmware brakes and the status LED goes back to blinking. The library never says the connection is gone, so without this the bot would keep driving on the last stick position.

### Slew limit

The speed of each side moves towards its target by at most 40 of 255 per 10 ms loop. Full ahead to full astern in one step is how paralleled motors on one cell trip the driver's overcurrent limit or brown out the ESP32. Stopping is immediate.

### Open loop

No encoders, so the firmware commands a speed and trusts the motors. Precise distances, speed held under load and stall detection would need N20s with hall encoders.

## Power

```
USB-C ── TP4056 ── B+/B− ── battery
              └── OUT+ ──┬── LOLIN32 battery + ── 3.3 V regulator ── ESP32, IMU
                         └── DRV8833 VCC ── motors
              └── OUT− ── common ground
```

- **No power switch.** Nothing is ever disconnected from the cell; the firmware sleeps instead. See [Sleep and wake](#sleep-and-wake).
- **Low-voltage cutoff in firmware.** The DW01A only cuts at 2.4 V, well past where a LiPo starts taking damage. A 100 kΩ / 100 kΩ divider on GPIO 35 lets the firmware stop the motors at 3.3 V, or at 3.0 V while they are running, because load pulls the voltage down. The dip has to last three seconds. Half a minute later the ESP32 goes into deep sleep, since Bluetooth alone would keep draining the cell.
- **The divider is a setting, not detected.** GPIO 35 has no pull resistors, so without the divider it floats and can read as anything. `BATTERY_SENSE_FITTED` says whether it is there.
- **Calibrate it.** Many ESP32s of this generation have no ADC calibration burnt in, which leaves the reading up to 10 % off. A 100 nF capacitor on the pin steadies it; `BATTERY_DIVIDER` corrects it against a multimeter.
- **Decoupling.** 220–470 µF across the driver's supply. The regulator needs about 3.4 V in to hold 3.3 V out, and a stalled motor can pull a tired cell below that.
- **Two chargers.** The LOLIN32's own TP4054 charges whatever hangs on its battery input, so with both USB ports plugged in two chargers feed one cell. Plug in one at a time.
- **Never route motor current through the ESP32 board.** Its regulator and traces are sized for a few hundred mA.

## Sleep and wake

An ESP32 with Bluetooth on draws around 100 mA, which empties the cell in hours, and the build has no switch. So after three minutes without driving the firmware powers down:

- **Motor driver**: `EEP` low, held low through the ESP32's sleep. A few µA.
- **ESP32**: deep sleep. The board around it (regulator, USB chip) decides what that really draws; expect somewhere under 1 mA.
- **IMU**: left awake on its accelerometer alone, about 0.5 mA, with its motion interrupt armed. Its `INT` pin goes to GPIO 34 and wakes the ESP32.

Picking the bot up or nudging it raises `INT`, and the ESP32 boots as if switched on. If nobody drives within three minutes it sleeps again.

- **Not the IMU's cycle mode.** It draws a fraction of that, but several people report that the motion interrupt never fires in it.
- **`INT` is latched**, so it stays high until the status register is read. A short pulse could be missed by the wake circuit.
- **A high-pass filter in the chip removes gravity**, so the threshold (`WAKE_THRESHOLD`, about 2 mg per step) compares against movement only.
- **Without an IMU the bot stays awake**, because nothing could wake it inside a sealed hull. A low battery still sends it to sleep; then only a reset brings it back, which the serial monitor does when it opens the port.

## Paired motors per side

```
left front  + ─┐
left rear   + ─┴── OUT1
left front  − ─┐
left rear   − ─┴── OUT2
```

Same for the right side on `OUT3` / `OUT4`.

- One driver instead of two, four GPIOs instead of eight
- Current per channel doubles: about 400 mA cruising, up to about 0.9 A with both motors stalled at 3.7 V. Inside the driver's 1.5 A
- Both motors on a side have to match, so buy all four from one listing
- If one motor of a pair runs the wrong way, swap its leads. Not fixable in software

## Which way is up

The MPU-6050's accelerometer reads gravity. The sign of its Z axis says whether the bot is on its wheels or on its back.

- Above +0.5 g: upright. Below −0.5 g: on its back. In between (on its side, in the air) the last answer stands.
- A new answer has to hold for 300 ms before it counts, so a bump does not flip the controls.
- The chip's 5 Hz low-pass filter is on, which keeps motor vibration out.

On its back the wheels touch the floor with their other side, so the same motor direction now drives the bot the other way: the throttle is negated. Steering needs no change, because the sides swap and reverse at the same time.

The firmware talks to the chip directly over I²C: wake it, set the filter, read two bytes. No library.

## Hull

The full description is in [`src/model/README.md`](src/model/README.md). The reasoning:

### Wheels inside

The hull is a closed square, 123 × 123 × 16 mm, and the wheels run in wells inside it. Each well is a cylinder around the axle, 1.5 mm larger than the tyre all round, open to both faces. The tyres stand 4.9 mm proud of each face. Nothing sticks out in any other direction, so the bot hits walls with its hull, not with a wheel.

The price is ground clearance: 4.9 mm, flat floors only.

### Motor mount

The wheel hubs are cups, so the motor does not have to stop short of its wheel. It passes through the wall of the well, and the front 3.4 mm of its gearbox stands inside the hub. That depth is the hub's width minus the shaft's length, which puts the shaft tip flush with the hub's outer face and the whole solid end of the hub on the shaft. It also makes the hull about 7 mm narrower than with the gearbox in front of the wall.

Each motor lies on two saddles in the base and under two in the lid: one under the end cap, one from the front of the can up to the well wall. The gearbox is an open frame of brass plates, so the front saddle is long enough to always carry one of them.

- **Along its axis** the motor is held by a stop behind its end cap, and by a small stop on the outer wall of the well that faces the shaft tip. That one touches only at the centre of rotation, so it does not drag.
- **A wheel that hits the floor levers its motor against the saddles.** The wheel hangs outside the front saddle, so the saddles see up to about twice the force on the wheel, one pushing on the lid and one on the base. That is why the lid's screws stand right beside each motor.

### Split on the axle line

Both shells end at the axle, so the motors with their wheels drop in from above and the shafts lie in half-round notches. Everything else that goes through a wall is also centred on the seam, which makes the hull look the same either way up.

### Screws

- The first lid clicked on with snap fingers. Printed, it felt loose and wonky, so the lid is screwed down instead.
- Four M2 × 10 button head screws go into brass heat-set inserts. One sits beside each wheel, in the pocket between the motor bay and the end wall: that is where a wheel that lands hard levers its motor against the lid.
- Each screw runs through a post that is half in the lid and half in the base. The halves meet on the seam, so tightening clamps plastic on plastic and does not bend the lid.
- All four screws go in through the lid and all four inserts sit in the base. A split with two of each per shell was drawn first, so both faces would look the same; one shell for the inserts and one for the screws is simpler to build and to open.
- The heads sit in recesses, below the face, so nothing new touches the floor.
- A lip on the base stands 1 mm into the lid, round the cavity and round the outer wall. It centres the lid and takes sideways loads, so the screws only have to hold the lid down.

### Layout

- USB-C (charger) in the middle of the left side, micro-USB (ESP32) in the middle of the right side. Each board lies with its socket against the wall.
- The sockets sit at different heights on their boards, so each board rests on ledges of its own height that put its socket on the seam.
- The battery lies lengthwise in the middle, on foam tape, as far from the ESP32's antenna as the charger allows: 5.6 mm. A foil pouch that close can cost range.
- Boards rest on ledges under the edges that carry no pads. The lid has a rib over each board that stops just above it.

### Material

Translucent PETG: tough, good layer adhesion, and the status LED lights the whole hull.
