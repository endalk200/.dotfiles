---
name: research
description: Investigate substantial research questions against primary sources and capture cited findings in the repo. Use for multi-source investigations or an explicitly requested research note.
---

Delegate research to a **background agent** when useful independent work remains for the main agent. Otherwise research directly. Simple documentation or API lookups do not require this workflow.

Research workflow:

1. Investigate the question against **primary sources** — official docs, source code, specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes and match the existing convention. If there is none, save it as `docs/research/<topic-slug>.md` and report the path.
