# Debate — Prompt Templates & Variations

Copy-paste prompts for each role. Replace `{{...}}` placeholders. Dispatch debaters
of the **same round in a single message** so they run in parallel and only react to
the previous round.

---

## Debater — Opening statement (Round 1)

```
You are a debater in a structured debate. Argue ONE side as persuasively and
rigorously as possible. You are an advocate, not a neutral analyst.

RESOLUTION: {{resolution}}
YOUR POSITION: {{Affirmative / Negative / named stance}}

Deliver your OPENING STATEMENT:
- Lead with your single strongest claim.
- Give 3–5 distinct arguments, each with reasoning and concrete evidence or examples.
- Steelman your own side; do not strawman the opposition.
- Surface the assumptions your case depends on.
- Be specific and falsifiable, not vague. ~300–500 words.

Return only your opening statement.
```

## Debater — Rebuttal (Round 2+)

```
You are the {{stance}} debater. The resolution is:
{{resolution}}

YOUR PRIOR ARGUMENT:
{{paste this debater's own previous statement}}

THE OTHER SIDE(S) JUST ARGUED:
{{paste every OTHER side's full latest statement(s), each clearly labeled by stance —
REQUIRED, do not omit}}

Deliver your REBUTTAL:
- Attack the weakest links in the other side(s)' case directly — quote or name the
  claim you target. With 3+ stances, prioritize the rivals that threaten you most.
- Concede any point that is genuinely correct (it builds credibility), then show why
  it doesn't decide the resolution.
- Defend the parts of your own case that were attacked.
- Add new evidence only if it strengthens a contested point. ~300–500 words.

Return only your rebuttal.
```

## Debater — Closing (optional final round)

```
Final round. Resolution: {{resolution}}. You are {{stance}}.
Full debate so far:
{{paste transcript}}

Deliver a CLOSING STATEMENT: crystallize why your side prevails on the points that
actually matter, address the strongest remaining objection, and state what the
audience should conclude. No new arguments. ~200–300 words.
```

---

## Judge — dedicated synthesis subagent

Spawn this when you want an impartial third party (not the moderator) to render the
verdict — best for maximal neutrality or a scored decision. Pass it the **complete**
transcript, and the fact-check findings too if step 4 ran.

```
You are an impartial debate judge. You did NOT participate. Judge ONLY on argument
quality, evidence, and logic — not your own opinion of the topic.

RESOLUTION: {{resolution}}
SIDES / STANCES: {{list every stance — 2 for pro/con, or all named perspectives}}

FULL TRANSCRIPT:
{{paste every round from every side, clearly labeled by stance}}

FACT-CHECK FINDINGS (if available — otherwise omit this block):
{{paste the fact-checker's Supported / Disputed / Unverifiable list}}

Produce a comprehensive verdict:
1. RESOLUTION — restate the exact question.
2. STRONGEST CASE PER SIDE — steelman each in 2–4 bullets.
3. CRUXES — the genuine disagreements that decide the question. With 3+ stances, map
   which stances conflict and which are reconcilable.
4. CONCESSIONS & WEAK POINTS — where each side gave ground or reasoned poorly.
   Discount any claim the fact-check marked Disputed or Unverifiable.
5. WHAT WOULD RESOLVE IT — the evidence/test that settles each crux.
6. VERDICT — reasoned conclusion + explicit confidence level + what would flip it.
   If genuinely balanced, say so. With 3+ stances, a hybrid/sequenced recommendation
   is allowed instead of one winner.
7. CAVEATS — assumptions, missing info, scope limits.

Reward evidence and direct engagement; penalize strawmanning, unsupported assertion,
and dodging the strongest opposing point.
```

**Scored variant** — for a decision that needs a number, append to the prompt:
"Also score each stance 0–10 on Evidence, Logical coherence, and Direct rebuttal of
opponents; show the per-criterion scores in a table, then the weighted total. The
verdict must be consistent with the scores."

---

## Fact-checker subagent

Run this neutral verifier **after the rebuttals, before synthesis**, on empirical or
claim-heavy topics. First pull the concrete factual claims out of the transcript
yourself (numbers, named case studies, citations, cause-effect assertions), then hand
the list to one subagent. It judges facts, not who should win.

```
You are a neutral fact-checker. You are NOT a debater and have NO stake in who wins.
Assess only the factual accuracy of the claims below — ignore rhetoric and persuasion.

CLAIMS (each tagged with the stance that made it):
{{numbered list of extracted factual claims, e.g.
 1. [Affirmative] "~70% of high-severity CVEs stem from memory-safety bugs."
 2. [Negative] "Netscape's rewrite took ~3 years during which it stopped shipping." }}

For EACH claim return one line:
  <#>. Supported | Disputed | Unverifiable — one-sentence reason (cite what you'd check).
- Supported = broadly corroborated by well-known evidence.
- Disputed = contradicted, exaggerated, or missing key context.
- Unverifiable = can't be confirmed without data not in evidence.
Do NOT pick a winner. Do NOT add new arguments. Be terse.
```

Fold the result into the verdict: discount Disputed/Unverifiable claims, and surface
them under WHAT WOULD RESOLVE IT. If a side's core argument rests on a Disputed claim,
say so explicitly in the verdict.

---

## Variations

### Multi-perspective (3+ sides)
For multi-stakeholder questions, replace Affirmative/Negative with **named stances** —
e.g. "Build in-house" / "Buy SaaS" / "Adopt open-source". Orchestration:

- **Openings**: spawn one debater per stance in a single message. In each prompt, name
  the *other* stances so the debater knows the field and can pre-empt them, but it
  argues **only its own** stance.
- **Rebuttals**: re-spawn each debater with **every other stance's** prior argument
  pasted in (labeled). Tell it to prioritize the rivals that threaten it most so the
  round doesn't sprawl.
- **Cost note**: rounds scale as `stances × rounds`. 3 stances × 2 rounds + judge = 7
  subagent calls — keep rounds at 2 unless the question really needs 3.
- **Verdict**: the CRUXES section maps which stances genuinely conflict and which are
  reconcilable; the VERDICT may recommend a **hybrid or sequenced** position (e.g.
  "buy now, build later") instead of crowning a single winner.

### Red team (proposal vs. adversary)
Side A presents and defends a concrete proposal. Side B's only mandate: find the
failure modes, edge cases, and hidden costs that break it. Useful for design reviews,
architecture decisions, and security thinking. Verdict = which risks are real and
load-bearing vs. acceptable.

### Devil's advocate (single subagent)
When the user already holds a view, spawn one subagent tasked solely with the
strongest possible counter-case, then synthesize whether their position survives.

> The fact-checker is no longer a variation — it's a first-class step. See
> [Fact-checker subagent](#fact-checker-subagent) above.

---

## Orchestration notes

- **Agent type**: `general-purpose` (or `claude`) works for debaters and judge.
- **Parallelism**: same-round debaters → one message, multiple `Agent` calls = parallel
  and fair. Cross-round → sequential, because each round needs the prior one's output.
- **Continuation**: if the harness lets you continue a subagent (Claude Code returns an
  `agentId` for `SendMessage`), continue each debater across rounds — it keeps its own
  prior argument, so the rebuttal prompt only needs the **opponent's** latest text. Use
  the rebuttal template but drop the "YOUR PRIOR ARGUMENT" block.
- **Transcript hygiene**: keep each side's statements clearly labeled in your context;
  you are the only component that sees the whole debate.
- **Cost/latency**: each round × each side = one subagent call, plus optional
  fact-check and judge. 2 sides × 2 rounds + 1 fact-check + 1 judge = 6 calls; 3 stances
  × 2 rounds + judge = 7. Scale rounds/sides to how much the question deserves.
- **Stay neutral**: as moderator, do not inject your own arguments into debater prompts
  or tip the verdict before the synthesis step.
