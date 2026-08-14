SHELL := /bin/bash
.DELETE_ON_ERROR:

ROOT := $(abspath .)
BUILD := $(ROOT)/build
TOOLS := $(BUILD)/tools
ZXCC_BUILD := $(BUILD)/zxcc-src
ZXCC_PREFIX := $(TOOLS)/zxcc
ZXCC := $(ZXCC_PREFIX)/bin/zxcc
ZXCC_PATCHSTAMP := $(ZXCC_BUILD)/.patched
CPMTOOLS_BUILD := $(BUILD)/cpmtools-src
CPMTOOLS_PREFIX := $(TOOLS)/cpmtools
CPMCP := $(CPMTOOLS_PREFIX)/bin/cpmcp
CPMLS := $(CPMTOOLS_PREFIX)/bin/cpmls
KERM_BUILD := $(BUILD)/kermit
KERM_COM := $(KERM_BUILD)/KERMIT.COM
DISK := $(BUILD)/cpma.dsk
PYTHON := $(ROOT)/.venv/bin/python

KERM_SOURCES := $(wildcard vendor/kermit-80/*.asm)

.PHONY: all tools kermit disk test verify setup-emulator clean

all: $(DISK)

tools: $(ZXCC) $(CPMCP)

kermit: $(KERM_COM)

disk: $(DISK)

$(ZXCC_PATCHSTAMP): patches/zxcc-track-source.patch
	mkdir -p "$(ZXCC_BUILD)" "$(ZXCC_PREFIX)"
	cp -a vendor/zxcc/. "$(ZXCC_BUILD)/"
	patch -d "$(ZXCC_BUILD)" -p1 < patches/zxcc-track-source.patch
	touch "$@"

$(ZXCC): $(ZXCC_PATCHSTAMP)
	cd "$(ZXCC_BUILD)" && ./configure \
		--prefix="$(ZXCC_PREFIX)"
	$(MAKE) -C "$(ZXCC_BUILD)"
	$(MAKE) -C "$(ZXCC_BUILD)" install

$(CPMCP):
	mkdir -p "$(CPMTOOLS_BUILD)" "$(CPMTOOLS_PREFIX)"
	cp -a vendor/cpmtools/. "$(CPMTOOLS_BUILD)/"
	cd "$(CPMTOOLS_BUILD)" && ./configure \
		--prefix="$(CPMTOOLS_PREFIX)"
	$(MAKE) -C "$(CPMTOOLS_BUILD)"
	$(MAKE) -C "$(CPMTOOLS_BUILD)" install

$(KERM_COM): $(ZXCC) $(KERM_SOURCES) \
		vendor/kermit-80/lasm.com vendor/kermit-80/MLOAD25.COM
	mkdir -p "$(KERM_BUILD)"
	cp $(KERM_SOURCES) "$(KERM_BUILD)/"
	cp vendor/kermit-80/lasm.com "$(KERM_BUILD)/"
	cp vendor/kermit-80/MLOAD25.COM "$(KERM_BUILD)/mload25.com"
	cd "$(KERM_BUILD)" && "$(ZXCC)" lasm cpsker
	cd "$(KERM_BUILD)" && "$(ZXCC)" lasm cpxtyp
	cd "$(KERM_BUILD)" && "$(ZXCC)" mload25 kermit=CPSKER,CPXTYP
	mv "$(KERM_BUILD)/kermit.com" "$(KERM_COM)"

$(DISK): $(CPMCP) $(KERM_COM) runtime/KERMIT.INI \
		vendor/agon-cpm/template.dsk vendor/agon-cpm/diskdefs
	mkdir -p "$(BUILD)"
	cp vendor/agon-cpm/template.dsk "$(DISK)"
	cd "$(ROOT)/vendor/agon-cpm" && \
		"$(CPMCP)" -f nihirash "$(DISK)" "$(KERM_COM)" 0:KERMIT.COM
	cd "$(ROOT)/vendor/agon-cpm" && \
		"$(CPMCP)" -f nihirash -t "$(DISK)" \
			"$(ROOT)/runtime/KERMIT.INI" 0:KERMIT.INI

test:
	"$(PYTHON)" -m unittest discover -s tests -v

verify: $(DISK)
	"$(PYTHON)" scripts/verify.py
	cd "$(ROOT)/vendor/agon-cpm" && \
		"$(CPMLS)" -f nihirash "$(DISK)" | grep -Fx 'kermit.com'
	cd "$(ROOT)/vendor/agon-cpm" && \
		"$(CPMLS)" -f nihirash "$(DISK)" | grep -Fx 'kermit.ini'
	$(MAKE) test

setup-emulator: $(DISK)
	"$(PYTHON)" scripts/setup_emulator.py

clean:
	@printf 'Generated files are under %s; remove that directory explicitly if required.\n' "$(BUILD)"
