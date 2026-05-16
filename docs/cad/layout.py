#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["matplotlib>=3.9"]
# ///
"""Top-down chassis layout — matches chassis.scad geometry.

Shows the enclosed-box design where wheels sit entirely inside the
chassis perimeter and poke out only through cutouts in the top and
bottom plates.
"""

from pathlib import Path

import matplotlib.patches as patches
import matplotlib.pyplot as plt

OUT = Path(__file__).resolve().parent

# ─── parameters (kept in sync with chassis.scad) ────────────────────
plate_length = 120
plate_width = 130
wall_thick = 3

motor_diameter = 12.2
motor_length = 25
motor_axle_pitch = 70
motor_center_y = (plate_width / 2) - wall_thick - 4 - motor_length / 2

wheel_diameter = 33
wheel_width = 20
wheel_inset_from_motor = 15
wheel_center_y = motor_center_y - motor_length / 2 - wheel_inset_from_motor

esp_length = 52
esp_width = 25
driver_length = 26
driver_width = 26
battery_length = 45
battery_width = 25

motor_positions = [
    (-motor_axle_pitch / 2,  motor_center_y),
    (-motor_axle_pitch / 2, -motor_center_y),
    ( motor_axle_pitch / 2,  motor_center_y),
    ( motor_axle_pitch / 2, -motor_center_y),
]

wheel_positions = [
    (-motor_axle_pitch / 2,  wheel_center_y),
    (-motor_axle_pitch / 2, -wheel_center_y),
    ( motor_axle_pitch / 2,  wheel_center_y),
    ( motor_axle_pitch / 2, -wheel_center_y),
]


def render() -> None:
    fig, ax = plt.subplots(figsize=(11, 9), dpi=140)

    # Outer chassis outline
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2, -plate_width / 2),
        plate_length, plate_width,
        linewidth=2.5, edgecolor="black", facecolor="#f4ecdc",
    ))
    # Inner void (the cavity)
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2 + wall_thick, -plate_width / 2 + wall_thick),
        plate_length - 2 * wall_thick, plate_width - 2 * wall_thick,
        linewidth=1, edgecolor="#aaa", facecolor="#fffaf0", linestyle="--",
    ))
    ax.text(0, plate_width / 2 - 8, "PETG translucent shell (3mm walls all around)",
            ha="center", fontsize=8.5, color="#666")

    # Wheel cutouts in the plate (visible from above)
    for x, y in wheel_positions:
        ax.add_patch(patches.FancyBboxPatch(
            (x - 33 / 2, y - wheel_width / 2),
            33, wheel_width,
            boxstyle="round,pad=0.5",
            linewidth=1.5, edgecolor="#222", facecolor="#3a3a3a", alpha=0.85,
        ))
        ax.text(x, y, "wheel\ncutout", ha="center", va="center",
                fontsize=6.5, color="white")

    # Motors (under the cutouts visually, but at different Y)
    for x, y in motor_positions:
        ax.add_patch(patches.Rectangle(
            (x - motor_diameter / 2, y - motor_length / 2),
            motor_diameter, motor_length,
            linewidth=1, edgecolor="#666", facecolor="#cfcfcf", alpha=0.9,
        ))
        ax.text(x, y, "N20", ha="center", va="center", fontsize=6.5, color="#222")
        # shaft arrow toward chassis centre
        ax.annotate("", xy=(x, y - motor_length / 2 - 13 if y > 0 else y + motor_length / 2 + 13),
                    xytext=(x, y - motor_length / 2 if y > 0 else y + motor_length / 2),
                    arrowprops=dict(arrowstyle="->", color="#777", lw=1.2))

    # Electronics: ESP32 centered-left
    esp_cx, esp_cy = -30, 0
    ax.add_patch(patches.Rectangle(
        (esp_cx - esp_length / 2, esp_cy - esp_width / 2),
        esp_length, esp_width,
        linewidth=1, edgecolor="#055", facecolor="#7ec8c8", alpha=0.85,
    ))
    ax.text(esp_cx, esp_cy, "ESP32 LOLIN32 Lite\n(52×25mm)", ha="center", va="center", fontsize=7, color="#022")

    # TB6612 right-lower
    drv_cx, drv_cy = 20, -15
    ax.add_patch(patches.Rectangle(
        (drv_cx - driver_length / 2, drv_cy - driver_width / 2),
        driver_length, driver_width,
        linewidth=1, edgecolor="#722", facecolor="#e08e8e", alpha=0.85,
    ))
    ax.text(drv_cx, drv_cy, "TB6612\n(26×26)", ha="center", va="center", fontsize=7, color="#311")

    # Battery right-upper
    bat_cx, bat_cy = 20, 15
    ax.add_patch(patches.Rectangle(
        (bat_cx - battery_length / 2, bat_cy - battery_width / 2),
        battery_length, battery_width,
        linewidth=1, edgecolor="#640", facecolor="#e8c878", alpha=0.85,
    ))
    ax.text(bat_cx, bat_cy, "1S LiPo 1200mAh\n(45×25×7)", ha="center", va="center", fontsize=7, color="#311")

    # USB slot indicator on the front wall
    ax.plot([-plate_length / 2 + 0.5, -plate_length / 2 + 0.5], [-6, 6], color="red", lw=3)
    ax.text(-plate_length / 2 - 3, 0, "USB\nslot", ha="right", va="center", fontsize=7, color="red")

    # Corner mount holes
    for sx in (-1, 1):
        for sy in (-1, 1):
            ax.add_patch(patches.Circle(
                (sx * (plate_length / 2 - 7), sy * (plate_width / 2 - 7)),
                1.6, color="#333", zorder=10,
            ))

    # Direction arrow
    ax.annotate("", xy=(-plate_length / 2 - 8, plate_width / 2),
                xytext=(-plate_length / 2 - 8, plate_width / 2 - 12),
                arrowprops=dict(arrowstyle="->", color="#888", lw=1.5))
    ax.text(-plate_length / 2 - 13, plate_width / 2 - 6, "front", fontsize=8, color="#888",
            va="center", ha="right")

    ax.set_xlim(-plate_length / 2 - 25, plate_length / 2 + 25)
    ax.set_ylim(-plate_width / 2 - 15, plate_width / 2 + 15)
    ax.set_aspect("equal")
    ax.set_title(
        f"minibot chassis — top-down layout (enclosed, wheels inside)\n"
        f"{plate_length}×{plate_width}×18mm  •  3mm walls all around  •  invertible",
        fontsize=11,
    )
    ax.set_xlabel("mm")
    ax.set_ylabel("mm")
    ax.grid(True, linestyle=":", alpha=0.4)

    fig.tight_layout()
    fig.savefig(OUT / "layout.png", bbox_inches="tight")
    print(f"wrote: {OUT / 'layout.png'}")


if __name__ == "__main__":
    render()
