# Route 2 — Naive Frame: Direct Two-Timescale GDA without Strictness

**Frame**: Naive (textbook attempt — mimic Jin–Netrapalli–Jordan 2019 with the strictness assumption dropped)
**Polarity**: Positive (assume "yes, two-timescale GDA already handles non-strict")
**Goal**: Reproduce the Jin–Netrapalli–Jordan 2019 Lyapunov proof for the strict local minimax case but allow $\nabla^2_{yy} f(x^*,y^*)$ and the outer "implicit Hessian" to have zero eigenvalues. Identify the EXACT lemma that breaks.

---

## Pre-proof Hooks

### Hook A — Strategy Signature Lookup
- `proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/` is the closest cousin: same algorithm (two-timescale GDA), same Lyapunov $V_t = \Phi(x_t) + c\,\delta_t$, same envelope-via-Danskin technique. The signature MATCHES on `algorithm_type=GDA`, `target_quantity=stationarity-of-envelope`, `iterate_type=last`, but DIFFERS on `function_class`: cousin uses **strong concavity** in $y$; here we have only $\nabla^2_{yy} f(x^*,y^*) \preceq 0$ (possibly with a zero eigenvalue).
- This is the right meta-template (MT1: Cancellation Pair via Lyapunov $V_t$ with descent on $\Phi$ + contraction on $\delta_t$). The slot-fill attempt below shows precisely which slot is unfillable.

### Hook B — Meta-Template Slot-Fill (MT1)
| Slot | Strict case (Jin et al. 2019) | Non-strict case (this route) |
|---|---|---|
| **V_t** | $\Phi(x_t) + c\|y_t-y^*(x_t)\|^2$ | Same form attempted |
| **TELESCOPE** | $V_t - V_{t+1}$ via Danskin + smoothness | Danskin needs $y^*(x)$ unique — **BLOCKER** |
| **GOOD** | $\eta_x \|\nabla\Phi(x_t)\|^2$ | Same |
| **BAD** | $L^2 \delta_t$ (gradient mismatch) | Same |
| **IDENTITY/INEQ** | Lemma A: $y^*$ is $\kappa$-Lipschitz; Lemma C: contraction $1 - 1/\kappa$ | **BLOCKER**: $\kappa = L/\mu = \infty$ when $\mu = 0$ |

Two slots blocked: the contraction constant is the central one. This route is structurally doomed; below we walk through the proof and pin the failure to a single point.

### Hook C — Structure Map Consultation
No saddle-point analogy in `structure_map.md` covers degenerate inner Hessians. The OGDA bilinear chassis (skew-symmetric coupling) does NOT extend to non-strict local minimax because the asymmetry between inner-max and outer-min in the local minimax notion is incompatible with the $\langle z, F(z)\rangle = 0$ skew identity.

### Hook D — Failure-Trigger Pre-Scan
Pitfalls flagged in `routes.md` step 0c that we must hit:
- **FP-GDA-NONSTRICTNESS**: degenerate fixed points are saddles for the two-timescale flow, hence repelling.
- **FP gda-nonconvex-strongly-concave Lesson 1**: $\eta_x/\eta_y = O(1/\kappa^2)$; when $\mu \to 0$, $\kappa\to\infty$ forces $\eta_x \to 0$.
- **FP-OGDA-BILINEAR**: Lyapunov approach fails when cross-term bound is loose; here the looseness is intrinsic at the degenerate eigendirection.

---

## Setup

Let $f \in C^2(\mathbb{R}^m \times \mathbb{R}^n)$, gradients $L$-Lipschitz on a neighbourhood of $(x^*, y^*)$. We attempt to mimic the cousin proof. Iterations:
$$x_{t+1} = x_t - \eta_x \nabla_x f(x_t, y_t), \qquad y_{t+1} = y_t + \eta_y \nabla_y f(x_t, y_t).$$
Step-size ratio $\eta_x/\eta_y \to 0$, with concrete choices to be determined ($\eta_y = 1/L$, $\eta_x = 1/(16\kappa^2 L)$ in the strict case).

We will faithfully follow Steps 1–8 of `gda-nonconvex-strongly-concave-convergence/proof.md` and document precisely where each step breaks.

---

## Step 1 (attempt at Lemma A: $y^*$ Lipschitz) — **BREAK #1**

### Strict case (cousin)
By $\mu$-strong concavity of $f(x,\cdot)$:
$$\big(\nabla_y f(x,y) - \nabla_y f(x,y')\big)^\top (y-y') \le -\mu \|y-y'\|^2,$$
with $\mu > 0$. Substituting $y = y^*(x), y' = y^*(x')$ and using $\nabla_y f(x',y^*(x')) = 0$ gives
$$\mu \|y^*(x) - y^*(x')\|^2 \le L \|x-x'\| \cdot \|y^*(x) - y^*(x')\|,$$
hence $\|y^*(x) - y^*(x')\| \le \frac{L}{\mu}\|x-x'\| = \kappa \|x-x'\|$.

### Non-strict case
Two distinct failure modes appear, both triggered by $\mu = 0$:

**(1a) $y^*(x)$ may not be unique.** A non-strict local maximum at $y^*$ for $f(x^*, \cdot)$ means the Hessian $\nabla^2_{yy} f(x^*, y^*)$ has a non-trivial null space $\mathcal{N} \subset \mathbb{R}^n$. By the implicit function theorem on the gradient equation $\nabla_y f(x, y) = 0$, when restricted to the non-degenerate eigendirections $\mathcal{N}^\perp$, we get a $C^1$ branch $y^*_\perp(x)$. Along $\mathcal{N}$, however, $\nabla_y f(x^*, y^* + tv) = O(t^2)$ for $v \in \mathcal{N}$, so the **maximizer set** $\mathcal{Y}^*(x^*)$ contains an entire curve (or higher-dimensional manifold) of critical points. The single-valued map $y^*: x \mapsto y^*(x)$ in the cousin proof is replaced by a set-valued map.

**(1b) Even where $y^*(x)$ exists as a $C^1$ branch off $x^*$, no Lipschitz constant exists.** Take the canonical degenerate example
$$f(x,y) = \tfrac{1}{2} x y^2 - \tfrac{1}{4} y^4, \quad x \in \mathbb{R}, \ y \in \mathbb{R}.$$
For each fixed $x \ne 0$, the unique stationary points in $y$ are $y = 0$ and $y = \pm\sqrt{x}$ (when $x > 0$); $\nabla^2_{yy} f(x,y) = x - 3y^2$. At $y = \pm\sqrt{x}$ we have $\nabla^2_{yy} = -2x$, so for $x>0$ these are strict local maxima. As $x \downarrow 0$, $y^*_{\pm}(x) = \pm\sqrt{x}$, so $\frac{dy^*_{\pm}}{dx} = \pm\frac{1}{2\sqrt{x}} \to \infty$. There is **no Lipschitz constant** $\kappa$ for $y^*$ at $x = 0$.

In the cousin proof the constant $\kappa$ is used everywhere downstream. With $\kappa = \infty$, every subsequent inequality becomes vacuous. **Lemma A fails.**

> **Step-1 BREAK**: Strong concavity (used to extract $-\mu \|y-y'\|^2$) is replaced by $\mu = 0$, so the division step yielding $\kappa = L/\mu$ is undefined. Lemma A cannot be repaired without an alternative regularity hypothesis (e.g., PL/KL on $f(x,\cdot)$ near $\mathcal{Y}^*(x)$, which is exactly Route 1's added assumption).

We try to push on assuming Lemma A "morally" holds with a finite $\kappa$ to see whether downstream lemmas might recover. **This is a deliberate fiction** — the goal is to find ALL break points, not just the first.

---

## Step 2 (attempt at Lemma B: $\Phi$ smoothness) — **BREAK #2** (Danskin fails)

### Strict case
Danskin's theorem applies because $y^*(x)$ is **unique**: $\Phi(x) := \max_y f(x,y)$ is differentiable with $\nabla \Phi(x) = \nabla_x f(x, y^*(x))$. Combined with Lemma A, $\Phi$ is $L(1+\kappa)$-smooth.

### Non-strict case
The local-minimax notion uses the truncated envelope $\Phi_\delta(x) := \max_{\|y - y^*\| \le \delta} f(x, y)$ rather than the global one. Two issues:

**(2a) Danskin's classical theorem requires the argmax to be a singleton.** When $\nabla^2_{yy} f(x^*, y^*)$ has a zero eigenvalue, the argmax of $f(x^*, \cdot)$ on $\{\|y-y^*\| \le \delta\}$ may be an entire arc or even higher-dimensional set. The generalized (Clarke) Danskin theorem then gives only
$$\partial^C \Phi_\delta(x) = \overline{\text{conv}}\{\nabla_x f(x, y) : y \in \mathcal{Y}^*_\delta(x)\},$$
a set-valued **subdifferential**, not a single gradient. The "descent inequality" $\Phi(v) \le \Phi(u) + \nabla\Phi(u)^\top(v-u) + \tfrac{L_\Phi}{2}\|v-u\|^2$ cannot be invoked because $\nabla\Phi$ does not exist as a single vector.

**(2b) The smoothness constant blows up via Lemma A.** Even if we replace $\nabla\Phi$ by an arbitrary selection from $\partial^C \Phi_\delta(x)$, the Lipschitz bound $L_\Phi \le L(1 + \kappa)$ depends on $\kappa$, and $\kappa = \infty$ in the degenerate case (Step 1).

**(2c) Truncated envelope vs. unconstrained envelope.** The local minimax notion is parameterized by the "outer radius" $\delta$. As $\delta$ varies, $\Phi_\delta(x)$ changes, and the formal Danskin gradient (where it exists) jumps when the constraint $\|y - y^*\| \le \delta$ becomes active. The cousin proof never deals with this — it uses the global envelope $\Phi$.

> **Step-2 BREAK**: The cousin's clean Danskin identity $\nabla\Phi(x) = \nabla_x f(x, y^*(x))$ is replaced by a set-valued Clarke subdifferential. Smoothness of $\Phi_\delta$ fails on the set where the active maximizer changes. The descent inequality (eq. (2) in cousin proof) does not hold with a single gradient and a single smoothness constant.

---

## Step 3 (gradient mismatch) — partial recovery, but now uncontrolled

### Strict case
$\|\nabla_x f(x_t, y_t) - \nabla\Phi(x_t)\| \le L \sqrt{\delta_t}$, where $\delta_t = \|y_t - y^*(x_t)\|^2$.

### Non-strict case
The mismatch lemma still holds **as a one-sided estimate** for any reference point $\bar y \in \mathcal{Y}^*_\delta(x_t)$:
$$\|\nabla_x f(x_t, y_t) - \nabla_x f(x_t, \bar y)\| \le L \|y_t - \bar y\|,$$
but the right-hand side now requires choosing $\bar y$, and "$\delta_t = \|y_t - y^*(x_t)\|^2$" is undefined when $y^*$ is set-valued. Replace $\delta_t$ by $d_t := \mathrm{dist}(y_t, \mathcal{Y}^*(x_t))^2$.

**Catch**: $\mathcal{Y}^*(x_t)$ is the **local maximizer set** of $f(x_t,\cdot)$, and as $x_t$ varies this set may pop in/out of existence — local maximizers can disappear via fold catastrophes when $\det \nabla^2_{yy} = 0$ at the limit. In the example $f(x,y) = \frac{1}{2}xy^2 - \frac{1}{4}y^4$ from Step 1, the local maxima $y = \pm\sqrt{x}$ exist only for $x > 0$ and **disappear** for $x \le 0$. So $d_t$ is itself ill-defined when $x_t$ crosses the discriminant.

This is not an immediate hard break, but it foreshadows an instability that becomes terminal at Step 4.

---

## Step 4 (Lemma C: $y$-step contraction) — **BREAK #3 (the killer)**

This is the key lemma in the cousin proof. We follow it line by line.

### Strict case
Fix $x = x_t$. Let $F(y) := -f(x_t, y)$, which is $\mu$-strongly convex and $L$-smooth, with minimizer $y^*(x_t)$. The $y$-step is gradient descent on $F$ with step $\rho = \eta_y$:
$$\|y_{t+1} - y^*(x_t)\|^2 = \|y_t - y^*(x_t)\|^2 - 2\rho \langle \nabla F(y_t) - \nabla F(y^*(x_t)), y_t - y^*(x_t)\rangle + \rho^2 \|\nabla F(y_t) - \nabla F(y^*(x_t))\|^2.$$
Nesterov's co-coercivity for $\mu$-strongly-convex $L$-smooth $F$ gives
$$\langle \nabla F(y_t) - \nabla F(y^*(x_t)), y_t - y^*(x_t)\rangle \ge \frac{\mu L}{\mu + L}\|y_t - y^*(x_t)\|^2 + \frac{1}{\mu + L}\|\nabla F(y_t) - \nabla F(y^*(x_t))\|^2.$$
With $\rho = 1/L$, the squared-gradient coefficient becomes non-positive (drop it), and the contraction factor is
$$1 - \frac{2\rho \mu L}{\mu + L} \le 1 - \frac{\mu}{L} = 1 - \frac{1}{\kappa}.$$
**This is the engine of the cousin proof.** Each $y$-step contracts $\delta_t$ by a factor $(1 - 1/\kappa) < 1$.

### Non-strict case (the failure)

When $\nabla^2_{yy} f(x^*, y^*)$ has a zero eigenvalue, $F = -f(x^*, \cdot)$ has $\nabla^2 F(y^*) \succeq 0$ but with zero eigenvalue along the kernel direction $v \in \ker \nabla^2 F(y^*)$. **$F$ is convex but not $\mu$-strongly convex for any $\mu > 0$.** Equivalently, the "strong convexity constant" is $\mu = 0$.

Re-running the calculation with $\mu = 0$:
$$\langle \nabla F(y_t) - \nabla F(y^*), y_t - y^*\rangle \ge 0 \cdot \|y_t - y^*\|^2 + \frac{1}{L}\|\nabla F(y_t) - \nabla F(y^*)\|^2.$$
(This is the Baillon–Haddad / co-coercivity of $\nabla F$ alone, with no quadratic floor.) Substituting:
$$\|y_{t+1} - y^*\|^2 \le \|y_t - y^*\|^2 - \frac{2\rho}{L}\|\nabla F(y_t)\|^2 + \rho^2 \|\nabla F(y_t)\|^2.$$
With $\rho = 1/L$: $\|y_{t+1} - y^*\|^2 \le \|y_t - y^*\|^2 - \frac{1}{L^2}\|\nabla F(y_t)\|^2$.

This says the $y$-distance is **non-increasing** but provides **no contraction rate**: along the kernel direction, $\nabla F(y_t) = O(\|y_t - y^*\|^p)$ for some $p \ge 2$ (from Taylor), so the decrement $\|\nabla F\|^2 = O(\|y_t - y^*\|^{2p})$ is super-linear in the residual itself, and the geometric rate $(1 - 1/\kappa)$ degenerates to $1$.

**Concretely**: take $F(y) = \frac{1}{4}y^4$ on $\mathbb{R}$, the prototypical degenerate case ($F'(0) = F''(0) = 0$, but $F^{(4)}(0) = 6$). The gradient flow is $\dot y = -y^3$, giving $y(t) = O(t^{-1/2})$ — a sub-linear, polynomial rate, not geometric. The gradient-descent iterate satisfies $y_{t+1} = y_t(1 - \rho y_t^2)$, so for small $|y_t|$:
$$y_{t+1} - y^* = y_t(1 - \rho y_t^2) - 0 = y_t \cdot (1 - \rho y_t^2).$$
The "contraction factor" is $1 - \rho y_t^2$, which $\to 1$ as $y_t \to 0$. There is **no uniform geometric contraction rate**.

> **Step-4 BREAK (the killer)**: The cousin's contraction $\delta_{t+1} \le (1 - 1/\kappa)\delta_t$ in eq. (3) becomes $\delta_{t+1} \le \delta_t \cdot (1 - O(\delta_t^{(p-1)}))$, which is $1 - o(1)$. The cousin's Lyapunov coefficient $c$ (chosen so that the descent of $\Phi$ on the GOOD term and the contraction of $\delta_t$ on the BAD term balance) satisfies $c = 4\kappa \eta_x L^2$. With $\kappa = \infty$ this forces $c = \infty$, i.e., the Lyapunov $V_t = \Phi(x_t) + c\,\delta_t$ is undefined. **The proof's central inequality (10), $V_{t+1} \le V_t - \frac{\eta_x}{4}\|\nabla\Phi\|^2$, is unavailable.**

---

## Step 5 (Lemma D + step-size choice) — Compounded by Step 4

Lemma D combines (3) with Young's inequality and the $\kappa$-Lipschitz $y^*$ to get
$$\delta_{t+1} \le (1-\tfrac{1}{2\kappa})\delta_t + 3\kappa^3 \eta_x^2 \|g_t\|^2.$$
With $\kappa = \infty$, every constant in this line is undefined. The Young's-split parameter $\alpha = 1/(2\kappa)$ becomes $\alpha = 0$, which annihilates Young's inequality. **No coherent recursion for $\delta_t$ exists.**

Step-size choices in the cousin: $\eta_x = 1/(16\kappa^2 L)$ and $c = L/(4\kappa)$. As $\mu \to 0$ (hence $\kappa \to \infty$), both $\eta_x \to 0$ and $c \to 0$. **The two-timescale ratio $\eta_x/\eta_y = 1/(16\kappa^2) \to 0$**, exactly the failure pattern flagged in `failure_patterns.md` (gda-nonconvex-strongly-concave Lesson 1: "two-timescale ratio is intrinsic"). Algorithmically, this means: as the geometry approaches degeneracy, the algorithm requires infinitely-many inner steps per outer step, and never makes outer progress.

---

## Step 6 (Lemma E: $x$-descent on $\Phi$) — **BREAK #4** (envelope is non-smooth)

The cousin uses the smoothness descent inequality (eq. (2)) on $\Phi$:
$$\Phi(x_{t+1}) \le \Phi(x_t) + \nabla\Phi(x_t)^\top (x_{t+1} - x_t) + \tfrac{L_\Phi}{2}\|x_{t+1}-x_t\|^2.$$

In the non-strict case:
- $\Phi$ may not be differentiable (Step 2); replace by a Clarke subgradient $\xi_t \in \partial^C \Phi_\delta(x_t)$, but then the descent inequality becomes a **subgradient inequality** valid only for convex (or weakly convex) $\Phi$, and the local minimax does NOT generally make $\Phi_\delta$ convex.
- $L_\Phi$ depends on $\kappa$ (Step 2), hence is infinite.
- Most basically: a non-strict local minimax in the **outer problem** means the implicit Hessian $\nabla^2 \Phi(x^*)$ also has a zero eigenvalue (this is a separate degeneracy: the outer one). Even if the inner problem were strict, an outer non-strict optimum would yield $\Phi$ with a zero curvature direction at $x^*$, so any first-order $x$-step fails to make progress along that direction — the $-\eta_x \|\nabla\Phi(x_t)\|^2$ descent term is $0$ on iterates approaching from the degenerate direction.

> **Step-6 BREAK**: Smoothness descent on $\Phi$ fails because (i) $\Phi$ may not be differentiable, (ii) $L_\Phi = \infty$, and (iii) the descent term vanishes along the outer-degenerate direction.

---

## Step 7 (Lyapunov combination) — **Aggregate failure**

The Lyapunov combination $V_t = \Phi(x_t) + c\,\delta_t$ in eq. (10) becomes
$$V_{t+1} \le V_t - \underbrace{(\tfrac{3\eta_x}{8} - 6c\kappa^3 \eta_x^2)}_{\text{coeff of }\|\nabla\Phi\|^2}\|\nabla\Phi(x_t)\|^2 - \underbrace{(\tfrac{c}{2\kappa} - \eta_x L^2 - 6c\kappa^3\eta_x^2 L^2)}_{\text{coeff of }\delta_t}\delta_t.$$

The cousin chooses $c = 4\kappa \eta_x L^2$ to make both coefficients positive. With $\kappa = \infty$:
- coeff of $\|\nabla\Phi\|^2$: $\tfrac{3\eta_x}{8} - 6c\kappa^3 \eta_x^2 = \tfrac{3\eta_x}{8} - \infty < 0$ ❌
- coeff of $\delta_t$: $\tfrac{c}{2\kappa} - \eta_x L^2 - 6c\kappa^3\eta_x^2 L^2 = 0 - \eta_x L^2 - \infty < 0$ ❌

So the descent inequality fails on **both** coefficients simultaneously. There is no choice of $c$ that fixes this, because the system of constraints
$$\frac{3\eta_x}{8} \ge 6c\kappa^3 \eta_x^2 \quad \text{and} \quad \frac{c}{2\kappa} \ge \eta_x L^2 + 6c\kappa^3 \eta_x^2 L^2$$
has solutions only when $\kappa < \infty$ (the algebra requires $c \kappa^3 \eta_x = O(1)$ on one side and $c/\kappa = \Omega(\eta_x L^2)$ on the other, giving a feasibility interval of width $\propto 1/\kappa^2$).

> **Step-7 BREAK (aggregate)**: The Lyapunov contraction $V_{t+1} \le V_t - \frac{\eta_x}{4}\|\nabla\Phi\|^2$ in eq. (11) cannot be derived without $\kappa < \infty$.

---

## Step 8–9 (telescoping, conclusion) — Vacuous

The telescoped bound $\frac{1}{T}\sum_{t<T}\|\nabla\Phi(x_t)\|^2 \le \frac{4(V_0 - V_T)}{\eta_x T}$ is meaningless once eq. (11) fails. Even if we ignored Steps 1–7's breaks and proclaimed $V_t$ non-increasing on faith, the rate $O(\kappa^2 / (T\epsilon^2))$ becomes $\infty$ for any finite $T$.

---

## Single-Sentence Summary of the Naive Frame's Failure

The naive route fails at **Step 4 (Lemma C)**: when $\nabla^2_{yy} f(x^*, y^*) \preceq 0$ has a zero eigenvalue, the inner gradient-step contraction $\delta_{t+1} \le (1 - 1/\kappa)\delta_t$ degenerates to $\delta_{t+1} \le \delta_t (1 - O(\delta_t))$, i.e., **sub-geometric (polynomial) convergence at best**, which prevents the cousin's Lyapunov $V_t = \Phi + c\delta_t$ from satisfying $V_{t+1} \le V_t - \frac{\eta_x}{4}\|\nabla\Phi\|^2$ for any positive $c$ and any positive $\eta_x$.

The break is **structural**, not technical: the strong-concavity constant $\mu = 0$ enters multiplicatively in the contraction factor, the smoothness constant of $\Phi$, the Lyapunov weight, and the step-size choice — each becomes ill-defined or vacuous. There is no parameter retuning that rescues the proof.

---

## Counterexample illustrating the break (anchor)

Consider the **flat-y example** alluded to in `problem.md`: $f(x,y) = \frac{1}{2}x y^2 - \frac{1}{4}y^4$ on $\mathbb{R}\times\mathbb{R}$. This is a 1-1-D version of the obstruction.

- For $x = 0$: $f(0, y) = -\frac{1}{4}y^4$, so $y = 0$ is a non-strict local maximum (Hessian $f_{yy}(0,0) = 0$).
- For $x > 0$: stationary points in $y$ are $y = 0$ (local min) and $y = \pm\sqrt{x}$ (strict local max).
- For $x < 0$: only $y = 0$ is stationary, and it is the (unique) local max.
- The "envelope" (taking $\delta = 1$, say): $\Phi_1(x) = \max_{|y|\le 1} f(x,y)$.
  - For $x \le 0$: $\Phi_1(x) = f(x, 0) = 0$.
  - For $x > 0$ small: $\Phi_1(x) = f(x, \sqrt{x}) = \frac{1}{2}x \cdot x - \frac{1}{4}x^2 = \frac{x^2}{4}$.

So $\Phi_1$ is $C^1$ on $\mathbb{R}$ (with $\Phi_1'(0^-) = 0 = \Phi_1'(0^+)$), even $C^2$ on each side, but the kink in the third derivative at $x=0$ already means the smoothness constant blows up. At $(x^*, y^*) = (0, 0)$:
- $\nabla^2_{yy} f(0, 0) = 0$ (degenerate).
- $\Phi_1''(0) = 0$ (also degenerate; outer non-strictness).
- $\Phi_1$ has its local minimum at $x^* = 0$ but with $\Phi_1''(0) = 0$.

Run two-timescale GDA from $(x_0, y_0) = (\epsilon, \epsilon)$ for small $\epsilon > 0$:
- $y$-step: $y_{t+1} = y_t + \eta_y(x_t y_t - y_t^3)$. For the first inner sweep with $x_t \approx \epsilon$, the local max is $y \approx \sqrt{\epsilon}$. The contraction rate at this $y^*$ is $1 - \eta_y \cdot (-f_{yy}(0, \sqrt\epsilon)) \cdot (\text{factor}) = 1 - 2\eta_y \epsilon$ at the strict stationary point, and exactly $1$ at $\epsilon = 0$.
- After the inner loop "converges", the $x$-step takes $x_{t+1} = x_t - \eta_x \cdot \frac{1}{2}y_t^2 \approx x_t - \eta_x \cdot \frac{x_t}{2}$, driving $x_t \to 0$.
- As $x_t \to 0^+$, $y^*(x_t) = \sqrt{x_t} \to 0$, but $y^*$ is **not Lipschitz**: $|y^*(x) - y^*(0)| = \sqrt x$, so $|y^*(x) - y^*(x')| \le |x - x'|^{1/2}$, only Hölder-continuous with exponent $1/2$.
- The two-timescale Lyapunov $V_t = \Phi_1(x_t) + c\|y_t - y^*(x_t)\|^2$ requires $c = 4\kappa \eta_x L^2$, but $\kappa$ depends on the local Hessian eigenvalue, which is $\to 0$ as $x_t \to 0$. The Lyapunov coefficient diverges.
- **Net effect**: the iterates approach $(0, 0)$ along a curve where the Lyapunov is ill-conditioned, and the convergence rate of the cousin's proof bound, $O(\kappa^2/T)$, blows up to $\infty$ at the limit point.

(Numerical simulation, suggested but not required: SymPy can verify $\Phi_1''(0) = 0$ and that the cousin's choice $c = L/(4\kappa)$ diverges; NumPy can run GDA at $\eta_y = 0.1, \eta_x = 0.001$ and exhibit the slow-down. Out of scope for this report; the analytic argument suffices.)

---

## Could the proof be patched?

| Patch attempt | Outcome |
|---|---|
| Increase $\kappa$ to a large constant and treat $\mu \to 0$ as a limit | The bound $O(\kappa^2/(T\epsilon^2))$ becomes vacuous; no uniform-in-$\kappa$ convergence guarantee. |
| Replace strong concavity by PL on the inner problem | This is **Route 1** (orthodox) — partial positive result under added assumption; not the naive frame. |
| Use Clarke subdifferential of $\Phi_\delta$ + weakly-convex envelope | Requires $\Phi_\delta$ to be weakly convex, which is false in general (the envelope of the local-minimax notion is parameterized by $\delta$ and exhibits non-smooth phase transitions). |
| Use center-manifold theorem on the GDA flow | This is **Route 2 (very hard)** — does not give a quantitative rate; the flow on the center manifold has zero linear contraction rate by construction. |
| Replace the geometric contraction by a polynomial one | Requires the inner gradient to satisfy $\|\nabla_y f(x,y)\|^2 \ge c \|y - y^*\|^{2p}$ for some $p \ge 1$ (i.e., a **PL-with-exponent** condition). This is not implied by $C^2$ regularity alone. |
| Add Hessian queries (curvature-aware step) | Violates the "first-order only" constraint of the problem. |

**No first-order patch exists within the naive frame.** The cousin proof's contraction $1 - 1/\kappa$ has no replacement when $\kappa = \infty$, and dropping that contraction collapses every downstream lemma.

---

## What additional assumption would minimally rescue the proof?

The minimal repair is to replace strong concavity by a **Polyak–Łojasiewicz (PL) condition** on $f(x, \cdot)$ uniformly in $x$ near $(x^*, y^*)$:
$$\exists\, \mu_{\text{PL}} > 0, \delta > 0: \forall (x, y) \text{ with } \|x-x^*\|,\|y-y^*\| \le \delta,\ \|\nabla_y f(x,y)\|^2 \ge 2\mu_{\text{PL}}(\Phi_\delta(x) - f(x,y)).$$
Under PL, the gradient-descent iterate $y_{t+1}$ satisfies $\Phi_\delta(x_t) - f(x_t, y_{t+1}) \le (1 - \eta_y \mu_{\text{PL}})(\Phi_\delta(x_t) - f(x_t, y_t))$ — a geometric contraction, just with $\mu_{\text{PL}}$ in place of $\mu$. This rescues Lemma C, hence the entire cousin chassis. **But this is exactly the partial / orthodox frame (Route 1)**, and the open problem (Chae–Kim–Kim 2023) remains for the case where no PL/KL condition is assumed.

For PL with exponent $\theta \in (0,1)$ (KL inequality), the contraction is sub-geometric and the rate degrades to $O(t^{-\theta/(1-\theta)})$ via the harmonic-recursion lemma [REF: `proofs/fragments/harmonic-recursion-lemma.md`], but the proof still goes through; this is the most-general structural assumption that retains the cousin's chassis.

---

## Route Failure Report

- **Route**: Route 2 (Naive — Direct Two-Timescale GDA without Strictness)
- **Failed at**: Step 4 (Lemma C — $y$-step contraction toward $y^*(x_t)$), with concomitant aggregate failures in Steps 1, 2, 5, 6, 7.
- **Obstacle**: The strong-concavity constant $\mu$ of $f(x,\cdot)$ near the non-strict local minimax optimum is exactly zero. Lemma C's contraction $\|y_{t+1} - y^*(x_t)\|^2 \le (1 - 1/\kappa) \|y_t - y^*(x_t)\|^2$ uses $\mu/L = 1/\kappa$ multiplicatively; with $\mu = 0$, the contraction degenerates to "$\le 1 \cdot$" (no contraction). The Lyapunov weight $c = L/(4\kappa)$ vanishes; the step-size $\eta_x = 1/(16\kappa^2 L)$ vanishes; the smoothness constant $L_\Phi = 2\kappa L$ diverges. Every downstream constant is ill-defined. No first-order patch within $C^2$ regularity rescues the proof.
- **What would be needed to fix it**: A **PL or KL inequality** on the inner problem $f(x, \cdot)$, uniformly in a neighbourhood of $(x^*, y^*)$. Under PL with constant $\mu_{\text{PL}} > 0$, replace $\mu$ by $\mu_{\text{PL}}$ throughout and the cousin proof transfers. Under KL with exponent $\theta \in (0,1)$, the contraction becomes sub-geometric and the harmonic-recursion lemma closes the rate. **These are added assumptions not present in the open problem statement, so the naive frame cannot reach the original target**; this is exactly Route 1's regime.

---

## Hooks Report

- **Strategy signatures consulted**: [`gda-nonconvex-strongly-concave-convergence`, `ogda-bilinear-last-iterate`]; useful=YES; the cousin's Lyapunov + Danskin chassis is the right structural template, and watching it fail at the strong-concavity slot pinpointed the break to Lemma C / Step 4.
- **Meta-template attempted**: MT1 (Cancellation Pair via Lyapunov + descent + tracking-error contraction); slots filled: [V_t, GOOD, BAD, partial TELESCOPE]; blocker slot: **IDENTITY/INEQ** (the geometric contraction $1 - 1/\kappa$ in Lemma C requires $\mu > 0$, unavailable in the non-strict regime). This is exactly the anti-pattern note for MT1: "Genuinely non-convex problems with no descent direction (no V_t exists)".
- **Structure map links used**: SAME_TEMPLATE link to C2/C4 (gda-nonconvex-strongly-concave + ogda-bilinear-last-iterate cluster) consulted; no analogy resolves the degenerate inner Hessian.
- **Failure triggers checked**: [FP-OGDA-BILINEAR (Lyapunov approach fails when cross-term bound is loose), FP-GDA-NONSTRICTNESS (degenerate fixed points are saddles for two-timescale flow), FP-gda-nonconvex-SC Lesson 1 (two-timescale ratio $\eta_x/\eta_y \propto 1/\kappa^2 \to 0$ at degeneracy)]; matched: [all three]; pivots taken: documented as honest failure path per Scout's instruction; route rejected, defer to Routes 1, 3, 4, 5 for genuine progress.

---

*Generated by Explorer (Naive frame), 2026-04-27.*
