# Discovery Agent 3 Report — Optimization/Stochastic Part 1

Analyzes 7 stochastic-optimization proofs to reverse-engineer the original human discovery path.

---

## 1. SPS-SGD Convergence Rate

### 1. The Spark
**pattern-spotted** — Someone noticed that the Polyak step size $\gamma = (f(x)-f^*)/\|\nabla f(x)\|^2$ used in deterministic GD has a stochastic analog $f_i(x_k)/\|\nabla f_i(x_k)\|^2$ that is **computable** precisely when $f_i^* = 0$ (interpolation), and asked: does it converge?

### 2. The Key Insight
The SPS substitution makes a magical simplification appear: $\gamma_k^2 \|\nabla f_{i_k}\|^2 = \gamma_k f_{i_k}/c$ — the quadratic penalty term in the squared-distance recursion becomes linear in $f_{i_k}$ matching the descent term. This collapses the recursion to $\|x_{k+1}-x^*\|^2 \le \|x_k-x^*\|^2 - \gamma_k f_{i_k}(x_k)$. The leap is recognizing that the SPS *self-tunes* so this cancellation is automatic — no a-priori smoothness knowledge is required for this step. Brute-force step-size scheduling could not find this; it requires writing out the recursion symbolically with the SPS form already substituted.

### 3. The Technique Chain
- Squared-distance expansion: standard, intro stochastic optimization.
- Convexity inner-product bound + interpolation $f_i(x^*)=0$: standard.
- Smoothness gradient-domination $\|\nabla f_i\|^2 \le 2L f_i$: standard (textbook).
- Substitution of the *specific* SPS form to enable cancellation: non-standard, this is the SPS paper's contribution (Loizou et al. 2021).
- Telescoping + Jensen: standard.

### 4. The Construction
Skip — no construction; the SPS step size *is* the construction.

### 5. The Failure Modes
- **Constant step size $\gamma$**: classical SGD analysis gives $O(1/\sqrt{T})$ even under interpolation unless $\gamma$ is precisely $1/L$ (which requires knowing $L$).
- **Original Polyak step $f(x)/\|\nabla f(x)\|^2$**: requires knowing $f^*$, not stochastic-friendly.
- **Trying to bound $\gamma_k$ before substituting**: leads to messy adaptive analyses; the trick is to substitute symbolically *first*, then bound at the end.

### 6. The Discovery Path
1. Observation: deterministic Polyak step works beautifully when $f^*$ is known.
2. First attempt: replace $f$ with $f_i$ blindly — but how to bound the rate?
3. Insight: under interpolation $f_i(x^*)=0$, so the step size $f_i(x)/\|\nabla f_i\|^2$ is computable AND becomes a magnitude that matches the convexity bound exactly.
4. Algebra: write out $\|x_{k+1}-x^*\|^2$, substitute SPS, watch terms cancel; lower-bound $\gamma_k$ via smoothness only at the very end.
5. Polish: telescope and Jensen for the average iterate.

### 7. Transferable Patterns
- **Self-tuning step sizes that produce algebraic cancellations**: the structural template "choose $\gamma_k$ so that $\gamma_k^2\|g\|^2 = \gamma_k \cdot (\text{descent}) /c$" generalizes to AdaGrad-style and adaptive methods.
- **Interpolation as a noise-killer at the optimum**: lets per-component bounds act as if they were full-gradient bounds.

---

## 2. Clipped SGD under Heavy-Tailed Noise

### 1. The Spark
**failure-of-natural-approach** — Standard SGD analysis requires bounded variance ($p=2$); when noise has only $p < 2$ moments, the descent lemma blows up, prompting the question "what does the right rate look like?"

### 2. The Key Insight
Replace the natural target $\|\nabla_t\|^2$ with a **truncated surrogate** $\phi_t = \min(\|\nabla_t\|^2, \tau\|\nabla_t\|)$, which is exactly the quantity that descent-of-clipped-step gives you for free in both regimes (gradient small / gradient large). Then recover $\|\nabla_t\|^2 = \phi_t + \|\nabla_t\|(\|\nabla_t\|-\tau)_+$ by a *separate* telescoping for the excess term, which only fires when $\|\nabla_t\| > \tau \ge 2\sigma$ — and that's exactly when a strictly negative term $-\eta\|\nabla_t\|(\|\nabla_t\|-\sigma)$ can be safely dropped. The two-stage decomposition is the non-obvious move: most analyses try to bound $\|\nabla_t\|^2$ directly and get stuck on the clipping bias.

### 3. The Technique Chain
- Smoothness descent lemma: standard.
- Clipping bias decomposition $g_t - c_t = g_t(1-\tau/\|g_t\|)_+$: standard, from Zhang et al. 2020 / Gorbunov et al. 2020.
- Sub-additivity $(a+b)_+ \le a_+ + b$: elementary, ad-hoc lemma.
- Jensen $\mathbb{E}\|\xi\| \le (\mathbb{E}\|\xi\|^p)^{1/p}$ for $p \ge 1$: standard.
- Surrogate $\phi_t$ + Young + case split: non-standard, the proof's main creative move.
- Two-stage telescoping (one for $\phi_t$, one for excess): non-standard.
- Parameter tuning $\tau = \sigma T^{1/p-1/2}$, $\eta = \sqrt{\Delta_f/L}/(\tau\sqrt{T})$: AM-GM trade-off, standard once the bound is in place.

### 4. The Construction
The choice $\tau \ge 2\sigma$ is forced: any smaller and the excess term cannot be controlled (the "$\|\nabla_t\| > \sigma$" inequality used to drop the negative term breaks). The schedule $\tau = \sigma T^{1/p-1/2}$ is forced by balancing the three terms $\Delta_f/(\eta T)$, $\sigma^2$, $L\eta\tau^2$.

### 5. The Failure Modes
- **No clipping**: under $p<2$ noise, $\mathbb{E}\|g_t\|^2 = \infty$, descent lemma immediately fails.
- **Clip but bound $\|\nabla_t\|^2$ directly**: the clipping bias $\|\nabla_t\|(\|g_t\|-\tau)_+$ does not telescope cleanly without the case split on $\|\nabla_t\|$ vs $\tau$.
- **Use a single Lyapunov function**: the $\phi_t$ surrogate is genuinely needed because gradient magnitude relative to the clipping threshold changes the regime.

### 6. The Discovery Path
1. Observation: SGD diverges in expectation under heavy tails; clipping is needed.
2. First attempt: write descent lemma, get $-\eta\langle\nabla_t, c_t\rangle$ — bias term $\langle\nabla_t, g_t-c_t\rangle$ resists Cauchy-Schwarz alone.
3. Insight: instead of bounding $\|\nabla_t\|^2$ directly, define $\phi_t$ that the clipped descent naturally controls, and recover the rest separately.
4. Execute case split: small gradient (Young absorbs $\sigma\|\nabla_t\|$) vs large gradient ($\tau \ge 2\sigma$ kills the residual).
5. Tune $\tau, \eta$ by AM-GM, verify rate matches the lower bound from Zhang et al.

### 7. Transferable Patterns
- **Surrogate-then-recover**: when the natural quantity is unbounded, prove a bound on a truncated version, then recover the original via a *separate* telescope of the excess.
- **Conservative threshold $\tau \ge 2\sigma$**: a small constant slack creates a strict inequality that lets you drop a negative term — used widely in clipped/normalized methods.

---

## 3. SGD under PL + Interpolation with Iterate Averaging

### 1. The Spark
**gap-in-literature** — PL-SGD with strong growth gives linear rate $(1-\mu/(\rho L))^t$, but the per-iterate rate doesn't show how Polyak-Ruppert averaging interacts. Question: does averaging give an *additional* polynomial speedup like in classical Robbins-Monro?

### 2. The Key Insight
Under interpolation + strong growth + PL + decreasing step size $\gamma_t = 2/(\mu(t+t_0))$, the per-iterate function gap $e_t$ satisfies a *quadratic* induction $e_t \le t_0^2/(t+t_0)^2 \cdot e_0$ — i.e., $O(1/t^2)$ per-iterate, much stronger than the usual $O(1/t)$. The reason: under interpolation, variance is $\propto \|\nabla f\|^2$ (multiplicative, no additive floor), so the recursion $\alpha_t = 1 - 2\mu\gamma_t + \rho L \mu \gamma_t^2$ has both the $\Theta(1/t)$ and $\Theta(1/t^2)$ terms aligned to permit a quadratic-decay solution.

### 3. The Technique Chain
- Smoothness descent + strong growth: standard (Vaswani et al. 2019).
- PL ($\|\nabla f\|^2 \ge 2\mu(f-f^*)$): standard.
- One-step recursion $e_{t+1} \le \alpha_t e_t$: standard manipulation.
- Polynomial induction with explicit cubic $P(s) \ge 0$ verification: standard but tedious; the *form* $t_0^2/(t+t_0)^2$ is non-standard — most PL analyses use $1/(t+t_0)$.
- Jensen-via-convexity for averaging: standard.
- Integral comparison $\sum 1/(t+t_0)^2 \le 2/t_0$: standard.

### 4. The Construction
The step size $\gamma_t = 2/(\mu(t+t_0))$ with $t_0 = 2\rho L/\mu$ is forced: $t_0$ must be large enough that the descent step $1 - \rho L \gamma_t / 2 > 0$ throughout, and the leading constants of $\alpha_t$ must align so the quadratic ansatz $e_t \le t_0^2/(t+t_0)^2 e_0$ closes the induction.

### 5. The Failure Modes
- **Use $\gamma_t = 1/(t+t_0)$**: gives only $O(1/t)$ — misses the multiplicative structure.
- **Skip averaging**: per-iterate $1/t^2$ is already strong, but averaging with convexity is the standard final touch — if you skip it you don't get the function-value bound.
- **Try classical Robbins-Monro analysis**: assumes additive noise, doesn't recognize the multiplicative structure.

### 6. The Discovery Path
1. Observation: SGD-PL with constant step gives geometric, but practitioners use decreasing steps.
2. First attempt: $\gamma_t = 1/t$, get $O(1/t)$ per iterate via standard argument — but does averaging help?
3. Insight: under interpolation the noise vanishes at $x^*$, so the recursion supports a faster polynomial ansatz; try $e_t \le C/t^2$.
4. Verify induction by reducing to polynomial inequality $P(s) \ge 0$ for $s \ge t_0$.
5. Apply convexity + Jensen to convert per-iterate to averaged bound; integral-bound the sum.

### 7. Transferable Patterns
- **Quadratic induction for SGD with multiplicative noise**: the ansatz $e_t \le C/(t+t_0)^2$ is the right template whenever variance is $\propto \|\nabla f\|^2$ (interpolation/strong growth).
- **Two-phase rates (linear then polynomial)**: pair geometric-burn-in with polynomial-decay step size to mix benefits.

---

## 4. Momentum SGD Interpolation — Linear Convergence (variant 1)

### 1. The Spark
**gap-in-literature** — Vanilla SGD under interpolation has linear rate $1 - O(1/\kappa)$ (Vaswani et al. 2019). Adding Polyak momentum is a popular practical choice — does it provably preserve this rate, or even accelerate?

### 2. The Key Insight
Set up a $2 \times 2$ recursion on $(\mathbb{E}\|x_t-x^*\|^2, \mathbb{E}\|\gamma v_t\|^2)$ in **scaled coordinates** $s_t = \gamma v_t$, then certify spectral radius $< 1$ by a Perron-Frobenius positive Lyapunov vector $(1, c)$ rather than computing eigenvalues. The non-obvious move is choosing $c = 1/\kappa^2$ — large enough to absorb cross-terms, small enough to preserve $\rho < 1$. Setting $\beta = O(1/\kappa^2)$ (much smaller than the textbook heavy-ball $\beta = ((\sqrt\kappa-1)/(\sqrt\kappa+1))^2$) is the price of the simple Lyapunov.

### 3. The Technique Chain
- Co-coercivity per component + interpolation gives $\mathbb{E}_i\|\nabla f_i\|^2 \le L^2\|x-x^*\|^2$: standard.
- Squared-distance expansion: standard.
- Young's inequality (twice, with tuned parameters $p_1 = \gamma\mu/\beta$, $p_2 = 1$): standard.
- $2 \times 2$ matrix Lyapunov: standard linear algebra.
- Perron-Frobenius certificate via positive eigenvector: non-standard packaging; most papers compute eigenvalues directly.

### 4. The Construction
$\beta = 1/(4\kappa^2)$ and $\gamma = 1/(2L\kappa)$ are forced by the requirement that all five terms $a_{11}, a_{12}, a_{21}, a_{22}$ be $O(1/\kappa^2)$ relative to the diagonal; smaller $\beta$ would work but give worse rate, larger $\beta$ breaks the Lyapunov.

### 5. The Failure Modes
- **Use $\beta = O(1)$**: cross-term $\beta^2/(\gamma\mu)$ becomes $O(1)$, the matrix doesn't contract.
- **Try a one-dimensional Lyapunov $\|e_t\|^2$ alone**: the momentum contribution doesn't vanish, you need to track $\|v_t\|^2$ jointly.
- **Try to prove acceleration with optimal $\beta^*$**: requires non-diagonal Lyapunov / IQC machinery (Lessard et al.); naive Lyapunov can't.

### 6. The Discovery Path
1. Observation: vanilla SGD-interpolation works; add momentum, run experiments — it's stable, prove it.
2. First attempt: scalar Lyapunov $\|e_t\|^2$ — momentum injects $\beta\langle u_t, s_t\rangle$ that won't vanish.
3. Insight: track joint state $(\|e\|^2, \|s\|^2)$, set up $2\times 2$ recursion.
4. Spectral analysis via Perron-Frobenius eigenvector $(1, 1/\kappa^2)$; tune $\beta = 1/(4\kappa^2)$ to fit.
5. Verify all coefficient inequalities for $\kappa \ge 3$.

### 7. Transferable Patterns
- **Joint-state Lyapunov + Perron-Frobenius**: standard recipe for proving stability of stochastic linear systems with momentum / inertia.
- **Scaled coordinates** ($s = \gamma v$) put position and velocity in the same scale, simplifying constant-tracking.

---

## 5. Momentum SGD Interpolation — Contraction (variant 2, with $A_S = 0$ trick)

### 1. The Spark
**pattern-spotted** — Same theorem as variant 1, but someone noticed: if you choose $\gamma = 1/(4L)$ and use the $\alpha = 1/2$ split co-coercivity, the variance coefficient $A_S = 4\gamma^2 - \gamma/L$ in the joint Lyapunov becomes **exactly zero**.

### 2. The Key Insight
The variance term $\gamma^2\mathbb{E}\|g\|^2$ from the squared-distance expansion can be **exactly cancelled** by the $-\frac{1-\alpha}{L}S_t$ portion of the split-co-coercivity bound, provided $\alpha = 1/2$ and $\gamma = 1/(4L)$. After this cancellation the remaining recursion involves only $\|e_t\|^2$ and $\|v_t\|^2$ — no stochastic-variance term to control. This is "interpolation as free SVRG": no explicit control variate needed.

### 3. The Technique Chain
- Per-component co-coercivity $\langle \nabla f_i, x-x^*\rangle \ge \|\nabla f_i\|^2/L$: standard.
- Convex combination of strong convexity and averaged co-coercivity (the "$\alpha$-split"): non-standard; this technique is folklore in interpolation analyses (Vaswani, Ma, Bach et al.).
- Joint Lyapunov $\Phi_t = \|e_t\|^2 + \gamma^2\|v_t\|^2$: standard.
- Young's inequalities on cross-terms: standard.
- Tuning $\beta = \mu/(8L)$: forced by $A_v/c < 1$.

### 4. The Construction
The pair $(\gamma, \alpha) = (1/(4L), 1/2)$ is uniquely forced by requiring $A_S = 4\gamma^2 - \gamma/L = 0$. Different $\alpha$ would change the ratio between the two contraction terms; only $\alpha = 1/2$ produces the symmetric cancellation.

### 5. The Failure Modes
- **$\alpha = 1$ (only strong convexity)**: $A_S = 4\gamma^2 > 0$, variance term doesn't vanish.
- **$\alpha = 0$ (only co-coercivity)**: lose the strong-convexity contraction $\mu\|e\|^2$.
- **$\gamma = 1/L$ (textbook GD step)**: $A_S = 4/L^2 - 1/L^2 = 3/L^2 > 0$, no cancellation.

### 6. The Discovery Path
1. Observation: interpolation makes vanilla SGD converge linearly; how does it interact with momentum?
2. First attempt: write out joint Lyapunov, see that $A_S$ is the obstruction.
3. Insight: parameterize $\langle \nabla f, e\rangle$ via convex combination of strong-convexity and co-coercivity, vary $\alpha$ to find the sweet spot where $A_S$ vanishes.
4. Algebra: $\alpha = 1/2$, $\gamma = 1/(4L)$ (or $1/L$ in variant 6) gives $A_S = 0$; pick $\beta$ so that $A_v/c < 1$.
5. Verify rates and constants.

### 7. Transferable Patterns
- **The $\alpha$-split co-coercivity trick**: convex-combination of two different inner-product lower bounds, then tune $\alpha$ to make a target coefficient vanish — a general meta-tool for interpolation-style analyses.

---

## 6. Momentum SGD Interpolation — Convergence (variant 3, $\gamma = 1/L$)

### 1. The Spark
**pattern-spotted** — Same theorem again, but now the author commits to a stronger step size $\gamma = 1/L$ (matching deterministic GD) and asks: does the same $\alpha = 1/2$ split-co-coercivity trick still cancel the variance, and at what $\beta$?

### 2. The Key Insight
This is essentially variant 5 with $\gamma$ doubled. With $\gamma = 1/L$, the co-coercivity portion $-\gamma/L \cdot S_t = -S_t/L^2$ exactly cancels the variance contribution $\gamma^2 S_t = S_t/L^2$ from the squared-distance expansion (Step 6, "variance reduction effect of interpolation"). The discovery path is the same as variant 5 — the only meaningful difference is the choice of $a$ (Lyapunov weight) and $\beta = \mu^2/(16L^2)$. Notes confirm this is "Route 3 — Variance Reduction Viewpoint", emphasizing the same mechanism. **This is essentially the same theorem from a slightly different angle**: it's variant 5 with parameters chosen for the Lyapunov $\Phi = \|e\|^2 + a\|m\|^2$ rather than $\Phi = \|e\|^2 + \gamma^2\|v\|^2$.

### 3. The Technique Chain
Identical to variant 5: split co-coercivity (Lemma 1), interpolation variance bound (Lemma 2), gradient Lipschitz bound (Lemma 3), joint Lyapunov, Young on cross-terms, parameter tuning. The novelty is purely organizational.

### 4. The Construction
$\gamma = 1/L$, $a = \mu/(4L)$, $\beta = \mu^2/(16L^2)$. The relation $\gamma = 1/L$ is what makes the variance cancel exactly — same as variant 5 but at the larger GD step.

### 5. The Failure Modes
Same as variant 5; additionally:
- **Tracking $\|v_t\|^2$ instead of $\|m_t\|^2 = \gamma^2\|v_t\|^2$**: scale mismatch makes constants harder.

### 6. The Discovery Path
1. Observation: variant 5 used $\gamma = 1/(4L)$; can we push to $\gamma = 1/L$ (the GD step)?
2. First attempt: redo expansion, see that the same $\alpha = 1/2$ split still cancels variance at $\gamma = 1/L$.
3. Insight: the cancellation $-2\gamma\langle e, \nabla f\rangle + \gamma^2\mathbb{E}\|g\|^2 \le -(\mu/L)\|e\|^2$ is robust across $\gamma$ choices as long as $\gamma = 1/L$ (this gives the cleanest form).
4. Tune Lyapunov weight $a$ and momentum $\beta$ to fit the cross-terms within a $\mu/(2L)$ budget; allocate three perturbation terms each with budget $\mu/(8L)$.
5. Verify the residual momentum coefficient $R_m \le a\rho$ holds for all $\kappa \ge 1$.

### 7. Transferable Patterns
- **Budget-allocation analysis**: split a target contraction into named portions (here $\mu/(8L)$ per perturbation term), each absorbed by a Young's inequality with prescribed parameter — makes constant-tracking mechanical.

---

## 7. Momentum SGD — Spectral Analysis Convergence

### 1. The Spark
**question-asked** — The Lyapunov-based variants 4–6 give rate $1 - O(1/\kappa^2)$ at very small $\beta$. Can we get the **GD-rate $1 - O(1/\kappa)$** by analyzing the second-moment operator spectrally instead of with a hand-written Lyapunov?

### 2. The Key Insight
Linearize via the integral Hessian $\nabla f_i(x_t) = H_i(x_t)e_t$ (valid because $\nabla f_i(x^*) = 0$ and each $f_i$ is convex $L$-smooth), so the iteration becomes $z_{t+1} = A_{i_t}(x_t) z_t$ with $z = (e, d)$. The expected second moment $\mathbb{E}[z_t z_t^T]$ evolves under a linear operator $\mathcal{T}(S) = (1/n)\sum_i A_i S A_i^T$, and $\rho(\mathcal{T}) < 1$ certifies convergence. This converts the analysis into a problem about the spectral radius of a $4d \times 4d$ Kronecker-product matrix — clean but hard to bound by hand. The compromise is a diagonal $P = I + a\cdot\text{vv}^T$ Lyapunov + the bound $H_i^2 \preceq L H_i$, giving rate $1 - 5/(16\kappa)$ (better than $1/\kappa^2$ but not optimal $1/\sqrt\kappa$).

### 3. The Technique Chain
- Integral Hessian linearization $\nabla f_i = H_i \cdot e$ via interpolation: standard (used implicitly in many quadratic-style proofs).
- Reduction to Markov-jump linear systems: from Costa-Fragoso-Marques 2005 (control theory, non-standard for ML).
- Kronecker product $\mathcal{M} = (1/n)\sum A_i \otimes A_i$ for the second-moment operator: standard control theory.
- $H_i^2 \preceq L H_i$ from smoothness: standard but key.
- Diagonal Lyapunov $\Phi = \|e\|^2 + \alpha\|p\|^2$: standard fallback.
- Young's inequality + parameter tuning: standard.

### 4. The Construction
$\gamma = 1/(2L)$, $\beta = 1/\kappa$, $\alpha = 5\mu/(8L(\gamma L + \beta))$. The choice $\beta = 1/\kappa$ (not $1/\kappa^2$ as in variants 4–6) is the gain: it's enabled by the spectral viewpoint, which provides finer control than the joint $(e, v)$ Lyapunov alone.

### 5. The Failure Modes
- **Try non-diagonal $P$**: notes show several attempts; the cleanest closed form requires a non-trivial coupling that explodes the algebra.
- **Compute eigenvalues of $\bar N$ explicitly**: $3\times 3$ characteristic polynomial is tractable but the contraction conditions are messy.
- **Hope for accelerated rate $1 - 1/\sqrt\kappa$**: requires IQC / Nesterov-style estimating-sequence machinery; not within this proof's scope.

### 6. The Discovery Path
1. Observation: variants 4–6 give rate $1 - O(1/\kappa^2)$, but numerical experiments show $1 - O(1/\kappa)$ is achievable.
2. First attempt: try non-diagonal Lyapunov $P$ — algebra explodes, $d^2$ coefficient becomes intractable for $\beta > 1/2$.
3. Insight: use the integral-Hessian linearization to recast the analysis as a linear control problem; cite Costa-Fragoso-Marques for existence of $P$.
4. Settle for diagonal $P$ + bound $H_i^2 \preceq LH_i$; tune $\gamma = 1/(2L)$, $\beta = 1/\kappa$ to extract a $1 - 5/(16\kappa)$ rate.
5. Verify Young constants and cross-term budget hold for all $\kappa \ge 1$; confirm numerically that better $\beta$ exists but lacks closed-form proof.

### 7. Transferable Patterns
- **Integral Hessian linearization under interpolation**: $\nabla f_i(x) = H_i(x) (x-x^*)$ when $\nabla f_i(x^*) = 0$ — converts general smooth-strongly-convex analysis into matrix-state-dependent linear analysis. Powerful and general.
- **Citing Markov-jump-linear-systems theory** (Costa et al. 2005) to assert existence of Lyapunov $P$ when explicit construction is hopeless.

---

## Cross-cutting note on variants 4, 5, 6, 7

Variants 4–7 prove the **same theorem** (linear convergence of SGD + Polyak momentum under interpolation for smooth strongly convex $f$) by **four different routes**:
- Variant 4 (linear-convergence): joint Lyapunov + Perron-Frobenius certificate, rate $1 - 1/(16\kappa^2)$.
- Variant 5 (contraction): joint Lyapunov + $\alpha$-split with $\gamma = 1/(4L)$, rate $1 - 1/(4\kappa)$.
- Variant 6 (convergence): joint Lyapunov + $\alpha$-split with $\gamma = 1/L$, rate $1 - 1/(2\kappa)$.
- Variant 7 (spectral): integral-Hessian + Markov-jump theory + diagonal Lyapunov, rate $1 - 5/(16\kappa)$.

The discovery PATHS overlap (variants 5, 6 are essentially the same trick at different $\gamma$; variant 4 is a weaker precursor; variant 7 is genuinely different). Real intellectual progress: **variant 4 is "we can prove anything", variants 5–6 are "we can prove the right rate using the $\alpha = 1/2$ split", variant 7 is "we can match GD rate by going spectral"**.

---

**Summary**

- File written: `C:\Users\12729\Desktop\Math\workspace\discovery_reports\agent_3.md`
- Proofs analyzed: 7 (SPS-SGD; Clipped SGD heavy-tail; SGD PL+interpolation+averaging; 4 variants of Polyak-momentum SGD under interpolation)
- Most interesting cross-cutting observation: **Interpolation is the unifying thread — five of seven proofs exploit $\nabla f_i(x^*) = 0$ as a "free variance reduction" mechanism, and the discovery moves all reduce to: (a) write expansion, (b) recognize that under interpolation a key noise term becomes proportional to $\|x-x^*\|^2$ rather than an additive $\sigma^2$, (c) choose step / momentum / Lyapunov so this multiplicative structure cancels exactly. The "$\alpha$-split co-coercivity" with $\alpha = 1/2$ and the integral-Hessian linearization $\nabla f_i = H_i e$ are the two cleanest technical instantiations of this same idea.**
