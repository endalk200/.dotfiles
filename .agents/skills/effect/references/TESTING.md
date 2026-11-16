# Testing

The installed `ai-docs/src/09_testing` examples own `@effect/vitest` basics and shared-layer tests. This reference owns time, synchronization, fakes, and test config.

## Defaults

- Use `it.effect` by default; it runs with `TestClock`. Use `it.live` only when real time or live runtime services are the behavior under test.
- Use test layers and `ConfigProvider` rather than global mutation.
- Drive sleeps, schedules, retries, leases, and timeouts with `TestClock.adjust` or `TestClock.setTime` (`import { TestClock } from "effect/testing"`), forking the sleeping effect before advancing the clock.
- Synchronize deterministically; real sleeps belong only in `it.live` tests whose behavior is real time.
- Assert typed failures, rollback, interruption, finalization, retry bounds, idempotency, concurrency laws, and malformed persistence where relevant.

## Synchronization Instead Of Sleeps

- `Deferred` for one-shot readiness or completion signals.
- `Queue` for handing test-controlled work or observed events across fibers.
- `Latch` for reusable open/close gates.
- `Ref` for shared observation state.
- An explicit test hook when the production boundary can expose a deterministic synchronization point.

```ts
import { assert, it } from "@effect/vitest"

it.effect("publishes exactly once", () =>
  Effect.gen(function* () {
    const published = yield* Queue.unbounded<Message>()
    const ready = yield* Deferred.make<void>()

    const runWorker = makeWorker({
      onReady: () => Deferred.succeed(ready, undefined),
      onPublish: (message) => Queue.offer(published, message),
    })

    yield* runWorker.pipe(Effect.forkScoped)

    yield* Deferred.await(ready)
    const message = yield* Queue.take(published)

    assert.deepStrictEqual(message, expectedMessage)
  }),
)
```

## First-Class Test Stubs

For a reusable stateful fake that needs a control surface, extend the production interface with a second, test-only service tag and provide both tags from one layer.

```ts
export interface Interface {
  readonly send: (message: Message) => Effect.Effect<void, SendError>
}

export class Notifier extends Context.Service<Notifier, Interface>()(
  "myapp/notifier/Notifier",
) {}

export interface TestInterface extends Interface {
  readonly sentMessages: Effect.Effect<ReadonlyArray<Message>>
  readonly failNextSend: (error: SendError) => Effect.Effect<void>
}

export class NotifierTest extends Context.Service<NotifierTest, TestInterface>()(
  "myapp/notifier/NotifierTest",
) {}

export const testLayer = Layer.effectContext(
  Effect.gen(function* () {
    const sent = yield* Ref.make<ReadonlyArray<Message>>([])
    const nextFailure = yield* Ref.make<Option.Option<SendError>>(Option.none())

    const service = NotifierTest.of({
      send: Effect.fn("Notifier.Test.send")(function* (message) {
        const failure = yield* Ref.getAndSet(nextFailure, Option.none())
        if (Option.isSome(failure)) return yield* failure.value
        yield* Ref.update(sent, (messages) => [...messages, message])
      }),
      sentMessages: Ref.get(sent),
      failNextSend: (error) => Ref.set(nextFailure, Option.some(error)),
    })

    return Context.empty().pipe(
      Context.add(Notifier, service),
      Context.add(NotifierTest, service),
    )
  }),
)
```

- Back both tags with the same object; production code depends only on the real tag, and tests use the test tag for control and inspection.
- Match the production service shape, exposing zero-argument operations as readonly Effect values.
- Use `Layer.succeed` for a complete, static test implementation, and `Layer.mock` only for a tiny local partial mock whose omitted members should fail loudly.

## Config In Tests

- Use `ConfigProvider.layer(ConfigProvider.fromUnknown({ ... }))` when the test should exercise Config decoding.
- Use `Layer.succeed(AppConfiguration, config)` when the app wraps decoded config in its own service and the test does not need env decoding.
