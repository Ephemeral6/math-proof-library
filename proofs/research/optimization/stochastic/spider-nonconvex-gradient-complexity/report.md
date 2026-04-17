# SPIDER Gradient Complexity — Five-Phase Report

## Phase 1: Scout
**Problem:** Prove SPIDER achieves $O(n + \sqrt{n}/\epsilon^2)$ gradient complexity for finding $\epsilon$-stationary points of nonconvex finite-sum problems.

**Route assigned:** Lyapunov potential $\Phi_t = f(x_t) + \lambda\|e_t - \nabla f(x_t)\|^2$.

**Key insight identified:** The polarization identity $\langle \nabla f, v\rangle = \frac{1}{2}(\|v\|^2 + \|\nabla f\|^2 - \|e\|^2)$ produces a negative $\|v_t\|^2$ term in the descent that absorbs the variance error without lossy inequalities like Young's.

## Phase 2: Explorer
**Approach:** 
1. Established the variance tracking lemma: $\mathbb{E}[\|e_t\|^2] \leq \frac{L^2\eta^2}{b}\sum_{s<t}\mathbb{E}[\|v_s\|^2]$.
2. Used polarization in the $L$-smoothness descent to get: $f(x_{t+1}) \leq f(x_t) - \frac{\eta}{2}\|\nabla f(x_t)\|^2 + \frac{\eta}{2}\|e_t\|^2 - \frac{\eta(1-L\eta)}{2}\|v_t\|^2$.
3. The cumulative variance error $\sum\|e_t\|^2$ is absorbed by the negative $\sum\|v_t\|^2$ term.

**Critical finding:** The step size $\eta = 1/(2L)$ (not $1/(L\sqrt{q})$) is correct when $b = q$, because the constraint $\gamma = 1 - L\eta - L^2\eta^2 q/b \geq 0$ becomes $1 - 1/2 - 1/4 = 1/4 > 0$.

**Failed attempts:** 
- Young's inequality approach leads to $O(n^{3/4}/\epsilon^2)$ (SVRG rate), not the SPIDER rate.
- Explicit Lyapunov potential $f + \lambda\|e\|^2$ works but requires careful coefficient tracking that obscures the key mechanism.

## Phase 3: Judge
The polarization-based proof is clean and rigorous. All steps verified.

## Phase 4: Auditor
**Verification checklist:**
- [x] Variance lemma: recursive bound correct, uses $L$-smoothness of each $f_i$ and i.i.d. sampling
- [x] Polarization identity: algebraically verified
- [x] Parameter constraint $\gamma = 1/4 > 0$: verified with $\eta = 1/(2L)$, $b = q$
- [x] Telescoping across epochs: correct with last-iterate output $x_0^{(k+1)} = x_q^{(k)}$
- [x] Complexity arithmetic: $K = O(1/(\sqrt{n}\epsilon^2))$, cost/epoch $= O(n)$, total $= O(n + \sqrt{n}/\epsilon^2)$

**Potential issues addressed:**
- Uniform-sample epoch output vs. last-iterate output: last-iterate is needed for clean telescoping
- Step size choice: $\eta = 1/(2L)$ is the correct choice for the $\sqrt{n}$ rate; $\eta = 1/(L\sqrt{q})$ is too conservative

## Phase 5: Final
Proof complete and verified. The key technical insight is using the polarization identity to extract a negative $\|v_t\|^2$ term that absorbs variance error, avoiding the lossy Young's inequality that would give the weaker $n^{3/4}$ rate.
