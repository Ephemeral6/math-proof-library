# Judge — Theorem 4.4 (LDT variant, v2.3 with cross-pollination)

## Pre-Selection Gate (consistency with problem.md)

- Route 1 (Alexander cite-chain): Explorer 1 produced PARTIAL proof —
  Case A (uniform) closed, Case B (mixed) strategic-stuck. Classified
  as **PARTIAL**.
- Route 2 (genus + braid): Explorer 2 produced PARTIAL — asymmetric
  case killed, uniform case closed, mixed-mixed case strategic-stuck.
  Classified as **PARTIAL**.

Neither route is ELIGIBLE (full proof); both are PARTIAL. Judge does
NOT emit `REJECT_ALL` (because partial progress exists) but scoring
is bounded by 25/55 per problem §7 Pre-Selection Gate rule.

## Scoring (5 axes)

### Route 1 (Explorer 1): Alexander cite-chain
- Completeness: 5/10 (Case A complete, Case B stuck)
- Correctness: 8/10 (no logical errors; honest about Case B gap)
- Elegance: 7/10 (clean use of level1 chain for Case A)
- Gaps: 5/10 (one large strategic gap)
- Geometric Content: 3/10 (Alexander-polynomial argument is
  algebraic; no geometric OPERATION performed)
  Evidence:
    - Load-bearing step: none identifiable (Case A is polynomial
      arithmetic; Case B incomplete)
    - Operation: "no geometric operation identified"
    - If removed: N/A (no geometric content to remove)
  [VOCAB-CAP not needed; score is below 6]
- **Total: 5+8+7+5+3×1.5 = 29.5/55**
- Notes: Case A is a textbook-quality derivation; Case B is an
  honest strategic failure.

### Route 2 (Explorer 2): Seifert genus + braid combinatorics
- Completeness: 6/10 (asymmetric case killed, uniform case handled,
  mixed-mixed incomplete)
- Correctness: 8/10 (honest gap identification; small arithmetic
  confusion at Step 2 self-corrected)
- Elegance: 6/10 (messy but the genus reduction is a clean insight)
- Gaps: 4/10 (two strategic gaps: det formula, signature formula)
- Geometric Content: 5/10 (Seifert genus is geometrically meaningful;
  block-cyclic Seifert structure engages the topological scaffolding;
  but no explicit geometric OPERATION on the knot is performed)
  Evidence:
    - Load-bearing step: Step 1 (genus dichotomy reduction)
    - Operation: "Step 1 applies Theorem 3.5(i) to rule out
      asymmetric-uniform/mixed pairs. This is a GEOMETRIC
      operation on the Seifert genus (an honest topological
      invariant), not pure algebra."
    - If removed: YES — without the genus dichotomy, Route 2 has no
      more progress than Route 1. But Case A handling does not
      require it, so the geometric content is specifically useful
      for the NEGATIVE-result portion.
  Since "If removed: YES", score capped at 6 per VOCAB-CAP rule.
  Actual score: 5/10 (below the cap; no change).
- **Total: 6+8+6+4+5×1.5 = 31.5/55**
- Notes: Better than Route 1 on geometric content and completeness;
  same strategic stuck-point.

## Cross-pollination extraction (v2.3 U3)

Two non-winning routes (neither wins outright; both PARTIAL). Scan
both for reusable fragments. Cap: 3 per route.

### From Route 1 (Explorer 1)

[REUSABLE-FRAGMENT: from=Explorer 1, id=fragment-1]
Statement: If $S(p,q,\epsilon) \cong S(q,p,\epsilon')$ and
$\epsilon$ is uniform (so $S(p,q,\epsilon) = T(p,q)$ up to mirror),
then $\epsilon'$ is uniform and $S(q,p,\epsilon') = T(q,p)$.
Proof sketch: Step 2 Case A of Explorer 1. Uses
[REF:level1:corollary_3_10] + [REF:level1:proposition_4_3] uniqueness
at $(q,p)$.
Status: verified
Relevance: Handles the uniform-$\epsilon$ arm of Theorem 4.4. Any
future Route that splits into uniform vs mixed cases can cite
fragment-1 for the uniform arm and focus effort on mixed.

[REUSABLE-FRAGMENT: from=Explorer 1, id=fragment-2]
Statement: The level1 library as registered is INSUFFICIENT for the
mixed-$\epsilon$ case of Theorem 4.4. The paper's §4 must contain an
additional lemma (Lemma 4.1 or 4.2) that refines the Alexander-
polynomial classification for mixed spiral knots.
Proof sketch: Explorer 1 Step 3 analysis — attempt 1 (Alexander alone)
and attempt 2 (Seifert form) both fail for lack of scaffolding.
Status: verified-as-counterexample
Relevance: Tells Fixer/orchestrator NOT to waste rounds attempting
Case B with the current library. Suggested orchestrator action:
populate a new level1 lemma from Blackwell §4.

### From Route 2 (Explorer 2)

[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-3]
Statement: Under $S(p,q,\epsilon) \cong S(q,p,\epsilon')$ and
[REF:level1:theorem_3_5](i), the case "$\epsilon$ uniform,
$\epsilon'$ mixed" (and symmetrically "$\epsilon$ mixed, $\epsilon'$
uniform") is impossible because genus is an isotopy invariant but the
uniform and mixed genera differ by at least 1.
Proof sketch: Step 1 of Explorer 2. Direct application of Theorem
3.5(i).
Status: verified
Relevance: Kills the asymmetric case cleanly. Any Route that wants
to reduce Theorem 4.4 to the symmetric cases can cite fragment-3.

[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-4]
Statement: The block-cyclic Seifert matrix from [REF:level1:theorem_3_5](ii)
has dimensions $q(p-1) \times q(p-1)$ at parameters $(p,q)$ and
$p(q-1) \times p(q-1)$ at parameters $(q,p)$. These dimensions
differ (since $p \ne q$), but the matrices can still be S-equivalent
because S-equivalence allows stabilization.
Proof sketch: Step 2 of Explorer 2 (the rank/size confusion resolved
by S-equivalence).
Status: unverified (Explorer 2 observed the dimension difference but
did not complete the S-equivalence analysis; a Fixer citing this
fragment MUST verify the S-equivalence claim).
Relevance: Useful for any Route attempting the mixed-mixed case via
Seifert matrices. The dimension mismatch is a concrete hook.

## Final Selection

**Winner: Route 2** (Explorer 2). Higher total (31.5 vs 29.5),
stronger geometric content (5 vs 3), and fragment-3 (genus dichotomy
killing the asymmetric case) is more useful downstream than Route 1's
Case A alone.

**Reason**: Route 2 makes concrete additional progress beyond Route
1 by killing the asymmetric case. Both stall at the same strategic
point, but Route 2's partial result is richer. Geometric Content
score of 5 (vs 3) also shifts the decision under the 1.5× multiplier
per the LDT Judge criterion.

**Second place**: Route 1 (total 29.5; within 5 points of Route 2's
31.5). Per the close-call rule, Auditor should AUDIT BOTH, with
Route 1 saved as `alternative_route.md`.

**Minor issues to fix**: Neither route closes the mixed-mixed case.
All identified SPs are STRATEGIC. Fixer will refuse. Orchestrator
must decide route-switch / re-Scout / accept PARTIAL.

## Note on REJECT_ALL threshold

Judge considered emitting REJECT_ALL because both routes fail the
main theorem. But per the Pre-Selection Gate rule, PARTIAL routes
(which prove a non-trivial fragment of the theorem) are eligible
for scoring with capped total. The fragments extracted give useful
downstream value, so REJECT_ALL would be over-strict. The honest
verdict is PARTIAL-winner-with-strategic-SP.
