#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"
cd $REPO_ROOT

# The order of these scripts matters.
# The more foundational frameworks should be set up last.
Scripts/CI/openattributegraph_setup.sh
Scripts/CI/openrenderbox_setup.sh
Scripts/CI/opencoregraphics_setup.sh
Scripts/CI/openobservation_setup.sh
Scripts/CI/framework_setup.sh
