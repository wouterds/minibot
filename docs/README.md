# minibot docs

Index of the documentation in this folder.

| File | What it covers |
|---|---|
| [`bom.md`](bom.md) | Bill of materials: every component, quantity, cost, and vendor recommendations |
| [`schematics/`](schematics/) | System block diagram, ESP32 ↔ TB6612FNG wiring, power distribution |
| [`schematics/generate.py`](schematics/generate.py) | Regenerates all three schematics with [`schemdraw`](https://schemdraw.readthedocs.io). Runs via `uv` with PEP 723 inline deps. |
| [`cad/chassis.scad`](cad/chassis.scad) | Parametric OpenSCAD source for the two chassis plates |
| [`cad/layout.py`](cad/layout.py) | Top-down matplotlib visualization of the chassis layout |

See also the top-level [`research.md`](../research.md) for the full design journal with decision rationale.

## Regenerating diagrams

```sh
docs/schematics/generate.py   # → system.png, wiring.png, power.png
docs/cad/layout.py            # → layout.png
```

Both scripts use [`uv`](https://docs.astral.sh/uv/) with inline PEP 723 dependencies — no separate `pip install` step needed.

## Rendering the chassis STL

OpenSCAD CLI (one-shot render):

```sh
openscad --export-format=stl -o top.stl    -D 'plate_kind="top"'    cad/chassis.scad
openscad --export-format=stl -o bottom.stl -D 'plate_kind="bottom"' cad/chassis.scad
```

Or just open `cad/chassis.scad` in the [OpenSCAD GUI](https://openscad.org/) and hit `F6`.
