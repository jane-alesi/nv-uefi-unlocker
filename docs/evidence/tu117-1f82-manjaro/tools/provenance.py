#!/usr/bin/env python3
"""Emit the SOURCE-MANIFEST.json + PROVENANCE.json pair (schema nvuu-*/1)
for a built stick root. Linux twin of release/make-provenance.ps1 (same
field set; JSON formatting is ours, the content rows are identical).
Re-runs are idempotent: both outputs are excluded from the manifest.

Usage: provenance.py DIR [--efi-sha256 HEX] [--note TEXT]
"""
import argparse
import hashlib
import json
import os
import sys
from datetime import datetime, timezone


def sha256_of(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("dir")
    ap.add_argument("--efi-sha256", default="")
    ap.add_argument("--note", default="")
    a = ap.parse_args()

    droot = os.path.abspath(a.dir)
    if not os.path.isdir(droot):
        print(f"not a directory: {droot}", file=sys.stderr)
        return 1
    out_manifest = os.path.join(droot, "SOURCE-MANIFEST.json")
    out_prov = os.path.join(droot, "PROVENANCE.json")
    skip = {os.path.realpath(p) for p in (out_manifest, out_prov)}

    rows = []
    total = 0
    for dirpath, _dirs, files in os.walk(droot):
        for fn in files:
            full = os.path.join(dirpath, fn)
            if os.path.realpath(full) in skip:
                continue
            rel = os.path.relpath(full, droot).replace(os.sep, "/")
            size = os.path.getsize(full)
            rows.append({"path": rel, "bytes": size, "sha256": sha256_of(full)})
            total += size
    rows.sort(key=lambda r: r["path"])

    manifest = {
        "schema": "nvuu-source-manifest/1",
        "root": os.path.basename(droot),
        "file_count": len(rows),
        "files": rows,
    }
    with open(out_manifest, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")

    prov = {
        "schema": "nvuu-provenance/1",
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source_manifest": "SOURCE-MANIFEST.json",
        "source_manifest_sha256": sha256_of(out_manifest),
        "file_count": len(rows),
        "total_bytes": total,
        "field_proven_efi_sha256": a.efi_sha256.lower() or None,
        "rebuild_declaration": (
            "rebuilding this directory via release/make-usbroot.sh from the pinned "
            "public inputs must reproduce every sha256 in SOURCE-MANIFEST.json"
        ),
        "note": a.note,
    }
    with open(out_prov, "w", encoding="utf-8") as f:
        json.dump(prov, f, indent=2)
        f.write("\n")

    print(f"manifest   : {out_manifest} ({len(rows)} files, {total} bytes)")
    print(f"provenance : {out_prov} (manifest sha256 {prov['source_manifest_sha256'][:16]}...)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
