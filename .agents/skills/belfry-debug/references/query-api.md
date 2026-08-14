# Query API

Read this reference before querying Belfry. Use the endpoint reported by
`daemon status --json`, not a remembered port.

## Construct a bounded time window

The Query API represents nanoseconds as decimal strings. This example produces
a recent 15-minute window using Bun:

```sh
TO_NS="$(bun -e 'process.stdout.write((BigInt(Date.now()) * 1000000n).toString())')"
FROM_NS="$(bun -e 'process.stdout.write(((BigInt(Date.now()) - 15n * 60n * 1000n) * 1000000n).toString())')"
```

Set `BELFRY_ENDPOINT` to the verified endpoint:

```sh
BELFRY_ENDPOINT='http://127.0.0.1:4318'
```

The configured maximum lookback is normally seven days, the result ceiling is
normally 500, and the query timeout is normally two seconds. Narrow time
bounds first when a query times out.

## Inventory Services

```sh
curl -sS --get "${BELFRY_ENDPOINT}/api/services" \
  --data-urlencode "fromNs=${FROM_NS}" \
  --data-urlencode "toNs=${TO_NS}" \
  --data-urlencode "limit=100"
```

Each item includes the exact `service` identity, first/last seen timestamps,
span/log/error counts, and `unknownService`. Trace Service Filters match when
any span in a trace has one selected identity; trace detail still includes
every participating Service.

## Search traces

Every trace search requires `fromNs`, `toNs`, `services`, `attributes`, `sort`,
and `limit`. This example also includes optional filters:

```sh
curl -sS "${BELFRY_ENDPOINT}/api/traces/search" \
  -H 'content-type: application/json' \
  --data @- <<JSON
{
  "fromNs": "${FROM_NS}",
  "toNs": "${TO_NS}",
  "services": [
    {
      "namespace": "shop",
      "name": "checkout",
      "environment": "development"
    }
  ],
  "status": "error",
  "attributes": [],
  "sort": "newest",
  "limit": 100
}
JSON
```

Optional trace filters are `operation`, `status`, `minimumDurationNs`,
`maximumDurationNs`, `traceId`, `text`, and `cursor`. Omit an optional filter
instead of sending an empty value. Valid status values are `all`, `error`,
`ok`, and `active`; valid sorts are `newest`, `oldest`, and `slowest`.
`operation` is a contains filter on the root operation.

Add bounded attribute evidence with:

```json
{
  "attributes": [
    {
      "key": "inventory.sku",
      "operator": "equals",
      "value": "BELFRY-42"
    }
  ]
}
```

Start with the smallest set justified by the symptom. `status: "error"` means
at least one stored span has OTLP status code `2`. `ok` excludes active traces.
`active` finds traces with at least one span lacking an end timestamp.

## Search logs

Every log search requires `fromNs`, `toNs`, `services`, `attributes`, `sort`,
and `limit`. This example also includes optional filters:

```sh
curl -sS "${BELFRY_ENDPOINT}/api/logs/search" \
  -H 'content-type: application/json' \
  --data @- <<JSON
{
  "fromNs": "${FROM_NS}",
  "toNs": "${TO_NS}",
  "services": [
    {
      "namespace": "shop",
      "name": "checkout",
      "environment": "development"
    }
  ],
  "minimumSeverity": 17,
  "attributes": [],
  "sort": "newest",
  "limit": 100
}
JSON
```

Optional log filters are `minimumSeverity`, `maximumSeverity`, `traceId`,
`spanId`, `text`, and `cursor`. Omit them when unknown. OpenTelemetry severity
ranges are:

| Range | Meaning |
| --- | --- |
| 1–4 | Trace |
| 5–8 | Debug |
| 9–12 | Info |
| 13–16 | Warn |
| 17–20 | Error |
| 21–24 | Fatal |

Use `traceId` and `spanId` for exact correlation. Use time, Service, severity,
text, and attributes to discover uncorrelated logs.

## Discover facets

Facets reveal bounded values before committing to a filter:

```sh
curl -sS "${BELFRY_ENDPOINT}/api/facets" \
  -H 'content-type: application/json' \
  --data @- <<JSON
{
  "fromNs": "${FROM_NS}",
  "toNs": "${TO_NS}",
  "signal": "traces",
  "kind": "attribute-value",
  "services": [],
  "key": "inventory.sku",
  "prefix": "BEL",
  "limit": 100
}
JSON
```

Kinds are `service`, `operation`, `severity`, `attribute-key`, and
`attribute-value`. `operation` requires `signal: "traces"`, `severity` requires
`signal: "logs"`, and `attribute-value` requires `key`.

## Open exact details and correlations

| Evidence | Request |
| --- | --- |
| Trace detail | `GET /api/traces/{traceId}` |
| Span detail | `GET /api/traces/{traceId}/spans/{spanId}` |
| All trace logs | `GET /api/traces/{traceId}/logs?limit=100` |
| One span's logs | `GET /api/traces/{traceId}/logs?limit=100&spanId={spanId}` |
| Log detail | `GET /api/logs/{logId}` |

Trace detail includes:

- root span/operation, time range, duration, active state, counts, and Services;
- structurally ordered spans with depth, status, events, links, attributes,
  resource, scope, warnings, and correlated `logCount`;
- `spansTruncated`, which requires dedicated span requests for complete
  inspection.

Structural warnings are `missing-parent`, `multiple-roots`, `orphan-span`,
`running-span`, and `cycle`. They are evidence about the received span graph,
not automatic proof of an application defect.

Log summaries contain previews. Open log detail for the complete typed body,
attributes, resource, scope, event name, trace ID, and span ID.

## Understand search projections

Trace text search covers span names, status messages, event names, and bounded
automatically projected scalar attributes. Log text search covers the body,
severity text, event name, and projected attributes.

Attribute filters support `equals` and `contains`, but only for scalar
attributes admitted to the bounded projection. Detail responses expose
`filterableAttributeKeys`. Sensitive keys and high-cardinality identity-like
keys are excluded from automatic indexes while complete retained details
remain inspectable. Search trace and span IDs through their dedicated fields,
not general attribute filters.

`text` is a phrase search. Add it after a broader Service/status or
Service/severity query establishes the wording present in Belfry.

An empty search result proves absence only inside the applied time range,
filters, projection, pagination, and retention boundary.

## Exhaust cursor pagination

Every page includes:

- `items`
- applied `bounds`
- `truncated`
- optional `nextCursor`

While `truncated` is `true`, send the `nextCursor` to the same endpoint with the
same bounds, filters, limit, and sort. For POST searches and facets, add only:

```json
{
  "cursor": "opaque-next-cursor"
}
```

to the otherwise identical body. For GET lists, URL-encode
`cursor={nextCursor}`. Cursors are signed and fingerprinted to the query; a
cursor from a different endpoint or changed request is invalid.

## Inspect ingestion and API state

| Request | Purpose |
| --- | --- |
| `GET /api/health` | Liveness and read/write gates |
| `GET /api/ingestion/stats` | Accepted, rejected, dropped, queue, latency, storage, retention counters |
| `GET /api/ingestion/diagnostics?fromNs=...&toNs=...&limit=100` | Timestamped ingest/storage/retention failures |
| `GET /openapi.json` | Running version's authoritative schemas |

Query errors are typed:

- `400`: invalid schema, range, limit, or cursor;
- `404`: exact record not found;
- `503`: Store, migration, or query timeout unavailable.
