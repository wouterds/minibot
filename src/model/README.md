# Hull

Two printed shells around everything, 123 × 123 × 16 mm, held together by four M2 screws.

![The hull, closed](../../images/product-hero.jpg)

- **Wheels inside.** Each wheel runs in its own well. The well is a cylinder around the axle, so its wall stays 1.5 mm from the tyre all the way round. The wells are open to both faces and the tyres stand 4.9 mm proud of each, so the bot drives the same on its back. Nothing sticks out sideways, in front or behind.
- **Sealed middle.** The motors and the electronics sit in a closed cavity between the wells. The wheel hubs are hollow, and each motor reaches through the wall of its well so that the front of its gearbox stands 3.4 mm inside its hub. At that depth the tip of the shaft ends flush with the hub's outer face. A small stop on the outer wall of the well faces the shaft tip and keeps the motor and its wheel from sliding outwards.
- **Same either way up.** The shells split on the axle line and everything that goes through a wall is centred on that seam. USB-C for charging sits in the middle of the left side, micro-USB for flashing in the middle of the right side. Front and tail are plain walls, and there is no power switch: the firmware sleeps and the IMU wakes it.
- **Light and sound.** A 10 mm RGB LED lies on the centreline with its dome against the front wall, so the front of the hull glows and shows which end leads. A buzzer lies beside the ESP32. Each sits in a round cradle, half in the base and half in the lid.
- **Screwed shut.** Four M2 × 10 screws into brass heat-set inserts, one beside each wheel, where the wheel loads come in. The two at the front go in through the lid into inserts in the base, the two at the rear through the base into inserts in the lid, so each face shows two heads at one end and the bot looks the same on its back. Each sits in a post that fills the pocket between the motor bay and the end wall; the two halves of a post meet on the seam, so a screw clamps plastic on plastic. The heads sit in recesses, below the faces. A lip runs round the cavity and the whole outer wall and centres the lid.

![The USB-C port, on the seam](../../images/product-detail.jpg)

`minibot.scad` is the whole design. Every dimension is a parameter at the top of the file.

## Layout

![Top view with the lid off](../../images/layout.png)

The red arrow points forward. Both USB sockets sit on the seam, so the cuts for them are the same in both shells.

The wires are drawn loose, in the colours of the [wiring table](../../README.md#wiring), to show where they run: past the two ends of the battery, between the motors and over the small boards. None goes over the battery.

![Cut open across the middle](../../images/section.png)

Cut across the middle, seen from the front: micro-USB and ESP32 on the left of the picture, battery on its foam tape in the middle, charger and USB-C on the right. The ribs coming down from the lid stop just above each part and keep it in place when the bot is on its back.

![Cut open through the front axle](../../images/axle.png)

Cut through the front axle: wheels in their wells, motors between them, each one on two saddles in the base and under two in the lid.

## Printing

| File                  | Qty | Orientation     |
| --------------------- | --- | --------------- |
| `stl/base.stl`        | 1   | outer face down |
| `stl/lid.stl`         | 1   | outer face down |

The STLs are in [`stl/`](../../stl), already in print orientation. No supports: nothing overhangs more than 45°. The two recesses for screw heads in each shell print against the bed with a 1 mm ledge around the screw hole; clean it with the screw if it sags.

![Shells in print orientation](../../images/print.png)

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

Dry the filament first: wet PETG strings.

The two outer faces print on the bed, so they take on its texture. A smooth plate gives clear faces.

## Assembly

1. Press the four brass inserts in with a soldering iron at about 230 °C: two into the front posts of the base, two into the rear posts of the lid. Those are the posts with the wider hole. Each insert goes in from the seam until it sits flush with the top of its post. Let it cool before touching it.
2. Solder everything, outside the hull. See the wiring table in the [main README](../../README.md#wiring).
3. Push a hub onto each motor shaft, open end towards the motor, until the shaft tip is flush with the hub's solid face. Tighten the set screw, then roll the tyre on.
4. Lower each motor into its bay with the wheel in the well. The gearbox drops into the notch in the well wall.
5. Stick a strip of 1 mm foam tape on the floor between the battery fences and press the battery onto it.
6. Lay the boards in their seats: charger with its USB-C in the left wall, driver and IMU on either side of it, ESP32 with its micro-USB in the right wall.
7. Lay the LED in its cradle at the front, dome against the wall, and the buzzer in its cradle beside the ESP32, face against the wall of the wheel well. Turn each so its legs lie flat on the seam: they pass over the low stop behind it.
8. Tuck the wires down. They run past the ends of the battery and between the motors, not over the battery. Keep them clear of the four screw posts.
9. Set the lid on and put in the four M2 × 10 screws, two from above and two from below. Snug is enough: the inserts hold, the plastic around them does not like force.

To open it, take the screws out and twist a coin in one of the four slots on the seam, at the ends next to the wheels.

## Tuning

The parameters most likely to need a change after a first print:

- `motor_w`, `motor_h`, `motor_l`: the motor. `motor_l` runs from the brass front face to the black end cap, without the solder tabs.
- `motor_fit`, `motor_end_fit`, `motor_crush`: room beside and behind the motor, and how far the lid's crush ribs bite into it.
- `wheel_d`, `wheel_w`, `wheel_gap`: the wheel and the room around it. The hull's width follows from these.
- `shaft_l`, `wheel_w`: together they set how far the gearbox stands inside the hub.
- `insert_d`, `insert_l`: the brass insert. Its hole is 0.3 mm narrower than `insert_d`, which is the width over the knurls. This is the one to check with a caliper before printing.
- `screw_l`, `screw_head_d`, `screw_head_h`: the screw. A longer or shorter one than 10 mm does not reach or bottoms out, the model says so.
- `lip_h`: how far the base's lip stands into the lid, 1 mm. Through translucent plastic the overlap shows as a band along the seam, so it is kept low. Raise it if the shells shear apart in a drop.
- `wall`, `skin`: the outer walls and the two faces, both 1.6 mm. The two lips on the seam share the wall, so they are 0.7 mm each; a thinner wall leaves them too thin to print.
- `led_d`, `led_l`, `buzzer_d`, `buzzer_h`: the LED and the buzzer. Their cradles follow.
- `fit`: room around every board, per side. Raise it if a board does not drop into its seat.
- `esp_usb_off`, `esp_usb_h`, `usbc_h`: where the sockets sit on their boards. They decide whether the plugs line up with the openings.
- `usbc_open`, `usb_open`: the openings for the plugs, 13 × 7 mm and 12.5 × 7.5 mm. Both sockets sit behind the wall, so the grip of the plug has to pass through it, not just its metal tip. Widen one if a cable with a fat grip does not go in.

## Commands

- `./check.sh` intersects every pair of parts and prints the volume they share. OpenSCAD does not complain when parts collide, this does.
- `./export.sh` writes the STLs to [`stl/`](../../stl).
- `../render/previews.sh` draws the views of the model.
- `../render/product.sh [shot ...]` ray-traces the product shots (`hero`, `exploded`, `open`, `detail`).
- `../render/wiring.py` draws the wiring diagram.

All pictures land in [`images/`](../../images).

They need the OpenSCAD snapshot build (`brew install --cask openscad@snapshot`) and, for the product shots, `uv`. Blender's renderer comes in through `uv` as a Python package.

After a change to the model, run them all and commit `stl/` and `images/` with the source.

## What is and is not verified

Checked in the model:

- Both shells export as closed solids.
- With everything in place nothing overlaps, except where it is meant to: 3 mm³ where the crush ribs bite into the motors.
- The lid's ribs clear the base with the lid 0.2 mm off-centre in any direction.
- The wires as drawn clear both shells. They are stand-ins, real ones will lie where they fall.

Seen on a first print of the base, without the lid:

- The boards and the motors drop into their seats. With 0.25 mm of room per side they rattled, so the room around them is now 0.1 mm per side. With the lid off they still lift straight out: the base only locates the parts sideways, the lid holds them down.

Not checked yet:

- **The inserts.** Their hole is sized for inserts 3.5 mm wide, a size read off a photo, not measured.
- **Drops.** A wheel that lands hard levers its motor against the lid with about twice the force on the wheel. The screws sit right beside the motors for that, but nothing has been dropped yet.
- **A few dimensions.** Nearly everything is measured, see [`measurements.md`](measurements.md). Still estimated: where the micro-USB sits across the ESP32 (taken from a video frame, good to about half a mm), the inside of the wheel hubs, and the thickness of the driver and IMU boards.
- **Radio range.** The ESP32's antenna ends 5.1 mm from the battery, which is close for a foil pouch.
