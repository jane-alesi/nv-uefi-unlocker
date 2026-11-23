# On-site runbook - TU117 `\tx-relock.txt` ablation (prepared 2026-11-19, NOT yet run)

**Purpose.** Upstream's highest-value ablation for #246: hand the card to the OS with the FEAT gate **re-locked** (`0xffffffef`) while the SS overrides stay written - the only handoff shape with a proven Linux GSP-RM acceptance on a Turing die (#103 log line 417, see `upstream-movement-2026-11-19.md`). One cold boot answers H1 (580.x refuses PLM-open-at-handoff) vs H2 (TU117-specific refusal).

**Status: needs owner GO.** Nothing below has been executed. ESP writes and the boot itself are owner-run (agent guard blocks `EFI/**`, and everything needs sudo anyway).

**Hard rules:** one transaction boot, **zero retries**, no further power cycles beyond the ones listed, capture before any reboot.

---

## Prepared offline (done 2026-11-19, no hardware touched)

| Item | Value |
|---|---|
| Stage on disk (outside git, NVIDIA blobs never committed) | `~/nvunlock/stage-tu11x-rc4-pinned/` |
| Loader | tag `v2.1.12-rc4`, `cargo build --release -p loader --target x86_64-unknown-uefi --features tx` -> `3ced1096ecc638eb34e5b10558636aace1b8550f1316a49fb2114ad2fe4fe598` (524800 B), `check_efi.py` verdict **TX build (gated artifact)** |
| 7 stage assets | **byte-identical** to the Nov 15 green-run stage (`staging/tu11x-asset-hashes.txt`): booter `2e78e446`, payload `c79208ac`, `gsp_boot` `de676bae`, fwimage `c10c2866`, fwsignature `c94c6cb3`, sec2_bl `f21f1cfb`, gsp_boot_desc `9e7cca2c` |
| Full stage manifest | `staging/stage-tu11x-rc4-pinned-hashes.txt` |
| Why rc4 loads but rc3 assets | `7f90924..v2.1.12-rc4` loader delta = `\tx-no-flr.txt` for the **ga10x/ada** arm only; pinned-input hashes unchanged. `family_is_turing()` covers `tu11x`, so `\tx-relock.txt` takes the Turing arm: relock target `0xffffffef`, expectation `ss0=0x88888888 && ss1=0x8` |
| Route trap found and fixed | default `--utils-source auto` resolved to **badge mode** (host 580.178.04 ELF) and produced a different `fwimage` (`3a2b48ce`/30469792). Rebuilt with `--utils-source arch` = pinned 610.43.03 (`c10c2866`/29339080) = the green-run asset. Filed upstream as [#263](https://github.com/physicsdolphin/nv-uefi-unlocker/issues/263) |

Rebuild command (reproducible, inputs cached in `inputs-tx/`):

```bash
cd ~/external/physicsdolphin/nv-uefi-unlocker   # after: git worktree add <dir> v2.1.12-rc4
cargo build --release -p loader --target x86_64-unknown-uefi --features tx
release/make-usbroot.sh --family tu11x --utils-source arch \
  --work <workdir-with-pinned-inputs> --boot-efi <built loader.efi> \
  --out <stage> --no-install-prompt
```

---

## Step 0 - at the machine, before anything (2 min)

```bash
uname -r; nvidia-smi --query-gpu=driver_version,gsp_firmware.default --format=csv,noheader
sudo efibootmgr | head -8
ls /boot/efi/EFI/ | head; sudo grub-editenv /boot/grub/grubenv list
```

Record the output. Driver must still be **580.178.04** (the #246 datum is version-bound) and GSP firmware active. If a kernel/driver update landed since the 15th, say so before arming - it changes the experiment.

## Step 1 - verify the stage, then copy it to the ESP

```bash
cd ~/nvunlock/stage-tu11x-rc4-pinned && find . -type f | sort | xargs sha256sum   # must equal the committed manifest
sudo cp -a ~/nvunlock/stage-tu11x-rc4-pinned/BOOTX64.EFI /boot/efi/EFI/NVUNLOCK-TX/BOOTX64.EFI
sudo cp -a ~/nvunlock/stage-tu11x-rc4-pinned/*.bin /boot/efi/
```

Then verify **on the ESP** (the copy, not the source) against the same manifest, and confirm the TX banner is in the booted binary:

```bash
python3 - <<'PY'
d=open('/boot/efi/EFI/NVUNLOCK-TX/BOOTX64.EFI','rb').read()
print(len(d), 'TX banner' if b'TX BUILD: CONTAINS GPU-WRITE PATHS' in d else 'NOT TX')
PY
```

Expected `524800 TX banner`.

## Step 2 - markers

```bash
cd /boot/efi
echo '0000:01:00.0' | sudo tee tx-select-bdf.txt >/dev/null   # pin exactly one card
sudo touch i_know_what_i_am_doing.txt                          # armed mode: 5 s countdown
sudo touch tx-relock.txt                                       # <<< THE ABLATION
ls -la /boot/efi/*.txt
```

**The only difference from the Nov 15 green run is `tx-relock.txt`.** Keep the Nov 15 markers as they were; do not add any other marker (in particular not `\tx-no-flr.txt` - that arm is ga10x/ada only).

## Step 3 - arm the one-shot, then a real cold boot

```bash
sudo grub-reboot "NVUNLOCK-TX"
sudo grub-editenv /boot/grub/grubenv list        # next_entry must name NVUNLOCK-TX
sudo poweroff                                     # PSU stays ON, no reboot (cold entry)
```

`grubenv next_entry` survives the power-off, so the loader runs on the next power-on exactly once. At the machine: power button -> the loader prints the banner (confirm the `TX BUILD` line), runs the transaction, chains back to Manjaro on its own. Screen capture or a photo of the final report block if convenient.

## Step 4 - capture BEFORE any reboot (the Nov 15 lesson)

```bash
mkdir -p ~/capture-$(date +%F) && cd ~/capture-$(date +%F)
cp /boot/efi/loader.log .                        # copy off first - any later run overwrites it
sudo journalctl -k -b 0 > kernel-boot.log         # full boot log incl. pre-login module init
sudo dmesg > dmesg-live.log
nvidia-smi -q > nvidia-smi-q.txt
sudo nvidia-bug-report.sh --output-prefix gpu- >/dev/null 2>&1; ls gpu-*
```

`journalctl -k -b 0` is the artifact that upstream's ablation 4 asked for (the lines **before** the first `RmInitAdapter`); the Nov 15 context is unrecoverable (volatile journal + power cycle). **Do not reboot until this block has run.**

## Step 5 - read the verdict

| Where | Look for | Pass shape |
|---|---|---|
| `loader.log` `POST-GOP` | `FEAT_PLM=` / `SS0=` / `SS1=` / `READOUT_1=` / `CANARY=` | `SS0=0x88888888` `SS1=0x8` `READOUT_1=0x00000000` `CANARY=intact` with `FEAT_PLM=0xffffffef` **or** `0xffffff8f` - see the erratum below |
| `loader.log` `HANDOFF-OUT` | `tu10x:unlock=` | `unlock=true` |
| `kernel-boot.log` | `RmInitAdapter failed` | **absent**, GSP firmware version printed, `nvidia-smi` lists the card |

**Erratum (upstream `3d2ff2f`, 2026-11-22, from #280):** the relock *write value* is factory `0xffffff8f`; `0xffffffef` is the post-write **readback** (bits 5:6 resist host clearing once the gate has been opened - TU106/TU104 silicon; TU102 22G once read `0x8f` with SS retained, board variance #74). So the loader may print `unlock NOT intact ... want plm=0xffffffef` when the readback is `0x8f` with SS retained - that line is **informational, not a failure**; the SS pair + `READOUT_1` are the verdict. If `READOUT_1` goes nonzero or SS washes, the unlock is gone (relock achieved factory) and the run's datum is "relock arm produces a factory-equivalent state on TU117".

Negative-control note (#286): the only TU117 zero-write negative control is **agitate-only**; TU117 replay mode dies `mailbox0=0x0b` (signature domain) and must not be read as a control.

Then the functional check (READOUT stays the only register verdict; autotune before trusting a GEMM number, per the unlocked-ada-gemm note upstream now references):

```bash
cd ~/external/physicsdolphin/nv-uefi-unlocker/docs/evidence/tu117-1f82-manjaro/tools
nvcc -O3 bench-gemm.cu -lcublas -o bench-gemm && ./bench-gemm     # factory reference: BEST 1651.95 / MEAN 1602.99
```

| Outcome | Meaning | Action |
|---|---|---|
| PLM re-locked + SS live + driver inits + bench >= factory | **H1 confirmed**, relock tail = the 16-series deliverable config on Linux | send log + bench; unlock is volatile, no further action |
| PLM re-locked + SS live + driver still refuses | H1 dead, H2 (TU117-specific) documented | send log; upstream takes it from there |
| Any red criterion / unexpected register value | stop | power off (PSU stays on) -> power on = factory; send the log anyway. **No second attempt without a new GO** |

Recovery from any state: cold power-off, power on -> factory derivation, driver healthy (proven twice).

## Step 6 - same visit: the WOL fix (do it after the transaction boot)

```bash
sudo poweroff            # PSU stays ON
```

Watch the NIC link LED while the box is off. Dead LED -> BIOS (`F10` at power-on): **Advanced > Built-In Device Options > Wake on LAN = enable**, **ErP / Deep Sleep = disable**, save, power on, re-test. From the LAN:

```bash
etherwake "$(grep -oE '([0-9a-f]{2}:){5}[0-9a-f]{2}' /etc/systemd/network/99-enp2s0-wakeonlan.link | head -1)"
# or read it off the NIC: cat /sys/class/net/enp2s0/address
```

Until that test passes, every S5/PSU event on this box counts as hands-required.

## 2026-11-23 amendment (pre-visit prep, superscedes Step 4's manual capture)

- **Capture is scripted**: owner runs `bash ~/capture-relock.sh` after the chainback - it copies `loader.log`, dumps the full boot journal (`-o short-monotonic`), `nvidia-smi`, and the register readback twice: with the driver loaded (known EINVAL, kept for the record) and after `rmmod` of the nvidia stack (the module holds BAR0 exclusively; unloaded, `tools/diag-unlock.py --bdf 0000:01:00.0` can mmap `resource0`). That second readback is upstream's "init refuses vs init scrubs" discriminator (their #246 reply 2026-11-23).
- **Persistent journal is armed pre-boot**: `sudo mkdir -p /var/log/journal && sudo systemctl restart systemd-journald` (one-time, Step 1 block below includes it).
- **Boot 2 staged** (conditional, only if Boot 1 fails): `~/nvunlock/NVIDIA-Linux-x86_64-580.142.run` (sha256 `20915fcf3ffe89c3550cf93b...`, HTTP 200 from NVIDIA, the exact #103 driver). Sequence on failure: remove the pacman nvidia packages (`sudo pacman -R nvidia-580xx-settings nvidia-580xx-utils lib32-nvidia-580xx-utils linux612-nvidia-580xx` - drop `lib32-` if absent), run the `.run` installer (headers 6.12.112 are installed; no dkms needed, the .run builds its own module), **warm reboot** (unlock survives warm reboot, proven 11-15; relock flag stays on the ESP), re-run the capture script, then power off. Revert afterwards = power cycle + reinstall the pacman packages (listed in Step 6's closure).
- Upstream expectation for Boot 1 is now negative-leaning (#280 ran the same relock shape on Windows 621.14 GSP and got Code 43) - **both outcomes are decisive** and GO for Boot 1 was re-confirmed by upstream on #246 (2026-11-23 13:13Z): "the relock boot is still the top ask from this box".

## Cleanup after the outcome is published

Per the removal table in `REPORT.md`: the tu11x stage + `*.txt` markers come off the ESP once upstream has consumed the data point (keep `loader.log` and the capture dir in the evidence branch).
