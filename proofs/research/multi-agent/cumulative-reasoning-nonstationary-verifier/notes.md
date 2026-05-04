# Notes: Cumulative Reasoning under Non-Stationary Verifier

## Proof technique

**Winning route**: Direct product bound + integral test approximation of $\sum \varepsilon_t$.

The whole problem reduces to estimating
$$S_T = \sum_{t=1}^T \varepsilon_0(1+t/T_0)^\alpha$$
and $Q_T = \sum \varepsilon_t^2$. The integral test gives the sharp two-sided sandwich
$$\int_0^T f \le S_T \le \int_0^T f + f(T) - f(0),$$
and the closed form $\int_0^T (1+s/T_0)^\alpha ds = \frac{T_0}{\alpha+1}[(1+T/T_0)^{\alpha+1}-1]$ converts everything into elementary expressions.

## Key steps

1. **The integral closed form** (algebraic) is the keystone — verified by SymPy.
2. **The two-sided integral test** $\int \le \sum \le \int + (f(T)-f(0))$ is what makes the constants explicit. Audit Round 3 caught a bug where I omitted $-f(0)$.
3. **Quadratic correction** $Q_T \le \varepsilon_T S_T \le S_T/2$ accounts for $\log(1-x) = -x - x^2/2 - ...$.
4. **Strict concavity** of $\Phi(T) = \beta\log T - \int \varepsilon_0(1+s/T_0)^\alpha$ guarantees unique optimum in (d).

## Audit result

3 audit rounds. Round 1 caught looseness in constants and the ambiguous interpretation of part (b). Round 2 (re-verification) detected a bug in the "tightened bound" for (a) where $f(0)$ correction was omitted; this falsified the ostensible bound. Round 3 corrected the bound to $\log P_T \ge -S_T - Q_T$ with $S_T \le \int + (f(T)-f(0))$, giving asymptotic $C(\alpha) = 3\cdot 2^\alpha/(\alpha+1)$.

Numerical verification confirms:
- (a) $\alpha=0.5$: corrected bound holds for all tested $T$, ratio $0.85$–$0.96$.
- (b) $\alpha=1$: marginal log-decrement = 1 at $T^{**} \approx 632$ as predicted.
- (c) $\alpha=2$: $\log P_T \to -\infty$ super-polynomially.
- (d) Optimum matches asymptotic prediction within factor 1.2–2.0.

## Honesty disclaimers

1. The problem's stated threshold $T_0^{\alpha/(\alpha-1)}\varepsilon_0^{-1/(\alpha-1)}$ in (c) is dimensionally inconsistent with natural scaling; we replaced it with the derived $T_{\text{div}} \asymp T_0^{\alpha/(\alpha+1)}\varepsilon_0^{-1/(\alpha+1)}$.
2. Part (b)'s "decreases reliability past $T^*$" required interpretation: without a benefit term, $P_T$ is trivially decreasing for all $T$. We formalized via marginal log-decrement reaching 1 (at $T^{**} = (1-1/e)T^*$) or via the Proposer-benefit FOC.
3. The continuum-to-discrete error in (d) is observed as a $20$–$50$% systematic bias; the prediction is correct as Big-Theta but not as a sharp constant.

## Related results

- **Stationary case** ($\alpha=0$): standard cumulative-reasoning bound $P_T \ge \exp(-\varepsilon_0 T)$. The $\alpha=0$ specialization recovers this.
- **Connection to compositional reuse** (`proofs/research/multi-agent/cumulative-reasoning-compositional-reuse/`): both involve product-of-failures structure; the non-stationary case adds time-dependence.
- **Connection to depth lower bound** (`proofs/research/multi-agent/cumulative-reasoning-depth-lower-bound/`): provides an upper bound on optimal depth $T^*(\alpha)$, complementing lower-bound arguments.
- **Optimization technique**: the FOC $\beta/T = \varepsilon_0(1+T/T_0)^\alpha$ is reminiscent of the bias-variance tradeoff in adaptive optimization (e.g., AdaGrad step size schedules).
