## 2025-05-25 — Plan Project bootstrap & .clinerules authoring
- **Model:** Claude Opus 4.7
- **Prompt:** I'm about to build a full-stack eCommerce platform using AI-assisted development in Cline. The project has multiple features — auth, product catalog, cart, checkout, account section- and will be developed in phases across multiple Cline sessions. What's the best way to keep the AI consistent across sessions? I don't want to re-explain architecture decisions, naming conventions, or coding patterns every time I start a new conversation. What do you recommend?
- **Output:**
  - Create a `.clinerules/` directory
- **Notes:** No code scaffolded yet.

---

- **Model:** Claude Sonnet 4.5
- **Prompt:** Define architecture rules for a full-stack eCommerce platform (React 18 + Vite + React Query v5 + Tailwind + shadcn/ui / Node + Express + mysql2) and generate a complete `.clinerules` file covering stack, folder structure, naming conventions, backend layer pattern, auth cookie pattern, React Query hook pattern, error handling, git workflow, and documentation protocol.
- **Output:**
  - `.clinerules` created at project root
  - `docs/README.md` created (manual fix log)
  - `docs/ai-interactions.md` created (this file)
  - `docs/PROGRESS.md` created (phase tracker)
  - `docs/adr/` and `docs/features/` stub directories created
- **Notes:** No code scaffolded yet. Next session starts Phase 1 — auth feature.