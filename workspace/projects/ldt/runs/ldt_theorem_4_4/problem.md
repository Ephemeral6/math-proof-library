# Theorem 4.4 (Blackwell et al., arXiv:2506.17889)

## Source
- Paper: Blackwell, Chen, et al. "Spiral knots via braid words" (arXiv:2506.17889)
- Statement location: §4, Theorem 4.4.

## Definitions (fixed here for the pipeline)

**Spiral knot.** For coprime integers $p, q \ge 2$ and a sign sequence
$\epsilon = (\epsilon_1, \ldots, \epsilon_{p-1}) \in \{+1, -1\}^{p-1}$,
the **spiral knot** $S(p,q,\epsilon)$ is the closure of the braid word
$$
\beta(p,q,\epsilon) \;=\; \big(\sigma_1^{\epsilon_1} \sigma_2^{\epsilon_2}
\cdots \sigma_{p-1}^{\epsilon_{p-1}}\big)^q
$$
in the braid group $B_p$.

**Torus knot.** The torus knot $T(p,q)$ equals $S(p,q,\epsilon)$ with
$\epsilon = (+1, +1, \ldots, +1)$ (all $+1$). Equivalently, $T(p,q)$ is
the closure of $(\sigma_1 \sigma_2 \cdots \sigma_{p-1})^q$.

## Statement (to be proven)

**Theorem 4.4.** Let $p, q \ge 2$ be coprime and
$\epsilon \in \{+1, -1\}^{p-1}$. Then
$$
S(p,q,\epsilon) \;\cong\; S(q,p,\epsilon')
\quad\text{for some}\ \epsilon' \in \{+1,-1\}^{q-1}
\quad\iff\quad
S(p,q,\epsilon) \ \text{is a torus knot.}
$$

Here $\cong$ denotes ambient isotopy of oriented knots in $S^3$.

## Allowed background

- Classical knot theory at the level of Lickorish or Kauffman's textbook.
- Alexander polynomial $\Delta_K(t)$ and its standard properties.
- Seifert surface and Seifert matrix.
- Torus-knot Alexander polynomial:
  $\Delta_{T(p,q)}(t) = \frac{(t^{pq}-1)(t-1)}{(t^p-1)(t^q-1)}$.
- Braid-group generators $\sigma_i$ and closure construction.
- Paper-chained lemmas registered in `level1_lemmas/` (see
  `level1_lemmas/README.md`): Theorem 3.5, Corollary 3.10,
  Proposition 4.3.

## Domain tag
low-dimensional-topology

## Difficulty
advanced / research

## Notes
- The "$\Rightarrow$" direction requires showing that any $(p,q)$-swap
  equivalence forces all $\epsilon_i = +1$ (after possible mirror /
  reversal). This is the hard direction.
- The "$\Leftarrow$" direction (torus knot $\Rightarrow$ swap
  equivalence) is classical: $T(p,q) \cong T(q,p)$ is a standard fact
  (see any knot-theory textbook).
