# RESUME - after the recovery reboot that follows the Boot 2 attempt (2026-11-23 ~17:10 CET)

## What happened (facts)

- Boot 1 (relock arm) done 16:26-16:42: loader green, OS refused - see `relock-2026-11-23/`.
- Boot 2 (runtime driver swap to 580.142) **did not run**. At 17:01:58 the loaded 580.178.04
  modules were unloaded for the swap. One second later the first probe of the new module
  reported `Unable to change power state from D3cold to D0, device inaccessible`; five more
  probes by 17:02:13 gave the same. The card's config space read all-ones from then on
  (`lspci -vv`: `Unknown header type 7f`), root-port link not active, display black, SSH fine.
- Both unloads of the 580.178.04 module this boot (16:32:40 capture script, 17:01:58 swap)
  logged `BUG nvidia_stack_cache ... Objects remaining on __kmem_cache_shutdown()` - the
  kernel was tainted `W`/`B` twice.
- NOT established: what put the card into D3cold. The first unload today (16:32:40) was
  followed by a successful reload within a second, so "unload -> card drops" is not a
  rule; the second unload differed in prior idle time (30 min) and in what probed next.
  Do not describe the 580.142 module as the cause - it never got past the PCI probe.
- Evidence: `relock-2026-11-23/boot2-attempt/dmesg-17-05-redacted.log`.

## Why a reboot

Card unresponsive on the bus + tainted kernel + no GPU driver. A warm reboot asserts
reset to the slot and reloads the stock 580.178.04 modules from the initramfs.

## Procedure on resume (in this order, read-only first)

1. `uptime` - must be the new boot. `sudo dmesg | grep -cE 'BUG |WARNING'` - expect 0 nvidia slab BUGs.
2. `sudo lspci -vv -s 01:00.0 | head -5` - header type must be `00`, not `7f`. If still `7f`:
   the card did not come back from a warm reset -> STOP, tell the owner, power cycle via
   WoL is the next step (PSU-off needs hands).
3. `sudo dmesg | grep -E 'NVRM|nvidia-drm' | head`:
   - `[drm] Initialized nvidia-drm 0.0.0 for 0000:01:00.0 on minor 0` and no `RmInitAdapter failed`
     -> **factory state**: the D3cold event erased the unlock (expected if the card really lost
     power). Box is healthy. Verify `nvidia-smi`, stop here, restore the owner's services
     (nothing to do), then record.
   - `RmInitAdapter failed! (0x62:0x40:2674)` -> unlock survived the event. Stop the init storm
     (`sudo systemctl stop nvidia-cdi-refresh.path nvidia-cdi-refresh.service`), record, and
     propose a power cycle (`poweroff` + owner's magic packet) for factory.
4. Record the outcome in `relock-2026-11-23/SUMMARY-relock-2026-11-23.md` (Boot 2 section),
   timeline, commit, push; post on #246 (data: D3cold-after-unload, rmmod slab BUG, Boot 2
   not run) and #264.

## Rules added by this attempt

- No runtime `rmmod` of the nvidia stack on this box for experiments: the unload is unclean
  (slab BUG) and this time the card dropped to D3cold.
- A Boot 2 on this box needs a design that never loads the stock modules: the initramfs
  embeds them (`MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`, image carries
  `extramodules/nvidia*.ko.zst`, no fallback image). Candidate for later, with the owner:
  a one-shot GRUB entry with `modprobe.blacklist=` so the stock modules stay out, then
  `insmod` 580.142 - on-site, or after a warm reboot proven to keep the card on the bus.
- Built and verified, unused: `~/nvunlock/nv-580.142-src/kernel/*.ko` (version 580.142,
  vermagic 6.12.112-1-MANJARO), firmware installed by the owner at
  `/usr/lib/firmware/nvidia/580.142/` (sha256 `9f5494c1…` gsp_tu10x, `a6b8d5d2…` gsp_ga10x).
  No package was removed; the pacman module package is untouched.
