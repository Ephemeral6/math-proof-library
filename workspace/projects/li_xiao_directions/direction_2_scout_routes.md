# Direction 2 — Scout Routes: Last-Iterate Upper Bound for Fixed-Momentum SHB on Smooth Convex

**Date:** 2026-04-28  
**Problem:** Prove (or refute) a last-iterate upper bound  
$$\mathbb{E}[f(x_T) - f^\star] \leq C(\beta)\cdot\frac{LD^2}{T} + C'(\beta)\cdot\frac{\sigma D}{\sqrt{T}}$$  
for fixed-momentum SHB on $L$-smooth convex (non-strongly-convex) functions with bounded-variance $\sigma^2$ stochastic oracle.

**Context:** OP-2 proves $\Omega(LD^2/T + \sigma D/\sqrt{T})$ for the last iterate on $\mathcal{F}$. GFJ15 gives $O(LD^2/T)$ only for the Cesàro average in the deterministic case ($\sigma=0$). No published matching stochastic last-iterate UB for fixed-momentum SHB is known. The question is whether the rate is $O(LD^2/T + \sigma D/\sqrt{T})$, or genuinely worse (e.g., $O(LD^2/T^{1/2})$ or $O(\sigma D \sqrt{\log T}/\sqrt{T})$), or altogether unavailable for fixed momentum.

---

## Route A — 3-Term Lyapunov / Energy Descent

### Target theorem

**Theorem A.** For fixed $\beta \in [0,1)$, $\eta \in (0, (1-\beta)/L]$ (a subset of the stability region $\mathcal{S}$), and any $L$-smooth convex $f$ with $\|x_0 - x^\star\| \leq D$, the fixed-momentum SHB last iterate satisfies
$$\mathbb{E}[f(x_T) - f^\star] \leq \frac{C_1(\beta)}{T}\cdot LD^2 + C_2(\beta)\cdot \sigma^2/L,$$
where $C_1(\beta) = O(1/(1-\beta))$ and $C_2(\beta) = O(1/(1-\beta)^2)$.

(Note: the variance term saturates at $\sigma^2/L$, not $\sigma D/\sqrt{T}$ — this is the key distinction from the SGD rate.)

### Critical lemmas

**Lemma A1 (SHB gradient descent inequality).** For $L$-smooth convex $f$:
$$f(x_{t+1}) \leq f(x_t) - \eta\langle\nabla f(x_t), g_t\rangle + \frac{L\eta^2}{2}\|g_t\|^2.$$

**Lemma A2 (Lyapunov increment).** Let $V_t = (f(x_t) - f^\star) + \frac{a}{2}\|x_t - x^\star\|^2 + \frac{b}{2}\|x_t - x_{t-1}\|^2$. Show that for appropriate $a = a(\beta,\eta,L)$ and $b = b(\beta,\eta,L)$:
$$\mathbb{E}[V_{t+1} \mid \mathcal{H}_t] \leq (1 - \alpha)\, V_t + C\,\sigma^2\eta^2.$$
The key obstruction: the SHB update $x_{t+1} = x_t - \eta g_t + \beta(x_t - x_{t-1})$ makes $\|x_{t+1} - x^\star\|^2$ depend on $x_{t-1}$, producing cross terms $\langle x_t - x_{t-1}, x_t - x^\star\rangle$ that must be absorbed into $b\|x_t - x_{t-1}\|^2$.

**Lemma A3 (Cross-term absorption).** For $\beta \in [0,1)$ and $\eta \leq (1-\beta)/L$, the choice $a = \beta/(2\eta)$ and $b = \eta\beta/(2(1-\beta))$ (or similar) resolbs the cross-term: $\beta\langle x_t - x_{t-1}, x_t - x^\star\rangle \leq \frac{\beta}{4\delta}\|x_t - x_{t-1}\|^2 + \delta\|x_t - x^\star\|^2$ for a $\delta$ that balances with $a$.

**Lemma A4 (Telescope).** If $V_{t+1} \leq (1-\alpha)V_t + C\sigma^2\eta^2$, then by induction $V_T \leq (1-\alpha)^T V_0 + (C\sigma^2\eta^2)/\alpha$. For the convex (non-SC) setting $\alpha \to 0$ and one must use the ergodic sum instead, yielding the averaging step $f(x_T) - f^\star \leq \frac{1}{T}\sum_t [V_t - V_{t+1}] + \frac{C\sigma^2\eta^2}{\alpha}\cdot\frac{1}{T}$.

**Lemma A5 (Stationary noise floor).** The term $C\sigma^2\eta^2/\alpha$ represents the noise floor of the 3-term Lyapunov; when $\alpha$ is small (convex non-SC case), this can scale as $\sigma^2\eta^2/(\eta(1-\beta)/(LD^2\cdot\text{something}))$ — which needs careful analysis to extract the optimal $\sigma D/\sqrt{T}$ rate vs a flat $\sigma^2/L$ floor.

### Difficulty

**Research.** The 3-term Lyapunov is standard for SHB in the SC setting (see Gadat-Panloup-Saadane 2018, Ghadimi et al. 2015 for various versions), but the non-SC convex case with last-iterate (not Cesàro) analysis is non-standard. The parameter tuning for $a, b$ to achieve a non-trivial contraction with non-SC functions is the main obstacle.

### Most likely failure mode

**Failure:** The natural Lyapunov produces $V_{t+1} \leq V_t - \text{progress} + C\sigma^2\eta^2$, but for non-SC $f$ the progress term $\text{progress}$ is proportional to $f(x_t) - f^\star$ which decays to zero, not bounded below. The result is $V_T \leq V_0 + C\sigma^2\eta^2 \cdot T$, giving a diverging bound. To get $O(1/\sqrt{T})$ variance, one needs a step-size $\eta \sim 1/\sqrt{T}$ — but for fixed $\eta$ (fixed momentum), this collapses to a constant-variance floor $\sigma^2\eta^2/\text{(something)}$, not decreasing in $T$. The Lyapunov cannot produce a $\sigma D/\sqrt{T}$ rate with fixed $\eta$.

### Predicted rate

The Lyapunov approach is likely to yield:
- **Bias term:** $O(LD^2/(T(1-\beta)))$ via telescoping $\sum_t (f(x_t) - f^\star) \leq V_0/(T\alpha)$
- **Variance term:** $O(\sigma^2/(L(1-\beta)^2))$ — a **constant noise floor**, NOT $O(\sigma D/\sqrt{T})$

This is a meaningful UB but does NOT match the OP-2 LB form. The rate is $O(LD^2/T + \sigma^2/L)$. This would imply that for large $T$ with $\sigma$ fixed, the last iterate of SHB does NOT converge to $f^\star$ — it stagnates at $O(\sigma^2/L)$. This is the correct qualitative picture for fixed step-size stochastic gradient methods, and is consistent with the best-iterate analysis in the background (Section 5.3 of the best-iterate LB proof).

---

## Route B — FTRL/Online-to-Batch Adaptation

### Target theorem

**Theorem B.** There exists a regret bound for fixed-momentum SHB viewed as an online algorithm such that applying the online-to-batch conversion yields a last-iterate bound of the form:
$$\mathbb{E}[f(x_T) - f^\star] \leq \frac{C_1(\beta) \cdot LD^2}{T} + C_2(\beta)\cdot\frac{\sigma D \sqrt{\log T}}{\sqrt{T}}.$$
The log-factor is the expected penalty for fixed (non-tunable) momentum.

### Critical lemmas

**Lemma B1 (FTRL regret for fixed-momentum).** The online iterate $x_t$ of SHB satisfies a regret decomposition $\text{Regret}_T = \sum_t \langle\nabla f(x_t), x_t - x^\star\rangle \leq R(\beta, \eta, L, D, T)$ where $R$ is an explicit upper bound. (Requires identifying the "implicit regularizer" for fixed-momentum updates.)

**Lemma B2 (Coupling to FTRL).** Fixed-momentum SHB with step-size $\eta$ is equivalent to a proximal-point iteration with an auxiliary sequence; or alternatively, it can be written as a mirror-descent step with a time-varying norm. The key lemma pins down the per-step regret structure.

**Lemma B3 (Last iterate via Be-the-Regularized-Leader).** The Li-Liu-Orabona 2022 last-iterate bound for FTRL uses the "interplay" between regularizer geometry and the gradient sequence. For fixed momentum, this analysis does not apply directly (their bound requires increasing momentum to satisfy a stability condition). The analogous fixed-momentum result would require showing a "quasi-stability" condition holds, possibly producing an extra $\log T$ factor.

**Lemma B4 (Online-to-batch with last iterate).** Connecting online regret to the stochastic setting: $\mathbb{E}[f(x_T) - f^\star] \leq \frac{1}{T}\text{Regret}_T + \text{Martingale correction}$. The martingale correction from stochastic gradients introduces additional variance terms.

**Lemma B5 (Fixed-momentum regret penalty).** Unlike the increasing-momentum schedule in Li-Liu-Orabona where $\beta_t \to 1$ forces the iterates to eventually track the optimal solution, fixed $\beta$ means the momentum term $\beta(x_t - x_{t-1})$ adds a persistent bias. This results in an extra $\log T$ factor in the regret bound, explaining the $\sigma D\sqrt{\log T}/\sqrt{T}$ prediction.

### Difficulty

**Research / Conjecture.** The FTRL framework for fixed-momentum methods is not well-developed. The Li-Liu-Orabona work is specifically designed for increasing-momentum schedules; adapting it to fixed momentum requires new analysis of the momentum term's contribution to regret. This is likely to be technically involved and may not close.

### Most likely failure mode

**Failure:** The fixed-momentum term $\beta(x_t - x_{t-1})$ cannot be absorbed into any standard FTRL regularizer without producing a $\beta$-dependent correction that grows in $T$. Specifically, the "implicit regularizer" for SHB involves the entire history $\sum_{s<t} \beta^{t-s}(x_s - x_{s-1})$, which is a moving average of increments with exponentially decaying weights. This is not a standard FTRL regularizer structure. The analysis may produce only a trivial bound $O(\sqrt{T})$ regret (i.e., $O(1/\sqrt{T})$ rate) without the $LD^2/T$ bias improvement.

### Predicted rate

If the route succeeds: $O(LD^2/T + \sigma D\sqrt{\log T}/\sqrt{T})$. The log factor from fixed-momentum inefficiency matches the $\Omega(\log T/\sqrt{T})$ LB of Li-Liu-Orabona for the non-smooth Lipschitz setting, and would be consistent with fixed momentum being "log-suboptimal" in the stochastic case.

If the route fails: only $O(1/\sqrt{T})$ rate recovered, losing the $LD^2/T$ bias term.

---

## Route C — Sebbouh et al. De-averaging

### Target theorem

**Theorem C.** Let Sebbouh-Gower-Defazio 2021 (arXiv:2006.07867) prove almost-sure convergence of the SHB last iterate at rate $o(1/\sqrt{k})$ on convex smooth functions. Converting their argument to an in-expectation rate with explicit constants yields:
$$\mathbb{E}[f(x_T) - f^\star] \leq C(\beta)\cdot\frac{LD^2}{T\cdot\eta(1-\beta)} + C'(\beta)\cdot\frac{\sigma^2\eta}{(1-\beta)^2},$$
where the variance term saturates at a constant (noise floor), NOT $\sigma D/\sqrt{T}$.

### Critical lemmas

**Lemma C1 (Sebbouh et al. key recursion).** The almost-sure convergence proof in Sebbouh et al. relies on a Robbins-Siegmund type lemma applied to a potential $V_t = \|x_t - x^\star\|^2 + c\|x_t - x_{t-1}\|^2$. The recursion has the form $V_{t+1} \leq V_t - \delta_t + \varepsilon_t$ where $\sum \delta_t = \infty$ a.s. and $\sum \varepsilon_t < \infty$ a.s. (for decreasing step-sizes or bounded variance).

**Lemma C2 (Fixed step-size case).** For fixed $\eta$, $\varepsilon_t = C\sigma^2\eta^2$ is constant, so $\sum \varepsilon_t = \infty$ and Robbins-Siegmund fails in the standard form. Sebbouh et al.'s result for fixed-step-size requires instead a different argument (possibly ergodic-average type), giving only $\liminf_t f(x_t) - f^\star = 0$ almost surely, not rate.

**Lemma C3 (Expectation conversion).** Converting the Robbins-Siegmund-type almost-sure statement to expectation via Fatou's lemma gives only $\mathbb{E}[\liminf_t (f(x_t) - f^\star)] = 0$, not $\mathbb{E}[f(x_T) - f^\star] \to 0$. The interplay of a.s. and $L^1$ convergence requires uniform integrability or an $L^1$ version of the argument.

**Lemma C4 (Rate extraction for smooth convex with fixed $\eta$).** In the smooth convex setting, a telescoping argument from the SHB descent lemma gives $\frac{1}{T}\sum_{t=0}^{T-1}(f(x_t)-f^\star) \leq O(LD^2/T) + O(\sigma^2\eta/L)$ (Cesàro rate). For the LAST iterate, one needs a Cesàro-to-last-iterate conversion, which typically requires additional assumptions or produces a worse rate.

**Lemma C5 (Sebbouh's actual fixed-momentum theorem).** A careful reading of Sebbouh et al. §3.3 or §4 for fixed momentum: they likely require either decreasing $\eta$ or the interpolation condition. For fixed $\eta$ on general smooth convex, their results give convergence in Cesàro average or ergodic sense, not last iterate.

### Difficulty

**Advanced.** Reading and correctly extracting the fixed-momentum result from Sebbouh et al. is feasible but requires careful attention to assumptions. The de-averaging step (Cesàro to last iterate) is the key technical challenge.

### Most likely failure mode

**Failure:** Sebbouh et al.'s last-iterate convergence for fixed momentum on smooth convex may only hold asymptotically ($o(1/\sqrt{T})$ with no quantitative rate), or may require additional assumptions not present in our setting (e.g., interpolation, or decreasing step-sizes). The de-averaging argument from Cesàro to last-iterate generically fails for non-strongly-convex functions — there is no last-iterate-to-Cesàro gap lemma that avoids an extra $O(\sqrt{T})$ factor in the variance regime.

### Predicted rate

The route is likely to produce:
- **What Sebbouh et al. actually give:** $\mathbb{E}[f(x_T)-f^\star] = o(1)$ for fixed $\eta$ (convergence to noise floor), or qualitative $o(1/\sqrt{T})$ under decreasing $\eta_t \sim 1/\sqrt{t}$.
- **What we can extract for fixed $\eta$:** Noise floor $O(\sigma^2\eta/L(1-\beta)^2)$ — a constant. No $\sqrt{T}$ decay for fixed $\eta$.
- **Conclusion:** Route C is likely to confirm that fixed-momentum SHB last iterate does NOT achieve $\sigma D/\sqrt{T}$ rate with fixed $\eta$, and instead stagnates at a noise floor.

---

## Route D — Online-to-Batch via Regret + Bridge Lemma

### Target theorem

**Theorem D.** Viewing fixed-momentum SHB as a momentum-augmented OGD, suppose it achieves regret $R_T \leq C(\beta)(LD^2 + \sigma^2/L)$. Dividing by $T$ gives the Cesàro rate $O(LD^2/T + \sigma^2/(LT))$. Applying a last-iterate-to-average bridge lemma yields:
$$\mathbb{E}[f(x_T) - f^\star] \leq \frac{C(\beta) \cdot LD^2}{T} + \frac{C'(\beta)\cdot\sigma^2}{L},$$
where the variance term is again a constant noise floor, not $\sigma D/\sqrt{T}$.

### Critical lemmas

**Lemma D1 (SHB as modified OGD).** Write the SHB update as:
$$x_{t+1} = x_t - \eta g_t + \beta(x_t - x_{t-1}) = \arg\min_{x}\left\{\eta\langle g_t, x\rangle + \frac{1}{2}\|x - x_t\|^2 + \frac{\beta}{2}\|x - x_t\|^2 - \beta\langle x_t - x_{t-1}, x - x_t\rangle\right\}.$$
The momentum term adds a linear tilt in the direction of the previous step. This can be absorbed into an "effective gradient" $\tilde{g}_t = g_t - \frac{\beta}{\eta}(x_t - x_{t-1})$, but $\tilde{g}_t$ is now biased (it includes the momentum direction which is correlated with past noise).

**Lemma D2 (Regret of effective-gradient OGD).** For the effective-gradient interpretation, $\text{Regret}_T = \sum_t\langle \tilde{g}_t, x_t - x^\star\rangle$. Decompose into true gradient part and momentum-bias part: $\text{Regret}_T = \sum_t\langle g_t, x_t - x^\star\rangle - \frac{\beta}{\eta}\sum_t\langle x_t - x_{t-1}, x_t - x^\star\rangle$. The second sum is an Abel summation / telescoping that can be bounded.

**Lemma D3 (Orabona bridge lemma).** A last-iterate-to-Cesàro conversion for OGD-type algorithms: if the Cesàro average satisfies $f(\bar{x}_T) - f^\star \leq B_T$, then under monotone regret growth, $f(x_T) - f^\star \leq 2B_T + O(\text{noise}/T)$. This lemma requires the specific structure of OGD and does not trivially transfer to SHB's biased effective gradient.

**Lemma D4 (Variance term in regret).** The stochastic noise $\sigma^2$ contributes $\sum_t\langle \xi_t, x_t - x^\star\rangle$ to the regret. This is a martingale with increments bounded by $\sigma D$, giving by Azuma-Hoeffding: $O(\sigma D\sqrt{T})$ total. Divided by $T$: $O(\sigma D/\sqrt{T})$ — this is the standard SGD rate. However, for fixed-$\eta$ SHB, the bounded-domain condition ($\|x_t - x^\star\| \leq D$) may not hold for all $t$ without a projection step, breaking the Azuma argument.

**Lemma D5 (Domain confinement).** Whether $\|x_t - x^\star\|$ remains bounded by $O(D)$ for all $t$ under fixed-momentum SHB with $(\beta,\eta) \in \mathcal{S}$. In the SC case this is guaranteed by the stability region. In the non-SC smooth convex case, the iterates can drift: SHB on $(L/2)\|x\|^2$ with noise has a stationary distribution with variance $\sigma^2\eta/(L(1-\beta^2))$, which can be $\gg D^2$ for large $\sigma$.

### Difficulty

**Research.** The online-to-batch route is conceptually clean but has the domain-confinement issue (Lemma D5) as a critical blocker: if $\|x_t - x^\star\|$ can be $\gg D$, the Azuma argument fails and the variance term explodes. For non-strongly-convex functions, the iterates are not automatically confined.

### Most likely failure mode

**Critical failure at Lemma D5.** For $L$-smooth convex non-SC $f$, fixed-momentum SHB with fixed $\eta$ does NOT confine iterates to a ball of radius $O(D)$ — the noise drives a diffusion that grows as $O(\sigma\sqrt{T})$ in the worst case. This breaks the Azuma bound in Lemma D4 and yields only $O(\sigma^2 T / T) = O(\sigma^2)$ per-step variance, i.e., a constant noise floor rather than a $\sigma D/\sqrt{T}$ rate.

The route can potentially be rescued by adding a projection step (projected SHB), but that changes the algorithm and is not the fixed-momentum SHB of interest.

### Predicted rate

For projected SHB (with projection onto $\{x: \|x - x^\star\| \leq D\}$): $O(LD^2/T + \sigma D/\sqrt{T})$ — matching the OP-2 LB.

For unprojected fixed-momentum SHB: the variance term diverges or saturates at $O(\sigma^2\eta/(L(1-\beta^2)))$, a constant independent of $T$ and $D$. This rate stagnates. Route D will likely conclude: the $\sigma D/\sqrt{T}$ last-iterate UB is FALSE for unprojected fixed-momentum SHB with fixed $\eta$.

---

## Route E — PEP/SDP Numerical Upper Bound

### Target theorem

**Theorem E (Numerical).** For fixed $(\beta, \eta, L, \sigma, D, T)$, the Performance Estimation Problem for fixed-momentum SHB last iterate on $L$-smooth convex functions with bounded-variance oracle gives an exact worst-case rate $\gamma^\star(T, \beta, \eta)$ satisfying:

- At small $T$ (e.g., $T = 1, 5, 20$): $\gamma^\star(T, \beta, \eta) = \Theta(1/\sqrt{T})$ dominated by variance.
- At large $T$: either $\gamma^\star \sim C/T$ (matching SGD) or $\gamma^\star \sim C'\sigma^2/L$ (constant noise floor — saturation).

The numerical data distinguishes between the $O(1/\sqrt{T})$ and constant-noise-floor scenarios.

### Critical lemmas

**Lemma E1 (PEP SDP formulation for stochastic SHB).** Taylor-Hendrickx-Glineur 2017 (Math. Prog.) formulate the PEP for deterministic gradient methods as an SDP. Extending to stochastic oracles with bounded variance $\sigma^2$ requires augmenting the SDP with noise variables $\xi_t$ satisfying $\|\xi_t\|^2 \leq \sigma^2$ (or in expectation $\mathbb{E}[\|\xi_t\|^2] \leq \sigma^2$) as additional semidefinite constraints.

**Lemma E2 (Interpolation conditions for stochastic SHB).** The function class $\mathcal{F}_{L,0}$ (L-smooth, 0-SC convex) can be encoded via the L-smooth interpolation conditions (Taylor-Hendrickx-Glineur): $f_i + \langle g_i, x_j - x_i\rangle + \frac{1}{2L}\|g_i - g_j\|^2 \leq f_j$ for all $i, j$. Combined with the SHB update equations, this gives a feasible SDP.

**Lemma E3 (Noise expectation encoding).** Encoding $\mathbb{E}[\|\xi_t\|^2] \leq \sigma^2$ in an SDP requires either: (a) treating the worst-case deterministic noise realization $\|\xi_t\| = \sigma$ (overestimates), or (b) using a second-moment SDP lift. Option (a) gives a valid but potentially conservative UB.

**Lemma E4 (SDP scalability).** The PEP SDP for SHB with $T$ steps and $d$-dimensional problem has $O(T^2)$ variables (pairwise function values and gradients). For $T \leq 50$ this is tractable (CVXPY + MOSEK). For $T \sim 100$, the SDP may be slow but feasible.

**Lemma E5 (Extrapolation from numerical data).** Given $\gamma^\star(T)$ for $T = 1, \ldots, 50$, fit the rate as $a/T + b/\sqrt{T} + c$ to identify whether $c > 0$ (constant noise floor) or $c = 0$ (genuine $O(1/\sqrt{T})$ decay). The quality of fit determines whether fixed-momentum SHB has a stagnating or decaying last-iterate rate.

### Difficulty

**Standard (for numerical PEP) / Research (for closed-form extraction).** PEP SDPs for deterministic methods are standard (PEPit library). The stochastic extension requires implementation effort but is methodologically well-established. The closed-form extraction from numerical data is more speculative.

### Most likely failure mode

**Computational.** The stochastic PEP SDP with expectation constraints may be difficult to encode correctly (the expectation over noise is not standard in the deterministic PEP framework). Using the worst-case deterministic noise overestimates; using the expectation requires careful moment-SDP techniques. The SDP may also be too large for $T > 30$.

**Interpretational.** The numerical data at $T \leq 50$ may not be conclusive about the asymptotic rate (the crossover from $1/\sqrt{T}$ to noise floor may occur at $T \gg 50$). Extrapolation is inherently unreliable.

### Predicted rate

The PEP is expected to reveal one of two scenarios:

**Scenario 1 (optimistic):** For $(\beta, \eta) \notin \mathcal{F}$ (stable but non-cycling parameters), $\gamma^\star(T)$ decays as $O(1/\sqrt{T})$ without saturation, suggesting the $O(LD^2/T + \sigma D/\sqrt{T})$ last-iterate UB may hold for some parameter regime.

**Scenario 2 (pessimistic, more likely):** $\gamma^\star(T)$ saturates at a constant $c(\beta,\eta)\sigma^2/L > 0$ as $T \to \infty$ for fixed $\eta$, confirming the noise-floor picture. The SDP optimum at large $T$ will be achieved by a quadratic hard instance ($(L/2)\|x\|^2$) where the stationary distribution has variance $\sigma^2\eta/(L(1-\beta^2))$.

Route E is primarily **diagnostic**: it tells us which scenario is correct without yielding a proof, but it informs which of the other routes to invest in.

---

## Route F — Negative Result / Refutation of $\sigma D/\sqrt{T}$

### Target theorem

**Theorem F.** The last-iterate bound $\mathbb{E}[f(x_T) - f^\star] \leq C \cdot \sigma D/\sqrt{T}$ is **FALSE** for fixed-momentum SHB with any fixed $(\beta, \eta) \in \mathcal{S}$ on $L$-smooth convex functions. Specifically:

For $f(x) = (L/2)x^2$ on $\mathbb{R}^1$ (or $\mathbb{R}^d$ with i.i.d. noise), the fixed-$\eta$ SHB last iterate satisfies
$$\mathbb{E}[f(x_T) - f^\star] = \frac{L}{2}\mathbb{E}[x_T^2] \to \frac{L}{2}\cdot\frac{\sigma^2\eta}{L(1-\beta^2)} =: \nu^2(\beta,\eta,\sigma,L) > 0$$
as $T \to \infty$. The limit $\nu^2 > 0$ is a constant independent of $T$ and $D$, strictly positive for any $\sigma > 0$ and $(\beta,\eta) \in \mathcal{S}$.

**Corollary F.** There is NO rate $\sigma D/\sqrt{T}$ for fixed-momentum SHB last iterate; the correct asymptotic is:
$$\mathbb{E}[f(x_T) - f^\star] \to \frac{\sigma^2\eta}{2(1-\beta^2)} > 0.$$
This does NOT match the OP-2 lower bound of $\Omega(\sigma D/\sqrt{T})$ in the sense of an upper bound — rather, it means the last iterate DOES NOT CONVERGE to $f^\star$ for fixed $\eta$, and the OP-2 lower bound for the $T$-dependent hard instance ($f^{(T)}_{\beta,\eta}$) is not in contradiction (since the hard instance changes with $T$).

### Critical lemmas

**Lemma F1 (SHB stationarity on quadratic).** For $f(x) = (L/2)x^2$ on $\mathbb{R}$, the SHB iterate satisfies $x_{t+1} = (1+\beta-\eta L)x_t - \beta x_{t-1} + \eta\xi_t$ where $\xi_t$ is i.i.d. zero-mean variance $\sigma^2$. This is a linear recurrence driven by noise. The pair $(x_t, x_{t-1})$ forms a Markov chain.

**Lemma F2 (Stationary distribution).** The Markov chain $(x_t, x_{t-1})$ has a unique Gaussian stationary distribution under stability ($(\beta,\eta) \in \mathcal{S}$) and ergodic convergence to it. The stationary variance of $x_t$ is:
$$\text{Var}_\infty(x_t) = \frac{\sigma^2\eta^2}{1 - (1+\beta-\eta L)^2 - \beta^2 + 2\beta(1+\beta-\eta L)\cdot r_{\text{lag}}}$$
where $r_{\text{lag}}$ is the lag-1 autocorrelation. A cleaner formula using the Vieta identity: $\text{Var}_\infty = \sigma^2\eta/(L(1-\beta^2))$ (from the algebraic identity $(1-r_1)(1-r_2) = \eta L$ and Parseval for stationary sequences).

**Lemma F3 (Convergence to stationary distribution).** For $(\beta,\eta) \in \mathcal{S}$, $\mathbb{E}[x_T^2]$ converges to $\text{Var}_\infty$ at an exponential rate (spectral radius of the noiseless operator):
$$\left|\mathbb{E}[x_T^2] - \text{Var}_\infty\right| \leq C \cdot \rho^T \cdot \|x_0\|^2$$
where $\rho = \max_j|r_j|^2 < 1$ (roots of the characteristic polynomial squared). Hence:
$$\mathbb{E}[f(x_T) - f^\star] = \frac{L}{2}\mathbb{E}[x_T^2] \geq \frac{L}{2}\left(\text{Var}_\infty - C\rho^T\|x_0\|^2\right) \geq \frac{L}{2}\cdot\frac{\sigma^2\eta}{2L(1-\beta^2)} > 0$$
for all $T \geq T_0$ (some explicit $T_0$).

**Lemma F4 (Contradiction with $\sigma D/\sqrt{T}$ bound).** If $\mathbb{E}[f(x_T) - f^\star] \leq C\sigma D/\sqrt{T}$ held for all $T$, then taking $T \to \infty$: $\text{Var}_\infty \leq 0$, a contradiction. Hence no constant $C$ makes $C\sigma D/\sqrt{T}$ a last-iterate UB for fixed $\eta$.

**Lemma F5 (Reconciliation with OP-2 LB).** The OP-2 lower bound uses a $T$-dependent function $f^{(T)}_{\beta,\eta}$ (the wall radius $R = D/\sqrt{2} - \sigma/(3L\sqrt{T})$ depends on $T$). For each fixed $T$, the LB $\Omega(\sigma D/\sqrt{T})$ holds. But these are different functions for each $T$ — the OP-2 LB does NOT claim: for a single fixed $f$, $\mathbb{E}[f(x_T)-f^\star] \geq c\sigma D/\sqrt{T}$ for all $T$. There is no contradiction.

### Difficulty

**Standard.** The quadratic stationary distribution computation is elementary (linear systems theory / spectral analysis). The Vieta identity $(1-r_1)(1-r_2) = \eta L$ (already proved in the κ-blowup analysis) gives the stationary variance formula cleanly. The refutation is concrete and verifiable numerically.

### Most likely failure mode

**Conceptual misunderstanding.** The refutation only applies to the fixed-$f$ setting. The OP-2 LB is for the optimal $T$-dependent choice of $f$. If someone asks "does fixed-momentum SHB have a last-iterate UB of the form $O(LD^2/T + \sigma D/\sqrt{T})$ for some $f$-independent bound?", the answer from Route F is: NO for any single fixed $f$ with fixed $\eta$, but YES for a $T$-dependent $f$ (matching OP-2's hard instance). This distinction is crucial for the paper's framing.

The route does NOT refute the OP-2 LB — it complements it by showing that the matching UB only exists in the $\forall$-$\exists$ sense (for each $T$, a different $f$), not in the $\exists$-$\forall$ sense (a single $f$ that achieves $\sigma D/\sqrt{T}$ rate for all $T$).

### Predicted rate

**Confirmed negative result:** Fixed-momentum SHB last iterate with fixed step-size $\eta$ has:
$$\liminf_{T\to\infty}\mathbb{E}[f(x_T) - f^\star] \geq \frac{\sigma^2\eta}{2(1-\beta^2)} > 0$$
on the quadratic $f(x) = (L/2)\|x\|^2$. The last-iterate UB $O(\sigma D/\sqrt{T})$ is FALSE for this fixed $f$.

**Implication for the paper:** The OP-2 lower bound is a $\forall$-$\exists$ result; any matching UB must also be $\forall$-$\exists$ (for each $T$, find $f$ achieving the bound), not $\exists$-$\forall$ (a single $f$ with decreasing rate). The current framing in the paper comparing OP-2's LB to GFJ15's UB is already in this $\forall$-$\exists$ mode, so Route F does not break the paper's claims — it strengthens them by explicitly showing why fixed $\eta$ prevents a clean uniform-in-$f$ last-iterate bound.

---

## Synthesis: The Noise-Floor Picture

All six routes point toward the same underlying phenomenon:

**Fixed-momentum SHB with fixed step-size $\eta$ on $L$-smooth convex (non-SC) functions has a last-iterate behavior that saturates at a positive noise floor $\sigma^2\eta/(L(1-\beta^2))$, rather than converging to $f^\star$.** This is a fundamental feature of fixed-$\eta$ stochastic algorithms.

The OP-2 lower bound $\Omega(\sigma D/\sqrt{T})$ is consistent with this: it uses a $T$-dependent hard instance (the wall function) that is specifically designed so that the variance term is large for exactly $T$ steps, avoiding the noise-floor saturation issue by changing the function at each $T$.

The upshot for the paper's framing:
- **Last-iterate UB matching the OP-2 LB:** Does NOT exist in the $\exists$-$\forall$ sense (no single $f$ achieves $\sigma D/\sqrt{T}$ decay for all $T$).
- **Last-iterate UB in the $\forall$-$\exists$ sense:** May hold with a constant noise floor $O(\sigma^2\eta/(L(1-\beta^2)))$ per fixed $f$, but this does NOT match the $\sigma D/\sqrt{T}$ form.
- **Consequence:** The OP-2 LB is tight against the class of $T$-dependent instances (each $T$ picks its own hard function), which is the standard minimax framework. The "missing UB" noted by the reviewer is a real gap: there is no matching $O(LD^2/T + \sigma D/\sqrt{T})$ last-iterate UB for a single fixed function.

---

## Final Ranking Table

| Route | Aim | Predicted outcome | Difficulty | Priority | Recommended? |
|---|---|---|---|---|---|
| **F (Refutation)** | Prove $\sigma D/\sqrt{T}$ UB is FALSE for fixed $f$, fixed $\eta$ | Succeeds: quadratic stationary distribution gives constant noise floor $\sigma^2\eta/(2(1-\beta^2))$ | Standard | 1 (highest) | **YES — assign Explorer 1** |
| **A (3-term Lyapunov)** | Prove last-iterate UB with explicit constants | Partial success: produces $O(LD^2/T + \sigma^2\eta/(L(1-\beta)^2))$ noise floor, not $\sigma D/\sqrt{T}$ | Research | 2 | **YES — assign Explorer 2** |
| **E (PEP/SDP Numerical)** | Numerically determine exact worst-case rate | Succeeds diagnostically: confirms noise floor vs $\sigma D/\sqrt{T}$ debate numerically | Standard (numerical) | 3 | **YES — assign Explorer 3** |
| **C (Sebbouh de-averaging)** | Extract explicit rate from Sebbouh et al. | Partial success: confirms fixed-$\eta$ stagnates; cannot extract $\sigma D/\sqrt{T}$ rate | Advanced | 4 | **YES — assign Explorer 4** |
| **D (Online-to-batch)** | Derive last-iterate bound via regret | Likely fails at domain confinement (Lemma D5); projected SHB gives $\sigma D/\sqrt{T}$ | Research | 5 | **YES — assign Explorer 5 (modified to projected SHB)** |
| **B (FTRL adaptation)** | Adapt Li-Liu-Orabona FTRL to fixed momentum | Likely fails: fixed momentum breaks FTRL stability; at best log-factor penalty | Research / Conjecture | 6 (lowest) | **OPTIONAL — assign Explorer 6 only if capacity allows** |

### Recommended Explorer assignments

1. **Explorer 1 → Route F (Refutation):** Prove the quadratic stationary distribution lower bound explicitly. Use Vieta identity $(1-r_1)(1-r_2) = \eta L$ to compute $\text{Var}_\infty = \sigma^2\eta/(L(1-\beta^2))$. State Theorem F clearly. This is the most important result: it clarifies the paper's scope.

2. **Explorer 2 → Route A (Lyapunov):** Set up the 3-term Lyapunov $V_t$ for SHB. Prove the best possible UB: $\mathbb{E}[f(x_T)-f^\star] \leq C_1 LD^2/T + C_2 \sigma^2\eta/(L(1-\beta)^2)$. This is the correct upper bound companion to OP-2's lower bound.

3. **Explorer 3 → Route E (PEP):** Run the stochastic PEP SDP for SHB at $T = 5, 10, 20, 30, 50$. Plot $\gamma^\star(T)$ vs $1/T$ and $1/\sqrt{T}$. Determine whether noise floor or $1/\sqrt{T}$ fits better. Report: is $\gamma^\star(T)$ converging to a constant or to zero?

4. **Explorer 4 → Route C (Sebbouh):** Read Sebbouh et al. §3–4 for fixed-momentum results. Identify whether their result applies to fixed $\eta$ or requires decreasing $\eta$. If fixed $\eta$: extract the noise floor expression. Compare with $\text{Var}_\infty$ from Route F.

5. **Explorer 5 → Route D (Online-to-batch, projected).** Analyze PROJECTED SHB (with projection onto $\{x: \|x-x^\star\| \leq D\}$) via online-to-batch. This gives $O(LD^2/T + \sigma D/\sqrt{T})$ last-iterate UB for the projected algorithm — a valid (though modified) UB that matches OP-2 exactly. Serves as a conditional positive result.

6. **Explorer 6 → Route B (FTRL, optional).** Only if Explorers 1–5 do not resolve the picture. Attempt to find an intermediate result: fixed momentum at best gives $\sigma D\sqrt{\log T}/\sqrt{T}$ rate via FTRL. If the log factor is unavoidable, this would explain why no clean matching UB exists.

### Honest feasibility assessment

| Route | Probability of producing a clean theorem | Impact if successful |
|---|---|---|
| F | 95% | High: clarifies the scope of OP-2's result and the missing UB |
| A | 70% | High: provides the correct UB companion ($\sigma^2/L$ noise floor) |
| E | 85% | Medium: numerical confirmation of noise floor |
| C | 50% | Medium: literature cross-check |
| D | 60% (projected SHB version) | Medium: gives matching UB for modified algorithm |
| B | 20% | Low: likely fails or produces log-penalty result |

**Overall conclusion:** The six routes collectively point to a coherent negative answer — the $O(\sigma D/\sqrt{T})$ last-iterate UB for fixed-momentum SHB does NOT hold for fixed $f$ with fixed $\eta$. The correct bound is $O(LD^2/T + \sigma^2\eta/(L(1-\beta^2)))$, where the variance term is a constant (noise floor). The paper's reviewer concern is valid: there is no matching stochastic last-iterate UB. The resolution is to clarify the $\forall$-$\exists$ scope of OP-2 and note that the noise-floor characterization is the correct upper bound companion.
