# Round 0.5 hyperbolic `best_proof.md` — Axis 5 re-score with Evidence Field (Fix 3)

**Input**: the Round 0.5 best proof of $3_1 \not\sim 4_1$ — the Seifert-vs-hyperbolic
dichotomy argument (Gordon–Luecke + Thurston Seifert classification + Thurston
hyperbolization + Mostow rigidity).

**Rubric applied**: post-Fix-3 `judge_ldt.md` (Axis 5 with Evidence Field).

**Pre-fix Axis 5 score (from Probe 6 Part B)**: 9/10 × 1.5 = **13.5/15**.

**Expected post-fix score (per task brief)**: 6/10 × 1.5 = **9/15**,
because the proof cites Thurston's ideal-tetrahedra construction rather
than constructing it.

---

## Proof structure recap (from Probe 1's citation audit)

| Step | Claim | Kind |
|------|-------|------|
| Setup | Complements are compact oriented 3-mflds with torus cusps | I |
| Setup | Gordon–Luecke: $K \sim K' \iff M_K \cong M_{K'}$ | E3 |
| 1 | $3_1 = T(2,3)$; torus-knot complements are Seifert-fibered over $D^2(2,3)$ | E2 + E1 |
| 1 | $\chi_{\text{orb}}(D^2(2,3)) = -1/6$ | I |
| 1 | Seifert with $\chi < 0 \Rightarrow \widetilde{SL_2(\mathbb R)}$ geometry, not $\mathbb H^3$ | E3 (Thurston's classification) |
| **2** | **$M_{4_1}$ = two regular ideal tetrahedra glued** | **E3** (Thurston's Princeton notes) |
| 2 | Lobachevsky volume formula $\Lambda(\alpha)+\Lambda(\beta)+\Lambda(\gamma)$ | E2 |
| 2 | $6\Lambda(\pi/3) \approx 2.02988$ | I + TSV lookup |
| 3 | Mostow rigidity ⇒ hyperbolic structure is a topological invariant | E3 |
| 4 | Contradiction assembly | I |
| 5 | Gordon–Luecke closes | E3 (same citation as Setup) |

The candidate geometric steps are **Step 1** (Seifert-fibration argument)
and **Step 2** (ideal-tetrahedra argument).

---

## Evidence Field evaluation

### Candidate A: Step 1 — Seifert fibration of $M_{3_1}$

- **Load-bearing?** YES — the Seifert-vs-hyperbolic dichotomy is the
  proof's main lever.
- **Operation performed?**
  - $3_1 = T(2,3)$: 1-line standard identification (not an operation, a
    lookup).
  - $\chi_{\text{orb}}(D^2(2,3)) = 1 - 1/2 - 2/3 = -1/6$: an arithmetic
    operation on orbifold data. This IS geometric content (Euler-char
    of an orbifold).
  - "Seifert with $\chi < 0 \Rightarrow \widetilde{SL_2(\mathbb R)}$":
    cited to Thurston, not derived.
- **Operation performed (summary)**: One orbifold Euler-char computation
  ($\chi_{\text{orb}} = -1/6$), feeding into a cited classification.
- **If removed?** If the orbifold Euler-char computation is removed and
  replaced with "the complement is Seifert-fibered with negative Euler
  char" cited to Thurston, the proof STILL goes through — Thurston's
  classification gives the same conclusion. So Step 1's geometric
  operation (the orbifold arithmetic) is NOT strictly load-bearing;
  it is confirmatory, not structural.

### Candidate B: Step 2 — ideal-tetrahedra triangulation of $M_{4_1}$

- **Load-bearing?** YES — this is where the proof claims $M_{4_1}$ is
  hyperbolic with a specific volume.
- **Operation performed?** This is the crux. The proof states:
  > "$M_{4_1}$ = two regular ideal tetrahedra glued (Thurston's Princeton
  > notes §4)"
- **Is this a geometric operation?** NO. The proof **cites** that such a
  triangulation exists; it does NOT exhibit the face-pairing. The
  Auditor's Probe 1 finding explicitly records: "Thurston's Princeton
  notes §4" — the Explorer did not write down which face pairs with
  which, did not verify the gluing equations, did not check that the
  ideal vertices match. The two ideal tetrahedra are invoked as a name,
  not constructed.
- **If the geometric content is replaced by a citation?** It ALREADY IS
  a citation. The "operation" is an appeal to authority ("Thurston proves
  this decomposition exists"), not a construction.

Per the Fix 3 rubric's "If removed: YES" condition, Step 2's geometric
content is decorative at the Evidence-Field level. The substantive claim
— that $M_{4_1}$ is hyperbolic with volume $\approx 2.03$ — is delivered
by a chain of citations (Thurston triangulation + Lobachevsky formula +
TSV numerical lookup), with no step in the proof doing the triangulation.

### Candidate C: Step 2 — the Lobachevsky volume computation

- **Load-bearing?** Yes, at the numerical level.
- **Operation?** $\Lambda(\pi/3)$ is a special value; $6\Lambda(\pi/3) \approx 2.02988$
  is a numerical evaluation. It's a closed-form arithmetic step once the
  triangulation is given — not a geometric construction.
- **If removed?** YES, the conclusion still goes through via TSV lookup
  of $\mathrm{vol}(4_1)$ alone. The Lobachevsky formula is pedagogical here.

### Evidence Field verdict

The proof has ONE candidate load-bearing geometric operation (the Step 1
orbifold Euler-char computation), but per the Fix 3 "If removed" test,
that operation can be replaced by a citation to Thurston's Seifert
classification without breaking the proof. Step 2's ideal-tetrahedra
argument is **entirely by citation** — the construction is not exhibited.

Under the post-fix rubric, this is precisely the scenario the **6/10 cap**
is designed for: the proof uses geometric language correctly (unlike the
Probe 3 bluff), every citation is load-appropriate, and the proof is
substantive — but no step in the proof **performs** a geometric operation
whose removal breaks the proof. The "If removed: YES" for every candidate
means Evidence Field cannot be filled to exceed 6/10.

---

## Post-fix Axis 5 score

```
Geometric Content: 6/10 × 1.5 = 9/15   [VOCAB-CAP applied]
Evidence:
  - Load-bearing step: Step 1 (orbifold Euler-char = -1/6) — the only
    step performing a geometric arithmetic operation.
  - Operation: compute chi_orb(D^2(2,3)) = 1 - 1/2 - 2/3 = -1/6 and
    feed into Thurston's Seifert-geometry classification.
  - If removed: YES. The proof still goes through by citing Thurston's
    classification directly ("T(2,3) complement is Seifert with negative
    Euler char; hence SL~_2(R) geometry, not H^3"). Step 2's ideal-
    tetrahedra claim is stated by citation to Thurston, not by
    constructing the face-pairing, so Step 2 has no Evidence-Field
    operation.
```

Axis 5: **6/10 → 9/15** (post-fix). Previously 9/10 → 13.5/15 (pre-fix).
Net reduction: **4.5 points** on the 55-point total.

No VOCABULARY-BLUFF warning — the proof is not a bluff. It is a
citation-heavy geometric proof where the Explorer's contribution is
organization and routing rather than construction. The rubric cap is
appropriate: the proof is solid, but it does not exhibit the "geometric
intuition, not just computation" criterion the collaborator asked for.

---

## Expected-vs-observed check

Task brief's expected behavior for Round 0.5 post-fix:
- Axis 5 = 6/10 × 1.5 = 9/15 ✓ (matched exactly — "since Step 2 cites
  ideal-tetrahedra construction rather than constructing it").

Outcome matches.

---

## What this does to the Probe 6 rubric comparison

Using the Probe 6 numbers as baseline:

| | judge.md (40) | judge_ldt.md PRE-fix (55) | judge_ldt.md POST-fix (55) |
|---|---|---|---|
| P0 (Jones) | 30/40 = 75.0% | 36/55 = 65.5% | 36/55 = 65.5% (unchanged; Jones was already 4/10) |
| P0.5 (hyperbolic) | 37/40 = 92.5% | 50.5/55 = 91.8% | **46/55 = 83.6%** (Axis 5: 13.5 → 9) |
| Gap | +7 pts | +14.5 pts | **+10 pts** |

The gap between P0.5 and P0 narrows from 14.5 to 10 points post-fix.
P0.5 still wins, because its Completeness (9/10), Correctness (10/10),
Elegance (9/10), Gaps (9/10) score higher than P0's on the non-Axis-5
axes — which is appropriate. The Axis 5 tightening removes the
inappropriate-vocabulary-reward without inverting the winner.

(This analysis does not retroactively address diagnostic finding 6's
other sub-issues — Axis 3/Axis 5 double-counting, Completeness
insensitivity to citation depth, no reward for flag-and-resolve. Those
remain for a future pass.)

---

## Limitations noted

1. Whether Step 1's orbifold Euler-char computation "counts" as a
   load-bearing geometric operation is a judgment call. A stricter Judge
   could call it arithmetic-on-notation and cap at 4/10. Under the
   rubric as written, 6/10 is the natural cap. This boundary is visible
   and will influence calibration across proofs.

2. The fix does not reward Explorers who STATE that a step is
   "citation-only" vs. Explorers who phrase the same citation as
   their own prose. Both are equally caught at 6/10; neither is
   rewarded for honesty about the gap. A future fix could add a
   "transparency bonus" for explicit `[REF:external,load-bearing]`
   tags.

3. Round 0's Jones proof (P0) is already at Axis 5 = 4/10 pre-fix and
   stays there post-fix. The Evidence-Field mechanism doesn't harm
   legitimately-algebraic proofs, since they never attempted to claim
   geometric content.

*Saved 2026-04-20. Artifact for Fix 3 of the V2.1 LDT diagnostic repair.*
