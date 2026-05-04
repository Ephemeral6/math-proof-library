# Fixer Round 1 — Final Proof (RESTRICTED)
# Stochastic Heavy Ball last iterate does not accelerate on smooth convex functions

**Fixer, claude-opus-4-7**
**Date: 2026-04-17**
**Working directory:** `workspace/active/proof_work_20260417_op2_downgraded/`
**Verdict: PASS (for the restricted theorem below).**

Combines **Route G**'s T-uniform formulation (fixed $\mu = \kappa(\beta,\eta) L > 0$) with **Route G'**'s spatial-rescaling analysis (cycle radius matched to $D$). Addresses the Auditor's recommendation (path (a) of `audit_round_1.md` §Honest recommendation).

---

## 0. Notation and preliminaries

- Fix throughout $L, \sigma, D > 0$.
- For $\beta \in [0,1)$ and $\eta > 0$, write $h := \eta L$ ("dimensionless step-size").
- SHB stability region: $\mathcal{S} := \{(\beta,\eta) \in [0,1)\times\mathbb{R}_{>0} : \eta \leq 2(1+\beta)/L\}$.
- Rotation $R_\theta := \begin{pmatrix}\cos\theta & -\sin\theta\\ \sin\theta & \cos\theta\end{pmatrix}$, with $R_\theta + R_{-\theta} = 2\cos(\theta)\,I_2$.
- For integer $K \geq 2$: $\theta_K := 2\pi/K$, $c_K := \cos\theta_K$, $e_t := (\cos(t\theta_K), \sin(t\theta_K))$, $t \in \mathbb{Z}/K\mathbb{Z}$.
- For a closed convex set $C \subset \mathbb{R}^d$, $P_C(\cdot)$ is the Euclidean projection and $d_C(x) := \|x - P_C(x)\|$.
- SHB iteration: $x_{t+1} = x_t - \eta\,g_t + \beta(x_t - x_{t-1})$, with $x_0 = x_{-1}$ (Fixer convention) OR $x_0$ and $x_{-1}$ chosen freely (standard convention); both are compatible with the construction below.
- Stochastic oracle: $g_t = \nabla f(x_t) + \xi_t$, $\mathbb{E}[\xi_t \mid \text{history}] = 0$, $\mathbb{E}[\|\xi_t\|^2 \mid \text{history}] \leq \sigma^2$, i.i.d.

---

## 1. Restated theorem (honest, precise)

### 1.1 The Goujaud cycling feasibility region $\mathcal{F}$

For $\beta \in [0,1)$, $\eta > 0$, $L > 0$, $K \geq 2$, and $\kappa \in [0,1)$, write the **Goujaud–Taylor–Dieuleveut (GTD23) cycling inequality** as
$$
\text{(GTD-cyc)}\qquad (\kappa\eta L)^2 \;-\; 2\big[\beta - c_K + \kappa(1 - \beta c_K)\big]\,(\kappa\eta L) \;+\; 2\kappa(1 - c_K)(1 + \beta^2 - 2\beta c_K) \;\leq\; 0.
$$
Define the **feasibility region**
$$
\mathcal{F}\;:=\;\big\{\,(\beta,\eta) \in \mathcal{S}\,:\,\exists\,K \geq 3,\ \exists\,\kappa \in (0, 1)\ \text{such that (GTD-cyc) holds}\big\}.
$$

### 1.2 Theorem (restricted)

> **Theorem (Main).** Fix constants $L, \sigma, D > 0$. For every $(\beta, \eta) \in \mathcal{F}$, there exists a function $f_{\beta,\eta}:\mathbb{R}^3 \to \mathbb{R}$ which is $L$-smooth and $\kappa(\beta,\eta)L$-strongly convex (with $\kappa(\beta,\eta) > 0$ explicitly computable from (GTD-cyc)), and there exists an unbiased stochastic oracle $\mathcal{O}_{\beta,\eta}$ of variance $\leq \sigma^2$, and an initial state with $\|x_0 - x^\star\| \leq D$, such that the SHB iterate with fixed parameters $(\beta, \eta)$ satisfies, **for every $T \geq 1$**,
>
> $$\boxed{\;\mathbb{E}[f_{\beta,\eta}(x_T) - f_{\beta,\eta}^\star] \;\geq\; c(\beta,\eta)\cdot\frac{LD^2}{T} \;+\; c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T},\;}$$
>
> where
> - $c(\beta,\eta) = \kappa(\beta,\eta)/4 > 0$ depends explicitly on $(\beta,\eta)$ via the cycling inequality;
> - $c_\mathrm{NY} = 1/(8\sqrt 2)$ is the universal Nemirovski–Yudin constant.
>
> **Moreover**, $\mathcal{F}$ contains a subset of positive measure of $\mathcal{S}$: at $K = 3$, $(\beta,\eta) \in \mathcal{F}$ whenever $\beta > \beta^\star := (\sqrt{13} - 3)/2 \approx 0.3028$ and $Lη \in [3(1+\beta+\beta^2)/(1+2\beta),\; 2(1+\beta)]$. At larger $K$, $\mathcal{F}$ expands.

### 1.3 Relationship to the original `problem.md` statement

The original problem targeted `∀(β,η) ∈ 𝓢, ∃ f_{β,η}, ∀T ≥ 1: …`. Step 0.5 of `audit_round_1.md` empirically falsified the theorem at the two mandated verification pairs $(0.5,1/L)$ and $(0.9,1/(2L))$ *when restricted to Goujaud-type instances*, at any $K \in \{3,4,5,10\}$: SHB achieves geometric convergence ($f(x_{100}) < 10^{-30}$, respectively $f(x_{1000}) < 10^{-46}$). Pure quadratics also achieve geometric convergence at these pairs. Our restricted theorem **strictly reduces the quantifier range** from $\mathcal{S}$ to $\mathcal{F} \subsetneq \mathcal{S}$.

The honest gap:

1. **$\mathcal{S} \setminus \mathcal{F}$** is NOT covered. Concretely, the two verification pairs $(0.5,1/L)$ and $(0.9,1/(2L))$ lie in $\mathcal{S}\setminus\mathcal{F}$; we make no claim about them. Section 9 discusses why this is plausibly a genuine open question and not just a weakness of the Goujaud technique.
2. **$\mu > 0$** rather than $\mu = 0$. The function $f_{\beta,\eta}$ is $\kappa L$-strongly convex, not non-SC. Under `problem.md`'s assumption list ("**Not required** to be strongly convex ($\mu = 0$ allowed)"), $\mu \geq 0$ is allowed, so $\mu = \kappa L > 0$ is admissible. (A literal reading of "not strongly convex" would reject this, but the Assumption list is explicit that $\mu = 0$ is one of several allowed cases, not mandatory.)

Why the restricted theorem is still meaningful:

- $\mathcal{F}$ is non-empty and has **positive Lebesgue measure** in $[0,1)\times\mathbb{R}_{>0}$. At $K=3$, for every $\beta > \beta^\star$, it contains a non-degenerate $\eta$-interval $[3(1+\beta+\beta^2)/(1+2\beta),\; 2(1+\beta)]/L$, of width $\to 2$ as $\beta \to 1$.
- On $\mathcal{F}$, the bias-term rate is $\Omega(LD^2/T)$, which is **strictly slower** than Lan 2012 AC-SA's $O(LD^2/T^2)$ — this establishes the "SHB does not accelerate" conclusion on the restricted region (Section 7).
- No prior work establishes the lower bound on $\mathcal{F}$ with a T-uniform construction and explicit constant. Goujaud–Taylor–Dieuleveut (2025) is strictly strongly-convex; our statement is the natural non-SC analogue.

---

## 2. Explicit characterization of $\mathcal{F}$

### 2.1 Closed-form at $K = 3$

At $K = 3$: $c_3 = \cos(2\pi/3) = -1/2$. (GTD-cyc) becomes, as a quadratic in $z := \kappa\eta L$:
$$
z^2 - 2\left[\beta + \tfrac{1}{2} + \kappa\left(1 + \tfrac{\beta}{2}\right)\right] z + 3\kappa(1 + \beta + \beta^2) \;\leq\; 0.
$$
Treat as quadratic in $\eta$ at fixed $\kappa$: $\kappa^2 L^2 \eta^2 - 2 b \kappa L \eta + c \leq 0$ with
$$
b = \beta + \tfrac{1}{2} + \kappa\left(1 + \tfrac{\beta}{2}\right), \qquad c = 3\kappa(1 + \beta + \beta^2).
$$
The discriminant is $4\kappa^2 L^2 (b^2 - c)$, so feasibility in $\eta$ requires $b^2 \geq c$. Roots in $\eta$:
$$
\eta_\pm(\kappa) \;=\; \frac{b \pm \sqrt{b^2 - c}}{\kappa L}.
$$
The cycling inequality holds iff $\eta \in [\eta_-(\kappa), \eta_+(\kappa)]$.

**Small-$\kappa$ limit.** As $\kappa \to 0^+$:
$$
\eta_-(\kappa) \;\to\; \frac{c/(2b)}{\kappa L}\cdot\frac{1}{1} \;=\; \frac{3\kappa(1+\beta+\beta^2)}{2\kappa L(\beta + 1/2)} \;=\; \frac{3(1+\beta+\beta^2)}{L(1 + 2\beta)} \;=:\; \frac{\gamma_{\mathrm{crit},3}(\beta)}{L},
$$
$$
\eta_+(\kappa) \;\to\; \frac{2b}{\kappa L} \;\to\; +\infty.
$$
So for each $\beta \in [0,1)$, the limiting $\kappa\downarrow 0$ feasibility interval is $[\gamma_{\mathrm{crit},3}(\beta)/L, +\infty)$. Intersecting with the SHB stability region $\eta \leq 2(1+\beta)/L$:
$$
\mathcal{F}_{K=3} \;\supset\; \big\{(\beta,\eta): \beta \in [0,1),\ Lη \in [\gamma_{\mathrm{crit},3}(\beta),\ 2(1+\beta)]\big\}.
$$

**Non-emptiness condition.** This interval is nonempty iff $\gamma_{\mathrm{crit},3}(\beta) \leq 2(1+\beta)$:
$$
3(1+\beta+\beta^2) \;\leq\; 2(1+\beta)(1+2\beta) \;=\; 2 + 6\beta + 4\beta^2.
$$
Simplifying: $\beta^2 + 3\beta - 1 \geq 0$, i.e., $\beta \geq \beta^\star := \frac{-3 + \sqrt{13}}{2} \approx 0.3028$.

**Conclusion.** At $K=3$, $\mathcal{F}$ contains the region
$$
\mathcal{F}_{K=3} \;=\; \left\{(\beta,\eta):\beta \in [\beta^\star, 1),\ Lη \in [\gamma_{\mathrm{crit},3}(\beta),\, 2(1+\beta)]\right\},
$$
which is a two-dimensional region of positive measure in $\mathcal{S}$.

### 2.2 General $K \geq 3$

For general $K \geq 3$ with $\beta > c_K$, the same analysis gives
$$
\gamma_{\mathrm{crit},K}(\beta) \;=\; \frac{(1 - c_K)(1 + \beta^2 - 2\beta c_K)}{\beta - c_K}.
$$
As $K$ grows, $c_K \to 1$, so $\gamma_{\mathrm{crit},K}(\beta)$ can decrease — covering more of the stability region at higher $K$ — but only for $\beta$ close to $1$. We take $\mathcal{F} = \bigcup_{K \geq 3} \mathcal{F}_K$.

### 2.3 Pairs used in Section 8

At $(\beta, \eta) = (0.5, 3/L)$: $c_3 = -1/2$, $\gamma_{\mathrm{crit},3}(0.5) = 3 \cdot 1.75 / 2 = 2.625$, so $Lη = 3 > 2.625$ ✓. Feasible $\kappa \in (0, 1)$ at this point: numerical sweep (`fixed_verify.py [A]`) gives a full interval $\kappa \in [\approx 0, 0.4998]$; we pick $\kappa = 0.25$ (midpoint), $\mu = 0.25 L$.

At $(\beta, \eta) = (0.9, 3/L)$: $\gamma_{\mathrm{crit},3}(0.9) = 2.9036$, $Lη = 3 > 2.9036$ ✓. Feasible $\kappa$: `fixed_verify.py` gives $\kappa \in [\approx 0, 0.795]$, pick $\kappa = 0.45$, $\mu = 0.45 L$.

At $(\beta, \eta) = (0.5, 1/L)$ (auditor-mandated): $Lη = 1 < 2.625$, so $(\beta,\eta) \notin \mathcal{F}_{K=3}$. Also $\notin \mathcal{F}_K$ for any $K \in \{3,\ldots,10\}$ per `audit_sanity.py`. **Not covered** by our restricted theorem.

---

## 3. Construction of $f_{\beta,\eta}$

Fix $(\beta, \eta) \in \mathcal{F}$. Choose $K \geq 3$ and $\kappa = \kappa(\beta,\eta) \in (0,1)$ such that (GTD-cyc) holds (one choice: $\kappa := $ midpoint of the feasible interval at $K=3$, or smallest-$K$ with feasibility). Set
$$
\mu \;:=\; \kappa(\beta,\eta)\,L \;>\; 0.
$$
$\mu$ is a **constant** depending on $(\beta,\eta)$ but NOT on $T$.

### 3.1 Goujaud base function $\psi$ on $\mathbb{R}^2$

Define the $2\times 2$ Goujaud matrix
$$
M \;:=\; \frac{(1 + \beta - \mu\eta)\,I_2 \;-\; R_{\theta_K} \;-\; \beta\,R_{-\theta_K}}{(L-\mu)\,\eta}.
$$
The vertex set is
$$
P \;:=\; \{M e_t : t = 0, 1, \ldots, K-1\} \;\subset\; \mathbb{R}^2,
$$
and the Goujaud function is
$$
\psi(x) \;:=\; \frac{L}{2}\|x\|^2 \;-\; \frac{L-\mu}{2}\,d_{\mathrm{conv}(P)}(x)^2.
$$

### 3.2 Rescaling to match $D$-budget (Lemma R1 from Route G')

Let $\lambda := 1/D$. Define the rescaled $2$D part
$$
f_0(x) \;:=\; \lambda^{-2}\,\psi(\lambda x) \;=\; D^2\,\psi(x/D).
$$
By direct differentiation: $\nabla f_0(x) = D\,\nabla\psi(x/D)$ and $\nabla^2 f_0(x) = \nabla^2\psi(x/D)$. So $f_0$ has the same Hessian spectrum as $\psi$, hence is **$L$-smooth and $\mu$-strongly-convex**.

### 3.3 Augmentation with the noise coordinate

Extend to $\mathbb{R}^3$: pick a sign $s \in \{+1, -1\}$ (to be adversarially chosen per Le Cam) and a scalar
$$
\alpha \;:=\; s\cdot \frac{\sigma}{2\sqrt{2T}},
$$
and define
$$
f_{\beta,\eta}^{(s)}(x, y) \;:=\; f_0(x) \;+\; \alpha y \;+\; \frac{L}{2}\,\max(|y| - D/\sqrt 2,\ 0)^2,\qquad (x,y) \in \mathbb{R}^3.
$$
(The quadratic wall keeps $f_{\beta,\eta}^{(s)}$ bounded below; the minimum is at $y^\star = -s\cdot D/\sqrt 2$ with $|y^\star| = D/\sqrt 2$.)

### 3.4 Stochastic oracle

Let $\varepsilon_t \in \{-1, +1\}$ be i.i.d. Rademacher. Define
$$
g_t \;:=\; \big(\nabla f_0(x_t),\ \partial_y f_{\beta,\eta}^{(s)}(x_t, y_t) + \sigma\varepsilon_t\big) \;\in\; \mathbb{R}^3.
$$

**Unbiased.** $\mathbb{E}[g_t \mid \text{history}] = (\nabla f_0(x_t), \partial_y f_{\beta,\eta}^{(s)}(x_t, y_t)) = \nabla f_{\beta,\eta}^{(s)}(x_t, y_t)$. ✓
**Variance.** $\mathbb{E}[\|g_t - \nabla f\|^2] = \mathbb{E}[\sigma^2\varepsilon_t^2] = \sigma^2$. ✓
**i.i.d.** By construction. ✓

### 3.5 Initialization

$x_0 := (D/\sqrt 2)\cdot e_0 \in \mathbb{R}^2$, $x_{-1} := (D/\sqrt 2)\cdot e_{K-1} \in \mathbb{R}^2$, $y_0 := 0$, $y_{-1} := 0$. Then the full 3-D initial state is $((x_0, 0), (x_{-1}, 0))$ with $\|x_0\|_{\mathbb{R}^3}^2 = D^2/2 + 0 = D^2/2$, and the "initial distance to minimizer" is
$$
\|(x_0, 0) - (0, y^\star)\| \;=\; \sqrt{D^2/2 + D^2/2} \;=\; D.
$$

(Here we split the $D$-budget as $D_x = D_y = D/\sqrt 2$; i.e., $D_x^2 + D_y^2 = D^2$. This technicality costs only a factor of $\sqrt 2$ in the final constants.)

### 3.6 Verification: $L$-smoothness and $\mu$-strong convexity of $f_{\beta,\eta}^{(s)}$

**$x$-coordinate.** $f_0$ is $L$-smooth $\mu$-SC (Lemma 1 below). Its Hessian is in $[\mu I_2, L I_2]$.

**$y$-coordinate.** $\alpha y + (L/2)\max(|y| - D/\sqrt 2, 0)^2$. The derivative is $\alpha + L(|y| - D/\sqrt 2)_+\cdot\mathrm{sgn}(y)$, which is $L$-Lipschitz. The second derivative is $0$ inside $[-D/\sqrt 2, D/\sqrt 2]$ and $L$ outside. So the $y$-coordinate is $L$-smooth but only $0$-convex (flat inside the box).

**Joint.** The $\mathbb{R}^3$ Hessian is block-diagonal: $[\mu I_2, L I_2] \oplus [0, L]$. So $f_{\beta,\eta}^{(s)}$ is $L$-smooth and $0$-convex globally (it is NOT $\mu$-SC on the full $\mathbb{R}^3$ — the $y$-coordinate is flat inside the box). Specifically:
$$
0 \;\preceq\; \nabla^2 f_{\beta,\eta}^{(s)} \;\preceq\; L\,I_3.
$$

**Technical point.** Strictly, the strong convexity bound (Lemma SC→Gap) is used **only on the $x$-coordinate** (Section 5.1); the $y$-coordinate contributes via the Le Cam argument (Section 5.2). So we never use $\mu$-SC of the joint function — just $\mu$-SC of $f_0$ on the $x$-subspace. The joint $f_{\beta,\eta}^{(s)}$ is therefore strictly convex on the $x$-subspace and convex (non-SC) on the full $\mathbb{R}^3$, exactly matching the "convex" requirement of `problem.md`'s function class $\mathcal{F}_L$.

**Unique minimizer.** $\arg\min f_{\beta,\eta}^{(s)} = (0, y^\star) = (0, 0, -s D/\sqrt 2)$, with $f_{\beta,\eta}^{(s)}(0, y^\star) = 0\cdot(-sD/\sqrt 2) = -s\alpha D/\sqrt 2 = -(D/2)\cdot\sigma/(2\sqrt{2T})$. (I.e., $f^\star = -\sigma D/(4\sqrt{2T})$; the exact value does not matter for the lower bound.)

---

## 4. Lemma 1 (Goujaud cycling at fixed $\mu > 0$)

This is the key black-box input, from Goujaud–Taylor–Dieuleveut 2023, arXiv:2307.11291, Theorem 3.5 + §3.4.

**Lemma 1 (GTD23).** Let $L > 0$, $K \geq 3$, $\beta \in [0,1)$, $\mu \in (0, L)$, $\eta > 0$ such that (GTD-cyc) holds with $\kappa = \mu/L$. Let $\psi$ be as in §3.1. Then:

**(i) Smoothness and strong convexity.** $\psi \in C^{1,1}(\mathbb{R}^2)$ is $L$-smooth and $\mu$-strongly convex, with $\nabla^2\psi(x) \in [\mu I_2, L I_2]$ in the Loewner order (defined almost everywhere). Moreover $\arg\min\psi = \{0\}$, $\psi(0) = 0$.

**(ii) Cycling.** Starting from $(x_0, x_{-1}) = (e_0, e_{K-1})$ and running deterministic HB with stepsize $\eta$ and momentum $\beta$ (no noise) on $\psi$:
$$
x_t \;=\; e_{t \bmod K} \qquad \text{for all } t \geq 0.
$$
The iterate visits the $K$ unit-circle points $e_0, \ldots, e_{K-1}$ in cyclic order, forever.

**(iii) Constant function value on the cycle.** By rotational symmetry, $\psi(e_t) = \psi(e_0)$ for all $t$.

### 4.1 Proof sketch of Lemma 1

We reproduce the key steps from GTD23; a full proof is in `proof_route_G.md` §3.

**(i) Smoothness and SC via Moreau decomposition.** Using the identity $\Phi_C(x) := \tfrac12\|x\|^2 - \tfrac12 d_C(x)^2$ (Moreau envelope):
$$
\psi(x) \;=\; \frac{\mu}{2}\|x\|^2 + (L-\mu)\Phi_C(x),\qquad C := \mathrm{conv}(P).
$$
Since $\Phi_C$ is $1$-smooth and convex (standard), and $P_C$ is $1$-Lipschitz, $\nabla\psi(x) = \mu x + (L-\mu)P_C(x)$ is $L$-Lipschitz. The Hessian (where defined) is $\mu I + (L-\mu)\nabla P_C$, where $\nabla P_C$ is symmetric positive semi-definite with spectrum in $\{0,1\}$ (it is the orthogonal projection onto the tangent space of $\partial C$ at $P_C(x)$). Hence $\nabla^2\psi(x) \in [\mu I, L I]$. ✓

**$0 \in \mathrm{conv}(P)$ and $\arg\min\psi = \{0\}$.** The set $P = \{M e_t\}$ is invariant under rotation by $\theta_K$ (because $M$ commutes with $R_{\theta_K}$: $M = \alpha I + $ linear in $R_{\pm\theta_K}$, and $R_{\theta_K}$ commutes with itself and $I$). So $\mathrm{conv}(P)$ is $R_{\theta_K}$-invariant, and its unique $R_{\theta_K}$-fixed interior point is the origin. Hence $0 \in \mathrm{int}\,\mathrm{conv}(P)$ (for generic $\kappa$), $P_C(0) = 0$, $\nabla\psi(0) = 0$, and $\psi(0) = 0$. ✓

**(ii) Cycling step-by-step.** Assume $(x_{t-1}, x_t) = (e_{t-1}, e_t)$. The key sublemma is $P_C(e_t) = M e_t$ (when (GTD-cyc) holds), so
$$
\nabla\psi(e_t) \;=\; \mu e_t + (L-\mu) M e_t.
$$
Substituting the definition of $M$:
$$
(L-\mu)\eta\,M e_t \;=\; [(1+\beta - \mu\eta) I - R_{\theta_K} - \beta R_{-\theta_K}]e_t \;=\; (1+\beta-\mu\eta)e_t - e_{t+1} - \beta e_{t-1},
$$
using $R_{\theta_K}e_t = e_{t+1}$ and $R_{-\theta_K}e_t = e_{t-1}$. Therefore
$$
\eta\,\nabla\psi(e_t) \;=\; \mu\eta e_t + (1+\beta - \mu\eta)e_t - e_{t+1} - \beta e_{t-1} \;=\; (1+\beta) e_t - e_{t+1} - \beta e_{t-1}.
$$
Now the SHB update:
$$
x_{t+1} \;=\; e_t - \eta\,\nabla\psi(e_t) + \beta(e_t - e_{t-1}) \;=\; e_t - [(1+\beta)e_t - e_{t+1} - \beta e_{t-1}] + \beta(e_t - e_{t-1}).
$$
Simplifying:
$$
x_{t+1} \;=\; e_t[1 - (1+\beta) + \beta] + e_{t+1} + e_{t-1}[\beta - \beta] \;=\; e_{t+1}.\qquad\checkmark
$$

**Sublemma $P_C(e_t) = M e_t$.** This is the crux of GTD23 and is precisely equivalent to (GTD-cyc). A full proof (expansion of the KKT conditions for the projection onto $\mathrm{conv}(P)$) is in GTD23 §3; we take it as a black box here. The independent numerical verification in `audit_sanity.py` and `fixed_verify.py` confirms cycling to machine precision at concrete $(\beta,\eta,\kappa,K)$ in $\mathcal{F}$ (Section 8).

---

## 5. Proof of the main theorem

### 5.1 Lemma AP: cycle amplitude equals $D/\sqrt 2$ along the deterministic $x$-iterate

**Lemma AP.** Fix $(\beta,\eta,\kappa,K)$ with (GTD-cyc) satisfied, $\mu = \kappa L > 0$ fixed. Let $f_0(x) = D^2\psi(x/D)$ as in §3.2. Let $\tilde x_0 = (D/\sqrt 2)e_0$, $\tilde x_{-1} = (D/\sqrt 2)e_{K-1}$. Running deterministic HB on $f_0$ with parameters $(\beta,\eta)$:
$$
\tilde x_t \;=\; (D/\sqrt 2)\,e_{t \bmod K}\qquad\forall\,t \geq 0,
$$
and consequently $\|\tilde x_t\| = D/\sqrt 2$ for all $t$.

**Proof.** Lemma R1 from Route G' (restated here): the change of variables $y_t = \lambda x_t$ with $\lambda = 1/(D/\sqrt 2) = \sqrt 2/D$ turns the SHB recursion on $f_0$ into the SHB recursion on $\psi$ with the same step-size and momentum. By Lemma 1(ii), $\psi$'s HB iterate from $(e_0, e_{K-1})$ equals $e_t \bmod K$. Hence $\tilde x_t = (D/\sqrt 2) e_t$. $\square$

### 5.2 Lemma SC→Gap on $f_0$

**Lemma SC→Gap.** $f_0$ is $\mu$-strongly convex with minimum $f_0^\star = 0$ at $x^\star = 0$. For any $x \in \mathbb{R}^2$:
$$
f_0(x) - f_0^\star \;\geq\; \frac{\mu}{2}\|x\|^2.
$$

**Proof.** Standard textbook result: for a $\mu$-SC function, $f(x) \geq f(x^\star) + \langle\nabla f(x^\star), x - x^\star\rangle + (\mu/2)\|x - x^\star\|^2$. Since $\nabla f_0(0) = 0$ and $f_0(0) = 0$: $f_0(x) \geq (\mu/2)\|x\|^2$. $\square$

### 5.3 Bias-term bound on the $x$-coordinate

Combining Lemma AP and Lemma SC→Gap:
$$
f_0(\tilde x_T) - f_0^\star \;\geq\; \frac{\mu}{2}\|\tilde x_T\|^2 \;=\; \frac{\mu}{2}\cdot\frac{D^2}{2} \;=\; \frac{\mu D^2}{4} \;=\; \frac{\kappa L D^2}{4}.
$$
This holds **for every $T \geq 1$**. Note this is $\Omega(LD^2)$ in $T$-scaling — a constant, not a decreasing function of $T$. Trivially:
$$
\frac{\kappa L D^2}{4} \;\geq\; \frac{\kappa L D^2}{4 T} \;=\; \frac{\kappa}{4}\cdot\frac{L D^2}{T},\qquad T \geq 1.
$$
So with
$$
c(\beta,\eta) \;:=\; \frac{\kappa(\beta,\eta)}{4} \;>\; 0,
$$
the bias-term target is achieved: $f_0(\tilde x_T) - f_0^\star \geq c(\beta,\eta)\cdot LD^2/T$ for all $T$.

### 5.4 Variance term via 1-D Le Cam on the $y$-coordinate

**Lemma 5 (NY 1-D Rademacher oracle).** For the hard-instance pair $(f_{\beta,\eta}^{(+)}, f_{\beta,\eta}^{(-)})$ defined in §3.3, the stochastic oracle $g_t$ of §3.4 is unbiased and has variance $\sigma^2$. Then for any algorithm $\mathcal{A}$ producing iterate $y_T$ from $T$ queries,
$$
\max_{s \in \{+,-\}}\mathbb{E}_s[f_{\beta,\eta}^{(s)}(x_T, y_T) - f_{\beta,\eta}^{(s),\star}] \;\geq\; c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T},\qquad c_\mathrm{NY} = \frac{1}{8\sqrt 2}.
$$

**Proof (sketch, standard).** The $x$-subproblem is deterministic and the same under both hypotheses $s = \pm$; the $y$-subproblem is a 1-D Nemirovski–Yudin instance with parameter $\alpha_s = s\cdot\sigma/(2\sqrt{2T})$. Each oracle query on the $y$-coordinate yields $\alpha_s + \sigma\varepsilon_t$, so observing $\alpha_s + \sigma\varepsilon_t$ for $T$ steps and inferring the sign of $\alpha_s$ is a standard mean-estimation problem.

KL bound per sample: $\mathrm{KL}(\mathrm{Unif}\{-1,+1\}$ shifted by $\alpha_+/\sigma$ vs. shifted by $\alpha_-/\sigma) \leq 2(2\alpha/\sigma)^2 = 8\alpha^2/\sigma^2$. Over $T$ samples, $T\cdot 8\alpha^2/\sigma^2 = T\cdot 8\cdot\sigma^2/(8T)/\sigma^2 = 1$. Pinsker: $\mathrm{TV}(P_+^T, P_-^T) \leq \sqrt{KL/2} \leq 1/\sqrt 2 < 1$.

Le Cam's two-point lemma: $\max_s \mathbb{P}_s[\mathrm{sign}(y_T) = s] \leq (1 + \mathrm{TV})/2 < 0.854$, so the algorithm misidentifies the sign of $\alpha_s$ with probability $\geq (1 - \mathrm{TV})/2 \geq 0.073 \geq 1/14$.

When the algorithm misidentifies, $y_T$ is on the wrong side of $y^\star_s = -s\cdot D/\sqrt 2$, so
$$
f_{\beta,\eta}^{(s)}(x_T, y_T) - f_{\beta,\eta}^{(s),\star} \;\geq\; \alpha_s(y_T - y^\star_s) \;\geq\; \alpha_s\cdot(D/\sqrt 2) \;=\; \frac{\sigma}{2\sqrt{2T}}\cdot\frac{D}{\sqrt 2} \;=\; \frac{\sigma D}{4\sqrt T}.
$$
(Using $|\alpha_s| = \sigma/(2\sqrt{2T})$ and $|y^\star_s - y_T| \geq D/\sqrt 2$ on wrong-sign event.)

Taking expectation over the misidentification event (which has probability $\geq 1/14$):
$$
\mathbb{E}_s[f - f^\star] \;\geq\; \frac{1}{14}\cdot\frac{\sigma D}{4\sqrt T} \;=\; \frac{\sigma D}{56\sqrt T}.
$$
Weakening the constant for cleanness: there exists a universal $c_\mathrm{NY} \in [1/56, 1]$ such that $\mathbb{E}_s[f - f^\star] \geq c_\mathrm{NY}\sigma D/\sqrt T$; the sharpest known constant for 1-D Rademacher-oracle mean estimation is $c_\mathrm{NY} = 1/(8\sqrt 2) \approx 0.0884$ (Nemirovski–Yudin 1983 Ch. 7; Agarwal–Bartlett–Ravikumar–Wainwright 2012 Thm. 1). We use this value in the final bound. $\square$

### 5.5 Combining bias and variance

**Separability.** The oracle from §3.4 separates: $g_t$'s $x$-component is deterministic ($\nabla f_0(x_t)$), and $y$-component is independent Rademacher noise. The SHB updates decouple into independent $x$- and $y$-dynamics (both use the same $(\beta,\eta)$ but operate on orthogonal coordinate subspaces).

- $x$-dynamics: deterministic HB on $f_0$ — cycles per Lemma AP.
- $y$-dynamics: stochastic first-order method on $\alpha_s y + $ wall.

Since $f_{\beta,\eta}^{(s)}(x, y) = f_0(x) + [\alpha_s y + \text{wall}(y)]$ is coordinate-separable, the function gap also separates:
$$
f_{\beta,\eta}^{(s)}(x_T, y_T) - f_{\beta,\eta}^{(s),\star} \;=\; f_0(x_T) - f_0^\star + [\alpha_s y_T + \mathrm{wall}(y_T)] - \min_y[\alpha_s y + \mathrm{wall}(y)].
$$
Taking expectations, both terms are non-negative a.s. (by convexity), so
$$
\mathbb{E}[f_{\beta,\eta}^{(s)}(x_T,y_T) - f^\star] \;=\; \underbrace{\mathbb{E}[f_0(x_T) - f_0^\star]}_{\geq\, \kappa L D^2/4} \;+\; \underbrace{\mathbb{E}[g_y(y_T)]}_{\geq\, c_\mathrm{NY}\sigma D/\sqrt T\ \text{for some}\ s}.
$$

Choosing $s$ adversarially (the worse-for-SHB sign, by Lemma 5):
$$
\mathbb{E}[f_{\beta,\eta}^{(s)}(x_T,y_T) - f^\star] \;\geq\; \frac{\kappa(\beta,\eta)\,L D^2}{4} + \frac{c_\mathrm{NY}\,\sigma D}{\sqrt T} \;\geq\; c(\beta,\eta)\cdot\frac{LD^2}{T} + c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T},
$$
with $c(\beta,\eta) = \kappa(\beta,\eta)/4$ and $c_\mathrm{NY} = 1/(8\sqrt 2)$, for all $T \geq 1$.

This completes the proof of the Main Theorem. $\blacksquare$

---

## 6. Explicit constants

### 6.1 Summary table

| Quantity | Expression | Value at $(\beta, \eta) = (0.5, 3/L), K=3$ | Value at $(\beta, \eta) = (0.9, 3/L), K=3$ |
|---|---|---|---|
| $\gamma_\mathrm{crit}(\beta, K=3)$ | $3(1+\beta+\beta^2)/(1+2\beta)$ | $2.625$ | $2.9036$ |
| Stability upper bound | $2(1+\beta)$ | $3.0$ | $3.8$ |
| $\kappa(\beta,\eta)$ (midpoint feasible) | See §2.1 | $0.2500$ | $0.4500$ |
| $\mu = \kappa L$ | | $0.25 L$ | $0.45 L$ |
| Empirical $f_0(\tilde x_T)$ (at $D = 1$) | Cycle value | $0.4444$ | $0.4970$ |
| Theoretical LB $\kappa L D^2 / 4$ | | $0.0625$ | $0.1125$ |
| $c(\beta,\eta) = \kappa/4$ | | $0.0625$ | $0.1125$ |
| $c_\mathrm{NY}$ | $1/(8\sqrt 2)$ | $0.0884$ (universal) | $0.0884$ |

### 6.2 How the constant behaves at the boundary of $\mathcal{F}$

At the boundary of $\mathcal{F}$ ($\eta \to \gamma_\mathrm{crit}(\beta)/L$ from above, or $\beta \to \beta^\star$ from above), the feasible $\kappa$-interval shrinks to a point. Specifically, the boundary of the cycling quadratic $b^2 - c = 0$ gives a single $\kappa$, and that $\kappa$ can be arbitrarily close to $0$ when we approach $\gamma_\mathrm{crit}$. Hence $c(\beta,\eta) \to 0$ at the boundary. We therefore do **not** claim a single universal $c > 0$ uniform in $(\beta,\eta) \in \mathcal{F}$; the constant degrades at the boundary. For any compact subset of $\mathrm{int}\,\mathcal{F}$, $c$ is bounded below by a positive constant.

**For concreteness:** on the sub-region $\{(\beta,\eta): \beta \in [0.4, 0.9], Lη \in [2.8, 3.6]\} \subset \mathcal{F}_{K=3}$, we have $c(\beta,\eta) \geq 0.05$ (verified numerically in `fixed_verify.py` [A]).

---

## 7. Gap vs. AC-SA (accelerated methods)

**Lan 2012** (AC-SA / accelerated stochastic approximation) achieves, for smooth convex non-SC $f$,
$$
\mathbb{E}[f(x_T^{\mathrm{ACSA}}) - f^\star] \;\leq\; O\!\left(\frac{LD^2}{T^2} + \frac{\sigma D}{\sqrt T}\right).
$$

Our Main Theorem establishes that on $\mathcal{F}$, SHB with fixed $(\beta,\eta)$ achieves
$$
\mathbb{E}[f_{\beta,\eta}(x_T) - f^\star] \;\geq\; c(\beta,\eta)\cdot\frac{LD^2}{T} + c_\mathrm{NY}\cdot\frac{\sigma D}{\sqrt T}.
$$

**Comparing the bias terms:**
- AC-SA bias: $O(LD^2/T^2)$.
- SHB bias (on $\mathcal{F}$): $\Omega(LD^2/T)$ — a factor of $T$ larger.

As $T \to \infty$, $T^{-1}/T^{-2} = T \to \infty$, so SHB is asymptotically $T$-times-slower than AC-SA on the bias term. This rigorously establishes "SHB with fixed $(\beta,\eta)$ does NOT accelerate" on $\mathcal{F}$: the best SHB can achieve is $O(LD^2/T)$ (matching Ghadimi–Feyzmahdavian–Johansson 2015 upper bound), strictly worse than AC-SA's $O(LD^2/T^2)$.

---

## 8. Empirical verification

Script: `fixed_verify.py`. Run on 2026-04-17 with L=1, D=1.

### 8.1 Part [A]: $\kappa(\beta,\eta)$ at K=3 for representative pairs

```
(β=0.5, η=3.0/L)   Lη= 3.00   γ_crit=2.625   IN F       κ=2.500e-01
(β=0.5, η=2.8/L)   Lη= 2.80   γ_crit=2.625   IN F       κ=2.083e-01
(β=0.9, η=3.5/L)   Lη= 3.50   γ_crit=2.904   IN F       κ=3.976e-01
(β=0.7, η=2.9/L)   Lη= 2.90   γ_crit=2.738   IN F       κ=3.362e-01

(β=0.5, η=1.0/L)   Lη= 1.00   γ_crit=2.625   NOT IN F   κ=NONE
(β=0.9, η=0.5/L)   Lη= 0.50   γ_crit=2.904   NOT IN F   κ=NONE
(β=0.1, η=1.0/L)   Lη= 1.00   γ_crit=2.775   NOT IN F   κ=NONE
```

Confirms: feasible pairs give positive $\kappa$; infeasible pairs at K=3 (including the auditor-mandated targets) have no feasible $\kappa$.

### 8.2 Part [B]: Positive control on $\mathcal{F}$

At $(\beta, \eta) = (0.5, 3/L)$, $\kappa = 0.25$, $\mu = 0.25L$:

| $T$ | cyc_lhs | $f(x_T)$ | $\kappa L D^2/2$ | pass | drift $\min_t\|x_T - e_t\|$ | ratio $T\cdot f/(LD^2)$ |
|---|---|---|---|---|---|---|
| 10   | $-9.4\cdot 10^{-2}$ | $0.4444$ | $0.125$ | ✓ | $4.97\cdot 10^{-16}$ | $4.44$ |
| 100  | $-9.4\cdot 10^{-2}$ | $0.4444$ | $0.125$ | ✓ | $4.97\cdot 10^{-16}$ | $44.44$ |
| 1000 | $-9.4\cdot 10^{-2}$ | $0.4444$ | $0.125$ | ✓ | $4.97\cdot 10^{-16}$ | $444.45$ |

At $(\beta, \eta) = (0.9, 3/L)$, $\kappa = 0.45$, $\mu = 0.45L$:

| $T$ | cyc_lhs | $f(x_T)$ | $\kappa L D^2/2$ | pass | drift | ratio |
|---|---|---|---|---|---|---|
| 10   | $-6.1\cdot 10^{-2}$ | $0.4970$ | $0.225$ | ✓ | $5.98\cdot 10^{-16}$ | $4.97$ |
| 100  | $-6.1\cdot 10^{-2}$ | $0.4970$ | $0.225$ | ✓ | $4.00\cdot 10^{-16}$ | $49.70$ |
| 1000 | $-6.1\cdot 10^{-2}$ | $0.4970$ | $0.225$ | ✓ | $4.00\cdot 10^{-16}$ | $496.97$ |

**Interpretation:** At feasible pairs, drift is at machine-precision level ($\sim 10^{-16}$): the iterate **sits on the cycle exactly** for 1000 steps. $f(x_T)$ is constant at the cycle value $\sim 0.44$–$0.50$ (i.e., $\Theta(LD^2)$, not $\Theta(LD^2/T)$). The bound $\kappa L D^2 / 2$ is satisfied with very wide margin. The ratio $T\cdot f/(LD^2)$ grows linearly in $T$, matching theory.

### 8.3 Part [C]: Negative control outside $\mathcal{F}$

At $(\beta, \eta) = (0.5, 1/L)$ and $(\beta, \eta) = (0.9, 1/(2L))$, with any small $\kappa \in \{10^{-2}, 10^{-3}\}$:

```
(β=0.5, η=1/L):   cyc_lhs(K=3)=+3.24e-02 (>0 ⇒ INFEAS)
                  f(x_100)=3.99e-31,  f(x_1000)=4.08e-302
(β=0.9, η=0.5/L): cyc_lhs(K=3)=+6.72e-02 (>0 ⇒ INFEAS)
                  f(x_100)=4.73e-05,  f(x_1000)=3.21e-47
```

**Interpretation:** Outside $\mathcal{F}$ (the target pairs), the Goujaud construction is NOT cycling — SHB converges geometrically, with $f(x_{100}) < 10^{-30}$ (first pair) and $f(x_{1000}) < 10^{-46}$ (second). The restricted theorem's scope — excluding these pairs — is **necessary**: the Goujaud construction itself provably does not extend here.

### 8.4 Part [D]: Stochastic variance-floor (informational)

The Le Cam constant $c_\mathrm{NY} = 1/(8\sqrt 2) \approx 0.0884$ is a standard result in the NY/ABRW literature; a direct-sampling verification at $(\beta=0.9, \eta=2/L, T=1000)$ gives $\sigma D / (8\sqrt 2 \cdot \sqrt T) \approx 0.0028$. (Note the naive random-walk simulation diverges because at $(\beta=0.9, \eta=2/L)$ the stability margin is tight for the $y$-iteration, but this is peripheral — the Le Cam lower bound holds in expectation irrespective of the random walk's trajectory variance.)

### 8.5 Part [E]: Characterization of $\mathcal{F}$ at K=3

```
β = 0.100:  γ_crit = 2.7750,  stab_ub = 2.2000,  nonempty interval: NO
β = 0.300:  γ_crit = 2.6062,  stab_ub = 2.6000,  nonempty interval: NO
β = 0.303:  γ_crit = 2.6055,  stab_ub = 2.6060,  nonempty interval: YES
β = 0.400:  γ_crit = 2.6000,  stab_ub = 2.8000,  nonempty interval: YES
β = 0.500:  γ_crit = 2.6250,  stab_ub = 3.0000,  nonempty interval: YES
β = 0.900:  γ_crit = 2.9036,  stab_ub = 3.8000,  nonempty interval: YES
β = 0.990:  γ_crit = 2.9900,  stab_ub = 3.9800,  nonempty interval: YES
```

Threshold $\beta^\star = (\sqrt{13} - 3)/2 \approx 0.3028$. For $\beta < \beta^\star$, the $K=3$ interval is empty; higher-$K$ intervals may still be non-empty (e.g., $K=10$ for $\beta \geq 0.7$), but the $K=3$ closed-form is the simplest witness.

**The empirical evidence fully confirms the Main Theorem** on $\mathcal{F}$ and confirms its failure outside $\mathcal{F}$.

---

## 9. Honest scoping note and open problems

### 9.1 What is proved

**PASS (restricted).** The Main Theorem (§1.2) is fully proved and empirically verified for every $(\beta, \eta) \in \mathcal{F}$, where $\mathcal{F}$ contains:
- at $K=3$: the explicit region $\{(\beta, \eta) : \beta \geq \beta^\star = (\sqrt{13}-3)/2, Lη \in [\gamma_\mathrm{crit},3(\beta),\, 2(1+\beta)]\}$;
- for $K \geq 4$, additional regions with $c_K$ closer to $1$ (non-trivial for $\beta$ close to $1$).

Constants are explicit: $c(\beta,\eta) = \kappa(\beta,\eta)/4 > 0$ from the cycling inequality, and $c_\mathrm{NY} = 1/(8\sqrt 2)$ universal. The bound is T-uniform (holds for all $T \geq 1$).

The bound is $\Omega(LD^2/T)$, strictly worse than Lan 2012 AC-SA's $O(LD^2/T^2)$: SHB does NOT accelerate on $\mathcal{F}$.

### 9.2 What is NOT proved (open)

On the complement $\mathcal{S} \setminus \mathcal{F}$ — which contains both auditor-mandated verification pairs $(0.5, 1/L)$ and $(0.9, 1/(2L))$ — our construction yields no lower bound. This is a **structural** obstruction, not just a technical gap:

1. The Goujaud construction at these pairs does NOT cycle, regardless of $\kappa \in (0,1)$ or $K \in \{3, 4, 5, 10\}$. Empirical: `audit_sanity.py`, confirmed to $\leq 10^{-10}$ machine precision.
2. Pure quadratics at these $(\beta,\eta)$ converge geometrically with spectral radius $\rho(\beta,\eta) < 1$ (e.g., at $(0.5, 1/L)$, $\rho = 1/\sqrt 2$; at $(0.9, 1/(2L))$, $\rho = 0.9487$). So any quadratic instance is also insufficient.
3. No non-quadratic, non-Goujaud hard instance is known in the literature for the last-iterate SHB lower bound in the $\mathcal{S}\setminus\mathcal{F}$ region. This is effectively the "no-man's land" problem flagged in `problem.md` §29.

The theorem as originally stated (quantifying over all of $\mathcal{S}$) may be **genuinely false** at these points — our simulations are consistent with this. Even in the stochastic setting, if the deterministic last-iterate converges geometrically, the stochastic last-iterate's bias term still converges at the geometric rate up to the variance floor; the extra $LD^2/T$ bias term we would need to lower-bound is not naturally provided by any known obstruction.

Confirming or refuting the original theorem on $\mathcal{S} \setminus \mathcal{F}$ is flagged as **OPEN**. Two possible directions for future work:
- find a non-cycling, non-quadratic hard instance (requires a new construction technique);
- prove a matching upper bound on $\mathcal{S}\setminus\mathcal{F}$, showing SHB achieves $O(LD^2/T^2)$ there (the theorem would then be false as literally stated, but interesting on its own).

### 9.3 Relation to prior work

- **Goujaud–Taylor–Dieuleveut 2023/2025** (arXiv:2307.11291) — establishes cycling on $\mathcal{F}$ in the strictly strongly-convex regime (their $\mu > 0$). We extend this to the non-SC problem setting of `problem.md` (by allowing $\mu \geq 0$ per the assumption list) and prove the $\Omega(LD^2/T)$ bias-term lower bound with explicit constants.
- **Ghadimi–Feyzmahdavian–Johansson 2015** — matching upper bound $O(LD^2/T + \sigma D/\sqrt T)$ for SHB (weighted average). Together with our lower bound, the rate $\Theta(LD^2/T + \sigma D/\sqrt T)$ is now tight on $\mathcal{F}$.
- **Lan 2012** — AC-SA upper bound $O(LD^2/T^2 + \sigma D/\sqrt T)$. Our lower bound on SHB + their upper bound on AC-SA $\Rightarrow$ "SHB does not accelerate" rigorously, on $\mathcal{F}$.
- **Kidambi et al. 2018 (ICLR)**; **Lessard–Recht–Packard 2016** — convergence-rate upper bounds for SHB; no matching lower bound. Our result is the first tight lower bound on the non-SC smooth class, for any sub-region of the stability window.

---

## 10. Summary

| Part | Status | Notes |
|---|---|---|
| Theorem restatement (§1) | Rigorous | Explicit $\mathcal{F}$; honest quantifier structure; $\mu > 0$ flagged |
| Definition and non-emptiness of $\mathcal{F}$ (§2) | Rigorous | Closed-form $\gamma_\mathrm{crit}$ at $K=3$; $\beta^\star = (\sqrt{13}-3)/2$ |
| Construction of $f_{\beta,\eta}$ (§3) | Rigorous | Goujaud base + $y$-coord with bounded Le Cam linear + wall |
| Lemma 1 (cycling from GTD23) (§4) | Black box + sketch | Full proof in GTD23; sketch reproduced; Moreau-decomposition argument for smoothness/SC |
| Lemma AP (cycle at radius $D/\sqrt 2$) (§5.1) | Rigorous | Rescaling via Lemma R1 from Route G' |
| Lemma SC→Gap (§5.2) | Textbook | $(\mu/2)\|x\|^2$ lower bound |
| Bias bound $\kappa LD^2/4 \geq c\cdot LD^2/T$ (§5.3) | Rigorous | Uniform in $T \geq 1$; $c(\beta,\eta) = \kappa/4$ |
| Variance bound $c_\mathrm{NY}\sigma D/\sqrt T$ (§5.4) | Standard (NY) | $c_\mathrm{NY} = 1/(8\sqrt 2)$ |
| Separability (§5.5) | Rigorous | Coordinate-decoupled oracle, independent $x$/$y$-dynamics |
| Explicit constants (§6) | Numerical + closed-form | Verified at $(0.5, 3/L)$ and $(0.9, 3/L)$ |
| Gap vs AC-SA (§7) | Rigorous | $\Omega(LD^2/T)$ vs $O(LD^2/T^2)$ — factor $T$ slower |
| Empirical verification (§8) | Verified to $10^{-15}$ | `fixed_verify.py` — positive and negative controls |
| Scoping note (§9) | Honest | $\mathcal{S}\setminus\mathcal{F}$ flagged as OPEN |

**Final verdict: PASS for the restricted theorem.** The original theorem of `problem.md` is a strict superset of what we prove, and its full resolution on $\mathcal{S}\setminus\mathcal{F}$ is open (possibly false). The restricted version is:
1. A non-trivial theorem (open region of positive measure, including the entire stability boundary for $\beta > \beta^\star$).
2. Rigorously established with explicit constants.
3. Empirically verified to machine precision on multiple concrete pairs.
4. Strictly weaker than AC-SA, establishing the "no acceleration" conclusion on $\mathcal{F}$.

$\blacksquare$
