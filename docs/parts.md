# Parts

Everything needed to build a minibot from scratch. Prices are rough AliExpress prices in euro; Amazon, Adafruit and Sparkfun cost two to three times as much and ship faster.

## Electronics

| Qty | Component | Notes | Unit | Subtotal |
|---|---|---|---:|---:|
| 1 | **WeMos LOLIN32 Lite** | ESP32 with micro-USB and a JST battery socket, 49 × 26 mm. Leave the pin headers off. | €5–8 | €5–8 |
| 1 | **DRV8833 dual motor driver breakout** | About 18.5 × 16 mm, 1.5 A per channel. Buy a spare. | €1.50 | €1.50 |
| 4 | **N20 6 V 400 RPM gear motor, 20 mm shaft** | From one listing, so all four match. The long shaft matters, see below. | €2.50 | €10 |
| 4 | **Wheel, ⌀25 × 23 mm, 3 mm bore, set screw** | Metal hub with a silicone tyre, JS2622 or a clone. | €1.80 | €7.20 |
| 1 | **MPU-6050 module (GY-521)** | Tells the firmware which way is up. | €1.50 | €1.50 |
| 1 | **TP4056 USB-C charge board with DW01A protection** | The 28 × 17 mm board with six pads. | €1–2 | €1.50 |
| 1 | **1S LiPo 3.7 V 1000 mAh, 603048** | 50 × 30 × 6 mm with its sealed edge. Wires go straight to the charge board. | €6 | €6 |
| 1 | **Slide switch SS12D00, 3 mm lever** | Only switches the ESP32, so its 0.3 A rating is enough. | €0.10 | €0.10 |
| 1 | **Electrolytic capacitor, 220–470 µF, 6.3 V or more** | Across the driver's supply. Up to 8 mm thick fits in the free corner beside the ESP32. | €0.10 | €0.10 |
| 2 | **Resistor 100 kΩ** | Divider for the battery voltage. Optional. | — | — |
| 1 | **PS3 controller** | DualShock 3 or a clone. | €0–20 | €0 |
| | | | **electronics** | **~€33–36** |

### Shaft length

The motor sits inside the hull with its gearbox against the wall of the wheel well. The shaft has to cross that wall (2 mm) and the gap to the wheel (1.5 mm) before it reaches the hub. A 20 mm shaft leaves 16.5 mm inside a 23 mm wide wheel. The standard 10 mm shaft leaves only 6.5 mm, which is the bare minimum. If you buy a different length, set `shaft_l` in [`cad/minibot.scad`](../cad/minibot.scad).

### Charge current

The charge board ships set to 1 A, which is 1C for this cell and warm work inside a closed hull. Swapping its programming resistor (the one marked `122`, 1.2 kΩ) for 2.4 kΩ halves the current.

## Hull

| Qty | Component | Notes | Cost |
|---|---|---|---:|
| ~90 g | **Translucent PETG** | Both shells. | €2 |
| 1 strip | **Double-sided foam tape, 1 mm** | Sticks the battery to the floor. | — |
| | **Silicone wire 26–28 AWG, heat shrink, solder** | About 1 m of wire. Heat shrink over the motor tabs. | €3–5 |

No screws and no inserts: the shells click together.

## Later, maybe

| Component | Notes | Cost |
|---|---|---:|
| **WS2812B strip, 5–10 LEDs** | Glow through the hull. | €1–3 |
| **N20 motors with encoders** | Speed control and odometry. | €3 each |
| **2S battery and a 5 V regulator** | Nearly twice the speed. Needs a different charger. | €10 |

## Where to buy

| Vendor | Good | Bad |
|---|---|---|
| **AliExpress** | Cheapest by far, has everything | Two to four weeks, quality varies |
| **Amazon** | A day or two | Two to three times the price |
| **TinyTronics, Reichelt, Mouser** | Fast within the EU, reliable parts | Dearer than AliExpress |
| **Adafruit, Sparkfun, Pimoroni** | Good breakouts and documentation | Dearest, few motors |
