#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
launcher="${HOME}/Agon/mystuff/agon-dev-env/scripts/run_emulator.sh"

if [[ ! -x "${launcher}" ]]; then
    printf 'Canonical emulator launcher is missing: %s\n' "${launcher}" >&2
    exit 1
fi

exec "${launcher}" "${project_root}/.emulator"
