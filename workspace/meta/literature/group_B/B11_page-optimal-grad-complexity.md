# B11 — PAGE optimal gradient complexity

**Verdict**: DISCREPANCY (final complexity stated incorrectly)

**Source**: Li, Bao, Zhang, Richtárik, *"PAGE: A Simple and Optimal Probabilistic Gradient Estimator for Nonconvex Optimization"*, ICML 2021 Best Paper (arXiv:2008.10898).

## OUR statement
Finite-sum $f = \frac1n\sum f_i$, $L$-smooth. PAGE with $p=1/\sqrt n$, $b'=\sqrt n$, $\eta=1/(2L\sqrt n)$:
$$\frac{1}{T}\sum \mathbb{E}\|\nabla f(x_t)\|^2 \le 4L\sqrt n\,\Delta_0/T.$$
Total SFO: $n + T \cdot O(\sqrt n) = O(n + nL\Delta_0/\varepsilon^2)$ (proof's "Gradient Complexity" section).

## Paper statement (verified from abstract)
PAGE achieves $O(n + \sqrt n/\varepsilon^2)$ for finite-sum, matching the lower bound $\Omega(n + \sqrt n/\varepsilon^2)$ from Fang et al. 2018.

## Comparison
- Iteration bound $T = O(L\sqrt n\,\Delta_0/\varepsilon^2)$: **CORRECT** and matches PAGE Thm 1.
- Per-step cost analysis: $p\cdot n + (1-p)\cdot b' = (1/\sqrt n)\cdot n + (1-1/\sqrt n)\cdot\sqrt n = \sqrt n + \sqrt n - 1 = 2\sqrt n - 1 = O(\sqrt n)$. **CORRECT**.
- Total SFO: $T\cdot O(\sqrt n) = O(\sqrt n)\cdot O(L\sqrt n\Delta_0/\varepsilon^2) = O(nL\Delta_0/\varepsilon^2)$.
- Proof's stated total: "$O(n + nL\Delta_0/\varepsilon^2)$" and then claims "matches lower bound $\Omega(n+\sqrt n/\varepsilon^2)$" — **CONTRADICTION**: $n/\varepsilon^2 \ne \sqrt n/\varepsilon^2$.

## Source of error
Per-step cost should be $O(\sqrt n)$ for the **bias-correction term** ($b' = \sqrt n$) but the **full-gradient resets** happen with probability $p = 1/\sqrt n$ once per step, contributing $p\cdot n = \sqrt n$ in expectation. Sum $= O(\sqrt n)$ per iteration ✓. So total SFO = $T\cdot O(\sqrt n) = O(\sqrt n\cdot \sqrt n/\varepsilon^2) = O(n/\varepsilon^2)$, **not** $O(\sqrt n/\varepsilon^2)$.

The published $O(n+\sqrt n/\varepsilon^2)$ result requires choosing **$p, b'$ as the optimal trade-off**: $p = b'^2/(b'^2 + n)$ with $b' = \sqrt n$ gives $p = \sqrt n/(n+\sqrt n) \approx 1/\sqrt n$ — same as ours. But the per-step expected cost is $p\cdot n + b' \cdot (1-p)$. For $p = 1/\sqrt n$, $b' = \sqrt n$: expected cost = $\sqrt n + \sqrt n(1-1/\sqrt n) = 2\sqrt n - 1$. So $T \cdot 2\sqrt n = O(\sqrt n \cdot \sqrt n /\varepsilon^2) = O(n/\varepsilon^2)$.

Wait — let me recompute. $T = O(L\sqrt n\Delta/\varepsilon^2)$, so $T\cdot \sqrt n = O(n/\varepsilon^2)$.

The published rate $O(\sqrt n/\varepsilon^2)$ would require $T = O(1/\varepsilon^2)$, i.e., a $\sqrt n$-faster iteration count. PAGE actually achieves this because the **iteration bound** $T$ in the published paper is $O(\Delta L/\varepsilon^2)$ with no $\sqrt n$ factor (the $\sqrt n$ saving comes from variance reduction, not iteration count).

Re-reading proof Step 3: $\eta = 1/(2L\sqrt n)$ is responsible for the $\sqrt n$ factor in $T = O(L\sqrt n\Delta/\varepsilon^2)$. Published PAGE uses $\eta = 1/(2L)$ (independent of $n$) and gets $T = O(L\Delta/\varepsilon^2)$, with cost $\sqrt n$ per step → $O(\sqrt n L\Delta/\varepsilon^2)$. **The proof's choice $\eta = 1/(2L\sqrt n)$ gives a strictly worse complexity than PAGE.**

## Verdict
**DISCREPANCY**: the proof's gradient complexity $O(n + nL\Delta/\varepsilon^2)$ does **not** match the published PAGE rate $O(n + \sqrt n L\Delta/\varepsilon^2)$, and the proof's claim "matches lower bound $\Omega(n+\sqrt n/\varepsilon^2)$" is **incorrect** (off by a factor of $\sqrt n$). Root cause: step size choice $\eta = 1/(2L\sqrt n)$ is too conservative; published PAGE uses $\eta = 1/(2L)$. The intermediate bound (iteration complexity $T = O(L\sqrt n\Delta/\varepsilon^2)$) is internally consistent with the chosen $\eta$, but the final complexity claim is wrong.
