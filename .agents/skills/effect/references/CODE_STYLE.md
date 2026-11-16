# Code Style And Control Flow

Match the project's established style first. The installed `AGENTS.md` owns `Effect.gen`, `Effect.fn`, and `Effect.fnUntraced`; this reference owns the choices it leaves open.

## Application Boundary

- Run a long-lived application with the platform `runMain` (`NodeRuntime`, `BunRuntime`, or `BrowserRuntime`) or with `Layer.launch` when the application is a layer.
- Put resource acquisition, finalizers, and teardown inside the main Effect so shutdown interrupts the application fiber and releases its scopes.
- Bridge into a host that owns the lifecycle (a web framework, worker queue, or callback API) with one `ManagedRuntime` built from the application layer.
- Reserve `Effect.runPromise` and `Effect.runSync` for tests, short scripts, and embedding.

## Callbacks And Dual APIs

Write callbacks explicitly: `Effect.map((value) => normalize(value))` rather than `Effect.map(normalize)`. Explicit callbacks keep inference through optional parameters and overloads, and keep stack traces legible.

For a dual API, use data-last inside a pipeline and data-first for one direct call. When both forms read equally well, follow the surrounding module.

## Sequencing

- Use a shallow `pipe` for a linear chain of transformations over one value.
- Use `Effect.gen` when later steps depend on earlier results, or the workflow has branches, loops, early failure, or several named intermediate values. It also replaces `Effect.Do` record plumbing.
- Extract a named `Effect.fn` operation when a generator still hides a distinct domain step.
- Use native `for` or `while` inside `Effect.gen` for loops with local state, `break`, or collected values; `Effect.forEach` for traversal; and `Effect.repeat` with a `Schedule` for time-based repetition.

## Branching And Pattern Matching

Use ordinary `if` for a simple boolean branch, including inside `Effect.gen`. Represent an expected invalid outcome as `Option` or a typed failure.

Use `Effect.when(effect, conditionEffect)` when the condition is itself an Effect: a false condition skips the source and yields `Option.none`, and a failed condition stays a typed failure.

Use `Match` when structural conditions or a closed union benefit from declarative, type-narrowed, exhaustive handling:

- `Match.type<T>()` builds a reusable matcher function; `Match.value(value)` matches one value immediately.
- Add cases with `Match.when`, `Match.not`, `Match.tag`, literal or object patterns, or built-in predicates such as `Match.string` and `Match.number`.
- Finish a closed union with `Match.exhaustive`.
- Use `Match.orElse` for a real fallback, `Match.option` when no match is expected absence, and `Match.result` when the unmatched input must remain available as failure data.
- Put `Match.withReturnType<T>()` first in the pipeline; placed later, it does not check every case.
- For `Data.TaggedEnum` and `Schema.TaggedUnion`, use their own exhaustive matchers (`references/SCHEMA.md`).

## Combining And Traversing Effects

- Use `Effect.zip` for two results kept as a tuple and `Effect.zipWith` when they are combined immediately.
- Use `Effect.all` for a known tuple, iterable, struct, or record of Effects; the result keeps the input shape.
- Use `Effect.forEach` to apply one effectful operation across an iterable; results keep input order.
- These operators run sequentially by default. Add concurrency only when the operations are independent and the downstream system permits it: `{ concurrent: true }` for `zip` and `zipWith`, a bounded `{ concurrency: n }` for `all` and `forEach`.
- Collections short-circuit on the first typed failure. Use `Effect.all(..., { mode: "result" })` when every outcome must be collected as a `Result`.
- Set `{ discard: true }` when only execution matters.
