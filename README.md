# minibot

A small invertible 4WD ESP32 robot driven by a PS3 controller over Bluetooth.

[![build](https://github.com/wouterds/minibot/actions/workflows/build.yml/badge.svg)](https://github.com/wouterds/minibot/actions/workflows/build.yml)
[![PlatformIO](https://img.shields.io/badge/PlatformIO-Arduino-orange.svg)](https://platformio.org)

## Overview

- **ESP32 (WeMos LOLIN32 Lite)** — WiFi + Bluetooth Classic + onboard LiPo charging
- **PS3 DualShock 3 controller** as the wireless remote (BT Classic + HID)
- **4× N20 6 V / 400 RPM** gear motors, paired left/right through a single **TB6612FNG** dual H-bridge
- **1S LiPo 3.7 V / 1200 mAh**, ~1 hour of cruising
- **3D-printed PETG translucent chassis** — fully enclosed (3 mm walls all around), invertible, ~136 × 110 × 18 mm

## System

```mermaid
flowchart LR
    PS3([PS3 Controller]) -->|HID / Bluetooth Classic| ESP[ESP32<br/>LOLIN32 Lite]
    ESP -->|PWM + direction<br/>3.3 V logic| DRV[TB6612FNG]
    DRV -->|VM rail| MOT[4× N20 motors<br/>2 paired per side]
    BAT[(1S LiPo<br/>3.7 V / 1200 mAh)] -->|VBAT| ESP
    BAT -.->|VM raw battery| DRV
```

## Wiring

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

The two motors on each side are wired in parallel to a single driver channel — `AO1` / `AO2` drive both left motors, `BO1` / `BO2` both right motors. See [`research.md`](research.md) for the design rationale.

## Power

```mermaid
flowchart LR
    USB([USB 5 V]) -->|Vbus| TP[TP4054<br/>charge IC]
    USB -.->|powers ESP32<br/>when plugged in| LDO[LOLIN32<br/>3.3 V LDO]
    TP -->|trickle charge| BAT[(1S LiPo<br/>3.0–4.2 V)]
    BAT -->|VBAT| LDO
    BAT -->|VBAT raw| VM[TB6612 VM]
    LDO -->|3.3 V| LOGIC[ESP32 core<br/>+ TB6612 VCC/STBY]
    VM -->|3–4 A peak| MOT[4× N20 motors]
```

When USB is plugged in, the LOLIN32's onboard **TP4054** charges the battery while the ESP32 runs from USB. Unplug USB and the battery seamlessly takes over via the 3.3 V LDO. The TB6612FNG's motor supply (`VM`) always comes from raw battery — motor current never touches the USB cable or the LDO.

## Chassis

![Top-down chassis layout](docs/cad/layout.png)

Two identical tray-shaped plates (3 mm floor + 6 mm half-walls) join open-face-to-open-face into a closed box. Four motors mount in half-cylinder pockets in each plate, shafts pointing outward toward the side walls. Wheels sit on the shafts close to but inside the walls, and protrude only through cutouts in the top and bottom plates. Nothing is exposed laterally.

The parametric source is at [`docs/cad/chassis.scad`](docs/cad/chassis.scad). Render to STL with OpenSCAD:

```sh
openscad --export-format=stl -o plate.stl docs/cad/chassis.scad
```

Print the same shape twice — the chassis is invertible.

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

## Parts

Quick summary — see [`docs/parts.md`](docs/parts.md) for the full list with vendors.

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
