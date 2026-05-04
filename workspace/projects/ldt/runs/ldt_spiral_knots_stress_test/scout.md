# Scout — Spiral-knot Alexander polynomial and genus

## Step 0 — Library / technique / failure survey

- **Technique dictionary** `proof_techniques_ldt.md` (10 seeded items): the only
  directly relevant item is **1.3 Burau representation → Alexander polynomial**
  (formula $\Delta_{\widehat\beta}(t) = \det(I - \overline\rho(\beta)) / (1 + t +
  \cdots + t^{p-1})$ up to units). Items 1.1 (skein), 1.2 (state sum / Kauffman
  bracket), 1.4 (HOMFLY specialization), 1.5 (hyperbolic volume) are partially
  relevant — only for small-case cross-checks, not a general proof. No technique
  dictionary entry for "Seifert surface genus bound from a concrete surface",
  "block/circulant determinant factorization", "fibered-knot monodromy", or
  "Alexander polynomial degree bound for $2g$". The dictionary flags this as
  `[TECHNIQUE-NEW]` territory.
- **Library** `proofs/library/low-dimensional-topology/`:
  - `knot-invariants/jones-trefoil-right.md` — right-trefoil Jones (reference for
    TSV cross-check of $S(2,3,(+1))$ and $S(3,2,(+1,+1))$).
  - `knot-invariants/jones-figure-eight.md` — $4_1$ Jones (cross-check for
    $S(3,2,(+1,-1))$).
  - `knot-invariants/kauffman-bracket-axioms.md` — skein axioms.
  - `braid-group/README.md` — placeholder only; no verified Burau formula yet.
  - No Seifert-surface, Seifert-matrix, or genus-breadth lemma is archived.
- **Failure patterns**: `grep -A6 "domain: low-dimensional-topology"` returns
  only the Fix-1 `FP-KAUFFMAN-CONVENTION-2026-04-20` (convention bug). No prior
  failure related to Burau normalization or Seifert-matrix construction has been
  recorded yet — so there is no prior to inherit.
- **Similar archived proofs**: searched `proofs/research/` and `proofs/library/`
  — no spiral-knot proof, no $T(p,q)$ torus-knot Alexander proof, no fibered-knot
  monodromy argument. The closest analogue (Round 0.5 hyperbolic dichotomy) is
  orthogonal to this problem.

### Implications for routing

Because the current LDT library is thin and the seed dictionary has **one**
technique that reaches the statement of Theorem 3.5 (namely 1.3 Burau → Alexander),
the Scout cannot honestly propose 5 library-rooted routes. At least two routes
will be `[TECHNIQUE-NEW]` — the Scout names the techniques explicitly so the
Auditor can tag them.

---

## Route A — Reduced Burau on a cyclic braid word + eigenvalue factorization

- **Key idea**: By the Burau formula (dictionary 1.3),
  $$\Delta_{\widehat{\beta}}(t) \;\doteq\; \det(I_{p-1} - \overline\rho(\beta)) \;/\; \Phi_p(t)$$
  where $\Phi_p(t) = 1 + t + \cdots + t^{p-1}$ and $\doteq$ means equality up to
  $\pm t^k$. Let $B := \overline\rho(\sigma_1^{\epsilon_1} \cdots
  \sigma_{p-1}^{\epsilon_{p-1}})$, so $\overline\rho(\beta) = B^q$. The
  crucial factorization is
  $$\det(I - B^q) \;=\; \prod_{\ell=0}^{q-1} \det(I - \zeta_q^\ell\, B),
  \qquad \zeta_q = e^{2\pi i/q},$$
  derivable from $1 - x^q = \prod_\ell (1 - \zeta_q^\ell x)$ applied to the
  eigenvalues of $B$. One factor ($\ell = 0$) cancels against the Burau
  denominator $\Phi_p(t)$, leaving $\prod_{\ell=1}^{q-1} \det(I - \zeta_q^\ell B)$
  up to units.
- **Required tools**:
  - (i) Dictionary item 1.3 Burau → Alexander formula (used as stated; verify
    convention against `proofs/library/.../conventions.md §1.3`).
  - (ii) Reduced Burau matrix of the word $\sigma_1^{\epsilon_1} \cdots
    \sigma_{p-1}^{\epsilon_{p-1}}$ is **tridiagonal** in the standard basis.
    (Claim to verify inside Explorer.)
  - (iii) Tridiagonal characteristic-polynomial recursion $p_k = \alpha_k
    p_{k-1} - \beta_k p_{k-2}$ — a C-class library result from linear algebra.
  - (iv) $1 - x^q = \prod (1 - \zeta^\ell x)$ factorization (C-class).
  - (v) TSV base-case cross-checks: $(p,q,\epsilon) = (2,3,(+1)),
    (3,2,(+1,+1)), (3,2,(+1,-1))$.
- **Estimated difficulty**: **hard**. The structural claim (ii) that the
  reduced Burau of the cyclic word is tridiagonal is non-trivial, and the
  identification of $C_{p-1}(x,t)$ with the characteristic polynomial
  $\det(xI - B)$ up to the right variable change needs care.
- **Potential pitfalls**:
  - Burau normalization: reduced vs. unreduced, the denominator form, signs of
    generators.
  - The eigenvalue factorization assumes $B$ is diagonalizable — for generic
    $\epsilon$ it is, but edge cases exist and are not in scope.
  - Convention drift: the problem statement's $\mu(i) \in \{1, t\}$ must be
    aligned with the chosen Burau convention (e.g., Birman–Weinberg in
    `conventions.md §1.3`).
- **Genus as corollary**: Theorem 4.2 upper bound $(p-1)(q-1)/2$ follows from
  Seifert's algorithm applied to the braid closure diagram (crossings $c =
  (p-1)q$, Seifert circles $= p$, so genus of the Seifert surface is
  $(c - p + 1)/2 = ((p-1)(q-1))/2$). Lower bound $2g \ge \deg \Delta$ from
  Theorem 3.5 (C-class: breadth bound). This two-sided argument requires
  Theorem 3.5 as input.

## Route B — Direct Seifert-matrix construction from the braid closure diagram

- **Key idea**: Skip the Burau black box. Exhibit the Seifert surface $F$
  produced by Seifert's algorithm on the closed-braid diagram and compute its
  Seifert matrix $M$ directly. The surface has $p$ Seifert circles (= $p$
  disks) and $(p-1)q$ twisted bands (one per crossing). Choose a basis of
  $H_1(F)$ adapted to the $q$-fold cyclic structure: one "cycle" per band,
  decomposed into $q$ groups of $p-1$. In this basis the Seifert form $V(a,b) =
  \mathrm{lk}(a^+, b)$ is (hopefully) block tri-diagonal with a $q \times q$
  circulant block structure indexed by the iteration. Then compute
  $\det(M - tM^T)$ by block-circulant diagonalization via roots-of-unity
  substitution, recovering the product formula.
- **Required tools**:
  - Seifert's algorithm (`[REF:external]`, depth-L1 per the checklist if we
    treat it as 30-s-verify; L2 if we treat it as a cited theorem).
  - Linking-number calculation for Seifert circle diagrams — **combinatorial
    and explicit**.
  - Block-circulant determinant identity: $\det(\text{circ}(A_0, \ldots, A_{q-1}))
    = \prod_{\ell=0}^{q-1} \det(\sum_k \zeta_q^{\ell k} A_k)$ (linear-algebra
    C-class, but not yet in library).
  - TSV base-case cross-checks.
- **Estimated difficulty**: **hard** (may slip to **very hard**). Writing down
  the correct Seifert matrix is error-prone; the basis choice determines
  whether the block structure appears cleanly.
- **Potential pitfalls**:
  - Linking-number signs: Seifert circles in braid closure diagrams have a
    standard orientation convention that must be pinned down before computation.
  - The Seifert form is not symmetric; $M \ne M^T$; the Alexander polynomial is
    sensitive to this.
  - Without a pre-chosen basis (the paper's "cake" homology basis is the right
    one but we do not have access to it), the block structure may not appear
    cleanly — Explorer may end up chasing a messy $(p-1)q \times (p-1)q$
    determinant.
- **Genus as corollary**: Same as Route A — upper bound from the exhibited
  Seifert surface, lower bound from $\deg \Delta$.
- **Technique tag**: `[TECHNIQUE-NEW]` — not in the seed dictionary. If
  successful, adds "block-circulant Seifert matrix diagonalization" to the
  technique dictionary.

## Route C — Skein / state-sum computation for small $(p,q)$, extrapolate by
induction on $q$

- **Key idea**: For fixed $p$, relate $\Delta_{S(p, q, \epsilon)}$ to
  $\Delta_{S(p, q-1, \epsilon)}$ via a skein relation applied at the "seam"
  between the last iteration and the rest. The cyclic structure suggests a
  recursion on $q$ with $p-1$ variables controlling the seam crossings.
- **Required tools**:
  - Conway / Alexander skein relation:
    $\Delta_{L_+}(t) - \Delta_{L_-}(t) = (t^{1/2} - t^{-1/2}) \Delta_{L_0}(t)$
    (C-class, standard).
  - Induction on $q$ with a strengthened hypothesis.
  - TSV base-case cross-checks.
- **Estimated difficulty**: **very hard**. The skein at the seam produces
  diagrams that are not themselves spiral knots, so a closed inductive
  hypothesis must allow for more general braid closures. The "intermediate
  diagrams" are likely to proliferate into an open class that the induction
  cannot close.
- **Potential pitfalls**:
  - Non-closed skein family: failing to preserve spiral-knot form means the
    induction will require a far larger class of knots, and the theorem will
    not apply directly to the intermediate steps.
  - This route tends to produce a "works for small $p$ only" partial result.
- **Not dictionary**: same partial coverage as 1.1 (skein).

---

## Route ranking

| Rank | Route | Difficulty | Library support | Dictionary coverage |
|------|-------|------------|------------------|---------------------|
| 1    | A (Burau + eigenvalue factorization) | hard | partial (1.3) | 1.3 + new |
| 2    | B (direct Seifert matrix + block-circulant) | hard–very hard | none | `[TECHNIQUE-NEW]` |
| 3    | C (skein induction on $q$) | very hard | partial (1.1) | 1.1 + new |

A is the most promising because it leverages the one dictionary item that
speaks directly to Alexander-of-braid-closure. B is geometrically the most
satisfying (and likely the paper's intended route, though Scout has no access
to the paper), but requires more infrastructure that the current library
does not provide. C is a fallback and is unlikely to close cleanly.

## Honest disclosure

- Three of the five seeded dictionary techniques (1.1, 1.2, 1.5) are
  effectively useless for this problem: state-sum and skein don't scale to
  arbitrary $(p, q)$, and hyperbolic volume isn't defined without
  geometrization of the specific complement (which doesn't factor the
  Alexander polynomial).
- Both Route A and Route B rely on results (tridiagonal char-poly recursion,
  block-circulant determinant, Seifert-matrix linking-number calculation) that
  are folklore / standard linear algebra but are **not** in the current
  library. The Explorer must either prove them inline (increasing Independent
  step count) or tag them `[REF:external]` at the appropriate L-depth.
- Route A's genus corollary depends on both the Alexander-polynomial upper
  bound on genus (`2g \ge \deg \Delta`, standard lemma, C-class) and on
  Seifert's algorithm counting correctly — both need to be present in the
  final proof.
- If Route A stalls at the identification $C_{p-1}(x,t) = \det(xI - B)$
  (i.e., the recursion matches but the sign/variable convention does not),
  this is a likely stuck point and should be flagged early.
