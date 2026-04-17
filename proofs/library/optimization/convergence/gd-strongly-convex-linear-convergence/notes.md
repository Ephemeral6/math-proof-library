# Notes: Gradient Descent Linear Convergence for Strongly Convex Functions

## Proof technique
The winning proof combines two complementary approaches:
- **Part (a)**: Descent Lemma + PL Inequality route. This is the most natural and textbook-standard approach. The descent lemma provides sufficient decrease per step, and the Polyak-Lojasiewicz inequality (derived from strong convexity) converts gradient norm lower bounds into function gap lower bounds.
- **Part (b)**: Interpolation Inequality route (via Baillon-Haddad theorem). The direct iterate analysis requires the stronger interpolation inequality for the function class $\mathcal{F}_{\mu,L}$, which gives a tighter contraction rate $(\kappa-1)/(\kappa+1)$ that implies the claimed $(1-1/\kappa)$ rate.

Route 1 alone gives part (a) sharply but only part (b) with a $\kappa$ prefactor. Route 2 alone gives part (b) sharply but only part (a) with a $\kappa$ prefactor. The combination gives both parts with sharp rates.

## Key steps
1. **Descent lemma from L-smoothness**: $f(x_{k+1}) \leq f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2$
2. **PL inequality from strong convexity**: $\|\nabla f(x)\|^2 \geq 2\mu(f(x) - f(x^*))$ (derived by minimizing the strong convexity lower bound over $y$)
3. **Interpolation inequality for $\mathcal{F}_{\mu,L}$**: Derived via Baillon-Haddad applied to $g = f - (\mu/2)\|\cdot\|^2$
4. **Rate comparison**: $\frac{L-\mu}{L+\mu} \leq 1 - \frac{\mu}{L}$ to convert the tighter iterate rate to the claimed form

## Audit result
PASS on first round. All 7 steps verified VALID. Four critical algebraic manipulations verified by SymPy. Only 3 LOW severity presentational notes (edge case L=mu, Baillon-Haddad cited not proved, minor clarity in PL derivation).

## Related results
- **Nesterov accelerated GD**: Achieves $(1 - \sqrt{\mu/L})^k$ rate, which is optimal for first-order methods on $\mathcal{F}_{\mu,L}$
- **Nesterov's first-order lower bound**: $\Omega((\kappa-1)/(\kappa+1))^k$ lower bound matches the iterate contraction we derived
- **PL condition**: The PL inequality alone (without strong convexity) suffices for function value linear convergence; this is strictly weaker than strong convexity
- **Proximal gradient method**: Same rate applies when $f = g + h$ with $g$ smooth strongly convex and $h$ convex (proximal operator)
- **SGD on strongly convex**: Achieves $O(1/(\mu k))$ rate with decreasing step sizes (no linear convergence due to noise)
