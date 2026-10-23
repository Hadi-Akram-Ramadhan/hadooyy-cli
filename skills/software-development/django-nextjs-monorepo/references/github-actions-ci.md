# GitHub Actions CI Workflow for Django + Next.js Monorepo

Complete workflow template for `.github/workflows/ci.yml`.

```yaml
name: CI Test Suite

on:
  push:
    branches: [main, master, hadooyy]
  pull_request:
    branches: [main, master, hadooyy]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  frontend-ci:
    name: Frontend (Next.js)
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint
      - run: npm run test
      - run: npm run build
        env:
          NEXT_PUBLIC_API_URL: http://localhost:8000

  backend-ci:
    name: Backend (Django)
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
          cache-dependency-path: backend/requirements.txt
      - run: pip install --upgrade pip && pip install -r requirements.txt
      - run: python manage.py check
        env:
          DEBUG: "True"
          SECRET_KEY: "ci-secret-key-not-for-production"
      - run: python manage.py migrate
        env:
          DEBUG: "True"
          SECRET_KEY: "ci-secret-key-not-for-production"
      - run: python manage.py seed_data
        env:
          DEBUG: "True"
          SECRET_KEY: "ci-secret-key-not-for-production"
      - run: python manage.py test
        env:
          DEBUG: "True"
          SECRET_KEY: "ci-secret-key-not-for-production"
```

## Step Order Rationale

Frontend: `typecheck` -> `lint` -> `test` -> `build`
- Compiler errors are faster and block linting on broken ASTs
- Lint runs in seconds; don't waste test run time on style failures
- Tests fail before bundling overhead if logic is broken

Backend: `check` -> `migrate` -> `seed_data` -> `test`
- `check` identifies model misconfigurations without touching the DB
- Tables must exist before fixtures can insert (migrate before seed)
- Test runs its own isolated in-memory DB, independent of seed state

## Notes

- `concurrency.cancel-in-progress: true` prevents queue buildup on fast pushes
- Backend CI does not need PostgreSQL service for unit tests — SQLite is sufficient
- `seed_data` command name may differ; check `backend/core/management/commands/` for actual filename
- Typecheck will fail in CI if `src/types/next.d.ts` is missing — see main SKILL.md for the fix
- List ALL active dev branches in the trigger; update when branches change
