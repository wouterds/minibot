# Measurements

Caliper readings of the actual parts, taken by the owner. These outrank datasheets and anything measured off a photo. The model in [`cad/minibot.scad`](../cad/minibot.scad) should follow this file.

Readings are in mm, as shown on the caliper.

## Wheel

Aluminium hub with two flanges and a red silicone tyre between them. One end of the hub is a solid plate with the bore, the other end is an open cup. The motor fits inside the cup.

| What | Reading | Notes |
|---|---:|---|
| Outer diameter, tyre on the hub | 25.99 | The model has 25 |
| Hub width, flange to flange | 22.16 | This is the width of the whole wheel: the tyre sits between the flanges. The model has 23 |
| Cup inner diameter | | The motor slides in; how much play? |
| Cup depth, rim to plate | | |
| Plate thickness | | |
| Set screw, distance from the plate's outer face | | It sits near one flange; which end? |

## Motor

N20 with an open brass gearbox and a smooth D-shaft.

| What | Reading | Notes |
|---|---:|---|
| Width | 11.96 | Model: 12 |
| Height, across the flats | 9.92 | Model: 10 |
| Total length, shaft tip to the rear end | 45.40 | Includes the shaft and whatever sticks out at the back |
| Shaft length from the gearbox face | 18.73 | Model: 20. The D flat runs most of its length |
| Gearbox face to the end of the can, without the tabs | | Model: 24. Total minus shaft leaves 26.67 for body plus tabs, so the body is probably nearer 25 |
| Solder tabs | | Model: 1.8 |
| Gearbox length | | Model: 9 |
| Shaft diameter, and across the D flat | | |

## Battery, 2000 mAh

Marked `TY 103450 2000mAh 3.7V 7.4Wh`. Protection board under yellow tape at the lead end, small two-pin plug.

| What | Reading | Notes |
|---|---:|---|
| Length | 52.56 | Including the taped end |
| Width | 33.99 | |
| Thickness | 10.35 | Measured over the taped end, the thickest spot |

The cavity is 12 mm high. With 1 mm of foam tape underneath, this cell leaves 0.65 mm, so the hull has to grow about 1 mm in height to take it.

## Battery, 1000 mAh

Marked `603048 3.7V 1000mAh`.

| What | Reading | Notes |
|---|---:|---|
| Length × width | 50 × 30 | From the earlier CAD, not re-measured |
| Thickness | | Model: 6 |

## ESP32, LOLIN32 Lite

| What | Reading | Notes |
|---|---:|---|
| Length | 49.22 | Model: 49 |
| Width | 25.70 | Model: 26 |
| Micro-USB centre to the long edge beside pin `13` | | Model: 6 |
| Board plus micro-USB socket | 3.77 | Model: 4.2. A micro-USB socket is about 2.6 high, so the board is about 1.2 and the socket's centre sits about 2.5 above the board's underside |
| Board plus the white battery socket, the tallest part | 6.75 | Model: 7.1 |
| How far the micro-USB sticks out past the board edge | | Model: 0 |

Seen in the photos: two mounting holes, one in the corner beside `VP` at the antenna end and one beside pin `13` at the USB end. The micro-USB sits on the `3V … 13` side, the white battery socket on the `VP … G` side, the reset button between them.

## Charger, TP4056 with USB-C

| What | Reading | Notes |
|---|---:|---|
| Width | 17.40 | The earlier CAD had 16 |
| Length, USB-C mouth to the far edge of the board | 28.13 | A second reading, taken edge-on, gave 27.78. The earlier CAD had 26.5 for the board plus 2.5 for the socket |
| Board plus USB-C socket | 4.19 | Model: 4.4. A USB-C socket is about 3.2 high, so the board is about 1.0 and the socket's centre sits about 2.6 above the board's underside |
| USB-C socket past the board edge | | The earlier CAD had 2.5; in the photo it looks nearer 1 |

## Driver and IMU

| What | Reading | Notes |
|---|---:|---|
| DRV8833 board | 18.40 × 15.95 | Marked `HW-627`. The two rows of six pads run along the 15.95 edges, 18.40 apart. The model has them on the other pair of edges |
| DRV8833 total thickness | | Model: 3.1 |
| MPU-6050 board | 20 × 15.5 | From the earlier CAD |
| MPU-6050 total thickness | | Model: 3.1 |
