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

run_mise() {
  if [[ ${#MISE_ARGS[@]} -gt 0 ]]; then
    mise "${MISE_ARGS[@]}" "$@"
  else
    mise "$@"
  fi
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
run_mise install
run_mise exec -- tuist install
run_mise exec -- tuist generate --no-open
