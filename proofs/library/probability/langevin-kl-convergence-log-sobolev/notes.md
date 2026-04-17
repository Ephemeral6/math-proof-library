# Notes: Langevin KL Convergence via Log-Sobolev

## Proof technique
Route 1 (Entropy Dissipation: De Bruijn + LSI + Gronwall) won. This is the most direct and standard approach. All four routes (entropy dissipation, Girsanov, semigroup/spectral, Otto calculus) converged to the same core argument.

## Key steps
1. **Fokker-Planck in relative form**: $\partial_t \rho_t = \nabla \cdot (\rho_t \nabla \log(\rho_t/\pi))$ — the evolution is a continuity equation with velocity field $\nabla \log(\rho_t/\pi)$.
2. **De Bruijn identity**: $\frac{d}{dt}\text{KL} = -I(\mu_t \| \pi)$ — entropy dissipation equals negative Fisher information. Derived by integration by parts against the FP equation.
3. **LSI substitution**: Setting $f = \sqrt{\rho_t/\pi}$ converts the abstract LSI into the concrete bound $I \geq 2\alpha \cdot \text{KL}$. The factor of 4 in $|\nabla f|^2$ is crucial.
4. **Gronwall closure**: The differential inequality $H' \leq -2\alpha H$ integrates to exponential decay.

## Audit result
PASS on first round. All 4 steps validated. Only presentation-level issues (boundary terms, regularity assumptions, LSI convention).

## Related results
- The LSI is implied by strong convexity of $V$ (Bakry-Émery criterion: $\nabla^2 V \geq \alpha I$ ⟹ LSI with constant $\alpha$)
- Otto calculus interprets this as gradient flow of KL in Wasserstein space; LSI ⟺ geodesic convexity
- Poincaré inequality (weaker) gives $L^2$ convergence but not KL convergence
- Discrete-time analogue: Langevin Monte Carlo convergence rates
