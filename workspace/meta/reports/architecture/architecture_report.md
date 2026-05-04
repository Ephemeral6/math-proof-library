# Math Agent — Architecture Report & Discovery-Loop Design Notes

**Date**: 2026-04-30
**Scope**: Two subsystems running today in this repo —
  (1) the **Lean Formalization Pipeline** (formerly "math-proof-agent" + LeanAgent skill),
  (2) the **Mathematical Discovery Pipeline** (the OP-1 / Theorem-3 / OP-2 working mode).
**Audience**: design discussion only. **Part II** answers eight specific questions about
evolving the system into a *discovery loop*. No code in this document; no source files
are modified.

---

# Part I — Current Architecture

## A. Lean Proof Pipeline

The Lean pipeline is fully scripted as a Claude Code skill (`lean-formalization-agent`)
running 7 sequential stages with a per-lemma compile-fix subloop. The skill shells out
to `lean/LeanAgent/scripts/{compile.sh, check_axioms.sh, init_child.sh}`; there is no
external LLM driver — the same Claude Code session that reads `SKILL.md` also writes
the Lean files.

### A.1 Per-stage decomposition

| Stage | Input | Output | Implementation | What it actually does |
|---|---|---|---|---|
| **0. Architect** | Structured NL proof (markdown) | Modular blueprint = DAG of lemmas + file layout + reuse tags `[MATHLIB] / [REGISTRY] / [NEW]` | LLM only (no Lean) | Identify atomic lemmas; enforce minimum-hypothesis / max-abstraction; tag each external dependency three-way. |
| **1. Decomposer** | Architect blueprint + raw proof | Per-lemma atomic step list (1–3 tactics each) | LLM only | Each step records its premise, conclusion, method, and external theorem with a feasibility check. As of 2026-04-30, also detects "Lyapunov / extrapolated / auxiliary sequence" keywords and emits a `noncomputable def` block (G-NEW pattern, validated on Nesterov item #13). |
| **2. Aligner** | NL atom list | Lean signatures (no body) + `[MATHLIB-anchor]` for each name used | LLM + `lake env lean` for `exact?` probes | Decides typeclass abstraction (e.g. `InnerProductSpace ℝ E` over `ℝⁿ`), inserts `CompleteSpace E` where Mathlib's `gradient` requires it. |
| **3. Skeleton Builder** | Aligner signatures | Compilable Lean file with all `sorry`s | LLM emits .lean; `compile.sh` checks | Per file ≤ 300 LOC budget. Multi-file decomposition (G5) imports already-CERTIFIED siblings. |
| **4. Tactic Filler** | Skeleton + atom list | Filled tactics, possibly with leaf STUCK markers | **per-lemma loop**: LLM emit → `compile.sh` → diff goal state → retry. Up to 5 rounds. | Tier-1 (`exact?, apply?, aesop`) → Tier-2 (registry playbook) → Tier-3 (recursive synthesis: emit a child lemma, descend up to depth 3 via `init_child.sh`). |
| **5. Verifier** | All proofs `sorry`-free | PASS/FAIL on three checks | `compile.sh` + `check_axioms.sh` (axiom whitelist `{propext, Classical.choice, Quot.sound}`) + back-translation diff | Three hard gates: (a) compile clean, (b) axiom-clean, (c) NL ↔ Lean signatures back-translate isomorphically. |
| **6. Linter** | Verified Lean | Mathlib-PR-ready code | `lake build` + Mathlib lint hook | Naming, docstring, `simp`-shape lints. Currently the weakest stage — ~1.7× LOC inflation across the benchmark, mostly addressable by polish. |

### A.2 Tightness Pre-Audit (added 2026-04-29)

Despite the v2.0 doc, the pipeline as actually run by `math-proof-agent` adds a sixth
stage **between Explorer and Judge**: `workspace/agents_spec/tightness_preaudit.md`.
For each Explorer frame it runs five checks (T1 rate preservation, T2 metric
consistency last-iterate vs Cesàro, T3 constant tracking, T4 triangle / Cauchy-Schwarz
alert, T5 stochastic-vs-deterministic), emits a `tightness_report.md`, and a verdict
∈ {PROCEED, FIX_BEFORE_JUDGE, REJECT_FRAME}. This was forced by three concrete
failures (OP-2 v5 §4.2.1; Theorem 3 Step 2–3; v4 leading constant κ/10 vs κ/23).
The Auditor's Rule A-NEW makes every Pre-Audit WARNING explicitly check rate impact;
CRITICALs that leak past Judge fail with `[T{n}-CRITICAL-LEAKED-FROM-PREAUDIT]`.

### A.3 Verified capability, by benchmark item

13/13 CERTIFIED on the optlib benchmark (`lean/LeanAgent/benchmark/FINAL_SUMMARY.md`,
2026-04-28 → 2026-04-30). Capability evidence anchored to specific items:

| Capability | Evidence (item) | Notes |
|---|---|---|
| Single-file proofs ≤ 300 LOC | #04 (~58 LOC), #08 (111), #11 (167), #12 (258), #13 (304) | 304 is the tested ceiling. |
| Multi-route exploration (G2) | #01/#03 chose derivative-comparison after PARTIAL on integral route in earlier session | |
| Tier-3 recursive synthesis (G8) | #04 produced 3 helpers at depths 1, 1, 2; #06 unlocked as a side effect | |
| Multi-file decomposition (G5) | #11 imports #06+#07; #12 imports #03+#06+#08; #13 imports #03+#06+#08 | Cross-module name resolution + `lake build` propagation working end-to-end. |
| PNat → ℕ destructure | #12 final calc step | Codified as playbook entry `pnat-to-nat-destructure`. |
| Auxiliary-sequence synthesis (G-NEW) | #13 `zSeq` + `xkk1_eq_combine` + `y_eq_combine` | Decomposer trigger keywords: "Lyapunov" / "extrapolated" / "auxiliary". |
| Vector identity normalisation | #13 `y_eq_combine` succ case | `match_scalars <;> field_simp <;> ring`; `abel` was insufficient. |
| Algebraic dexterity at Layer 3 | #12 (165 LOC optlib → 258 LOC), #13 (290 → 304, 1.05× near-optimal) | Polarisation, prox-subgradient inequality, inner-product folding all at scale. |

### A.4 Known gaps in the Lean pipeline

1. **Tactic-shape preflight linter** is missing. All 23 cumulative compile-fix rounds
   across the 13 items were tactic-shape problems (no-goals, explicit-arg count,
   `simp` over-rewrite, `field_simp` vs `ring` ordering, **section-variable name
   shadowing**). A goal-state-aware pre-emit linter is estimated to remove ≥ 50 % of
   compile cycles.
2. **Stage-6 polish is weak**: Layer-3 LOC inflation is 1.5–2.8×, partly because the
   agent emits intermediate `set` / `have` bindings even when optlib uses anonymous
   `calc` chains.
3. **No PR-submission loop**: registry tracks `pr_ready: false` but nothing pushes
   to Mathlib.
4. **Stage 0 reuse-tagging is heuristic**: relies on LLM semantic search of Mathlib
   docs + registry NL summaries; failure mode is "tagged `[MATHLIB]` but no such
   lemma exists" → cleared at Stage 4 only after a wasted compile round.

---

## B. Discovery Pipeline (mathematical research mode)

This is the workflow the system actually runs when given an *open* problem rather
than a benchmark theorem. There is no scripted skill; the structure is reconstructed
from the OP-1 trace (`workspace/op1_detailed.md` and the 35 scripts in
`workspace/op1_scripts/`) and the Theorem-3 trace (44 numbered scripts in
`workspace/active/op2_v5_gaps/gap2_ub/resolution/theorem3_new/route_T/`).

### B.1 What actually happens, step by step

```
Open problem (NL)
   ↓
[1] Literature pass            arXiv / Google Scholar via WebSearch + WebFetch
   ↓
[2] Reduction / framing        carve out a single-shot existence claim or numerical conjecture
   ↓
[3] Numerical exploration      domain-specific computation (curver, gudhi, cvxpy, mpmath, …)
   ↓
[4] Conjecture refinement      ≥ 1 round of: try → counterexample → weaken → re-test
   ↓
[5] Proof attempt              formal argument; may invoke Lean pipeline for sub-lemmas
   ↓
[6] Failure analysis           taxonomise the obstruction, narrow the lemma form
   ↓
[7] Iterate                    return to [2] or [4] with the new constraint
```

### B.2 Where each step is currently human, where automated

| Step | OP-1 trajectory | Theorem-3 trajectory | Automation status |
|---|---|---|---|
| [1] Literature | Patrias 2009 (REU); Aougab–Gaster; rejected as not addressing homotopy type | arXiv:Bot-Schindler 2025; Goujaud 2025 cycling impossibility | **manual** WebSearch chains; agent picks queries, user vetoes |
| [2] Framing | "Standard convention E3, want full contractibility" | "Last-iterate O(1/T) for SHB on L-smooth convex" | **manual** — the agent does the framing, but no scripted abstraction step |
| [3] Numerical | curver MCG-orbit BFS, gudhi homology, networkx dismantlability | CLARABEL conic solves, SymPy symbolic descent, mpmath verification | **scripted** — each script is one-shot but agent writes it on demand |
| [4] Conjecture refinement | 6 iterations: universal vertex (FAILED) → contractibility → dismantlability → chordality → (W4)+(M) | Round 1–4: 2-step LMI (β\* = 0.957) → 1-step lookahead (0.978) → 2-step (0.993) → 3-step (numerical garbage) | **manual** — refinement decisions come from reading the previous round's failure mode |
| [5] Proof attempt | Bestvina-Brady filtration sketch; Hatcher surgery program | Positivstellensatz certificate from CLARABEL dual | **partial** — Lean pipeline available but not invoked here yet |
| [6] Failure analysis | "K_4-core counterexamples", "12 non-chordal exceptions", T1/T3/T5 dominator typology | "f(y_t) NOT eventually monotone at β ≥ 0.95 → Cesàro+monotonicity blocked" | **manual** + ad-hoc Python (`analyze_no_universal.py`, `chordality_thorough.py`) |
| [7] Iterate | 6 iterations recorded in `op1_detailed.md §11.6` | 4 rounds in `theorem3_final.md` | **manual** — no orchestrator |

### B.3 What scripts exist already

`workspace/op1_scripts/` (geometry / curve complex):

- enumeration: `enumerate_v2.py`, `enumerate_S12.py` (curver MCG-orbit BFS)
- topology: `analyze_complex.py` (gudhi flag-complex Betti)
- structural tests: `dismantle_check.py`, `chordality_check.py`, `chordality_thorough.py`
- conjecture probes: `verify_dehn_formula.py`, `verify_descending_link.py`,
  `verify_descending_link_higher.py`, `verify_sigma_universal.py`,
  `exhaustive_k2.py`, `analyze_no_universal.py`, `analyze_dismantle_pattern.py`,
  `check_first_step.py`, `surgery_domination_categorize.py`,
  `surgery_domination_E_reverse.py`, `extended_DL_dismantle.py`
- (W4) / (M): `systolic_check.py`, `bridged_check.py`, `quadrangle_check.py`,
  `characterize_W4_fillers.py`

`workspace/active/op2_v5_gaps/gap2_ub/resolution/theorem3_new/route_T/` (optimization /
LMI Lyapunov certificate hunt):

- numerical: `01_numerical_Vt_check.py`, `02_numerical_Vt_nonSC.py`
- symbolic: `03_symbolic_descent.py`, `04_symbolic_descent_v2.py`
- LMI conic SDPs: `05_one_step_lmi.py` … `21_lmi_boundary_precise.py`
  (one-step → 2-step → 3-step → time-varying → growing weights)
- post-hoc audits: `33–43` — `audit_certificate.py`, `mpmath_verify.py`,
  `strict_certificate_audit.py`, `clarabel_tight_verify.py`
- exact certificates: `40_exact_certificate.py`, `44_exact_high_beta.py`
- fits & extrapolation: `22_fit_blowup.py`, `36_audit_blowup_refit.py`

Pattern: the agent generates one **disposable, append-numbered** script per probe.
Failure of probe N motivates probe N+1. There is no abstraction over "what kind of
probe this is" — the script is its own record.

### B.4 What is missing as a *system*

- No structured `State` representation (the live state is reconstructed from
  `op1_detailed.md §11.6` table by reading prose).
- No structured failure schema (it's English commentary inside the proof markdown).
- No proposer module: each refinement step is a fresh LLM emission that re-derives
  why the previous form failed.
- No automatic literature retrieval between iterations: literature was loaded
  once at the start of OP-1 and re-queried only when prompted by the user.
- No automatic dispatching to the Lean pipeline once a sub-lemma is finite-data
  enough to formalise (e.g. (W4)'s 5-curve existence statement is a prime
  Lean candidate but was never handed off).

---

## C. Registry System

`lean/LeanAgent/registry/` has four channels. All four are append-mostly; nothing
expires; there is no compaction or dedup pass.

### C.1 `lemmas/` — one JSON per certified or partial lemma

Schema (from `descent_lemma_v2.json`):

```json
{
  "lemma_name": "...",
  "nl_statement": "...",
  "lean_signature": "theorem ... : ...",
  "lean_file": "lean/LeanAgent/Generated/foo.lean",
  "imports": ["Mathlib"],
  "depends_on": [],
  "assumptions": ["E real inner product space (complete)", ...],
  "verdict": "CERTIFIED" | "PARTIAL" | "STUCK",
  "n_stuck": 0,
  "pr_ready": false,
  "abstraction_level": "InnerProductSpace ℝ E + CompleteSpace E (generic)",
  "reuse_potential": "high" | "medium" | "low",
  "reuse_reason": "core inequality used by every first-order optimization convergence proof",
  "ts": "ISO-8601"
}
```

Stage 0 reads `nl_statement` + `assumptions` for `[REGISTRY]` semantic search; Stage 4
reads `lean_signature` + `imports` to write `import` lines in Generated files.

### C.2 `pairs/entries.jsonl` — NL ↔ Lean parallel corpus

One JSON line per certified theorem. Schema overlaps with `lemmas/` but the
purpose differs: `pairs/` is the back-translation reference for Stage 5's
isomorphism check. 18 entries as of 2026-04-30; added in this session: `gradient_method`,
`proximal_gradient_method_converge`, `phi_three_point_y`, `Nesterov_first_converge`.

### C.3 `playbook/entries.jsonl` — proof patterns

Two-shape format. Old shape (Tier-2 tactic recipes):

```json
{
  "lemma_name": "...",
  "atom_id": 6,
  "goal_pattern": "|⟪x - y, z⟫_ℝ| ≤ ‖x - y‖ * ‖z‖ (Cauchy-Schwarz on real inner product)",
  "tactic": "intro t; have h := @norm_inner_le_norm ℝ E _ _ _ _ _; simpa [Real.norm_eq_abs] using h",
  "tier": 2,
  "ts": "...",
  "note": "explicit @ + scalar field needed; abs_inner_le_norm does not exist in this Mathlib"
}
```

New shape (named pattern, 2026-04-30): `layer3-multi-file-decomposition`,
`pnat-to-nat-destructure`, `aux-sequence-synthesis`,
`match-scalars-for-vector-identities`. Fields: `name / trigger / action / evidence /
ts`. These are agent-readable hints invoked by the Decomposer at Stage 1 when
keywords match.

### C.4 `failures/entries.jsonl` — STUCK record

```json
{
  "lemma_name": "...",
  "atom_id": 2,
  "stuck_id": "STUCK_2",
  "lean_goal": "verbatim goal state",
  "atom_nl": "what the proof said this step does",
  "tier1_tried": ["exact?", "apply?", "aesop"],
  "tier2_tried": ["needs HasFDerivAt.comp + Riesz representation linking gradient_def : gradient f x = (innerSL ℝ).symm (fderiv ℝ f x)"],
  "last_error": "out of time budget",
  "ts": "..."
}
```

Used to build Stage 4's playbook and as the input to a future "fixer" pass — but
no automated fixer exists today; entries are read by humans.

### C.5 Counts (2026-04-30)

| Channel | Count |
|---|---|
| `lemmas/` | 8 (`sub_normsquare_gradient`, `convex_monotone_gradient_prime_helper`, `convex_first_order_condition_grad`, `descent_lemma_v2`, `strong_convex_gradient_lower_bound`, `shb_foundations_basic` / `defs` / `descent`) |
| `pairs/` | 18 |
| `playbook/` | 10 (6 tactic + 4 named patterns) |
| `failures/` | 5 |
| Generated `.lean` | 22 |

---

## D. External Tool Chain

### D.1 Lean / formal-verification stack

- Lean 4 toolchain `leanprover/lean4:v4.30.0-rc2` (`lean/LeanAgent/lean-toolchain`).
- Mathlib v4.30.0-rc2 (`lean/LeanAgent/lakefile.toml`).
- `lake build` for module compilation; per-file `lake env lean` for one-shot probes.
- `#print axioms` whitelist `{propext, Classical.choice, Quot.sound}` enforced by
  `check_axioms.sh`.
- Optlib pinned commit `03124b75df1422afed0a96e370f0e258589650ba` for benchmark
  ground truth.

### D.2 Python / numerical stack (run inside WSL Ubuntu 24.04)

- `curver 0.5.1` — surface triangulations, MCG action, geometric intersection
  numbers (OP-1 enumeration).
- `gudhi 3.12.0` — flag complex expansion, simplex tree, Betti numbers over
  ℤ/2 and ℤ/3 (OP-1 §6).
- `networkx 3.6.1` — dismantlability search, dominator tests (OP-1 §11.4.3).
- `cvxpy + clarabel` — conic SDPs for LMI Lyapunov certificates (Theorem 3,
  scripts 5–21).
- `sympy` — symbolic descent / coefficient identities (Theorem 3 scripts 03–04).
- `mpmath` — high-precision verification of conic certificates (script 38).
- `numpy / scipy` — linear algebra, eigenvalue, PSD checks (script 40).
- `flipper / spherogram / SnapPy / Regina / low_index / knot_floer_homology` —
  3-manifold side (OP-3, OP-4).
- `Sage / pyzotero` — auxiliary literature management (skill `zotero-cli`).

### D.3 Configuration

- WSL Ubuntu 24.04 with Python 3.12.3 (geometry tools) — confirmed in
  `workspace/wsl_compatibility_report.md`.
- Native Windows for `lake build` (LeanAgent runs on Windows; only the Python
  scripts cross into WSL).

---

## E. End-to-End Data Flow Traces

### E.1 Trace 1 — Lean benchmark item #13 (Nesterov O(1/T²))

Input: a single NL theorem statement plus optlib's `nesterov_first.lean` ground-
truth file containing the statement and stubs. Wall-clock: ~50 min, 5 compile-fix
rounds, 304 LOC final.

```
[input]
nesterov_first_O1T2.theorem_statement (NL):
  "O(1/T²) convergence of Nesterov accelerated proximal gradient on min f+h with
   f convex L-smooth and h convex: forall k, (f+h)(x_{k+1}) - (f+h)(xm)
   ≤ gamma_k² / (2 t_k) ‖x₀ - xm‖²."

       │
       ▼ Stage 0 Architect
       │   • Detects keywords {"Lyapunov", "extrapolated", "auxiliary sequence"}.
       │   • DAG = { phi_three_point_y, xkk1_eq_combine, y_eq_combine,
       │             zSeq def, induction step, Nesterov_first_converge }
       │   • depends_on: { #03 descent, #06 FOC, #08 prox_iff_subderiv } → [REGISTRY] hits
       │   • file plan: import 3 Generated modules; emit one new file
       │   • triggers G-NEW: top-level noncomputable def zSeq
       │
       ▼ Stage 1 Decomposer
       │   • atomic steps for phi_three_point_y (clone of #12's phi_three_point at y_k)
       │   • atomic steps for zSeq induction
       │   • playbook hits: aux-sequence-synthesis, match-scalars-for-vector-identities
       │
       ▼ Stage 2 Aligner
       │   • Lean signatures with {E} [NACG] [InnerProductSpace ℝ E] [CompleteSpace E]
       │   • PNat → ℕ bridge planned for the final calc step (playbook
       │     pnat-to-nat-destructure)
       │
       ▼ Stage 3 Skeleton Builder
       │   • emit nesterov_first_O1T2.lean with all sorrys and the noncomputable
       │     def zSeq stub
       │   • compile.sh OK (skeleton with sorries)
       │
       ▼ Stage 4 Tactic Filler  ← per-lemma loop, 5 compile-fix rounds total
       │   • zSeq def closed by definition + match_scalars on succ case
       │   • xkk1_eq_combine: rewrite + ring (clean)
       │   • y_eq_combine succ: match_scalars <;> field_simp <;> ring (playbook hit)
       │   • induction step: per-step Lyapunov, then telescope
       │   • final calc: rintro ⟨n, hn_pos⟩ → rcases Nat.exists_eq_succ_of_ne_zero …
       │
       ▼ Stage 5 Verifier
       │   • compile.sh: 0
       │   • check_axioms.sh: subset of {propext, Classical.choice, Quot.sound} ✓
       │   • back-translation matches NL statement
       │
       ▼ Stage 6 Linter   (no rewrites in this run; LOC 304 vs optlib 290 = 1.05×)
       │
       ▼ archive
       │   • registry/pairs/entries.jsonl gets `Nesterov_first_converge` row
       │   • registry/lemmas/ no new entry (the helpers were inlined in the file)
       │   • registry/playbook/entries.jsonl gets aux-sequence-synthesis,
       │     match-scalars-for-vector-identities
       │   • lean/LeanAgent/Generated/nesterov_first_O1T2.lean: CERTIFIED
       │
[output]
   axiom-clean .lean file + 4 new registry rows.
```

### E.2 Trace 2 — OP-1 Round 6 (Chepoi-Osajda discovery)

Input: prose problem statement "what is the homotopy type of $C_1(S_{g,n})$ for
$g \ge 1$?" with 5 prior rounds of failed conjectures recorded in
`op1_detailed.md §11.6`. Wall-clock: ~1.5 hours, much of it spent reading
extended literature and writing the (W4) / (M) verification scripts.

```
[input]
state at start of Round 6:
  goal       : prove C_1(S_{g,n}) contractible for g ≥ 1
  current    : Lemma 11.4(b)'' (DL is dismantlable) — 378/378 verified, geometric
               proof OPEN
  failures   : universal vertex form DISPROVED (6 K_4-core CEs);
               chordality FAILS for k ≥ 4 (12 non-chordal DLs);
               immediate dominator form DISPROVED (Strategy α);
               extended-DL dataset (11,438 curves) does NOT introduce new DL members
  data       : data_S_1_1.json (100 v), data_S_1_2.json (400 v),
               data_S_2_1.json (250 v); descending_link_higher.json;
               dismantle_results.json
  open hint  : the obstacle to a uniform geometric proof is the iterative
               case-by-case structure (T1 48.5%, T3 27.6%, T5 77.3%, no single
               type universal)

       │
       ▼ [1] Literature pass   (manual / WebSearch)
       │   • Hits Chepoi-Osajda 2014 (arXiv:0910.5444): weakly modular complexes
       │     are dismantlable iff they satisfy the W4-wheel + triangle conditions.
       │   • Pattern match: dismantlability ⇒ check W4 + (TC) on 318 DLs.
       │
       ▼ [2] Reframing
       │   • old form: "DL admits an iterative dismantling ordering" — abstract
       │   • new form: "every induced 4-cycle in DL has a common neighbour,
       │              and every (edge,vertex) at equal distance has a strictly
       │              closer common neighbour" — finite-data existence claims
       │
       ▼ [3] Numerical verification
       │   • new scripts: systolic_check.py, bridged_check.py,
       │                  quadrangle_check.py, characterize_W4_fillers.py
       │   • run on every DL across S_{1,2} k = 2..8, S_{2,1} k = 2..4
       │
       │   results:
       │     S_{1,2}: 271/271 satisfy (M); 271/271 satisfy (W4)
       │              (209 vacuously, 62 with induced 4-cycles all filled)
       │     S_{2,1}: 47/47 satisfy (M); 47/47 satisfy (W4)
       │     TOTAL  : 318/318 — zero exceptions
       │
       ▼ [4] Conjecture refinement
       │   • Lemma 11.4(b)'''' = (W4) + (M) on every DL at every level k ≥ 2
       │   • implies dismantlability via Chepoi-Osajda
       │   • implies clique complex strongly collapsible
       │   • implies contractibility
       │   • status: empirically 100%; geometric proof OPEN
       │
       ▼ [5] Proof attempt
       │   • not done in Round 6 — the (W4) statement reduces to a clean
       │     5-curve existence claim, ready for either a 1–2 page geometric
       │     argument or a Lean formalisation
       │
       ▼ [6] Failure analysis
       │   • Strategy γ remains: T1/T2/T3/T5 dominator typology has no single
       │     universal type → uniform geometric proof must handle case structure
       │
       ▼ [7] Iterate
       │   • Net gain: open lemma sharpened from "DL is dismantlable" (graph-
       │     theoretic, no obvious geometric content) to "every 4-cycle has a
       │     filler curve" (clean finite-data existence statement).
       │
[output]
  workspace/op1_detailed.md §11 updated.
  No registry write (none of the OP-1 results are Lean theorems yet).
```

The contrast with Trace 1 is the point: Trace 1 has structured input/output at every
stage, Trace 2 only has structure inside the per-step computation. Steps [2], [4],
[6], [7] in Trace 2 are unstructured agent prose with no machine-readable handoff.

---

# Part II — Suggestions for the 5-Module Discovery Loop

The proposed architecture:

```
State = (Goal, Current_Conjecture, Evidence, Failed_Attempts)

Loop:
  PROPOSER  : (Goal, Failed_Attempts, Diagnoses) → next conjecture
  VERIFIER  : conjecture × dataset → (pass_rate, counterexamples)
  PROVER    : verified conjecture → proof | failure-with-stuck-point
  DIAGNOSER : (failed proof, counterexamples) → structured failure
  BRIDGE    : (refined conjecture, diagnosis) → relevant literature
```

Below: suggestions only; no implementation.

### Q1. Proposer prompt design — encoding failures as anti-hints

The current human-readable trace ("universal vertex failed because of K_4+leaves
structure") needs three kinds of structure for an LLM to reuse it without
repeating the failure:

1. **Failure schema** — every disproved candidate form gets one record with fields
   `{conjecture, falsifiers (verbatim CE data), structural pattern, what was strictly
   weaker that survived}`. The OP-1 sequence yields five such records:
   - "DL has universal vertex" / [6 K_4-core CEs on S_{1,2}] / "K_4 ∪ 4 leaves with
     missing-one-core-edge" / "DL is contractible".
   - "DL is contractible" / [no CE, just no proof] / — / "DL is dismantlable".
   - "Every max-level β has immediate dominator" / [4 max-level vertices in K_4 core]
     / "K_4 core" / "DL admits an iterative dismantling ordering".
   - "DL is chordal" / [12 specific DLs at k ≥ 4 on S_{1,2} with degree sequence
     (6,5,5,5)] / "characteristic 4-cycle skeleton" / "DL is dismantlable".
   - "Single dominator type covers all (α, β) pairs" / [T1 48.5%, T3 27.6%, T5 77.3%
     with overlap 98.2%] / "no type universal" / "iterative case-by-case".
2. **Anti-hint injection at prompt time**: the Proposer sees, in addition to the
   goal, *the survivor* of each falsified pair plus *one sentence about why the
   weaker form survived*. Concretely the prompt skeleton:

   > Goal: prove C_1(S_{g,n}) contractible for g ≥ 1.
   > **What is already known to fail**:
   >   - "DL has a universal vertex" was disproved by K_4-core CEs (6/64). Strictly
   >     weaker forms of the same claim are off-limits.
   >   - "DL is chordal" was disproved at k ≥ 4 (12 CEs).
   > **The strictly-weaker survivor** is "DL is dismantlable" (378/378).
   > **Propose a refinement that is *not* strictly stronger than any of the
   > failed forms above.**

3. **Surgery on the proposal**: before emitting, the Proposer is required to label
   its candidate's relation to each prior form (`STRICTLY_STRONGER`, `STRICTLY_WEAKER`,
   `INCOMPARABLE`, `EQUIVALENT`). The orchestrator rejects `STRICTLY_STRONGER` candidates
   silently and asks for a re-roll. This makes the failure record *load-bearing* in
   the prompt rather than decorative.

The OP-1 jump that the Proposer would have had to reproduce is from "DL is
dismantlable" (graph-theoretic, no geometric content) to "DL satisfies (W4) + (M)"
(local finite-data conditions). The bridge there is **literature-driven** (Chepoi-
Osajda 2014's W4-wheel theorem). So the Proposer should be configured to call the
BRIDGE module *before* every emission and inject the top 3 retrieved theorems'
hypothesis-form as candidate vocabulary. Cf. Q5 below.

### Q2. Diagnoser computation — what the "domain-specific analysis" actually is

In OP-1 the diagnoser did three things, and in Theorem-3 it did three different
things. The unifying abstraction is **"slice the counterexample by candidate axes
of structure, report the axis on which it is uniform"**:

| OP-1 axis | Concrete check |
|---|---|
| graph-theoretic | dismantlability (networkx); chordality (perfect-elimination); independence number; max-clique |
| metric | diameter; distance-to-base-vertex; dominator level |
| typology | partition CE set by "type" (T1 / T3 / T5); compute coverage |

| Theorem-3 axis | Concrete check |
|---|---|
| solver | CLARABEL feasibility; LMI rank; condition number |
| asymptotic | fit C(β) = a (1−β)^b on bulk; check 1/(1−β) blow-up structure |
| anchor structure | k-step lookahead increments, geometric tail |

The cross-domain abstraction is: a Diagnoser is a **collection of axis-specific
probes** plus a **uniformity test**. The agent is good at writing one-shot probes
when prompted, so the right shape is:

1. A small **probe library** keyed by `(domain, conjecture-form)` (graph-theoretic
   conjecture → run dismantlability + chordality + cop-win + etc.; LMI conjecture
   → run feasibility + extract certificate + try one-step lookahead).
2. A **uniformity scorer** that runs each probe across all CEs and returns the
   probes whose result is constant (all dismantlable; all have K_4 core; all are
   non-chordal at k ≥ 4). This is the closest thing to "what makes the failure
   structural".
3. Each new domain seed-loads the library with 3–5 probes; failure to find a
   uniform axis is itself the signal to call BRIDGE on the conjecture's
   *negation* (literature on counterexamples).

The library does NOT need to be complete — every new probe written in a session
goes into it (with the probe's prompt as docstring), so the library grows
organically. The OP-1 set above came from 6 iterations totalling ~50 scripts;
seeding from those is one-shot work.

### Q3. State representation

A State should be a single JSON object readable by both the orchestrator and the
LLM. Sketch:

```jsonc
{
  "goal": "C_1(S_{g,n}) is contractible for g ≥ 1",
  "current_conjecture": {
    "id": "L11.4(b)''''",
    "form": "every DL satisfies (W4) and (M)",
    "logical_relation_to_goal": "implies via Chepoi-Osajda 2014",
    "verification_status": "318/318 verified; geometric proof OPEN"
  },
  "evidence": [
    { "kind": "exhaustive", "scope": "S_{1,2} k=2..8", "result": "271/271", "script": "quadrangle_check.py" },
    { "kind": "exhaustive", "scope": "S_{2,1} k=2..4", "result": "47/47",  "script": "quadrangle_check.py" }
  ],
  "failed_attempts": [
    {
      "id": "L11.4(b)",
      "form": "DL has universal vertex",
      "disproved_by": "6 K_4-core CEs on S_{1,2}",
      "structural_pattern": "K_4 ∪ 4 leaves",
      "successor_id": "L11.4(b)'"
    },
    /* ... four more ... */
  ],
  "diagnoses": [
    "T1/T3/T5 dominator types have no single universal cover (98.2% union, 77.3% best single)"
  ],
  "literature_in_scope": [
    "Chepoi-Osajda 2014 (W4-wheel)",
    "Boulet-Fieux-Jouve 2008 (dismantlable ⇔ strongly collapsible)",
    "Bestvina-Brady 1997 (filtration)"
  ],
  "iteration_count": 6,
  "last_update": "2026-04-30"
}
```

The orchestrator owns this file; every module reads + appends. The schema is
deliberately loose: free-text values stay free text, but the *containers* are
typed enough that the LLM can produce a `failed_attempts[i]` row in one shot.

### Q4. Termination conditions

A simple rule covers the cases observed:

- **Exit OK** if the current conjecture has a proof attempt that passes the Lean
  pipeline's Stage 5 (or, in non-Lean mode, a Pre-Audit verdict of PROCEED with
  zero CRITICALs).
- **Exit FOR REVIEW** if `iteration_count` exceeds a budget AND the diff between
  the current and previous conjecture is "epsilon" (no new structural element,
  no new evidence). Operationally: the Proposer emits the same `(form, hypotheses)`
  signature as a previous round.
- **Exit STUCK** if the Verifier's `pass_rate` falls below 1.0 *and* the Diagnoser
  reports no uniform axis *and* BRIDGE returns no new literature on three consecutive
  rounds. This is the hardest case — currently human-judged ("跑满 1 小时" is the
  fallback heuristic).

The right metric to add is **"information gain per round"** computed as the change
in the failed_attempts list: a round that *eliminates* a candidate form is
progress; a round that just re-emits a form already dominated is not. OP-1's
6 rounds each eliminated something (universal vertex; chordality; immediate
dominator; …); a 7th round that didn't add or remove anything would be the cue
to stop.

### Q5. Interface to the existing Lean pipeline

The Proposer's output is in general NL ("DL has property P with respect to
intersection number i"), and the Lean pipeline consumes structured NL theorems.
Three options for the bridge, in increasing automation cost:

1. **Manual handoff (status quo)**: when a sub-conjecture becomes
   finite-data-existence (e.g. (W4)'s 5-curve claim), a human writes the formal
   statement and submits it to the math-proof-agent. Cheap, no new code.
2. **Aligner-as-translator**: Stage 2 of the Lean pipeline already does NL → Lean
   signatures with typeclass abstraction. Make it accept the State's
   `current_conjecture.form` directly and produce a Lean signature; if Stage 3
   compiles the skeleton, the conjecture is "Lean-eligible" and gets pushed to
   the per-lemma loop. If not, the failure becomes a Diagnoser input ("conjecture
   is not formal-statable yet — quantifier alternation unclear / undefined
   notion / …").
3. **Full integration**: Stage 0 Architect already emits a DAG; the Proposer's
   output becomes a node in that DAG, marked `[OPEN_CONJECTURE]`. The Lean
   pipeline tries to discharge it; if it can't (Stage 4 STUCK), the failure
   record is fed back to the Proposer as a fresh failed_attempt.

(2) is the right level for now: the OP-1 (W4) claim is finite-data and would
translate cleanly. (3) is correct long-term but requires the Lean pipeline to
gracefully handle "this conjecture is true on a finite enumeration but no
geometric proof yet exists" — it currently doesn't, and adding that is its own
project.

### Q6. Cross-domain Verifier

The current Verifiers are domain-specific (curver / cvxpy / Lean). A general
Math Agent needs to either select among them or build new ones. Three observations:

- The **selection** problem is easy: each conjecture mentions an object (graph,
  surface, function, sequence) and a property; a small lookup `{object → tools}`
  picks the right Python stack. OP-1 mentions surfaces → curver; Theorem-3
  mentions iterates and L-smooth → cvxpy. A 2-page table covers ~all current
  domains.
- The **building** problem is harder. New objects (e.g. matroid, persistent
  homology with a non-standard filtration, …) need new Verifier code. The agent
  is good at writing one-off scripts; the pattern that worked in OP-1 is "let
  the LLM emit a bespoke `quadrangle_check.py` per round and append-number it".
  That pattern is *fine*; what is missing is registering each script as a
  Verifier with a typed I/O contract so the next round can reuse it without re-
  writing.
- The **verification correctness** problem is the deepest. cvxpy's CLARABEL
  reports `optimal_inaccurate` ~5% of the time on the Theorem-3 LMIs; gudhi's
  Betti numbers depend on the prime; curver's intersection numbers are exact but
  the MCG-orbit BFS is incomplete enumeration. The Verifier should report a
  *qualifier* — `EXACT`, `EXHAUSTIVE_ON_SAMPLE`, `NUMERICAL_INACCURATE`,
  `INCOMPLETE_ENUMERATION` — and the orchestrator's termination rule should
  treat `pass_rate = 1.0` differently for each.

So: yes, cross-domain is achievable; the architecture is "selector + script
library + verdict-with-qualifier". General Math Agent ≠ "single tool that does
everything" but rather "agent that knows which tool to invoke and what the tool's
verdict means".

### Q7. Cambridge arXiv:2603.04528 — comparison

The Cambridge multi-agent paper (assuming it's the conjecture-prove-refine loop
the user describes — note: the publication date 2026-03 is in the future from
the system view but consistent with knowledge cutoff, so this is a recent paper)
also has Proposer / Verifier / Prover modules and an iteration mechanism. The
distinguishing features of the present system are:

1. **A formal-verification backend** (Lean + Mathlib) that gives axiom-clean
   PASS/FAIL on proofs. The Cambridge work uses LLM-judged verification or
   theorem-prover sanity checks; this system enforces a `#print axioms` whitelist.
   This makes the PROVER's verdict load-bearing in a way LLM-judged systems
   cannot match — the Proposer's anti-hint of "this form was disproved" is
   backed by a Lean failure, not by an LLM saying "this seems wrong".
2. **A real open problem at the demo end**: OP-1 is a published-literature open
   question (homotopy type of $C_1(S_{g,n})$ for $g \ge 1$); the system has
   already produced a non-trivial new conjectural form (Lemma 11.4(b)'''') and
   a geometric reduction (Chepoi-Osajda framework). The Cambridge work
   demonstrates on toy domains and mathematical games. Demonstrating on a real
   open problem changes what the workshop paper claims (capability) versus what
   it merely sketches (architecture).
3. **A registry that accumulates between problems**: lemmas / pairs / playbook
   / failures persist and get reused (item #11 imports #06 + #07; item #12
   imports #03 + #06 + #08). The Cambridge work tends to treat each problem
   independently. Across-problem reuse is what makes the second OP-N cheaper
   than the first.

The Cambridge work likely has the advantage on Proposer creativity (more
candidate forms emitted per round) and on multi-agent coordination (their
agents argue with each other). The two systems would be complementary: their
Proposer + this PROVER and registry would be a strict upgrade on either alone.

### Q8. Minimum viable demo (workshop-paper grade)

The simplest demo that *demonstrates* the discovery loop, using only assets
already in the repo:

> **Demo: replay OP-1 Round 1 → Round 6 with the system in autonomous mode.**
>
> Round 1 input = "what is the homotopy type of C_1(S_{g,n}) for g ≥ 1?" plus
> the literature snapshot at the start of OP-1 (Patrias, Aougab-Gaster).
> Output to evaluate = trace through (Proposer → Verifier → Prover → Diagnoser
> → Bridge) and check that the system reaches Lemma 11.4(b)'''' (or a logically
> equivalent finite-data form) within 6 rounds.

Why this works as a workshop demo:

- The ground truth is the existing `op1_detailed.md` writeup, which records
  every iteration's conjecture and falsifier. Each round can be **scored** as
  "did the system arrive at the same successor conjecture (or a different but
  equivalent one) as the human trace did?".
- The Verifier scripts already exist (`dismantle_check.py`, `quadrangle_check.py`,
  etc.); the Proposer just needs to *select* which to run, not write new ones.
- The Bridge has a known-correct lookup: the literature actually used
  (Bestvina-Brady, Boulet-Fieux-Jouve, Chepoi-Osajda) is recorded in the
  references section. Hand the Bridge module those plus 20 distractor papers
  and check that it picks the right ones at the right round.
- The success criterion is non-vacuous: a baseline LLM without the failure-
  schema anti-hint will plausibly re-propose the universal-vertex form
  (it's the "obvious" first try); the discovery loop should not.

The next-cheapest demo is the **Theorem-3 lookahead trajectory** (round 1 = 2-step
LMI → round 4 = 3-step lookahead) — also fully recorded with concrete numerical
verifiers.

A workshop paper writes up one demo + the architecture + an honest assessment
of where it works (these two replays) and where it doesn't yet (no Proposer
creativity beyond literature-driven moves; no cross-domain transfer in either
demo).

---

# Appendix — File-system pointers (for the next session)

| Topic | Path |
|---|---|
| Lean pipeline skill | `lean/LeanAgent/SKILL.md` |
| Pipeline v2 spec | `lean/LeanAgent/lean_formalization_agent_architecture_v2.md` |
| Tightness Pre-Audit | `workspace/agents_spec/tightness_preaudit.md` |
| Benchmark scorecard | `lean/LeanAgent/benchmark/FINAL_SUMMARY.md` |
| Registry | `lean/LeanAgent/registry/{lemmas,pairs,playbook,failures}` |
| Generated Lean files | `lean/LeanAgent/LeanAgent/Generated/*.lean` |
| Helper scripts | `lean/LeanAgent/scripts/{compile.sh, check_axioms.sh, init_child.sh}` |
| OP-1 detailed log (6 rounds) | `workspace/op1_detailed.md` |
| OP-1 verification scripts | `workspace/op1_scripts/` |
| Geometry tooling status | `workspace/geometry_tools_status.md` |
| Theorem-3 final | `workspace/active/op2_v5_gaps/gap2_ub/resolution/theorem3_new/theorem3_final.md` |
| Theorem-3 scripts (44 numbered) | `workspace/active/op2_v5_gaps/gap2_ub/resolution/theorem3_new/route_T/` |
| Open-problem investigation report | `workspace/geometry_open_problems.md` |
| Cross-cut architecture history | `workspace/agent_architecture*.md` |
