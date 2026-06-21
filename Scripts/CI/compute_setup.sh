#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_compute() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh compute)
  cd ..
  if [ ! -d Compute ]; then
    gh repo clone OpenSwiftUIProject/Compute
    cd Compute
  else
    echo "Compute already exists, skipping clone."
    cd Compute
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  if [ -n "$revision" ]; then
    git checkout --quiet "$revision"
  else
    echo "No pinned revision for Compute, using default branch."
  fi
}

update_compute() {
  cd $REPO_ROOT/../Compute
  git submodule sync --recursive --quiet
  git submodule update --init --recursive
}

clone_checkout_compute
update_compute
