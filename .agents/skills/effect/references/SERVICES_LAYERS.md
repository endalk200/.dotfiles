# Services, Layers, And Config

The installed `AGENTS.md` and its `03_services` examples own the `Context.Service` shape. This reference owns module surface, layer choice, wiring, and config.

## Module Surface

Follow the existing module style. When there is none, use a domain-named `Context.Service` class with its primary layers as static members.

```ts
export class NotFound extends Schema.TaggedError<NotFound, { readonly brand: unique symbol }>()(
  "UserRepo.NotFound",
  { id: UserId },
) {}

export class UserRepo extends Context.Service<UserRepo, {
  readonly get: (id: UserId) => Effect.Effect<User, NotFound | PersistenceError>
}>()("myapp/users/UserRepo") {
  static readonly layer = Layer.effect(
    this,
    Effect.gen(function* () {
      const sql = yield* SqlClient.SqlClient

      const get = Effect.fn("UserRepo.get")(function* (id: UserId) {
        // ...
      })

      return UserRepo.of({ get })
    }),
  )
}
```

Export the intentional service, error, and layer surface. Keep row codecs, local schemas, and implementation helpers private.

Expose a zero-argument operation as a readonly `Effect` value (`readonly list: Effect.Effect<...>`): an Effect is already lazy.

## Layer Constructors

```ts
Layer.succeed(Service, impl)       // already-built service
Layer.sync(Service, () => impl)    // lazy synchronous service
Layer.effect(Service, makeEffect)  // effectful acquisition; the default for real implementations
```

- Use `Layer.effectContext(...)` when one acquisition supplies several services, such as a first-class test stub or one client backing several service tags.
- Use `Layer.unwrap(...)` when config or runtime discovery chooses or builds the layer.
- Use `Layer.fresh(...)` or `Effect.provide(layer, { local: true })` only when a test or operation needs isolated acquisition.
- Use `Context.Reference` only for ambient references with a real safe default.

## Long-Lived Work

A layer that starts a stream, listener, worker, subscription, or forever loop forks that work into the layer scope, so layer acquisition completes.

```ts
export const layer = Layer.effectDiscard(
  Effect.gen(function* () {
    const events = yield* Events

    yield* events.stream.pipe(
      Stream.runForEach(handleEvent),
      Effect.forkScoped,
    )
  }),
)
```

- Use `Effect.forkScoped`, `FiberSet`, or `FiberMap` for scoped background work.
- Expose a public `start` method only when manual lifecycle control is part of the domain.

## Runtime Wiring

- Use `Layer.provide(...)` to hide an implementation dependency, and `Layer.provideMerge(...)` only when downstream consumers should still see it.
- Use `Layer.mergeAll(...)` for independent layers.
- Build the runtime layer as flat, topologically sorted values with named subgraphs, so authority and lifecycle dependencies stay visible.
- Provide layers at the application entrypoint, test, or runtime boundary rather than inside service code.

## Effect.fn Transforms

Extra `Effect.fn(...)` arguments wrap the whole call. Each receives `(effect, ...originalArgs)`.

```ts
const readAttachment = Effect.fn("Attachment.read")(
  function* (ref: AttachmentRef) {
    return yield* api.read(ref)
  },
  (effect, ref) =>
    effect.pipe(
      Effect.annotateLogs({ attachmentId: ref.id }),
      persistenceError("Attachment.read"),
    ),
)
```

Good whole-call transforms are error classification, localized recovery, log annotations, spans, retry, timeout, cleanup, small local provisioning, and result mapping. Keep the generator body on the core workflow, keep each function to one or two transforms, and handle local branches inside the body.

## Operation Error Helpers

For boundary errors that carry an operation label, share one curried `mapError` helper per error instead of hand-writing wrappers in every module.

```ts
const operationError =
  <E>(make: (fields: { readonly operation: string; readonly cause: unknown }) => E) =>
  (operation: string) =>
    Effect.mapError((cause: unknown) => make({ operation, cause }))

const persistenceError = operationError((fields) => new PersistenceError(fields))

const row = yield* query.pipe(persistenceError("UserRepository.findById"))
```

Name each helper after the error it produces (`persistenceError`, `projectionError`). Payload labels complement `Effect.fn` spans; they do not replace them.

## Config

Read runtime configuration through `Config` and provider layers, and keep direct environment access at the application boundary.

```ts
export const layerFromEnvironment = Layer.effect(
  Configuration,
  Effect.gen(function* () {
    const apiKey = yield* Config.Redacted("API_KEY")
    const model = yield* Config.option(Config.String("MODEL"))
    const enabled = yield* Config.Boolean("FEATURE_ENABLED").pipe(
      Config.withDefault(false),
    )
    const dataDirectory = yield* Config.schema(AbsolutePath, "APP_DATA_DIR")

    return Configuration.of({ apiKey, model, enabled, dataDirectory })
  }),
)
```

- `Config<T>` is yieldable and reads the current `ConfigProvider`; the default is `ConfigProvider.fromEnv()`.
- Use `Config.Redacted` for credentials, `Config.schema(schema, name)` or `Config.mapEffect` for refined values, and `Config.option` for semantic absence.
- `Config.withDefault` replaces missing data only; malformed values still fail. Use `Config.orElse` only when every parse failure should fall back.
- Built-in providers read an empty string as missing. Pass `{ preserveEmptyStrings: true }` when an empty value is meaningful.
- `ConfigProvider.layer(provider)` replaces the active provider; `ConfigProvider.layerAdd(provider)` adds a fallback, and `{ asPrimary: true }` makes it override.
- `ConfigProvider.constantCase` reads camelCase keys from `SCREAMING_SNAKE_CASE` variables; `ConfigProvider.nested(...)` scopes a provider under a prefix.
- Treat `.env`, directory, and environment providers as startup sources rather than business-workflow reads.

A library-style service can offer both a concrete `layer(options)` and a config-backed `layerConfig`, so tests pass plain values:

```ts
export const layerConfig = (config: Config.Wrap<ClientOptions>) =>
  Layer.effect(
    Client,
    Config.unwrap(config).pipe(
      Effect.flatMap(makeClient),
      Effect.map((client) => Client.of(client)),
    ),
  )
```

Config in tests lives in `TESTING.md`.
