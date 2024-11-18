#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_og() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh opengraph)
  cd ..
  gh repo clone OpenSwiftUIProject/OpenGraph
  cd OpenGraph
  git checkout --quiet $revision
}

update_og() {
  cd $REPO_ROOT/../OpenGraph
  ./AG/update.sh
}

clone_checkout_og
update_og
