# minibot

ESP32 firmware built with [PlatformIO](https://platformio.org) and the Arduino framework.

## Hardware

- **Board**: ESP32-D0WDQ6 (original ESP32, dual-core 240MHz, WiFi + BT)
- **USB-to-serial**: CH340 → `/dev/cu.usbserial-110`

## Prerequisites

- VSCode + [PlatformIO IDE](https://marketplace.visualstudio.com/items?itemName=platformio.platformio-ide) extension
- [`lefthook`](https://github.com/evilmartians/lefthook) (for git hooks) — `brew install lefthook`

## Setup

```sh
brew install lefthook
lefthook install
```

PlatformIO will pull the ESP32 toolchain and Arduino framework on the first build (one-time, a few hundred MB).

## Develop

From the PlatformIO sidebar in VSCode, or via the CLI:

```sh
pio run                       # build
pio run -t upload             # build + flash
pio device monitor            # serial monitor (Ctrl+C to exit)
pio run -t upload -t monitor  # flash + open monitor
pio run -t clean              # clean build artifacts
```

## Source layout

```
platformio.ini       PlatformIO config (board, framework, monitor settings)
src/main.cpp         entry point — Arduino setup() / loop()
scripts/pair-ps3.py  pair a DualShock 3 / SIXAXIS controller to the ESP via USB
```

## Pairing a PS3 controller

The ESP32's Bluetooth MAC is **`24:6f:28:b1:f8:b6`** (eFuse base MAC + 2).

PS3 controllers don't pair the normal way — you write the host MAC into the controller's memory via USB, then the controller auto-connects to that host over Bluetooth when powered on.

1. Plug the PS3 controller into your Mac via USB.
2. Write the ESP's BT MAC into the controller:
   ```sh
   ./scripts/pair-ps3.py 24:6f:28:b1:f8:b6
   ```
3. Unplug the controller, flash the ESP, then press the PS button.
4. Watch the serial monitor — button events stream in, LED on GPIO19 goes solid when connected.

To read the currently paired host MAC (no write):

```sh
./scripts/pair-ps3.py
```

## Commit conventions

Commits follow [Conventional Commits](https://www.conventionalcommits.org). Enforced by a lefthook `commit-msg` hook.

```
feat: add wifi connect helper
fix(serial): handle missing baud rate
chore: bump platformio config
```
