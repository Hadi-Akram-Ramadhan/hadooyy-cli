---
name: django-nextjs-monorepo
description: Merge or scaffold Django backend with Next.js frontend.
metadata:
  origin: Pantara session
---

# Django + Next.js Monorepo Setup

Procedure for bringing a Django backend into an existing Next.js repo (or scaffolding one from scratch) so both services live under one git root and work together in dev.

## Trigger Patterns

- User has separate Django and Next.js repos and wants to unify them
- Scaffold backend folder inside an existing frontend-only repo
- "satuin backend ke frontend" / "merge backend ke project front"

## Folder Layout Convention

```
project-root/
├── frontend/          # Next.js app (App Router)
│   ├── src/
│   ├── package.json
│   └── ...
├── backend/           # Django project
│   ├── config/        # settings, urls, wsgi, asgi
│   ├── <app>/         # Django apps (core, work, adaptive, ...)
│   ├── manage.py
│   ├── requirements.txt
│   ├── pyproject.toml  # for uv
│   └── .env.example
├── docs/
├── .gitignore         # covers BOTH frontend and backend artifacts
└── README.md
```

## Migration Procedure (Existing Django → Existing Next.js Repo)

### 1. Read both codebases FIRST

Before touching anything, read:
- `docs/` in the target repo — look for architecture docs that describe the *intended* folder layout and milestone phases. The backend may be planned for a future milestone; copy into the shape the docs describe.
- `backend/config/settings.py` — note INSTALLED_APPS, DATABASES, CORS config
- `backend/requirements.txt` — full dependency list
- `frontend/package.json` — confirm dev port (usually 3000)

Do NOT start copying until you understand which phase the project is in and what folder structure the team expects.

### 2. Copy backend folder

```bash
cp -r /path/to/source/backend /path/to/target/backend
```

### 3. Remove artifacts immediately after copy

```bash
# venv — never commit, always recreate
rm -rf backend/venv backend/.venv backend/env

# Database — SQLite is local state, not source
rm -f backend/db.sqlite3 backend/*.sqlite3-journal

# Logs — transient
rm -f backend/server.log backend/*.log

# Compiled Python
find backend -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null
find backend -name '*.pyc' -delete 2>/dev/null
```

Delete these BEFORE verifying git status — they pollute `git status` and confuse the diff.

### 4. Update root .gitignore

The root `.gitignore` must cover backend artifacts. The frontend usually has its own `.gitignore` under `frontend/` — add Python patterns at root level:

```gitignore
# Python & Backend
__pycache__/
*.py[cod]
*$py.class
*.sqlite3
*.sqlite3-journal
*.log
venv/
.venv/
env/
.pytest_cache/
.ruff_cache/
dist/
build/
*.egg-info/
```

### 5. Align settings.py for monorepo dev

Required changes in `backend/config/settings.py`:

**a) Use python-decouple for env vars (already in requirements.txt):**

```python
from pathlib import Path
try:
    from decouple import config
except ImportError:
    def config(key, default=None, cast=None):
        import os
        val = os.environ.get(key, default)
        if cast and val is not None and cast == bool:
            return str(val).lower() in ('true', '1', 't')
        return cast(val) if cast and val is not None else val

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = config('SECRET_KEY', default='django-insecure-dev-key')
DEBUG = config('DEBUG', default=True, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='*',
    cast=lambda v: [s.strip() for s in v.split(',') if s.strip()])
```

**b) CORS — point at Next.js dev server:**

```python
CORS_ALLOW_ALL_ORIGINS = config('CORS_ALLOW_ALL_ORIGINS', default=True, cast=bool)
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]
```

`CORS_ALLOW_ALL_ORIGINS=True` is fine for dev; in prod set it to False and list only real origins.

### 6. Add pyproject.toml (for uv)

Django Architecture docs for this project specify `uv sync` as the dev command. Add `pyproject.toml` alongside `requirements.txt`:

```toml
[project]
name = "<project>-backend"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    # copy from requirements.txt exactly
]

[tool.uv]
dev-dependencies = [
    "ruff>=0.4",
    "pytest>=8",
    "pytest-django>=4.8",
]

[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings"
python_files = ["tests.py", "test_*.py", "*_test.py"]

[tool.ruff]
line-length = 120
```

### 7. Add .env.example

```
DEBUG=True
SECRET_KEY=django-insecure-dev-key-change-in-prod
ALLOWED_HOSTS=*
CORS_ALLOW_ALL_ORIGINS=True
# DATABASE_URL=postgres://user:password@localhost:5432/dbname
```

### 8. Add health check endpoint

In `backend/config/urls.py`, add before all other urlpatterns:

```python
from django.http import JsonResponse

def health(request):
    return JsonResponse({"status": "ok", "service": "<project>-backend"})

urlpatterns = [
    path('api/health/', health, name='health'),
    # ... rest of urls
]
```

### 9. Verify git status is clean

```bash
git status
```

Expected: only the new `backend/` folder as untracked, and root `.gitignore` as modified. Nothing else. If artifacts appear, the cleanup in step 3 was incomplete.

### 10. Update README in backend/

Patch `backend/README.md` to reflect `uv` as the recommended setup path. Keep the existing content — patch, don't overwrite.

## Frontend–Backend Connectivity

The correct pattern for dev connectivity is **CORS direct fetch**, NOT Next.js rewrites:

1. Backend: `CORS_ALLOW_ALL_ORIGINS = True` + list `localhost:3000` in `CORS_ALLOWED_ORIGINS` (both coexist — the flag takes precedence)
2. Frontend: create `src/lib/api.ts` with a fetch wrapper reading `NEXT_PUBLIC_API_URL`
3. **Do NOT use `next.config.ts` rewrites with `destination: 'http://localhost:8000/...'`.** Turbopack (Next.js 16+) does not reliably proxy external hosts — requests fall through to App Router 404 handler silently.
4. **Do NOT use App Router catch-all route handlers (`[...path]/route.ts`) as a proxy.** Turbopack does not hot-pick new directories during a running dev session; restart is required, and trailing-slash matching is unreliable.

Verify CORS before building the API client:
```bash
curl -s -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -X OPTIONS http://localhost:8000/api/health/ -v 2>&1 | grep "< access-control"
# Expected: access-control-allow-origin: *
```

Minimal `src/lib/api.ts` pattern:
```ts
const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
export async function apiFetch<T = unknown>(endpoint: string, options: RequestInit = {}) {
  const url = `${API_BASE}${endpoint.startsWith('/') ? endpoint : '/' + endpoint}`;
  try {
    const res = await fetch(url, { ...options, headers: { 'Content-Type': 'application/json', Accept: 'application/json', ...options.headers } });
    if (!res.ok) return { data: null, error: await res.text(), status: res.status };
    if (res.status === 204) return { data: null, error: null, status: 204 };
    return { data: (await res.json()) as T, error: null, status: res.status };
  } catch (err) { return { data: null, error: err instanceof Error ? err.message : 'Network error', status: 0 }; }
}
```

Add to `frontend/.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## Next.js TypeScript: `LayoutProps` / `PageProps` Not Found

Next.js generates these types inside `.next/types/app/` — only after `next build` runs. In a clean CI environment, `tsc --noEmit` fails with `Cannot find name 'LayoutProps'`.

Fix: add `frontend/src/types/next.d.ts` permanently:
```ts
/* eslint-disable @typescript-eslint/no-explicit-any */
declare global {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  type PageProps<Route extends string = string> = { params: Promise<any>; searchParams?: Promise<any>; };
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  type LayoutProps<Route extends string = string> = { children: React.ReactNode; params?: Promise<any>; };
}
export {};
```
The `eslint-disable-next-line` comments on the generic parameter are required — omitting them produces lint warnings that fail CI.

## GitHub Actions CI/CD

See `references/github-actions-ci.md` for the full workflow template.

Key structure:
- Two parallel jobs: `frontend-ci` (Node 22, npm ci, tsc, eslint, vitest, next build) and `backend-ci` (Python 3.12, pip, manage.py check + migrate + test)
- Both use `defaults.run.working-directory:` to avoid per-step `cd`
- Backend job passes `SECRET_KEY` and `DEBUG` via `env:` on each step, not repo secrets in dev
- `concurrency.cancel-in-progress: true` prevents queue buildup on fast pushes
- Trigger on `push` and `pull_request` for all active branches

## Dev Commands After Setup

### Preferred: uv

```bash
cd backend
uv sync
cp .env.example .env
uv run python manage.py migrate
uv run python manage.py <seed_command>   # check management/commands/ for actual name
uv run python manage.py runserver        # :8000
```

### Fallback: pip + venv (when uv not installed)

`uv` may not be on PATH on Windows by default. Detect with `uv --version`; if absent, fall back:

```bash
# Find a working Python — try py -3.12 before python3 on Windows
py -3.12 -m venv backend/venv
backend/venv/Scripts/pip.exe install -r backend/requirements.txt
backend/venv/Scripts/python.exe backend/manage.py migrate
backend/venv/Scripts/python.exe backend/manage.py <seed_command>
```

Verify the venv is populated before running: `ls backend/venv/Lib/site-packages` — if only `pip` is there, the original venv was empty and dependencies were never installed.

### Run both services

```bash
# Terminal 1 — backend
backend/venv/Scripts/python.exe backend/manage.py runserver   # :8000

# Terminal 2 — frontend
cd frontend && npm run dev                                     # :3000
```

Quick smoke test after backend starts:
```bash
curl http://localhost:8000/api/health/
# expected: {"status": "ok", "service": "<project>-backend"}
```

### Run tests

```bash
# uv
uv run pytest

# venv fallback
backend/venv/Scripts/python.exe backend/manage.py test

# Lint (uv only)
uv run ruff check .
```

## Pitfalls

- **Check whether uv is installed before writing setup instructions.** Run `uv --version`; if absent, use `py -3.12 -m venv` + `pip install -r requirements.txt`. Do not document `uv sync` as the only path if uv is not present on the machine.
- **On Windows, `py -3.13` may point at the Store stub (no real Python installed).** Try `py -3.12` first; if that also fails, check `py -0` to list available versions and pick an installed one.
- **Source venv may be empty (only pip in site-packages).** Always check `ls venv/Lib/site-packages` before trusting a copied venv. If empty, delete and recreate — do not try to pip-install into the broken venv in place.
- **`node_modules` cleanup on Windows: `rm -rf` via bash will fail on deeply nested directories with ENOTEMPTY.** Use `cmd /c "rmdir /s /q C:\path\to\node_modules"` instead, then re-run `npm install`.
- **Run `manage.py migrate` then `manage.py test` immediately after setup** to confirm the backend is wired correctly before starting the server. 29 green tests is a stronger signal than the server starting.
- **Read the project docs before copying.** Architecture docs often specify the intended folder layout and active milestone. Copying into the wrong location (e.g., at root instead of `backend/`) wastes a full redo.
- **Pyright/LSP `reportMissingImports` on `decouple` is a false positive** when no venv is active in the editor. Ignore it — `decouple` is in `requirements.txt`.
- **Never copy the source venv.** It contains absolute paths compiled into `.pth` files; it will not work at the destination. Delete immediately after copy and let `uv sync` or `pip install` recreate it.
- **`CORS_ALLOW_ALL_ORIGINS=True` + `CORS_ALLOWED_ORIGINS` can coexist.** `CORS_ALLOW_ALL_ORIGINS` takes precedence when True. List specific origins anyway so toggling the flag in prod works without another config change.
- **`git status` after migration should show only `backend/` as untracked.** If pycache, db, or venv appear, cleanup was incomplete — delete them before committing anything.
- **Do not touch frontend source during a backend migration.** If the frontend is in M0 mock mode (demo store), leave it alone. Connecting it to the backend is a separate milestone.
- **`seed_data` management command name may differ from what README says.** Check `backend/core/management/commands/` for the actual command name before documenting it.
- **On Windows, killing and restarting `npm run dev` can leave a zombie process holding port 3000.** Next.js detects the conflict and starts on port 3001 instead, then immediately exits. Kill the zombie first: `taskkill /PID <pid> /F` (PID shown in Next.js error output), then restart. Do not use `nohup`/`&` wrappers in the terminal tool — use `terminal(background=True)` with notify patterns so Hermes tracks the process.
- **`npm install` on Windows can fail with ENOTEMPTY on deeply nested node_modules.** `rm -rf` via git-bash leaves locked dirs. Use `cmd /c "rmdir /s /q C:\path\to\node_modules"` then re-run `npm install`.
- **`tsc --noEmit` fails in clean CI because Next.js generated types (`LayoutProps`, `PageProps`) only exist after `next build`.** Add `frontend/src/types/next.d.ts` as a permanent fallback — see the `Next.js TypeScript` section above for the exact file content.
