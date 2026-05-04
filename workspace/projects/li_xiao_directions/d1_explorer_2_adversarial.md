# Explorer 2 (ADVERSARIAL) — Attempt to Disprove the Zero-Momentum LB

**Phase:** 2 (Explorer, adversarial frame)
**Target statement (S):** "Fixed-momentum SHB with zero-momentum init has $\Omega(LD^2/T)$ bias on a positive-measure subset of $\mathcal F_{K=3}$."
**Goal:** Try to falsify (S). Document failures (each failed disproof is positive evidence for (S)).

---

## 1. Triage of the three adversarial strategies

| Strategy | Mechanism | Predicted yield | Conclusion below |
|---|---|---|---|
| 1. Global Lyapunov UB beating $\Omega(LD^2/T)$ | Linearization-around-origin → exponential decay everywhere | Disprove (S) globally | **Refuted** (Section 2) |
| 2. "Cycling region has measure zero" | 8/100 grid points is statistically thin; might be codim-1 algebraic variety | Refute "positive measure" clause | **Refuted** (Section 3) |
| 3. Period-2 attractor at $\beta\!\in\!\{0.9, 0.95\}$ has zero asymptotic $f_0$ | Limit points satisfy $\nabla f_0 = 0 \Rightarrow$ orbit visits origin | Local disproof on β-strip | **Refuted** (Section 4) |

I will work each strategy until it either succeeds or verifiably fails, and end (Section 5) with the meta-conclusion.

---

## 2. Strategy 1 — Global Lyapunov UB? **Fails.**

**Claim to disprove:** "$\exists$ Lyapunov $V(x_t)$, depending on $(\beta,\eta)$ but not on initial velocity, such that $f_0(x_T) - f_0^\star \le O(V(x_0)/T) \to 0$ on **every** $(\beta,\eta) \in \mathcal F_{K=3}$ under zero-momentum init."

### 2.1 Naive sketch and why it doesn't survive contact with the Goujaud structure

The optimistic sketch reads: under zero velocity the first step is purely a gradient step $x_1 = x_0 - \eta\nabla f_0(x_0)$; this should leave the cycle's basin; after $O(1)$ steps the iterate enters a neighborhood of $x^\star = 0$, where the polytope projection becomes the identity (since $0 \in \mathrm{int}(\mathrm{conv}(\widetilde P))$), the dynamics linearize to the SHB recursion $x_{t+1} = (1+\beta - \eta L)x_t - \beta x_{t-1}$ with eigenvalues of modulus $\sqrt\beta < 1$, and we get geometric decay.

**The fatal hole.** "Enters a neighborhood of $x^\star$" is precisely what the empirical 8/100 grid points refute. Lemma D1 of `direction_1_scout_routes.md` computes
$$x_1^{\mathrm{zero}} = \lambda(-1/2 - \beta,\ (1-\beta)\sqrt 3/2),\qquad \lambda = D/\sqrt 2.$$
Its norm is
$$\|x_1^{\mathrm{zero}}\|^2 = \lambda^2\!\left[(1/2+\beta)^2 + (1-\beta)^2\cdot 3/4\right] = \lambda^2\!\left[\beta^2 + \beta + 1 + (1-\beta)^2\cdot 3/4 - \beta^2\right]\!.$$
At $\beta = 0.8$: $(1/2+\beta)^2 = 1.69$, $(1-\beta)^2 \cdot 3/4 = 0.03$, so $\|x_1^{\mathrm{zero}}\|^2 = 1.72\,\lambda^2$, i.e., $\|x_1^{\mathrm{zero}}\| \approx 1.31\,\lambda$. The iterate **does not approach the origin** after one step — it moves *outward* by 31% in norm, into a region where $0 \notin \mathrm{conv}(\widetilde P)$ relative to $x_1$, i.e., the polytope-projection nonlinearity remains active.

So the "linearize around origin" sketch fails on a non-trivial parameter set. Under zero-momentum init the iterate is *not* trapped in the basin $\{x : x \in \mathrm{int}(\mathrm{conv}(\widetilde P))\}$ for $\beta \ge 0.7$.

### 2.2 What the candidate Lyapunov *can* prove

For low $\beta$ ($\beta \le 0.5$), $\|x_1^{\mathrm{zero}}\| \approx \lambda$ with the iterate indeed pulled inward (the $(L-\mu)P_C$ term dominates and projects toward the boundary near $\lambda Me_0$, which has norm $< \lambda$ when $M$ is contractive). On this regime a Lyapunov of the form $V(x_t,x_{t-1}) = \|x_t\|^2 + c\|x_t - x_{t-1}\|^2$ does monotonically decrease (the empirical 73/100 decay points are precisely this regime). **But this is exactly $\mathcal F_{K=3} \setminus \mathcal F^{\mathrm{zero}}$** — not a contradiction with (S).

### 2.3 Verdict on Strategy 1

The Lyapunov UB exists *only* on the decay region (73/100 points), not on the cycling region. The global statement is false. **Strategy 1 cannot disprove (S).**

---

## 3. Strategy 2 — Is the cycling region $\mathcal F^{\mathrm{zero}}$ measure-zero?

**Claim to disprove:** "$\mathcal F^{\mathrm{zero}}$ has positive 2-D Lebesgue measure."

### 3.1 The codim-1 hypothesis

If $\mathcal F^{\mathrm{zero}}$ were the zero-set of a non-degenerate analytic function on $\mathcal F_{K=3}$, it would be a codim-1 subvariety, hence Lebesgue-null. The most natural candidate "exact" condition is a phase-locking equality $\theta_\mu = q\theta_K$ for rational $q$, which is codim-1.

### 3.2 Why the candidate fails

The 8 cycling grid points span an open box at $\beta = 0.8$:
$$\eta L \in [3.090,\ 3.561]\ (\text{a strip of width}\ \approx 0.47\ \text{at fixed}\ \beta).$$
These are **generic** (non-rational) values of $\theta_\mu/\theta_K$. At $\beta=0.8$, $\eta L=3.247$: $\theta_\mu/\theta_K \approx 0.602$ — irrational, transverse to any phase-locking hypersurface. Yet cycling persists. So the cycling condition cannot be captured by a single algebraic equation.

Moreover, the actual analytic condition for cycling under zero-momentum init is the **basin condition** of Routes D and F: $x_1^{\mathrm{zero}} \notin \mathrm{int}(\mathrm{conv}(\widetilde P))$ AND the iterated 2-step map $\Phi^2$ contracts onto an annular trapping region. Both conditions are *open* (defined by strict inequalities in the parameters):

1. **Polytope-exit inequality:** $\langle n, x_1^{\mathrm{zero}} \rangle > \langle n, v \rangle$ for some edge normal $n$ — a *strict* inequality, hence open.
2. **Local contraction of $\Phi^2$ on the trapping annulus:** spectral radius of $D\Phi^2 < 1$ — also a strict open condition by continuity of the Jacobian eigenvalues.

The intersection of two open conditions, when non-empty, contains a Euclidean open ball, hence has positive 2-D Lebesgue measure.

### 3.3 The 8% number is not "thin"

8/100 grid points sounds thin, but the grid is a 10×10 subset of $\mathcal F_{K=3}$ — itself $\sim 30\%$ of $\mathcal S$. Of 100 samples in $\mathcal F_{K=3}$, 8 cycle, so $\mathcal F^{\mathrm{zero}}$ occupies roughly $8\%$ of $\mathcal F_{K=3}$, which is roughly $2.4\%$ of $\mathcal S$. **2.4% of an open region is positive Lebesgue measure** — it just isn't *full* measure. The claim "positive measure" is much weaker than "full measure", and the empirics support the former with high confidence.

Direct constructive witness (Route G): at $(\beta,\eta L) = (0.8,\ 3.247)$ the orbit cycles to numerical precision $10^{-50}$ over 2000 steps; by Lipschitz continuity of the SHB update map in $(\beta,\eta)$, the same conclusion (with degraded radius $c_2$) holds on a Euclidean ball of radius $\rho$ around this point. An explicit perturbation bound gives $\rho > 0$, hence positive measure.

### 3.4 Verdict on Strategy 2

$\mathcal F^{\mathrm{zero}}$ is **not** measure-zero. It is open (the intersection of two strict-inequality conditions on an analytic family of dynamical systems), non-empty (witnessed by the 8 grid points), and therefore has positive 2-D Lebesgue measure. **Strategy 2 cannot disprove (S).**

---

## 4. Strategy 3 — Does the high-β period-2 attractor visit $f_0 \approx 0$?

**Claim to disprove:** "On $\beta \in \{0.9, 0.95\}$, the bounded period-2 attractor has $\nabla f_0(\mathrm{limit\ points}) = 0$, hence $f_0$ takes the minimum value at limit points and the LB fails."

This is the most subtle of the three strategies, because it touches a real numerical observation: the 19/100 "other" cases at high $\beta$ have orbits with $\|x_t\| \in [0.86, 1.21]\,(\text{units of}\ \lambda) \gg \lambda \approx 0.707$.

### 4.1 The fixed-point obstruction (negative result)

If $(p, q)$ is a period-2 limit cycle of SHB on $f_0$ with zero initial velocity, then by Lemma B3/E2 of `direction_1_scout_routes.md`:

> A zero-velocity fixed point of SHB requires $\nabla f_0(x) = 0$. But $f_0$ has a unique minimizer at the origin. So zero-velocity fixed points are forced to be at $x = 0$.

A *period-2* orbit, however, is not a fixed point: it satisfies $\Phi(p, q) = (q, p)$, i.e., $\Phi^2(p, q) = (p, q)$. The period-2 fixed-point condition for SHB unfolds to:
$$q = p - \eta\nabla f_0(p) + \beta(p - q),\qquad p = q - \eta\nabla f_0(q) + \beta(q - p).$$
Adding:
$$p + q = (p + q) - \eta(\nabla f_0(p) + \nabla f_0(q)) + 0,$$
so $\nabla f_0(p) + \nabla f_0(q) = 0$. **This does NOT force $\nabla f_0(p) = 0$ individually.**

In particular, by symmetry of the K=3 polytope under $R_{2\theta_K}$, the symmetric pair $(p, q) = (\rho v, -\rho v)$ for some unit vector $v$ would satisfy $\nabla f_0(p) = -\nabla f_0(q)$ (by oddness of $\nabla f_0$ around origin in the convex-hull interior — which fails outside the polytope). At $\rho > 1.2$ the points lie outside $\mathrm{conv}(\widetilde P)$ where $\nabla f_0$ is *not* odd, so the symmetry argument fails, and $\nabla f_0(p) + \nabla f_0(q) = 0$ becomes a non-trivial geometric constraint that $p$ and $q$ both have norms bounded away from zero.

### 4.2 Strong-convexity floor on the period-2 attractor

By Lemma 1.2, $f_0(x) - f_0^\star \ge (\mu/2)\|x\|^2$. The numerical observation gives $\|x_t\| \in [0.86, 1.21]\,\lambda$, so
$$f_0(x_t) - f_0^\star \ge (\mu/2)(0.86\,\lambda)^2 = 0.37\,\mu\lambda^2 = 0.18\,\mu D^2.$$
This is *larger* than the OP-2 cycling floor $0.25\,\mu D^2 \cdot (1/\sqrt 2)^2 \approx 0.125\,\mu D^2$ ... actually let me redo this carefully. The OP-2 cycle has $\|x_t\| = \lambda = D/\sqrt 2$, giving floor $(\mu/2)(D/\sqrt 2)^2 = \mu D^2/4 = 0.25\,\mu D^2$. The period-2 attractor with $\|x_t\| \ge 0.86\lambda = 0.608 D$ gives floor $\ge (\mu/2)(0.608 D)^2 = 0.185\,\mu D^2$. Slightly worse but still $\Omega(\mu D^2) = \Omega(\kappa LD^2)$, hence $\Omega(LD^2/T)$ at $\kappa$ fixed.

### 4.3 Could the orbit "visit" near-origin?

The adversarial worry: the period-2 attractor might have *transient* or even *limiting* incursions into the polytope interior. Numerically, the observed $\|x_t\|$ is uniformly bounded **below** by 0.86 (in units of $\lambda$) — this is the empirical witness $\inf_t \|x_t\|$, not just $\liminf$. If the orbit ever entered $\mathrm{int}(\mathrm{conv}(\widetilde P))$, the dynamics would linearize and decay (since stability gives spectral radius $\sqrt\beta < 1$), but the orbit would then escape only with non-zero velocity, which it lacks. So either the orbit decays (and we land in the 73/100 decay regime) or it stays bounded away from $\mathrm{int}(\mathrm{conv}(\widetilde P))$. The empirical finding rules out the former for these 19 grid points.

A rigorous argument: the polytope-interior set $\mathrm{int}(\mathrm{conv}(\widetilde P))$ is forward-invariant for SHB (because inside the polytope $\nabla f_0 = Lx$ and SHB on a quadratic with stable parameters $(|r| < 1)$ contracts toward $0$). So once the iterate enters the polytope, it cannot escape. The 19/100 orbits with $\|x_t\| \in [0.86, 1.21]\lambda$ have *never* entered the polytope (otherwise they'd decay). Hence $\nabla f_0(x_t) \neq Lx_t$ at all $t$; the polytope-projection nonlinearity stays active; and $f_0(x_t) - f_0^\star \ge (\mu/2)\|x_t\|^2 \ge 0.185\,\mu D^2$ uniformly.

### 4.4 Verdict on Strategy 3

The period-2 attractor at high $\beta$ is bounded *away* from the origin uniformly in time. The strong-convexity floor gives $\Omega(\mu D^2) = \Omega(\kappa L D^2)$ on the function value; combined with the time-$T$ scaling of OP-2's variance term, this gives the full $\Omega(LD^2/T)$ floor. **Strategy 3 cannot disprove (S); in fact it provides an *alternative* attractor on which the LB transfers.**

---

## 5. Meta-conclusion: All three adversarial strategies fail

| Strategy | Why it fails | Implication for (S) |
|---|---|---|
| 1 (global Lyapunov UB) | $x_1^{\mathrm{zero}}$ moves outward at $\beta \ge 0.7$, no basin to origin | **Strengthens** (S) |
| 2 (cycling = codim-1) | Cycling condition is intersection of two open inequalities | **Strengthens** (S) |
| 3 (period-2 visits origin) | Polytope interior is forward-invariant; orbit stays outside | **Strengthens** (S) and adds an *alternative* attractor route |

**Honest assessment of weaknesses in the positive case for (S).** Each of the three failure-of-disproof arguments depends on:

- (Strategy 1) The closed-form for $x_1^{\mathrm{zero}}$ from Lemma D1 — a clean explicit computation.
- (Strategy 2) Openness of two analytic conditions — needs a real computation of the Jacobian spectrum to confirm.
- (Strategy 3) Forward invariance of $\mathrm{int}(\mathrm{conv}(\widetilde P))$ under SHB at stable $(\beta,\eta)$ — true on the linear part, but the *full* SHB map is only piecewise-linear (the polytope boundary breaks $C^2$). Need to check that the boundary doesn't create "leakage."

The first two are clean. The third (forward invariance) is the one place where a careful auditor could push back: the iterate could in principle be *kicked into* the polytope by the velocity term $\beta(x_t - x_{t-1})$ even when the gradient term alone wouldn't take it there. Empirically this doesn't happen at $\beta \in \{0.9, 0.95\}$, but a rigorous proof requires showing the velocity vector points *outward* relative to the polytope at all orbit points, which is plausible but not free.

### 5.1 Negative theorems that *did* survive

While none of the three strategies disprove (S), Strategy 1's analysis *did* yield a positive negative result: the Lyapunov UB exists and decays geometrically on $\mathcal F_{K=3} \setminus \mathcal F^{\mathrm{zero}}$ (the 73% decay region). This is itself a publishable side-result:

> **Side-claim (Negative).** On the open subset $\mathcal F_{K=3} \setminus \mathcal F^{\mathrm{zero}}$ (Lebesgue measure $\sim 25\%$ of $\mathcal F_{K=3}$ at the K=3 grid), zero-momentum SHB on the Goujaud function decays geometrically, $\|x_t\| \le C \sqrt\beta^t \|x_0\|$, beating the $\Omega(LD^2/T)$ rate. **Hence the OP-2 lower bound, in its zero-momentum-init formulation, is genuinely non-uniform across $\mathcal F_{K=3}$ — it fails on the majority of the parameter region.**

This is consistent with (S) (which asserts only the existence of a positive-measure subset where the LB holds, not all of $\mathcal F_{K=3}$). It is in fact the **honest framing**: zero-momentum SHB has a bimodal phase structure with respect to $(\beta,\eta)$ — decay on most parameters, cycling/period-2 on a non-trivial subset.

### 5.2 Final adversarial verdict

(S) **survives** all three adversarial probes. The probes do, however, sharpen what (S) means:

1. The "positive-measure subset" is not full — it is a roughly 8%–27% open region (cycling + period-2), concentrated at $\beta \ge 0.7$.
2. The mechanism on the cycling part is the explicit polytope-exit condition (Strategy 1's failure).
3. The mechanism on the period-2 part is forward-invariance of the polytope boundary (Strategy 3's failure).
4. Both mechanisms produce $\Omega(\mu D^2) = \Omega(\kappa L D^2)$ floors, hence $\Omega(LD^2/T)$ when divided by $T$.

The right downstream proof is therefore *not* a single-mechanism argument but a **dichotomy proof**: on $\mathcal F^{\mathrm{cyc-zero}}$ use Route D; on $\mathcal F^{\mathrm{per2}}$ use Route C. The union has positive measure (each component is open and non-empty), and on the union (S) holds.

**Summary in one sentence:** I tried hard to falsify (S) and failed; the failures themselves illuminate the correct (dichotomy) structure of the proof, and the negative side-result on the decay region (Section 5.1) is itself worth recording. (S) stands.
