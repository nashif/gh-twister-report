#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright The Zephyr Project Contributors
# SPDX-License-Identifier: Apache-2.0
#
# Install the gh-twister-report extension into the gh CLI.
#
# gh extension install requires the source directory to be a git repository.
# This script creates a temporary git repo, installs from it, then cleans up.
#
# Usage (from anywhere inside the Zephyr tree):
#   ./scripts/ci/gh-twister-report/install.sh
# Or from this directory:
#   ./install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMPDIR_EXT="$(mktemp -d)"

cleanup() {
    rm -rf "${TMPDIR_EXT}"
}
trap cleanup EXIT

EXTDIR="${TMPDIR_EXT}/gh-twister-report"
mkdir -p "${EXTDIR}"

cp "${SCRIPT_DIR}/gh-twister-report" "${EXTDIR}/gh-twister-report"
chmod +x "${EXTDIR}/gh-twister-report"

git -C "${EXTDIR}" init -q
git -C "${EXTDIR}" add gh-twister-report
git -C "${EXTDIR}" \
    -c user.email="install@localhost" \
    -c user.name="installer" \
    commit -q -m "gh-twister-report extension"

gh extension install "${EXTDIR}"

echo "Installed: gh twister-report"
echo "Run 'gh twister-report --help' to get started."
