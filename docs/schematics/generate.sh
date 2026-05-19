#!/usr/bin/env bash
# Compile all .tex schematics in this directory to PDF + PNG.
#
# Requires:
#   tectonic   — LaTeX engine (brew install tectonic)
#   pdftoppm   — from poppler (brew install poppler)

set -euo pipefail

cd "$(dirname "$0")"

for tex in *.tex; do
  name="${tex%.tex}"
  echo "→ $tex"
  tectonic "$tex" >/dev/null 2>&1
  pdftoppm -r 200 -png "$name.pdf" "$name"
  # pdftoppm adds a -1 page suffix; flatten to the bare name
  if [[ -f "${name}-1.png" ]]; then
    mv "${name}-1.png" "${name}.png"
  fi
done

echo "done — PNG + PDF outputs ready"
