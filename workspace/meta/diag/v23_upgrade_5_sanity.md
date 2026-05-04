# Sanity check — Upgrade 5 (SP severity × type refactor)

**Date.** 2026-04-21.
**Target.** Confirm the updated Auditor emits SPs with BOTH severity
and type tags, and the Fixer correctly dispatches by type (ROUTINE →
one-block fix; STRUCTURAL → full treatment; STRATEGIC → FIXER-REFUSED).

## Mock Auditor output (input to Fixer)

Auditor audits a hypothetical LDT proof and finds 4 SPs:

```
## Issues Found
1. SP-1 [severity=HIGH] [type=STRUCTURAL] Step 4 introduces a new
   induction variable $k_j$ but does not define the base case at
   $j = 0$. The inductive step writes "$k_j = k_{j-1} + \epsilon_j$"
   which references $k_{-1}$, undefined.
2. SP-2 [severity=HIGH] [type=STRUCTURAL] The claimed isomorphism
   $H_1(\Sigma_2) \cong H_1(\Sigma_1) \oplus \mathbb{Z}$ in Step 5
   requires a Mayer-Vietoris argument that is not given. The step says
   "clearly" but clarity requires explicit computation.
3. SP-3 [severity=HIGH] [type=STRATEGIC] The overall route assumes
   the Alexander polynomial distinguishes $S(p,q,\epsilon)$ from
   $S(q,p,\epsilon')$ when they are inequivalent, but Corollary 3.10
   [REF:level1:corollary_3_10] only gives equality of polynomials
   for equivalent spiral knots (one direction), not the converse.
   Without the converse, the route cannot prove the "only if"
   direction of Theorem 4.4. This is irreparable within Route A.
4. SP-4 [severity=LOW] [type=ROUTINE] Step 2 cites "Farb–Margalit
   Prop 1.6" without a page number. Add page reference.
```

## Simulated Fixer execution (v2.3 severity × type dispatch)

Reading `fixer.md` "Severity × type dispatch" section:

### SP-1 [HIGH, STRUCTURAL]

STRUCTURAL → Fixer must give a full treatment (no length cap).

```
### Issue 1 Fix (SP-1)
- Original: Step 4 induction base case at j=0 missing.
- Fix approach: introduce j=0 as "empty product" convention; rewrite
  the recurrence to make $k_0 := 1$ explicitly; add base-case proof.
- Fixed step: "Step 4 (revised). Define $k_0 := 1$ and $k_j := k_{j-1}
  + \epsilon_j$ for $j \ge 1$. The base case $j = 0$ requires
  verification that $k_0 = 1$ produces the correct starting value of
  the Seifert-matrix diagonal; this is Step 4a below. For $j \ge 1$,
  induction proceeds by the recurrence..."
- New sub-step 4a proves $k_0 = 1$ gives the correct Seifert-matrix
  (11) entry by direct expansion of the braid word at the trivial
  level.
```

### SP-2 [HIGH, STRUCTURAL]

STRUCTURAL → full treatment. The Mayer-Vietoris computation that was
"clear" must be written.

```
### Issue 2 Fix (SP-2)
- Original: H_1 isomorphism in Step 5 asserted without proof.
- Fix approach: invoke Mayer-Vietoris on the decomposition $\Sigma_2 =
  \Sigma_1 \cup (\text{band})$, where the band glues two boundary
  arcs of $\Sigma_1$.
- Fixed step: "Step 5 (revised). Let $\Sigma_2 = \Sigma_1 \cup_A B$
  where $B$ is a 2-handle (band) attached to $\Sigma_1$ along an arc
  $A$. The Mayer-Vietoris sequence gives
     $H_1(A) \to H_1(\Sigma_1) \oplus H_1(B) \to H_1(\Sigma_2) \to
      H_0(A) \to H_0(\Sigma_1) \oplus H_0(B)$.
  Since $A$ is an arc, $H_1(A) = 0$ and $H_0(A) = \mathbb{Z}$; since
  $B$ is a 2-disk, $H_1(B) = 0$, $H_0(B) = \mathbb{Z}$. Connectedness
  of $\Sigma_1 \cup B$ makes the last map injective. The resulting
  short exact sequence gives $H_1(\Sigma_2) \cong H_1(\Sigma_1)
  \oplus \mathbb{Z}$ as claimed."
```

### SP-3 [HIGH, STRATEGIC]

STRATEGIC → Fixer CANNOT close. Must emit FIXER-REFUSED.

Per the fixer prompt, the output is:

```
## Progress ledger
- Net HIGH/STRUCTURAL delta: REFUSED
- Strategic SPs forcing refusal:
  - SP-3 (HIGH, STRATEGIC) — Route A's reliance on Alexander-
    polynomial converse is false without additional structure. The
    route as designed cannot prove the "only if" direction.
- Non-strategic SPs left unaddressed this round: SP-1, SP-2, SP-4
  (not addressed because FIXER-REFUSED terminates the round).

## FIXER-REFUSED
Cannot close strategic SP-3 inside Route A. The Alexander polynomial
argument requires a converse (Δ determines spiral knot up to some
equivalence) that Corollary 3.10 does NOT provide. Orchestrator must
decide:
(a) ask Judge to switch to a non-winning Route B/C (e.g., Seifert-
    form-direct approach using Theorem 3.5's block structure),
(b) re-invoke Scout with constraint "must not rely on Alexander-
    polynomial converse",
(c) terminate as PARTIAL with SP-3 recorded in failure_patterns.md.

No `## Complete Fixed Proof` follows.
```

### SP-4 [LOW, ROUTINE]

ROUTINE → close in one token-dense block. But since FIXER-REFUSED was
already emitted for SP-3, this round does NOT attempt SP-4 (the round
is void except for the refusal). A later round after orchestrator
re-routes MAY address SP-4 if the new route retains the same Step 2.

## Orchestrator dispatch (simulated)

Reading FIXER-REFUSED-CONFIRMED from Auditor F4:

1. Check if any non-winning route exists with different technique:
   - Suppose Judge's cross-pollination (v2.3 U3) extracted
     [REUSABLE-FRAGMENT: from=Explorer 3, id=fragment-5] with
     statement="Seifert-form-direct Lemma X" status=verified.
   - This suggests a Seifert-form route that does NOT rely on
     Alexander-polynomial converse.
   - DISPATCH (a): Judge re-runs with SP-3 as constraint and selects
     the Seifert-form route using fragment-5.

2. If no such alternative exists: DISPATCH (b) re-invokes Scout with
   "must not rely on Alexander-polynomial converse" in the route
   constraints.

3. If (b) has been tried once on the same theorem already: DISPATCH
   (c) terminate PARTIAL and log SP-3 in failure_patterns.md.

## Verification of dispatch correctness

### Check 1: Type tags are present on every SP

| SP | Severity | Type | Correct? |
|----|----------|------|----------|
| SP-1 | HIGH | STRUCTURAL | ✓ |
| SP-2 | HIGH | STRUCTURAL | ✓ |
| SP-3 | HIGH | STRATEGIC | ✓ |
| SP-4 | LOW | ROUTINE | ✓ |

All 4 SPs correctly dual-tagged. PASS.

### Check 2: Fixer correctly dispatches by type

- SP-1, SP-2 (STRUCTURAL): full treatment attempted (though void-ed by
  refusal on SP-3). Dispatch rule followed: yes.
- SP-3 (STRATEGIC): FIXER-REFUSED emitted. No force-fix attempted.
  Dispatch rule followed: yes.
- SP-4 (LOW, ROUTINE): would have been closed in one block, but
  subsumed by refusal. Dispatch rule followed: yes.

### Check 3: FIXER-REFUSED format correct

- `## Progress ledger` with `Net: REFUSED` and strategic SP list: YES.
- Strategic SP stated with reason: YES.
- No `## Complete Fixed Proof` section: YES.
- Orchestrator options (a)/(b)/(c) listed: YES.

PASS.

### Check 4: Orchestrator routes by FIXER-REFUSED-CONFIRMED

- Auditor F4 on the refused Fixer output emits
  FIXER-REFUSED-CONFIRMED.
- Orchestrator picks option (a) if non-winning route / fragment
  provides alternative technique.

PASS.

## Contrast: what V2.2 would have done

Under V2.2 (no severity × type):
- Auditor emits SPs with severity only: SP-1 HIGH, SP-2 HIGH, SP-3
  HIGH, SP-4 LOW.
- Fixer would attempt to fix all 4, including SP-3. It would either:
  (i) silently fail on SP-3 after wasted tokens and produce a Fix
  Report that doesn't actually close SP-3 but claims to (FALSE-CLOSE
  behavior that v2.3 F4 catches), or
  (ii) hallucinate a fix for the Alexander-polynomial converse that
  is wrong.
- Either way, the pipeline would burn a Fixer round on a fundamentally
  irreparable issue, wasting budget and inflating round count.

Under V2.3:
- Fixer refuses immediately on seeing the STRATEGIC tag.
- Orchestrator routes to Judge / Scout / PARTIAL within the same
  round's budget.
- No token burn on force-fixing an irreparable issue.

## Result

**PASS.** All four checks succeed. The SP severity × type refactor:
1. Forces Auditor to think about what KIND of work the SP requires,
   not just how bad it is.
2. Gives Fixer a clear dispatch rule per type (one-block / full
   treatment / refuse).
3. Lets the orchestrator cleanly handle strategic failures without
   burning Fixer rounds.
4. The SP-3 case demonstrates the new STRATEGIC pathway's value:
   early refusal + orchestrator re-route is strictly better than
   V2.2's force-fix behavior.

**Design trade-off identified.** The STRATEGIC tag is only as good as
the Auditor's ability to diagnose path-level failures. In easy cases
(Auditor sees "this claim is literally false"), the tag is clear. In
subtle cases ("the route MIGHT fail but I'm not sure"), the Auditor
should default to STRUCTURAL per the classification rule ("if in doubt
between STRUCTURAL and STRATEGIC, prefer STRUCTURAL"). This defensive
default prevents over-eager STRATEGIC tagging from short-circuiting
routes that could actually be fixed.
