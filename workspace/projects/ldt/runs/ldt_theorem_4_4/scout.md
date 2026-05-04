# Scout — Theorem 4.4 (spiral knot (p,q)-swap ⇔ torus)

## 0a. 技巧库检索
Searched `proof_techniques_ldt.md`: "Alexander polynomial via
block-cyclic Seifert matrix" is the dominant pattern for spiral-knot
problems in this corpus. Appears 2x. No prior failure pattern listed.

## 0b. 引理库检索
- Checked `proofs/library/low-dimensional-topology/*/`: no direct
  spiral-knot or Alexander-polynomial-classification proof available.
- Checked `proofs/research/low-dimensional-topology/knot-theory/`:
  README only, no prior spiral-knot proof archived.

## 0b-level1. Level-1 lemma library (v2.3, NEW)
`{work_dir}/level1_lemmas/` EXISTS. Inventory:
- `theorem_3_5.md` — Seifert structure (UNPROVEN-HERE, L2-citable).
- `corollary_3_10.md` — Alexander invariance (UNPROVEN-HERE, L2).
- `proposition_4_3.md` — torus Δ + uniqueness at fixed $(p,q)$
  (UNPROVEN-HERE, L2).

Routes are scored based on how effectively they can leverage these
three paper-chained lemmas.

## 0c. 应用规则
- Block-cyclic Seifert matrix technique appears in 2+ LDT proofs →
  at least one route must use it.
- No failure patterns flagged for spiral knots.

## Route 1: Alexander-polynomial + uniqueness (cite-chain route)
- **Key idea**: If $S(p,q,\epsilon) \cong S(q,p,\epsilon')$, by
  [REF:level1:corollary_3_10] their Alexander polynomials agree. Split
  into cases: $\epsilon$ uniform (= torus) vs $\epsilon$ mixed.
  - Uniform case: $\Delta_{S(p,q,\epsilon)} = \Delta_{T(p,q)} = \Delta_{T(q,p)}$.
    By [REF:level1:proposition_4_3] uniqueness at $(q,p)$,
    $S(q,p,\epsilon') = T(q,p)$. DONE.
  - Mixed case: need to show NO mixed $\epsilon'$ at parameters $(q,p)$
    matches the Δ of a mixed $S(p,q,\epsilon)$. This is where the
    route CRITICALLY depends on a stronger Alexander-polynomial
    classification that is NOT registered in level1.
- **Required tools**: Alexander polynomial arithmetic, level1
  citations, case analysis, possibly block-cyclic determinant
  expansion [REF:level1:theorem_3_5].
- **Estimated difficulty**: medium-hard. The uniform case is clean;
  the mixed case is the research content.
- **Potential pitfalls**: If no L2 result in level1 covers
  "Alexander polynomial distinguishes mixed spiral knots across
  $(p,q)$-swap", the route hits a STRATEGIC SP. May need a sub-
  pipeline (U2) for the missing classification lemma, OR fragment
  extraction from losing routes.

## Route 2: Seifert genus + braid combinatorics
- **Key idea**: Use [REF:level1:theorem_3_5](i): torus iff genus =
  $(p-1)(q-1)/2$, mixed $\epsilon$ ⇒ genus $<$ max. If
  $S(p,q,\epsilon) \cong S(q,p,\epsilon')$, both have equal genus.
  Both being torus (uniform $\epsilon, \epsilon'$) is one case and
  gives the conclusion. Both mixed with equal sub-max genus requires
  a direct braid-combinatorial argument showing no such match is
  possible.
- **Required tools**: Seifert-genus invariance, Theorem 3.5(i), braid-
  word combinatorics in $B_p$ vs $B_q$.
- **Estimated difficulty**: hard. The braid-combinatorial part has no
  level1 support.
- **Potential pitfalls**: Genus equality does NOT force torus for the
  mixed case, so Route 2 degenerates to essentially the same research
  content as Route 1. STRATEGIC risk on the mixed case.

## Route 3: Direct braid-word contradiction
- **Key idea**: Assume $S(p,q,\epsilon) \cong S(q,p,\epsilon')$ with
  mixed $\epsilon, \epsilon'$. Apply Markov's theorem to produce a
  sequence of Markov moves between the two braid closures. Track an
  invariant (e.g., writhe, linking-number with a fiber, etc.) that is
  preserved under Markov moves and distinguishes mixed from uniform.
- **Required tools**: Markov's theorem (L2), braid-group relations,
  invariant construction.
- **Estimated difficulty**: very hard. No level1 support; likely
  requires original construction of the distinguishing invariant.
- **Potential pitfalls**: Markov moves are infinitely many and hard to
  track; without a known invariant, this is essentially a research
  program.

## Route recommendation
**Primary**: Route 1 (cite-chain). Most level1-aligned, cleanest
uniform case. Main risk: mixed case STRATEGIC SP.
**Backup**: Route 2 (genus). Similar risk profile; may provide a
reusable fragment (genus dichotomy) even if the route fails.
**Exploratory**: Route 3 (direct). Low confidence; forward only if
Routes 1/2 both STRATEGIC-fail.

## Route diversity check
Routes 1, 2 share the "level1 + case split" architecture; Route 3 is
structurally different. Acceptable — Route 3 is the diversity card.

## Recommendation to Explorer
Launch Routes 1 and 2 in parallel (Explorer 1, 2). Hold Route 3 in
reserve. Judge will see two cite-chain attempts and decide if a Route
3 launch is warranted.
