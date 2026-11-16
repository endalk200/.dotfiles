---
name: setup-skills
description: "Configure this repo for the engineering skills: set up its issue tracker, triage and Wayfinder label vocabulary, and domain doc layout. Run once before first use of the other engineering skills."
disable-model-invocation: true
---

# Setup Skills

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker**: where issues live (GitHub by default; local markdown is also supported out of the box)
- **Triage and Wayfinder labels**: the strings used by whichever of those skills are installed
- **Domain docs**: where `GLOSSARY.md` and ADRs live, and the consumer rules for reading them

Explore the repository and prepare complete configuration drafts before the final approval checkpoint. Ask early only for missing choices that materially affect those drafts. Reuse decisions and write authorization already supplied by the user.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config`: is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root: does either exist? Is there already an `## Agent skills` section in either?
- `GLOSSARY.md` and `GLOSSARY-MAP.md` at the repo root, and the legacy `CONTEXT.md` / `CONTEXT-MAP.md`. If a legacy file exists, propose a `git mv` to its `GLOSSARY` name in the draft and use the new names in `docs/agents/domain.md`. If the user declines, record the legacy names in `docs/agents/domain.md` instead.
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/`: does this skill's prior output already exist?
- `.scratch/`: a sign that a local-markdown issue tracker convention is already in use
- Whether `triage` and `wayfinder` are installed, either as sibling skill folders or in the available skill catalog
- Monorepo signals such as `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or multiple populated packages with their own source roots

### 2. Present findings and ask

Summarise what is present and missing. Reuse existing configuration and accepted choices. Ask only for unresolved decisions needed to prepare complete drafts, grouping independent questions together. Include routine proposed defaults in the final draft instead of asking for approval at each section.

**Section A: Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-tickets`, `triage`, `to-spec`, `code-review`, and `wayfinder` read from and write to it. They need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:

- **GitHub**: issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab**: issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Local markdown**: issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.): ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

When `triage` is installed and the user picked **GitHub** or **GitLab**, record **PRs as a request surface: no** without asking. The tracker template explains the option so a repository that treats external PRs as requests can enable it later. For local-markdown and other trackers, omit the setting.

A GitHub or GitLab tracker needs a reachable repo. When the user picks one and no `git remote` points at that host, get the repo URL from them and include wiring it up (`git init` if needed, `git remote add origin <url>`) in the draft. The setup is done only when `gh repo view` / `glab repo view` prints the project from inside this directory; if it can't, stop and tell the user what's missing. In a fork, also check which repo `gh repo view --json nameWithOwner` resolves to, because `gh` can default to the upstream parent; record the intended repo in `docs/agents/issue-tracker.md`.

**Section B: Triage and Wayfinder label vocabulary.**

Run this section when `triage` or `wayfinder` is installed. Skip it when neither is installed.

> Explainer: Triage uses labels for categories and workflow states. Wayfinder uses labels to distinguish maps and decision-ticket types. Configure only the roles used by the installed skills so they map to strings that exist in the selected tracker.

If `triage` is installed, configure both category roles and state roles:

- `bug`: something is broken
- `enhancement`: new feature or improvement
- `needs-triage`: maintainer needs to evaluate
- `needs-info`: waiting on reporter
- `ready-for-agent`: fully specified, AFK-ready
- `ready-for-human`: needs human implementation
- `wontfix`: will not be actioned

If `wayfinder` is installed, configure its artifact roles:

- `wayfinder:map`: the shared map for one effort
- `wayfinder:research`: an AFK research ticket
- `wayfinder:prototype`: a prototype ticket
- `wayfinder:grilling`: a decision-making conversation
- `wayfinder:task`: prerequisite work that unblocks a decision

Default: each applicable role's string equals its name. Reuse compatible existing labels or user-specified mappings; include unresolved defaults in the complete draft for final approval.

For GitHub or GitLab, compare the proposed mapping with existing labels. Include any proposed label creations in the final draft and approval request, separately from local configuration writes. Create and verify labels (`gh label create` / `glab label create`) only when that external action is authorized. If declined, record the mapping and identify which installed skill cannot apply each missing role.

**Section C: Domain docs.**

> Explainer: Some skills (`improve-codebase-architecture`, `domain-modeling`, and `tdd`) read a `GLOSSARY.md` file to learn the project's domain language, and `docs/adr/` for past architectural decisions. They need to know whether the repo has one global context or multiple (e.g. a monorepo with separate frontend/backend contexts) so they look in the right place.

Default to **single-context** (one `GLOSSARY.md` plus `docs/adr/` at the repository root) in the draft. If exploration reveals unresolved monorepo layout choices, ask whether to use a root `GLOSSARY-MAP.md` pointing to per-context `GLOSSARY.md` files before preparing the final draft.

### 3. Confirm and edit

Resolve which instruction file to edit using step 4 before drafting. Show the user complete drafts of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md` and `docs/agents/domain.md`
- The contents of `docs/agents/triage-labels.md` when Section B ran

Include the exact target paths and any proposed external label creations. Incorporate feedback, then obtain approval for the complete drafts and required writes unless that scope is already authorized. Ask only about remaining unresolved choices or unauthorized actions.

### 4. Write

**Pick the file to edit:**

- If `AGENTS.md` exists, edit it.
- Else if `CLAUDE.md` exists, edit it.
- If neither exists, ask the user which one to create; don't pick for them.

When both exist, edit `AGENTS.md`. Never create one instruction file when the other already exists.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Skill labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Include the labels subsection only when Section B ran.

Then write the docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md): GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md): GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md): local-markdown issue tracker
- [triage-labels.md](./triage-labels.md): label mapping, only when Section B ran
- [domain.md](./domain.md): domain doc consumer rules + layout

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

### 5. Done

Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later; re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.
