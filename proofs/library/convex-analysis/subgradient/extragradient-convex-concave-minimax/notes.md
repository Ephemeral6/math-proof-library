# Notes: Extragradient Convex-Concave Minimax Convergence

## Proof technique
Route 2 (VI Reformulation) won. The proof uses:
1. Reformulation as variational inequality with monotone operator F
2. Projection variational inequality applied to BOTH extrapolation and update steps
3. The key EG cancellation: ‖z^k - z^{k+1}‖² terms from the two steps cancel exactly
4. Young's inequality + Lipschitz to control the remaining cross terms
5. Convexity-concavity converts operator inner products to gap function values
6. Jensen's inequality on averaged iterates + telescoping

## Key steps
1. **The EG cancellation**: This is THE insight. The update step gives -‖z^k - z^{k+1}‖² and the extrapolation step gives +‖z^k - z^{k+1}‖². These cancel, leaving only the Lipschitz error which is absorbed when η ≤ 1/L.

2. **Three versions of the bound**: The proof carefully distinguishes:
   - Per-comparator: f(hat_x, y_u) - f(x_u, hat_y) ≤ ‖z⁰-u‖²/(2ηK) for any u
   - Full gap: Gap ≤ D²/(2ηK) where D = sup_u ‖z⁰-u‖ (needs bounded Z)
   - Saddle-point residual: uses ‖z⁰-z*‖² only

3. **Why EG and not GDA**: Standard gradient descent-ascent (GDA) does NOT converge for general convex-concave problems. The extrapolation step is essential — it "looks ahead" to stabilize the updates.

## Audit result
- Round 1: PASS WITH REVISIONS (D² definition needed clarification)
- Round 2: PASS

## Related results
- Korpelevich 1976: Original extragradient method
- Nemirovski 2004: Mirror-prox extension
- The O(1/K) rate is optimal for first-order methods on smooth convex-concave minimax
- Optimistic GDA achieves the same rate with only one gradient evaluation per step
