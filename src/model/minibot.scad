// minibot hull: a sealed, invertible body for a 4WD skid-steer bot.
//
// Two printed shells, held together by four M2 screws into brass heat-set inserts:
//   base - carries the motors and all electronics, print outer face down
//   lid  - holds everything in place, print outer face down
// Two screws go in through each shell, so both faces look the same.
//
// The wheels live inside the hull, each in its own well that is open to both faces. They stand
// equally proud of the top and the bottom, so the bot drives the same on either face, and
// nothing sticks out sideways, in front or behind. Each motor sits in the sealed middle and
// reaches through the wall of its well, so the front of its gearbox stands inside the hollow
// hub of its wheel.
//
// Dimensions of the bought parts come from measurements.md.
//
// Coordinates: X forward, Y left, Z up. Origin in the middle of the hull, on the axle line.
// The seam between the shells is the plane Z = 0.

part = "assembly"; // assembly | layout | section | axle | print | base | lid | coupon-base | coupon-lid | none

/* [Drivetrain] */
wheel_d = 26;           // tyre diameter
wheel_w = 22.16;        // hub, flange to flange
wheel_gap = 1.5;        // around the wheel, to the walls of its well
motor_w = 12;           // N20 gearbox, the wide way (lies along X)
motor_h = 10;           // N20 across the flats (stands along Z)
motor_l = 25.64;        // brass front face to the black end cap
motor_gear_l = 9.4;     // the open brass gearbox at the front
motor_tab = 1.1;        // solder tabs behind the end cap
motor_boss_d = 4;       // bearing boss around the output shaft
shaft_d = 3;
shaft_l = 18.73;        // from the brass front face

/* [Hull] */
wheelbase = 91;
corridor = 28;          // between the end caps of two motors that face each other
hull_h = 16.2;
wall = 1.6;
skin = 1.6;
chamfer = 1;            // outer edges of both faces
well_lip = 1;           // straight rim of the wheel openings
corner_r = 3;

/* [Electronics: x size, y size, board thickness] */
esp = [25.7, 49.22, 1.17];  // LOLIN32 Lite, micro-USB on the -Y end; the length is over its sockets
esp_usb_off = 7;            // micro-USB centre from the board centreline, towards +X
esp_usb_h = 2.6;            // micro-USB socket height above the board
bat = [52.56, 33.99, 10.35]; // 103450 LiPo, 2000 mAh
bat_pad = 1;                // foam tape that sticks the battery to the floor
tp = [17.4, 27.78, 0.99];   // TP4056 USB-C charger, USB-C on the +Y end
usbc_h = 3.2;               // USB-C socket height above the board
usbc_over = 0.35;           // how far that socket sticks out past the board
drv = [15.95, 18.4, 1.6];   // DRV8833, its pads run along both short edges
imu = [15.5, 20, 1.6];      // GY-521 (MPU-6050)
led_d = 9.92;               // 10 mm RGB LED, across the dome
led_flange_d = 10.86;       // across the collar at its base
led_l = 13.7;               // tip of the dome to the base
buzzer_d = 11.7;
buzzer_h = 9.47;            // without its pins

/* [Fit] */
fit = 0.1;              // clearance around a board, per side
motor_fit = 0.1;        // beside the motor, per side
motor_crush = 0.1;      // how far the lid's crush ribs bite into the motor
motor_end_fit = 0.15;   // behind the motor
lap_gap = 0.2;          // between the lips of the two shells
lip_h = 1;              // height of the lip that centres the lid on the base

/* [Screws] */
screw_d = 2;            // M2 button head
screw_l = 10;
screw_head_d = 3.8;
screw_head_h = 1.5;
insert_d = 3.5;         // brass heat-set insert, across its knurls
insert_l = 4;

/* [Hidden] */
e = 0.01;
$fa = 3;
$fs = 0.3;
rib = 1.2;
bay_rib = 2;            // walls of the motor bays
stop_t = 1;
lap_in = (wall - lap_gap) / 2;   // the two lips share the wall

axle_x = wheelbase / 2;
well_r = wheel_d / 2 + wheel_gap;
gear_y = corridor / 2 + motor_end_fit + motor_l;   // brass front face of the gearbox
motor_nest = wheel_w - shaft_l;               // gearbox this far inside the hub puts the shaft tip flush with the hub's outer face
wall_y = gear_y - motor_nest - wheel_gap - wall;   // cavity side of the well wall; the gearbox passes through it
well_y0 = wall_y + wall;
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
// on either side of the charger. Both USB ports sit at x = 0. There is no power switch: the
// firmware puts the bot to sleep and the IMU wakes it.
esp_cx = -esp_usb_off;
esp_x0 = esp_cx - esp[0] / 2;
esp_x1 = esp_cx + esp[0] / 2;
esp_y0 = -in_y + 0.2;
esp_y1 = esp_y0 + esp[1];
esp_z1 = -esp_usb_h / 2;                      // board top, puts the micro-USB socket on the seam
esp_z0 = esp_z1 - esp[2];
tp_y1 = min(in_y - 0.2, in_y + wall - usbc_over - 0.3);   // board against the wall, socket mouth inside the hull's face
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
pod_y0 = bat_y1 + 2 * rib + fit + 0.3;        // their end towards the middle
board_z0 = -in_z + 1.5;                       // their underside
fence_z = -in_z + 3.5;                        // top of the low fences
// One screw beside each wheel, in the pocket between the motor bay and the end wall. That is
// where a wheel that lands hard levers its motor against the lid.
post_w = in_x - bay_x1 - bay_rib;             // the pocket's width, the post fills it
post_x = in_x - post_w / 2;
post_y = (motor_rear_y + wall_y) / 2;
screw_seat_z = hull_h / 2 - screw_head_h;     // underside of the screw's head
insert_hole_l = insert_l + 2;                 // room under the insert for a screw that is a little long
// The status LED lies on the centreline with its dome against the front wall, so the front of
// the hull lights up. The buzzer lies in the corner beside the ESP32, its face against the wall
// of the front right well.
led_x1 = in_x - 0.3;
led_x0 = led_x1 - led_l;
buzzer_x1 = mid_x - 0.3;
buzzer_x0 = buzzer_x1 - buzzer_h;
buzzer_y = -(wall_y + in_y) / 2;

// Both sockets sit behind the wall, so the grip of a plug has to pass through it.
usbc_open = [13, 7];
usb_open = [12.5, 7.5];

assert(protrusion >= 2, "wheels barely clear the hull");
assert(motor_nest >= 0, "shaft longer than the wheel is wide: it would stick out of the hub");
assert(esp_x0 - fit - rib >= -mid_x && esp_x1 + fit + rib <= mid_x, "ESP32 does not fit between the wells");
assert(bat_y0 - fit - rib >= esp_y1 + fit + rib, "battery runs into the ESP32");
assert(buzzer_x0 - 0.3 - rib >= esp_x1 + fit + rib + 4, "buzzer runs into the ESP32");
assert(post_w >= insert_d + 2.4, "no room for the insert beside the motor bay");
assert(screw_seat_z - screw_l > -insert_hole_l && screw_seat_z - screw_l < -1.5, "screw too long or too short for its insert");

echo(str("hull (l x w x h): ", hull_l, " x ", hull_w, " x ", hull_h));
echo(str("tyres stand ", protrusion, " mm proud of both faces, ", wheel_gap, " mm clear of their wells"));
echo(str("gearbox stands ", motor_nest, " mm inside the hub"));

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

// ---------- shell ----------

module cavity(grow = 0) {
  g = 2 * grow;
  cube([2 * in_x + g, 2 * wall_y + g, 2 * in_z + g], center = true);
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

// A small stop on the outer wall of each well, facing the tip of the shaft. It keeps the motor
// and its wheel from sliding outwards, and touches only at the centre of rotation.
module thrust_stops() {
  reach = wheel_gap - 0.3;
  quadrants() translate([axle_x, well_y1, 0]) hull() {
    translate([0, 0.05, 0]) cube([3, 0.1, 3 + 2 * reach], center = true);
    translate([0, -reach + 0.05, 0]) cube([1, 0.1, 3], center = true);
  }
}

module shell() {
  difference() {
    chamfer_box(hull_l, hull_w, hull_h, corner_r, chamfer);
    cavity();
    difference() {
      wells();
      thrust_stops();
    }
  }
}

module inner_outline(grow = 0) {
  offset(delta = grow) {
    square([2 * in_x, 2 * wall_y], center = true);
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
  // motors, through the well walls
  quadrants() port([axle_x, wall_y + wall / 2, 0], "y", motor_w + 2 * motor_fit + 0.2, motor_h + 0.2, wall + 2 * e, 0.5);
  // USB-C charging, left side
  port([0, hull_w / 2 - wall / 2, 0], "y", usbc_open[0], usbc_open[1], wall + 1, 2);
  // micro-USB for flashing, right side
  port([0, -hull_w / 2 + wall / 2, 0], "y", usb_open[0], usb_open[1], wall + 1, 2);
}

// The base's lip has to let the motors and the plugs through.
module tongue_gaps() {
  h = [0, lip_h + e];
  quadrants() translate([axle_x, wall_y, 0]) box([-motor_w / 2 - 0.8, motor_w / 2 + 0.8], [-1, 2], h);
  translate([0, in_y, 0]) box([-usbc_open[0] / 2 - 0.5, usbc_open[0] / 2 + 0.5], [-1, 2], h);
  translate([0, -in_y, 0]) box([-usb_open[0] / 2 - 0.5, usb_open[0] / 2 + 0.5], [-2, 1], h);
}

// ---------- screws ----------

// A post in each of the four pockets, half in the base and half in the lid. The halves meet on
// the seam, so a screw clamps plastic on plastic and does not bend the lid.
module post_half() {
  quadrants() box([post_x - post_w / 2 - e, in_x + e], [post_y - post_w / 2, post_y + post_w / 2], [-in_z - e, 0]);
}

// The two screws at the front go in through the lid into inserts in the base, the two at the rear
// through the base into inserts in the lid. Each face then shows two heads at one end, and the
// bot looks the same on its back.
module from_lid() {
  sym_y() translate([post_x, post_y, 0]) children();
}

module from_base() {
  sym_y() translate([-post_x, post_y, 0]) mirror([0, 0, 1]) children();
}

// Both are drawn for a screw that comes down through the lid.
// the insert is pressed in hot from the seam
module insert_hole() {
  translate([0, 0, -insert_hole_l]) cylinder(d = insert_d - 0.3, h = insert_hole_l + e);
}

// the screw's shank, and a recess that takes its head below the face
module screw_hole() {
  translate([0, 0, -e]) cylinder(d = screw_d + 0.4, h = hull_h);
  translate([0, 0, screw_seat_z]) cylinder(d = screw_head_d + 0.6, h = hull_h);
}

// Slots on the seam at both ends: twist a coin in one to lift the lid once the screws are out.
module pry_slots() {
  quadrants() port([hull_l / 2, post_y, 0], "x", 12, 2.2, wall, 0.4);
}

// ---------- motor bays ----------

// Front left bay, base half. The motor lies along Y and passes through the well wall. A wheel
// that hits the floor levers its motor against the saddles, so they sit as far apart as they
// can: one under the end cap, one from the front of the can up to the well wall. The gearbox
// is an open frame, so the front saddle is long enough to always catch one of its plates.
saddles = [[motor_rear_y + 0.5, motor_rear_y + 2.5], [gear_y - motor_gear_l - 3, wall_y + e]];
crush_y = [motor_rear_y + 1.5, gear_y - motor_gear_l - 1.5];   // both on the can

module motor_bay() {
  // walls in front of and behind the motor
  box([bay_x0 - bay_rib, bay_x0], [motor_rear_y - stop_t, wall_y + e], [-in_z - e, -0.1]);
  box([bay_x1, bay_x1 + bay_rib], [motor_rear_y - stop_t, wall_y + e], [-in_z - e, -0.1]);
  for (y = saddles) box([bay_x0 - e, bay_x1 + e], y, [-in_z - e, -motor_h / 2]);
  motor_stop();
}

// behind the end cap; it stays low so the solder tabs and the wires pass over it
module motor_stop() {
  box([bay_x0 - e, bay_x1 + e], [motor_rear_y - stop_t, motor_rear_y], [-in_z - e, -3.2]);
}

// Lid half, drawn upside down. The saddles stop
// short of the motor and carry a thin rib each that bites into the can, which takes up the
// tolerance of the motor without holding the lid off.
module motor_cap() {
  for (y = saddles) box([bay_x0 - e, bay_x1 + e], y, [-in_z - e, -motor_h / 2 - 0.2]);
  for (y = crush_y) box([bay_x0 - e, bay_x1 + e], [y - 0.3, y + 0.3], [-in_z - e, -motor_h / 2 + motor_crush]);
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

// Seat for a small board beside the charger, long side along Y. It rests on ledges under the
// pair of edges that carries no pads: the short ends, or the long sides when pads_on_ends.
// Posts and fences stand well above the board, since its keeper in the lid stays clear of the
// parts on it.
module board_seat(size, pads_on_ends = false) {
  x1 = pod_x0 + size[0];
  cx = (pod_x0 + x1) / 2;
  y1 = pod_y0 + size[1];
  cy = (pod_y0 + y1) / 2;
  top = board_z0 + size[2] + 2.6;
  if (pads_on_ends) {
    for (x = [pod_x0 - fit, x1 - 1]) box([x, x + 1 + fit], [cy - 5, cy + 5], [-in_z - e, board_z0]);
    // posts at the corners, beside the pad rows
    for (x = [pod_x0 - fit, x1 - 1.2], y = [pod_y0 - fit - rib, y1 + fit])
      box([x, x + 1.2 + fit], [y, y + rib], [-in_z - e, top]);
  } else {
    for (y = [pod_y0 - fit, y1 - 1]) box([cx - 5, cx + 5], [y, y + 1 + fit], [-in_z - e, board_z0]);
    for (y = [pod_y0 - fit - rib, y1 + fit]) box([cx - 5, cx + 5], [y, y + rib], [-in_z - e, top]);
  }
  // towards the well
  box([x1 + fit, mid_x + e], [pod_y0, y1], [-in_z - e, top]);
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

// Half a cradle for a round part that lies along X on the seam: a saddle under its body and a
// stop behind its back end. The stop ends below the seam, so the part's legs pass over it. The
// lid carries the other half.
module round_seat(x0, y, d, play = 0) {
  difference() {
    box([x0 + 3, x0 + 7.5], [y - d / 2 - rib, y + d / 2 + rib], [-in_z - e, -0.1]);
    translate([x0, y, 0]) rotate([0, 90, 0]) cylinder(d = d + 0.3 + 2 * play, h = 10);
  }
  box([x0 - 0.3 - rib, x0 - 0.3], [y - d / 2, y + d / 2], [-in_z - e, -1]);
}

module round_seats(play = 0) {
  round_seat(led_x0, 0, led_d, play);
  round_seat(buzzer_x0, buzzer_y, buzzer_d, play);
}

module base_fittings() {
  post_half();
  round_seats();
  charger_seat();
  board_seat(drv, pads_on_ends = true);
  mirror([1, 0, 0]) board_seat(imu);
  esp_seat();
  battery_seat();
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
    from_lid() insert_hole();
    from_base() screw_hole();
    pry_slots();
  }
}

// ---------- lid ----------

// rib from the ceiling down to z
module keeper(xr, yr, z) {
  box(xr, yr, [z, in_z + e]);
}

// A post over the middle of a small board. It stops above the tallest part on the board, so it
// only keeps the board from climbing out of its seat when the bot is on its back.
module board_keeper(size, cx) {
  cy = pod_y0 + size[1] / 2;
  keeper([cx - 2, cx + 2], [cy - 2, cy + 2], board_z0 + size[2] + 2.4);
}

module lid_fittings() {
  // charger: on the USB-C shell, and on the board edge between the battery pads
  keeper([-3, 3], [tp_y1 - 4.5, tp_y1 - 0.5], -tp_z1 + 0.2);
  keeper([-2, 2], [tp_y0 + 0.2, tp_y0 + 1.1], tp_z1 + 0.3);
  // driver and IMU
  board_keeper(drv, pod_x0 + drv[0] / 2);
  board_keeper(imu, -pod_x0 - imu[0] / 2);
  // ESP32: on the micro-USB shell, and on the bare antenna end
  keeper([-3, 3], [esp_y0 + 0.3, esp_y0 + 4.3], -esp_z1 + 0.2);
  keeper([esp_cx - 5, esp_cx + 5], [esp_y1 - 1.1, esp_y1 - 0.2], esp_z1 + 0.3);
  // battery: a backstop, the foam tape under it does the holding
  for (y = [-8, 8]) keeper([-20, 20], [bat_cy + y - rib / 2, bat_cy + y + rib / 2], bat_z0 + bat[2] + 0.7);
  // status LED and buzzer: the other half of their cradles
  mirror([0, 0, 1]) round_seats(0.1);
  mirror([0, 0, 1]) post_half();
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
    }
    openings();
    from_lid() screw_hole();
    from_base() insert_hole();
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
c_tyre = "#d8281f";

// The section views draw every part as the slice of it that lies in the plane x = slice_x, seen
// from the front, each in its own colour.
slice_x = part == "section" ? 0 : part == "axle" ? axle_x : undef;

module col(c) {
  color(c)
    if (is_undef(slice_x)) children();
    else linear_extrude(0.1) projection(cut = true)
      multmatrix([[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, -slice_x]]) children();
}

hub_plate = 4;          // stand-in only: thickness of the hub's solid end
hub_cup_d = 17;         // stand-in only: inside of the hub's cup

// front left motor
module motor_brass() {
  translate([axle_x, 0, 0]) {
    box([-motor_w / 2, motor_w / 2], [gear_y - motor_gear_l, gear_y], [-motor_h / 2, motor_h / 2]);
    for (x = [-3.45, 3.45]) box([x - 0.75, x + 0.75], [gear_y - motor_l - motor_tab, gear_y - motor_l], [-0.2, 0.2]);
  }
}

module motor_steel() {
  translate([axle_x, 0, 0]) {
    intersection() {
      translate([0, gear_y - motor_gear_l, 0]) rotate([90, 0, 0]) cylinder(d = motor_w, h = motor_l - motor_gear_l);
      box([-motor_w / 2, motor_w / 2], [gear_y - motor_l, gear_y - motor_gear_l], [-motor_h / 2, motor_h / 2]);
    }
    translate([0, gear_y - e, 0]) rotate([-90, 0, 0]) {
      cylinder(d = motor_boss_d, h = 0.7);
      cylinder(d = shaft_d, h = shaft_l);
    }
  }
}

module tyre() {
  translate([axle_x, wheel_y, 0]) rotate([90, 0, 0]) difference() {
    cylinder(d = wheel_d, h = wheel_w - 2.4, center = true);
    cylinder(d = wheel_d - 6, h = wheel_w, center = true);
  }
}

// the hub is a cup: open towards the motor, solid at its outer end, a flange on each rim
module wheel_hub() {
  translate([axle_x, wheel_y, 0]) rotate([-90, 0, 0]) difference() {
    union() {
      cylinder(d = wheel_d - 6, h = wheel_w, center = true);
      for (s = [-1, 1]) translate([0, 0, s * (wheel_w / 2 - 0.6)]) cylinder(d = wheel_d - 3, h = 1.2, center = true);
    }
    translate([0, 0, -hub_plate]) cylinder(d = hub_cup_d, h = wheel_w, center = true);
    cylinder(d = shaft_d, h = wheel_w + 1, center = true);
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

// two rows of six pads: along the long sides, or along the short ends
module pod_gold(size, on_ends = false) {
  for (r = [-1, 1], i = [0:5]) {
    along = -6.35 + i * 2.54;
    across = r * ((on_ends ? size[1] : size[0]) / 2 - 1.4);
    translate([pod_x0 + size[0] / 2 + (on_ends ? along : across), pod_y0 + size[1] / 2 + (on_ends ? across : along), board_z0 + size[2] / 2])
      cube([1.6, 1.6, size[2] + 0.1], center = true);
  }
}

module led_dome() {
  translate([led_x0, 0, 0]) rotate([0, 90, 0]) {
    cylinder(d = led_flange_d, h = 1.2);
    cylinder(d = led_d, h = led_l - led_d / 2);
    translate([0, 0, led_l - led_d / 2]) sphere(d = led_d);
  }
}

module led_legs() {
  for (y = [-3.81, -1.27, 1.27, 3.81]) translate([led_x0 - 3, y, 0]) cube([6, 0.5, 0.5], center = true);
}

module buzzer_body() {
  translate([buzzer_x0, buzzer_y, 0]) rotate([0, 90, 0]) cylinder(d = buzzer_d, h = buzzer_h);
}

module buzzer_pins() {
  for (y = [-3.25, 3.25]) translate([buzzer_x0 - 2, buzzer_y + y, 0]) cube([4, 0.6, 0.6], center = true);
}

module screw() {
  translate([0, 0, screw_seat_z]) {
    cylinder(d = screw_head_d, h = screw_head_h - 0.2);
    translate([0, 0, -screw_l]) cylinder(d = screw_d, h = screw_l);
  }
}

module insert() {
  translate([0, 0, -insert_l]) difference() {
    cylinder(d = insert_d, h = insert_l);
    translate([0, 0, -e]) cylinder(d = screw_d, h = insert_l + 2 * e);
  }
}

// what each shell carries: its own two inserts, and the two screws that go in through it
module base_inserts() from_lid() insert();
module lid_inserts() from_base() insert();
module base_screws() from_base() screw();
module lid_screws() from_lid() screw();

module screws() {
  base_screws();
  lid_screws();
}

module hardware() {
  col(c_dark) screws();
  col(c_brass) base_inserts();
  col(c_brass) lid_inserts();
}

module electronics() {
  col("#f1eef0") led_dome();
  col(c_metal) led_legs();
  col(c_dark) buzzer_body();
  col(c_metal) buzzer_pins();
  col("#d9c7a1") led_resistors();
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
  col(c_brass) pod_gold(drv, on_ends = true);
  mirror([1, 0, 0]) {
    col("#1f4f8f") pod_pcb(imu);
    col(c_dark) pod_chip(imu);
    col(c_brass) pod_gold(imu);
  }
}

// ---------- wires ----------

// Loose stand-ins for the wiring, pad to pad, in the colours of the wiring table. They show
// where the wires run: past the ends of the battery, between the motors and over the small
// boards, never over the battery.

wire_d = 1.2;
wire_colours = [["red", "#d6221c"], ["black", "#151515"], ["white", "#f2f2ee"], ["yellow", "#f0c000"], ["green", "#1f9a40"], ["blue", "#2468d8"]];

// pads, on top of their boards
function esp_pad(side, i) = [esp_cx + side * 11.43, esp_y0 + 11.5 + i * 2.54, esp_z1];   // side +1: 13 15 2 0 4 16 17 5 18 23 19 22 3V; side -1: G 12 14 27 26 25 33 32 35 34
function esp_bat(i) = [esp_cx - 9.8 + i * 2.6, esp_y0 + 7, esp_z1];                       // legs of the battery socket: + then -
function drv_pad(row, i) = [pod_x0 + drv[0] / 2 - 6.35 + i * 2.54, pod_y0 + drv[1] / 2 + row * (drv[1] / 2 - 1.4), board_z0 + drv[2]];   // row -1: IN1 IN2 VCC GND IN3 IN4; row +1: EEP OUT1 OUT2 OUT3 OUT4
function imu_pad(i) = [-pod_x0 - imu[0] + 1.4, pod_y0 + imu[1] / 2 - 6.35 + i * 2.54, board_z0 + imu[2]];   // VCC GND SCL SDA - INT
function tp_pad(x) = [x, tp_y0 + 1.5, tp_z1];                                             // OUT- B- B+ OUT+ at -7 -3 3 7
function tab(sx, sy, t) = [sx * axle_x + t * 3.45, sy * (gear_y - motor_l - motor_tab / 2), 0];
function led_leg(i) = [led_x0 - 6, -3.81 + i * 2.54, 0];                                  // red, common, green, blue
function buzzer_pin(s) = [buzzer_x0 - 4, buzzer_y + s * 3.25, 0];

wf = -in_z + 1;                               // lying on the floor
function layer(n) = wf + 1.4 * n;             // stacked in a channel
function slot(n) = -30 - 1.1 * n;             // side by side in the channel past the rear end of the battery
function trunk(n) = -22.6 - 1.2 * n;          // and beside the ESP32

// from a pad on the ESP32's rear edge to the rear channel
function rear_run(pad, n, z) = [pad, [pad[0] - 2.5, pad[1], pad[2] - 1], [trunk(n), pad[1] + 3, z], [trunk(n), -14, z], [slot(n), -8, z], [slot(n), 14, z], [slot(n), 27, z]];
// from a pad on its front edge over the board to the same channel
function over_esp(pad, n, z) = [pad, [1, pad[1] + 1, 1.5], [-12, pad[1] + 1.5, 2.2], [-21.5, pad[1] + 2, 1], [trunk(n), pad[1] + 6, z], [trunk(n), -14, z], [slot(n), -8, z], [slot(n), 14, z], [slot(n), 27, z]];
// from the rear channel over the IMU and the charger to the driver
function to_drv(n) = [[-29, 31, 1], [-27.5, 33.2 + 0.3 * n, 1.8], [-18, 34.2 + 1.1 * n, 2.4], [-2, 34.2 + 1.1 * n, 2.4], [9, 34.6 + 0.6 * n, 2]];
// from the rear channel along the edge of the IMU to one of its pads
function to_imu(pad, n) = [[-29, 31.2, 0.2], [-26.9 - 0.45 * n, 33.5, 0.9], [-26.9 - 0.45 * n, pad[1] - 1.5, 0.9], [-26.2, pad[1], 0.7], [-24.5, pad[1], 0], pad];
// from an output of the driver to the channel past the front end of the battery
function drv_front(pad, n) = let(x = 26.9 + 1.2 * (n % 2), z = 0.5 + 1.4 * floor(n / 2))
  [pad, [pad[0], 51.3, -3], [20, 53.4 + 0.6 * n, -3.5], [x, 52.6, z], [x, 47, z], [x, 35, z], [30.2, 31.2, z - 1], [30.9 + 1.2 * n, 26, wf + 0.6], [30.9 + 1.2 * n, 17, wf]];
// and to the channel past its rear end
function drv_rear(pad, m, n, z) = [pad, [pad[0] - 0.5, 51.6, -2], [11.5, 51, 0.8], [0, 49.8 - 1.2 * m, 1.5], [-12, 49.8 - 1.2 * m, 1], [-22, 49.8 - 1.2 * m, 1.2], [-27.2 - 0.3 * m, 45, 2.4], [-27.2 - 0.3 * m, 35, 2.4], [-28.8, 32, 2.2], [slot(n) + 0.6, 30, z + 1.5], [slot(n), 26, z], [slot(n), 16, z]];
// the last bit to a motor's solder tab
function to_tab(sx, sy, t) = [[sx * (axle_x - 2) + t * 3.45, sy * 11 - sy * 0.5 * t, -3], tab(sx, sy, t) - [0, sy, 0.5], tab(sx, sy, t)];
// from the LED to the front edge of the ESP32
function led_run(i) = [led_leg(i), led_leg(i) - [9, 0, 0], [30.6 - 0.7 * i, -7 - 0.8 * i, -1.5], [23.8 - 1.1 * i, -20 - 1.2 * i, -3], [13.5 - i, -28.5 - 1.5 * i, -2.5]];

wires = [
  // battery to the charger, the cell's own leads
  ["red", [[bat[0] / 2 - 1, bat_cy + 2, 1], [28.8, bat_cy + 2, 0], [31, bat_cy + 5, -2], [31, 27, layer(2)], [29.5, 31.5, 0.8], [20, 31.6, 0.9], [6, 31.4, 0.9], [4.2, 32.2, 0.4], tp_pad(3)]],
  ["black", [[bat[0] / 2 - 1, bat_cy - 2, 1], [28.8, bat_cy - 2, 0], [32.3, bat_cy + 4, -2], [32.4, 27, layer(2)], [30.5, 30.6, 0.8], [20, 30.4, 0.9], [2, 30.6, 0.9], [-4.6, 31.6, 0.4], tp_pad(-3)]],
  // charger to the driver
  ["red", [tp_pad(7), [9.3, 33.2, 0.6], [13, 32.6, 0], drv_pad(-1, 2)]],
  ["black", [tp_pad(-7), [-5.5, 35.6, 0.6], [0, 36.2, 1], [9, 35.5, 1], [15, 35.5, -1], drv_pad(-1, 3)]],
  // charger to the ESP32: plus to the + leg of its battery socket, minus to G
  ["red", concat([tp_pad(7), [5.5, 36, 0.9], [-4, 37.5, 0.9], [-14, 37, 0.9], [-26.5, 34.6, 0.9], [-28.8, 31.6, 0.2], [slot(2), 26, wf], [slot(2), 14, wf], [slot(2), -6, wf], [-27.5, -14, wf], [-27.5, -40, wf], [-24, -50, -2], [-20.5, -52.5, 0.2]], [esp_bat(0)])],
  ["black", concat([tp_pad(-7), [-8.5, 36.5, 0.9], [-15, 35.5, 0.9], [-26, 33.6, 0.9], [-28.6, 31, 0.2], [slot(1), 26, wf], [slot(1), 14, wf], [slot(1), -6, wf], [-26.2, -14, wf], [-26.2, -40, wf], [-24.5, -47, -3], [-22, -48.3, -2]], [esp_pad(-1, 0)])],
  // ESP32 to the driver: 32 33 25 26 to IN1 IN2 IN3 IN4, 27 to EEP
  ["yellow", concat(rear_run(esp_pad(-1, 7), 0, layer(1)), to_drv(0), [drv_pad(-1, 0)])],
  ["green", concat(rear_run(esp_pad(-1, 6), 1, layer(1)), to_drv(1), [drv_pad(-1, 1)])],
  ["blue", concat(rear_run(esp_pad(-1, 5), 2, layer(1)), to_drv(2), [[20, 36.5, 0], drv_pad(-1, 4)])],
  ["white", concat(rear_run(esp_pad(-1, 4), 3, layer(1)), to_drv(3), [[23.5, 37, 0], drv_pad(-1, 5)])],
  ["yellow", concat(rear_run(esp_pad(-1, 3), 4, layer(1)), to_drv(4), [[10.8, 42, 0.5], drv_pad(1, 0)])],
  // ESP32 to the IMU: 3V, 19 (SCL), 23 (SDA), 34 (INT); its ground comes from the charger
  ["red", concat(over_esp(esp_pad(1, 12), 0, layer(2)), to_imu(imu_pad(0), 0))],
  ["yellow", concat(over_esp(esp_pad(1, 10), 1, layer(2)), to_imu(imu_pad(2), 1))],
  ["blue", concat(over_esp(esp_pad(1, 9), 2, layer(2)), to_imu(imu_pad(3), 2))],
  ["white", concat(rear_run(esp_pad(-1, 9), 3, layer(2)), to_imu(imu_pad(5), 3))],
  ["black", [tp_pad(-7), [-8.6, 34.8, 0.6], [-12, 38.6, -0.5], [-20, 38.5, -2], imu_pad(1)]],
  // driver to the motors: OUT1 and OUT2 to both left motors, OUT3 and OUT4 to both right ones
  ["red", concat(drv_front(drv_pad(1, 1), 0), [[35, 12, wf]], to_tab(1, 1, -1))],
  ["black", concat(drv_front(drv_pad(1, 2), 1), [[35, 10.5, wf]], to_tab(1, 1, 1))],
  ["red", concat(drv_front(drv_pad(1, 3), 2), [[34.6, 0, wf], [34.6, -9.5, wf]], to_tab(1, -1, -1))],
  ["black", concat(drv_front(drv_pad(1, 4), 3), [[35.8, 0, wf], [35.8, -8.5, wf]], to_tab(1, -1, 1))],
  ["red", concat(drv_rear(drv_pad(1, 1), 0, 3, wf), [[-37, 11.5, wf]], to_tab(-1, 1, 1))],
  ["black", concat(drv_rear(drv_pad(1, 2), 1, 0, wf), [[-36, 10, wf]], to_tab(-1, 1, -1))],
  ["red", concat(drv_rear(drv_pad(1, 3), 2, 1, layer(3)), [[-36.5, 4, wf], [-37, -8, wf]], to_tab(-1, -1, 1))],
  ["black", concat(drv_rear(drv_pad(1, 4), 3, 2, layer(3)), [[-38, 4, wf], [-38.4, -7, wf]], to_tab(-1, -1, -1))],
  // ESP32 to the status LED: 4, 16, 17 to red, green, blue through a resistor each
  ["yellow", concat(led_run(0), [[8, -38, -1.5], esp_pad(1, 4)])],
  ["green", concat(led_run(2), [[8.5, -35.6, -1.5], esp_pad(1, 5)])],
  ["blue", concat(led_run(3), [[9, -33, -1.5], esp_pad(1, 6)])],
  ["black", concat(led_run(1), [[10, -39, -1.5], [7.5, -41.5, 0.5], [0, -46, 2.5], [-9, -51, 3], [-13, -51.8, 1], esp_bat(1)])],
  // ESP32 to the buzzer
  ["white", [buzzer_pin(1), [12, -44, -1], [8, -47.5, -1.5], esp_pad(1, 0)]],
  ["black", [buzzer_pin(-1), [11, -50.5, 0.5], [6.5, -50.3, 1.5], [-3, -51.5, 2.6], [-10, -51.5, 2.4], [-13.6, -52.3, 0.5], esp_bat(1)]],
];

function bend(a, b, c, d, t) = 0.5 * (2 * b + (c - a) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (3 * b - a - 3 * c + d) * t * t * t);
function smooth(p, steps = 4) = concat(
  [for (i = [0:len(p) - 2], k = [0:steps - 1]) bend(p[max(i - 1, 0)], p[i], p[i + 1], p[min(i + 2, len(p) - 1)], k / steps)],
  [p[len(p) - 1]]);

module wire(points) {
  path = smooth(points);
  for (i = [0:len(path) - 2]) hull() {
    translate(path[i]) sphere(d = wire_d, $fn = 8);
    translate(path[i + 1]) sphere(d = wire_d, $fn = 8);
  }
}

// every wire, or only those of one colour
module wiring(only = undef) {
  for (c = wire_colours) if (is_undef(only) || only == c[0]) color(c[1])
    for (w = wires) if (w[0] == c[0]) wire(w[1]);
}

module led_resistors() {
  for (i = [0, 2, 3]) translate(led_leg(i) - [4.5, 0, 0]) rotate([0, 90, 0]) cylinder(d = 2.2, h = 6, center = true);
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

// The front right corner of each shell: one wheel well, one motor bay, one screw post. A short
// print to check how the motor, the wheel and the screw fit before printing the full shells.
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
  hardware();
  wiring();
  motors();
  wheels();
  color(c_hull) base();
  color(c_hull) lid();
}

if (part == "layout") {
  color(c_shell) base();
  col(c_brass) base_inserts();
  electronics();
  wiring();
  motors();
  wheels();

  label([esp_cx, esp_y0 + 22], "ESP32");
  label([-6, bat_cy], "LiPo");
  label([0, tp_y0 + 10], "TP4056", 2.4);
  label([pod_x0 + drv[0] / 2, pod_y0 + drv[1] / 2], "DRV", 2.4);
  label([-pod_x0 - imu[0] / 2, pod_y0 + imu[1] / 2], "IMU", 2.4);
  label([led_x0 - 9, 0], "LED", 2.4);
  label([buzzer_x0 + buzzer_h / 2, buzzer_y + buzzer_d / 2 + 4], "buzzer", 2.4);
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
  hardware();
  electronics();
  motors();
  wheels();
}
