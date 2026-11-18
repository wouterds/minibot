#!/usr/bin/env python3
"""Draws images/wiring.svg: every wire, pad to pad, in the colour it is soldered in.

The boards are spread out so the wires stay readable; it is not to scale and not where the parts
sit in the hull. images/layout.png shows that.
"""
from pathlib import Path

W, H = 1400, 1070
RED, BLACK, YELLOW, GREEN, BLUE = "#e02a22", "#17181a", "#f2c400", "#22a045", "#2a6fe0"
WHITE, ORANGE = "#fbfbf8", "#f47a12"
out = []


def text(x, y, s, size=15, anchor="start", weight="normal", fill="#1b1d21"):
    out.append(
        f'<text x="{x}" y="{y}" font-size="{size}" text-anchor="{anchor}" font-weight="{weight}" fill="{fill}">{s}</text>'
    )


def board(x0, y0, x1, y1, fill, title, sub=None, light=True):
    out.append(f'<rect x="{x0}" y="{y0}" width="{x1 - x0}" height="{y1 - y0}" rx="8" fill="{fill}" stroke="#14161a" stroke-width="2"/>')
    ink = "#ffffff" if light else "#1b1d21"
    text((x0 + x1) / 2, y0 + 26, title, 17, "middle", "bold", ink)
    if sub:
        text((x0 + x1) / 2, y0 + 46, sub, 12, "middle", fill=ink)


pads = []


# side: where the label goes, seen from the pad
def pad(x, y, label, side="right", used=True, ink="#ffffff"):
    pads.append((x, y, used))
    dx, anchor = {"right": (14, "start"), "left": (-14, "end"), "above": (0, "middle"), "below": (0, "middle")}[side]
    dy = {"right": 5, "left": 5, "above": -14, "below": 24}[side]
    text(x + dx, y + dy, label, 13, anchor, "bold" if used else "normal", ink if used else "#9aa3ad")


wires = []


def wire(colour, *points):
    wires.append((colour, points))


def resistor(x, y, label):
    parts.append(f'<rect x="{x - 18}" y="{y - 8}" width="36" height="16" rx="3" fill="#d9c7a1" stroke="#14161a" stroke-width="1.5"/>')
    parts.append(f'<text x="{x}" y="{y - 13}" font-size="12" text-anchor="middle" fill="#1b1d21">{label}</text>')


parts = []

# ---------- boards ----------

# charger, pads on its right edge
board(300, 70, 500, 230, "#1f4f8f", "TP4056", "USB-C charger")
out.append('<rect x="286" y="128" width="30" height="44" rx="6" fill="#b9bcc2" stroke="#14161a" stroke-width="2"/>')
for y, name in [(95, "OUT+"), (135, "B+"), (175, "B−"), (215, "OUT−")]:
    pad(500, y, name, "left")

board(600, 105, 860, 205, "#c7ccd1", "Battery", "1S LiPo, 2000 mAh", light=False)

# motor driver, inputs towards the ESP32, outputs towards the motors
board(300, 470, 490, 730, "#6a2c91", "")
text(300, 460, "DRV8833", 17, weight="bold")
for i, name in enumerate(["IN1", "IN2", "VCC", "GND", "IN3", "IN4"]):
    pad(490, 500 + 40 * i, name, "left")
for i, name in enumerate(["EEP", "OUT1", "OUT2", "OUT3", "OUT4", "ULT"]):
    pad(300, 500 + 40 * i, name, "right", used=name != "ULT")

for y, name in [(440, "front left"), (540, "rear left"), (640, "front right"), (740, "rear right")]:
    board(60, y, 200, y + 80, "#8d9299", "N20", name)
    pad(200, y + 25, "", "left")
    pad(200, y + 55, "", "left")

# ESP32, seen from its component side with the USB end down
board(640, 320, 860, 950, "#1d2b36", "ESP32", "LOLIN32 Lite")
left = ["VP", "VN", "EN", "34", "35", "32", "33", "25", "26", "27", "14", "12", "G"]
right = ["3V", "22", "19", "23", "18", "5", "17", "16", "4", "0", "2", "15", "13"]
used = {"34", "35", "32", "33", "25", "26", "27", "G", "3V", "19", "23", "17", "16", "4", "13"}
esp_y = {}
for i, (a, b) in enumerate(zip(left, right)):
    y = 370 + 44 * i
    esp_y[a] = esp_y[b] = y
    pad(640, y, a, "right", a in used)
    pad(860, y, b, "left", b in used)
text(746, 690, "battery sense:", 11, fill="#9aa3ad")
text(746, 704, "2 × 10 kΩ,", 11, fill="#9aa3ad")
text(746, 718, "100 nF, 35 to G", 11, fill="#9aa3ad")
text(800, 419, "onboard LED", 11, "end", fill="#9aa3ad")
text(804, 916, "micro-USB", 11, "middle", fill="#9aa3ad")
out.append('<rect x="672" y="905" width="76" height="45" rx="4" fill="#e9e6dc" stroke="#14161a" stroke-width="2"/>')
text(718, 922, "battery", 11, "middle")
pad(690, 950, "", "above")
pad(730, 950, "", "above")
text(677, 945, "+", 13, "middle", "bold")
text(743, 945, "−", 13, "middle", "bold")
out.append('<rect x="776" y="925" width="56" height="34" rx="5" fill="#b9bcc2" stroke="#14161a" stroke-width="2"/>')

# IMU, pads on its left edge
board(1080, 320, 1240, 705, "#1f4f8f", "MPU-6050", "GY-521")
for i, name in enumerate(["VCC", "GND", "SCL", "SDA", "XDA", "XCL", "AD0", "INT"]):
    pad(1080, 370 + 44 * i, name, "right", used=name not in ("XDA", "XCL", "AD0"))

# status LED: legs red, common (the long one), green, blue
out.append('<path d="M1150 772 h70 a64 64 0 0 1 0 128 h-70 z" fill="#f4f1f3" stroke="#14161a" stroke-width="2"/>')
out.append('<rect x="1140" y="766" width="14" height="140" rx="3" fill="#f4f1f3" stroke="#14161a" stroke-width="2"/>')
for y in (790, 820, 850, 880):
    out.append(f'<line x1="1120" y1="{y}" x2="1140" y2="{y}" stroke="#8d9299" stroke-width="4"/>')
text(1224, 806, "RGB LED", 17, "middle", "bold")
text(1224, 824, "10 mm", 12, "middle")
text(1120, 928, "Long leg to minus: common cathode.", 12)
text(1120, 944, "Common anode: long leg to OUT+.", 12)
for y, name in [(790, "B"), (820, "G"), (850, "long leg"), (880, "R")]:
    pad(1120, y, "", "left")
    text(1162, y + 5, name, 12, fill="#1b1d21")

out.append('<circle cx="1010" cy="940" r="45" fill="#1b1c1f" stroke="#14161a" stroke-width="2"/>')
text(1010, 945, "buzzer", 14, "middle", "bold", "#ffffff")
pad(965, 925, "+", "right")
pad(965, 955, "−", "right")

# capacitor across the driver's supply
out.append('<path d="M490 580 h20 M490 620 h20" stroke="#8d9299" stroke-width="4"/>')
out.append('<rect x="506" y="574" width="26" height="52" rx="6" fill="#30343a" stroke="#14161a" stroke-width="2"/>')
text(519, 592, "+", 13, "middle", "bold", "#ffffff")
text(384, 752, "220–470 µF across VCC and GND, + on VCC", 11)

# ---------- wires ----------

# battery to the charger: the cell's own leads
wire(RED, (600, 135), (500, 135))
wire(BLACK, (600, 175), (500, 175))

# charger to the driver
wire(RED, (500, 95), (520, 95), (520, 50), (270, 50), (270, 290), (398, 290), (398, 560), (490, 560), (490, 580))
wire(BLACK, (500, 215), (528, 215), (528, 262), (412, 262), (412, 640), (490, 640), (490, 620))

# charger to the ESP32: plus to the + leg of its battery socket, minus to its G pad
wire(RED, (500, 95), (528, 95), (528, 38), (40, 38), (40, 1010), (690, 1010), (690, 950))
wire(BLACK, (500, 215), (520, 215), (520, 250), (52, 250), (52, 998), (606, 998), (606, 898), (640, 898))

# ESP32 to the driver
wire(YELLOW, (640, esp_y["32"]), (590, esp_y["32"]), (590, 500), (490, 500))
wire(GREEN, (640, esp_y["33"]), (572, esp_y["33"]), (572, 540), (490, 540))
wire(BLUE, (640, esp_y["25"]), (554, esp_y["25"]), (554, 660), (490, 660))
wire(WHITE, (640, esp_y["26"]), (536, esp_y["26"]), (536, 700), (490, 700))
wire(ORANGE, (640, esp_y["27"]), (622, esp_y["27"]), (622, 800), (372, 800), (372, 484), (300, 484), (300, 500))

# driver to the motors, two motors on each pair of outputs
wire(RED, (300, 540), (270, 540), (270, 465), (200, 465))
wire(RED, (300, 540), (270, 540), (270, 565), (200, 565))
wire(BLACK, (300, 580), (250, 580), (250, 495), (200, 495))
wire(BLACK, (300, 580), (250, 580), (250, 595), (200, 595))
wire(RED, (300, 620), (250, 620), (250, 665), (200, 665))
wire(RED, (300, 620), (250, 620), (250, 765), (200, 765))
wire(BLACK, (300, 660), (270, 660), (270, 695), (200, 695))
wire(BLACK, (300, 660), (270, 660), (270, 795), (200, 795))

# ESP32 to the IMU
wire(RED, (860, esp_y["3V"]), (1080, 370))
wire(YELLOW, (860, esp_y["19"]), (1080, 458))
wire(BLUE, (860, esp_y["23"]), (1080, 502))
wire(BLACK, (500, 215), (536, 215), (536, 300), (940, 300), (940, 414), (1080, 414))
wire(WHITE, (1080, 678), (1060, 678), (1060, 726), (1270, 726), (1270, 284), (614, 284), (614, esp_y["34"]), (640, esp_y["34"]))

# ESP32 to the status LED, a resistor in each colour
wire(BLUE, (860, esp_y["17"]), (1000, esp_y["17"]), (1000, 790), (1120, 790))
wire(GREEN, (860, esp_y["16"]), (980, esp_y["16"]), (980, 820), (1120, 820))
wire(ORANGE, (860, esp_y["4"]), (960, esp_y["4"]), (960, 880), (1120, 880))
wire(BLACK, (1120, 850), (1090, 850), (1090, 987), (724, 987), (724, 950))
for y in (790, 820, 880):
    resistor(1050, y, "")
text(1050, 772, "3 resistors", 12, "middle")

# ESP32 to the buzzer
wire(WHITE, (860, esp_y["13"]), (930, esp_y["13"]), (930, 925), (965, 925))
wire(BLACK, (965, 955), (930, 955), (930, 975), (736, 975), (736, 950))

# battery sense: the socket's + leg and G to 35, a resistor in each
wire(RED, (640, esp_y["35"]), (654, 558), (730, 558), (730, 898), (690, 898), (690, 950))
wire(BLACK, (640, esp_y["35"]), (654, 572), (700, 572), (700, 876), (654, 876), (640, 898))
for x in (700, 730):
    parts.append(f'<rect x="{x - 8}" y="682" width="16" height="36" rx="3" fill="#d9c7a1" stroke="#14161a" stroke-width="1.5"/>')

# ---------- page ----------

svg = [
    f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" font-family="Helvetica, Arial, sans-serif">',
    f'<rect width="{W}" height="{H}" fill="#e9ecf0"/>',
]
svg += out
for colour, points in wires:
    d = "M" + " L".join(f"{x} {y}" for x, y in points)
    svg.append(f'<path d="{d}" fill="none" stroke="#14161a" stroke-width="8" stroke-linejoin="round" stroke-linecap="round"/>')
    svg.append(f'<path d="{d}" fill="none" stroke="{colour}" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>')
svg += parts
for x, y, used_pad in pads:
    fill = "#e8c35a" if used_pad else "#7c8490"
    svg.append(f'<circle cx="{x}" cy="{y}" r="8" fill="{fill}" stroke="#14161a" stroke-width="2"/>')

legend = [
    (RED, "plus: battery, 3.3 V, one lead of each motor"),
    (BLACK, "minus: ground, the other lead of each motor"),
    (YELLOW, "IN1, SCL"),
    (GREEN, "IN2, LED green"),
    (BLUE, "IN3, SDA, LED blue"),
    (WHITE, "IN4, INT, buzzer"),
    (ORANGE, "EEP, LED red"),
]
for i, (colour, meaning) in enumerate(legend):
    y = 56 + 22 * i
    svg.append(f'<rect x="930" y="{y - 11}" width="34" height="14" rx="3" fill="{colour}" stroke="#14161a" stroke-width="1.5"/>')
    svg.append(f'<text x="974" y="{y + 1}" font-size="14" fill="#1b1d21">{meaning}</text>')
svg.append(f'<text x="930" y="226" font-size="12" fill="#4a5059">Not to scale. Follow the names printed on your boards:</text>')
svg.append(f'<text x="930" y="242" font-size="12" fill="#4a5059">the order of the pads can differ from this drawing.</text>')
svg.append("</svg>")

Path(__file__).resolve().parents[2].joinpath("images/wiring.svg").write_text("\n".join(svg) + "\n")
