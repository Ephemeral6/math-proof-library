# Proof Route 4: Characteristic Polynomial + 1D Construction

## Route Failure Report
- Route: Characteristic Polynomial + Explicit 1D Counterexample
- Part 1: Succeeded (equivalent to Route 1)
- Part 2: Failed at: Counterexample construction
- Obstacle: Simple 1D piecewise constructions (piecewise quadratic, smoothstep-based) converge for all tested initial conditions in the 1D setting. The piecewise quadratic function f(x)=L/2*x^2 for x>=0, mu/2*x^2 for x<0 converges for all kappa values tested. The smoothstep-based construction also converges. Only the log-cosh construction (Route 3) produces divergence. The key insight is that the curvature profile matters: having LOW curvature at the origin and HIGH curvature far away (as in the log-cosh function) is essential for creating the resonance that sustains the limit cycle.
