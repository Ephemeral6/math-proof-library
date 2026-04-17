# Notes: ULA KL Convergence under Log-Sobolev Inequality

## Proof technique

**Winning route**: Route 2 — Girsanov change of measure + KL decomposition.

The key insight is the **path-space decoupling** of the one-step KL error into two independently-controllable pieces:

1. **Langevin contraction piece**: the true Langevin SDE from $x_k$ contracts KL at rate $2\alpha$ via LSI and entropy dissipation $\frac{d}{dt}\mathrm{KL}(\mu_t\|\pi) = -\mathrm{FI}(\mu_t\|\pi) \le -2\alpha\mathrm{KL}$.

2. **Girsanov discretization piece**: the path-KL between ULA's frozen-drift SDE and the true Langevin SDE is
$$\mathrm{KL}(P_{\tilde X}\|P_Y) = \frac{1}{4}\mathbb{E}\int_{kh}^{(k+1)h}\|\nabla f(\tilde X_t) - \nabla f(x_k)\|^2 dt,$$
which by $L$-smoothness and the moment bound $\mathbb{E}\|\tilde X_t - x_k\|^2 \le 2h^2\mathbb{E}\|\nabla f(x_k)\|^2 + 4hd$ becomes $O(L^2 dh^2)$.

The KL chain rule / data-processing step combines them:
$$\mathrm{KL}(\rho_{(k+1)h}\|\pi) \le \mathrm{KL}(\nu_{(k+1)h}\|\pi) + \mathrm{KL}(P_{\tilde X}\|P_Y).$$

Under $h \le \alpha/(4L^2)$, the algebra $e^{-2\alpha h} + L^2 dh^2 \le e^{-\alpha h} + 2L^2 dh^2$ absorbs cleanly, giving a one-step recursion
$$\mathrm{KL}(\rho_{(k+1)h}\|\pi) \le e^{-\alpha h}\mathrm{KL}(\rho_{kh}\|\pi) + 2L^2 dh^2.$$

Telescoping via geometric series (using $1 - e^{-\alpha h} \ge \alpha h/2$ under $\alpha h \le 1$) yields the target.

## Key steps

1. **Coupling** (Setup): Define $\tilde X_t$ (ULA interpolation, frozen drift) and $Y_t$ (true Langevin) on the same Brownian motion, starting at $x_k$.
2. **Girsanov path-KL** (Lemma 1): Apply Girsanov with $\sigma = \sqrt{2}I$ diffusion; the factor $1/4 = \frac{1}{2}(\sqrt{2})^{-2}$ is the correct normalization.
3. **LSI entropy dissipation** (Lemma 2): de Bruijn identity + LSI + Grönwall gives Langevin contraction at rate $2\alpha$.
4. **Moment bound** (Lemma 3): Direct computation on $\tilde X_t - x_k$ plus the standard LSI-gradient bound $\mathbb{E}_\rho\|\nabla f\|^2 \le 2Ld + 4L^2\alpha^{-1}\mathrm{KL}(\rho\|\pi)$.
5. **KL chain rule**: Data-processing inequality on path marginals.
6. **Telescoping**: Geometric sum of the bias over $k$ steps.

## Audit result

- **Round 1 (PASS-WITH-MINOR-ISSUES)**: Mathematical content is sound. The proof actually establishes constant $4$ (not $8$) in the bias term; the target $8$ is achieved with slack. Five minor presentational/rigor issues flagged: (i) Novikov condition sketched rather than proved (e.g., via Beneš criterion); (ii) KL chain rule stated as a "coupling argument" without full two-line lemma; (iii) LSI-gradient bound derivation is loose; (iv) an arithmetic step gives $\frac{1}{2}L^2 dh^2$ but the proof uses $L^2 dh^2$ (in the conservative direction, so harmless); (v) WLOG $\alpha \le L$ reasoning was informal.

## Related results

- **Dalalyan 2017** (strong convexity version): target of this generalization. Strong log-concavity implies LSI (Bakry-Emery), so this result strictly subsumes it.
- **Log-Sobolev inequality** (`proofs/library/statistics/concentration/` — if archived): the core functional inequality used; bounds $\mathrm{KL}$ by $\mathrm{FI}$ with constant $1/(2\alpha)$.
- **Entropy dissipation for Langevin**: the continuous-time decay $\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi) = -\mathrm{FI}(\rho_t\|\pi)$ is a classical fact (de Bruijn / Jordan-Kinderlehrer-Otto gradient flow perspective).

## Lessons learned (for future SDE-based sampling proofs)

1. **Girsanov + coupling beats pathwise drift comparison**: When comparing two SDEs with different drifts, Girsanov's theorem gives a clean exact path-KL formula, while trying to compute pathwise $\mathbb{E}\|\tilde X_t - Y_t\|^2$ directly introduces cross-terms and requires delicate Grönwall argument.

2. **LSI is "Poincaré plus exponential tails"**: A log-Sobolev inequality is strictly stronger than Poincaré. It gives geometric (not just polynomial) convergence of the Fisher information under entropy dissipation. The $\alpha$-LSI constant exactly matches the contraction rate.

3. **Step-size $h \le \alpha/(4L^2)$ is optimal for the absorption**: Smaller $h$ gives smaller bias but slower convergence; the constraint $h \le \alpha/(4L^2)$ is the "largest safe" step size ensuring the discretization bias $O(L^2 dh^2)$ can be absorbed by the residual $(e^{-\alpha h}-e^{-2\alpha h}) = \alpha h e^{-\alpha h} \cdot (1+O(h))$ in the one-step recursion.

4. **The $hd L^2/\alpha$ bias is irreducible for ULA**: This matches the $W_2$ bias known for Euler-Maruyama schemes; improving requires MALA (Metropolis-adjusted) or higher-order discretizations (Langevin Monte Carlo with midpoint rule, etc.), which yield $O(h^2 dL^2/\alpha)$ bias but require more assumptions.
