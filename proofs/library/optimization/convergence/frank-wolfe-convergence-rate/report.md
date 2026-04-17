# Proof Report: Frank-Wolfe (Conditional Gradient) O(1/k) Convergence Rate

## 1. Problem Statement

**Theorem.** Let $f: \mathbb{R}^d \to \mathbb{R}$ be convex and $L$-smooth (i.e., $\nabla f$ is $L$-Lipschitz), and let $\mathcal{D} \subset \mathbb{R}^d$ be a compact convex set with diameter $\text{diam}(\mathcal{D}) \leq D$.

The Frank-Wolfe algorithm with step size $\gamma_t = \frac{2}{t+2}$:

$$s_t = \arg\min_{s \in \mathcal{D}} \langle \nabla f(x_t), s \rangle, \quad x_{t+1} = x_t + \gamma_t (s_t - x_t)$$

satisfies: $f(x_t) - f(x^*) \leq \frac{2LD^2}{t+2}$ for all $t \geq 1$, where $x^* = \arg\min_{x \in \mathcal{D}} f(x)$.

**Source**: Frank & Wolfe 1956; Jaggi 2013 (ICML).

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed (3 viable, 1 ODE approach deemed impractical) |
| Explorer | Opus | 4 proofs attempted, 3 succeeded, 1 failed (ODE route) |
| Judge | Sonnet | Route 2 selected (score: 37/40) |
| Audit | Opus | PASS (1 round, 0 issues HIGH/MEDIUM, 3 LOW) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

1. **Direct Induction** (23/40): Correct but messy base case discussion with multiple false starts.
2. **Lyapunov / Recurrence** (37/40, SELECTED): Clean 4-step structure. Derives recurrence, verifies ansatz, clean base case, induction.
3. **Frank-Wolfe Gap-Based** (34/40): Good analysis with practical stopping criterion insight, but tangential detour into optimal step sizes.
4. **ODE Continuous-Time** (FAILED): Non-smooth selection map makes ODE approach impractical for this result.

## 4. Final Proof

**Setup.** Let $f$ be convex and $L$-smooth on $\mathbb{R}^d$, $\mathcal{D} \subset \mathbb{R}^d$ compact convex with diameter $D$, $x^* \in \arg\min_{\mathcal{D}} f$. Define $h_t = f(x_t) - f(x^*)$.

The Frank-Wolfe iterates are:
$$s_t = \arg\min_{s \in \mathcal{D}} \langle \nabla f(x_t), s \rangle, \quad x_{t+1} = x_t + \gamma_t(s_t - x_t), \quad \gamma_t = \frac{2}{t+2}.$$

---

**Step 1: Derive the fundamental recurrence.**

By $L$-smoothness (descent lemma) applied with $x = x_t$, $y = x_{t+1} = x_t + \gamma_t(s_t - x_t)$:

$$f(x_{t+1}) \leq f(x_t) + \gamma_t \langle \nabla f(x_t), s_t - x_t \rangle + \frac{L\gamma_t^2}{2}\|s_t - x_t\|^2.$$

Since $s_t, x_t \in \mathcal{D}$ and $\text{diam}(\mathcal{D}) \leq D$:

$$f(x_{t+1}) \leq f(x_t) + \gamma_t \langle \nabla f(x_t), s_t - x_t \rangle + \frac{L\gamma_t^2 D^2}{2}. \tag{A}$$

By linear minimization: $\langle \nabla f(x_t), s_t \rangle \leq \langle \nabla f(x_t), x^* \rangle$, so $\langle \nabla f(x_t), s_t - x_t \rangle \leq \langle \nabla f(x_t), x^* - x_t \rangle$.

By convexity: $\langle \nabla f(x_t), x^* - x_t \rangle \leq f(x^*) - f(x_t) = -h_t$.

Combining and subtracting $f(x^*)$:

$$h_{t+1} \leq (1 - \gamma_t) h_t + \frac{L\gamma_t^2 D^2}{2}. \tag{R}$$

**Step 2: Verify the ansatz $h_t \leq \frac{2LD^2}{t+2}$.**

Substituting $\gamma_t = \frac{2}{t+2}$ and $h_t \leq \frac{2LD^2}{t+2}$ into (R):

$$h_{t+1} \leq \frac{2LD^2}{(t+2)^2}(t + 1).$$

Need: $\frac{2LD^2(t+1)}{(t+2)^2} \leq \frac{2LD^2}{t+3}$, equivalently $(t+1)(t+3) \leq (t+2)^2$, i.e., $3 \leq 4$. $\checkmark$

**Step 3: Base case.** $\gamma_0 = 1 \Rightarrow h_1 \leq LD^2/2 \leq 2LD^2/3$. $\checkmark$

**Step 4: Conclusion.** By induction: $f(x_t) - f(x^*) \leq \frac{2LD^2}{t+2}$ for all $t \geq 1$. $\blacksquare$

## 5. Audit Result

**PASS** after 1 round. All 6 steps marked VALID. Three LOW-severity observations:
1. Bound stated for $t \geq 1$ (consistent with Jaggi 2013; $t=0$ requires initialization assumption)
2. Descent lemma cited without proof (standard)
3. Iterates staying in $\mathcal{D}$ used implicitly (convex combination preserves membership)

Key algebraic steps verified symbolically via SymPy and numerically with random spot checks.

## 6. Fix History

No fixes needed. Audit passed on the first round.
