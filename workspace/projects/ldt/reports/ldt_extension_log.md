# LDT Extension Progress Log

Timestamped entries for Stages 1–3. Append-only.

---

## 2026-04-20 — Stage 1 CHECKPOINT (framework built)

All 7 subitems (1.1–1.7) complete. No proofs attempted yet — that's Stage 2.

### Files created (11)

- `proofs/research/low-dimensional-topology/{knot-theory, mapping-class-groups, curve-complex, teichmuller-theory, 3-manifolds}/README.md` (5)
- `proofs/library/low-dimensional-topology/{knot-invariants, braid-group, dehn-twist-relations, simplicial-complexes, hyperbolic-geometry}/README.md` (5)
- `~/.claude/skills/math-verifier/tsv/tsv_knot.py`
- `~/.claude/skills/math-verifier/tsv/tsv_group.py`
- `~/.claude/skills/math-verifier/tsv/tsv_simplicial.py`
- `~/.claude/skills/math-verifier/tsv/README.md`
- `~/.claude/skills/math-problem-generator/ldt_seeds.md`
- `~/.claude/skills/math-auditor/ldt_checklist.md`
- `workspace/proof_techniques_ldt.md`
- `workspace/agent_architecture_v2.1_ldt_extension.md`
- `workspace/ldt_extension_log.md` (this file)

### Files modified (3)

- `~/.claude/skills/math-verifier/SKILL.md` — added TSV as Mode 4
- `~/.claude/skills/math-problem-generator/SKILL.md` — added direction 7 (LDT)
- `workspace/failure_patterns.md` — added v2.1 entry template with `domain` tag

### TSV self-test results

All three submodes pass their built-in self-tests:
- `tsv_knot.py`: Jones(trefoil) = -q^{-4} + q^{-3} + q^{-1}; Jones(figure-8) = q^{-2} - q^{-1} + 1 - q + q^2; Reidemeister check returns False (correct; Jones polys differ). Hyperbolic volume returns 2.0298832... for figure-8 and None for trefoil (non-hyperbolic).
- `tsv_group.py`: Artin relations verified in B_3 and B_4; Dehn-twist braid / commute checks correct; lantern and chain relations declared correctly.
- `tsv_simplicial.py`: 4-cycle flag check OK; distance-upper-bound verification OK; invalid-path rejection OK; local neighborhood construction returns labeled complex.

### Blockers / fallbacks applied

1. **SnapPy install failed** (network timeout during `pip install snappy`). Applied fallback specified in task brief section 1.2: hardcoded 10-knot hyperbolic volume table. Documented in `tsv/README.md` and `tsv_knot.py`.
2. **Sage install** — did not attempt, out of scope for Stage 1.
3. **GAP install** — did not attempt; TSV-Group uses pure-Python bounded rewriting, which is NOT a complete decision procedure. Documented as `confidence=medium` with "may require Garside normal form for proof" reason string.

### What is explicitly honest about this stage

- Technique dictionary has 10 entries vs. optimization's 36. Scout WILL see gaps.
- LDT library is empty; `[REF:]` produces zero matches.
- TSV-Simplicial is toy-level; global C(S) properties (hyperbolicity, etc.) are `out-of-TSV-scope`.
- Generic-braid Jones is not implemented; only named knots in the 7-knot table + Burau-B_2 fallback.
- All 8 audit checklist items are hypotheses; Round 0 will show which fire and which don't.

### Next

Proceeding to Stage 2 (Round 0: trefoil vs figure-eight). Do NOT help the system. Run naturally. Goal is gap discovery, not correct proof.

---

## 2026-04-20 — Fix 1 (P0: Kauffman-bracket convention bug)

Addresses the finding in `workspace/diag/c5_tsv_coverage_map.md` that
`kauffman_bracket("trefoil")` silently returned the wrong polynomial with
`confidence=high`. The Probe 4 PASS depended on a cross-check against this
function, so restoring correctness here is load-bearing for the broader V2.1
LDT pipeline's cross-verification story.

### Root cause

`kauffman_bracket` substituted `q = A^{-4}` into the stored Jones polynomial,
but the table stores Jones in the **q-convention** (Convention B, q = t^{-1})
while the Kauffman identity `<D> = (-A)^{3w} V_L(t)|_{t = A^{-4}}` is stated
in the **t-convention**. Pulling t = A^{-4} through q = t^{-1} gives
**q = A^{+4}**, not A^{-4}. See FP-KAUFFMAN-CONVENTION-2026-04-20.

### Files modified

- `~/.claude/skills/math-verifier/tsv/tsv_knot.py`
  - Module-level Jones-convention comment block extended with explicit q = A^4
    derivation + pointer to FP entry.
  - `kauffman_bracket`: one-character fix (`_A**(-4)` → `_A**4`); docstring
    extended with full Convention Contract block and worked right-trefoil
    derivation.
  - `jones_polynomial`, `alexander_polynomial`, `check_reidemeister_equivalent`,
    `hyperbolic_volume`, `lookup_knotinfo`: each gained a Convention Contract
    docstring block with worked examples.
  - `_resolve_name`: fixed latent bug where `"unknot".replace("knot","")` →
    `"un"` caused `jones_polynomial("unknot")` to return out-of-scope.
    Now tries raw name first; strips `" knot"` / `"knot"` suffix as a
    fallback (and never strips from `"unknot"` specifically).
  - `__main__`: rewritten as an assert-based self-test (was print-only).
    60 named assertions covering: Jones table match, mirror relation,
    Kauffman-Jones identity for every table entry, textbook bracket values
    for 3_1 / 3_1m / 4_1, Alexander normalization (Δ(1)∈{±1}, |Δ(-1)|=det)
    for every table entry, reidemeister chirality detection, hyperbolic
    volume authoritative-null vs out-of-scope distinction, lookup_knotinfo
    variable rejection, out-of-scope Jones tag.

### Files created

- `~/.claude/skills/math-verifier/tsv/tsv_convention_audit.md`
  Per-function convention + worked right-trefoil example; explicit
  self-test contract; historical note on the bug.

### Files modified (other)

- `workspace/failure_patterns.md` — added FP-KAUFFMAN-CONVENTION-2026-04-20
  (domain / subdomain / technique / step-stuck / reason / lesson / date).

### Verification

`python ~/.claude/skills/math-verifier/tsv/tsv_knot.py` exits 0. All 60
assertions pass. In particular:

- `<3_1> = -A^5 - A^{-3} + A^{-7}` ✓ (Kauffman 1987)
- `<4_1> = A^8 - A^4 + 1 - A^{-4} + A^{-8}` ✓ (Lickorish Ch 3)
- `<D> * (-A)^{-3w} == V(q=A^4)` for every table entry, symbolically ✓

### Retroactive impact on prior artifacts

Probe 4's PASS was earned under simulation (diagnostic authoring). A real
V2.1 pipeline running against the pre-fix TSV would have triggered an
Explorer/TSV disagreement at Step 8 and entered the Auditor–Fixer loop on a
different axis than the one recorded. With the post-fix TSV, the scenario
described in Probe 4 (Explorer returns textbook bracket, TSV agrees, Audit
PASS) is now an honest pipeline outcome, not a simulated one. The Probe 5
finding is preserved for the record.

### Not addressed in Fix 1 (intentional — scoped out by task brief)

- Generic-diagram / generic-braid Kauffman bracket remains out-of-scope.
  The fallback path still returns `(None, confidence=low)` for unknown inputs.
- The `tsv_simplicial.py` and `tsv_group.py` convention audits are NOT in
  scope for this fix.

---

## 2026-04-20 — Fix 2 (P1: L1/L2/L3 citation classification)

Addresses diagnostic finding 6 ("Completeness axis treats citations and
derivations identically, so citation-heavy proofs score well on Completeness
without signaling their dependence on deep external machinery") and
Probe 1's finding that Round 0.5's hyperbolic proof rests on 4 E3 citations
with thin independent reasoning.

### Scope

Tag every `[REF:external]` citation with a depth class L1/L2/L3. When
the proof rests on ≥3 L3 citations with <3 Independent steps, emit a
STRUCTURAL-CITATION-WARNING alongside (NOT in place of) the verdict.

### Files modified

- `~/.claude/skills/math-auditor/ldt_checklist.md`
  - New item **F2 — Citation-depth classification (L1/L2/L3)**.
  - Definitions: L1 = 30s-verifiable lemma lookup, L2 = single theorem
    from single paper, L3 = deep research-program machinery.
  - Canonical L3 reference list for LDT:
    Thurston hyperbolization, Mostow rigidity, Gordon–Luecke,
    Agol's virtual Haken, Wise's quasi-convex hierarchy,
    Masur–Minsky curve-complex machinery, Mirzakhani,
    Kirby calculus, Heegaard Floer / Ozsváth–Szabó,
    Khovanov / Rasmussen, Thurston's 8 geometries,
    Eskin–Mirzakhani–Mohammadi.
  - Auditor procedure: tag each citation, record L3s in a new audit
    subsection, count Independent steps, emit warning on trigger.
  - STRUCTURAL-CITATION-WARNING text spelled out verbatim.
  - Output-format table extended with an F2 row and a new
    `### L3 citations used` subsection.

- `~/.claude/skills/math-proof-agent/prompts/auditor.md`
  Added a short pointer at end-of-file: when problem.md is tagged with the
  LDT domain, apply the LDT checklist in addition to V2 audit; F2 is
  mandatory in that case.

### Files created

- `workspace/diag/c2_audit_with_l3_classification.md`
  Re-audit of Probe 2's synthetic citation-heavy proof under the post-fix
  rubric. Result: PASS + STRUCTURAL-CITATION-WARNING, matching the task
  brief's expected behavior.
  - L3 citations counted: 7 (Waldhausen, Perelman, Agol, Wise, Gordon–Luecke,
    Thurston, Mostow). L2: 1 (Seifert). Independent: 0.
  - 3 of the 7 L3s flagged as decorative or redundant (Waldhausen, Agol,
    Wise not load-bearing for the final conclusion).
  - Verdict unchanged: PASS. Warning attached.

### Verification

The Probe 2 proof, re-audited against the post-fix checklist, produces
exactly the expected verdict (PASS + STRUCTURAL-CITATION-WARNING). The
warning correctly identifies the originality-vs-citation gap that the
baseline Completeness axis was insensitive to. No regression against the
previously PASS'd Probe 4 proof: that proof has 0 L3 citations (the Markov
trace identification is L1/L2 grade at most, citing Kauffman 1987 §3), so
the trigger does NOT fire and the verdict is unchanged.

### Known limitations (carried forward into post-fix summary)

1. Mechanism is retrospective — it fires after the proof exists, not
   during Explorer phase.
2. L3 classification is judgment-sensitive at the L2/L3 boundary.
3. "Independent step" counting is coarse.
4. Warning applies only under the LDT checklist currently; non-LDT
   domains do not yet have a canonical L3 list.

---

## 2026-04-20 — Fix 3 (P1: Axis 5 Evidence Field)

Addresses diagnostic finding 3 (Axis 5 rewards geometric vocabulary over
geometric operations) and Probe 3's concrete demonstration that a
vocabulary-bluff proof scored 12–13.5/15 on Axis 5 despite performing no
geometric work.

### Scope

Rewrite Axis 5 in `judge_ldt.md` so that scoring above 6/10 requires an
**Evidence Field** identifying a load-bearing geometric step, the
specific operation performed, and a removal test. Cap at 6/10 regardless
of vocabulary if Evidence Field cannot be filled.

### Files modified

- `~/.claude/skills/math-proof-agent/prompts/judge_ldt.md`
  - Axis 5 rubric rewritten: levels 0/2/4/6/8/10 redefined around
    "geometric WORK not geometric vocabulary".
  - Evidence Field requirement added for scores >6/10:
    (1) load-bearing geometric step (a specific numbered step),
    (2) operation performed (specific, not "invokes X"),
    (3) removal test (if replacing the step with a citation leaves the
        proof intact, cap at 6/10).
  - `[VOCAB-CAP applied]` annotation mandated when Judge lowers a
    naive score of >6 to 6.
  - `[WARN: VOCABULARY-BLUFF]` emitted in Notes when vocabulary suggests
    ≥8 but Evidence Field fails.
  - Output-format template updated to include the Evidence block.

### Files created

- `workspace/diag/c3_axis5_with_evidence_field.md`
  Re-score of Probe 3 bluff proof. Result: **Axis 5 = 6/10 (capped)
  → 9/15**, down from pre-fix 8–9/10 → 12–13.5/15.
  Evidence Field cannot be filled — no load-bearing geometric step
  exists; all "geometric" content is prologue/epilogue vocabulary.
  `[WARN: VOCABULARY-BLUFF]` emitted.

- `workspace/diag/round0_5_axis5_with_evidence_field.md`
  Re-score of Round 0.5 hyperbolic `best_proof.md`. Result:
  **Axis 5 = 6/10 (capped) → 9/15**, down from pre-fix 9/10 → 13.5/15.
  Evidence Field check: only candidate load-bearing operation is the
  orbifold Euler-char arithmetic $\chi_{\text{orb}}(D^2(2,3)) = -1/6$
  in Step 1; under the "If removed: YES" test, that arithmetic can be
  replaced by a citation to Thurston's Seifert classification without
  breaking the proof. Step 2's ideal-tetrahedra claim is delivered by
  citation to Thurston's Princeton notes §4, not by exhibiting the
  face-pairing; therefore no Evidence at level >6. No bluff warning
  (the proof is substantive; just not geometrically constructive).

### Impact on the P0-vs-P0.5 gap under judge_ldt.md

| | judge_ldt.md PRE-fix | judge_ldt.md POST-fix |
|---|---|---|
| P0 (Jones) Axis 5 | 4/10 → 6/15 | 4/10 → 6/15 (unchanged) |
| P0.5 (hyperbolic) Axis 5 | 9/10 → 13.5/15 | 6/10 → 9/15 (capped) |
| P0 total | 36/55 (65.5%) | 36/55 (65.5%) |
| P0.5 total | 50.5/55 (91.8%) | 46/55 (83.6%) |
| Gap | +14.5 pts (26.3pp) | +10 pts (18.2pp) |

Gap closes from 14.5 to 10 points. P0.5 still wins — appropriately, as
its non-Axis-5 scores are legitimately higher — but the Axis 5 inflation
for citation-heavy geometric proofs is removed.

### Verification

Probe 3's bluff proof scores at the 6/10 cap with a VOCABULARY-BLUFF
warning (expected). Round 0.5 scores at the 6/10 cap without a bluff
warning (expected — not a bluff). Round 0 (Jones) unchanged at 4/10
(expected — Evidence-Field mechanism does not penalize
legitimately-algebraic proofs).

### Known limitations (carried forward into post-fix summary)

1. The 6/10 cap is binary — a proof with one decorative vocabulary
   sentence and a proof with 10 pages of decoration both land at 6/10.
2. Judgment boundary between "orbifold arithmetic is a geometric
   operation" and "orbifold arithmetic is notation-shuffling" is
   Judge-dependent; Round 0.5 hits 6/10 under the natural read, but a
   stricter Judge could cap at 4/10.
3. No transparency bonus for Explorers that label their citations
   honestly (e.g., `[REF:external,load-bearing]` vs. paraphrasing the
   citation as prose).
4. Axis 5 is still at the 1.5× multiplier, which amplifies its swing;
   Fix 3 narrows the swing at the top (via the cap) but does not touch
   the multiplier.

---

## 2026-04-20 — Stage 4: Spiral-Knots Stress Test (PASS, Category A)

Stress-test target: Theorems 3.5 and 4.2 of Blackwell–Das–Mayer–Moyar–Quraishi–Stees,
"Classical invariants of spiral knots" (arXiv 2506.17889, June 2025). Pipeline
ran with no paper access. TSV base-case verification allowed; no TSV expansion.

### Pipeline result

- **Theorem 3.5** (Alexander factorization $\Delta_{S(p,q,\epsilon)}(t) \doteq \prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t)$): **closed** unconditionally.
- **Theorem 4.2** (genus $(p-1)(q-1)/2$): **closed** unconditionally.
- Converged in 2 Fixer rounds (of 3 allowed). No forced convergence.
- Verdict category: **A (Independent reconstruction)**. See `workspace/diag/spiral_knots_stress_test_report.md`.

### Citation profile

- 0 L3 citations (STRUCTURAL-CITATION-WARNING did not fire).
- 4 L2: Birman–Weinberg Burau conventions, Burau→Alexander formula, $2g \ge \deg\Delta$ (Rolfsen), reduced-Burau generators.
- 10 L1: Seifert algorithm, χ→g, polynomial factorizations, row preservation, block inspection, Laplace, etc.
- ≥ 12 Independent steps: Block Structure Lemma, Lemma Q (Q_k = F_{k-1}/μ(k)), SP-2 cyclotomic scalar recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$, SP-4 top/bot monomial sub-lemma, full assembly.

### Observations (pipeline diagnostics)

1. **Scout correctly flagged Burau as the only relevant seeded technique** (1/5), but its tactical hint (tridiagonal characteristic polynomial) was **falsified** by Explorer 1 at p=4. Explorer 1 pivoted to a stronger identity, verified exhaustively on 14 cases.
2. **Route A (algebraic)** won over **Route B (geometric / Seifert matrix)**. Route B got the small cases right (TSV 2/2 in-scope) but block-circulant structure failed to emerge in the tree basis. Judge margin was 3/55 (within close-call threshold, so both audited).
3. **Route C (skein induction on q)** correctly diagnosed its own failure (skein at seam crossings leaves the spiral family). Honest negative result.
4. **Fixer Round 1 corrected a framing error**: Explorer's D_k (leading principal minors of B_p) did NOT satisfy the recursion; Fixer re-framed to intrinsic F_k in B_{k+1} and proved the Block Structure Lemma + Lemma Q.
5. **Fixer Round 2 was comparatively small**: SP-2 collapsed via the ε-independent scalar recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$ once SP-3 was in hand. SP-4 was a 2-page top/bot monomial induction.
6. **Evidence Field (Axis 5, Fix-3) calibration confirmed**: Route A capped at 6/10 (Seifert step citation-removable); Route B scored 8/10 for genuine geometric computation even though the general formula didn't close. Multiplier produced a 3-point spread — the intended calibration. STRUCTURAL-CITATION-WARNING did not fire.

### Failure patterns added to `workspace/failure_patterns.md`

- FP-SPIRAL-BLOCK-CIRCULANT-BASIS — tree basis destroys cyclic symmetry.
- FP-SPIRAL-SKEIN-LEAVES-FAMILY — skein at seam leaves periodic-braid family.
- FP-SPIRAL-PRINCIPAL-MINOR-MISFRAMING — induction on Burau matrix size must use "word in B_{k+1}", not "principal k×k minor of B_p".

### Assessment of real LDT capability

Positive: pipeline produced a genuine independent reconstruction of a 2025
research-paper theorem, with the core identity (SP-3 = Block Structure Lemma
+ Lemma Q) discovered by the Fixer without outside help. The pipeline's own
error-catching behaved as designed: Scout's tridiagonality → Explorer's
falsification → Explorer's replacement identity → Fixer's corrected framing.

Caveat: spiral knots are an unusually algebra-friendly family (positive braid +
periodic word + $B_p$ action). Success here does not generalize to genuinely
geometric targets (hyperbolic invariants, Heegaard Floer, Khovanov) where L3
citations would likely be forced. Route B's near-miss on the block-circulant
argument suggests the paper's actual proof uses a more geometric
"cake-surface" approach that this pipeline cannot currently reproduce.

Artifacts:
- `workspace/active/ldt_spiral_knots_stress_test/` — all 10 files
- `workspace/diag/spiral_knots_stress_test_report.md` — 5-section final report
- `workspace/failure_patterns.md` — 3 new FP entries

Evidence extraction for external reviewer completed. File: workspace/diag/spiral_knots_evidence_extraction.md. No verdict changes.

---

## 2026-04-21 — Stage P0 (Integrator role) CHECKPOINT

Three-tier upgrade triggered by the B+ verdict on spiral knots. P0 addresses
the architectural finding "no Integrator role; archived best_proof.md is not
self-contained".

### Files created (4)

- `~/.claude/skills/math-proof-agent/prompts/integrator.md` — Integrator
  role specification (5-step protocol; 8 reliability rules; non-scope list).
- `~/.claude/skills/math-auditor/integration_check.md` — 7-item integrity
  sweep (C1–C7): source traceability, cross-refs, citation definitions,
  VERIFIED-SYMPY tag validity, definition discipline, conclusion vs. target,
  stuck-point bookkeeping.
- `~/.claude/skills/math-proof-agent/orchestrator_update.md` — pipeline
  orchestration note with model assignments (Integrator = Opus,
  integration_check = Sonnet) and failure-mode signals.
- `workspace/agent_architecture_v2.2_integrator.md` — architecture doc
  for v2.2; explicit list of additions and non-additions; does NOT modify
  the frozen `agent_architecture_v2.md` or v2.1 extension.

### Files modified (0)

Per the task brief, Integrator is additive. No existing prompt, checklist,
or architecture file was modified.

### Spiral knots test-case application

- Preserved pre-rewrite `best_proof.md` as `best_proof_pre_integrator.md`
  (214 lines, 22,340 bytes).
- Rewrote `best_proof.md` to self-containment (528 lines, 38,741 bytes;
  +147% lines, +73% bytes).
  - Step 3 NEW: reframes induction from (wrong) $D_k$ principal minors to
    (correct) intrinsic $F_k = \det(I_k - y A'_k)$ with $A'_k \in B_{k+1}$.
  - Step 4 NEW: Block Structure Lemma with 3-part proof inlined.
  - Step 5 REWRITTEN: uses correct $F_k$; Lemma Q and three-term recursion
    fully inlined.
  - Step 6 REWRITTEN: universal scalar recursion $h_k = (1+t)h_{k-1} - t
    h_{k-2}$ with full proof; stale "By Step 3" citation removed.
  - Step 9 NEW: top/bot monomial sub-lemma fully inlined.
  - Step 10 EXPANDED: breadth argument with roots-of-unity product.
- Wrote `integrator_report.md` with §0 Target ToC, §1 10 obsolete fragments
  removed, §2 17 new fragments integrated, §3 citation ledger delta (L1: 6→10,
  I: 6→12), §4 8 cross-ref fixups, §5 15-script roster, §6 residual gaps
  (none).
- Ran `integration_check.md` on the rewrite: **INTEGRATION-PASS on first
  try**. All 7 items OK. Report: `integration_check_report.md`.
- Delta report at `workspace/diag/spiral_knots_post_integrator_delta.md`:
  documents the change and confirms the B+ reviewer's two main complaints
  (Step 5 wrong induction; Step 6 stale citation) are both resolved, plus
  the self-containment finding is resolved.

### Verdict-level effect

P0's test-case application shows that applying Integrator to the spiral
knots artifact resolves finding (1) of the B+ external review. The
rewritten `best_proof.md` is readable end-to-end without opening any
Fixer file.

### P0 status

**COMPLETE.** Ready to proceed to P1 (Verified Sympy Block protocol).

---

## 2026-04-21 — P1: Verified Sympy Block protocol (authored + retroactively applied)

### Scope

Formalize a protocol that distinguishes **symbolic claims** (which must be
proved in the body) from **empirical sympy certifications** (which
certify a finite parameter range). Provide machine-verifiable markup so
the Auditor can check that every empirical claim in a proof is backed
by a runnable sympy script that actually exits 0 and announces its case
count.

### Files authored (global — the protocol)

- `~/.claude/skills/math-verifier/VERIFIED_SYMPY_PROTOCOL.md` — 8-section
  protocol document. Inline tag format, 8 script requirements (R1–R8),
  scope limits ("what sympy MAY / MAY NOT verify"), 4 template IDs +
  `bespoke`, lifecycle, retroactive-application policy, governance.
- `~/.claude/skills/math-verifier/sympy-templates/template_identity_family.py`
  — Template 1 (identity-over-parameter-family). Illustrative math:
  $(x+1)^n = \sum_k \binom{n}{k} x^k$ for $n \in [1, 5]$ and
  $x \in \{-2, -1, 0, 1, 2, 3\}$. `ALL PASSED: 30 cases`, exit 0.
- `~/.claude/skills/math-verifier/sympy-templates/template_recursion_target.py`
  — Template 2 (recursion-matches-target). Illustrative math: Fibonacci
  recursion vs Binet formula for $n \in [0, 14]$.
  `ALL PASSED: 15 cases`, exit 0.
- `~/.claude/skills/math-verifier/sympy-templates/template_polynomial_breadth.py`
  — Template 3 (polynomial-breadth). Illustrative math:
  $\Phi_{n+1}(x) = 1 + x + \dots + x^n$ has breadth $n$ for
  $n \in [1, 16]$. Handles Laurent polynomials by shifting with
  $x^{200}$. `ALL PASSED: 16 cases`, exit 0.
- `~/.claude/skills/math-verifier/sympy-templates/template_base_cases_tsv.py`
  — Template 4 (base-cases-via-TSV). Illustrative math: Alexander
  polynomials of $3_1$, $4_1$, $5_1$ cross-checked against TSV.
  Graceful skip when a knot is out-of-TSV-scope. `ALL PASSED: 3 cases`,
  exit 0.
- `~/.claude/skills/math-auditor/ldt_checklist.md` — added §F3
  "Verified-Sympy Block protocol compliance" with 7 Auditor procedures
  (missing inline tag → HARD FAIL; missing protocol docstring block →
  FLAG; case-count mismatch → FLAG; non-deterministic → FLAG;
  runtime > 60s → FLAG; empirical claim without tag → FLAG; scope
  overreach (symbolic claim delegated to sympy) → HARD FAIL). Added
  F3 row to the output format table.
- `~/.claude/skills/math-proof-agent/prompts/fixer.md` — rewritten
  "Sympy-verification protocol (v2.2-P1)" section. Rules of thumb:
  scripts go under `{work_dir}/verify/`, start from a template, carry
  the protocol docstring and inline tags, case counts must match, and
  sympy never substitutes for a symbolic proof of a universal claim.
  Output template extended with "Sympy scripts added/updated" section.

### Retroactive application to spiral knots

- Relocated 9 protocol-eligible scripts from `fixer_work/` to
  `workspace/active/ldt_spiral_knots_stress_test/verify/`:
  `verify_p5.py`, `verify_Ek.py`, `check_recursion.py`, `find_Qk.py`,
  `sp2_verify_phi_p.py`, `sp2_Ck_at_y1.py`, `sp4_breadth.py`,
  `sp4_monomial.py`, `sp4_topbot.py`.
- Edited each script for protocol compliance: added the top-of-file
  `[VERIFIED-SYMPY-PROTOCOL: <template-id>, cases=<N>, description=<...>]`
  line, added explicit PASS/FAIL counting where the original script
  only printed informational output (e.g. `find_Qk.py`,
  `sp2_verify_phi_p.py`, `sp4_breadth.py`), and added a final-line
  `print("ALL PASSED: N cases")` + `sys.exit(0)` on success /
  `sys.exit(1)` on fail. All 9 scripts now exit 0 with the claimed case
  count. Individual runtimes all well under 60s (each ≤ 20s on this
  workstation).
- Case counts (total 643 across 9 scripts):
  `verify_p5.py` = 30, `verify_Ek.py` = 62, `check_recursion.py` = 24,
  `find_Qk.py` = 11, `sp2_verify_phi_p.py` = 62,
  `sp2_Ck_at_y1.py` = 258, `sp4_breadth.py` = 6, `sp4_monomial.py` = 62,
  `sp4_topbot.py` = 128.
- Added 9 inline `[VERIFIED-SYMPY: script=..., cases=..., result=PASS,
  description=...]` tags to `best_proof.md`:
  Step 5 *Lemma Q* → `find_Qk.py` (11 cases); Step 5 recursion (R) →
  `check_recursion.py` (24); §10.4 → `verify_Ek.py` (62) +
  `verify_p5.py` (30); §10.5 → `sp2_Ck_at_y1.py` (258) +
  `sp2_verify_phi_p.py` (62); §10.6 → `sp4_monomial.py` (62) +
  `sp4_topbot.py` (128); §10.7 → `sp4_breadth.py` (6).
- Rewrote §13 Numerical-verification script roster as a table with
  script/template/cases/description/inline-cite columns, pointing to
  the new `verify/` directory (not `fixer_work/`).

### Re-run of integration_check C4

Programmatic C4 scan: parse `best_proof.md` for `[VERIFIED-SYMPY:...]`
tags, run each referenced script, diff claimed `cases=N` against the
`ALL PASSED: N cases` line in each script's stdout. Result:
**9 tags, 9 PASS, 0 MISMATCH, 0 MISSING** (exit code 0 for all 9
scripts). C4 flipped from "OK (trivial; P1 not yet in force)" to
"OK (P1 re-run)" in `integration_check_report.md`.

### Effect on verdict

P1 addresses the B+ external review's lingering concern that the proof
depends on sympy without the checker being able to tell what is
certified for what parameter range. With the inline tags, the proof
now displays — at the step level — which symbolic claims rest on which
finite empirical certificates, and the Auditor can mechanically
re-verify the certificates by running the referenced scripts.

### P1 status

**COMPLETE.** Ready to proceed to P2 (TSV-Simplicial upgrade roadmap,
document only).

---

## 2026-04-21 — P2: TSV-Simplicial upgrade roadmap (document-only)

### Scope

Survey the capabilities the math-verifier would need in order to
*mechanically* check LDT proof steps in the five research subdomains
represented under `proofs/research/low-dimensional-topology/`
(3-manifolds, curve-complex, knot-theory, mapping-class-groups,
teichmuller-theory). Identify the dependency DAG, feasibility per
capability, and the Minimum Viable Increment.

No code written. The deliverable is a roadmap document.

### File authored

- `workspace/diag/TSV_SIMPLICIAL_UPGRADE_ROADMAP.md` — 4 sections:
  1. **§1 Capability demands** (per subdomain, 39 numbered
     capabilities: K1–K8, M1–M8, C1–C8, T1–T6, 3M1–3M8).
  2. **§2 Capability DAG** (5 tiers: Tier 0 regression, Tier 1 table
     expansion, Tier 2 intersection/simplicial, Tier 3 external
     solvers, Tier 4 citation-only).
  3. **§3 Feasibility assessment** (cost / risk / hit-rate per
     capability; aggregate verdict: Tier 0 + Tier 1 = ~15 d with low
     risk and ~55% hit-rate on current LDT stuck-points).
  4. **§4 MVI proposal**: Tier 0 + the low-risk core of Tier 1 + Tier
     4 registration. 5 deliverables (K4 regression fix, K1 table
     expansion to 30 knots, K2 braid-Alexander for B_n, n≤6, C1
     Farey-graph oracles, citation-DB seed). Total cost ~6 engineer-
     days, aggregate risk medium (driven by K2 conventions).

### Non-goals explicitly documented

- No Tier 2+ (intersection arithmetic, Dehn-twist updates,
  subsurface projection, pants graph) in the MVI.
- No Tier 3 externals (SnapPy, Bestvina-Handel) in the MVI.
- No generic-braid Jones / HOMFLY in the MVI (held back because the
  K4 Kauffman-bracket regression shows the convention-risk for these
  polynomials is real; K4 regression-net must ship first).
- No infinite / global C(S), Mod(S), T(S) verification at any tier;
  those stay as citation-only under Tier 4.

### Key design decision

The roadmap prefers **table expansion + cross-check** over
**symbolic-first** for LDT. Rationale documented in Appendix C:
the current K4 regression came from a symbolic-first implementation
that derived the Kauffman bracket from the Jones polynomial and
shipped the wrong convention with `high` confidence. For a domain
with as many sign / variable-inversion pitfalls as low-dim topology,
the safer pattern is to ship a hand-curated table, then validate
symbolic derivations against it.

### P2 status

**COMPLETE.** Roadmap written; no code changes.

---

## 2026-04-21 — V2.2 cold-start regression test on $\mathcal{C}(S_{1,1})$

Full pipeline (Scout → 3 Explorers → Judge → Auditor R1 → Fixer R1 → Auditor R2 → Integrator → integration_check) completed in 1 Fixer round. Route D (coherent-resolution surgery) produced the accepted proof with 1 L2 citation (FM Prop 1.6). O1–O5 all PASS; see `workspace/diag/curve_complex_s11_test_log.md` for detailed observations and capability-assessment paragraph.


---

## 2026-04-21 — V2.3 Stage 1 CHECKPOINT (five structural upgrades)

Prompt-only changes to deepen mathematical capability. No Python. All
modified prompt files backed up to `workspace/architecture_backups/v2.2/`
before editing.

### Upgrades landed

| # | Upgrade | Key files changed |
|---|---------|-------------------|
| U1 | Dynamic Fixer round limit (progress ledger + F4 gate) | `prompts/fixer.md`, `math-auditor/ldt_checklist.md`, `prompts/auditor.md`, `orchestrator_update.md` |
| U2 | Sub-pipeline recursion (`[SUB-PROBLEM:...]`) | `prompts/sub_pipeline.md` (NEW), `prompts/explorer.md`, `prompts/fixer.md`, `prompts/auditor.md`, `orchestrator_update.md` |
| U3 | Cross-pollination at Judge (`[REUSABLE-FRAGMENT:...]`) | `prompts/judge_ldt.md`, `prompts/judge.md`, `prompts/fixer.md`, `prompts/auditor.md` |
| U4 | Level-1 library (`level1_lemmas/`, `[REF:level1:*]`) | `prompts/level1_library_protocol.md` (NEW), `prompts/scout.md`, `math-auditor/ldt_checklist.md`, `prompts/integrator.md` |
| U5 | SP severity × type refactor (ROUTINE/STRUCTURAL/STRATEGIC) | `prompts/auditor.md`, `math-auditor/ldt_checklist.md`, `prompts/fixer.md`, `orchestrator_update.md` |

### Backups (workspace/architecture_backups/v2.2/)

- fixer.md, auditor.md, judge.md, judge_ldt.md, explorer.md, scout.md,
  integrator.md, ldt_checklist.md, orchestrator_update.md

### Sanity checks (all five)

- `workspace/diag/v23_upgrade_1_sanity.md` — PASS. Caught + fixed sign
  ambiguity in fixer.md's Net delta formula. Mock Round-3 Fixer closing
  LOW/ROUTINE + introducing HIGH/STRUCTURAL correctly triggers
  FIXER-STALLED.
- `workspace/diag/v23_upgrade_2_sanity.md` — PASS. Mock inadmissible
  sub-problem (strictly MORE general than parent) correctly rejected
  with SUB-PROBLEM-REJECTED; admissible counterpart passes.
- `workspace/diag/v23_upgrade_3_sanity.md` — PASS. Judge extracted 3
  fragments from C(S_{1,1}) losing Route A, including the target
  `status=verified-as-counterexample` fragment preserving SP-A3's
  forensic value.
- `workspace/diag/v23_upgrade_4_sanity.md` — PASS. Mock level1_lemmas
  correctly scanned by Scout 0b-level1; Auditor F2 classifies
  PROVEN-HERE → L1, UNPROVEN-HERE → L2, doesn't count toward L3 warning.
  L3-in-disguise exception correctly re-classifies abuse attempts.
- `workspace/diag/v23_upgrade_5_sanity.md` — PASS. Mock 4-SP audit
  (routine-LOW, structural-HIGH × 2, strategic-HIGH) correctly
  dispatched: STRUCTURAL → full treatment, STRATEGIC → FIXER-REFUSED,
  orchestrator routes to Judge / Scout / PARTIAL per the strategic SP.

**Sanity-check scoreboard:** 5/5 PASS. Two sanity checks (U1, U3) caught
real issues in the drafts — a sign-convention ambiguity and a missed
fragment type — demonstrating the sanity layer is catching, not
rubber-stamping.

### Next step

Stage 2: run full V2.3 pipeline on Blackwell et al. Theorem 4.4 with
real level1_lemmas populated. Observations to log: U1–U5 per-upgrade
behavior + O1–O5 (standard cold-start metrics). Target file:
`workspace/diag/theorem_4_4_v23_test_log.md`.
