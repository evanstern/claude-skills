#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
TARGET_DIR="$HOME/.claude/skills"

mkdir -p "$TARGET_DIR"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$TARGET_DIR/$skill_name"

  # Already a symlink pointing to the right place
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$skill_dir" ]; then
    echo "  $skill_name: already linked"
    continue
  fi

  # Exists but is not a symlink — back it up
  if [ -e "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    echo "  $skill_name: backing up existing to $backup"
    mv "$target" "$backup"
  fi

  ln -s "$skill_dir" "$target"
  echo "  $skill_name: linked"
done

echo ""
echo "Done. Skills installed to $TARGET_DIR"
