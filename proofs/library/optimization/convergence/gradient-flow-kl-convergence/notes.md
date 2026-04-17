# Notes: Gradient Flow KL Convergence Rates

## Proof technique
The winning route combines Route 2's desingularizing function composition (for the universal finite-length result) with Route 3's direct ODE comparison principle (for explicit convergence rates). The key reduction is: KL + gradient flow yields the scalar differential inequality $\dot{E} \leq -\kappa E^{2\theta}$, which is then compared against its equality counterpart solved in closed form.

## Key steps
1. **Energy dissipation**: $\dot{E} = -\|\nabla f\|^2$ (chain rule along gradient flow)
2. **KL lower bound**: $\|\nabla f\| \geq E^\theta / [c(1-\theta)]$ (rearrangement of KL inequality)
3. **Scalar ODE**: $\dot{E} \leq -\kappa E^{2\theta}$ (combining steps 1 and 2)
4. **Desingularizing trick**: $\Phi = c E^{1-\theta}$ satisfies $\dot{\Phi} \leq -\|\dot{x}\|$, giving finite trajectory length
5. **Comparison principle**: $E(t) \leq y(t)$ where $y$ solves $\dot{y} = -\kappa y^{2\theta}$ exactly
6. **Closed-form solutions**: Different regimes of $2\theta$ relative to 1 yield linear, exponential, or polynomial decay

## Audit result
PASS with no critical issues. Two minor presentational notes: (1) the exponential bound for $\theta \in (0,1/2)$ could be stated more cleanly (finite-time convergence trivially implies any exponential bound); (2) the $t_0$-to-$t$ shift in the polynomial case uses $t - t_0 \geq t/2$, which is correct but slightly ad hoc.

## Related results
- **Discrete analogue**: The same trichotomy holds for proximal point algorithms and descent methods under KL (Attouch, Bolte, Svaiter 2013)
- **PL inequality**: The Polyak-Łojasiewicz condition corresponds to KL with $\theta = 1/2$, recovering the well-known linear convergence of GD under PL
- **Analytic functions**: Real-analytic functions satisfy KL with $\theta \in [0, 1)$ (Łojasiewicz 1963), so gradient flow on analytic functions always converges
- **Semi-algebraic functions**: Semi-algebraic functions satisfy KL (Kurdyka 1998; Bolte et al. 2007), with $\theta$ computable from the function's algebraic structure
- **Non-smooth extension**: Bolte, Sabach, Teboulle (2014) extend the KL convergence framework to proximal gradient methods for non-smooth composite optimization
- **Connection to GD convergence**: For $\theta = 0$ (sharp minima), the finite-time result connects to finite identification of active constraints in polyhedral optimization
