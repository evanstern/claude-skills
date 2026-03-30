# CLAUDE.md

## Project: claude-skills

A version-controlled repository for Claude Code custom skills. Skills are markdown-based (SKILL.md) with YAML frontmatter that define slash commands for Claude Code. This repo is the source of truth for all custom skills — they get installed into `~/.claude/skills/` for Claude Code to pick up.

## Origin

Spun off from `evanstern/ideas` after building several skills (`/humanizer`, `/process-downloads`, `/spin-off-project`) directly in `~/.claude/skills/` with no version control. These are valuable enough to track, version, and back up properly.

## Architecture / Design (PROPOSED — verify with user before building)

**Repo structure mirrors the skills directory:**
Each skill lives in its own directory with a `SKILL.md` file (and optional supporting files like templates).

**Installation model (needs discussion):**
- Option A: **Symlink** — `~/.claude/skills/` contains symlinks pointing back to this repo. Changes in the repo are immediately live.
- Option B: **Copy/install script** — A script copies skills from this repo into `~/.claude/skills/`. Explicit install step, but decoupled.
- Option C: **This repo IS `~/.claude/skills/`** — Make `~/.claude/skills/` itself a git repo (or symlink the whole directory).

**NOTE TO CLAUDE:** This architecture was captured from an initial brainstorming conversation.
Before implementing, walk through this design with the user to confirm it still reflects their
vision. Things may have evolved since this was written. Ask the user: "I've read the CLAUDE.md —
does this architecture still match your vision, or has your thinking evolved?"

## Existing Skills to Migrate

These skills currently live in `~/.claude/skills/` and should be brought into this repo:

- **humanizer** — Removes AI writing patterns from text (v2.1.1). Has supporting files.
- **process-downloads** — Processes downloaded media files from /Volumes/complete (v1.0.0).
- **spin-off-project** — Spins off ideas from conversations into new GitHub repos.

## Key Challenges

- **Installation/sync model** — How do skills get from this repo to `~/.claude/skills/`? Symlinks are simplest but might have edge cases with Claude Code's file resolution.
- **Skill versioning** — Some skills already have version fields in frontmatter. Should the repo use git tags, or is per-skill versioning in frontmatter enough?
- **Supporting files** — Some skills (humanizer) have subdirectories with templates. The install mechanism needs to handle these.

## Project Structure (PROPOSED)

```
skills/
  humanizer/
    SKILL.md
    (supporting files)
  process-downloads/
    SKILL.md
  spin-off-project/
    SKILL.md
install.sh            — Script to install/symlink skills into ~/.claude/skills/
```

## Getting Started

When first opening this project in Claude Code:
1. **Review the architecture above with the user.** Confirm the installation model (symlink vs copy vs direct) and repo structure before writing code. Ask explicitly:
   "I've read the CLAUDE.md — does this architecture still match your vision, or has your thinking evolved?"
2. Then proceed with the build phases below.

### Build Phases

1. Decide on the installation model (symlink, copy, or direct)
2. Set up repo structure and migrate existing skills from `~/.claude/skills/`
3. Create install/sync script
4. Test that skills work correctly after installation
5. Document how to add new skills

## Commands

(To be filled in as we build)
