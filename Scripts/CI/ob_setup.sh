#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_og() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh openbox)
  cd ..
  if [ ! -d OpenBox ]; then
    gh repo clone OpenSwiftUIProject/OpenBox
    cd OpenBox
  else
    echo "OpenBox already exists, skipping clone."
    cd OpenBox
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  git checkout --quiet $revision
}

update_og() {
  cd $REPO_ROOT/../OpenBox
  ./Scripts/CI/darwin_setup_build.sh
}

clone_checkout_og
update_og
