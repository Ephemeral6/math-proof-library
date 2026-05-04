# Judge — Spiral-knot pipeline (post-Fix-3 `judge_ldt.md`)

## Pre-Selection Gate — eligibility check

Problem asks for (A) Theorem 3.5 — formula
$\Delta_{S(p,q,\epsilon)} \doteq \prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t)$;
(B) Theorem 4.2 — genus $= (p-1)(q-1)/2$.

| Route | Theorem 3.5 quantitative conclusion | Theorem 4.2 | Status |
|-------|-------------------------------------|-------------|--------|
| A (Burau + eigenvalue factorization) | Proved for $p \le 4$ all $\epsilon$ (exhaustive); general $p$ modulo 4 flagged stuck points (SP-1 corrected, SP-2/SP-3/SP-4 incomplete). Formula matches on all TSV-reachable cases. | Upper bound closed; lower bound modulo SP-4 breadth claim. | **ELIGIBLE_WITH_GAP** |
| B (direct Seifert matrix + block-circulant) | Proved for 3 small cases by explicit linking calc; general case **blocked**: block-circulant does not emerge in the chosen basis. | Upper bound closed; lower bound blocked (no general Δ formula). | **PARTIAL** |
| C (skein induction on $q$) | **Not proved.** Structural obstruction: skein leaves the spiral family at every step; induction cannot close. | Upper bound closed; lower bound blocked (same reason). | **PARTIAL (negative)** |

No route is INELIGIBLE (no route produces a *wrong* conclusion; Route C correctly diagnoses its own failure). Scoring proceeds on all three.

---

## Evaluation Report

### Route 1 — A: Burau + eigenvalue factorization

- **Completeness: 5/10** — Four explicit `[STEP-STUCK]`:
  - SP-1: Scout's tridiagonality hypothesis falsified at $p=4$ (honest correction, not a gap in the proof itself).
  - SP-2: $\det(I - B) \doteq \Phi_p(t)$ asserted from standard Burau theory, not derived.
  - SP-3: Key identity $\det(I - yB_\epsilon) = t^{e(\epsilon)} C_{p-1}(y,t)$ exhaustively verified for $p \le 4$ (14 cases) but general-$p$ induction sketched only.
  - SP-4: Breadth of $\prod C_{p-1}(\zeta^\ell, t)$ = $(p-1)(q-1)$ asserted via no-cancellation but not rigorously proved.
  SP-1 is a correction, not a deduction-worthy gap. SP-2 is a cited-but-not-derived standard lemma. SP-3 and SP-4 are genuine incomplete steps. Deduct ~2 per unresolved SP-3/SP-4 with half-credit for SP-2 that's at least a named citation.
- **Correctness: 7/10** — Sound reasoning everywhere it closes; no logical errors. Eigenvalue factorization via Jordan-form-over-closure-then-symmetric-function argument is valid. Base cases all match TSV. No circular dependency. The identity discovered in Step 5 ($t^{e(\epsilon)}$ factor) has an elegant uniform pattern supported by all 14 of the $p \le 4$ cases.
- **Elegance: 7/10** — Minimal L-citations (3 L1, 4 L2, 0 L3). The proof's reliance on the Burau black box is appropriate for the difficulty level. The honest detection and correction of the Scout's wrong tridiagonality claim is a plus.
- **Gaps (deduction form): 4/10** — Four flagged-and-unresolved stuck points. Rubric nominally gives 10 − 2·(# unresolved) but is lenient because SP-1 is a correction and SP-2 is a known-identity citation.
- **Geometric Content: 6/10 × 1.5 = 9/15   [VOCAB-CAP applied]**
  ```
  Evidence:
    - Load-bearing step: Step 7 (Seifert's algorithm on the braid closure).
    - Operation: count Seifert circles $s = p$ and bands $c = (p-1)q$ for the
      standard closed-braid diagram; compute $\chi(F) = p - (p-1)q$; derive
      $g(F) = (p-1)(q-1)/2$ as a direct Euler-char calculation.
    - If removed: YES. The statement "closure of a positive braid of $p$
      strands with $c$ crossings has Seifert-surface genus $(c-p+1)/2$" is
      an L1 textbook fact; replacing the explicit counting by that citation
      preserves the proof.
  ```
  The main body (Steps 1–6, 8, 9) is algebraic (Burau matrices, char
  polynomials, breadth of polynomials), not geometric. Step 7 is the only
  step performing a geometric operation, and it is removable by citation.
  Per Fix-3 rubric this caps at 6/10.
- **Total: 5 + 7 + 7 + 4 + 9 = 32/55**
- **Notes**: Well-structured partial proof. No `[WARN: VOCABULARY-BLUFF]` — the
  proof does not claim geometric content it doesn't have; it is honestly
  algebraic. TSV base-case discipline was model: 3/3 in-scope cases
  verified, out-of-scope case tagged correctly.

### Route 2 — B: Direct Seifert matrix + block-circulant

- **Completeness: 3/10** — Five explicit stuck points. The central claim
  (block-circulant structure) **fails in the chosen basis**. The alternative
  "difference" basis is acknowledged as probably correct but not verified.
  The final identification with $C_{p-1}$ is explicitly imported from Route A
  rather than derived. The main theorem is not closed in general.
- **Correctness: 5/10** — Everything stated is correct. The three small-case
  Seifert matrices reproduce the Alexander polynomials correctly
  ($3_1$ twice, $4_1$ once). The structural conclusion "block-circulant
  does not emerge in the tree basis" is correct and honestly reported.
  But the proof doesn't assemble into a theorem.
- **Elegance: 6/10** — Very clean small-case computations. Clear separation
  of what works from what doesn't. No hand-waving at stuck points.
- **Gaps (deduction form): 3/10** — Five stuck points, one of which
  (block-circulant structure failure) is the main obstruction.
- **Geometric Content: 8/10 × 1.5 = 12/15**
  ```
  Evidence:
    - Load-bearing step: Cases A, B, C linking-number calculations (§§3-6),
      plus Step 2 (Seifert surface construction from the braid-closure
      diagram).
    - Operation: exhibits the Seifert surface $F = \bigsqcup D_i \cup
      \bigsqcup b_{k,i}$ explicitly; picks a fundamental-cycle basis
      $\alpha_{k,i} = b_{k,i} - b_{1,i}$ of $H_1(F)$; computes the Seifert
      form $V(\alpha, \beta) = \mathrm{lk}(\alpha^+, \beta)$ by direct
      push-off for each pair of basis cycles in the three base cases;
      produces explicit $2 \times 2$ Seifert matrices and verifies
      $\det(M - tM^T)$ against TSV.
    - If removed: NO. The linking-number calculations cannot be replaced by
      a single citation; the proof's contribution to Theorem 4.2's upper
      bound and to the small-case verifications is done by actual geometric
      computation.
  ```
  This is the strongest route on Axis 5. The proof performs genuine
  geometric operations. The fact that the OVERALL proof doesn't close
  does not reduce the Axis-5 score — Axis 5 rewards the geometric work
  performed, not the overall completeness.
- **Total: 3 + 5 + 6 + 3 + 12 = 29/55**
- **Notes**: Route B is the most "LDT-native" attempt but fails to reach the
  general formula. No `[WARN: VOCABULARY-BLUFF]`. TSV: 2/2 in-scope cases
  verified; $10_{123}$ out-of-scope flagged.

### Route 3 — C: Skein recursion on $q$

- **Completeness: 3/10** — Route documents its own structural failure
  (skein at seam leaves the spiral family, induction can't close).
  Produces Theorem 4.2 upper bound only, via the same Seifert's-algorithm
  step as the other routes. No general proof of Theorem 3.5 attempted.
- **Correctness: 6/10** — Small-case skein consistency is verified
  correctly. The negative conclusion ("induction cannot close inside the
  spiral family") is a correct structural observation, supported by
  explicit permutation / component counting for $L_-$ and $L_0$ at small
  $(p,q)$.
- **Elegance: 6/10** — Clean diagnostic of why the route fails. Does not
  waste pages trying to force closure.
- **Gaps (deduction form): 3/10** — Same five-ish stuck points as the
  other routes' analogs, but Route C's are structural rather than
  technical.
- **Geometric Content: 6/10 × 1.5 = 9/15**
  ```
  Evidence:
    - Load-bearing step: Step 5, Case A (the skein identity verification
      for the $q=3$ trefoil case).
    - Operation: applies the Conway skein relation
      $\Delta_{L_+} - \Delta_{L_-} = (t^{1/2} - t^{-1/2}) \Delta_{L_0}$
      at an explicit crossing; identifies $L_+, L_-, L_0$ as trefoil,
      unknot, Hopf link; checks the arithmetic identity
      $(t - 1 + t^{-1}) = 1 + (t^{1/2} - t^{-1/2})^2$ directly.
    - If removed: N/A. The skein IS the route's sole mechanism; removing
      it is removing the route.
  ```
  Route C's geometric content is combinatorial/diagrammatic (rubric
  level 6 verbatim: "state sum on a diagram, skein relation..."). The
  work is done but does not assemble into a theorem, so Axis 5 stays at
  the level-6 ceiling.
- **Total: 3 + 6 + 6 + 3 + 9 = 27/55**
- **Notes**: Negative / obstructive result documented honestly. No bluff;
  no vocabulary abuse. Route C's real contribution is the failure pattern
  to be added to `failure_patterns.md`.

---

## Final Selection

**Winner: Route 1 (Route A — Burau + eigenvalue factorization).**

**Reason**: Route A produces the most complete argument — Theorem 3.5 is
reached modulo four explicit and well-isolated stuck points, and the key
identity is exhaustively verified on 14 small cases; Theorem 4.2 closes on
both sides modulo a routine breadth argument. Route B has stronger Axis-5
Geometric Content (12/15 vs. 9/15) and is a tidier *partial*, but its main
obstruction (block-circulant structure failing to emerge in the chosen
basis) is a genuine blocker that prevents it from closing in general. Route C
documents its own structural failure as a dead end. Total: 32/55 vs. 29/55
vs. 27/55.

**Second place: Route 2 (Route B).** Gap is **3 points on the 55-point
scale** (well within the 5-point close-call threshold). Per
`judge_ldt.md`'s close-call rule, **both Route A and Route B should be
audited**. Route B is the "geometric alternative" audit route — its
Seifert-matrix construction and small-case linking-number calculations are
independent work that could be combined with Route A's Burau core to
produce a cleaner final proof.

**Minor issues to fix** (for Fixer, in priority order):
1. SP-3 (Route A): complete the general-$p$ induction of the identity
   $\det(I - yB_\epsilon) = t^{e(\epsilon)} C_{p-1}(y, t)$. The 14-case
   exhaustive check makes this near-certain; the induction sketch needs
   to be written out.
2. SP-2 (Route A): derive $\det(I - B) \doteq \Phi_p(t)$ from the
   unreduced/reduced Burau transition formula (this is a known standard
   identity but was asserted, not proved).
3. SP-4 (Route A): make the breadth argument rigorous for
   $\prod_\ell C_{p-1}(\zeta_q^\ell, t)$.
4. Cross-link Route B's genus upper bound to Route A (they use the same
   Seifert-algorithm count — no new work, just deduplication in the final
   writeup).

## Overall Judge verdict: ELIGIBLE_WITH_GAP (Route A is best)

This is *not* a reject — the proof attempt is substantive and partially
closed. It is *not* an accept — four stuck points remain. The appropriate
Auditor action is to run the LDT checklist with L1/L2/L3 classification
and issue a **FIX** verdict listing SP-2, SP-3, SP-4 as the items to close.

No `[WARN: VOCABULARY-BLUFF]` on any route. The Fix-3 Evidence Field
operates as designed: Route A scored 6/10 (cap) for algebraic-body plus
one removable geometric step; Route B scored 8/10 for genuine
geometric-computation contribution; Route C scored 6/10 for
combinatorial/skein work. The multiplier produces a 3-point spread that
matches the intended calibration — Route B is rewarded for being
geometrically more substantive even though its overall proof is less
complete, and Route A still wins because its Completeness and Correctness
are strictly higher.
