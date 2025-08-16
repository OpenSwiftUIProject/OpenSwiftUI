#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_dpf() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh darwinprivateframeworks)
  cd ..
  if [ ! -d DarwinPrivateFrameworks ]; then
    gh repo clone OpenSwiftUIProject/DarwinPrivateFrameworks
    cd DarwinPrivateFrameworks
  else
    echo "DarwinPrivateFrameworks already exists, skipping clone."
    cd DarwinPrivateFrameworks
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  git checkout --quiet $revision
}

update_dpf() {
  cd $REPO_ROOT/../DarwinPrivateFrameworks
  swift package update-xcframeworks --allow-writing-to-package-directory
}

clone_checkout_dpf
update_dpf
