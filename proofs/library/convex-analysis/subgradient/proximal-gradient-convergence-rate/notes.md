# Notes: Proximal Gradient Method O(1/T) Convergence

## Proof technique
Route 2 (Lyapunov potential) won. The proof's core insight:

The optimality gap upper bound F(x_{t+1}) - F(x*) and the Lyapunov decrease Φ_t - Φ_{t+1} are **the same expression**: (1/(2L))||G_t||² + ⟨G_t, x_{t+1} - x*⟩. This makes the per-step inequality F(x_{t+1}) - F(x*) ≤ Φ_t - Φ_{t+1} immediate by comparison.

## Key steps
1. **Proximal optimality** gives G_t - ∇f(x_t) ∈ ∂g(x_{t+1})
2. **Descent lemma** + **convexity** + **subgradient inequality** combine to bound F(x_{t+1}) - F(x*)
3. **Algebraic identity** on ||x_t - x*||² gives the identical Lyapunov decrease
4. **Monotonicity** F(x_{t+1}) ≤ F(x_t) follows from setting u = x_t (instead of x*) in the same inequality
5. **Telescoping** + monotonicity upgrades sum bound to last-iterate bound

## Audit result
PASS on first round. All steps verified correct. The proof's versatility (inequality (A) holds for any point u) is the key structural feature.

## Related results
- ISTA/FISTA: accelerated proximal gradient achieves O(1/T²) via Nesterov momentum
- Strong convexity: if f is μ-strongly convex, linear convergence rate O((1-μ/L)^T)
- Mirror descent: the Bregman viewpoint (Route 4) generalizes to non-Euclidean geometries
- ADMM: related splitting method for constrained problems
