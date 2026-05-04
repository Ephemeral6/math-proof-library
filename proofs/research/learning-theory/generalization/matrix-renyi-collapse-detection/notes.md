# Notes: Matrix Rényi entropy and representation collapse detection

## Proof technique

- (a),(b): **Spectral reduction** to classical Rényi entropy on the simplex Δ^{n-1}, then
  - (a) elementary: x^α-vs-x crossing analysis (the only fixed points are 0, 1);
  - (b) Jensen on the strictly convex/concave power function x ↦ x^α.

- (c): **Lyapunov / entropy-PL** technique on the PSD manifold. Three ingredients:
  1. Chain rule: explicit Frobenius gradient ∇_K S_α = (α/((1-α) tr K^α)) K^{α-1} and trace-free part R(K).
  2. Identity: dS_α/dt = -(2/τ) ⟨R(K) F, ∇_F L⟩, exact.
  3. Polyak–Łojasiewicz on entropy: G(K) ≤ (1/(2α) + O(ε)) ||R K^{1/2}||² on ε-neighborhood of I/n.

## Key steps

- The local Taylor expansions (around δ_i = 0):
  - G(K) = (α/(2n)) Σ δ_i² + O(||δ||³)
  - ||R(K) K^{1/2}||² = (α²/n) Σ δ_i² + O(||δ||³)
- These give the PL constant 1/(2α) at leading order.
- Conversion ||R F||² = τ ||R K^{1/2}||² lets us pass between F-gradient and K-gradient norms.

## Audit result

Single round, no fixer:
- SymPy verified Tests 1–4 (forward and reverse direction of (a), (b), Taylor coefficient).
- NumPy gradient flow on n=4 verified monotonicity for α ∈ {0.5, 2, 3} (0 violations / 199 steps).
- Z3 verified the polynomial PL inequality at α=2, n=2, |δ| ≤ 1/2 (tight at boundary).

## Honesty caveats

- **Hypotheses (H1)–(H3) are explicit** for part (c). The literal statement "for the SimCLR loss" is not provable without specifying L_MSSL. Concrete losses like L = ||K - I/n||²/2 (Barlow-Twins-like) provably satisfy (H1)–(H3); the proof is robust to this choice but depends on the specific structure.
- The constant c in the conclusion depends on the neighborhood radius ε and approaches 2 c₀/(α) (with c₀ from (H2)+(H3)) as ε → 0. The PL constant 1/(2α) is sharp as a leading-order constant.
- For 0 < α < 1, K must be full-rank along the trajectory.

## Related results

- Classical Rényi entropy theory (Bobkov–Ledoux for entropy-PL inequalities).
- Bures-Wasserstein metric on the manifold of PSD matrices (the natural metric for which dS_α/dt analysis simplifies).
- Connection to von Neumann entropy: lim_{α → 1} S_α(K) = -tr(K log K).
- Matrix-SSL / Barlow-Twins line of work on diagnosing collapse via spectral entropy.
- Polyak–Łojasiewicz framework for convergence of gradient flows in non-convex problems.
