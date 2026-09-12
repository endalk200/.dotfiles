---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user to resolve the decisions needed for the agreed outcome. Map those decisions as a **design tree**; keep unrelated branches outside the session scope and preserve decisions already settled.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Each question should be formatted like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), use the host's isolated-agent mechanism to find it — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the agent to report — ask the rest of the frontier now. The _decisions_ are the user's — put each to them and wait.

The session is done when the decisions needed for the agreed outcome are resolved. Summarize those decisions and any remaining assumptions. Live human decisions still require the user's answers; do not answer on their behalf. Continue into execution only when it is part of the authorized request, asking for confirmation only if a material decision remains unresolved.
