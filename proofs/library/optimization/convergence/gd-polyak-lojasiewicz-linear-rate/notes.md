# Notes: GD with Polyak-Lojasiewicz Linear Convergence Rate

## Proof technique
Route 1 (Direct Descent Lemma + PL) was selected. The proof is a clean two-step argument: first derive the per-step sufficient decrease from L-smoothness, then plug in the PL condition to convert gradient norm into function gap. All four explored routes succeeded; Route 1 won due to being fully self-contained (includes the descent lemma derivation from scratch).

## Key steps
1. **Descent lemma** (the workhorse): L-smoothness alone gives $f(x_{k+1}) \leq f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2$. This is proved via the fundamental theorem of calculus + Cauchy-Schwarz, requiring zero convexity.
2. **PL substitution**: The PL condition $\|\nabla f(x)\|^2 \geq 2\mu(f(x) - f^*)$ directly converts the gradient norm bound into a function-value contraction.
3. **Factoring**: After substitution, the algebra gives exactly $(1 - \mu/L)$ as the contraction factor.
4. **Iteration**: Simple recursion yields the geometric rate.

## Audit result
PASS on first round. All 4 steps verified VALID. Numerical verification on a quadratic test function (L=10, mu=1) confirmed all inequalities with actual contraction ratio 0.81 well below the predicted bound 0.9. Three LOW-severity observations (finiteness of f*, mu <= L condition, iteration complexity approximation) — none are gaps.

## Related results
- **Strong convexity => PL**: If f is mu-strongly convex, it satisfies mu-PL. So this result generalizes the standard GD convergence for strongly convex functions (proved separately in this library).
- **SGD under PL**: The stochastic version (SGD + PL + interpolation) is proved in `proofs/optimization/stochastic/sgd-pl-interpolation-averaging/`.
- **PL hierarchy**: PL is implied by strong convexity, restricted strong convexity, and the essential strong convexity condition. It implies the error bound condition and the quadratic growth condition (Karimi et al. 2016).
- **Non-convex applications**: PL holds for over-parameterized neural networks near initialization (under NTK regime), making this result relevant to deep learning theory.
- **Proximal extension**: Under PL, proximal gradient descent also achieves linear convergence (Karimi et al. 2016).
