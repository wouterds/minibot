#!/bin/sh
# Fit check: the volume every pair of parts shares once assembled.
# Two overlaps are meant to be there: the bend the snap fingers keep, and the bite of the lid's
# crush ribs into the motors. Everything else must be 0.
cd "$(dirname "$0")" || exit 1
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
status=0
check() { # a b allowed-mm3 [shift of b]
  rm -f "$tmp/pair.stl"
  openscad -o "$tmp/pair.stl" -D 'part="none"' -D "a=\"$1\"" -D "b=\"$2\"" -D "shift=${4:-[0,0]}" \
    --backend=manifold --export-format binstl tools/check.scad >/dev/null 2>&1
  v=$(python3 tools/volume.py "$tmp/pair.stl")
  ok=$(python3 -c "print('ok' if $v <= $3 else 'COLLISION')")
  [ "$ok" = ok ] || status=1
  printf '%-12s %-12s %-12s %8s mm3  %s\n' "$1" "$2" "${4:-}" "$v" "$ok"
}
check base lid 14
# the lid's lip leaves it 0.2 mm of play; its ribs must clear the base wherever it ends up
for shift in "[0.2,0]" "[-0.2,0]" "[0,0.2]" "[0,-0.2]"; do check base keepers 0 "$shift"; done
for other in electronics motors wheels; do check base $other 0; done
check lid electronics 0
check lid motors 8
check lid wheels 0
check electronics motors 0
check electronics wheels 0
check motors wheels 0
# the wires are loose stand-ins, but they must not run through a shell
check base wires 0
check lid wires 0
exit $status
