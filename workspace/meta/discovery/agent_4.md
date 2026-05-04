# Discovery Agent 4 Report — Variance Reduction + Adaptive Methods

Analyzing 7 proofs across the SPIDER/SARAH/STORM/PAGE family (variance reduction) and the Adam/AMSGrad/AdaGrad-Norm family (adaptive methods). The two families form coherent narrative arcs: VR is driven by chasing the $\sqrt{n}/\epsilon^2$ lower bound; adaptive methods are driven by patching successive failures of correlation control between gradients and the adaptive denominator.

---

## Proof 1: SPIDER Nonconvex Gradient Complexity ($O(n + \sqrt{n}/\epsilon^2)$)

### 1. The Spark
**gap-in-literature** — SVRG-style variance reduction had stalled at $O(n^{2/3}/\epsilon^2)$ for nonconvex finite sums; the gap to the conjectured $\sqrt{n}/\epsilon^2$ lower bound demanded a new estimator.

### 2. The Key Insight
Replace SVRG's "snapshot reset every $q$ steps" with a *recursive* gradient correction $v_{t+1} = v_t + \frac{1}{b}\sum_i[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)]$ so the error process becomes a martingale ($e_{t+1} = e_t + \delta_{t+1}$ with zero-mean increments). This converts variance growth from independent-sample-noise scale ($O(\sigma^2)$ per step) to displacement-scaled noise ($O(L^2\eta^2 \|v_t\|^2/b)$). The leap is recognizing that the descent lemma's "wasted" $-\eta(1-L\eta)/2 \|v_t\|^2$ term, exposed via the polarization identity, can absorb exactly this displacement variance.

### 3. The Technique Chain
- **Recursive estimator** (SARAH 2017, Nguyen et al.) — non-standard at the time; SPIDER inherits and re-analyzes.
- **Polarization identity** $\langle\nabla f, v\rangle = \tfrac12(\|v\|^2 + \|\nabla f\|^2 - \|e\|^2)$ — standard linear algebra, non-standard *use*: replaces the lossy Young's inequality.
- **Martingale variance recursion** — standard probability tool.
- **Epoch telescoping** — standard from SVRG.

### 4. The Construction
*N/A — no hard instance constructed; this is an algorithm/upper-bound proof.*

### 5. The Failure Modes
- **Young's inequality on $\langle\nabla f, e\rangle$**: discards the negative $\|v\|^2$ term, forcing a self-bounding argument that costs $\sqrt q$ and yields only $n^{3/4}$.
- **Standard variance bound $\mathbb{E}\|v_t - \nabla f\|^2 \le \sigma^2$**: ignores the recursive structure, gives SGD's $1/\epsilon^4$.

### 6. The Discovery Path
1. Observe: SVRG hits $n^{2/3}$ wall; lower bound says $\sqrt n$ should be possible.
2. Try: standard SVRG analysis with smaller step or larger batch — coefficients don't close.
3. Insight: SARAH's recursive estimator gives a martingale error; coupled with polarization rather than Young, the descent lemma's $\|v\|^2$ term *exactly* cancels the variance.
4. Execute: pick $\eta = 1/(2L)$, $b = q = \sqrt n$ so the absorption coefficient $\gamma = 1 - L\eta - L^2\eta^2 q/b = 1/4 > 0$.
5. Verify: cost $K \cdot 2n = O(\sqrt n / \epsilon^2 \cdot n) \cdot n^{-1/2}$ matches the Fang et al. lower bound — tight.

### 7. Transferable Patterns
- **Polarization-over-Young** template: whenever a descent lemma produces $-\|v\|^2$, never bound the cross-term with Young; expose the negative term via polarization and use it as a free absorber.
- **Recursive (vs reset) estimators**: trade snapshot cost for martingale structure when individual $L$-smoothness is available.

---

## Proof 2: SPIDER/SARAH Variance Reduction Nonconvex (sibling proof)

### 1. The Spark
**pattern-spotted** — Same $\sqrt n$ rate as Proof 1, but reached via the *Young + self-bounding* path, suggesting an alternative pedagogy where polarization is not invoked.

### 2. The Key Insight
The variance-absorption inequality $V \le 2L^2\eta^2 q (G + V)$ is a *self-bounding* recursion: when $2L^2\eta^2 q \le 1/2$, one rearranges to $V \le 4L^2\eta^2 q\, G$, so the variance becomes a constant-multiple of the gradient sum and can be paid for from the descent. The leap is choosing the step size $\eta = \Theta(1/(L\sqrt q))$ small enough to make $2L^2\eta^2 q$ a small constant — this *intentional shrinkage* of the step is what differentiates SARAH-style analysis from SPIDER's bigger-step polarization.

### 3. The Technique Chain
- **SARAH recursive estimator** — same as Proof 1.
- **Young's inequality + $\|a+b\|^2 \le 2\|a\|^2 + 2\|b\|^2$** — standard, accepted as lossy here.
- **Self-bounding rearrangement** — non-standard meta-move (variance bound feeding back on itself).
- **Epoch telescoping with tower property** — standard.

### 4. The Construction
*N/A.*

### 5. The Failure Modes
- **Step too large**: $2L^2\eta^2 q > 1/2$ breaks the self-bounding rearrangement (denominator $\to 0$); the rate explodes.
- **Skipping epoch resets**: without periodic full-gradient $v_0 = \nabla f(x_0)$, the variance recursion has no anchor and grows unboundedly.

### 6. The Discovery Path
1. Observe: SARAH (Nguyen 2017) recursive estimator works in convex; want nonconvex extension.
2. Try: directly bound $\sum \|e_t\|^2$ — get a coupled inequality involving itself.
3. Insight: rearrange the coupling — solve $V \le c(G+V)$ for $V$ when $c < 1$.
4. Execute: tune $\eta = 1/(10L\sqrt q)$, $q = \sqrt n$ to clear all conditions simultaneously.
5. Verify: same total complexity $O(n + \sqrt n / \epsilon^2)$ as Proof 1, via different bookkeeping.

### 7. Transferable Patterns
- **Self-bounding inequalities**: when an error bound recursively refers to the quantity being bounded, isolate-and-divide is often cleaner than telescoping.
- **Step-size as condition-enforcer**: pick $\eta$ to satisfy *all* coefficient inequalities at once, not just descent.

**Discovery-angle difference vs Proof 1**: Proof 1 uses *polarization* to expose a free negative term (no step shrinkage needed); Proof 2 uses *Young + self-bounding* (forced to shrink $\eta$). They reach the same rate but via complementary technique families.

---

## Proof 3: STORM Nonconvex Convergence ($O(\sigma^2/\epsilon^3)$)

### 1. The Spark
**failure-of-natural-approach** — SPIDER requires knowing $n$ (epoch length is $\sqrt n$) and periodic full gradients; in the streaming/online setting these are unavailable. Can we get the same rate *single-loop, parameter-free*?

### 2. The Key Insight
Replace SPIDER's hard reset with a *soft* exponential-moving-average reset: $d_t = (1-a) d_{t-1} + \nabla f(x_t;\xi_t) - (1-a)\nabla f(x_{t-1};\xi_t)$. The variance recursion becomes $\mathbb{E}\|e_t\|^2 \le (1-a)\|e_{t-1}\|^2 + 2L^2\eta^2\|d_{t-1}\|^2 + 2a^2\sigma^2$ — a contraction with a residual noise floor $\Theta(a^2\sigma^2)$. The Lyapunov function $\Phi_t = f(x_t) + \frac{\eta}{2a}\|e_t\|^2$ with the *exact* coupling constant $c = \eta/(2a)$ makes the error coefficient $ca - \eta/2$ vanish identically — that's the magic.

### 3. The Technique Chain
- **Momentum-form variance reduction** — STORM's signature, novel in 2019 (Cutkosky-Orabona).
- **Polarization identity** — borrowed from SPIDER (Proof 1).
- **Lyapunov coupling with surgically-chosen $c$** — standard technique, surgical use.
- **Mini-batch initialization** ($B = \sigma/\epsilon$) — added in fix to absorb the $\sigma^4/\epsilon^4$ initialization tail.

### 4. The Construction
*N/A.*

### 5. The Failure Modes
- **Single-sample initialization** $d_0 = \nabla f(x_0;\xi_0)$ creates a one-time error of $\sigma^2$ that requires $T = \sigma^4/\epsilon^4$ steps to wash out — the fix is mini-batch warmup.
- **Choosing $c$ generically**: any $c \neq \eta/(2a)$ leaves a residual $\|e_t\|^2$ term that must be controlled by extra inequalities, blowing the constants.

### 6. The Discovery Path
1. Observe: SPIDER's epoch structure is artificial; momentum gives the same effect smoothly.
2. Try: just take SPIDER's variance recursion and set "epoch length = $1/a$" — works dimensionally but boundary terms don't telescope.
3. Insight: build a Lyapunov $f + c\|e\|^2$ where $c$ is chosen to *exactly* zero out the error coefficient.
4. Execute: balance $a = \epsilon^2/(6\sigma^2)$, $\eta = \epsilon/(2L\sqrt 6 \sigma)$ to make all three error terms equal to $\epsilon^2/3$.
5. Verify: total $O(\sigma^2/\epsilon^3)$ matches the Arjevani-Carmon lower bound for online stochastic nonconvex.

### 7. Transferable Patterns
- **Soft resets via EMA** instead of hard epoch resets — converts batched algorithms into single-loop streaming algorithms while preserving rates.
- **Lyapunov with exact-cancellation coupling**: pick the coupling constant by solving the algebraic equation that makes one inequality tight.

---

## Proof 4: PAGE Optimal Gradient Complexity ($O(n + \sqrt n/\epsilon^2)$)

### 1. The Spark
**pattern-spotted** — SPIDER (deterministic epochs) and STORM (momentum) achieve optimality but with different machinery; can a *probabilistic* mixing of the two unify them?

### 2. The Key Insight
Flip a Bernoulli($p$) coin at each step: with probability $p$ do a full reset (SPIDER's epoch boundary), else apply SPIDER's correction. The expected estimator error then satisfies $V_{t+1} \le (1-p) V_t + \frac{L^2\eta^2}{b'}\mathbb{E}\|g_t\|^2$ — a *clean geometric recursion* (no epoch boundaries to chase). Unrolling and swapping summation gives $\mathcal V \le \frac{L^2\eta^2}{p b'} \mathcal H$, where $1/p = \sqrt n$ is exactly the effective horizon.

### 3. The Technique Chain
- **Probabilistic reset** — PAGE's innovation (Li et al. 2021).
- **Geometric series unrolling** — standard.
- **Polarization** — borrowed from SPIDER.
- **Self-absorption via descent** — same template as SPIDER but without epoch bookkeeping.

### 4. The Construction
*N/A.*

### 5. The Failure Modes
- **Trying to telescope by epoch**: there are no epochs — the natural attempt fails because reset times are random.
- **Bounding $V_t$ by $\sigma^2$ uniformly**: ignores the geometric decay structure and recovers only SGD's rate.

### 6. The Discovery Path
1. Observe: SPIDER's $q = \sqrt n$ epoch length is precisely where reset cost equals correction cost; what if we randomize?
2. Try: set reset probability $p = 1/q = 1/\sqrt n$, hope it works in expectation.
3. Insight: the variance recursion now has a clean $(1-p)$ contraction — geometric series sum is $1/p$, recovering the $\sqrt n$ horizon naturally.
4. Execute: same descent lemma + polarization absorption as SPIDER, but with the unrolled formula instead of epoch telescoping.
5. Verify: per-step cost $p\cdot n + (1-p)\cdot b' = O(\sqrt n)$, total $O(n + \sqrt n/\epsilon^2)$ — same as SPIDER, simpler proof.

### 7. Transferable Patterns
- **Randomization-as-simplification**: replace deterministic schedules with Bernoulli coin flips; the resulting recursions are often cleaner because they kill boundary conditions.
- **Geometric-recursion = effective-horizon $1/p$**: a useful mental model for tuning probabilistic algorithms.

---

## Proof 5: Adam Nonconvex Convergence ($O(d \log T / \sqrt T)$)

### 1. The Spark
**failure-of-natural-approach** — Reddi et al. (2018) showed Adam can *diverge* on convex problems; the community needed conditions under which it nonetheless converges in nonconvex settings.

### 2. The Key Insight
Under $\beta_1^2 \le \beta_2$, Jensen's inequality gives $[\hat m_t]_i^2 \le [\hat v_t]_i$ coordinate-wise, so the preconditioned step satisfies $|[D_t]_i| \le 1$ and $\|D_t\|^2 \le d$. This is the dimension-factor's origin. Combined with the polarization identity on the inner product $\langle g_t, D_t\rangle$ — bounding it below by gradient signal minus momentum-error — and a horizon-dependent learning rate $\alpha_t = \alpha_0 t^{-1/2} T^{-1/4}$, the momentum bias gets absorbed into the rate.

### 3. The Technique Chain
- **EMA weight comparison** $p_s \le q_s$ under $\beta_1^2 \le \beta_2$ (Reddi 2018).
- **Polarization** $ab = \tfrac{a^2 c + b^2/c}{2} - \tfrac{(ac-b)^2}{2c}$ — standard, used here per-coordinate.
- **Momentum path-length bound** via $L$-smoothness: $\|g_t - \hat m_t\|^2 \le L^2 d \alpha^2 \beta_1 \log T / (1-\beta_1)^2$.
- **Horizon-dependent step** $\alpha = \alpha_0 T^{-1/4}$ — non-standard, forced by needing to balance the momentum-bias term.

### 4. The Construction
*N/A.*

### 5. The Failure Modes
- **Treating $D_t$ as bounded by $G/\epsilon$ uniformly**: gives a $d/\epsilon^2$ factor instead of $d$, and ruins the dimension dependence.
- **Skipping $\beta_1^2 \le \beta_2$**: without it, $\hat m_t$ can outrun $\sqrt{\hat v_t}$ along bursts, and Adam diverges (Reddi's counterexample).

### 6. The Discovery Path
1. Observe (Reddi 2018): Adam diverges on simple problems; AMSGrad fixes via $\hat v_t = \max$.
2. Question: does the original Adam converge under *some* nonconvex condition?
3. Insight: Jensen's inequality on EMA weights gives $\hat m^2 \le \hat v$ iff $\beta_1^2 \le \beta_2$ — a clean sufficient condition.
4. Execute: descent lemma, bound $\|D_t\|^2 \le d$, polarize the inner product, control momentum lag.
5. Verify: rate $d \log T / \sqrt T$ — slower than SGD by $\log T$, the price of adaptivity; matches Zhou-Tang-Zhou-Cao-Yan-Gu (2018).

### 7. Transferable Patterns
- **Jensen-on-EMA-weights**: when comparing momentum and second-moment EMAs, the weight-domination $p_s \le q_s$ unlocks $\hat m^2 \le \hat v$ pointwise.
- **Horizon-dependent step**: when a non-vanishing bias term appears, set $\alpha = \alpha_0 T^{-\beta}$ to force vanishing.

---

## Proof 6: AMSGrad Nonconvex Convergence ($O(1/\sqrt T)$ + non-vanishing bias)

### 1. The Spark
**failure-of-natural-approach** — Adam's analysis breaks because the denominator $\sqrt{v_t}$ is correlated with the numerator $g_t$. AMSGrad (Reddi 2018) introduced $\hat v_t = \max(\hat v_{t-1}, v_t)$ specifically to make the denominator monotone — does this fix enable a clean nonconvex proof?

### 2. The Key Insight
The "$\hat v_{t-1}$ trick": split the noise cross-term $B_t = \sum_i \nabla f_i \xi_{t,i} / (\sqrt{\hat v_t} + \epsilon)$ as $B_t^{\text{main}}$ (with denominator $\sqrt{\hat v_{t-1}}$, predictable, hence zero conditional mean) plus $B_t^{\text{corr}}$ (small because $\hat v_t - \hat v_{t-1} \le (1-\beta_2) G^2$ and $\sqrt{a+c} - \sqrt a \le \sqrt c$). The leap is recognizing that AMSGrad's monotonicity gives a *quantitative* upper bound on the perturbation when sliding the denominator's time index back by one.

### 3. The Technique Chain
- **Coordinate-wise descent lemma** — standard.
- **Decompose $m_t$** into gradient + noise + momentum components — standard.
- **Predictable surrogate trick** ($\hat v_{t-1}$ in place of $\hat v_t$) — non-standard, AMSGrad-specific.
- **$\sqrt{a+c} - \sqrt a \le \sqrt c$** — elementary but key for the correction bound.
- **Monotonicity of $\hat v_t$** — Reddi 2018.

### 4. The Construction
*N/A.*

### 5. The Failure Modes
- **Use $\hat v_t$ in the cross-term**: $\hat v_t$ depends on $g_t$, so $\mathbb{E}[B_t | \mathcal F_{t-1}] \neq 0$ and the noise term doesn't vanish.
- **Naive $a \le |a|$**: a textbook student would write $a/(\sqrt{\hat v}+\epsilon) \ge a/(G+\epsilon)$, which fails for $a < 0$ — this was actually caught in audit Round 1.

### 6. The Discovery Path
1. Observe: Adam's denominator is non-predictable, killing martingale arguments.
2. Try: use $\hat v_t$ directly — cross-term doesn't vanish.
3. Insight: shift the denominator's time index back by one ($\hat v_{t-1}$ is predictable!) and bound the correction using monotonicity + $\sqrt{\cdot}$ subadditivity.
4. Execute: descent lemma, bound $\|D_t\|^2$, decompose $\langle\nabla f, D_t\rangle$ into gradient signal + noise (zero mean) + correction (small) + momentum lag.
5. Verify: $1/\sqrt T$ rate plus a *non-vanishing* momentum-bias term proportional to $\beta_1/(1-\beta_1)$ — honest disclosure that Adam-family methods carry irreducible bias.

### 7. Transferable Patterns
- **Predictable-surrogate trick**: when the natural denominator depends on the current sample, replace it with the previous step's value (predictable) and bound the correction via monotonicity.
- **Honest non-vanishing terms**: in adaptive method analysis, accept bias terms rather than forcing them to vanish via assumption-stacking.

---

## Proof 7: AdaGrad-Norm Nonconvex Convergence ($O(\log T / \sqrt T)$)

### 1. The Spark
**question-asked** — AdaGrad has a well-known regret bound for online convex; what's the right analog for *non-convex* SGD with the *scalar* (norm) variant?

### 2. The Key Insight
Two clean technical moves. (a) The decoupling identity $\frac{1}{b_k^2} - \frac{1}{b_{k+1}^2} = \frac{\|g_k\|^2}{b_k^2 b_{k+1}^2}$ converts the un-summable $\sum \|g_k\|^2/b_k^2$ (where $b_k$ is *not* predictable w.r.t. $g_k$) into the summable $\sum \|g_k\|^2/b_{k+1}^2$ plus a small correction. (b) Because the AdaGrad-Norm step $\eta/b_k$ uses *only the past* (scalar $b_k$ depends on $g_0, \ldots, g_{k-1}$), the noise cross-term $\langle \nabla f_k, \xi_k\rangle / b_k$ is *exactly* a martingale increment — no surrogate trick needed (unlike AMSGrad).

### 3. The Technique Chain
- **Adaptive descent lemma** with step $\eta/b_k$ — standard with care.
- **Log accumulator** $\sum a_k^2/B_{k+1}^2 \le \log(B_T^2/B_0^2)$ via integral comparison (monotone $1/u$) — folklore from AdaGrad regret proofs.
- **Algebraic decoupling identity** — non-standard; unique to the *Norm* variant.
- **Almost-sure envelope** $b_T \le b_0 + M\sqrt T$ — replaces high-probability arguments with clean deterministic bound.
- **Cauchy-Schwarz / Jensen pass-through** to convert $\sum \|\nabla f_k\|^2/b_k$ into $\sum \|\nabla f_k\|^2 / b_T$ — standard.

### 4. The Construction
*N/A.*

### 5. The Failure Modes
- **Treating $b_k$ as predictable for $g_k$**: it's not — $b_{k+1}$ depends on $g_k$. A naive student would conflate $b_k$ and $b_{k+1}$.
- **Directly bounding $\sum \|g_k\|^2/b_k^2$ by integral test**: fails because the integrand is evaluated at the wrong endpoint ($b_k$, not $b_{k+1}$); off-by-one shifts ruin the log bound.
- **Using only $b_T \ge b_0$**: gives the trivial SGD rate without the adaptive log-improvement.

### 6. The Discovery Path
1. Observe: AdaGrad regret in convex case uses log-accumulator easily; what's the nonconvex analog?
2. Try: descent lemma → cross-term $\langle \nabla f, g\rangle / b_k$ is a martingale increment (good) → quadratic $\|g\|^2/b_k^2$ is *not* directly summable (bad, off-by-one).
3. Insight: the algebraic identity $1/b_k^2 - 1/b_{k+1}^2 = \|g_k\|^2/(b_k^2 b_{k+1}^2)$ shifts the index by one for free, yielding a summable form plus a controllable correction.
4. Execute: log accumulator + envelope $b_T \le b_0 + M\sqrt T$ + Cauchy-Schwarz to assemble the rate.
5. Verify: $C \log T / \sqrt T$ with explicit, polynomial-in-parameters $C$. Matches Ward-Wu-Bottou (2019).

### 7. Transferable Patterns
- **Algebraic index-shifting via telescoping identities**: when a sum $\sum a_k/B_k$ is un-summable due to predictability issues, exploit $1/B_k - 1/B_{k+1}$ to create a summable surrogate.
- **A.s. envelopes over high-probability**: when an upper-bound increment is bounded a.s., use deterministic envelope arithmetic rather than martingale concentration — cleaner constants.

---

## Cross-cutting observation

The variance-reduction quartet (SPIDER → SPIDER/SARAH → STORM → PAGE) is a **sequence of "remove the inconvenience" simplifications** of the same core mechanism (recursive estimator + descent absorption): SPIDER needs deterministic epochs (inconvenient if $n$ unknown); STORM removes them via momentum (inconvenient because of EMA mini-batch warmup); PAGE replaces both by a single Bernoulli coin (cleanest analysis). Meanwhile the adaptive trio (Adam → AMSGrad → AdaGrad-Norm) is a **sequence of "fix the correlation problem"** between gradient and adaptive denominator: Adam needs $\beta_1^2 \le \beta_2$ + horizon-dependent step (stacks assumptions); AMSGrad uses $\hat v_{t-1}$ surrogate trick (specific algebraic move); AdaGrad-Norm has a scalar predictable $b_k$ so the cross-term is *automatically* zero-mean (the architecture solves the problem upstream). In both arcs, the discovery direction is **algorithm-design-as-proof-simplification**: the cleaner the algorithm, the cleaner the analysis — a meta-pattern worth internalizing.
