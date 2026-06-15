#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
MISE_ARGS=()

usage() {
  printf '%s\n' \
    "Usage: $(basename "$0") [--compute]" \
    "" \
    "Options:" \
    "  --compute  Use mise.compute.toml while installing tools and generating the project."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --compute)
      MISE_ARGS=(--env compute)
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

cd "$SCRIPT_DIR"
mise trust "$SCRIPT_DIR/mise.toml"
if [[ ${#MISE_ARGS[@]} -gt 0 ]]; then
  mise trust "$SCRIPT_DIR/mise.compute.toml"
fi
mise "${MISE_ARGS[@]}" install
mise "${MISE_ARGS[@]}" exec -- tuist install
mise "${MISE_ARGS[@]}" exec -- tuist generate --no-open
