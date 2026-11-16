# Hull

Two printed shells that click together around everything, 120 × 120 × 16 mm, no hardware.

![The bot on its wheels and on its back](renders/product-pair.jpg)

- **Wheels inside.** Each wheel runs in its own well. The well is a cylinder around the axle, so its wall stays 1.5 mm from the tyre all the way round. The wells are open to both faces and the tyres stand 4.5 mm proud of each, so the bot drives the same on its back. Nothing sticks out sideways, in front or behind.
- **Sealed middle.** The motors and the electronics sit in a closed cavity between the wells. Each motor lies with its gearbox against the wall of its well and its shaft goes through that wall into the wheel.
- **Same either way up.** The shells split on the axle line and everything that goes through a wall is centred on that seam. USB-C for charging sits in the middle of the left side, micro-USB for flashing in the middle of the right side, with the power switch beside it. Front and tail are plain walls.
- **Click fit.** Eleven snap fingers hang from the lid. Two grip the walls of every motor bay, right where the wheel loads come in, and three hold the side walls. A lip runs round the cavity and the whole outer wall and centres the lid.

`minibot.scad` is the whole design. Every dimension is a parameter at the top of the file.

## Layout

![Top view with the lid off](renders/layout.png)

The red arrow points forward. Both USB sockets and the switch lever sit on the seam, so the cuts for them are the same in both shells.

![Cut open across the middle](renders/section.png)

Cut across the middle, seen from the front: micro-USB and ESP32 on the left of the picture, battery on its foam tape in the middle, charger and USB-C on the right. The ribs coming down from the lid stop just above each part and keep it in place when the bot is on its back.

![Cut open through the front axle](renders/axle.png)

Cut through the front axle: wheels in their wells, motors between them, each one on two saddles in the base and under two in the lid.

## Printing

| File                  | Qty | Orientation     |
| --------------------- | --- | --------------- |
| `stl/base.stl`        | 1   | outer face down |
| `stl/lid.stl`         | 1   | outer face down |
| `stl/coupon-base.stl` | 1   | test piece      |
| `stl/coupon-lid.stl`  | 1   | test piece      |

The STLs are already in print orientation. No supports: nothing overhangs more than 45° except the hooks of the snap fingers and their grooves, which are 55° and under 1 mm deep.

**Print the coupon first.** It is the front right corner of both shells: one wheel well, one motor bay, two snap fingers. It takes about 13 g and shows whether the motor drops in, the wheel clears its well and the click feels right, before 90 g goes into the full shells.

![Shells in print orientation](renders/print.png)

Settings for translucent PETG on a 0.4 mm nozzle, starting from a 0.20 mm standard profile:

| Setting         | Value                              |
| --------------- | ---------------------------------- |
| Layer height    | 0.20 mm                            |
| Wall loops      | 4                                  |
| Order of walls  | inner / outer / inner              |
| Wall generator  | Arachne                            |
| Outer wall      | 60 mm/s                            |
| Top / bottom    | 5 / 5 layers, so the skins are solid |
| Sparse infill   | 15 % gyroid, hardly any is used    |
| Supports, brim  | off                                |

Dry the filament first. Wet PETG strings, and strings between a snap finger and the wall next to it glue the finger down.

The two outer faces print on the bed, so they take on its texture. A smooth plate gives clear faces.

## Assembly

1. Solder everything first, outside the hull. See the wiring table in the [main README](../README.md#wiring).
2. Push a wheel onto each motor shaft, about 3.5 mm from the gearbox, and tighten its set screw.
3. Lower each motor into its bay with the wheel in the well and the shaft in the notch of the well wall. Slide the wheel until it sits in the middle of its well.
4. Stick a strip of 1 mm foam tape on the floor between the battery fences and press the battery onto it.
5. Lay the boards in their seats: charger with its USB-C in the left wall, driver and IMU on either side of it, ESP32 with its micro-USB in the right wall, switch behind its recess beside the ESP32.
6. Tuck the wires down. Keep them off the walls of the motor bays and off the three places on the side walls where the fingers come down.
7. Set the lid on and press down beside each wheel until it clicks, then along the sides.

To open it, twist a coin in one of the slots on the seam. There are four at the ends, next to the wheels, and two on the left side.

## Tuning

The parameters most likely to need a change after the coupon:

- `motor_w`, `motor_h`, `motor_l`: the motor. `motor_l` is gearbox plus can, without the solder tabs. Clones run from 24 to 26 mm.
- `motor_fit`, `motor_crush`: room beside the motor, and how far the lid's crush ribs bite into it.
- `wheel_d`, `wheel_w`, `wheel_gap`: the wheel and the room around it. The hull's width follows from these.
- `shaft_l`: has to reach well into the hub. 3.5 mm of it is used up by the wall and the gap.
- `snap_bump`, `snap_gap`, `snap_t`: how hard the lid clicks. A lid that pops off wants a bigger `snap_bump`; fingers that crack want a thinner `snap_t`.
- `snap_preload`: how firmly a closed lid is pulled down. Raise it if the lid rattles.
- `fit`: room around every board.
- `esp_usb_off`, `esp_usb_h`, `usbc_h`: where the sockets sit on their boards. They decide whether the plugs line up with the openings.

## Commands

- `./render.sh` regenerates the STLs and the preview images in `renders/`.
- `./check.sh` intersects every pair of parts and prints the volume they share. OpenSCAD does not complain when parts collide, this does.
- `./product/render.sh [shot ...]` ray-traces the product shots (`hero`, `pair`, `exploded`, `open`, `detail`).

They need the OpenSCAD snapshot build (`brew install --cask openscad@snapshot`) and, for the product shots, `uv`. Blender's renderer comes in through `uv` as a Python package.

After a change to the model, run all three and commit `stl/` and `renders/` with the source.

## What is and is not verified

Checked in the model:

- Both shells export as closed solids.
- With everything in place nothing overlaps, except where it is meant to: 9 mm³ where the snap fingers stay bent, and 4.5 mm³ where the crush ribs bite into the motors.
- The lid's ribs clear the base with the lid 0.2 mm off-centre in any direction.

Not checked, because none of this has been printed yet:

- **The click.** Its strength depends on the printer and the filament.
- **Drops.** The fingers are printed standing up, which is the weak direction of a print. By calculation they hold roughly 190 N together. A wheel that lands hard levers its motor against the lid with about twice the force on the wheel, so a hard, flat landing on all four wheels may still pop the lid. Drop the coupon before trusting it.
- **Board dimensions.** The motors, the wheels, the battery and the board outlines were measured, as was how far the USB-C socket sticks out of the charger. Where the micro-USB sits on the ESP32, how thick the boards are and the size of the switch come from drawings and photos of similar parts.
- **Radio range.** The ESP32's antenna ends 5.7 mm from the battery, which is close for a foil pouch.
