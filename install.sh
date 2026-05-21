#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright The Zephyr Project Contributors
# SPDX-License-Identifier: Apache-2.0
#
# Install (or upgrade) the gh-twister-report extension into the gh CLI.
#
# The gh CLI discovers extensions by scanning ~/.local/share/gh/extensions/.
# This script creates a directory there and places a symlink pointing back to
# the live source file, so any future edit to gh-twister-report takes effect
# immediately — no reinstall needed.
#
# Usage (from anywhere inside the Zephyr tree):
#   ./scripts/ci/gh-twister-report/install.sh
# Or from this directory:
#   ./install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_NAME="twister-report"
EXT_DIR="${HOME}/.local/share/gh/extensions/gh-${EXT_NAME}"

mkdir -p "${EXT_DIR}"

# Symlink the live source file so edits are reflected immediately.
ln -sf "${SCRIPT_DIR}/gh-${EXT_NAME}" "${EXT_DIR}/gh-${EXT_NAME}"

echo "Installed:  gh ${EXT_NAME}"
echo "Source:     ${SCRIPT_DIR}/gh-${EXT_NAME}"
echo "Edits to that file take effect immediately — no reinstall needed."
echo ""
echo "Run: gh twister-report --help"
