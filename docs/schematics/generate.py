#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["schemdraw>=0.20", "matplotlib>=3.9"]
# ///
"""Generate minibot schematic diagrams as PNG files.

Outputs to docs/schematics/:
    system.png   — top-level system block diagram
    wiring.png   — pin-level wiring between ESP32 and TB6612FNG
    power.png    — battery / 3V3 / VM power distribution
"""

from pathlib import Path

import schemdraw
import schemdraw.elements as elm
import schemdraw.flow as flow

OUT = Path(__file__).resolve().parent


def system() -> None:
    with schemdraw.Drawing(file=str(OUT / "system.png"), show=False) as d:
        d.config(unit=2.5, fontsize=11)

        ps3 = flow.Box(w=3, h=1.6).label("PS3 Controller\n(BT Classic)")
        d += ps3
        d += elm.Arrow().right().length(2.5).label("HID / BT", loc="top")

        esp = flow.Box(w=3.6, h=2).label("ESP32\nLOLIN32 Lite")
        d += esp
        d += elm.Arrow().right().length(2.5).label("PWM + dir\n3.3V logic", loc="top")

        driver = flow.Box(w=3.6, h=2).label("TB6612FNG\nDual H-bridge")
        d += driver
        d += elm.Arrow().right().length(2.5).label("Motor power\nVM rail", loc="top")

        motors = flow.Box(w=3.2, h=2).label("4x N20\n2 paired/side")
        d += motors

        d.move_from(esp.S, 0, -2)
        battery = flow.Box(w=3.6, h=1.4).label("1S LiPo\n3.7V / 1200mAh")
        d += battery

        d += elm.Line().up().at(battery.N).to(esp.S)
        d += elm.Line().right().at(battery.E).length(7)
        d += elm.Arrow().up().to(driver.S).label("VM rail\n(battery+)", loc="right")


def wiring() -> None:
    with schemdraw.Drawing(file=str(OUT / "wiring.png"), show=False, canvas="matplotlib") as d:
        d.config(unit=1, fontsize=10)

        IcPin = elm.IcPin

        esp_pins = [
            IcPin(name="3V3", side="right"),
            IcPin(name="GND", side="right"),
            IcPin(name="VBAT(+)", side="right"),
            IcPin(name="GPIO 19", side="right"),
            IcPin(name="GPIO 13", side="right"),
            IcPin(name="GPIO 14", side="right"),
            IcPin(name="GPIO 27", side="right"),
            IcPin(name="GPIO 26", side="right"),
            IcPin(name="GPIO 16", side="right"),
            IcPin(name="GPIO 17", side="right"),
        ]
        esp = elm.Ic(pins=esp_pins, w=3, pinspacing=0.7).label("ESP32\nLOLIN32 Lite", "top")
        d += esp

        drv_pins = [
            IcPin(name="VCC", side="left"),
            IcPin(name="GND", side="left"),
            IcPin(name="VM", side="left"),
            IcPin(name="STBY", side="left"),
            IcPin(name="PWMA", side="left"),
            IcPin(name="AIN1", side="left"),
            IcPin(name="AIN2", side="left"),
            IcPin(name="PWMB", side="left"),
            IcPin(name="BIN1", side="left"),
            IcPin(name="BIN2", side="left"),
            IcPin(name="AO1", side="right"),
            IcPin(name="AO2", side="right"),
            IcPin(name="BO1", side="right"),
            IcPin(name="BO2", side="right"),
        ]
        drv = elm.Ic(pins=drv_pins, w=3, pinspacing=0.7).at((6, 0)).label("TB6612FNG", "top")
        d += drv

        # Map ESP pin index to TB6612 pin index for the wiring connections
        connections = [
            (0, 0, "3.3V"),    # 3V3 -> VCC
            (0, 3, "3.3V"),    # 3V3 -> STBY (branch)
            (1, 1, "GND"),     # GND -> GND
            (2, 2, "VBAT"),    # VBAT -> VM
            (4, 4, "PWMA"),    # GPIO 13 -> PWMA
            (5, 5, "AIN1"),    # GPIO 14 -> AIN1
            (6, 6, "AIN2"),    # GPIO 27 -> AIN2
            (7, 7, "PWMB"),    # GPIO 26 -> PWMB
            (8, 8, "BIN1"),    # GPIO 16 -> BIN1
            (9, 9, "BIN2"),    # GPIO 17 -> BIN2
        ]

        for esp_idx, drv_idx, _ in connections:
            esp_pin = list(esp.anchors.values())[esp_idx + 4]  # skip header anchors
            drv_pin = list(drv.anchors.values())[drv_idx + 4]
            try:
                d += elm.Wire("-|").at(esp.absanchors[f"inR{esp_idx + 1}"]).to(
                    drv.absanchors[f"inL{drv_idx + 1}"]
                )
            except KeyError:
                pass

        # Motor terminals
        for i, lbl in enumerate(("LEFT motors +", "LEFT motors −", "RIGHT motors +", "RIGHT motors −")):
            try:
                d += elm.Line().right().at(drv.absanchors[f"inR{i + 1}"]).length(1.5).label(lbl, loc="right")
            except KeyError:
                pass


def power() -> None:
    with schemdraw.Drawing(file=str(OUT / "power.png"), show=False) as d:
        d.config(unit=2.5, fontsize=11)

        battery = flow.Box(w=3, h=1.6).label("1S LiPo\n3.7V / 1200mAh")
        d += battery

        d += elm.Arrow().right().length(2).label("VBAT (+)\n3.0–4.2V", loc="top")
        vbat = elm.Dot().label("VBAT")
        d += vbat

        # Up to LOLIN32 LDO -> 3V3
        d += elm.Line().up().length(2).at(vbat.center)
        d += elm.Arrow().right().length(2)
        ldo = flow.Box(w=3, h=1.4).label("LOLIN32\nLDO 3.3V")
        d += ldo
        d += elm.Arrow().right().length(2).label("3V3 logic", loc="top")
        d += flow.Box(w=3, h=1.4).label("ESP32 core\nTB6612 VCC/STBY")

        # Right from VBAT -> TB6612 VM
        d += elm.Line().down().length(2).at(vbat.center)
        d += elm.Arrow().right().length(2).label("VBAT (raw)", loc="bottom")
        vm = flow.Box(w=3, h=1.4).label("TB6612FNG\nVM rail")
        d += vm
        d += elm.Arrow().right().length(2).label("3–4A peak", loc="bottom")
        d += flow.Box(w=3, h=1.4).label("4x N20\nmotors")

        # GND rail at the bottom
        d.move(-15, -3)
        d += elm.Line().right().length(15).label("GND (common: battery − / ESP32 GND / TB6612 GND)", loc="bottom")


if __name__ == "__main__":
    system()
    wiring()
    power()
    print(f"wrote: {OUT / 'system.png'}")
    print(f"wrote: {OUT / 'wiring.png'}")
    print(f"wrote: {OUT / 'power.png'}")
