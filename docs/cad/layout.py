#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["matplotlib>=3.9"]
# ///
"""Top-down chassis layout — mirrors chassis.scad geometry."""

from pathlib import Path

import matplotlib.patches as patches
import matplotlib.pyplot as plt

OUT = Path(__file__).resolve().parent

# ─── parameters (kept in sync with chassis.scad) ────────────────────
plate_length = 136
plate_width = 110
wall_thick = 3

motor_diameter = 12.2
motor_length = 25
motor_axle_pitch = 70
motor_track = 35

wheel_diameter = 33
wheel_width = 20

motor_center_y = motor_track / 2
wheel_center_y = motor_center_y + motor_length / 2 + wheel_width / 2

esp_length, esp_width = 52, 25
driver_length, driver_width = 22, 22
battery_length, battery_width = 45, 25
imu_length, imu_width = 21, 16

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
    fig, ax = plt.subplots(figsize=(10, 10), dpi=140)

    # Outer chassis outline
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2, -plate_width / 2),
        plate_length, plate_width,
        linewidth=2.5, edgecolor="black", facecolor="#f4ecdc",
    ))
    # Inner cavity (dashed)
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2 + wall_thick, -plate_width / 2 + wall_thick),
        plate_length - 2 * wall_thick, plate_width - 2 * wall_thick,
        linewidth=1, edgecolor="#aaa", facecolor="#fffaf0", linestyle="--",
    ))

    # Wheel cutouts (poking out of top + bottom plates)
    for x, y in wheel_positions:
        ax.add_patch(patches.FancyBboxPatch(
            (x - 30 / 2, y - wheel_width / 2),
            30, wheel_width,
            boxstyle="round,pad=0.5,rounding_size=2",
            linewidth=1.2, edgecolor="#222", facecolor="#3a3a3a", alpha=0.85,
        ))
        ax.text(x, y, "wheel\ncutout", ha="center", va="center",
                fontsize=6.5, color="white")

    # Motors with shaft arrows pointing outward
    for x, y in motor_positions:
        ax.add_patch(patches.Rectangle(
            (x - motor_diameter / 2, y - motor_length / 2),
            motor_diameter, motor_length,
            linewidth=1, edgecolor="#666", facecolor="#cfcfcf", alpha=0.9,
        ))
        ax.text(x, y, "N20", ha="center", va="center", fontsize=6.5, color="#222")
        # arrow indicating shaft direction (outward)
        sign = 1 if y > 0 else -1
        ax.annotate(
            "", xy=(x, y + sign * (motor_length / 2 + 10)),
            xytext=(x, y + sign * motor_length / 2),
            arrowprops=dict(arrowstyle="->", color="#777", lw=1.2),
        )

    # TB6612 (front, between the front wall and front motors)
    drv_x = -53
    ax.add_patch(patches.Rectangle(
        (drv_x - driver_length / 2, -driver_width / 2),
        driver_length, driver_width,
        linewidth=1, edgecolor="#722", facecolor="#e08e8e", alpha=0.85,
    ))
    ax.text(drv_x, 0, f"TB6612\n({driver_length}×{driver_width})",
            ha="center", va="center", fontsize=7, color="#311")

    # ESP32 (rotated 90°, right of centre)
    esp_x = 15
    ax.add_patch(patches.Rectangle(
        (esp_x - esp_width / 2, -esp_length / 2),
        esp_width, esp_length,
        linewidth=1, edgecolor="#055", facecolor="#7ec8c8", alpha=0.85,
    ))
    ax.text(esp_x, 0, "ESP32\nLOLIN32 Lite\n(25×52)",
            ha="center", va="center", fontsize=7, color="#022")

    # Battery (rotated 90°, left of centre)
    bat_x = -15
    ax.add_patch(patches.Rectangle(
        (bat_x - battery_width / 2, -battery_length / 2),
        battery_width, battery_length,
        linewidth=1, edgecolor="#640", facecolor="#e8c878", alpha=0.85,
    ))
    ax.text(bat_x, 0, "1S LiPo\n1200mAh\n(25×45)",
            ha="center", va="center", fontsize=7, color="#311")

    # GY-521 IMU behind the rear motors, before the back wall
    imu_x = 53
    ax.add_patch(patches.Rectangle(
        (imu_x - imu_length / 2, -imu_width / 2),
        imu_length, imu_width,
        linewidth=1, edgecolor="#444", facecolor="#bcd", alpha=0.85,
    ))
    ax.text(imu_x, 0, f"GY-521\n({imu_length}×{imu_width})",
            ha="center", va="center", fontsize=6.5, color="#113")

    # USB slot in the back wall (+X), centred
    ax.plot([plate_length / 2 - 0.5, plate_length / 2 - 0.5],
            [-6, 6], color="red", lw=3)
    ax.text(plate_length / 2 + 4, 0, "USB", ha="left", va="center", fontsize=7, color="red")

    # Corner mount holes
    for sx in (-1, 1):
        for sy in (-1, 1):
            ax.add_patch(patches.Circle(
                (sx * (plate_length / 2 - 7), sy * (plate_width / 2 - 7)),
                1.6, color="#333", zorder=10,
            ))

    # Driving direction arrow (front of robot = TB6612 side)
    ax.annotate(
        "", xy=(-plate_length / 2 - 12, 0),
        xytext=(-plate_length / 2 - 2, 0),
        arrowprops=dict(arrowstyle="->", color="#888", lw=1.5),
    )
    ax.text(-plate_length / 2 - 14, 0, "front",
            fontsize=8, color="#888", va="center", ha="right")

    ax.set_xlim(-plate_length / 2 - 18, plate_length / 2 + 18)
    ax.set_ylim(-plate_width / 2 - 18, plate_width / 2 + 18)
    ax.set_aspect("equal")
    ax.set_title(
        f"minibot chassis — top-down\n"
        f"{plate_length}×{plate_width}×18 mm  •  3 mm enclosed walls  •  invertible",
        fontsize=10,
    )
    ax.set_xlabel("mm")
    ax.set_ylabel("mm")
    ax.grid(True, linestyle=":", alpha=0.4)

    fig.tight_layout()
    fig.savefig(OUT / "layout.png", bbox_inches="tight")
    print(f"wrote: {OUT / 'layout.png'}")


if __name__ == "__main__":
    render()
