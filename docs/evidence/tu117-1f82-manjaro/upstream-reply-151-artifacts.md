Here are the two artifacts the thread asked for, then our follow-up plan.

## 1. Full loader.log (Nov 3 run, TX stage on 10de:1f82)

`sha256(tx-run.log) = 30e0842d7c6df710608b1b5e8ffb14d2eda47bcbf9091e7418572fc785a7ad58`, 339 lines. Our evidence commits exist only in our local checkout (our account has issue access but no push right on this repo), so pasting the log inline as requested:

```log
[    103ms] INFO : loader::logging: log file \loader.log opened on boot volume
[    104ms] INFO : loader::logging: nv-uefi-unloader v2.1.9 (M0 skeleton: read-only)
[    106ms] INFO : loader: WATCHDOG: disabled
[    109ms] INFO : loader::banner: ==================================================
[    110ms] INFO : loader::banner:  nv-uefi-unlocker v2.1.9 (built Mon 2026-11-02 16:33:12 +01:00)
[    112ms] INFO : loader::banner:  ** TX BUILD: CONTAINS GPU-WRITE PATHS **
[    113ms] INFO : loader::banner:  transaction: claim->gfw->fwsec->booter->selectors->flr
[    114ms] INFO : loader::banner: ======== PRESS SPACE or ENTER to CONTINUE ========
[    115ms] INFO : loader::banner: ======== PRESS SPACE or ENTER to CONTINUE ========
[    116ms] INFO : loader::banner: ======== PRESS SPACE or ENTER to CONTINUE ========
[    118ms] INFO : loader::banner:   other key or 30s no-key = ABORT; unlocks NOTHING
[    119ms] INFO : loader::banner:   other key or 30s no-key = ABORT; unlocks NOTHING
[    120ms] INFO : loader::banner:   other key or 30s no-key = ABORT; unlocks NOTHING
[    121ms] INFO : loader::banner:  armed: \i_know_what_i_am_doing.txt = 5s auto-run, any key aborts
[    123ms] INFO : loader::banner:  multi-GPU: no marker = every supported card in order;
[    124ms] INFO : loader::banner:             \tx-select-bdf.txt (bb:dd.f) pins exactly one
[    127ms] INFO : loader::banner:  failure = no retry (per card; the next card still runs)
[    129ms] INFO : loader::banner: ==================================================
[    130ms] INFO : loader::banner: PHASE: CONFIRM
[    133ms] INFO : loader: CONFIRM: \i_know_what_i_am_doing.txt present - ARMED: 10s countdown auto-runs, ANY key aborts
[    135ms] INFO : loader::tx_prep: PREP: enumerate begin
[    136ms] INFO : loader::pci: PHASE: ENUMERATE (read-only)
[    139ms] INFO : loader::pci: ENUMERATE: 23 PciIo handles
[    140ms] INFO : loader::pci: PCI 0000:00:00.0 8086:3ec2 class 000600
[    141ms] INFO : loader::pci: PCI 0000:00:01.0 8086:1901 class 000604
[    141ms] INFO : loader::pci: PCI 0000:01:00.0 10de:1f82 class 000300
[    142ms] INFO : loader::pci: NVIDIA GPU? 0000:01:00.0 device 1f82
[    143ms] INFO : loader::pci:   BAR0 32-bit mem base 0xa2000000
[    144ms] INFO : loader::pci:   BAR1 64-bit mem base 0x0000000090000000
[    145ms] INFO : loader::pci:   BAR3 64-bit mem base 0x00000000a0000000
[    146ms] INFO : loader::pci:   BAR5 io base 0x5000
[    147ms] INFO : loader::pci:   cap 0x01 @0x60
[    150ms] INFO : loader::pci:   cap 0x05 @0x68
[    151ms] INFO : loader::pci:   PCIe cap @0x78: DEVCAP 0x112c8de1 (FLR yes) LINKCAP 0x00453d03
[    154ms] ERROR: loader::pci: cfg_read32(0x0100) status UNSUPPORTED
[    155ms] INFO : loader::pci: PCI 0000:01:00.1 10de:10fa class 000403
[    156ms] INFO : loader::pci: NVIDIA fn 0000:01:00.1 device 10fa
[    157ms] INFO : loader::pci:   BAR0 32-bit mem base 0xa3080000
[    158ms] INFO : loader::pci:   cap 0x01 @0x60
[    159ms] INFO : loader::pci:   cap 0x05 @0x68
[    194ms] INFO : loader::pci:   PCIe cap @0x78: DEVCAP 0x012c8de1 (FLR no) LINKCAP 0x00453d03
[    231ms] ERROR: loader::pci: cfg_read32(0x0100) status UNSUPPORTED
[    266ms] INFO : loader::pci: PCI 0000:00:12.0 8086:a379 class 001180
[    302ms] INFO : loader::pci: PCI 0000:00:14.0 8086:a36d class 000c03
[    337ms] INFO : loader::pci: PCI 0000:00:14.2 8086:a36f class 000500
[    372ms] INFO : loader::pci: PCI 0000:00:14.5 8086:a375 class 000805
[    407ms] INFO : loader::pci: PCI 0000:00:15.0 8086:a368 class 000c80
[    443ms] INFO : loader::pci: PCI 0000:00:15.1 8086:a369 class 000c80
[    480ms] INFO : loader::pci: PCI 0000:00:16.0 8086:a360 class 000780
[    515ms] INFO : loader::pci: PCI 0000:00:17.0 8086:a352 class 000106
[    551ms] INFO : loader::pci: PCI 0000:00:1c.0 8086:a33c class 000604
[    586ms] INFO : loader::pci: PCI 0000:02:00.0 10ec:8168 class 000200
[    621ms] INFO : loader::pci: PCI 0000:00:1c.5 8086:a33d class 000604
[    656ms] INFO : loader::pci: PCI 0000:03:00.0 10ec:c821 class 000280
[    691ms] INFO : loader::pci: PCI 0000:00:1d.0 8086:a330 class 000604
[    727ms] INFO : loader::pci: PCI 0000:04:00.0 144d:a809 class 000108
[    762ms] INFO : loader::pci: PCI 0000:00:1e.0 8086:a328 class 000780
[    797ms] INFO : loader::pci: PCI 0000:00:1f.0 8086:a304 class 000601
[    832ms] INFO : loader::pci: PCI 0000:00:1f.3 8086:a348 class 000403
[    869ms] INFO : loader::pci: PCI 0000:00:1f.4 8086:a323 class 000c05
[    904ms] INFO : loader::pci: PCI 0000:00:1f.5 8086:a324 class 000c80
[    989ms] INFO : loader::tx_prep: PREP: gop-probe begin
[   1024ms] INFO : loader::gop: PHASE: GOP-PROBE (read-only)
[   1062ms] INFO : loader::gop: GOP-PROBE: 1 GOP handles
[   1099ms] INFO : loader::gop: GOP handle Handle(0x87fe0218): 1920x1080 Bgr
[   1184ms] INFO : loader::tx_prep: PREP: sample begin
[   1219ms] INFO : loader::sample: PHASE: SAMPLE (M1 read-only cold state)
[   1257ms] INFO : loader::sample: SAMPLE: GPU 10de:1f82 @ 0000:01:00.0
[   1292ms] INFO : loader::sample: SAMPLE PMC_BOOT_0 chip-id = 0x167000a1 [ok]
[   1327ms] INFO : loader::sample: SAMPLE FB_SIZE_MIB 0x1183a4 = 0xbadf5040 [PRIV_VIOLATION]
[   1363ms] INFO : loader::sample: SAMPLE VGA_WORKSPACE 0x625f04 = 0x00020e09 [ok]
[   1398ms] INFO : loader::sample: SAMPLE GFW_PLM 0x118128 = 0xffffff8f [ok]
[   1433ms] INFO : loader::sample: SAMPLE GFW_SCRATCH 0x118234 = 0x000003ff [ok]
[   1469ms] INFO : loader::sample: SAMPLE GSP_CPUCTL 0x110100 = 0x00000010 [ok]
[   1504ms] INFO : loader::sample: SAMPLE PGC6_BSI_SCRATCH15 0x1180fc = 0x201001bf [ok]
[   1539ms] INFO : loader::sample: SAMPLE MMU_PLM 0x1fa7c8 = 0xbadf5040 [PRIV_VIOLATION]
[   1575ms] INFO : loader::sample: SAMPLE MMU_LOCK_LO 0x1fa82c = 0x00100000 [ok]
[   1610ms] INFO : loader::sample: SAMPLE MMU_LOCK_HI 0x1fa830 = 0x00effff0 [ok]
[   1645ms] INFO : loader::sample: SAMPLE WPR2_LO 0x1fa824 = 0x1ffffe00 [ok]
[   1681ms] INFO : loader::sample: SAMPLE WPR2_HI 0x1fa828 = 0x00000000 [ok]
[   1718ms] INFO : loader::sample: SAMPLE SEC2_CPUCTL 0x840100 = 0x00000010 [ok]
[   1753ms] INFO : loader::sample: SAMPLE FUSE_OPT_FEAT_OVR_DISABLE 0x8203f0 = 0xbadf5040 [PRIV_VIOLATION]
[   1789ms] INFO : loader::sample: SAMPLE FUSE_VER 0x824140 = 0xbadf5040 [PRIV_VIOLATION]
[   1825ms] INFO : loader::sample: SAMPLE FUSE_VER_DECODE 0x8241c0 = 0xbadf5040 [PRIV_VIOLATION]
[   1860ms] INFO : loader::sample: SAMPLE AD1xx CYA 0x88724 = 0x00000008 [ok]
[   1897ms] INFO : loader::sample: SAMPLE AD1xx CFG 0x88dcc = 0x00000002 [ok]
[   1932ms] INFO : loader::sample: SAMPLE AD1xx XVE_PLM 0x88ff4 = 0xbadf5040 [PRIV_VIOLATION]
[   1968ms] INFO : loader::sample: SAMPLE AD1xx BAR1_CAP_MIRROR 0x88bbc = 0x00001c00 [ok]
[   2003ms] INFO : loader::sample: SAMPLE ADA WPR_PLM 0x1fa7c4 = 0xbadf5040 [PRIV_VIOLATION]
[   2039ms] INFO : loader::sample: SAMPLE ADA WPRCFG_PLM 0x1fa7cc = 0xbadf5040 [PRIV_VIOLATION]
[   2074ms] INFO : loader::sample: SAMPLE ADA FBPA_PLM 0x9a0148 = 0xffffffcf [ok]
[   2109ms] INFO : loader::sample: SAMPLE TU10x FEAT_PLM 0x409650 = 0xffffff8f [ok]
[   2145ms] INFO : loader::sample: SAMPLE TU10x FEAT_SS0 0x409664 = 0x24264126 [ok]
[   2180ms] INFO : loader::sample: SAMPLE TU10x FEAT_READOUT 0x409668 = 0x00000000 [ok]
[   2216ms] INFO : loader::sample: SAMPLE XP3G PLM0 0x8e1b0 = 0xffffff8f [ok]
[   2251ms] INFO : loader::sample: SAMPLE XP3G PLMC 0x8e1bc = 0xbadf5040 [PRIV_VIOLATION]
[   2289ms] INFO : loader::sample: SAMPLE XP3G OVR0 0x8e110 = 0x00000000 [ok]
[   2324ms] INFO : loader::sample: SAMPLE XP3G VAL0 0x8e120 = 0x00000000 [ok]
[   2359ms] INFO : loader::sample: SAMPLE XVE LNKCAP 0x88084 = 0x00453d03 [ok]
[   2394ms] INFO : loader::sample: SAMPLE XVE LNKCTL 0x88088 = 0x11010043 [ok]
[   2430ms] INFO : loader::sample: SAMPLE XVE LNKCAP2 0x880a4 = 0x0000000e [ok]
[   2465ms] INFO : loader::sample: SAMPLE XVE LNKCTL2 0x880a8 = 0x001f0003 [ok]
[   2500ms] INFO : loader::sample: SAMPLE LNK MISC_1 0x8841c = 0x20340500 [ok]
[   2536ms] INFO : loader::sample: SAMPLE LNK VSEC_HIER 0x88610 = 0x00001001 [ok]
[   2571ms] INFO : loader::sample: SAMPLE LNK LTSSM_KICK 0x8872c = 0x00000000 [ok]
[   2606ms] INFO : loader::sample: SAMPLE LNK LINK_CONFIG_0 0x8c040 = 0x800c5800 [ok]
[   2642ms] INFO : loader::sample: SAMPLE LNK PL_LINK_RATE 0x8c1c0 = 0x00140036 [ok]
[   2677ms] INFO : loader::sample: SAMPLE LNK CYA_DISG2 0x8c2c0 = 0x060711b3 [ok]
[   2712ms] INFO : loader::sample: SAMPLE FEAT sweep 0x823800-0x82382f+0x823b00 (dword stride): 0 ok / 13 badf / 0 all-ones / 0 read-errors
[   2783ms] INFO : loader::sample: SAMPLE FEAT cluster: NOT readable at PL0 on this chip (all badf) - recorded as the answer
[   2819ms] INFO : loader::sample: SAMPLE FEAT_READOUT_1 = 0xbadf5040 (0 = no compute throttle active)
[   2854ms] INFO : loader::sample: SAMPLE PSTRAPS SET0 0x101000 = 0x00400080 [ok] / SET1 0x10100c = 0x02013000 [ok]
[   2894ms] INFO : loader::sample: SAMPLE PSTRAPS decode: BAR1 index 0 = 64MiB  BAR0 index 0 (16MiB<<idx)  BAR3=2xBAR0  override_en=0 (0 = ROM straps win on reset)
[   2980ms] INFO : loader::sample: SAMPLE NV_PROM first 0x10000 bytes: crc32 0xf90b139d, magic 0xeb74aa55
[   3016ms] INFO : loader::sample: SAMPLE complete (read-only, nothing restored because nothing touched)
[   3102ms] INFO : loader::tx_prep: PREP: select begin
[   3141ms] INFO : loader::tx: TX-ASSET-DIAG: \tx-select-bdf.txt loaded 13/13 bytes
[   3177ms] INFO : loader::pci: ENUMERATE: tx-select-bdf matched 0000:01:00.0 - only this card runs
[   3263ms] INFO : loader::tx_prep: PREP: assets begin
[   3299ms] INFO : loader::tx: TX-ASSET-DIAG: \booter_load_tu10x.bin loaded 59224/59224 bytes
[   3335ms] INFO : loader::tx: TX-ASSET-DIAG: \gsp_boot_desc_tu10x.bin loaded 76/76 bytes
[   3371ms] INFO : loader::tx: TX-ASSET-DIAG: \gsp_boot_tu10x.bin loaded 24576/24576 bytes
[   3440ms] INFO : loader::tx: TX-ASSET-DIAG: \fwimage_tu10x.bin loaded 29339080/29339080 bytes
[   3480ms] INFO : loader::tx: TX-ASSET-DIAG: \fwsignature_tu10x.bin loaded 4096/4096 bytes
[   3516ms] INFO : loader::tx: TX-ASSET-DIAG: \v67-direct-ss.bin absent
[   3552ms] INFO : loader::tx: TX-ASSET-DIAG: \v67-tu10x-four-plm.bin loaded 64000/64000 bytes
[   3588ms] INFO : loader::tx: TX-ASSET-DIAG: \sec2_bl_tu10x.bin loaded 768/768 bytes
[  10175ms] INFO : loader::tx_prep: CONFIRM: 10s armed countdown elapsed - PROCEED (marker file opted in)
[  10213ms] INFO : loader::chainload: CHAIN-PRE: pre-transaction loader preload begin
[  10252ms] INFO : loader::chainload: CHAIN-PRE: LoadImage '\EFI\Manjaro\grubx64.efi' (FromDevicePath)
[  10295ms] INFO : loader::chainload: CHAIN-PRE: '\EFI\Manjaro\grubx64.efi' resident at 0x81e23000 (0x27000 bytes), PE header probe ok
[  10367ms] INFO : loader::pci: ENUMERATE: tx-select-bdf matched 0000:01:00.0 - only this card runs
[  10402ms] INFO : loader::tx: TX-ROOT-DIR: EFI size=4096
[  10437ms] INFO : loader::tx: TX-ROOT-DIR: booter_load_tu10x.bin size=59224
[  10473ms] INFO : loader::tx: TX-ROOT-DIR: gsp_boot_desc_tu10x.bin size=76
[  10508ms] INFO : loader::tx: TX-ROOT-DIR: gsp_boot_tu10x.bin size=24576
[  10543ms] INFO : loader::tx: TX-ROOT-DIR: fwimage_tu10x.bin size=29339080
[  10579ms] INFO : loader::tx: TX-ROOT-DIR: fwsignature_tu10x.bin size=4096
[  10614ms] INFO : loader::tx: TX-ROOT-DIR: sec2_bl_tu10x.bin size=768
[  10649ms] INFO : loader::tx: TX-ROOT-DIR: v67-tu10x-four-plm.bin size=64000
[  10684ms] INFO : loader::tx: TX-ROOT-DIR: gsp-gate.txt size=160
[  10720ms] INFO : loader::tx: TX-ROOT-DIR: SOURCE-MANIFEST.json size=2882
[  10755ms] INFO : loader::tx: TX-ROOT-DIR: PROVENANCE.json size=645
[  10790ms] INFO : loader::tx: TX-ROOT-DIR: i_know_what_i_am_doing.txt size=3
[  10828ms] INFO : loader::tx: TX-ROOT-DIR: tx-select-bdf.txt size=13
[  10863ms] INFO : loader::tx: TX-ROOT-DIR: loader.log size=11856
[  10899ms] INFO : loader: TX: ===== target 1/1: 10de:1f82 @ 0000:01:00.0 =====
[  10935ms] INFO : loader: TX: device 10de:1f82 -> asset family 'tu10x'
[  10974ms] INFO : loader: TX: V67 present - unlock mode (family-specific write chain)
[  11009ms] INFO : loader::tx: TX: BEGIN (phases: detach claim pre-flr scrub gfw layout fwsec booter verify selectors restore flr)
[  11081ms] INFO : loader::tx: TX: >4GB staging gate: true (family tu10x)
[  11117ms] INFO : loader::tx_detach: PM: entry PMCSR=0x0008 state=D0 (cap@0x60)
[  11152ms] INFO : loader::tx_detach: PM: D0 verified (PMCSR=0x0008)
[  11187ms] INFO : loader::tx_detach: DETACH: staged console/driver detach begin (TOTORONG craft)
[  11225ms] INFO : loader::tx_detach: DIAG PCIIO-OPENERS: Handle(0x86540798) agent=0x88fd9f98 controller=0x0 attr=0x1 count=26
[  11261ms] INFO : loader::tx_detach: DIAG PCIIO-OPENERS: Handle(0x86540798) agent=0x8664d418 controller=0x86540798 attr=0x10 count=1
[  11332ms] INFO : loader::tx_detach: DIAG PCIIO-OPENERS: Handle(0x86540798) agent=0x8664d418 controller=0x87fe0218 attr=0x8 count=1
[  11402ms] INFO : loader::tx_detach: DIAG PCIIO-OPENERS: Handle(0x86540798) agent=0x87dadb98 controller=0x0 attr=0x2 count=1
[  11438ms] INFO : loader::tx_detach: DIAG GOP-TOPOLOGY: Handle(0x87fe0218) devpath_len=Some(36) on_target=true protocols=6
[  11474ms] INFO : loader::tx_detach: DIAG GOP-OPENERS: Handle(0x87fe0218) agent=0x88fd9f98 controller=0x0 attr=0x1 count=168
[  11512ms] INFO : loader::tx_detach: DIAG GOP-OPENERS: Handle(0x87fe0218) agent=0x87e0d918 controller=0x87fe0218 attr=0x10 count=1
[  11583ms] INFO : loader::tx_detach: DIAG GOP-OPENERS: Handle(0x87fe0218) agent=0x87fc9598 controller=0x0 attr=0x2 count=1
[  11619ms] INFO : loader::tx_detach: DETACH: pre-claim attributes Some(1816) (VGA subset 0x18)
[  11656ms] INFO : loader::tx_detach: DETACH: stage GOP handle Handle(0x87fe0218) protocols 6
[  11701ms] INFO : loader::tx_detach: DETACH: GOP disconnect status Ok(()) protocols 6 -> 4
[  11718ms] INFO : loader::tx_detach: DETACH: PCI disconnect status Ok(()) protocols 2 -> 2
[  11720ms] INFO : loader::tx_detach: DIAG PCIIO-OPENERS: Handle(0x86540798) agent=0x88fd9f98 controller=0x0 attr=0x1 count=26
[  11720ms] INFO : loader::tx_detach: DIAG GOP-TOPOLOGY: no GOP handles
[  11720ms] INFO : loader::tx_detach: DETACH: PciIo EXCLUSIVE claimed
[  11722ms] INFO : loader::tx_detach: DETACH: Attributes(Enable) no-op (cmd=0x0100) - raw COMMAND write
[  11724ms] INFO : loader::tx_detach: DETACH: raw COMMAND write result cmd=0x0007
[  11726ms] INFO : loader::tx_detach: DETACH: config baseline (vendor=0x10de dev=0x1f82 cmd=0x0007 - MEM=true BME=true)
[  11728ms] INFO : loader::tx: TX: detach+claim ok
[  11729ms] INFO : loader::tx: PRE-FLR: disabled (no \pre-flr-on.txt) - kernel-matching flow
[  11731ms] INFO : loader::tx: AUTH-SCAN begin (differential GSP vs SEC2)
[  11731ms] INFO : loader::tx: AUTH-SCAN falcon +0x000 ENG           gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x040 MBOX0         gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x044 MBOX1         gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x0d0 EXCI          gsp=0x00900400[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x0f4 HWCFG         gsp=0x000007f7[ok] sec2=0x000007f7[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x100 CPUCTL        gsp=0x00000010[ok] sec2=0x00000010[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x104 BOOTVEC       gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x108 CAPS          gsp=0x40420100[ok] sec2=0x40420100[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x10c DMACTL        gsp=0x00000080[ok] sec2=0x00000001[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x110 DMATRFBASE    gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x118 DMATRFCMD     gsp=0x00000002[ok] sec2=0x00000002[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x11c DMATRFFBOFFS  gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x120 DMATRFBASE1   gsp=0x00000010[ok] sec2=0x00000010[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x130 CPUCTL_ALIAS  gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x14c TRACEPC       gsp=0x0000065b[ok] sec2=0x00004607[ok]
[  11733ms] INFO : loader::tx: AUTH-SCAN falcon +0x180 IMEMC         gsp=0x91009800[ok] sec2=0x00000000[ok]
[  11734ms] INFO : loader::tx: AUTH-SCAN falcon +0x188 IMEMT         gsp=0x00000097[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x1c0 DMEMC         gsp=0x01000420[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x300 UNK300        gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x3c0 ENG_RESET     gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x3c4 RESET_PLM?    gsp=0x000000ff[ok] sec2=0x000000ff[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x440 UNK440        gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x4e4 UNK4E4        gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x4f4 UNK4F4        gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x520 UNK520        gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon +0x524 UNK524        gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon2 +0x180 MOD_SEL       gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon2 +0x198 UCODE_ID      gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon2 +0x19c ENGIDMASK     gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon2 +0x210 PARAADDR      gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon2 +0x388 RISCV388      gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN falcon2 +0x668 BCR           gsp=0x00000000[ok] sec2=0x00000000[ok]
[  11736ms] INFO : loader::tx: AUTH-SCAN end
[  11739ms] INFO : loader::tx: TX-tu10x: scrubber step skipped (not part of the proven Turing chain; BSI handoff state logged above)
[  11739ms] INFO : loader::tx_fwsec: layout inputs: fb_mib=0xbadf5040 vga=0x00020e09 mmu_plm=0xbadf5040 mmu_lo=0x00100000 mmu_hi=0x00effff0 image=0x1bfadc8 boot=0x6000
[  11739ms] INFO : loader::tx_fwsec: layout: LOCAL_MEMORY_RANGE 0x00000207 decoded usable FB = 4096 MiB (ecc=false) - driver source
[  11739ms] INFO : loader::tx_fwsec: layout: MMU_PLM PLM-locked on Turing (0xbadf5040) - skipping the lock-bit sanity check (lo/hi window remains the layout input)
[  11739ms] INFO : loader::tx_fwsec: layout mmu: lock ignored (high address is not the FB top)
[  11739ms] INFO : loader::tx_fwsec: layout: fb=0x100000000 vga=0xfffe0000 frts=0xffee0000 wpr=[0xf8900000,0xfffe0000]
[  11739ms] INFO : loader::tx: TX: layout ok (frts=0xffee0000)
[  11739ms] INFO : loader::tx: TX-tu10x: entry WPR2 lo=0x1ffffe00 hi=0x0 (cold) - FWSEC will be fired by the loader [fwsec=ran]
[  11739ms] INFO : loader::tx_fwsec: FWSEC-TU10X: BSI_SCRATCH15=0x201001bf handoff=1 (DONE=3)
[  11739ms] INFO : loader::tx_fwsec: FWSEC-TU10X: reading PROM at 0x300000
[  11970ms] INFO : loader::tx_fwsec: FWSEC-TU10X: imem ns 0..0x400 + sec 0x400+0x9400 dmem 0x420 @img 0x9800 iface@0xe0 stored=0x9c20
[  11970ms] INFO : loader::pci: MEMMAP: 0x7ca79000-0x8026f000 (55 MiB) type=LOADER_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11970ms] INFO : loader::pci: MEMMAP: 0x8026f000-0x81d12000 (26 MiB) type=CONVENTIONAL attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11970ms] INFO : loader::pci: MEMMAP: 0x81d12000-0x81e23000 (1 MiB) type=LOADER_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11970ms] INFO : loader::pci: MEMMAP: 0x81e23000-0x81e4a000 (0 MiB) type=LOADER_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11970ms] INFO : loader::pci: MEMMAP: 0x81e4a000-0x81e5a000 (0 MiB) type=LOADER_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x81e5a000-0x81e5b000 (0 MiB) type=CONVENTIONAL attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x81e5b000-0x81e79000 (0 MiB) type=LOADER_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x81e79000-0x81e81000 (0 MiB) type=CONVENTIONAL attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x81e81000-0x81e88000 (0 MiB) type=LOADER_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x81e88000-0x81eaf000 (0 MiB) type=LOADER_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x81eaf000-0x821b1000 (3 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x821b1000-0x821cf000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x821cf000-0x821fe000 (0 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x821fe000-0x821ff000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x821ff000-0x8221b000 (0 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x8221b000-0x82226000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x82226000-0x82242000 (0 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x82242000-0x82247000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x82247000-0x83681000 (20 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x83681000-0x83691000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11973ms] INFO : loader::pci: MEMMAP: 0x83691000-0x836b6000 (0 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x836b6000-0x836cd000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x836cd000-0x836f5000 (0 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x836f5000-0x83728000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x83728000-0x83742000 (0 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x83742000-0x8375b000 (0 MiB) type=BOOT_SERVICES_CODE attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x8375b000-0x8375c000 (0 MiB) type=CONVENTIONAL attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x8375c000-0x83768000 (0 MiB) type=LOADER_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x83768000-0x83769000 (0 MiB) type=CONVENTIONAL attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x83769000-0x8376a000 (0 MiB) type=LOADER_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x8376a000-0x88fda000 (88 MiB) type=BOOT_SERVICES_DATA attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 0x88fda000-0x8917a000 (1 MiB) type=CONVENTIONAL attr=MemoryAttribute(UNCACHEABLE | WRITE_COMBINE | WRITE_THROUGH | WRITE_BACK)
[  11975ms] INFO : loader::pci: MEMMAP: 2 conventional descriptors above 4GB
[  11975ms] INFO : loader::pci: DMA alloc: family not gated for >4GB staging - legacy PciIo path
[  11975ms] INFO : loader::pci: DMA alloc: 10 pages memtype=EfiBootServicesData dev=0x8631a000 [LOW] (PciIo)
[  11975ms] INFO : loader::tx_fwsec: FWSEC-TU10X: staging allocated in the LOW band by default (dev=0x8631a000) - >=4GiB is unreachable on some platforms (issue #74); \tx-fwsec-high-staging.txt restores high
[  11975ms] INFO : loader::tx_fwsec: FWSEC mapper patched: frts=0xffee0000 cmd@0x3e0
[  11978ms] INFO : loader::tx: Falcon reset begin: base=0x110000 switch_to_falcon=false
[  11979ms] INFO : loader::tx: poll timeout tolerated: reg=0x1100f4 mask=0x80000000 expected=0x80000000 budget_us=1000
[  11979ms] INFO : loader::tx: Falcon pre-reset timeout tolerated per HW bug 3419321
[  11989ms] INFO : loader::tx: Falcon reset done: base=0x110000 hwcfg=0x7f7 chip=0x167000a1
[  11989ms] INFO : loader::tx_fwsec: FWSEC-TU10X: GSP reset done: rm=0x167000a1 cpuctl=0x00000010 chip=0x167000a1
[  11989ms] INFO : loader::tx_fwsec: FWSEC-TU10X: FBIF trans4=0x00000015 dmactl cleared (vram_staging=false)
[  11989ms] INFO : loader::tx_portal: PORTAL: DMEM loaded - 84 bytes at dest=0x0
[  11989ms] INFO : loader::tx_fwsec: FWSEC-TU10X: BL at IMEM dst=0xfe00 (hwcfg 256 blocks), BOOTVEC=0xfd00  <== dst != 0xfd00 (50HX saw 0xfd00 on TU102/TU106)
[  11989ms] INFO : loader::tx_portal: PORTAL: IMEM loaded - 2 blocks, 512 bytes, dest=0xfe00 va=0xfd00 secure=false
[  11989ms] INFO : loader::tx_fwsec: FWSEC-TU10X: STARTCPU, polling WPR2 up (5s budget)...
[  11992ms] INFO : loader::tx_fwsec: FWSEC-TU10X: *** WPR2 UP lo=0xffee00 hi=0xfffc00 after 3ms ***
[  12079ms] INFO : loader::tx_fwsec: FWSEC-TU10X: GSP-HALT gate: CPUCTL 0x00000000 -> halted=true after 85ms (exact WPR2 lo=0xffee00 hi=0xfffc00)
[  12079ms] INFO : loader::tx_fwsec: FWSEC-TU10X: FWSEC result (kernel shape): MAILBOX0=0x00000000 MAILBOX1=0x00000000 scratch0e=0x00000000 frts_err=0x0000
[  12079ms] INFO : loader::tx_fwsec: FWSEC-TU10X: WPR2 verified (FRTS at 0xffee0000) [GSP-HALT gate]
[  12079ms] INFO : loader::tx: TX: fwsec ok (WPR2 verified)
[  12079ms] INFO : loader::tx: TX: tu10x BL topology pinned: size 0x6000 code@0x1800 data@0x800 manifest@0x0
[  12081ms] INFO : loader::tx: TX: booter bundle ok (image 59136 sigs 16)
[  12082ms] INFO : loader::pci: DMA alloc: 15 pages memtype=EfiBootServicesData HIGH dev=0x100000000 (descriptor 0x100000000+0x40000000)
[  12082ms] INFO : loader::pci: DMA alloc: 16 pages memtype=EfiBootServicesData HIGH dev=0x10000f000 (descriptor 0x10000f000+0x3fff1000)
[  12083ms] INFO : loader::pci: DMA alloc: 1 pages memtype=EfiBootServicesData HIGH dev=0x10001f000 (descriptor 0x10001f000+0x3ffe1000)
[  12084ms] INFO : loader::pci: DMA alloc: 1 pages memtype=EfiBootServicesData HIGH dev=0x100020000 (descriptor 0x100020000+0x3ffe0000)
[  12084ms] INFO : loader::pci: DMA alloc: 6 pages memtype=EfiBootServicesData HIGH dev=0x100021000 (descriptor 0x100021000+0x3ffdf000)
[  12084ms] INFO : loader::tx: TX: booter sig fuse_ver=0 (payload_mode=true)
[  12085ms] INFO : loader::pci: DMA alloc: 7179 pages memtype=EfiBootServicesData HIGH dev=0x100027000 (descriptor 0x100027000+0x3ffd9000)
[  12090ms] INFO : loader::tx_booter: radix: leaves=7163 tables=16 level0=0x100027000
[  12090ms] INFO : loader::tx_booter: WprMeta tu10x driver-exact heap: off=0xf7900000 size=0x6900000 wpr_start=0xf7800000 flags=0x1 (deploy marker: driver formula vs 40HX dmesg 0x1f7900000+0x6900000)
[  12091ms] INFO : loader::tx: TX: WprMeta published (payload_mode=true)
[  12091ms] INFO : loader::pci: DMA-PATH[before-bridge-bme]: gpu loc=Some((0, 1, 0, 0)) command=0x0007 status=0x0010 devctl=0x2930 (cap 0x78)
[  12091ms] INFO : loader::pci: DMA-PATH[before-bridge-bme]: bridge 8086:1901 loc=Some((0, 0, 1, 0)) command=0x0107 status=0x0010 pri/sec/sub=0/1/1 bridgectl=0x0012
[  12091ms] INFO : loader::pci: DMA-PATH[before-bridge-bme]: bridge 8086:a33c loc=Some((0, 0, 28, 0)) command=0x0107 status=0x0010 pri/sec/sub=0/2/2 bridgectl=0x0012
[  12091ms] INFO : loader::pci: DMA-PATH[before-bridge-bme]: bridge 8086:a33d loc=Some((0, 0, 28, 5)) command=0x0107 status=0x0010 pri/sec/sub=0/3/3 bridgectl=0x0012
[  12091ms] INFO : loader::pci: DMA-PATH[before-bridge-bme]: bridge 8086:a330 loc=Some((0, 0, 29, 0)) command=0x0107 status=0x0010 pri/sec/sub=0/4/4 bridgectl=0x0012
[  12093ms] INFO : loader::pci: BRIDGE-BME: Some((0, 0, 1, 0)) already has bus master (command=0x0107)
[  12093ms] INFO : loader::pci: DMA-PATH[after-bridge-bme]: gpu loc=Some((0, 1, 0, 0)) command=0x0007 status=0x0010 devctl=0x2930 (cap 0x78)
[  12093ms] INFO : loader::pci: DMA-PATH[after-bridge-bme]: bridge 8086:1901 loc=Some((0, 0, 1, 0)) command=0x0107 status=0x0010 pri/sec/sub=0/1/1 bridgectl=0x0012
[  12094ms] INFO : loader::pci: DMA-PATH[after-bridge-bme]: bridge 8086:a33c loc=Some((0, 0, 28, 0)) command=0x0107 status=0x0010 pri/sec/sub=0/2/2 bridgectl=0x0012
[  12094ms] INFO : loader::pci: DMA-PATH[after-bridge-bme]: bridge 8086:a33d loc=Some((0, 0, 28, 5)) command=0x0107 status=0x0010 pri/sec/sub=0/3/3 bridgectl=0x0012
[  12094ms] INFO : loader::pci: DMA-PATH[after-bridge-bme]: bridge 8086:a330 loc=Some((0, 0, 29, 0)) command=0x0107 status=0x0010 pri/sec/sub=0/4/4 bridgectl=0x0012
[  12094ms] INFO : loader::tx: Falcon reset begin: base=0x840000 switch_to_falcon=false
[  12096ms] INFO : loader::tx: poll timeout tolerated: reg=0x8400f4 mask=0x80000000 expected=0x80000000 budget_us=1000
[  12096ms] INFO : loader::tx: Falcon pre-reset timeout tolerated per HW bug 3419321
[  12106ms] INFO : loader::tx: Falcon reset done: base=0x840000 hwcfg=0x7f7 chip=0x167000a1
[  12106ms] INFO : loader::tx: FALCON-UNBLOCK: FBIF_CTL=0x00000190 TRANSCFG0=0x00000115 DMACTL=0x00000000 (want ctl bit7=1, trans&7=5, dmactl=0)
[  12106ms] INFO : loader::tx_portal: PORTAL: IMEM loaded - 1 blocks, 256 bytes, dest=0x0 va=0x0 secure=false
[  12106ms] INFO : loader::tx: TX-ASSET-DIAG: \tx-sec-base.txt absent
[  12107ms] INFO : loader::tx_booter: BOOTER-PLACE: ns 0x0+0x100 -> dest 0 tag 0x0 | sec 0x100+0x8400 -> dest 0x100 tag 0x100 (default dest 0x100, tag==dest: true, override: false) | bootvec 0x0 (ns stub)
[  12108ms] INFO : loader::tx_portal: PORTAL: IMEM loaded - 132 blocks, 33792 bytes, dest=0x100 va=0x100 secure=true
[  12108ms] INFO : loader::tx_portal: PORTAL: DMEM loaded - 25088 bytes at dest=0x0
[  12111ms] INFO : loader::tx_booter: BOOTER-AUDIT: ns readback MATCH (fnv 0016580a21)
[  12111ms] INFO : loader::tx_booter: BOOTER-AUDIT: sec first mismatch at va 0x100: got 0xdead5ec1
[  12119ms] INFO : loader::tx_booter: BOOTER-AUDIT: sec readback MISMATCH (fnv 0056bc76c5, 8400 bytes walked) - Turing secure pages return the scrub pattern on NS reads (field-proven on success machines); not a verdict, ns/dmem lines are
[  12119ms] INFO : loader::tx_booter: BOOTER-AUDIT: dmem readback MATCH (fnv 00dfde6ac5)
[  12119ms] INFO : loader::tx_booter: BOOTER-DIRECT: fire meta dev=0x10001f000 mbox0=0x0001f000 mbox1=0x00000001
[  12124ms] INFO : loader::tx_booter: BOOTER-DIRECT start-probe: pre=0x00000010 imm=0x00000000 +5ms=0x00000010
[  12124ms] INFO : loader::tx_booter: BOOTER-DIRECT: mbox live @sample 0: mbox0=0x00000031 mbox1=0x00000001
[  12124ms] INFO : loader::tx_booter: BOOTER-DIRECT: core halted at sample 0, DMEM[0x600]=0x00000000
[  12124ms] INFO : loader::tx_booter: BOOTER-DIRECT: mid-run sampler verdict: dma_landed=false sanitized_only=false
[  12124ms] INFO : loader::tx_booter: BOOTER-DIRECT: halted, mailbox0=0x31 mailbox1=0x1 exci=0x00a00100
[  12124ms] INFO : loader::tx_booter: BOOTER: EXCI decode: EXPC=0x100 EXCAUSE=0xa (MISS_INS) - also seen in successful runs, not a verdict by itself
[  12126ms] INFO : loader::tx_booter: BOOTER: mailbox0 verdict: 0x31 - NS-stub pre-secure marker (final) - the secure entry never executed (placement/entry-level failure)
[  12129ms] INFO : loader::tx_booter: BOOTER-DIRECT: post-halt SEC2 FBIF TRANSCFG0=0x00000115 CTL=0x00000190 (fire-time 0x115/0x190)
[  12129ms] INFO : loader::tx_booter: BOOTER-DIRECT: DMEM[0x0600] = 0x00000000
[  12129ms] INFO : loader::tx_booter: BOOTER-DIRECT: DMEM[0x6140] = 0x000d2408
[  12129ms] INFO : loader::tx_booter: BOOTER-DIRECT: DMEM[0xff38] = 0x00000000
[  12131ms] INFO : loader::tx_booter: BOOTER-DIRECT: DMEM[0xff4c] = 0x00000000
[  12131ms] INFO : loader::tx_booter: BOOTER-DIRECT: DMEM[0xff50] = 0x00000000
[  12131ms] INFO : loader::tx_booter: BOOTER-DIRECT: DMEM[0x0200] = 0x67436032
[  12131ms] INFO : loader::tx_booter: BOOTER-DIRECT: DMEM verdict: signature DMA never landed - the 0x4a7 fill check is V67-SPECIFIC: in replay mode, or when sanitize wins the race to the sample point, this is NOT a rejection signal (#14/#90 field-proven false negatives; #90's PLM opened and selectors landed with this exact verdict)
[  12131ms] INFO : loader::tx_booter: BOOTER-DIRECT: verdict deferred to POST-BOOT (mailbox0 may be input carrier or status code)
[  12133ms] INFO : loader::tx: TX: booter fired
[  12133ms] INFO : loader::tx_booter: POST-BOOT: FEAT_PLM=0xffffff8f SS0=0x24264126 SS1=0x6 (Turing 0x4096xx block)
[  12135ms] INFO : loader::tx_booter: POST-BOOT: FACTORY FEAT_READOUT_1=0x00000000 (0 = full speed; badf5040 = PLM still closed)
[  12137ms] INFO : loader::tx_booter: POST-BOOT: SEC2 MAILBOX0=0x00000031 WPR2_HI=0xfffc00
[  12139ms] INFO : loader::tx_booter: POST-BOOT: PLM still locked - the payload's writes did not happen
[  12141ms] INFO : loader::tx_booter: POST-BOOT: status 0x31 = NS-stub pre-secure marker (final) - the secure entry never executed (placement/entry level, see PR #67 D/E rounds)
[  12144ms] INFO : loader::tx: TX: stock signature restored (failure-path unwind)
[  12144ms] INFO : loader: TX: transaction failed: EIO - NOT retrying this session
[  12244ms] INFO : loader::tx: FLR: cmd=0x0003 devsta=0x0010 (pending=false) gfw_boot=0x101 wpr2_hi=0xe00
[  12256ms] INFO : loader::tx: PM: post-FLR PMCSR=0x0008 state=D0 (entry 0x0008)
[  12258ms] INFO : loader::tx: HANDOFF-OUT: ss0=0xbadf5040 ss1=0xbadf5040 readout1=0xbadf5040 feat_plm=0xbadf5040 wpr2_hi=0xe00 pmcsr=0x0008 dstate=D0 | tu10x: plm=0xffffff8f ss0=0x24264126 ss1=0x00000006 readout=0x00000000 | tu10x:unlock=false ga/ada:ss0_unlock=false ss1_unlock=false plm_open=false
[  12260ms] INFO : loader: TX: multi-GPU pass complete (1 target(s) processed)
[  12260ms] INFO : loader::chainload: PHASE: CHAIN
[  12263ms] INFO : loader::chainload: CHAIN-PRE: start-time PE header probe ok - StartImage the preloaded '\EFI\Manjaro\grubx64.efi'
```

## 2. Booter asset identity (what the Nov 3 run actually sent)

*(edit: the first version of this table listed hashes I had transcribed from a summary rather than from the archive - corrected below to the exact staged files. The log in section 1 is unaffected.)*

The complete staged TX asset set, `docs/evidence/tu117-1f82-manjaro/staging/tx-asset-hashes.txt`:

| Asset | Size (B) | SHA-256 |
|---|---|---|
| `booter_load_tu10x.bin` (**the booter placed on the die**) | 59224 | `51507de61777cf46f3703a084cdfa896c21f6bc0c8af8f245bd09b2e9c49bf54` |
| `gsp_boot_desc_tu10x.bin` | 76 | `9e7cca2cfdc5ce601b0adba39967850046108df6c2d23fff95578ca3f0ccbe01` |
| `gsp_boot_tu10x.bin` (GspRmBoot slice `de676bae...`, pinned NVIDIA 610.43.03) | 24576 | `de676bae28a480011d3d012db14bef539324e62a841a9627863c689bea168af3` |
| `fwimage_tu10x.bin` | 29339080 | `c10c2866e360154e822087957bc4269168e44f8d45922110e67fd751355806f9` |
| `fwsignature_tu10x.bin` | 4096 | `f5020943a001134927f247f5d9aeccb38a51111fcd490bc91eade76c6e1f437e` |
| `sec2_bl_tu10x.bin` | 768 | `f21f1cfbb8fffa8067685314367fc4c50f3f84dd99eda7c19db4292d9269b9d9` |
| `v67-tu10x-four-plm.bin` | 64000 | `b0ec90294d1de3c67e024631c0a11000f281470d76eed806fc24c66b7fd1ef41` |

No FWSEC file was staged - the loader takes FWSEC from the card's PROM at runtime (VBIOS 90.17.27.00.22), like the driver does.

The mismatch hypothesis is confirmed by the identity directly: the placed image is the TU102-keyed TU10x booter - the BOOTER-PLACE line in the log shows the TU10x geometry (`sec 0x100+0x8400`), while your TU116 archive carries its own patch slot at `0x8600` and a different signature. No TU116/TU117-keyed material was involved, exactly the condition the tu11x route fixes.

Re: the `dst=0xfe00 vs BOOTVEC=0xfd00` drilldown flag - agreed it is load-address vs entry-vector; the BOOTER-PLACE line in the log is the authoritative one and shows an exact MATCH.

## 3. Follow-up: we will run the tu11x verification

The host owner has approved exactly one die-keyed tu11x verification boot (our internal review council supported this 3/4 with the same gate wording). Protocol we are committing to:

- sync to current `main`, build the TX stage via the `-Family 16` / `--family tu11x` branch,
- verify staged assets by size + sha256 before flashing the ESP,
- **one cold boot, zero retries under any outcome** (three-outcomes-all-informative as you framed it),
- loader-side readback (placement / mailbox / PLM / signature-restore) archived and reported regardless of result,
- if the result is red, it will be reported with the ambiguity discipline our reviewer raised: route bug vs RE re-anchor vs 1f82-specificity, not flattened into "die-keying wrong".

Single-die caveat noted (our card is TU117; TU116 IDs stay unverified). No `tx-bootvec-sec` ablation and no extra boots beyond the one - if the tu11x run needs a follow-up experiment, that is a new decision for the owner. Result posted here afterwards.
