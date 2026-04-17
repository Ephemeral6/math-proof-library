# Notes: SGD with Stochastic Polyak Step-size Convergence

## Proof technique
Route 1 (Descent Lemma + Telescoping Sum) won. All three routes converged to the same core argument: squared distance recursion with SPS substitution. The key insight is that the SPS step size creates a natural cancellation between the gradient inner product and the quadratic penalty term.

## Key steps
1. The SPS substitution $\gamma_k^2\|\nabla f_i\|^2 = \gamma_k f_i/c$ simplifies the squared distance expansion elegantly
2. The interpolation condition $f_i(x^*) = 0$ is essential — it makes the convexity bound $\langle \nabla f_i, x_k - x^*\rangle \geq f_i(x_k)$ clean
3. The L-smoothness gradient domination $\|\nabla f_i\|^2 \leq 2Lf_i$ provides the uniform lower bound $\gamma_k \geq 1/(2cL)$

## Audit result
PASS on first round. All 7 steps valid. Medium notes: strong interpolation assumption and implicit non-negativity of f_i.

## Related results
- Classical Polyak step-size for deterministic GD
- AdaGrad-style analyses (similar adaptive step-size structure)
- SPS_max variant with clipped step sizes (Loizou et al., 2021)
- Connection to the Polyak-Łojasiewicz condition under interpolation

## Constant discrepancy
The proven bound is $2cL/T$, while the problem stated $cL/(2T)$. The factor-of-4 gap is inherent to the standard proof technique using $\|\nabla f_i\|^2 \leq 2Lf_i$. The tighter constant may use a different L-smoothness convention.
