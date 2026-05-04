# Auditor — Round 1 (best_proof.md = Route 2, Explorer 2)

## Pre-flight

- Target file: `best_proof.md` (copy of `explorer_2_route_2.md` +
  cross-pollination fragment block).
- Judge verdict: PARTIAL-winner; Pre-Selection Gate triggered;
  score 31.5/55.
- F4 gate: inactive (this is Audit Round 1; no prior Fixer cycle).
- Cross-pollination fragments present: 3 (fragment-1, fragment-2,
  fragment-4).

## Step 0.5 — Reverse-consistency check

Theorem 4.4 claims an IFF. Check that the proof addresses BOTH
directions and that the conclusion matches the hypothesis.

- **Backward** (torus ⇒ $\exists \epsilon'$ with swap): Step 0 covers
  this via classical $T(p,q) \cong T(q,p)$. VALID.
- **Forward** ($\cong$ ⇒ torus): Step 1 reduces to "both uniform" or
  "both mixed" via genus dichotomy. "Both uniform" closes (both are
  torus). "Both mixed" is UNRESOLVED.

**Reverse-consistency verdict**: Backward clean; forward PARTIAL
(uniform subcase closed; mixed subcase open). No false direction
claim.

## Step-by-step verification

### Step 0 (backward)
- Claim: $\epsilon = (+1,\ldots,+1)$ uniform ⇒ $S(p,q,\epsilon) =
  T(p,q) \cong T(q,p) = S(q,p,(+1,\ldots,+1))$.
- Classical $T(p,q) \cong T(q,p)$ is L2 (textbook, Lickorish §7,
  Kauffman §3).
- **VERDICT: VALID.**
- Minor note: the mirror case ($\epsilon$ all $-1$) is handled via
  the "mirror convention" — the theorem statement should be read up
  to mirror. Confirmed consistent with problem.md.

### Step 1 (genus dichotomy)
- Claim: Seifert genus is an isotopy invariant; therefore
  $g(S(p,q,\epsilon)) = g(S(q,p,\epsilon'))$.
  - Genus invariance under isotopy: L1 (definitional).
- Claim: $g(S(p,q,\epsilon)) = (p-1)(q-1)/2$ iff $\epsilon$ uniform
  (from [REF:level1:theorem_3_5](i)).
  - Level-1 citation. Level1 library shows status UNPROVEN-HERE →
    L2 per level1_library_protocol. VALID as L2.
- Case elimination:
  - Both uniform: arithmetic OK. Genera both equal max =
    $(p-1)(q-1)/2$. Closes via Step 0 argument.
  - Both mixed: arithmetic OK. Genera both < max, and equal.
    UNRESOLVED.
  - Asymmetric (one uniform, one mixed): genera unequal, so
    equivalence is impossible. VALID.
- **VERDICT: VALID.** Step 1 is a clean application of Theorem
  3.5(i). It rules out the asymmetric case and reduces forward to
  two sub-cases.
- Numerical spot-check: $(p,q) = (3,5)$: $(p-1)(q-1)/2 = 4$.
  Uniform spiral has $g = 4$. Mixed with $\epsilon = (+,-)$ has
  $g < 4$ per 3.5(i). Consistent.

### Step 2 (mixed-mixed via block-cyclic structure)
- Initial "size contradiction" argument: reader caught a reading
  error — treating block-cyclic matrix total dimension as $2g$
  directly. Self-corrected.
- Corrected reading: block-cyclic presentation has size $q(p-1)$
  but rank $2g$ after stabilization; S-equivalence is a weaker
  relation than equality.
- **Arithmetic verification** of self-correction:
  - Total size at $(p,q)$: $q(p-1)$. At $(q,p)$: $p(q-1)$.
  - $q(p-1) - p(q-1) = qp - q - pq + p = p - q \ne 0$ for $p \ne q$.
  - So sizes genuinely differ; but S-equivalence permits
    stabilization (adding $\pm 1$ blocks on the diagonal).
  - Conclusion "no direct contradiction" VALID.
- SP-1 [HIGH, STRATEGIC] recorded: no $\det(V_\epsilon)$ formula.
- **VERDICT: VALID self-correction; STEP STUCK** (no closure in
  level1 lib).
- Note: the arithmetic confusion in Step 2 is self-corrected in
  the proof text. A production-grade write-up should collapse the
  "wait — let me recheck" passage into a clean statement. This is
  a WRITE-UP issue, not a mathematical issue. Flagged as LOW/
  ROUTINE for future polish.

### Step 3 (signature attempt)
- Signature $\sigma$ invariance: L1.
- Claim: "No level1 lemma provides the spiral-signature formula."
  - Confirmed by inspecting `level1_lemmas/` — only Theorem 3.5,
    Corollary 3.10, Proposition 4.3 are registered. None gives
    $\sigma(S(p,q,\epsilon))$.
- SP-2 [HIGH, STRATEGIC] recorded.
- **VERDICT: VALID-as-obstacle.**

### Step 4 (sub-problem attempt, U2)
- Candidate sub-problem: "For $p=3$, mixed $\epsilon \in \{\pm 1\}^2$
  with one +1 and one −1, no mixed $\epsilon'$ satisfies the swap."
- U2 admissibility: "Strictly smaller because: strictly smaller
  parameter range — fixes $p = 3$." This matches the U2 rubric
  (smaller parameter range).
- Explorer 2 elected NOT to emit the sub-problem because the
  sub-pipeline would need the same missing scaffolding, so it
  would STRATEGIC-fail and burn breadth budget.
- **VERDICT: VALID decision** (U2 rule-respecting; non-emission
  is legitimate when the sub-problem does not isolate a newly-
  tractable piece).

### Step 5–7 (verdict + citation profile + SPs)
- Step 5 verdict: STRATEGIC failure on mixed case. Consistent with
  Steps 2–3.
- Step 6 citation profile: correct. All level1 citations present
  and tagged [REF:level1:theorem_3_5].
- Step 7 SP list: SP-1, SP-2 both HIGH/STRATEGIC. Classification
  consistent with U5 rubric (missing machinery, not a local
  calculation error).

### Cross-pollination block audit (U3)
- fragment-1 (Explorer 1 uniform-arm handler, status=verified):
  re-reading Explorer 1 Step 2 Case A confirms this fragment.
  Statement quoted is accurate. VALID.
- fragment-2 (library-insufficiency counterexample, status=
  verified-as-counterexample): re-reading Explorer 1 Step 3 confirms
  the library insufficiency; the paper's §4 Lemma 4.1 / 4.2 is not
  in level1_lemmas/. VALID.
- fragment-4 (Seifert matrix dimension mismatch, status=
  unverified): flagged "unverified" correctly — the S-equivalence
  claim is asserted but not proven. VALID that the status is
  honest.
- **Fragment cap**: 3 fragments total from 2 losing-route pools (1
  from Route 1 winning's losing sub-route? Actually both Route 1 and
  Route 2 are PARTIAL; Judge extracted 3 under the "both losing"
  rule). Within cap. VALID.

## Issues Found (v2.3 SP table, U5 dual classification)

| ID | Severity | Type | Description | Fixable locally? |
|----|----------|------|-------------|------------------|
| SP-1 | HIGH | STRATEGIC | No closed-form $\det(V_\epsilon)$ in level1 | NO — missing machinery |
| SP-2 | HIGH | STRATEGIC | No spiral-signature formula in level1 | NO — missing machinery |
| SP-3 | LOW | ROUTINE | Step 2 write-up has a self-correction passage that could be collapsed | YES, but not load-bearing |

SP-1 and SP-2 point at the same underlying issue: the paper's §4
almost certainly has Lemma 4.1 / 4.2 supplying the needed
classification, and we did NOT register those in level1_lemmas/.
SP-3 is cosmetic.

## LDT-Specific Audit checklist

| Item | Status | Notes |
|------|--------|-------|
| F1 (geometric content justified) | PARTIAL | Seifert genus is geometric; Step 1 is a real geometric operation on the genus invariant. Step 2–3 attempts are algebraic. |
| F2 (citation classification, L3 count) | PASS | All non-level1 citations: L1 (genus invariance, σ invariance) + L2 ($T(p,q) \cong T(q,p)$). L3 total: 0. Level1 exempted per v2.3 protocol. |
| F2-cross (level1 exemption sanity) | PASS | The 3 level1 citations are legitimately paper-internal results being assumed-valid; not L3-in-disguise. |
| F3 (no undeclared blackboxes) | PASS | All blackboxes declared: [REF:level1:...] or explicit L2 textbook cite. |
| F4 (progress ledger) | N/A | Audit Round 1; no prior Fixer cycle. Ledger will be populated at Round 2 if a Fixer round occurs. |
| F5 (genuine knot-theoretic engagement) | PARTIAL | Step 1 engages genus non-trivially. Mixed-mixed case is stuck at a machinery gap, not at a geometric conceptual barrier. |
| F6 (honest failure reporting) | PASS | SPs classified honestly as STRATEGIC; sub-problem attempt transparently documented; self-correction visible. |

STRUCTURAL-CITATION-WARNING: **not triggered**. L3 count = 0
(level1 citations exempted).

## Geometric Intuition Assessment

- Step 1 (genus dichotomy): GENUINELY GEOMETRIC. Genus is an
  invariant of the Seifert surface; dichotomy is an honest
  topological fact from 3.5(i).
- Steps 2–3 (Seifert matrix, signature): ALGEBRAIC in spirit,
  working with $V$ and $V + V^T$; geometric connection is indirect
  (via Seifert surface homology).
- No explicit geometric OPERATION (surgery, Dehn twist, cobordism
  construction) is performed.
- Judge's Axis-5 score of 5/10 is well-calibrated.

## Verdict

**PARTIAL-with-STRATEGIC-SP.**

The proof does NOT close Theorem 4.4. What it DOES establish is:
1. Backward direction (Step 0).
2. Forward direction, both-uniform subcase (via fragment-1 from
   cross-pollination + Step 1 genus dichotomy).
3. Forward direction, asymmetric-case elimination (Step 1).

What remains open:
- Forward direction, both-mixed subcase (Steps 2–3, stuck at
  missing machinery).

Per U5, STRATEGIC SPs are not locally fixable by the Fixer. The
Fixer will issue FIXER-REFUSED and the orchestrator must decide
route-switch / re-Scout / accept-PARTIAL.

## Audit output tags

- AUDIT-VERDICT: PARTIAL
- PARTIAL-SUBCASES-CLOSED: [backward, forward-uniform, forward-asymmetric-elimination]
- PARTIAL-SUBCASES-OPEN: [forward-both-mixed]
- SP-LIST: [SP-1 HIGH STRATEGIC, SP-2 HIGH STRATEGIC, SP-3 LOW ROUTINE]
- STRUCTURAL-CITATION-WARNING: not triggered (L3 = 0)
- F4-PROGRESS-LEDGER: N/A (first audit)
- CROSS-POLLINATION-AUDIT: 3/3 fragments verified-as-stated
- FIXER-ROUTING: STRATEGIC-heavy; expect FIXER-REFUSED
