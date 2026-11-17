// Overlap between two things in the assembly, for check.sh. An empty result means they clear.
include <../minibot.scad>
a = "base";
b = "lid";
shift = [0, 0];   // moves b sideways, to try a lid that sits off-centre in the play of its lip

module thing(name) {
  if (name == "base") base();
  if (name == "lid") lid();
  if (name == "keepers") difference() {
    intersection() {
      cavity(0.05);
      lid_fittings();
    }
    lip_relief();
  }
  if (name == "electronics") electronics();
  if (name == "motors") motors();
  if (name == "wheels") wheels();
  if (name == "wires") wiring();
  if (name == "screws") screws();
}

intersection() {
  thing(a);
  translate([shift[0], shift[1], 0]) thing(b);
}
