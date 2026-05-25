# Helfy — Premium Electronics eCommerce Platform

A full-stack eCommerce platform built with React 18 + Vite + TypeScript (frontend) and Node.js + Express + TypeScript + MySQL (backend).

---

## Quickstart

### Prerequisites
- Node.js ≥ 20
- Docker + Docker Compose

### 1. Clone & install dependencies
```bash
git clone https://github.com/royDavidovich/helfy-home-ex.git
cd helfy-home-ex
npm install
```

### 2. Configure environment
```bash
# Backend
cp .env.example backend/.env
# Edit backend/.env with your values (defaults work for local Docker)

# Frontend
cp .env.example frontend/.env
# VITE_API_BASE_URL=/api is already correct for local dev
```

### 3. Start the database
```bash
npm run db:up
# MySQL starts on port 3306, schema + seed data applied automatically via docker/init.sql
# Wait ~15s for first-run initialization
```

### 4. Start the dev servers
```bash
# In two separate terminals:
npm run dev:backend    # http://localhost:3001
npm run dev:frontend   # http://localhost:5173
```

### 5. Verify
- Frontend: http://localhost:5173
- Backend health: http://localhost:3001/api/health

---

## Project Structure

```
helfy-home-ex/
├── backend/          # Node.js + Express + TypeScript API
├── frontend/         # React 18 + Vite + TypeScript SPA
├── docker/
│   └── init.sql      # MySQL schema + seed data
├── docs/             # Architecture docs, ADRs, session logs
├── docker-compose.yml
├── package.json      # npm workspaces root
└── tsconfig.base.json
```

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18, TypeScript, Vite, React Query v5, Tailwind CSS, shadcn/ui, Framer Motion |
| Backend | Node.js, Express, TypeScript |
| Database | MySQL 8.0 (via Docker) |
| Auth | JWT in HttpOnly cookies (access 15min + refresh 7d) |
| Forms | React Hook Form + Zod |
| Routing | React Router v6 |

## Database management

```bash
npm run db:up      # start MySQL container
npm run db:down    # stop container (data persisted in volume)
npm run db:reset   # destroy volume + restart (re-seeds from init.sql)
npm run db:logs    # tail MySQL logs
```

---

## Manual Fixes Log

See [`docs/README.md`](docs/README.md) for a record of manual interventions and why the AI couldn't handle them.

## AI Session Log

See [`docs/ai-interactions.md`](docs/ai-interactions.md) for a record of all AI-assisted sessions, models used, and outputs.