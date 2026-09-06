#!/usr/bin/env bash

set -euo pipefail

source_root="$1"
binary_root="$2"
source_root="$(cd "$source_root" && pwd -P)"
binary_root="$(cd "$binary_root" && pwd -P)"

node -e 'require(process.argv[1]).validateVersion(process.env.VERSION)' "$source_root/Scripts/CI/release.js"
cd "$binary_root"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

tag_exists=false
if git show-ref --verify --quiet "refs/tags/$VERSION"; then
  tag_exists=true
  git checkout --detach "$VERSION"
fi

node "$source_root/Scripts/CI/release.js" render-package "$source_root" "$binary_root"
git add -A -- Package.swift README.md Sources/OpenSwiftUIMacros

if [[ "$tag_exists" == true ]]; then
  if ! git diff --cached --quiet; then
    echo "Binary package tag $VERSION contains different artifacts or macros." >&2
    exit 1
  fi
  echo "Binary package tag $VERSION already contains the release."
  exit 0
fi

if ! git diff --cached --quiet; then
  git commit -m "Update to $VERSION with code-signed XCFrameworks"
fi
git tag "$VERSION"
# A concurrent main update must reject both refs so a retry can start from it.
git push --atomic origin HEAD:refs/heads/main "refs/tags/$VERSION:refs/tags/$VERSION"
