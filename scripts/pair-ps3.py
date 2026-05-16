#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["hidapi>=0.14"]
# ///
"""Pair a PS3 (DualShock 3 / SIXAXIS) controller to a host MAC over USB.

Plug the controller into USB first, then run:

    scripts/pair-ps3.py                       # Show current paired host MAC
    scripts/pair-ps3.py 24:6f:28:b1:f8:b6     # Write new host MAC

After pairing, unplug USB and press the PS button — the controller will
auto-connect to the host with that MAC.
"""

import re
import sys

import hid

VENDOR_ID = 0x054C
PRODUCT_ID = 0x0268


def parse_mac(s: str) -> bytes:
    cleaned = re.sub(r"[^0-9a-fA-F]", "", s)
    if len(cleaned) != 12:
        sys.exit(f"Invalid MAC: {s!r}")
    return bytes.fromhex(cleaned)


def fmt_mac(b: bytes) -> str:
    return ":".join(f"{x:02x}" for x in b)


def main() -> int:
    device = hid.device()
    try:
        device.open(VENDOR_ID, PRODUCT_ID)
    except (OSError, IOError) as e:
        sys.exit(f"Could not open PS3 controller — is it plugged in via USB? ({e})")

    if len(sys.argv) > 1:
        mac = parse_mac(sys.argv[1])
        device.send_feature_report([0xF5, 0x01, *mac])
        print(f"Wrote pairing MAC: {fmt_mac(mac)}")

    response = bytes(device.get_feature_report(0xF5, 8))
    current = response[2:8]
    print(f"Current pairing MAC: {fmt_mac(current)}")
    device.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
