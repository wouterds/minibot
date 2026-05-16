// minibot chassis — parametric, invertible, fully enclosed
//
// Two identical "tray" plates that join open-face-to-open-face to form a
// closed box. Each plate has 3mm flat floor + 6mm half-walls on its
// perimeter; when stacked they meet in the middle of the 12mm motor
// cavity. Motors mount shaft-inward so the wheels sit ENTIRELY INSIDE
// the chassis perimeter, poking out only through wheel cutouts in the
// top and bottom plates — nothing protrudes from the sides.
//
// Render with OpenSCAD (https://openscad.org):
//
//   openscad --export-format=stl -o plate.stl docs/cad/chassis.scad
//
// Or open in the GUI and hit F6. Both plates are identical (chassis is
// invertible), so you print this one shape twice.

// ─── parameters ──────────────────────────────────────────────────────

plate_kind = "plate";   // [plate, assembly]

// Plate footprint
plate_length = 120;     // mm — front-to-back
plate_width  = 130;     // mm — side-to-side
plate_thick  = 3;       // mm — flat floor thickness

// Walls: each plate has 6mm-tall half-walls that meet the other plate's
// 6mm walls at the cavity centreline, giving a 12mm closed cavity.
wall_thick       = 3;   // mm — wall material thickness
wall_half_height = 6;   // mm — wall height on one plate (×2 = 12mm cavity)

// N20 motor body (the metal can, NOT the gearbox or shaft)
motor_diameter   = 12.2;  // mm — slight clearance fit
motor_length     = 25;    // mm — body length only
motor_axle_pitch = 70;    // mm — front-rear motor spacing (centre to centre)

// Motor body CENTRE Y-position. Motors mount near the side walls with
// shafts pointing inward to the chassis centre. The outer face of the
// motor body sits 4mm inside the wall:
//   motor_center_y = (plate_width/2) - wall_thick - clearance - motor_length/2
motor_center_y   = (plate_width / 2) - wall_thick - 4 - motor_length / 2;
// → for plate_width=130 with 3mm wall, motors centre at y ≈ ±45.5

// Motor pocket geometry
pocket_depth     = motor_diameter / 2;   // half-cylinder = 6.1mm
pocket_clearance = 0.3;

// Wheels (SLT20 33×20mm)
wheel_diameter = 33;
wheel_width    = 20;
wheel_clearance = 1.0;

// Wheel Y-position: wheels mounted on shafts pointing toward chassis
// centre, so wheel sits INSIDE the chassis at:
//   motor body inner face = motor_center_y - motor_length/2
//   then gearbox (~10mm) + shaft engagement (~5mm) inward
wheel_inset_from_motor = 15;     // mm — gearbox + partial shaft
wheel_center_y = motor_center_y - motor_length / 2 - wheel_inset_from_motor;

// Electronics pockets (recessed into the inner face of the plate)
esp_length = 52;
esp_width  = 25;
esp_pocket_depth = 2;

driver_length = 26;
driver_width  = 26;
driver_pocket_depth = 2;

battery_length = 45;
battery_width  = 25;
battery_pocket_depth = 2;

// Mounting holes for M3 screws + heat-set inserts in the corners
mount_hole_d     = 3.2;
mount_hole_inset = 7;

// Side access slot for micro-USB
usb_slot_width  = 12;
usb_slot_height = 6;

// Render resolution
$fa = 4;
$fs = 0.5;


// ─── derived geometry ────────────────────────────────────────────────

motor_pocket_d = motor_diameter + pocket_clearance;

motor_positions = [
  [-motor_axle_pitch / 2,  motor_center_y],   // front-left
  [-motor_axle_pitch / 2, -motor_center_y],   // front-right
  [ motor_axle_pitch / 2,  motor_center_y],   // rear-left
  [ motor_axle_pitch / 2, -motor_center_y],   // rear-right
];

// Wheel hub Y positions (4 wheels mirroring motor sides)
wheel_positions = [
  [-motor_axle_pitch / 2,  wheel_center_y],
  [-motor_axle_pitch / 2, -wheel_center_y],
  [ motor_axle_pitch / 2,  wheel_center_y],
  [ motor_axle_pitch / 2, -wheel_center_y],
];


// ─── modules ─────────────────────────────────────────────────────────

module motor_pocket(pos) {
  // Half-cylinder cut into the plate floor. Axis along Y (lateral),
  // so the motor body lies sideways with its shaft pointing inward.
  translate([pos[0], pos[1], plate_thick - pocket_depth])
    rotate([90, 0, 0])
      cylinder(d=motor_pocket_d, h=motor_length, center=true);
}

module wheel_cutout(pos) {
  // Rounded-rectangle slot in the plate so the wheel can poke through.
  // Wheel rotates around Y axis; its top-down footprint is roughly
  //   (X-width) ≈ 2 * sqrt(R² - z_offset²)   (= ~30mm at mid-plate)
  //   (Y-width) = wheel_width (20mm)
  // Use a generous 35×22 rounded slot for tolerance.
  hull() {
    for (sx = [-1, 1])
      translate([pos[0] + sx * (35/2 - 5), pos[1], -1])
        cylinder(r=5, h=plate_thick + 2);
    for (sx = [-1, 1])
      translate([pos[0] + sx * (35/2 - 5), pos[1], -1])
        translate([0, (wheel_width + 2 - 10)/2, 0])
          cylinder(r=5, h=plate_thick + 2);
  }
  // simpler: just rectangle
  translate([pos[0], pos[1], -1])
    linear_extrude(plate_thick + 2)
      square([35, wheel_width + 2], center=true);
}

module rect_pocket(w, l, depth, x=0, y=0) {
  translate([x, y, plate_thick - depth])
    linear_extrude(depth + 1)
      square([l, w], center=true);
}

module mount_holes() {
  // Screws go through the floor + into the wall above
  for (sx = [-1, 1]) for (sy = [-1, 1])
    translate([
      sx * (plate_length / 2 - mount_hole_inset),
      sy * (plate_width  / 2 - mount_hole_inset),
      -1
    ])
      cylinder(d=mount_hole_d, h=plate_thick + wall_half_height + 2);
}

module usb_slot() {
  // Slot through the front wall
  translate([-plate_length / 2, -usb_slot_width / 2, plate_thick + (wall_half_height - usb_slot_height) / 2])
    cube([wall_thick + 0.1, usb_slot_width, usb_slot_height]);
}

module plate() {
  difference() {
    union() {
      // Flat floor
      translate([-plate_length / 2, -plate_width / 2, 0])
        cube([plate_length, plate_width, plate_thick]);
      // 6mm walls on the perimeter, hollow inside
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

    // Wheel cutouts through the floor (top + bottom plates both have these)
    for (p = wheel_positions) wheel_cutout(p);

    // Electronics recesses
    rect_pocket(esp_width, esp_length, esp_pocket_depth, x=-30, y=0);
    rect_pocket(driver_width, driver_length, driver_pocket_depth, x=20, y=-15);
    rect_pocket(battery_width, battery_length, battery_pocket_depth, x=20, y=15);

    // Side USB slot in the front wall
    usb_slot();

    // Corner mount holes
    mount_holes();
  }
}


// ─── render ──────────────────────────────────────────────────────────

if (plate_kind == "plate") {
  plate();
} else if (plate_kind == "assembly") {
  // Both plates joined open-face-to-open-face for a preview render
  plate();
  translate([0, 0, plate_thick + 2 * wall_half_height])
    mirror([0, 0, 1]) plate();
}
