# Upstream issue body: TU117 10de:1f82 first data point

Title: TU117 GTX 1650 (10de:1f82) first data point: Booter 0x31 (secure entry never executed), unlock=false, clean FLR + handoff

Repo: https://github.com/physicsdolphin/nv-uefi-unlocker/issues

---

Body (paste via `gh issue create --title ... --body-file` or web):

---

First 10de:1f82 (TU117, GTX 1650) data point for the tu10x family.
docs/compatibility.en.md carries "GTX 16 hardware verification with this
tool remains pending"; this is the first field run on this PCI ID.

## Result

- **No unlock established.** Booter halted at sample 0 with
  mailbox0=0x31: "NS-stub pre-secure marker (final) - the secure entry
  never executed (placement/entry-level failure, see PR #67 D/E rounds)".
- No payload writes happened (POST-BOOT readback: PLM 0xffffff8f closed,
  SS0 0x24264126 default, READOUT 0, "the payload's writes did not happen").
- Failure-path unwind was clean: stock signature restored, FLR clean
  (pending=false, D0), chainback to the OS bootloader.
- **No retry loop was performed** - a 0x31 result on an unverified chip
  is a data point, not a flake to chase.

## Target

- GPU: NVIDIA GeForce GTX 1650, TU117, PCI 10de:1f82 rev a1,
  subsystem 1043:871c (ASUSTeK), BDF 0000:01:00.0
- VBIOS: 90.17.27.00.22
- Host driver: 580.178.04, GSP-RM mode (GSP firmware 580.178.04)
- Payload inputs: pinned NVIDIA 610.43.03 (kernel-module-source +
  cachyos nvidia-utils), TU10x booter/GspRmBoot slice de676bae...
  (proven on TU106 2026-10-27). Note the host driver here is 580.178.04,
  not 610.43.03: the maker gate checks GSP-RM mode, not version match.

## Platform

- Manjaro 6.12.108-1-MANJARO, x86_64, headless (no monitor), dGPU-direct:
  kwin_wayland + Xwayland + Sunshine use the GPU
- Loader: v2.1.9 TX build, SHA-256
  542f7fdfb8c20c1f5f44743a16e74aa19f18ca5f571f09b4f167c0cf01c69d2b
- Entry path: GRUB one-shot menu entry chainloading
  /EFI/NVUNLOCK-TX/BOOTX64.EFI from the ESP (no USB stick on this box);
  target selected via \tx-select-bdf.txt ("0000:01:00.0"), armed via
  \i_know_what_i_am_doing.txt (10s auto-run countdown, headless)
- Chainback: preloaded \EFI\Manjaro\grubx64.efi, StartImage, back to
  Linux. No NVRAM BootOrder changes.

## Key log lines (TX run)

```
[  11739ms] TX-tu10x: entry WPR2 lo=0x1ffffe00 hi=0x0 (cold) - FWSEC will be fired by the loader [fwsec=ran]
[  11989ms] FWSEC-TU10X: GSP reset done: rm=0x167000a1 cpuctl=0x00000010 chip=0x167000a1
[  11989ms] FWSEC-TU10X: BL at IMEM dst=0xfe00 (hwcfg 256 blocks), BOOTVEC=0xfd00  <== dst != 0xfd00 (50HX saw 0xfd00 on TU102/TU106)
[  11992ms] FWSEC-TU10X: *** WPR2 UP lo=0xffee00 hi=0xfffc00 after 3ms ***
[  12079ms] FWSEC-TU10X: GSP-HALT gate: CPUCTL 0x00000000 -> halted=true after 85ms
[  12079ms] FWSEC-TU10X: FWSEC result (kernel shape): MAILBOX0=0x00000000 MAILBOX1=0x00000000 scratch0e=0x00000000 frts_err=0x0000
[  12107ms] BOOTER-PLACE: ns 0x0+0x100 -> dest 0 tag 0x0 | sec 0x100+0x8400 -> dest 0x100 tag 0x100 (tag==dest: true)
[  12111ms] BOOTER-AUDIT: ns readback MATCH (fnv 0016580a21)
[  12119ms] BOOTER-AUDIT: dmem readback MATCH (fnv 00dfde6ac5)
[  12124ms] BOOTER-DIRECT: mbox live @sample 0: mbox0=0x00000031 mbox1=0x00000001
[  12124ms] BOOTER-DIRECT: core halted at sample 0, DMEM[0x600]=0x00000000
[  12124ms] BOOTER-DIRECT: halted, mailbox0=0x31 mailbox1=0x1 exci=0x00a00100
[  12124ms] BOOTER: EXCI decode: EXPC=0x100 EXCAUSE=0xa (MISS_INS) - also seen in successful runs, not a verdict by itself
[  12126ms] BOOTER: mailbox0 verdict: 0x31 - NS-stub pre-secure marker (final) - the secure entry never executed (placement/entry-level failure)
[  12131ms] BOOTER-DIRECT: DMEM verdict: signature DMA never landed - ... (#14/#90 field-proven false negatives; #90's PLM opened and selectors landed with this exact verdict)
[  12133ms] POST-BOOT: FEAT_PLM=0xffffff8f SS0=0x24264126 SS1=0x6 (Turing 0x4096xx block)
[  12139ms] POST-BOOT: PLM still locked - the payload's writes did not happen
[  12144ms] TX: stock signature restored (failure-path unwind)
[  12244ms] FLR: cmd=0x0003 devsta=0x0010 (pending=false) gfw_boot=0x101 wpr2_hi=0xe00
[  12258ms] HANDOFF-OUT: ... | tu10x: plm=0xffffff8f ss0=0x24264126 ss1=0x00000006 readout=0x00000000 | tu10x:unlock=false ga/ada:ss0_unlock=false ss1_unlock=false plm_open=false
```

## In-OS state after the run

- nvidia re-attached healthy: GSP 580.178.04 running, VBIOS 90.17.27.00.22
  unchanged, P0/D0, no Code 43
- Post-run fixed GEMM bench matches the pre-run baseline within run-to-run
  variance (best 2060.65 vs 1999.23 GFLOPS, checksum identical): no gain,
  consistent with unlock=false

## In-OS diagnosis / kernel data points (6.12.108-1-MANJARO)

1. **sysfs BAR0 mmap blocked**: `/sys/bus/pci/devices/.../resource0` mmap
   returns EINVAL on this kernel (iomem_is_exclusive on the GPU BAR0,
   IORESOURCE_EXCLUSIVE; BAR1/BAR3 on the same device mmap fine).
   tools/diag-unlock.py therefore cannot run here; the UEFI loader's own
   readbacks were used as the authoritative in-OS substitute.
2. **nvidia unbind/rebind hangs the probe**: unbind left
   `drm_WARN_ON(!list_empty(&fb->filp_head))` in nv_drm_dev_unload; the
   subsequent bind blocks in D-state indefinitely. Recovery = reboot.
3. **NVreg_DynamicPowerManagement=0x00 via /etc/modprobe.d is not
   reflected**: /proc/driver/nvidia/params still reports 3.

## Full log

Unredacted loader.log (35,850 bytes / 339 lines, TX run):
`docs/evidence/tu117-1f82-manjaro/efi-log/tx-run.log` in this checkout,
sha256 `30e0842d7c6df710608b1b5e8ffb14d2eda47bcbf9091e7418572fc785a7ad58`
(the read-only pre-write sampler run: `efi-log/ro-run.log`, 108 lines,
sha256 `4322b94d754fce769d30057c4451728676431fb956628b8043d190f7cf85a18a`).
Happy to paste the full log here on request.
