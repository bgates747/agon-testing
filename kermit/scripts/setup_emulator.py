#!/usr/bin/env python3
"""Provision the isolated Fab Agon Emulator profile for the Kermit test."""

from __future__ import annotations

import os
from pathlib import Path

from write_zinc_cfg import write_config


ROOT = Path(__file__).resolve().parent.parent
AGON_ROOT = Path.home() / "Agon"
FAB_ROOT = AGON_ROOT / "fab-agon-emulator"
PROFILE = ROOT / ".emulator"


def require(path: Path) -> Path:
    if not path.exists():
        raise SystemExit(f"Required path is missing: {path}")
    return path.resolve()


def replace_symlink(link: Path, target: Path) -> None:
    target = require(target)
    if link.is_symlink():
        link.unlink()
    elif link.exists():
        raise SystemExit(f"Refusing to replace non-symlink path: {link}")
    link.parent.mkdir(parents=True, exist_ok=True)
    link.symlink_to(os.path.relpath(target, link.parent))


def sync_link_directory(source: Path, destination: Path) -> None:
    source = require(source)
    if destination.is_symlink() or (destination.exists() and not destination.is_dir()):
        raise SystemExit(f"Refusing unexpected profile directory: {destination}")
    destination.mkdir(parents=True, exist_ok=True)
    for item in source.iterdir():
        link = destination / item.name
        if link.exists() and not link.is_symlink():
            continue
        replace_symlink(link, item)


def emulator_executable() -> Path:
    for candidate in (
        FAB_ROOT / "fab-agon-emulator",
        FAB_ROOT / "target/release/fab-agon-emulator",
    ):
        if candidate.is_file():
            return candidate
    raise SystemExit(f"Fab emulator executable is missing under {FAB_ROOT}")


def main() -> None:
    shared_sd = require(FAB_ROOT / "sdcard")
    disk = require(ROOT / "build/cpma.dsk")
    cpm = require(ROOT / "vendor/agon-cpm/cpm.bin")

    PROFILE.mkdir(parents=True, exist_ok=True)
    sdcard = PROFILE / "sdcard"
    sdcard.mkdir(exist_ok=True)

    replace_symlink(PROFILE / "fab-agon-emulator", emulator_executable())
    replace_symlink(PROFILE / "firmware", FAB_ROOT / "firmware")
    replace_symlink(sdcard / "firmware.bin", shared_sd / "firmware.bin")
    replace_symlink(sdcard / "MOS.bin", shared_sd / "MOS.bin")
    sync_link_directory(shared_sd / "bin", sdcard / "bin")
    sync_link_directory(shared_sd / "mos", sdcard / "mos")

    app = sdcard / "kermit"
    if app.is_symlink() or (app.exists() and not app.is_dir()):
        raise SystemExit(f"Refusing unexpected Kermit SD path: {app}")
    app.mkdir(parents=True, exist_ok=True)
    replace_symlink(app / "cpm.bin", cpm)
    replace_symlink(app / "cpma.dsk", disk)

    write_config(sdcard / "mos/zinc.cfg", baud=115_200)
    autoexec = sdcard / "autoexec.txt"
    if not autoexec.exists():
        autoexec.write_bytes(
            b"SET KEYBOARD 1\r\n"
            b"cd /kermit\r\n"
            b"load cpm.bin\r\n"
        )

    print(f"Emulator profile: {PROFILE}")
    print(f"CP/M disk:        {disk}")
    print(f"UART config:      {sdcard / 'mos/zinc.cfg'} (115200 8N1)")
    print(f"Autoexec:         {autoexec}")


if __name__ == "__main__":
    main()
