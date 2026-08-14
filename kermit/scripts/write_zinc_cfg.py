#!/usr/bin/env python3
"""Create the binary UART configuration consumed by ZINC and Agon CP/M."""

from __future__ import annotations

import argparse
from pathlib import Path


def encode_uart_config(
    baud: int = 115_200,
    data_bits: int = 8,
    stop_bits: int = 1,
    parity: int = 0,
    hardware_flow_control: int = 0,
    software_flow_control: int = 0,
) -> bytes:
    if not 0 < baud < 1 << 24:
        raise ValueError("baud must fit in an unsigned 24-bit field")
    if data_bits not in {5, 7, 8}:
        raise ValueError("data_bits must be 5, 7, or 8")
    if stop_bits not in {1, 2}:
        raise ValueError("stop_bits must be 1 or 2")
    if parity not in {0, 1, 2}:
        raise ValueError("parity must be 0 (none), 1 (odd), or 2 (even)")
    flags = (hardware_flow_control, software_flow_control)
    if any(flag not in {0, 1} for flag in flags):
        raise ValueError("flow-control fields must be 0 or 1")
    return (
        baud.to_bytes(3, byteorder="little")
        + bytes((data_bits, stop_bits, parity, *flags))
    )


def write_config(path: Path, baud: int = 115_200) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(encode_uart_config(baud=baud))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("path", type=Path)
    parser.add_argument("--baud", type=int, default=115_200)
    args = parser.parse_args()
    write_config(args.path, baud=args.baud)


if __name__ == "__main__":
    main()
