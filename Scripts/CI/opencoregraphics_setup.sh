#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_opencoregraphics() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh opencoregraphics)
  cd ..
  if [ ! -d OpenCoreGraphics ]; then
    gh repo clone OpenSwiftUIProject/OpenCoreGraphics
    cd OpenCoreGraphics
  else
    echo "OpenCoreGraphics already exists, skipping clone."
    cd OpenCoreGraphics
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  git checkout --quiet $revision
}

clone_checkout_opencoregraphics
