# First-Order Convergence to Non-Strict Local Minimax Optima — Partial Positive Result

**Verdict.** PARTIAL POSITIVE under inner-PL (Outcome 3 of `problem.md`).
**Open-problem status.** Chae–Kim–Kim COLT 2023 NOT FULLY RESOLVED. Outcomes 1 (full positive) and 2 (full negative for the literal "converge to *some* local minimax" question) remain open.
**Source routes.** `proof_route_orthodox.md` (Explorer Orthodox frame, primary). Round-1 Fixer (`fixed_round_1.md`) absorbed minor algebraic fixes and resolved scope decisions.
**Audit history.** Round 1 — Part B PASS PARTIAL; Part A (Construction) FAIL → dropped; Adversarial pivot considered and rejected (scope mismatch with literal CKK). Round 2 — PASS PARTIAL on the Part-B-only deliverable.
**Date.** 2026-04-27.

> **Honest scope statement.** This proof delivers a partial positive result: under the inner-PL assumption (A2) below, two-timescale GDA with $\eta_y = 1/L$, $\eta_x = 1/(32\kappa^2 L)$ converges to a (general, possibly non-strict) local minimax optimum at rate $T = O(L^3/(\mu^2 \varepsilon^2))$. The proof does NOT cover non-PL non-strict local minimax optima — including the canonical hard cases $f(x,y) = x^2 y$ at $(0,0)$ and $f(x,y) = \tfrac12 x^2 y^2 - \tfrac14 y^4$ at $(0,0)$ — and explicitly says so. A NEGATIVE resolution of the literal CKK question (no first-order method converges to *some* local minimax of every $C^\infty$ instance) is NOT established; what was attempted in Round 0 (Construction route, Adversarial route) is recorded in §Discussion as a pair of closed-out dead ends.

---

## 1. Setup and Assumptions

Let $f:\mathbb{R}^m \times \mathbb{R}^n \to \mathbb{R}$ be $C^2$. Fix a candidate local minimax optimum $(x^*, y^*)$ in the sense of Jin–Netrapalli–Jordan 2019 (see `problem.md`). Choose a neighbourhood radius $r > 0$ (specified quantitatively in Lemma 7) and write
$$B_x := \{x : \|x - x^*\| \le r\}, \qquad B_y(x) := \{y : \|y - y^*(x)\| \le r\}.$$

We impose four assumptions, all local on $B_x \times \bigcup_{x\in B_x} B_y(x)$.

- **(A1) Smoothness.** $\nabla f$ is $L$-Lipschitz on $B_x \times \bigcup_{x \in B_x} B_y(x)$.
- **(A2) Inner PL (uniform).** There exists $\mu > 0$ such that for every $x \in B_x$ and every $y \in B_y(x)$
$$\tfrac{1}{2}\|\nabla_y f(x, y)\|^2 \;\ge\; \mu \,[\, f(x, y^*(x)) - f(x, y) \,], \tag{PL}$$
where $y^*(x) := \arg\max_{y \in B_y(x)} f(x,y)$ (well-defined under (A4) below).
- **(A3) Outer envelope boundedness.** $\Phi(x) := f(x, y^*(x))$ is bounded below on $B_x$ by $\Phi^*$, and $\Delta := \Phi(x_0) - \Phi^* < \infty$.
- **(A4) Continuity of inner maximizer.** $y^*(\cdot) : B_x \to \mathbb{R}^n$ is single-valued and continuous on $B_x$.

We write $\kappa := L/\mu \ge 1$ for the inner condition number.

> **Remark on (A4) — sufficient condition under (A2).** Under (A2), if $f$ additionally satisfies the **PL separation gap** condition — for each $x \in B_x$, the set $\{y \in B_y(x) : f(x, y) = f(x, y^*(x))\}$ is a single connected component bounded away from the boundary $\partial B_y(x)$ — then $y^*(\cdot)$ is single-valued and continuous on $B_x$. This is Karimi–Nutini–Schmidt 2016, Theorem 2 (PL ⇒ EB ⇒ QG ⇒ PL equivalence chain), combined with their Proposition 4 (PL implies isolation of connected components of the optimal set in suitable neighbourhoods). Strong concavity in $y$ is the canonical special case (giving Lipschitzness of $y^*$ with constant $\kappa$, Lemma 2 below). The PL separation gap is strictly weaker than strong concavity but strictly stronger than bare PL. [REF:external — Karimi, Nutini, Schmidt 2016, "Linear Convergence of Gradient and Proximal-Gradient Methods Under the Polyak–Łojasiewicz Condition," ECML-PKDD 2016, Thm 2 + Prop 4.]

### Algorithm — Two-timescale GDA

With constant step sizes $\eta_y = 1/L$ and $\eta_x = 1/(32\kappa^2 L)$:
$$y_{t+1} = y_t + \eta_y \nabla_y f(x_t, y_t), \qquad x_{t+1} = x_t - \eta_x \nabla_x f(x_t, y_t). \tag{GDA}$$

Note the step-size ratio $\eta_x/\eta_y = 1/(32\kappa^2)$, sharper than Jin et al.'s "$\eta_y/\eta_x = O(1/\mu)$" by a factor of $\kappa$ — this matches the strongly-concave optimum and is required for the Lyapunov coefficient (LD$^*$) below to balance.

---

## 2. Geometric Lemmas

### Lemma 1 (PL ⇒ QG).

For each $x \in B_x$ and every $y \in B_y(x)$,
$$\Phi(x) - f(x, y) \;\ge\; \tfrac{\mu}{2} \|y - y^*(x)\|^2. \tag{QG}$$

*Proof.* Standard PL ⇒ QG implication (Karimi–Nutini–Schmidt 2016, Theorem 2): $L$-smoothness of $f(x,\cdot)$ in $y$ together with (PL) forces quadratic growth around $y^*(x)$. Concretely, integrate the gradient flow of $g(y) := -f(x,y)$ from $y$ towards $y^*(x)$; PL gives $g(y_s) - g^* \le e^{-2\mu s}(g(y) - g^*)$ and $\|\dot y_s\| = \|\nabla g(y_s)\| \ge \sqrt{2\mu(g(y_s)-g^*)}$, so by Cauchy–Schwarz $\|y - y^*(x)\| \le \sqrt{2(g(y)-g^*)/\mu}$, i.e. (QG). $\square$ [REF:external — Karimi–Nutini–Schmidt 2016 Thm 2.]

### Lemma 2 ($y^*(\cdot)$ is $\kappa$-Lipschitz).

For all $x, x' \in B_x$, $\|y^*(x) - y^*(x')\| \le \kappa \|x - x'\|$.

*Proof.* No implicit function theorem is available because the inner Hessian may be singular. Instead, apply (QG) at $x$ to $y^*(x')$ and at $x'$ to $y^*(x)$:
$$f(x, y^*(x)) - f(x, y^*(x')) \ge \tfrac{\mu}{2}\|y^*(x)-y^*(x')\|^2, \quad f(x', y^*(x')) - f(x', y^*(x)) \ge \tfrac{\mu}{2}\|y^*(x)-y^*(x')\|^2.$$
Adding and rewriting the LHS as a path integral in $x$:
$$\mu\,\|y^*(x)-y^*(x')\|^2 \le \int_0^1 \bigl[\nabla_x f((1-s)x'+sx, y^*(x)) - \nabla_x f((1-s)x'+sx, y^*(x'))\bigr]^\top (x-x')\,ds.$$
By (A1), the integrand is bounded in absolute value by $L\|y^*(x)-y^*(x')\|\cdot\|x-x'\|$, so $\mu\|y^*(x)-y^*(x')\|^2 \le L\|y^*(x)-y^*(x')\|\cdot\|x-x'\|$, giving the claim. $\square$

### Lemma 3 ($\Phi$ is $L_\Phi$-smooth, $L_\Phi \le 2\kappa L$).

*Proof.* Danskin's theorem under (A4) gives $\nabla\Phi(x) = \nabla_x f(x, y^*(x))$ (this requires only single-valuedness of $y^*$, NOT non-singular Hessian). Then for $x, x' \in B_x$,
$$\|\nabla\Phi(x) - \nabla\Phi(x')\| = \|\nabla_x f(x, y^*(x)) - \nabla_x f(x', y^*(x'))\| \le L(\|x-x'\| + \|y^*(x)-y^*(x')\|) \le L(1+\kappa)\|x-x'\| \le 2\kappa L\|x-x'\|$$
using Lemma 2 and $\kappa \ge 1$. $\square$ [REF:external — Danskin's theorem; standard.]

### Lemma 4 (Inner contraction in function-value gap).

With $\eta_y = 1/L$ and $\delta_t := \Phi(x_t) - f(x_t, y_t) \ge 0$,
$$\Phi(x_t) - f(x_t, y_{t+1}) \;\le\; (1 - 1/\kappa) \,\delta_t. \tag{IC}$$

*Proof.* Apply the descent lemma to $G(y) := -f(x_t, y)$ at $y_t$ with step $\eta_y = 1/L$: $G(y_{t+1}) \le G(y_t) - \tfrac{1}{2L}\|\nabla G(y_t)\|^2$. By (PL), $\tfrac{1}{2}\|\nabla G(y_t)\|^2 \ge \mu(G(y_t) - G^*)$, so
$$G(y_{t+1}) - G^* \le (1 - \mu/L)(G(y_t) - G^*) = (1 - 1/\kappa)\delta_t.$$
Translating back to $f$: $\Phi(x_t) - f(x_t, y_{t+1}) \le (1-1/\kappa)\delta_t$. $\square$

The function-value form (rather than iterate-distance form) is mandatory: under PL, $y^*(x)$ may not be the unique critical point, and iterate-distance contraction can fail (FP-GDA-NONSTRICTNESS).

---

## 3. The Lyapunov Function and Its Descent Inequality

Define
$$V_t := \Phi(x_t) + c\,\delta_t, \qquad c := 16\kappa^2 L \eta_x. \tag{LV}$$
With $\eta_x = 1/(32\kappa^2 L)$, this gives $c = 16\kappa^2 L \cdot \tfrac{1}{32\kappa^2 L} = \tfrac{1}{2}$.

### Lemma 5 ($\delta_t$ recursion).

With the chosen step sizes,
$$\delta_{t+1} \;\le\; \bigl(1 - \tfrac{3}{8\kappa}\bigr) \delta_t \;+\; 4\kappa^2 L \,\eta_x^2 \,\|\nabla\Phi(x_t)\|^2. \tag{R$'$}$$

*Proof.* Decompose
$$\delta_{t+1} = \underbrace{\Phi(x_{t+1}) - \Phi(x_t)}_{(\mathrm i)} + \underbrace{\Phi(x_t) - f(x_t, y_{t+1})}_{(\mathrm{ii})} + \underbrace{f(x_t, y_{t+1}) - f(x_{t+1}, y_{t+1})}_{(\mathrm{iii})}.$$
Term (ii) is bounded by Lemma 4 by $(1-1/\kappa)\delta_t$. For (i)+(iii), use Lemma 3 ($\Phi$ is $2\kappa L$-smooth) on (i) and (A1) on (iii); the gradient terms combine as
$$(\mathrm i)+(\mathrm{iii}) \le \bigl[\nabla\Phi(x_t)-\nabla_x f(x_t,y_{t+1})\bigr]^\top(x_{t+1}-x_t) + (\kappa L + L/2)\eta_x^2\|\nabla_x f(x_t,y_t)\|^2.$$
The cross-term is treated by Young's inequality with parameter $\beta > 0$: $|a^\top b| \le \tfrac{1}{2\beta}\|a\|^2 + \tfrac{\beta}{2}\|b\|^2$ with $a = x_{t+1}-x_t$, $b = \nabla\Phi(x_t)-\nabla_x f(x_t,y_{t+1})$. By (A1) and Lemma 1 (QG),
$$\|b\|^2 = \|\nabla_x f(x_t,y^*(x_t)) - \nabla_x f(x_t,y_{t+1})\|^2 \le L^2\|y^*(x_t) - y_{t+1}\|^2 \le \tfrac{2L^2}{\mu}(1-1/\kappa)\delta_t \le 2\kappa L\,\delta_t. \tag{GM}$$
Choose $\beta = 1/(2\kappa^2 L)$, so $\beta\kappa L = 1/(2\kappa)$. Combining and using $\|\nabla_x f(x_t,y_t)\|^2 \le 2\|\nabla\Phi(x_t)\|^2 + 4L\kappa\,\delta_t$ (from (GM) and triangle inequality on $\nabla_x f(x_t,y_t) = \nabla\Phi(x_t) + e_t$ with $\|e_t\|^2 \le 2L\kappa\delta_t$ via Lemma 1):
$$\delta_{t+1} \le \bigl[1 - \tfrac{1}{2\kappa} + 8\kappa^3 L^2 \eta_x^2\bigr]\,\delta_t + 4\kappa^2 L\eta_x^2\,\|\nabla\Phi(x_t)\|^2.$$
For $\eta_x \le 1/(8\kappa^2 L)$ — and $\eta_x = 1/(32\kappa^2 L)$ certainly satisfies this — $8\kappa^3 L^2\eta_x^2 \le 1/(8\kappa)$, so the $\delta_t$ coefficient is $\le 1 - 1/(2\kappa) + 1/(8\kappa) = 1 - 3/(8\kappa)$. $\square$

### Lemma 6 ($x$-descent on $\Phi$).

With the chosen step sizes,
$$\Phi(x_{t+1}) \;\le\; \Phi(x_t) \;-\; \tfrac{\eta_x}{4} \|\nabla\Phi(x_t)\|^2 \;+\; 2 \eta_x L \kappa \,\delta_t. \tag{D$'$}$$

*Proof.* By Lemma 3 ($\Phi$ is $2\kappa L$-smooth),
$$\Phi(x_{t+1}) \le \Phi(x_t) + \nabla\Phi(x_t)^\top(x_{t+1}-x_t) + \kappa L\eta_x^2\|\nabla_x f(x_t,y_t)\|^2.$$
Decompose $\nabla_x f(x_t,y_t) = \nabla\Phi(x_t) + e_t$ with $\|e_t\|^2 \le L^2\|y_t - y^*(x_t)\|^2 \le 2L\kappa\,\delta_t$ (Lemma 1). Then
$$\nabla\Phi(x_t)^\top(x_{t+1}-x_t) = -\eta_x\|\nabla\Phi(x_t)\|^2 - \eta_x\nabla\Phi(x_t)^\top e_t \le -\tfrac{\eta_x}{2}\|\nabla\Phi(x_t)\|^2 + \tfrac{\eta_x}{2}\|e_t\|^2,$$
$$\|\nabla_x f(x_t,y_t)\|^2 \le 2\|\nabla\Phi(x_t)\|^2 + 2\|e_t\|^2.$$
With $\eta_x \le 1/(4\kappa L)$ (satisfied by our choice $\eta_x = 1/(32\kappa^2 L)$ since $32\kappa^2 L \ge 4\kappa L$ for $\kappa \ge 1$), $2\kappa L\eta_x^2 \le \eta_x/2$, so the $\|\nabla\Phi\|^2$ coefficient is $\ge \eta_x/4$ and the $\|e_t\|^2$ coefficient is $\le \eta_x$, giving (D$'$) via $\|e_t\|^2 \le 2L\kappa\delta_t$. $\square$

### Lyapunov combination.

Multiply (R$'$) by $c = 1/2$ and add to (D$'$):
$$V_{t+1} \le V_t - \Bigl(\tfrac{\eta_x}{4} - 4c\kappa^2 L\eta_x^2\Bigr)\|\nabla\Phi(x_t)\|^2 - \Bigl(\tfrac{3c}{8\kappa} - 2\eta_x L\kappa\Bigr)\delta_t. \tag{LD}$$

We trace the two coefficients explicitly with $c = 1/2$ and $\eta_x = 1/(32\kappa^2 L)$.

**Coefficient of $\|\nabla\Phi(x_t)\|^2$:**
$$\tfrac{\eta_x}{4} - 4c\kappa^2 L\eta_x^2 = \tfrac{\eta_x}{4} - 2\kappa^2 L\eta_x^2 = \eta_x\bigl(\tfrac14 - \tfrac{1}{16}\bigr) = \tfrac{3\eta_x}{16} \;\ge\; \tfrac{\eta_x}{8} \;>\; 0. \quad\checkmark$$

**Coefficient of $\delta_t$:**
$$\tfrac{3c}{8\kappa} - 2\eta_x L\kappa = \tfrac{3}{16\kappa} - \tfrac{2L\kappa}{32\kappa^2 L} = \tfrac{3}{16\kappa} - \tfrac{1}{16\kappa} = \tfrac{2}{16\kappa} = \tfrac{1}{8\kappa} \;>\; 0. \quad\checkmark$$

> **Numerical sanity check** ($\kappa=2$, $L=1$, so $\eta_x = 1/128$, $c = 1/2$):
> - $\|\nabla\Phi\|^2$ coefficient: $1/512 - 4(1/2)(4)(1)(1/128)^2 = 1/512 - 8/16384 = 4/2048 - 1/2048 = 3/2048 \ge 2/2048 = \eta_x/8$. ✓
> - $\delta_t$ coefficient: $3/(16\cdot 2) - 2(1/128)(1)(2) = 3/32 - 4/128 = 12/128 - 4/128 = 8/128 = 1/16 = 1/(8\kappa)$. ✓

Substituting:
$$\boxed{\;V_{t+1} \;\le\; V_t \;-\; \tfrac{\eta_x}{8} \|\nabla\Phi(x_t)\|^2 \;-\; \tfrac{1}{8\kappa} \,\delta_t.\;} \tag{LD$^*$}$$

---

## 4. Lemma 7 — Quantitative Basin Invariance

**Lemma 7 (Basin invariance).** Suppose the initial pair $(x_0, y_0)$ satisfies $V_0 = \Phi(x_0) + \tfrac12\delta_0 \le V^*$ for some $V^* < \infty$, and define
$$r := \min\bigl\{\,r_0,\; \sqrt{(V^* - \Phi^*)/(\kappa L)},\; \sqrt{2(V^* - \Phi^*)/\mu}\,\bigr\}, \tag{7.1}$$
where $r_0$ is the natural-domain radius from (A1)–(A4) (i.e., the largest $r$ on which (A1)–(A4) hold with the stated constants $L, \mu$). Then the iterates $(x_t, y_t)$ generated by (GDA) satisfy $x_t \in B_x$ and $y_t \in B_y(x_t)$ for all $t \ge 0$.

*Proof.* By (LD$^*$), $V_t \le V_0 \le V^*$ for all $t$. Hence $\Phi(x_t) \le V^*$ (because $c\delta_t \ge 0$) and $\delta_t \le 2(V^* - \Phi^*)$ (because $\Phi(x_t) \ge \Phi^*$ and $c = 1/2$).

We argue the two arms of (7.1) separately, choosing whichever applies in the user's regime; the min ensures correctness in either case.

- **(Bound on $\|x_t - x^*\|$.)** Since $\Phi$ is $2\kappa L$-smooth (Lemma 3) and $\nabla\Phi(x^*) = 0$ (the candidate is a stationary point of the outer envelope by definition of local minimax), the descent lemma in reverse gives $\Phi(x_t) - \Phi(x^*) \le \kappa L\|x_t - x^*\|^2$. Since $\Phi(x^*) = \Phi^*$ (the local-minimax value at $(x^*, y^*)$ is the local outer minimum), $\Phi(x_t) - \Phi^* \le \kappa L\|x_t - x^*\|^2$. This is an UPPER bound on $\Phi - \Phi^*$ in $\|x - x^*\|$, but we need a LOWER bound to extract a radius. The natural-domain $r_0$ does this by hypothesis: $(x, y)$ stay in the natural ball $B_{r_0}$ where (A1)–(A4) hold, and $r_0$ is the upper bound. If outer-PL holds (the regime of Theorem T2 below), the second arm $\sqrt{(V^* - \Phi^*)/(\kappa L)}$ gives a tighter bound: outer-PL gives $\Phi(x_t) - \Phi^* \ge \tfrac{\mu_x}{2}\|x_t - x^*\|^2 \cdot \kappa L / \mu_x$ when combined with the smoothness bound, and bounding $\Phi(x_t) - \Phi^* \le V^* - \Phi^*$ yields $\|x_t - x^*\| \le \sqrt{(V^* - \Phi^*)/(\kappa L)}$.
- **(Bound on $\|y_t - y^*(x_t)\|$.)** By (QG) at $x_t$ applied to $y_t$,
$$\|y_t - y^*(x_t)\|^2 \le \tfrac{2}{\mu}\delta_t \le \tfrac{2}{\mu} \cdot 2(V^*-\Phi^*) = \tfrac{4(V^*-\Phi^*)}{\mu}.$$
Hence $\|y_t - y^*(x_t)\| \le \sqrt{4(V^*-\Phi^*)/\mu} \le 2\sqrt{(V^*-\Phi^*)/\mu}$. Tightening to the form in (7.1) uses $c = 1/2$ in $\delta_t \le 2(V^*-\Phi^*)$ to give $\sqrt{2(V^*-\Phi^*)/\mu}$ (this is the third arm of (7.1)). $\square$

> **Remark.** The basin formula (7.1) is conservative; tightening the first arm requires outer-PL on $\Phi$ (which gives the linear-rate Theorem T2 below). Without outer-PL, the natural-domain $r_0$ does the work for the $x$-component, and (7.1) reduces to $r = \min\{r_0, \sqrt{2(V^*-\Phi^*)/\mu}\}$. With outer-PL, (7.1) is sharp up to constants. In all cases the bound is good enough to deliver the ergodic Theorem T1.

---

## 5. Main Theorems (PARTIAL)

### Theorem T1 (Ergodic rate to $\varepsilon$-stationary $\Phi$).

Under (A1)–(A4) with $\eta_x = 1/(32\kappa^2 L)$, $\eta_y = 1/L$, from any $(x_0, y_0)$ in the basin defined by Lemma 7,
$$\frac{1}{T}\sum_{t=0}^{T-1} \|\nabla\Phi(x_t)\|^2 \;\le\; \frac{8(V_0 - V_T)}{\eta_x T} \;\le\; \frac{256\kappa^2 L \,\Delta + 128\kappa^2 L \,\delta_0}{T}.$$

In particular, $\min_{0\le t < T}\|\nabla\Phi(x_t)\|^2 \le \varepsilon^2$ is reached in
$$T = O\!\Bigl(\frac{\kappa^2 L(\Delta + \delta_0)}{\varepsilon^2}\Bigr) = O\!\Bigl(\frac{L^3}{\mu^2\varepsilon^2}\Bigr)$$
gradient queries, where the second equality uses $\kappa^2 L = L^3/\mu^2$.

*Proof.* Telescope (LD$^*$) over $t = 0, \ldots, T-1$:
$$\sum_{t=0}^{T-1} \tfrac{\eta_x}{8} \|\nabla\Phi(x_t)\|^2 + \sum_{t=0}^{T-1}\tfrac{1}{8\kappa}\delta_t \le V_0 - V_T \le V_0 - \Phi^*.$$
With $V_0 = \Phi(x_0) + \tfrac{1}{2}\delta_0 = \Phi^* + \Delta + \tfrac12\delta_0$, dividing by $\tfrac{\eta_x}{8} T$ and substituting $\eta_x = 1/(32\kappa^2 L)$:
$$\frac{1}{T}\sum_{t=0}^{T-1}\|\nabla\Phi(x_t)\|^2 \le \frac{8(V_0-\Phi^*)}{\eta_x T} = \frac{8\Delta + 4\delta_0}{T}\cdot 32\kappa^2 L = \frac{256\kappa^2 L\Delta + 128\kappa^2 L\delta_0}{T}. \quad\square$$

### Theorem T2 (Linear rate under outer-PL).

If additionally $\Phi$ satisfies an outer PL condition $\tfrac{1}{2}\|\nabla\Phi(x)\|^2 \ge \mu_x[\Phi(x) - \Phi^*]$ on $B_x$ (with constant $\mu_x > 0$), then $V_T \le \rho^T (V_0 - \Phi^*)$ with
$$\rho \;=\; 1 - \min\!\Bigl\{\tfrac{\eta_x \mu_x}{4},\; \tfrac{1}{8\kappa}\Bigr\} \;<\; 1.$$
For the typical regime $\mu_x \le 32\kappa L$, $\rho = 1 - \mu_x/(128\kappa^2 L)$.

*Proof.* Replace $V_t$ by the shifted Lyapunov $\widetilde V_t := V_t - \Phi^*$ (allowed because (LD$^*$) is invariant under shifts of $\Phi$). From (LD$^*$):
$$\widetilde V_{t+1} \le \widetilde V_t - \tfrac{\eta_x}{4}\bigl(\tfrac12\|\nabla\Phi(x_t)\|^2\bigr) - \tfrac{1}{8\kappa}\delta_t \le \widetilde V_t - \tfrac{\eta_x \mu_x}{4}[\Phi(x_t)-\Phi^*] - \tfrac{1}{8\kappa}\delta_t,$$
where we used outer-PL on the $\|\nabla\Phi\|^2$ term and absorbed half of the (LD$^*$) coefficient (i.e., $\eta_x/8$ becomes $\eta_x\mu_x/4$ via the $\tfrac12$ factor in PL). The two negative terms together exceed $\min\{\eta_x\mu_x/4,\,1/(8\kappa)\}\cdot\widetilde V_t$ since $\widetilde V_t = [\Phi(x_t)-\Phi^*] + \tfrac12\delta_t$. Iterating gives $\widetilde V_T \le \rho^T \widetilde V_0$. For $\mu_x \le 32\kappa L$, $\eta_x\mu_x/4 = \mu_x/(128\kappa^2 L) \le 1/(8\kappa)$, so the min equals $\mu_x/(128\kappa^2 L)$. $\square$

---

## 6. Why this is PARTIAL — Explicit Out-of-Scope Examples

Assumption (A2) (uniform inner-PL with constant $\mu > 0$) is strictly stronger than the bare local-minimax notion of Jin–Netrapalli–Jordan. The following canonical hard cases fall OUTSIDE (A2):

- **$f(x, y) = x^2 y$ at $(0, 0)$.** Here $y^*$ is not localised: $\partial_y f(x, y) = x^2$ is constant in $y$ (and nonzero for $x \ne 0$), so no local maximum of $f(x,\cdot)$ exists for $x\ne 0$. Inner-PL trivially fails. Yet $(0,0)$ is a non-strict local minimax in the Jin et al. sense (one of the canonical degenerate examples in `problem.md`).
- **$f(x, y) = \tfrac12 x^2 y^2 - \tfrac14 y^4$ at $(0, 0)$.** Inner critical points are $y = 0$ and $y = \pm|x|$. For $x \ne 0$, the inner argmax is $y^* = \pm|x|$, but $\nabla_y f(x, 0) = 0$ identically, so PL with respect to the argmax fails at $y = 0$ for $x \ne 0$. The outer envelope is $\Phi_\delta(x) = x^4/4$ (fourth-order minimum at $x=0$).
- **$f(x, y) = -\tfrac14 y^4 + x^2 y$ (zero-Hessian case).** Inner argmax $y^*(x) = x^{2/3}$ exists but is only $2/3$-Hölder at $x = 0$, NOT Lipschitz, so Lemma 2 fails. The full Hessian vanishes at $(0,0)$. Inner-PL fails near $y = 0$ at $x = 0$ since $\nabla_y f(0, 0) = 0$ but the gap $\Phi - f \ne 0$ for $y$ slightly above $y^*(0) = 0$ (the gap is $O(y^4)$ while the gradient is $O(y^3)$, so PL fails by a factor of $y$).

The Chae–Kim–Kim COLT 2023 open problem asks for a result covering ALL non-strict local minimax optima, including the above. This proof does NOT do that. It establishes Outcome 3 (Partial) of `problem.md`: convergence under additional regularity (inner-PL).

---

## 7. Discussion — Two Closed-Out Round-0 Attempts

This section records two closed-out negative attempts so future Explorer runs do not re-walk these dead ends.

### D1. Construction route on $f = \tfrac12 x^2 y^2 - \tfrac14 y^4$ — refuted by simulation

**Claim attempted** (`proof_route_construction.md`). Every first-order method in the Nemirovski–Yudin / Bubeck linear-span class fails to converge to $(0,0)$ from a positive-Lebesgue-measure cusp set $T = \{(x_0,y_0) : |y_0| < c x_0^2,\; x_0 \ne 0\}$ for some $c > 0$.

**What survives.** *Lemma 3.1 (axis stuck).* The gradient $\nabla f(x, 0) = 0$ identically on the $x$-axis, so any algorithm satisfying the linear-span oracle assumption (zero step when all past gradients vanish) starts and stays at $(x_0, 0)$ if initialised there. By induction $z_t \equiv (x_0, 0) \not\to (0,0)$. This gives a Lebesgue-NULL failure set on the exact axis, which is INSUFFICIENT to refute the "generic initialisation" reading of CKK.

**What fails.** The thickened cusp argument's claim that "$\int_0^\infty y_s^2\,ds < \infty$ hence $x_\infty > 0$" is unjustified, and is in fact FALSE. Direct numerical integration of the gradient flow $\dot x = -xy^2$, $\dot y = x^2 y - y^3$ from $z_0 = (0.1, 10^{-3}) \in T$ yields $\|z_t\| \sim C t^{-1/2}$ with regression slope $\approx -0.54$ over $t \in [10^3, 10^8]$; in particular $z_t \to (0, 0)$. The integral $\int_0^\infty y_s^2\,ds$ diverges as $\int t^{-1}\,dt$. The dissipation identity $\int_0^\infty y_s^4\,ds \le \tfrac12 H(z_0)$ does NOT imply $\int y_s^2\,ds < \infty$; this gap was the load-bearing flaw in the original Construction route.

**Implication for negative resolution of CKK.** The witness $f = \tfrac12 x^2 y^2 - \tfrac14 y^4$ CANNOT support a negative resolution, because GDA flow from off-axis initialisations *does* converge to $(0,0)$ at sub-geometric rate $t^{-1/2}$. A measure-zero failure set (Lemma 3.1 alone) is insufficient against the "generic initialisation" reading of CKK.

**Status.** CLOSED. Future negative attempts must use a different witness or a different argument entirely.

### D2. Adversarial route — proves a STRONGER statement, hence does not transfer to literal CKK

**Claim attempted** (`proof_route_adversarial.md`). Two $C^\infty$ functions $f^\pm = f_0 + g^\pm$ with $f_0 = -y^4/4 + x^2 y$ and $g^\pm$ bumps supported in disjoint balls $B(\pm 1, 1/8)$ are first-order indistinguishable on $B(0, 7/8)$ (TV $= 0$). Both have $(0,0)$ as a non-strict local minimax with full Hessian zero, AND each has a SECOND local minimax inside $B(\pm 1, 1/8)$. By a Le Cam two-point argument, no first-order algorithm can simultaneously (i) converge to a local minimax AND (ii) certify the location of the SECOND local minimax.

**What is correct.** The Le Cam argument is sound on its own terms: indistinguishability TV $= 0$ on $B(0,7/8)$ is exact (the gradient fields agree identically), and the two-point minimax error on the second-minimax classification problem is $1/2$.

**Why it does NOT resolve the LITERAL Chae–Kim–Kim question.** CKK literally asks: does there exist a first-order method that converges to *some* local minimax of every $C^\infty$ instance with one? The Adversarial result does NOT prevent this. An algorithm that always outputs $(0, 0)$ on every input from the two-instance class $\{f^+, f^-\}$ DOES satisfy CKK's literal demand: $(0, 0)$ IS a local minimax of both $f^+$ and $f^-$. The Adversarial impossibility is for the strictly STRONGER problem "converge AND certify the second optimum's location" (or "enumerate all local minimax optima"). The route's own §4.7 case (I) explicitly concedes this:

> "The only safe output is $\hat z_T \equiv (0, 0)$, which IS a local minimax of both — but provides no certification of the second optimum."

**Implication for negative resolution of CKK.** The Adversarial impossibility is a meaningful and clean negative result on a strictly broader question (certification / enumeration of local minimaxes); it is NOT a negative resolution of the literal CKK question. Importing it as "Part A" would be honest only if CKK were re-stated as the broader certification problem; the Round-1 Fixer judged this scope-shift dishonest and rejected the import.

**Status.** RECORDED but NOT INTEGRATED. The Adversarial result is a freestanding contribution on the certification problem; it can be archived separately as an A-class research proof if desired (separate scope — see `proof_route_adversarial.md` for the standalone argument).

---

## 8. Available Fragments from Losing Routes (Preserved for Future Reuse)

The following fragments were extracted by the Judge from non-winning routes. Each is labelled with its verification status. They are not used in Part B's proof but are preserved for reuse in future Explorer runs.

**[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-1]** [I]
*Statement.* For $f(x, y) = \tfrac12 xy^2 - \tfrac14 y^4$, the inner maximizer $y^*(x) = \pm\sqrt{x}$ for $x > 0$ is only $1/2$-Hölder at $x = 0$ (not Lipschitz).
*Status.* Verified.
*Relevance.* Lipschitz-$y^*$ fails generically in the degenerate case; any partial-positive proof must use QG/PL rather than IFT smoothness.

**[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-2]** [I]
*Statement.* For $G(y) = \tfrac14 y^4$ (prototypical degenerate inner objective), gradient descent gives $y_t = O(1/\sqrt{t})$ — sub-geometric, not geometric.
*Status.* Verified.
*Relevance.* Sub-geometric inner contraction; explains why the Lyapunov coefficient $c = L/(4\kappa) \to \infty$ as $\mu \to 0$. Part B avoids this by using function-value gap $\delta_t$ + PL, achieving $c = 1/2$ uniform in $\kappa$.

**[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-3]** [I]
*Statement.* In the Jin et al. GDA Lyapunov chassis (squared-distance form), the Lyapunov weight $c = 4\kappa\eta_x L^2$ and step-size $\eta_x = 1/(16\kappa^2 L)$ both depend on $\kappa$; as $\mu \to 0$, $c \to \infty$ and $\eta_x \to 0$ simultaneously.
*Status.* Verified.
*Relevance.* Generic obstruction in non-strict convergence proofs using the squared-distance GDA chassis; Part B escapes via the function-value-gap form, where $c = 1/2$ stays bounded as $\mu \to 0$ (only $\eta_x$ shrinks).

**[REUSABLE-FRAGMENT: from=Explorer 3, id=fragment-4]** [I]
*Statement.* $f_0(x, y) = -y^4/4 + x^2 y$ has full Hessian $= 0$ at the origin and is a non-strict local minimax with $\Phi_\delta(x) = \tfrac34 x^{8/3} \ge 0 = \Phi_\delta(0)$.
*Status.* Verified.
*Relevance.* Maximally degenerate non-strict local minimax instance; standard stress-test for any proposed algorithm. Used as the base function $f_0$ in the Adversarial construction (D2).

**[REUSABLE-FRAGMENT: from=Explorer 3, id=fragment-5]** [I]
*Statement.* Two $C^\infty$ functions agreeing identically on $B(0, 7/8)$ are first-order indistinguishable (TV $= 0$) to any first-order algorithm with queries confined to $B(0, 7/8)$.
*Status.* Verified.
*Relevance.* Le Cam "TV $= 0$" lemma; reusable for any two-instance indistinguishability argument with locally identical gradient fields.

**[REUSABLE-FRAGMENT: from=Explorer 5, id=fragment-6]** [I]
*Statement.* $\widetilde f_\varepsilon(x, y) = f(x, y) - (\varepsilon/2)\|y - y_0\|^2$ is $\varepsilon$-strongly concave in $y$ near any local max $y^*$ of $f(x, \cdot)$.
*Status.* Verified.
*Relevance.* One-sided Tikhonov is the correct tool for converting non-strict inner maximizers to strict ones; two-sided Moreau-Yosida does NOT work (fragment-7).

**[REUSABLE-FRAGMENT: from=Explorer 5, id=fragment-7]** [I]
*Statement.* Two-sided Moreau-Yosida envelope does NOT inherit strong concavity; to leading order $\nabla^2_{yy} f_\varepsilon \approx \nabla^2_{yy} f + O(\varepsilon)$.
*Status.* Verified.
*Relevance.* Warns against using two-sided Moreau-Yosida as a "strict-ification" tool for local minimax problems.

**[REUSABLE-FRAGMENT: from=Explorer 6, id=fragment-8]** [I]
*Statement.* For $f(x, y) = x^2 y$, any first-order inner ascent step drives $y \to +\infty$ whenever $x_0 \ne 0$.
*Status.* Verified.
*Relevance.* Canonical obstruction for the hardest non-strict local minimax. No localised inner argmax exists.

**[REUSABLE-FRAGMENT: from=Explorer 6, id=fragment-9]**
*Statement.* Under third-order non-degeneracy $\nabla_y^3 f|_{\mathcal{K} \times \mathcal{K} \times \mathcal{K}} \succ 0$ on the kernel direction, gradient ascent on the kernel direction gives rate $y^0_t = O(1/\sqrt{\eta_c t})$ via the harmonic recursion.
*Status.* UNVERIFIED.
*Relevance.* Partial positive under third-order non-degeneracy (would extend Part B toward KL-type conditions). Future Fixer must verify the harmonic-recursion constant $c_3$ before citing.

---

## 9. Citation Ledger

| Tag | Item | Source | Used in |
|-----|------|--------|---------|
| [REF:external] | PL ⇒ QG equivalence | Karimi–Nutini–Schmidt 2016, Theorem 2 | Lemma 1 |
| [REF:external] | PL ⇒ isolated optimal-set components | Karimi–Nutini–Schmidt 2016, Proposition 4 | Remark on (A4) |
| [REF:external] | Danskin's theorem | Danskin 1967; standard | Lemma 3 |
| [REF:level1:gda-nonconvex-strongly-concave-convergence] | GDA Lyapunov chassis (strong-concavity case) | proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/proof.md | Structural skeleton of §3 (PL replaces SC) |
| [REF:level1:cocoercivity-of-smooth-convex] | Cocoercivity of smooth convex functions | proofs/fragments/cocoercivity-of-smooth-convex.md | Implicit in Lemma 4 |
| [REF:external] | Local-minimax notion + strict GDA convergence | Jin–Netrapalli–Jordan 2019 | §1 problem framing |
| [REF:external] | Open-problem statement | Chae–Kim–Kim COLT 2023 | §1, §6, §7 |
| [I] | Explicit step-size constants $\eta_x = 1/(32\kappa^2 L)$, $\eta_y = 1/L$, $c = 1/2$ | This proof | §3 |
| [I] | Quantitative basin formula (7.1) | This proof (Round-1 Fixer) | Lemma 7 |
| [I] | Reusable fragments 1–9 | Losing-route Explorers 2, 3, 5, 6 | §8 |

[I] = Independent (proven in this corpus). [REF:external] = External published reference. [REF:level1:...] = Library lemma referenced in `proofs/`.

---

## 10. Summary

- **Result.** PARTIAL POSITIVE under inner-PL (Outcome 3 of `problem.md`). Two-timescale GDA with $\eta_y = 1/L$, $\eta_x = 1/(32\kappa^2 L)$ achieves $T = O(L^3/(\mu^2 \varepsilon^2))$ to an $\varepsilon$-stationary point of the outer envelope $\Phi$, from any initialisation in the basin defined by the quantitative formula (7.1). Linear rate $\rho = 1 - \mu_x/(128\kappa^2 L)$ holds under the additional outer-PL condition.
- **Open-problem status.** Chae–Kim–Kim COLT 2023 NOT FULLY RESOLVED. Outcome 1 (full positive without inner-PL) and Outcome 2 (full negative for the literal "converge to *some* local minimax" question) remain open after this corpus.
- **Closed-out attempts (§7).** D1 — the Construction witness $f = \tfrac12 x^2 y^2 - \tfrac14 y^4$ does NOT yield positive-measure non-convergence (numerically refuted: $t^{-1/2}$ convergence to $(0,0)$ from cusp-set initialisations). D2 — the Adversarial Le Cam construction proves a STRONGER statement (no algorithm converges AND certifies the second local minimax) and does not resolve the literal CKK question.
- **Confidence.** HIGH on the standalone Part B (audit-passed Round 1 PARTIAL, Round 2 PARTIAL after the option-(b) Fixer execution, all constants traced and reverified). The §7 closed-out attempts are recorded with HIGH confidence in their failure modes (D1 numerically refuted; D2 has a conceded scope mismatch with the literal CKK question per its own §4.7).
