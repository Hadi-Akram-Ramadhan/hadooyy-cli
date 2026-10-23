---
name: chrome-extension-engineering
description: Build and maintain Chrome Manifest V3 extensions.
version: 0.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [chrome-extension, manifest-v3, content-scripts, shadow-dom, mathml]
    related_skills: [codebase-inspection, dogfood]
---

# Chrome Extension Engineering (Manifest V3)

Guide for building, patching, and verifying Chrome Manifest V3 extensions with strict CSP compliance, isolated content script UI, and math rendering.

## Architecture & Responsibilities

- **Manifest (`manifest.json`):** MV3 manifest declaring permissions, background service worker, and content scripts.
- **Service Worker (`background.js`):** Ephemeral execution context. Handles network calls (API fetching, SSE streaming), screenshot capture (`chrome.tabs.captureVisibleTab`), and background logic.
- **Content Scripts (`content.js`):** Runs in isolated world on web pages. Builds in-page UI, captures user selection, renders floating widgets.
- **Library / Extension Pages (`library.html`, `options.html`):** Origin-isolated extension pages with full access to extension APIs and IndexedDB.

## Security & CSP Rules (MV3)

1. **Zero `eval()` / `new Function()`:** MV3 strictly disallows string evaluation in all extension contexts. Any vendored library must be audit-checked for `eval` and `Function(`.
2. **Key Storage:** Store sensitive API keys in `chrome.storage.local` with `chrome.storage.local.setAccessLevel({ accessLevel: 'TRUSTED_CONTEXTS' })` so untrusted content scripts cannot read them directly.
3. **Sender Validation:** In service worker message listeners, always verify `sender.id === chrome.runtime.id` to reject unauthorized external callers.

## UI Injection & Shadow DOM

Inject floating widgets inside a closed or open Shadow DOM attached to a host container:

```javascript
const host = document.createElement('div');
host.id = 'ext-host';
host.style.cssText = 'position:fixed;inset:0;z-index:2147483647;pointer-events:none;';
document.documentElement.appendChild(host);
const shadow = host.attachShadow({ mode: 'open' });
const style = document.createElement('style');
style.textContent = CSS_TEXT;
shadow.appendChild(style);
```

- **CSS Scoping:** Styles must be appended inside `shadow` to apply to shadow DOM children.
- **Theme Variables:** CSS custom properties set on `host` penetrate shadow roots, enabling host-level theme adjustments.

## Math & Formula Rendering in Content Scripts

Rendering complex LaTeX formulas in third-party web pages without leaking extension resources:

1. **Native MathML over HTML/CSS fonts:**
   - KaTeX with `{ output: 'mathml' }` compiles LaTeX directly into W3C native `<math>` elements.
   - Chromium (109+) natively renders MathML Core without downloading external web fonts (`.woff2`).
   - Prevents broken relative font URLs or CORS blocks on host domains.
   - Inherits text color (`color: inherit`) automatically in dark and light modes.
2. **Regex Delimiters:**
   - Display math: `/\$\$([\s\S]+?)\$\$/g` and `/\\\[([\s\S]+?)\\\]/g`.
   - Inline math: `/\\\(([\s\S]+?)\\\)/g` and `/(?<![\\\$])\$([^\$\s\n](?:[^\$\n]*?[^\$\s\n])?)\$(?!\$)/g`.
   - Currency Guard: Ignore inline matches consisting solely of digits (`/^\d+(?:\.\d+)?$/`) to prevent clashing with currency values like `$100`.
   - Code Blocks: Convert blocks with language `latex` or `math` to display formulas.
3. **Script Ingestion Order:**
   - In `manifest.json`: List dependencies before content script: `"js": ["katex.min.js", "content.js"]`.
   - In dynamic script injection (`chrome.scripting.executeScript`): Pass dependencies in order: `files: ['katex.min.js', 'content.js']`.

## Pitfalls

- **Stale Content Script after Reload:** Reloading the unpacked extension in `chrome://extensions` invalidates active content scripts. Catch extension context invalidated errors and instruct the user to refresh (F5) the open tab.
- **Port Disconnect on Idle SW:** MV3 service workers can go idle. Always manage connection ports with explicit message handlers, request IDs, and disconnect cleanup.
- **Native Windows Path Conversion in Tests:** When running regression tests in Node on Windows, use `path.join(__dirname, '..')` to avoid MSYS/native path mismatches.
