#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

case "$(uname -s)" in
Darwin)
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=1
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=0
    ;;
*)
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=0
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1
    ;;
esac

exec swift run ExampleApp "$@"
