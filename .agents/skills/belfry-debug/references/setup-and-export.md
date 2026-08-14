# Setup and Export

Read this reference when Belfry must be installed, started, configured, or
connected to a target Service.

## Resolve the CLI

Belfry requires Bun 1.3 or newer.

In the Belfry source repository:

```sh
bun run belfry -- daemon start --json
bun run belfry -- daemon status --json
```

With the published CLI:

```sh
bun add --global @belfry/cli
belfry daemon start --json
belfry daemon status --json
```

Run the global installation only when machine-level installation is in scope.
Use the command's JSON `endpoint` for every request. The built-in value is
`http://127.0.0.1:4318`, but configuration may select another loopback port.

Useful setup commands:

```sh
belfry config validate
belfry config init
belfry config path
belfry web --no-open
```

`config init` documents every supported limit. Configuration precedence is
environment, `~/.belfry/config.toml`, then built-in defaults.

## Read the health gates

Request `GET {endpoint}/api/health` and interpret the fields independently:

| Field | Gate |
| --- | --- |
| `live` | The Daemon can answer requests. |
| `migrationReady` | The Telemetry Store schema is available. |
| `writerReady` | OTLP requests may be committed. |
| `readsAvailable` | Query API reads may proceed. |
| `status` | `ok`, `degraded`, `starting`, or `stopping`. |
| `message` | The current actionable limitation when present. |

A degraded Daemon may still allow read-only investigation. Require
`writerReady: true` before testing export and `readsAvailable: true` before
searching.

## Configure the OTLP contract

Belfry accepts OTLP/HTTP traces and logs:

| Signal | Endpoint |
| --- | --- |
| Traces | `POST {endpoint}/v1/traces` |
| Logs | `POST {endpoint}/v1/logs` |

Use protobuf (`application/x-protobuf`) or OTLP JSON (`application/json`), with
optional gzip. Belfry does not receive metrics or OTLP/gRPC. An HTTP `200`
means the SQLite transaction committed.

Prefer the target's existing OpenTelemetry SDK or distribution. Extend its
providers with OTLP/HTTP exporters so instrumentation, sampling, propagation,
and shutdown remain owned in one place.

For SDKs that honor standard environment configuration:

```sh
export BELFRY_ENDPOINT='http://127.0.0.1:4318'
export OTEL_SERVICE_NAME=checkout
export OTEL_RESOURCE_ATTRIBUTES='service.namespace=shop,deployment.environment.name=development'
export OTEL_EXPORTER_OTLP_ENDPOINT="${BELFRY_ENDPOINT}"
export OTEL_EXPORTER_OTLP_PROTOCOL='http/protobuf'
export OTEL_TRACES_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
```

Set `OTEL_EXPORTER_OTLP_ENDPOINT` to the verified Daemon endpoint. A global base
endpoint lets an SDK append `/v1/traces` and `/v1/logs`. When configuring
signal-specific endpoints, use the complete URLs:

```sh
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="${BELFRY_ENDPOINT}/v1/traces"
export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT="${BELFRY_ENDPOINT}/v1/logs"
```

Confirm which environment variables the target SDK actually implements.
Preserve existing resource attributes when adding:

- `service.name`: stable component name; Belfry uses `unknown_service` when it
  is absent;
- `service.namespace`: groups related Services;
- `deployment.environment.name`: distinguishes local environments;
- `service.version`: useful when comparing behavior across builds.

The Service Filter identity is the exact tuple `(namespace, name, environment)`.
Spans in one trace may carry different Service identities.

## JavaScript/TypeScript correlation probe

Use the target's compatible OpenTelemetry package versions. This minimal shape
matches Belfry's repository acceptance fixture and proves explicit
trace/log export plus correlation:

```ts
import { context, SpanStatusCode, trace } from "@opentelemetry/api";
import { SeverityNumber } from "@opentelemetry/api-logs";
import { OTLPLogExporter } from "@opentelemetry/exporter-logs-otlp-http";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { resourceFromAttributes } from "@opentelemetry/resources";
import {
  LoggerProvider,
  SimpleLogRecordProcessor,
} from "@opentelemetry/sdk-logs";
import {
  BasicTracerProvider,
  SimpleSpanProcessor,
} from "@opentelemetry/sdk-trace-base";

const endpoint = process.env.BELFRY_ENDPOINT ?? "http://127.0.0.1:4318";
const resource = resourceFromAttributes({
  "service.namespace": "shop",
  "service.name": "checkout",
  "deployment.environment.name": "development",
});
const traces = new BasicTracerProvider({
  resource,
  spanProcessors: [
    new SimpleSpanProcessor(
      new OTLPTraceExporter({ url: `${endpoint}/v1/traces` }),
    ),
  ],
});
const logs = new LoggerProvider({
  resource,
  processors: [
    new SimpleLogRecordProcessor({
      exporter: new OTLPLogExporter({ url: `${endpoint}/v1/logs` }),
    }),
  ],
});

const span = traces.getTracer("belfry.probe").startSpan("belfry handshake");
const spanContext = trace.setSpan(context.active(), span);
logs.getLogger("belfry.probe").emit({
  context: spanContext,
  severityNumber: SeverityNumber.ERROR,
  severityText: "ERROR",
  eventName: "belfry.handshake",
  body: "recognizable Belfry probe",
});
span.setStatus({ code: SpanStatusCode.ERROR, message: "probe" });
span.end();

await Promise.all([traces.forceFlush(), logs.forceFlush()]);
await Promise.all([traces.shutdown(), logs.shutdown()]);
```

For a long-running application, use its established processors and lifecycle.
For a short-lived command or test, force-flush and shut down providers before
process exit. Emit a log with the active span context so its OTLP record carries
the trace and span IDs.

## Effect v4 export

Effect v4 requires explicit processors. Setting
`OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_TRACES_EXPORTER`, or
`OTEL_LOGS_EXPORTER` does not make `NodeSdk.layer` or `WebSdk.layer` construct
exporters.

Use `@effect/opentelemetry/NodeSdk` for Node applications. It reads
`OTEL_SERVICE_NAME` and `OTEL_RESOURCE_ATTRIBUTES`, but still needs the
processors below. Use `@effect/opentelemetry/WebSdk` for Bun or browser
applications and provide resource metadata explicitly. Belfry's Bun CLI uses
this shape:

```ts
import * as WebSdk from "@effect/opentelemetry/WebSdk";
import { OTLPLogExporter } from "@opentelemetry/exporter-logs-otlp-http";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { SimpleLogRecordProcessor } from "@opentelemetry/sdk-logs";
import { SimpleSpanProcessor } from "@opentelemetry/sdk-trace-base";
import { Effect } from "effect";

const endpoint = process.env.BELFRY_ENDPOINT ?? "http://127.0.0.1:4318";
const TelemetryLive = WebSdk.layer(() => ({
  resource: {
    serviceName: "checkout",
    serviceVersion: "development",
    attributes: {
      "service.namespace": "shop",
      "deployment.environment.name": "development",
    },
  },
  spanProcessor: [
    new SimpleSpanProcessor(
      new OTLPTraceExporter({ url: `${endpoint}/v1/traces` }),
    ),
  ],
  logRecordProcessor: [
    new SimpleLogRecordProcessor({
      exporter: new OTLPLogExporter({ url: `${endpoint}/v1/logs` }),
    }),
  ],
  loggerMergeWithExisting: true,
}));

const instrumented = program.pipe(
  Effect.withSpan("checkout"),
  Effect.provide(TelemetryLive),
  Effect.scoped,
);
```

`Effect.withSpan`, `Effect.annotateCurrentSpan`, `Effect.annotateLogs`, and
`Effect.log*` share the Effect runtime span context. The Effect OpenTelemetry
logger encodes `traceId` and `spanId` as log attributes; Belfry recognizes them
for correlation. Logs outside a span remain uncorrelated.

Keep the telemetry layer scoped: provider release force-flushes and shuts down.
`loggerMergeWithExisting` defaults to `true`; set it to `false` only when the
OpenTelemetry logger should replace the application's current loggers. Register
Node auto-instrumentations before importing modules they patch.

Effect v4 APIs are beta APIs. Inspect the target's installed
`NodeSdk.Configuration` or `WebSdk.Configuration` before adapting this
version-matched pattern. Effect interruptions are not necessarily exported as
error status, so investigate operation, attributes, and logs as well as
`status: "error"`.

`BELFRY_TELEMETRY` is separate: it opts Belfry's own CLI into self-telemetry and
does not configure a target application.

## Prove export

Take a before/after snapshot of `GET {endpoint}/api/ingestion/stats`. The key
counters are:

- `acceptedTraceRecords`
- `acceptedLogRecords`
- `rejectedRequests`
- `decodeErrors`
- `droppedRecords`
- `truncatedValues`

Exercise one recognizable operation and flush. The accepted counters for every
enabled signal must rise. Then list Services over that operation's time window
and match the full identity. A successful `OPTIONS` request proves only that an
HTTP server is reachable; accepted counters and Service discovery prove the
telemetry handshake.

Browser SDKs may export directly when the application origin is loopback HTTP
or HTTPS. Belfry rejects remote origins, non-loopback hosts, and deployment
behind a proxy because it is a local-development tool.
