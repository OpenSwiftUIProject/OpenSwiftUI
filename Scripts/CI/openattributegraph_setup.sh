#!/bin/bash

# A `realpath` alternative using the default C implementation.
filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

REPO_ROOT="$(dirname $(dirname $(dirname $(filepath $0))))"

clone_checkout_openattributegraph() {
  cd $REPO_ROOT
  revision=$(Scripts/CI/get_revision.sh openattributegraph)
  cd ..
  if [ ! -d OpenAttributeGraph ]; then
    gh repo clone OpenSwiftUIProject/OpenAttributeGraph
    cd OpenAttributeGraph
  else
    echo "OpenAttributeGraph already exists, skipping clone."
    cd OpenAttributeGraph
    git fetch --all --quiet
    git stash --quiet || true
    git reset --hard --quiet origin/main
  fi
  git checkout --quiet $revision
}

update_openattributegraph() {
  cd $REPO_ROOT/../OpenAttributeGraph
  ./Scripts/CI/darwin_setup_build.sh
}

clone_checkout_openattributegraph
update_openattributegraph
