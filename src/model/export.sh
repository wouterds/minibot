#!/bin/sh
# Print-ready STLs in ../../stl. Needs the OpenSCAD snapshot build.
cd "$(dirname "$0")" || exit 1
mkdir -p ../../stl
for p in base lid coupon-base coupon-lid; do
  openscad -o "../../stl/$p.stl" -D "part=\"$p\"" --backend=manifold --export-format binstl minibot.scad 2>&1 |
    grep -E "WARNING|ERROR"
done
exit 0
