#!/bin/zsh

# A `realpath` alternative using the default C implementation.
filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

OPENSWIFTUI_ROOT="$(dirname $(dirname $(filepath $0)))"

cd $OPENSWIFTUI_ROOT

export OPENSWIFTUI_SWIFT_TESTING=0
export OPENGRAPH_SWIFT_TESTING=0
swift build -c release -Xswiftc -emit-module-interface -Xswiftc -enable-library-evolution
