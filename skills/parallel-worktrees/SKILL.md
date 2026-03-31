---
name: parallel-worktrees
description: |
  Launch multiple worktree agents in parallel to work on independent tasks.
  Each agent gets its own git branch, isolated worktree, and clear scope.
  Manages the full lifecycle: launch, track, push, PR, and merge.
  Use when you have a list of features, fixes, or research tasks that can
  be worked on independently.
argument-hint: "<list of tasks to work on in parallel>"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# Parallel Worktrees

You are launching multiple worktree agents to work on independent tasks in parallel.

## Input

The user has provided:

$ARGUMENTS

## What You Must Do

### Step 1: Parse the Task List

Extract individual tasks from the user's input. For each task, determine:
- **branch-name** — kebab-case feature branch name (`feature/<name>`)
- **type** — `code` (modifies source files) or `design` (produces documentation only)
- **scope** — one-line description of what the agent will do
- **files** — specific files the agent will likely read or modify
- **deliverables** — concrete list of outputs

If the input is ambiguous, ask the user to clarify before proceeding.

### Step 2: Confirm with the User

Present a table of the planned tasks:

```
| # | Branch | Type | Scope |
|---|--------|------|-------|
| 1 | feature/foo | code | Description... |
| 2 | feature/bar | design | Description... |
```

Ask the user to confirm, modify, or add tasks before launching.

### Step 3: Prepare the Base

Before launching agents:
1. Check for uncommitted changes. If any exist, ask the user to commit or stash first.
2. Ensure the current branch is up to date with the remote.
3. Note the current branch name — this is the base branch for all worktrees.

### Step 4: Launch All Agents

Launch one Agent tool call per task, ALL in a single message for maximum parallelism. Use these parameters:
- `isolation: "worktree"`
- `run_in_background: true`

**CRITICAL:** Every agent prompt MUST include this line near the top:

> IMPORTANT: You have full access to Bash, Read, Write, Edit, Glob, Grep, and all other tools. Use them freely.

Without this, worktree agents will sometimes refuse to run git commands.

Each agent prompt must include:
1. The line above about tool access
2. Context about the project (what it does, tech stack)
3. The branch name to create
4. A CLAUDE.md update block:
   ```
   ## Active Worktree: <branch-name-without-feature-prefix>
   This is a worktree branch for <scope>.
   Scope: <one-line scope>.
   Other parallel branches: <comma-separated list of sibling branches>
   ```
   This goes right after the `## Project:` heading in CLAUDE.md.
5. Specific files to read and modify
6. Clear deliverables list
7. Instruction to commit on the feature branch

### Step 5: Track Progress

As agents complete, handle each one:

**If the agent committed successfully:**
- Push the branch: `git push -u origin <branch-name>`

**If the agent wrote files but failed git operations:**
- Navigate to the worktree directory (from the agent result's `worktreePath`)
- Create the branch: `git checkout -b <branch-name>`
- Stage and commit the changes
- Push: `git push -u origin <branch-name>`

**For all branches before pushing:**
- Check if CLAUDE.md has an "Active Worktree" header — strip it. These are ephemeral context for the agent and should not land on the base branch.

### Step 6: Present Summary

When all agents are done, show a summary table:

```
| Branch | Type | Status |
|--------|------|--------|
| feature/foo | Code | Pushed |
| feature/bar | Design | Pushed |
```

### Step 7: Create PRs (when user requests)

Offer to create PRs. When doing so, follow this merge order:
1. **Design docs first** — they only add files to `docs/` and never conflict
2. **Code changes smallest-first** — measured by insertions + deletions

For each PR:
1. Fetch the latest base branch
2. Merge the base branch into the feature branch to surface conflicts:
   ```bash
   cd <worktree-path>
   git fetch origin
   git merge origin/<base-branch>
   ```
3. If there are conflicts:
   - **CLAUDE.md conflicts**: Always resolve by dropping the "Active Worktree" header block entirely
   - **Code file conflicts**: Take the feature branch's new code and integrate any additions from the base branch (e.g., imports, new functions added by previously-merged branches)
4. Commit the resolution and push
5. Create the PR with `gh pr create`
6. Report the PR URL to the user
7. Wait for the user to merge before proceeding to the next PR (earlier merges change the base for later ones)

### Step 8: Clean Up

After all PRs are merged, offer to clean up:
- Delete local worktree directories
- Delete remote feature branches (if the user wants)

## Guidelines

- **All agents launch in one message.** Never launch agents one at a time — the whole point is parallelism.
- **Always include the Bash permission note.** Worktree agents that don't see this will refuse git operations and produce incomplete results.
- **Strip worktree headers.** The "Active Worktree" CLAUDE.md headers are ephemeral agent context. Never let them land on the base branch.
- **Design docs merge first.** They're conflict-free and reduce the conflict surface for code branches.
- **Smallest code changes merge first.** This minimizes the blast radius of merge conflicts.
- **Don't modify the base branch directly.** All work happens in worktrees. The base branch only changes through PR merges.
- **One PR at a time.** Create, merge, then move to the next. Each merge changes the base for subsequent branches.
- **Warn about shared files.** If multiple code branches touch the same file, tell the user upfront that later merges will need conflict resolution.
