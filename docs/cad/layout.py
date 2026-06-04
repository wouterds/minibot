#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["matplotlib>=3.9"]
# ///
"""Top-down + side view chassis layout — mirrors chassis.scad geometry."""

from pathlib import Path

import matplotlib.patches as patches
import matplotlib.pyplot as plt

OUT = Path(__file__).resolve().parent

# ─── parameters (kept in sync with chassis.scad) ────────────────────
plate_length = 145
plate_width = 113
plate_thick = 3       # floor thickness (Z)
wall_thick = 2.5      # perimeter wall thickness (X/Y)
wall_half_height = 6  # half of the cavity height (so cavity = 12 mm)

motor_width = 12       # X dimension when laid flat
motor_height = 10      # Z dimension (perpendicular to plate)
motor_diameter = motor_width
motor_length = 26      # body only, excluding shaft
motor_axle_pitch = 70
motor_track = 32

wheel_diameter = 25      # measured outer diameter incl. rubber tire
wheel_width = 23
wheel_clearance = 2.0

motor_center_y = motor_track / 2
wheel_center_y = motor_center_y + motor_length / 2 + wheel_width / 2

esp_length, esp_width = 49, 26
driver_length, driver_width = 18.5, 16
battery_length, battery_width = 50, 30
imu_length, imu_width = 20, 15.5
tp4056_length, tp4056_width = 29, 16

esp_thick = 4         # PCB + components (Z direction)
driver_thick = 4
battery_thick = 6
imu_thick = 3
tp4056_thick = 3

chassis_height = 2 * plate_thick + 2 * wall_half_height  # = 18 mm
cavity_z_center = chassis_height / 2

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

# Component centre positions. Battery + ESP32 stack flat in the centre
# (each ~50 mm long in X, only ±25 mm wide so they clear the corner
# motors). DRV8833 + MPU-6050 on the two sides; TP4056 fills the back
# centre with its USB-C reaching the back-wall slot.
bat_x, bat_y = 0, +13
esp_x, esp_y = 0, -17
drv_x, drv_y = 0, +46
imu_pos_x, imu_pos_y = 0, -46
tp_x, tp_y = 56, 0


def draw_top(ax) -> None:
    # Outer chassis outline
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2, -plate_width / 2),
        plate_length, plate_width,
        linewidth=2.5, edgecolor="black", facecolor="#f4ecdc",
    ))
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2 + wall_thick, -plate_width / 2 + wall_thick),
        plate_length - 2 * wall_thick, plate_width - 2 * wall_thick,
        linewidth=1, edgecolor="#aaa", facecolor="#fffaf0", linestyle="--",
    ))

    cutout_x = 24
    cutout_y = wheel_width + 2
    for x, y in wheel_positions:
        ax.add_patch(patches.FancyBboxPatch(
            (x - cutout_x / 2, y - cutout_y / 2),
            cutout_x, cutout_y,
            boxstyle="round,pad=0.5,rounding_size=2",
            linewidth=1.2, edgecolor="#222", facecolor="#3a3a3a", alpha=0.85,
        ))
        ax.text(x, y, "wheel\ncutout", ha="center", va="center",
                fontsize=6.5, color="white")

    for x, y in motor_positions:
        ax.add_patch(patches.Rectangle(
            (x - motor_diameter / 2, y - motor_length / 2),
            motor_diameter, motor_length,
            linewidth=1, edgecolor="#666", facecolor="#cfcfcf", alpha=0.9,
        ))
        ax.text(x, y, "N20", ha="center", va="center", fontsize=6.5, color="#222")
        sign = 1 if y > 0 else -1
        ax.annotate(
            "", xy=(x, y + sign * (motor_length / 2 + 10)),
            xytext=(x, y + sign * motor_length / 2),
            arrowprops=dict(arrowstyle="->", color="#777", lw=1.2),
        )

    # Battery — flat (long axis X), centre
    ax.add_patch(patches.Rectangle(
        (bat_x - battery_length / 2, bat_y - battery_width / 2),
        battery_length, battery_width,
        linewidth=1, edgecolor="#640", facecolor="#e8c878", alpha=0.85,
    ))
    ax.text(bat_x, bat_y, f"1S LiPo 1000mAh ({battery_length}×{battery_width})",
            ha="center", va="center", fontsize=7, color="#311")

    # DRV8833 — on the +Y side, centred in X
    ax.add_patch(patches.Rectangle(
        (drv_x - driver_length / 2, drv_y - driver_width / 2),
        driver_length, driver_width,
        linewidth=1, edgecolor="#722", facecolor="#e08e8e", alpha=0.85,
    ))
    ax.text(drv_x, drv_y, f"DRV8833\n({driver_length}×{driver_width})",
            ha="center", va="center", fontsize=7, color="#311")

    # MPU-6050 — on the -Y side, centred in X
    ax.add_patch(patches.Rectangle(
        (imu_pos_x - imu_length / 2, imu_pos_y - imu_width / 2),
        imu_length, imu_width,
        linewidth=1, edgecolor="#444", facecolor="#bcd", alpha=0.85,
    ))
    ax.text(imu_pos_x, imu_pos_y, f"MPU-6050\n({imu_length}×{imu_width})",
            ha="center", va="center", fontsize=6.5, color="#113")

    # ESP32 — flat (long axis X), below the battery
    ax.add_patch(patches.Rectangle(
        (esp_x - esp_length / 2, esp_y - esp_width / 2),
        esp_length, esp_width,
        linewidth=1, edgecolor="#055", facecolor="#7ec8c8", alpha=0.85,
    ))
    ax.text(esp_x, esp_y, f"ESP32 LOLIN32 Lite ({esp_length}×{esp_width})",
            ha="center", va="center", fontsize=7, color="#022")

    # TP4056
    ax.add_patch(patches.Rectangle(
        (tp_x - tp4056_length / 2, tp_y - tp4056_width / 2),
        tp4056_length, tp4056_width,
        linewidth=1, edgecolor="#136", facecolor="#9bd", alpha=0.85,
    ))
    ax.text(tp_x, tp_y, f"TP4056\nUSB-C\n({tp4056_width}×{tp4056_length})",
            ha="center", va="center", fontsize=6.5, color="#013")

    # USB-C slot
    ax.plot([plate_length / 2 - 0.5, plate_length / 2 - 0.5],
            [-6, 6], color="red", lw=3)
    ax.text(plate_length / 2 + 4, 0, "USB-C\n(charge)",
            ha="left", va="center", fontsize=7, color="red")

    # Corner mount holes
    for sx in (-1, 1):
        for sy in (-1, 1):
            ax.add_patch(patches.Circle(
                (sx * (plate_length / 2 - 7), sy * (plate_width / 2 - 7)),
                1.6, color="#333", zorder=10,
            ))

    # Driving direction arrow
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
        f"top-down view  •  {plate_length}×{plate_width} mm",
        fontsize=10,
    )
    ax.set_xlabel("mm")
    ax.set_ylabel("mm")
    ax.grid(True, linestyle=":", alpha=0.4)


def draw_side(ax) -> None:
    """X–Z view, looking at the bot from the +Y side."""

    # Chassis envelope (overall outline)
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2, 0),
        plate_length, chassis_height,
        linewidth=2, edgecolor="black", facecolor="#f4ecdc",
    ))
    # Bottom plate floor band
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2, 0),
        plate_length, plate_thick,
        linewidth=0, facecolor="#e3d4b0",
    ))
    # Top plate floor band
    ax.add_patch(patches.Rectangle(
        (-plate_length / 2, chassis_height - plate_thick),
        plate_length, plate_thick,
        linewidth=0, facecolor="#e3d4b0",
    ))

    # Wheel cutout slots in the plates at each wheel X
    cutout_x_side = 28
    for x, _ in wheel_positions[:2]:  # only x positions matter (each appears twice)
        for z_band in (0, chassis_height - plate_thick):
            ax.add_patch(patches.Rectangle(
                (x - cutout_x_side / 2, z_band),
                cutout_x_side, plate_thick,
                linewidth=0, facecolor="white",
            ))

    # Wheels: full circles centred at cavity centre, protruding above/below
    for x in (-motor_axle_pitch / 2, motor_axle_pitch / 2):
        ax.add_patch(patches.Circle(
            (x, cavity_z_center),
            wheel_diameter / 2,
            linewidth=1.5, edgecolor="#222", facecolor="#3a3a3a", alpha=0.9,
        ))
        ax.text(x, cavity_z_center + wheel_diameter / 2 + 1.5,
                f"⌀{wheel_diameter}",
                ha="center", va="bottom", fontsize=6.5, color="#444")

    # Motors at each X (front + rear), shown as 12×10 rectangles in X–Z
    for x in (-motor_axle_pitch / 2, motor_axle_pitch / 2):
        ax.add_patch(patches.Rectangle(
            (x - motor_width / 2, cavity_z_center - motor_height / 2),
            motor_width, motor_height,
            linewidth=1, edgecolor="#666", facecolor="#cfcfcf", alpha=0.75,
        ))

    # Electronics sitting on the bottom plate floor (z = plate_thick → up)
    components = [
        (drv_x, driver_length, driver_thick, "#e08e8e", "#722", "DRV"),
        (imu_pos_x - driver_length / 2 - 5, imu_length, imu_thick, "#bcd", "#444", "IMU"),
        (bat_x, battery_length, battery_thick, "#e8c878", "#640", "battery"),
        (esp_x, esp_length, esp_thick, "#7ec8c8", "#055", "ESP32"),
        (tp_x, tp4056_length, tp4056_thick, "#9bd", "#136", "TP4056"),
    ]
    for cx, cwidth_x, cthick, fcol, ecol, label in components:
        ax.add_patch(patches.Rectangle(
            (cx - cwidth_x / 2, plate_thick + 0.1),
            cwidth_x, cthick,
            linewidth=0.8, edgecolor=ecol, facecolor=fcol, alpha=0.85,
        ))
        ax.text(cx, plate_thick + cthick / 2 + 0.1, label,
                ha="center", va="center", fontsize=6.5, color=ecol)

    # USB-C slot in the back wall
    ax.add_patch(patches.Rectangle(
        (plate_length / 2 - wall_thick, plate_thick + 1),
        wall_thick, 6,
        linewidth=0, facecolor="red", alpha=0.7,
    ))
    ax.text(plate_length / 2 + 1, plate_thick + 4, "USB-C", ha="left",
            va="center", fontsize=7, color="red")

    # Annotate chassis height and wheel protrusion
    wheel_top = cavity_z_center + wheel_diameter / 2
    wheel_bot = cavity_z_center - wheel_diameter / 2
    ax.text(-plate_length / 2 - 4, chassis_height / 2,
            f"{chassis_height:g} mm\nchassis",
            ha="right", va="center", fontsize=7, color="#555")
    ax.text(plate_length / 2 + 18, wheel_top - 0.5,
            f"+{wheel_top - chassis_height:g} mm",
            ha="left", va="center", fontsize=6.5, color="#555")
    ax.text(plate_length / 2 + 18, wheel_bot + 0.5,
            f"−{-wheel_bot:g} mm",
            ha="left", va="center", fontsize=6.5, color="#555")

    ax.set_xlim(-plate_length / 2 - 18, plate_length / 2 + 30)
    ax.set_ylim(wheel_bot - 6, wheel_top + 6)
    ax.set_aspect("equal")
    ax.set_title(
        f"side view  •  chassis {chassis_height:g} mm tall  •  wheel ⌀ {wheel_diameter} mm",
        fontsize=10,
    )
    ax.set_xlabel("mm  (length)")
    ax.set_ylabel("mm  (height)")
    ax.grid(True, linestyle=":", alpha=0.4)


def render() -> None:
    fig, ax_top = plt.subplots(figsize=(11, 9), dpi=140)
    fig.suptitle(
        f"minibot chassis  •  {plate_length}×{plate_width}×{chassis_height:g} mm  •  "
        f"{wall_thick:g} mm walls  •  invertible",
        fontsize=11, y=0.995,
    )
    draw_top(ax_top)
    fig.tight_layout()
    fig.savefig(OUT / "layout.png", bbox_inches="tight")
    print(f"wrote: {OUT / 'layout.png'}")


if __name__ == "__main__":
    render()
