# Upstream movement check - 2026-11-19 (4 days after the green run)

Read-only sweep. No hardware touched, no boot, no writes to the card.

## Maintainer replies (landed 2026-11-15, during our EOD wrap - we missed them that day)

| Where | Who | Content that matters |
|---|---|---|
| #151 physicsdolphin 10:33Z | milestone | **First TU117 unlock established**; Nov 3 -> Nov 15 = clean single-variable confirmation of the placement root cause (`sec 0x100+0x8300` vs tu10x `0x8400` was the `0x31` blocker). `dma_landed=false sanitized_only=true` is a **sampler false negative**, not a verdict: `FEAT_PLM=0xffffffff` has exactly one writer (the payload chain), the selector stage never touches the PLM. `halted mailbox0=0x0` = TU116 booter completion semantics (family difference, both end gate-open); `0xdead5ec2` = the booter's own end-of-run sanitize |
| #246 physicsdolphin 10:42Z | diagnosis | Tuples decode against the open kernel-module `osinit.c`: `(0x62:0x40:2674)` = **NV_ERR_RESET_REQUIRED : NV_ERR_INVALID_STATE**; `(0x22:0x56:897)` = NV_ERR_INVALID_CLASS : NV_ERR_NOT_SUPPORTED (aftermath). Hypotheses: **H1** 580.x init refuses PLM-open-at-handoff (state-consistency rejection), **H2** TU117-specific. WPR2 `lo=0x00f78000/hi=0x0` reads as a torn-down window, ranked below H1 |
| #246 physicsdolphin 10:50Z | sequencing | **Ablation order: 1 `\tx-relock.txt` (highest information per cold boot), 2 driver 580.142, 3 610.43.** "Nothing further needed from us before your relock run"; pass = 16-series deliverable configuration, fail = H1 dead + TU117-specific rejection documented. Confirmed our misfire boot was a valid fail-safe demonstration; confirms the SS cold-instability datum (2nd independent sighting); retires the `\tx-bootvec-sec.txt` ablation no seat endorsed |

## Fact-check we ran (primary source, no new data needed)

The two maintainer comments conflict on the **#103** handoff shape: #151 says "same success tail (gate open at handoff, FLR skipped)", #246 says #103 predates the gate-open default and used the legacy relock tail. Pulled #103's own log:

```
417  TU10X PLM relock: plm=0xffffffef known-good (bits 5:6 sticky-open) ... unlock_persist=true
418  TX-tu10x: FLR skipped (Turing FEAT PLM does not survive FLR)
```

**#246 is right, #151's wording is wrong** (carrier v2.1.9-rc1, filed 2026-11-01, before `061aef8` 2026-11-08). Consequence: gate-open-at-handoff has **never** been accepted by Linux GSP-RM on any Turing die - our run is the first such attempt - so H1 leads and the relock boot is the correct next gated run. Posted with the citation: [#246 comment](https://github.com/physicsdolphin/nv-uefi-unlocker/issues/246#issuecomment-7006619333).

## Readiness check for the relock run (offline, zero boots)

- `loader/src/tx.rs::family_is_turing()` = `family == "tu10x" || family == "tu11x"` -> `\tx-relock.txt` takes the **Turing arm** on TU117: relock target `0xffffffef`, loader expectation `POST-GOP plm=0xffffffef && ss0=0x88888888 && ss1=0x8`.
- Marker logic identical in our staged v2.1.12-rc3 @ `7f90924`. `7f90924..v2.1.12-rc4` loader delta = `\tx-no-flr.txt` for the **ga10x/ada** arm only (issue #242); pinned-input hashes unchanged -> an rc4 rebuild produces the same tu11x assets. Plan: rebuild from tag `v2.1.12-rc4`, re-verify payload `c79208ac…` / booter `2e78e446…` against `staging/tu11x-asset-hashes.txt`.
- Arming = add `\tx-relock.txt` to the ESP stage + `grub-reboot "NVUNLOCK-TX"`. **Needs owner GO + physical presence.**

## Data loss admitted on the record

Upstream's ablation 4 (full dmesg context around the tuples) is **unrecoverable**: journald on this host is volatile and the box has been power-cycled since the failing session (journal now starts 2026-11-17). Only the two tuple excerpts in `REPORT-tu11x-2026-11-15.md` / #151 survive. Future runs capture `dmesg -w` from module load + `journalctl -k -b 0` + `nvidia-bug-report.sh` as first-class artifacts.

## Other upstream movement relevant to us (no action, context)

| Commit | Relevance |
|---|---|
| `5c7dd1c` | **Our datum canonized**: compat matrix "GTX 16 \| 1f82 first unlock established (#151; OS-side driver acceptance pending ablation)" |
| `e60c428` | Turing **non-GSP four-quadrant** verdict: legacy x gate-open = Code 43; legacy x gate-closed = TDR storm -> FEAT washed; both GSP quadrants alive. Consistent with our GSP-mode host; `EnableGpuFirmware=1` upgraded from heuristic to ablation-backed requirement |
| `1e3151c` + `5a62951` | `\tx-no-flr.txt` (ada/ga10x only) + version bump **v2.1.12-rc4** |
| `fb9496c` | Harry-Chen/unlocked-ada-gemm: post-unlock CUDA kernel heuristic mismatch -> autotune before trusting a first-run GEMM number (applies if the relock run passes) |
| `ab2c81c` | gsetupmod credited as platform-side relock remedy (Windows, UEFI-variable based) |
| `79349ab` | Windows-side `EnableRuntimePowerManagement=0` hybrid workaround (iGPU-only mode cost) |
| `cca3f74` | ssdiag 0.8.2 fail-closed tier-2 gate (Windows VBS) |

## State / next

GPU: factory derivation, driver healthy. ESP: tu11x stage + markers live; relock test is one file away.
Blocked on: **owner GO** for the single relock cold boot; physical presence for WOL BIOS fix.
