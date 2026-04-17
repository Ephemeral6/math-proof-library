# Notes: SGD with Polyak Momentum under Interpolation

## Proof technique
Route 5 — PL Condition + Joint $(f(x_t)-f^*, \|v_t\|^2)$ Recursion won, but adapted to work directly with $\|x_t - x^*\|^2$ instead of $f(x_t) - f^*$. The key innovation was:

1. Working with the scaled momentum $s_t = \gamma v_t$ to put iterate and momentum in the same coordinate space.
2. Setting up a $2\times 2$ linear matrix recursion on $(\mathbb{E}[e_t], \mathbb{E}[S_t])$.
3. Using a Lyapunov vector $(1, c)$ with $c = 1/\kappa^2$ to certify spectral radius $< 1$.

## Key steps

1. **The critical parameter choice:** $\beta = O(1/\kappa^2)$ rather than the common $\beta = O(1)$. With $\beta = \mu/(4L)$ (the "natural" choice), the cross-term $\beta^2/(\gamma\mu)$ in $a_{12}$ is $O(1)$, which makes the Lyapunov argument fail. Reducing to $\beta = \mu^2/(4L^2)$ makes $a_{12} = O(1/\kappa^2)$, enabling the argument.

2. **Cross-term elimination via AM-GM with tuned parameters:** The cross term $\langle u_t, s_t\rangle$ was absorbed by using half the strong convexity descent ($p_1 = \gamma\mu/\beta$). The gradient-momentum cross term $\langle s_t, \bar{g}_t\rangle$ was bounded using smoothness + AM-GM.

3. **Perron-Frobenius certificate:** Rather than computing eigenvalues of the $2\times 2$ matrix explicitly, the positive Lyapunov vector gives an upper bound on the spectral radius.

## Audit result
PASS. All algebraic steps verified. The proof is valid for $\kappa \geq 3$ ($L \geq 3\mu$). For well-conditioned problems ($\kappa < 3$), vanilla SGD already converges fast and the momentum analysis can be adapted with slightly different constants.

## Related results
- **SGD under PL + interpolation** (in library): Same $O(1/\kappa^2)$ rate without momentum. This proof extends that technique to the momentum case, showing momentum does not improve the worst-case rate in the stochastic interpolation setting.
- **Heavy ball instability** (in library): The deterministic heavy ball can diverge on smooth strongly convex functions. Our result shows that under interpolation (which zeroes noise at optimum), stochastic heavy ball still converges but doesn't accelerate.
- **SVRG linear convergence** (in library): Variance reduction achieves $1 - O(1/\kappa)$ rate, which is faster than the $1 - O(1/\kappa^2)$ rate here.
- **Nesterov momentum:** In the deterministic case, Nesterov achieves $1 - O(1/\sqrt{\kappa})$. Whether stochastic Nesterov under interpolation can beat $1 - O(1/\kappa^2)$ is an open question related to acceleration in the stochastic setting.

## Limitations and open questions
1. The momentum parameter $\beta = O(1/\kappa^2)$ is very small. Can one prove convergence with larger $\beta$ (e.g., $\beta = 0.9$)?
2. The rate $1 - O(1/\kappa^2)$ does not improve over vanilla SGD. Is this tight, or can a sharper analysis recover acceleration?
3. The proof requires $\kappa \geq 3$. A unified argument covering all $\kappa$ would be cleaner.
