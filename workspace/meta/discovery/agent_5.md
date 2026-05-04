# Discovery Report — Agent 5

**Scope.** Lower bounds for Stochastic Heavy Ball (4 variants of OP-2 / Goujaud–Taylor–Dieuleveut), four operator-splitting ergodic-rate proofs (Douglas–Rachford, Chambolle–Pock, Davis–Yin, ADMM), and one diffusion-sampling rate (ULA under LSI).

---

## 1. SHB no acceleration — restricted lower bound (`shb-no-acceleration-restricted`)

### The Spark
**failure-of-natural-approach.** Numerical sweeps showed that at the auditor-mandated pairs $(0.5,1/L)$ and $(0.9,1/(2L))$ the SHB iterate on a Goujaud cycling instance **converges geometrically** rather than cycling — so the original "for all $(\beta,\eta) \in \mathcal{S}$" claim is false as stated, and the authors had to retreat to a subregion $\mathcal{F}$.

### The Key Insight
The Goujaud cycling inequality (GTD-cyc) does not hold on all of $\mathcal{S}$ — there is a sharp algebraic feasibility region $\mathcal{F}$, and the "no acceleration" theorem must be quantified over $\mathcal{F}$, not $\mathcal{S}$. The $D$-budget must be split across a 2-D cycling subspace and an orthogonal 1-D Le Cam noise coordinate so that the bias term $\Omega(LD^2/T)$ and the variance term $\Omega(\sigma D/\sqrt T)$ live on disjoint coordinates and add cleanly. Strong convexity $\mu = \kappa L > 0$ is **forced** by the GPT cycling identity (the cycle radius matters), so the "non-SC" version of the theorem is structurally different from what the literal problem asked for.

### The Technique Chain
- **Goujaud–Taylor–Dieuleveut 2023 polytope-Moreau function** $\psi(x) = (L/2)\|x\|^2 - ((L-\mu)/2) d_{\mathrm{conv}(P)}^2(x)$ — non-standard, lifted as black box from arXiv:2307.11291.
- **Spatial rescaling** $f_0(x) = D^2 \psi(x/D)$ to match the $D$-budget — standard linear scaling, but tactically essential.
- **Coordinate decoupling** (orthogonal sum $\mathbb{R}^2 \oplus \mathbb{R}$) to make Le Cam noise commute with cycling — standard "block-diagonal hard instance" template.
- **Le Cam two-point method + Pinsker** for the variance lower bound — standard from Nemirovski–Yudin 1983 / ABRW 2012.
- **Strong-convexity floor** $f(x) - f^\star \geq (\mu/2)\|x-x^\star\|^2$ at minimizer — textbook.

### The Construction
The 2-D Goujaud function forces SHB iterates to **cycle exactly** on a $K$-vertex polygon at radius $D/\sqrt{2}$, so the strong-convexity floor pins $f(x_t) - f^\star \geq \mu D^2/4$ uniformly in $t$. The orthogonal $y$-coordinate adds a tiny linear drift $\alpha = O(\sigma/\sqrt T)$ inside a quadratic wall, so a Le Cam two-point hypothesis-test argument forces $\Omega(\sigma D/\sqrt T)$ regardless of how the algorithm uses the noisy gradients. Without the orthogonality the noise would couple to cycling and break Lemma AP; without the wall the linear function is unbounded; without the spatial rescaling the cycle radius is fixed at $1$ and decoupled from $D$.

### The Failure Modes
- **Pure quadratic instance.** Spectral analysis gives geometric convergence on quadratics throughout $\mathcal{S}$ — quadratics provably cannot deliver an $\Omega(1/T)$ lower bound.
- **NY 1-D linear instance alone.** Gives only the variance term $\sigma D/\sqrt T$, no bias term — misses the entire "no acceleration" content.
- **Try to extend cycling to all of $\mathcal{S}$.** Numerical falsification at $(0.5,1/L)$ kills this immediately; the Goujaud feasibility set is genuinely smaller than $\mathcal{S}$.

### The Discovery Path
1. Try to mimic GTD23's strongly-convex lower bound for the non-SC setting demanded by the problem.
2. First attempt (Route F) takes $\mu \to 0$ in GTD23 — discovers the cycling feasibility shrinks along with $\mu$, region collapses.
3. Numerical sanity check (audit Step 0.5) reveals cycling fails at the standard verification pairs; this is the "honest gap" moment — the literal problem may be **false**.
4. Pivot: keep $\mu = \kappa L > 0$ fixed (so the problem's "non-SC allowed" assumption is technically satisfied since $\mu \geq 0$ is allowed), restrict quantifier to the algebraic region $\mathcal{F}$, derive closed-form $\gamma_\mathrm{crit}$ and threshold $\beta^\star = (\sqrt{13}-3)/2$.
5. Verify cycling to machine precision ($10^{-16}$ drift over 1000 steps) inside $\mathcal{F}$ and explicit non-cycling outside — restricted theorem PASS, full theorem flagged OPEN.

### Transferable Patterns
- **"Restricted-quantifier rescue."** When a stated theorem is empirically false, find the maximal subregion where the construction works, derive its sharp boundary algebraically, and present an honest scoping note. The pattern of pairing a "bias coordinate" with an orthogonal "Le Cam noise coordinate" is reusable for any $\Omega(\text{bias}/T) + \Omega(\sigma D/\sqrt T)$ lower bound.

---

## 2. SHB cycling — critical momentum threshold (`shb-cycling-critical-momentum`)

### The Spark
**pattern-spotted.** While computing the cycling feasibility region $\mathcal{F}_K$ for the OP-2 lower bound, a closed-form expression $\gamma_3(\beta) = 3(1+\beta+\beta^2)/(1+2\beta)$ emerged, and asking "for which $\beta$ is this $\leq 2(1+\beta)$?" produced an unexpectedly clean quadratic $\beta^2 + 3\beta - 1 \geq 0$.

### The Key Insight
The complicated GPT cycling inequality, after substituting $c_K = \cos(2\pi/K)$, factors as $(1+c_K)\cdot Q_K(\beta)$ where $Q_K(\beta) = \beta^2 + 2(1-c_K)\beta - 1$ is purely quadratic in $\beta$. This factorization is non-obvious because the original inequality is a tangle of $\beta, c_K, \eta$ in three different positions, but algebraic expansion reveals all $c_K$-dependence collapses into the single coefficient $1-c_K$. The threshold $\beta^\star$ is then a closed-form root of $Q_3$, attained at $K=3$ because $\beta_{\min}(c_K) = \sqrt{(1-c_K)^2+1} - (1-c_K)$ is decreasing in $1-c_K$ and $K=3$ minimizes $1-c_K$ among $K \geq 3$.

### The Technique Chain
- **Direct polynomial factorization** to expose hidden $\beta$-quadratic structure — standard but requires guessing the right grouping.
- **Quadratic formula + sign-of-discriminant** to get the threshold root — textbook.
- **Monotonicity argument** $\varphi(u) = \sqrt{u^2+1} - u = 1/(\sqrt{u^2+1}+u)$ via rationalization — textbook trick (multiply by conjugate).
- **Discrete optimization over $K \geq 3$** — note that the relevant variable is $u_K = 1 - \cos(2\pi/K)$ which is monotone in $K$.

### The Construction
n/a — this is purely an algebraic threshold computation, no construction.

### The Failure Modes
- **Solving directly in $\eta$ first.** Gives $\eta_-(\kappa)$ as a rational function — messy, hides the $\beta$-quadratic.
- **Numerical sweep without closed form.** Would find $\beta^\star \approx 0.3028$ but miss the exact value $(\sqrt{13}-3)/2$ and the $K=3$-witness uniqueness.

### The Discovery Path
1. While defining $\mathcal{F}$ in OP-2, write the closed form $\gamma_3(\beta)$ at $K=3$.
2. Compute $\gamma_3(\beta) - 2(1+\beta)$ and observe it factors as $-(\beta^2 + 3\beta - 1)/(1+2\beta)$ — surprise.
3. Conjecture: $K=3$ minimizes the threshold; numerically verify $\beta_{\min}(c_K)$ at $K = 3,4,5,10,50,100,1000$.
4. Prove monotonicity via the rationalization trick and substitute $u_K \downarrow 0$.
5. Sharpness check at $\beta = \beta^\star$: equality in $(\dagger_3)$ at the unique boundary $\eta = 2(1+\beta^\star)/L$, verified numerically to $10^{-16}$.

### Transferable Patterns
- **"Conjugate-rationalization for monotonicity."** Whenever you see $\sqrt{u^2+a} \pm u$, multiply by the conjugate to get $a/(\sqrt{u^2+a} \mp u)$, which often reveals monotonicity invisible in the original form.
- **Reduce a multi-parameter inequality to a single-variable polynomial threshold by isolating the right pivot variable.**

---

## 3. SHB interpolation regime LB (`shb-interpolation-regime-lb`)

### The Spark
**question-asked.** "What happens to the OP-2 bound $\Omega(LD^2/T) + \Omega(\sigma D/\sqrt T)$ when noise vanishes at the optimum (interpolation regime)?" The answer is asymmetric: the bias term survives unchanged, but the variance term is **provably impossible**.

### The Key Insight
Under interpolation noise $\mathbb{E}\|\xi_t\|^2 \leq \sigma^2 \rho(\|x_t-x^\star\|)$ with $\rho(0)=0$, a **noiseless oracle** ($\xi_t \equiv 0$) is admissible since $0 \leq \sigma^2 \rho(r)$ trivially — so the OP-2 deterministic Goujaud cycling argument transfers verbatim and gives $\Omega(\kappa L D^2/T)$ with the **sharper** constant $\kappa/2$ (no $D$-budget split needed). Conversely, an explicit quadratic with multiplicative noise $\xi_t = \sigma\|x_t\|\varepsilon_t$ achieves second-moment contraction $\mathbb{E}\|x_{t+1}\|^2 = \rho \cdot \mathbb{E}\|x_t\|^2$ with $\rho = (1+\sigma^2/L^2)/4 < 1$ — exponential decay that destroys any polynomial $\Omega(\sigma D/\sqrt T)$ bound.

### The Technique Chain
- **Reuse OP-2 construction as a special case** (noiseless oracle ⊂ any interpolation oracle) — meta-pattern.
- **Direct second-moment recursion on quadratics** with multiplicative noise — standard from Vaswani–Bach–Schmidt 2019 and Bach 2014 LSquares analysis.
- **"Exponential beats polynomial" refutation** — elementary calculus, but the conceptual move (algorithm-existential disproof) is non-trivial.
- **$\eta$-optimization** $\eta^\star = L/(L^2+\sigma^2)$ for the general $\sigma$ case — single-variable derivative.

### The Construction
The quadratic $f(x) = (L/2)\|x\|^2$ with multiplicative noise $\xi_t = \sigma\|x_t\|\varepsilon_t$ is the simplest possible counterexample: noise vanishes at $x^\star = 0$, making interpolation tight, while the oracle is unbiased and second-moment-bounded by $\sigma^2 \|x_t\|^2 = \sigma^2 \rho_1(\|x_t-x^\star\|)$. The cross term $\langle x_t, \varepsilon_t\rangle$ vanishes in expectation, so the recursion is purely contractive — no random walk floor.

### The Failure Modes
- **Try to repeat NY Le Cam under interpolation.** The wall optimum $y^\star = -sD/\sqrt 2$ has nonzero distance from iterates, so the variance there is $\sigma^2 \rho(D/\sqrt 2) > 0$ — *seems* to save the argument, but the existence of a quadratic counterexample (Part B) proves no algorithm-uniform LB can hold.
- **Try to prove a fractional rate $\Omega(\sigma^{2/3}/T^{2/3})$ instead.** Open question for $\rho(r) = r$, but for $\rho(r) = r^2$ even this fails by the exponential counterexample.

### The Discovery Path
1. Note OP-2's variance term $\Omega(\sigma D/\sqrt T)$ uses bounded-variance oracle; ask what happens if noise vanishes at optimum.
2. First attempt: try to extend Le Cam construction with $\sigma_{\mathrm{eff}} = \sigma\sqrt{\rho(D/\sqrt 2)}$ — looks like it might work, but the "joint coordinate" structure of OP-2 fights against it.
3. Pivot to algorithm-existential disproof: just exhibit ONE algorithm that beats the bound exponentially.
4. Quadratic + multiplicative noise + GD with $\eta = 1/(2L)$ gives $\rho = (1+\sigma^2/L^2)/4$ — clean second-moment recursion.
5. Verify with $N=20000$ trajectories: 4-decimal match between empirical and theoretical $\rho$.

### Transferable Patterns
- **"Algorithm-existential refutation."** To kill a putative universal lower bound $\geq c \cdot R(T)$, exhibit one $(f, \mathcal{O}, \mathcal{A})$ tuple where the algorithm achieves $\ll R(T)$. Far cleaner than "the standard argument fails because…" reasoning.
- **Noiseless oracle as edge case** of any noise class with $\rho(0) = 0$ — automatic transfer of any deterministic LB.

---

## 4. SHB no-acceleration best-iterate (`shb-no-acceleration-best-iterate`)

### The Spark
**question-asked.** "Does the OP-2 last-iterate lower bound also hold for the best iterate $\min_{t \leq T} f(x_t)$?" The bias term yes (trivially), but the variance term **fails** — best-iterate is fundamentally easier than last-iterate stochastically.

### The Key Insight
The Goujaud cycle visits each vertex with **identical** distance $D/\sqrt 2$ to the optimum — there is no "favorable" iterate, so $\min_t f(x_t) = f(x_t)$ for every $t$, and the bias bound transfers to best-iterate with the same constant. But on the noise coordinate, Le Cam's two-point lower bound is tied to the **last iterate's sign** $\mathrm{sign}(y_T)$: replacing this with $\mathrm{sign}(y_{t^*})$ for $t^* = \arg\min$ produces a near-perfect test, voiding the Le Cam guarantee. Worse, a 1-D random walk visits any neighborhood of the optimum infinitely often, so the best iterate's stochastic gap actually scales as $O(1/T)$ or $O(1/T^2)$ — exponentially smaller than the putative $\sigma D/\sqrt T$ floor.

### The Technique Chain
- **Reuse OP-2 cycling and SC floor verbatim** for bias — direct transfer.
- **Critical analysis of Le Cam test choice** — non-standard meta-observation: which iterate the test reads matters.
- **Random-walk visit-rate argument** for variance — standard SDE/Markov-chain heuristic, though here used as an obstruction rather than an upper bound.
- **Empirical disproof** with explicit decay rate $T^{-2}$ instead of target $T^{-1/2}$.

### The Construction
n/a for the bias part (reuse OP-2). For the variance disproof, the OP-2 1-D wall instance at $(\beta, \eta) = (0.5, 1/L)$ is simulated and shown to have best-iterate stochastic gap $\sim T^{-2}$, much faster than the conjectured $T^{-1/2}$.

### The Failure Modes
- **Naive transfer of OP-2 last-iterate Le Cam.** Replaces $\hat s = -\mathrm{sign}(y_T)$ with $\hat s = -\mathrm{sign}(y_{t^*})$ — but this near-perfectly recovers $s$, since $y_{t^*}$ is closest to $y^\star = -sD/\sqrt 2$.
- **Try to show best-iterate variance LB on a different construction.** Conjecturally false in general — best iterate of any unbiased random walk converges to optimum.

### The Discovery Path
1. Ask: does OP-2's argument transfer to best iterate?
2. Bias: yes, trivially, since cycling is uniform.
3. Variance: try to apply Le Cam — discover the test based on $y_{t^*}$ has classification error $\to 0$, voiding Le Cam.
4. Conjecture: best-iterate variance UB is $O(\sigma^2/L)$ (random walk noise floor), not $O(\sigma D/\sqrt T)$.
5. Empirical confirmation: at $T = 1000$, gap is $4 \times 10^{-6}$, target is $0.0026$ — factor 650 short and worsening.

### Transferable Patterns
- **"Min-vs-last asymmetry in stochastic LBs."** Many stochastic last-iterate bounds rely on the test reading a specific iterate; best-iterate disrupts this. A general meta-principle: lower bounds via Le Cam are intrinsically sensitive to the *information-extracting test*, and switching from "look at $x_T$" to "look at $\arg\min_t f(x_t)$" can collapse the lower bound entirely.
- **Cycle-uniformity** as a tool: when all iterates have identical distance to optimum, best = last for the bias term.

---

## 5. Douglas–Rachford O(1/k) (`douglas-rachford-splitting-rate`)

### The Spark
**pattern-spotted.** The DR operator has the suggestive form $T_{DR} = \mathrm{Id} + J_{\gamma A}(2J_{\gamma B} - \mathrm{Id}) - J_{\gamma B}$. Lions & Mercier 1979 noticed this telescoping structure simplifies dramatically to $T_{DR} = (\mathrm{Id} + R_A R_B)/2$ — an "averaged operator" form that immediately implies firm nonexpansiveness.

### The Key Insight
DR splitting hides a clean averaged-operator structure: $T_{DR} = \frac{1}{2}(\mathrm{Id} + R_A R_B)$ where $R_A, R_B$ are *reflected* resolvents (each nonexpansive because each resolvent is firmly nonexpansive). The composition $R_A R_B$ is nonexpansive, so $T_{DR}$, being the average of identity and a nonexpansive operator, is firmly nonexpansive — yielding the Fejér inequality $\|T_{DR}(z) - z^*\|^2 + \|T_{DR}(z) - z\|^2 \leq \|z - z^*\|^2$ for free.

### The Technique Chain
- **Resolvent firm nonexpansiveness via monotonicity** — classical Minty/Rockafellar.
- **Reflected-resolvent identity** $R = 2J - \mathrm{Id}$ and its nonexpansiveness — standard.
- **Algebraic simplification** $T_{DR} = (\mathrm{Id} + R_A R_B)/2$ — Lions–Mercier 1979.
- **Krasnosel'skii–Mann iteration of $R_A R_B$** — standard convergence theory.
- **Telescoping Fejér inequality + monotone residuals** to get $O(1/k)$ — standard since Brezis–Lions.
- **Opial's lemma + demiclosedness (Browder)** for weak convergence — standard Hilbert space technique.

### The Construction
n/a — pure operator-theoretic proof.

### The Failure Modes
- **Treat DR as just sequential prox.** Misses the reflection structure; fails to prove FNE of $T_{DR}$.
- **Try to bound $f(x_k) - f^\star$ directly.** DR doesn't operate on a function — it operates on monotone inclusions, so there's no objective gap to telescope; the residual $\|z_{k+1} - z_k\|$ is the right Lyapunov.

### The Discovery Path
1. Lions–Mercier 1979 propose DR for monotone inclusions, derive the operator form.
2. Algebraic manipulation: substitute $R_A = 2J_A - \mathrm{Id}$ and discover the averaged-operator form.
3. Combine with Krasnosel'skii–Mann theory: averaged ops have FNE, hence Fejér inequality.
4. Telescope + use monotonicity of residuals (consequence of $T_{DR}$ being nonexpansive) to get $\|z_{k+1} - z_k\|^2 \leq D^2/k$.
5. Add Opial + demiclosedness for weak convergence of $\{z_k\}$, plus FNE of $J_B$ for strong convergence of $\{x_k\}$.

### Transferable Patterns
- **"Averaged-operator template."** Whenever $T = (\mathrm{Id} + N)/2$ with $N$ nonexpansive, you get FNE of $T$ for free, hence Fejér monotonicity, hence $\|z_k - z_{k-1}\|^2 = O(1/k)$. This is the master template applied to DR, ADMM-as-DR, and many proximal-splitting methods.
- **Reflection trick** $R = 2J - \mathrm{Id}$ converts firm nonexpansive ops to plain nonexpansive ops, suitable for composition.

---

## 6. Chambolle–Pock PDHG ergodic O(1/N) (`chambolle-pock-pdhg-ergodic-convergence`)

### The Spark
**gap-in-literature.** Pre-2010 saddle-point algorithms (Arrow–Hurwicz, Korpelevich's extragradient) lacked tight $O(1/N)$ ergodic rates with simple step-size conditions. Chambolle–Pock 2011 closed the gap by adding extrapolation $\bar x^n = 2x^n - x^{n-1}$ and proving the rate under the simple condition $\tau\sigma L^2 < 1$.

### The Key Insight
PDHG is a preconditioned proximal-point method on the monotone inclusion $0 \in (A+B)(z)$ where $B$ is skew (linear coupling) and $A$ is the subdifferential of $g \oplus f^*$. The step-size condition $\tau\sigma L^2 < 1$ is *exactly* the Schur-complement condition for the preconditioner $\mathcal{M}$ to be positive definite, and it *also* exactly cancels the cross term arising from extrapolation when applying Young's inequality. The extrapolation is essential: it gives $x^{n+1} - \bar{x}^n = (x^{n+1} - x^n) - (x^n - x^{n-1})$, which decomposes into telescoping plus a controllable residual involving consecutive iterative differences.

### The Technique Chain
- **Saddle-point → monotone inclusion** with skew $B$ and maximal monotone $A$ — Rockafellar sum theorem.
- **Preconditioned proximal point** view (Chambolle–Pock 2011, He–Yuan 2012) — non-standard at the time, now textbook.
- **Schur complement** for $\mathcal{M} \succ 0$ — textbook linear algebra.
- **Three-point identity** $2\langle a-b, c-a\rangle = \|c-b\|^2 - \|c-a\|^2 - \|a-b\|^2$ — standard polarization.
- **Young's inequality** $\langle Ka, b\rangle \leq (\sigma L^2/2)\|a\|^2 + (1/(2\sigma))\|b\|^2$ tuned to absorb cross terms.
- **Telescoping + Jensen** on the Lagrangian gap — standard ergodic analysis.

### The Construction
n/a — pure algorithmic/algebraic proof.

### The Failure Modes
- **Vanilla Arrow–Hurwicz without extrapolation.** Diverges or only achieves $O(1/\sqrt N)$ — extrapolation is the secret sauce.
- **Treat $K$ as just a coupling matrix.** Misses the variational-inequality view that makes telescoping clean.
- **Use $\tau\sigma L^2 \leq 1$ (non-strict).** Boundary case requires more care; $\tau\sigma L^2 < 1$ gives strict positive definiteness, simplifying the algebra.

### The Discovery Path
1. Try Arrow–Hurwicz / extragradient — get $O(1/N)$ but with restrictive step-sizes or extra projection.
2. Chambolle–Pock 2011: try sequential prox $y$-then-$x$ with extrapolation $\bar x = 2x^n - x^{n-1}$ — empirically faster.
3. Reformulate as preconditioned proximal point on $0 \in (A+B)z$.
4. Schur complement reveals $\tau\sigma L^2 < 1 \Leftrightarrow \mathcal{M} \succ 0$.
5. Telescope per-step VI inequality, decompose extrapolation cross term, apply Young's inequality with parameter $\sigma$ chosen so the absorbed term cancels exactly.
6. Jensen's inequality on the convex-concave Lagrangian to get ergodic gap.

### Transferable Patterns
- **"Extrapolation creates telescopable cross terms."** Whenever you see $\bar{x}^n = 2x^n - x^{n-1}$ in a primal-dual algorithm, expect $x^{n+1} - \bar{x}^n = \Delta_{n+1} - \Delta_n$ and look for telescoping.
- **"Step-size = positive definiteness = cross-term cancellation."** A single condition often plays multiple roles in primal-dual analyses; recognizing this unifies the proof.

---

## 7. Davis–Yin three-operator splitting ergodic variant (`davis-yin-three-operator-splitting-ergodic-variant`)

### The Spark
**failure-of-natural-approach.** The original Davis–Yin 2017 ergodic O(1/K) bound uses an averagedness lemma proved separately; trying to derive the rate purely from local algebra (convexity + descent + polarization) hits a wall when $\gamma > 1/\beta$. The honest variant restricts to $\gamma \in (0, 1/\beta]$ and bounds a *split* objective $\widetilde F(\bar x^K, \bar y^K)$.

### The Key Insight
The DYS one-step inequality factors cleanly as $\widetilde F^k - F(x^*) \leq (1/(2\gamma))(\|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2) - ((\alpha-1)/(2\gamma))\|r^k\|^2$ where $r^k = x^k - y^k$ and $\alpha = 2 - \gamma\beta$. The residual coefficient is non-positive iff $\alpha \geq 1$ iff $\gamma \leq 1/\beta$. The crucial primal–dual identity (eq. 6) $u^k + v^k + \nabla h(y^k) = -r^k/\gamma$ — derived from the prox optimality conditions — is what closes the algebra and produces the $\langle r^k, x^k - x^*\rangle$ term needed for polarization.

### The Technique Chain
- **Three convexity inequalities** (one per operator $f, g, h$) — textbook subgradient inequality.
- **$\beta$-smooth descent lemma** for $h$ — textbook.
- **Primal–dual identity from prox Fermat conditions** — non-standard but essential structural lemma.
- **Polarization identity** $\langle a-b, a-c\rangle = (\|a-b\|^2 + \|a-c\|^2 - \|b-c\|^2)/2$ — standard.
- **Anchor shift** $z^* = x^* + \gamma v^*$ to align Lyapunov with prox structure — non-standard tactical move.
- **Telescoping + Jensen** on the split objective $\widetilde F(\bar x^K, \bar y^K)$ — standard ergodic analysis.

### The Construction
n/a — pure algorithmic proof.

### The Failure Modes
- **Try to bound $F(\bar x^K)$ instead of split $\widetilde F(\bar x^K, \bar y^K)$.** Difference is $g(\bar y^K) - g(\bar x^K)$, which requires extra hypotheses (e.g., Lipschitz $g$) to control — honest variant accepts the split objective.
- **Try $\gamma \in (0, 2/\beta)$.** Residual coefficient becomes positive for $\gamma > 1/\beta$; need DYS averagedness lemma (Davis–Yin Prop 2.1) which is not derivable from local algebra alone.
- **Anchor at $z^*$ instead of $x^*$.** Makes the polarization identity less clean; the $x^*$-anchor exactly cancels the $\langle r^k, v^k\rangle$ term via identity (6).

### The Discovery Path
1. Try to derive O(1/K) for DYS by direct algebra mimicking PDHG.
2. Discover that the natural Lyapunov $\|z^k - z^*\|^2$ requires the DYS averagedness lemma.
3. Restrict to $\gamma \leq 1/\beta$ where the residual term is automatically non-positive.
4. Notice that $x^*$ is a more natural anchor than $z^*$ for the polarization, since prox-Fermat conditions naturally produce $x^k - x^* + r^k$ structure.
5. Telescope, Jensen, and explicitly document the four discrepancies vs. the original theorem (split objective, anchor, step-size range, missing $1/\alpha$).

### Transferable Patterns
- **"Honest variant when full theorem requires black-box lemma."** Restrict the step-size range, accept a slightly weaker objective, document each gap precisely, and prove what is provable algebraically. Clean intellectual hygiene applicable wherever a rate proof requires an external "averagedness" or "contraction" lemma.
- **"Fermat-derived primal-dual identity"** $u^k + v^k + \nabla h(y^k) = -r^k/\gamma$ is a recurring pattern in three-operator splittings.

---

## 8. ADMM ergodic O(1/T) (`admm-ergodic-convergence`)

### The Spark
**pattern-spotted.** He–Yuan 2012 noticed that ADMM, written in an augmented-Lagrangian form, admits a Lyapunov $\mathcal{E}^k = (1/(2\beta))\|\tilde\lambda - \lambda^k\|^2 + (\beta/2)\|B(\tilde z - z^k)\|^2$ that drops by exactly the gap function value (modulo a perfect-square slack), giving a clean O(1/T) ergodic primal–dual gap.

### The Key Insight
The "lagged dual" $\bar\lambda_T = (1/T)\sum_{k=0}^{T-1}\lambda^k$ (offset by 1 from the primals) is the **right** ergodic dual variable — it pairs with primal-step $(k+1)$ via the Jensen averaging, producing a Lagrangian gap that telescopes. The seemingly-mysterious term $\beta\langle B(z^k - z^{k+1}), A(x^{k+1} - \tilde x)\rangle$ in the $x$-subproblem optimality (Step 4) splits via $A(x^{k+1} - \tilde x) = r^{k+1} - d - B(z^{k+1} - \tilde z)$ into three pieces, and after polarization on the $r^{k+1}$ piece and the $B$-piece, the cross terms combine into a **perfect square** $-(\beta/2)\|s^{k+1}\|^2 \leq 0$ where $s^{k+1} = Ax^{k+1} + Bz^k - c$ is the intermediate primal residual seen by the $x$-subproblem.

### The Technique Chain
- **Augmented-Lagrangian first-order optimality** — standard Rockafellar.
- **Subgradient convexity inequalities** at test point — standard.
- **Lagged-dual averaging** $\bar\lambda_T = (1/T)\sum_{k=0}^{T-1} \lambda^k$ — non-standard "off-by-one" trick essential for clean Jensen.
- **Residual decomposition** $A(x^{k+1} - \tilde x) = r^{k+1} - d - B(z^{k+1} - \tilde z)$ — algebraic identity.
- **Two polarization identities** (dual + $B$-primal) — standard three-point identity.
- **Perfect-square absorption** of cross terms into $-(\beta/2)\|s^{k+1}\|^2$ — clever bookkeeping.
- **Jensen + telescoping** — standard ergodic analysis.

### The Construction
n/a — pure algorithmic proof.

### The Failure Modes
- **Use synchronized dual $\bar\lambda_T = (1/T)\sum_{k=1}^T \lambda^k$.** Off-by-one mismatch breaks Jensen; the gap function becomes $\bar\lambda_T \cdot r$ instead of $\lambda^k \cdot r$ inside the sum.
- **Assume $A$ or $B$ full rank.** The proof uses $\|B(\tilde z - z^k)\|^2$ as a *semi-norm*, which is OK precisely because we only need $\mathcal{E}^k \geq 0$ — no inverse needed.
- **Try to extend to infeasible test points without correction.** The $\beta\langle s^{k+1}, d\rangle$ term doesn't telescope; need to either restrict to $d=0$ or accept an extra $(\beta/2)\|d\|^2$ term.

### The Discovery Path
1. He–Yuan 2012: observe ADMM is preconditioned proximal point on a saddle-point inclusion.
2. Try to prove O(1/T) on the standard Lagrangian gap.
3. Discover that the $x$-subproblem cross term doesn't telescope unless decomposed via the residual identity.
4. Try ergodic dual $\bar\lambda_T = (1/T)\sum_{k=1}^T \lambda^k$ — Jensen mismatch.
5. Switch to lagged dual $\bar\lambda_T = (1/T)\sum_{k=0}^{T-1}\lambda^k$ — Jensen now clean.
6. Notice the Lyapunov $\mathcal{E}^k$ uses the $B$-seminorm naturally (no full-rank assumption needed).

### Transferable Patterns
- **"Lagged-iterate ergodic averaging."** When a method has primal step $k+1$ paired with dual step $k$ in the optimality conditions, the ergodic dual should average the *lagged* iterates to align with Jensen.
- **"Perfect-square absorption."** Cross terms of the form $-(\beta/2)\|a\|^2 - \beta\langle a, b\rangle - (\beta/2)\|b\|^2 = -(\beta/2)\|a+b\|^2 \leq 0$ are reusable across all primal-dual proofs.

---

## 9. ULA KL convergence under LSI (`ula-kl-convergence-lsi`)

### The Spark
**analogy-from-other-field.** Vempala–Wibisono 2019 imported the Girsanov change-of-measure technique from stochastic analysis (originally for diffusion approximations) to bound the KL divergence between the discrete-time ULA marginal and the true Langevin marginal — converting "discretization error" into a path-space KL that's directly computable.

### The Key Insight
Couple ULA and the true Langevin diffusion via the **same Brownian motion** so they share noise; then the KL between path laws is a clean Girsanov integral $(1/4)\mathbb{E}\int \|\nabla f(\tilde X_t) - \nabla f(x_k)\|^2 dt$ over the discretization interval. Decompose the marginal KL as Langevin contraction (controlled by LSI: $\mathrm{KL}(\nu_{(k+1)h}\|\pi) \leq e^{-2\alpha h}\mathrm{KL}(\rho_{kh}\|\pi)$ via de Bruijn + Grönwall) plus discretization (controlled by the Girsanov integral, bounded using $L$-smoothness and a moment estimate). The contraction $e^{-\alpha h}$ then absorbs the $\alpha h/2 \cdot \mathrm{KL}$ part of the discretization error, yielding a clean recursion $\mathrm{KL}(\rho_{(k+1)h}\|\pi) \leq e^{-\alpha h}\mathrm{KL}(\rho_{kh}\|\pi) + 2L^2 dh^2$.

### The Technique Chain
- **Synchronous coupling** of ULA and Langevin via shared Brownian motion — standard SDE coupling.
- **Girsanov's theorem** for path-KL between SDEs — classical Itô calculus, requires Novikov's condition.
- **Data-processing inequality** to descend from path-KL to marginal-KL — standard information theory.
- **De Bruijn / Fokker–Planck identity** $(d/dt)\mathrm{KL}(\mu_t\|\pi) = -\mathrm{FI}(\mu_t\|\pi)$ — classical.
- **Log-Sobolev inequality** $\mathrm{FI} \geq 2\alpha \mathrm{KL}$ + Grönwall — standard functional inequalities.
- **Integration-by-parts (Stein)** for $\mathbb{E}_\pi\|\nabla f\|^2 \leq Ld$ — standard.
- **LSI-to-gradient bound** $\mathbb{E}_\rho\|\nabla f\|^2 \leq 2Ld + 4L^2\alpha^{-1}\mathrm{KL}(\rho\|\pi)$ — Vempala–Wibisono Lemma.
- **One-step contraction + telescoping** via geometric sum — standard.

### The Construction
The synchronous-coupling construction of $(\tilde X_t, Y_t)$ is the only "construction" — but this is structural rather than adversarial. The key choice is to identify the noise: same $B_t$ in both processes makes the drift difference $\Delta_t = -\nabla f(x_k) + \nabla f(\tilde X_t)$ small (controlled by $L$-smoothness × discretization moment).

### The Failure Modes
- **Bound $W_2$ distance instead of KL.** Loses the LSI contraction structure; you'd need a Wasserstein contraction (requires log-concavity, stronger than LSI).
- **Use TV distance.** Pinsker gives $\mathrm{TV} \leq \sqrt{\mathrm{KL}/2}$ but then squaring loses a $1/2$, and you can't telescope additively.
- **Bound marginal-KL directly without coupling.** Without Girsanov, you have no handle on $\mathrm{KL}(\rho_{(k+1)h}\|\nu_{(k+1)h})$ — coupling + path-space KL is the trick that makes the discretization error computable.
- **Step-size $h > \alpha/(4L^2)$.** Discretization term overwhelms contraction; recursion blows up.

### The Discovery Path
1. Try Wasserstein analysis (Durmus–Moulines 2017) — works for log-concave but not LSI.
2. Pivot: bound KL directly. KL satisfies de Bruijn identity, LSI gives exponential decay along Langevin flow.
3. Need to compare ULA marginal $\rho_{(k+1)h}$ to true Langevin marginal $\nu_{(k+1)h}$.
4. Synchronous coupling + Girsanov → path-KL = explicit integral of drift difference squared.
5. Discretization moment bound: $\mathbb{E}\|\tilde X_t - x_k\|^2 = O(h\,d) + O(h^2 \mathbb{E}\|\nabla f(x_k)\|^2)$.
6. LSI-to-gradient bound to close the recursion: $\mathbb{E}\|\nabla f(x_k)\|^2$ bounded by $Ld + L^2\alpha^{-1}\mathrm{KL}$.
7. Choose $h \leq \alpha/(4L^2)$ so $e^{-2\alpha h} + \alpha h/2 \leq e^{-\alpha h}$, getting clean one-step recursion.
8. Telescope: $\mathrm{KL}(\rho_k\|\pi) \leq e^{-\alpha h k}\mathrm{KL}(\rho_0\|\pi) + 8hdL^2/\alpha$.

### Transferable Patterns
- **"Couple + Girsanov + data processing."** The standard template for any discrete-vs-continuous SDE comparison: synchronous coupling, Girsanov on path space, data-processing to reduce to marginals. Works for any sampling scheme (ULA, MALA, underdamped Langevin) and any contraction-style functional inequality (LSI, Poincaré, isoperimetry).
- **"Contraction-absorbs-discretization."** The trick of choosing $h$ so that $e^{-2\alpha h} + \alpha h/2 \leq e^{-\alpha h}$ — a step-size-tunable absorption — is reused throughout the sampling-rate literature (Cheng–Bartlett 2018, Chewi et al.).

---

## Cross-cutting observations

- **The 4 SHB lower-bound proofs are evolutionary variants of the same hard instance** — the Goujaud polytope-Moreau function $\psi$ — exploring different settings (restricted region, threshold characterization, interpolation regime, best iterate). Three of them (interpolation, best-iterate, restricted) are partially negative results: they restrict the OP-2 quantifier or disprove the variance term in their setting. The discovery pattern is "stress-test OP-2 against weaker noise / different iterate / smaller region", and each variant reveals a structural feature (cycle uniformity, noiseless oracle as edge case, near-perfect best-iterate test) that wasn't visible in OP-2.
- **The 4 splitting-method proofs share a 4-step template**: (1) reformulate as monotone inclusion / saddle-point, (2) derive per-step variational/subgradient inequality, (3) telescope + polarization to a Lyapunov drop, (4) Jensen on ergodic average. The proofs differ mainly in *which polarization identity* and *which Lyapunov norm* (Euclidean for DR, $\mathcal{M}$-weighted for PDHG, $z^*$- or $x^*$-anchored for DYS, $B$-seminorm + dual for ADMM).
- **The ULA proof is genuinely different in flavor** — it uses stochastic coupling and functional inequalities rather than algebraic telescoping — but shares the meta-structure of "one-step recursion that absorbs error into contraction, then geometric sum".
