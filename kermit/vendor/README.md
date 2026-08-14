# Vendored inputs and provenance

The Kermit test build is intentionally independent of mutable checkouts beside
this repository.  These files are unmodified snapshots unless a path is
explicitly described as a downloaded release artifact.

## Kermit 4.11 and CP/M build programs

- Upstream repository: <https://github.com/nihirash/ZINC>
- Upstream commit: `9df58126ae1ba1c47122792b479ef43ad7c550bd`
- Vendored path in that commit: `apps/3rd-party/kermit`
- Local path: `vendor/kermit-80`
- Original program/document attribution: Columbia University Kermit-80 4.11,
  documented in `vendor/kermit-80/readme.txt`
- Included CP/M build programs: `lasm.com` and `MLOAD25.COM`

Nihirash's build selects `gener EQU TRUE` in `cpxtyp.asm`.  For that generic
target, `cpxsy2.asm` defines `spdtbl` and `sphtbl` as zero, so Kermit's
`SET SPEED` command is intentionally unavailable.  The snapshot also includes
Nihirash's previously built binary only as an upstream comparison artifact;
the test disk receives `build/kermit/KERMIT.COM`, never that binary.

## Agon CP/M runtime

- Upstream repository: <https://github.com/nihirash/Agon-CPM2.2>
- Source/release commit: `4215f31ad49f6177c44afd468c50fa9acc46ac7e`
- Release tag: `1.3`
- Runtime download:
  <https://github.com/nihirash/Agon-CPM2.2/releases/download/1.3/cpm.bin>
- `cpm.bin` SHA-256:
  `5b49e08afc5eaa55cb7901080ee43cef026243675bb1b59c303a912b72e41975`
- Local path: `vendor/agon-cpm`

`diskdefs`, `template.dsk`, `terminal.inc`, the upstream README, and the
Coffeeware license were copied from the source commit.  `cpm.bin` is the exact
release asset.  `terminal.inc` establishes the relevant runtime contract: it
loads the eight-byte `/mos/zinc.cfg` structure and passes it to `mos_uopen`.

## ZXCC

- Upstream repository: <https://github.com/agn453/ZXCC>
- Upstream commit: `c45e5065eca63dd045d60511a8b21ab7f567303a`
- Local path: `vendor/zxcc`
- License: GPL-2.0 for ZXCC, with component licenses retained in the snapshot

ZXCC runs the original CP/M-hosted LASM and MLOAD tools on the development
host.  It is built into `build/tools/zxcc`; it is not installed globally.
The pinned snapshot's `cpmredir/lib/Makefile.am` includes `track.c`, but its
generated `Makefile.in` predates that change. The build applies
`patches/zxcc-track-source.patch` to the disposable build copy so the symbols
referenced by CPMREDIR are linked. The vendor snapshot itself remains intact.

## cpmtools

- Upstream repository: <https://github.com/lipro-cpm4l/cpmtools>
- Upstream commit: `e534e20c15973a9559e981efb498a102020e5db7`
- Local path: `vendor/cpmtools`
- License: GPL-3.0, retained as `vendor/cpmtools/COPYING`

The locally built `cpmcp` creates the test disk from Nihirash's template and
adds the locally built Kermit program and tracked initialization file.  The
tools are installed only below `build/tools/cpmtools`.

## Refresh policy

Do not replace a vendored tree from an unpinned branch.  A refresh must record
the new full commit, update relevant artifact hashes and behavioural notes,
retain upstream license files, rebuild from a clean generated directory, and
pass `make verify` before review.
