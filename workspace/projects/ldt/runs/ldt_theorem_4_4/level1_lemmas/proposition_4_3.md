# Proposition 4.3

## Statement
Let $p, q \ge 2$ be coprime. The torus knot $T(p,q)$ has Alexander
polynomial
$$
\Delta_{T(p,q)}(t) \;=\; \frac{(t^{pq}-1)(t-1)}{(t^p-1)(t^q-1)}.
$$
Moreover, among spiral knots $S(p,q,\epsilon)$ with the same $(p,q)$,
the torus knot $T(p,q) = S(p,q,(+1,\ldots,+1))$ is the UNIQUE knot with
this Alexander polynomial. (Non-torus $\epsilon$ produce strictly
smaller-genus Seifert surfaces and correspondingly distinct Alexander
polynomials by Theorem 3.5(i).)

## Source
- Paper: Blackwell, Chen, et al. arXiv:2506.17889
- Location: §4, Proposition 4.3.

## Status
UNPROVEN-HERE

## Usage contract
- Citation tag: [REF:level1:proposition_4_3]
- The first sentence is classical (torus-knot Alexander polynomial).
- The second sentence (torus = unique realization at fixed $(p,q)$) is
  paper-specific and is the key handle for Theorem 4.4.

## Notes
The uniqueness clause reduces the Theorem 4.4 forward direction to:
"if $S(p,q,\epsilon) \cong S(q,p,\epsilon')$, then their Alexander
polynomials agree, AND at least one of them (by $(p,q)$ symmetry of the
torus-knot formula) must equal the torus polynomial — whence by
Proposition 4.3 both are torus." This chain works only when the
$(p,q)$-swap of Alexander polynomials is tractable, which Theorem 3.5's
block-cyclic structure provides.
