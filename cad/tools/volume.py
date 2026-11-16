#!/usr/bin/env python3
"""Print the volume in mm3 of a binary STL (0 for an empty or missing file)."""
import struct
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = path.read_bytes() if path.exists() else b""
count = struct.unpack_from("<I", data, 80)[0] if len(data) >= 84 else 0

volume = 0.0
for i in range(count):
    ax, ay, az, bx, by, bz, cx, cy, cz = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
    volume += ax * (by * cz - bz * cy) - ay * (bx * cz - bz * cx) + az * (bx * cy - by * cx)

print(f"{abs(volume) / 6:.2f}")
