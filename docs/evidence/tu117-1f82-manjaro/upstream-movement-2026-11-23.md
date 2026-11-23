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

---

# Evening addendum - 2026-11-23 (after Boot 1, the failed Boot 2 attempt and the recovery)

## Fresh upstream clues (7 commits 21:15-21:55 +08, #286 thread)

| Source | Clue |
|---|---|
| #286 attachment (TU117 `1f83` GTX 1630, Windows, reporter-run ladder) | **FEAT state is excluded as the trigger**: gate open / closed, SS full-speed / all-zero, even fully factory (replay + `tx-force-continue`, v67 removed) -> Code 43 whenever FWSEC+booter ran and no reset happened before handoff. Agitate-only (no FWSEC) and "replay + emergency FLR" are both normal. Reading: the TU11x driver refuses the **pre-initialised residue**, not the unlock |
| #286 | `0xffffff8f` relock is a **one-way gate** on that card (an in-OS `0xffffffff` re-open write is dropped); PnP disable/enable does not reset (canary intact) |
| #286 | First Turing 11X fuse-row dump (1630, stock session): `SM_SPEED_SELECT_DP/FFMA/FMLA16/FMLA32/IMLA0..4 = 0x0`, `GEN3_SPEED_DISABLE = 0x0` |
| `cfa8384`, `bfbe53c` | Selector semantics calibrated on TU106: SS0 = eight nibbles (bit3 = override enable, [2:0] rate 0/1/2/3 = full/half/quarter/eighth), nibble3 = FP16 tensor (the 20-series factory clamp), nibble4 = plain FP32; **SS1 don't-care on the 20 series** |
| maintainer to the 1630 reporter | "1630 has no tensor cores; your acceptance metric is Code 43 or not (transaction-path integrity) - no compute run required (not necessarily any gain)"; compat doc: "16 series has no tensor cores, unlock benefit = n/a, transaction generality only" |
| `cf8dbec`, `6ed769e` | ssdiag 0.8.9 / `tools/diag-unlock.py` gain `--target-offset/--value` arbitrary in-OS writes (the in-vivo vehicle) |
| compat matrix | GTX 16 = asset-level all-models support; **OS-side driver acceptance = the open question** |

## What our own logs say about THIS card (read-only, no new boot)

- `FACTORY FEAT_READOUT_1=0x00000000` on every run (Nov 3 RO, Nov 15, Nov 23) - all nine
  selectors already at full speed **before** any unlock; `READOUT_1=0x00000000` again after it.
- Cold SS0 words (`0x24264126`, `0x25264026`, `0x07254066`): low bits are reset-state noise,
  but bit 3 (override enable) is clear in every nibble.
- Our Linux pattern matches the 1630's: FWSEC + failed booter + emergency FLR (11-03) ->
  accepted; FWSEC + booter + no reset before handoff (11-15, 11-23) -> refused.

**Conclusion for the GTX 1650 (TU117 `1f82`):** the transaction opens the gate and the
selector writes land (proven three times) - but nothing is rate-limited on this silicon
(factory READOUT 0, no tensor cores), and the driver refuses the state for a reason
independent of FEAT (residue). Even a driver-accepted unlock could not make this card
faster; its value is upstream's family picture only.

## Correction to our Nov 3 root cause of the in-OS BAR0 `EINVAL`

`ro-pass/os-readback-blockers.md` said "BAR0 marked IORESOURCE_EXCLUSIVE, verified in the
6.12 source at /usr/src/linux612". That tree is headers-only (0 `.c` files). Checked against
the real upstream v6.12 sources (torvalds/linux):

- `drivers/pci/pci-sysfs.c` `pci_mmap_resource_fop()`: `if (res->flags & IORESOURCE_MEM
  && iomem_is_exclusive(res->start)) return -EINVAL;`
- `kernel/resource.c` `resource_is_exclusive()`: exclusive = a `SYSTEM_RAM|EXCLUSIVE`
  resource, **or** (`strict_iomem_checks` **and** `IORESOURCE_BUSY` **and**
  (`CONFIG_IO_STRICT_DEVMEM` or `IORESOURCE_EXCLUSIVE`)).
- `iomem=relaxed` sets `strict_iomem_checks = 0` -> every non-RAM busy resource stops being
  "exclusive" -> the sysfs mmap block lifts (x86 `devmem_is_allowed()` uses the same
  function, so `/dev/mem` opens too).

So the blocker is "BAR0 is claimed by a driver on a strict-IO kernel", not a flag special to
this card - which is why BAR1/BAR3 (unclaimed) mapped fine. Today's `EINVAL` persisting after
`rmmod` is consistent with the unload not releasing the region (the same exit path that
leaked slab objects) - inference. **Not yet tested**: `iomem=relaxed` is a boot parameter;
first use must confirm the source reading.

## Options this opens (WoL cycle available)

1. In-OS read access on Linux via `iomem=relaxed` for one boot: a factory reference read on a
   healthy boot (zero GPU risk), then the refused-state residue inventory (WPR2 shape,
   BSI/GFW scratch, SEC2/GSP CPUCTL, canary, FEAT block) = the Linux half of the maintainer's
   residue question list, plus the refuses-vs-scrubs register answer.
2. In-OS single-variable ablation pokes (`--target-offset/--value`) in the refused state -
   each needs owner GO; re-init attempts come free from any NVML client.
3. Cold-boot loader-side ablations (e.g. `tx-no-canary.txt`) - follow the #286 ladder.
4. 580.142 driver cell - needs the stock modules never to load (one-shot `modprobe.blacklist=`).

Not options: anything that `rmmod`s the nvidia stack, or unbinds it (11-03: D-state hang).
