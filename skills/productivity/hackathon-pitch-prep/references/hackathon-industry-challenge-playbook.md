# Hackathon Industry Challenge & Submission Round 1 Playbook

This reference provides the operational framework for executing venture hackathons (such as GenoHack / SoluSEA) where teams must navigate industry challenges, rapid validation sprints, and pre-submission artifact gates.

---

## 1. The Industry Challenge Blueprint: Compact Panel & Cohort Fit
Venture hackathons with corporate partners (e.g., Pathgen, Albitec, AWS) frequently issue specialized "Industry Challenges" alongside open tracks. Across diagnostics, food security, and biomanufacturing, industry partners evaluate designs using four universal constraints:

1. **Compact Panel Architecture:**
   - *The Principle:* More markers is NOT better. Every additional biomarker adds exponential assay complexity, multiplexing interference, and reagent cost.
   - *Benchmark:* Diagnostics typically cap panels at $\le 15$ targets; operational field surveillance (e.g., pond/soil eDNA) caps weekly panels at **3 to 5 actionable markers**.
2. **Local Cohort & Population Fit:**
   - *The Principle:* Public global databases (e.g., TCGA-BRCA, NCBI Western isolates) suffer from massive demographic or geographical bias.
   - *The Pitch Hook:* Show where Western/global references fail locally (e.g., Asian mutation spectra like *PIK3CA H1047L* or regional pathogenic variants like Situbondo IMNV 622-aa deletion) and prove your panel is calibrated for regional realities.
3. **Actionability Over Frequency:**
   - *The Principle:* High frequency alone does not justify inclusion. A marker must directly trigger a validated intervention (targeted therapy in clinical settings; feed reduction, siphoning, or aeration in agriculture).
4. **Cost Proxy Calibration:**
   - *The Principle:* Use target count and multiplex reaction limits as direct proxies for unit COGS. Demonstrate that the resulting test price fits customer willingness to pay.

---

## 2. The Four Lenses of Deep-Tech Commercialization (ALBITEC Framework)
Biotech and deep-tech ventures do not fail because the science is wrong; 42% fail due to "No Market Need". Evaluate every proposal through four distinct lenses:

| Lens | Guiding Question | Critical Hackathon Test |
| :--- | :--- | :--- |
| **1. Desirability** | *Do they actually want it?* | Who feels the pain, how acute is it, and what do they currently use as a workaround? |
| **2. Feasibility** | *Can it be built and repeated?* | Consistent analytical throughput, reproducible yields/detection limits, and asset-light partner workflow. |
| **3. Viability** | *Is it profitable at scale?* | Retail price covers COGS, CAC, and operational overhead with $\ge 50\%$ gross margin. |
| **4. Permissibility** | *Is it legal to deploy and claim?* | Regulatory classification (IVD vs RUO vs animal health monitoring), genetic resource access, and verified marketing claims. |

---

## 3. The 3 Pre-Hackathon Artifacts (Submission Round 1 Gate)
Competitions following Disciplined Entrepreneurship (Aulet Steps 20–24) mandate three deliverables before or during Submission Round 1 (evaluated at 30% total score: Criteria D 15% + Criteria E 15%):

### 1. Worksheet 20.1: Key Assumptions Matrix
Map all venture assumptions across Market, Technical, Financial, and Regulatory axes. Sort by **Impact if Wrong** $\times$ **Thinness of Evidence** (Bland & Osterwalder 2019):
- *Tier 1 (Critical Risks):* High impact, thin evidence $\rightarrow$ **Must test in 48-hour sprint**.
- *Tier 2 (Monitor):* High impact, strong evidence $\rightarrow$ Cite peer-reviewed literature.
- *Tier 3 (Defer):* Low impact, thin evidence $\rightarrow$ Defer until pilot phase.

### 2. Worksheet 21.1–21.2: 48-Hour Rapid Validation Plan
Plan rapid tests for the top 3 assumptions. **Rule: Pass/fail criteria must be written BEFORE executing the experiment**:
- *Market Assumption Test:* Call or message 3–5 target customers/operators. Measure behavior (past spend, current turnaround, willingness to pilot), never polite opinion.
- *Problem Owner Clinic Integration:* Interview visiting industry mentors/problem owners during clinic hours. Capture direct quotes and feedback to substantiate Criteria E.
- *Economic Assumption Test:* Contact 2–3 chemical/reagent vendors to replace estimated TEA guesses with itemized catalog quotes.

### 3. Techno-Economic Analysis (TEA) Sketch
- Detail annual CAPEX + OPEX over annual throughput.
- Itemize per-unit COGS down to consumable reagents, flowcell multiplex allocations, and shipping.
- Run $\pm 20\%$ sensitivity swings on the single largest cost driver to prove gross margin survivability.

---

## 4. Criteria E Rubric (Evidence & Validation 1–5 Scale)

| Score | Evaluator Description | How to Achieve in Hackathon Sprint |
| :---: | :--- | :--- |
| **1** | No validation. | Relying purely on slide concepts without external input. (Automatic fail). |
| **2** | Internal / mentor-only validation. | Discussing only within the team or with assigned academic supervisors. |
| **3** | **3–5 external customer / problem owner conversations.** | Conduct 3–5 targeted interviews during Problem Owner Clinic or via messaging; capture exact operational pain and willingness to pay. |
| **4** | **Written evidence with a documented pivot.** | Document interview notes/chat screenshots in the appendix; show one explicit feature or pricing change made based on user feedback. |
| **5** | Written commitments / LOI / test data. | Signed Letter of Intent, formal pilot site agreement, or shared raw partner test datasets. |

---

## 5. The 9 Cash-Flow Friendly Pricing Models for SMB/Field Verticals
When pitching to farmers, small clinics, or local laboratories, avoid rigid all-or-nothing upfront pricing. Present a menu of de-risked options:
1. **Milestone-Based (Bayar Per Tahap):** Split into 3 installments pegged to operational phases (e.g., DOC 0 stocking, DOC 30 stress window, DOC 60 grow-out). Customers can halt testing anytime and only pay for delivered reports.
2. **Site Package (Base Fee + Per-Unit Rate):** Flat site visit / logistics fee + discounted incremental per-unit fee (e.g., Rp 2.0M site base + Rp 1.5M per pond). Eliminates smallholder pricing penalties for multi-unit facilities.
3. **Harvest Deducted (Potong Panen):** 20% down-payment at start to cover reagent COGS; remaining 80% settled post-harvest via partner offtaker or processing plant deductions. Platform never extends unbacked direct credit.
4. **Fintech / Cooperative Credit Lines:** Platform receives 100% upfront settlement from the lending partner (e.g., input financing programs like eFishery Kabayan); customer repays the lender under established agricultural credit terms.
5. **Success Fee / Performance Contingency:** Fixed base operational fee + success bonus contingent on crop survival without catastrophic disease mortality. Ideal for landing the first 2 lighthouse pilot facilities.
6. **B2B2C Bundling / Third-Party Payer:** Diagnostic service bundled into volume feed or breeding stock contracts; paid directly by corporate integrators to secure supply chain stability.
7. **Multi-Cycle Lock-In:** 10% volume discount for a 3-consecutive-cycle annual contract, securing predictable recurring subscription revenue.
8. **Paid Trial (Never Free):** 1–2 units tested during the first cycle at standard single-tier pricing before facility-wide rollout.
9. **SLA Turnaround Guarantee:** 50% discount or free stage if diagnostic laboratory results exceed turnaround SLA thresholds.

---

## 6. Official Judges' Financial Formulas & Mathematical Proofs
Always compute and present the venture metrics using the exact formulas taught by SoluSEA / MIT Disciplined Entrepreneurship:

1. **Techno-Economic Analysis (TEA) Unit Cost:**
   $$\text{Biaya per Unit (COGS)} = \frac{\text{CAPEX Tahunan} + \text{OPEX Tahunan}}{\text{Output Sampel / Kolam Tahunan}}$$
2. **Gross Profit Margin:**
   $$\text{Gross Margin (\%)} = \frac{\text{Harga Jual Layanan} - \text{COGS}}{\text{Harga Jual Layanan}} \times 100\%$$
3. **Titik Impas / Break-Even Point (BEP in Customers):**
   $$\text{BEP (Customers/Ponds)} = \frac{\text{Fixed Costs Tahunan (Wages + Cloud)}}{\text{Annual Contribution Margin per Customer (Revenue - Variable Costs)}}$$
4. **Lifetime Value (LTV, Step 17):**
   $$\text{LTV} = \sum_{t=1}^{n} \frac{\text{Gross Profit per Cycle} \times \text{Cycles per Year}}{(1 + r)^t}$$
5. **Cost of Customer Acquisition (COCA, Step 19):**
   $$\text{COCA} = \frac{\text{Total Annual Sales \& Marketing Budget}}{\text{New Customers Acquired}}$$
6. **The LTV : COCA Golden Ratio:**
   $$\frac{\text{LTV}}{\text{COCA}} \ge 3 : 1 \quad (\text{Target } 5:1 \text{ to } 7:1 \text{ for high investability})$$
7. **Customer Payback Ratio (ROI):**
   $$\text{ROI} = \frac{\text{Protected Working Capital}}{\text{Service Cost per Cycle}} \quad (\text{Target } \ge 15\times - 45\times)$$

---

## 7. Competitor Wargame Framework & Deadliest-Move Counter-Punches
Never present a simplistic checkmark table. Prepare for judge interrogation by mapping each competitor archetype, anticipating their deadliest competitive move, and delivering a decisive counter-punch:

| Competitor Archetype | Example Players | Deadliest Competitive Move | Platform Defense & Counter-Punch |
| :--- | :--- | :--- | :--- |
| **Well-Funded Regional Diagnostic Labs** | CeKolam (Nusantics) | Opening same-day regional testing facilities and bundling NGS reports with feed mills. | They sell expensive, quote-based academic reports. We deliver **actionable WhatsApp decision alerts** with transparent per-site pricing and adaptive panels. |
| **Dominant Farm IoT & Software Incumbents** | JALA Tech | Adding manual diagnostic test logging into their farm management software. | They are hardware/physicochemical specialists lacking genomic bioinformatic pipelines. We position as an **API partner ("Intel Inside")**, providing the missing biological layer. |
| **Portable On-Site PCR Hardware Kits** | POCKIT / SpeedPCR | Promising 2-hour on-site results at pond edge without sending samples to external labs. | High CAPEX (Rp 80M+), extreme pipetting error by farm hands, and single-target blind spots. We offer **Zero-CAPEX managed service** with ISO-17025 certified lab quality. |
| **Regional Government / Central Labs** | UPT Pasuruan, BBPBAP | Offering subsidized official government testing. | 3–7 day turnaround time means crops die before results arrive; format is an academic certificate without remediation advice. We turn them into **Asset-Light Wet-Lab Partners**. |

