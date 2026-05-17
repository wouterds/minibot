# Parts

Everything needed to build a minibot from scratch. Prices are rough Euro estimates from AliExpress in 2026 — Amazon / Adafruit / Sparkfun are 2–3× higher but ship faster.

## Electronics

| Qty | Component | Notes | Unit price | Subtotal |
|---|---|---|---:|---:|
| 1 | **WeMos LOLIN32 Lite** (ESP32 + CH340 + JST + TP4054) | The brain. Search "LOLIN32 Lite" on AliExpress. | €5–8 | €5–8 |
| 1 | **TB6612FNG dual motor driver breakout** | Need 1 active. Recommend buying spares — buy 5 for €1.50 each. | €1.50 | €1.50 |
| 4 | **N20 6V 400 RPM micro metal gearmotor**, 20 mm shaft, D-cut | Get them all from one listing so they're matched. Search "N20 6V 400rpm 20mm shaft". | €2.50 | €10 |
| 4 | **SLT20 33×20 mm wheel**, D-shaft hub | Hub depth ~12–15 mm; matches the 20 mm shaft motor. | €1.80 | €7.20 |
| 1 | **GY-521 (MPU6050) IMU module** | 6-axis accel + gyro on I²C. Used to detect upside-down and auto-flip drive direction. Spare buying recommended — 5 for ~€1.50 each. | €1.50 | €1.50 |
| 1 | **1S LiPo 3.7 V 1200 mAh** pouch with JST PH2.0 connector | Wing or quadcopter style packs work well. <8 mm thick fits the cavity. | €6 | €6 |
| 1 | **PS3 controller** (DualShock 3, original or SHANWAN clone) | Reuse one you already have. SHANWAN clones are €15–25 new. | €0–20 | €0 |
| | | | **electronics** | **€32–55** |

## Mechanical / fasteners

| Qty | Component | Notes | Unit price | Subtotal |
|---|---|---|---:|---:|
| 1 set | **PETG translucent filament**, ~50 g for both plates | Any reputable brand (Polymaker / eSun / Prusament). 1 kg spool ≈ €20; chassis uses €1–2 worth. | — | €1–2 |
| 4 | **M3×10 mm machine screws** (chassis assembly) | | €0.10 | €0.40 |
| 4 | **M3 heat-set inserts** (M3 × 5 mm OD, brass) | Pressed into the printed bosses with a soldering iron. | €0.20 | €0.80 |
| 1 | **Misc**: silicone wire 24–28 AWG (~2 m), heat shrink, solder | | — | €3–5 |
| | | | **mechanical** | **€5–8** |

## Optional add-ons (for v2+)

| Qty | Component | Notes | Unit price |
|---|---|---|---:|
| 1 | **WS2812B / NeoPixel strip** (5–10 LEDs) | Glow effects through the translucent chassis. ESP32 drives directly. | €1–3 |
| 1 | **HC-SR04 ultrasonic distance sensor** | Obstacle detection. ~€1 on AliExpress. | €1 |
| 1 | **N20 encoder add-on** (magnetic hall, ×2 or ×4) | Closed-loop speed control / odometry. ~€3 per motor. | €3 |

## Total estimate

| Tier | What you get | Estimated cost |
|---|---|---:|
| **Minimum viable** (reuse PS3 controller, 1 driver only) | A working invertible 4WD bot | **~€32–42** |
| **Comfortable** (spare driver, new controller, extras) | Same bot + spares + buffer | **~€55–80** |
| **Loaded** (all add-ons) | Bot with NeoPixels + ultrasonic + encoders | **~€80–110** |

## Sources

| Vendor | Strength | Weakness |
|---|---|---|
| **AliExpress** | Cheapest by ~3×, all parts available | 2–4 week shipping, quality varies |
| **Amazon** | Fast (1–2 days), well-known brands | 2–3× the price |
| **Adafruit / Sparkfun** | US warehoused, high-quality breakouts, great docs | Most expensive option |
| **TinyTronics / Reichelt / Mouser** (EU) | Fast EU shipping, professional parts | More expensive than Ali |
| **Pimoroni** (UK) | Fast EU/UK shipping, curated selection | Limited motor selection |

## Already on hand (don't re-buy)

- USB cable for programming (any micro-USB cable, ≥30 cm)
- Soldering iron + flux + solder
- 3D printer with PETG capability
- Computer running VSCode + PlatformIO
- Phone with a USB-C or Lightning charger (for the LiPo charger circuit on the LOLIN32)
