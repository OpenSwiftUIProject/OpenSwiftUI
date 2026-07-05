#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_compute() {
  cd $REPO_ROOT
  revision="${OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_SOURCE_VERSION:-}"
  if [ -z "$revision" ]; then
    revision=$(Scripts/CI/get_revision.sh compute 2>/dev/null || true)
  fi
  if [ -z "$revision" ]; then
    revision="0.3.0-bugfix.1"
  fi
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
  git checkout --quiet "$revision"
}

update_compute() {
  cd $REPO_ROOT/../Compute
  git submodule sync --recursive --quiet
  git submodule update --init --recursive
}

clone_checkout_compute
update_compute
