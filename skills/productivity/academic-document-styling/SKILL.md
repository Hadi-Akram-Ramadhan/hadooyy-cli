---
name: academic-document-styling
description: "Use when formatting academic text and scientific terms."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [academic, proposal, journal, italics, typography, nomenclature, eyd, apa]
    category: productivity
    related_skills: [docx, pdf, grounded-citations]
---

# Academic Document Styling & Nomenclature

Guidelines and audit workflows for scientific nomenclature, typography, foreign loanwords, and academic reference styles across formal proposals, thesis manuscripts, and peer-reviewed journal submissions.

## When to Use

- Auditing or correcting formatting (italics, casing, abbreviations) in academic proposals, papers, or technical reports.
- Applying proper binomial nomenclature (genus/species), gene vs. protein casing, and biochemical symbols.
- Checking foreign terms and loanwords against standard Indonesian orthography (EYD V and KBBI VI).
- Ensuring reference list adherence to APA 7th Edition typography rules.

## Core Rules & Typographic Conventions

### 1. Binomial & Taxonomic Nomenclature
- **Genus & Species:** Strictly italicized (*Penaeus vannamei*, *Vibrio parahaemolyticus*, *Litopenaeus vannamei*, *Escherichia coli*). Capitalize genus only; species epithet is always lowercase.
- **Genus Alone:** Italicized when referring to the genus taxon (*Vibrio*, *Penaeus*). Roman when referring loosely to group members ("vibrio-like bacteria").
- **Higher Taxa (Family, Order, Class):** Roman with initial capital (Vibrionaceae, Decapoda, Crustacea).
- **Common / Vernacular Names:** Roman, lowercase (*udang vaname*, *udang windu*, *platypus*). In Indonesian, "vaname" is an official KBBI entry; do not italicize.
- **Within English Reference Titles (APA 7):** Article titles in reference lists use sentence-case roman, but embedded scientific binomial names (*Penaeus vannamei*) **must remain italicized**.

### 2. Genetics & Molecular Nomenclature (ASM, CDC Guidelines)
- **Bacterial & Viral Genes:** Lowercase, italicized (*pirA*, *pirB*, *pirAB*, *gyrA*, *16S rRNA* gene).
- **Proteins & Toxins:** Roman, capitalized initial (PirA, PirB, PirAB, PirAB toxins, Cry toxin). When text reads "toksin PirAB", write PirAB in roman capital; if referring to the gene complex, write "gen *pirAB*".
- **Acronyms of Diseases & Viruses:** Roman uppercase (AHPND, WSSV, IMNV, IHHNV, TSV).

### 3. Citations & Reference Lists (APA 7th Edition)
- **"et al." in Citations:** Roman (never italicized). APA 7th Section 6.29 explicitly designates Latin abbreviations ("et al.", "e.g.", "i.e.") to remain roman.
- **Periodical / Journal Titles:** Strictly italicized (*Microbiology Spectrum*, *Vaccine*, *Aquaculture*, *Diseases of Aquatic Organisms*).
- **Article Titles:** Roman sentence case. Do not italicize general English words (e.g. *sampling*, *detection*, *approach*) simply because they are in an English title.

### 4. Indonesian Formal Prose & Foreign Terms (EYD V & KBBI VI)
- **Unassimilated Foreign Terms:** Words not yet registered in KBBI VI must be italicized (*dataset*, *mobile*, *mobile-first*, *pipeline*, *frontend*, *backend*, *wet-lab*, *deployment*, *hatchery*, *lo-fi*, *hi-fi*, *proof of concept*).
- **Official KBBI Entries:** Words registered in KBBI VI remain roman ("pilot" as an adjective for trial/experimental, e.g. "pilot lapangan"; "probiotik", "parameter").
- **Colloquial / Non-Standard Entries:** Words marked *cak* (ragam cakapan) in KBBI (e.g. "monitoring") must either be italicized (*monitoring*) or replaced with standard formal terms ("pemantauan").
- **Technical Prefixes & Initialisms:** Roman (eDNA, qPCR, PCR, API, MVP, QC, TKT, NDA). The lowercase letters in "eDNA" (environmental) and "qPCR" (quantitative) are technical prefixes, not algebraic variables; never italicize "e" or "q".
- **Proper Names and Program Titles:** EYD V explicitly exempts proper nouns from italics. Program and challenge titles ("PROGRAM HACKATHON DEEPTECH 2026") remain roman.

## Document Inspection & Patching Workflow (.docx)

1. **Check Exclusive Locks:**
   On Windows, open Word documents lock the file (`[Errno 13] Permission denied`). Test writability first; if locked, save changes to a non-colliding path (`<name>_revised.docx`).
2. **Scan Structured Containers:**
   Proposals and forms place critical text inside table cells. Always inspect `doc.tables` recursively alongside `doc.paragraphs`.
3. **Normalize Runs Before Matching:**
   Word often fragments a single phrase across multiple adjacent runs. Merge runs sharing identical font and style properties before searching for targets to avoid missed splits.
4. **Selective Run Splitting:**
   When formatting a specific target within a run, split the run into `[before, target, after]` slices, copy the exact font name, size, bold, and color properties to all slices, set `italic = True` only on the target slice, and reinsert in-place using `addnext()`.
5. **Verify Package Integrity:**
   Ensure OPC relationship IDs (`word/_rels/document.xml.rels`) resolve correctly and test readability with a fresh `docx.Document` instance.
