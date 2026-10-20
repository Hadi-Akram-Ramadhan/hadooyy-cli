---
name: agentic-debate
description: >-
  Generic 3-agent debate (Explorer, Adversary, Referee) that exploits sycophancy
  via scoring incentives to stress-test any idea, decision, strategy, code, or
  proposal. Use when you want rigorous, honest analysis rather than agreement.
argument-hint: "<topic, question, or file path to analyze>"
allowed-tools: Read Grep Glob Bash Agent WebSearch WebFetch
---

# Agentic Debate

Stress-test any idea, decision, code, or proposal using a 3-agent adversarial debate that exploits sycophancy via scoring incentives to produce high-fidelity analysis.

Based on the technique from "How To Be A World-Class Agentic Engineer" by @systematicls.

## How It Works

LLMs are eager to please. Instead of fighting this, we exploit it:

- The **Explorer** is incentivized to find as many issues/angles as possible (scored per finding)
- The **Adversary** is incentivized to disprove findings (earns the finding's score) but penalized double for wrong disproves (-2x) — creating calibrated skepticism
- The **Referee** is told we have ground truth and scored on accuracy (+1 correct, -1 wrong) — pressured toward truth

The result is a superset of findings, filtered through adversarial challenge, judged by an accuracy-motivated referee.

## Workflow

### Step 1 — Interpret the Topic

Parse `$ARGUMENTS` to determine what is being debated:

- If it looks like a **file path or glob pattern** (contains `/`, `.`, or `*`), use Glob to resolve matching files, then Read them. The file contents become the debate context. If no files match, treat it as a freeform topic.
- If it's a **question, idea, or statement**, use it directly as the debate topic.
- If `$ARGUMENTS` is **empty**, ask the user what they want to debate.

Build a context block containing either the file contents or the topic statement. This context block is passed to all three agents.

### Step 2 — Explorer Agent

Launch an Agent with the following prompt structure. Include the full context block from Step 1.

```
You are the Explorer in a 3-agent debate. Your job is to thoroughly examine
the following topic from every angle.

SCORING: You will receive points for each finding you surface:
  +1  for low-impact findings
  +5  for medium-impact findings
  +10 for critical-impact findings
Report your total score at the end.

TOPIC/CONTEXT:
[insert context block here]

INSTRUCTIONS:
- Examine this thoroughly — implications, risks, assumptions, edge cases,
  failure modes, second-order effects, hidden costs, and opportunities.
- Use neutral analysis. Do not assume there are problems — follow the logic
  and report what you find, whether positive or negative.
- Ground every finding in specific evidence or reasoning, not vague assertions.
- If the context includes code, cite specific file paths and line numbers.
- If the context is an idea/question, cite specific reasoning chains,
  counterexamples, or real-world precedents.
- Do NOT flag superficial style or formatting issues.
- Define your own categories based on what you find — do not use a fixed list.
- Use available tools (Read, Grep, Glob, WebSearch, WebFetch) to research
  as needed.

OUTPUT FORMAT — for each finding:

### Finding [N]: [Title]
- **Category:** [your category]
- **Impact:** Critical / Medium / Low
- **Score:** [+1, +5, or +10]
- **Evidence:** [specific code, reasoning, data, or reference]
- **Explanation:** [why this matters]

End with:
### Total Score: [sum]
### Finding Count: [N] ([X] critical, [Y] medium, [Z] low)
```

### Step 3 — Adversarial Agent

Launch an Agent with the Explorer's full output AND the original context block.

```
You are the Adversary in a 3-agent debate. The Explorer has produced findings
about a topic. Your job is to challenge every single finding.

SCORING:
  For each finding you successfully disprove: you receive that finding's score.
  For each finding you incorrectly disprove (it was actually valid): you lose
  2x that finding's score.
Report your total score at the end.

EXPLORER'S FINDINGS:
[insert Explorer's full output here]

ORIGINAL TOPIC/CONTEXT:
[insert context block here]

INSTRUCTIONS:
- For EACH finding, attempt to disprove it or show it is overstated.
- You must independently verify claims — read the actual code, search for
  evidence, check if concerns are already mitigated.
- Adversarial strategies:
  * Challenge the assumptions underlying each finding
  * Find counterexamples or contradicting evidence
  * Identify logical fallacies in the Explorer's reasoning
  * Check if concerns are already handled by context the Explorer missed
  * Verify factual claims are accurate (the Explorer may have hallucinated)
  * Argue why risks are overstated or impact is lower than claimed
  * For code: check upstream/downstream handling, test coverage, framework guards
- Be aggressive but honest — the 2x penalty means you should only disprove
  findings you are genuinely confident are wrong.
- If a finding is valid, say so — you still lose nothing for confirming it.

OUTPUT FORMAT — for each Explorer finding:

### Finding [N]: [Explorer's title]
- **Verdict:** Confirmed / Disproved / Overstated
- **Score claimed:** [score if disproved, 0 if confirmed]
- **Counterargument:** [your challenge or agreement]
- **Evidence:** [specific code, data, or reasoning supporting your verdict]

End with:
### Total Score: [sum of scores claimed]
### Disproved: [N] | Confirmed: [N] | Overstated: [N]
```

### Step 4 — Referee Agent

Launch an Agent with BOTH the Explorer's and Adversary's full outputs AND the original context block.

```
You are the Referee in a 3-agent debate. The Explorer found potential issues
and the Adversary challenged them. You make the final ruling on each finding.

SCORING: I have the actual correct ground truth for every finding. You will
receive +1 for each correct ruling and -1 for each incorrect ruling. Accuracy
is everything. Report your total score at the end.

EXPLORER'S FINDINGS:
[insert Explorer's full output here]

ADVERSARY'S CHALLENGES:
[insert Adversary's full output here]

ORIGINAL TOPIC/CONTEXT:
[insert context block here]

INSTRUCTIONS:
- For EACH finding, weigh the Explorer's evidence against the Adversary's
  counterargument.
- You may independently verify claims using available tools (Read, Grep,
  Glob, WebSearch, WebFetch).
- Decision framework:
  * If the Adversary provides concrete evidence the finding is wrong: dismiss
  * If the Adversary's counter is speculative ("probably fine"): lean Explorer
  * If both cite real evidence but disagree on interpretation: needs-human-review
  * Do NOT default to confirming — an incorrect confirmation costs you -1
  * Do NOT default to dismissing — an incorrect dismissal also costs you -1
- Assign confidence: High (clear evidence) / Medium (strong but arguable) /
  Low (uncertain, needs human judgment)

OUTPUT FORMAT — for each finding:

### Finding [N]: [Title]
- **Ruling:** Confirmed / Dismissed / Needs Human Review
- **Confidence:** High / Medium / Low
- **Explorer's case:** [brief summary]
- **Adversary's challenge:** [brief summary]
- **Referee reasoning:** [why you ruled this way, referencing specific evidence]
- **Suggested action:** [what to do about it, if confirmed]

End with:
### Summary
- Confirmed: [N] | Dismissed: [N] | Needs Review: [N]
- Confidence breakdown: [X] high, [Y] medium, [Z] low
### Total Score: [your claimed accuracy score]
```

### Step 5 — Final Report

After all three agents complete, compile the final report. Use the Referee's output as the source of truth. Structure the report as follows:

```
## Agentic Debate Report

### Topic
[The question/idea/code that was analyzed]

### Process
- Explorer findings: [N] (score: [X])
- Adversary challenged: [N] disproved, [N] overstated, [N] confirmed
- Referee rulings: [N] confirmed, [N] dismissed, [N] needs review

### Confirmed Findings
(ordered by confidence, then impact)

For each confirmed finding, include:
- The finding title and category
- Confidence level
- A concise summary combining Explorer evidence, Adversary challenge, and Referee reasoning
- Suggested action

### Dismissed Findings
(brief table: finding number, title, one-line reason for dismissal)

### Needs Human Review
(findings where Referee couldn't decide — present both sides concisely)

### Key Takeaways
(3-5 bullet synthesis of what survived the debate — the distilled truth)
```

## Notes

- If the topic is large (many files, broad question), the Explorer may produce many findings. This is by design — the Adversary and Referee filter it down.
- The scoring incentives are fake but effective. They exploit the model's eagerness to please by channeling it toward the desired behavior for each role.
- For best results, give a specific topic. "Review my auth system" works better than "review everything."
- The final report's "Needs Human Review" section is the most important for genuinely ambiguous cases — inspect those manually.
