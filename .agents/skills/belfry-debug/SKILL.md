---
name: belfry-debug
description: Use Belfry to set up local observability, export OpenTelemetry traces or logs, or debug a Service through bounded searches and exact trace/span/log correlations.
---

# Belfry

Establish a **telemetry handshake**, then follow the **evidence trail**.

Belfry is a local-development workbench. Use its verified Daemon endpoint and
bounded Query API; treat the shared SQLite Telemetry Store as an implementation
detail. Keep telemetry on loopback and redact sensitive values before export.

## 1. Establish the Daemon endpoint

Resolve the command before running it:

- In the Belfry source repository, use `bun run belfry --`.
- Elsewhere, use an installed `belfry`.

Run `daemon status --json`. When it is stopped, run `daemon start --json`.
Capture the `endpoint` from the JSON instead of assuming the default port, then
request `GET {endpoint}/api/health`.

When Belfry is absent, configuration is invalid, the endpoint is unknown, or a
target Service is not visible yet, read
[setup and export](references/setup-and-export.md) completely before changing
instrumentation.

Complete this step when the verified endpoint is recorded, `live` is `true`,
and the health response establishes whether `writerReady` and `readsAvailable`
permit the next operation.

## 2. Prove the telemetry handshake

Before exercising the target, snapshot `GET /api/ingestion/stats`. Run one
recognizable operation, flush the enabled exporters, and request the statistics
again. Then list Services over the same time window.

Before the bounded Service request, read
[the Query API reference](references/query-api.md) completely for time
construction, required fields, and cursor rules.

For every enabled signal:

- its accepted-record counter increased;
- rejected/decode counters did not unexpectedly increase;
- the exact Service identity `(namespace, name, environment)` appeared.

When a counter or Service does not move, read
[troubleshooting](references/troubleshooting.md) completely and locate the
break before searching wider.

Complete this step when every expected signal is committed and discoverable, or
when the first broken layer is identified with health, counter, diagnostic, or
exporter evidence.

## 3. Bound the investigation

Record the symptom, expected behavior, target Service, and the narrowest useful
nanosecond window. Preserve exact IDs and timestamps from the failure. Prefer a
known trace ID, span ID, log ID, operation, error text, or domain attribute over
an unbounded text search.

Use [the Query API reference](references/query-api.md) for request payloads,
search projections, and response semantics. Treat
`{endpoint}/openapi.json` as authoritative when the running version differs
from the reference.

Complete this step when the endpoint, Service Filter, time bounds, and sharpest
known identifier are explicit.

## 4. Follow the evidence trail

Choose the entry point that matches the evidence:

- **Trace-first:** search traces, select an exact candidate, open its detail,
  inspect the failing span, then load trace- or span-correlated logs.
- **Log-first:** search logs, open each relevant log detail, then open its exact
  trace and span when correlation IDs are present.
- **Identity-first:** open a known trace, span, or log directly.

For a trace, record its root operation, participating Services, active state,
errors, structural warnings, and `spansTruncated`. Inspect error spans, events,
links, attributes, resource, scope, and `logCount`. Use the dedicated span
endpoint when trace detail is truncated or one span needs complete inspection.

For logs, distinguish exact correlation from temporal inference. A shared trace
ID, and optionally span ID, is exact. Similar timestamps, text, or attributes
without shared IDs are supporting evidence only.

Follow every page while `truncated` is `true`. Replay the identical endpoint,
filters, bounds, limit, and sort with only `cursor` added; signed cursors cannot
be reused with a changed query.

Complete this step when one exact causal path is supported across trace, span,
and logs, or every bounded candidate and correlation page is exhausted and the
remaining absence is explicit.

## 5. Report evidence

Report:

- Daemon endpoint and health gates;
- query bounds, filters, sort, and exhausted pages;
- Service identities;
- trace, span, and log IDs with exact nanosecond timestamps;
- ingestion diagnostics or counter deltas relevant to missing data;
- observations, separately labelled hypotheses, and unresolved gaps.

Complete the investigation only when every conclusion cites reported telemetry
evidence or is explicitly marked as a hypothesis or unresolved.
