# Math Agent — Complete Architecture Audit

> **Audit date**: 2026-04-27
> **Goal**: One file describing exactly what the system looks like RIGHT NOW (vs. what was only planned).
> **Method**: Direct read of every prompt / skill / knowledge file on disk, plus grep-based verification of cross-references.

---

## Section A — What ACTUALLY EXISTS

### A.1 Skills (under `~/.claude/skills/`)

| Skill | File | Lines (approx) | Last modified | Purpose |
|---|---|---|---|---|
| `math-dispatcher` | `SKILL.md` | 68 | 2026-04-02 | Classifies problems and routes to proof / construct / verify pipelines. Stable, untouched since v2 baseline. |
| `math-proof-agent` | `SKILL.md` | 245 | 2026-04-11 | The five-phase orchestration spec (Scout → Explorer×N → Judge → Audit ⇄ Fix). Canonical entry point. |
| `math-proof-agent` | `orchestrator_update.md` | 175 | 2026-04-21 | v2.2 / v2.3 amendment: adds Integrator stage, dynamic Fixer loop with F4 gates, sub-pipeline dispatch, level-1 library protocol. |
| `math-proof-agent` | `meta_templates.md` | 359 | 2026-04-27 | **Layer 5**: the 8 named meta-templates (MT1–MT8) accounting for ~85% of the library, with examples and anti-patterns. |
| `math-proof-agent/prompts` | `scout.md` | 76 | 2026-04-21 | Step 0a/0b/0b-level1/0c knowledge-base lookup protocol; outputs 3–5 routes. |
| `math-proof-agent/prompts` | `explorer.md` | 146 | 2026-04-27 | Knowledge Reuse Hooks (Layers 1/2/4/5) + REF library citation rules + sub-problem markers + CALL markers. Mandatory `## Hooks Report` block at end. |
| `math-proof-agent/prompts` | `judge.md` | 132 | 2026-04-21 | 4-axis scoring + Pre-Selection Gate + REJECT_ALL branch + v2.3 cross-pollination fragment extraction. |
| `math-proof-agent/prompts` | `judge_ldt.md` | 273 | 2026-04-21 | 5-axis LDT variant with Geometric Content (×1.5) + Evidence Field + vocabulary-bluff warning. |
| `math-proof-agent/prompts` | `auditor.md` | 263 | 2026-04-27 | Step 0.5 reverse consistency + numerical verification + constant tracing + cross-verification + Failure Trigger Scan + Hooks Report Cross-Check + LDT extension + v2.3 SP dual-tagging + F4 Fixer progress check. |
| `math-proof-agent/prompts` | `fixer.md` | 159 | 2026-04-21 | Mandatory Progress ledger block + severity×type SP dispatch (ROUTINE / STRUCTURAL / STRATEGIC) + FIXER-REFUSED protocol + sympy-verification protocol. |
| `math-proof-agent/prompts` | `integrator.md` | 258 | 2026-04-21 | v2.2-P0 integrator: rewrites `best_proof.md` to be self-contained after Auditor PASS. |
| `math-proof-agent/prompts` | `sub_pipeline.md` | 119 | 2026-04-21 | Lite pipeline for `[SUB-PROBLEM:...]` markers (Scout-lite → 1 Explorer → 1 Auditor; depth ≤ 2; breadth ≤ 3). |
| `math-proof-agent/prompts` | `level1_library_protocol.md` | 182 | 2026-04-21 | Per-workdir `level1_lemmas/` directory protocol with `[REF:level1:<file-stem>]` tags and PROVEN/UNPROVEN/KNOWN-FROM status. |
| `math-proof-agent/prompts` | `explorer.md.bak.20260427` | — | 2026-04-27 | Backup of pre-2026-04-27 explorer.md. |
| `math-proof-agent/prompts` | `auditor.md.bak.20260427` | — | 2026-04-27 | Backup of pre-2026-04-27 auditor.md. |
| `math-verifier` | `SKILL.md` | 93 | 2026-04-20 | 4 modes: SymPy, Z3, NumPy, TSV. |
| `math-verifier/prompts` | `verifier.md` | 33 | 2026-04-02 | Skeleton script template. |
| `math-verifier` | `VERIFIED_SYMPY_PROTOCOL.md` | 244 | 2026-04-21 | v2.2-P1 protocol: `[VERIFIED-SYMPY:...]` tag format, R1–R8 script requirements, 4 templates. |
| `math-verifier/sympy-templates` | `template_*.py` (4 files) | — | — | identity-over-parameter-family, recursion-matches-target, polynomial-breadth, base-cases-via-TSV. |
| `math-verifier/tsv` | `tsv_knot.py`, `tsv_group.py`, `tsv_simplicial.py` | — | — | LDT verifier leg (Jones / Alexander / Kauffman / B_n / Dehn-twist / finite simplicial). |
| `math-constructor` | `SKILL.md` | 63 | 2026-04-02 | 3-part output: LaTeX def + condition verification + sympy code. |
| `math-constructor/prompts` | `constructor.md` | 23 | 2026-04-02 | Template for the 3-part output. |
| `math-problem-generator` | `SKILL.md` | 182 | 2026-04-20 | 7 rotation directions, weighted (LDT 10–15%); difficulty-adaptive Explorer count and audit rounds. |
| `math-problem-generator` | `ldt_seeds.md` | — | 2026-04-20 | 18 LDT seed problems. |
| `math-auditor` | `ldt_checklist.md` | — | (created 2026-04-20) | LDT-specific items A–H including F4 Fixer progress gates. |
| `math-auditor` | `integration_check.md` | — | 2026-04-21 | 7-item integrity sweep run after Integrator. |

### A.2 Knowledge Layers (under `workspace/`)

| Layer | File | Lines | Status | Wired into prompt? | Has actually fired? |
|---|---|---|---|---|---|
| **Layer 1 — Strategy index** | `workspace/strategy_index.md` | 1518 | EXISTS, 69 strategy signatures | YES — Explorer Pre-proof Step A; Scout Step 0 | YES — adagrad-complexity Hooks Report cites `adagrad-norm-nonconvex-convergence`, `amsgrad-nonconvex-convergence`. |
| **Layer 2 — Failure triggers** | `workspace/failure_triggers.md` | 951 | EXISTS, ~48 triggers | YES — Explorer Step D; Auditor Failure Trigger Scan section | YES — adagrad-complexity Hooks Report matched `FT-RATE-UB-LB-MISMATCH`; mitigated `FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM`. |
| **Layer 3 — Fragments** | `proofs/fragments/` (40 .md + INDEX.md) | INDEX = 116 lines | EXISTS, 40 lemmas, 38 verified / 2 likely-correct | YES — Explorer "Library Reuse" section (`[REF: proofs/fragments/...]`) | YES — INDEX cross-references show 28 distinct source proofs harvested; multi-fragment reuse documented (polarization-identity-gradient-error in 3 distinct families). |
| **Layer 4 — Structure map** | `workspace/structure_map.md` | 443 | EXISTS, 28 cross-proof links across 5 clusters A–E | YES — Explorer Pre-proof Step C; named explicitly as "Reduction frame" support | YES — adagrad-complexity Hooks Report cites D5 / D1 links from Cluster D. |
| **Layer 5 — Meta-templates** | `~/.claude/skills/math-proof-agent/meta_templates.md` | 359 | EXISTS, MT1–MT8 with frequencies validated against master discovery report | YES — Explorer Pre-proof Step B; instructed to "report at the end which template fired and which slots filled/blocked" | YES — adagrad-complexity report shows "MT1 (Cancellation Pair); slots filled... blocker: IDENTITY/INEQ". |

### A.3 Strategic infrastructure

| Component | File(s) | Status |
|---|---|---|
| Discovery reports (10 parallel agents) | `workspace/discovery_reports/agent_{1..10}.md` + `master_discovery_report.md` (274 lines) | EXISTS. Master report ranks meta-strategies by frequency over 69 proofs; explicitly used to validate the MT1–MT8 frequencies in `meta_templates.md`. |
| Proposer outputs | `workspace/proposer/{ranked_problems.md, gap_matrix.md, pattern_extrapolation.md, failure_conjectures.md, cross_domain_transfer.md, anomalies.md}` + `scripts/` + `results/` | EXISTS as STATIC artefacts of a one-shot task. **Not a running agent** — there is no `proposer/` skill, no SKILL.md, no prompt file. The 73 ranked candidate problems are outputs of a single past run. |
| Failure analysis | `workspace/failure_analysis/{all_failures.md, root_cause_analysis.md, statistics.md, retry_queue.md, retry_results.md}` | EXISTS. 28 problem-level non-PASSes catalogued; root-cause distribution computed (RC1–RC7). |
| Literature crosscheck | `workspace/literature_crosscheck/group_{A..E}/*.md` + summaries | EXISTS. ~76 individual crosscheck files. Static archive. |
| Architecture docs | `agent_architecture.md` (v1), `agent_architecture_v2.md` (frozen, 420 lines), `agent_architecture_v2.1_ldt_extension.md` (168), `agent_architecture_v2.2_integrator.md` (199) | EXISTS. v2 is the frozen baseline; 2.1 added LDT, 2.2 added Integrator. |
| V2 validation | `workspace/v2_validation_report.md` (251 lines) | EXISTS. Tested on 3 proofs (AMSGrad, DP, STORM) — REF mechanism confirmed in 3/3, Auditor numerical-verification confirmed in 6/6 audit rounds. |
| Knowledge-reuse validation | `workspace/knowledge_reuse_validation.md` (243 lines) | EXISTS. Static simulation of 3 archetypal problems against the 5 layers; conclusion: L1+L5 highest leverage, L4 mostly confirmatory, L2 informative when relevant. **No actual proof execution** in this validation. |
| Failure patterns | `workspace/failure_patterns.md` (488 lines) | EXISTS. 17+ entries with v2.1 schema (`domain` / `subdomain` tags); auto-appended via Step F. |
| Technique dictionaries | `workspace/proof_techniques_summary.md` (396 lines), `workspace/proof_techniques_ldt.md` | EXISTS. ~36 techniques; LDT seeded with 10. |

### A.4 Components that DO NOT exist

| Claimed component | Status |
|---|---|
| `workspace/frame_statistics.md` | **DOES NOT EXIST.** No file with this name anywhere in the workspace. |
| `math-explorer` skill | **DOES NOT EXIST** (planned in v2 architecture doc as future work; never created). |
| `math-prover` skill | **DOES NOT EXIST** as a separate skill (referenced in `math-dispatcher` and `agent_architecture_v2.md` but math-proof-agent is the canonical implementation; no `~/.claude/skills/math-prover/` directory). |
| `math-analogist` / analogist agent | **DOES NOT EXIST.** Grep across `~/.claude/` and workspace for "analogist" returns one match (a paste cache file, not a skill). |
| `proposer` skill | **DOES NOT EXIST.** The proposer outputs are static markdown produced by a one-shot task; no SKILL.md, no recurring agent. |
| Auto-Scout (arXiv paper extraction) | **DOES NOT EXIST.** Explicitly disabled in `level1_library_protocol.md`: "[For now, this mode is disabled; requires paper-fetching infrastructure not in V2.3]". |
| 6-frame forced divergence in Explorer | **NOT IMPLEMENTED.** Grep `explorer.md` for "frame" returns zero matches. The Explorer prompt mandates Hooks (Layers 1/2/4/5) and CALL markers, not frame divergence. |

---

## Section B — Complete Flow Diagram (as actually implemented)

```
[user input: theorem]
        ↓
[CLAUDE.md project setup]: create workspace/active/proof_work_YYYYMMDD_HHMMSS/, save problem.md
        ↓
        ┌────────────────────────────────────────────────────────────────┐
        │  PHASE 1 — SCOUT  (Sonnet, 1 agent)                             │
        │  Prompt: prompts/scout.md                                        │
        │  Reads:                                                          │
        │   - problem.md                                                   │
        │   - workspace/proof_techniques_summary.md (Step 0a)              │
        │   - workspace/failure_patterns.md (Step 0a)                      │
        │   - proofs/library/ + proofs/research/ + proofs/fragments/ (0b)  │
        │   - {work_dir}/level1_lemmas/README.md (0b-level1, optional)     │
        │  Writes: routes.md (3–5 candidate routes with [REF:] tags)       │
        └────────────────────────────────────────────────────────────────┘
        ↓ orchestrator picks N routes by difficulty
        ↓ standard=2, advanced=3, research=4, conjecture=5
        ┌────────────────────────────────────────────────────────────────┐
        │  PHASE 2 — EXPLORER  (Opus, N agents IN PARALLEL)               │
        │  Prompt: prompts/explorer.md  +  meta_templates.md (Layer 5)    │
        │  Pre-proof reads (Knowledge Reuse Hooks):                       │
        │    A — strategy_index.md (L1)                                    │
        │    B — meta_templates.md (L5)                                    │
        │    C — structure_map.md (L4)                                     │
        │  During-proof: failure_triggers.md (L2) every ~3 steps           │
        │  Library reuse: proofs/library/, proofs/fragments/ (L3)          │
        │  Sub-problem: emit [SUB-PROBLEM:...] markers (depth ≤ 2)        │
        │  Inline calls: [CALL:math-verifier], [CALL:math-constructor]    │
        │  Writes: proof_route_1.md ... proof_route_N.md                  │
        │  MUST end with `## Hooks Report` block                          │
        └────────────────────────────────────────────────────────────────┘
        ↓ orchestrator scans for CALL markers, executes, injects RESULTs
        ↓ orchestrator scans for [SUB-PROBLEM:...], spawns sub_<N>/
        ↓
        ┌────────────────────────────────────────────────────────────────┐
        │  PHASE 3 — JUDGE  (Sonnet, 1 agent)                              │
        │  Prompt: prompts/judge.md  (or judge_ldt.md if LDT-tagged)       │
        │  Pre-Selection Gate: ELIGIBLE / ELIGIBLE_WITH_GAP / INELIGIBLE   │
        │     / PARTIAL  → REJECT_ALL branch if all INELIGIBLE             │
        │  Scores: completeness, correctness, elegance, gaps (each /10)    │
        │     +Geometric Content (×1.5) for LDT (judge_ldt.md, /55)        │
        │  v2.3: cross-pollination fragment extraction from losing routes │
        │  Writes: evaluation.md (Winner: Route N + reusable fragments)    │
        │  Orchestrator copies proof_route_N.md → best_proof.md           │
        └────────────────────────────────────────────────────────────────┘
        ↓
        ┌────────────────────────────────────────────────────────────────┐
        │  PHASE 4 — AUDITOR  (Opus, 1 agent per round)                   │
        │  Prompt: prompts/auditor.md (+ ldt_checklist.md if LDT)          │
        │  Step 0.5: reverse consistency check (UB vs LB)                 │
        │  Step 1+: per-step VALID / INVALID with severity                │
        │  Numerical verification (≥2 parameter substitutions)            │
        │  Constant tracing table                                         │
        │  Cross-verification (vs library/ + research/ baselines)         │
        │  Failure Trigger Scan (Layer 2) → TRIGGER-CONFIRMED /            │
        │     TRIGGER-MITIGATED / TRIGGER-IRRELEVANT                       │
        │  Hooks Report consistency check                                 │
        │  v2.3: SP dual-tagging [severity=...] [type=...]                │
        │  v2.3: F4 Fixer progress gate (FIXER-PROGRESS / -STALLED /      │
        │     -NEARLY-DONE / -REFUSED-CONFIRMED / -LEDGER-MISSING)         │
        │  Writes: audit_round_N.md                                        │
        └────────────────────────────────────────────────────────────────┘
        ↓ if PASS → skip to Integrator
        ↓ if FAIL or HIGH/MED issues → Phase 5
        ┌────────────────────────────────────────────────────────────────┐
        │  PHASE 5 — FIXER  (Opus, 1 agent per round)                     │
        │  Prompt: prompts/fixer.md                                        │
        │  MUST begin with `## Progress ledger` block                      │
        │  Severity × type SP dispatch:                                   │
        │     ROUTINE → 1-block close;                                     │
        │     STRUCTURAL → full lemma;                                     │
        │     STRATEGIC → FIXER-REFUSED, kick to orchestrator              │
        │  May emit [SUB-PROBLEM:...] (depth ≤ 2)                         │
        │  Sympy verification protocol (v2.2-P1) for finite-param claims  │
        │  Writes: fixed_round_N.md, updates best_proof.md                 │
        └────────────────────────────────────────────────────────────────┘
        ↓ loops back to Phase 4
        ↓ exit conditions (v2.3 dynamic loop, no fixed cap):
        ↓   FIXER-PROGRESS → next round
        ↓   FIXER-NEARLY-DONE → may PASS or do one mop-up
        ↓   FIXER-STALLED → terminate PARTIAL
        ↓   FIXER-REFUSED-CONFIRMED → switch route / re-scout / PARTIAL
        ↓
        ┌────────────────────────────────────────────────────────────────┐
        │  PHASE 6 — INTEGRATOR  (Opus, 1 agent; v2.2-P0)                  │
        │  Prompt: prompts/integrator.md                                   │
        │  Triggers iff: Auditor PASS AND ≥1 Fixer round ran               │
        │  Reads: problem.md, best_proof.md, all explorer/fixer/auditor   │
        │     rounds, level1_lemmas/, verify/                              │
        │  Writes: best_proof_pre_integrator.md (backup),                  │
        │     best_proof.md (rewritten, self-contained),                   │
        │     integrator_report.md                                         │
        │  Then: integration_check.md (Sonnet, 7 items C1–C7)             │
        │     PASS → archive                                               │
        │     FAIL → 1 corrective Integrator pass; if still FAIL, archive  │
        │       with [WARN: INTEGRATION-DEGRADED]                          │
        └────────────────────────────────────────────────────────────────┘
        ↓
[POST-ARCHIVE — SKILL.md Step F]
  - extract failed routes → workspace/failure_patterns.md
  - move work_dir to workspace/archive/
[CLAUDE.md auto-archive]: classify A/B/C, branch, generate
  problem.md/proof.md/report.md/notes.md, update INDEX
```

### Stage-by-stage table

| # | Stage | Role | Prompt | Reads | Writes | Parallel? |
|---|---|---|---|---|---|---|
| 1 | Scout | Route analyst | `prompts/scout.md` | `problem.md`, `workspace/proof_techniques_summary.md`, `workspace/failure_patterns.md`, `proofs/library/`, `proofs/research/`, `proofs/fragments/INDEX.md`, optional `level1_lemmas/` | `routes.md` | No (1 agent) |
| 2 | Explorer | Proof writer | `prompts/explorer.md` + `meta_templates.md` | route assignment, `strategy_index.md`, `meta_templates.md`, `structure_map.md`, `failure_triggers.md`, `proofs/library/`, `proofs/fragments/` | `proof_route_N.md` (with mandatory Hooks Report) | YES (2–5 in parallel) |
| 3 | Judge | Evaluator | `prompts/judge.md` or `prompts/judge_ldt.md` | all `proof_route_*.md`, `problem.md` | `evaluation.md` (+ extracted fragments appended to `best_proof.md`) | No |
| 4 | Auditor | Verifier | `prompts/auditor.md` (+ `ldt_checklist.md`) | `best_proof.md`, `problem.md`, `failure_triggers.md`, `proofs/library/`, `proofs/research/` | `audit_round_N.md` | No (1 round at a time, looped) |
| 5 | Fixer | Repair | `prompts/fixer.md` | `best_proof.md`, latest `audit_round_N.md`, optional `verify/` and `level1_lemmas/` | `fixed_round_N.md`, updated `best_proof.md` | No |
| 6 | Integrator | Self-containment rewrite | `prompts/integrator.md` | full work_dir | `best_proof.md` (overwritten), `integrator_report.md`, `best_proof_pre_integrator.md` | No (≤ 2 invocations) |
| 6b | integration_check | Integrity sweep | `math-auditor/integration_check.md` | rewritten `best_proof.md` | check verdict | No |
| 7 | Archive (Step F) | Failure-pattern extractor | embedded in `SKILL.md` | `failed_attempts/`, `proof_route_N.md` not selected | append to `workspace/failure_patterns.md` | No |
| 7b | Archive (CLAUDE.md) | Index updater | `CLAUDE.md` protocol | `final_report.md` | `proofs/research/.../{problem,proof,report,notes}.md`, `RESEARCH_INDEX.md` / `LIBRARY_INDEX.md` | No |

### Sub-pipeline (depth ≤ 2)

```
[parent Explorer/Fixer emits [SUB-PROBLEM: <statement>]]
        ↓ (parent Auditor admissibility check)
[create sub_<N>/problem.md]
        ↓
Scout-lite (Sonnet, 2 routes max) → Explorer (1 route, 1 agent) → Auditor (1 round, no Fixer)
        ↓
PASS → result.md with [RESOLVED:sub-problem-<N>]; parent cites [REF:sub-problem-<N>]
FAIL → result_failed.md; parent receives a structural SP
```

Hard limits: depth ≤ 2; breadth ≤ 3 sub-pipelines per parent run.

---

## Section C — Knowledge Reuse Integration Points

| Layer | File | Built? | Wired into Explorer? | Wired into Auditor? | Has fired in a real proof? |
|---|---|---|---|---|---|
| L1 — Strategy index | `workspace/strategy_index.md` (1518 lines, 69 sigs) | YES | YES (Pre-proof Step A in `explorer.md`) | NO direct read; Auditor checks Hooks Report consistency only | YES — `adagrad-complexity-improvement-partial-refutation/proof.md` Hooks Report cites adagrad-norm + amsgrad signatures (PARTIAL useful). |
| L2 — Failure triggers | `workspace/failure_triggers.md` (951 lines, ~48 triggers) | YES | YES (During-proof Step D in `explorer.md`) | YES — auditor.md "Failure Trigger Scan" section is mandatory and tags TRIGGER-CONFIRMED / TRIGGER-MITIGATED / TRIGGER-IRRELEVANT | YES — adagrad-complexity matched FT-RATE-UB-LB-MISMATCH; pivoted around FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM. |
| L3 — Fragments | `proofs/fragments/` (40 lemmas + INDEX.md) | YES | YES (Library Reuse rules in `explorer.md`) | YES (REF tags accepted; FRAGMENT-NEEDS-AUDIT for unverified ones) | YES — INDEX cross-references show 28 distinct source proofs, plus polarization-identity-gradient-error reused in 3 distinct proof families per the INDEX. |
| L4 — Structure map | `workspace/structure_map.md` (443 lines, 28 cross-proof links) | YES | YES (Pre-proof Step C, named "Reduction frame" support) | NO direct read | YES — adagrad-complexity Hooks Report references D5/D1 cross-cluster links. |
| L5 — Meta-templates | `~/.claude/skills/math-proof-agent/meta_templates.md` (359 lines, MT1–MT8) | YES | YES (Pre-proof Step B; mandatory report at end) | YES (TEMPLATE-CLAIM-INCONSISTENT flag if claimed template doesn't match structure) | YES — adagrad-complexity Hooks Report claims MT1 (Cancellation Pair); slots filled / blocker IDENTITY/INEQ. |

### Hook firing in practice

Grep result for `Hooks Report` across `proofs/research/`:
- **8 files matched, all in ONE proof folder**: `proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/`.
- **Zero matches** in any other research proof (e.g., none of the 50+ other A-class proofs have a Hooks Report block).
- Most existing A-class proofs predate the v2 Knowledge Reuse Hooks layer in `explorer.md` (the hooks were added in the 2026-04-27 explorer.md update, replacing the pre-2026-04-27 version preserved as `explorer.md.bak.20260427`).

**Implication**: the hooks system is fully wired in the prompt and demonstrably fires when the proof is run AFTER 2026-04-27, but only ONE archived proof has actually exercised it on disk. The full library is grandfathered without hook reports.

---

## Section D — Components That Were PLANNED But May Not Be Implemented

### D.1 Explorer 6-frame forced divergence

**Status: NOT IMPLEMENTED in `explorer.md`.**

- Grep `explorer.md` for `Frame|frame [1-6]|forced|six`: **zero matches**.
- The "frames" terminology lives ONLY in `workspace/proposer/ranked_problems.md`, where each candidate problem carries a "Suggested Explorer Frames" line listing some subset of {Construction, Naive, Adversarial, Orthodox, Reduction, Compositional}. These are *proposer hints to the user*, not forced behaviour of the Explorer agent.
- The Explorer prompt instead mandates: read meta-templates (L5), perform Pre-proof Steps A/B/C (L1/L5/L4), run Failure Trigger Scan (L2) every ~3 steps, end with a Hooks Report. There is no requirement to launch agents under different "frames".

### D.2 Auto-Scout (arXiv paper extraction)

**Status: EXPLICITLY DISABLED.**

`level1_library_protocol.md` §"Population rules" item 2: *"Automatically by Scout (step 0b-extended) when the target problem.md carries a `Source: arXiv:<id>` header. Scout may fetch the paper's referenced lemmas via a citation scan and populate level1_lemmas with `status=UNPROVEN-HERE`. **[For now, this mode is disabled; requires paper-fetching infrastructure not in V2.3]**"*

Population paths that DO work: (1) manual user pre-population of `level1_lemmas/`; (3) dynamic Fixer addition during a round.

### D.3 Proposer agent

**Status: NOT a standalone agent. One-shot task output only.**

- No `~/.claude/skills/math-proposer/` directory.
- No `proposer.md` prompt file anywhere.
- `workspace/proposer/` contains static `.md` reports + `scripts/*.py` + `results/*.csv` from a single past run that produced 73 ranked candidate problems.
- The math-problem-generator skill generates ITS OWN problems by domain rotation; it does not read `workspace/proposer/ranked_problems.md`.
- If a future user wanted to use the ranked problems, they would have to manually paste them into the generator — there is no automated link.

### D.4 frame_statistics.md tracking

**Status: DOES NOT EXIST.**

- `workspace/frame_statistics.md` is not on disk.
- No file in the workspace tree has "frame_statistics" in its name.
- No prompt or SKILL writes such a file.

### D.5 Analogist agent

**Status: DOES NOT EXIST.**

- Grep for `analogist|Analogist|analogy.agent` in `~/.claude/` returns one match in `paste-cache/` (a stale file unrelated to skills).
- No SKILL.md, no prompt, no orchestration mention.
- The functionality conceptually closest to "analogy" is **Layer 4 (structure_map.md)**, which is consulted by the Explorer as part of Pre-proof Step C ("Reduction frame"). That consultation is built into the Explorer prompt — it is not a separate agent.

### D.6 Knowledge system auto-update after each proof

**Status: PARTIALLY IMPLEMENTED.**

| Layer | Auto-updated after proof? | Mechanism |
|---|---|---|
| L1 strategy_index | NO | Manual entry only. The 69 signatures are a static snapshot. |
| L2 failure_triggers | NO | Manual entry only. ~48 triggers were derived offline from `failure_patterns.md`. |
| L3 fragments | NO | Manual extraction. Fragment files in `proofs/fragments/` are hand-curated; INDEX.md is hand-maintained. |
| L4 structure_map | NO | Static snapshot, derived from the 10-agent discovery exercise. |
| L5 meta_templates | NO | Static. Frequencies are validated against master_discovery_report.md, not regenerated automatically. |
| **`failure_patterns.md`** | **YES** | SKILL.md Step F: after archiving, scan `failed_attempts/`, extract failed-route metadata, append. |

The single auto-updated knowledge artefact is `failure_patterns.md`. Everything else requires a manual curation pass (or a fresh discovery-agent run).

---

## Section E — Cross-Domain / Analogy Architecture

Grep results across all relevant files for analogy/cross-domain language:

### E.1 "analogy" / "ANALOGY"

| File | Role | Active or static? |
|---|---|---|
| `workspace/structure_map.md` | Defines **ANALOGY** as one of 5 link types (others: SAME_TEMPLATE, DUAL, GENERALIZATION, SHARPENING, CONTRADICTS). 28 typed links across clusters A–E. The "Reduction frame" support layer. | ACTIVE — `explorer.md` Pre-proof Step C tells the Explorer to "look for ANALOGY links involving your problem's domain"; the `Isomorphism description` field tells what mapping to use. |
| `workspace/structure_map.md` line 5 | *"Used by the Explorer's Reduction frame: before attempting a domain translation… consult this map for ANALOGY links."* | This is the only place "Reduction frame" is named in the prompt-readable infrastructure. |
| `workspace/proposer/ranked_problems.md` | Lists "Reduction" as one of 6 suggested explorer frames per candidate problem. | STATIC hints only — not consumed by any agent at runtime. |
| `workspace/proposer/cross_domain_transfer.md` | One of the proposer's 4 generation modes; lists 18 cross-domain transfer candidates. | STATIC artefact. Not consumed at runtime. |

### E.2 "analogist" / "Analogist"

- Grep across `~/.claude/`: 1 match in `paste-cache/c4662bc96e76979a.txt` (stale paste, not a skill). Inconclusive — definitely not a wired-in agent.

### E.3 "structure_map"

| File | What it says |
|---|---|
| `workspace/structure_map.md` itself | The data file. |
| `~/.claude/skills/math-proof-agent/prompts/explorer.md` | Pre-proof Step C: read structure_map, look for ANALOGY / SAME_TEMPLATE / DUAL / GENERALIZATION / SHARPENING links. |
| `~/.claude/skills/math-proof-agent/SKILL.md` | NOT mentioned (orchestration is layer-agnostic). |
| `~/.claude/skills/math-proof-agent/prompts/auditor.md` | NOT mentioned. (Auditor cross-verifies against `proofs/library/` + `proofs/research/` directly, without going through the structure map.) |
| `workspace/agent_architecture_v2.md` §6.3 | "未启用" (not enabled) for proof→proof reference graph; structure_map is partially this, populated manually for now. |

### E.4 "Frame 4" / "Reduction"

- "Frame 4" — **zero matches** in any prompt or skill file.
- "Reduction" — appears in `structure_map.md` (line 5: "Used by the Explorer's Reduction frame…") and in `workspace/proposer/ranked_problems.md` as one of the suggested explorer frames. **Neither place defines a numbered Frame 4**; the "Reduction frame" is a label inside the structure_map document for "the time when the Explorer is consulting structure_map.md for an analogy".
- The numbered frames (1–6 or similar) are NOT a system feature.

### E.5 Summary of cross-domain architecture

| Component | Type | Active? |
|---|---|---|
| `structure_map.md` (28 cross-proof links) | Data | YES, read by Explorer Pre-proof Step C |
| ANALOGY links inside structure_map.md | Data | YES — Explorer instructed to copy the `Isomorphism description` |
| `cross_domain_transfer.md` (proposer) | Static report | NO — never read at runtime |
| Numbered frames (1–6) | Concept | NO — not in any prompt |
| Forced frame divergence | Mechanism | NO — Explorer is given ONE assigned route by the orchestrator, not multiple frames |
| Analogist agent | Skill | NO — does not exist |

---

## Net assessment

**Five-phase pipeline is fully operational** with v2.3 amendments wired in: Scout → Explorer×N → Judge → Auditor ⇄ Fixer (dynamic loop) → Integrator → integration_check → archive. Sub-pipelines for `[SUB-PROBLEM:...]` markers are wired with depth ≤ 2 / breadth ≤ 3 caps. CALL markers route to math-verifier and math-constructor. Level-1 library protocol is wired but its auto-population from arXiv is disabled; only manual + Fixer-dynamic population works.

**Five knowledge layers (L1–L5) are wired into the Explorer prompt**, plus L2 and L5 are wired into the Auditor. Hooks Reports are mandatory in Explorer output and cross-checked by Auditor. **Empirically, the hooks-system has fired exactly once on disk** (`adagrad-complexity-improvement-partial-refutation`); the rest of the library predates the 2026-04-27 explorer.md hooks-section update. A fresh proof run today will exercise every layer.

**The "frames" / "Analogist" / "Auto-Scout" / "Proposer-as-running-agent" / "frame_statistics" cluster is mostly aspirational**: the data products exist as one-shot static reports under `workspace/proposer/`, and `structure_map.md` is the single piece that bridges into runtime via the Explorer's "Reduction frame" Pre-proof Step C. There is no analogist agent, no auto-scout, no statistics tracker for frame usage, and no automated link from proposer outputs into the problem generator.

**The single auto-updated knowledge artefact** is `failure_patterns.md` (via SKILL.md Step F). All other layers (strategy_index, failure_triggers, fragments, structure_map, meta_templates) are static snapshots requiring manual curation.
