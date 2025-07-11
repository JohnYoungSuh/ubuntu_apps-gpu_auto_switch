#!/bin/bash

LOG="/var/log/gpu-switch.log"
PSY="ucsi-source-psy-USBC000:001"  # Update if yours differs
ONLINE_FILE="/sys/class/power_supply/$PSY/online"

# Ensure log exists
if [ ! -f "$LOG" ]; then
  sudo touch "$LOG"
  sudo chmod 664 "$LOG"
  echo "$(date '+%F %T') Log created" >> "$LOG"
fi

echo "$(date '+%F %T') Power event triggered" >> "$LOG"

if [ "$(cat $ONLINE_FILE 2>/dev/null)" = "1" ]; then
  echo "$(date '+%F %T') Dock powered: switching to NVIDIA" >> "$LOG"
  sudo prime-select nvidia
else
  echo "$(date '+%F %T') Dock unpowered: switching to Intel" >> "$LOG"
  sudo prime-select intel
fi
