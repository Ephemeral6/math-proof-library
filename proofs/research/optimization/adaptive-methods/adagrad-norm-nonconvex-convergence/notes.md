# Notes: AdaGrad-Norm Non-Convex Convergence (Ward-Wu-Bottou 2019)

## Proof technique

**Winning route**: Route 1 — Surrogate $b_{k+1}$ substitution.

The core technical move is the exact identity
$$\frac{1}{b_k^2} - \frac{1}{b_{k+1}^2} = \frac{\|g_k\|^2}{b_k^2 b_{k+1}^2},$$
which converts the stochastic quadratic $\|g_k\|^2 / b_k^2$ (not directly summable since $b_k$ is not predictable w.r.t. $g_k$) into $\|g_k\|^2 / b_{k+1}^2$ (summable via the "integral test" log accumulator) plus a controllable correction $\|g_k\|^4 / (b_k^2 b_{k+1}^2)$ which is pathwise bounded by $(G+\sigma)^2 / b_0^2 \cdot \|g_k\|^2 / b_{k+1}^2$ using the a.s. gradient norm bound.

The cross-term $\langle \nabla f_k, g_k - \nabla f_k \rangle / b_k$ is mean-zero conditionally on $\mathcal{F}_k$ because $b_k \in \mathcal{F}_k$ (it depends only on $g_0, \dots, g_{k-1}$). This is the crux of why the *scalar* AdaGrad-Norm admits a clean martingale decoupling — the per-coordinate AdaGrad does not share this convenience without extra work.

## Key steps

1. **Descent lemma** under $L$-smoothness with step $\eta/b_k$.
2. **Decoupling identity**: $1/b_k^2 - 1/b_{k+1}^2 = \|g_k\|^2/(b_k^2 b_{k+1}^2)$ — pure algebra from $b_{k+1}^2 = b_k^2 + \|g_k\|^2$.
3. **Log accumulator**: $\sum_k a_k^2 / B_{k+1}^2 \le \log(B_T^2 / B_0^2)$ via the integral comparison $\int_{B_k^2}^{B_{k+1}^2} du/u \ge a_k^2 / B_{k+1}^2$ (monotone decreasing integrand).
4. **Pathwise envelope**: $b_T \le b_0 + (G+\sigma)\sqrt{T}$ from a.s. bounded increments.
5. **Rate assembly**: $\sum_k \mathbb{E}[\|\nabla f_k\|^2 / b_T] \le \text{const} + O(\log T)/\eta$. Multiplying through by $b_T = O(\sqrt T)$ and dividing by $T$ gives $O(\log T / \sqrt T)$.

## Audit result

PASS on audit round 1. 17/17 steps VALID. 5/5 numerical checks passed (log accumulator, decoupling identity, quadratic bound, envelope, empirical 1D decay). All Judge-flagged minor issues were LOW-severity phrasing, not mathematical errors. No Fix round needed.

## Related results

- **Adam non-convex convergence** (`proofs/research/optimization/adaptive-methods/adam-nonconvex-convergence/`): uses polarization identity and horizon-dependent LR $\alpha_0 T^{-1/4}$ — more complex because of the biased second moment and the per-coordinate adaptivity.
- **AMSGrad non-convex convergence** (`proofs/research/optimization/adaptive-methods/amsgrad-nonconvex-convergence/`): uses the $\hat{v}_{t-1}$ trick to replace the correlated denominator with a predictable one. Conceptually sibling to the surrogate-$b_{k+1}$ move used here.
- **STORM non-convex convergence** (`proofs/research/optimization/stochastic/storm-nonconvex-convergence/`): uses a genuine Lyapunov $\Phi = f + c\|e\|^2$. Attempting the same framing here (Route 3) collapses back to this proof.
- The rate $O(\log T / \sqrt T)$ matches the non-convex SGD rate with known step size up to a $\log T$ factor — the $\log$ is the price of adaptivity.

## Route outcomes (for learning)

- Route 1 (surrogate $b_{k+1}$): **selected**, 38/40.
- Route 2 (direct a.s. bound via ratio $b_{k+1}/b_k$): 38/40, fully valid; chose Route 1 in tiebreaker for cleaner Lemma 3 structure.
- Route 3 (Lyapunov $V_k = W_k + (L\eta^2/2) \sum_{i<k} \|g_i\|^2 / b_i^2$): honestly collapses to Route 1's algebra; Lyapunov is a bookkeeping reorganization, not a new technique.
- Route 4 (online-to-batch via regret): non-convex bridge fails (no free convexity from $\langle \nabla f_k, x_k - u \rangle$); leaves a reusable AdaGrad-Norm regret lemma as a byproduct.
