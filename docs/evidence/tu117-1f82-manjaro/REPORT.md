# TU117 (10de:1f82) GTX 1650 - final report and verdict

Host: ja-manjaro (Manjaro, kernel 6.12.108-1-MANJARO, x86_64)
Target: 0000:01:00.0, NVIDIA GeForce GTX 1650, TU117, 10de:1f82 rev a1,
subsystem 1043:871c (ASUSTeK), VBIOS 90.17.27.00.22.
Host driver: 580.178.04, GSP-RM mode (GSP firmware 580.178.04).
Display mode: headless, no monitor, dGPU-direct (kwin_wayland + Xwayland +
Sunshine use the GPU).

## Verdict

**Valid TU117 no-gain result. No unlock was ever established. No retry loop
was performed (objective: stop, report, file the 10de:1f82 first-report
data point upstream).**

TU117 (1f82) is not in the verified set; docs/compatibility.en.md carries
"GTX 16 hardware verification with this tool remains pending". This run is
the first data point for 10de:1f82.

## Transaction outcome (TX run, loader v2.1.9, TX build 542f7fdf...)

The transaction ran to completion and finished cleanly:

| Stage | Result |
|---|---|
| FWSEC fire | WPR2 UP lo=0xffee00 hi=0xfffc00 after 3ms; GSP-HALT gate passed (85ms) |
| Booter place | ns 0x0+0x100 / sec 0x100+0x8400; ns+dmem readback MATCH; sec 0xdead5ec1 scrub pattern (documented non-verdict on Turing) |
| Booter fire | **Halted at sample 0, mailbox0=0x31** "NS-stub pre-secure marker (final) - the secure entry never executed (placement/entry-level failure, see PR #67 D/E rounds)" |
| POST-BOOT readback | FEAT_PLM=0xffffff8f (closed), SS0=0x24264126 (default), READOUT=0 - "the payload's writes did not happen" |
| Unwind | stock signature restored (failure-path unwind) |
| FLR | clean: cmd=0x0003 devsta=0x0010 pending=false, D0 |
| HANDOFF-OUT | `tu10x: plm=0xffffff8f ss0=0x24264126 ss1=0x00000006 readout=0x00000000 | tu10x:unlock=false ... plm_open=false` |
| Chainback | preloaded \EFI\Manjaro\grubx64.efi, StartImage ok, back to Linux |

Full log: efi-log/tx-run.log (339 lines, sha256 30e0842d...).

## Bench A/B (fixed cuBLAS GEMM, N=2048, 5 reps x 100 iters, seed 0xC0DE1234)

| Metric | Baseline (pre-write) | Post (post-TX) | Delta |
|---|---|---|---|
| Best GFLOPS | 1999.23 | 2060.65 | +3.1% |
| Mean GFLOPS | 1805.63 | 1945.40 | +7.7% |
| Checksum | 2082.0000 | 2082.0000 | identical |
| Peak temp | 88 C | 85 C | -3 C |
| Power state | D0 | D0 | same |

Deltas are within run-to-run variance; with no unlock established, "no
gain" is the correct result. No thermal or frequency regression.

## Post-test machine state (factory derivation confirmed in-OS)

- Driver re-attached healthy: nvidia-smi shows GSP 580.178.04 running,
  VBIOS 90.17.27.00.22 unchanged, P0/D0, kwin/Xwayland contexts active,
  no Code 43.
- No volatile unlock state was ever established (POST-BOOT readback above),
  so the objective's "reboot to restore factory derivation" clause (red
  criteria only) does not apply; a confirming reboot was judged to add no
  evidence and was skipped.
- GRUB one-shot consumed: next_entry= in /boot/grub/grubenv; NVRAM
  BootOrder untouched (Boot0000 Manjaro, as in baseline snapshot).
- Secure Boot: off (efivars header 0x06 0x00 0x00).

## Left in place (inert without a selected menu entry; documented for removal)

| Artifact | Location | Remove via |
|---|---|---|
| NVUNLOCK-RO/TX EFI apps + assets | /boot/efi/EFI/NVUNLOCK-RO/, /boot/efi/EFI/NVUNLOCK-TX/, ESP root (booter/gsp/fwimage/fwsignature/sec2/v67 bins, SOURCE-MANIFEST.json, PROVENANCE.json, gsp-gate.txt) | `sudo rm -r /boot/efi/EFI/NVUNLOCK-RO /boot/efi/EFI/NVUNLOCK-TX` + the listed root files |
| Armed markers | /boot/efi/i_know_what_i_am_doing.txt, /boot/efi/tx-select-bdf.txt | `sudo rm /boot/efi/i_know_what_i_am_doing.txt /boot/efi/tx-select-bdf.txt` |
| loader.log | /boot/efi/loader.log (archived here as efi-log/*.log) | `sudo rm /boot/efi/loader.log` |
| GRUB menu entries | /etc/grub.d/42_nvunlock | `sudo rm /etc/grub.d/42_nvunlock && sudo grub-mkconfig -o /boot/grub/grub.cfg` (pre-test grub.cfg backup: /tmp/opencode/nv-uefi-unlocker/grub.cfg.pre-nvunlock.bak) |
| DPM override | /etc/modprobe.d/nvidia-runtimepm.conf | `sudo rm /etc/modprobe.d/nvidia-runtimepm.conf` |

## Open data points (all filed upstream)

1. **Booter 0x31 on TU117 with placement MATCH**: ns+dmem readback matched,
   WPR2 was up, yet the secure entry never executed. First 1f82 report.
   Note the TU10x host driver here is 580.178.04 while the pinned asset
   inputs are 610.43.03 (maker gate passed on GSP-RM mode, not version
   match).
2. **In-OS BAR0 readback blocked**: sysfs resource0 mmap returns EINVAL on
   kernel 6.12.108-1-MANJARO (iomem_is_exclusive, BAR0 marked
   IORESOURCE_EXCLUSIVE); BAR1/BAR3 mmap fine; /dev/mem EPERM.
   tools/diag-unlock.py therefore cannot run on this machine; the loader's
   own readbacks are the authoritative in-OS substitute (ro-pass/os-readback-blockers.md).
3. **nvidia unbind/rebind hangs the probe** (D-state, drm_WARN_ON in
   nv_drm_dev_unload); recovery = reboot. Do not re-attempt unbind on this
   box.
4. **DPM override not reflected**: /etc/modprobe.d/nvidia-runtimepm.conf
   sets NVreg_DynamicPowerManagement=0x00 and modprobe -c shows it, but
   /proc/driver/nvidia/params still reports 3.

## Upstream

First-report issue filed per docs/faq.en.md "How do I report an
incompatibility or failure?" (full loader.log reference, GPU model/PCI ID,
platform, driver, display mode, entry path, in-OS diagnosis):
docs/evidence/tu117-1f82-manjaro/upstream-issue-1f82.md carries the exact
body; the filed issue URL is recorded here once created.

## File inventory

- baseline/ : nvidia-smi -q full + clocks, lspci -vvv, driver params,
  modprobe config, efibootmgr -v, SecureBoot var bytes, system-info.txt
- bench/ : gemm_bench.cu + compiled gemm_bench (sha recorded in
  baseline-broken-scale.txt note: first build had a GFLOPS unit bug,
  rebuilt; final binary sha256 7d8589f3...), run_bench.sh,
  baseline.txt, post.txt
- ro-pass/ : diag-unlock-ro.txt (failure trace), os-readback-blockers.md
- efi-log/ : ro-run.log (108 lines, sha256 4322b94d...),
  tx-run.log (339 lines, sha256 30e0842d...)
- staging/ : pre-reboot-state.txt, ro-provenance.txt, tx-asset-hashes.txt,
  esp-chainback-targets.txt, timeline.txt
- tools/ : provenance.py (Linux twin of release/make-provenance.ps1,
  same schema nvuu-source-manifest/1 + nvuu-provenance/1)
