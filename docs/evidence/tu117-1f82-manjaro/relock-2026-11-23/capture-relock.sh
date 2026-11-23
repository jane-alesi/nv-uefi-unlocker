#!/usr/bin/env bash
# TU117 relock-boot capture - OWNER-RUN after the chainback lands in Manjaro.
# Zero GPU writes: read-only capture + one rmmod of the nvidia stack so the
# BAR0 register readback (diag-unlock.py) can run (driver module holds the
# device exclusively; the 11-15 blocker was exactly this).
# Idempotent: safe to re-run; every re-run makes a fresh directory.
set -u
D=~/capture-relock-$(date +%F-%H%M)
mkdir -p "$D"; cd "$D"
R=~/external/physicsdolphin/nv-uefi-unlocker

# 1) the loader's own readback record (copy off FIRST - later runs overwrite it)
sudo cp /boot/efi/loader.log loader.log

# 2) full boot journal (persistent journal was enabled pre-boot; this is the
#    artifact that answers upstream's "lines before the first RmInitAdapter")
journalctl -b -o short-monotonic > boot-journal.log
sudo dmesg > dmesg-live.log

# 3) driver state as found
nvidia-smi -q > nvidia-smi-q.txt 2> nvidia-smi-err.txt
nvidia-smi --query-gpu=driver_version,name,pstate,clocks.sm --format=csv,noheader > nvidia-smi-line.txt 2>> nvidia-smi-err.txt || true

# 4) register readback - with driver loaded (expect the known EINVAL/busy;
#    documented blocker), then with the stack unloaded (the discriminator:
#    "init refuses" vs "init scrubs" - upstream ask, #246 2026-11-23)
{
  echo "== diag with driver loaded (expected: blocked; kept for the record)"
  sudo python3 "$R/tools/diag-unlock.py" --bdf 0000:01:00.0 2>&1
  echo "== unloading nvidia stack"
  for m in nvidia_uvm nvidia_drm nvidia_modeset nvidia; do
    sudo rmmod "$m" 2>&1 || true
  done
  echo "== diag with driver UNLOADED (the real readback channel)"
  sudo python3 "$R/tools/diag-unlock.py" --bdf 0000:01:00.0 2>&1
} > diag-readback.txt
sudo dmesg > dmesg-after-rmmod.log

echo "CAPTURE DONE -> $D"
ls -la "$D"
echo "Next: leave the box as it is (driver unloaded is fine) and report back."
