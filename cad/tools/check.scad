// Overlap between two things in the assembly, for check.sh. An empty result means they clear.
include <../minibot.scad>
a = "base";
b = "lid";

module thing(name) {
  if (name == "base") base();
  if (name == "lid") lid();
  if (name == "electronics") electronics();
  if (name == "motors") motors();
  if (name == "wheels") wheels();
}

intersection() {
  thing(a);
  thing(b);
}
