# RESUME - Boot 1 (relock arm), armed 2026-11-23 ~16:20 +01:00

Machine powered off by the agent for a WoL wake. **Nothing below may start until the box is back in Manjaro from that wake.**

## Armed state (observed, owner transcript 2026-11-23)

| Item | Value |
|---|---|
| Loader | rc4 TX `3ced1096…` at `/EFI/NVUNLOCK-TX/BOOTX64.EFI`, `sudo cmp` OK against `~/nvunlock/stage-tu11x-rc4-pinned/` |
| Assets | 7 `.bin` at ESP root, 7/7 `sudo cmp` OK = byte-identical to the Nov 15 green run |
| Markers | `tx-relock.txt` (0 B, **the single delta**), `tx-select-bdf.txt` = `0000:01:00.0`, `i_know_what_i_am_doing.txt` (3 B, Nov 15 file, auto-run countdown) |
| One-shot | `next_entry=NVUNLOCK-TX`, `saved_entry=gnulinux-simple-708e5695…` untouched |
| ESP record files | `gsp-gate.txt` / `nvuu-stick.json` are the **Nov 15** ones unless the owner copied the rc4 pair - record files only, the loader never reads them (`git grep` on rc4: no reference). Authoritative identity = the cmp-verified hashes in the transcript + `staging/stage-tu11x-rc4-pinned-hashes.txt` + the loader banner |
| Journal | persistent (`/var/log/journal`), so `journalctl -b` still works after later reboots - but capture first anyway |
| Staged for later | `~/capture-relock.sh` (capture), `~/nvunlock/NVIDIA-Linux-x86_64-580.142.run` (Boot 2, sha256 `20915fcf…`) |

Near-miss on the way: the first marker line was a `cd … &&` chain and the zoxide-wrapped `cd` failed, silently skipping the writes while the one-shot was already armed. Caught from the pasted output. Rules in `RUNBOOK-relock-2026-11-19.md` (field amendment).

## Procedure on resume (in this order)

1. `uptime` - must be the new boot. `journalctl -b -p err --no-pager | tail` for a first look.
2. `nvidia-smi --query-gpu=driver_version --format=csv,noheader`
   - **works** (PASS candidate): run the bench FIRST - `cd ~/external/physicsdolphin/nv-uefi-unlocker/docs/evidence/tu117-1f82-manjaro/tools && ./bench-gemm` (factory reference for this script: BEST 1651.95 / MEAN 1602.99 GFLOPS) - because the next step unloads the driver.
   - **fails** (`No devices were found`): expected shape after #280; go straight to step 3.
3. `bash ~/capture-relock.sh` -> `~/capture-relock-<date>/` (`loader.log`, `boot-journal.log`, `dmesg-live.log`, `nvidia-smi-q.txt`, `diag-readback.txt`, `dmesg-after-rmmod.log`). Read-only except `rmmod` of the nvidia stack; leaves the driver unloaded until the next reboot. If the guard blocks it, run the steps individually - the only protected path is the `loader.log` copy.
4. Read `loader.log`: banner (`TX BUILD` + `tx-relock.txt present`), `BOOTER-DIRECT: halted, mailbox0=…`, `POST-BOOT`, `SELECTOR RESULT`, the `TU10X PLM relock:` line, `POST-GOP` (PLM / SS0 / SS1 / READOUT_1 / CANARY), `HANDOFF-OUT … tu10x:unlock=`.
5. Read `diag-readback.txt`: the second block (driver unloaded) is the in-OS register truth - upstream's "init **refuses** vs init **scrubs**" discriminator. If it still cannot read BAR0, say so plainly; the functional probe (driver init) plus the loader readback remain the record.
6. Classify per runbook Step 5 + the erratum: verdict = SS pair `0x88888888`/`0x8` + `READOUT_1=0x0` + `CANARY=intact`; `FEAT_PLM` of `0xffffffef` **or** `0xffffff8f` with SS retained are both valid relock shapes (the write value is `0x8f`, `0xef` is a sticky readback). PASS = SS live **and** the driver initialized. FAIL = driver refused with SS live. UNLOCK GONE = SS washed (relock produced a factory-equivalent state).
7. Evidence: copy the capture dir into `docs/evidence/tu117-1f82-manjaro/relock-2026-11-23/` (redact the MAC if any file carries it), timeline line, commit, `git push mine main:evidence-tu117-1f82`. Post the outcome on #246 (data) and #264 (lane record).
8. **Stop here and report to the owner.** Boot 2 (580.142 swap) is pre-authorized in principle but removes the working driver while the owner is remote: wait for a one-word confirm. Zero retries regardless of outcome.

## Hard constraints

- No reboot / poweroff before the capture is on disk and pushed.
- The unlock state is volatile: a power cycle returns factory (healthy driver) - that is the rollback, and it needs hands or a working WoL.
- The driver stays unloaded after step 3 until the next reboot - intentional.
