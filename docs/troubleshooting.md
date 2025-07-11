# Troubleshooting

## No events in log

- Run `udevadm monitor --environment --udev` and plug/unplug.
- Verify POWER_SUPPLY_NAME matches `/sys/class/power_supply/`.

## Script not executable

- `sudo chmod +x /usr/local/bin/gpu-switch.sh`
- Shebang must be `#!/bin/bash` on line 1.

## prime-select errors

- Ensure `nvidia-prime` is installed.
- Run `sudo prime-select intel` or `nvidia` manually to test.

## Session crashes on switch

- Use Xorg instead of Wayland.
- Add `sleep 5` before calling `prime-select` in the script.
