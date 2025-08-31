#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_openobservation() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh openobservation)
  cd ..
  if [ ! -d OpenObservation ]; then
    gh repo clone OpenSwiftUIProject/OpenObservation
    cd OpenObservation
  else
    echo "OpenObservation already exists, skipping clone."
    cd OpenObservation
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  git checkout --quiet $revision
}

clone_checkout_openobservation