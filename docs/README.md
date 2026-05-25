# Manual Fixes Log

This file documents cases where the developer manually corrected something Cline produced,
or where Cline was unable to handle something. Every entry should include a root cause
analysis and a prevention note so future sessions avoid the same failure.

---

## Template

```md
## YYYY-MM-DD — <file or area>
- **What I changed:** <concrete description of the fix>
- **Why the AI couldn't handle it:** <root cause: missing context, hallucinated API, version mismatch, unclear spec, etc.>
- **How to prevent recurrence:** <new rule to add, doc to update, context to include next time>
```

---

<!-- Append entries below this line, newest first -->