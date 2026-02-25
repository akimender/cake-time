# CakeTime Web

React + Vite frontend for CakeTime. Landing and auth routes; app (home) will use the Django API.

## Setup

```bash
cd web
npm install
```

## Run

```bash
npm run dev
```

Opens at [http://localhost:3000](http://localhost:3000). API proxy: requests to `/api` go to the Django backend (set `server.proxy` in `vite.config.js` if your backend runs elsewhere).

## Build

```bash
npm run build
```

Output is in `dist/`. Serve with any static host or your Django app.

## Routes

- `/` — Landing
- `/login` — Log in (placeholder)
- `/register` — Get started (placeholder)
