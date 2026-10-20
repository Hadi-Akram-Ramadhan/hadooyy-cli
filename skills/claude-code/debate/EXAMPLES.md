# Debate — Worked Examples

Two real runs, condensed to show the *shape* of a debate. Each debater's real output was
~400–600 words; here they're trimmed to their core claims. See [SKILL.md](SKILL.md) for the
workflow and [REFERENCE.md](REFERENCE.md) for the prompt templates behind each turn.

- **Example A** — the simplest path: 2 sides, 2 rounds, moderator judges, no fact-check.
- **Example B** — everything at once: 3 perspectives + fact-check + a scored Judge subagent.

---

## Example A — Quick 2-side (moderator judges)

**Resolution**: A mature, well-running production backend service should be *completely
rewritten* in Rust. · **Sides**: Affirmative / Negative · **Rounds**: 2 · **Judge**:
moderator · **Calls**: 2 openings + 2 rebuttals = 4.

### Round 1 — Openings (2 agents, parallel)

**Affirmative (rewrite)** — "Running well" is the *best* time to rewrite: a stable system
gives you a behavior baseline, a regression suite, and live metrics, turning a rewrite from a
gamble into a verifiable migration. Memory & concurrency safety belong at compile time:
~70% of high-severity CVEs are memory-safety bugs; Google's Android memory-safety vulns fell
76%→35% after adopting Rust, with zero in new Rust code. Quantified wins: Discord's Read
States (Go→Rust) erased GC latency spikes; Cloudflare's Pingora serves trillions of
requests/day at ~70% less CPU and 67% less memory. *Premise: the service is
perf/security/cost-sensitive, the team has Rust capacity, and migration is incremental and
reversible (strangler-fig).*

**Negative (don't)** — A complete rewrite of a healthy service spends certain cost to gamble
on uncertain gains, and history says that bet usually loses. It discards hard-won implicit
domain knowledge — the ugly code is scar tissue from real incidents (Joel Spolsky, *Things
You Should Never Do*). Netscape's engine rewrite took ~3 years of not shipping and the
company died as IE took over. Opportunity cost: months of zero new value while carrying all
the dual-system / migration / regression risk. And Rust solves problems a "well-running"
service mostly doesn't have — the bottleneck is usually DB / I/O / architecture. *Premise: no
acute crisis, incremental refactor is viable, the business must keep shipping.*

### Round 2 — Rebuttals (each sees the other's opening)

**Affirmative** — Concedes big-bang rewrites are wrong and knowledge loss is real, but:
strangler-fig is the *means*, an all-Rust end-state is the *terminus* — the resolution is
about the terminus. "Running well" ≠ no latent risk (OpenSSL "ran well" before Heartbleed;
memory-safety failures are silent). The Discord/Cloudflare gains weren't I/O problems.

**Negative** — Memory safety is real but doesn't decide *this* motion. The Affirmative's own
premise picks "incremental, reversible strangler-fig" — that *is* the gradual approach, not a
complete rewrite, so it concedes the motion. And its best case studies are a single component
(Discord) or greenfield (Pingora), not complete rewrites of mature services.

### Verdict (moderator) — Negative, confidence ~70%

The literal motion ("*completely* rewrite a well-running service") favors the Negative:
(1) the Affirmative effectively conceded the safe path is incremental and its strongest
evidence is component-level / greenfield, not full rewrites; (2) "well-running" implies no
acute crisis, so the burden is on showing a structural, language-level problem only a full
rewrite solves — generally unmet; (3) the default-correct move is targeted strangler-fig
replacement of proven hot spots, capturing most of Rust's benefit at a fraction of the risk.
**Flips when** the service is genuinely memory-unsafe / security-critical (recurring CVEs in
C/C++), or runtime cost (GC latency / CPU bill) is a dominant, language-attributable line item
at scale — **and** the team has Rust capacity.

---

## Example B — Full 3-way + fact-check + scored Judge

This run exercises every feature at once: multi-perspective, the fact-check step, and a
dedicated Judge subagent with a scored rubric.

### Frame

- **Decision question**: How should an early-stage (~10-person, seed) SaaS startup solve
  user authentication & authorization (authn/authz)?
- **Stances (3)**: ① Build in-house · ② Buy an Auth SaaS (Auth0/Clerk/WorkOS) ·
  ③ Self-host open-source (Keycloak/Ory/Supabase Auth)
- **Rounds**: 2 (opening + rebuttal) · **Fact-check**: ON (pricing/claim-heavy) ·
  **Judge**: dedicated subagent with a scored rubric
- **Subagent calls**: 3 openings + 3 rebuttals + 1 fact-check + 1 judge = **8**

---

### Round 1 — Opening statements (3 agents, parallel)

**① Build in-house** — Authz is coupled to the product; org→team→project→resource
ABAC/ReBAC resolves in one SQL `join` in your own DB. Per-MAU billing back-bites after
growth (5-figure/yr past the SSO "enterprise wall"); auth is the highest-migration-cost
subsystem, so building = no lock-in + data sovereignty. *Premise: a session-security-aware
engineer, mature libs (no homemade crypto), restrained initial scope.*

**② Buy a SaaS** — Auth is the *door*, not the product; don't spend the scarcest resource
(engineer time) on it. Clerk/Auth0 ship the full flow in an afternoon; security is
outsourced to a full-time team + bug bounty + SOC 2; MFA/SSO/SAML/SCIM are the hard gate
for B2B deals. *Premise: early MAU billing < headcount cost, no extreme compliance, auth
isn't the product, lock-in is hedgeable.*

**③ Self-host open-source** — Get "don't reinvent the wheel" *and* "don't get locked in":
outsource the auth layer (hashing/sessions/OIDC) to battle-tested code, customize only the
authz layer. Decoupled from per-MAU; data stays yours (a GDPR/VPC compliance shortcut);
native OIDC/OAuth2/SAML. *Premise: someone can run a container + DB and own upgrades; B2B
is on the roadmap.*

---

### Round 2 — Rebuttals (3 agents, parallel; each sees the other two openings)

**① vs ②③** — To ②: "cheap early" is bait pricing — auth is a one-way door, you can't
export plaintext credentials, migration means forced resets; "hedgeable lock-in" is empty.
To ③: open-source reclaims the *data* but not the *authz model* — your ABAC rules still end
up as the final `join` in your own DB, so OSS adds a service to operate without removing the
hard part. *Concedes: auth isn't differentiating; per-MAU is a real trap.*

**② vs ①③** — To ③: "$tens/month" counts the machine bill, not the head bill — who handles
a CVE at 3am, HA, backups, rollback, credential-stuffing forensics? A hidden on-call job.
To ①: security has no backstop; one slip = stuffing/session-fixation, fatal at seed stage.
To ①'s per-MAU point: you're using a Series-C problem to reject the seed-stage optimum.
*Concedes: long-run cost curve favors ①③; lock-in is real — but both are future-tense.*

**③ vs ①②** — To ①: your weakest link is *writing auth yourself* — if you'll use mature
libs anyway, why not a mature *system* hardened by millions of deployments? I inherit your
authz depth and skip your from-scratch-auth CVE risk. To ②: per-MAU + lock-in/data-residency
are exactly my home turf. *Concedes: buying ships in an afternoon; building suits extreme
customization — but those differ by days, cost/lock-in by years.*

---

### Step 4 — Fact-check (1 neutral verifier; claims extracted from the transcript)

| # | Claim (stance) | Verdict |
|---|---|---|
| 1 | Commercial Auth bills per-MAU; enterprise features sit in higher/"contact sales" tiers (②) | **Supported** |
| 2 | Tens-of-thousands MAU + enterprise SSO → 5-figure USD/yr (①③) | **Supported** (a range) |
| 3 | Keycloak runs tens of thousands of users on a $tens/month instance (③) | **Disputed** — conflates total users vs. concurrency; needs HA/more resources |
| 4 | Keycloak natively ships OIDC/SAML **and built-in SCIM + LDAP/AD** (③) | **Disputed** — SCIM is a default-off experimental feature (to 26.x), long needed extensions |
| 5 | Clerk/Auth0 wire the basic flow in a few hours (②) | **Supported** |
| 6 | WorkOS markets "enterprise SSO in a few lines" (②) | **Supported** |
| 7 | Major vendors have SOC 2 + bug bounty + security team (②) | **Supported** |
| 8 | ~90% of seed startups never reach tens of thousands of MAU (②) | **Disputed** — over-precise; failure rate ~50–90% and measures shutdown, not a MAU threshold |
| 9 | After hosting hashes with Auth0/Clerk, migration can't export plaintext; needs reset/shadow migration (①③) | **Supported** |

> The fact-checker ran web searches and cited sources. Note how it discounts ③'s two
> headline claims (cost #3, SCIM #4) — which directly lowers ③'s score below.

---

### Step 5 — Dedicated Judge verdict (scored)

| Stance | Evidence | Logic | Direct rebuttal | Weighted |
|---|---|---|---|---|
| ② Buy SaaS | 9 | 8 | 8 | **8.3** |
| ① Build | 6 | 7 | 8 | **7.0** |
| ③ Self-host OSS | 5 | 6 | 7 | **6.0** |

**Cruxes**
- **A — Can authz be outsourced?** No — fine-grained authz is the final `join` in *your* DB.
  But ②③ only outsource *authn*, so the right read is **decouple authn from authz**, not "①
  wins." → points to a hybrid, not a single winner.
- **B — Per-MAU billing vs. hidden ops headcount.** ②'s "who handles the 3am CVE / HA /
  backups" lands; ③ never answered it, and fact-check #3 already dented its cost claim.
- **C — Timeline mismatch.** ①③'s advantages are future-tense; ②'s are present-tense, and a
  high-discount-rate seed startup weights the present more (fact-check #8 weakens ①'s urgency).

**Verdict (confidence 65%)** — Not a single winner but a **phased hybrid**:
- **Months 0–12**: **buy authn** (Clerk/Auth0; WorkOS if B2B SSO is near).
- **From day one**: **build authz** in your own DB (the un-outsourceable part).
- **Trigger**: when the per-MAU bill approaches one engineer's monthly cost, or data
  residency becomes a hard requirement, re-evaluate migrating to ① or ③.

**Flip conditions** — Hard compliance (customer VPC / data residency in contracts) → tilts
to ③. Day-one authz that's extremely complex and latency-sensitive → ①'s coupled-`join`
advantage rises (but only for the authz layer).

---

### What this run validated

- **Multi-perspective (3+)**: genuine three-way clash; the verdict mapped conflicting vs.
  reconcilable stances and recommended a hybrid instead of crowning one winner.
- **Fact-checker**: caught the three weakest claims with sources, which measurably lowered
  the stance that leaned on them.
- **Dedicated Judge**: independent 7-part verdict + score table, consistent with the scores,
  with fact-check findings folded in.
- **Continuation note**: this harness exposed no callable "continue subagent" primitive, so
  rebuttals used the robust default (re-spawn + paste the other sides' arguments) — exactly
  why SKILL.md marks continuation as *"if your harness supports it."*
