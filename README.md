# minibot

A small invertible 4WD ESP32 robot driven by a PS3 controller over Bluetooth.

[![build](https://github.com/wouterds/minibot/actions/workflows/build.yml/badge.svg)](https://github.com/wouterds/minibot/actions/workflows/build.yml)
[![PlatformIO](https://img.shields.io/badge/PlatformIO-Arduino-orange.svg)](https://platformio.org)

## Overview

- ESP32 (WeMos LOLIN32 Lite) — WiFi + Bluetooth Classic + onboard LiPo charging
- PS3 DualShock 3 controller as the wireless remote (BT Classic + HID)
- 4× N20 6 V / 400 RPM gear motors, paired left/right through a single TB6612FNG dual H-bridge
- 1S LiPo 3.7 V / 1200 mAh, runs roughly an hour of cruising
- 3D-printed PETG translucent shell — fully enclosed (3 mm walls on all sides), invertible, ~130 × 130 × 18 mm

## System overview

![System block diagram](docs/schematics/system.png)

The PS3 controller pairs once over USB then auto-connects to the ESP32 over Bluetooth. The ESP32 generates PWM and direction signals for the TB6612FNG, which switches battery voltage to the motors. Logic and motor power both come from the LiPo via two rails: regulated 3.3 V from the LOLIN32's onboard LDO, and raw VBAT to the driver's VM input.

## Wiring

![Wiring schematic](docs/schematics/wiring.png)

| ESP32 pin | TB6612FNG pin | Purpose |
|---|---|---|
| `3V3` | `VCC` + `STBY` | Logic supply, chip enable |
| `GND` | `GND` | Common ground |
| `VBAT (+)` | `VM` | Motor supply (battery, 3–4.2 V) |
| `GPIO 19` | (status LED) | Connection indicator |
| `GPIO 13` | `PWMA` | Left side speed |
| `GPIO 14` | `AIN1` | Left side direction bit 1 |
| `GPIO 27` | `AIN2` | Left side direction bit 2 |
| `GPIO 26` | `PWMB` | Right side speed |
| `GPIO 16` | `BIN1` | Right side direction bit 1 |
| `GPIO 17` | `BIN2` | Right side direction bit 2 |

The two motors on each side are wired in parallel to a single driver channel — `AO1`/`AO2` drive both left motors, `BO1`/`BO2` both right motors. See [`research.md`](research.md) for the design rationale and trade-offs.

### Power distribution

![Power schematic](docs/schematics/power.png)

## Chassis

![Top-down chassis layout](docs/cad/layout.png)

Two identical tray-shaped plates (3 mm floor + 6 mm half-walls) join open-face-to-open-face into a closed box. The four motors mount in half-cylinder pockets in each plate, shafts pointing outward toward the side walls. Wheels sit on those shafts close to — but inside — the walls, and protrude only through cutouts in the top and bottom plates. No part of the wheel is exposed laterally.

The parametric OpenSCAD source is at [`docs/cad/chassis.scad`](docs/cad/chassis.scad). Render to STL:

```sh
openscad --export-format=stl -o plate.stl docs/cad/chassis.scad
```

Print the same shape twice — the chassis is invertible. The matplotlib top-down preview is regenerated with `docs/cad/layout.py` (`uv` + PEP 723 inline deps).

### Print settings

| Setting | Value |
|---|---|
| Material | PETG translucent |
| Plate thickness | 3 mm |
| Layer height | 0.2 mm |
| Infill | 25–30 % gyroid |
| Perimeters | 3–4 walls |
| Orientation | Plates flat on the bed |
| Mounting | M3 heat-set inserts in the corner bosses |

## Bill of materials

Quick summary — see [`docs/bom.md`](docs/bom.md) for the full list with vendors and sourcing notes.

| Component | Qty | ~Cost |
|---|---|---:|
| ESP32 LOLIN32 Lite | 1 | €5–8 |
| TB6612FNG breakout | 1 | €1.50 |
| N20 6 V 400 RPM motor, 20 mm shaft | 4 | €10 |
| SLT20 33×20 mm wheel | 4 | €7.20 |
| 1S LiPo 1200 mAh | 1 | €6 |
| PETG translucent (chassis) | ~50 g | €1–2 |
| M3 hardware, wire, heat-shrink | — | €5–8 |
| PS3 controller (reuse) | 1 | €0–20 |
| **Total (minimum viable build)** | | **~€30–40** |

## Assembly

1. Print two chassis plates from PETG translucent.
2. Press M3 heat-set inserts into the four corner bosses of one plate.
3. Solder wires directly to the LOLIN32 Lite and TB6612FNG (no headers, to keep everything flush in the 12 mm cavity).
4. Wire the boards per the table above; double-check `VM` / `VCC` are not swapped.
5. Solder both left motors in parallel to `AO1` / `AO2`, both right motors to `BO1` / `BO2`. If a motor spins backwards after first boot, swap that motor's two leads at the driver output.
6. Drop motors into the half-pockets, slide wheels onto the shafts, sandwich between plates, and screw together at the corners.
7. Connect the battery via the JST PH2.0 on the LOLIN32. The onboard TP4054 charges the battery whenever USB is plugged in.

## Software

### Prerequisites

- macOS / Linux / Windows with VSCode + [PlatformIO IDE](https://platformio.org/platformio-ide)
- [`uv`](https://docs.astral.sh/uv/) (for the PS3 pairing script)
- USB cable for first programming

### Build and flash

```sh
git clone https://github.com/wouterds/minibot
cd minibot
pio run -t upload -t monitor
```

Or from the PlatformIO sidebar in VSCode: **Project Tasks → esp32dev → Upload**. The first build downloads the ESP32 toolchain (~few hundred MB, one-time).

### Pairing the PS3 controller

PS3 controllers store a single host MAC and only auto-connect to that address. To pair to this ESP32:

```sh
# Plug controller into your Mac via USB, then:
./scripts/pair-ps3.py 24:6f:28:b1:f8:b6
```

The MAC above is the ESP32's burned-in Bluetooth MAC (see [`research.md`](research.md)). Replace it with your own ESP32's BT MAC if you're using a different chip.

After pairing, unplug USB and press the PS button. The status LED on GPIO 19 turns solid when connected.

### Controls

| Input | Effect |
|---|---|
| △ Triangle | Toggle LED on GPIO 17 |
| ○ Circle | Toggle LED on GPIO 33 |
| ✕ Cross | Toggle LED on GPIO 32 |
| □ Square | Toggle LED on GPIO 25 |
| Left stick ↑ / ↓ | Ramp global LED brightness up / down |
| Disconnect | All LEDs off, status LED blinks |
