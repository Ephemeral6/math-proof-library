# Judge — Trefoil vs Figure-Eight Inequivalence

## Inputs

Three Explorer reports:
- `explorer_1_jones.md` — Route 1: Jones polynomial inequality
- `explorer_2_alexander.md` — Route 2: Alexander polynomial / determinant
- `explorer_3_hyperbolic.md` — Route 3: Hyperbolic-volume obstruction

## Scoring rubric (V2 judge protocol)

Four axes, each 0–5:
1. **Correctness** — does the argument actually prove the theorem?
2. **Completeness** — are all steps justified? Any stuck-points?
3. **Elegance** — short, clean, minimal black-box citations?
4. **Verifiability** — TSV coverage, ground-truth anchoring at every key step?

Tiebreaker axis (LDT-specific, from collaborator criterion):
5. **Geometric intuition** — does the proof show what the knots LOOK like, not just compute?

## Route-by-route scores

### Route 1 — Jones polynomial

- **Correctness: 5/5.** Jones polynomials $V_{3_1} = -q^{-4} + q^{-3} + q^{-1}$ and $V_{4_1} = q^{-2} - q^{-1} + 1 - q + q^2$ are distinct Laurent polynomials; Jones is an ambient-isotopy invariant; therefore $3_1 \not\sim 4_1$. Airtight.
- **Completeness: 4/5.** One internal sign-convention stumble at Step 3 (computed mirror polynomial first, then corrected by adopting Lickorish's convention). Flagged explicitly as `[SIGN-CONVENTION]`, but the reader has to trust the TSV cross-check rather than an independent self-recomputation.
- **Elegance: 5/5.** Kauffman bracket → writhe normalization → substitute $A = q^{-1/4}$ → done. Textbook-clean, two invariant computations compared at the end.
- **Verifiability: 5/5.** Four `[CALL:tsv-knot]` checks (kauffman of $3_1$, jones of $3_1$, jones of $4_1$, reidemeister-pair), all returning high-confidence matches. Every key numeric object is anchored.
- **Geometric intuition: 2/5.** State-sum on a diagram is combinatorial. Reader can follow without visualizing the knots.
- **Subtotal (1–4, equal weight): 19/20.**

### Route 2 — Alexander polynomial

- **Correctness: 4/5.** $\Delta_{3_1}(t) = t^2 - t + 1$, $\Delta_{4_1}(t) = t^2 - 3t + 1$, determinants $3 \ne 5$. Logic is sound, BUT Route 2's own derivation of $\Delta_{4_1}$ via Burau did not close (see next axis); the final comparison relies on TSV's value rather than Route 2's own calculation. That is legitimate within the V2 protocol (`[CALL:tsv-knot]` is a first-class verifier) but makes Route 2 less self-contained than Route 1.
- **Completeness: 2/5.** `[STEP-STUCK: normalization]` at Step 3: computed $\det(I - M) = -t^2 + 2t + 1 + 2t^{-1} - t^{-2}$, which did not cleanly divide by $1 + t + t^2$. Explorer punted to TSV. This is an unresolved computational gap.
- **Elegance: 3/5.** The $B_2$ part is crisp (one-line computation); the $B_3$ Burau matrix arithmetic is tedious and had sign/normalization issues. The argument is still textbook-standard but less smooth than Route 1.
- **Verifiability: 5/5.** Three `[CALL:tsv-knot]` checks cover the two polynomials. TSV rescued the stuck step, which is exactly its job.
- **Geometric intuition: 1/5.** Pure algebra. Matrix multiplication over $\mathbb{Z}[t, t^{-1}]$. Almost no topological content visible to the reader.
- **Subtotal (1–4, equal weight): 14/20.**

### Route 3 — Hyperbolic-volume obstruction

- **Correctness: 5/5.** If we accept Thurston hyperbolization, Mostow rigidity, and Gordon–Luecke as black boxes, the argument is airtight: $3_1$'s complement is Seifert-fibered (non-hyperbolic); $4_1$'s is hyperbolic with $\mathrm{vol} \approx 2.02988$; these two classes of 3-manifold cannot be homeomorphic; Gordon–Luecke promotes this to knot inequivalence.
- **Completeness: 3/5.** Three deep black-box theorems cited without proof. Each `[REF:external]` tag is honest — this is the LDT-extension protocol — but the proof's self-containedness score is low. A reader who doesn't already know Thurston/Mostow/Gordon–Luecke cannot follow it to the axioms.
- **Elegance: 5/5.** Despite the heavy references, the final argument is *shorter* than Routes 1 and 2: once the three theorems are granted, the contradiction is a single paragraph.
- **Verifiability: 4/5.** Two `[CALL:tsv-knot]` checks: `hyperbolic_volume("figure-eight") = 2.02988…` and `hyperbolic_volume("trefoil") = None (non-hyperbolic)`. The three black-box theorems are outside TSV scope and carry only `[REF:external]`, not `[VERIFIED:]`. This is honest but means 75% of the proof's load-bearing claims sit on external references.
- **Geometric intuition: 5/5.** Directly engages the geometric structure: one complement *is* hyperbolic (negative curvature, ideal tetrahedra), the other is Seifert-fibered (locally $\mathbb{H}^2 \times \mathbb{R}$ on the base). The distinction is a GEOMETRIC one, not a combinatorial one. Maximally aligned with collaborator criterion H.
- **Subtotal (1–4, equal weight): 17/20.**

## Summary table

| Route | Corr | Compl | Eleg | Verif | Subtotal (1–4) | GeomInt (tiebreaker) |
|-------|------|-------|------|-------|----------------|----------------------|
| 1 Jones | 5 | 4 | 5 | 5 | **19/20** | 2/5 |
| 2 Alexander | 4 | 2 | 3 | 5 | 14/20 | 1/5 |
| 3 Hyperbolic | 5 | 3 | 5 | 4 | 17/20 | **5/5** |

## Decision

**Winner: Route 1 (Jones polynomial).**

**Rationale.** On the V2 rubric (correctness + completeness + elegance + verifiability), Route 1 scores highest (19/20). It is the only route that closes *internally*: every computational step was carried out, double-checked with TSV, and produced the stated answer (modulo a flagged sign-convention resolved by Lickorish's convention). Routes 2 and 3 both have structural weaknesses — Route 2 has an unresolved normalization step that had to be outsourced to TSV; Route 3 leans on three external black-box theorems whose statements exceed this write-up's scope.

**Explicit trade-off flagged for the user.** The collaborator criterion ("geometric intuition, not just computational ability") ranks Route 3 (5/5) well above Route 1 (2/5). If the collaborator criterion is given decisive weight, the winner flips to Route 3. This is a **judgement call** that the V2 rubric does not resolve unambiguously. Per V2 protocol, we default to the main rubric and surface Route 3 as a co-winner in spirit, not in ranking.

**Recommendation for the final proof of record.** Use Route 1 as `best_proof.md`; retain Routes 2 and 3 as `failed_attempts/` and `alternative_route_hyperbolic.md` respectively. When the LDT library matures and the collaborator has evaluated multiple rounds, reconsider whether to promote Route 3 to primary for geometric-intuition problems.

## Handoff to Auditor

Auditor must run:
1. V2 full audit on Route 1 (`explorer_1_jones.md`).
2. LDT checklist (8 items A–H) — expect items A (isotopy vs equivalence), B (orientation), G (picture-proof handling), H (geometric-intuition score) to fire.
3. Step 0.5 reverse-consistency check: does the proof work if we swap $3_1 \leftrightarrow 4_1$? Yes — polynomials still differ; so Step 0.5 is a near-trivial pass.
4. Flag the sign-convention stumble at Step 3 for explicit resolution.
