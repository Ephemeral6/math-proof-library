# C1.4 — Feasibility Analysis (STORM-style recursive momentum for MCMC ergodic averages)

**Purpose**: Determine whether STORM's $O(\sigma^{2/3}/T^{2/3})$-type variance reduction can be ported to MCMC ergodic averages $\hat{\pi}_T h = \frac{1}{T}\sum_{t=1}^T h(X_t)$, giving an accelerated rate for posterior expectations.

**Conjecture (to test)**: Under suitable mixing + smoothness assumptions, a STORM-momentum-augmented estimator $\tilde{\pi}_T h$ achieves
$$\mathbb{E}[(\tilde{\pi}_T h - \pi(h))^2] = O(\mathrm{Var}_\pi(h)/T^2)$$
improving on the standard Kipnis-Varadhan CLT rate $O(\sigma_{KV}^2/T)$.

---

## Q1. Descent-lemma analog

**STORM ingredient**: Smoothness-based descent lemma
$$f(x_{t+1}) \le f(x_t) - \eta \langle \nabla f(x_t), d_t\rangle + \tfrac{L\eta^2}{2}\|d_t\|^2$$
provides a Lyapunov function decreasing along iterates, anchoring the potential $\Phi_t = f(x_t) + \frac{\eta}{2a}\|e_t\|^2$.

**MCMC context**: There is **no function being minimized**. The Markov chain $X_t \sim P$ leaves $\pi$ invariant; $\hat\pi_T h$ is an average, not a sequence of optimization iterates. The natural Lyapunov candidate is a $\chi^2$- or KL-divergence $D(\mu_t\|\pi)$ of marginals, but $\hat\pi_T h$ depends on the *joint* trajectory, not just marginals — so the descent of $D(\mu_t\|\pi)$ (Poincaré inequality) does **not** directly control the estimator error.

**Verdict on Q1**: **No clean analog.** The STORM Lyapunov structure breaks at the first step because there is no minimization objective to descend in. Any "descent" would have to be on a secondary functional (Poisson-equation residual, control-variate gap), which is not what STORM tracks.

---

## Q2. Chain contraction $\rho$ vs STORM's $(1-a)$

**STORM recursion**: $d_t = \nabla f_t + (1-a)(d_{t-1} - \nabla f_{t-1}(x_t))$. The factor $(1-a) \in (0,1)$ is an **algorithm-design parameter**, freely chosen; the variance contraction comes from $(1-a)^2 \cdot \mathrm{Var}(e_{t-1}) + a^2\sigma^2$, giving $\mathrm{Var}(e_t) = O(a\sigma^2)$ in steady state.

**MCMC analog candidate**: The chain's spectral-gap contraction $\rho = 1 - \gamma \in (0,1)$, where $\gamma$ is the Poincaré/SG constant: $\|P\mu - \pi\|_{L^2(\pi)} \le \rho \|\mu - \pi\|_{L^2(\pi)}$.

**Mismatch**:
1. $(1-a)$ is **freely tunable**; $\rho$ is a **property of the chain**, fixed for a given sampler.
2. $(1-a)$ multiplies an **error term** $e_{t-1}$ in STORM; $\rho$ multiplies a **distribution-to-target distance** — different object. In STORM $e_t = d_t - \nabla f_t$ is a vector in the same space as the gradient; in MCMC the analog quantity would be $\nabla$-of-something that doesn't exist.
3. If one tries to *compose*: adding recursive momentum *on top of* a chain with contraction $\rho$ gives an effective smoothing factor $(1-a)\cdot \rho$ (or similar), **not** a replacement.

**Verdict on Q2**: $(1-a)$ and $\rho$ **do not interchange**. They are orthogonal mechanisms (one about algorithm-designed momentum, the other about sampler mixing). Any analog must treat them as **composable**, not substitutable.

---

## Q3. Regularity / mixing needed for the variance recursion

Even granting (against Q1–Q2) that one could define a STORM-analog recursion on MCMC sample estimates, the variance recursion would demand:

- **Geometric ergodicity** (uniform or at least $L^2(\pi)$) to control $\rho < 1$ uniformly.
- **$h$ bounded-Lipschitz** in the chain's natural metric (so $h(X_{t+1}) - h(X_t)$ is a controlled increment).
- **Small-step chain** (e.g., small-step MALA / small-step HMC, Langevin with small stepsize): so successive samples are close, and one-step differences $h(X_{t+1}) - h(X_t)$ are $O(\sqrt{\Delta t})$.
- **Smooth test function** $h$: so $\mathrm{Var}_\pi(h(X_{t+1})|X_t)$ is small.

**Fails for**: large-jump Metropolis, Gibbs with discrete blocks, any chain where successive samples can be far apart in the function-value metric.

**Verdict on Q3**: Hypotheses exist in principle but constrain to a **narrow class** of samplers (small-step diffusion-like). This is already the regime where Belomestny–Iosipoi et al. (arXiv:1903.07373, 1910.03643) have MCMC variance-reduction results — and their rates are **still Θ(1/T)**, not 1/T².

---

## Q4. **CRITICAL — Kipnis-Varadhan lower bound**

**Kipnis-Varadhan CLT (1986)**: For a reversible, ergodic Markov chain and $h \in L^2(\pi)$ with $\mathbb{E}_\pi h = 0$,
$$\sqrt{T}(\hat\pi_T h - \pi(h)) \xrightarrow{d} \mathcal{N}(0, \sigma_{KV}^2)$$
where $\sigma_{KV}^2 = \mathrm{Var}_\pi(h) + 2\sum_{k\ge 1}\mathrm{Cov}_\pi(h(X_0), h(X_k))$ is the asymptotic variance.

**Consequence**: $\mathrm{Var}(\hat\pi_T h) = \sigma_{KV}^2/T + o(1/T)$. This is a **CLT statement**, not just an upper bound: the rate $\Theta(1/T)$ is **tight** for any estimator that is an **unweighted linear functional of $T$ chain samples**, up to the asymptotic variance.

**Can STORM-momentum beat 1/T?**

Known ways to break the $\Theta(1/T)$ barrier:
1. **Zero-variance MCMC** (Mira, Assaraf–Caffarel): use a control variate $\phi$ solving the Poisson equation $(I - P)\phi = h - \pi(h)$, giving an estimator with variance 0 in principle. Practically, one *approximates* $\phi$ via basis expansion; variance reduction is a **constant factor**, not a rate improvement.
2. **Unbiased MCMC** (Jacob, O'Leary, Atchadé 2020; Rhee–Glynn): pair coupled chains, telescope to remove bias. Gives unbiased estimators with $\mathrm{Var} = \Theta(1/T)$ still — no rate improvement, just bias removal.
3. **Quasi-Monte Carlo / RQMC**: for i.i.d. $\Theta(1/T)$ → $\Theta(1/T^2)$, but requires independent samples, not Markov-chain samples.

**STORM's mechanism**: STORM's recursive momentum $d_t = g_t + (1-a)(d_{t-1}-g_{t-1}(x_t))$ achieves variance $O(a\sigma^2)$ (constant) via cancellation of one-step gradient differences under $L$-smoothness. The gradient cancellation works because consecutive iterates $x_{t-1}, x_t$ are close and $\|\nabla f(x_t) - \nabla f(x_{t-1})\| \le L\|x_t - x_{t-1}\|$ is $O(\eta)$, which is *smaller* than $\|\nabla f(x_t)\|$ itself — so the differences are low-variance.

**In MCMC**: the analog $h(X_t) - h(X_{t-1})$ has size $\Theta(1)$ (not vanishing with $T$), because the chain does not converge to a point — it *samples* the stationary distribution. The variance of $h(X_t) - h(X_{t-1})$ is $\Theta(\mathrm{Var}_\pi h)$, not $O(\eta^2)$. **There is no "smoothness towards a minimum" to exploit.**

**Key identity**: To beat $\Theta(1/T)$ one would need a control variate with $\mathrm{Var} \to 0$ as $T \to \infty$, which requires solving (asymptotically) the Poisson equation. STORM's recursion is **not** a Poisson-equation solver: it forms a running weighted average of past $h$-values, which, by Kipnis-Varadhan, has variance $\Theta(1/T)$.

**Verdict on Q4**: ⛔ **RED — the $O(1/T^2)$ rate violates the Kipnis-Varadhan CLT lower bound.** STORM's recursive momentum is structurally a smoothing operator on chain samples, not a Poisson-equation solver; it cannot beat $\Theta(1/T)$.

---

## Q5. Proof-template portability

| STORM ingredient | MCMC analog | Ports? |
|---|---|---|
| $L$-smoothness of $f$ | $h$ bounded-Lipschitz in natural metric | ✓ |
| Descent lemma on $f$ | — | ✗ (no objective) |
| Polarization identity $\langle \nabla f,d\rangle = \frac12(\|\nabla f\|^2 + \|d\|^2 - \|e\|^2)$ | $\pi(h) \in \mathbb{R}$ is **scalar**, not a vector | ✗ (identity doesn't type-check) |
| Recursive variance: $\mathrm{Var}(e_t) = (1-a)^2\mathrm{Var}(e_{t-1}) + a^2\sigma^2$ | Would require i.i.d. noise; chain samples are correlated | ✗ (cross-terms) |
| $a = \Theta(1/\sqrt{T})$ tuning | Can mechanically copy | ✓ syntactically, but meaningless given Q4 |
| Lyapunov $\Phi_t = f(x_t) + \frac{\eta}{2a}\|e_t\|^2$ | No $f$, no $\|\cdot\|$ on scalar $\pi(h)$ | ✗ |

**Verdict on Q5**: Only the *syntactic* $a$-tuning ports. The **Lyapunov/polarization structure does not port**: $\pi(h) \in \mathbb{R}$ is a scalar (or finite-dim if $h$ is vector-valued), so the key inner-product geometry that drives STORM's variance cancellation has no analog. Chain sample correlations further corrupt the variance recursion.

---

## Q6. Headline application (hypothetical)

*Had the rate been achievable*, the most compelling targets would have been:
1. **Bayesian neural network posterior predictive** — estimating $\mathbb{E}_\pi[f(\theta, x_\text{new})]$ where $\pi$ is the posterior. Currently $T \sim 10^3$–$10^4$ samples; a $1/T^2$ rate would reduce to $T \sim 10^{1.5}$–$10^2$.
2. **Log partition function (log-Z) estimation** via path sampling / annealed importance sampling — classical $\Theta(1/T)$.
3. **Posterior expectations in mechanistic-model inference** (ODE/PDE models in epidemiology, neuroscience).

**Stakeholder impact if rate were real**: 100×–1000× sample-efficiency improvement for MCMC-based Bayesian inference — would be a major result.

**Given Q4 RED verdict**: moot. No audience will accept a rate claim that violates Kipnis-Varadhan.

---

## Q7. Literature check — is this already done?

Targeted arXiv searches performed:

1. **"STORM MCMC"** / **"recursive momentum Markov chain"**: no direct hit. STORM was used in deep RL and optimization only.
2. **MCMC variance reduction with momentum**: Belomestny, Iosipoi, Moulines, Naumov, Samsonov — arXiv:[1903.07373](https://arxiv.org/abs/1903.07373), [1910.03643](https://arxiv.org/abs/1910.03643): control-variate methods using eigenfunctions of the generator / empirical spectral decomposition. **Constant-factor variance reduction at $\Theta(1/T)$ rate.** Not a rate improvement.
3. **Zero-variance MCMC**: Mira, Solgi, Imparato — various papers since ~2013. Constant-factor variance reduction via control variates; requires approximating Poisson equation. Not rate improvement.
4. **Unbiased MCMC with couplings**: Jacob, O'Leary, Atchadé 2020 (JRSS-B); Glynn–Rhee 2014. Removes bias while preserving $\Theta(1/T)$ variance. Not rate improvement.
5. **Rough paths / multilevel MCMC**: MLMC gives constant-factor variance improvement at $\Theta(1/T)$. Giles 2015.

**Observation**: The literature has explored **every plausible mechanism** for improving MCMC ergodic-average variance, and they all land at "constant-factor improvement at $\Theta(1/T)$" — consistent with Kipnis-Varadhan. **No paper claims $O(1/T^2)$** because it is information-theoretically impossible for a reversible ergodic chain.

---

## Identified blockers

| # | Blocker | Severity |
|---|---|---|
| B1 | **No descent-lemma analog**: MCMC is not minimization | Fundamental |
| B2 | **Polarization identity doesn't type-check**: $\pi(h)$ scalar, STORM's identity needs a vector inner product with an error term that decays toward 0 | Fundamental |
| B3 | **$O(1/T^2)$ violates Kipnis-Varadhan $\Theta(1/T)$ CLT lower bound** | ⛔ **Information-theoretic** |
| B4 | Chain-sample correlation breaks STORM's i.i.d.-noise variance recursion | Structural |
| B5 | Only narrow sampler class (small-step Langevin, bounded-Lip $h$) admits any analog at all; exactly the regime where Belomestny et al. already work at $\Theta(1/T)$ | Coverage |

---

## Possible salvage (YELLOW variant)

**Salvage 1 — Same rate, better constant**: Restate as "STORM-momentum MCMC achieves asymptotic variance $\sigma_{KV}^2 / T$ with provably smaller constant than naive ergodic average." This is achievable in principle but:
- Already the territory of Belomestny–Iosipoi (1903.07373) and Mira-style zero-variance MCMC.
- Would need to show the STORM-specific constant beats their eigenfunction-based constant — no a priori reason to believe this.
- Verdict: **rediscovery risk too high**.

**Salvage 2 — Variance reduction for small-$T$ transient**: Before the CLT kicks in (small $T$, high bias regime), STORM-momentum *might* reduce MSE = bias² + variance. But then it's a transient-phase paper, not a rate paper, and the audience shrinks dramatically.

**Salvage 3 — Drop MCMC, target a different "ergodic average"**: e.g., stochastic approximation (SA) with Markovian noise, per Li–Wai (2022) and others. Here the "objective" exists ($\theta^* = \mathbb{E}_\pi[\text{update}]$), so STORM's descent-lemma structure ports. **But this is no longer C1.4 — it's a known literature area and the result might already exist**.

---

## Final verdict

### ⛔ **RED** — fundamental information-theoretic blocker (Kipnis-Varadhan)

**Core issue**: The claimed $O(1/T^2)$ rate contradicts a well-established CLT lower bound. STORM's recursive momentum is a smoothing operator on correlated chain samples, not a Poisson-equation solver; the mechanism that gives variance reduction in optimization (smoothness-based gradient cancellation between close iterates $x_{t-1}, x_t$) **has no MCMC analog**, because chain samples $X_{t-1}, X_t$ do not converge to a point but continue to sample $\pi$.

**Secondary issues**: Even ignoring Kipnis-Varadhan, the proof template (descent lemma, polarization identity, Lyapunov $\|e_t\|^2$) does not type-check in the MCMC setting.

---

## Recommendation

**Abandon C1.4.** Move to the next candidate in the priority list:

### **Next candidate: C3.3 — one-agent perturbation generalization in potential games**

**Reminder** (from analogy_exploration.md): if a multi-agent game is a potential game and one agent's action is perturbed by a single-sample-replacement analog, does the potential $\Phi$ generalize? This was marked TRULY NEW in round-2 and has no direct overlap with known literature.

**Why promote**: 
- No identified information-theoretic blocker.
- Setup is constructive but not pathological (potential games are a standard object; single-agent perturbation is a natural analog of leave-one-out).
- Lands in the game-theory ∩ learning-theory intersection where the literature is less dense than MCMC variance reduction.

**Caveat / pre-work**: C3.3 requires defining the problem setup (what is "generalization" in a game-theoretic context?) before a proof can begin. This is a **modeling task**, not a proof task — should be the next step.

### Updated priority ranking

| Rank | Candidate | Status | Next step |
|---|---|---|---|
| 1 | ~~C1.4~~ | **RED-blocked** | Drop |
| 2 | C3.3 | Promoted | Modeling phase: define potential-game generalization |
| 3 | ~~C3.4~~ | **Subsumed (Kozachkov 2022)** | Drop |
| 4 | C3.4-salvage (SGD on permutations) | Niche, speculative | Hold |

---

## Sources consulted

- Cutkosky & Orabona 2019 — STORM (NeurIPS) — arXiv:[1905.10018](https://arxiv.org/abs/1905.10018). Main template.
- Kipnis & Varadhan 1986 — "Central limit theorem for additive functionals of reversible Markov processes" — Comm. Math. Phys. **Tight $\Theta(1/T)$ lower bound.**
- Belomestny, Iosipoi, Moulines, Naumov, Samsonov — arXiv:[1903.07373](https://arxiv.org/abs/1903.07373), [1910.03643](https://arxiv.org/abs/1910.03643) — empirical spectral control variates for MCMC variance reduction. Θ(1/T) rate.
- Mira, Solgi, Imparato — zero-variance MCMC line of work (various 2013+).
- Jacob, O'Leary, Atchadé 2020 (JRSS-B) — unbiased MCMC via couplings. Preserves Θ(1/T).
- Glynn & Rhee 2014 — unbiased estimators for Markov-chain ergodic averages.
- Giles 2015 — MLMC survey. Θ(1/T) for MCMC applications.
