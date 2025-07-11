# gpu-auto-switch

Effortless Performance and Efficiency with Automatic GPU Switching

Imagine your Ubuntu laptop intuitively toggling between Intel’s energy-savvy graphics when you’re unplugged and NVIDIA’s high-power GPU the moment you dock—no manual toggles, no interruptions.  Other video force to install addtion lib or code.

---

## Key Benefits

- Intelligent power management  
  Automatically shifts to Intel graphics to extend battery life when the dock’s power is unplugged, then switches back to NVIDIA for peak performance once you reconnect.  

- Seamless Ubuntu integration  
  Built directly into your existing Ubuntu setup—no extra tools or complex scripts needed.  

- Optimized workflow  
  Focus on your work without worrying about configuration changes; your system adapts in real time.  

- Balanced performance and efficiency  
  Enjoy long unplugged use on Intel’s lean GPU, then harness NVIDIA’s full capabilities the instant you plug in.

---

Experience the ideal blend of battery longevity and graphics power—all triggered by your USB-C dock’s power state.

## Features

- Detects USB-C power on/off events via udev
- Runs a script to call `prime-select nvidia` or `prime-select intel`
- Logs all switches to `/var/log/gpu-switch.log`
- Easily customizable to your power-supply name

## Prerequisites

- Ubuntu (Xorg session recommended)
- NVIDIA drivers + `nvidia-prime` installed
- `udev` and root privileges

## Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/<your-username>/gpu-dock-auto-switch.git
   cd gpu-dock-auto-switch
# ubuntu_apps/gpu_auto_switch
