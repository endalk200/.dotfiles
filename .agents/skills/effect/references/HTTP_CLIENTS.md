# HTTP Clients

The installed `ai-docs/src/50_http-client/10_basics.ts` example owns HttpClient setup: a service that configures one client with `HttpClient.mapRequest`, `HttpClient.filterStatusOk`, and `HttpClient.retryTransient`, then decodes bodies with `HttpClientResponse.schemaBodyJson`. Import the modules from `effect/http`. This reference owns boundary shape and retry choice.

Use Effect HttpClient for outgoing HTTP in Effect application and provider code. Raw `fetch` stays reasonable for platform transports and libraries that deliberately avoid the HTTP modules.

## Boundary Shape

An HTTP adapter method is a named effect that owns the full boundary:

- construct the request, attaching auth and headers
- execute it
- classify the status before decoding
- decode the response body with Schema
- map transport, status, and decode failures to typed domain errors
- apply retry or rate-limit policy where the operation is idempotent

Keep raw provider and network effects outside business services and database transactions.

## Decoding Responses

- `HttpClientResponse.schemaBodyJson(schema)` decodes the body only.
- `HttpClientResponse.schemaJson(schema)` decodes status, headers, and body together, for contracts that branch on status.
- `HttpClientResponse.schemaNoBody(schema)` decodes status and headers without reading a body.
- `HttpClientRequest.schemaBodyJson(schema)` encodes a request body through a schema.

## Retry And Rate Limits

- `HttpClient.retryTransient(...)` retries transport errors, timeouts, and `408`, `429`, `500`, `502`, `503`, and `504` responses. Apply it to idempotent requests.
- `HttpClient.withRateLimiter(...)` paces requests proactively and learns from rate-limit and `Retry-After` headers. It requires a `RateLimiter` plus initial window, limit, and key options, adds `RateLimiterError` to the error channel, and retries `429` responses without limit unless `times` is set.
- Use operation-level `Effect.retry(...)` when retry depends on domain-specific typed errors, provider payloads, or idempotency rules; read `SCHEDULING.md` for `retryAfterMs`-aware schedules.

## Raw Fetch Exception

When raw `fetch` is unavoidable, keep it inside an adapter service with the same boundary discipline:

```ts
const request = Effect.fn("Provider.request")(function* (input: RequestInput) {
  const response = yield* Effect.tryPromise({
    try: (signal) => fetch(input.url, { signal, headers: input.headers }),
    catch: (cause) => new ProviderError({ operation: "Provider.request", cause }),
  })

  if (!response.ok) {
    return yield* new ProviderRejected({
      operation: "Provider.request",
      status: response.status,
    })
  }

  const json = yield* Effect.tryPromise({
    try: () => response.json(),
    catch: (cause) => new ProviderError({ operation: "Provider.decodeJson", cause }),
  })

  return yield* Schema.decodeUnknownEffect(ResponseSchema)(json).pipe(
    Effect.mapError((cause) =>
      new ProviderError({ operation: "Provider.decodeResponse", cause }),
    ),
  )
})
```

- Pass the `AbortSignal` from `Effect.tryPromise` into `fetch` so interruption cancels the request.
- Classify the status before decoding a successful payload.
- Preserve provider evidence needed for diagnosis, and redact secrets and private payloads.
- Prefer moving the adapter to HttpClient before adding more behavior to it.
