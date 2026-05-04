# Scout — Trefoil vs Figure-Eight Inequivalence

## Step 0: Library / technique / failure-pattern search

**0a. Technique library.** Read `workspace/proof_techniques_ldt.md` (10 seeded entries) and `workspace/failure_patterns.md` (grep `domain: low-dimensional-topology` → **zero matches**; the failure DB has no LDT entries yet).

Relevant listed techniques for this problem:
- §1.1 Skein-relation computation → gives Jones polynomial via Kauffman bracket.
- §1.2 State sum → equivalent path; direct.
- §1.3 Burau representation → gives Alexander polynomial via braid word.
- §1.5 Hyperbolic-volume obstruction → Gromov–Thurston; very clean for 3_1 (non-hyperbolic) vs 4_1 (hyperbolic).

**0b. Library lemma search.** `proofs/library/low-dimensional-topology/**/*.md` — **empty directory** (only README stubs). Zero reusable lemmas.  Out-of-LDT libraries (`proofs/library/statistics/`, etc.) are irrelevant for this problem.

**0c. Application rules.** No technique in this domain has ≥3 uses (library empty), so the 40%-coverage rule is vacuous. No failure patterns to avoid. Scout is free to recommend any route; should favor those TSV can ground-truth check.

## Routes

### Route 1: Jones polynomial inequality (PRIMARY CANDIDATE)

- **Key idea**: Compute $V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}$ and $V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2$, both via the Kauffman bracket from a standard diagram. Since Jones is an ambient-isotopy invariant, unequal polynomials $\Rightarrow$ unequal knots.
- **Required tools**: Kauffman bracket axioms, skein relation, writhe normalization, `[CALL:tsv-knot] jones_polynomial("trefoil")` and `jones_polynomial("figure-eight")`, `lookup_knotinfo(V)`.
- **Estimated difficulty**: easy.  Standard textbook argument.
- **Potential pitfalls**: Sign conventions — right-handed vs. left-handed trefoil have mirror polynomials. Writhe normalization in Kauffman bracket is easy to drop. Need to specify orientation.
- **Reusable B/C lemmas created**: "Jones polynomial of right-handed trefoil", "Jones polynomial of figure-eight", "Kauffman bracket axioms as skein relation" — candidates to archive into `proofs/library/low-dimensional-topology/knot-invariants/`.

### Route 2: Alexander polynomial / determinant inequality

- **Key idea**: Compute $\Delta_{3_1}(t) = t^2 - t + 1$ and $\Delta_{4_1}(t) = t^2 - 3t + 1$ via the Burau representation of braid words $\sigma_1^3$ and $\sigma_1 \sigma_2^{-1} \sigma_1 \sigma_2^{-1}$. Unequal Alexander polynomials (at t=-1: determinants 3 vs 5) $\Rightarrow$ unequal knots.
- **Required tools**: Reduced Burau representation, determinant formula $\Delta(\mathrm{closure}(\beta))(t) = \det(I - \beta) / (1 + t + \cdots)$, `[CALL:tsv-knot] alexander_polynomial(...)`.
- **Estimated difficulty**: easy-medium. The Burau-matrix computation is straightforward for B_2 but the Alexander-normalization factor causes minor bookkeeping.
- **Potential pitfalls**: Normalization (multiply by $\pm t^k$) ambiguous until you fix the convention; dimension mismatch if you forget the $n-1$ dimension reduction for reduced Burau.
- **Reusable lemmas**: "Alexander polynomial of right-handed trefoil"; "Alexander polynomial of figure-eight"; "Burau representation of B_2".

### Route 3: Hyperbolic-volume obstruction (most geometric)

- **Key idea**: $3_1$ is a torus knot $T(2,3)$; its complement is a Seifert-fibered space with no hyperbolic structure.  $4_1$ is hyperbolic with volume $2\Lambda(\pi/3) \approx 2.02988$.  Gromov–Thurston: hyperbolic volume is a topological invariant, so one knot has "volume 0" (non-hyperbolic) and the other has positive volume. Inequivalent.
- **Required tools**: Thurston's hyperbolization for knot complements, torus-knot classification as Seifert-fibered, Mostow rigidity for volume well-definedness, `[CALL:tsv-knot] hyperbolic_volume(...)`.
- **Estimated difficulty**: medium.  The ingredients (Thurston, Mostow) are heavy references, but the final argument is short and geometric.
- **Potential pitfalls**: "Non-hyperbolic $\Rightarrow$ volume 0" is a CONVENTION; rigorous treatments define volume separately. Must state clearly that we compare a number (vol of $4_1$) to a non-number (vol of $3_1$ is undefined) and rely on invariance.
- **Collaborator criterion**: **most geometric route** — directly uses the hyperbolic structure of 4_1's complement. Strongest signal of "geometric intuition" per the LDT checklist item H.
- **Reusable lemmas**: "Hyperbolic volume of 4_1 is 2.02988...", "Torus knots are non-hyperbolic".

### Route 4: Diagrammatic / Reidemeister direct argument

- **Key idea**: Try to show no Reidemeister-move sequence takes a standard 3_1 diagram to a standard 4_1 diagram.
- **Estimated difficulty**: HARD (essentially impossible as a direct argument; this is the question Reidemeister moves were designed to ANSWER, not DECIDE; no upper bound on diagram complexity is known).
- **Potential pitfalls**: Dead-end; Reidemeister moves are undecidable in direct formulation.
- **Verdict**: NOT RECOMMENDED.

## Route prioritization

1. **Route 1 (Jones)** — primary. Shortest, cleanest, and TSV can ground-truth it exactly.
2. **Route 3 (hyperbolic volume)** — secondary. Best geometric content (collaborator criterion). Requires citing Thurston + Mostow as black boxes.
3. **Route 2 (Alexander)** — tertiary. Alternative to Route 1 using a different invariant; good redundancy check.
4. **Route 4 (Reidemeister direct)** — EXCLUDED. Not a viable route.

**Recommendation**: Run Routes 1, 2, 3 in parallel as Explorer×3. Judge will pick the winner. Route 3 is the geometrically-richest; Routes 1 and 2 are algebraic twins.
