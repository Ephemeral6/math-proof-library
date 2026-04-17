# Notes: Fenchel Smoothness-Strong Convexity Duality

## Proof technique
Route 2 (Direct Inequality Manipulation) won. The proof is entirely self-contained, building from the integral representation of smooth functions through cocoercivity to the final duality result.

The key technical device is the **two-point auxiliary test function**: to lower-bound the Bregman residual $B = f(x) - f(y) - \langle \nabla f(y), x-y\rangle$, we evaluate the QUB at center $x$ and convexity at center $y$, both at the auxiliary point $w = x - \frac{1}{L}(\nabla f(x) - \nabla f(y))$. The symmetric construction for $A$ uses $w' = y + \frac{1}{L}(\nabla f(x) - \nabla f(y))$.

## Key steps
1. **Descent Lemma** (QUB): $f(y) \leq f(x) + \langle \nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2$. Proved via integral representation.
2. **Cocoercivity**: $\langle \nabla f(x) - \nabla f(y), x-y\rangle \geq \frac{1}{L}\|\nabla f(x) - \nabla f(y)\|^2$. This is the heart of the proof.
3. **QLB**: $f(y) \geq f(x) + \langle \nabla f(x), y-x\rangle + \frac{1}{2L}\|\nabla f(y) - \nabla f(x)\|^2$. Immediate from cocoercivity.
4. **Strong convexity transfer**: The QLB applied at $(\nabla f)^{-1}(y)$ and $(\nabla f)^{-1}(y')$ gives the strong convexity inequality for $f^*$ via Fenchel-Young.
5. **Converse**: Decompose $f^* = h + \frac{1}{2L}\|\cdot\|^2$, use conjugation to reconstruct QUB for $f$.

## Audit result
PASS. All algebraic steps verified. The proof correctly handles domain issues (stating results on $\text{range}(\nabla f)$ rather than all of $\mathbb{R}^n$). The original problem statement's claim that "$f^*$ has $(1/L)$-Lipschitz gradient" was identified as imprecise: the correct conclusion is $(1/L)$-strong convexity, not Lipschitz gradient (the latter would require strong convexity of $f$).

## Related results
- **Moreau envelope smoothness** (proved in this library): The Moreau envelope $M_\lambda f$ is $(1/\lambda)$-smooth. This is closely related: the Moreau envelope can be expressed via conjugation as $M_\lambda f = f \Box \frac{1}{2\lambda}\|\cdot\|^2$.
- **Strong duality via Slater's condition** (proved in this library): Another duality result in convex analysis.
- **Proximal gradient convergence** (proved in this library): Uses the smoothness-strong convexity duality implicitly when analyzing composite problems.
- The full duality chain: $f$ is $\mu$-strongly convex and $L$-smooth $\Leftrightarrow$ $f^*$ is $(1/L)$-strongly convex and $(1/\mu)$-smooth.
- **Baillon-Haddad theorem** (1977): Cocoercivity of the gradient of a convex function is equivalent to Lipschitz continuity. Our Lemma 2 proves one direction; the other is trivial by Cauchy-Schwarz.
