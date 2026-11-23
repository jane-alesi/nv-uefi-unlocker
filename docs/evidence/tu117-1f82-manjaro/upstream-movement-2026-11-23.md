# Upstream movement check - 2026-11-23 (standby sweep, no hardware touched)

149 new commits on `origin/main` since our base (`7f90924`), tags `v2.1.12-rc5/rc6/rc7`. The TU11x OS-acceptance question is now a multi-machine family with its own discriminator ladder.

## Headlines

| Item | What landed |
|---|---|
| **#263 (ours) closed as adopted-in-full** | `45c7690` + `02d72fd` (both twins sh+ps1): loud `fwimage source: BADGE ... / PINNED ...` line, `nvuu-stick.json` gains `fw_source` (route, driver, staged-ELF SHA-256), badge-vs-pin warn. Ships in the next release built from main (post-rc4) |
| **#151 correction posted** (11-19 17:07) | Upstream retracted the wrong "#103 gate-open" sentence, crediting our #246 fact-check; matrix no longer claims gate-open Linux-accepted on Turing |
| **#246 maintainer follow-up** (11-19 17:07) | Same-phase WPR2 baselines from their archived logs: residual nonzero `lo` + `hi=0` is the standard shape in both handoff arms (TU106 `0x01f70000/0x01f77000`, Ada `0x1ffffe00`), so our `0x00f78000` reading is per-card variation, **deprioritized vs H1** - our REPORT's "no same-phase comparison" gap is closed. Ablation order confirmed (relock first, GO with owner); they endorse the rc4+pinned-route stage |
| **#280 (new, 11-22): TU116 first field case** | GTX 1660 SUPER `21c4`, Windows 11, driver **621.14 with `EnableGpuFirmware=1` (GSP mode)**, carrier **v2.1.11 = relock handoff** (`plm=0xffffffef` + SS live, confirmed loader- and OS-side). EFI three-proof green, in-OS ssdiag `UNLOCKED` + canary intact - then **nvlddmkm GSP init Code 43**. Power-cycle clears (ProblemCode=0) |
| **Erratum (`3d2ff2f`)** | The relock **write value is factory `0xffffff8f`** (tx.rs:1711); `0xffffffef` is the post-write readback - once the gate has been opened, bits 5:6 resist host clearing (TU106/TU104 silicon; TU102 22G once read `0x8f` with SS retained = board variance, #74). So "RM dislikes bits 5:6" is **not a controllable axis**; there is no knob |
| **#286 (11-23): TU117 legacy cell filled** | GTX 1630 `1f83`, rc5+rc7 keep-open handoff: EFI green + in-OS `UNLOCKED`/canary intact, but Code 43 on driver enable (621.24 and 617.42, both generations); boot-bound -> suspected TDR hang. **Code 43 leaves the unlock state intact** (unlike the TU106 bench's gate-closed x legacy wash). Only valid TU117 zero-write negative control = agitate-only (TU117 replay dies `mailbox0=0x0b`, signature domain - unusable) |
| **GTX 16 promoted** (`ea35c37`/`57abf90`) | Compat matrix: GTX 16 = **asset-level all-models support** (die-keyed tu11x assets on main); per-card field records accumulating; **OS-side driver acceptance is the open question** (#246/#280 ladder). Our `c79208ac` payload hash is cited unchanged in #280 |

## The settled picture (maintainer's table on #280)

| Handoff shape | Result |
|---|---|
| open `0xffffffff` | #246 (TU117 `1f82`, Linux 580.178, rc3): RmInitAdapter fails |
| relock `0xef`-readback + SS live | #280 (TU116 `21c4`, Windows 621.14, v2.1.11): Code 43 |
| TU102, both shapes | accepted (#12/#103/#125/#240) |

**TU11x RM rejection is independent of the handoff PLM shape.** H1 (gate-open rejection) is dead as the sole explanation; the working frame is a TU11x-family OS-acceptance gap. Remaining ladder cells: TU11x x GSP x keep-open on #286's machine (reporter has the stick, will flip `EnableGpuFirmware`), WPR2 residual diff, RM error-code decode, driver generation. #246 got the `TU11X` label today (11-23 04:14) - now tracked as one family with #280/#286.

## Impact on our queued relock boot

The cell "TU117 x Linux 580.178 x relock" is still empty, but its prior dropped hard: #280 shows the relock shape rejected on Windows 621.14. Our runbook's pass-shape row also needs the erratum correction (see RUNBOOK 2026-11-23 amendment): `0xef` is a readback, `0x8f`+SS-retained is a valid shape too; SS pair + READOUT stay the verdict. Asked upstream on #246 whether this boot remains their top ask before spending it.

## Loader/asset stability check for our stage

- Relock block (`tx.rs`/`tx_booter.rs`) unchanged `7f90924..v2.1.12-rc7` - runbook loader-side facts stand.
- tu11x payload/booter hashes unchanged (upstream's own #280/#286 records carry `c79208ac`/`2e78e446`, same as our green run).
- `assets/src/main.rs` + `make-usbroot.sh` grew (`fw_source` plumbing, #263) - build-time only, no loader behavior change for tu11x.
