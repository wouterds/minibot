# Parts

Everything needed to build a minibot from scratch. Prices are rough AliExpress prices in euro; Amazon, Adafruit and Sparkfun cost two to three times as much and ship faster.

## Electronics

| Qty | Component | Notes | Unit | Subtotal |
|---|---|---|---:|---:|
| 1 | **WeMos LOLIN32 Lite** | ESP32 with micro-USB and a JST battery socket, 49 × 26 mm. Leave the pin headers off. | €5–8 | €5–8 |
| 1 | **DRV8833 dual motor driver breakout** | The `HW-627` board, 18.4 × 16 mm, 1.5 A per channel. Buy a spare. | €1.50 | €1.50 |
| 4 | **N20 6 V 400 RPM gear motor, long D-shaft** | From one listing, so all four match. The shaft is 18.7 mm long, see below. | €2.50 | €10 |
| 4 | **Wheel, ⌀26 × 22 mm, 3 mm bore, set screw** | Hollow aluminium hub with a silicone tyre, JS2622 or a clone. | €1.80 | €7.20 |
| 1 | **MPU-6050 module (GY-521)** | Tells the firmware which way is up. | €1.50 | €1.50 |
| 1 | **TP4056 USB-C charge board with DW01A protection** | 27.8 × 17.4 mm. The version with six pads, including `OUT+` and `OUT−`. | €1–2 | €1.50 |
| 1 | **1S LiPo 3.7 V 2000 mAh, 103450** | 52.6 × 34 × 10.4 mm with its protection board. Wires go straight to the charge board. | €8 | €8 |
| 1 | **RGB LED, 10 mm, diffused, four legs** | Status light at the front of the hull. Common cathode or common anode, the firmware has a setting for either. | €0.20 | €0.20 |
| 3 | **Resistor** for the LED | 150 Ω for red, 47 Ω for green and blue. With a common anode: 220 Ω and 100 Ω. | — | — |
| 1 | **Buzzer, 12 mm, two pins** | ⌀11.7 × 9.5 mm. Active (beeps on a steady voltage) or passive, the firmware has a setting for either. | €0.30 | €0.30 |
| 1 | **Electrolytic capacitor, 220–470 µF, 6.3 V or more** | Across the driver's supply. Up to 8 mm thick fits beside the ESP32, next to the buzzer. | €0.10 | €0.10 |
| 2 | **Resistor 100 kΩ**, 1 | **capacitor 100 nF** | Divider for the battery voltage. Optional. | — | — |
| 1 | **PS3 controller** | DualShock 3 or a clone. | €0–20 | €0 |
| | | | **electronics** | **~€33–36** |

### Shaft length

The wheel hubs are cups: solid at one end, where the bore is, and hollow from the other. The motor reaches through the wall of the wheel well into that hollow, and the shaft has to span the rest of the hub to reach the solid end. With a 22.2 mm wide hub and an 18.7 mm shaft, the gearbox stands 3.4 mm inside the hub and the shaft tip ends flush with the hub's outer face.

A shorter shaft puts the motor deeper into the hub, which makes the hull narrower. A shaft longer than the hub is wide would stick out of it. Either way, set `shaft_l` in [`cad/minibot.scad`](../cad/minibot.scad) and the hull follows.

### Charge current

The charge board ships set to 1 A, which is half the cell's capacity per hour and fine for it. A full charge takes a bit over two hours.

## Hull

| Qty | Component | Notes | Cost |
|---|---|---|---:|
| ~80 g | **Translucent PETG** | Both shells. | €2 |
| 4 | **M2 × 10 screw, button head** | Hold the shells together: two go in through the lid, two through the base. The heads sit below the faces. | €0.20 |
| 4 | **M2 brass heat-set insert, 3.5 mm wide, up to 4 mm long** | Two pressed into the base and two into the lid, with a soldering iron. | €0.30 |
| 1 strip | **Double-sided foam tape, 1 mm** | Sticks the battery to the floor. | — |
| | **Silicone wire 26–28 AWG, heat shrink, solder** | About 1 m of wire. Heat shrink over the motor tabs. | €3–5 |

No power switch: the bot sleeps when left alone.

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
