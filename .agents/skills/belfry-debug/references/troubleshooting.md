# Troubleshooting

Read this reference when the telemetry handshake, a Query API request, or an
expected correlation fails. Diagnose from the Daemon outward and stop at the
first layer whose evidence is wrong.

## 1. Daemon and Store

Run:

```sh
belfry daemon status --json
curl -sS "${BELFRY_ENDPOINT}/api/health"
curl -sS "${BELFRY_ENDPOINT}/api/ingestion/stats"
```

Use `bun run belfry --` in the Belfry source repository. Confirm the endpoint
from status and health identify the same Daemon.

- `live: false` or no response: start/adopt the Daemon.
- `writerReady: false`: exports cannot commit; use `message` and foreground
  `belfry daemon serve` output.
- `readsAvailable: false`: preserve health as the query limit.
- `degraded` with reads available: continue read-only investigation and report
  the write limitation.

## 2. Export transport and ingestion

Compare ingestion statistics before and after one recognizable operation and
exporter flush.

| Symptom | Evidence to collect |
| --- | --- |
| No accepted-counter delta | Resolved endpoint, exporter URL/protocol, enabled signal, sampling, exporter callback/error, flush/shutdown |
| `rejectedRequests` rose | Recent ingestion diagnostics and OTLP HTTP status |
| `decodeErrors` rose | Diagnostic code/message, content type, encoding, and payload |
| Traces rise but logs do not | Log provider/bridge, OTLP log exporter, log processor, and shutdown flush |
| Logs rise but traces do not | Tracer provider, sampler, ended spans, trace exporter, and shutdown flush |
| `droppedRecords` or `truncatedValues` rose | SDK dropped counts plus Belfry's configured indexing/cardinality limits |

List recent diagnostics:

```sh
curl -sS --get "${BELFRY_ENDPOINT}/api/ingestion/diagnostics" \
  --data-urlencode "fromNs=${FROM_NS}" \
  --data-urlencode "toNs=${TO_NS}" \
  --data-urlencode "limit=100"
```

OTLP ingest statuses mean:

| Status | Meaning |
| --- | --- |
| `200` | SQLite transaction committed |
| `400` | Malformed or invalid OTLP |
| `413` | Compressed or decompressed size limit |
| `415` | Unsupported content type or encoding |
| `429` | Bounded ingestion capacity full |
| `503` | Writer, migration, or storage unavailable |

An `OPTIONS` response proves reachability only. Accepted counters prove commit.

## 3. Service identity and time

When a Service is absent:

1. Verify `service.name` on the exported resource.
2. Match optional namespace and environment exactly; absence and an empty string
   are different identities.
3. Use the operation's actual timestamp, not only the current time.
4. Check retention and the configured maximum lookback.
5. List Services without a Service Filter before narrowing.

`unknown_service` proves Belfry accepted records whose resource lacked
`service.name`.

## 4. Search and detail

When a known record is missing from search:

1. Search its exact trace ID or span correlation ID.
2. Remove speculative text and attribute filters.
3. Widen only the bounded time range.
4. Exhaust every cursor page.
5. Check `filterableAttributeKeys` before relying on an attribute filter.
6. Open `/openapi.json` after a `400` to compare against the running schema.

Text search is a bounded projection, not a scan of every retained detail.
Sensitive, non-scalar, oversized, and high-cardinality identity-like
attributes may remain visible in detail while absent from search indexes.

A `404` for an exact ID can mean the ID or endpoint is wrong, or the record has
left the retention boundary. Trace IDs are canonical lowercase 32-character
hex; span IDs are canonical lowercase 16-character hex.

## 5. Trace/log correlation

Exact trace correlation requires a canonical `traceId`. A canonical `spanId`
is optional; when present, it narrows the correlation to a specific span. Emit
the log while the intended span context is active, and propagate context across
asynchronous and cross-Service boundaries.

Belfry also recognizes canonical IDs in log attributes named `traceId` or
`trace_id`, and `spanId` or `span_id`, for SDK bridges that encode Effect span
context as attributes. The span ID fallback is used only when a trace ID is
present.

When correlated-log endpoints are empty:

1. Open the full log detail and inspect its `traceId` and `spanId`.
2. Verify the log was emitted inside the intended span context.
3. Search logs by Service, time, text, or attributes to find uncorrelated
   records.
4. Label timestamp/text similarity as inference rather than exact correlation.

For cross-Service gaps, inspect propagation, sampling, missing parents, links,
and every participating Service. Structural warnings describe the received
graph and can expose incomplete propagation or export without identifying the
cause by themselves.

For Effect v4 HTTP, verify propagation is enabled and inspect W3C
`traceparent` plus B3 headers at the client/server boundary. Preserve trace
flags and trace state when continuing a remote trace; otherwise sampling and
parentage can diverge even when the trace ID appears familiar.

## 6. Privacy and local boundary

Telemetry may contain credentials, cookies, personal data, SQL, prompts, and
request bodies. Redact at instrumentation before retrying export. Belfry keeps
complete retained details locally even when a key is excluded from search
indexes.

Belfry accepts loopback hosts and loopback browser origins only. A remote
website, proxy, container, or virtual machine needs a genuinely local
loopback-reachable arrangement; Belfry has no remote-bind mode.
