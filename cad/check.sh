#!/bin/sh
# Fit check: the volume every pair of parts shares once assembled.
# The shells may only overlap each other, by the bend the snap fingers keep. Everything else must be 0.
cd "$(dirname "$0")" || exit 1
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
status=0
check() { # a b allowed-mm3
  openscad -o "$tmp/$1-$2.stl" -D 'part="none"' -D "a=\"$1\"" -D "b=\"$2\"" --backend=manifold --export-format binstl \
    tools/check.scad >/dev/null 2>&1
  v=$(python3 tools/volume.py "$tmp/$1-$2.stl")
  ok=$(python3 -c "print('ok' if $v <= $3 else 'COLLISION')")
  [ "$ok" = ok ] || status=1
  printf '%-12s %-12s %8s mm3  %s\n' "$1" "$2" "$v" "$ok"
}
check base lid 10
for shell in base lid; do
  for other in electronics motors wheels; do check $shell $other 0; done
done
check electronics motors 0
check electronics wheels 0
check motors wheels 0
exit $status
