---
name: effect
description: |
  Use when writing, reviewing, or debugging Effect v4 code: Schema models, services and Layers, Config, retry or polling, caching, Streams, outgoing HTTP, Atom or reactivity UI state, or Effect tests.
compatibility: Requires Effect v4 (4.0.0 or later). Last checked against effect 4.1.4 and @effect/tsgo 0.69.0 in November 2026.
---

# Effect

This skill holds the _decisions_: which Effect API fits a situation, and which boundary owns it. The installed `effect` package holds the _facts_: its API, its examples, and its own agent guide. When the two disagree on a fact, the installed package wins.

## Start

1. Read the installed package's `AGENTS.md` (for example `node_modules/effect/AGENTS.md`) once per task, and the `ai-docs/src/` example it links for each topic you touch. It owns the basics: `Effect.gen`, `Effect.fn`, `Context.Service`, error handling, and running programs.
2. When an API named here fails to typecheck, or behaves differently than described, confirm it in `node_modules/effect/src/<Module>.ts` and follow the installed version; read the `source-context` skill completely and follow it when you need upstream tests or history.
3. Find the project's Effect diagnostics: an `effecttsgo` preset in the oxlint config, an `effect-tsgo` or `effect-language-service` script in `package.json`, or the `@effect/language-service` plugin in `tsconfig.json`. Its rule severities settle style questions. HTTP, reactivity, and `@effect/vitest` APIs are marked `@stability unstable`, so follow the project's `unstable-api-usage` setting.
4. Load only the references whose branch the change touches.

## Branch Chooser

- Program entrypoints, pipelines versus generators, branching, pattern matching, loops, or combining and traversing effects: read `references/CODE_STYLE.md`.
- Data models, schemas, brands, variants, optional keys, typed errors, or decoders: read `references/SCHEMA.md`.
- Services, layers, runtime wiring, `Effect.fn` transforms, background work, or `Config` and `ConfigProvider`: read `references/SERVICES_LAYERS.md`.
- Retry, repeat, polling, backoff, jitter, or rate-limit-aware policies: read `references/SCHEDULING.md`.
- Memoization, per-key TTL caches, deduplicating concurrent lookups, or request batching: read `references/CACHING.md`.
- Streams, event sources, callbacks, queues or pubsubs, pagination, backpressure, or stream consumers: read `references/STREAMS.md`.
- Outgoing HTTP calls, status handling, or HTTP rate limiting: read `references/HTTP_CLIENTS.md`.
- `effect/reactivity`, `@effect/atom-*`, `AsyncResult`, API-backed UI, atom runtimes, reactivity keys, optimistic updates, or stream-backed UI state: read `references/EFFECT_ATOM.md`.
- Effect tests, time, sleeps, concurrency synchronization, fakes, or test config: read `references/TESTING.md`.

## Cross-Cutting Defaults

- Keep expected failures typed; let defects and interruption reach the owning supervision boundary.
- Give Schema classes, errors, and opaque types a brand type argument (`references/SCHEMA.md`).
- Decode unknown boundary input with `Schema.decodeUnknownEffect`; use `schema.makeEffect` for typed constructor input whose validation can fail.
- Scope long-lived resources and background work to the Layer or component that owns their lifetime.
- Retry only idempotent operations, at the narrowest boundary that can classify the failure truthfully.
- Solve Effect typing problems with precise types rather than unchecked casts or non-null assertions.

## Boundary Rules

- Keep HTTP handlers thin: decode input, read context, call services, map typed errors to transport responses.
- Place business rules in services or domain functions.
- Wrap HTTP clients, SDKs, CLIs, and external integrations in named effects at adapter boundaries.
- Decode persisted rows with Schema or SQL-specific helpers when values are not trivially trusted.
- Keep provider and network calls outside authoritative database transactions.
- Catch or retry only where the current boundary has a truthful response, and let exhausted failures stay visible unless the boundary has a real fallback.

## Completion Criterion

Before finishing:

- every Effect API introduced or changed typechecks against the installed version
- the guidance of every touched branch is applied
- the narrowest relevant typecheck and tests pass
- the project's Effect diagnostics report nothing new on the changed files: run its lint (`oxlint --type-aware <files>` with an `effecttsgo` preset), its patched `tsc`, or `effect-language-service diagnostics --file <file>`
- the change introduces no unchecked cast, swallowed interruption, unscoped long-lived work, or unbounded retry

The work is complete only when every item above is checkable and satisfied.
