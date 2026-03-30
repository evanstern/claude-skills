# CLAUDE.md

## Project: claude-skills

A version-controlled repository for Claude Code custom skills. Skills are markdown-based (SKILL.md) with YAML frontmatter that define slash commands for Claude Code. This repo is the source of truth for all custom skills — they get symlinked into `~/.claude/skills/` for Claude Code to pick up.

## Origin

Spun off from `evanstern/ideas` after building several skills (`/humanizer`, `/process-downloads`, `/spin-off-project`) directly in `~/.claude/skills/` with no version control. These are valuable enough to track, version, and back up properly.

## Architecture

**Repo structure mirrors the skills directory:**
Each skill lives in its own directory under `skills/` with a `SKILL.md` file (and optional supporting files like templates).

**Installation model: Symlinks**
`~/.claude/skills/` contains symlinks pointing back to this repo. Changes in the repo are immediately live. Run `./install.sh` to create/update symlinks.

## Skills

- **humanizer** — Removes AI writing patterns from text (v2.1.1). Has README.md supporting file.
- **process-downloads** — Processes downloaded media files from /Volumes/complete (v1.0.0).
- **spin-off-project** — Spins off ideas from conversations into new GitHub repos.

## Project Structure

```
skills/
  humanizer/
    SKILL.md
    README.md
  process-downloads/
    SKILL.md
  spin-off-project/
    SKILL.md
install.sh            — Symlinks skills into ~/.claude/skills/
```

## Commands

```bash
./install.sh          # Create/update symlinks in ~/.claude/skills/
```

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter and instructions
2. Run `./install.sh` to symlink it into Claude Code
