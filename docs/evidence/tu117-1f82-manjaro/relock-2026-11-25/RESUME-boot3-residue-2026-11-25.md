# RESUME - Boot 3: residue read (gate-open transaction under `iomem=relaxed`), prepared 2026-11-25 ~07:30 CET

Upstream GO on #246 (2026-11-23 16:48:55Z): "one transaction boot (gate-open default) under
`iomem=relaxed`, read-only residue diff", capture list fixed (see below). This run answers
the maintainer's residue question list on **Linux 580.178.04** with **zero GPU writes beyond
the standard transaction** (gate-open arm = the 11-15 shape; no SS writes, no relock).

## Owner block A - before power-off (paste, then paste output back)

```bash
# backups
sudo cp -a /boot/grub/grub.cfg /boot/grub/grub.cfg.bak-20261125
sudo cp -a /etc/default/grub /etc/default/grub.bak-20261125
# add the boot parameter
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&iomem=relaxed /' /etc/default/grub
grep -n '^GRUB_CMDLINE_LINUX_DEFAULT' /etc/default/grub     # must start with iomem=relaxed
# regenerate + validate
sudo grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | tail -3
sudo grub-script-check /boot/grub/grub.cfg && echo "grub.cfg syntax OK"
grep -c 'iomem=relaxed' /boot/grub/grub.cfg                 # >0
grep -c 'NVUNLOCK-TX'   /boot/grub/grub.cfg                 # >0
# gate-open arm: the ONLY change vs Boot 1 is dropping tx-relock.txt
# (the transaction still writes SS0/SS1 - this is exactly the 11-15 shape)
sudo rm -f /boot/efi/tx-relock.txt
ls -la /boot/efi/*.txt                                      # i_know + tx-select-bdf remain
sudo grub-reboot "NVUNLOCK-TX"
sudo grub-editenv /boot/grub/grubenv list                   # next_entry=NVUNLOCK-TX
```

Then the agent schedules `shutdown -h +1`; owner sends the magic packet; reopens the session;
says "up". **PSU stays on.**

## Agent procedure on resume (read-only except the listed service stop)

1. `uptime`, `journalctl --list-boots | tail -2` - new boot id (previous: `ba3aff1a…`).
2. `sudo dmesg | grep -E 'NVRM|Initialized nvidia-drm|RmInitAdapter'` - expect the refused
   shape: module load, then `RmInitAdapter failed! (0x62:0x40:2674)` loop, no
   `Initialized nvidia-drm`.
3. `bash ~/capture-boot3.sh` (staged, see below) - runs `tools/diag-unlock-20261125.py
   --bdf 0000:01:00.0` (upstream main version; `iomem=relaxed` lifts the mmap block, no
   unbind needed), captures `loader.log`, full journal, dmesg, and stops the CDI refresh
   storm if the driver refused.
4. Compare, per register, cold factory (loader.log SAMPLE/POST-BOOT lines) vs post-handoff
   (diag readback): WPR2 lo/hi, `BSI_SCRATCH15 0x1180fc`, `GFW_SCRATCH 0x118234`, `GFW_PLM
   0x118128`, `GSP_CPUCTL 0x110100` + `GSP_EXCI 0x1100d0`, `SEC2_CPUCTL 0x840100` +
   `SEC2_EXCI 0x8400d0`, PBUS canary `0x1480/0x1484`, MMU PLM `0x1fa7c8`, FEAT
   PLM/SS0/SS1/READOUT `0x409650/64/68/6c`.
5. Refuse-vs-scrub: if the driver refused but the FEAT/SS registers still read the unlocked
   values -> refuses-without-scrub (matches #280/#286). If they read factory -> scrubbed.
6. Evidence: `relock-2026-11-25/residue/`, SUMMARY addendum, timeline, commit, push; post
   the register diff on #246. Then restore: owner block re-adds nothing - revert = remove
   `iomem=relaxed` from `/etc/default/grub` + regen, and `poweroff` + WoL for factory.

## Capture list fixed by upstream (2026-11-23 16:48:55Z)

`BSI_SCRATCH15 0x1180fc`, `GFW scratch 0x118234` + `GFW PLM 0x118128`, SEC2/GSP CPUCTL +
EXCI (IMEM `0xfe00` / EXCI latch `0x900100` observation), PBUS canary `0x1480/0x1484`,
WPR2 lo/hi, MMU PLM, FEAT block. SS/PLM **writes** stay behind a separate per-experiment GO.

## Known deviations / risks

- Carrier stays the verified rc4 stage on the ESP (rc8 changed the marker scheme to
  `tx.ini`; not needed for this run - gate-open default is the 11-15 shape).
- The refused state leaves GPU-dependent services down until the final power cycle.
- `iomem=relaxed` relaxes root's IO-memory mapping restrictions system-wide for that boot;
  removed from the cmdline at cleanup.
- If the card does not come back from POST (it did after the D3cold event on 11-23): power
  off + WoL again; PSU-off needs hands.

## OUTCOME (07:30-07:40 CET) - executed in full

Wake 07:26:37, refused state confirmed (`0x62:0x40:2674`, 565+ attempts). Readback
**worked first try** under `iomem=relaxed` - first in-OS BAR0 access on this box, with the
driver bound. Results in `residue/residue-register-diff.md`:

- FEAT fully live in-OS during the refusal loop (PLM open, SS `0x88888888/0x8`, READOUT 0)
  -> **refuse-without-scrub, register-confirmed** (was inference on 11-23).
- The failing driver built **its own WPR2 window** (`0x00ffee00/0x00fffc00`) after handoff
  (handoff was `HI=0`) - it ran its own FWSEC, then returned RESET_REQUIRED.
- Unchanged-from-factory: `BSI_SCRATCH15 0x201001bf`, `GFW_SCRATCH 0x3ff`, `GFW_PLM`,
  GSP CPUCTL/EXCI, MMU/FBPA PLMs -> not candidates.
- Residue present: SEC2 EXCI latch `0x00900100` (booter halt), loader canary (intact),
  SEC2 CPUCTL stopped.
- `nvidia-cdi-refresh` storm stopped twice (re-triggered once by the `agent-zero` container
  restart -> `nvidia-modprobe`); probe count static after the second stop.

Recovery plan: revert `iomem=relaxed` from the cmdline, power-off + owner WoL -> factory.
