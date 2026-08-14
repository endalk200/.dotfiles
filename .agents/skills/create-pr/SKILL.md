---
name: create-pr
description: File a concise pull or merge request.
disable-model-invocation: true
---

# File PR

Before filing, identify the source repository from the current branch's push remote, falling back to `origin` or the only configured remote. Resolve the destination separately: honor a user-specified repository; otherwise use the forge to detect the source repository's fork parent or upstream, falling back to the source repository itself. Ask when multiple destinations remain plausible.

Determine the provider from the destination host: use `gh` for GitHub, including GitHub Enterprise, and `glab` for GitLab, including self-managed GitLab. Use that CLI to find the destination's default branch and check for an open PR or MR from the source branch. Return a matching request instead of creating a duplicate.

Review the diff locally against the destination's default branch to make sure its contents match the goal. Push the current branch to the source repository when needed, then create the PR or MR non-interactively with explicit destination repository, source repository and branch, and target branch.

PR and MR titles usually become commit messages, so follow the repository's title conventions. Look at recently merged requests and Git history for examples. Prefer a concise, human-readable title that explains why the change matters:

BAD

> ❌ perf(server): negotiate permessage-deflate on the websocket

GOOD

> ✅ perf(server): cut websocket frame size by 70%+ with gzipping

Open the description with a simple explanation of the problem based on the user's original prompt, then briefly explain the solution. Put implementation details after that opening when they help reviewers:

BAD

> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD

> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

Treat these examples as shape, not evidence. Use measurements, first-person framing, and user-impact claims only when supported by the user's prompt, the diff, or observed verification.

Open a ready PR or MR so review bots run unless the user explicitly requests a draft. If the user also asked to babysit it, continue with the `babysit-pr` skill.
