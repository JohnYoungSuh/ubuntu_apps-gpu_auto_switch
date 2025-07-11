# gpu-dock-auto-switch

Automatically switch GPU profiles (Intel ↔ NVIDIA) when you plug or unplug your USB-C dock’s power source.

---
## Table of Contents
1. [Features](#features)  
2. [Prerequisites](#prerequisites)  
3. [Installation](#installation)  
4. [Customization](#customization)  
5. [Troubleshooting](#troubleshooting)  
6. [License](#license)

---
## Features
- Detects USB-C power on/off events via udev  
- Calls `prime-select nvidia` or `prime-select intel`  
- Logs switches to `/var/log/gpu-switch.log`  
- Configurable power-supply name for any dock  

---
## Prerequisites
- Ubuntu (Xorg session recommended)  
- NVIDIA drivers + `nvidia-prime` installed  
- `udev` and root privileges  

---
## Installation

1. **Clone the repo**  
   ```bash
   git clone https://github.com/<your-username>/gpu-dock-auto-switch.git
   cd gpu-dock-auto-switch
