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
platformio.ini     PlatformIO config (board, framework, monitor settings)
src/main.cpp       entry point — Arduino setup() / loop()
```

## Commit conventions

Commits follow [Conventional Commits](https://www.conventionalcommits.org). Enforced by a lefthook `commit-msg` hook.

```
feat: add wifi connect helper
fix(serial): handle missing baud rate
chore: bump platformio config
```
