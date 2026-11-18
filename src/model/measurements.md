# Measurements

Caliper readings of the actual parts, taken by the owner. These outrank datasheets and anything measured off a photo. The model in [`minibot.scad`](minibot.scad) follows this file.

Readings are in mm, as shown on the caliper.

## Wheel

Aluminium hub with two flanges and a red silicone tyre between them. One end of the hub is a solid plate with the bore, the other end is an open cup. The motor fits inside the cup.

| What | Reading | Notes |
|---|---:|---|
| Outer diameter, tyre on the hub | 25.99 | |
| Hub width, flange to flange | 22.16 | This is the width of the whole wheel: the tyre sits between the flanges |
| Cup inner diameter | | Not measured. The motor goes in and the hub turns freely around it |

## Motor

N20 with an open brass gearbox and a smooth D-shaft.

| What | Reading | Notes |
|---|---:|---|
| Width | 11.96 | |
| Height, across the flats | 9.92 | |
| Total length, shaft tip to the rear end | 45.40 | Includes the shaft and whatever sticks out at the back |
| Shaft length from the gearbox face | 18.73 | The D flat runs most of its length |
| Body: brass front face to the black end cap | 25.64 | The first hull assumed 24 and would have been 1.6 too short |
| Brass front face to the rearmost point | 26.04 | Jaw on the back of the motor rather than beside the tabs. Total minus shaft gives 26.67 to the tab tips |
| Can with its end cap | 16.25 | Leaves 9.4 for the gearbox |
| Solder tabs past the end cap | about 1.0 | Derived: 26.67 minus 25.64 |
| Gearbox length | about 9.4 | Derived: 25.64 minus 16.25 |
| Shaft diameter, and across the D flat | | |

## Battery, 2000 mAh

Marked `TY 103450 2000mAh 3.7V 7.4Wh`. Protection board under yellow tape at the lead end, small two-pin plug.

| What | Reading | Notes |
|---|---:|---|
| Length | 52.56 | Including the taped end |
| Width | 33.99 | |
| Thickness | 10.35 | Measured over the taped end, the thickest spot |

This is the cell the hull is built for. The cavity is 13 mm high: 1 mm of foam tape, the cell, and 1.65 mm above it.

## Battery, 1000 mAh

Marked `603048 3.7V 1000mAh`.

| What | Reading | Notes |
|---|---:|---|
| Length × width | 50 × 30 | From the earlier CAD, not re-measured |
| Thickness | | Not measured, about 6. This cell is not the one in the hull |

## ESP32, LOLIN32 Lite

| What | Reading | Notes |
|---|---:|---|
| Length | 49.22 | |
| Width | 25.70 | |
| Micro-USB centre to the long edge beside pin `13` | about 6 | Read off a video frame of the board in the printed base, good to about half a mm. The model uses 5.85 and its opening leaves 0.9 mm on either side of a 10.7 mm wide plug |
| Board plus micro-USB socket | 3.77 | A micro-USB socket is about 2.6 high, so the board is about 1.2 and the socket's centre sits about 2.5 above the board's underside |
| Board plus the white battery socket, the tallest part | 6.75 | |
| Length with a jaw on the sockets | 49.22 | Same as the length above, so that reading is over the sockets: they end flush with the board edge or stand proud of it, and 49.22 is what has to fit |

Seen in the photos: two mounting holes, one in the corner beside `VP` at the antenna end and one beside pin `13` at the USB end. The micro-USB sits on the `3V … 13` side, the white battery socket on the `VP … G` side, the reset button between them.

## Charger, TP4056 with USB-C

| What | Reading | Notes |
|---|---:|---|
| Width | 17.40 | The earlier CAD had 16 |
| Length over the USB-C socket | 28.87 | Measured again after the board sat loose in a print. The first reading, 28.13, was wrong |
| Board length, without the socket | 27.16 | Measured again. The first reading, 27.78, was wrong, and left the board 0.6 mm of room to slide |
| USB-C socket past the board edge | 1.71 | 28.87 minus 27.16. By eye about 1.8. The socket reaches through the 1.6 mm wall to just inside the outer face |
| Notch in the rear edge, between the corners | about 11.5 × 1.8 | Read off a photo, not measured. Only the two corners, about 2 mm wide each, reach the full 27.16 |
| Board plus USB-C socket | 4.19 | A USB-C socket is about 3.2 high, so the board is about 1.0 and the socket's centre sits about 2.6 above the board's underside |

## Driver and IMU

| What | Reading | Notes |
|---|---:|---|
| DRV8833 board | 18.40 × 15.95 | Marked `HW-627`. The two rows of six pads run along the 15.95 edges, 18.40 apart, so the board rests on its 18.40 edges |
| DRV8833 total thickness | | Not measured, about 3. Its keeper in the lid stays 2.4 above the board |
| MPU-6050 board | 20 × 15.5 | From the earlier CAD |
| MPU-6050 total thickness | | Not measured, about 3. Its keeper in the lid stays 2.4 above the board |

## Status LED and buzzer

| What | Reading | Notes |
|---|---:|---|
| RGB LED, across the dome | 9.92 | Milky white, four legs |
| RGB LED, across the collar at its base | 10.86 | |
| RGB LED, tip of the dome to the base | 13.70 | Without the legs |
| Buzzer, diameter | 11.70 | Black, two pins, `+` marked on top |
| Buzzer, height | 9.47 | Without the pins |

Not known: whether the LED is common cathode or common anode, and whether the buzzer is active or passive. Neither changes the hull.
