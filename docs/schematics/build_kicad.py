#!/usr/bin/env -S uv run --with simp-sexp --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["simp-sexp>=0.3"]
# ///
"""Hand-author a KiCad schematic for minibot and render via kicad-cli.

For each component we use the real KiCad library symbol (TB6612FNG,
MPU-6000, Battery_Cell, generic connectors). The script parses each
symbol's pin positions, then attaches a labelled stub wire to every
used pin so the resulting schematic is legible.
"""

import re
import subprocess
import uuid
from dataclasses import dataclass
from pathlib import Path

KICAD_APP = Path("/Applications/KiCad.app")
SYMBOL_DIR = KICAD_APP / "Contents/SharedSupport/symbols"
KICAD_CLI = KICAD_APP / "Contents/MacOS/kicad-cli"

OUT = Path(__file__).resolve().parent
SCH_PATH = OUT / "circuit.kicad_sch"
PDF_PATH = OUT / "circuit.pdf"


def new_uuid() -> str:
    return str(uuid.uuid4())


# ─── Symbol library parsing ─────────────────────────────────────────


@dataclass
class Pin:
    number: str
    name: str
    x: float
    y: float
    angle: int  # 0 = right, 90 = up, 180 = left, 270 = down


def _balance(text: str, start: int) -> int:
    """Return the index of the closing paren matching the one at `start`."""
    depth = 0
    i = start
    while i < len(text):
        c = text[i]
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise RuntimeError("unbalanced parens")


def extract_symbol(lib_file: str, symbol_name: str) -> tuple[str, list[Pin]]:
    """Return (renamed_symbol_block, list_of_pins) for one symbol."""
    path = SYMBOL_DIR / lib_file
    text = path.read_text()
    pattern = re.compile(rf'\(symbol "{re.escape(symbol_name)}"')
    m = pattern.search(text)
    if not m:
        raise RuntimeError(f"symbol {symbol_name} not found in {lib_file}")
    end = _balance(text, m.start())
    block = text[m.start() : end + 1]

    # Rename the top-level symbol id to "Lib:Name" so the schematic can
    # reference it as a lib_id.
    lib_prefix = lib_file.replace(".kicad_sym", "")
    renamed = block.replace(
        f'(symbol "{symbol_name}"', f'(symbol "{lib_prefix}:{symbol_name}"', 1,
    )

    # Extract pins from the block. We need (at X Y angle), (name "..."), (number "...")
    pins: list[Pin] = []
    pin_re = re.compile(r"\(pin\s+\S+\s+\S+\s*", re.DOTALL)
    for pin_match in pin_re.finditer(block):
        pin_start = pin_match.start()
        pin_end = _balance(block, pin_start)
        pin_block = block[pin_start : pin_end + 1]
        at_match = re.search(r"\(at\s+([-\d.]+)\s+([-\d.]+)\s+(\d+)\)", pin_block)
        name_match = re.search(r'\(name\s+"([^"]+)"', pin_block)
        number_match = re.search(r'\(number\s+"([^"]+)"', pin_block)
        if not (at_match and name_match and number_match):
            continue
        pins.append(
            Pin(
                number=number_match.group(1),
                name=name_match.group(1),
                x=float(at_match.group(1)),
                y=float(at_match.group(2)),
                angle=int(at_match.group(3)),
            )
        )
    return renamed, pins


@dataclass
class Component:
    lib_id: str
    ref: str
    value: str
    x: float
    y: float
    pins: list[Pin]
    rotation: int = 0


def load(lib_file: str, name: str) -> tuple[str, list[Pin]]:
    return extract_symbol(lib_file, name)


# ─── Component placement ────────────────────────────────────────────

esp_block, esp_pins = load("Connector_Generic.kicad_sym", "Conn_01x12")
drv_block, drv_pins = load("Driver_Motor.kicad_sym", "TB6612FNG")
imu_block, imu_pins = load("Sensor_Motion.kicad_sym", "MPU-6000")
bat_block, bat_pins = load("Device.kicad_sym", "Battery_Cell")
m_block, m_pins = load("Connector_Generic.kicad_sym", "Conn_01x02")

# Customise the LOLIN32 symbol: rename "Pin_N" → actual signal name so
# the connector body shows meaningful labels.
LOLIN_PIN_NAMES = {
    "1": "+3V3", "2": "GND", "3": "VBAT", "4": "STATUS_LED",
    "5": "SDA", "6": "SCL",
    "7": "PWMA", "8": "AIN1", "9": "AIN2",
    "10": "PWMB", "11": "BIN1", "12": "BIN2",
}
for number, friendly in LOLIN_PIN_NAMES.items():
    esp_block = re.sub(
        rf'(\(pin\s+\S+\s+\S+[^)]*?\(name\s+)"Pin_{number}"',
        rf'\1"{friendly}"',
        esp_block,
        count=1,
        flags=re.DOTALL,
    )
# Update the in-block name so lib_id can reference it as LOLIN32_Lite
esp_block = esp_block.replace(
    '"Connector_Generic:Conn_01x12"', '"MiniBot:LOLIN32_Lite"', 1,
)
esp_block = esp_block.replace("Conn_01x12_0_1", "LOLIN32_Lite_0_1")
esp_block = esp_block.replace("Conn_01x12_1_1", "LOLIN32_Lite_1_1")

# Update the pin name properties on the LOLIN32 symbol so they also
# update the value/reference defaults if any.
for old_inline in ("Generic connector", "Conn_01x12"):
    esp_block = esp_block.replace(old_inline, "LOLIN32_Lite")

SYMBOLS = {
    "MiniBot:LOLIN32_Lite": esp_block,
    "Driver_Motor:TB6612FNG": drv_block,
    "Sensor_Motion:MPU-6000": imu_block,
    "Device:Battery_Cell": bat_block,
    "Connector_Generic:Conn_01x02": m_block,
}

# Place components at chosen coordinates (mm). Use generous spacing
# so label stubs don't collide with pin numbers or each other.
esp = Component("MiniBot:LOLIN32_Lite", "J1", "LOLIN32 Lite", 90, 90, esp_pins)
drv = Component("Driver_Motor:TB6612FNG", "U1", "TB6612FNG", 200, 90, drv_pins)
imu = Component("Sensor_Motion:MPU-6000", "U2", "MPU-6050 (GY-521)", 90, 195, imu_pins)
bat = Component("Device:Battery_Cell", "BT1", "1S LiPo 3.7V", 35, 105, bat_pins)
m_lf = Component("Connector_Generic:Conn_01x02", "M1", "Motor LF", 280, 50, m_pins)
m_lr = Component("Connector_Generic:Conn_01x02", "M2", "Motor LR", 280, 80, m_pins)
m_rf = Component("Connector_Generic:Conn_01x02", "M3", "Motor RF", 280, 110, m_pins)
m_rr = Component("Connector_Generic:Conn_01x02", "M4", "Motor RR", 280, 140, m_pins)

all_components = [esp, drv, imu, bat, m_lf, m_lr, m_rf, m_rr]


# ─── ESP32 pin → net mapping (the LOLIN32's exposed 12-pin header) ──

esp_net_by_pin_number = {
    "1": "+3V3",
    "2": "GND",
    "3": "VBAT",
    "4": "STATUS_LED",
    "5": "SDA",
    "6": "SCL",
    "7": "PWMA",
    "8": "AIN1",
    "9": "AIN2",
    "10": "PWMB",
    "11": "BIN1",
    "12": "BIN2",
}


def driver_net(pin_name: str) -> str | None:
    mapping = {
        "VM1": "VBAT", "VM2": "VBAT", "VM3": "VBAT",
        "VCC": "+3V3", "STBY": "+3V3",
        "GND": "GND", "PGND1": "GND", "PGND2": "GND",
        "PWMA": "PWMA", "AIN1": "AIN1", "AIN2": "AIN2",
        "PWMB": "PWMB", "BIN1": "BIN1", "BIN2": "BIN2",
        "AO1": "LEFT+", "AO2": "LEFT-",
        "BO1": "RIGHT+", "BO2": "RIGHT-",
    }
    return mapping.get(pin_name)


def imu_net(pin_name: str) -> str | None:
    mapping = {
        "VDD": "+3V3", "GND": "GND",
        "SDA/MOSI": "SDA", "SCL/SCLK": "SCL",
    }
    return mapping.get(pin_name)


def motor_net(component_ref: str, pin_number: str) -> str:
    side = "LEFT" if component_ref in ("M1", "M2") else "RIGHT"
    return f"{side}+" if pin_number == "1" else f"{side}-"


# ─── Schematic generation ───────────────────────────────────────────


def symbol_instance(c: Component) -> str:
    sym_uuid = new_uuid()
    return f'''
  (symbol
    (lib_id "{c.lib_id}")
    (at {c.x} {c.y} {c.rotation})
    (unit 1)
    (exclude_from_sim no)
    (in_bom yes)
    (on_board yes)
    (dnp no)
    (uuid "{sym_uuid}")
    (property "Reference" "{c.ref}"
      (at {c.x} {c.y - 12} 0)
      (effects (font (size 1.27 1.27)) (justify left))
    )
    (property "Value" "{c.value}"
      (at {c.x} {c.y - 9} 0)
      (effects (font (size 1.27 1.27)) (justify left))
    )
    (instances
      (project "minibot"
        (path "/" (reference "{c.ref}") (unit 1))
      )
    )
  )'''


def pin_absolute(c: Component, pin: Pin) -> tuple[float, float, int]:
    """Compute absolute pin position assuming rotation 0."""
    return (c.x + pin.x, c.y + pin.y, pin.angle)


def label_stub(c: Component, pin: Pin, net: str, stub: float = 12.7) -> str:
    """Draw a short wire from a pin and place a labelled net at the end."""
    px, py, angle = pin_absolute(c, pin)
    dx, dy = {0: (stub, 0), 90: (0, -stub), 180: (-stub, 0), 270: (0, stub)}[angle]
    ex, ey = px + dx, py + dy
    label_justify = "left" if dx >= 0 else "right"
    return f'''
  (wire
    (pts (xy {px} {py}) (xy {ex} {ey}))
    (stroke (width 0) (type default))
    (uuid "{new_uuid()}")
  )
  (label "{net}"
    (at {ex} {ey} 0)
    (effects (font (size 1.27 1.27)) (justify {label_justify} bottom))
    (uuid "{new_uuid()}")
  )'''


body = [symbol_instance(c) for c in all_components]

# ESP32 connector — pin names already show the net inside the symbol,
# so just attach a short stub + label so the net is also explicitly
# connected.
for pin in esp.pins:
    net = esp_net_by_pin_number.get(pin.number)
    if net:
        body.append(label_stub(esp, pin, net, stub=5.08))

# TB6612FNG driver pins → labels
for pin in drv.pins:
    net = driver_net(pin.name)
    if net:
        body.append(label_stub(drv, pin, net))

# IMU pins → labels
for pin in imu.pins:
    net = imu_net(pin.name)
    if net:
        body.append(label_stub(imu, pin, net))

# Battery
for pin in bat.pins:
    if pin.name == "+":
        body.append(label_stub(bat, pin, "VBAT"))
    elif pin.name == "-":
        body.append(label_stub(bat, pin, "GND"))

# Motors
for motor in (m_lf, m_lr, m_rf, m_rr):
    for pin in motor.pins:
        body.append(label_stub(motor, pin, motor_net(motor.ref, pin.number)))


# ─── Write the schematic ────────────────────────────────────────────

lib_symbols_block = "\n".join(SYMBOLS.values())

sch = f'''(kicad_sch
  (version 20231120)
  (generator "minibot-build")
  (uuid "{new_uuid()}")
  (paper "A3")
  (title_block
    (title "minibot")
    (rev "1.0")
    (company "minibot project")
  )
  (lib_symbols
{lib_symbols_block}
  )
{"".join(body)}
)
'''

SCH_PATH.write_text(sch)
print(f"wrote {SCH_PATH}")

# Render PDF
result = subprocess.run(
    [str(KICAD_CLI), "sch", "export", "pdf", "-o", str(PDF_PATH), str(SCH_PATH)],
    capture_output=True, text=True,
)
if result.returncode != 0:
    print("kicad-cli error:")
    print(result.stderr)
else:
    print(f"wrote {PDF_PATH}")
    subprocess.run(
        ["pdftoppm", "-r", "150", "-png", str(PDF_PATH), str(OUT / "circuit")],
        check=False,
    )
    legacy = OUT / "circuit-1.png"
    final = OUT / "circuit.png"
    if legacy.exists():
        if final.exists():
            final.unlink()
        legacy.rename(final)
    print(f"wrote {final}")
