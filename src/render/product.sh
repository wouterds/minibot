#!/bin/sh
# Ray-traced product shots in translucent PETG, written to ../../images/product-*.jpg.
#   ./product.sh [shot ...]     shots: hero pair exploded open detail
# Needs openscad and uv; Blender's renderer comes in through uv as the bpy package, nothing to install.
cd "$(dirname "$0")" || exit 1
[ $# -eq 0 ] && set -- hero pair exploded open detail
meshes=$(mktemp -d)
trap 'rm -rf "$meshes"' EXIT
for p in base lid tyres steel brass pcb_dark pcb_blue pcb_purple chips white battery tape foam led \
  wire_red wire_black wire_white wire_yellow wire_green wire_blue \
  base_brass lid_brass base_screws lid_screws; do
  openscad -o "$meshes/$p.stl" -D 'part="none"' -D "piece=\"$p\"" --backend=manifold --export-format binstl \
    product.scad 2>&1 | grep -E "WARNING|ERROR" &
done
wait
openscad -o "$meshes/dims.echo" -D 'part="none"' -D 'piece="none"' product.scad 2>/dev/null
sed -n 's/.*dims = \[\(.*\)\].*/\1/p' "$meshes/dims.echo" > "$meshes/dims.txt"
for shot in "$@"; do
  uv run --quiet --python 3.11 --with bpy==5.0.1 product.py "$meshes" "$PWD/../../images/product-$shot.jpg" \
    "$shot" "${WIDTH:-2400}" "${SAMPLES:-128}" 2>&1 | grep -E "Error|Traceback|line [0-9]+"
done
exit 0
