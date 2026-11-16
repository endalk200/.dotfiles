# Scheduling And Retry

The installed `ai-docs/src/06_schedule` example owns `Schedule` construction and composition. This reference owns retry semantics, worker failure policy, and provider-aware delays.

## Core Rules

- `Effect.retry(...)` retries typed failures; defects and interruptions are not retried.
- `Effect.repeat(...)` repeats successes; a failure stops repetition unless the pass handles it first.
- The source effect runs once before the schedule steps, so `Schedule.recurs(3)` means three retries or repetitions after the initial run.
- `Schedule.spaced(...)` waits after each run completes; `Schedule.fixed(...)` aligns runs to a cadence.
- Use `Schedule.exponential(...)` or `Schedule.fibonacci(...)` for backoff, add `Schedule.jittered` to avoid synchronized retry storms, and bound a delay schedule with `Schedule.upTo({ times })`.
- Use `Schedule.tap(({ input, output, duration, attempt }) => ...)` for retry logging or metrics.
- Use `Effect.retryOrElse(...)` when exhausted retries need a fallback or reporting effect.
- Retry only at the narrowest boundary with proven idempotency, and keep exhausted failures visible unless the boundary has a truthful fallback.

## Polling Workers

Log and drop expected pass failures with `Effect.ignore({ log, message })`. It discards typed failures only, so defects still reach supervision.

```ts
const run = runPass().pipe(
  Effect.ignore({ log: "Error", message: "Worker.pass_failed" }),
  Effect.repeat(Schedule.spaced("1 second")),
)
```

Recover selected typed failures with `Effect.catchIf(...)`, `Effect.catchFilter(...)`, `Effect.catchTag(...)`, or `Effect.retry(...)`. Reserve cause-level recovery for a supervision boundary whose policy is "report any non-interrupt failure and continue":

```ts
const logNonInterruptCauseAndContinue = (message: string) =>
  Effect.catchCauseIf(
    (cause) => !Cause.hasInterrupts(cause),
    (cause) => Effect.logError(message, cause),
  )
```

## Per-Item Failure Isolation

In a batch worker, drop expected item-level failures around each item so one bad item does not stall the batch:

```ts
yield* Effect.forEach(
  items,
  (item) =>
    processItem(item).pipe(
      Effect.ignore({ log: "Error", message: "Worker.item_failed" }),
      Effect.annotateLogs({ itemId: item.id }),
    ),
  { discard: true, concurrency: 5 },
)
```

Do this only when retrying the item later is truthful or skipping it is the product policy.

## Reusable Retry Policy

```ts
const projectionRetrySchedule = Schedule.exponential("100 millis").pipe(
  Schedule.setInputType<ProjectionError>(),
  Schedule.jittered,
  Schedule.upTo({ times: 5 }),
)

const reconcileWithRetry = (target: Target) =>
  reconcile(target).pipe(
    Effect.retryOrElse(
      projectionRetrySchedule.pipe(
        Schedule.tap(({ input: error }) =>
          Effect.logWarning("Agent.Projection.reconcile.retrying").pipe(
            Effect.annotateLogs({ operation: error.operation }),
          ),
        ),
      ),
      (error) => Effect.logError("Agent.Projection.reconcile.stopped", error),
    ),
  )
```

`Schedule.setInputType<E>()` types the schedule's input as the retried error, so `tap` and `modifyDelay` can read its fields.

## Rate-Limit-Aware Typed Retry

For provider errors that carry `retryAfterMs`, wait for the larger of the backoff delay and the provider delay:

```ts
type RateLimited = {
  readonly retryAfterMs?: number | undefined
}

const providerRetrySchedule = Schedule.exponential("200 millis").pipe(
  Schedule.setInputType<RateLimited>(),
  Schedule.jittered,
  Schedule.upTo({ times: 5 }),
  Schedule.passthrough,
  Schedule.modifyDelay(({ input, duration }) =>
    Effect.succeed(
      input.retryAfterMs === undefined
        ? duration
        : Duration.max(duration, Duration.millis(input.retryAfterMs)),
    ),
  ),
)
```

Use this for operation-level retries over typed provider errors. For HttpClient-level `429` handling and proactive pacing, read `HTTP_CLIENTS.md`.

## Timeouts And Delays

- Use `Effect.timeout(...)` when the operation has a real deadline.
- Use `Effect.delay(...)` when one operation should start later.
- Use `Effect.sleep(...)` in production workflows only when sleeping is itself the domain behavior.
- In tests, drive time with `TestClock`; read `TESTING.md`.
