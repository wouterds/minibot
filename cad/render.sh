#!/bin/sh
# Print-ready STLs in stl/ and preview images in renders/. Needs the OpenSCAD snapshot build.
cd "$(dirname "$0")" || exit 1
mkdir -p stl renders
view() { # name part rot_x rot_z projection
  openscad -o "renders/$1.png" -D "part=\"$2\"" --camera="0,0,0,$3,0,$4,300" --viewall --autocenter \
    --imgsize=1600,1200 --projection="$5" --render --backend=manifold --colorscheme=Tomorrow \
    minibot.scad 2>&1 | grep -E "WARNING|ERROR"
}
view assembly assembly 60 215 p
view layout   layout   0  0   o
view open     open     50 215 p
view exploded exploded 72 215 p
view section  section  0  0   o
view axle     axle     0  0   o
view print    print    50 205 p
for p in base lid coupon-base coupon-lid; do
  openscad -o "stl/$p.stl" -D "part=\"$p\"" --backend=manifold --export-format binstl minibot.scad 2>&1 |
    grep -E "WARNING|ERROR"
done
exit 0
