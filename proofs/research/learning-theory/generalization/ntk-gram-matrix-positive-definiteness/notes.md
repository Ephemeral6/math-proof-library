# Notes: NTK Gram Matrix Positive Definiteness

## Proof technique
Route 4 (Quadratic form + hyperplane arrangement adjacency) won. The key insight is expressing c^T H^∞ c as E[||v(w)||^2] and then using the hyperplane arrangement to extract algebraic conditions that force c=0.

## Key steps
1. Quadratic form = expectation of squared norm (immediate PSD)
2. v(w) = 0 a.s. → algebraic conditions on each sign-pattern cell
3. Adjacent cell lemma: x_k ≠ ±x_j ensures Π_k distinct from Π_j, enabling sign flip of exactly one coordinate
4. Subtraction of adjacent cell equations isolates c_k x_k = 0

## Audit result
PASS on first round. All 7 steps valid. Notes on dimensional generality and antipodal necessity.

## Related results
- NTK theory for deep networks (Du et al. 2019, Allen-Zhu et al. 2019)
- Arc-cosine kernels (Cho & Saul 2009)
- Lazy training regime / infinite-width limits
- Schoenberg's theorem for strictly PD kernels on spheres
