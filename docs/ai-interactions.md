# AI Session Log

This file records every [PERSON_NAME]-assisted development session.
Append a new entry at the end of each session before closing.

---

## Template

```md
## YYYY-MM-DD — <short title>
- **Model:** <e.g. Claude Sonnet 4.5>
- **Prompt:** <verbatim or summarized prompt>
- **Output:** <files created/modified, key decisions, commit hash if available>
- **Notes:** <anything noteworthy, follow-ups, things that didn't work>
```

---

## 2025-05-25 — Project bootstrap & .clinerules authoring
- **Model:** Claude Sonnet 4.5
- **Prompt:** Define architecture rules for a full-stack eCommerce platform (React 18 + Vite + React Query v5 + Tailwind + shadcn/ui / Node + Express + mysql2) and generate a complete `.clinerules` file covering stack, folder structure, naming conventions, backend layer pattern, auth cookie pattern, React Query hook pattern, error handling, git workflow, and documentation protocol.
- **Output:**
  - `.clinerules` created at project root
  - `docs/README.md` created (manual fix log)
  - `docs/ai-interactions.md` created (this file)
  - `docs/PROGRESS.md` created (phase tracker)
  - `docs/adr/` and `docs/features/` stub directories created
- **Notes:** No code scaffolded yet. Next session starts Phase 1 — auth feature.

---

<!-- Append new entries below this line, newest last -->