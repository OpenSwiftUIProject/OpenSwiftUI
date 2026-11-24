#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
OPENSWIFTUI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
DEFAULT_WORKSPACE_ROOT="$(cd "$OPENSWIFTUI_ROOT/.." && pwd -P)"

SIBLING_REPOS=(
  "Compute|https://github.com/OpenSwiftUIProject/Compute.git"
  "DarwinPrivateFrameworks|https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git"
  "OpenAttributeGraph|https://github.com/OpenSwiftUIProject/OpenAttributeGraph.git"
  "OpenCoreGraphics|https://github.com/OpenSwiftUIProject/OpenCoreGraphics.git"
  "OpenObservation|https://github.com/OpenSwiftUIProject/OpenObservation.git"
  "OpenRenderBox|https://github.com/OpenSwiftUIProject/OpenRenderBox.git"
  "UIKit-cross-platform|https://github.com/OpenSwiftUIProject/UIKit-cross-platform.git"
)

# Public upstream submodules (such as UIKit-cross-platform) use SSH URLs.
# Rewrite in this process tree so clean machines do not need a GitHub SSH key.
git_config_count="${GIT_CONFIG_COUNT:-0}"
export "GIT_CONFIG_KEY_${git_config_count}=url.https://github.com/.insteadOf"
export "GIT_CONFIG_VALUE_${git_config_count}=git@github.com:"
export GIT_CONFIG_COUNT="$((git_config_count + 1))"

usage() {
  cat <<EOF
Usage:
  ./Scripts/$SCRIPT_NAME [options] [branch]

Clone or switch sibling OpenSwiftUI dependency repositories for local Android
development (OPENSWIFTUI_USE_LOCAL_DEPS=1 / MISE_ENV=local).

Options:
  -b, --branch <branch>   Target branch to check out (default: \$ANDROID_DEPS_BRANCH,
                          current OpenSwiftUI branch, or 'android/dev').
  --root <dir>            Parent directory containing sibling checkouts
                          (default: parent directory of OpenSwiftUI).
  --pull                  Fast-forward existing checkouts from origin when clean.
  --create-missing        Create <branch> locally from origin's default branch if
                          origin/<branch> does not exist (default: fall back to
                          the repository's default branch, e.g. 'main').
  --skip-darwin           Skip DarwinPrivateFrameworks on non-Apple hosts.
  -n, --dry-run           Print planned actions without modifying repositories.
  -h, --help              Show this help message.
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

repo_exists() {
  local repo_dir="$1"
  [[ -d "$repo_dir/.git" || -f "$repo_dir/.git" ]]
}

detect_default_target_branch() {
  if [[ -n "${ANDROID_DEPS_BRANCH:-}" ]]; then
    printf '%s\n' "$ANDROID_DEPS_BRANCH"
    return
  fi

  local current
  current="$(git -C "$OPENSWIFTUI_ROOT" branch --show-current 2>/dev/null || true)"
  if [[ -n "$current" ]]; then
    printf '%s\n' "$current"
  else
    printf '%s\n' "android/dev"
  fi
}

origin_default_branch() {
  local repo_dir="$1"
  local origin_head
  origin_head="$(git -C "$repo_dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -n "$origin_head" ]]; then
    printf '%s\n' "${origin_head#origin/}"
  elif git -C "$repo_dir" show-ref --verify --quiet refs/remotes/origin/main; then
    printf '%s\n' "main"
  elif git -C "$repo_dir" show-ref --verify --quiet refs/remotes/origin/master; then
    printf '%s\n' "master"
  else
    die "unable to determine default branch for $repo_dir"
  fi
}

ensure_clean_worktree() {
  local repo_dir="$1"
  local repo_name="$2"
  local target="$3"
  if ! git -C "$repo_dir" diff --quiet || ! git -C "$repo_dir" diff --cached --quiet; then
    die "$repo_name ($repo_dir) has uncommitted changes; commit or stash them before switching to '$target'"
  fi
}

sync_submodules() {
  local repo_dir="$1"
  local repo_name="$2"
  local dry_run="$3"

  [[ -f "$repo_dir/.gitmodules" ]] || return 0
  git -C "$repo_dir" config --file .gitmodules --get-regexp '^submodule\..*\.path$' >/dev/null 2>&1 || return 0

  if [[ "$dry_run" -eq 1 ]]; then
    printf '[%s] would sync and update submodules\n' "$repo_name"
    return 0
  fi

  printf '[%s] updating submodules\n' "$repo_name"
  git -C "$repo_dir" submodule sync --recursive --quiet
  git -C "$repo_dir" submodule update --init --recursive
}

setup_sibling_repo() {
  local workspace_root="$1"
  local repo_name="$2"
  local repo_url="$3"
  local requested_branch="$4"
  local pull_updates="$5"
  local create_missing="$6"
  local dry_run="$7"
  local repo_dir="$workspace_root/$repo_name"

  if ! repo_exists "$repo_dir"; then
    if [[ -e "$repo_dir" ]]; then
      die "path exists and is not a Git repository: $repo_dir"
    fi
    if [[ "$dry_run" -eq 1 ]]; then
      printf '[%s] would clone %s -> %s (target branch: %s)\n' "$repo_name" "$repo_url" "$repo_dir" "$requested_branch"
      return 0
    fi
    printf '[%s] cloning %s\n' "$repo_name" "$repo_url"
    git clone "$repo_url" "$repo_dir"
  fi

  if [[ "$dry_run" -eq 0 ]]; then
    git -C "$repo_dir" fetch origin --prune --quiet
  fi

  local resolved_branch="$requested_branch"
  local fallback_branch=""
  local has_local=0
  local has_remote=0

  if git -C "$repo_dir" show-ref --verify --quiet "refs/heads/$requested_branch"; then
    has_local=1
  fi
  if git -C "$repo_dir" show-ref --verify --quiet "refs/remotes/origin/$requested_branch"; then
    has_remote=1
  fi

  if [[ "$has_local" -eq 0 && "$has_remote" -eq 0 && "$create_missing" -eq 0 ]]; then
    fallback_branch="$(origin_default_branch "$repo_dir")"
    resolved_branch="$fallback_branch"
    printf "[%s] branch '%s' not found on origin; using '%s'\n" "$repo_name" "$requested_branch" "$resolved_branch"
  fi

  local current_branch
  current_branch="$(git -C "$repo_dir" branch --show-current)"

  if [[ "$current_branch" == "$resolved_branch" ]]; then
    printf "[%s] on '%s'\n" "$repo_name" "$resolved_branch"
    if [[ "$pull_updates" -eq 1 ]] && git -C "$repo_dir" show-ref --verify --quiet "refs/remotes/origin/$resolved_branch"; then
      ensure_clean_worktree "$repo_dir" "$repo_name" "$resolved_branch"
      if [[ "$dry_run" -eq 1 ]]; then
        printf "[%s] would fast-forward '%s' from 'origin/%s'\n" "$repo_name" "$resolved_branch" "$resolved_branch"
      else
        git -C "$repo_dir" merge --ff-only "origin/$resolved_branch"
      fi
    fi
  else
    ensure_clean_worktree "$repo_dir" "$repo_name" "$resolved_branch"
    if [[ "$dry_run" -eq 1 ]]; then
      printf "[%s] would switch '%s' -> '%s'\n" "$repo_name" "${current_branch:-DETACHED}" "$resolved_branch"
    elif git -C "$repo_dir" show-ref --verify --quiet "refs/heads/$resolved_branch"; then
      printf "[%s] switching to '%s'\n" "$repo_name" "$resolved_branch"
      git -C "$repo_dir" checkout "$resolved_branch"
      if [[ "$pull_updates" -eq 1 ]] && git -C "$repo_dir" show-ref --verify --quiet "refs/remotes/origin/$resolved_branch"; then
        git -C "$repo_dir" merge --ff-only "origin/$resolved_branch"
      fi
    elif git -C "$repo_dir" show-ref --verify --quiet "refs/remotes/origin/$resolved_branch"; then
      printf "[%s] checking out '%s' tracking 'origin/%s'\n" "$repo_name" "$resolved_branch" "$resolved_branch"
      git -C "$repo_dir" checkout -b "$resolved_branch" --track "origin/$resolved_branch"
    else
      fallback_branch="$(origin_default_branch "$repo_dir")"
      printf "[%s] creating '%s' from 'origin/%s'\n" "$repo_name" "$resolved_branch" "$fallback_branch"
      git -C "$repo_dir" checkout --no-track -b "$resolved_branch" "origin/$fallback_branch"
    fi
  fi

  sync_submodules "$repo_dir" "$repo_name" "$dry_run"
}

main() {
  local target_branch=""
  local workspace_root="$DEFAULT_WORKSPACE_ROOT"
  local pull_updates=0
  local create_missing=0
  local skip_darwin=0
  local dry_run=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--branch)
        [[ $# -ge 2 ]] || die "--branch requires a value"
        target_branch="$2"
        shift 2
        ;;
      --root)
        [[ $# -ge 2 ]] || die "--root requires a directory path"
        mkdir -p "$2"
        workspace_root="$(cd "$2" && pwd -P)"
        shift 2
        ;;
      --pull)
        pull_updates=1
        shift
        ;;
      --create-missing)
        create_missing=1
        shift
        ;;
      --skip-darwin)
        skip_darwin=1
        shift
        ;;
      -n|--dry-run)
        dry_run=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        die "unknown option: $1 (try --help)"
        ;;
      *)
        [[ -z "$target_branch" ]] || die "unexpected argument: $1"
        target_branch="$1"
        shift
        ;;
    esac
  done

  if [[ -z "$target_branch" ]]; then
    target_branch="$(detect_default_target_branch)"
  fi

  mkdir -p "$workspace_root"
  printf 'Setting up OpenSwiftUI sibling dependencies in %s (target branch: %s)\n' "$workspace_root" "$target_branch"

  local spec repo_name repo_url
  for spec in "${SIBLING_REPOS[@]}"; do
    IFS='|' read -r repo_name repo_url <<< "$spec"
    if [[ "$skip_darwin" -eq 1 && "$repo_name" == "DarwinPrivateFrameworks" ]]; then
      continue
    fi
    setup_sibling_repo \
      "$workspace_root" \
      "$repo_name" \
      "$repo_url" \
      "$target_branch" \
      "$pull_updates" \
      "$create_missing" \
      "$dry_run"
  done
}

main "$@"
