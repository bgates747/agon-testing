#!/usr/bin/env python3
"""Verify pinned inputs and the locally built Generic CP/M-80 Kermit."""

from __future__ import annotations

import hashlib
from pathlib import Path

from write_zinc_cfg import encode_uart_config


ROOT = Path(__file__).resolve().parent.parent

PINNED_HASHES = {
    "vendor/agon-cpm/cpm.bin": (
        "5b49e08afc5eaa55cb7901080ee43cef026243675bb1b59c303a912b72e41975"
    ),
    "vendor/agon-cpm/template.dsk": (
        "35b3b683377aa9f6063d6e2c2ad1764d7518039b31fc8d7be10d7a3c533d45af"
    ),
    "vendor/kermit-80/lasm.com": (
        "87126d4aa4c5814df9d3449d30e27d72c67894af879a0e4fb5c8ab0b12b12d75"
    ),
    "vendor/kermit-80/MLOAD25.COM": (
        "758f8e1f8399185232df193f78dd6b272cb320abd1726cfb11145b76e8ac6dd0"
    ),
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    for relative, expected in PINNED_HASHES.items():
        path = ROOT / relative
        actual = sha256(path)
        if actual != expected:
            raise SystemExit(f"Hash mismatch for {relative}: {actual}")

    target_source = (ROOT / "vendor/kermit-80/cpxtyp.asm").read_text(
        encoding="ascii", errors="replace"
    )
    overlay_source = (ROOT / "vendor/kermit-80/cpxsy2.asm").read_text(
        encoding="ascii", errors="replace"
    )
    if "gener\tEQU\tTRUE" not in target_source:
        raise SystemExit("Vendored CPXTYP does not select Generic CP/M-80")
    if "spdtbl  equ     0" not in overlay_source:
        raise SystemExit("Generic overlay no longer disables SET SPEED")

    binary = (ROOT / "build/kermit/KERMIT.COM").read_bytes()
    if b"Generic CP/M-80" not in binary:
        raise SystemExit("Built KERMIT.COM lacks the Generic CP/M-80 identity")

    config = encode_uart_config()
    if config != bytes.fromhex("00c2010801000000"):
        raise SystemExit(f"Unexpected 115200 8N1 configuration: {config.hex()}")

    print("Pinned artifacts, Generic CP/M target, and UART configuration verified.")


if __name__ == "__main__":
    main()
