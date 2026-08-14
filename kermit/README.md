# Kermit on Agon CP/M

This subproject builds the generic CP/M-80 Kermit 4.11 program shipped by
Nihirash, places the locally built `KERMIT.COM` in a fresh Agon CP/M disk
image, and provisions an isolated Fab Agon Emulator profile for testing it.

The immediate experiment is to verify the existing baud-rate behaviour before
answering community questions or changing Kermit.  The vendored generic target
intentionally has no `SET SPEED` table; Agon CP/M 1.2 and later instead load
UART1 parameters from `/mos/zinc.cfg` before entering CP/M.  The generated test
profile sets that configuration to 115200 baud, 8 data bits, one stop bit, no
parity, and no flow control.

## Layout

- `vendor/kermit-80/` — Kermit 4.11 sources plus the LASM and MLOAD CP/M tools.
- `vendor/zxcc/` — host CP/M emulator used to run LASM and MLOAD.
- `vendor/cpmtools/` — host tools used to populate the CP/M disk image.
- `vendor/agon-cpm/` — Agon CP/M runtime, disk definition/template, and the
  UART bootstrap source used to establish the test configuration.
- `runtime/KERMIT.INI` — selects the Agon CP/M `TTY` device and disables
  Kermit's own terminal translation. The disk build converts its tracked Unix
  line endings to CP/M CRLF text.
- `patches/` — documented build-only fixes applied to disposable vendor copies.
- `scripts/` — deterministic configuration, verification, and emulator setup.
- `build/` — generated host tools, `KERMIT.COM`, and `cpma.dsk` (ignored).
- `.emulator/` — generated project-local emulator instance (ignored).

Full upstream URLs, revisions, file hashes, and licensing notes are in
[`vendor/README.md`](vendor/README.md).

## Environment

The project-local environment is created with CPython 3.14:

```bash
~/.local/bin/python3.14 -m venv .venv
.venv/bin/python -m unittest discover -s tests -v
```

There are currently no third-party Python packages.  The virtual environment
exists to keep all setup and verification scripts on one known interpreter.

Host compilation additionally needs a C compiler, `make`, `patch`, and the
curses/ncurses development libraries. The vendored releases include generated
`configure` scripts, so Autotools is not needed. ZXCC and cpmtools themselves
are built from the vendored sources; no system installation is performed.

## Build and verify

From this directory:

```bash
make all
make verify
```

The important generated files are:

```text
build/kermit/KERMIT.COM
build/cpma.dsk
```

`make verify` checks the Python tests, pinned vendor artifacts, Kermit target
identity, the generated UART configuration, and the presence of `KERMIT.COM`
and `KERMIT.INI` on the generated CP/M disk.

## Emulator

Create or refresh the isolated profile after `make all`:

```bash
make setup-emulator
scripts/run_emulator.sh
```

The profile uses the stock Fab Agon Emulator runtime from
`~/Agon/fab-agon-emulator`, but owns its SD-card overlay, CP/M disk, UART
configuration, and autoexec file.  It does not modify Fab's tracked `sdcard`
submodule.  `autoexec.txt` changes to `/kermit` and loads CP/M; inside CP/M,
run:

```text
DIR
KERMIT
SHOW
SET SPEED 115200
```

The expected baseline is that `SHOW` identifies Generic CP/M-80 and
`SET SPEED 115200` reports `(Not implemented)`, while UART1 was already opened
at 115200 by the CP/M bootstrap.

On hardware, the equivalent supported setup is to run ZINC's `zinc-setup`
MOSlet before starting CP/M and select 115200, 8 data bits, 1 stop bit, and no
parity. It writes the same `/mos/zinc.cfg` file consumed by the CP/M bootstrap;
Kermit itself should remain on the `TTY` port and does not need to set speed.

This emulator profile and all emulator-coupled changes must remain uncommitted
until a human has exercised the profile and explicitly approved them.
