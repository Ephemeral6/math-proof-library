# Notes: GDA Nonconvex-Strongly-Concave $O(\kappa^2 \epsilon^{-2})$ Convergence

## Proof technique

**Winning route**: Route 1 — Lyapunov $V_t = \Phi(x_t) + c \cdot \delta_t$ with $c = L/(4\kappa)$, $\delta_t = \|y_t - y^*(x_t)\|^2$.

The architecture is the "套路 A + 套路 B" combination: descent lemma on $\Phi$ (for the slow $x$-variable) coupled with contraction of the inner tracking error (for the fast $y$-variable), both wrapped into a single Lyapunov function whose decay isolates $\|\nabla\Phi(x_t)\|^2$.

**Why $c = L/(4\kappa)$, not $c = \kappa^2 L/4$ as the route sketch hinted**: The two Lyapunov constraints derived from the one-step inequality are
- (i) $c \kappa^3 \eta_x \le 1/48$ (so $\delta_t$-coefficient in $x$-descent is absorbed into $\delta_t$-decay)
- (ii) $c/(2\kappa) \ge 32L/(512\kappa^2) \cdot$ (scaling factor) (so the $\|\nabla\Phi\|^2$ margin dominates the $\delta_t$ noise fed by the self-bounded $\|g_t\|^2$)

At $\eta_x = 1/(16\kappa^2 L)$, constraint (i) gives $c \le 3L/(\kappa \cdot ?)$, constraint (ii) gives $c \ge$ small positive. $c = L/(4\kappa)$ satisfies both with slack $29L/(512\kappa^2) > 0$.

## Key steps

1. **Lemma A ($y^*$ is $\kappa$-Lipschitz)**: By strong monotonicity of $\nabla_y f(x,\cdot)$ combined with $L$-Lipschitzness of $\nabla_y f(\cdot, y)$ in $x$:
   $\mu \|y^*(x')-y^*(x)\|^2 \le (\nabla_y f(x, y^*(x')) - \nabla_y f(x', y^*(x')))^\top (y^*(x)-y^*(x')) \le L \|x-x'\| \cdot \|y^*(x)-y^*(x')\|$.
   
2. **Lemma B ($\Phi$ is $2\kappa L$-smooth)**: Danskin $\nabla\Phi(x) = \nabla_x f(x, y^*(x))$, then $\|\nabla\Phi(x')-\nabla\Phi(x)\| \le L(\|x'-x\| + \|y^*(x')-y^*(x)\|) \le L(1+\kappa) \|x'-x\| \le 2\kappa L \|x'-x\|$.

3. **Lemma C ($y$-contraction)**: One step of GD on $F(y) = -f(x_t, y)$ (μ-SC, L-smooth) with $\eta_y = 1/L$. Nesterov co-coercivity gives $(1-2\mu/(\mu+L)) \le (1-\mu/L) = (1-1/\kappa)$ contraction; the $\|\nabla F\|^2$ residual term has nonpositive coefficient $\frac{1}{L^2} \cdot \frac{\mu-L}{\mu+L} \le 0$ and is dropped.

4. **Lemma D ($\delta_t$ recursion)**: Young's splitting with $\alpha = 1/(2\kappa)$ combines the contraction with the drift of $y^*$:
   $\delta_{t+1} \le (1-1/(2\kappa)) \delta_t + 3 \kappa^3 \eta_x^2 \|g_t\|^2$.

5. **Lemma E ($x$-descent)**: By $2\kappa L$-smoothness of $\Phi$, expand $g_t = \nabla\Phi(x_t) + e_t$ with $\|e_t\| \le L\sqrt{\delta_t}$. Young's gives
   $\Phi(x_{t+1}) \le \Phi(x_t) - (3\eta_x/8) \|\nabla\Phi(x_t)\|^2 + \eta_x L^2 \delta_t$.

6. **Lyapunov combination**: $V_t = \Phi(x_t) + (L/(4\kappa)) \delta_t$ gives $V_{t+1} \le V_t - (\eta_x/4) \|\nabla\Phi(x_t)\|^2$.

7. **Telescope**: Sum over $t = 0, \ldots, T-1$ and use $V_0 - V_T \le \Delta + (L/(4\kappa)) \delta_0$.

## Audit result

**Round 1**: 2 MEDIUM cosmetic issues (C₂ μ-absorption, Step 4 citation vs. inline).
**Round 2: PASS.**
- All 9 steps VALID, all numerical checks (κ=2, L=1, μ=1/2) verify.
- Constraint (i): $c \kappa^3 \eta_x = 1/64 \le 1/48$ ✓
- Constraint (ii): $61L/(512\kappa^2) \ge 32L/(512\kappa^2)$ with slack $29L/(512\kappa^2) > 0$ ✓
- Final: $C_1 = 64$, $C_2 = 16$ with convention $\tilde\delta_0 = L \|y_0 - y^*(x_0)\|^2$.

## Related results

- **SAM convergence to flat minima** ([REF: proofs/research/optimization/convergence/sam-convergence-flat-minima/]): same descent-on-$\Phi$ skeleton; SAM uses an ascent step on $y = $ perturbation direction at scale $\rho$, here GDA uses an ascent step on $y = $ dual variable with stepsize $\eta_y = 1/L$.
- **OGDA bilinear last-iterate** ([REF: proofs/research/optimization/convergence/ogda-bilinear-last-iterate/]): Lyapunov approach failed there due to loose cross-terms; here the two-time-scale ratio $\eta_x / \eta_y = 1/(16\kappa^2)$ tames the cross-term via Young's with $\alpha = 1/(2\kappa)$.
- **Extragradient-type corrections (Mokhtari-Ozdaglar-Pattathil 2020)**: achieve $O(\kappa \epsilon^{-2})$ (one factor of $\kappa$ better) by using predictor-corrector structure; GDA without corrections pays the extra $\kappa$.
- **GD linear convergence under strong convexity** ([REF: proofs/library/optimization/convergence/gd-strongly-convex-linear-convergence/]): provides the base template for the $y$-step contraction (Lemma C), here specialized to the inner problem with the co-coercivity refinement to handle the $\eta_y = 1/L$ edge case.
- **Moreau envelope smoothness** ([REF: proofs/library/convex-analysis/subgradient/moreau-envelope-smoothness/]): max-envelope version of the smoothness-transfer argument used in Lemma B.

## Lessons learned

1. **Two-time-scale step-size ratio is intrinsic**: $\eta_x / \eta_y = 1/(16\kappa^2)$ is not a proof artifact — it is dictated by the requirement that the drift $\|y^*(x_{t+1}) - y^*(x_t)\|^2 \le \kappa^2 \eta_x^2 \|g_t\|^2$ be absorbed by the $(1-1/(2\kappa))$ contraction of the inner recursion. Any slower $y$-update or faster $x$-update breaks the Lyapunov descent.

2. **Lyapunov coefficient $c$ is not $O(\kappa^2)$**: The route sketch's hint that $c = O(\kappa^2 L)$ balances the two error budgets is wrong; the correct $c = L/(4\kappa)$ emerges from solving the two constraints explicitly. This is a common trap — the sketch's "dimensional analysis" overshoots.

3. **Route 3 (PL / inner-gap) and Route 1 are equivalent in spirit but not in simplicity**: The inner gap $g_t = \Phi(x_t) - f(x_t, y_t)$ and the tracking error $\delta_t = \|y_t - y^*(x_t)\|^2$ differ by a factor of $\mu/2$ to $L/2$ (both directions). Route 3 introduces an extra unit-conversion that produces a $C_2 = O(\kappa L)$ rather than $C_2 = O(1)$; Route 1 avoids this by working directly with $\delta_t$.

4. **IFT is elegant but unnecessary**: Route 4 derives $\|Dy^*(x)\| \le \kappa$ via the IFT Jacobian formula, but (i) this requires $f \in C^2$, stricter than the $C^{1,1}$ assumption; (ii) the same bound follows from Lemma A's elementary strong-monotonicity argument. IFT is strictly more work for the same result.

5. **Co-coercivity identity is essential at $\eta_y = 1/L$**: The naive bound $\|y_+ - y^*\|^2 \le (1 - \mu\eta_y + L^2 \eta_y^2) \|y - y^*\|^2$ fails at $\eta_y = 1/L$ (the coefficient $L^2 \eta_y^2 = 1$ makes the bound trivial). The co-coercivity refinement (Nesterov Thm 2.1.12) supplies a negative $\|\nabla F\|^2$ term whose coefficient $(\rho^2 - 2\rho/(\mu+L)) \le 0$ at $\rho = 1/L$ cancels the $\|\nabla F\|^2$ noise cleanly. This is the single most subtle step.
