# Research notes

Running log of what we learned while building minibot. Updated as we go.

## Hardware

### ESP32 dev board

- **Chip**: ESP32-D0WDQ6 rev v1.0 — original ESP32, dual-core Xtensa LX6 @ 240 MHz, WiFi + BT/BLE
- **USB-to-serial**: CH340 (`1a86:7523`) → `/dev/cu.usbserial-110`
- **Crystal**: 41.01 MHz reported (a bit off the 40 MHz spec — common quirk on CH340 clones)
- **Base MAC**: `24:6F:28:B1:F8:B4` (WiFi STA)
- **Bluetooth MAC**: `24:6F:28:B1:F8:B6` (= base + 2, per ESP32's MAC derivation rule)
- **Board**: WeMos LOLIN32 Lite (or clone) — confirmed by visible silkscreen + features
- **Footprint**: ~52 × 25 × 5 mm (no headers soldered, direct-wire build)
- **Onboard**:
  - JST PH2.0 connector for 1S LiPo (top edge)
  - TP4054 LiPo charge IC — battery charges automatically when USB is plugged in
  - 3.3V LDO regulator
  - CH340C USB-serial
  - Micro-USB connector
  - RST button
  - PCB antenna (no external connector)
- **Power pins exposed**:
  - `+` (next to JST) — raw battery voltage (3.0–4.2V), perfect for feeding TB6612FNG `VM`
  - `3V` — regulated 3.3V, for TB6612FNG `VCC` and `STBY`
  - `GND` — common ground
- **Pin labels visible**: `UP` (= GPIO 36 / SENSOR_VP), `UN` (= GPIO 39 / SENSOR_VN), `EN`, plus GPIOs 0, 2, 4, 5, 12–19, 22, 23, 25–27, 32–35

### PS3 controller

- **VID/PID**: `054c:0268` (Sony DualShock 3 / SIXAXIS)
- **Manufacturer string**: `SHANWAN` — it's a clone, not a genuine Sony. Most clones work with standard pairing flow.

### Motors

- **Type**: N20 micro metal gear motors, **6V 400 RPM, 20mm shaft** (4×)
- **Voltage choice**: 6V over 3V because the 3.7V LiPo (4.2V full) overvolts a 3V motor by 23–40%, shortening lifespan and risking thermal failure under stall. Undervolting a 6V motor is harmless — it just runs slower, with more headroom on heat and stall current.
- **Shaft length**: 20mm to match deep-hub SLT20-style wheels (33×20mm). Standard ~9mm shafts would slip in deep hubs.
- **RPM choice**: 400 RPM was the practical pick from what's actually in stock — ideal would have been 600 RPM for a snappier "speedy" feel, but 400 RPM is still a usable balance of speed and torque. At 3.7V loaded with 33mm wheels: ~1.2 km/h cruise, ~1.4 km/h peak. Future upgrade path: 2S LiPo (7.4V) would push it to ~2.4 km/h.
- **Visible gear stages identical across all 4** → same gear ratio → same output RPM at same voltage.
- **Current draw**: ~200 mA cruise, 500–700 mA stall per motor. Paired (2× per side) → 1–1.4 A stall per side — within TB6612FNG's 1.2 A continuous / 3 A peak window.
- **Encoders**: none — open-loop control only (we command, we don't sense).

### Motor driver: TB6612FNG

Picked over the alternatives for our 4× N20 setup:

| Driver | $ for 2× | Continuous | Peak | Notes |
|---|---|---|---|---|
| **TB6612FNG** ✅ | ~$4–6 | 1.2 A / ch | 3 A | MOSFET, clean API (separate PWM pin), most libs/tutorials |
| DRV8833 | ~$2–4 | 1.5 A / ch | 3 A (parallel) | Cheaper, but weirder API (PWM on direction pins) |
| L298N | ~$3 | 2 A / ch | — | BJT, ~2 V drop → wastes battery as heat |
| L9110S / MX1508 | ~$1–2 | 800 mA / ch | — | Marginal for stalled N20s |

Plan: **1× TB6612FNG breakout** for the basic 4-motor tank drive — see the [paired-motors topology](#paired-motors-per-side) below: each pair of motors on one side is wired in parallel and treated as one logical motor, so we only need 2 driver channels total. Ordering 5 drivers = 1 active + 4 future / spares.

## Software stack

### Why PlatformIO + Arduino framework

Considered Moddable SDK (TypeScript on ESP) first — beautiful idea but installing the SDK + ESP32 toolchain + ESP-IDF was a multi-GB, multi-hour setup. Dropped TS-as-hard-requirement in favour of:

- **PlatformIO IDE** (VSCode extension) — handles toolchain, library mgr, debugger, monitor, all from one extension
- **Arduino framework** on `espressif32` platform — friendlier than raw ESP-IDF, huge library ecosystem

One click in the PlatformIO status bar = build, upload, monitor. No env vars, no shell config.

### Key library

- `jvpernis/esp32-ps3` (pulled via `lib_deps` git URL) — handles PS3 BT Classic + HID + button/stick event callbacks

## PS3 controller pairing

PS3 pairing is **not** standard Bluetooth pairing. The controller stores **one** host MAC internally and will only connect to that address. There's no discovery, no PIN, no negotiation — the controller hunts for that exact MAC.

To pair:

1. Plug controller into a Mac/Linux host via USB.
2. Write the desired host MAC into the controller's memory via HID feature report `0xF5`.
3. Unplug USB → press PS button → controller auto-connects to that host over Bluetooth.

We do step 2 with `scripts/pair-ps3.py` (uses `hidapi` cython package; runs via `uv` with PEP 723 inline deps).

### Why not just `pip install hid`?

We tried the ctypes-based `hid` package first. On macOS, brew installs `libhidapi.dylib` to `/opt/homebrew/lib` which isn't a default dyld search path, and SIP strips `DYLD_FALLBACK_LIBRARY_PATH` when env-invoking system binaries — so the ctypes loader can never find the library.

The cython-based `hidapi` package builds a self-contained extension during install and bypasses the issue.

## ESP32 GPIO constraints

### Input-only pins (cannot drive outputs / LEDs / motor signals)

- **GPIO 34, 35, 36, 39** — no internal output drivers, no pull-ups/downs. ADC/sensor only.

### Strapping pins (avoid for outputs that need defined boot levels, or be careful)

- **GPIO 0** — boot mode select. Avoid for outputs.
- **GPIO 2** — boot mode. OK if not held HIGH at boot.
- **GPIO 12** — flash voltage select. Must be LOW at boot or chip enters wrong mode → won't boot.
- **GPIO 15** — debug print on boot. Must be HIGH or you lose early boot serial.
- **GPIO 5** — boot mode select. Generally fine as output, just floats high briefly at boot.

### Reserved

- **GPIO 6–11** — wired to internal SPI flash. Touching them = brick.
- **GPIO 1, 3** — UART0 used by USB-serial.

### Currently used

- `19` — status LED (solid when PS3 connected, blinks while waiting)
- `17, 25, 32, 33` — face-button LEDs (will be reallocated when motors arrive)

## Motor control

### Why a driver is mandatory

| | ESP32 GPIO | N20 motor |
|---|---|---|
| Voltage | 3.3 V | 3–6 V |
| Current | 12 mA max | 200 mA – 1 A |
| Direction | one-way | needs polarity swap to reverse |
| Back-EMF | fries logic | spikes voltage on every PWM cycle |

GPIO straight to motor = dead ESP32 in milliseconds.

### H-bridge truth table (TB6612FNG)

| IN1 | IN2 | Effect |
|---|---|---|
| HIGH | LOW | Forward |
| LOW | HIGH | Reverse |
| LOW | LOW | Coast (free spin) |
| HIGH | HIGH | Brake (short across motor) |

`PWMx` rides on top → speed magnitude.

### Stick → driver mental model

PS3 stick gives signed `-128..+127`. The driver only understands:

- **Unsigned PWM 0–255** (magnitude / how hard)
- **Two direction pins** (which way)

Code splits the signed stick value into `abs()` → PWM and `sign()` → IN1/IN2 levels. The H-bridge handles the polarity flip across the motor terminals so we never need "negative PWM".

### Open-loop vs closed-loop

Our bare N20s have **no encoders**, so we run **open-loop** — we command a direction + speed and trust the motor obeys. For:

- Precise distance ("drive 30 cm")
- Speed regulation under load
- Detecting stall against a wall

…we'd need N20s with **magnetic hall encoders** (~$3–5 extra per motor, quadrature output). Not in scope for v1.

## Power topology

```
Battery+ ─┬── ESP32 VIN  (logic via onboard LDO → 3.3V rail)
          └── TB6612 VM  (motor supply, both drivers)

Battery− ─── ESP32 GND ─── TB6612 GND (both drivers)  ← MUST be common
```

- **VM**: motor power, 3–13.5 V (battery directly)
- **VCC**: logic power, 3.3 V (from ESP32)
- **STBY**: tie to 3.3 V to keep the driver enabled (or wire to a GPIO for software sleep)
- **Decoupling**: a 100–470 µF cap across VM/GND helps absorb stall-current dips. Most breakouts have a small cap on-board but it's marginal for stalled N20s.

⚠️ Never pull motor current through ESP32's `VIN` or `3V3` pin — onboard LDO maxes out around 800 mA and the input diode is tiny. Motors get their power *directly* from the battery via the driver's `VM`.

## Paired motors per side

To save a driver and GPIO budget, **the two motors on each side are wired in parallel** and treated as a single logical motor:

```
Left Front  motor + ─┐
Left Rear   motor + ─┴───── Driver AO1
Left Front  motor − ─┐
Left Rear   motor − ─┴───── Driver AO2
```

(Same for the right side via BO1/BO2.)

Implications:

- **1 driver, not 2** — both sides fit on a single TB6612FNG (one channel per side)
- **6 GPIOs instead of 12** for motor control
- **Current doubles per channel** — 2× N20 in parallel pull ~400 mA cruise, ~1.5–2 A at simultaneous stall. Within the TB6612FNG's 1.2 A continuous / 3 A peak window, but tight enough to want decent decoupling and a battery that can deliver it.
- **Both motors on a side must be matched** (same gear ratio + winding) so they spin at the same RPM under the same drive signal. Our 4× N20s look identical externally + share the same visible gear stages, so this should hold.
- **Wire polarity matters** — if a paired motor spins the "wrong way" relative to its partner, just flip its leads at the driver output. Don't try to fix it in software.

## Wiring plan (1× TB6612FNG, 4 motors paired, tank drive)

| Side | PWM | IN1 | IN2 | Driver / output | Motors |
|---|---|---|---|---|---|
| Left  | GPIO 13 | 14 | 27 | A channel (AO1+AO2) | Left Front + Left Rear in parallel |
| Right | GPIO 26 | 16 | 17 | B channel (BO1+BO2) | Right Front + Right Rear in parallel |

`STBY` → ESP32 `3V3`. `VM` → battery+. `VCC` → ESP32 `3V3`. All `GND` rails common (battery −, ESP32 GND, driver GND).

Final pin budget: 6 GPIO for motors + 1 status LED (GPIO 19) = 7 used. Huge headroom for future sensors (ultrasonic, IMU, encoders, etc.).
