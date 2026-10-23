---
name: systematic-debugging
description: "4-phase root cause debugging: understand bugs before fixing."
version: 1.1.4
author: Hermes Agent (adapted from obra/superpowers)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [debugging, troubleshooting, problem-solving, root-cause, investigation]
    related_skills: [test-driven-development, subagent-driven-development]
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## The Feedback Loop Rule

The feedback loop is the debugging work. Before reading code to build a theory, create or identify a **tight** command that can go red on the user's exact symptom and green when the bug is fixed. A tight loop is fast, deterministic, agent-runnable, and specific enough to catch this bug — not merely "doesn't crash".

When a clean repro is hard, spend disproportionate effort building the loop. Guessing without a red-capable loop is the failure mode this skill exists to prevent.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Someone wants it fixed NOW (systematic is faster than thrashing)

## The Four Phases

You MUST complete each phase before proceeding to the next.

---

## Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

### 1. Read Error Messages Carefully

- Don't skip past errors or warnings
- They often contain the exact solution
- Read stack traces completely
- Note line numbers, file paths, error codes
- Check error metadata: in error trackers (Sentry/Glitchtip), `"handled": true` indicates the exception was caught by an application `try/catch` and explicitly forwarded to the reporter (e.g. `report($e)`), rather than an uncaught crash. Trace the enclosing catch blocks.
- Beware error views masquerading as maintenance: In production environments (`APP_DEBUG=false`), unhandled 500 fatal exceptions render custom error templates (e.g. `resources/views/errors/500.blade.php`). If the custom 500 view is styled with maintenance illustrations or "website under build / maintenance" copy, users will report "the site shows maintenance", masking an underlying 500 crash. Trace the exact route, HTTP method, and server error logs to find the real exception rather than checking server maintenance mode flags.
- Trace null dereferences (`Attempt to read property on null`, `Cannot read properties of null/undefined`): Look upstream at route parameters and repository/model lookups. When an endpoint accepts an entity ID from a URL or input and performs a permissive lookup (`Model::find($id)` or nullable access) without existence checks, missing or probed IDs leak `null` to view templates or response serializers, turning an expected 404 into a 500 fatal error. Always enforce entity presence at the controller boundary (`findOrFail($id)` or explicit 404 abort) before querying dependent data or passing variables to views.
- Concurrency & filesystem errors (`mkdir(): File exists`, `EEXIST`, race conditions): Look for check-then-act directory creation (`!file_exists($dir) && mkdir($dir)`) in multi-worker environments (Octane, FPM, cluster workers). When multiple workers hit uncreated directories simultaneously, the second worker emits a warning converted to an `ErrorException`. Fix by pointing temporary storage to guaranteed system paths (e.g. `sys_get_temp_dir()`) or bootstrapping required directories during application startup (`@mkdir` in `boot()`) rather than lazily during request handling.
- Unknown column in where clause (`Unknown column 'id' in 'where clause'`): In ORM models (e.g. Eloquent), this error indicates a misconfigured primary key on a table using custom primary keys (`id_entity` instead of `id`). Check for property definition typos in the model (e.g. `protected $primary = 'id_entity';` instead of `protected $primaryKey = 'id_entity';`). Unrecognized property names cause the ORM to silently default the primary key to `'id'`, breaking methods like `$model->fresh()`, updates, and model event listeners (e.g. ActivityLog) that query by primary key.
- Memory exhaustion during file exports (`Allowed memory size exhausted` in ZipStream/Spreadsheet/PDF): Inspect query scoping and column selection. Unbounded queries lacking required parent/partition IDs, or `select *` loading rich HTML/BLOBs and nested relations, overwhelm process memory during document compilation. Fix by enforcing parent ID presence, selecting strictly needed columns on parent and relations, using chunked/streaming builders, and providing dedicated memory headroom (`ini_set('memory_limit', '512M')`).

**Action:** Use `read_file` on the relevant source files. Use `search_files` to find the error string in the codebase.

### 2. Build a Tight Feedback Loop

- Can you trigger the user's exact symptom with one command?
- Does the command fail for this bug and only pass once the bug is fixed?
- Is it fast enough to run repeatedly?
- Is it deterministic? For flaky bugs, can you raise the reproduction rate high enough to debug?
- If not reproducible → gather more data, don't guess.

**Ways to construct a loop — try in roughly this order:**

1. **Failing test** at the seam that reaches the bug: unit, integration, or end-to-end.
2. **HTTP script / curl** against a running dev server.
3. **CLI invocation** with fixture input, diffing stdout/stderr against expected output.
4. **Headless browser script** (Playwright/Puppeteer) asserting on DOM, console, or network.
5. **Replay a captured trace**: HAR, request payload, event log, queue message, or webhook body.
6. **Throwaway harness** that boots the smallest useful slice of the system and calls the failing path.
7. **Property / fuzz loop** when the bug is intermittent wrong output over a broad input space.
8. **Bisection harness** suitable for `git bisect run` when the bug appeared between two known states.
9. **Differential loop** comparing old vs new version, two configs, two providers, or two datasets.
10. **Human-in-the-loop script** only as a last resort: script the human steps and capture their result so the loop stays structured.

**Tighten the loop once it exists:**

- Make it faster: cache setup, narrow scope, skip unrelated initialization.
- Isolate test harnesses: if unit tests fail on database connections (`PDOException`, `ECONNREFUSED`) in `setUp()` due to global harness traits (e.g. `DatabaseTransactions`), force an in-memory driver (e.g. `DB_CONNECTION=sqlite DB_DATABASE=:memory:`) to keep the loop runnable without live server daemons.
- Fast schema scaffolding for isolated unit tests: If testing query builders, models, or controllers in environments where the primary database server is offline and full migrations or `RefreshDatabase` cannot be run, create minimal table schemas dynamically inside test `setUp()` (e.g. `Schema::create(...)`) and tear them down in `tearDown()` (`Schema::dropIfExists(...)`) backed by in-memory SQLite. This provides an instant, zero-dependency feedback loop.
- Make the signal sharper: assert the exact symptom, not generic success.
- Make it more deterministic: pin time, seed randomness, isolate filesystem, freeze network.

For non-deterministic bugs, the immediate goal is a higher reproduction rate, not perfection. Run the trigger 100x, parallelize, add stress, narrow timing windows, or inject sleeps. A 50% flake is debuggable; a 1% flake usually is not.

**Action:** Use the `terminal` tool to run the tight loop:

```bash
# Run a specific failing test
pytest tests/test_module.py::test_name -v

# Or run a scripted repro
python scripts/repro_bug.py

# Or run a high-repetition flaky repro
for i in {1..100}; do pytest tests/test_flake.py::test_name -q || break; done
```

### 3. Check Recent Changes

- What changed that could cause this?
- Git diff, recent commits
- New dependencies, config changes

**Action:**

```bash
# Recent commits
git log --oneline -10

# Uncommitted changes
git diff

# Changes in specific file
git log -p --follow src/problematic_file.py | head -100
```

### 4. Gather Evidence in Multi-Component Systems

**WHEN system has multiple components (API → service → database, CI → build → deploy):**

**BEFORE proposing fixes, add diagnostic instrumentation:**

For EACH component boundary:
- Log what data enters the component
- Log what data exits the component
- Verify environment/config propagation
- Check state at each layer

Run once to gather evidence showing WHERE it breaks.
THEN analyze evidence to identify the failing component.
THEN investigate that specific component.

### 5. Trace Data Flow

**WHEN error is deep in the call stack:**

- Where does the bad value originate?
- What called this function with the bad value?
- Keep tracing upstream until you find the source
- Fix at the source, not at the symptom

**Action:** Use `search_files` to trace references:

```python
# Find where the function is called
search_files("function_name(", path="src/", file_glob="*.py")

# Find where the variable is set
search_files("variable_name\\s*=", path="src/", file_glob="*.py")
```

- When debugging ORM/database errors (such as `Column in where clause is ambiguous`, SQLSTATE 1052): Inspect the compiled SQL via query builder `toSql()`. In ORMs with join-backed relationships (e.g. `belongsToMany` pivots or `hasManyThrough`), relation scoping joins the pivot table with the target table. Unqualified column names (`where('id_x', ...)`) cause ambiguity if both tables share the column (such as foreign keys). Always qualify columns with the exact table name (`where('table.id_x', ...)`).

### Phase 1 Completion Checklist

- [ ] Error messages fully read and understood
- [ ] A tight loop command exists and has been run at least once
- [ ] Loop is red-capable: it asserts the user's exact symptom, not a nearby failure
- [ ] Loop is deterministic, or a flaky bug has a high enough reproduction rate to debug
- [ ] Recent changes identified and reviewed
- [ ] Evidence gathered (logs, state, data flow)
- [ ] Problem isolated to specific component/code
- [ ] Root cause hypotheses can be stated and tested

**STOP:** Do not proceed to Phase 2 until you understand WHY it's happening.

---

## Phase 2: Pattern Analysis

**Find the pattern before fixing:**

### 0. Minimize the Reproduction

Once the loop is red, shrink the repro to the smallest scenario that still goes red. Cut inputs, callers, config, data, and steps **one at a time**, re-running the loop after each cut. Keep only what is load-bearing for the failure.

Done when removing any remaining element makes the loop go green. A minimal repro narrows the hypothesis space and often becomes the cleanest regression test.

### 1. Find Working Examples

- Locate similar working code in the same codebase
- What works that's similar to what's broken?

**Action:** Use `search_files` to find comparable patterns:

```python
search_files("similar_pattern", path="src/", file_glob="*.py")
```

### 1.1 Scan Sibling Implementations (Clone & Copy-Paste Bugs)

- When a bug stems from a missing import, syntax mistake, or wrong model reference in a controller/module, search for the same method or pattern across sibling namespaces (e.g., `Admin/` vs `dosen/` vs `api/` or tenant modules). Copy-pasted features replicate the exact same missing import across siblings.
- In namespaced languages (PHP, C#), unqualified symbol usage (`Foo::bar()`) resolves relative to the current namespace (`App\Path\To\Foo`), throwing `Class "App\Path\To\Foo" not found` only when the specific execution path is exercised. Always verify imports (`use App\Models\Foo;`) across all sibling controllers where the feature was duplicated.

### 2. Compare Against References

- If implementing a pattern, read the reference implementation COMPLETELY
- Don't skim — read every line
- Understand the pattern fully before applying

### 3. Identify Differences

- What's different between working and broken?
- List every difference, however small
- Don't assume "that can't matter"

### 4. Understand Dependencies

- What other components does this need?
- What settings, config, environment?
- What assumptions does it make?

---

## Phase 3: Hypothesis and Testing

**Scientific method:**

### 1. Form Ranked Falsifiable Hypotheses

- Generate 3–5 plausible hypotheses before testing any single one.
- Rank them by likelihood and cheapness to falsify.
- State the prediction each hypothesis makes: "If X is the cause, then changing or observing Y should make Z happen."
- Discard or sharpen any hypothesis that does not make a testable prediction.

If the user is present, show the ranked list before testing. They may have domain knowledge that instantly re-ranks it. If the user is AFK, proceed with your ranking.

### 2. Test Minimally

- Test the highest-ranked hypothesis with the smallest possible probe.
- Change one variable at a time.
- Don't fix multiple things at once.
- Prefer debugger/REPL inspection when available; one breakpoint beats ten logs.
- If you add logs, tag every temporary line with a unique prefix such as `[DEBUG-a4f2]` so cleanup is a single search.

### 3. Verify Before Continuing

- Did it work? → Phase 4
- Didn't work? → Form NEW hypothesis
- DON'T add more fixes on top

### 4. When You Don't Know

- Say "I don't understand X"
- Don't pretend to know
- Ask the user for help
- Research more

---

## Phase 4: Implementation

**Fix the root cause, not the symptom:**

### 1. Create Failing Test Case

- Simplest possible reproduction
- Automated test if possible
- MUST have before fixing
- Use the `test-driven-development` skill

### 2. Implement Single Fix

- Address the root cause identified
- ONE change at a time
- No "while I'm here" improvements
- No bundled refactoring

### 3. Verify Fix

```bash
# Run the specific regression test
pytest tests/test_module.py::test_regression -v

# Run full suite — no regressions
pytest tests/ -q
```

- For false-alarm error tracking bugs (noise in Sentry/Glitchtip), assert that the reporting sink is NOT called (e.g. `Exceptions::fake()` + `assertNotReported()`), not merely that the HTTP response code is correct.
- For third-party clients and retry loops (e.g., Laravel `Http::retry(...)`), verify if the retry helper defaults to throwing exceptions on non-2xx responses (e.g., `throw: true`). Set `throw: false` if 4xx responses are expected domain outcomes (like invalid tokens) that should be inspected via status checks rather than caught as system errors.
- Template/View defense-in-depth: Pair controller boundary fixes (`findOrFail`) with null-coalescing / optional chaining in templates (e.g., `{{ $entity->name ?? 'Default' }}`) so future schema deviations or soft-deleted associations cannot trigger fatal 500 errors.
- Concurrency & Ephemeral File Safety: In high-concurrency environments, avoid on-demand directory creation inside request handlers. If third-party libraries create local temp directories at request time, configure them to use the OS temp directory (`sys_get_temp_dir()`) or bootstrap them during application initialization to eliminate file-exists race conditions.

### 4. If Fix Doesn't Work — The Rule of Three

- **STOP.**
- Count: How many fixes have you tried?
- If < 3: Return to Phase 1, re-analyze with new information
- **If ≥ 3: STOP and question the architecture (step 5 below)**
- DON'T attempt Fix #4 without architectural discussion

### 5. If 3+ Fixes Failed: Question Architecture

**Pattern indicating an architectural problem:**
- Each fix reveals new shared state/coupling in a different place
- Fixes require "massive refactoring" to implement
- Each fix creates new symptoms elsewhere

**STOP and question fundamentals:**
- Is this pattern fundamentally sound?
- Are we "sticking with it through sheer inertia"?
- Should we refactor the architecture vs. continue fixing symptoms?

**Discuss with the user before attempting more fixes.**

This is NOT a failed hypothesis — this is a wrong architecture.

---

## Red Flags — STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals a new problem in a different place**

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** Question the architecture (Phase 4 step 5).

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question the pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence, trace data flow | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare, identify differences | Know what's different |
| **3. Hypothesis** | Form theory, test minimally, one variable at a time | Confirmed or new hypothesis |
| **4. Implementation** | Create regression test, fix root cause, verify | Bug resolved, all tests pass |

## Hermes Agent Integration

### Investigation Tools

Use these Hermes tools during Phase 1:

- **`search_files`** — Find error strings, trace function calls, locate patterns
- **`read_file`** — Read source code with line numbers for precise analysis
- **`terminal`** — Run tests, check git history, reproduce bugs
- **`web_search`/`web_extract`** — Research error messages, library docs

### With delegate_task

For complex multi-component debugging, dispatch investigation subagents:

```python
delegate_task(
    goal="Investigate why [specific test/behavior] fails",
    context="""
    Follow systematic-debugging skill:
    1. Read the error message carefully
    2. Reproduce the issue
    3. Trace the data flow to find root cause
    4. Report findings — do NOT fix yet

    Error: [paste full error]
    File: [path to failing code]
    Test command: [exact command]
    """,
    toolsets=['terminal', 'file']
)
```

### With test-driven-development

When fixing bugs:
1. Write a test that reproduces the bug (RED)
2. Debug systematically to find root cause
3. Fix the root cause (GREEN)
4. The test proves the fix and prevents regression

## Real-World Impact

From debugging sessions:
- Systematic approach: 15-30 minutes to fix
- Random fixes approach: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: Near zero vs common

**No shortcuts. No guessing. Systematic always wins.**
