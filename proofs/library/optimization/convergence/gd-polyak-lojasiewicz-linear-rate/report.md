# Proof Report: GD with Polyak-Lojasiewicz Condition — Exact Linear Convergence Rate

## 1. Problem Statement

Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth and satisfy the $\mu$-PL condition:

$$\frac{1}{2}\|\nabla f(x)\|^2 \geq \mu(f(x) - f^*)$$

where $f^* = \inf_x f(x)$. Note: $f$ need NOT be convex.

Prove that gradient descent with step size $\eta = 1/L$:

$$x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$$

satisfies:

$$f(x_{k+1}) - f^* \leq \left(1 - \frac{\mu}{L}\right)(f(x_k) - f^*)$$

and consequently:

$$f(x_k) - f^* \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f^*)$$

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed |
| Explorer | Opus | 4 proofs attempted, 4 succeeded |
| Judge | Sonnet | Route 1 selected (score: 39/40) |
| Audit | Opus | PASS (1 round, 0 issues) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

| Route | Name | Score | Outcome |
|-------|------|-------|---------|
| 1 | Direct Descent Lemma + PL | 39/40 | **Selected** — fully self-contained with descent lemma proof |
| 2 | Lyapunov Function Framework | 35/40 | Succeeded — clean but condensed, cites descent lemma without proof |
| 3 | Quadratic Upper Bound Minimization + PL | 38/40 | Succeeded — nice step size optimality argument |
| 4 | Comparison with Strong Convexity | 33/40 | Succeeded — more discussion than self-contained proof |

## 4. Final Proof

**Setup.** Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth, meaning $\nabla f$ is $L$-Lipschitz continuous:

$$\|\nabla f(x) - \nabla f(y)\| \leq L\|x - y\| \quad \forall x, y \in \mathbb{R}^d$$

and let $f$ satisfy the $\mu$-PL condition:

$$\frac{1}{2}\|\nabla f(x)\|^2 \geq \mu(f(x) - f^*) \quad \forall x \in \mathbb{R}^d$$

where $f^* = \inf_x f(x)$ and $0 < \mu \leq L$. Consider gradient descent with step size $\eta = 1/L$:

$$x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$$

---

**Step 1: Descent Lemma from $L$-smoothness.**

Since $f$ is $L$-smooth, for any $x, y \in \mathbb{R}^d$:

$$f(y) \leq f(x) + \langle \nabla f(x), y - x \rangle + \frac{L}{2}\|y - x\|^2$$

*Proof*: By the fundamental theorem of calculus:

$$f(y) = f(x) + \int_0^1 \langle \nabla f(x + t(y-x)), y-x \rangle \, dt$$

$$= f(x) + \langle \nabla f(x), y-x \rangle + \int_0^1 \langle \nabla f(x + t(y-x)) - \nabla f(x), y-x \rangle \, dt$$

By Cauchy-Schwarz and $L$-Lipschitz continuity:

$$\left|\int_0^1 \langle \nabla f(x + t(y-x)) - \nabla f(x), y-x \rangle \, dt\right| \leq \int_0^1 Lt\|y-x\|^2 \, dt = \frac{L}{2}\|y-x\|^2$$

---

**Step 2: Apply to the GD iterate.**

Set $x = x_k$, $y = x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$:

$$f(x_{k+1}) \leq f(x_k) - \frac{1}{L}\|\nabla f(x_k)\|^2 + \frac{1}{2L}\|\nabla f(x_k)\|^2 = f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2 \tag{Descent}$$

---

**Step 3: Apply the PL inequality.**

By PL: $\|\nabla f(x_k)\|^2 \geq 2\mu(f(x_k) - f^*)$. Substituting into (Descent) and subtracting $f^*$:

$$f(x_{k+1}) - f^* \leq \left(1 - \frac{\mu}{L}\right)(f(x_k) - f^*) \tag{Contraction}$$

---

**Step 4: Iterate.**

Applying (Contraction) $k$ times:

$$f(x_k) - f^* \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f^*) \qquad \blacksquare$$

## 5. Audit Result

**PASS** (Round 1). All 4 steps verified as VALID. Numerical verification on a quadratic test function confirms all inequalities. Three LOW-severity notes identified (finiteness of $f^*$, $\mu \leq L$ condition, iteration complexity approximation) — none are gaps in the proof.

## 6. Fix History

No fixes needed. The proof passed audit on the first round.
