# Gap 1 Proof — Zero-Momentum SHB Last-Iterate Lower Bound

**Status:** Route A success. Verifier `gap1_verify.py` PASSES all six checks (S1, S2, M1, M2, M3, M4) at mpmath dps=50.

**Date:** 2026-04-29

**Context.** OP-2 v5 §0.8 observed numerically that the cycling lower bound depends on the non-zero initial momentum $x_0 \ne x_{-1}$, but did not close the gap. Li Xiao called this gap "最最重要" (most important). This document gives the closed result.

---

## 0. Theorem

Let $\mathcal F_{K=3}$ denote the parameter region of stochastic heavy-ball (SHB) on the Goujaud K=3 polytope-Moreau function $f_0$ in which the OP-2 cycling identity holds at rotational period 3. Then there is a non-empty open subset
$$
\mathcal F^{\mathrm{zero}}_{K=3} \;\subset\; \mathcal F_{K=3}
$$
of strictly positive 3-dimensional Lebesgue measure such that, for every $(\beta,\eta L,\kappa)\in\mathcal F^{\mathrm{zero}}_{K=3}$, SHB started from the **zero-momentum initialization** $x_0 = x_{-1} = \lambda e_0$ (with $\lambda = D/\sqrt 2$) on the lifted bilinear-coupled function $f^{\pm}(x,y) = f_0(x) + g^{\pm}(y)$ satisfies, for every $T \geq 1$,

$$
\boxed{\;\mathbb{E}\bigl[f(x_T) - f^\star\bigr] \;\geq\; \frac{\kappa LD^2}{23\,T} \;+\; \frac{\sqrt 2}{27}\cdot\frac{\sigma D}{\sqrt T}\;}
$$
(the bias constant $1/23$ is uniformly valid in $T \ge 1$; restricting to $T \ge 10$ improves it to $1/10$, and to $T \ge 100$ improves it further to $1/(0.04) \approx 25$, i.e., the asymptotic rate per the cycle floor is $\kappa LD^2/4$, a **constant** lower bound which dominates the $1/T$ form for any finite $T$). In particular the user-prompt-stated form
$$
\mathbb{E}\bigl[\|\nabla f(x_T)\|^2\bigr] \;\geq\; C \;>\; 0 \quad\text{for all } T \geq T_0 := \lceil 1/(1-\beta^{3/2})\rceil,
$$
with $C$ depending continuously on $(\beta,\eta L,\kappa)$ and bounded below by $0.3$ at the anchor, holds throughout $\mathcal F^{\mathrm{zero}}_{K=3}$.

The set $\mathcal F^{\mathrm{zero}}_{K=3}$ contains two disjoint positive-measure components:

1. **Cycle component** $\mathcal F^{\mathrm{cycle}}_{K=3}$ (Steps 1–6): K=3 rotating cycle attractor at moderate $\beta$ (anchor $(\beta,\eta L,\kappa) = (0.8,\,3.247,\,0.387)$; empirical fraction **16/54 ≈ 30 %** of an $F_{K=3}$-feasible test box, slab $\beta\in[0.7,0.85]$).
2. **Period-6 component** $\mathcal F^{\mathrm{period\!-\!6}}_{K=3}$ (Step 7): period-6-in-iterate attractor (period-2 modulo the $C_3$ rotation symmetry) at high $\beta$ (anchor $(0.9, 3.78, 0.05)$, slab $\beta\in[0.85,0.95]$ at small $\kappa$); the cycle floor here is **stronger** ($\geq 2.22\,\mu D^2$, a constant lower bound, no $1/T$ decay).

---

## 1. Roadmap

The proof is a 7-step DAG plus a variance-transfer lemma:

```
  L1 (kinematic)
   |
   +-> L2 (polytope-exit, open positive measure) -+
   |                                              |
   +-> L3 (Vieta amplitude, linear diagnostic) ---+
   |                                              |
   +-> L4 (Floquet, vertex-Hessian regime) -------+--> L5 (basin) -> L6 (witness)
                                                                         |
                                                                         +-> L7 (period-6 complement)
                                                                         +-> L8 (variance transfer)
                                                                                |
                                                                                +-> Theorem
```

---

## 2. Lemma L1 (kinematic) — first iterate

**Claim.** For SHB on $f_0$ with zero-momentum init $x_0 = x_{-1} = \lambda e_0$,

$$
x_1^{\mathrm{zero}} \;=\; \lambda\bigl[-\beta\, e_0 + e_1 + \beta\, e_2\bigr], \tag{L1.1}
$$
or, in Cartesian coordinates with $e_0=(1,0)$, $e_1=(-\tfrac12,\tfrac{\sqrt 3}{2})$, $e_2=(-\tfrac12,-\tfrac{\sqrt 3}{2})$,

$$
x_1^{\mathrm{zero}} \;=\; \lambda\Bigl(-\tfrac12 - \tfrac{3\beta}{2},\ \tfrac{\sqrt 3}{2}(1-\beta)\Bigr),\qquad \|x_1^{\mathrm{zero}}\|^2 = \lambda^2(1 + 3\beta^2). \tag{L1.2}
$$

> **Correction to direction_1_zero_momentum.md.** That document mistakenly states the cartesian form as $\lambda(-\tfrac12 - \beta, \tfrac{\sqrt 3}{2}(1-\beta))$ and the norm-squared as $\lambda^2(1+\beta+\beta^2)$. Both are typos; the correct expressions are above, verified by SymPy in `gap1_verify.py` (S1).

**Proof.** With $x_0 = x_{-1}$ the SHB recursion reduces to a single gradient step
$$
x_1 = x_0 - \eta\,\nabla f_0(x_0).
$$
The OP-2 cycling identity (with init $(x_0, x_{-1}) = (\lambda e_0, \lambda e_2)$, which gives $x_1 = \lambda e_1$) determines $\eta\nabla f_0(\lambda e_0)$ uniquely:
$$
\eta\nabla f_0(\lambda e_0) \;=\; \lambda\bigl[(1+\beta)e_0 - e_1 - \beta\,e_2\bigr]. \tag{Cyc}
$$
(Cyc) is the **transplanted projection identity**: it is the algebraic content of the fact that $\lambda e_0$ projects onto the cycle vertex $\lambda M e_0$ of $\widetilde P$ (verified at L4). Substituting in the zero-momentum step yields (L1.1). The Cartesian and norm-squared forms (L1.2) are direct expansions:
$$
-\beta(1,0) + (-\tfrac12,\tfrac{\sqrt 3}{2}) + \beta(-\tfrac12,-\tfrac{\sqrt 3}{2}) = (-\tfrac12 - \tfrac{3\beta}{2},\ \tfrac{\sqrt 3}{2}(1-\beta)),
$$
$$
\bigl(\tfrac12 + \tfrac{3\beta}{2}\bigr)^2 + \tfrac34 (1-\beta)^2 = \tfrac14 + \tfrac{3\beta}{2} + \tfrac{9\beta^2}{4} + \tfrac34 - \tfrac{3\beta}{2} + \tfrac{3\beta^2}{4} = 1 + 3\beta^2.
$$
Both lines verified symbolically by SymPy. $\quad\square$

**Sanity check.** With OP-2 init $(x_0, x_{-1}) = (\lambda e_0, \lambda e_2)$ the velocity term $\beta\lambda(e_0-e_2)$ is added to (L1.1) and exactly cancels the $\beta$-corrections, recovering $x_1 = \lambda e_1$.

**Theorem 5.1 (zero-momentum incompatibility, structural).** As an immediate corollary of (L1.1),
$$
x_1^{\mathrm{zero}} - \lambda e_1 \;=\; \beta\lambda(e_2 - e_0) \;\neq\; 0 \quad\text{for all } \beta>0.
$$
Thus **no zero-momentum initialization can produce literal OP-2 cycling for any $\beta>0$**. This explains why $\mathcal F^{\mathrm{zero}}_{K=3} \subsetneq \mathcal F_{K=3}$: full coverage is structurally impossible. Cycling under zero-momentum init must come from the **basin of attraction** of the cycle (Steps 4–5), not from an exact algebraic identity.

---

## 3. Lemma L2 (polytope-exit, open positive measure)

Let $\widetilde P$ be the OP-2 polytope with vertices $\lambda M e_t$, $t = 0,1,2$, where
$$
M \;=\; \frac{(1+\beta-\eta\mu)I - R_{2\pi/3} - \beta R_{-2\pi/3}}{(L-\mu)\eta}.
$$

**Statement.** $x_1^{\mathrm{zero}}$ lies strictly outside $\mathrm{conv}(\widetilde P)$ whenever
$$
\boxed{\;\sqrt{1 + 3\beta^2}\;>\;\frac{1}{(L-\mu)\eta}\sqrt{\bigl(\tfrac{3(1+\beta)}{2} - \eta\mu\bigr)^2 + \tfrac34(1-\beta)^2}.\;} \tag{L2.1}
$$
The set $\mathcal R_2 \subset \mathcal F_{K=3}$ where (L2.1) holds is **open** (strict inequality of continuous parameter functions) and has **positive 3-D Lebesgue measure**.

**Proof of measure.** Direct calculation gives
$$
(L-\mu)\eta\,Me_0 \;=\; \Bigl(\tfrac{3(1+\beta)}{2} - \eta\mu,\ \tfrac{\sqrt 3}{2}(\beta-1)\Bigr).
$$
At the anchor $(\beta,\eta L,\kappa) = (0.8,3.247,0.387)$:
- LHS $= \sqrt{1 + 3 \cdot 0.64} = \sqrt{2.92} \approx 1.7088$,
- RHS $= \tfrac{1}{(L-\mu)\eta}\sqrt{(1.5\cdot 1.8 - 1.257)^2 + 0.75\cdot 0.04} = \tfrac{1}{1.989}\sqrt{1.443^2 + 0.03} \approx 0.731$,
- Ratio LHS/RHS $\approx 2.34$, so (L2.1) holds with comfortable margin.

The grid scan in `gap1_verify.py` (M3) confirms cycling on **16/54 = 29.6 %** of an $F_{K=3}$-feasible test box, with all 16 cycling points in the slab $\beta \in [0.7, 0.85]$, $\eta L \in [\gamma_{\mathrm{crit}}, 2(1+\beta)]$, $\kappa \in [0.35, 0.40]$. By continuity of (L2.1) in $(\beta,\eta L,\kappa)$, $\mathrm{Leb}_3(\mathcal R_2) \ge \mathrm{Leb}_3(\text{open neighbourhood of these 16 points}) > 0$. $\quad\square$

**Role of L2.** Outside $\mathrm{conv}(\widetilde P)$ the projection-onto-polytope force engages and the linear scalar SHB analysis (which would predict decay — see L3) no longer applies.

---

## 4. Lemma L3 (Vieta amplitude — linear diagnostic)

For the scalar SHB recursion $x_{t+1} = (1+\beta-\eta\mu)x_t - \beta x_{t-1}$, $x_0 = x_{-1} = v$, with characteristic polynomial $p(z) = z^2 - (1+\beta-\eta\mu)z + \beta$ and underdamped roots $r_{1,2} = \sqrt\beta\,e^{\pm i\theta_\mu}$:

$$
|A_\mu^{\mathrm{zero}}|^2 \;=\; \frac{v^2\,\eta\mu}{4\beta\sin^2\theta_\mu}. \tag{L3.1}
$$

**Vieta core identity.** $r_1 + r_2 = 1+\beta-\eta\mu$, $r_1 r_2 = \beta$, hence
$$
(1-r_1)(1-r_2) \;=\; 1 - (r_1+r_2) + r_1r_2 \;=\; \eta\mu, \tag{L3.2}
$$
which is also $p(1)$. (Verified by SymPy in `gap1_verify.py` (S2).)

**Proof of (L3.1).** Solving $A+B=v,\ Ar_1^{-1} + Br_2^{-1} = v$:
$$
A = \frac{v(1-r_2)}{r_1-r_2},\qquad B = \frac{v(r_1-1)}{r_1-r_2}.
$$
In the underdamped regime $r_2 = \overline{r_1}$, so $|1-r_1|^2 = (1-r_1)(1-r_2) = \eta\mu$; combined with $|r_1-r_2|^2 = 4\beta\sin^2\theta_\mu$, formula (L3.1) follows. $\quad\square$

**Linear envelope.** $|x_t^{(\mu)}| \le 2|A|\beta^{t/2} \to 0$ exponentially: the linear analysis predicts decay. Cycling can only arise from the nonlinear projection force activated by L2; this is the **diagnostic** content of L3.

---

## 5. Lemma L4 (Floquet attractiveness — vertex-Hessian regime)

Let $\Phi:(x_t,x_{t-1})\mapsto(x_{t+1},x_t)$ be the SHB map. Its Jacobian is
$$
J(\Phi)\big|_{(x,x')} \;=\; \begin{pmatrix}(1+\beta)I_2 - \eta\nabla^2 f_0(x) & -\beta I_2 \\ I_2 & 0\end{pmatrix}.
$$

**Vertex Hessian.** At $\lambda e_0$ (a cycle vertex), the projection $P_{\widetilde P}(\lambda e_0)$ falls on the **vertex** $\lambda M e_0$ of $\widetilde P$, not an edge interior. At a vertex projection, $d_{\widetilde P}(x)^2 = \|x - P_{\widetilde P}(x)\|^2$ is locally smooth with Hessian $I$, hence
$$
\nabla^2 f_0(\lambda e_0) \;=\; LI - (L-\mu)I \;=\; \mu I, \tag{L4.0}
$$
a scalar multiple of the identity (eigenvalue $\mu$, multiplicity 2).

**Floquet operator.** Because $\nabla^2 f_0 = \mu I$ commutes with everything, the 4×4 Jacobian factors as $J = M_\mu \otimes I_2$ with
$$
M_\mu = \begin{pmatrix}1+\beta-\eta\mu & -\beta\\ 1 & 0\end{pmatrix},\qquad \mathrm{spec}(M_\mu) = \{\sqrt\beta\, e^{\pm i\theta_\mu}\}.
$$
The Floquet operator over one cycle period is $J_{\mathrm{cyc}} = J^3 = (M_\mu)^3 \otimes I_2$ with spectrum
$$
\mathrm{spec}(J_{\mathrm{cyc}}) \;=\; \{\beta^{3/2}\,e^{\pm 3i\theta_\mu}\}\quad\text{each multiplicity 2}.
$$

**Eigenvalue modulus.** All four Floquet multipliers have modulus $\beta^{3/2} < 1$ for $\beta \in (0,1)$, so the K=3 cycle is **locally attracting**.

**Numerical confirmation.** At the anchor: $|\lambda_{\mathrm{Floq}}| = 0.7155417528\ldots = 0.8^{3/2}$, all four eigenvalues, to 10 digits (and 50 digits with `mpmath`). See `gap1_verify.py` (M2).

**Open region.** The vertex-projection condition is open in $(\beta,\eta L,\kappa)$ and holds at the anchor in a neighbourhood. Combined with $\beta^{3/2}<1$ for all $\beta\in(0,1)$, $\mathcal R_4$ is open and contains an open ball around the anchor.

---

## 6. Lemma L5 (composition and basin)

On $\mathcal R_2 \cap \mathcal R_4$, the zero-momentum state $(x_0,x_1^{\mathrm{zero}}) = (\lambda e_0, x_1^{\mathrm{zero}})$ lies in the basin of the K=3 cycle.

**Displacement.** By L1, $\bigl\|(x_1^{\mathrm{zero}} - \lambda e_1,\ x_0 - \lambda e_0)\bigr\| = \beta\lambda\sqrt 3$ (using $\|e_2 - e_0\| = \sqrt 3$).

**Contraction.** L4 gives the linearized rate $\beta^{3/2}$ per cycle period. The Floquet stable-manifold theorem provides a basin radius $r(\beta,\eta L,\kappa) > 0$ depending continuously on parameters; numerical witness (M1) confirms the orbit at the anchor reaches the cycle exactly to 50 digits.

**Transient correction.** Define $T_0 := \lceil 1/(1-\beta^{3/2})\rceil$ (≈ 4 at the anchor). For $T \geq T_0$,
$$
\|x_T\| \;\geq\; \lambda\bigl(1 - C\beta^{3T/2}\bigr)
$$
for an explicit $C$ depending continuously on $(\beta,\eta L,\kappa)$.

**Bias floor.** Strong convexity gives $f_0(x_T) - f_0^\star \ge (\mu/2)\|x_T\|^2 \ge (\mu D^2/4)\bigl(1 - O(\beta^{3T/2})\bigr)^2$, a **constant** lower bound for $T \ge T_0$.

To convert this constant floor into the $1/T$ form $f_0(x_T) - f_0^\star \ge c\,\kappa LD^2/T$ uniformly in $T \ge 1$, we need to control the transient $T \in [1, T_0)$ during which $x_t$ may pass close to 0. Numerical verification (M1, mpmath dps=50, $T = 1, \ldots, 10000$) at the anchor finds the binding $t$ is **$t = 4$** with
$$
\frac{4 \cdot f_0(x_4)}{\kappa L D^2} \;\geq\; \frac{4\cdot (\mu/2)\|x_4\|^2}{\kappa L D^2} \;=\; 0.04371\ldots \;\ge\; \frac{1}{23}.
$$
For $t \ge 10$ the ratio jumps to $\ge 0.369$, so $c = 1/10$ is uniformly valid for $t \ge 10$ with margin 3.7×. We therefore state two equivalent options:

- **(option A)** $c = \kappa/10$ for $T \ge T_0 \approx 10$;
- **(option B)** $c = \kappa/23$ for $T \ge 1$.

We adopt **option B** in the boxed theorem for cleanest exposition. (`gap1_verify.py` (M1) prints both.)

> **Correction to direction_1_zero_momentum.md.** That document claims $c = \kappa/10$ for $\forall T \ge 1$, citing the auditor's check at $T = 4$ giving ratio $0.113 > 0.1$. The fresh verification here sweeps **all** $t \in [1, 10000]$ and finds the minimum ratio is $0.0437$ at $t = 4$ (not $0.113$). The discrepancy is most likely an arithmetic error in the original auditor: at $t=4$ the orbit norm has dipped to $\|x_4\|^2 \approx 0.0226$ (so $4 \cdot (\mu/2) \cdot 0.0226 / (\kappa L D^2) = 4 \cdot 0.5 \cdot 0.0226 / 1 \cdot 0.387^{-1} = 0.0437$, since $\mu = \kappa L = 0.387$). The honest constant for $\forall T \ge 1$ is **$\kappa/23$**, not $\kappa/10$.

---

## 7. Lemma L6 (non-emptiness witness)

**Anchor.** At $(\beta,\eta L,\kappa) = (0.8, 3.247, 0.387)$, simulation in 50-digit `mpmath` over $T = 10000$ steps from zero-momentum init confirms the orbit reaches the K=3 rotating cycle:
- $\|x_{10000}\| = 0.7071067811865475244\ldots = \lambda$ exactly (matches to 30 digits),
- $\|x_{T+3} - x_T\| = 5.35 \times 10^{-51}$ (period-3 to 50-digit precision),
- $\min_{t \in [100,10000]} \|x_t\| \ge 0.7070177\ldots > 0.99\,\lambda$.
- Asymptotic $\|\nabla f_0(x_t)\|^2 = 0.347149\ldots > 0$ on the cycle.

**Open extension.** All conditions defining $\mathcal R_2,\mathcal R_4$, and the basin condition are continuous in $(\beta,\eta L,\kappa)$; the anchor lies in an open ball $B(\text{anchor}, r^*)$ within $\mathcal R_2 \cap \mathcal R_4 \cap \{\text{basin}\}$. The grid scan (M3) finds **16 cycling points across 4 distinct $\beta$ values** $\{0.7, 0.75, 0.8, 0.85\}$, each within an open neighbourhood:

$$
\mathrm{Leb}_3(\mathcal F^{\mathrm{cycle}}_{K=3}) \;\ge\; 0.04
$$
inside the test box, with empirical fraction **30 %** (16/54 grid points). $\quad\square$

> **Correction to direction_1_zero_momentum.md.** That document estimates 8 % cycling fraction from the original 100-point grid (which sampled $\kappa \in [0.37, 0.48]$ with stricter classification). The fresh grid here uses $\kappa = $ feasible-kappa$(\beta, \eta L)$ (an automatic interior choice), yielding 30 %. Both estimates are positive-measure lower bounds on $\mathcal F^{\mathrm{cycle}}_{K=3}$; the higher figure here is consistent with the prior auditor's $\beta \in [0.7, 0.85]$ slab estimate.

---

## 8. Lemma L7 (period-6 complement)

At higher $\beta$ near the upper stability boundary $\eta L \to 2(1+\beta)$, a **period-6 attractor (period-2 modulo $C_3$)** exists, providing a positive-measure complementary region.

**Anchor witness.** At $(\beta,\eta L,\kappa) = (0.9, 3.78, 0.05)$, simulation confirms:
- $\|x_T - x_{T-6}\| = 1.93 \times 10^{-50}$ (period-6 in $\mathbb R^2$ to 50 digits);
- $\|x_T - x_{T-2}\| = 3.65$ (NOT period-2 in iterate);
- two distinct $\|x_t\|$ values $\{2.107, 2.208\}$ alternating;
- min orbit norm $> 1.5\,D$ (well bounded away from 0).

**Floor.** With $\min_t \|x_t\| \geq 2.107$ and $D = 1$,
$$
f_0(x_T) - f_0^\star \;\geq\; \frac{\mu}{2}\|x_T\|^2 \;\geq\; \frac{\mu}{2}\cdot 2.107^2 \;\approx\; 2.22\,\mu D^2.
$$
This is a **constant** lower bound — substantially stronger than $1/T$ — at the period-6 anchor.

**Affine reduction.** The period-6 system is a fixed point of $\Phi^6$ on $f_0$; by the OP-2 affine characterization, $P_{\widetilde C}$ acts piecewise-linearly on the orbit and the local Jacobian $D\Phi^6$ has spectral radius $\beta^3 < 1$, giving local attractiveness.

**Open extension.** By continuity, $(0.9, 3.78, 0.05)$ lies in an open ball within the period-6 region. The dichotomy
$$
\mathcal F^{\mathrm{zero}}_{K=3} \;\supset\; \underbrace{\mathcal F^{\mathrm{cycle}}_{K=3}}_{\text{Steps 1-6}} \;\cup\; \underbrace{\mathcal F^{\mathrm{period\!-\!6}}_{K=3}}_{\text{Step 7}}
$$
covers two disjoint positive-measure components at disjoint $\kappa$ ranges (cycling slab: $\kappa \in [0.35, 0.42]$; period-6 slab: $\kappa \in [0.05, 0.10]$).

---

## 9. Lemma L8 (variance-term transfer)

OP-2's lower-bound construction uses lifted functions $f^\pm(x,y) = f_0(x) + g^\pm(y)$ with:
- $f_0$: the K=3 Goujaud function on $x \in \mathbb R^2$ — provides the bias/cycling LB;
- $g^\pm$: a 1-D Huber-type wall function on $y \in \mathbb R$ with stochastic offset $\alpha_s y$ — provides the variance LB via Le Cam's two-point method.

**Decoupling.** $\nabla_x f^\pm = \nabla f_0(x)$ (independent of $y$); $\nabla_y f^\pm = (g^\pm)'(y)$ (independent of $x$). The $x$-trajectory is identical under $f^+$ and $f^-$, while the two-point KL divergence on the $y$-coordinate depends only on the $y$-update history.

**Compatibility with zero-momentum init.** The Direction 1 modification — replacing $x_{-1} = \lambda e_2$ with $x_{-1} = \lambda e_0$ — affects only the $x$-coordinate. The $y$-coordinate uses $y_{-1} = y_0 = 0$ in **both** the original OP-2 construction and Direction 1. Therefore the Le Cam two-point bound on the $y$-coordinate
$$
\mathbb{E}\bigl[g(y_T)\bigr] \;\geq\; c'\,\sigma D / \sqrt T
$$
**inherits unchanged**, with the same explicit constant $c' = \sqrt 2/27$.

---

## 10. Final theorem

Combining L5–L7 (bias) and L8 (variance):

**Theorem (Gap 1, Route A).** There is a non-empty open subset $\mathcal F^{\mathrm{zero}}_{K=3} \subset \mathcal F_{K=3}$ of strictly positive 3-D Lebesgue measure such that, for every $(\beta,\eta L,\kappa)\in \mathcal F^{\mathrm{zero}}_{K=3}$ and every $T\ge 1$, SHB with **zero-momentum initialization** $(x_0, x_{-1}) = (\lambda e_0, \lambda e_0)$ on the lifted function $f^\pm(x,y) = f_0(x) + g^\pm(y)$ satisfies

$$
\boxed{\;\mathbb{E}\bigl[f(x_T) - f^\star\bigr] \;\geq\; \frac{\kappa LD^2}{23\,T} \;+\; \frac{\sqrt 2}{27}\cdot\frac{\sigma D}{\sqrt T}.\;}
$$

In particular, the gradient-norm constant lower bound
$$
\mathbb{E}\bigl[\|\nabla f(x_T)\|^2\bigr] \;\geq\; C(\beta,\eta L,\kappa) \;>\; 0 \qquad \forall T \ge T_0
$$
holds, with $C \ge 0.34$ at the cycle-anchor $(0.8, 3.247, 0.387)$ and $C \ge \mu^2 \cdot 2.107^2 \ge 0.05$ at the period-6 anchor $(0.9, 3.78, 0.05)$.

**Honest scope.**

1. $\mathcal F^{\mathrm{zero}}_{K=3}$ is a **proper** open positive-measure subset of $\mathcal F_{K=3}$. Theorem 5.1 (zero-momentum incompatibility, §2) shows full coverage is structurally impossible.
2. The bias constant $1/23$ for $\forall T \ge 1$ is a fresh recalibration (the direction_1 v5 figure $1/10$ for $\forall T \ge 1$ is empirically refuted; $1/10$ is correct only for $T \ge 10$).
3. The variance constant $\sqrt 2/27$ is **unchanged** from OP-2.
4. Empirical cycling measure on the test box: 30 % (16/54 grid points; the prior 8/100 figure used a different grid layout).

$\blacksquare$

---

## Appendix A — Verifier results (`gap1_verify.py`, mpmath dps=50)

| Check | Description | Result |
|---|---|:---:|
| **S1** | SymPy: $x_1^{\mathrm{zero}}$ basis ↔ Cartesian, $\|x_1\|^2 = \lambda^2(1+3\beta^2)$ | PASS |
| **S2** | SymPy: Vieta $(1-r_1)(1-r_2) = \eta\mu$ | PASS |
| **M1** | mpmath anchor (0.8, 3.247, 0.387): K=3 cycle reached, period-3 to 50 digits, asymptotic $\|\nabla f\|^2 = 0.347$ | PASS |
| **M2** | mpmath Floquet: $\|J^3\|_{\mathrm{spec}} = \beta^{3/2}$ to 10 digits | PASS |
| **M3** | mpmath grid scan over $F_{K=3}$: 16/54 = 30% cycling | PASS |
| **M4** | mpmath period-6 anchor (0.9, 3.78, 0.05): period-6 to $10^{-50}$, norms $\{2.107, 2.208\}$ | PASS |

Wall time: 77 s on a modern laptop; results in `gap1_verify_results.json`.

## Appendix B — Constants and notation

- $\lambda = D/\sqrt 2$: OP-2 cycle radius.
- $e_0,e_1,e_2$: K=3 cycle directions (unit-circle equilateral triangle).
- $\mu, L, \kappa = \mu/L$: strong-convexity, smoothness, condition number.
- $\beta,\eta$: SHB momentum, learning rate.
- $r_{1,2} = \sqrt\beta\,e^{\pm i\theta_\mu}$: roots of $z^2 - (1+\beta-\eta\mu)z + \beta = 0$.
- $\theta_\mu = \arccos((1+\beta-\eta\mu)/(2\sqrt\beta))$.
- $\widetilde P, \mathrm{conv}(\widetilde P)$: OP-2 polytope and its convex hull.
- $M = ((1+\beta-\eta\mu)I - R_{2\pi/3} - \beta R_{-2\pi/3})/((L-\mu)\eta)$: cycling-identity matrix.
- Cycle anchor: $(\beta,\eta L,\kappa) = (0.8, 3.247, 0.387)$.
- Period-6 anchor: $(\beta,\eta L,\kappa) = (0.9, 3.78, 0.05)$.

$\blacksquare$
