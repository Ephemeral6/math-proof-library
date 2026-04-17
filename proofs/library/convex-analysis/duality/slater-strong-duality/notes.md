# Notes: Strong Duality via Slater's Condition

## Proof technique
The winning route (Route 4: Direct Epigraphical Separation) uses the **perturbation function + supporting hyperplane** approach. The key idea is:
1. Define a perturbation function $\phi(u,v)$ that parameterizes how the optimal value changes when constraints are relaxed/perturbed
2. Show $\phi$ is convex and $(0,0)$ is in the relative interior of its domain (this is where Slater's condition enters)
3. Apply the supporting hyperplane theorem to epi$(\phi)$ at $(0,0,p^*)$ to obtain an affine lower bound
4. The affine lower bound's coefficients, when negated, yield dual variables $(\lambda^*, \nu^*)$
5. A beautiful cancellation trick shows $g(\lambda^*, \nu^*) \geq p^*$, which combined with weak duality gives equality

This route won over alternatives because it handles both inequality and equality constraints in a unified framework, avoids subsidiary lemmas, and maintains correct sign conventions throughout.

## Key steps
1. **Convexity of $\phi$**: Standard but essential — uses convexity of $f_i$, $\mathcal{D}$, and linearity of $A$
2. **$(0,0) \in \text{ri}(\text{dom}(\phi))$**: The critical use of Slater's condition. The strict inequality $f_i(\hat{x}) < 0$ gives points in dom$(\phi)$ on both sides of the origin in $u$-coordinates
3. **$\gamma < 0$ in the supporting hyperplane**: Uses the relative interior property to rule out degenerate separation ($\gamma = 0$)
4. **The cancellation trick in Step 8**: For any $x \in \mathcal{D}$: $L(x,\lambda^*,\nu^*) \geq \phi(f(x), Ax-b) + \lambda^{*T}f(x) + \nu^{*T}(Ax-b) \geq p^*$, where the last inequality follows because the perturbation lower bound $(\dagger)$ and the Lagrangian penalty terms cancel exactly

## Audit result
- **Round 1**: PASS (all 9 steps VALID)
- **Issues**: 3 LOW-severity presentational items:
  - Continuity of $f_i$ at Slater point should be stated explicitly
  - $\gamma \neq 0$ argument needs relative topology for non-full-dimensional dom$(\phi)$
  - Non-attainment of $p^*$ should be addressed via closure of epigraph
- No fixes needed

## Related results
- **Weak duality** (used as a building block): $d^* \leq p^*$ always holds for convex problems
- **KKT conditions**: When Slater's condition holds and $p^*$ is attained, the dual attainment implies existence of KKT multipliers
- **Refined Slater's condition**: For affine $f_i$, strict inequality $f_i(\hat{x}) < 0$ is not needed (only $f_i(\hat{x}) \leq 0$). This is because affine functions don't create the "boundary degeneracy" that nonlinear convex constraints can
- **Fenchel-Rockafellar duality**: A generalization of this result in the framework of conjugate duality
- **Perturbation analysis**: The dual variables $\lambda^*, \nu^*$ can be interpreted as sensitivity of $p^*$ to constraint perturbations (local slopes of $\phi$ at the origin)
- **Proximal gradient convergence** (in our library): Uses strong duality implicitly when analyzing dual problems
- **ADMM convergence** (in our library): Relies on strong duality for the augmented Lagrangian reformulation
