---
name: maintain-verification
description: Use only when the user invokes it to audit or update the repository's verification runbook and feature map.
disable-model-invocation: true
---

# Maintain Verification

A feature map goes stale the moment the app changes. This pass checks every feature in `docs/agents/verification/` against the source and against the running app, then ships proven corrections. The unit of rigor is the feature: every feature file gets a source read and a live drive, without proving every sentence.

When `docs/agents/verification/` does not exist, stop and point the user at the `setup-verification` skill.

## Outcomes

End with exactly one, and name it:

- **clean**: every feature got source and live coverage, and nothing needs to change. No branch, no PR.
- **changed**: one PR ships proven corrections to the runbook, harness, or map.
- **blocked**: coverage could not finish, or a proven fix could not ship safely. Name exactly what blocked it.

## Edit scope

Edit only `docs/agents/verification/`. Product code stays untouched for the whole run. When the app no longer does what the map says, the mismatch is either **drift** (the map is wrong, so fix the map) or a **product gap** (the app is broken, so report it and leave the map describing the intended behavior).

## Pass

1. **Index.** Read `features/README.md` and list its sibling files. Fix missing, extra, duplicate, and dead entries.

2. **Source read.** Take the feature files one at a time. For each, read the source behind the feature and write a run note: a feature summary, its source entry points, likely drift with `file:line` citations or "none", and one live recipe. Done when every feature file has a note.

3. **Reconcile.** Merge the recipes into as few app states as practical. Spot-check each cited drift against the source. Then read `git log <last commit touching docs/agents/verification/>..HEAD` for user-facing surfaces the map lacks, and call a surface missing only with a concrete source path.

4. **Live pass.** Required even when the source read found nothing. Follow the runbook's launch model: one long-lived instance driven serially for servers and UIs, or a fresh isolated session per drive for a short-lived CLI. Drive every feature at least once, and hold three invariants for the whole pass:
   - **Doctor first.** Run Doctor before the first drive, on each fresh session, and after any failed drive. When Doctor cannot see the failure (a wedged UI on a healthy process), reset to a known state or relaunch.
   - **Evidence survives.** After every Cleanup, check the evidence at its named location.
   - **No residue.** Clean what each failed drive started, whether its session is stuck, exited, or shared. On a shared instance, clean the residue and keep the instance.

   A Doctor failure caused by runbook drift is drift: fix it within edit scope, restart only what the fix invalidated, and retry once before calling the pass blocked. A feature is **unreachable** only with its concrete prerequisite (auth, entitlement, OS, external state) and the route attempted; a prerequisite the map omits is drift. Final Cleanup runs after the last drive of the pass, including the re-drives from step 5.

5. **Triage.** Sort each finding:
   - **Drift:** the map's user-POV description is wrong or missing. Fix the map.
   - **Harness gap:** the app works, but the runbook cannot drive it. Fix the harness, keeping every script in `scripts/` executable with its invocation shown in the runbook, then re-drive the feature live.
   - **Product gap:** the app is broken. Record it with its evidence for the report, outside this change.

6. **Ship or stop.** For changed, re-read every changed file, commit on a new branch with the `commit` skill, and open one PR with the `create-pr` skill. For clean or blocked, stop without a branch.

Keep run notes (features covered, unreachable prerequisites, confirmed drift, outcome) beside this run's evidence, where git ignores them.

## Report

Tell the user the outcome, the features covered by source and live, each drift and harness gap fixed, each product gap with its evidence path, each unreachable feature with its prerequisite, and the PR link when the outcome is changed.
