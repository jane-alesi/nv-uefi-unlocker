# Residue register diff - gate-open transaction, Linux 580.178.04 refused state (2026-11-25 07:30)

Boot `ff3b76b0…` (kernel start 07:26:37, `iomem=relaxed`). Transaction = gate-open arm
(loader spine in `loader-gateopen-2026-11-25.log`: cold entry, FWSEC, booter halt
`mailbox0=0x0` `exci=0x00900100`, selectors written, signature restored, FLR skipped,
canary armed, chainback). Driver refused: `RmInitAdapter failed (0x62:0x40:2674)`, 786+
attempts by 07:38. Readback via upstream main `diag-unlock.py` (`iomem=relaxed`, driver
loaded, no unbind): first working in-OS BAR0 read on this box.

| Register | Cold factory (loader.log, this boot) | Post-handoff, driver refusing (diag) | Moved |
|---|---|---|---|
| `PMC_BOOT_0` | `0x167000a1` | `0x167000a1` | - |
| FEAT PLM `0x409650` | `0xffffff8f` -> `0xffffffff` (payload) | **`0xffffffff` (OPEN)** | payload-set, **held** |
| SS0 `0x409664` | `0x5200025` (cold noise) -> `0x88888888` | **`0x88888888`** | payload-set, **held (not scrubbed)** |
| SS1 `0x40966c` | `0x7` -> `0x8` | **`0x8`** | payload-set, **held** |
| READOUT_1 `0x409668` | `0x00000000` | `0x00000000` | unchanged - effective rates identical (nothing rate-limited on this silicon) |
| WPR2_LO `0x1fa824` | `0x1ffffe00` (cold) -> `0x00f78000` (handoff) | **`0x00ffee00`** | **moved: the failing driver built its own window** |
| WPR2_HI `0x1fa828` | `0x0` (cold) -> `0x0` (handoff) | **`0x00fffc00`** | **moved (see below)** |
| `BSI_SCRATCH15 0x1180fc` | `0x201001bf` | `0x201001bf` | unchanged from factory |
| `GFW_SCRATCH 0x118234` | `0x000003ff` | `0x000003ff` | unchanged from factory |
| `GFW_PLM 0x118128` | `0xffffff8f` | `0xffffff8f` | unchanged |
| SEC2 CPUCTL `0x840100` | `0x00000010` (cold) | `0x00000000` | changed (engine stopped after the booter halt) |
| SEC2 EXCI `0x8400d0` | not sampled cold | `0x00900100` | **booter halt EXCI latch = residue** |
| GSP CPUCTL `0x110100` | `0x00000010` | `0x00000010` | unchanged |
| GSP EXCI `0x1100d0` | not sampled cold | `0x00000000` | - |
| PBUS canary `0x1480/0x1484` | absent at cold | `0x0164c0de/0x0165cafe` intact | **loader-planted residue** |
| MMU PLM `0x1fa7c8` | `0xbadf5040` | `0xbadf5040` | unchanged (PL0-blocked) |
| FBPA PLM `0x9a0148` | `0xffffffcf` | `0xffffffcf` | unchanged |

## Findings

1. **Refuse-without-scrub, register-confirmed (first Linux register confirmation).**
   The FEAT block reads fully live in the OS during the failure loop: gate `0xffffffff`
   open, SS overrides `0x88888888/0x8` in place, while every init attempt returns
   `RESET_REQUIRED`. Nothing was scrubbed across 700+ attempts.
2. **The failing driver builds its own WPR2 window before failing.** At handoff
   `WPR2_HI=0x0` (the payload's write), so the driver ran its own FWSEC (per the #286
   mechanism note) and left a fresh window `0x00ffee00/0x00fffc00` - then returned
   `RESET_REQUIRED`. Refines the #286 "WPR2 shape" axis: at the moment of refusal the
   window is the **driver's own**, not the loader's, not cold.
3. **Non-factory residues present at refusal** (candidates, in upstream's list order):
   SEC2 residue (EXCI latch `0x00900100`, engine state) > PBUS canary (loader-planted;
   excluded on Windows #286, Linux confirmation pending) > FEAT trio (excluded on #286) >
   BSI/GFW values (unchanged from factory -> not candidates unless checked dynamically).
4. `READOUT_1 = 0` before and after settles, again, that nothing on this silicon is
   rate-limited: the unlock is behaviourally a no-op on a GTX 1650.
