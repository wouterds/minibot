# minibot

A small invertible 4WD ESP32 robot driven by a PS3 controller over Bluetooth.

[![build](https://github.com/wouterds/minibot/actions/workflows/build.yml/badge.svg)](https://github.com/wouterds/minibot/actions/workflows/build.yml)
[![PlatformIO](https://img.shields.io/badge/PlatformIO-Arduino-orange.svg)](https://platformio.org)

![minibot in its translucent hull](cad/renders/product-hero.jpg)

## Overview

- **ESP32 (WeMos LOLIN32 Lite)** with Bluetooth Classic
- **PS3 DualShock 3 controller** as the remote
- **4× N20 6 V / 400 RPM** gear motors, paired left and right on one **DRV8833** dual H-bridge
- **MPU-6050 IMU**: when the bot lands on its back, forward stays forward. It also wakes the bot from sleep, so there is no power switch
- **10 mm RGB LED** at the front: it lights the hull and shows what the bot is doing
- **Buzzer** for a beep on connect, on low battery and as a horn
- **TP4056 USB-C charge board with DW01A protection**
- **1S LiPo 3.7 V / 2000 mAh (103450)**, about two hours of cruising
- **Translucent PETG hull**, 123 × 123 × 16 mm, two shells that click together with the wheels inside. See [`cad/`](cad/README.md)

![Exploded view](cad/renders/product-exploded.jpg)

## Status

The firmware builds and the hull passes its fit checks in CAD. The drive code has not run on the bot yet. The base has been test-printed once and the parts drop in; the lid has not been printed, so the click is untested. [`cad/README.md`](cad/README.md#what-is-and-is-not-verified) lists what the model does and does not prove.

## System

```mermaid
flowchart LR
    PS3([PS3 controller]) -->|Bluetooth Classic| ESP[ESP32<br/>LOLIN32 Lite]
    IMU[MPU-6050] -->|I²C: which way is up<br/>INT: wake up| ESP
    ESP -->|4 PWM pins<br/>+ sleep| DRV[DRV8833]
    ESP --> LED[RGB LED]
    ESP --> BUZ[Buzzer]
    DRV --> MOT[4× N20 motors<br/>2 in parallel per side]
    BAT[(1S LiPo)] --> TP[TP4056<br/>charge + protect]
    TP --> ESP
    TP --> DRV
```

## Wiring

No pin headers anywhere: every wire is soldered straight to a pad, so nothing stands taller than the 13 mm cavity.

![Every wire, pad to pad](docs/wiring.svg)

The drawing shows what connects to what, in the wire colours below. It is not where the parts sit: the [top view](cad/README.md#layout) shows that, with the same wires laid loosely in the hull.

| From | To | Wire | Purpose |
|---|---|---|---|
| Battery `+` / `−` | TP4056 `B+` / `B−` | the cell's own leads | The only place the battery connects |
| TP4056 `OUT+` | DRV8833 `VCC` | red | Motor supply |
| TP4056 `OUT+` | LOLIN32 battery `+` | red | Logic supply. Solder to the `+` leg of the JST socket; the board has no battery pin on its headers |
| TP4056 `OUT−` | DRV8833 `GND` | black | |
| TP4056 `OUT−` | LOLIN32 `G` | black | |
| TP4056 `OUT−` | MPU-6050 `GND` | black | |
| LOLIN32 `3V` | MPU-6050 `VCC` | red | |
| `GPIO 32` | DRV8833 `IN1` | yellow | Left side |
| `GPIO 33` | DRV8833 `IN2` | green | Left side |
| `GPIO 25` | DRV8833 `IN3` | blue | Right side |
| `GPIO 26` | DRV8833 `IN4` | white | Right side |
| `GPIO 27` | DRV8833 `EEP` | yellow | Wakes the driver. Low while the bot sleeps |
| `GPIO 19` | MPU-6050 `SCL` | yellow | |
| `GPIO 23` | MPU-6050 `SDA` | blue | |
| `GPIO 34` | MPU-6050 `INT` | white | Wakes the ESP32 when the bot is moved |
| `GPIO 4` | LED red leg, through 150 Ω | yellow | |
| `GPIO 16` | LED green leg, through 47 Ω | green | |
| `GPIO 17` | LED blue leg, through 47 Ω | blue | |
| LED long leg | LOLIN32 battery `−` | black | The `−` leg of the JST socket |
| `GPIO 13` | Buzzer `+` | white | |
| Buzzer `−` | LOLIN32 battery `−` | black | The `−` leg of the JST socket |
| `GPIO 35` | middle of a 100 kΩ / 100 kΩ divider from battery `+` to `GND` | | Battery voltage, optional |
| DRV8833 `OUT1` / `OUT2` | both left motors, in parallel | red / black | |
| DRV8833 `OUT3` / `OUT4` | both right motors, in parallel | red / black | |

Notes:

- **There is no power switch.** After three minutes without driving, the firmware puts the motor driver and the ESP32 to sleep and sets the IMU to watch for movement. Pick the bot up or nudge it and it wakes. Asleep it should draw around 1 mA, which is weeks on a full cell; that figure is an estimate, not a measurement.
- **Without the IMU the bot never sleeps**, because nothing could wake it again inside a sealed hull. The battery is then empty in a few hours.
- **`GPIO 21` is not on this board**, which is why I²C sits on 19 and 23. They are next to `3V`, in the order the IMU's pads want them.
- **The LED's long leg is its common leg.** The table is for a common cathode: long leg to minus. With a common anode the long leg goes to TP4056 `OUT+` instead, the resistors become 220 Ω for red and 100 Ω for green and blue, and `RGB_COMMON_ANODE` in [`src/config.h`](src/config.h) becomes `true`. To find out which one it is, hold the long leg and one other leg to the battery through a resistor: it lights one way round only.
- **The buzzer is taken to be an active one**, which beeps on a steady voltage. If it only clicks when held to the battery it is passive: set `BUZZER_ACTIVE` to `false` and the firmware makes the tone.
- **The onboard LED on `GPIO 22`** follows the status light, for when the lid is off.
- **The four motor pins are quiet during boot.** Several other pins pulse at reset and would twitch the motors.
- **A 220–470 µF capacitor** across the driver's `VCC` and `GND` keeps motor starts from browning out the ESP32.
- **The divider on `GPIO 35` is optional.** Once it is soldered in, set `BATTERY_SENSE_FITTED` to `true` in [`src/config.h`](src/config.h), put 100 nF from the pin to `GND`, and correct `BATTERY_DIVIDER` until the voltage in the serial log matches a multimeter.
- **If a side runs backwards**, swap the two motor leads of that side at the driver.
- **Mount the IMU component side up.** If the bot drives backwards the right way up, set `IMU_Z_SIGN` to `-1` in [`src/config.h`](src/config.h).
- **Never plug in both USB ports at once.** The LOLIN32 has its own charger; with both connected, two chargers feed one cell.

All pins are constants in [`src/config.h`](src/config.h). [`research.md`](research.md) has the reasoning.

## Power

```mermaid
flowchart LR
    USBC([USB-C 5 V]) --> TP[TP4056<br/>charger]
    TP --> BAT[(1S LiPo<br/>3.0–4.2 V)]
    BAT --> DW[DW01A<br/>protection]
    DW -->|OUT+| LDO[LOLIN32<br/>3.3 V regulator]
    DW -->|OUT+| VM[DRV8833 VCC]
    LDO -->|3.3 V| LOGIC[ESP32, IMU]
    VM --> MOT[4× N20 motors]
```

The TP4056 board charges the cell from USB-C, and its DW01A cuts the output on overcharge, overdischarge, overcurrent and short circuit. That cutoff only comes at 2.4 V, so with the divider fitted the firmware stops the motors at 3.3 V, blinks the LED fast for half a minute and then powers the ESP32 down.

## Driving

| Control | Does |
|---|---|
| Left stick, up / down | Throttle |
| Right stick, left / right | Steering |
| Cross | Horn |

| Status light | Means |
|---|---|
| Blue, breathing | Waiting for the controller |
| Green | Connected. Brighter the harder it drives |
| Green through yellow to red | The same, with the battery divider fitted: the colour is the charge |
| Purple | Connected and on its back |
| Red, fast blink | Battery low, motors off, going to sleep in 30 s |
| Off | Asleep. Move the bot to wake it |

The buzzer beeps twice when the controller connects, once when it drops out and three times when the battery is low.

The bot brakes when the controller stops sending for half a second. Speed changes are stepped, so a full reversal takes about 130 ms.

## Building

```sh
pio run                 # build
pio run -t upload       # flash over micro-USB
pio device monitor      # serial log
```

The PS3 controller only talks to the one Bluetooth address stored in it. The firmware gives the ESP32 the address in `HOST_MAC` ([`src/config.h`](src/config.h)). Plug the controller in over USB once and write that same address to it:

```sh
scripts/pair-ps3.py 24:6f:28:b1:f8:b6
```

## Hull

![Lid off](cad/renders/product-open.jpg)

Two shells split on the axle line. The wheels run in wells inside the hull and stand 4.9 mm proud of both faces, so the bot drives the same on its back. Each motor reaches through the wall of its well into the hollow hub of its wheel. USB-C sits in the middle of the left side and micro-USB in the middle of the right side, both on the seam. There is no power switch: the bot sleeps when left alone and wakes when moved. Eleven snap fingers hold the lid, no screws.

Printing, assembly and tuning are in [`cad/README.md`](cad/README.md).

## Parts

See [`docs/parts.md`](docs/parts.md) for the full list.

| Component | Qty | ~Cost |
|---|---|---:|
| ESP32 LOLIN32 Lite | 1 | €5–8 |
| DRV8833 breakout | 1 | €1.50 |
| N20 6 V 400 RPM motor, long D-shaft | 4 | €10 |
| Wheel, ⌀26 × 22 mm, hollow hub | 4 | €7.20 |
| MPU-6050 module | 1 | €1.50 |
| TP4056 USB-C board with protection | 1 | €1–2 |
| RGB LED 10 mm, buzzer 12 mm | 1 each | €0.50 |
| 1S LiPo 2000 mAh (103450) | 1 | €8 |
| Capacitor, resistors, wire, foam tape | | €3–5 |
| Translucent PETG, ~80 g | | €2 |
| PS3 controller (reuse) | 1 | €0–20 |
| **Total** | | **~€37–43** |
