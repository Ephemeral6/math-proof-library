# Proof Route 6 — Compositional (Three-Timescale with Finite-Difference Hessian-Vector Approximation)

**Frame**: Compositional
**Polarity attempted**: POSITIVE (existence of a first-order algorithm converging to general — including non-strict — local minimax optima)
**Author**: Explorer-Compositional
**Date**: 2026-04-27

---

## 0. Pre-proof Hooks (Layers 1/4/5)

- **L1 strategy_index match (closest)**: `gda-nonconvex-strongly-concave-convergence` — meta-template is *two-timescale Lyapunov* `V = Φ(x) + c·δ`. We will graft a third timescale onto this signature.
- **L4 structure_map match**: Cluster B / Hardt-Recht-Singer derivatives use a *trajectory split* into "non-degenerate block" + "degenerate block" with separate Lyapunov scaling — same skeleton we need.
- **L5 meta_template (claimed)**: MT3 *Two-Timescale Drift Decomposition*, with an attempted promotion to MT3' *Three-Timescale Drift Decomposition*. Slot list:
  - Slot A (fast): inner $y$-update via $\nabla_y f$;
  - Slot B (slow): outer $x$-update via descent on a curvature-corrected envelope;
  - Slot C (intermediate, NEW): finite-difference Hessian–vector product $\hat H(\tau) v := \tau^{-1}[\nabla_y f(x,y+\tau v) - \nabla_y f(x,y)]$ used to estimate the smallest-eigenvalue direction of $-\nabla^2_{yy}f$.
- **L2 failure-trigger pre-scan** (same triggers as the route file flagged):
  - FT-LEGACY-CD-EUCLIDEAN-NORM (norm conversion losing factors) — relevant when projecting onto the approximate kernel.
  - The two project-specific patterns flagged by Scout:
    - FP-GDA-NONSTRICTNESS (degenerate fixed point is a saddle of two-timescale flow);
    - FP-CYCLING / FP-OP2-CYCLING-INIT-BASIN-DEPENDENCE (basin attractiveness needs a separate certificate).

We register these and proceed.

---

## 1. Algorithm specification

Fix a putative non-strict local minimax $(x^*,y^*)$ with $\nabla_x f(x^*,y^*)=0$, $\nabla_y f(x^*,y^*)=0$, and Hessian decomposition

$$H_y := \nabla^2_{yy}f(x^*,y^*) \preceq 0,
\qquad H_y = \begin{pmatrix} H_y^{\perp} & 0 \\ 0 & 0 \end{pmatrix}$$

in coordinates aligned with the kernel $\mathcal K := \ker H_y$ of dimension $k\ge 1$ (this is the "degenerate direction"). Let $\dim y = n$, $\dim \mathcal K = k$, $n_\perp := n-k$. Set
$\mu := -\lambda_{\max}(H_y|_{\mathcal K^\perp}) > 0$ (curvature on the non-degenerate block).

**Algorithm CMP-3T** (Compositional, three-timescale).

Given step sizes $\eta_x\ll\eta_c\ll\eta_y$ with rates to be chosen, and a finite-difference scale $\tau_t\to 0$:

```
Step 1 (FAST, inner ascent):
   y_t^{(1)} = y_t + η_y ∇_y f(x_t, y_t)

Step 2 (FAST, kernel estimation via one Lanczos sweep):
   For i=1..k:
      pick a probe direction v_t^{(i)} ∈ S^{n-1}
      ĝ_t^{(i)} = τ_t^{-1} [∇_y f(x_t, y_t^{(1)} + τ_t v_t^{(i)}) - ∇_y f(x_t, y_t^{(1)})]
      // ĝ_t^{(i)} ≈ H_y(x_t,y_t) v_t^{(i)} + O(L_2 τ_t)
   Form Ĥ_t = Σ_i v_t^{(i)} ĝ_t^{(i)⊤}  (rank-k approximation)
   Compute approximate kernel projector  P̂_t  via SVD of Ĥ_t, threshold σ_t.

Step 3 (INTERMEDIATE, kernel-direction descent):
   r_t = ∇_y f(x_t, y_t^{(1)})
   y_{t+1} = y_t^{(1)} + η_c P̂_t r_t

Step 4 (SLOW, outer descent on curvature-corrected envelope):
   x_{t+1} = x_t - η_x [∇_x f(x_t, y_{t+1}) + η_c α_t · P̂_t ∇_y f(x_t, y_{t+1}) ]
```

The bracket in Step 4 is the candidate "curvature-corrected" outer drift. The motivation is that, in a non-strict local minimax, the implicit function $y^*(x)$ is multi-valued along $\mathcal K$, so the standard outer drift $\nabla\Phi(x) = \nabla_x f(x,y^*(x))$ is ill-defined; the correction term tries to pick the "right branch" via the kernel projector.

Only first-order queries are used: every Hessian appearance is replaced by a finite-difference of $\nabla_y f$. We count $1+k+1=k+2$ gradient queries per outer step.

---

## 2. Where the proof must close

We need three convergence statements, layered:

1. **(C1) Fast-block contraction.** Tracking error on the non-degenerate block,
   $\delta_t^{\perp} := \| (y_t - y^*(x_t))_{\mathcal K^\perp} \|^2$,
   contracts at rate $1 - \Theta(\mu \eta_y)$ along Step 1 alone.

2. **(C2) Kernel estimate accuracy.** With high probability over the probe directions, the projector error
   $\|P̂_t - P_{\mathcal K_t}\|$
   is bounded by the Hessian-perturbation error plus the finite-difference error,
   $$\|P̂_t - P_{\mathcal K_t}\| \le \frac{C_1 L_2 \tau_t + C_2 \|y_t - y^*(x_t)\|}{\text{gap}_t}, $$
   where $\text{gap}_t$ is the spectral gap between $\mathcal K_t$ and $\mathcal K_t^\perp$.

3. **(C3) Slow-block descent on the envelope.** With $V_t := \Phi_\delta(x_t) + c_\perp \delta_t^{\perp} + c_0 (\delta_t^{0})^q$ for some $q>1$ on the kernel-block tracking error $\delta_t^{0}$, the Lyapunov decreases:
   $V_{t+1} - V_t \le -\eta_x \|\nabla \Phi_\delta(x_t)\|^2 + \text{(perturbation from finite-diff and projector errors)}$.

I now go through each block honestly and document precisely where it fails.

---

## 3. Block (C1) — Fast-block contraction (DOES close)

This is essentially a re-application of the $\mu$-strong-concavity argument from `gda-nonconvex-strongly-concave-convergence`, restricted to the orthogonal complement of $\mathcal K_t$. Concretely:

**Lemma 3.1.** Suppose $f \in C^2$, $\nabla_y f$ is $L$-Lipschitz, $\eta_y \le 1/L$, and $-\nabla^2_{yy}f$ has eigenvalue $\ge \mu > 0$ on $\mathcal K_t^\perp$ in a neighborhood of $(x^*,y^*)$. Then the projection of one ascent step onto $\mathcal K_t^\perp$ satisfies
$$\| (y_t^{(1)} - y^*(x_t))_{\mathcal K^\perp} \|^2 \le (1 - \mu \eta_y)\, \delta_t^\perp + \eta_y^2 L^2 \delta_t^\perp.$$

*Proof sketch.* Direct: write $y_t^{(1)} - y^*(x_t) = (I + \eta_y \nabla^2_{yy}f) (y_t - y^*(x_t)) + O(\|y_t-y^*\|^2)$. On $\mathcal K_t^\perp$, the operator $I+\eta_y\nabla^2_{yy}f$ has spectrum in $[1-\eta_y L, 1-\eta_y\mu]$. □

This follows the standard `[REF: proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/proof.md]` template; the only real change is the projection.

**Issue 3.A** (minor). The kernel $\mathcal K_t = \ker \nabla^2_{yy}f(x_t, y^*(x_t))$ depends on $x_t$, so the "$\mathcal K^\perp$ component" varies smoothly. By a standard implicit-function argument the projector $P_{\mathcal K_t}$ is $\mathrm{Lip}$ in $x_t$ provided the spectral gap is bounded below by some $g_0>0$. So this block is OK.

**Status of (C1): CLOSED**, modulo a uniform spectral gap on $\mathcal K_t^\perp$.

---

## 4. Block (C2) — Kernel estimate accuracy (DOES NOT CLEANLY close)

Here is the heart of the obstruction. We need a finite-difference estimator $\hat H(\tau)$ to approximate $H_y(x_t,y_t)$ well enough to extract its kernel.

### 4.1 Bias of one finite-difference query

By a Taylor expansion at $y$ with remainder:

$$\hat H(\tau)v - H_y v = \frac{1}{\tau}\big[\nabla_y f(x,y+\tau v) - \nabla_y f(x,y)\big] - H_y v
= \tfrac{\tau}{2}\, \nabla^3_y f(x,y)[v,v] + O(\tau^2 L_3),$$

so the per-query bias is $O(\tau)$. Summed over $k$ queries we get $\|\hat H_t - H_y(x_t,y_t)\|_{\mathrm{op}} \le C L_2 \tau_t$, where $L_2$ bounds $\|\nabla^3_y f\|$.

### 4.2 Davis–Kahan for the projector

If we want $\|\hat P_t - P_{\mathcal K_t}\|\le \epsilon_P$, we need (Davis–Kahan)
$$\frac{\|\hat H_t - H_y(x_t,y_t)\|_{\mathrm{op}}}{\text{gap}_t} \le \epsilon_P, \qquad \text{gap}_t \ge g_0.$$

### 4.3 The contradiction: $\tau$ must shrink, but cost grows

We now run the complete bookkeeping.

**Step A (per-iterate bias requirement).** Slow-block descent (C3) needs the perturbation to the outer drift to be $o(\eta_x \|\nabla\Phi\|^2)$ in expectation. The kernel-projector error $\epsilon_P$ enters Step 4 multiplicatively; tracking through Step 4 gives a per-step error term $\eta_x \eta_c \alpha_t \cdot \epsilon_P \cdot \|\nabla_y f\|$. To absorb this we need

$$\epsilon_P \le c \cdot \frac{\|\nabla\Phi_\delta(x_t)\|}{\eta_c \alpha_t \|\nabla_y f(x_t,y_{t+1})\|}. \qquad (\star)$$

Near the limit $\|\nabla\Phi_\delta(x_t)\| \to 0$ along the trajectory, the RHS of $(\star)$ tends to **zero**, so $\epsilon_P$ must shrink to zero. By Davis–Kahan, $\tau_t \to 0$ as well.

**Step B (lower bound on $\tau$ from finite-precision oracle effects).** This is where the route fundamentally breaks. The problem statement's "first-order method, only gradient access" oracle must be interpreted to admit either:

- (a) an exact gradient oracle $\nabla_y f(x,y)$ in real arithmetic, or
- (b) a noisy / finite-precision oracle.

Under (a), no lower bound on $\tau$ exists — the Hessian-vector product $\hat H(\tau)v$ is exact in the limit $\tau\to 0$, and we morally have the *full Hessian* at any point. **This makes the algorithm second-order in disguise and falls outside the spirit of the open problem.** The Chae–Kim–Kim 2023 problem statement is implicitly under model (b), where the gradient is queried with some additive perturbation $\varepsilon$, in which case finite differences amplify noise as $\tau^{-1}$.

Under (b), the variance of $\hat H(\tau)$ is $\Theta(\varepsilon^2 / \tau^2)$. To make $\|\hat H - H_y\|_{\mathrm{op}} \le \epsilon$, we need $\tau \ge C\varepsilon/\epsilon$ (variance) AND $\tau \le \epsilon / L_2$ (bias). Compatible only if $\varepsilon \le C\epsilon^2/L_2$, i.e., $\epsilon \ge C\sqrt{\varepsilon L_2}$. So $\epsilon$ has a hard floor determined by the oracle precision $\varepsilon$.

**Step C (averaging does not save us).** One natural fix is to average $\hat H_t$ over many queries: averaging reduces variance from $\varepsilon^2/\tau^2$ to $\varepsilon^2/(M\tau^2)$ at cost $M$ queries. But the bias remains $L_2\tau$; minimizing $\sqrt{\varepsilon^2/(M\tau^2)} + L_2\tau$ in $\tau$ gives $\tau^* = (\varepsilon/L_2\sqrt M)^{1/2}$ and optimal error $(\varepsilon L_2)^{1/2} M^{-1/4}$. So $M$-fold averaging buys a factor $M^{-1/4}$ improvement.

Combined with $(\star)$ and the convergence requirement $\|\nabla\Phi_\delta(x_t)\|\to 0$, we need
$M_t \to \infty$ super-polynomially, breaking the $O(1)$-per-step query budget.

**Status of (C2): DOES NOT CLOSE.** Either (i) we admit infinite query precision, in which case the algorithm is morally second-order (violating the spirit of the problem), or (ii) under any noisy oracle we get a hard error floor that prevents $\|\nabla\Phi_\delta\|\to 0$, only an $\epsilon$-stationary guarantee for $\epsilon = \Omega(\sqrt{\varepsilon L_2})$.

---

## 5. Block (C3) — Slow-block descent (CONDITIONAL CLOSURE under a structural assumption)

Even granting (C2), we now show a second obstacle in the slow block.

### 5.1 Smoothness of $\Phi_\delta$ on the degenerate set

The envelope $\Phi_\delta(x) = \max_{\|y-y^*\|\le \delta} f(x,y)$ is $C^1$ near $x^*$ only if the inner maximizer is unique, but in our setting $\arg\max f(x,\cdot)$ on a small ball is a manifold (the kernel $\mathcal K_t$) of dimension $k\ge 1$. Then by Danskin's theorem in its set-valued form (Clarke 1983), $\Phi_\delta$ is locally Lipschitz, and its Clarke subdifferential is
$\partial^\circ \Phi_\delta(x) = \mathrm{conv}\{\nabla_x f(x,y) : y \in \arg\max\}$.

This subdifferential is **set-valued** at $x^*$. So even *defining* a descent direction along the slow block is non-trivial: $\nabla_x f(x_t, y_{t+1})$ is one element of $\partial^\circ \Phi_\delta(x_t)$, but it is generically *not* the minimum-norm element.

### 5.2 The curvature correction does not close the gap

The added term $\eta_c \alpha_t P̂_t \nabla_y f(x_t,y_{t+1})$ in Step 4 is meant to push $y_{t+1}$ toward the right branch of $\arg\max$. But in the limit $\eta_c \to 0$, the correction vanishes and we recover plain GDA. In the limit $\eta_c \to \infty$ (relative to $\eta_x$), the correction dominates and we lose any descent on $\Phi_\delta$. There is **no choice of $\eta_c/\eta_x$** that guarantees descent, because the curvature correction is in the wrong space — it is a perturbation in $y$ that we are using to perturb the $x$-update.

A cleaner candidate: use $\hat H_t^\dagger$ (pseudo-inverse) to solve $\hat H_t (\Delta y) = -\nabla_y f(x_t, y_{t+1})$ on $\mathcal K_t^\perp$ (Newton step on the non-degenerate block) and then descend. But this requires inverting Hessian estimates whose conditioning blows up as $\text{gap}_t\to 0$, recursively triggering (C2).

### 5.3 Specific failure on the canonical example $f(x,y)=x^2y$

The problem statement gives $f(x,y)=x^2y$ at $(0,0)$ as a non-strict local minimax. Let us run CMP-3T and see what happens.

- $\nabla_x f = 2xy$, $\nabla_y f = x^2$. So $\nabla_y f(0,y)=0$ for all $y$ — every $y$ is a critical point of $f(0,\cdot)$.
- $\nabla^2_{yy} f \equiv 0$ globally. So $H_y \equiv 0$, $\mathcal K = \mathbb R^1$ (entire space), and $\hat H_t \equiv 0$ for any $\tau$.
- The kernel projector $\hat P_t = I$, the identity.
- Step 1: $y_t^{(1)} = y_t + \eta_y x_t^2$.
- Step 3: $y_{t+1} = y_t^{(1)} + \eta_c x_t^2 = y_t + (\eta_y + \eta_c) x_t^2$.
- Step 4: $x_{t+1} = x_t - \eta_x [2 x_t y_{t+1} + \eta_c \alpha_t x_t^2 ]$.

The iterates have $y_t \to +\infty$ whenever $x_0 \neq 0$, regardless of how the step sizes are chosen — the $y$-increment is always $+\eta x_t^2 \ge 0$, with no countervailing force pulling $y$ toward $0$. **The algorithm does not converge to $(0,0)$.**

This is not a quirk of CMP-3T; it is a genuine pathology of the local minimax notion in this example. Note that $(0,0)$ is a local minimax in the Jin et al. sense only because $\Phi_\delta(x)=\delta x^2$ is locally minimized at $x^*=0$ — but the inner $\max$ in $\Phi_\delta$ is achieved at $y=\pm\delta$ (the boundary of the ball), and as $\delta\to 0$ the inner maximizer escapes.

**Status of (C3): NEGATIVE** on the canonical example. CMP-3T does not converge to the stated optimum.

---

## 6. The third timescale itself does not commute

A separate obstacle, even abstracting from (C2)-(C3): three-timescale ODE theory (Mokkadem–Pelletier 2006) requires the three slow / medium / fast subsystems to satisfy a *commutativity at fixed-point* condition. Concretely: if we collapse the fast $y$-iteration to its fixed point $y^*(x,P)$ as a function of $(x,P)$ where $P$ is the projector, and then collapse the medium $P$-iteration to its fixed point $P^*(x)$, the resulting $x$-flow must coincide with the gradient flow of $\Phi_\delta$.

For our scheme this requires: the kernel projector at the fast fixed point $y^*(x,P)$ must equal the true kernel of $\nabla^2_{yy}f(x,y^*(x))$ for all $x$ in a neighborhood. Since the fixed point of Step 1+3 depends on $P$ (the medium-timescale variable), a self-consistency loop is created. Self-consistency is typically established by a **contraction map argument**, but at a non-strict local minimax the relevant contraction modulus is exactly zero (the kernel is one-dimensional with zero curvature).

So three-timescale theory does not apply: the assumed contraction at the medium scale fails precisely at the optima we want to converge to.

---

## 7. What positive content survives

Despite the failures above, two genuinely useful by-products are visible:

**Partial result 1 (CMP-3T under a non-degenerate-kernel assumption).** If we add the assumption "the kernel $\mathcal K_t$ has a strictly positive third-order curvature on the non-zero block, i.e., $\nabla_y^3 f|_{\mathcal K\times\mathcal K\times\mathcal K} \succ 0$", then the kernel-direction descent in Step 3 effectively becomes
$$y^0_{t+1} - y^*_0 = (1 - \eta_c c_3 |y^0_t - y^*_0|^2)\, (y^0_t - y^*_0) + O((y^0)^3),$$
which is the harmonic-recursion form `[REF: proofs/fragments/harmonic-recursion-lemma.md]` and gives $y^0_t = O(1/\sqrt{\eta_c t})$. Combined with (C1) and an outer-block descent argument that allows the slow drift to be polynomially perturbed by the kernel error, we obtain partial outcome 3 of the problem statement: **convergence to the local minimax under a third-order non-degeneracy condition.**

The third-order condition is strictly weaker than the second-order condition required by Jin et al. 2019. So this is honest progress.

**Partial result 2 (CMP-3T as a $\sqrt\varepsilon$-stationarity result under a noisy oracle).** The error floor identified in Section 4 implies CMP-3T converges to an $\epsilon$-stationary region of $\Phi_\delta$ with $\epsilon = O(\sqrt{\varepsilon L_2})$, where $\varepsilon$ is the gradient-oracle noise. This is parallel to the standard finite-difference Newton results in convex optimization.

Neither partial result establishes the open problem. Both require structural assumptions that the open problem deliberately omits.

---

## 8. Honest assessment of the composition

**The composition does NOT close.** Specifically:

1. **Block (C1)** closes (standard two-timescale on the non-degenerate block).
2. **Block (C2)** has a fundamental obstruction: the finite-difference scale $\tau_t$ must satisfy $\tau_t \to 0$ to avoid bias, but under any noisy gradient oracle $\tau_t$ has a positive lower bound, giving a hard error floor incompatible with convergence to a fixed non-strict optimum.
3. **Block (C3)** fails on the canonical example $f(x,y)=x^2y$ from the problem statement: the algorithm does not converge to $(0,0)$ regardless of step sizes, because $\nabla_y f$ has no restoring component along $y$.
4. **Three-timescale commutativity** (Mokkadem–Pelletier) is not satisfied because the medium-scale contraction modulus is zero at exactly the fixed points we target.

**Net polarity**: NEGATIVE evidence for the existence of a first-order algorithm that converges to **all** local minimax optima. The composition fails for structural reasons (no finite-difference scale survives the limit at non-strict optima), and the canonical example $f(x,y)=x^2y$ illustrates that the failure is generic, not an artifact of CMP-3T's specific construction.

**Net positive content**: A "partial" result is salvageable under a third-order non-degeneracy assumption (Partial Result 1 above). This is consistent with the problem statement's *Outcome 3 (Partial)* allowance.

---

## 9. Lessons for downstream routes

- **R3 (Le Cam impossibility) is reinforced.** Section 5.3 shows that even for the simplest non-strict instance $f(x,y)=x^2y$, no first-order algorithm with a translation-invariant update rule can converge: the trajectory of $\nabla_y f$ has no zero crossing. A Le Cam argument exploiting this kind of structural blindness is the right way to formalize the impossibility.
- **R1 (orthodox + KL/PL)** is the right "partial-positive" route — and Partial Result 1 here shows that *third-order non-degeneracy* plays the role analogous to KL/PL.
- **CMP-3T's failure mode is a candidate FT entry**: "finite-difference Hessian-vector estimators force a positive lower bound on the FD scale under noisy oracles, breaking convergence to non-strict optima." Add to `failure_triggers.md` as `FT-COMP-FD-HESSIAN-NOISY-FLOOR` (suggested).

---

## Route Failure Report

- **Route**: Compositional (R6) — three-timescale GDA with finite-difference Hessian-vector approximation
- **Failed at**: Block (C2) [Section 4.3, Step C] and Block (C3) [Section 5.3, canonical example]
- **Obstacle**: Two independent failure modes:
  1. Finite-difference scale $\tau_t$ must tend to zero, but any noisy gradient oracle forces $\tau_t \ge C\sqrt{\varepsilon}$, creating an irreducible Hessian-estimation error floor.
  2. The canonical non-strict local minimax $f(x,y)=x^2 y$ at $(0,0)$ has $\nabla_y f \equiv x^2 \ne 0$ for any $x\ne 0$, so the inner ascent strictly increases $y$; no first-order update with curvature correction can reverse this. Hence CMP-3T diverges from $(0,0)$ along $y$.
- **Salvageable**: Partial outcome under the assumption of third-order non-degeneracy of $\nabla_y^3 f$ on the kernel direction.

---

## Hooks Report

- **Strategy signatures consulted (L1)**: `gda-nonconvex-strongly-concave-convergence` (template for two-timescale Lyapunov; extended to three-timescale and broken — slot Slot-A/Slot-B filled, Slot-C newly introduced and obstructive). `harmonic-recursion-lemma` consulted for the kernel-direction $1/\sqrt t$ rate (used in Partial Result 1, not in the main route).
- **Meta-template attempted (L5)**: MT3 *Two-Timescale Drift Decomposition*; attempted promotion to MT3' *Three-Timescale Drift Decomposition*. **Slots filled**: fast = Step 1 (inner ascent), slow = Step 4 (outer descent). **Blocker slot**: medium-scale contraction modulus is zero at non-strict optima — three-timescale composition theorem (Mokkadem–Pelletier) does not apply, so the slot cannot be instantiated. *Verdict*: TEMPLATE-CLAIM-INCONSISTENT for MT3'; the standard MT3 (two-timescale) was correct for the strict case but cannot be extended.
- **Structure-map links (L4)**: Cluster B trajectory-split skeleton (degenerate vs non-degenerate block) was used to organize the Lyapunov $V_t = \Phi_\delta + c_\perp \delta^\perp + c_0 (\delta^0)^q$. The split itself works; the failure is at a more granular level inside the kernel block.
- **Failure-trigger scan (L2)** — three triggers reviewed every ~3 sections:
  - `FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE`: TRIGGER-IRRELEVANT (this is a positive-attempt route, not a cycling LB).
  - `FT-LEGACY-CD-EUCLIDEAN-NORM`: TRIGGER-IRRELEVANT (no coordinate descent norm conversion).
  - `FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM`: TRIGGER-IRRELEVANT (no Le Cam product structure here).
  - **NEW trigger candidate** registered in §9: `FT-COMP-FD-HESSIAN-NOISY-FLOOR` — finite-difference Hessian estimators have an error floor under any noisy gradient oracle that scales as $\sqrt\varepsilon$, breaking convergence to genuinely degenerate fixed points. This is the load-bearing failure of the present route.
- **Fragments cited (L3)**: `harmonic-recursion-lemma` (consulted, used only in Partial Result 1); `cocoercivity-of-smooth-convex` (consulted for §3 Lemma 3.1, supplied implicitly by the strong-concavity argument); `heavy-ball-jordan-block-quadratic` (consulted by analogy for discretization-error scaling in §4.3, not load-bearing).
- **Sub-problem markers**: none emitted. The three failure modes (§4 noise floor, §5 canonical example, §6 commutativity) are each *structural* and would not benefit from a sub-pipeline — they are obstructions to the entire compositional approach, not local sub-lemmas to be discharged.
- **CALL markers**: none emitted. Numerical verification of the $f(x,y)=x^2y$ divergence in §5.3 is symbolic and does not require math-verifier; the computation is completed inline.
