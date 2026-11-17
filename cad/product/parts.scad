// One material of the assembly at a time, in place, for product/render.sh.
include <../minibot.scad>
piece = "base";

// what render.py needs to know to stand the bot on its wheels, in mm
echo(dims = [hull_h, wheel_d]);

if (piece == "base") base();
if (piece == "lid") lid();
if (piece == "tyres") quadrants() tyre();
if (piece == "steel") {
  quadrants() {
    wheel_hub();
    motor_steel();
  }
  esp_metal();
  charger_metal();
  led_legs();
  buzzer_pins();
}
if (piece == "brass") {
  quadrants() motor_brass();
  esp_gold();
  charger_gold();
  pod_gold(drv, on_ends = true);
  mirror([1, 0, 0]) pod_gold(imu);
}
if (piece == "pcb_dark") esp_pcb();
if (piece == "pcb_blue") {
  charger_pcb();
  mirror([1, 0, 0]) pod_pcb(imu);
}
if (piece == "pcb_purple") pod_pcb(drv);
if (piece == "chips") {
  esp_chips();
  charger_chips();
  pod_chip(drv);
  mirror([1, 0, 0]) pod_chip(imu);
  buzzer_body();
}
if (piece == "white") {
  esp_white();
  led_dome();
  led_resistors();
}
for (c = wire_colours) if (piece == str("wire_", c[0])) wiring(c[0]);
if (piece == "battery") battery();
if (piece == "tape") battery_tape();
if (piece == "foam") battery_foam();
if (piece == "led") esp_led();
// the inserts and the screws stay with the shell they sit in
if (piece == "base_brass") base_inserts();
if (piece == "lid_brass") lid_inserts();
if (piece == "base_screws") base_screws();
if (piece == "lid_screws") lid_screws();
