# Fragment: value-iteration-monotone-bracket

## Statement
For a monotone Bellman-style operator $T_\tau$ that satisfies pointwise $0 \le (T_\tau V)(s) - (TV)(s) \le \tau \log A$ relative to a base operator $T$ with fixed point $V^*$ (e.g., entropy-regularized vs. standard Bellman with $A$ actions and temperature $\tau$):
$$V^* \;\le\; V_\tau^* \;\le\; V^* + \frac{\tau \log A}{1 - \gamma}\,\mathbf{1}.$$

The proof uses **monotonicity** of $T_\tau$ and the **per-step gap** $\tau\log A$ together with a $\gamma$-contraction.

## Proof
**Lower bound** ($V_\tau^* \ge V^*$): Set $V_0 = V^*$, $V_{k+1} = T_\tau V_k$. By induction using monotonicity of $T_\tau$ and $T_\tau V \ge T V$ (single-step gap): $V_k \ge V^*$ for all $k$. Take $k \to \infty$ (Banach fixed-point convergence): $V_\tau^* \ge V^*$.

**Upper bound** ($V_\tau^* \le V^* + \frac{\tau\log A}{1-\gamma}\mathbf{1}$): Let $W := V^* + \frac{\tau\log A}{1-\gamma}\mathbf{1}$. Apply $T_\tau$ to $W$:
$$(T_\tau W)(s) \le (TW)(s) + \tau\log A = V^*(s) + \gamma\cdot\frac{\tau\log A}{1-\gamma} + \tau\log A = V^*(s) + \frac{\tau\log A}{1-\gamma} = W(s),$$
using $TW = TV^* + \gamma \frac{\tau\log A}{1-\gamma}\mathbf 1 = V^* + \gamma\frac{\tau\log A}{1-\gamma}\mathbf 1$ (Bellman equation for $V^*$ and the constant shift). Hence $T_\tau W \le W$. By monotonicity, $T_\tau^k W \le W$, and Banach fixed-point gives $V_\tau^* \le W$. $\square$

## Source
- `proofs/research/optimization/convergence/entropy-regularized-value-iteration/proof.md` — Section (iv) "Approximation Error Bound".

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (bounds approximation error of soft Bellman vs hard Bellman)
- **Potential applications**:
  - Entropy-regularized RL approximation guarantees (soft Q-learning, SAC)
  - Smoothed value-iteration bounds (Mellowmax, generalized log-sum-exp)
  - Discount-factor sensitivity analysis via supersolution arguments
  - Bounding suboptimality of regularized policies vs. unregularized
  - Generic monotone-operator contraction-with-perturbation pattern

## Tags
value-iteration, bellman, monotone, soft-Q, contraction, supersolution
