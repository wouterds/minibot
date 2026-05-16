// minibot chassis — parametric, invertible motor-sandwich design
//
// Render in OpenSCAD (https://openscad.org). Generates two identical
// plates (top + bottom) that sandwich the motors and electronics.
//
//   openscad --export-format=stl -o top.stl    -D 'plate_kind="top"'    chassis.scad
//   openscad --export-format=stl -o bottom.stl -D 'plate_kind="bottom"' chassis.scad
//
// Or just open in the GUI and hit F6 to render.

// ─── parameters ──────────────────────────────────────────────────────

// Which plate to render: "top" or "bottom". Both are geometrically
// identical except for orientation; the chassis is invertible so it
// makes no difference which side is up.
plate_kind = "top";  // [top, bottom]

// Overall plate footprint
plate_length = 110;   // mm — length along travel direction
plate_width  = 80;    // mm — width across wheels
plate_thick  = 3;     // mm

// N20 motor body (the metal can, NOT the gearbox)
motor_diameter   = 12.2;  // mm — slight clearance fit
motor_length     = 25;    // mm — body length, NOT including gearbox/shaft
motor_axle_pitch = 70;    // mm — front-to-rear motor spacing (centre to centre)
motor_track      = 56;    // mm — left-to-right motor spacing (centre to centre)

// Motor pocket: half-cylinder cut into each plate
pocket_depth     = motor_diameter / 2;   // = 6.1mm
pocket_clearance = 0.3;                  // PETG extrudate widens; add slop

// Wheel cutouts on the plate edges
wheel_diameter = 33;
wheel_width    = 20;
wheel_clearance = 1.0;

// Electronics pockets
esp_length = 52;
esp_width  = 25;
esp_pocket_depth = 2;     // recess for the PCB body

driver_length = 26;
driver_width  = 26;
driver_pocket_depth = 2;

// Battery pocket (1S LiPo pouch)
battery_length = 45;
battery_width  = 25;
battery_pocket_depth = 2;

// Mounting holes for M3 screws + heat-set inserts
mount_hole_d = 3.2;
mount_hole_inset = 6;     // distance from plate corner

// Side access slots
usb_slot_width  = 12;     // micro-USB on LOLIN32 needs ~8mm + margin
usb_slot_height = 6;

// Resolution
$fa = 4;
$fs = 0.5;


// ─── derived geometry ────────────────────────────────────────────────

motor_pocket_d = motor_diameter + pocket_clearance;
wheel_well_d   = wheel_diameter + wheel_clearance;

// Motor centre positions (4 motors: front-left, front-right, rear-left, rear-right)
motor_positions = [
  [-motor_axle_pitch/2,  motor_track/2],   // front-left
  [-motor_axle_pitch/2, -motor_track/2],   // front-right
  [ motor_axle_pitch/2,  motor_track/2],   // rear-left
  [ motor_axle_pitch/2, -motor_track/2],   // rear-right
];


// ─── modules ─────────────────────────────────────────────────────────

module motor_pocket(pos) {
  // Half-cylinder lying on its side, axis along the X axis (front-to-back wheel rotation)
  // Pocket cuts UP into the plate from the inner face.
  translate([pos[0], pos[1], plate_thick - pocket_depth])
    rotate([0, 90, 0])
      cylinder(d=motor_pocket_d, h=motor_length, center=true);
}

module wheel_well(side) {
  // Cutout in the plate's outer long edge so the wheel can spin freely.
  // `side` = +1 (left) or -1 (right). One well per motor pair (front + rear gang).
  for (x = [-motor_axle_pitch/2, motor_axle_pitch/2]) {
    translate([x, side * (plate_width/2 - wheel_well_d/4), -1])
      cylinder(d=wheel_well_d, h=plate_thick + 2);
  }
}

module rect_pocket(w, l, depth) {
  // Top-down rectangular pocket cut into the plate's inner face.
  translate([0, 0, plate_thick - depth])
    linear_extrude(depth + 1)
      square([l, w], center=true);
}

module mount_holes() {
  for (sx = [-1, 1]) for (sy = [-1, 1])
    translate([
      sx * (plate_length/2 - mount_hole_inset),
      sy * (plate_width/2  - mount_hole_inset),
      -1
    ])
      cylinder(d=mount_hole_d, h=plate_thick + 2);
}

module usb_slot() {
  // Cutout in the side wall — slot in the long edge near the ESP32 pocket.
  translate([0, -plate_width/2, plate_thick/2])
    rotate([90, 0, 0])
      cylinder(d=usb_slot_height, h=usb_slot_width, center=true);
  translate([0, -plate_width/2, plate_thick/2])
    cube([usb_slot_width, plate_thick + 2, usb_slot_height], center=true);
}

module plate() {
  difference() {
    // Base plate
    translate([-plate_length/2, -plate_width/2, 0])
      cube([plate_length, plate_width, plate_thick]);

    // Motor half-pockets
    for (p = motor_positions) motor_pocket(p);

    // Wheel wells on both long edges
    wheel_well(+1);
    wheel_well(-1);

    // Electronics pockets (centred)
    translate([-15, 12, 0]) rect_pocket(esp_width, esp_length, esp_pocket_depth);
    translate([15, 12, 0])  rect_pocket(driver_width, driver_length, driver_pocket_depth);
    translate([0, -15, 0])  rect_pocket(battery_width, battery_length, battery_pocket_depth);

    // Side USB-access slot (only really needed on one plate but harmless on both)
    translate([-15, 0, 0]) usb_slot();

    // Mounting holes
    mount_holes();
  }
}


// ─── render ──────────────────────────────────────────────────────────

if (plate_kind == "top") {
  plate();
} else if (plate_kind == "bottom") {
  // Bottom is geometrically identical (chassis is invertible).
  // Mirror it for clarity when both are rendered side by side.
  mirror([0, 0, 1]) translate([0, 0, -plate_thick]) plate();
} else {
  // Render both stacked with motor cavity between
  plate();
  translate([0, 0, plate_thick + motor_diameter])
    mirror([0, 0, 1]) translate([0, 0, -plate_thick]) plate();
}
