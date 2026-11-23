#!/usr/bin/env bash
# TU117 capture - OWNER/AGENT-RUN after a transaction boot lands in Manjaro.
# Read-only. Zero GPU writes, and since 2026-11-23 NO `rmmod`: unloading the nvidia
# stack on this box was unclean both times (BUG nvidia_stack_cache: Objects remaining)
# and the second unload dropped the card to D3cold ("device inaccessible") until a
# power-off. The in-OS BAR0 readback is refused (mmap EINVAL) with the driver loaded
# or unloaded, so the unload bought nothing anyway.
# Idempotent: safe to re-run; every re-run makes a fresh directory.
set -u
D=~/capture-relock-$(date +%F-%H%M)
mkdir -p "$D"; cd "$D"
R=~/external/physicsdolphin/nv-uefi-unlocker

# 1) the loader's own readback record (copy off FIRST - later runs overwrite it)
sudo cp /boot/efi/loader.log loader.log

# 2) full boot journal. Do NOT trust journal timestamps for kernel lines: journald
#    may start late and stamp the whole kernel backlog with its receive time. Use
#    the printk timestamps in brackets, or `sudo dmesg -T`.
journalctl -b -o short > boot-journal.log
sudo dmesg -T > dmesg-live.log            # -T: by time, never slice by line number (ring wraps)

# 3) driver state as found
nvidia-smi -q > nvidia-smi-q.txt 2> nvidia-smi-err.txt
nvidia-smi --query-gpu=driver_version,name,pstate,clocks.sm --format=csv,noheader > nvidia-smi-line.txt 2>> nvidia-smi-err.txt || true

# 4) register readback attempt with the driver loaded (known EINVAL; kept for the record)
sudo python3 "$R/tools/diag-unlock.py" --bdf 0000:01:00.0 > diag-readback.txt 2>&1 || true

# 5) stop the init-attempt storm if the driver refused (path unit re-fires on every
#    failure; each start = one RM init attempt + a red FAILED line on the console)
if ! nvidia-smi -L > "nvidia-smi-L.txt" 2>&1; then
  sudo systemctl stop nvidia-cdi-refresh.path nvidia-cdi-refresh.service || true
  echo "CDI refresh path stopped (driver refused)" | tee -a diag-readback.txt
fi

echo "CAPTURE DONE -> $D"
ls -la "$D"
echo "Next: report back. No reboot/power-off before the capture is committed and pushed."
