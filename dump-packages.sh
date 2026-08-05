#!/usr/bin/env bash
# Re-run this occasionally (before committing) to refresh the package lists
# so a fresh install of bootstrap.sh reproduces this machine.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dnf repoquery --userinstalled --qf '%{name}\n' \
  | grep -vE '^(kernel|kernel-core|kernel-modules)' \
  | sort > "$REPO_DIR/packages/dnf-packages.txt"

dnf copr list 2>/dev/null | awk '{print $1}' | sort > "$REPO_DIR/packages/copr-repos.txt"

flatpak list --app --columns=application | sort > "$REPO_DIR/packages/flatpak-packages.txt"

echo "Updated package lists in $REPO_DIR/packages/"
