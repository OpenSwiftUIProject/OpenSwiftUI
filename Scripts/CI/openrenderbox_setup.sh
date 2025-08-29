#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_openrenderbox() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh openrenderbox)
  cd ..
  if [ ! -d OpenRenderBox ]; then
    gh repo clone OpenSwiftUIProject/OpenRenderBox
    cd OpenRenderBox
  else
    echo "OpenRenderBox already exists, skipping clone."
    cd OpenRenderBox
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  git checkout --quiet $revision
}

update_openrenderbox() {
  cd $REPO_ROOT/../OpenRenderBox
  ./Scripts/CI/darwin_setup_build.sh
}

clone_checkout_openrenderbox
update_openrenderbox
