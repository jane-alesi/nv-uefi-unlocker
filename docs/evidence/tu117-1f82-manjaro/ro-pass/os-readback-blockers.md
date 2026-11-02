# In-OS register readback blockers on ja-manjaro (2026-11-02)

Target: 0000:01:00.0 TU117 GTX 1650 (10de:1f82), kernel 6.12.108-1-MANJARO,
nvidia 580.178.04 (GSP-RM running, GSP fw 580.178.04).

## 1. sysfs resource0 mmap blocked (IORESOURCE_EXCLUSIVE)

`sudo python3 tools/diag-unlock.py --bdf 0000:01:00.0` dies in Bar0.__init__:

    OSError: [Errno 22] Invalid argument  (mmap of /sys/.../resource0)

Repro: any length, root, O_RDWR:

    $ sudo python3 -c "open('/sys/.../resource0','r+b') + mmap(f.fileno(), 4096)"
    mmap: [Errno 22] Invalid argument

Kernel path (6.12 source, /usr/src/linux612): pci_mmap_resource() in
drivers/pci/pci-sysfs.c returns -EINVAL when iomem_is_exclusive(res->start);
IORESOURCE_EXCLUSIVE (0x08000000) = "Userland may not map this resource"
(include/linux/ioport.h). The GPU's BAR0 (0xa2000000-0xa2ffffff, 16M, boot-VGA
legacy window: journal "vgaarb: setting as boot VGA device") is marked
exclusive; BAR1/BAR3 on the same device and unrelated 64-bit BARs on other
devices are NOT (4K sysfs mmap verified OK on 0000:01:00.0 resource1/3 and
on 0000:00:1f.3). /dev/mem mmap of 0xa2000000 also fails with EPERM
(driver-claimed PCI MMIO region).

Consequence: the in-OS readback tool diag-unlock.py (sysfs BAR0 reader) cannot
run on this machine. Pre-write and post-write register readback is done via
the UEFI loader's read-only sampler (documented: "Build with cargo efi for
read-only sampling", FAQ #usb) + nvidia-smi (GSP/clocks/VBIOS) + loader.log.

## 2. nvidia driver unbind/rebind hang (field data point)

Probe: `echo 0000:01:00.0 > .../driver/unbind` (to test whether the exclusive
mark is driver-owned) succeeded but left the DRM teardown in a bad state:
drm_WARN_ON(!list_empty(&fb->filp_head)) in nv_drm_dev_unload
(dmesg @boot+37741s). Subsequent `.../drivers/nvidia/bind` blocks in D-state
(kernel device_attach/probe stuck; userspace echo in uninterruptible sleep,
>10 min, no completion). GPU unbound, nvidia module loaded but "No devices
were found" (nvidia-smi).

Recovery: REBOOT (per docs/faq.md recovery path). Do NOT unbind nvidia on
this box; the stuck probe blocks the driver for the rest of the session.

Both items are candidates for the upstream 10de:1f82 first-report
(docs/faq.md "reporting" + compatibility: TU117 bare-die row).
