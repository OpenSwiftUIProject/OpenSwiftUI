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
  if [ ! -d OpenGraph ]; then
    gh repo clone OpenSwiftUIProject/OpenGraph
    cd OpenGraph
  else
    echo "OpenGraph already exists, skipping clone."
    cd OpenGraph
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  git checkout --quiet $revision
}

update_og() {
  cd $REPO_ROOT/../OpenGraph
  ./Scripts/CI/darwin_setup_build.sh
}

clone_checkout_og
update_og
