
This document walks through everything you’ve done—from GPU auto-detection to repo-level CI/CD and automation scripts—then shows you how to verify each step and automate those tests in GitHub Actions.
1. Prerequisites
- Linux machine with Intel/NVIDIA hybrid GPU  
- Bash, Git, ssh, `udevadm` installed  
- GitHub account with SSH key or Personal Access Token (PAT)  
- `pandoc` and TeX (for PDF builds) on CI runner  

2. GPU Auto-Switch Script & udev Rule
2.1. Script: `scripts/gpu-switch.sh`

```bash
#!/usr/bin/env bash
LOG="/var/log/gpu-switch.log"
PSY="USB-C-0"  # adjust from `ls /sys/class/power_supply`
ONLINE_FILE="/sys/class/power_supply/$PSY/online"
state=$(cat "$ONLINE_FILE")
echo "$(date -Iseconds) Dock online? $state" >> "$LOG"

if [[ $state -eq 1 ]]; then
  # Enable NVIDIA GPU
  prime-select nvidia
else
  # Switch to Intel GPU
  prime-select intel
fi
```

- Ensure executable:  
  ```bash
  sudo chmod +x scripts/gpu-switch.sh
  ```

2.2. udev Rule: `rules/99-gpu-switch.rules`

```udev
# Trigger on dock plug/unplug
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="USB-C-0", ATTR{online}=="1", RUN+="/usr/local/bin/gpu-switch.sh"
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="USB-C-0", ATTR{online}=="0", RUN+="/usr/local/bin/gpu-switch.sh"
```
- Copy to `/etc/udev/rules.d/` and reload:  
  ```bash
  sudo cp rules/99-gpu-switch.rules /etc/udev/rules.d/
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  ```
---
3. Git Repository Setup

```
gpu-dock-auto-switch/
├── LICENSE
├── README.md
├── PROJECT.md         ← This document
├── .gitignore
├── scripts/
│   └── gpu-switch.sh
├── rules/
│   └── 99-gpu-switch.rules
└── .github/
    └── workflows/
        ├── ci-template.yml   ← Shared reusable workflow (in .github repo)
        └── ci.yml            ← Stub to call shared CI
```

1. Initialize and add SSH remote:  
   ```bash
   git init
   git remote add origin git@github.com:JohnYoungSuh/ubuntu_apps-gpu_auto_switch.git
   git add .
   git commit -m "Initial commit: GPU auto-switch + CI/CD setup"
   git push -u origin main
   ```
