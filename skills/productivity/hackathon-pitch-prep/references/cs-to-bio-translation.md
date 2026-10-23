# CS-to-Bio Translation Guide (Kamus Hacker Biologi)

When software, backend, or AI engineers build solutions for biotechnology, aquaculture, or life science venture competitions, domain terminology can be intimidating. This rosetta stone maps biological mechanisms directly to Computer Science and systems programming concepts.

---

## 1. Core Systems Mapping

| Life Science Concept | Computer Science Equivalent | How to Explain it at Demo Day |
| :--- | :--- | :--- |
| **DNA / Genome** | **Base Code / Binary Instruction Set** | 4-state digital code (A, T, G, C) storing instructions. 2 bits per base. |
| **Gene** | **Subroutine / Function / Method** | A specific routine with inputs/outputs (e.g., function producing a structural protein or toxin). |
| **Plasmid (e.g., pVA1)** | **External DLL / USB Payload / Plugin** | Extrachromosomal mobile code. Bacteria can ingest this external plugin, acquiring hostile subroutines like *pirAB* toxin expression. |
| **Conjugation (T4SS)** | **P2P Lateral Movement / Worm Spread** | Direct transfer of plasmids between peer nodes via biological tunneling, enabling exponential horizontal spread across a cluster. |
| **eDNA (Environmental DNA)** | **Telemetry Logs / Environmental Core Dump** | Traces shed into water/air. Diagnostic monitoring without needing root/SSH access to the host organism. |
| **16S rRNA Gene** | **MAC Address / SHA-256 System Fingerprint** | Universal marker on all bacteria. Conserved region = vendor OUI; variable regions (V1–V9) = device serial identifying species. |
| **Nanopore Sequencing** | **Wireshark Packet Sniffer (Promiscuous Mode)** | Reads all passing DNA packets in real time. Ideal for discovery of unknown threats across the whole network. |
| **qPCR (Quantitative PCR)** | **Grep Regex + High-Speed Packet Counter** | Targeted query for 1–5 specific signatures with cycle-threshold quantification (Ct value). Fast and low-cost for monitoring. |
| **Compositional Data (16S)** | **Relative CPU Utilization Graph (Sum = 100%)** | Proportions sum to 1. If process B spikes to 90%, process A drops on screen even if its absolute workload never changed. |
| **Centered Log-Ratio (CLR)** | **Log-Ratio Normalization / Scaling** | Mathematical transform projecting simplex compositional data into real Euclidean space to prevent spurious correlation in ML. |
| **Shannon Diversity Index ($H'$)** | **Information Entropy ($-\sum p \log p$)** | Measures community entropy/balance. High entropy = resilient ecosystem; low entropy = single strain dominance / pre-crash state. |
| **Dysbiosis** | **Degraded State / Cascading Latency Anomaly** | Imbalance preceding system crash. The window where preventive remediation (load shedding, siphon) works. |
| **Profile HMM** | **Fuzzy Signature Scanner / Regex Engine** | Probabilistic state machine finding divergent or mutated toxin variants that evade rigid string matching. |
| **Stability Selection (Knapsack)** | **Greedy Knapsack Feature Optimizer** | Selecting top 3–5 informative markers that maximize disease detection under a strict lab budget ceiling. |
| **Ground Truth** | **Golden Dataset / Validated Class Labels** | Confirmed field clinical outcomes (e.g., histopathology or mortality), not surrogate intermediate metrics. |

---

## 2. Pacing and Stage Presence for Tech Founders

1. **Own Your Technical Core:** Never apologize for being a software engineer. Frame computation, data pipelines, and decision intelligence as the true commercial bottleneck in modern genomics.
2. **Asset-Light Lab Operations:** State clearly that wet-lab sequencing and PCR execution are outsourced to accredited partner laboratories.
3. **Advisory Governance:** When regulations cap team size, place molecular biologists and disease pathologists on the official Advisory Board.
