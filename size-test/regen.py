#!/usr/bin/env python3
# Recreate the large size-test dummies from the committed 600-kb.jpg base.
# Appends zero-padding AFTER the JPEG EOI marker, so each file stays a valid,
# openable image while hitting the target byte size. Run after a fresh clone:
#   python size-test/regen.py
import os
HERE = os.path.dirname(os.path.abspath(__file__))
base = os.path.join(HERE, "600-kb.jpg")
targets = {"50mb.jpg": 50 * 1024 * 1024, "100-mb-example-jpg.jpg": 100 * 1024 * 1024}
with open(base, "rb") as f:
    seed = f.read()
for name, size in targets.items():
    out = os.path.join(HERE, name)
    if os.path.exists(out):
        print("skip (exists):", name); continue
    with open(out, "wb") as f:
        f.write(seed)
        f.write(b"\x00" * (size - len(seed)))
    print("created:", name, f"{size // (1024*1024)}MB")
