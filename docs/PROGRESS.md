# Project Progress

## Current Phase
**Phase 0 — Bootstrap complete.** No application code written yet.

## Phases Overview
| Phase | Feature | Status |
|---|---|---|
| 0 | Project setup & rules | ✅ Complete |
| 1 | Auth (register, login, refresh, logout, /me) | 🔲 Not started |
| 2 | Product catalog (list, detail, search, filters) | 🔲 Not started |
| 3 | Cart (add, update, remove, persist) | 🔲 Not started |
| 4 | Checkout (order placement, payment integration) | 🔲 Not started |
| 5 | Account section (profile, order history) | 🔲 Not started |

---

## Last Completed Unit
- `.clinerules` authored and committed
- `docs/` folder scaffolded (README, ai-interactions, PROGRESS, adr/, features/)

## Next Planned Unit
**Phase 1 — Auth feature**
1. Create `feature/auth` branch off `main`
2. Backend: `migrations/0001_create_users.sql`
3. Backend: `backend/src/config/db.ts` (mysql2 pool)
4. Backend: `backend/src/utils/AppError.ts` + `asyncHandler.ts`
5. Backend: `backend/src/middleware/errorHandler.ts`
6. Backend: auth routes → controller → service → db (register, login, refresh, logout, /me)
7. Frontend: Vite + React 18 + TypeScript scaffold
8. Frontend: `src/lib/apiClient.ts` (axios with `withCredentials: true`)
9. Frontend: `src/api/authApi.ts` (React Query hooks)
10. Frontend: Register and Login pages with React Hook Form + Zod

## Open Questions / Blockers
- MySQL connection string / credentials (need `.env` values before running)
- Confirm whether frontend and backend share a root `package.json` workspace or use two independent ones

---

*Updated: 2025-05-25*