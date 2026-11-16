---
name: setup-verification
description: Use only when the user invokes it to set up scripted verification of a repository's running app.
disable-model-invocation: true
---

# Setup Verification

Give the repository a scripted way for any agent to launch the real app, drive a feature the way a user does, and capture evidence. The output is a runbook and a feature map in `docs/agents/verification/`, reached from `AGENTS.md` or `CLAUDE.md`, so every coding agent finds it the same way. Write both for an agent that reads them cold, mid-task, and has never seen the app.

When `docs/agents/verification/` already exists, stop and point the user at the `maintain-verification` skill.

## 1. Survey the repository

Answer these from the code, and ask the user only what the code cannot answer:

- **Surface:** what a user touches: a web UI, a CLI or TUI, a desktop app, an API, a mobile app, a library. Pick the primary surface and note the others.
- **Run:** the repository's own dev command (package scripts, Makefile, README quickstart), with its ports, env vars, seed data, and auth.
- **Drive:** a shell command that exercises the surface. Existing harnesses come first: Playwright or Cypress specs, expect scripts, PTY helpers, curl-able endpoints, a debug port. Otherwise use a browser automation script for web and Electron, tmux or a PTY for a CLI or TUI, and plain HTTP for a service. Every drive is a shell command, so any agent on any machine can follow it.
- **Observe:** the evidence available: screenshots, terminal transcripts, response bodies, logs, exit codes, database state.
- **Isolate:** whether two instances can run side by side (ports, data dirs, profiles). When they cannot, the runbook says so and drives only an instance the run started itself.

The checkout must build and start before you write anything, because a runbook written against a broken base teaches wrong steps. Fix the build, or report exactly what blocks it. When an irrelevant missing asset blocks startup (a static dir the app never serves, a sample config), the runbook may create it as marked verification scaffolding and remove it in Cleanup.

## 2. Write the runbook

Write `docs/agents/verification/README.md` from [runbook.md](runbook.md), replacing every `<...>` with real commands, paths, selectors, and ports from the survey. Each section must meet its bar:

- **Launch** reaches a usable state from an empty data dir, including migrations and seed data, and names the signal that proves readiness. Ready means usable: a database health check can pass while its init scripts still run. For a short-lived CLI or TUI, Launch builds or installs once, and each drive opens its own isolated PTY or tmux session.
- **Doctor** answers "is this instance worth driving?" in one read-only command: process up, expected build, port owned by this run, auth valid.
- **Drive** uses stable handles (ARIA roles and names, data attributes, prompt strings, route paths) over coordinates and tab order.
- **Evidence** names a git-ignored directory. Add it to `.gitignore` when it is missing.
- **Cleanup** stops exactly what Launch started, by the PID, container, or session name Launch recorded.
- **Helpers** lists each script in `docs/agents/verification/scripts/`. Every script is executable and its invocation is shown. Delete the section when no script ships.

## 3. Seed the feature map

Write `docs/agents/verification/features/README.md` and one file per user-facing feature, starting with the top 3 to 5 found in routes, commands, menus, or docs. Follow the shape in [references/feature-map-example/](references/feature-map-example/): the index carries baseline preconditions, driving conventions, proof reporting, the entry contract, and the feature list; each feature file carries an H1, a one-paragraph description of the user-visible behavior, and four H2s in order: `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, `Gotchas`.

Write every file from the user's point of view. A feature's proof covers every entry point its file lists. When the seed data lacks a precondition a journey needs, the journey reports a failure and the reason goes in that feature's `Gotchas`; the journey keeps its full user path.

## 4. Prove it

Follow the runbook end to end as the next agent would: Launch, Doctor, drive one mapped feature, capture evidence, Cleanup. Then confirm the evidence still exists at its named location. Fix what fails, and run Cleanup after every failed attempt so no process or port outlives it. Done when one full pass succeeds and its evidence survives Cleanup.

When you proved it in a stand-in for the real target (a container for a fresh VM, a local stack for a remote one), list every setup step the stand-in did that the target will not. Those steps stay unverified until a run on the real target covers them.

## 5. Point agents at it

Add this subsection to the `## Agent skills` block of `AGENTS.md`, or of `CLAUDE.md` when only that file exists. When neither exists, ask the user which to create. Create the block when it is missing, and update an existing `### Verification` subsection in place.

```markdown
### Verification

Before calling a user-facing change done, reproducing a bug in the running app, or confirming a review finding live, follow `docs/agents/verification/README.md`.
```

## 6. Hand off

Report the surface and harness you chose, the features mapped, the evidence path from the proof run, every unverified step, and that the `maintain-verification` skill keeps the map current as the app changes.
