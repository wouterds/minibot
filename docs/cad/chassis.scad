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
plate_length = 130;     // mm — front-to-back (corner screws clear of the wheels)
plate_width  = 127;     // mm — side-to-side (1 mm tyre-to-wall gap)
plate_thick  = 3;       // mm — flat floor thickness

// Walls — 6 mm tall on each plate, meeting in the cavity centreline
wall_thick       = 2.5;
wall_half_height = 6;

// N20 motor body (measured: 12 mm wide × 10 mm tall when laid on its side)
motor_width      = 12;          // X dimension (lateral when laid flat)
motor_height     = 10;          // Z dimension (perpendicular to plate)
motor_diameter   = motor_width; // legacy alias used by half-cylinder pocket math below
motor_length     = 26;          // body only, excluding shaft (measured)
motor_axle_pitch = 84;  // mm — wheels near the corners; motors closer to the central boards
motor_track      = 48;  // mm — tyres sit 1 mm from the side walls (also clears TP4056)

// Pocket geometry (half-cylinder cut into the plate)
pocket_depth     = motor_diameter / 2;
pocket_clearance = 0.3;

// Wheels (measured: 25 mm outer diameter incl. rubber tire × 23 mm wide).
// Mounted on the motor's long shaft, which runs into the wheel hub.
wheel_diameter  = 25;
wheel_width     = 23;
wheel_clearance = 2.0;

// Electronics
esp_length = 49;
esp_width  = 26;
esp_pocket_depth = 2;

driver_length = 18.5;   // DRV8833 carrier (measured)
driver_width  = 16;
driver_pocket_depth = 2;

battery_length = 50;   // 603048 LiPo: 48 mm nominal, ~50 mm measured incl. sealed lip
battery_width  = 30;
battery_pocket_depth = 2;

// MPU-6050 (MPU6050) IMU breakout
imu_length = 20;
imu_width  = 15.5;
imu_pocket_depth = 2;

// TP4056 USB-C charging + protection board (PCB 26.5mm, +2.5mm for the USB-C connector overhang)
tp4056_length = 29;
tp4056_width  = 16;
tp4056_pocket_depth = 2;

// Corner mount holes (M2.5 heat-set inserts).
mount_hole_d     = 2.7;
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

// Wheel Y-position: the wheel is pushed onto the long shaft until the
// shaft tip is flush with the wheel's OUTER face. The shaft engagement
// equals the wheel width (25 mm), which places the wheel's INNER face
// right at the motor's gearbox face. So:
//   wheel_centre = gearbox_face + wheel_width/2
//                = (motor_center_y + motor_length/2) + wheel_width/2
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

// Wheel cross-section through the plate is widest at the plate's inner
// surface (closest to the wheel centre at z = cavity centre). For a
// 25 mm wheel centred at z = 9 mm in an 18 mm chassis, the chord at
// z = 3 mm (plate top) is 2·sqrt(12.5² − 6²) ≈ 22 mm; round up with
// clearance for the rubber to flex.
wheel_cutout_x = 24;
wheel_cutout_y = wheel_width + 1;  // keeps the slot just clear of the side wall


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

    // Electronics recesses. Battery + ESP32 stack flat in the centre (both
    // ~50 mm long in X, only ±25 mm wide so they clear the corner motors).
    // DRV8833 + MPU-6050 sit on the two sides; TP4056 fills the back centre
    // with its USB-C reaching the back-wall slot.
    rect_pocket(battery_width, battery_length, battery_pocket_depth, x=0,  y=+13);  // 50×30
    rect_pocket(esp_width,     esp_length,     esp_pocket_depth,     x=0,  y=-17);  // 49×26
    rect_pocket(driver_width,  driver_length,  driver_pocket_depth,  x=0,  y=+46);  // 18.5×16
    rect_pocket(imu_width,     imu_length,     imu_pocket_depth,     x=0,  y=-46);  // 20×15.5
    rect_pocket(tp4056_width,  tp4056_length,  tp4056_pocket_depth,  x=48, y=0);    // 29×16

    // USB slot through the front wall
    usb_slot();

    // Corner mount holes
    mount_holes();
  }
}


// ─── render ──────────────────────────────────────────────────────────

plate();
