---
name: spin-off-project
description: |
  Spin off an idea from the current conversation into a new GitHub repository.
  Creates the repo, clones it locally, scaffolds a CLAUDE.md capturing the
  context and vision from the conversation, and pushes the initial commit.
  Use when an idea has been explored and is ready to become its own project.
argument-hint: "<repo-name>: <short description>"
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
---

# Spin Off Project

You are spinning off an idea from the current conversation into its own GitHub repository.

## Input

The user has provided:

$ARGUMENTS

## What You Must Do

### Step 1: Parse the Input

Extract from the arguments:
- **repo-name** — the repository name (kebab-case, e.g. `voice-claude`). If not obvious, ask.
- **description** — a short one-line description for the GitHub repo

If the input is ambiguous or missing a clear repo name, ask the user before proceeding.

### Step 2: Gather Context from the Conversation

Before creating anything, review the current conversation to understand:
- What idea/project is being spun off
- What technical decisions have been made (language, framework, architecture)
- What the goals and motivations are
- What challenges or open questions exist
- Any planned structure or phased approach discussed

This context is the **most valuable part** of the skill — it's what makes this different from just `gh repo create`.

### Step 3: Offer the Monorepo Starter (if applicable)

If the project involves a **web application** (frontend, full-stack app, API with a web client, PWA, etc.), ask the user if they'd like to start from the **monorepo-starter** template (`evanstern/monorepo-starter`). This template provides a ready-to-run scaffold with:

- pnpm workspaces + Turborepo monorepo
- Hono + tRPC backend (`apps/server`)
- React Router 7 + Vite SSR frontend (`apps/web`)
- Shared packages: contracts (Zod schemas), shared (utils), ui (Radix + Tailwind components)
- Docker Compose for local dev
- Biome for linting/formatting

If the user says **yes**:
1. Clone `evanstern/monorepo-starter` into the project location (instead of creating an empty repo)
2. Create the new GitHub repo as usual
3. Update the git remote to point to the new repo
4. Find-and-replace `@monorepo-starter/` with `@<repo-name>/` across all package.json files
5. Find-and-replace `monorepo-starter` with `<repo-name>` in package.json (root), docker-compose.yml, and Dockerfiles
6. Update the CLAUDE.md with the actual project context (don't keep the starter's generic CLAUDE.md)
7. Update `apps/web/app/routes/home.tsx` meta title/description and page content for the new project
8. Proceed with the rest of the steps as normal

If the user says **no**, or the project doesn't involve a web app (e.g., CLI tool, library, script), skip this step and scaffold from scratch as usual.

### Step 4: Determine Project Location

The default location for new projects is the **parent directory of the current working directory**. For example, if you're in `/Users/evanstern/projects/evanstern/ideas`, create the project at `/Users/evanstern/projects/evanstern/<repo-name>`.

If the user specifies a different location, use that instead.

### Step 5: Check for Conflicts

Before creating anything, verify:
- The directory doesn't already exist locally
- The GitHub repo doesn't already exist (check with `gh repo view`)

If either exists, ask the user how to proceed.

### Step 6: Create the GitHub Repository

```bash
gh repo create <github-username>/<repo-name> --public --description "<description>" --clone=false
```

Use the GitHub username from the current git config or the existing repo's remote URL.

### Step 7: Clone and Scaffold

Clone the repo into the determined location, then create:

#### CLAUDE.md (REQUIRED — this is the most important file)

Write a CLAUDE.md that captures everything from the conversation:

```markdown
# CLAUDE.md

## Project: <repo-name>

<Clear description of what this project is and why it exists>

## Origin

<Where this idea came from — reference the conversation/exploration that led here>

## Architecture / Design (PROPOSED — verify with user before building)

<Any technical decisions, architecture diagrams, or design choices discussed>

**NOTE TO CLAUDE:** This architecture was captured from an initial brainstorming conversation.
Before implementing, walk through this design with the user to confirm it still reflects their
vision. Things may have evolved since this was written. Ask the user to review the architecture
and confirm or adjust before writing any code.

## Tech Stack

<Languages, frameworks, libraries, APIs decided on>

## Key Challenges

<Open questions, known hard problems, risks discussed>

## Project Structure (PROPOSED)

<Planned directory layout>

## Getting Started

When first opening this project in Claude Code:
1. **Review the architecture above with the user.** Confirm the proposed design, tech stack,
   and project structure are still what they want before writing code. Ask explicitly:
   "I've read the CLAUDE.md — does this architecture still match your vision, or has your
   thinking evolved?"
2. Then proceed with the phased build plan below.

### Build Phases

<Phased plan for building this out — what to do first, second, etc.>

## Commands

(To be filled in as we build)
```

The CLAUDE.md should be **thorough enough that a fresh Claude Code session can pick up the project with full context**. Don't be generic — include the specific details, decisions, and nuances from the conversation.

**CRITICAL:** The CLAUDE.md must instruct future Claude sessions to verify the architecture with the user before implementing. Ideas evolve — what was discussed in the spin-off conversation may not be the final vision.

#### .gitignore (REQUIRED)

Create an appropriate .gitignore for the project's language/framework.

#### Other Files (OPTIONAL)

Only create additional files if they were specifically discussed (e.g., package.json, tsconfig.json). Don't over-scaffold — the point is to capture context, not generate boilerplate.

### Step 8: Commit and Push

```bash
git add -A
git commit -m "Initial scaffold: CLAUDE.md with project vision and architecture

<2-3 line description of what was captured>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push -u origin <branch>
```

### Step 9: Report Back

Tell the user:
- The GitHub repo URL
- The local path where it was cloned
- A brief summary of what was captured in CLAUDE.md
- Remind them that the CLAUDE.md is set up so the first session will verify the architecture before building

## Guidelines

- **Capture, don't invent.** Only include decisions and details that were actually discussed. Don't fabricate architecture or make technical choices that weren't part of the conversation.
- **Be specific, not generic.** A good CLAUDE.md reads like meeting notes from the conversation, not a template.
- **Default to public repos.** If the user wants private, they'll say so.
- **Don't over-scaffold.** A CLAUDE.md and .gitignore are usually enough. The user will build the rest with Claude Code.
- **Preserve the "why".** The motivation and context behind decisions is more valuable than the decisions themselves.
- **Verify before building.** The CLAUDE.md must always instruct future sessions to confirm the architecture with the user before implementing anything.
