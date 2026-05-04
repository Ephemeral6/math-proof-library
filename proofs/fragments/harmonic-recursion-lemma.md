# Fragment: harmonic-recursion-lemma

## Statement
Let $\{a_t\}$ be a sequence of non-negative reals satisfying
$$0 \;\le\; a_{t+1} \;\le\; a_t(1 - c\,a_t)$$
for some $c > 0$, with initial condition $a_0 \in (0, 1/c]$. Then for all $t \ge 1$:
$$a_t \;\le\; \frac{1}{c\, t}.$$

## Proof
From the hypothesis, $a_{t+1} \le a_t$ (since $1 - ca_t \le 1$ and $a_t \ge 0$), and $1 - c a_t \ge 0$ throughout (induction on $a_t \le 1/c$). If $a_t = 0$ for some $t$, the bound holds trivially thereafter. Otherwise, divide $(a_t - a_{t+1}) \ge c\, a_t^2$ by $a_t a_{t+1} > 0$:
$$\frac{1}{a_{t+1}} - \frac{1}{a_t} = \frac{a_t - a_{t+1}}{a_t a_{t+1}} \ge \frac{a_t - a_{t+1}}{a_t^2} \ge c.$$
(Using $a_{t+1} \le a_t$ in the second step.) Telescoping: $1/a_t \ge 1/a_0 + ct \ge ct$. $\square$

**Corollary** (with burn-in): if instead $a_0 > 1/c$, define $T_0 := \min\{t \ge 0 : a_t \le 1/c\}$. Since the recursion drops $a_t$ by at least $c \cdot (1/c)^2 = 1/c$ each step while $a_t > 1/c$, $T_0 \le c\, a_0$ (finite). After $T_0$, apply the basic lemma to get $a_{T_0 + s} \le 1/(cs)$, hence $a_t \le 2/(ct)$ for $t \ge 2T_0$.

## Source
- `proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/proof.md` — Lemma 8.

## Status
- **Correctness**: VERIFIED (standard, but very widely reused)
- **Used in final proof**: YES (drives $O(1/t)$ rate for softmax PG)
- **Potential applications**:
  - $O(1/t)$ sublinear rates whenever the contraction is **non-uniform** (Łojasiewicz with exponent 1)
  - Convergence of subgradient method on smooth convex functions
  - Frank-Wolfe / conditional gradient $O(1/t)$ rate
  - Logistic regression GD without strong convexity
  - Any "per-step decrease ≥ c × current²" recursion

## Tags
harmonic-recursion, sublinear, lojasiewicz, telescoping, descent
