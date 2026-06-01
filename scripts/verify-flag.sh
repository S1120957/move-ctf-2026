#!/usr/bin/env bash
# Copyright (c) 2025 IOTA Stiftung
# SPDX-License-Identifier: Apache-2.0
#
# Confirms a flag was captured. Lists every `Flag` object owned by the active
# address (optionally filtered to one challenge package).
#
# Usage:
#   scripts/verify-flag.sh                 # all captured flags for the active address
#   scripts/verify-flag.sh <PACKAGE_ID>    # only flags minted by this package
#
# Note: Challenge 5 Stage B mints the flag to the (shared) vulnerable account, not to
# you — your proof there is that your exploit transaction executed. Inspect it with
# `iota client objects --address <VACC>` or check the FlagCaptured event of your tx.
set -euo pipefail

IOTA="${IOTA_BIN:-iota}"
PKG_FILTER="${1:-}"

ADDR="$($IOTA client active-address)"
echo "Captured flags owned by $ADDR:"

JSON="$($IOTA client objects --json 2>/dev/null)"

if [ -n "$PKG_FILTER" ]; then
  FLAGS="$(echo "$JSON" | jq -r --arg p "$PKG_FILTER" '.[] | .data | select((.type // "") | test("::Flag$")) | select((.type // "") | startswith($p)) | .objectId')"
else
  FLAGS="$(echo "$JSON" | jq -r '.[] | .data | select((.type // "") | test("::Flag$")) | .objectId')"
fi

if [ -z "$FLAGS" ]; then
  echo "  (none yet — keep going!)"
  exit 1
fi

echo "$FLAGS" | sed 's/^/  🏁 /'
