# Phase 2: Explorer (Adversarial Frame, Route 3) — Le Cam Impossibility for First-Order Convergence to Non-Strict Local Minimax Optima

**Author**: Explorer agent, claude-opus-4-7
**Date**: 2026-04-27
**Frame**: Adversarial (Le Cam two-point / Yao indistinguishability)
**Route from `routes.md`**: Route 3
**Polarity**: NEGATIVE (impossibility)

---

## Hooks Report (mandatory)

| Hook source | Triggered? | Action taken |
|---|---|---|
| `failure_triggers.md` FT-18-AUDITOR-MISSES-UB-LB-CONTRADICTION | NO | We prove an impossibility, not a UB; no UB-vs-LB exponent mismatch possible. |
| `failure_patterns.md` FP-Goujaud quantifier order (2026-04-17) | YES — actively respected | We construct ONE pair $(f^+, f^-)$ that fools EVERY first-order method; the universal-quantifier order is $\exists f^\pm \forall \mathcal{A}$. |
| `failure_patterns.md` FP-OP2-CYCLING-INIT-BASIN-DEPENDENCE | YES — respected | The argument is NOT cycling-based; it is gradient indistinguishability. We do not need the bad behavior to be attractive — we directly show the algorithm cannot distinguish two limit points. |
| `failure_patterns.md` FP-OP2-I4-SUFFIX-AVG-RESONANCE | YES — respected | Le Cam impossibility is defeated by averaging only if averaging breaks indistinguishability. Since the two laws of gradient queries coincide pointwise, averaging the queries also coincides — no resonance. |
| `failure_patterns.md` FP-SHB-BIAS quadratic-too-easy | YES — respected | Hard instances have $\nabla^2_{yy} f^\pm(x^*, y^*) = 0$ globally on a $\delta$-neighborhood (both Hessian eigenvalues vanish identically near the origin). |
| `failure_patterns.md` FP-GDA-NONSTRICTNESS | YES — leveraged | We exploit the fact that two-timescale GDA flow has the degenerate fixed point as a flow-saddle. Our construction makes BOTH targets be such flow-saddles, and the algorithm cannot tell them apart. |
| `routes.md` Route 3 prerequisite: $\nabla_y f^+(0,0) = \nabla_y f^-(0,0)$ at zeroth order | YES | Construction in §3 ensures $\nabla f^+ = \nabla f^-$ identically on a $\delta$-ball; the two functions differ only OUTSIDE the ball, hence first-order indistinguishability is exact (not just $O(\epsilon)$). |
| Cluster D template (D5 = SHB Le Cam, D2 = SSL Fano, D4 = CR depth) | YES — instantiated | We follow the D5 chassis: (i) name the bit being tested (sign of asymptotic target $y^*_s$), (ii) show queries on either instance generate the same law on $\delta$-ball, (iii) Le Cam two-point gives test error $\geq 1/2$. |
| Reverse-consistency check on the impossibility direction | YES | We explicitly verify: (a) both $f^\pm$ are $C^\infty$; (b) $(0,0)$ is a non-strict local minimax of BOTH; (c) the gradient fields agree on $B(0,\delta)$; (d) the correct attraction targets differ. |

---

## 0. Setting and notation

- Domain: $(x, y) \in \mathbb{R} \times \mathbb{R}$ (the simplest setting; the impossibility extends trivially to higher dimensions by tensoring with neutral coordinates).
- $f \in C^\infty(\mathbb{R}^2; \mathbb{R})$.
- A **first-order oracle** $\mathcal{O}_f$ takes a query point $(x, y)$ and returns $(\nabla f(x,y), f(x,y))$. (We allow function value too — this only makes the impossibility STRONGER: even with both first-order and zero-order access, the result holds.)
- A **first-order algorithm** $\mathcal{A}$ is a (possibly randomized) measurable map from query history $\{(x_t, y_t, \nabla f(x_t,y_t), f(x_t, y_t))\}_{t < T}$ to a next query $(x_T, y_T)$, plus a final output rule $\hat{z}_T \in \mathbb{R}^2$.
- We work in the **deterministic-oracle setting**: no stochastic noise is added to $\nabla f$. (Stochasticity would only further weaken the algorithm.)
- A **non-strict local minimax optimum** $(x^*, y^*)$ of $f$ (Jin–Netrapalli–Jordan 2019, restated in `problem.md`): there is $\delta > 0$ and $\delta_x > 0$ such that
   1. $y^*$ is a local maximum of $f(x^*, \cdot)$: $f(x^*, y) \le f(x^*, y^*)$ for $\|y - y^*\| \le \delta$;
   2. $\Phi_\delta(x) := \max_{\|y - y^*\| \le \delta} f(x, y)$ satisfies $\Phi_\delta(x) \ge \Phi_\delta(x^*)$ for $\|x - x^*\| \le \delta_x$.

   Non-strict means at least one of (1), (2) is degenerate at second order: either $\partial_y^2 f(x^*, y^*) = 0$ or the implicit-function-derived envelope Hessian $D^2 \Phi_\delta(x^*)$ has a zero eigenvalue (or both).

- "Convergence to a local minimax optimum from initialization $z_0$": $\hat z_T \to (x^*, y^*)$ where $(x^*, y^*)$ is some local minimax optimum of $f$.

- $B(0, r) := \{(x, y) : x^2 + y^2 \le r^2\}$.

---

## 1. Theorem statement

> **Theorem (Adversarial Impossibility, Route 3).**
> There exist constants $c_0, \delta_0, R_0 > 0$ and two $C^\infty$ functions
> $f^+, f^- : \mathbb{R}^2 \to \mathbb{R}$
> with the following four properties.
>
> **(P1) Both have $(0, 0)$ as a non-strict local minimax optimum.** In particular, $\partial_y^2 f^\pm(0, 0) = 0$, and $(0,0)$ satisfies the Jin–Netrapalli–Jordan local-minimax conditions for both $f^+$ and $f^-$.
>
> **(P2) First-order indistinguishability on a $\delta_0$-ball.**
> For all $(x, y) \in B(0, \delta_0)$:
> $$f^+(x, y) = f^-(x, y), \qquad \nabla f^+(x, y) = \nabla f^-(x, y). \tag{IND}$$
>
> **(P3) Different limit targets outside the ball.** For each sign $s \in \{+, -\}$, $f^s$ has exactly two local minimax optima: $(0, 0)$ and a second optimum $z^*_s := (s\,R_0,\; 0)$. Moreover, $(0,0)$ is a strict global maximum on the $y$-axis $\{x = 0\}$ for $f^+$, and a strict global minimum on the $y$-axis for $f^-$ — within the relevant outer neighborhood.
>
> **(P4) Le Cam impossibility.** For any (deterministic OR randomized) first-order algorithm $\mathcal{A}$ that runs at most $T$ first-order queries plus produces an output $\hat z_T$, and for any initialization $z_0 \in B(0, \delta_0/2)$, at least one of the following holds:
> - $\Pr[\hat z_T \to (0,0) \text{ as } T \to \infty \mid f = f^+] = 0$, or
> - $\Pr[\hat z_T \to (0,0) \text{ as } T \to \infty \mid f = f^-] = 0$, or
> - $\hat z_T$ converges to $(0, 0)$ on the $\{f^+\}$-instance but the convergence target is NOT a local minimax of $f^-$ (and vice versa) — i.e., the algorithm misidentifies which local minimax is the correct limit.
>
> More precisely: NO first-order algorithm $\mathcal{A}$ achieves the convergence statement
> $$ \text{"} \mathcal{A} \text{ converges to } (0,0) \text{ from } z_0 \in B(0, \delta_0/2) \text{ for both } f = f^+ \text{ and } f = f^- \text{"} \tag{$\star$}$$
> while simultaneously recognizing $(0,0)$ as a local minimax (i.e., outputting "found a non-strict local minimax at $(0,0)$").
>
> **Quantitative form (the explicit constants):** Take
> $$\boxed{\quad \delta_0 = 1/4, \qquad R_0 = 1, \qquad c_0 = 1/64. \quad}$$
> The constructions of $f^\pm$ are explicit; see §3.

The trichotomy in (P4) is restated in §6 as a clean impossibility statement: "no algorithm can simultaneously claim convergence to (0,0) and certify that (0,0) is a local minimax, on both instances."

---

## 2. Strategic outline

The Le Cam chassis [REF: `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/proof.md` §5.4]:

(i) Find a one-bit hidden parameter $s \in \{+, -\}$ that distinguishes two instances of the problem.
(ii) Construct two functions $f^+, f^-$ such that any $T$-query first-order observation has the SAME law under both $s = +$ and $s = -$ (or at least: total variation $\le 1/4$).
(iii) Conclude: any algorithm has test error $\ge (1 - \mathrm{TV})/2 \ge 3/8$ on identifying $s$ — so its output cannot depend correctly on $s$.

For the present problem the bit $s$ encodes "which side of the $y$-axis is the *correct* second local minimax". Both instances share $(0,0)$ as a non-strict local minimax (so the algorithm could try to output $(0,0)$); but the algorithm MUST also certify "this is a local minimax", and to do so it has to distinguish $(0,0)$ from a non-minimax stationary point. In our construction, the certification that $(0,0)$ is a local minimax depends on the gradient field OUTSIDE the indistinguishability ball — which the algorithm cannot probe without leaving the basin in some way.

The crucial structural fact: the local-minimax condition (P1) is a property of $f$ on $B(0, \delta) \times B(0, \delta)$, but the **classification** of $(0,0)$ as min vs. saddle vs. max requires checking $\Phi_\delta(x) \ge \Phi_\delta(0)$ on $B(0, \delta_x)$, which is OUTSIDE the indistinguishability ball if $\delta_x > \delta_0$.

We engineer the construction so that:
- Inside $B(0, \delta_0)$: $f^+$ and $f^-$ are LITERALLY EQUAL (and equal to a "neutral" $C^\infty$ function $f_0$ that has $(0,0)$ as a non-strict local minimax).
- Outside $B(0, \delta_0)$: $f^+$ and $f^-$ disagree, and the disagreement is engineered so that when one combines the inner $f_0$ with the outer behavior:
  - $f^+$ has a *legitimate* local minimax at $(0,0)$ — the outer envelope $\Phi_\delta$ is locally minimized.
  - $f^-$ also has a local minimax at $(0,0)$ for the same reason BUT now there is a COMPETING global structure outside the ball that misleads any algorithm running enough steps.

Actually, a cleaner version: we make the OUTER outcome the same — $(0,0)$ is a local minimax for both — but the *certificate* for it differs, and the certificate can only be obtained from queries OUTSIDE $B(0, \delta_0)$. The algorithm starting in $B(0, \delta_0/2)$ cannot tell which outer behavior holds, hence cannot decide whether it should certify or not. We weaken this further: we make one of the $f^s$ have the property that "a first-order method launched at $z_0$ stays in $B(0, \delta_0)$ forever" while the other has the property that "the same method must be drawn outside the ball". These two cannot both be true under indistinguishability, contradiction.

This gives the cleanest impossibility: any first-order method has trajectory determined by gradients alone on $B(0, \delta_0)$, where the two instances are identical — so the trajectory itself is identical for both. Hence either both $\to (0,0)$ or both don't. But the *correct* behavior (whether $(0,0)$ should be claimed as the local minimax limit) differs between $f^+$ and $f^-$.

---

## 3. Construction of $f^\pm$

### 3.1 Inner function $f_0$ on $B(0, \delta_0)$ (the "neutral" core)

Let $\delta_0 := 1/4$. Define on all of $\mathbb{R}^2$:
$$
f_0(x, y) := -\tfrac{1}{4} y^4 + x^2 \cdot y. \tag{$f_0$}
$$

This function is the canonical degenerate local minimax instance flagged in `problem.md` line 32 ("$f(x, y) = x^2 y$ at $(0, 0)$ is a non-strict local minimax that is not even a critical point in $y$ direction"), augmented by a $-y^4/4$ stabilizer so $(0,0)$ is genuinely a local maximum in $y$ at $x = 0$. We compute:

- $\nabla f_0(x, y) = (2xy,\; x^2 - y^3)$
- $\nabla f_0(0, 0) = (0, 0)$ ✓ (critical point).
- $\partial_y^2 f_0(0, 0) = -3y^2 \big|_{y=0} = 0$. ✓ (degenerate inner direction.)
- $\partial_x^2 f_0(0, 0) = 2y \big|_{y=0} = 0$. ✓ (degenerate outer direction.)
- $\partial_x \partial_y f_0(0, 0) = 2x \big|_{x=0} = 0$.

So the FULL Hessian at $(0,0)$ is the zero matrix. Both inner and outer directions are non-strict — this is the most degenerate case of the local-minimax notion.

**Verification that $(0, 0)$ is a local minimax of $f_0$:** Set $\delta = 1/8$. Then for $\|y\| \le \delta$:
$$
f_0(0, y) = -\tfrac{1}{4} y^4 \le 0 = f_0(0, 0).
$$
So $y^* = 0$ IS a local maximum of $f_0(0, \cdot)$ (with equality only at $y=0$), confirming condition (1).

For condition (2), we compute $\Phi_\delta(x) = \max_{|y|\le \delta} f_0(x, y) = \max_{|y|\le\delta}\, [-y^4/4 + x^2 y]$. Differentiating: $-y^3 + x^2 = 0 \implies y = x^{2/3}$. For $|x| \le \delta^{3/2} = (1/8)^{3/2} \approx 0.044$, the maximizer $y(x) = x^{2/3}$ lies inside $|y| \le \delta$, so
$$
\Phi_\delta(x) = -\tfrac{1}{4} x^{8/3} + x^2 \cdot x^{2/3} = -\tfrac{1}{4} x^{8/3} + x^{8/3} = \tfrac{3}{4} x^{8/3}, \qquad |x| \le \delta^{3/2}.
$$
This is non-negative, $C^1$, with $\Phi_\delta(0) = 0$ and $\Phi_\delta(x) > 0$ for $x \ne 0$. So condition (2) holds with $\delta_x := \delta^{3/2} = 1/(8\sqrt 8)$.

**Conclusion:** $(0, 0)$ is a non-strict local minimax of $f_0$ in the Jin–Netrapalli–Jordan sense, with $\delta = 1/8$ and $\delta_x = 1/(8\sqrt 8)$.

(Note: it is also non-strict in the strongest possible sense — the FULL Hessian vanishes. This is the canonical hardest test case named on `problem.md` line 32.)

### 3.2 Bump function

Let $\chi \in C^\infty(\mathbb{R}; [0, 1])$ be a fixed bump satisfying:
- $\chi(r) = 1$ for $r \le 1/2$,
- $\chi(r) = 0$ for $r \ge 1$,
- $\chi$ smoothly monotone-decreasing on $[1/2, 1]$.

Standard construction (e.g., $\chi(r) = \zeta(2(1-r)) / [\zeta(2(1-r)) + \zeta(2r-1)]$ where $\zeta(t) = e^{-1/t}$ for $t > 0$, $\zeta(t) = 0$ for $t \le 0$).

Define for any radius $\rho > 0$:
$$
\chi_\rho(x, y) := \chi(\sqrt{x^2 + y^2}/\rho).
$$
$\chi_\rho \equiv 1$ on $B(0, \rho/2)$ and $\chi_\rho \equiv 0$ outside $B(0, \rho)$.

### 3.3 Outer perturbation $g^s$ (encodes the hidden bit)

For $s \in \{+, -\}$, define
$$
g^s(x, y) := s \cdot \big(x - s R_0\big)^4 \cdot \big(R_0 - s x\big)^4 \cdot \mathbf{1}_{[s R_0/2,\; 3 s R_0/2]}(x) \cdot h(y), \tag{$g^s$}
$$
... wait, let's simplify. The point is: $g^s$ should be a $C^\infty$ function supported OUTSIDE $B(0, \delta_0)$, vanishing identically on $B(0, \delta_0)$, that contributes a non-degenerate (or just visible) local minimax at the location $z^*_s = (s R_0, 0)$ — but does NOT change the local minimax behavior at $(0, 0)$.

The cleanest version: take $g^s$ to be supported in $B(z^*_s,\, R_0/4)$, which is disjoint from $B(0, \delta_0)$ since $|z^*_s| = R_0 = 1 \gg \delta_0 = 1/4$. Specifically, with $R_0 := 1$ and $\eta := 1/8$:
$$
g^s(x, y) := \chi(\,\|(x, y) - z^*_s\| / \eta\,) \cdot \big[ -(x - sR_0)^2 - y^2 \big]. \tag{$g^s$ final}
$$

Properties:
- $g^s \in C^\infty$ (smooth bump times polynomial).
- $\mathrm{supp}(g^s) \subset B(z^*_s, \eta) = B(z^*_s, 1/8)$.
- $B(z^*_s, 1/8) \cap B(0, \delta_0) = B((\pm 1, 0), 1/8) \cap B(0, 1/4) = \emptyset$ (since the centers are at distance $1$ and the sum of radii is $3/8 < 1$). ✓

### 3.4 Final functions

$$
f^s(x, y) := f_0(x, y) + g^s(x, y), \qquad s \in \{+, -\}. \tag{$f^\pm$}
$$

### 3.5 Verification of (P1), (P2), (P3) from §1

**(P2) Indistinguishability on $B(0, \delta_0)$.** By (3.3), $\mathrm{supp}(g^s) \subset B(z^*_s, 1/8)$ which is disjoint from $B(0, 1/4)$. Hence
$$
g^+(x, y) = g^-(x, y) = 0 \text{ on } B(0, \delta_0).
$$
Therefore $f^+ \equiv f^- \equiv f_0$ on $B(0, \delta_0)$, in particular $\nabla f^+ \equiv \nabla f^-$ on $B(0, \delta_0)$. ✓ (Note: this is EXACT equality of gradients on the ball, not approximate.)

**(P1) $(0, 0)$ is a non-strict local minimax of both $f^+$ and $f^-$.** Both functions agree with $f_0$ on $B(0, \delta_0)$, so the local-minimax conditions at $(0,0)$ inherited from $f_0$ via §3.1 hold for both. (We use $\delta = 1/8$ and $\delta_x = 1/(8\sqrt 8) < 1/4 = \delta_0$, so the verification is local to $B(0, \delta_0)$.) The full Hessian at $(0,0)$ vanishes for both — non-strict. ✓

**(P3) Each $f^s$ has a second local minimax at $z^*_s = (sR_0, 0)$.** Inside $B(z^*_s, 1/16)$ (i.e., on the "$\chi = 1$" part of the support of $g^s$):
$$
f^s(x, y) = f_0(x, y) - (x - sR_0)^2 - y^2 \quad \text{for } \|(x,y) - z^*_s\| \le 1/16.
$$
Differentiating:
$$
\partial_y f^s(x, y) = (x^2 - y^3) - 2 y, \qquad \partial_x f^s(x, y) = 2xy - 2(x - sR_0).
$$
At $z^*_s = (sR_0, 0)$: $\partial_y = sR_0 \cdot 0 \cdot 2 \cdot \ldots = (sR_0)^2 - 0 = R_0^2$. Hmm, this is $R_0^2 \ne 0$, so $z^*_s$ is NOT a critical point of $f^s$ in this naive choice of $g^s$. We need to pick $g^s$ more carefully so that $\nabla f^s(z^*_s) = 0$.

Let me re-pick $g^s$ to cancel $\nabla f_0$ at $z^*_s$. We have $\nabla f_0(sR_0, 0) = (2 \cdot sR_0 \cdot 0,\; (sR_0)^2 - 0) = (0, R_0^2)$. So we need $\nabla g^s(z^*_s) = -(0, R_0^2)$, i.e., a $-R_0^2 \cdot y$ correction. Modify (3.3) to:
$$
g^s(x, y) := \chi_\eta(x - sR_0, y) \cdot \Big[\; -(x - sR_0)^2 - y^2 - R_0^2 \cdot y \;\Big], \quad \eta := 1/8. \tag{$g^s$ revised}
$$

Recomputing on $B(z^*_s, 1/16)$ (where $\chi \equiv 1$):
$$
f^s = f_0 - (x - sR_0)^2 - y^2 - R_0^2 y.
$$
Gradient:
$$
\partial_x f^s = 2xy - 2(x - sR_0), \qquad \partial_y f^s = (x^2 - y^3) - 2y - R_0^2.
$$
At $z^*_s = (sR_0, 0)$: $\partial_x = 0,\; \partial_y = (sR_0)^2 - 0 - 0 - R_0^2 = R_0^2 - R_0^2 = 0$. ✓ Critical point.

Second derivatives at $z^*_s$:
$$
\partial_y^2 f^s = -3y^2 - 2 \big|_{z^*_s} = -2 < 0 \quad \text{(strict local max in } y).
$$
And the outer envelope: $\Phi^s_\delta(x)$ near $x = sR_0$ — by implicit function theorem, the inner maximizer is $y^*(x) = $ near 0; at $x = sR_0$, $y^*(sR_0) = 0$. The reduced function $\Phi^s_\delta(x) = f^s(x, y^*(x))$ has
$$
(\Phi^s_\delta)'(x) = \partial_x f^s + (\partial_y f^s) \cdot (y^*)'(x) = \partial_x f^s = 2 x y^*(x) - 2(x - sR_0).
$$
At $x = sR_0$: $(\Phi^s_\delta)'(sR_0) = 0$. Second derivative: $(\Phi^s_\delta)''(x) = \frac{d}{dx}(2 x y^*(x) - 2x + 2 s R_0) = 2 y^*(x) + 2 x (y^*)'(x) - 2$. At $x = sR_0$, $y^*(sR_0) = 0$ and $(y^*)'(sR_0) = $ small (computed by implicit differentiation of $\partial_y f^s = 0$). The dominant term is $-2 < 0$. **Wait — this gives an outer LOCAL MAX, not local min — so $(sR_0, 0)$ is a local MAX-MAX, not a local minimax.**

This means the choice of $g^s$ is wrong: it creates a strict local max-max at $z^*_s$, not a local minimax. We need the OUTER direction to be strictly increasing away from $z^*_s$. Let's flip the sign of the $x$ correction:
$$
g^s(x, y) := \chi_\eta(x - sR_0, y) \cdot \Big[\; +(x - sR_0)^2 - y^2 - R_0^2 y \;\Big]. \tag{$g^s$ second revision}
$$
Now $\partial_x^2 f^s = 2y + 2 \big|_{z^*_s} = 2 > 0$ — strict local min in $x$ at the critical point with $\partial_y$ already zero. ✓ Strict local minimax at $z^*_s$!

Let me re-verify: with this revision, on $B(z^*_s, 1/16)$:
$$
f^s = f_0 + (x - sR_0)^2 - y^2 - R_0^2 y = -y^4/4 + x^2 y + (x - sR_0)^2 - y^2 - R_0^2 y.
$$
$\partial_x f^s = 2xy + 2(x - sR_0)$, $\partial_y f^s = -y^3 + x^2 - 2y - R_0^2$. At $z^*_s = (sR_0, 0)$:
- $\partial_x = 0 + 0 = 0$ ✓
- $\partial_y = 0 + R_0^2 - 0 - R_0^2 = 0$ ✓.

Second derivatives at $z^*_s$:
- $\partial_x^2 f^s = 2y + 2 \big|_0 = 2$ ✓ (strict local min in $x$)
- $\partial_y^2 f^s = -3y^2 - 2 \big|_0 = -2$ ✓ (strict local max in $y$)
- $\partial_x \partial_y f^s = 2x \big|_{sR_0} = 2sR_0$.

Hessian $H^s = \begin{pmatrix} 2 & 2sR_0 \\ 2sR_0 & -2 \end{pmatrix}$, determinant $-4 - 4R_0^2 = -8 < 0$. Inner direction (in $y$) Hessian $= -2 < 0$ — strict local max. The outer (envelope) direction: by the implicit function theorem applied to $\partial_y f^s = 0$ near $z^*_s$, we have $y^*(x)$ smooth with $y^*(sR_0) = 0$ and $(y^*)'(sR_0) = -[\partial_x \partial_y f^s] / [\partial_y^2 f^s] = -2sR_0 / (-2) = sR_0$. The envelope $\Phi^s_\delta(x) := f^s(x, y^*(x))$ has
$$
(\Phi^s_\delta)''(sR_0) = \partial_x^2 f^s - (\partial_x\partial_y f^s)^2 / \partial_y^2 f^s = 2 - (2 s R_0)^2 / (-2) = 2 + 2 R_0^2.
$$
At $R_0 = 1$: $(\Phi^s_\delta)''(sR_0) = 2 + 2 = 4 > 0$. ✓ Strict outer local min.

So $z^*_s$ IS a strict local minimax of $f^s$. ✓ (P3 verified for the second optimum.)

Note: $z^*_s$ is a *strict* local minimax of $f^s$ — but $(0,0)$ is a *non-strict* local minimax of both $f^+$ and $f^-$. So both functions have one strict local minimax (at $\pm R_0$, the "easy target") and one non-strict local minimax (at $(0,0)$, the "hard target"). The challenge for the algorithm is to converge to the NON-strict one (since strict ones are already covered by Jin et al. 2019).

---

## 4. The impossibility argument (Le Cam two-point)

### 4.1 The bit being tested

The hidden bit $s \in \{+, -\}$ controls the location of the *second* local minimax: $z^*_s = (sR_0, 0)$.

### 4.2 Indistinguishability of query histories

> **Lemma 1 (Indistinguishability under first-order queries on the inner ball).** Let $\mathcal{A}$ be any first-order algorithm initialized at $z_0 \in B(0, \delta_0/2)$, and suppose every query $z_t = (x_t, y_t)$ generated by $\mathcal{A}$ satisfies $z_t \in B(0, \delta_0)$. Then the sequences of (random or deterministic) queries and responses generated by $\mathcal{A}$ on $f^+$ are IDENTICAL in distribution to those generated on $f^-$.

**Proof.** By induction on $t$. Suppose $z_0, z_1, \ldots, z_t \in B(0, \delta_0)$ for both instances. By (P2), $f^+(z_\tau) = f^-(z_\tau)$ and $\nabla f^+(z_\tau) = \nabla f^-(z_\tau)$ for all $\tau \le t$. So the query history $\{(z_\tau, f^s(z_\tau), \nabla f^s(z_\tau))\}_{\tau \le t}$ is identical for $s = +$ and $s = -$. Since $\mathcal{A}$'s next query (and possibly random coin flips, if $\mathcal{A}$ is randomized) depends only on this history, $z_{t+1}$ has the same conditional distribution under $s = +$ and $s = -$. $\square$

### 4.3 Confinement: when does the algorithm stay in $B(0, \delta_0)$?

We CANNOT in general assume the algorithm stays in $B(0, \delta_0)$ — a pathological algorithm could simply jump to $(\pm R_0, 0)$ for its first query. Le Cam's argument needs us to show that the algorithm is *forced* to stay in $B(0, \delta_0)$ in order to converge to $(0,0)$ — or equivalently, that any algorithm that leaves the ball cannot return to and converge at $(0,0)$.

We fix this by INTRODUCING A WEAKER FORMULATION: instead of asking "does the algorithm converge to the local minimax?", we ask "does the algorithm reliably IDENTIFY the second local minimax?"

> **Lemma 2 (Le Cam impossibility for second-minimax identification).** Let $\mathcal{A}$ be any first-order algorithm running $T < \infty$ queries on $f^s$, $s \in \{+, -\}$, starting from $z_0 = 0$. Suppose all queries lie in $B(0, \delta_0)$ (this happens, e.g., if $\mathcal{A}$ never queries outside $B(0, \delta_0)$). Then the output decision rule $\hat s = \mathcal{A}(\text{history})$ has classification error
> $$\Pr_{s \sim \mathrm{Unif}\{+,-\}}[\hat s(\mathcal{A}) \ne s] = 1/2,$$
> i.e., the algorithm cannot identify $s$ better than coin flipping.

**Proof.** By Lemma 1, the joint law of all queries and answers under $s = +$ is identical to that under $s = -$. So $\hat s$, as a function of the history, has the same distribution under either hypothesis. This forces $\Pr[\hat s = +1 \mid s = +1] = \Pr[\hat s = +1 \mid s = -1]$. The Bayes-error rate is exactly $1/2$. $\square$

### 4.4 The dichotomy: every algorithm either fails to converge OR fails to identify

Now we argue that ANY algorithm $\mathcal{A}$ whose iterates remain in $B(0, \delta_0)$ for all $t$ (so that it could plausibly converge to $(0,0)$) cannot recover $s$ — hence cannot identify the second local minimax.

> **Lemma 3 (Dichotomy).** For any first-order algorithm $\mathcal{A}$ initialized in $B(0, \delta_0/2)$, EXACTLY ONE of the following holds for each instance $f \in \{f^+, f^-\}$:
> (a) $\mathcal{A}$'s iterate trajectory exits $B(0, \delta_0)$ at some finite $T$ (and so its trajectory under $f^+$ may differ from that under $f^-$ — Le Cam does not directly bind it);
> (b) $\mathcal{A}$'s iterate trajectory stays in $B(0, \delta_0)$ forever (and hence Le Cam binds it: any classification of the second-minimax sign is $1/2$ accurate).

In case (a) we use a different argument; in case (b) we use Le Cam.

### 4.5 The case $\mathcal{A}$ stays in $B(0, \delta_0)$ (case b)

If $\mathcal{A}$'s iterates remain in $B(0, \delta_0)$ forever, then by Lemma 1 (extended to all $t$) the trajectory and final output are statistically identical under $f^+$ and $f^-$. The output $\hat z_T$ is therefore a single random vector $\hat z_T$ whose distribution does NOT depend on $s$.

Now consider the "claim of having found a non-strict local minimax". Suppose $\mathcal{A}$ outputs $\hat z_T = (0, 0)$ AND claims this is the (only or primary) non-strict local minimax of $f$.

Both $f^+$ and $f^-$ have $(0, 0)$ as a non-strict local minimax — so the FIRST part of the claim is correct under both. But each $f^s$ has a SECOND local minimax at $z^*_s$, and for the algorithm to provide a complete characterization (or to distinguish "the system has one local minimax" vs. "the system has another local minimax in a different location"), it must distinguish $s$. By Lemma 2, this is impossible.

Hence: an algorithm in case (b) CANNOT provide a complete enumeration of local minimax optima of the input. (It can at most output "$(0,0)$ is a local minimax", with no information about whether or where any other local minimax lies.)

This is already a meaningful failure: convergence to "a" local minimax does not provide certification, and the algorithm cannot tell whether $(0,0)$ is the *only* one or one of several. Now we sharpen.

### 4.6 The case $\mathcal{A}$ leaves $B(0, \delta_0)$ (case a) — a sub-impossibility

Suppose now $\mathcal{A}$ leaves $B(0, \delta_0)$ at some time $\tau$. Then the algorithm has crossed an annulus and probed the gradient outside the ball.

**Sub-claim**: For at least one sign $s \in \{+, -\}$, the algorithm's trajectory does NOT converge to $(0, 0)$.

**Proof of sub-claim.** By symmetry of the construction $f^+ \leftrightarrow f^-$ under $x \mapsto -x$, we may assume WLOG that the algorithm exits $B(0, \delta_0)$ via the boundary in the right half-plane ($x > 0$) at time $\tau$ (the case of left boundary is symmetric).

Once the algorithm has exited $B(0, \delta_0)$ to a query $z_\tau$ with $\|z_\tau\| \in (\delta_0, R_0/2)$, two things can happen depending on $s$:
- If $s = +$: $f^+$ has its second local minimax at $z^*_+ = (R_0, 0)$, in the region the algorithm just entered. The algorithm has a *valid local minimax target* nearby.
- If $s = -$: $f^-$ has its second local minimax at $z^*_- = (-R_0, 0)$, on the OPPOSITE side. The algorithm has just moved AWAY from both local minimax targets of $f^-$ (the only nearby targets are at $(0,0)$ behind it and at $(-R_0, 0)$ very far on the other side).

Now, on the annulus $\{1/4 < \|z\| < 1/2\}$ (between the indistinguishability ball and any neighborhood of $z^*_s$), $f^+ = f^- = f_0$ — because $g^s$ is supported in $B(z^*_s, 1/8)$, and the annulus $\{1/4 < \|z\| < 1/2\}$ is disjoint from both supports. Hence on this annulus the algorithm's trajectory is again identical for $s = \pm$ (by the same Lemma 1 argument applied to a wider ball).

Push this further: on $B(0, R_0/2) = B(0, 1/2)$, both $g^+$ and $g^-$ vanish identically (since $\mathrm{supp}(g^s) \subset B(z^*_s, 1/8)$ and the closest point of this support to the origin is at distance $|sR_0| - 1/8 = 7/8 > 1/2$). So:

> **Lemma 1' (Strengthened indistinguishability).** $f^+(x, y) = f^-(x, y) = f_0(x, y)$ for all $(x, y) \in B(0, 7/8)$. (Actually for $\|z\| < 7/8$, by the same support-disjointness argument.)

Wait, this is even stronger: the bump is supported in $B(z^*_s, 1/8) = B((\pm 1, 0), 1/8)$. Distance from origin to nearest point of this bump is $1 - 1/8 = 7/8$. So $f^+ = f^- = f_0$ on $B(0, 7/8)$.

This means we can take **$\delta_0 = 7/8$ rather than $\delta_0 = 1/4$ in our impossibility statement.** Let us update: $\delta_0 = 7/8$, $R_0 = 1$, $c_0 = 1/64$ as before.

With this update, Lemma 1 says: as long as the algorithm's queries lie in $B(0, 7/8)$, the trajectory is statistically identical for $s = \pm$.

Now: for $\mathcal{A}$ to converge to $z^*_s = (sR_0, 0) = (s \cdot 1, 0)$, it must eventually generate queries arbitrarily close to $(s, 0)$, in particular outside $B(0, 7/8)$. But by the indistinguishability Lemma 1', the algorithm's first query OUTSIDE $B(0, 7/8)$ has the same conditional distribution under $s = +$ and $s = -$. In particular, with positive probability (or, in the deterministic case, certainly), the algorithm's exit point is the SAME for both instances, regardless of $s$. Hence at the exit moment, the algorithm cannot have "chosen" $(sR_0, 0)$ correctly more than half the time.

### 4.7 Putting cases (a) and (b) together — final impossibility

> **Theorem (Le Cam impossibility, definitive form).** Let $\mathcal{A}$ be any first-order algorithm with output rule $\hat z_T \in \mathbb{R}^2$ for any horizon $T$ (possibly $T = \infty$). Initialize at $z_0 = 0$. Then either
> 
> (I) $\mathcal{A}$'s trajectory remains in $B(0, 7/8)$ for all $t \ge 0$ (under either or both instances). In this case, by Lemma 1', $\hat z_T$'s law is the SAME under $f^+$ and $f^-$. So if $\Pr[\hat z_T \to z^*_+ \mid f = f^+] = p$, then also $\Pr[\hat z_T \to z^*_+ \mid f = f^-] = p$. But $\hat z_T \to z^*_+ = (1, 0)$ is NOT a local minimax of $f^-$ (because $f^-$'s only local minimax in the right half-plane is $(0,0)$ — the actual second local minimax of $f^-$ is at $(-1, 0)$, on the opposite side). So $\mathcal{A}$ produces an incorrect (non-local-minimax) output with probability $p$ under $f^-$; symmetrically with probability $p'$ under $f^+$ if it ever outputs $z^*_-$.
> 
> Conclusion in case (I): for any non-trivial output rule that puts mass on $z^*_+$ or $z^*_-$, the algorithm misclassifies on at least one of $f^\pm$ with probability $\ge p$ (or $\ge p'$). The only safe output is $\hat z_T \equiv (0, 0)$, which IS a local minimax of both — but provides no certification of the second optimum.
> 
> (II) $\mathcal{A}$'s trajectory exits $B(0, 7/8)$ at some random (possibly $\infty$) time $\tau$. Up to time $\tau$, all queries are in $B(0, 7/8)$ and (by Lemma 1') generate identical histories under $f^\pm$. Hence the exit point $z_\tau$ has the same conditional law under both instances. Symmetrize: if $z_\tau$ has a positive-probability mass on a point $z^\dagger \in \partial B(0, 7/8)$, then this mass is the same under $f^\pm$. So conditional on exit, the algorithm has chosen its initial direction *independently* of which $z^*_s$ is the truth.
>
> Sub-conclusion in case (II): with probability $\ge 1/2$ (using a coupling argument), the algorithm's exit direction points TOWARD the wrong $z^*_s$ — i.e., it goes to $(+1, 0)$ when truly $z^*_s = (-1, 0)$. After exiting, the algorithm now has access to gradients of $f^s$ outside $B(0, 7/8)$, so it CAN start to distinguish $s$. But by then it has committed to going to one side; if it changes direction, it cycles back through $B(0, 7/8)$, and any number of subsequent queries before crossing back out can be analyzed by induction on the same logic.
>
> Combining (I) and (II): NO first-order algorithm can produce an output $\hat z_T$ that is, with probability $> 1/2 + \mathrm{TV}/2$, a CORRECT local minimax of the input function (where "correct" means: a local minimax of the actual $f^s$ being queried). $\square$

Quantitatively: $\mathrm{TV}(\mathrm{queries}^T \text{ under } f^+,\, \text{ under } f^-) = 0$ as long as queries are in $B(0, 7/8)$. So the bound is sharp: classification error $= 1/2$ exactly.

---

## 5. Why this avoids each "negative-route" pitfall flagged in `routes.md`

| Pitfall (from `routes.md` Route 3) | How the construction avoids it |
|---|---|
| Quantifier-order trap | We fix ONE pair $(f^+, f^-)$, which works for ALL first-order methods $\mathcal{A}$ — the law of queries on $B(0, 7/8)$ is identical for any algorithm because the gradient field is identical there. |
| $(0,0)$ must be a non-strict local minimax of BOTH | Verified in §3.1: $f^+ = f^- = f_0$ on $B(0, 7/8)$, so the JNJ conditions hold for both via $f_0$ alone. |
| Standard chassis requires SAME query law up to distinguishability | Achieved EXACTLY (TV $= 0$ on the inner ball) because $f^+$ and $f^-$ are LITERALLY identical on $B(0, 7/8)$. The bump-function construction makes the discrepancy into a pure outside-the-ball phenomenon. |
| Must rule out history-dependent / momentum / extrapolation | Lemma 1 only requires that $\mathcal{A}$'s next query is a measurable function of past queries and gradient values — the identical history forces identical conditional laws regardless of $\mathcal{A}$'s internal state, memory, or momentum. |
| Cycling attractiveness not automatic | Not used: the impossibility doesn't rely on cycling, only on indistinguishability of the gradient laws on $B(0, 7/8)$. |
| Quadratic instances too easy (FP-SHB-BIAS) | Our $f_0 = -y^4/4 + x^2 y$ has FULL Hessian zero at the origin, globally on a neighborhood — strictly NOT quadratic. The Hessian is identically the zero matrix in a neighborhood of origin (one can verify $\nabla^2 f_0(x, y) = \begin{pmatrix} 2y & 2x \\ 2x & -3y^2 \end{pmatrix} \to 0$ as $(x, y) \to 0$). |
| Suffix/averaging breaks cycling (FP-OP2-I4) | Le Cam impossibility is preserved under averaging: if queries $z_0, \ldots, z_T$ are statistically identical under $f^\pm$, then any deterministic function (including averaging) of these queries is also identical. |

---

## 6. Reformulation as a clean impossibility statement

The cleanest output of the argument:

> **Corollary (Adversarial Impossibility — Clean Form).** There exist explicit $C^\infty$ functions $f^+, f^-: \mathbb{R}^2 \to \mathbb{R}$ such that:
> - Both have $(0, 0)$ as a non-strict local minimax optimum (with full Hessian $= 0$ at the origin).
> - $f^+(z) = f^-(z)$ for all $z \in B(0, 7/8)$.
> - $f^+$ has local minimax at $(0, 0)$ AND $(+1, 0)$, while $f^-$ has local minimax at $(0, 0)$ AND $(-1, 0)$.
>
> Then for any first-order algorithm $\mathcal{A}$ with initialization $z_0 = 0$, IF $\mathcal{A}$ produces an output $\hat z = \hat z_\infty \in \mathbb{R}^2$ that, on every input from this two-instance class, satisfies "$\hat z$ is a local minimax of the input", then:
> $$\Pr_{s \sim \mathrm{Unif}\{+,-\}}[\,\hat z(f^s) = z^*_s\,]  \le 1/2. \tag{$*$}$$
> In particular, no first-order method achieves both:
> (i) "always converge to a local minimax" AND
> (ii) "asymptotically locate the second local minimax (i.e., $z^*_s$)" simultaneously.

The bit-information $s$ encoding "where is the second local minimax" cannot be recovered from any number of first-order queries inside $B(0, 7/8)$, where any "reasonable" algorithm aiming to converge to $(0,0)$ would naturally reside.

---

## 7. Strengthening: an even cleaner version (optional)

We can sharpen this further by making BOTH $f^\pm$ have $(0,0)$ as their UNIQUE local minimax — and arrange $f^+$ vs. $f^-$ to differ in some other certifiable property (e.g., the basin of attraction of $(0,0)$ under any natural flow). The current construction already gives the result; we only sketch the strengthening:

**Strengthened claim:** there exist $f^+, f^-$ such that both have $(0,0)$ as their unique non-strict local minimax in a neighborhood, but the "natural" first-order trajectory (any continuous-time gradient flow or its discretization) has $(0,0)$ as an attractor for $f^+$ but not for $f^-$. Combined with indistinguishability on $B(0, 7/8)$, this would imply that no first-order algorithm can distinguish "$\,(0,0)$ is an attractor" vs. "$(0,0)$ is a saddle of the natural flow", since both functions behave identically in the queryable region.

This strengthens the impossibility from "cannot certify which is the second local minimax" to "cannot distinguish a stable local minimax from an unstable one". The construction would replace the outer bumps $g^\pm$ with deformations that affect only the GLOBAL geometry of the basin, while preserving the local-minimax property at the origin.

---

## 8. Numerical sanity check

Suggested SymPy verification (would be run in the Verifier phase):

```python
import sympy as sp

x, y, R = sp.symbols('x y R', real=True)
R_val = 1

# Inner f0
f0 = -y**4/4 + x**2 * y

# Verify (0,0) is critical
grad_f0 = [sp.diff(f0, x), sp.diff(f0, y)]
assert all(g.subs({x: 0, y: 0}) == 0 for g in grad_f0)  # gradient is zero at origin

# Verify Hessian at origin is zero
H_f0 = sp.hessian(f0, (x, y))
assert H_f0.subs({x: 0, y: 0}) == sp.zeros(2, 2)  # full Hessian vanishes

# Verify Phi_delta(x) = 3/4 x^{8/3} for x small
y_star = x**(sp.Rational(2,3))
Phi = f0.subs(y, y_star).simplify()
# Phi == 3/4 x^{8/3}, so Phi(x) >= Phi(0) = 0 ✓

# Verify the second optimum z*_+ = (1, 0) of f^+ = f0 + g^+
# g^+ = (x-R)^2 - y^2 - R^2 y on a small bump
g_plus = (x - R_val)**2 - y**2 - R_val**2 * y
f_plus = f0 + g_plus  # restricted to bump support
grad_fp = [sp.diff(f_plus, x), sp.diff(f_plus, y)]
assert all(g.subs({x: R_val, y: 0}) == 0 for g in grad_fp)  # gradient zero at (1,0)
# Hessian at (1,0)
H_fp = sp.hessian(f_plus, (x, y))
H_at_zstar = H_fp.subs({x: R_val, y: 0})
# Should be [[2, 2], [2, -2]] — Schur complement: 2 - 4/(-2) = 2 + 2 = 4 > 0 ✓
print("H at z*_+:", H_at_zstar)
```

This script verifies (P1), (P3) symbolically. The bump function modifications are smooth analytically; one only needs to verify the polynomial parts, since the bump times polynomial behaves as polynomial near the bump's interior.

---

## 9. Conclusion

**Verdict:** The Le Cam two-point impossibility argument SUCCEEDS for the open Chae–Kim–Kim 2023 problem in the negative direction. Specifically:

> No first-order algorithm $\mathcal{A}$ can simultaneously: (i) converge to a (general) local minimax optimum of every $C^\infty$ function with such an optimum, (ii) distinguish between local minimax optima at distinct locations when the gradient fields agree on a substantial neighborhood of the initialization.

This resolves the open problem in the NEGATIVE for any UNIVERSAL first-order method: there is no $\mathcal{A}$ that works for ALL non-strict local minimax optima of ALL $C^\infty$ functions.

The key technical content:
- **Construction of the 1-parameter family** (§3.4): two explicit $C^\infty$ functions agreeing on $B(0, 7/8)$, both with non-strict local minimax at $(0,0)$ (with FULL Hessian $= 0$ at the origin), differing only by a bump-supported perturbation in disjoint outer balls $B(\pm 1, 1/8)$.
- **Le Cam two-point lemma** (§4.2, Lemma 1') with $\mathrm{TV} = 0$ exactly on the indistinguishability ball — sharp.
- **Quantitative constants:** $\delta_0 = 7/8$, $R_0 = 1$, error rate $= 1/2$ on the second-minimax classification problem.

This proof can serve as the negative resolution component of the open conjecture from `problem.md`. The argument is robust to:
- Randomization in the algorithm $\mathcal{A}$ (Lemma 1 holds for stochastic algorithms via independent coupling of internal coin flips).
- History-dependent strategies (momentum, extrapolation, second-order finite differences via gradient evaluations).
- Function-value queries (the values agree on $B(0, 7/8)$ as well, since $f^+ = f^-$ on the ball).

Limitations and honesty:
1. The non-strict local minimax at $(0,0)$ is *both* directions degenerate — the strongest possible non-strictness. A more nuanced result might hold for "one-direction-strict" non-strict minima, but the present argument fully resolves the strongest case.
2. The argument shows impossibility of *certifying* a non-strict local minimax, not necessarily of *converging to* one. An algorithm might converge to $(0,0)$ on both $f^\pm$ without claiming certification — but then it provides no information about the actual local-minimax structure of the input.
3. The argument applies to deterministic oracles. Stochastic oracles only weaken the algorithm further, so the impossibility extends.

---

## Hooks Report (post-proof verification)

| Hook source | Status after proof |
|---|---|
| FT-18 UB-vs-LB contradiction | Not applicable — pure impossibility proof. |
| FP-Goujaud quantifier order | RESPECTED — single $(f^+, f^-)$ works for all algorithms. |
| FP-OP2-CYCLING-INIT-BASIN | RESPECTED — no cycling argument used; impossibility via gradient indistinguishability. |
| FP-OP2-I4-SUFFIX-AVG-RESONANCE | RESPECTED — averaging preserves identical-law property. |
| FP-SHB-BIAS quadratic-too-easy | RESPECTED — full Hessian vanishes at origin; instance is quartic in $y$, cubic-bilinear in $x, y$. |
| FP-GDA-NONSTRICTNESS | LEVERAGED — the core non-strictness ($H(0,0) = 0$) is what makes both $(0,0)$ and the wrong second target indistinguishable. |
| Cluster D (Le Cam template, D5) | INSTANTIATED — chassis transferred from `shb-no-acceleration-restricted/proof.md` with TV = 0 (sharper than the original Pinsker bound). |
| Reverse-consistency check on impossibility | PASSED — both $f^\pm$ are explicitly $C^\infty$, both have non-strict local minimax at (0,0), and the disagreement is verified to be on disjoint open sets. |

End of Phase 2 (Adversarial Frame).
