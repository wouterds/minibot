#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["matplotlib>=3.9"]
# ///
"""Render a top-down preview of the chassis layout.

Reads the same parameters as chassis.scad and emits a PNG showing the
plate outline, motor positions, board pockets, battery pocket and
wheel wells.
"""

from pathlib import Path

import matplotlib.patches as patches
import matplotlib.pyplot as plt

OUT = Path(__file__).resolve().parent

# ─── parameters (kept in sync with chassis.scad) ────────────────────
plate_length = 110
plate_width = 80

motor_diameter = 12.2
motor_length = 25
motor_axle_pitch = 70
motor_track = 56

wheel_diameter = 33
wheel_width = 20

esp_length = 52
esp_width = 25

driver_length = 26
driver_width = 26

battery_length = 45
battery_width = 25

motor_positions = [
    (-motor_axle_pitch / 2,  motor_track / 2),
    (-motor_axle_pitch / 2, -motor_track / 2),
    ( motor_axle_pitch / 2,  motor_track / 2),
    ( motor_axle_pitch / 2, -motor_track / 2),
]


def render() -> None:
    fig, ax = plt.subplots(figsize=(11, 8), dpi=140)

    # Plate outline
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2, -plate_width / 2),
        plate_length, plate_width,
        linewidth=2, edgecolor="black", facecolor="#f4ecdc",
    ))
    ax.text(0, plate_width / 2 - 5, "PETG translucent plate", ha="center", fontsize=9, color="#888")

    # Wheels (drawn as protruding past the plate edges)
    for x, y in motor_positions:
        side_y = (plate_width / 2) if y > 0 else -plate_width / 2
        wheel_y = side_y + (wheel_diameter / 2 - 7.5) * (1 if y > 0 else -1)
        ax.add_patch(patches.Rectangle(
            (x - wheel_width / 2, side_y - wheel_diameter / 2 if y > 0 else side_y - wheel_diameter / 2),
            wheel_width, wheel_diameter,
            linewidth=1, edgecolor="#444", facecolor="#222", alpha=0.85,
        ))
        ax.text(x, side_y + (wheel_diameter / 2 + 5) * (1 if y > 0 else -1),
                "wheel\n33×20mm", ha="center", va="center", fontsize=7, color="#444")

    # Motors (visible cylinders inside the chassis)
    for x, y in motor_positions:
        ax.add_patch(patches.Rectangle(
            (x - motor_length / 2, y - motor_diameter / 2),
            motor_length, motor_diameter,
            linewidth=1, edgecolor="#666", facecolor="#bdbdbd",
        ))
        ax.text(x, y, "N20\n6V 400rpm", ha="center", va="center", fontsize=6.5, color="#222")

    # ESP32 board (lays across the middle horizontally)
    esp_cx, esp_cy = -15, 7
    ax.add_patch(patches.Rectangle(
        (esp_cx - esp_length / 2, esp_cy - esp_width / 2),
        esp_length, esp_width,
        linewidth=1, edgecolor="#055", facecolor="#7ec8c8", alpha=0.85,
    ))
    ax.text(esp_cx, esp_cy, "ESP32 LOLIN32 Lite\n(52×25mm)", ha="center", va="center", fontsize=7, color="#022")

    # TB6612 board (next to ESP32)
    drv_cx, drv_cy = 25, 7
    ax.add_patch(patches.Rectangle(
        (drv_cx - driver_length / 2, drv_cy - driver_width / 2),
        driver_length, driver_width,
        linewidth=1, edgecolor="#722", facecolor="#e08e8e", alpha=0.85,
    ))
    ax.text(drv_cx, drv_cy, "TB6612FNG\n(26×26mm)", ha="center", va="center", fontsize=7, color="#311")

    # Battery (below ESP32+TB6612)
    bat_cx, bat_cy = 0, -18
    ax.add_patch(patches.Rectangle(
        (bat_cx - battery_length / 2, bat_cy - battery_width / 2),
        battery_length, battery_width,
        linewidth=1, edgecolor="#640", facecolor="#e8c878", alpha=0.85,
    ))
    ax.text(bat_cx, bat_cy, "1S LiPo 1200mAh\n(45×25×~7mm)", ha="center", va="center", fontsize=7, color="#311")

    # USB access slot indicator (on the bottom edge)
    ax.plot([esp_cx - 6, esp_cx + 6], [-plate_width / 2 - 0.5, -plate_width / 2 - 0.5], color="red", lw=3)
    ax.text(esp_cx, -plate_width / 2 - 4, "USB / power switch slot", ha="center", fontsize=7, color="red")

    # Mounting holes at corners
    for sx in (-1, 1):
        for sy in (-1, 1):
            ax.add_patch(patches.Circle(
                (sx * (plate_length / 2 - 6), sy * (plate_width / 2 - 6)),
                1.6, color="#333", zorder=10,
            ))

    # Direction indicator
    ax.annotate("", xy=(-plate_length / 2 + 4, 0), xytext=(-plate_length / 2 + 14, 0),
                arrowprops=dict(arrowstyle="->", color="#888", lw=1.5))
    ax.text(-plate_length / 2 + 16, 0, "front", fontsize=8, color="#888", va="center")

    ax.set_xlim(-plate_length / 2 - 25, plate_length / 2 + 25)
    ax.set_ylim(-plate_width / 2 - 25, plate_width / 2 + 25)
    ax.set_aspect("equal")
    ax.set_title(f"minibot chassis — top-down layout\n"
                 f"{plate_length}×{plate_width}×18mm (3mm plate + 12mm motor cavity + 3mm plate)",
                 fontsize=11)
    ax.set_xlabel("mm")
    ax.set_ylabel("mm")
    ax.grid(True, linestyle=":", alpha=0.4)

    fig.tight_layout()
    fig.savefig(OUT / "layout.png", bbox_inches="tight")
    print(f"wrote: {OUT / 'layout.png'}")


if __name__ == "__main__":
    render()
