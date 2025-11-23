#!/bin/zsh

# A `realpath` alternative using the default C implementation.
filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

OPENSWIFTUI_ROOT="$(dirname $(dirname $(filepath $0)))"

cd $OPENSWIFTUI_ROOT

# Set OPENSWIFTUI_LIB_SWIFT_PATH on Linux if swiftly is installed
if [[ "$(uname)" == "Linux" ]] && command -v swiftly &> /dev/null && [[ -z "$OPENSWIFTUI_LIB_SWIFT_PATH" ]]; then
  export OPENSWIFTUI_LIB_SWIFT_PATH="$(swiftly use --print-location)/usr/lib/swift"
  echo "Set OPENSWIFTUI_LIB_SWIFT_PATH=$OPENSWIFTUI_LIB_SWIFT_PATH"
fi

swift build
