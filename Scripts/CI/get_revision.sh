#!/bin/bash

# This script extracts the revision of a specific dependency from the Package.resolved file (Only support v3).
# Usage: ./get_revision.sh <dependency_name>
# Output: revision of the dependency

# A `realpath` alternative using the default C implementation.
filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"
cd $REPO_ROOT

# Ensure a dependency name is provided as an argument
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <dependency_name>"
  exit 1
fi

DEPENDENCY_NAME="$1"
PACKAGE_RESOLVED_PATH="Package.resolved"

# Check if the Package.resolved file exists
if [[ ! -f "$PACKAGE_RESOLVED_PATH" ]]; then
  echo "Error: $PACKAGE_RESOLVED_PATH file not found!"
  exit 1
fi

# Extract the revision using jq
REVISION=$(jq -r --arg name "$DEPENDENCY_NAME" '
  .pins[]? 
  | select(.identity == $name) 
  | .state.revision
' "$PACKAGE_RESOLVED_PATH")

# Check if a revision was found
if [[ -z "$REVISION" ]]; then
  echo "No revision found for dependency: $DEPENDENCY_NAME"
  exit 1
else
  echo "$REVISION"
fi