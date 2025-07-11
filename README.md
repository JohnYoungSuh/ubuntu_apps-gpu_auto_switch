# gpu-dock-auto-switch

Automatically switch GPU profiles (Intel ↔ NVIDIA) when you plug or unplug your USB-C dock’s power source.

## Features

- Detects USB-C power on/off events via udev
- Runs a script to call `prime-select nvidia` or `prime-select intel`
- Logs all switches to `/var/log/gpu-switch.log`
- Easily customizable to your dock’s power-supply name

## Prerequisites

- Ubuntu (Xorg session recommended)
- NVIDIA drivers + `nvidia-prime` installed
- `udev` and root privileges

## Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/<your-username>/gpu-dock-auto-switch.git
   cd gpu-dock-auto-switch
