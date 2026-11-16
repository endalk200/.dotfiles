# Schema And Data Modeling

The installed `ai-docs/src/01_effect/02_schema` example owns Schema basics. This reference owns representation choice, reuse, optionality, brands, variants, and errors.

## Records

Choose the representation from the decoded value the program needs:

| Representation | Decoded runtime value | TypeScript identity | Behavior |
| --- | --- | --- | --- |
| `Schema.Struct` | Plain object | Structural | Module-level functions |
| `Schema.Opaque` around a struct | The same plain object | Named and branded | Static members only |
| Direct schema subclass | Whatever the base schema decodes | Unchanged | Static members only |
| `Schema.Class` | Prototype-backed class instance | Named and branded | Static and instance members |

Use `Schema.Struct(...)` for an ordinary structural record.

```ts
export const User = Schema.Struct({
  id: UserId,
  name: Schema.NonEmptyString,
  email: Schema.optionalKey(Schema.String),
})

export type User = typeof User.Type
```

Use `Schema.Opaque` when the runtime value stays a plain object but the public type should be one named type.

```ts
export class Point extends Schema.Opaque<Point, { readonly brand: unique symbol }>()(
  Schema.Struct({
    x: Schema.Finite,
    y: Schema.Finite,
  }),
) {
  static readonly decode = Schema.decodeUnknownEffect(this)
}

const point = Point.make({ x: 1, y: 2 })
```

Treat the opaque class syntax as a thin type shell: construct with `.make(...)`, keep behavior static or module-level, and expect combinators such as `.annotate(...)` to return the wrapped struct rather than another opaque class.

Subclass an existing schema directly when it only needs co-located static helpers. The subclass keeps the base schema's decoded type and static helpers, including `.make(...)`, and adds no nominal identity, prototype, or `new` constructor.

```ts
export class UserName extends Schema.NonEmptyString {
  static readonly decode = Schema.decodeUnknownEffect(this)
}
```

Use `Schema.Class` when decoding must produce a real class instance or domain behavior belongs on each instance.

```ts
export class Point extends Schema.Class<Point, { readonly brand: unique symbol }>("geometry/Point")({
  x: Schema.Finite,
  y: Schema.Finite,
}) {
  static readonly origin = new Point({ x: 0, y: 0 })

  invert() {
    return new Point({ x: this.y, y: this.x })
  }
}
```

Class schemas support `new`, `.make(...)`, static and instance members, getters, and setters; preserve the prototype so `instanceof` and methods work; and compare structurally through `Equal.equals`.

### Brands On Schema Classes

Give every `Schema.Class`, `Schema.TaggedClass`, `Schema.Opaque`, `Schema.Error`, and `Schema.TaggedError` the brand type argument `{ readonly brand: unique symbol }`.

Without it, TypeScript accepts a plain object wherever the class type is expected when the visible fields match, yet the value never passed through the class transformation. In `HttpApi`, RPC, and other schema-driven handlers the response then compiles and fails at runtime encoding. The string identifier is runtime metadata (diagnostics, schema identity, hot reload) and cannot supply TypeScript nominality; make it stable and collision-resistant, such as a package-qualified name. When `@effect/tsgo` is configured, its Schema class completion writes the `Self` and brand arguments, and `schemaClassMissingBrand` flags a missing brand.

### Selection Rules

- `Schema.Struct` for DTOs, wire shapes, storage rows, and behavior-free records.
- `Schema.Opaque` for a named plain-object type with `.make(...)` and static helpers.
- A direct schema subclass to add static helpers without changing the decoded type.
- `Schema.Class` for prototypes, `instanceof`, instance behavior, or class-aware structural comparison.
- `Schema.TaggedClass` when a tagged variant needs class semantics; `Schema.TaggedStruct` when a plain tagged object is enough.

### Decoding And Construction

- Decode unknown encoded input at boundaries with `Schema.decodeUnknownEffect(...)`. When the input is already typed as the schema's `Encoded` type, use the typed `Schema.decodeEffect(...)`.
- Use `schema.makeEffect(...)` for typed constructor input whose validation failure belongs in the Effect error channel, and `schema.make(...)` when construction is trusted or throwing is acceptable.
- Use `Schema.decodeUnknownSync(...)` only in scripts, tests, or startup paths where throwing is acceptable.
- Use `Schema.decodeUnknownOption(...)` only when mismatch details are intentionally discarded, and `Schema.decodeUnknownResult(...)` for pure code that wants explicit success or failure.
- Add `.annotate({ identifier: "User" })` when tooling consumes it: HTTP API, RPC, OpenAPI or JSON Schema, docs, diagnostics, or codegen.

## Field And Contract Reuse

Reuse fields directly when contracts are semantically related.

```ts
export const CreateUserInput = Schema.Struct({
  name: User.fields.name,
  email: User.fields.email,
})

export const StoredUser = User.pipe(
  Schema.fieldsAssign({
    createdAt: Schema.DateTimeUtcFromString,
  }),
)
```

- Use `.fields`, `Schema.fieldsAssign(...)`, and `.mapFields(...)` for genuinely related contracts, building small related contracts rather than one oversized inheritance-by-schema object.
- Use `Schema.encodeKeys(...)` when decoded names differ from encoded wire or storage keys and naming is the only difference; keep explicit mapping when behavior, joins, validation, or domain translation is involved.
- Use `Schema.extendTo(...)` sparingly, for decoded-only derived fields.

## Optionality And Defaults

- Use `Schema.optionalKey(...)` for absent JSON or storage keys.
- Use `Schema.optional(...)` only when explicit `undefined` is part of the contract.
- Use `Schema.NullOr`, `Schema.UndefinedOr`, or `Schema.NullishOr` only when nullish values are part of the encoded contract.
- Keep normalized defaulted values as required fields and apply defaults in constructors or decoding.
- Model domain optionality from the contract, not construction convenience.

## Branded Values

Choose the constructor from where the invariant is enforced:

- A constrained branded schema for an ID or value object that crosses an unknown-input, persistence, or transport boundary. Apply schema constraints before `Schema.brand(...)` so validation and identity live in one codec.
- `Brand.nominal<A>()` for an internal distinction that needs identity without runtime validation, constructed where the value is already trusted.
- `Brand.make<A>(filter)` when an internal brand owns a runtime predicate. A direct call throws `BrandError`; use `.option`, `.result`, or `.is` when invalid input is expected.
- `Brand.all(...)` when one value must satisfy several brands over the same underlying type; derive the combined type with `Brand.Brand.FromConstructor<typeof Constructor>`.
- `Schema.fromBrand(...)` when a schema boundary reuses an existing `Brand` constructor; otherwise keep the constraint in Schema as the single source of truth.

`Brand.nominal` prevents accidental interchange at compile time; decode or validate values from outside the trusted domain before branding them.

## Variants

```ts
type Step = Data.TaggedEnum<{
  Continue: { readonly cursor: number }
  Finished: { readonly count: number }
}>

export const Step = Data.taggedEnum<Step>()

const next = Step.Continue({ cursor: 10 })
const label = Step.$match(next, {
  Continue: ({ cursor }) => `continue at ${cursor}`,
  Finished: ({ count }) => `finished ${count}`,
})
```

```ts
export const Event = Schema.TaggedUnion({
  Started: { runId: RunId },
  Finished: { runId: RunId, result: Schema.Json },
})

export type Event = typeof Event.Type

const event = Event.cases.Started.make({ runId })
const label = Event.match(event, {
  Started: ({ runId }) => `started ${runId}`,
  Finished: ({ runId }) => `finished ${runId}`,
})
```

Split by boundary: Data internally, Schema where values are validated or encoded.

- `Data.TaggedEnum` for internal control-flow algebras that need constructors, `$is`, and exhaustive `$match`.
- `Schema.TaggedStruct` for an ordinary `_tag` variant.
- `Schema.TaggedUnion` when the union needs decoding, encoding, persistence, wire validation, JSON Schema derivation, or composition.
- `Schema.tag(...)` when an external contract uses a custom discriminator such as `type` or `kind`, combined with `Schema.toTaggedUnion("type")` when union helpers are needed.
- `Schema.tagDefaultOmit(...)` when the encoded contract omits the discriminant.

## Errors

Define typed Effect errors with `Schema.TaggedError`, branded like any Schema class.

```ts
export class PersistenceError extends Schema.TaggedError<PersistenceError, { readonly brand: unique symbol }>()(
  "UserRepo.PersistenceError",
  {
    operation: Schema.String,
    cause: Schema.Defect(),
  },
) {}
```

- Map infrastructure failures into domain-specific tagged errors at service boundaries.
- Fail with the error itself: `return yield* new PersistenceError({ ... })`.
- Derive messages, status codes, or diagnostics with instance getters rather than redundant constructor fields.
- Include operation labels when they help diagnose adapter, persistence, provider, or transport failures.
- Use schema unions for public API or transport error surfaces, and `Schema.Defect()` for defect-like payloads.
- When one error has several distinct causes, give it a tagged `reason` field and recover with `Effect.catchReason` (see the installed `04_errors/20_reason-errors.ts` example).
- Preserve interruption when catching broad causes at ingress, worker, or stream boundaries.
