// minibot hull: a sealed, invertible body for a 4WD skid-steer bot.
//
// Two printed shells that click together, no hardware:
//   base - carries the motors and all electronics, print outer face down
//   lid  - holds everything in place and carries the snap fingers, print outer face down
//
// The wheels live inside the hull, each in its own well that is open to both faces. They stand
// equally proud of the top and the bottom, so the bot drives the same on either face, and
// nothing sticks out sideways, in front or behind. Each motor sits in the sealed middle with
// its gearbox against the wall of its well; the shaft goes through that wall into the wheel.
//
// Coordinates: X forward, Y left, Z up. Origin in the middle of the hull, on the axle line.
// The seam between the shells is the plane Z = 0.

part = "assembly"; // assembly | exploded | open | layout | section | axle | print | base | lid | coupon-base | coupon-lid | none

/* [Drivetrain] */
wheel_d = 25;           // tyre diameter
wheel_w = 23;
wheel_gap = 1.5;        // around the tyre, to the walls of its well
motor_w = 12;           // N20 gearbox, the wide way (lies along X)
motor_h = 10;           // N20 across the flats (stands along Z)
motor_l = 24;           // gearbox plus can, without the solder tabs
motor_tab = 1.8;        // solder tabs behind the can
motor_boss_d = 4;       // bearing boss around the output shaft
shaft_d = 3;
shaft_l = 20;           // from the gearbox face; has to reach well into the wheel hub

/* [Hull] */
wheelbase = 88;
corridor = 11.4;        // between the cans of two motors that face each other
hull_h = 16;
wall = 2;
skin = 2;
chamfer = 1;            // outer edges of both faces
well_lip = 1;           // straight rim of the wheel openings
corner_r = 3;

/* [Electronics: x size, y size, board thickness] */
esp = [26, 49, 1.6];        // LOLIN32 Lite, micro-USB on the -Y end
esp_usb_off = 7;            // micro-USB centre from the board centreline, towards +X
esp_usb_h = 2.6;            // micro-USB socket height above the board
bat = [50, 30, 6];          // 603048 LiPo
bat_pad = 1;                // foam tape that sticks the battery to the floor
tp = [16, 26.5, 1.2];       // TP4056 USB-C charger, USB-C on the +Y end
usbc_h = 3.2;               // USB-C socket height above the board
usbc_over = 2.5;            // how far that socket sticks out past the board
drv = [16, 18.5, 1.6];      // DRV8833
imu = [15.5, 20, 1.6];      // GY-521 (MPU-6050)
sw = [8.5, 3.5, 3.5];       // SS12D00 slide switch: length, height, depth along the lever
sw_lever = 3;               // how far the lever stands out of the body
sw_slot = [4.4, 2];         // opening for the lever and its travel

/* [Fit] */
fit = 0.25;             // clearance around a board, per side
motor_fit = 0.2;        // beside the motor, per side
motor_crush = 0.1;      // how far the lid's crush ribs bite into the motor
motor_end_fit = 0.3;    // behind the motor
lap_gap = 0.2;          // between the lips of the two shells
lip_h = 2;              // height of the lip that centres the lid on the base

/* [Snap fingers] */
snap_t = 1.1;
snap_gap = 0.6;         // between a finger and the wall it runs along
snap_bump = 1.2;        // hook height; it reaches snap_bump - snap_gap into the wall
snap_lead = 35;         // closing flank, degrees from the push direction
snap_ret = 55;          // holding flank
snap_preload = 0.15;    // how far a finger stays bent once the lid is down
snap_bay_w = 14;        // fingers beside the motors, two per motor
snap_side_w = 10;       // fingers on the side walls
snap_sides = [["+y", 17], ["+y", -17], ["-y", 17]];

/* [Hidden] */
e = 0.01;
$fa = 3;
$fs = 0.3;
rib = 1.2;
bay_rib = 2;            // walls of the motor bays; the lid's fingers hook into them
stop_t = 1;
lap_in = 0.9;

axle_x = wheelbase / 2;
well_r = wheel_d / 2 + wheel_gap;
gear_y = corridor / 2 + motor_end_fit + motor_l;   // gearbox face, on the inside of the well wall
well_y0 = gear_y + wall;
well_y1 = well_y0 + wheel_w + 2 * wheel_gap;
wheel_y = (well_y0 + well_y1) / 2;
hull_w = 2 * (well_y1 + wall);
hull_l = wheelbase + 2 * (well_r + wall);
protrusion = (wheel_d - hull_h) / 2;          // tyre past the hull, on both faces

// The cavity is a plus: a band between the wells that runs the full length, and a middle
// section between the front and the rear wells that runs the full width.
in_x = hull_l / 2 - wall;
in_y = hull_w / 2 - wall;
in_z = hull_h / 2 - skin;
mid_x = axle_x - well_r - wall;
bay_x0 = axle_x - motor_w / 2 - motor_fit;
bay_x1 = axle_x + motor_w / 2 + motor_fit;
motor_rear_y = corridor / 2;

// Layout across the middle section, right to left: ESP32 with its micro-USB in the right wall,
// battery lengthwise in the middle, charger with its USB-C in the left wall, driver and IMU
// on either side of the charger. Both USB ports sit at x = 0.
esp_cx = -esp_usb_off;
esp_x0 = esp_cx - esp[0] / 2;
esp_x1 = esp_cx + esp[0] / 2;
esp_y0 = -in_y + 0.3;
esp_y1 = esp_y0 + esp[1];
esp_z1 = -esp_usb_h / 2;                      // board top, puts the micro-USB socket on the seam
esp_z0 = esp_z1 - esp[2];
tp_y1 = in_y + wall - usbc_over - 0.3;         // the socket's mouth ends just inside the hull's face
tp_y0 = tp_y1 - tp[1];
tp_half = tp[0] / 2 + fit;
tp_stop = 2.4;                                // takes the push of a plug going in
// the battery sits as far from the ESP32's antenna as the charger lets it
bat_half = bat[0] / 2 + 0.75;
bat_y1 = tp_y0 - fit - tp_stop;
bat_y0 = bat_y1 - bat[1] - 1;                 // 1 mm for a cell that has swollen a little
bat_cy = (bat_y0 + bat_y1) / 2;
bat_z0 = -in_z + bat_pad;
tp_z1 = -usbc_h / 2;                          // board top, puts the USB-C socket on the seam
tp_z0 = tp_z1 - tp[2];
pod_x0 = tp_half + 1 + fit;                   // inner edge of the driver and of the IMU
pod_y0 = gear_y + 1.5;                        // their end towards the middle
board_z0 = -in_z + 1.5;                       // their underside
fence_z = -in_z + 3.5;                        // top of the low fences
sw_z = sw[1] / 2;
sw_wall = sw_lever - wall;                    // pad that sets the switch back until its lever ends flush
sw_recess = [14, 5];
snap_bay_y = gear_y - 4 - snap_bay_w / 2;

usbc_open = [14, 8.5];
usb_open = [13.5, 9];

assert(protrusion >= 2, "wheels barely clear the hull");
assert(wall + wheel_gap + 6 <= shaft_l, "shaft too short to hold the wheel");
assert(esp_x0 - fit - rib >= -mid_x && esp_x1 + fit + rib <= mid_x, "ESP32 does not fit between the wells");
assert(bat_y0 - fit - rib >= esp_y1 + fit + rib, "battery runs into the ESP32");
assert(bat_half + rib <= bay_x0 - bay_rib - snap_gap - snap_t - 1, "battery runs into the snap fingers");
assert(sw_wall >= 0, "switch lever is shorter than the wall is thick");
assert(pod_x0 + max(drv[0], imu[0]) + fit <= mid_x, "driver or IMU does not fit beside the charger");

echo(str("hull (l x w x h): ", hull_l, " x ", hull_w, " x ", hull_h));
echo(str("tyres stand ", protrusion, " mm proud of both faces, ", wheel_gap, " mm clear of their wells"));
echo(str("shaft inside the wheel: ", shaft_l - wall - wheel_gap, " mm"));

// ---------- helpers ----------

module box(xr, yr, zr) {
  translate([xr[0], yr[0], zr[0]]) cube([xr[1] - xr[0], yr[1] - yr[0], zr[1] - zr[0]]);
}

module sym_x() {
  children();
  mirror([1, 0, 0]) children();
}

module sym_y() {
  children();
  mirror([0, 1, 0]) children();
}

module quadrants() {
  sym_x() sym_y() children();
}

module rrect(l, w, r) {
  offset(r = r) square([l - 2 * r, w - 2 * r], center = true);
}

module chamfer_box(l, w, h, r, c) {
  hull() {
    linear_extrude(h - 2 * c, center = true) rrect(l, w, r);
    linear_extrude(h, center = true) rrect(l - 2 * c, w - 2 * c, max(r - c, 0.05));
  }
}

module below() {
  intersection() {
    children();
    translate([-500, -500, -500]) cube([1000, 1000, 500]);
  }
}

module above() {
  intersection() {
    children();
    translate([-500, -500, 0]) cube([1000, 1000, 500]);
  }
}

// rounded hole of w x h through a wall; dir is the axis it runs along
module port(pos, dir, w, h, depth, r = 1) {
  translate(pos) rotate(dir == "x" ? [90, 0, 90] : [90, 0, 0])
    linear_extrude(depth, center = true) rrect(w, h, r);
}

// places a profile drawn as [distance into the cavity, z] against an outer wall and extrudes it along that wall
module at_wall(side, along, w) {
  if (side == "+y" || side == "-y")
    translate([along, (side == "+y" ? 1 : -1) * in_y, 0]) mirror([0, side == "+y" ? 1 : 0, 0])
      rotate([90, 0, 90]) linear_extrude(w, center = true) children();
  else
    translate([(side == "+x" ? 1 : -1) * in_x, along, 0]) mirror([side == "+x" ? 1 : 0, 0, 0])
      rotate([90, 0, 0]) linear_extrude(w, center = true) children();
}

// things on the rear wall are drawn against the left wall and turned a quarter
module at_tail() {
  rotate([0, 0, 90]) children();
}

// ---------- shell ----------

module cavity(grow = 0) {
  g = 2 * grow;
  cube([2 * in_x + g, 2 * gear_y + g, 2 * in_z + g], center = true);
  cube([2 * mid_x + g, 2 * in_y + g, 2 * in_z + g], center = true);
}

// A well is a cylinder around the axle, so its wall follows the tyre at the same distance all
// the way round and the opening in each face is no wider than it has to be. The last well_lip
// of each face is cut straight down, which leaves the rim of the opening blunt instead of sharp.
module wells() {
  lip_x = sqrt(well_r ^ 2 - (hull_h / 2 - well_lip) ^ 2);
  quadrants() translate([axle_x, well_y0, 0]) {
    rotate([-90, 0, 0]) cylinder(r = well_r, h = well_y1 - well_y0);
    translate([-lip_x, 0, -hull_h]) cube([2 * lip_x, well_y1 - well_y0, 2 * hull_h]);
  }
}

module shell() {
  difference() {
    chamfer_box(hull_l, hull_w, hull_h, corner_r, chamfer);
    cavity();
    wells();
  }
}

module inner_outline(grow = 0) {
  offset(delta = grow) {
    square([2 * in_x, 2 * gear_y], center = true);
    square([2 * mid_x, 2 * in_y], center = true);
  }
}

module perimeter(grow = 0) {
  offset(delta = grow) square([2 * in_x, 2 * in_y], center = true);
}

// The walls overlap at the seam: the base keeps the inner half and stands lip_h into the lid,
// the lid keeps the outer half. That centres the lid, stops the shells shearing apart and closes
// the seam to light and dust. The lip runs round the cavity and round the whole outer wall,
// so the frames around the wells are tied together as well.
module tongue() {
  linear_extrude(lip_h) {
    difference() {
      inner_outline(lap_in);
      inner_outline();
    }
    difference() {
      perimeter(lap_in);
      perimeter();
    }
  }
}

module rebate() {
  translate([0, 0, -e]) linear_extrude(lip_h + 0.3 + e) {
    inner_outline(lap_in + lap_gap);
    difference() {
      perimeter(lap_in + lap_gap);
      perimeter(-0.3);
    }
  }
}

// room for the base's lip where a rib of the lid runs up to a wall
module lip_relief() {
  translate([0, 0, -e]) linear_extrude(lip_h + 0.3 + e) difference() {
    inner_outline(lap_in + lap_gap);
    inner_outline(-0.3);
  }
}

// Everything that goes through a wall is centred on the seam, so both shells get the same cut.
module openings() {
  d = motor_boss_d + 0.8;
  // drive shafts, through the well walls
  quadrants() port([axle_x, gear_y + wall / 2, 0], "y", d, d, wall + 1, d / 2 - e);
  // USB-C charging, left side
  port([0, hull_w / 2 - wall / 2, 0], "y", usbc_open[0], usbc_open[1], wall + 1, 1.5);
  // micro-USB for flashing, right side
  port([0, -hull_w / 2 + wall / 2, 0], "y", usb_open[0], usb_open[1], wall + 1, 1.5);
  // power switch, in the tail: a recess as deep as the wall, with the lever slot in its floor.
  // The lever ends flush with the hull, so a crash cannot flick or shear it.
  port([-hull_l / 2, 0, 0], "x", sw_recess[0], sw_recess[1], 2 * wall, 1.5);
  port([-in_x, 0, 0], "x", sw_slot[0], sw_slot[1], 2 * sw_wall + 2, 0.5);
}

// The base's lip has to let the shafts, the plugs and the switch lever through.
module tongue_gaps() {
  h = [0, lip_h + e];
  quadrants() translate([axle_x, gear_y, 0]) box([-motor_boss_d / 2 - 0.8, motor_boss_d / 2 + 0.8], [-1, 2], h);
  translate([0, in_y, 0]) box([-usbc_open[0] / 2 - 0.5, usbc_open[0] / 2 + 0.5], [-1, 2], h);
  translate([0, -in_y, 0]) box([-usb_open[0] / 2 - 0.5, usb_open[0] / 2 + 0.5], [-2, 1], h);
  translate([-in_x, 0, 0]) box([-2, 1], [-sw_recess[0] / 2 - 0.5, sw_recess[0] / 2 + 0.5], h);
}

// ---------- snap fit ----------

snap_tip_z = -in_z + 1.2;
snap_apex_z0 = snap_tip_z + (snap_bump - 0.3) / tan(snap_lead);
snap_apex_z1 = snap_apex_z0 + 0.3;
snap_ret_h = snap_bump / tan(snap_ret);
snap_slope = snap_ret_h / snap_bump;   // of the holding flank

// A finger hangs from the lid's ceiling and runs down beside a wall of the base. Its hook passes
// the top of that wall bent away from it and springs into a groove near the floor. Drawn as
// [distance from the wall, z].
module finger_profile() {
  g = snap_gap;
  t = snap_t;
  polygon([
    [g - 0.3, snap_tip_z], [g + t - 0.4, snap_tip_z], [g + t, snap_tip_z + 0.4],
    [g + t, in_z - 1], [g + t + 1, in_z + 0.05], [g, in_z + 0.05],
    [g, snap_apex_z1 + snap_ret_h], [g - snap_bump, snap_apex_z1], [g - snap_bump, snap_apex_z0],
  ]);
}

// The groove's holding flank sits snap_preload lower than the hook's, so a seated finger stays
// bent and keeps pulling the lid down onto the base. No rattle. Below the flank the groove runs
// straight down to the floor.
module groove_profile() {
  depth = snap_bump - snap_gap + 0.15;
  z0 = snap_apex_z1 + snap_slope * (snap_bump - snap_gap) - snap_preload * snap_slope;
  polygon([[0.05, z0 + 0.05 * snap_slope], [-depth, z0 - depth * snap_slope], [-depth, -in_z - e], [0.05, -in_z - e]]);
}

// Puts a profile at every snap: on both sides of each motor bay, where the wheels' loads come
// in, and on the side walls. wider makes it that much longer than the finger.
module snaps(wider = 0) {
  quadrants() {
    translate([bay_x0 - bay_rib, snap_bay_y, 0]) mirror([1, 0, 0])
      rotate([90, 0, 0]) linear_extrude(snap_bay_w + wider, center = true) children();
    translate([bay_x1 + bay_rib, snap_bay_y, 0])
      rotate([90, 0, 0]) linear_extrude(snap_bay_w + wider, center = true) children();
  }
  for (s = snap_sides) at_wall(s[0], s[1], snap_side_w + wider) children();
}

module snap_fingers() {
  snaps() finger_profile();
}

module snap_grooves() {
  snaps(1) groove_profile();
}

// Slots on the seam, near the fingers: twist a coin in one to lift the lid there.
module pry_slots() {
  sym_x() sym_y() port([hull_l / 2, snap_bay_y, 0], "x", 12, 2.2, 2, 0.4);
  for (s = snap_sides) port([s[1], (s[0] == "+y" ? 1 : -1) * hull_w / 2, 0], "y", 12, 2.2, 2, 0.4);
}

// ---------- motor bays ----------

// Front left bay, base half. The motor lies along Y with its gearbox against the well wall.
// A wheel that hits the floor levers its motor against the saddles, so they sit as far apart
// as the motor is long.
saddle_y = [gear_y - 2.5, motor_rear_y + 1.5];

module motor_bay() {
  // walls in front of and behind the motor
  box([bay_x0 - bay_rib, bay_x0], [motor_rear_y - stop_t, gear_y + e], [-in_z - e, -0.1]);
  box([bay_x1, bay_x1 + bay_rib], [motor_rear_y - stop_t, gear_y + e], [-in_z - e, -0.1]);
  for (y = saddle_y) box([bay_x0 - e, bay_x1 + e], [y - 1, y + 1], [-in_z - e, -motor_h / 2]);
  motor_stop();
}

// behind the can; it stays low so the solder tabs and the wires pass over it
module motor_stop() {
  box([bay_x0 - e, bay_x1 + e], [motor_rear_y - stop_t, motor_rear_y], [-in_z - e, -3.2]);
}

// Lid half, drawn upside down. The fingers stand where the base has its walls. The saddles stop
// short of the motor and carry a thin rib each that bites into it, which takes up the tolerance
// of the motor without holding the lid off.
module motor_cap() {
  for (y = saddle_y) {
    box([bay_x0 - e, bay_x1 + e], [y - 1, y + 1], [-in_z - e, -motor_h / 2 - 0.2]);
    box([bay_x0 - e, bay_x1 + e], [y - 0.3, y + 0.3], [-in_z - e, -motor_h / 2 + motor_crush]);
  }
  motor_stop();
}

// ---------- base ----------

module charger_seat() {
  sym_x() {
    // rails under the long edges, clear of the solder pads at the inner end
    box([tp[0] / 2 - 1, tp_half + 1], [tp_y0 + 6, in_y + e], [-in_z - e, tp_z0]);
    // fence beside the board
    box([tp_half, tp_half + 1], [tp_y0 - fit, in_y + e], [-in_z - e, tp_z1 + 0.6]);
  }
  // end stop, between the battery pads; it takes the push of a plug going in
  box([-3, 3], [tp_y0 - fit - tp_stop, tp_y0 - fit], [-in_z - e, tp_z1 + 0.6]);
}

// seat for a small board beside the charger, long side along Y: a ledge under each short end,
// a fence at each end and one towards the well
module board_seat(size) {
  x1 = pod_x0 + size[0];
  cx = (pod_x0 + x1) / 2;
  y1 = pod_y0 + size[1];
  for (y = [pod_y0 - fit, y1 - 1]) box([cx - 5, cx + 5], [y, y + 1 + fit], [-in_z - e, board_z0]);
  box([cx - 5, cx + 5], [pod_y0 - fit - rib, pod_y0 - fit], [-in_z - e, fence_z]);
  box([cx - 5, cx + 5], [y1 + fit, y1 + fit + rib], [-in_z - e, fence_z]);
  box([x1 + fit, mid_x + e], [pod_y0, y1], [-in_z - e, fence_z]);
}

module esp_seat() {
  top = esp_z1 + 0.6;
  // antenna end: ledge and stop
  box([esp_x0 + 1, esp_x1 - 1], [esp_y1 - 1, esp_y1 + fit + rib], [-in_z - e, esp_z0]);
  box([esp_x0 - fit - rib, esp_x1 + fit + rib], [esp_y1 + fit, esp_y1 + fit + rib], [-in_z - e, top]);
  // USB end: ledges under the long edges, where there are no header pads
  for (x = [esp_x0 - fit, esp_x1 - 1])
    box([x, x + 1 + fit], [-in_y - e, esp_y0 + 9], [-in_z - e, esp_z0]);
  // posts beside the long edges, near both ends; the middle stays open for the wires
  for (x = [esp_x0 - fit - rib, esp_x1 + fit], y = [[-in_y - e, esp_y0 + 9], [esp_y1 - 9, esp_y1 + fit + rib]])
    box([x, x + rib], y, [-in_z - e, top]);
}

module battery_seat() {
  // towards the ESP32 and towards the charger
  for (y = [bat_y0 - rib, bat_y1]) box([-20, 20], [y, y + rib], [-in_z - e, fence_z]);
  // ends, open in the middle for the leads
  sym_x() for (y = [[bat_y0 - rib, bat_cy - 5], [bat_cy + 5, bat_y1 + rib]])
    box([bat_half, bat_half + rib], y, [-in_z - e, fence_z]);
}

// drawn against the left wall; wall_y is the inside of that wall
module switch_seat(wall_y) {
  l = sw[0] / 2 + 0.15;
  y0 = wall_y - sw[2] - 0.2;
  // floor under the body
  box([-l - rib, l + rib], [y0 - rib, wall_y + e], [-in_z - e, -sw_z - 0.1]);
  // ends, and two posts behind the body that leave the pins free
  for (s = [-1, 1]) {
    translate([s * (l + rib / 2), 0, 0]) box([-rib / 2, rib / 2], [y0 - rib, wall_y + e], [-in_z - e, 1]);
    translate([s * (l - 0.5), 0, 0]) box([-0.8, 0.8], [y0 - rib, y0], [-in_z - e, 1]);
  }
}

module base_fittings() {
  charger_seat();
  board_seat(drv);
  mirror([1, 0, 0]) board_seat(imu);
  esp_seat();
  battery_seat();
  at_tail() {
    switch_seat(in_x - sw_wall);
    switch_pad([-in_z - e, 0]);
  }
}

// behind the switch recess the wall is a pad in each shell, with the lever slot in it
module switch_pad(zr) {
  box([-sw_recess[0] / 2 - 1, sw_recess[0] / 2 + 1], [in_x - sw_wall, in_x + e], zr);
}

module base() {
  difference() {
    union() {
      below() shell();
      tongue();
      intersection() {
        cavity(0.05);
        union() {
          quadrants() motor_bay();
          base_fittings();
        }
      }
    }
    openings();
    tongue_gaps();
    snap_grooves();
    pry_slots();
  }
}

// ---------- lid ----------

// rib from the ceiling down to z
module keeper(xr, yr, z) {
  box(xr, yr, [z, in_z + e]);
}

// Blades that reach over both short ends of a board lying with its long side along Y. They
// start inside the board's edge, so a lid that sits a little off never lands on a fence.
module end_keepers(cx, y0, y1, z) {
  keeper([cx - 3, cx + 3], [y0 + 0.2, y0 + 1.1], z);
  keeper([cx - 3, cx + 3], [y1 - 1.1, y1 - 0.2], z);
}

module lid_fittings() {
  // charger: on the USB-C shell, and on the board edge between the battery pads
  keeper([-3, 3], [tp_y1 - 4.5, tp_y1 - 0.5], -tp_z1 + 0.2);
  keeper([-2, 2], [tp_y0 + 0.2, tp_y0 + 1.1], tp_z1 + 0.3);
  // driver and IMU
  end_keepers(pod_x0 + drv[0] / 2, pod_y0, pod_y0 + drv[1], board_z0 + drv[2] + 0.3);
  end_keepers(-pod_x0 - imu[0] / 2, pod_y0, pod_y0 + imu[1], board_z0 + imu[2] + 0.3);
  // ESP32: on the micro-USB shell, and on the bare antenna end
  keeper([-3, 3], [esp_y0 + 0.3, esp_y0 + 4.3], -esp_z1 + 0.2);
  keeper([esp_cx - 5, esp_cx + 5], [esp_y1 - 1.1, esp_y1 - 0.2], esp_z1 + 0.3);
  // battery: a backstop, the foam tape under it does the holding
  for (y = [-8, 8]) keeper([-20, 20], [bat_cy + y - rib / 2, bat_cy + y + rib / 2], bat_z0 + bat[2] + 0.7);
  // switch
  at_tail() keeper([-sw[0] / 2 + 0.2, sw[0] / 2 - 0.2], [in_x - sw_wall - sw[2], in_x - sw_wall + e], sw_z + 0.15);
}

module lid() {
  difference() {
    union() {
      difference() {
        above() shell();
        rebate();
      }
      difference() {
        intersection() {
          cavity(0.05);
          union() {
            mirror([0, 0, 1]) quadrants() motor_cap();
            lid_fittings();
          }
        }
        lip_relief();
      }
      snap_fingers();
      at_tail() switch_pad([0, 4]);
    }
    openings();
    pry_slots();
  }
}

// ---------- stand-ins for the bought parts ----------

c_hull = [0.80, 0.90, 0.96, 0.45];
c_shell = "#cfe3ee";
c_pcb = "#1d2b36";
c_metal = "#b9bcc2";
c_brass = "#c9a54a";
c_dark = "#1b1c1f";
c_tyre = "#26272b";

// The section views draw every part as the slice of it that lies in the plane x = slice_x, seen
// from the front, each in its own colour.
slice_x = part == "section" ? 0 : part == "axle" ? axle_x : undef;

module col(c) {
  color(c)
    if (is_undef(slice_x)) children();
    else linear_extrude(0.1) projection(cut = true)
      multmatrix([[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, -slice_x]]) children();
}

// front left motor
module motor_brass() {
  translate([axle_x, 0, 0]) {
    box([-motor_w / 2, motor_w / 2], [gear_y - 9, gear_y], [-motor_h / 2, motor_h / 2]);
    for (x = [-3.45, 3.45]) box([x - 0.75, x + 0.75], [gear_y - motor_l - motor_tab, gear_y - motor_l], [-0.2, 0.2]);
  }
}

module motor_steel() {
  translate([axle_x, 0, 0]) {
    intersection() {
      translate([0, gear_y - 9, 0]) rotate([90, 0, 0]) cylinder(d = motor_w, h = motor_l - 9);
      box([-motor_w / 2, motor_w / 2], [gear_y - motor_l, gear_y - 9], [-motor_h / 2, motor_h / 2]);
    }
    translate([0, gear_y - e, 0]) rotate([-90, 0, 0]) {
      cylinder(d = motor_boss_d, h = 0.7);
      cylinder(d = shaft_d, h = shaft_l);
    }
  }
}

module tyre() {
  translate([axle_x, wheel_y, 0]) rotate([90, 0, 0]) difference() {
    cylinder(d = wheel_d, h = wheel_w - 4, center = true);
    cylinder(d = wheel_d - 8, h = wheel_w, center = true);
  }
}

module wheel_hub() {
  translate([axle_x, wheel_y, 0]) rotate([90, 0, 0]) difference() {
    union() {
      cylinder(d = wheel_d - 8 + e, h = wheel_w - 4, center = true);
      cylinder(d = wheel_d - 5, h = wheel_w, center = true);
    }
    cylinder(d = shaft_d, h = wheel_w + 1, center = true);
    for (s = [-1, 1]) translate([0, 0, s * wheel_w / 2]) cylinder(d = wheel_d - 11, h = 3, center = true);
  }
}

module esp_pcb() {
  translate([esp_cx, esp_y0, esp_z0]) box([-esp[0] / 2, esp[0] / 2], [0, esp[1]], [0, esp[2]]);
}

module esp_metal() {
  translate([esp_cx, esp_y0, esp_z1]) box([esp_usb_off - 3.8, esp_usb_off + 3.8], [-0.3, 5.3], [0, esp_usb_h]);
}

module esp_white() {
  translate([esp_cx, esp_y0, esp_z1]) box([-8.5 - 4, -8.5 + 4], [0, 6], [0, 5.5]);
}

module esp_chips() {
  translate([esp_cx, esp_y0, esp_z1]) {
    translate([0, 30, 0]) box([-3, 3], [-3, 3], [0, 0.9]);
    box([4, 9], [14, 19], [0, 1.4]);
  }
}

module esp_gold() {
  translate([esp_cx, esp_y0, esp_z1]) {
    for (i = [0:5]) box([-10 + i * 3.6, -8.6 + i * 3.6], [esp[1] - 6, esp[1] - 0.8], [0, 0.05]);
    for (x = [-11.43, 11.43], i = [0:12]) translate([x, 11.5 + i * 2.54, -esp[2] / 2]) cube([1.6, 1.6, esp[2] + 0.1], center = true);
  }
}

module esp_led() {
  translate([esp_cx - 5, esp_y0 + 24, esp_z1]) box([-0.8, 0.8], [-0.5, 0.5], [0, 0.6]);
}

module battery() {
  translate([0, bat_cy, bat_z0 + bat[2] / 2]) hull()
    for (x = [-1, 1], y = [-1, 1]) translate([x * (bat[0] / 2 - 2), y * (bat[1] / 2 - 2), 0]) cylinder(r = 2, h = bat[2], center = true);
}

module battery_tape() {
  translate([bat[0] / 2 - 3.1, bat_cy, bat_z0 + bat[2] / 2 + 0.05]) cube([6.2, bat[1] + 0.1, bat[2] + 0.1], center = true);
}

module battery_foam() {
  translate([0, bat_cy, -in_z + bat_pad / 2]) cube([bat[0] - 14, bat[1] - 10, bat_pad], center = true);
}

module charger_pcb() {
  box([-tp[0] / 2, tp[0] / 2], [tp_y0, tp_y1], [tp_z0, tp_z1]);
}

module charger_metal() {
  hull() for (x = [-1, 1]) translate([x * 2.9, tp_y1 + usbc_over, 0]) rotate([90, 0, 0]) cylinder(d = usbc_h, h = 7.3);
}

module charger_chips() {
  box([-2, 2], [tp_y1 - 17, tp_y1 - 12], [tp_z1, tp_z1 + 1.5]);
  for (x = [-3, 3]) box([x - 1.5, x + 1.5], [tp_y1 - 23, tp_y1 - 20], [tp_z1, tp_z1 + 1]);
}

module charger_gold() {
  for (x = [-7, -3, 3, 7]) translate([x, tp_y0 + 1.5, (tp_z0 + tp_z1) / 2]) cube([1.8, 1.8, tp[2] + 0.1], center = true);
}

// driver on the +X side of the charger; mirror it for the IMU
module pod_pcb(size) {
  box([pod_x0, pod_x0 + size[0]], [pod_y0, pod_y0 + size[1]], [board_z0, board_z0 + size[2]]);
}

module pod_chip(size) {
  translate([pod_x0 + size[0] / 2, pod_y0 + size[1] / 2, board_z0 + size[2]]) box([-2.5, 2.5], [-2.5, 2.5], [0, 1.1]);
}

module pod_gold(size) {
  for (s = [-1, 1], i = [0:5]) translate([pod_x0 + size[0] / 2 + s * (size[0] / 2 - 1.4), pod_y0 + size[1] / 2 - 6.35 + i * 2.54, board_z0 + size[2] / 2])
    cube([1.6, 1.6, size[2] + 0.1], center = true);
}

module switch_body() {
  at_tail() box([-sw[0] / 2, sw[0] / 2], [in_x - sw_wall - sw[2], in_x - sw_wall], [-sw_z, sw_z]);
}

module switch_metal() {
  at_tail() {
    translate([1, in_x - sw_wall - e, 0]) box([-0.75, 0.75], [0, sw_lever], [-0.75, 0.75]);
    for (x = [-2.5, 0, 2.5]) translate([x, in_x - sw_wall - sw[2], 0]) box([-0.25, 0.25], [-3, 0], [-0.15, 0.15]);
  }
}

module electronics() {
  col(c_pcb) esp_pcb();
  col(c_metal) esp_metal();
  col("#e9e6dc") esp_white();
  col(c_dark) esp_chips();
  col(c_brass) esp_gold();
  col("#39a0ff") esp_led();
  col("#c7ccd1") battery();
  col("#d9a520") battery_tape();
  col("#3a3d42") battery_foam();
  col("#1f4f8f") charger_pcb();
  col(c_metal) charger_metal();
  col(c_dark) charger_chips();
  col(c_brass) charger_gold();
  col("#6a2c91") pod_pcb(drv);
  col(c_dark) pod_chip(drv);
  col(c_brass) pod_gold(drv);
  mirror([1, 0, 0]) {
    col("#1f4f8f") pod_pcb(imu);
    col(c_dark) pod_chip(imu);
    col(c_brass) pod_gold(imu);
  }
  col(c_dark) switch_body();
  col(c_metal) switch_metal();
}

module motors() {
  quadrants() {
    col(c_brass) motor_brass();
    col(c_metal) motor_steel();
  }
}

module wheels() {
  quadrants() {
    col(c_tyre) tyre();
    col(c_metal) wheel_hub();
  }
}

// ---------- output ----------

// print orientation: outer face on the bed
module print_base() translate([0, 0, hull_h / 2]) base();
module print_lid() translate([0, 0, hull_h / 2]) rotate([180, 0, 0]) lid();

// The front right corner of each shell: one wheel well, one motor bay, one snap finger. A short
// print to check how the motor, the wheel and the click fit before printing the full shells.
module coupon() {
  intersection() {
    children();
    translate([mid_x - 2, -hull_w, -hull_h]) cube([hull_l, hull_w + 2, 2 * hull_h]);
  }
}

module label(pos, s, size = 3) {
  translate([pos[0], pos[1], hull_h]) {
    color("#111") linear_extrude(0.2) text(s, size = size, halign = "center", valign = "center", font = "Helvetica:style=Bold");
    color("#fff") translate([0, 0, -0.2]) linear_extrude(0.1) offset(r = 0.7) text(s, size = size, halign = "center", valign = "center", font = "Helvetica:style=Bold");
  }
}

if (part == "base") print_base();
if (part == "lid") print_lid();
if (part == "coupon-base") translate([0, 0, hull_h / 2]) coupon() base();
if (part == "coupon-lid") translate([0, 0, hull_h / 2]) rotate([180, 0, 0]) coupon() lid();

if (part == "print") {
  color(c_shell) {
    translate([0, hull_w / 2 + 4, 0]) print_base();
    translate([0, -hull_w / 2 - 4, 0]) print_lid();
  }
}

if (part == "assembly") {
  electronics();
  motors();
  wheels();
  color(c_hull) base();
  color(c_hull) lid();
}

if (part == "exploded") {
  color(c_shell) base();
  translate([0, 0, 22]) {
    electronics();
    motors();
    wheels();
  }
  translate([0, 0, 58]) color(c_shell) lid();
}

if (part == "open" || part == "layout") {
  color(c_shell) base();
  electronics();
  motors();
  wheels();
}

if (part == "layout") {
  label([esp_cx, esp_y0 + 22], "ESP32");
  label([-6, bat_cy], "LiPo");
  label([0, tp_y0 + 10], "TP4056", 2.4);
  label([pod_x0 + drv[0] / 2, pod_y0 + drv[1] / 2], "DRV", 2.4);
  label([-pod_x0 - imu[0] / 2, pod_y0 + imu[1] / 2], "IMU", 2.4);
  label([-in_x + 10, 0], "switch", 2.4);
  label([0, hull_w / 2 + 5], "USB-C: charge", 2.6);
  label([0, -hull_w / 2 - 5], "micro-USB: flash", 2.6);
  for (sx = [-1, 1], sy = [-1, 1]) label([sx * axle_x, sy * (gear_y - 12)], "N20", 2.4);
  color("#d33") translate([hull_l / 2 + 4, 0, 0]) linear_extrude(0.2) polygon([[0, -4], [7, 0], [0, 4]]);
}

// section: cut open across the middle, seen from the front: both USB ports, charger, battery, ESP32
// axle: cut open through the front axle: wheels in their wells, motors between them
if (part == "section" || part == "axle") {
  col("#7fb2d9") base();
  col("#f0a35e") lid();
  electronics();
  motors();
  wheels();
}
