# Direction 1 — Scout Routes: Zero-Momentum SHB Lower Bound

**Prepared:** 2026-04-28  
**Phase:** Scout (Phase 1 of 5)  
**Problem:** Prove $\mathcal F^{\mathrm{zero}} \subset \mathcal F_{K=3}$ is a positive-measure subset on which SHB with zero-momentum init $(x_0 = x_{-1} = (D/\sqrt 2)e_0)$ satisfies $\|x_T\| \geq cD$ for all $T \geq 1$.

---

## Background: What makes the OP-2 proof tick

The OP-2 proof (v4) achieves the lower bound through a chain:

1. **Goujaud cycling identity.** On $f_0(x) = (L/2)\|x\|^2 - (L-\mu)/2 \cdot d_{\mathrm{conv}(\tilde P)}(x)^2$, the OP-2 initialization $(x_0, x_{-1}) = ((D/\sqrt 2)e_0, (D/\sqrt 2)e_{K-1})$ yields $x_t = (D/\sqrt 2)e_{t \bmod K}$ for **all** $t \geq 0$ — an exact algebraic identity, not an approximation.

2. **Strong-convexity floor.** $\|x_t\| = D/\sqrt 2$ implies $f_0(x_T) \geq (\mu/2)(D/\sqrt 2)^2 = \mu D^2/4$.

3. **The gap between OP-2 and zero-momentum init.** The cycling identity in Step 1 requires $(x_{-1}, x_0) = (\lambda e_{-1}, \lambda e_0)$ with $\lambda = D/\sqrt 2$ — i.e., a non-zero "kick" $x_0 - x_{-1} = \lambda(e_0 - e_{K-1}) \neq 0$. Under zero-momentum init $x_0 = x_{-1} = \lambda e_0$, the first step produces $x_1 \neq \lambda e_1$ in general, because the inductive step in Lemma 2.6 requires both $x_{t-1} = \lambda e_{t-1}$ AND $x_t = \lambda e_t$ to work. The cycling orbit is no longer the trajectory.

4. **Numerical finding.** At $(\beta, \eta L) \in \{0.7, 0.8\} \times [\eta_{\min}, 2(1+\beta)]$, specifically 8 of 100 grid points, the zero-momentum orbit nevertheless converges to the K=3 cycle (or a bounded non-zero attractor), numerically supporting a non-empty $\mathcal F^{\mathrm{zero}}$.

The core mathematical question: **on what subset of parameters does $\|x_t\|$ remain bounded away from 0, and why?**

---

## Route A — Direct Algebraic: Amplitude Analysis via Vieta

### Precise claim

**Claim A.** Fix $K = 3$, $\lambda = D/\sqrt 2$. Consider the **linearized** SHB recursion obtained by replacing the Goujaud gradient at cycle points with the exact nonlinear gradient (outside the polytope) but linearizing the polytope-projection operator around the cycle. In the decoupled scalar SHB recursion along each frequency mode $\lambda_j \in \{\mu, L\}$, the zero-momentum initial condition $x_0 = x_{-1} = \lambda e_0$ produces amplitudes

$$A_\mu^{\mathrm{zero}} = \frac{\lambda e_0 (1 - r_{2,\mu})}{r_{1,\mu} - r_{2,\mu}}, \qquad B_\mu^{\mathrm{zero}} = \frac{\lambda e_0 (r_{1,\mu} - 1)}{r_{1,\mu} - r_{2,\mu}},$$

where $r_{1,\mu}, r_{2,\mu}$ are the two roots of the characteristic polynomial $z^2 - (1+\beta - \eta\mu)z + \beta = 0$.

**Sub-claim A1.** In the under-damped regime $\Delta_\mu := (1+\beta-\eta\mu)^2 - 4\beta < 0$, we have $r_{1,\mu} = \sqrt\beta e^{i\theta_\mu}$, $r_{2,\mu} = \sqrt\beta e^{-i\theta_\mu}$, and

$$|A_\mu^{\mathrm{zero}}|^2 = \frac{\lambda^2 \|e_0\|^2 |1 - \sqrt\beta e^{-i\theta_\mu}|^2}{4\beta \sin^2\theta_\mu} = \frac{\lambda^2(1 - 2\sqrt\beta\cos\theta_\mu + \beta)}{4\beta\sin^2\theta_\mu}.$$

**Sub-claim A2 (key).** On the domain where the iterate exits the polytope (i.e., the nonlinear cycling regime activates), $|A_\mu^{\mathrm{zero}}| > 0$ generically (it vanishes only on the measure-zero locus $\cos\theta_\mu = (1+\beta)/(2\sqrt\beta)$, which requires $\beta = 1$, outside the stability region). Hence the slow-mode amplitude is non-zero, and the iterate does not decay to zero along the slow-mode direction.

**The connection to cycling.** When $|A_\mu^{\mathrm{zero}}|$ is large and $|r_\mu| = \sqrt\beta$ (under-damped, modulus exactly $\sqrt\beta$), the iterate's slow-mode component oscillates with amplitude $\sim |A_\mu^{\mathrm{zero}}| \cdot \sqrt\beta^T$, which decays — but the *nonlinear* polytope projection sustains the orbit if the iterate exits the polytope. The route argues that when $\theta_\mu \approx \theta_K = 2\pi/K$, the nonlinear forcing is "in phase" with the mode oscillation, sustaining the cycle.

### Critical lemmas

**Lemma A1 (Amplitude formula).** Derive $A_\mu^{\mathrm{zero}}, B_\mu^{\mathrm{zero}}$ by substituting $x_0 = x_{-1} = v$ into the general solution $x_t = A r_1^t + B r_2^t$ and solving the $2\times 2$ Vandermonde system. Exact closed form via Vieta's formulas.

**Lemma A2 (Non-vanishing).** Show $|A_\mu^{\mathrm{zero}}| = 0$ iff $(1 - r_{2,\mu}) = 0$ iff $r_{2,\mu} = 1$ iff $1 - (1+\beta-\eta\mu) + \beta = 0$ iff $\eta\mu = 0$ iff $\mu = 0$. Since $\mu > 0$ by hypothesis, $A_\mu^{\mathrm{zero}} \neq 0$ everywhere in $\mathcal F$.

**Lemma A3 (Phase-locking condition).** Identify the locus $\Sigma \subset \mathcal F$ where $\theta_\mu \in (\theta_K/2, \theta_K)$ (mod $2\pi$), i.e., the slow-mode angle is "near" the cycle angle. Show $\Sigma$ is open and has positive measure.

**Lemma A4 (Nonlinear re-entry).** Show that when the linear iterate would have $\|x_t\|$ near $\lambda = D/\sqrt 2$ (due to non-zero amplitude) and the polytope boundary is reached, the nonlinear projection force "kicks" the iterate toward the next cycle vertex, sustaining the orbit. This is the key nonlinear step — the most difficult lemma.

**Lemma A5 (Positive measure of $\mathcal F^{\mathrm{zero}}$).** Combining Lemmas A3 and A4, $\mathcal F^{\mathrm{zero}} \supset \Sigma \cap \{\text{phase-locking holds}\}$, which is open and non-empty.

### Difficulty: **Research**

The amplitude non-vanishing (Lemma A2) is clean and doable. The hard step is Lemma A4: the nonlinear re-entry argument requires showing that the iterate, after one "linear decay" step, still hits the polytope boundary with the right angle. This involves a detailed tracking of $x_1$ under zero-momentum init and showing $x_1$ exits the polytope. The obstacle: with zero velocity, $x_1 = x_0 - \eta \nabla f_0(x_0) = \lambda e_0 - \eta[\mu \lambda e_0 + (L-\mu) P_{\tilde C}(\lambda e_0)]$. Since $\lambda e_0$ IS on the cycle (it equals $(D/\sqrt 2)e_0$, a cycle vertex), $P_{\tilde C}(\lambda e_0) = \lambda M e_0$ by the transplanted projection identity. So $x_1 = \lambda[1 - \eta\mu]e_0 - \eta(L-\mu)\lambda M e_0$. This is NOT $\lambda e_1$ in general. Whether $x_1$ exits the polytope and whether the subsequent nonlinear forcing is cycle-sustaining requires case analysis on $(\beta, \eta L)$.

### Likely failure mode

The nonlinear re-entry (Lemma A4) may fail: for most $(\beta, \eta L)$, $x_1$ lands INSIDE the polytope, where the dynamics linearize around the origin and decay. The route would then only show that $A_\mu^{\mathrm{zero}} \neq 0$ (which is vacuous without the nonlinear sustaining), and cannot conclude $\|x_T\| \geq cD$.

### Predicted constant

If successful, gives $\mathcal F^{\mathrm{zero}} = \{(\beta, \eta L) : \Delta_\mu < 0 \text{ and } x_1 \notin \mathrm{int}(\mathrm{conv}(\tilde P))\}$, a subset of $\mathcal F_{K=3}$ of positive but smaller measure. The cycling constant $c$ would be $\mu D^2/4$ as in OP-2 (same strong-convexity floor), giving the same asymptotic LB $\Omega(\kappa LD^2/T)$.

---

## Route B — Different Hard Instance: Shifted Polytope

### Precise claim

**Claim B.** There exists a modified Goujaud-type function $\tilde f_0$ on $\mathbb R^2$, obtained by shifting the polytope $\tilde P$ by a vector $v \in \mathbb R^2$ (so $\tilde P_v = \tilde P + v$ and $\mathrm{conv}(\tilde P_v) = \mathrm{conv}(\tilde P) + v$), such that:

(i) $\tilde f_0$ remains $L$-smooth and convex (possibly no longer $\mu$-strongly convex, but with a positive bias against the origin).

(ii) The zero-momentum initialization $x_0 = x_{-1} = (D/\sqrt 2)e_0$ coincides with a cycle vertex of the shifted function, AND the initialization has zero velocity, which is consistent with the shifted cycle's natural starting conditions.

(iii) SHB with the given $(\beta, \eta)$ and initialization $(x_0, x_{-1}) = ((D/\sqrt 2)e_0, (D/\sqrt 2)e_0)$ satisfies $\|x_t - x^\star\| \geq cD$ for all $t \geq 1$, for a constant $c > 0$ that is uniform over a positive-measure set of parameters.

### Strategy

The K=3 cycling identity in OP-2 requires $(x_{-1}, x_0) = (e_{-1 \bmod K}, e_0) = (e_2, e_0)$ — the "velocity" between successive vertices. Shifting the polytope or choosing a different $K$ can make zero-velocity init coincide with the cycle's natural entry point.

**Sub-approach B1: Use K=2.** The K=2 "cycle" (oscillation between two points) would require $x_0 = e_0$, $x_{-1} = e_1$ but with the same position ($K=2$ means $e_0 = -e_1$, so the "cycle" is $\pm e_0$ and natural zero-velocity init IS at one of the two points if one chooses $x_0 = x_{-1} = e_0$ — but K=2 is excluded ($K \geq 3$ in GTD23). Partial rescue: use the K=2 analog informally.

**Sub-approach B2: Period-doubling.** Instead of the K=3 cycle, look for a K=6 cycle of the SHB dynamics on the K=3 function, with zero-momentum init naturally landing on the K=6 orbit. Cycle vertices of K=6 under SHB on K=3 function are not the Goujaud vertices $e_t$ but a related 6-point orbit.

**Sub-approach B3: Translate initial point.** Keep the K=3 Goujaud function $f_0$ unchanged, but replace the initial point: set $x_0^{\mathrm{new}} = (D/\sqrt 2)e_0$ and look for $(x_{-1}^{\mathrm{new}}) = x_0^{\mathrm{new}}$ (zero velocity). But modify the function's polytope center so that $x_0^{\mathrm{new}}$ IS already at the correct position relative to the cycle. Specifically: translate $\tilde P$ so its first vertex is at $(D/\sqrt 2) e_0$, and the "previous vertex" is also $(D/\sqrt 2) e_0$ (not $e_{K-1}$ — i.e., use a degenerate K=1 fixed point).

### Critical lemmas

**Lemma B1.** For the modified function $\tilde f_0^{(v)}$ with shifted polytope center $v$, derive the analogue of the GTD-cyc inequality (★) that guarantees the shifted cycle is a valid SHB orbit.

**Lemma B2.** Show that for some $(v, K, \beta, \eta L)$ with $K \neq 3$, the zero-momentum initialization $(x_0, x_{-1}) = (\lambda e_0, \lambda e_0)$ lies on the cycle of $\tilde f_0^{(v)}$. This requires finding $v$ such that the two consecutive cycle vertices $\lambda e_0, \lambda e_0$ are compatible with the SHB map — i.e., there is a fixed point of the 1-step SHB map with velocity zero.

**Lemma B3 (Fixed-point existence).** A zero-velocity fixed point of SHB requires $x^\star_{\mathrm{cycle}} = x^\star_{\mathrm{cycle}} - \eta \nabla \tilde f_0(x^\star_{\mathrm{cycle}})$, i.e., $\nabla \tilde f_0(x^\star_{\mathrm{cycle}}) = 0$ — i.e., a fixed point of SHB with zero velocity is a stationary point of $\tilde f_0$. But $x^\star$ is the global minimizer at the origin (for the Goujaud function), not at $(D/\sqrt 2)e_0$. Hence zero-velocity cycling is impossible at non-stationary points for the standard Goujaud function.

**Lemma B4 (Period-2 alternative).** However, a period-2 orbit with $(x_0, x_1) = (\lambda e_0, \lambda e_1)$ and $x_2 = \lambda e_0$ (for K=2, which maps back to the start) gives a non-trivial orbit. But $e_0$ and $e_1$ for K=2 are antipodal, so zero-velocity init at $e_0$ cannot produce $x_1 = e_1 = -e_0$ without a large gradient push.

**Lemma B5.** Construct an explicit K=4 or K=6 instance where the zero-momentum init $(x_0, x_{-1}) = (\lambda e_0, \lambda e_0)$ is the start of a 2-step transient into a cycling orbit: after one "slip" step, $x_1$ lands near $\lambda e_1$, and from $x_1 \approx \lambda e_1$, $x_0 = \lambda e_0$, the standard cycle induction applies.

### Difficulty: **Advanced to Research**

Lemma B3 shows that exact zero-velocity cycling at non-stationary points is impossible for standard Goujaud. The route thus reduces to showing that **near** zero-velocity init leads to cycling — equivalent to Route D (perturbation). The shifted-polytope variant (B3) breaks strong convexity. This route has limited independent content beyond Route D unless a genuinely new function class is constructed.

**Exception:** if one finds a different smooth convex function (not of Goujaud type) where the zero-momentum init IS a natural fixed point of the cycling mechanism, this would be a clean separate result. That is a research-level construction problem.

### Likely failure mode

Lemma B3 blocks exact zero-velocity cycling at non-stationary points for ALL Goujaud-type functions. The route degenerates to the perturbation argument (Route D) or requires a fundamentally different function class. If the function class changes, the resulting LB is on a different function, not the standard smooth convex class where OP-2 holds — weakening the result.

### Predicted constant

If the K=4 or K=6 variant works: $c \approx \kappa'/4$ for a smaller $\kappa'$ (since the cycling inequality for K=4 requires $\beta > 0.414$, tighter than K=3's $\beta > 0.303$). Positive measure of parameters at $\beta \geq 0.414$.

---

## Route C — Period-2 Attractor

### Precise claim

**Claim C.** For $(\beta, \eta L) \in \mathcal F^{\mathrm{per2}} \subset \mathcal F_{K=3}$, there exists a **period-2 limit cycle** of the deterministic SHB dynamics on $f_0$ (with zero-momentum init) — i.e., a pair $(p, q)$ with $p \neq q$ such that $x_{2k} \to p$ and $x_{2k+1} \to q$ as $k \to \infty$, with $\|p\|, \|q\| \geq c D$ for a universal constant $c > 0$. Moreover, the basin of attraction of $(p, q)$ contains the diagonal $\{(x_0, x_{-1}) : x_0 = x_{-1} = (D/\sqrt 2) e_0\}$ on a positive-measure set $\mathcal F^{\mathrm{per2}}$ of parameters.

This is directly motivated by the numerical finding: at $\beta \in \{0.9, 0.95\}$, 19/100 grid points show a "bounded non-cycling attractor" with $\|x_t\| \in [0.86, 1.21] \gg D/\sqrt 2 \approx 0.707$. The attractor norm exceeding $D/\sqrt 2$ suggests a different orbit geometry.

### Strategy

The SHB dynamics on $f_0$ define a 2-step map $\Phi : (x_t, x_{t-1}) \mapsto (x_{t+2}, x_{t+1})$ on $\mathbb R^2 \times \mathbb R^2 \cong \mathbb R^4$. A period-2 orbit corresponds to a fixed point of $\Phi$. The fixed-point equation is:

$$x_2 = x_0: \quad \Phi(x_0, x_{-1}) = (x_2, x_1), \quad x_2 = x_0 \Rightarrow \Phi^2(x_0, x_{-1}) = (x_0, x_{-1}).$$

For the zero-momentum init on the diagonal $x_0 = x_{-1} = v$, the period-2 fixed-point equation becomes:

$$v = v - \eta \nabla f_0(v) + \beta(v - v) - \eta\nabla f_0(x_1) + \beta(x_1 - v),$$

where $x_1 = v - \eta \nabla f_0(v)$ (since velocity is zero initially). This simplifies to a nonlinear system in $v$ and $x_1$.

### Critical lemmas

**Lemma C1 (2-step map well-posedness).** The map $\Phi: (u, v) \mapsto (u', v')$ defined by one SHB step on $f_0$ is a $C^1$ diffeomorphism from $\mathbb R^4 \to \mathbb R^4$ (since $\nabla f_0$ is Lipschitz and the update is affine in $(u, v)$).

**Lemma C2 (Existence of period-2 fixed point by contraction).** Show that $\Phi^2$ is a contraction on a suitable annular region $A = \{(u,v) : \|u\|, \|v\| \in [cD, CD]\}$ for some $0 < c < C$, at high $\beta$ and $\eta L$ near $2(1+\beta)$. The fixed point theorem gives existence of $(p, q)$ with $\|p\|, \|q\| \geq cD$.

**Lemma C3 (Basin of attraction contains the diagonal).** Show that the zero-momentum initial state $(v, v)$ with $v = (D/\sqrt 2)e_0$ lies in the basin of attraction of the period-2 attractor, i.e., $\Phi^{2k}(v, v) \to (p, p)$ or oscillates between $(p, q)$, with $\|p\|, \|q\| \geq cD$.

**Lemma C4 (Parameter measure).** Show that the region $\mathcal F^{\mathrm{per2}}$ where the period-2 attractor exists and is attractive is open (by implicit function theorem on the period-2 fixed point) and has positive measure.

**Lemma C5 (LB transfer).** The strong-convexity floor: if $\|x_T\| \geq cD$ for all $T$, then $f_0(x_T) - f_0^\star \geq (\mu/2)(cD)^2 = c^2\mu D^2/2$.

### Difficulty: **Research**

The existence of a period-2 attractor is strongly supported numerically (the "bounded non-cycling attractor" at $\beta \in \{0.9, 0.95\}$) but proving it analytically requires:

1. An explicit construction of the period-2 fixed point — the nonlinear equation $\Phi^2(p, q) = (p, q)$ on the Goujaud function has no closed-form solution (unlike the exact K=3 cycle in OP-2, which exploits the special algebraic structure of the cycling inequality).
2. An eigenvalue/Jacobian analysis of $D\Phi^2$ at the fixed point to prove attractiveness.
3. A basin-of-attraction argument for the diagonal (which is not near the fixed point, so this requires a global trapping argument, not just local linearization).

The key difficulty is that the Goujaud function's projection-onto-polytope structure makes the gradient piecewise, and the 2-step map $\Phi^2$ is piecewise smooth. The analysis splits into several cases depending on whether $x_t$ is inside or outside the polytope at each step.

### Likely failure mode

The period-2 attractor, while numerically clear, may be analytically intractable: the fixed-point equation $\Phi^2(p,q) = (p,q)$ on the Goujaud piecewise-smooth function has no explicit solution, and proving the basin condition for the diagonal is a global argument. The contraction in Lemma C2 may not hold on the full annular region, only near the fixed point (local contracion), and getting the diagonal into the basin requires additional geometric work.

An additional risk: the "bounded non-cycling attractor" at $\beta = 0.9, 0.95$ might not be period-2 but rather a quasi-periodic orbit (irrational rotation number) or a more complex attractor. If so, the fixed-point approach fails and one needs a different argument (e.g., topological index theory or ergodic arguments).

### Predicted constant

The attractor norm $\|p\| \approx 0.86$–$1.21 \cdot (D/\sqrt 2) \approx 0.61$–$0.86 \cdot D$, giving strong-convexity floor $\geq (\mu/2)(0.61D)^2 \approx 0.186 \mu D^2$. This is **larger** than the OP-2 constant $\mu D^2/4 = 0.25\mu D^2$ by a factor $\sim 0.74$, so the constant would be slightly worse but in the same ballpark. Parameter region: $\beta \in [0.85, 1)$, $\eta L$ near $2(1+\beta)$ — roughly 15% of $\mathcal F_{K=3}$ by area.

---

## Route D — ε-Perturbation of Zero Velocity

### Precise claim

**Claim D.** For every $(\beta, \eta L) \in \mathcal F_{K=3}$ (the full K=3 cycling region), there exists $\delta_0 = \delta_0(\beta, \eta L) > 0$ such that: if $\|x_0 - x_{-1}\| \leq \delta_0$, then the SHB iterate on $f_0$ with any initialization satisfying $x_0 = (D/\sqrt 2)e_0$ and $\|x_0 - x_{-1}\| \leq \delta_0$ satisfies $\|x_t\| \geq c(\beta, \eta L) \cdot D$ for all $t \geq 1$.

**Corollary D.** Taking $\delta \to 0$: the set $\mathcal F^{\mathrm{zero}}$ of parameters where zero-momentum init ($x_0 = x_{-1}$) leads to a bounded orbit is the $\delta \to 0$ limit of the $\delta$-perturbation cycling region, which is **not necessarily all of $\mathcal F_{K=3}$**.

The route identifies the precise $\delta_0$-threshold structure: for $\delta > 0$, the orbit is cycling if and only if $x_1 = x_0 - \eta\nabla f_0(x_0) + \beta(x_0 - x_{-1})$ exits the polytope (with the "kick" term $\beta(x_0 - x_{-1}) = \beta\delta v$ for some unit vector $v$). The kick size is $\beta \delta$, and the tolerance for exiting the polytope at $x_1$ is controlled by the distance from $x_0$ to the polytope boundary.

### Critical lemmas

**Lemma D1 (First-step formula).** For init $(x_0, x_{-1}) = (\lambda e_0, \lambda e_0 - \delta v)$ (small velocity $\delta v$), compute:

$$x_1 = \lambda e_0 - \eta\nabla f_0(\lambda e_0) + \beta \delta v.$$

Now $\nabla f_0(\lambda e_0) = \mu \lambda e_0 + (L-\mu)\lambda M e_0$ (using the transplanted projection identity, valid since $\lambda e_0$ is a cycle vertex). The OP-2 calculation gives $\eta \nabla f_0(\lambda e_0) = \lambda[(1+\beta)e_0 - e_1 - \beta e_{-1}]$ (from Lemma 2.6). Hence:

$$x_1 = \lambda e_0 - \lambda[(1+\beta)e_0 - e_1 - \beta e_{-1}] + \beta\delta v = \lambda e_1 + \beta\lambda(e_{-1} - e_0 + \lambda^{-1}\delta v \cdot 1) - \lambda\beta e_{-1}$$

Wait — redo cleanly. From the OP-2 Lemma 2.6 Step 3: $\eta\nabla f_0(\lambda e_0) = \lambda[(1+\beta)e_0 - e_1 - \beta e_{-1 \bmod 3}]$. Then:

$$x_1 = \lambda e_0 - \lambda[(1+\beta)e_0 - e_1 - \beta e_2] + \beta\delta v = \lambda e_1 - \lambda\beta e_0 + \lambda\beta e_2 + \lambda\beta e_0 + \beta\delta v$$

Hmm — let me be more careful:
$$x_1 = x_0 - \eta\nabla f_0(x_0) + \beta(x_0 - x_{-1}) = \lambda e_0 - \lambda[(1+\beta)e_0 - e_1 - \beta e_2] + \beta\delta v$$
$$= \lambda e_0 - \lambda(1+\beta)e_0 + \lambda e_1 + \lambda\beta e_2 + \beta\delta v$$
$$= -\lambda\beta e_0 + \lambda e_1 + \lambda\beta e_2 + \beta\delta v.$$

For OP-2 init: $\beta\delta v = \beta(x_0 - x_{-1}) = \beta\lambda(e_0 - e_2)$. Then:
$$x_1^{\mathrm{OP2}} = -\lambda\beta e_0 + \lambda e_1 + \lambda\beta e_2 + \beta\lambda(e_0 - e_2) = \lambda e_1. \checkmark$$

For zero-momentum init: $\delta v = 0$, so:
$$x_1^{\mathrm{zero}} = -\lambda\beta e_0 + \lambda e_1 + \lambda\beta e_2.$$

This is a convex combination (if $\beta \in (0,1)$) of $e_1$ and $-\beta e_0 + \beta e_2 = \beta(e_2 - e_0)$. Explicitly for K=3: $e_0 = (1,0)$, $e_1 = (-1/2, \sqrt 3/2)$, $e_2 = (-1/2, -\sqrt 3/2)$. Then $e_2 - e_0 = (-3/2, -\sqrt 3/2)$, and $x_1^{\mathrm{zero}} = \lambda[(-1/2 - \beta, \sqrt 3/2 - \beta\sqrt 3/2)] = \lambda[(-1/2-\beta, (1-\beta)\sqrt 3/2)]$.

**Lemma D2 (First-step landing analysis).** Compute whether $x_1^{\mathrm{zero}} = \lambda[(-1/2-\beta, (1-\beta)\sqrt 3/2)]$ lies inside or outside $\mathrm{conv}(\tilde P)$. This is a function of $\beta$, $\eta L$, $\kappa$ only (through $\lambda$ and $M$).

**Lemma D3 (Polytope exit threshold).** Show that $x_1^{\mathrm{zero}}$ exits $\mathrm{conv}(\tilde P)$ if and only if a certain algebraic inequality holds on $(\beta, \eta L, \kappa)$. This gives the characterization of $\mathcal F^{\mathrm{zero}} \cap \{K=3\}$ directly — it is the set where $x_1^{\mathrm{zero}} \notin \mathrm{conv}(\tilde P)$.

**Lemma D4 (Subsequent cycling).** If $x_1^{\mathrm{zero}} \notin \mathrm{int}(\mathrm{conv}(\tilde P))$, the nonlinear projection force activates. Show inductively that once $x_1$ exits, the subsequent orbit $(x_1, x_0)$ satisfies the cycle induction — i.e., using $(x_0, x_1)$ as the new initial condition (with non-zero velocity $x_1 - x_0$), the orbit cycles.

**Lemma D5 (δ-threshold).** For $\|\delta v\|$ small (say $\delta < \delta_0$), the perturbed first step $x_1^\delta = x_1^{\mathrm{zero}} + \beta\delta v$ also exits the polytope (by continuity and the exit margin from Lemma D3). Hence $\delta_0$ = the margin by which $x_1^{\mathrm{zero}}$ clears the polytope boundary.

### Difficulty: **Advanced (doable)**

Lemma D1 is a clean explicit computation, done above. Lemma D2 requires computing whether a specific vector lies inside the GPT polytope $\mathrm{conv}(\tilde P)$ — this is an algebraic condition (support function inequality) that can be written explicitly in terms of $(\beta, \kappa)$ for K=3. Lemma D3 converts this to a region in parameter space. Lemma D4 is the key inductive step, which is the same as the OP-2 Lemma 2.6 induction but with a different starting condition — it works as long as $(x_0, x_1)$ satisfy the "shifted" cycling condition. This is not automatic but is a clean induction once $x_1 \notin \mathrm{int}(\mathrm{conv}(\tilde P))$.

The main challenge is Lemma D4: after the first non-cycling step, the pair $(x_0, x_1)$ does NOT match the OP-2 cycle vertices $(\lambda e_{-1}, \lambda e_0)$ — instead $x_1 = \lambda(-1/2-\beta, (1-\beta)\sqrt3/2) \neq \lambda e_1$. So the induction does not directly continue. This is the "basin" question: does the orbit from $(x_0, x_1)$ with this specific $x_1$ eventually enter the cycling basin?

### Likely failure mode

Lemma D4 fails if $x_1^{\mathrm{zero}}$ exits the polytope but does NOT land in the "right direction" toward $e_1$. Specifically, $x_1^{\mathrm{zero}} = \lambda(-1/2-\beta, (1-\beta)\sqrt3/2)$, which for $\beta \in (0,1)$ is in the second quadrant, with $x$-component $< -1/2$ and $y$-component $\in (0, \sqrt3/2)$. The cycle vertex $e_1 = (-1/2, \sqrt3/2)$ is in the same quadrant. The question is whether $x_1^{\mathrm{zero}}$ is close enough to $e_1$ (in the sense that the projection of $x_1^{\mathrm{zero}}$ onto the polytope boundary is near $Me_1$) to sustain cycling. This depends sensitively on $\beta$.

### Predicted constant and measure

If Lemma D2 gives polytope exit for $\beta \geq \beta_{\mathrm{exit}}$ (some threshold to be computed explicitly), then $\mathcal F^{\mathrm{zero}} = \mathcal F_{K=3} \cap \{\beta \geq \beta_{\mathrm{exit}}\}$. Empirically, $\beta_{\mathrm{exit}} \approx 0.7$. The 2-D measure of this region is positive (the $\beta$ strip $[0.7, 1) \times [\gamma_3(\beta)/L, 2(1+\beta)/L]$ has positive area).

---

## Route E — Rescaling Reparametrization

### Precise claim

**Claim E.** The OP-2 proof uses the hard instance $f_0^{(D)}(x) = (D^2/2)\psi(\sqrt 2 x/D)$ with cycle radius $D/\sqrt 2$. Replace $D$ by $D' = D/\sqrt 2$ (half the $\ell^2$ budget): the new function $f_0^{(D')}(x) = ((D')^2/2)\psi(\sqrt 2 x/D') = (D^2/4)\psi(2x/D)$ has:

- Cycle radius $(D')/\sqrt 2 = D/2$.
- Initial distance budget $D'$: $\|x_0^{D'} - x^\star\| = D' = D/\sqrt 2$.

If we set $x_0^{D'} = x_{-1}^{D'} = (D'/\sqrt 2) e_0 = (D/2) e_0$, then $x_0^{D'} = x_{-1}^{D'} = (D/2)e_0$ — zero velocity. Moreover, $\|x_0^{D'} - 0\| = D/2 \leq D'$ (within budget). Now apply the OP-2 initialization to $f_0^{(D')}$: the OP-2 init for $f_0^{(D')}$ is $x_0^{D'} = (D'/\sqrt 2)e_0 = (D/2)e_0$ and $x_{-1}^{D'} = (D'/\sqrt 2)e_{K-1} = (D/2)e_2$ — non-zero velocity.

The reparametrization idea: **choose $D'$ such that the OP-2 initialization for $f_0^{(D')}$ happens to coincide with zero-momentum init for the original problem at budget $D$.**

More precisely: the OP-2 init for $f_0^{(D)}$ requires $x_0 = (D/\sqrt 2)e_0$ and $x_{-1} = (D/\sqrt 2)e_2$. If we instead use $f_0^{(D')}$ with $D' = D/\sqrt 2$ and OP-2 init, we get $x_0^{D'} = (D/2)e_0$ and $x_{-1}^{D'} = (D/2)e_2$. This is NOT zero-velocity.

**Alternative rescaling strategy.** Use the positive homogeneity of the cycling identity: the cycling result is scale-free (it holds for any $\lambda > 0$ if the polytope is scaled by $\lambda$). Choose $\lambda$ so that the zero-momentum starting position $(\lambda e_0, \lambda e_0)$ satisfies the two-step induction after one "free" step: $x_1 = \lambda e_0 - \eta\nabla f_0(\lambda e_0) = -\lambda\beta e_0 + \lambda e_1 + \lambda\beta e_2$ (from Lemma D1), and declare a new cycle that starts from $(x_0, x_1) = (\lambda e_0, -\lambda\beta e_0 + \lambda e_1 + \lambda\beta e_2)$ rather than $(\lambda e_0, \lambda e_1)$.

**Precise claim E (revised).** There exists a rescaled Goujaud function $\tilde f_0^{(\lambda)}$ for some $\lambda^* \neq D/\sqrt 2$ and a modified polytope $\tilde P^*$ (obtained by applying the K=3 cycling inequality at a different $\kappa^* = \mu^*/L$) such that:

(i) $\tilde f_0^{(\lambda^*)}$ is $L$-smooth, $\mu^*$-strongly convex, with minimizer at the origin.

(ii) The zero-momentum initialization $x_0 = x_{-1} = \lambda^* e_0$ lies on a valid cycle of $\tilde f_0^{(\lambda^*)}$.

(iii) $\|\lambda^* e_0\| = \lambda^* \leq D$ (within budget).

(iv) $\|x_T\| = \lambda^*$ for all $T$, giving $f_0(x_T) \geq (\mu^*/2)(\lambda^*)^2$.

### Critical lemmas

**Lemma E1 (Invariance of cycling identity under rescaling).** The cycling identity $x_t = \lambda e_{t \bmod K}$ holds for any $\lambda > 0$ as long as the Goujaud function is rescaled accordingly: $f_0^{(\lambda)}(x) = \lambda^2 \psi(\sqrt 2 x / (\lambda\sqrt 2)) \cdot L$... (needs careful derivation).

**Lemma E2 (Zero-velocity init as a cycle start).** A zero-velocity initialization $(v, v)$ can start a cycling orbit only if $v$ is a "doubled vertex" of some 2K-cycle or a fixed point. For the Goujaud K-cycle, the only zero-velocity cycle start is a fixed point, which requires $v = 0$. Hence for non-trivial cycling, zero-velocity init cannot be a cycle vertex.

**Lemma E3 (Budget conversion).** If the hard instance uses parameter $D' \leq D$, the lower bound degrades: $\mathbb E[f(x_T) - f^\star] \geq c\kappa L(D')^2/T \leq c\kappa LD^2/T$. The budget is $D' = \|x_0 - x^\star\|$, which must be at most $D$. A smaller $D'$ gives a weaker LB.

**Lemma E4 (Optimal rescaling).** Find $D'$ maximizing the LB subject to: (a) zero-momentum init $(x_0^{D'} = x_{-1}^{D'})$ and (b) $\|x_0^{D'} - x^\star\| \leq D$. By Lemma E2, exact cycling under zero-momentum is impossible. The best achievable: $D' = D/\sqrt 2$ (from the perturbation approach, Route D), giving LB $\propto (D/\sqrt 2)^2 = D^2/2$ — half the OP-2 constant.

### Difficulty: **Standard to Advanced**

Lemma E2 is a short algebraic lemma showing zero-velocity fixed points of SHB must be stationary points of $f_0$. This rules out exact cycling under zero-momentum init for Goujaud-type functions. The route then reduces to: use a different $D'$ budget and the OP-2 init (non-zero velocity) at that $D'$, which gives a weaker LB. This is not really a zero-momentum result — it is the OP-2 result applied with $D' < D$.

**Key insight from Route E:** Rescaling can trade budget for initialization flexibility. The OP-2 init at budget $D' = D/\sqrt 2$ uses $x_0 = (D'/\sqrt 2)e_0 = (D/2)e_0$ and $x_{-1} = (D/2)e_2$ — velocity $= (D/2)(e_0 - e_2) \neq 0$. This does NOT give zero-momentum init. To get zero-momentum init with budget $D$, one would use $x_0 = x_{-1} = D \cdot u$ for some $\|u\| = 1/\sqrt 2$... this is equivalent to reducing the "effective" budget. The resulting LB is $\geq c\kappa L(D')^2/T$ for $D' = D$ but with a cycling constant that degrades by the ratio of $(D'/\sqrt 2)^2 / (D/\sqrt 2)^2$.

**The route's real value:** It shows that if one is WILLING to change the initial distance to $D' \leq D$ (a weaker condition), then zero-momentum init CAN be made to work by using the OP-2 construction at $D'$. The question is whether the resulting LB $\geq c\kappa L(D')^2/T$ for ANY $D' > 0$ constitutes an "answer" to the Prof. Li Xiao question. It does, with constant $c \cdot (D'/D)^2$, for any $D' > 0$.

### Likely failure mode

The route proves a LB but with init $x_0 = x_{-1}$ only if the cycle radius equals $\|x_0\|$, which forces $x_0 = x_{-1}$ to be a cycle vertex, which requires zero velocity — and the only zero-velocity cycle point is the origin ($\nabla f_0 = 0$). So the rescaling does not solve the problem; it confirms that exact zero-momentum cycling is impossible.

However, the route succeeds as a **weaker result**: for any $\varepsilon > 0$, one can find a hard instance with budget $D - \varepsilon$ and OP-2 (non-zero) init achieving the LB, and separately a trivial init-insensitive result. This is not what Prof. Li Xiao asked for (she wants ZERO-momentum init), but it is a rigorous sub-result.

### Predicted constant

$c = \kappa/4 \cdot (D'/D)^2$ for $D' = D - \varepsilon \to D$. This recovers the full OP-2 constant in the limit but requires non-zero velocity. No additional content beyond OP-2 for zero-momentum.

---

## Route F — Lyapunov / Basin Characterization

### Precise claim

**Claim F.** There exists a Lyapunov function $V : \mathbb R^2 \times \mathbb R^2 \to \mathbb R_{\geq 0}$ of the form

$$V(x_t, x_{t-1}) = \|x_t - \lambda e_{t \bmod K}\|^2 + \alpha \|x_t - x_{t-1} - \lambda(e_{t\bmod K} - e_{(t-1)\bmod K})\|^2$$

for some $\alpha > 0$ (a weighted sum of "position error" and "velocity error" from the cycle) such that:

(i) $V$ is non-increasing under the SHB update on $f_0$, on the "cycling region" $\{V(x_t, x_{t-1}) \leq r^2\}$ for some $r > 0$.

(ii) The zero-momentum initial state $(x_0, x_{-1}) = (\lambda e_0, \lambda e_0)$ satisfies $V(x_0, x_{-1}) = \|\lambda e_0 - \lambda e_0\|^2 + \alpha\|\lambda e_0 - \lambda e_0 - \lambda(e_0 - e_{K-1})\|^2 = \alpha\lambda^2\|e_0 - e_{K-1}\|^2 = \alpha\lambda^2 \cdot 2(1 - c_K)$.

(iii) If $V(x_0, x_{-1}) \leq r^2$ (which holds iff $\alpha \leq r^2 / (\lambda^2 \cdot 2(1-c_K))$), then by (i) $V(x_t, x_{t-1}) \leq r^2$ for all $t \geq 0$, implying $\|x_t - \lambda e_{t\bmod K}\| \leq r$, so $\|x_t\| \geq \lambda - r = D/\sqrt 2 - r \geq cD$ for $r < (1-c)D/\sqrt 2$.

### The Lyapunov approach reframed

A more natural Lyapunov candidate for the SHB around the cycle is the "energy" in the rotating frame. Let $z_t := R_{-t\theta_K} x_t$ (de-rotate the orbit). The cycle in the $z$-frame is the fixed point $z_t = \lambda e_0 = \lambda(1, 0)$. The SHB dynamics in the $z$-frame become a perturbed fixed-point iteration. Define

$$V(z_t, z_{t-1}) := \|z_t - \lambda e_0\|^2 + \gamma \|z_t - z_{t-1}\|^2.$$

If the rotated SHB map is a contraction in this $V$-metric on the set $\{V \leq r^2\}$, then $V$ is the sought Lyapunov function.

### Critical lemmas

**Lemma F1 (Rotating-frame dynamics).** Derive the SHB update for $z_t = R_{-t\theta_K} x_t$ in closed form. The gradient term introduces a term $R_{-t\theta_K} \nabla f_0(R_{t\theta_K} z_t) = \nabla f_0^{(\mathrm{rot})}(z_t)$ where $f_0^{(\mathrm{rot})}$ is the rotated function — which is the SAME function by rotational symmetry of $f_0$. So the rotating-frame map IS the same SHB map, but the cycle becomes a fixed point.

**Lemma F2 (Lyapunov decrease on cycling region).** Show that the Lyapunov function $V$ decreases along SHB orbits that are near the cycle (but starting with zero velocity error $z_{-1} = z_0 \neq \lambda e_0$). The decrease requires that the linearized SHB map around the cycle fixed point has spectral radius $< 1$ in the $V$-weighted norm.

**Lemma F3 (Linearization spectrum).** Compute the Jacobian $J$ of the SHB map at the cycle fixed point $(z_t, z_{t-1}) = (\lambda e_0, \lambda e_0)$. The Jacobian depends on the second derivative of $f_0$ at $\lambda e_0$, which involves the derivative of the polytope projection $\nabla P_{\mathrm{conv}(\tilde P)}$ at $\lambda e_0$. Since $\lambda e_0$ is on the polytope boundary (not interior), the projection derivative is a rank-1 matrix (tangential projection). The resulting $J$ has eigenvalues related to $r_{1,L}$, $r_{2,L}$, $r_{1,\mu}$, $r_{2,\mu}$ — the SHB eigenvalues.

**Lemma F4 (Basin radius $r$).** Show that the basin of the cycle (in the $V$-metric) has radius $r > 0$ that can be bounded below explicitly. The zero-momentum initial condition has $V$-value $\alpha\lambda^2 \cdot 2(1-c_K)$, which must be $\leq r^2$ for the cycle to be attractive.

**Lemma F5 (Characterization of $\mathcal F^{\mathrm{zero}}$).** The condition $V(\lambda e_0, \lambda e_0) \leq r^2$ is equivalent to an algebraic inequality on $(\beta, \eta L, \kappa)$, defining the set $\mathcal F^{\mathrm{zero}}$.

### Difficulty: **Research (hardest route)**

The key difficulty is Lemma F3: computing the Jacobian of the SHB map at the cycle boundary point. The Goujaud function $f_0$ is not $C^2$ everywhere (only $C^{1,1}$), and the projection $P_{\mathrm{conv}(\tilde P)}$ is not differentiable at points ON the polytope boundary (where $x = \lambda e_t$ — a vertex of $\tilde P$ or an edge point). Since $\lambda e_t$ IS the cycle, the linearization at the cycle IS at the non-smooth locus. The Jacobian analysis requires choosing the correct subdifferential, which depends on the specific geometry of the polytope at $\lambda e_0$.

For K=3, $\mathrm{conv}(\tilde P)$ is a triangle. The cycle vertices $\lambda M e_t$ are NOT the same as the cycle positions $\lambda e_t$ (they differ by $M$). The position $\lambda e_0$ relative to $\mathrm{conv}(\tilde P)$ depends on $\kappa = \mu/L$ and $(\beta, \eta)$ through $M$. Whether $\lambda e_0$ is inside, outside, or on the boundary of $\mathrm{conv}(\tilde P)$ determines the linearization.

An additional complication: the Lyapunov function must be defined carefully in the rotating frame to handle the nonlinear polytope projection. The standard Lyapunov theory for piecewise-smooth maps applies but requires verifying a sector condition on the projection operator.

### Likely failure mode

Lemma F3 fails: the cycle position $\lambda e_0$ is NOT in the interior of $\mathrm{conv}(\tilde P)$ (it IS outside — that's why cycling happens!), and the projection at a point outside the polytope IS differentiable (the projection onto a polygon is differentiable when the projection lands on an edge, not a vertex). However, if $\lambda e_0$ projects to a vertex of $\tilde P$, the projection is non-differentiable. Whether the projection lands on an edge or vertex depends on $(\beta, \eta L, \kappa)$.

Even if the Jacobian is computed, the eigenvalue analysis may show that the spectrum of $J$ has modulus $\geq 1$ in the direction orthogonal to the cycle, meaning the cycle is NOT locally stable for zero-momentum perturbations. This would explain the numerical decay: the cycle is an unstable periodic orbit (saddle point in the full state space) rather than an attractor for zero-momentum init.

### Predicted constant

If the route succeeds on $\mathcal F^{\mathrm{zero}}$: same constant as OP-2, $c = \kappa/4$. The measure of $\mathcal F^{\mathrm{zero}}$ would be characterized by the explicit basin condition $V(\lambda e_0, \lambda e_0) \leq r^2$, which at $\beta \geq 0.7$ gives a positive-measure subset. Predicted $\mathcal F^{\mathrm{zero}} \approx 8$% of $\mathcal F_{K=3}$ (matching numerics).

---

## Supplementary Route G — Direct Computation at Specific (β, ηL) via Interval Arithmetic

*Not in the original six, but recommended as a fallback.*

### Precise claim

**Claim G.** For a specific parameter $(\beta_0, \eta_0 L) = (0.8, 3.247)$ (one of the 8 empirically cycling points), prove rigorously using interval arithmetic (or a Cauchy-bound argument) that the zero-momentum SHB orbit satisfies $\|x_T\| \geq cD$ for all $T \leq T_{\max}$, for some explicit $T_{\max}$ and $c$. Extend to all $(\beta, \eta L)$ in a small open ball around $(\beta_0, \eta_0 L)$ by a Lipschitz continuity argument on the orbit.

This gives a constructive witness for $\mathcal F^{\mathrm{zero}}$ being non-empty and open (positive measure) without requiring a global Lyapunov function. The constant $c$ and the ball radius are explicit and computable.

### Difficulty: **Standard (computational)**

The computation is straightforward to $T_{\max} = 2000$ steps (matching the numerics), and the open-ball extension is an elementary perturbation bound. The result is a completely rigorous proof of the claim for this specific parameter, which is sufficient to establish positive measure of $\mathcal F^{\mathrm{zero}}$.

---

## Ranking Table

| Route | Description | Core Idea | Difficulty | Success Probability | Clean LB? | Measure of $\mathcal F^{\mathrm{zero}}$ |
|-------|-------------|-----------|------------|---------------------|-----------|-----------------------------------------|
| **D** | ε-perturbation → first-step exit | Explicit $x_1^{\mathrm{zero}}$ formula, polytope exit check | Advanced | **High (0.75)** | Yes, $\kappa/4$ | Positive, explicit algebraic condition |
| **G** | Interval arithmetic witness | Rigorous orbit bound at specific $(\beta_0, \eta_0)$ | Standard | **High (0.85)** | Yes, $\kappa/4$ | Non-empty open ball (constructive) |
| **A** | Amplitude non-vanishing + re-entry | $A_\mu^{\mathrm{zero}} \neq 0$ + nonlinear sustaining | Research | Medium (0.50) | Yes, same | Positive, algebraic |
| **C** | Period-2 attractor at high $\beta$ | Fixed point of $\Phi^2$, basin argument | Research | Medium (0.45) | Yes, $c^2\mu D^2$ | Positive, $\beta \in [0.85,1)$ |
| **F** | Lyapunov / basin characterization | Rotating-frame Lyapunov, spectral analysis | Research (hardest) | Low-Medium (0.35) | Yes, $\kappa/4$ | Characterizes $\mathcal F^{\mathrm{zero}}$ exactly |
| **B** | Different hard instance | Modified polytope / K variant | Advanced | Low-Medium (0.30) | Weaker | Positive but smaller $\mathcal F$ |
| **E** | Rescaling reparametrization | Budget $D' < D$ + OP-2 init at $D'$ | Standard | Low (0.15) | Weaker ($(D'/D)^2$ factor) | All of $\mathcal F_{K=3}$ but non-zero velocity |

---

## Recommendation for Explorer Agents

**Priority 1 — Route D (assign to Explorer 1):** The explicit $x_1^{\mathrm{zero}}$ computation is already done above (Lemma D1). The remaining work is: (a) determine when $x_1^{\mathrm{zero}} = \lambda(-1/2-\beta, (1-\beta)\sqrt3/2)$ exits the polytope $\mathrm{conv}(\tilde P)$ (a closed-form algebraic condition for K=3); (b) show inductively that once $x_1$ exits, the orbit cycles or stays bounded. This is the cleanest algebraic route and most likely to produce a publishable result within the scope of the project.

**Priority 2 — Route G (assign to Explorer 2):** Pure computation. Prove the claim rigorously for $(\beta, \eta L) = (0.8, 3.247)$ using exact rational arithmetic or Cauchy bounds. Takes the empirical 50-digit evidence and turns it into a mathematical proof. This is the "insurance" route: even if all analytic routes fail, this gives a rigorous positive result.

**Priority 3 — Route A (assign to Explorer 3):** The amplitude formula is clean. The hard part (Lemma A4) can be attacked by showing that the orbit starting from $(x_0, x_1^{\mathrm{zero}})$ with the specific $x_1^{\mathrm{zero}}$ satisfies the cycling induction from the second step onward — checking whether $x_1^{\mathrm{zero}}$ plays the role of a "perturbed $\lambda e_1$" that still triggers the same induction.

**Priority 4 — Route C (assign to Explorer 4):** The period-2 attractor at $\beta \in \{0.9, 0.95\}$ is the most exciting finding numerically (larger $\|x_t\|$ than the K=3 cycle!) but the hardest to prove. Assign to the most senior Explorer. Even a partial result — existence of the period-2 orbit without basin characterization — would be a significant new result.

**Priority 5 — Route F (assign to Explorer 5):** The Lyapunov approach is the most complete if it works (it would characterize $\mathcal F^{\mathrm{zero}}$ exactly), but also the most technically demanding. Assign as a parallel exploration — if Route D or A succeeds first, Route F becomes secondary.

**Do NOT prioritize Route B or E:** Route B reduces to Route D (the exact zero-velocity cycling is blocked by Lemma B3/E2). Route E is a weaker result that doesn't truly address zero-momentum init. These should be dropped in favor of the higher-value routes above.

---

## Mathematical crux: the $x_1^{\mathrm{zero}}$ exit condition (for Explorer 1)

The most actionable lemma, ready for immediate attack by Explorer 1:

For K=3, $e_0 = (1,0)$, $e_1 = (-1/2, \sqrt3/2)$, $e_2 = (-1/2, -\sqrt3/2)$, $\lambda = D/\sqrt2$:

$$x_1^{\mathrm{zero}} = \lambda(-1/2 - \beta,\ (1-\beta)\sqrt3/2).$$

The polytope $\mathrm{conv}(\tilde P)$ has vertices $\lambda M e_t$ for $t=0,1,2$. The matrix $M$ in the K=3 cycling identity is:

$$M = \frac{(1+\beta-\mu\eta)I - R_{2\pi/3} - \beta R_{-2\pi/3}}{(L-\mu)\eta},$$

which for $c_3 = -1/2$ and the K=3 cycling inequality gives explicit vertices depending on $(\beta, \eta L, \kappa)$.

**The exit condition** $x_1^{\mathrm{zero}} \notin \mathrm{conv}(\tilde P)$ can be tested via the support function: $x_1^{\mathrm{zero}} \notin \mathrm{conv}(\tilde P)$ iff $\langle n, x_1^{\mathrm{zero}}\rangle > \langle n, v\rangle$ for some outward normal $n$ and some edge $v$ of the triangle. For the K=3 polytope (a triangle), there are three edge normals to check. This is a direct algebraic computation in $(\beta, \eta L, \kappa)$ and is the first concrete task for Explorer 1.

The numerical evidence predicts this condition holds when $\beta \geq 0.7$ and $\eta L$ is close to $2(1+\beta)$. The goal of Explorer 1 is to find the explicit algebraic inequality on $(\beta, \eta L, \kappa)$ that is equivalent to the polytope exit condition, and verify it defines a positive-measure region.
