---
name: debate
description: Orchestrate a structured multi-agent debate on a topic, then synthesize a comprehensive verdict. Use when the user wants to debate a question, argue both sides, stress-test an idea, run a pro/con or multi-perspective analysis, settle a contested decision, or says "debate this", "argue for and against", "steelman both sides".
---

# Debate

Run a structured debate by dispatching subagents as debaters, moderating rounds
between them, then synthesizing a comprehensive verdict. **You are the moderator**,
not a debater — stay neutral until the synthesis step.

## Quick start

User: "Debate whether we should rewrite the service in Rust."

1. Frame a sharp resolution + pick sides (default: 2 — Affirmative / Negative).
2. Round 1 — spawn each debater **in parallel** for opening statements.
3. Round 2+ — spawn each debater again, feeding them the opponent's last arguments.
4. Synthesize a verdict (you, or a dedicated Judge subagent).

## Critical rule: subagents are stateless

Each `Agent` call starts cold with **no memory** of prior calls. A real debate
therefore depends on you, the moderator, doing this every round:

- Keep the full running transcript yourself.
- When spawning a debater for a rebuttal, **paste the opponent's latest arguments
  into its prompt.** A debater that can't see what it's rebutting will monologue.
- Spawn same-round debaters in one message (parallel) so neither sees the other's
  current-round text — they react only to the *previous* round. This keeps it fair.
- **Optimization** — if your harness supports continuing a prior subagent (e.g.
  Claude Code returns an `agentId` / `SendMessage`), continue each debater instead of
  re-spawning: it already remembers its own prior argument, so you only need to paste
  the **opponent's** latest arguments. Still spawn same-round debaters separately to
  keep the round fair.

## Workflow

Create a TodoWrite item per step for anything beyond a single quick round.

1. **Frame** — Restate the topic as a crisp, debatable resolution. Decide:
   - **Sides**: 2 (Affirmative/Negative) by default, or **3+ named perspectives** for
     multi-stakeholder questions (e.g. "Build in-house" / "Buy SaaS" / "Adopt OSS").
     See REFERENCE.md → Multi-perspective.
   - **Rounds**: 2 (opening + rebuttal) by default; 3 (add closing) for hard topics.
   - **Fact-check**: off by default; turn **on** for empirical / claim-heavy topics — a
     neutral verifier checks each side's factual claims before synthesis (step 4).
   - **Judge**: you synthesize by default; spawn a **dedicated Judge subagent** for
     maximal impartiality or a scored decision (step 5).
   - Confirm framing with the user only if the topic is ambiguous; otherwise proceed.

2. **Round 1 — Opening statements** — In a single message, spawn one
   `subagent_type: "general-purpose"` agent **per side / perspective**. Give each: the
   resolution, its assigned stance, the names of the other stances (so it knows the
   field), and the rules (evidence-based, steelman your side, concede nothing unearned).
   Collect every opening statement into your transcript.

3. **Rebuttal round(s)** — In a single message, re-spawn each debater. Each prompt now
   includes: the resolution, its stance, its own prior argument, and **every other
   side's full prior arguments** to rebut (for 3+ sides, paste all of them, labeled).
   Optionally add a closing round.

4. **(Optional) Fact-check** — If enabled, spawn one neutral verifier subagent with
   every side's factual claims pulled from the transcript. It marks each claim
   Supported / Disputed / Unverifiable with a one-line reason and does **not** take a
   side. Carry its findings into step 5 and discount flagged claims.

5. **Synthesize the verdict** — Reason over the transcript yourself, **or** spawn a
   dedicated Judge subagent with the complete transcript (plus any fact-check findings).
   Produce the structured verdict below.

See [REFERENCE.md](REFERENCE.md) for copy-paste prompt templates for every role —
opening, rebuttal, closing, fact-checker, judge — and modes.

## Verdict format

Output a comprehensive synthesis — not just "who won":

- **Resolution** — the exact question debated.
- **Strongest case per side** — each position steelmanned in 2–4 bullets.
- **Cruxes** — the points of *genuine* disagreement that actually decide the question.
- **Concessions & weak points** — where each side gave ground or argued poorly.
- **What would resolve it** — the evidence, data, or test that would settle each crux.
- **Verdict** — a reasoned conclusion with an explicit **confidence level** (and the
  conditions under which it would flip). If genuinely balanced, say so and explain why.
- **Caveats** — assumptions, missing information, scope limits.

**With 3+ perspectives**, the Cruxes section maps **which stances conflict and which
are reconcilable**, and the Verdict may recommend a hybrid or sequenced position rather
than crowning one winner. **If fact-check ran**, list disputed/unverifiable claims and
discount any conclusion that leaned on them.

## Tuning

- **Quick take**: 2 sides, 1 round, you judge. Fast pro/con.
- **Deep dive**: 2–3 sides, 3 rounds, dedicated Judge subagent.
- **Multi-perspective**: 3+ named stances for multi-stakeholder calls; the verdict maps
  conflicts vs. reconcilable positions instead of picking a single winner.
- **Red team**: 1 proposal + 1 adversary whose only job is to break it.
- **Fact-checked debate**: enable the fact-checker step for empirical / claim-heavy
  topics so the verdict rests only on verified claims.
