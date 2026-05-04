# Explorer 2 — Route 2: Seifert genus + braid combinatorics

**Route.** Use Theorem 3.5(i)'s torus-iff-max-genus dichotomy together
with direct braid-word manipulation in $B_p$ vs $B_q$.

## Step 0 — Backward direction
Same as Explorer 1 Step 0: if $S(p,q,\epsilon) = T(p,q)$ is torus,
then $\epsilon = (+1,\ldots,+1)$ and $T(p,q) = T(q,p)$ classically.

## Step 1 — Forward direction: genus dichotomy

Assume $S(p,q,\epsilon) \cong S(q,p,\epsilon')$. Seifert genus $g$ is
an ambient-isotopy invariant. So $g(S(p,q,\epsilon)) = g(S(q,p,\epsilon'))$.

By [REF:level1:theorem_3_5](i):
- $g(S(p,q,\epsilon)) = (p-1)(q-1)/2$ iff $\epsilon$ is uniform.
- $g(S(q,p,\epsilon')) = (q-1)(p-1)/2 = (p-1)(q-1)/2$ iff $\epsilon'$
  is uniform.

Four cases:
- **Both uniform**: $\epsilon, \epsilon'$ both uniform → both are
  torus. If $\epsilon = (+1,\ldots,+1)$, $S(p,q,\epsilon) = T(p,q)$
  and we're done. If $\epsilon = (-1,\ldots,-1)$, $S(p,q,\epsilon)$
  is the mirror $T(p,q)^*$; we handle via the mirror convention (the
  theorem statement implicitly quotients by mirror-equivalence or
  takes $\epsilon, \epsilon'$ up to global sign).
- **Both mixed**: $g(S(p,q,\epsilon)) < (p-1)(q-1)/2$ and equal to
  $g(S(q,p,\epsilon'))$. Genus alone does NOT force torus; the two
  knots could be distinct non-torus spirals of equal sub-max genus.
- **One uniform, one mixed**: genus differs — contradicts the
  isotopy-invariance of genus. So this case is IMPOSSIBLE.

The third case eliminates the asymmetric situations. Remaining: both
uniform (handled) or both mixed (UNRESOLVED).

## Step 2 — The "both mixed" case

Same obstacle as Explorer 1 Case B: genus dichotomy rules out
asymmetric uniform/mixed pairs, but cannot distinguish two
sub-max-genus mixed spiral knots.

**Attempt.** Use the block-cyclic Seifert matrix structure from
[REF:level1:theorem_3_5](ii). At parameters $(p,q)$: $q$ blocks of
size $(p-1) \times (p-1)$. At parameters $(q,p)$: $p$ blocks of size
$(q-1) \times (q-1)$. Total matrix dimensions:
- $(p,q)$-matrix: $q(p-1) \times q(p-1)$.
- $(q,p)$-matrix: $p(q-1) \times p(q-1)$.

These are $2g$-dimensional where $g$ is the Seifert genus. For uniform
$\epsilon$, $2g = (p-1)(q-1)$; dimensions match: $q(p-1) = (p-1)q$,
and $p(q-1)$ also equals $(p-1)q$ iff $p(q-1) = q(p-1)$, i.e., $pq - p = pq - q$,
i.e., $p = q$. But $p \ne q$ (coprime distinct). **Contradiction.**

**Wait — let me recheck.** If the Seifert matrix has dimensions
$q(p-1) \times q(p-1)$, its rank-over-$2g$ reading requires
$q(p-1) = 2g$. For uniform $\epsilon$, $2g = (p-1)(q-1)$, so
$q(p-1) = (p-1)(q-1)$, i.e., $q = q-1$, false. **My block-count
interpretation is wrong.**

Re-reading [REF:level1:theorem_3_5](ii): "block-cyclic with $q$ blocks
each $(p-1)\times(p-1)$". This is a statement about a specific
PRESENTATION of the Seifert matrix — not the minimal matrix. A
block-cyclic Seifert matrix of this form has total size $q(p-1)
\times q(p-1)$, but its rank (= $2g$) may be less than its size
(the matrix is Seifert-equivalent to a smaller matrix of rank $2g$).

OK so the size argument doesn't directly give a parameter-swap
contradiction. I need a rank/determinant argument.

**Attempt (rank).** Determinant $\det(V) = \pm 1$ or similar specific
value for spiral knots — check [REF:level1:theorem_3_5](ii). But
(ii) doesn't explicitly say. The paper's §3 likely has $\det(V)$
computed in closed form for the block-cyclic structure; I don't have
this formula.

[STEP-STUCK SP-1] — No closed-form for $\det(V_{\epsilon})$ available
from registered level1 lemmas.

## Step 3 — Alternate attempt: signature

**Signature** $\sigma(K)$ is an ambient-isotopy invariant computable
from the symmetrized Seifert matrix $V + V^T$. For torus knots,
$\sigma(T(p,q))$ is known in closed form. For spiral knots, the paper
likely computes $\sigma$ as a sum over $\epsilon$.

If $\sigma(S(p,q,\epsilon)) \ne \sigma(S(q,p,\epsilon'))$ for all
mixed choices at parameter swap, the mixed case is ruled out.

**Obstacle.** No level1 lemma provides the spiral-signature formula.
[STEP-STUCK SP-2].

## Step 4 — Attempt sub-problem (v2.3 U2)

Candidate: `[SUB-PROBLEM: For $p = 3$, coprime $q \ge 2$ to 3, and
mixed $\epsilon \in \{\pm 1\}^2$ with one $+1$ and one $-1$, no mixed
$\epsilon' \in \{\pm 1\}^{q-1}$ satisfies $S(3,q,\epsilon) \cong
S(q,3,\epsilon')$.]
Strictly smaller because: strictly smaller parameter range — fixes
$p = 3$.
Scope: base case of induction on $p$ + a concrete verification.`

Admissible under U2. BUT resolving this sub-problem still needs the
same missing machinery (spiral-signature formula or spiral-Δ
refinement). A sub-pipeline lite on this would likely also STRATEGIC-
fail, burning the breadth budget.

**Decision**: do not emit the sub-problem. Forward to Judge with
STRATEGIC SP.

## Step 5 — Verdict on Route 2

**STRATEGIC FAILURE on the mixed case**, by the same reason as Route
1. Genus gives a useful REDUCTION (kills the asymmetric-uniform/mixed
case) but not a complete proof.

## Step 6 — Citation profile

- **[REF:level1:theorem_3_5]**(i): Step 1 genus dichotomy (Load-bearing).
- **[REF:level1:theorem_3_5]**(ii): Step 2 block-cyclic structure
  attempted but uninstrumental.
- **L1**: Seifert genus / Alexander polynomial degree relation.
- **L2**: $T(p,q) \cong T(q,p)$ (Step 0).

## Step 7 — SPs

- **SP-1** [severity=HIGH] [type=STRATEGIC]: No closed-form
  $\det(V_\epsilon)$ for block-cyclic Seifert matrices in registered
  level1 lemmas.
- **SP-2** [severity=HIGH] [type=STRATEGIC]: No spiral-signature
  formula in registered level1 lemmas.

Both SPs point at the same underlying issue: missing paper scaffolding
(Lemma 4.1 / 4.2 in Blackwell et al.'s §4).

## Potentially reusable fragments (for Judge cross-pollination)

**Fragment candidate 1** (genus dichotomy reduction): "Under the
$(p,q) \leftrightarrow (q,p)$ swap, the asymmetric case (one uniform,
one mixed $\epsilon$) is ruled out by genus invariance alone.
Equivalently: an isotopy equivalence $S(p,q,\epsilon) \cong
S(q,p,\epsilon')$ requires $\epsilon, \epsilon'$ to be either both
uniform or both mixed."

This is status=verified (the argument is clean), and useful for any
future Route that wants to start by reducing to the symmetric cases.

## Post-hoc reflection

Route 2 gets further than Route 1 in one respect: it explicitly uses
Theorem 3.5(i) to KILL the asymmetric case. But the core mixed-mixed
obstruction is the same. The two routes share the strategic failure.

---

## Available fragments from losing routes (appended by Judge v2.3)

[REUSABLE-FRAGMENT: from=Explorer 1, id=fragment-1]
Statement: If $S(p,q,\epsilon) \cong S(q,p,\epsilon')$ and $\epsilon$ is uniform, then $\epsilon'$ is uniform and both are torus.
Proof sketch: Explorer 1 Step 2 Case A.
Status: verified
Relevance: uniform-arm handler.

[REUSABLE-FRAGMENT: from=Explorer 1, id=fragment-2]
Statement: The current level1 library is insufficient for the mixed case; Blackwell §4 likely contains Lemma 4.1 or 4.2 supplying the missing classification.
Proof sketch: Explorer 1 Step 3.
Status: verified-as-counterexample
Relevance: Tells Fixer/orchestrator not to force-fix Case B with current library.

[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-4]
Statement: At parameters $(p,q)$ the block-cyclic Seifert matrix has size $q(p-1)$; at $(q,p)$ size $p(q-1)$. Different but S-equivalence-reconcilable.
Proof sketch: Explorer 2 Step 2 corrected reading.
Status: unverified
Relevance: Seifert-matrix hook for mixed-mixed analysis.
