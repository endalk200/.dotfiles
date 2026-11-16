# Verify <app>

Drive <app> the way a user does and capture evidence that a behavior works. Feature recipes live in the [feature map](features/README.md). Run Doctor before the first drive and again after anything surprising.

## Launch

<exact command that starts the app for verification, including migrations and seed data>

Ready when: <observable signal that the app is usable>.

<how Launch records what it started: PID file, container ID, or session name>

## Doctor

<one read-only command>

Healthy when: <process up, expected build, port owned by this run, auth valid>.

## Drive

<harness recipe: how to run an action and read the result, with real commands from this repository>

## Evidence

Proof for a run lands in `<git-ignored directory>/<run-id>/`.

- Drive the real user path: the UI, command, or endpoint a user reaches.
- Capture the action and the resulting state, not only the final screen.
- Verify side effects (files written, rows inserted, messages sent) alongside what is visible.
- Mock only where a production boundary already isolates the external system.
- Treat a dry-run or test mode as unproven until you observe what it skips: files, network, git refs.

## Cleanup

<commands that stop exactly what Launch recorded and remove scratch state>

Cleanup removes instances and scratch state. Evidence stays at its named location.

## Helpers

The harness lives in `<docs/agents/verification/scripts/ or the repository path of its tooling>`. After changing tooling outside `scripts/`, `<check command>` stays green.

- `<script or command>`: <what it does>. Run `<invocation>`.
