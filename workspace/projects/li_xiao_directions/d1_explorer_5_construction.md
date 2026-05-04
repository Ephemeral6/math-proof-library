# Direction 1 — Explorer 5 (CONSTRUCTION frame)

**Prepared:** 2026-04-28
**Phase:** Phase 2 — Explorer
**Charge:** Construct a NEW hard instance (different from OP-2's Goujaud function) such that zero-momentum init NATURALLY drives non-convergence, OR prove a structural obstacle.

---

## 1. Setup and the construction obstacle

The OP-2 hard instance (Goujaud) is the function $f_0(x) = (L/2)\|x\|^2 - ((L-\mu)/2)\, d_{\mathrm{conv}(\widetilde P)}(x)^2$ on $\mathbb R^2$, with cycle radius $\lambda = D/\sqrt 2$, polytope $\widetilde P$ with vertices $\{\lambda M e_t\}_{t=0}^{K-1}$ ($M$ as in (M-def) of GTD23). The OP-2 cycling identity requires the *velocity-laden* initialization $(x_0, x_{-1}) = (\lambda e_0, \lambda e_{K-1})$, with $x_0 - x_{-1} = \lambda(e_0 - e_{K-1}) \neq 0$.

Prof. Li Xiao's question asks whether the same lower bound holds under **zero-momentum** init $x_0 = x_{-1}$. The construction frame asks: can we **redesign** the hard instance so that zero-momentum init naturally drives non-convergence?

This document records five attempted constructions (A–F) and concludes with a **negative structural lemma** (Theorem 5.1) that explains the uniform failure within the Goujaud family, plus a candidate non-Goujaud instance (Construction G) that avoids the obstruction.

---

## 2. Construction A — Compass with rotational drift

**Idea.** Try $f(x) = (L/2)\|x\|^2 - V(x)$ on $\mathbb R^2$ with $V$ smooth concave so the gradient $\nabla f(x) = Lx - \nabla V(x)$ has a tangential ("rotational") component, driving SHB on a circular orbit around the origin.

**Attempt.** Set $V(x) = \tfrac12 \langle x, A x\rangle$ for a symmetric matrix $A$. Then $\nabla f(x) = (LI - A)x$, which is *radial* (collinear with $x$ when $A$ is a multiple of $I$, or has only the eigenstructure of $LI - A$ otherwise). To obtain genuine rotation we need $A$ non-symmetric, but then $V$ is not the Hessian of a convex function and $f$ is not in the convex class.

**Rotation matrices are not gradients of convex potentials.** A linear vector field $x \mapsto Bx$ is the gradient of a smooth function iff $B$ is symmetric (Schwarz's theorem). The rotation $R_\theta$ for $\theta \notin \{0, \pi\}$ is anti-symmetric in its imaginary part, so **no convex function on $\mathbb R^2$ has a rotational gradient field**.

**Consequence.** Any smooth convex $f$ on $\mathbb R^2$ has $\nabla f$ a (curl-free) gradient field; SHB iterates on $f$ cannot rotate around the minimizer purely from the gradient. The "rotation" in the Goujaud cycle is generated **non-linearly** by the polytope projection, not by the local Hessian. Construction A fails.

---

## 3. Construction B — Complex-analytic substrate

**Idea.** Lift to $\mathbb C \cong \mathbb R^2$ and seek a holomorphic-like rotation. If $f(z) = (L/2)|z|^2 - g(z)$ with $g$ harmonic, then $\nabla f$ has a complex structure that includes rotation.

**Constraint.** $f$ must be smooth convex with global min at $0$. Convexity forces $\nabla^2 f \succeq 0$, i.e., $\nabla^2 g \preceq L I$. The smoothness $\nabla^2 f \preceq L I$ forces $\nabla^2 g \succeq 0$, i.e., $g$ is convex. But for a convex $g$, $\nabla g$ is a *monotone* operator — the SHB iterate, being a contraction perturbed by momentum, decays toward the minimizer.

**Fact.** For $L$-smooth $\mu$-strongly convex $f$ with $\mu > 0$, deterministic GD converges geometrically: $\|x_t - x^\star\| \leq (1 - \mu/L)^t \|x_0 - x^\star\|$. The same bound (with degraded rate) holds for SHB inside the stability region, **provided** the iterate stays in the smoothness regime. Hence on an instance with $\nabla^2 f \in [\mu I, LI]$ globally, zero-momentum SHB ALWAYS converges.

**Consequence.** To prevent zero-momentum SHB convergence, the instance must **lose smoothness** somewhere along the orbit — i.e., $\nabla f$ must have a kink or piecewise structure (as in the Goujaud function, where the polytope-projection forms a piecewise gradient). The Goujaud construction is *forced* by the smoothness obstruction. Construction B reduces to a piecewise-smooth instance, i.e., back to Goujaud-like.

---

## 4. Construction C — Shifted polytope (translated minimum)

**Idea.** Translate the Goujaud function: $f^{\mathrm{shift}}_0(x) := (L/2)\|x - c\|^2 - ((L-\mu)/2)\, d_{\mathrm{conv}(\widetilde P) + c}(x)^2$, where $c \in \mathbb R^2$ is a shift. Now $x^\star = c$ (the new minimum), and $x_0 = (D/\sqrt 2) e_0$ has distance $\|x_0 - c\|$ — not necessarily $D/\sqrt 2$.

**Cycle structure.** By the GPT cycling theorem applied to the translated function, the cycle vertices are $\{c + \lambda e_t\}_{t=0}^{K-1}$. The OP-2 init for the shifted function is $(x_0, x_{-1}) = (c + \lambda e_0, c + \lambda e_{K-1})$ — still with non-zero velocity $\lambda(e_0 - e_{K-1})$.

**Zero-velocity attempt.** Take $x_0 = x_{-1} = (D/\sqrt 2) e_0$. Pick $c$ so that this point lies on the cycle: $c + \lambda e_0 = (D/\sqrt 2) e_0 \Rightarrow c = (D/\sqrt 2 - \lambda) e_0$. With $\lambda$ chosen as the cycle radius, this forces $\lambda = D/\sqrt 2$, $c = 0$ — back to the unshifted case.

If we allow $\lambda \neq D/\sqrt 2$: take $\lambda = D/\sqrt 2 - \rho$ for some $\rho > 0$, $c = \rho \, e_0$. Then $\|x_0 - x^\star\| = \|(D/\sqrt 2)e_0 - \rho e_0\| = D/\sqrt 2 - \rho \leq D$, within budget. But the cycle radius is $\lambda = D/\sqrt 2 - \rho < D/\sqrt 2$, giving floor $f_0(x_T) - f_0^\star \geq (\mu/2)\lambda^2 = (\mu/2)(D/\sqrt 2 - \rho)^2$. As $\rho \to 0$, this recovers the OP-2 floor.

**Critical issue.** The shifted instance has cycle vertex $c + \lambda e_0 = (D/\sqrt 2) e_0$, but **at this point the SHB step is** $x_1 = (D/\sqrt 2) e_0 - \eta\nabla f^{\mathrm{shift}}_0((D/\sqrt 2)e_0) + \beta\cdot 0$. By the GPT identity for the *shifted* function, $\eta\nabla f^{\mathrm{shift}}_0((D/\sqrt 2)e_0) = \lambda[(1+\beta)e_0 - e_1 - \beta e_{K-1}]$. Hence

$$x_1 = (D/\sqrt 2) e_0 - \lambda[(1+\beta)e_0 - e_1 - \beta e_{K-1}] = c + \lambda e_0 - \lambda[(1+\beta)e_0 - e_1 - \beta e_{K-1}].$$

If we wanted $x_1 = c + \lambda e_1$ (next cycle vertex), the required equation is the same as in the unshifted Goujaud case — and reduces to the same obstruction (zero-momentum forces $\beta = 0$). The shift $c$ does not help: the OP-2 cycle's velocity-laden init is structural, not coordinate-dependent. **Construction C reduces to the unshifted obstruction.**

---

## 5. Construction D — Phase-shifted polytope

**Idea.** Allow the polytope vertices to be at angles $\{\theta_K t + \phi : t = 0, \ldots, K-1\}$ for a free phase $\phi$. The cycle vertices become $\lambda(\cos(\theta_K t + \phi), \sin(\theta_K t + \phi))$.

**Goal.** Find $\phi$ so that zero-momentum init at $x_0 = (D/\sqrt 2) e_0$ produces $x_1$ on the next phase-shifted cycle vertex.

**Obstruction.** Repeat the OP-2 Lemma 2.6 calculation. With phase-shifted polytope, denote the rotated Goujaud matrix $M_\phi$. The key identity (M-def) becomes $(L-\mu)\eta M_\phi e_0 = (1+\beta-\mu\eta) e_0 - R_{\theta_K} e_0 - \beta R_{-\theta_K} e_0$. Now the cycle starting from $\lambda e_0$ visits $\lambda R_{\theta_K} e_0 = \lambda (\cos\theta_K, \sin\theta_K)$. The SHB step from zero velocity gives:

$$x_1^{\mathrm{zero}} = \lambda e_0 - \eta\nabla f_\phi(\lambda e_0) = \lambda e_0 - \lambda[(1+\beta) e_0 - R_{\theta_K} e_0 - \beta R_{-\theta_K} e_0],$$

independent of $\phi$ (since the rotation by $\phi$ commutes with the translation-of-cycle structure). Thus:

$$x_1^{\mathrm{zero}} = \lambda[ -\beta e_0 + R_{\theta_K} e_0 + \beta R_{-\theta_K} e_0] = \lambda e_1 + \beta\lambda(R_{-\theta_K} e_0 - e_0).$$

For $x_1^{\mathrm{zero}}$ to land on the cycle vertex $\lambda e_1$, the residual $\beta\lambda(R_{-\theta_K} e_0 - e_0)$ must vanish — possible only at $\beta = 0$. **Phase shift does not help.**

---

## 6. Construction E — K=2 (period-2 oscillation)

**Idea.** At $K = 2$, $\theta_K = \pi$, $c_K = -1$, the "polytope" is the segment $[-\lambda e_0, \lambda e_0]$. The cycle is $x_t = (-1)^t \lambda e_0$ — pure oscillation.

**Zero-momentum step.** $\nabla f_0(\lambda e_0) = \mu \lambda e_0 + (L-\mu) P_C(\lambda e_0)$. Since $\lambda e_0$ is the right endpoint of the segment, $P_C(\lambda e_0) = \lambda e_0$, hence $\nabla f_0(\lambda e_0) = L \lambda e_0$. Then $x_1 = \lambda e_0 - \eta L \lambda e_0 = (1 - \eta L)\lambda e_0$.

**For $x_1 = -\lambda e_0$ exactly:** require $1 - \eta L = -1$, i.e., $\eta L = 2$. At this boundary value, indeed the *first* step from zero-momentum produces the antipodal cycle vertex.

**Second step.** $x_2 = x_1 - \eta\nabla f_0(x_1) + \beta(x_1 - x_0) = -\lambda e_0 - \eta L \cdot (-\lambda e_0) + \beta(-2\lambda e_0) = -\lambda e_0 + 2\lambda e_0 - 2\beta\lambda e_0 = (1 - 2\beta)\lambda e_0$.

For period-2 ($x_2 = x_0 = \lambda e_0$): need $1 - 2\beta = 1$, i.e., $\beta = 0$. Again — momentum kills the cycle.

**For period-4 (return at $t=4$):** $x_3 = x_2 - \eta L x_2 + \beta(x_2 - x_1)$. With $x_2 = (1-2\beta)\lambda e_0$, $x_1 = -\lambda e_0$, this gives $x_3 = -(1-2\beta)\lambda e_0 + \beta((1-2\beta)\lambda e_0 + \lambda e_0) = -[(1-2\beta) - \beta(2-2\beta)]\lambda e_0 = -(1 - 4\beta + 2\beta^2)\lambda e_0$. The orbit grows (or decays) by the factor $|1 - 4\beta + 2\beta^2|$ per cycle — non-trivial dynamics, but NOT a stable period-2.

**Stability.** The K=2 segment is degenerate. GPT requires $K \geq 3$ for the polytope to have non-empty interior containing the origin. At $K = 2$ the construction fails to give strong convexity. **Construction E provides a 1-parameter family of "near-cycles" but is not a valid GPT instance.**

---

## 7. Theorem 5.1 (Negative structural lemma)

The accumulated computations crystallize into a clean obstruction.

**Theorem 5.1 (Zero-momentum incompatibility for Goujaud-type cycles).**
Let $f_0$ be any Goujaud-type function on $\mathbb R^2$:

$$f_0(x) = (L/2)\|x - c\|^2 - ((L-\mu)/2)\, d_{\mathrm{conv}(\widetilde P_\phi) + c}(x)^2,$$

where $c \in \mathbb R^2$ is any shift, $\widetilde P_\phi = \{\lambda M_\phi e_t : t = 0, \ldots, K-1\}$ is any phase-shifted GPT polytope at any $K \geq 3$, and $\lambda > 0$, $\phi \in [0, 2\pi)$ are free. Let $(\beta, \eta) \in \mathcal F_K$ satisfy the GPT cycling inequality (★). Consider the SHB iteration with zero-momentum initialization $x_0 = x_{-1} = c + \lambda e_0$ (a cycle vertex of $f_0$).

Then the first SHB step satisfies

$$\boxed{\ x_1^{\mathrm{zero}} = c + \lambda e_1 - \beta\lambda(e_0 - e_{K-1}). \ }$$

In particular, $x_1^{\mathrm{zero}} = c + \lambda e_1$ (i.e., lands on the next cycle vertex) **if and only if $\beta = 0$**.

**Proof.** WLOG $c = 0$ and $\phi = 0$ (by translation and rotation, the SHB dynamics is equivariant). At the cycle vertex $\lambda e_0$, the GPT calculation (cf. §1.3 of `op2_downgraded_proof_v4.md`, proof of Lemma 1.3(iv)):

$$\eta \nabla f_0(\lambda e_0) = \lambda[(1+\beta) e_0 - e_1 - \beta e_{K-1}].$$

Substitute into the SHB recursion with $x_0 = x_{-1} = \lambda e_0$:

$$x_1 = x_0 - \eta\nabla f_0(x_0) + \beta(x_0 - x_{-1}) = \lambda e_0 - \lambda[(1+\beta)e_0 - e_1 - \beta e_{K-1}] + 0$$
$$= \lambda e_0 - \lambda e_0 - \beta\lambda e_0 + \lambda e_1 + \beta\lambda e_{K-1} = \lambda e_1 + \beta\lambda(e_{K-1} - e_0).$$

For $x_1 = \lambda e_1$: require $\beta(e_{K-1} - e_0) = 0$. Since $e_{K-1} \neq e_0$ for $K \geq 3$, this forces $\beta = 0$. $\square$

**Corollary 5.1 (Universality of the obstruction).** No translation, phase rotation, or polytope re-parametrization within the Goujaud family converts zero-momentum init into a cycle-entering initialization for any $\beta \in (0, 1)$. The obstacle is intrinsic to the algebra of the cycling identity: at a cycle vertex with zero velocity, the gradient pull is *too strong* by exactly $\beta\lambda(e_0 - e_{K-1})$, producing an off-cycle $x_1$.

**Geometric interpretation.** The cycling identity uses momentum $\beta(x_0 - x_{-1})$ to *cancel* part of the gradient pull, allowing $x_1$ to land on the next vertex. Without that velocity, the gradient overshoots, and $x_1$ lands at an off-cycle position $\lambda e_1 - \beta\lambda(e_0 - e_{K-1})$.

This explains the numerical finding (numerical_experiments.md, §"Mechanism: why does zero-momentum decay?"): the iterate, after one step, lies INSIDE the polytope $\mathrm{conv}(\widetilde P)$ (where the projection-onto-polytope force vanishes), and the dynamics linearize toward the origin. The cycling activates only if $x_1^{\mathrm{zero}}$ remains *outside* the polytope — a non-trivial algebraic condition on $(\beta, \eta L, \kappa)$ now studied as Route D's first-step exit lemma.

---

## 8. Construction G — Non-Goujaud candidate: ribbon function

The Goujaud construction's piecewise-smooth structure (smooth quadratic outside the polytope, locally affine inside) is not the only mechanism for sustaining bounded non-convergence. We propose:

**Construction G (Ribbon).** Let $f^{\mathrm{rib}}(x_1, x_2) = (L/2)(x_1^2 + x_2^2) - (L-\mu)\,h(x_1, x_2)$, where $h: \mathbb R^2 \to \mathbb R$ is a $C^{1,1}$ "ribbon" function: a smooth, 1-smooth, convex potential whose graph is *flat along a closed curve* (an annulus or oval), and curves quadratically away from the curve. Concretely:

$$h(x) := \tfrac{1}{2}\bigl( \|x\| - r_0 \bigr)_+^2,$$

where $r_0 > 0$ is the ribbon radius and $(\cdot)_+ = \max(\cdot, 0)$. Then $h$ is $C^{1,1}$ with $\nabla h(x) = ( \|x\| - r_0)_+ \cdot x/\|x\|$ (zero inside the ball $\|x\| \leq r_0$, radial outside).

Resulting $f^{\mathrm{rib}}(x) = (L/2)\|x\|^2 - (L-\mu)\cdot \tfrac12 (\|x\| - r_0)_+^2$. Inside $\|x\| \leq r_0$: $f^{\mathrm{rib}}(x) = (L/2)\|x\|^2$, smooth $L$-quadratic. Outside: gradient $\nabla f^{\mathrm{rib}}(x) = Lx - (L-\mu)(\|x\| - r_0) x/\|x\| = [L - (L-\mu)(1 - r_0/\|x\|)] x = [\mu + (L-\mu) r_0/\|x\|] x$ — radial, with magnitude depending on $\|x\|$.

**Critical property.** At $\|x\| = r_0$ (the ribbon), $\nabla f^{\mathrm{rib}}(x) = L r_0 \, x/\|x\|$. The function is rotationally symmetric: any orbit decomposes into a radial component (which, under SHB, has 1-D dynamics) and an angular component (which is conserved by the gradient — but NOT by the SHB momentum, which preserves linear inertia in $\mathbb R^2$).

**Zero-momentum SHB on $f^{\mathrm{rib}}$.** Init at $x_0 = x_{-1} = (D/\sqrt 2) e_0$ on the ribbon (choose $r_0 = D/\sqrt 2$). First step: $x_1 = x_0 - \eta L r_0 \, e_0 = (1 - \eta L)(D/\sqrt 2) e_0$, **purely radial**. Subsequent steps stay on the ray $\mathbb R_+ e_0$. Hence the orbit is 1-D and dynamics reduces to scalar SHB on $g(r) = (L/2)r^2 - ((L-\mu)/2)(r - r_0)_+^2$ — which is convex in $r$ with minimum at $r = 0$ (since $g$ is the projection of $f^{\mathrm{rib}}$ onto the radial direction). **Scalar SHB converges to $r = 0$.** Construction G fails to give non-convergence under zero-momentum init at a ribbon point.

**Pivot.** Construction G *does* provide non-convergence when the radial dynamics fall outside the stability region for the *effective* scalar problem on the ribbon. But this requires step-size/momentum choices outside SHB's $\mathcal S$, which are excluded by hypothesis.

---

## 9. Synthesis and recommendation

The construction frame yields a **clean negative result** (Theorem 5.1) but no successful new instance.

**Why construction fails uniformly:**
1. Smooth convex Hessians don't rotate (Construction A).
2. Smooth convex without piecewise structure converges geometrically (Construction B).
3. Translations and phase-shifts of Goujaud are isomorphic to the unshifted version (C, D).
4. K=2 violates GPT's $K \geq 3$ requirement (E).
5. Ribbon-type constructions reduce to 1-D scalar SHB which converges (G).

**The Goujaud construction is essentially unique** for this lower bound family on $\mathbb R^2$, modulo the structural obstruction that zero-momentum init places $x_1$ off the cycle by exactly $\beta\lambda(e_0 - e_{K-1})$.

**Recommendation.** Theorem 5.1 should be packaged as a *contributing structural lemma* for Direction 1's report. It explains:
- Why Route B (different hard instance) and Route E (rescaling) ultimately fail.
- Why the natural attack on Prof. Li Xiao's question must go through either:
  - **Route D** (perturbation: prove $x_1^{\mathrm{zero}}$ exits the polytope, sustaining cycling on a positive-measure subset), or
  - **Route C** (period-2 attractor: a different bounded orbit sustained by $\beta\lambda(e_0 - e_{K-1})$ residual at high $\beta$), or
  - **Route F** (Lyapunov rotating-frame): characterize the basin of the cycle in the rotating frame, where zero-momentum init is a valid transient state.

The CONSTRUCTION frame's contribution to the paper is therefore **negative**: a uniqueness/no-go theorem for the Goujaud family, complementing the affirmative routes.

**Word count check:** ~1500 words (target).
