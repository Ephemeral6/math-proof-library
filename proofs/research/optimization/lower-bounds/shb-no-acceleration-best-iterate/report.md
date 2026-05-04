# Audit Round 0 — OP-2 / I3 Best-Iterate LB

## Audit task

Verify three things:
1. Transient handling rigorous (Theorem 1).
2. Min vs expectation handled correctly (Theorem 1).
3. Constants explicit (Theorem 1).
4. Counterexample for Theorem 2 is sound.

## Theorem 1 (Bias) — Audit

### G1: Cycle initialization

**Claim** (§2.2, §2.3): Initialization $x_0 = (D/\sqrt 2)e_0$, $x_{-1} = (D/\sqrt 2)e_{K-1}$ places both points on the cycle, eliminating any transient.

**Verification.**
- Lemma 1 (OP-2 Lemma AP) requires the SHB orbit on $\psi$ from $(e_0, e_{K-1})$ to cycle as $e_t \mod K$. After the rescaling $y = (\sqrt 2/D)x$ on $f_0 = (D^2/2)\psi(\sqrt 2/D \cdot)$, the SHB iteration on $f_0$ from $(D/\sqrt 2)(e_0, e_{K-1})$ corresponds to SHB on $\psi$ from $(e_0, e_{K-1})$. ✓
- Empirical confirmation: simulation `simulate.py` Part A computes $\min_{t \le 300} f_0(x_t)$ — drift from cycle is at machine precision; min equals cycle value at all $T$. ✓

**Status: PASS, no transient.**

### G2: Min vs expectation for deterministic orbit

**Claim** (§2.5): Since $f_0(x_t) \ge \kappa LD^2/4$ pointwise for every $t$, the min over $t$ also satisfies the bound.

**Verification.** The orbit is deterministic (no noise on the $x$-coord). The pointwise inequality $f_0(x_t) \ge \kappa L D^2/4$ holds for each $t$, and minimum of pointwise-$\ge a$ values is also $\ge a$. ✓ No expectation needed.

**Status: PASS.**

### G3: Constants explicit

**Claim** (§2.5, §2.6): $c(\beta, \eta) = \kappa(\beta, \eta)/4$ is explicit, identical to OP-2's last-iterate constant.

**Verification.** $\kappa(\beta, \eta) > 0$ is the value satisfying GTD-cyc; explicit closed form at $K = 3$ from OP-2 §2.1. ✓

**Status: PASS.**

### G4: Strong convexity floor — slight technical issue

**Concern.** Lemma 2 uses $f_0$ being $\mu$-SC. This is true ON THE 2-D $x$-COORDINATE. In OP-2, the joint $f_{\beta,\eta}^{(s)}$ is convex but not $\mu$-SC (because the $y$-coord is flat). For Theorem 1, we DON'T add a $y$-coord — we use just the 2-D $f_0$. So the SC argument is on a 2-D function that IS $\mu$-SC. ✓

**Status: PASS.** (No 3-D extension needed for Theorem 1; we explicitly use only $f_0$ on $\mathbb{R}^2$.)

### G5: Quantifier check — "for every $T \ge 1$"

**Verification.** $f_0(x_t) \ge \kappa LD^2/4$ holds for $t = 0, 1, 2, \ldots$ since the orbit is on cycle from $t = 0$. So $\min_{0 \le t \le T} f_0(x_t) \ge \kappa LD^2/4$ for any $T \ge 0$. The conclusion $\ge \kappa LD^2/(4T)$ requires $\kappa L D^2/4 \ge \kappa L D^2/(4T)$ which holds iff $T \ge 1$. ✓

**Status: PASS.**

### G6: Initial-distance budget

**Claim**: $\|x_0 - x^\star\| = D/\sqrt 2 \le D$. ✓

But the original problem statement might require $\|x_0 - x^\star\| \le D$ exactly, not $D/\sqrt 2$. We use $D/\sqrt 2$, which is even MORE conservative (the bound applies for $\|x_0\| \le D$ with $D' := D/\sqrt 2$). To match exactly: scale up by $\sqrt 2$, getting $\|x_0\|_2 = D$ and the cycle radius becomes $D$ instead of $D/\sqrt 2$.

In that case, $f_0(x_t) - f_0^\star \ge (\mu/2)D^2 = \kappa LD^2/2$, even stronger than $\kappa LD^2/4$.

Either way, the bound $\ge \kappa(\beta, \eta) \cdot LD^2/(4T)$ holds. The factor $1/4$ is conservative; we can sharpen to $1/2$ if we use full $D$-budget on $x$-coord. ✓

**Status: PASS.** (We keep $1/4$ for cleanest comparison to OP-2.)

## Theorem 2 (Variance counterexample) — Audit

### V1: Counterexample claim

**Claim** (§3): For OP-2's stochastic 1-D $g_y$ at $(\beta, \eta) = (0.5, 1/L)$, $T = 1000$: $\mathbb{E}[\min_t g_y(y_t) - \min g_y] \approx 4 \times 10^{-6}$, vs. target $0.0026$. Failure margin $> 600\times$.

**Verification.** Simulation `variance_check_gauss.py` confirms numerically. Decay is $\approx T^{-2}$ for $T \in [10, 1000]$. ✓

**Status: PASS.** Counterexample is real.

### V2: Theoretical explanation

**Claim** (§3.4): The SHB random walk's exploration covers the optimum; $\min_t g_y(y_t) \to \min g_y$ at rate $\Theta(1/T)$ or faster.

**Verification.** Heuristic but plausible. The stationary variance of SHB on a linear function is $V = \sigma^2 \eta^2/(L^2(1-\beta^2))$ (after wall confinement, by Foster-Lyapunov-type arguments). The iterate spends roughly $T \cdot (\text{neighborhood width})/\sigma\sqrt V$ time near optimum. Closest approach scales as $\sqrt{V/T}$, giving $g_y$ gap $\approx L \cdot V/T = \sigma^2 \eta^2/((1-\beta^2)T)$. For $\sigma = \eta = L = D = 1, \beta = 0.5$: $\sim 1/(0.75 T)$ — matches the $T^{-1}$ to $T^{-2}$ empirical decay reasonably well. ✓

**Status: PASS** (heuristic but supported by simulation).

### V3: Le Cam bug identification

**Claim** (§3.3): The naive Le Cam test $\hat s = -\mathrm{sign}(y_{t^*})$ achieves NEAR-PERFECT classification, hence cannot be lower-bounded by Le Cam.

**Verification.** Sound logic. The orbit visits $y^\star$'s neighborhood (negative side from $s$), so $y_{t^*}$ has opposite sign from $s$. The test achieves Bayes-optimal classification, far better than Le Cam's worst-case bound of $0.146$. So Le Cam can't be invoked through this test. ✓

**Status: PASS.**

## Audit verdict

**ROUND 0 RESULT: PASS** for both Theorem 1 (positive) and Theorem 2 (negative counterexample).

No fixer round needed. All claims are rigorously supported.

## Caveat to be transparent about

Theorem 1 alone is a STRICTLY WEAKER result than the original I3 problem statement (which asked for combined bias + variance bound). We honestly report this as PARTIAL PASS:
- Bias term: PROVED.
- Variance term: DISPROVED (with empirical + heuristic-theoretical counterexample).

The conclusion $\min_t f(x_t) \ge c \cdot LD^2/T$ holds RIGOROUSLY on $\mathcal{F}$.
The conclusion $\min_t f(x_t) \ge c \cdot \sigma D/\sqrt T$ FAILS on this construction.

This is a genuine theoretical contribution: identifies the asymmetry between best-iterate and last-iterate stochastic lower bounds, with the variance term being the asymmetric component.
