# Theorem 3.5

## Statement
Let $S(p,q,\epsilon)$ be a spiral knot with $p,q \ge 2$ coprime and
$\epsilon \in \{+1,-1\}^{p-1}$. Let $n_+(\epsilon) = \#\{i : \epsilon_i = +1\}$
and $n_-(\epsilon) = (p-1) - n_+(\epsilon)$.
Then:
(i) $S(p,q,\epsilon)$ has Seifert genus
$g = (p-1)(q-1)/2$ if all $\epsilon_i$ agree in sign (torus or
mirror-torus case); otherwise $g \le (p-1)(q-1)/2$ with strict
inequality for "mixed" $\epsilon$.
(ii) The Seifert matrix $V_\Sigma$ admits a block-cyclic form of
$q$ blocks, each of size $(p-1) \times (p-1)$, with block entries
determined by $\epsilon$.

## Source
- Paper: Blackwell, Chen, et al. arXiv:2506.17889
- Location: §3, Theorem 3.5.

## Status
UNPROVEN-HERE

## Usage contract
- Citation tag: [REF:level1:theorem_3_5]
- Fixer may expand Statement verbatim if a step needs the explicit
  block structure.

## Notes
Part (ii) is the load-bearing part for Theorem 4.4 routes that analyze
the Alexander polynomial via $\det(V - t V^T)$. The block-cyclic form
makes the polynomial computable as a $q \times q$ determinant of
$(p-1)$-dimensional blocks.
