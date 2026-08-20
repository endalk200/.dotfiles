---
name: create-pr
description: Use when creating a pull or merge request.
disable-model-invocation: false
---

# File PR

Before filing, identify the source repository from the current branch's push remote, falling back to `origin` or the only configured remote. Resolve the destination separately: honor a user-specified repository; otherwise use the forge to detect the source repository's fork parent or upstream, falling back to the source repository itself. Ask when multiple destinations remain plausible.

Determine the provider from the destination host: use `gh` for GitHub, including GitHub Enterprise, and `glab` for GitLab, including self-managed GitLab. Use that CLI to find the destination's default branch and check for an open PR or MR from the source branch. Return a matching request instead of creating a duplicate.

Before filing, list the destination repository's existing labels with their descriptions. Choose the smallest set whose documented meanings match the actual change. Use only labels that already exist; if none clearly apply, leave the request unlabeled instead of inventing or creating one. Resolve "me" through the forge CLI's currently authenticated account, not from the Git author or email. Stop and report the blocker if the CLI cannot resolve that identity.

Review the diff locally against the destination's default branch to make sure its contents match the goal. Push the current branch to the source repository when needed, then create the PR or MR non-interactively with explicit destination repository, source repository and branch, target branch, selected labels, and the authenticated account as assignee.

PR and MR titles often become merge or squash commit subjects. Follow the repository's title conventions after inspecting recently merged requests and Git history. Prefer a concise title that names the observable behavior or outcome. Mention an implementation mechanism only when it distinguishes the change. Include a measurement only when observed verification supports it. Put the cause, rationale, trade-offs, and supporting implementation detail in the description.

Examples:

```text
Weak:   feat(auth): add password reset flow
Better: feat(auth): let users reset forgotten passwords

Weak:   perf(server): negotiate permessage-deflate on websocket
Better: perf(server): reduce websocket frame size with compression
```

When verification measured the result, prefer the verified outcome:

```text
perf(server): cut websocket frame size by 70%
```

Open the description with a simple explanation of the problem based on the user's original prompt, then briefly explain the solution. Put implementation details after that opening when they help reviewers:

BAD

> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD

> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

Treat the description examples as shape, not evidence. Use first-person framing and user-impact claims only when supported by the user's prompt, the diff, or observed verification.

Open a ready PR or MR so review bots run unless the user explicitly requests a draft. Fetch the created request and verify that its source, target, labels, and assignee match the intended values before reporting success. If the user also asked to babysit it, continue with the `babysit-pr` skill.
