# Boot 1 - `\tx-relock.txt` on TU117 (1f82) / Linux 580.178.04 - 2026-11-23

**Verdict: loader side GREEN (the #103 handoff shape, transplanted), OS side REFUSED.**
TU117 rejects the relock handoff on Linux 580.178.04 with the same RM tuple as the
gate-open run - so on this die + driver the rejection is independent of the PLM handoff
shape, matching what #280 found on Windows 621.14 (TU116). Upstream decision tree
(#246, 2026-11-23 13:13Z): "fail -> TU117/Linux rejects both GSP shapes, completing the
Linux-side picture and pointing the remaining variance at driver-minor/OS". Boot 2
(580.142) is the next cell; not run.

One cold boot (S5 -> WoL wake), zero retries. Carrier rc4, stage byte-identical to the
11-15 green run, single functional delta = `tx-relock.txt`.

## Loader log (`loader-relock-2026-11-23.log`, 57727 B)

| ms | line |
|---|---|
| 470 | `nv-uefi-unlocker v2.1.12-rc4 (built Thu 2026-11-19 11:49:03 +01:00)` / `** TX BUILD: CONTAINS GPU-WRITE PATHS **` |
| 12637 / 13428 | `TX-ROOT-DIR: tx-relock.txt size=0` / `TX: \tx-relock.txt present - the FEAT gate gets RELOCKED at handoff (legacy shape)` |
| 7605 / 11633 | `ENUMERATE: tx-select-bdf matched 0000:01:00.0 - only this card runs` |
| 14343 | `TX-tu11x: entry WPR2 lo=0x1ffffe00 hi=0x0 (cold) - FWSEC will be fired by the loader` |
| 14761 / 14816 | `BOOTER-PLACE: ns 0x0+0x100 ... sec 0x100+0x8300 -> dest 0x100` / `BOOTER-DIRECT: halted, mailbox0=0x0 mailbox1=0x1 exci=0x00900100` |
| 14843 | `POST-BOOT: FEAT_PLM=0xffffffff SS0=0x25264026 SS1=0x7` (factory SS words - a third cold-boot value after 11-15's `0x7254066/0x3`) |
| 14856 | `SELECTOR RESULT: SS0=0x88888888 SS1=0x8` |
| 14865 / 14867 | `TX: stock signature restored` / `FEAT PLM relock [tu10x]: plm=0xffffffef known-good (bits 5:6 sticky-open) SS0=0x88888888 SS1=0x00000008 unlock_persist=true` |
| 17200 | `POST-GOP: FEAT_PLM=0xffffffef SS0=0x88888888 SS1=0x8 READOUT_1=0x00000000 WPR2_LO=0x00f78000 WPR2_HI=0x0 CANARY=intact(0x0164c0de/0x0165cafe)` -> `unlock intact after the console rebuild` |
| 17215 | `HANDOFF-OUT: ... canary=intact pmcsr=0x0008 dstate=D0 \| tu10x: plm=0xffffffef ss0=0x88888888 ss1=0x00000008 readout=0x00000000 \| tu10x:unlock=true` |
| 17650 | `CHAIN: loader found ... \EFI\Manjaro\grubx64.efi` |

The relock line is byte-for-byte the shape of #103 log line 417 (`plm=0xffffffef ...
SS0=0x88888888 SS1=0x00000008 unlock_persist=true`). Leading `0xbadf5040` fields on
HANDOFF-OUT are the relock closing the block (expected, per the FAQ note).

## OS side

- `NVRM: loading NVIDIA UNIX x86_64 Kernel Module 580.178.04` at kernel clock 2.146 s.
- First `RmInitAdapter failed! (0x62:0x40:2674)` at **62.39 s** - the first init attempt
  takes ~60 s to return `NV_ERR_RESET_REQUIRED : NV_ERR_INVALID_STATE`; every later
  attempt fails within 0.1-3 s with the same tuple. 684 by 16:32, 786 final.
- `nvidia-smi`: `No devices were found`. `nvidia-drm`: `Failed to allocate NvKmsKapiDevice` (1x).
- No RM subsystem is named on the kernel console before the first failure
  (upstream's 11-15 ask #4): the only NVRM lines are the load banner and the tuple.
- The 11-15 second shape `(0x22:0x56:897)` did not recur.
- Collapsed record: `nvrm-summary.txt`. Raw: `dmesg-live.redacted.log.xz`,
  `boot-journal.nvidia-filtered.log.xz` (journal lines matching nvidia/NVRM/drm/cdi only).

## In-OS register readback: still blocked (the refuses-vs-scrubs discriminator)

`tools/diag-unlock.py` fails at `mmap(resource0, 16 MiB)` with `OSError: [Errno 22]`
**twice**: with the driver loaded, and again after `rmmod nvidia_uvm nvidia_drm
nvidia_modeset nvidia` (all four unloaded without error, see `diag-readback.txt`). So the
blocker is not the module holding the BAR - the sysfs resource mmap itself is refused on
this kernel/config, with or without a driver bound. Not root-caused here.

What can be said without the readback (inference, not a measurement): 786 consecutive
init attempts returned the identical `RESET_REQUIRED` tuple. If an attempt had scrubbed
the state back to factory, later attempts would be expected to behave differently (the
factory state is accepted by this driver - 11-03 control, and today's healthy pre-boot).
A stable rejection across ~800 attempts is consistent with "init refuses and leaves the
state alone" - the same reading #280/#286 made on Windows - but on this host that stays
an inference until a register channel exists.

## Timeline of the boot (wallclock; journald only starts writing at 16:28:00)

16:23:42 clean shutdown (scheduled) -> ~16:26:50 WoL wake (magic packet, owner; PSU on)
-> 16:26:56 kernel start -> 16:26:58 module load -> 16:27:58 first RM failure
-> 16:28:02 first `nvidia-ctk` run -> 16:28:05 link up (5 s on a healthy boot: the first
init attempt delays early userspace by ~60 s) -> 16:32 capture.

## Host mutations this session (all reversible, recorded)

| When | What | Why / revert |
|---|---|---|
| 16:32 | `rmmod` of the 4 nvidia modules (capture script), then re-loaded by `nvidia-ctk --load-kernel-modules` before the loop was stopped | readback attempt |
| ~16:34 | `systemctl stop nvidia-cdi-refresh.path nvidia-cdi-refresh.service` | the path unit re-fired on every failure = the init-attempt storm + the red `FAILED` lines on the console; not enabled at boot, returns on next boot or `systemctl start nvidia-cdi-refresh.path` |
| 16:35 | `nvidia-bug-report.sh` run (+4 init attempts) | promised on #246; kept local, not published (contains `dmidecode`, X session and PCI config dumps) - only `bugreport-extract-power-vermagic.txt` is published |
| ~15:4x | `mkdir -p /var/log/journal` + journald restart | no-op in hindsight - see correction below |

Unrelated to the GPU, pre-existing on the healthy boot too: `luca-docker-startup.service`
and `luca-agent-zero-startup.service` fail (LLM server at a LAN host never healthy in
300 s, then a docker build cache-key error); ACPI `\_SB.WMID` BIOS errors; `upsd` "6
config errors". No package change today except chromium. Daily `luca-maintenance-reboot.timer` at 05:55.

## Corrections to earlier records

1. **WOL works on this box now.** Three S5 wakes today (14:10->14:12, 14:13->14:14,
   16:23->16:27). The "box unreachable when off" constraint is lifted as of 2026-11-23
   (the owner was on site; BIOS change presumed, not verified by me).
2. **Journald was never volatile here.** Boot records from 14:09 today - before my
   `mkdir /var/log/journal` - exist in the persistent journal, so it was persistent all
   along. The 11-15 failing session was lost to rotation/vacuuming (a daily 05:55 reboot
   plus log volume), not volatility. My statement to upstream on #246 (2026-11-19) saying
   "journald on this host is volatile" was an unverified inference and is wrong.
3. Journal "monotonic" times for kernel lines can be receive times, not event times:
   in this boot journald's first write is 64 s after kernel start.

## Near-miss before the boot

The first marker block led with `cd /boot/efi && ...`; the owner's zoxide-wrapped `cd`
failed and the `&&` chain skipped the marker writes while the GRUB one-shot was already
armed. A boot then would have re-run the gate-open arm. Caught from the pasted output.
Rules: `RUNBOOK-relock-2026-11-19.md` field amendment.

## Boot 2 attempt (runtime swap to 580.142, 17:01) - DID NOT RUN

Owner GO given; design revised from "package swap + reboot" to a runtime `rmmod`/`insmod`
after finding that the initramfs embeds the stock modules (a reboot would have loaded the
old 580.178.04 first). Pre-checks were green: 580.142 modules built against 6.12.112 with
gcc 16.2 (`exit=0`, vermagic exact), all needed module parameters present, GSP firmware
installed by the owner and hash-verified.

| Time | Event |
|---|---|
| 17:01:58 | `rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia` (580.178.04) - returns 0, logs `BUG nvidia_stack_cache: Objects remaining on __kmem_cache_shutdown()` |
| 17:01:59 | `insmod nvidia.ko` (580.142) -> `No such device`; kernel: `nvidia 0000:01:00.0: Unable to change power state from D3cold to D0, device inaccessible`, probe failed |
| 17:02:10-13 | five further probes (distro `modprobe`, trigger not identified) - identical |
| 17:04-17:05 | `lspci -vv -s 01:00.0`: `Unknown header type 7f` (config space all-ones, 5 reads); root port `LnkSta: Speed 2.5GT/s, Width x16` without link-active; display black, SSH fine |

**The 580.142 module was never evaluated** - the card was already unreachable at its PCI
probe, one second after the unload. **Cause of the D3cold not established.** The first
unload this boot (16:32:40, capture script) was followed by a successful reload within a
second, so "unload drops the card" is not a rule; this unload differed in prior idle time
(30 min) and in what probed next.

Other findings from the attempt:
- Unloading the 580.178.04 module on the failed-init state is **unclean both times**
  (16:32:40 and 17:01:58): `BUG nvidia_stack_cache: Objects remaining on
  __kmem_cache_shutdown()` - six BUG reports on the second unload, twelve matching lines in
  the journal for the first - kernel WARN, taint `W`/`B`. `rmmod` still returns 0, so the
  capture script's log had carried the first one unnoticed.
- Capture bug again in my own tooling: slicing `dmesg` by baseline line number returned an
  empty file because the ring wrapped (the RmInitAdapter storm keeps it wrapping). Use
  timestamps.
- Nothing was removed or installed at the package level; the pacman module package and the
  initramfs are untouched. Added by this attempt only: the owner's two firmware files under
  `/usr/lib/firmware/nvidia/580.142/` and the build tree in `~/nvunlock/`.

Recovery: reboot (warm reset brings the slot back and reloads the stock modules from the
initramfs). Procedure after that boot: `RESUME-after-reboot-2026-11-23.md`. Rollback to
factory from any unlocked state: power cycle (WoL available).

## Rules added by this attempt

- No runtime `rmmod` of the nvidia stack on this box for experiments.
- A real Boot 2 needs the stock modules to never load (one-shot GRUB entry with
  `modprobe.blacklist=`, then `insmod` 580.142) - to be designed with the owner and, given
  today, ideally on-site.
