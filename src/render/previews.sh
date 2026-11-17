#!/bin/sh
# Views of the model in ../../images. Needs the OpenSCAD snapshot build.
cd "$(dirname "$0")" || exit 1
mkdir -p ../../images
view() { # name part rot_x rot_z projection
  openscad -o "../../images/$1.png" -D "part=\"$2\"" --camera="0,0,0,$3,0,$4,300" --viewall --autocenter \
    --imgsize=1600,1200 --projection="$5" --render --backend=manifold --colorscheme=Tomorrow \
    ../model/minibot.scad 2>&1 | grep -E "WARNING|ERROR"
}
view assembly assembly 60 215 p
view layout   layout   0  0   o
view section  section  0  0   o
view axle     axle     0  0   o
view print    print    50 205 p
exit 0
