// minibot chassis — parametric, invertible, fully enclosed
//
// Two identical tray plates that join open-face to open-face into a
// closed box. Each plate has a 3 mm floor + 6 mm half-walls; together
// they form an 18 mm tall enclosure with a 12 mm internal cavity.
//
// Motors mount with shafts pointing OUTWARD toward the side walls.
// Wheels are mounted on the shafts close to (but inside) the side
// walls; they poke through cutouts in the top and bottom plates only,
// so nothing protrudes laterally.
//
//   openscad --export-format=stl -o plate.stl docs/cad/chassis.scad
//
// The chassis is invertible — print this same shape twice.

// ─── parameters ──────────────────────────────────────────────────────

// Outer footprint
plate_length = 136;     // mm — front-to-back (extra length up front for the driver)
plate_width  = 110;     // mm — side-to-side
plate_thick  = 3;       // mm — flat floor thickness

// Walls — 6 mm tall on each plate, meeting in the cavity centreline
wall_thick       = 3;
wall_half_height = 6;

// N20 motor body (steel can only)
motor_diameter   = 12.2;
motor_length     = 25;
motor_axle_pitch = 70;  // mm — front-rear motor spacing
motor_track      = 35;  // mm — side-to-side motor spacing (centre to centre)

// Pocket geometry (half-cylinder cut into the plate)
pocket_depth     = motor_diameter / 2;
pocket_clearance = 0.3;

// Wheels (SLT20 33×20mm). Wheels mount on the shafts pointing OUTWARD
// from the motor body, hub flush with the motor's gearbox face, so
// the wheel's Y centre is one half-width past the motor's outer face.
wheel_diameter  = 33;
wheel_width     = 20;
wheel_clearance = 1.0;

// Electronics
esp_length = 52;
esp_width  = 25;
esp_pocket_depth = 2;

driver_length = 22;
driver_width  = 22;
driver_pocket_depth = 2;

battery_length = 45;
battery_width  = 25;
battery_pocket_depth = 2;

// GY-521 (MPU6050) IMU breakout
imu_length = 21;
imu_width  = 16;
imu_pocket_depth = 2;

// Corner mount holes (M3 heat-set inserts)
mount_hole_d     = 3.2;
mount_hole_inset = 7;

// Micro-USB slot in the front wall
usb_slot_width  = 12;
usb_slot_height = 6;

// Render resolution
$fa = 4;
$fs = 0.5;


// ─── derived geometry ────────────────────────────────────────────────

motor_pocket_d = motor_diameter + pocket_clearance;

// Motor body Y-position (motor centre). Body extends ±motor_length/2 in Y.
motor_center_y = motor_track / 2;

// Wheel Y-position: shaft points outward from motor, wheel hub flush
// with motor's outer face, so wheel centre is at:
//   motor_center_y + motor_length/2 + wheel_width/2
wheel_center_y = motor_center_y + motor_length / 2 + wheel_width / 2;

motor_positions = [
  [-motor_axle_pitch / 2,  motor_center_y],   // front-left
  [-motor_axle_pitch / 2, -motor_center_y],   // front-right
  [ motor_axle_pitch / 2,  motor_center_y],   // rear-left
  [ motor_axle_pitch / 2, -motor_center_y],   // rear-right
];

wheel_positions = [
  [-motor_axle_pitch / 2,  wheel_center_y],
  [-motor_axle_pitch / 2, -wheel_center_y],
  [ motor_axle_pitch / 2,  wheel_center_y],
  [ motor_axle_pitch / 2, -wheel_center_y],
];

wheel_cutout_x = 30;   // wheel cross-section at plate level (~28mm) + margin
wheel_cutout_y = wheel_width + 2;


// ─── modules ─────────────────────────────────────────────────────────

module motor_pocket(pos)
{
  // Half-cylinder along Y axis cut into the floor
  translate([pos[0], pos[1], plate_thick - pocket_depth])
    rotate([90, 0, 0])
      cylinder(d=motor_pocket_d, h=motor_length, center=true);
}

module wheel_cutout(pos)
{
  // Rounded-rectangle slot through the plate
  translate([pos[0], pos[1], -1])
    linear_extrude(plate_thick + 2)
      offset(r=2)
        square([wheel_cutout_x - 4, wheel_cutout_y - 4], center=true);
}

module rect_pocket(w, l, depth, x=0, y=0)
{
  translate([x, y, plate_thick - depth])
    linear_extrude(depth + 1)
      square([l, w], center=true);
}

module mount_holes()
{
  for (sx = [-1, 1]) for (sy = [-1, 1])
    translate([
      sx * (plate_length / 2 - mount_hole_inset),
      sy * (plate_width  / 2 - mount_hole_inset),
      -1
    ])
      cylinder(d=mount_hole_d, h=plate_thick + wall_half_height + 2);
}

module usb_slot()
{
  // Slot through the back wall (+X), centred. The ESP32's micro-USB
  // connector reaches it through a short internal cable / extension.
  translate([
    plate_length / 2 - wall_thick - 0.1,
    -usb_slot_width / 2,
    plate_thick + (wall_half_height - usb_slot_height) / 2
  ])
    cube([wall_thick + 0.2, usb_slot_width, usb_slot_height]);
}

module plate()
{
  difference() {
    union() {
      // Floor
      translate([-plate_length / 2, -plate_width / 2, 0])
        cube([plate_length, plate_width, plate_thick]);
      // Walls
      difference() {
        translate([-plate_length / 2, -plate_width / 2, 0])
          cube([plate_length, plate_width, plate_thick + wall_half_height]);
        translate([
          -plate_length / 2 + wall_thick,
          -plate_width  / 2 + wall_thick,
          plate_thick
        ])
          cube([
            plate_length - 2 * wall_thick,
            plate_width  - 2 * wall_thick,
            wall_half_height + 1
          ]);
      }
    }

    // Motor half-pockets in the floor
    for (p = motor_positions) motor_pocket(p);

    // Wheel cutouts through the plate
    for (p = wheel_positions) wheel_cutout(p);

    // Electronics recesses (rotated for balanced weight distribution):
    //   - TB6612FNG up front between the front wall and the front motor pair
    //   - ESP32 + battery rotated 90° (long axis along Y), placed side-by-side
    //     in the central X strip between the motor pairs
    //   - GY-521 IMU behind the rear motors, near the back-wall USB slot
    rect_pocket(driver_width,  driver_length,  driver_pocket_depth,  x=-53, y=0);
    rect_pocket(esp_length,    esp_width,      esp_pocket_depth,     x=+15, y=0);
    rect_pocket(battery_length, battery_width, battery_pocket_depth, x=-15, y=0);
    rect_pocket(imu_width,     imu_length,     imu_pocket_depth,     x=+53, y=0);

    // USB slot through the front wall
    usb_slot();

    // Corner mount holes
    mount_holes();
  }
}


// ─── render ──────────────────────────────────────────────────────────

plate();
