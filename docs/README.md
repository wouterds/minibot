# minibot docs

| File | What it covers |
|---|---|
| [`parts.md`](parts.md) | Parts list: every component, quantity, cost, and vendor recommendations |
| [`cad/chassis.scad`](cad/chassis.scad) | Parametric OpenSCAD source for the chassis plate |
| [`cad/layout.py`](cad/layout.py) | Top-down matplotlib visualisation of the chassis layout |

See also the top-level [`research.md`](../research.md) for the full design journal with decision rationale.

## Rendering the chassis

Run OpenSCAD on the source file:

```sh
openscad --export-format=stl -o plate.stl docs/cad/chassis.scad
```

Print the resulting `plate.stl` twice — the chassis is invertible. Or open the `.scad` in the OpenSCAD GUI and hit `F6`.

## Regenerating the layout PNG

```sh
docs/cad/layout.py
```

Uses [`uv`](https://docs.astral.sh/uv/) with inline PEP 723 dependencies — no separate `pip install` step needed.
