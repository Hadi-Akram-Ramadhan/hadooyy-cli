---
name: hackathon-pitch-prep
description: Use when preparing tech projects for venture hackathons.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [hackathon, pitching, venture, business-plan, tea, unit-economics, pitch-deck, defense, interactive-dashboards]
    related_skills: [claude-design, bolt-slides, frontend-design, humanizer]
---

# Hackathon & Venture Pitch Preparation

## When to Use
Use this skill when preparing a technical, scientific, or deep-tech project for a venture hackathon, startup competition, accelerator demo day, or investor pitch. It bridges the gap when technical builders are confident in code/bioinformatics/engineering but struggle with business viability, commercial pitching, and judge defense.

## The Core Rule (The Kak Dewa Law)
Investors and venture competition judges do not care about your academic citations or code complexity. They care about:
1. **The Bleeding Pain:** How much money or livelihood is destroyed if this problem is not solved?
2. **Who Pays & Why:** Clear distinction between the end user (operator/technician) and the economic buyer (owner/enterprise).
3. **Unit Economics & TEA:** Can this scale profitably, or is each unit a subsidy trap?
4. **Moat & Defensibility:** Why you, and why can't the incumbent (or a university lab) clone this next week?

---

## Standard Workflow

### 1. Rubric & Track Reconnaissance
- Map competition criteria directly into the presentation structure. (e.g., GenoHack/SoluSEA: Criteria D Business Viability 15%, Criteria E Validation & Evidence 15%, Criteria G Market Scale 15% = 45% of total score).
- Identify judge archetypes: Venture capitalists look for TAM/SOM, margins, and sales velocity; technical/academic judges test scientific boundaries and validation honesty.

### 2. The "Bahasa Bayi" (ELI5) & CS-to-Bio Bridge ("Kamus Hacker")
Before technical founders step on stage, they must pass the ELI5 test. If an engineer cannot explain the mechanism and unit economics using everyday school or food analogies, they will panic during Q&A and retreat into defensive jargon. Translate every intimidating domain term into an everyday analogy and Computer Science primitives for software founders (see detailed guide in `references/cs-to-bio-translation.md`):
- *eDNA (Environmental DNA)* → Telemetry logs / server trace dump in the environment (sampling without capturing or SSH-ing into the organism).
- *16S rRNA / Barcode* → MAC address / SHA-256 network fingerprint (universal marker identifying bacterial taxa).
- *Plasmid (e.g., pVA1)* → USB payload / external DLL plugin (extrachromosomal code carrying virulence features like *pirAB*).
- *Conjugation (T4SS)* → P2P lateral malware movement (horizontal gene transfer between bacterial nodes).
- *Nanopore Sequencing* → Wireshark packet capture on promiscuous mode (broad discovery of the whole community).
- *qPCR (Quantitative PCR)* → Grep regex + packet counter (fast, cheap counting of 1–5 known targets).
- *Compositional Data / CLR* → Relative CPU utilization percentage (sum = 100%) vs absolute IOPS; Centered Log-Ratio normalizes compositional distortion.
- *Shannon Diversity Index* → Shannon entropy from information theory ($-\sum p \log p$); measures community balance and system resilience.
- *Dysbiosis* → Distributed system in a degraded state / pre-crash anomaly (early imbalance warning before physical symptoms appear).
- *Profile HMM* → Fuzzy regex / antivirus signature scanner for mutated virulence variants.
- *TEA (Techno-Economic Analysis)* → Itemized recipe unit economics (material & operational costs vs retail price vs gross margin).

### 3. The Cross-Disciplinary Engineer's Mental Block ("Value Architect" Reframe)
When software/CS engineers say *"I understand the code, but I'm completely lost on the business and biology side"*, do not attempt to turn them into academic biologists or MBAs overnight. Reframe their role as the **Systems Integrator & Value Architect**:
1. **The Domain Data Contract:** Wet-lab assays are simply external telemetry sensors. The engineer only needs to master the interface contract: Assay Inputs (Ct values, FastQ reads) $\rightarrow$ Classification/Scoring Engine $\rightarrow$ Zero-Jargon Action Output (e.g. WhatsApp instruction in plain language).
2. **The Value Exchange:** Demystify business down to a 4-line ledger: Customer risks losing 100M $\rightarrow$ pays 4.5M to de-risk $\rightarrow$ platform pays 2.2M to outsourced lab partner $\rightarrow$ platform retains 50% gross margin.
3. **Converting Expert Pushback into Score 4 Gold:** When domain experts or lab technicians state *"your proposed technology (e.g., Nanopore) is overkill and too expensive for routine use"*, engineers often mistakenly fear their proposal failed. In venture judging, this is a **high-scoring asset**: teach the founder to frame it as a proud, proactive **"Measured Pivot"**:
   *"Our initial architecture planned full sequencing, but field lab validation proved it was economically overkill for weekly surveillance. We pivoted to a 2-tier qPCR-First routine model, slashing customer cost while securing a 51% gross margin."*
   This directly satisfies **Criteria E Score 4** (documented external evidence driving a strategic product pivot).

### 4. Positioning: Complementary Plugin, Never Replacement (The Missing Layer)
- **The Golden Rule of Market Positioning:** Never frame deep-tech / biotech analytics as a replacement for entrenched operational hardware that customers have already bought and installed (such as farm IoT probes or smart feeders).
- Frame the product as **"The Missing Layer"** (e.g., The Biological/Genomic Layer).
- Position incumbents as **Channel & API Partners**: Existing tools measure physical/chemical metrics (temperature, pH, dissolved oxygen), but are blind to living pathogens. Your platform acts as a complementary plug-in via open API, providing the missing biological intelligence without disrupting daily customer workflows.

### 5. Audited Data-Grounding (Anti-Halu Protocol)
Never invent numbers or use unverified generalizations in a venture pitch:
- **Cost of Inaction:** Ground in real farm/industrial operating budgets (e.g., 1,000 m² intensive pond = Rp 100M working capital in feed, fry, energy, and labor).
- **Disease & Mortality Windows:** Cite specific peer-reviewed papers (e.g., AHPND 100% mortality in DOC 10–35 via Sen et al. 2026; Situbondo IMNV 622-aa deletion via Mai et al. 2019).
- **Lab Reagent & Throughput Limits:** Ground in real vendor catalog costs and validated multiplex ceilings (e.g., MinION Native Barcoding 75 samples per flowcell via Juanpere-Borràs et al. 2026).
- **Public Genomic Repositories:** For hackathons without live wet-labs, cite verified public databases (e.g., NCBI BioProject PRJNA accessions like PRJNA1087723 for pond water 16S) to prove 100% data integrity without fabrication.
- **Clear Distinction:** Explicitly label what is validated peer-reviewed ground truth, what is verified local field practice, and what is a computational hypothesis scheduled for pilot validation.

### 6. Techno-Economic Analysis (TEA) & Judges' Financial Formulas Suite
Always ground the pitch in Harrison et al. / Aulet Step 24 unit economics and standard venture financial formulas:
- **TEA Biaya per Unit (Harrison et al. 2015):**
  $$\text{Unit Cost (COGS)} = \frac{\text{Annual CAPEX} + \text{Annual OPEX}}{\text{Annual Output (Samples/Ponds)}}$$
  *On asset-light managed service models (renting partner lab capacity), annual CAPEX is zero; COGS is strictly consumable reagents and cold-chain logistics.*
- **Gross Profit Margin:** $\text{Margin (\%)} = \frac{\text{Retail Price} - \text{COGS}}{\text{Retail Price}} \times 100\%$ (target $\ge 50\%$).
- **Titik Impas / Break-Even Point (BEP in Customers):**
  $$\text{BEP (Customers/Ponds)} = \frac{\text{Annual Fixed Costs (Developer Wages + Cloud)}}{\text{Annual Contribution Margin per Customer (Revenue - Variable Costs)}}$$
  *Express BEP as a percentage of the addressable beachhead market (e.g., needing only 2% to 5% beachhead adoption to break even proves low risk).*
- **Lifetime Value (LTV, Step 17):** Calculate gross profit over customer lifetime (e.g., 2-year retention across 5 grow-out cycles).
- **Cost of Customer Acquisition (COCA, Step 19):** $\text{COCA} = \frac{\text{Total Annual Sales \& Marketing Budget}}{\text{New Customers Acquired}}$.
- **The LTV : COCA Golden Ratio:** Enforce $\text{LTV} : \text{COCA} \ge 3 : 1$. (A ratio $> 5:1$ indicates high capital efficiency).
- **Customer Payback Ratio (ROI):** $\text{ROI} = \frac{\text{Protected Working Capital}}{\text{Service Cost}}$ (must achieve $\ge 15\times - 45\times$).
- **Sensitivity Analysis:** Run $\pm 20\%$ cost swings on the primary variable cost (e.g. flowcell / qPCR reagents) to demonstrate gross margin survivability.

### 7. The 9 Cash-Flow Friendly Pricing Models & Lab Reality Pivot
Rural and SMB operators (e.g., farmers, clinics, independent labs) operate on tight, seasonal cash-flow and refuse upfront annual lump sums. Pitching an all-or-nothing upfront price creates instant sales friction. Structure and present flexible, de-risked payment mechanisms (detailed in `references/hackathon-industry-challenge-playbook.md`):
1. **Bayar Per Tahap (Milestone-based):** Charge per completed sampling stage (e.g., DOC 0, 30, 60); customers can halt anytime and pay 7 days post-result.
2. **Paket Per Tambak (Base Fee + Per-Unit Rate):** Flat site visit/logistics fee + discounted per-pond fee. Solves the smallholder penalty (e.g., 3 ponds pay Rp 6.5M instead of Rp 13.5M).
3. **Potong Panen (Harvest-Deducted):** 20% down-payment at stocking to cover reagent COGS; remaining 80% deducted from crop sale via partner offtaker/cooperative. (Platform never issues unbacked micro-loans).
4. **Third-Party Financing / Fintech (e.g., eFishery Kabayan):** Platform is paid 100% upfront by lending partner; customer repays lender via standard feed credit lines.
5. **Success Fee:** Base operational fee + success bonus contingent on crop survival without catastrophic disease.
6. **B2B2C Bundling:** Service bundled into premium feed/fry purchases; customer perceives it as free; feed mill pays platform.
7. **Annual Multi-Cycle Contract:** 10% discount for 3 locked consecutive cycles to ensure predictable recurring revenue.
8. **Paid Trial (Never Free):** 1–2 units tested at single-tier pricing during the first cycle before scaling across the entire facility.
9. **SLA Service Guarantee:** 50% discount or free stage if lab results exceed turnaround SLA.
- **The Lab Reality Check & 2-Tier Pivot:** When wet-lab interviews reveal that an advanced technology (e.g., Nanopore/NGS) is overkill and cost-prohibitive for routine surveillance, **pivot immediately to a 2-tier architecture**:
  - *Tier 1 (Routine Surveillance):* 100% targeted, fast, inexpensive method (e.g., qPCR-First) to minimize recurring COGS.
  - *Tier 2 (On-Demand / Anomaly Investigation):* Reserve the advanced sequencing instrument for initial seasonal community baselines and unresolved outbreak investigations.
  - *Framing:* Present this not as a setback, but as an empirical, customer-driven pivot that elevates the venture to **Criteria E Score 4**.

### 8. Competitor Wargame & Deadliest-Move Counter-Punch
Judges will test defensibility against well-funded incumbents, regional diagnostic labs, and field kits. Never dismiss competitors with generic checkmark tables. Map the wargame:
- **Incumbent Diagnostic Labs (e.g., CeKolam/Nusantics):** They have regional labs and capital. *Deadliest Move:* Lowering test fees and bundling with feed mills. *Counter-Punch:* They sell expensive, quote-based academic reports; your platform sells **actionable WhatsApp decision alerts** with transparent per-site pricing and adaptive panels.
- **Farm Management Platforms (e.g., JALA):** They own the farmer relationship. *Deadliest Move:* Launching their own disease log. *Counter-Punch:* They are hardware/physicochemical IoT specialists, not genomic bioinformaticians. Position as an **API partner ("Intel Inside")**, feeding genomic risk metrics into their app.
- **Portable On-Site Kits (e.g., POCKIT):** *Deadliest Move:* Promising 2-hour results at pondside. *Counter-Punch:* Extreme CAPEX (Rp 80M+), high operator pipetting error, and single-target blind spots. Your platform offers **Zero-CAPEX managed service** with ISO-accredited lab quality.

### 9. Interactive HTML Dashboards & Printable Worksheet Dossier
Never stop at static Markdown documents. Whenever delivering business plans, unit economics, or hackathon worksheets, build an interactive zero-build HTML dashboard with:
- **Zero-Jargon / ELI5 Mode ("Bahasa Bayi"):** Toggleable visual cards translating complex bioprocesses and pricing math into plain everyday analogies.
- **Interactive Financial & Pricing Sliders:** Real-time recalculation of BEP, LTV:COCA, and cash-flow milestones for arbitrary customer sizes.
- **Competitor Battle Radar & Matrix:** Interactive side-by-side breakdown of features, pricing, and counter-punches.
- **Printable Submission Dossier (`@media print`):** Formatted clean printable report containing official Worksheet 20.1, 21.1–21.2, 22, Pak Gatot field quotes, and formal signature blocks ready to export to PDF for Submission Round 1.
- **Defensive Tab Routing Rule (Anti-Crash Guard):** When implementing tab-switching functions (e.g., `switchTab(tabId)` / `switchView(viewId)` iterating over ID lists), an ID mismatch between the array and the HTML element produces `null`, causing `.classList.add/remove` to throw an uncaught `TypeError: Cannot read properties of null (reading 'classList')` that freezes all tabs. **Always guard lookups:** `if (el && btn) { el.classList.remove('hidden'); ... }` and maintain strict 1:1 parity between list tokens and DOM IDs (`view-${id}`, `tab-btn-${id}`).
- **Multiline String Literal Hygiene in Inline JS:** In inline `<script>` blocks, never write multiline strings with physical raw newlines inside single (`'`) or double (`"`) quotes. Raw physical newlines throw a fatal `SyntaxError: Invalid or unexpected token` at parse time, which aborts script parsing and prevents all functions (`switchView`, event handlers) from being defined, cascading into `ReferenceError: <fn> is not defined`. **Always escape with `\n` or use ES6 template literals (backticks `` ` ``)**. Always validate with a JS interpreter (`node -e "new Function(scriptContent)"`) before saving.

### 10. Disciplined Entrepreneurship Step 22 (MVBP vs Prototype Rule)
Judges sharply differentiate a technical Prototype from an MVBP:
- **Prototype:** Tests technical feasibility ("Does the code / wet-lab pipeline work?").
- **MVBP (Step 22):** Tests transactional business viability through three non-negotiable tests:
  1. *Value Test:* Does the end user receive undeniable operational benefit (e.g. 5–7 day early warning preventing crop loss)?
  2. *Pay Test ($> 0$):* Does the economic buyer pay real money or commit budget? (Free trials do NOT validate an MVBP; use subsidized pilot pricing instead).
  3. *Feedback Loop:* Is there an active feedback channel (e.g. WhatsApp confirmation of actions taken) to iteratively calibrate the product?
- **Concierge MVP Strategy:** Do not build end-to-end automation before validating demand. Run wet-lab intake and messaging semi-manually ("Concierge before you automate") to verify willingess-to-pay with zero software waste.
- **Step 24 Product Evolution Roadmap:** Present a disciplined 3-stage horizon:
  - *V1 (Months 1–6, TRL 4):* Concierge managed service for 2 lighthouse pilot facilities (outsourced partner lab, manual alert QA).
  - *V2 (Months 7–18, TRL 5–6):* Structured REST API integration into incumbent platforms (e.g. JALA) + bundled input financing (e.g. eFishery).
  - *V3 (Months 19+, TRL 7–8):* Autonomous genomic surveillance platform, novel pathogen shotgun discovery, and national crop insurance underwriting.

### 11. 180-Second (3-Minute) Timed Pitch Deck Architecture
A winning 10-slide venture deck allocates time strictly:
- **Slide 1: Hook & Vision (00:00–00:20):** Company name, memorable motto ("Sequencing to discover, qPCR to monitor, Bahasa to act").
- **Slide 2: Bleeding Problem (00:20–00:50):** The exact financial loss and why existing sensors fail (sensor IoT measures physics/chemistry, but is blind to living biology).
- **Slide 3: Complementary Position & Gap (00:50–01:10):** The Missing Biological Layer; complement existing IoT instead of replacing it.
- **Slide 4: Solution & Dual-Stream Workflow (01:10–01:40):** Step-by-step workflow from sample to decision (Nanopore discovery + weekly qPCR monitoring).
- **Slide 5: Track Specific Alignment (01:40–02:00):** Address the thematic track mandate (e.g. biodiversity monitoring via Shannon Index and stopping rogue antibiotics).
- **Slide 6: Product Demo / UI (02:00–02:20):** High-contrast, mobile-first edge-of-pond interface.
- **Slide 7: Unit Economics & TEA (02:20–02:40):** The 51% margin and 22x customer payback.
- **Slide 8: Market Sizing & Beachhead (02:40–02:50):** TAM, SAM, and local geographic beachhead (e.g. 1,200 intensive ponds).
- **Slide 9: Hilirisasi & TRL Roadmap (02:50–03:00):** TRL 3 (NCBI dataset proof) → TRL 4 (retrospective validation) → TRL 5 (field pilot).
- **Slide 10: Team & Advisory Board (03:00 Closing):** Core technical engineers + external domain advisors.

### 12. Killer Q&A Defense Strategy
- **Never Bluff Scientific Bounds:** If testing on synthetic data, explicitly state it validates computational pipeline throughput, while clinical accuracy is the milestone of the upcoming retrospective validation phase.
- **Respect Biological Limits:** Never claim 16S amplicon sequencing discovers novel RNA viruses; explain that 16S maps bacteria, while viruses require target amplicons or shotgun metagenomics on the future roadmap.
- **Embrace Incumbents as Partners:** Never claim to "kill" dominant platforms like JALA; position your solution as an API partner adding the missing biological layer.
- **Team Size Compliance:** If competition rules cap team size (e.g. 6 members), appoint wet-lab scientists or pathologists to the official **Advisory Board**, not as unapproved team members.

### 13. Interactive Learning & Pitch Suite Deliverable
Deliver pitch preparation as an integrated, zero-build suite of self-contained HTML files (Tailwind CDN + Chart.js):
- `index.html`: Central portal connecting all tools.
- `business-simulator.html`: Interactive TEA sliders, sensitivity analysis, and P&L charts.
- `unit-economics-efishery.html`: Dedicated ELI5 / Bahasa Bayi explainer and sector titan comparison.
- `pitch-deck-interactive.html`: 10-slide deck with rehearsal timer, speaker notes, and taboo warnings.
- `genomics-pipeline.html` / `pipeline-visualizer.html`: Interactive wet-to-dry mock data flow.
- `competitive-moat.html`: Multi-dimensional capability radar chart.
- `qa-simulator.html`: Double-sided flip flashcards for judge question mastery.
- `worksheet-generator.html`: Interactive generator for Steps 20–22, financial engine, and competitor wargame.
- `docs/`: Markdown guides for reading on mobile.

All dashboards must run instantly when double-clicked or hosted via GitHub Pages without Node.js or build steps.

### 14. National Deep-Tech & Grant Proposal Format (LPDP / Kemdiktisaintek Standard)
When formal submissions require an official proposal document rather than slides (e.g. Program Hackathon Deeptech Kemdiktisaintek / LPDP), adhere strictly to the standardized 5-part structure and typography rules (Times New Roman 12pt, line spacing 1.15):
1. **Judul Proposal:** Exact project name and bilingual title; list team name and academic institution.
2. **Executive Summary (Hard limit: max 250 words):** Must concisely synthesize 6 mandatory elements: (a) resulting innovation, (b) target users, (c) commercial value/economic loss addressed, (d) competitive advantages, (e) project roadmap summary, and (f) explicit baseline-to-target TKT/TRL trajectory (e.g., TRL 2 to TRL 5).
3. **Deskripsi Inovasi (Max 2 pages):**
   - *Problem Statement:* Background, user target, evidence of acute need, performance targets, and commercial spin-off/commercialization channel.
   - *Initial Solution:* Core technological paradigm ("sequencing to discover, qPCR to monitor, local language to act"), 4 system pillars, scientific basis (e.g. host-to-environment microbiome convergence), and comparative matrix against existing tools.
   - *TRL / TKT Progression:* Ground initial TRL (TRL 2) in peer-reviewed citations; detail phased targets (TRL 3 PoC -> TRL 4 retrospective -> TRL 5 field pilot -> TRL 6 commercialization).
   - *Roadmap & Timetable (6–12 months):* 5-phase breakdown with structured monthly timetable and user validation interview plan (7 structured questions).
   - *Team Composition & Roles:* Multi-disciplinary division (AI/bioinformatics, business, UI/UX, backend, data/infra) plus advisory/wet-lab addition during bootcamp.
   - *Partner & User Support:* Academic backing, target pilot facilities, partner molecular labs, and incumbent software platform integrations.
4. **Pembagian Tugas & Monitoring Internal (Max 1 page):** Detailed task matrix per member (roles, specific responsibilities, target outputs) and 4-tier internal quality control: weekly agile sprints/daily standups, milestone TRL reviews, branch-protected git code reviews with automated CI/CD, and digital activity logbooks.
5. **Daftar Pustaka:** Strictly numbered in citation order ([1] to [N]).
6. **Pakta Integritas:** Official LPDP / ministry integrity pact template; keep unexecuted/unfilled until formal team submission.
