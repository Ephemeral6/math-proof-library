# Three-Tier v2.2 Upgrade — Consolidated Summary

**Date.** 2026-04-21.

**Upgrade layers.** P0 Integrator role → P1 Verified Sympy Block
protocol → P2 TSV-Simplicial upgrade roadmap.

**Trigger.** External review of the spiral-knots stress test
(Blackwell–Das–Mayer–Moyar–Quraishi–Stees, arXiv:2506.17889) returned
a **B+** verdict. Three concrete findings:

1. `best_proof.md` was not self-contained: the reader had to open
   `fixer_work/` files to recover key lemmas.
2. Step 5 cited an induction on the leading principal minors that had
   already been falsified in Round 0.
3. Step 6 cited an obsolete fragment.

P0 addresses (1)–(3) for this one artifact; P1 and P2 are systemic
upgrades prompted by gaps the review exposed.

---

## P0 — Integrator role

**Goal.** Introduce a pipeline role that rewrites `best_proof.md`
after the Auditor's PASS so the proof is self-contained, with the
Integrator's output re-checked by an integration_check sweep.

**Files authored (global).**

- `~/.claude/skills/math-proof-agent/prompts/integrator.md`
- `~/.claude/skills/math-auditor/integration_check.md` (7-item
  checklist: C1 source traceability, C2 cross-refs, C3 citation
  definitions, C4 VERIFIED-SYMPY tag validity, C5 definition
  discipline, C6 conclusion match, C7 stuck-point bookkeeping)
- `~/.claude/skills/math-proof-agent/orchestrator_update.md` — note
  on how the pipeline's 5-phase loop is extended to a 6-phase loop.
- `workspace/agent_architecture_v2.2_integrator.md` — the new
  architecture document (`agent_architecture_v2.md` is **not**
  modified; it is frozen).

**Test application.** Ran Integrator on the spiral knots artifact.

- `workspace/active/ldt_spiral_knots_stress_test/integrator_report.md`
  — 6 sections: §0 target ToC, §1 10 obsolete fragments removed, §2
  17 new fragments integrated, §3 citation-ledger update (L1: 6→10;
  Independent: 6→12), §4 8 cross-reference fixups, §5 script roster,
  §6 residual gaps (none).
- `workspace/active/ldt_spiral_knots_stress_test/best_proof.md`
  rewritten: 214 lines → 528 lines (+147%); 22,340 bytes → 38,741
  bytes (+73%); stuck-point tags 3→0; inlined lemmas 0→3. Delta
  documented in `workspace/diag/spiral_knots_post_integrator_delta.md`.
- `workspace/active/ldt_spiral_knots_stress_test/integration_check_report.md`
  — integration_check first-try PASS on all 7 items.

**Effect on verdict.** B+ finding (1) (self-containment) and finding
(2) (Step 5 stale induction) are addressed by the rewrite. Finding
(3) (Step 6 stale citation) also addressed.

**Status.** COMPLETE.

---

## P1 — Verified Sympy Block protocol

**Goal.** Formalize the boundary between **symbolic claims** (which
must be proved in the body) and **empirical sympy certifications**
(which certify a finite parameter range). Provide machine-verifiable
inline markup so the Auditor can mechanically check that each
empirical claim is backed by a runnable script that exits 0 and
announces its case count.

**Files authored (global — the protocol).**

- `~/.claude/skills/math-verifier/VERIFIED_SYMPY_PROTOCOL.md` —
  8-section document (motivation, inline tag format, roster format, 8
  script requirements R1–R8, scope limits, 4 template IDs +
  `bespoke`, lifecycle, retroactive-application policy, governance).
- Four templates (each runs standalone with protocol-compliant
  output):
  - `template_identity_family.py` — (x+1)^n = Σ C(n,k) x^k, 30 cases.
  - `template_recursion_target.py` — Fibonacci vs Binet, 15 cases.
  - `template_polynomial_breadth.py` — Φ_{n+1}(x) has breadth n, 16
    cases. Handles Laurent polynomials via `var**shift`.
  - `template_base_cases_tsv.py` — Alexander of 3_1, 4_1, 5_1 vs TSV,
    3 cases, graceful skip when a knot is out-of-scope.
- `~/.claude/skills/math-auditor/ldt_checklist.md` — §F3 added with
  7 procedures (missing tag → HARD FAIL; missing protocol block →
  FLAG; case-count mismatch → FLAG; non-deterministic → FLAG; >60s
  → FLAG; empirical claim without tag → FLAG; scope overreach → HARD
  FAIL). F3 row added to output-format table.
- `~/.claude/skills/math-proof-agent/prompts/fixer.md` — rewritten
  "Sympy-verification protocol (v2.2-P1)" section with rules of
  thumb and an extended output template.

**Retroactive application to spiral knots.**

- Relocated 9 protocol-eligible scripts from `fixer_work/` to
  `workspace/active/ldt_spiral_knots_stress_test/verify/`.
- Edited each to add the `[VERIFIED-SYMPY-PROTOCOL: <template-id>,
  cases=<N>, description=<...>]` docstring line, explicit PASS/FAIL
  counting, and final-line `ALL PASSED: N cases` print + `sys.exit`.
- **All 9 scripts exit 0; total 643 cases.** Per-script counts:
  `verify_p5.py`=30, `verify_Ek.py`=62, `check_recursion.py`=24,
  `find_Qk.py`=11, `sp2_verify_phi_p.py`=62, `sp2_Ck_at_y1.py`=258,
  `sp4_breadth.py`=6, `sp4_monomial.py`=62, `sp4_topbot.py`=128.
- 9 inline `[VERIFIED-SYMPY:...]` tags added to `best_proof.md` at
  Steps 5 (Lemma Q, recursion R), §§10.4, 10.5, 10.6, 10.7.
- §13 Numerical-verification script roster rewritten as a
  script/template/cases/description/inline-cite table.
- **C4 re-run:** parsed the 9 inline tags, ran each referenced
  script, diffed claimed `cases=N` against the ALL-PASSED line.
  Result: **0 mismatches / 0 missing / 9 PASS**. Recorded in the
  updated `integration_check_report.md`.

**Effect on verdict.** With machine-verifiable tags, the Auditor can
mechanically re-certify each empirical claim in `best_proof.md`; the
"is this sympy script still the one that supports this step?"
question is no longer manual. Addresses a lingering gap the B+ review
flagged regarding sympy dependency.

**Status.** COMPLETE.

---

## P2 — TSV-Simplicial upgrade roadmap (document-only)

**Goal.** Scope the capability upgrades the math-verifier's TSV
module would need in order to mechanically (not just on-citation)
check LDT proof steps across the five research subdomains under
`proofs/research/low-dimensional-topology/`. No code.

**File authored.** `workspace/diag/TSV_SIMPLICIAL_UPGRADE_ROADMAP.md`
(392 lines), 4 sections:

- **§1 Capability demands** — 39 numbered capabilities across the 5
  subdomains (K1–K8 knot-theory, M1–M8 mapping-class-groups, C1–C8
  curve-complex, T1–T6 teichmuller, 3M1–3M8 three-manifolds). Each
  tagged finite / infinite / citation-only.
- **§2 Capability DAG** — 5 tiers (Tier 0 regression, Tier 1 table
  expansion & existing formulas, Tier 2 intersection/simplicial,
  Tier 3 external solvers, Tier 4 citation-only).
- **§3 Feasibility assessment** — cost / risk / hit-rate per
  capability. Tier 0 + Tier 1 ≈ 15 engineer-days with low aggregate
  risk and ≈ 55% projected hit-rate on current LDT stuck-points.
- **§4 MVI proposal** — 5 deliverables totalling ~6 engineer-days:
  K4 Kauffman-bracket regression fix; K1 table expansion to 30
  knots; K2 Burau-Alexander for B_n, n ≤ 6; C1 Farey-graph oracles
  for S_{0,4} and S_{1,1}; Tier-4 citation-DB seed. Non-goals
  explicitly enumerated.

**Design decision.** Prefer table expansion + cross-check over
symbolic-first. Rationale: the current K4 regression (wrong Kauffman
bracket for the right trefoil, shipped with `high` confidence) came
from a symbolic-first implementation; given LDT's convention
landscape, a hand-curated table with cross-checks is the safer
pattern.

**Status.** COMPLETE. Roadmap is ready for ship/no-ship review.

---

## Current system capability state (post-P0/P1/P2)

| Layer | Capability | State (before) | State (now) |
|-------|------------|----------------|-------------|
| Pipeline | Self-containment of `best_proof.md` | Not guaranteed (reader had to open `fixer_work/`) | Guaranteed by Integrator role + integration_check |
| Pipeline | Proof step → sympy script linkage | Informal prose ("verified numerically") | Inline `[VERIFIED-SYMPY:...]` tags; Auditor F3 checks them |
| Pipeline | Sympy scripts on disk | Ad hoc; no common layout | Protocol (R1–R8), 4 templates, per-work-dir `verify/` home |
| Artifact | Spiral-knots proof | 214 lines, 3 stuck-point tags, relied on opening Fixer files | 528 lines, 0 stuck-point tags, 9 inline sympy tags cross-checked against 9 protocol-compliant scripts (643 cases) |
| Verifier | `tsv_knot.py` correctness | K4 regression (Kauffman bracket shipped wrong with `high` confidence) | Documented; fix scheduled in P2 MVI Item 1 |
| Verifier | TSV coverage of LDT | 7 knots + B_2 Burau + Farey-ish simplicial | Roadmap authored; MVI (~6 d) scoped to roughly double coverage and net 30pp stuck-point reduction |

---

## Next-action candidates (non-recommended; choose one)

The three-tier upgrade is complete. Reasonable next moves, in no
particular order:

### Candidate A — Execute the P2 MVI (~6 engineer-days).

Ships the K4 regression fix, K1 table expansion, K2 Burau-Alexander
for $B_n$ up to $n = 6$, C1 Farey-graph oracles for $S_{0,4}$ and
$S_{1,1}$, and a Tier-4 citation database seed. Highest payoff for a
concrete pipeline capability increase; medium aggregate risk driven
by K2's convention-sensitivity.

### Candidate B — Re-run the spiral-knots stress test through the upgraded pipeline and re-solicit external review.

Uses the existing artifact; quickest path to a verdict on whether
P0+P1 actually flip B+ → A/A−. No pipeline changes needed (but the
rewritten `best_proof.md` now has inline tags, which was the review's
lingering concern). Risk: external reviewer may raise a new finding
unrelated to self-containment or sympy linkage.

### Candidate C — Apply Integrator + Verified Sympy protocol to another existing LDT artifact as a second confirmation.

Most of the recent proofs under `proofs/research/optimization/` and
`proofs/research/learning-theory/` were audited before P0/P1 existed;
a small integration pass on one of them would provide a second data
point on whether the upgrades generalize or whether spiral-knots was
a one-shot fit. Cheap (~1-2 d) but does not itself increase pipeline
capability.

---

## Deliverables index (this upgrade)

Global (under `~/.claude/skills/`):

- `math-proof-agent/prompts/integrator.md` — new.
- `math-proof-agent/prompts/fixer.md` — rewritten (P1 section).
- `math-proof-agent/orchestrator_update.md` — new.
- `math-auditor/integration_check.md` — new.
- `math-auditor/ldt_checklist.md` — §F3 added + output-format row.
- `math-verifier/VERIFIED_SYMPY_PROTOCOL.md` — new.
- `math-verifier/sympy-templates/template_identity_family.py` — new.
- `math-verifier/sympy-templates/template_recursion_target.py` — new.
- `math-verifier/sympy-templates/template_polynomial_breadth.py` — new.
- `math-verifier/sympy-templates/template_base_cases_tsv.py` — new.

Workspace:

- `workspace/agent_architecture_v2.2_integrator.md` — architecture doc.
- `workspace/ldt_extension_log.md` — P0/P1/P2 checkpoints appended.
- `workspace/diag/spiral_knots_post_integrator_delta.md` — P0 delta
  report.
- `workspace/diag/TSV_SIMPLICIAL_UPGRADE_ROADMAP.md` — P2 roadmap.
- `workspace/diag/three_tier_upgrade_summary.md` — this document.

Spiral-knots artifact:

- `workspace/active/ldt_spiral_knots_stress_test/best_proof.md` —
  rewritten (528 lines, 9 inline VERIFIED-SYMPY tags).
- `workspace/active/ldt_spiral_knots_stress_test/integrator_report.md`
  — new.
- `workspace/active/ldt_spiral_knots_stress_test/integration_check_report.md`
  — new (C4 updated in P1).
- `workspace/active/ldt_spiral_knots_stress_test/verify/` — 9
  protocol-compliant scripts, 643 cases total.
