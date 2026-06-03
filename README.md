# minibot

A small invertible 4WD ESP32 robot driven by a PS3 controller over Bluetooth.

[![build](https://github.com/wouterds/minibot/actions/workflows/build.yml/badge.svg)](https://github.com/wouterds/minibot/actions/workflows/build.yml)
[![PlatformIO](https://img.shields.io/badge/PlatformIO-Arduino-orange.svg)](https://platformio.org)

## Overview

- **ESP32 (WeMos LOLIN32 Lite)** — WiFi + Bluetooth Classic
- **PS3 DualShock 3 controller** as the wireless remote (BT Classic + HID)
- **4× N20 6 V / 400 RPM** gear motors, paired left/right through a single **DRV8833** dual H-bridge
- **MPU-6050 IMU** for orientation detection — auto-flips drive direction when the bot is upside-down
- **TP4056 USB-C charge + DW01A protection board** — handles charging, overcharge, overdischarge and short-circuit protection
- **1S LiPo 3.7 V / 1000 mAh (603048)**, ~1 hour of cruising
- **3D-printed PETG translucent chassis** — fully enclosed (2.5 mm walls all around), invertible, ~150 × 120 × 18 mm

## System

```mermaid
flowchart LR
    PS3([PS3 Controller]) -->|HID / Bluetooth Classic| ESP[ESP32<br/>LOLIN32 Lite]
    IMU[MPU-6050 IMU] -->|I²C<br/>orientation| ESP
    ESP -->|2 PWM pins / side<br/>3.3 V logic| DRV[DRV8833]
    DRV -->|VM rail| MOT[4× N20 motors<br/>2 paired per side]
    BAT[(1S LiPo<br/>3.7 V / 1000 mAh)] -->|B+ / B-| TP[TP4056<br/>charge + protect]
    TP -->|OUT+ protected VBAT| ESP
    TP -.->|OUT+ to VM| DRV
```

## Wiring

| ESP32 pin | Destination | Purpose |
|---|---|---|
| `3V3` | DRV8833 `SLP`, MPU-6050 `VCC` | Wake the driver, power the IMU |
| `GND` | All `GND` | Common ground |
| `+` pad next to JST | DRV8833 `VM` (from TP4056 `OUT+`) | Motor supply, protected battery (3–4.2 V). Solder to the **pad next to the white JST connector**, not a side-header pin. |
| `GPIO 19` | Status LED | Connection indicator |
| `GPIO 21` | MPU-6050 `SDA` | I²C data (IMU) |
| `GPIO 22` | MPU-6050 `SCL` | I²C clock (IMU) |
| `GPIO 13` | DRV8833 `AIN1` | Left side PWM bit 1 |
| `GPIO 14` | DRV8833 `AIN2` | Left side PWM bit 2 |
| `GPIO 26` | DRV8833 `BIN1` | Right side PWM bit 1 |
| `GPIO 27` | DRV8833 `BIN2` | Right side PWM bit 2 |

Each motor uses **2 PWM-capable GPIOs**: drive one HIGH/PWM and hold the other LOW to spin one direction, swap to reverse. The two motors on each side are wired in parallel to a single driver channel — `AOUT1` / `AOUT2` drive both left motors, `BOUT1` / `BOUT2` both right motors. See [`research.md`](research.md) for the design rationale.

## Power

```mermaid
flowchart LR
    USBC([USB-C 5 V]) -->|Vbus| TP[TP4056<br/>charge IC]
    TP -->|charge| BAT[(1S LiPo<br/>3.0–4.2 V)]
    BAT --> DW[DW01A<br/>protection IC]
    DW -->|OUT+ protected| LDO[LOLIN32<br/>3.3 V LDO]
    DW -->|OUT+ raw| VM[DRV8833 VM]
    LDO -->|3.3 V| LOGIC[ESP32 core<br/>+ DRV8833 SLP, IMU VCC]
    VM -->|3–4 A peak| MOT[4× N20 motors]
```

USB-C plugs into the **TP4056** board: it charges the battery (constant-current → constant-voltage) and the paired **DW01A** protects against overcharge, overdischarge, overcurrent, and short-circuit. The **OUT+ / OUT-** terminals are the protected battery output that feeds both the LOLIN32's 3.3 V LDO and the DRV8833's VM rail. The LOLIN32's onboard TP4054 + JST connector is left unused — battery only ever connects to the TP4056's `B+ / B-`.


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
| Mounting | M2.5 heat-set inserts in the corner bosses |

## Parts

Quick summary — see [`docs/parts.md`](docs/parts.md) for the full list with vendors.

| Component | Qty | ~Cost |
|---|---|---:|
| ESP32 LOLIN32 Lite | 1 | €5–8 |
| DRV8833 breakout | 1 | €1.50 |
| N20 6 V 400 RPM motor, 20 mm shaft | 4 | €10 |
| JS2622 26×22 mm wheel | 4 | €7.20 |
| MPU-6050 IMU module | 1 | €1.50 |
| TP4056 USB-C charge + DW01A protection board | 1 | €1–2 |
| 1S LiPo 1000 mAh (603048) | 1 | €6 |
| PETG translucent (chassis) | ~50 g | €1–2 |
| M2.5 hardware, wire, heat-shrink | — | €5–8 |
| PS3 controller (reuse) | 1 | €0–20 |
| **Total (minimum viable build)** | | **~€33–44** |
