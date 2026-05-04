# Discovery Agent 7 Report — Bandits + Diffusion + PAC-Bayes

Reverse-engineering the human discovery path for 7 information-theoretic / online-learning proofs.

---

## 1. EXP3 Adversarial Bandit Regret (Auer–Cesa-Bianchi–Freund–Schapire 2002)

### The Spark
**analogy-from-other-field** — Researchers had Hedge/Multiplicative-Weights for the *full-information* expert problem with $O(\sqrt{T \log K})$ regret; the spark was: *can we keep the exponential-weights skeleton when we only see one coordinate of the loss vector?*

### The Key Insight
The trick is that the entire Hedge potential argument is *deterministic* and only requires a loss vector to plug in — so replace the unobserved $\ell_t$ by an **importance-weighted unbiased estimator** $\hat\ell_t(i) = \ell_t(i)\mathbf 1[I_t = i]/p_t(i)$. The non-obvious part is realizing that this estimator can have variance $\Theta(K)$ even though $\ell_t \in [0,1]^K$, which forces a *forced exploration* mixture $\gamma/K$ to keep $1/p_t(i)$ bounded. Prior knowledge needed: Hedge analysis + importance sampling. Brute force cannot find this — the choice of mixing rate $\gamma$ couples three asymptotically-equal terms.

### The Technique Chain
- **Exponential-weights potential** ($\Phi_t = \ln W_t$) — *standard*, from Hedge / Littlestone–Warmuth, used unchanged.
- **Importance-weighted estimator** — *standard from MC integration*, repurposed to make the loss observable.
- **Inequality $e^{-x} \le 1 - x + x^2/2$** for $x \ge 0$ — *standard*, but here applied to $\eta\hat\ell_t$ which can be large; only valid for *non-negative* losses (a structural choice).
- **$\gamma$-mixing of $\tilde p_t$ with uniform** — *non-standard at the time*; introduced precisely to bound $\tilde p_t(i)/p_t(i) \le 1/(1-\gamma)$.
- **Three-term balancing** $\eta = \sqrt{\ln K/(KT)}$, $\gamma = K\eta$ — *standard* AM-GM-style optimization.

### The Construction
Not a hard-instance construction — but the *algorithm itself* is the construction. The $\gamma$-mixture is forced because without it, $1/p_t(i)$ is unbounded and the $\hat\ell_t^2$ term in the potential argument blows up. Removing the mixture, the regret bound becomes infinite.

### The Failure Modes
- **Plug bandit losses directly into Hedge** (no importance weighting): biased, no telescoping interpretation — the regret cannot be related to the unobserved arms.
- **Importance weighting without exploration** ($\gamma = 0$): $1/p_t(i) \to \infty$ when an arm is rarely played; second-moment bound diverges.
- **UCB-style confidence intervals**: works for stochastic bandits but adversarial losses break the i.i.d. structure UCB needs.

### The Discovery Path
1. Observe that Hedge gives optimal regret for full-information experts and ask whether bandit feedback can be handled.
2. First attempt: pretend missing coordinates are zero — gives biased estimates, no clean potential argument.
3. Insight: importance weighting makes the estimator unbiased, so the *deterministic* Hedge potential identity still holds pathwise.
4. Variance bound forces forced-exploration $\gamma/K$; tune $\eta, \gamma$ to balance three terms.
5. Verify the $3\sqrt{KT\ln K}$ bound and check the regime $\gamma \le 1/2$ (small $T$ trivial).

### Transferable Patterns
- **"Deterministic pathwise inequality + take expectation"** is a meta-pattern: do the algebra without expectations first, then plug in the unbiased estimator.
- **Forced exploration to control variance of importance weights** generalizes to off-policy RL, propensity-score estimation, and bandit-convex optimization.

---

## 2. Tweedie's Formula for Gaussian Perturbation (Robbins 1956 / Efron 2011 / Vincent 2011)

### The Spark
**pattern-spotted** (and honestly, **calculation-discovery**) — observe that for Gaussian convolution $p_\sigma = p_{\text{data}} * \varphi_\sigma$, the gradient of $\log p_\sigma$ has a clean closed form because the Gaussian *score* is linear in $x - y$.

### The Key Insight
The single non-obvious step: differentiate $p_\sigma(x) = \int p_{\text{data}}(y)\varphi_\sigma(x - y)\,dy$, pull the gradient onto the Gaussian factor (which gives the linear $-(x-y)/\sigma^2$), then *recognize* that $p_{\text{data}}(y)\varphi_\sigma(x-y)/p_\sigma(x)$ is the posterior density of $Y \mid X$ — turning the integral into a conditional expectation. This is genuinely **textbook material in disguise**: if you know Gaussian scores and Bayes' rule, the formula falls out in five lines. The "discovery" is recognizing that this trick lets you train a denoising network without ever computing $\nabla \log p_\sigma$ directly.

### The Technique Chain
- **Differentiation under the integral** — *standard*, dominated convergence with Gaussian envelope.
- **Gaussian score identity** $\nabla \log \varphi_\sigma(x - y) = -(x-y)/\sigma^2$ — *standard one-line computation*.
- **Bayes' rule reinterpretation** — *standard*, but the *recognition* is the discovery.
- **Tower property + complete-the-square** for the denoising-score-matching equivalence — *standard $L^2$ projection*.

### The Construction
None — Tweedie's formula is universal for Gaussian noise.

### The Failure Modes
- **Try to estimate $\nabla \log p_\sigma$ directly** by score matching with $\nabla\log$ of a parametric density (Hyvärinen 2005): requires costly second-derivative computation; Tweedie sidesteps this entirely.
- **Forget the $1/\sigma^2$ scaling**: many beginners write the score as $\mathbb E[Y|X] - x$ instead of $(\mathbb E[Y|X] - x)/\sigma^2$; the units are wrong.
- **Try non-Gaussian noise without modification**: the linearity of the Gaussian score is what makes the formula work; for Laplace noise you get a sign function, not a clean conditional expectation.

### The Discovery Path
1. Robbins (1956): empirical Bayes — given $X = Y + \text{noise}$, what is $\mathbb E[Y|X]$?
2. Differentiate the convolution density; algebra produces $\mathbb E[Y|X] - x$.
3. Insight (Vincent 2011): rewriting as $-\mathbb E[\varepsilon|X]/\sigma$ means we can train a noise-prediction network.
4. Complete-the-square argument shows this loss is equivalent to score matching with the unknown $\nabla\log p_\sigma$ as target.
5. This becomes the foundation of denoising diffusion models (DDPM, Song et al.).

### Transferable Patterns
- **Convolution + gradient + Bayes** is the recipe for any "score of a smoothed measure": use it whenever you smooth with a known kernel.
- **Reparameterizing an unknown target as a tractable conditional expectation** is the meta-trick behind variational inference, score matching, and diffusion training.

---

## 3. OFUL Linear Bandit Regret (Abbasi-Yadkori–Pál–Szepesvári 2011)

### The Spark
**gap-in-literature** — Auer's LinRel and Dani–Hayes–Kakade had $O(d\sqrt T \log^{3/2} T)$ regret with loose self-normalized concentration; the spark was *Can we get a tight $\tilde O(d\sqrt T)$ via a self-normalized martingale concentration on the sum $S_t = \sum_s \eta_s a_s$?*

### The Key Insight
The decisive idea is **the method of mixtures (Pinelis–Sakhanenko / de la Peña)**: instead of taking a fixed direction and applying scalar Bernstein, integrate the exponential-supermartingale $\exp(\langle\theta, S_t\rangle/R^2 - \|\theta\|_{A_t}^2/2R^2)$ against a *Gaussian prior* on $\theta$. The Gaussian integral evaluates explicitly, producing $\det(V_t)^{-1/2}\exp(\|S_t\|_{V_t^{-1}}^2/2R^2)$ — a *self-normalized* deviation that holds *uniformly in $\theta$ for free*. This requires knowledge of: (a) Bregman/exponential-supermartingale techniques, (b) Ville's inequality (stopping-time Markov), (c) the matrix-determinant lemma. Brute force absolutely cannot find this; it is the deepest single trick in modern linear bandits.

### The Technique Chain
- **Exponential supermartingale construction** $L_t(\theta)$ — *standard from sub-Gaussian theory*, source: Freedman / de la Peña.
- **Gaussian-mixture method** — *non-standard for bandits in 2011*, imported from self-normalized empirical-process theory (Pinelis).
- **Ville's inequality** — *standard*; turns "fixed-$t$ Markov" into "uniform-in-$t$ tail".
- **Matrix-determinant lemma** $\det(V_t)/\det(V_{t-1}) = 1 + \|a_t\|_{V_{t-1}^{-1}}^2$ — *standard*, used for telescoping potentials.
- **Elliptical potential / log-det telescoping** — *non-standard at the time*; the inequality $x \le 2\ln(1+x)$ for $x \in [0,1]$ couples the per-round bonus to a global $\log\det$ budget.
- **Optimism-in-the-face-of-uncertainty (OFU)** — *standard from UCB*, lifted to Banach-norm confidence ellipsoids.

### The Construction
Not a hard-instance construction; the *confidence ellipsoid* $\{\theta : \|\theta - \hat\theta_t\|_{V_t} \le \beta_t\}$ is the construction. Its specific form is forced by the self-normalized concentration: any larger ellipsoid loses regret; any smaller fails to contain $\theta^*$.

### The Failure Modes
- **Naive Bernstein on $\langle a, S_t\rangle$ for fixed direction $a$**: gives $O(d\sqrt T \log T)$ with extra log factors and fails to exploit the design-matrix structure.
- **Union bound over a discretized $\theta$-grid**: gives $\exp(d)$-many points, costing $d\log T$ per direction — looser than $\sqrt{d \log T}$ from the mixture.
- **Use UCB1 per arm**: there are infinitely many arms in $\mathbb R^d$; UCB doesn't generalize to the linear case without sharing information across arms.

### The Discovery Path
1. Observe LinRel/Confidence-Ball algorithms get $\tilde O(d^{3/2}\sqrt T)$ — too loose.
2. First attempt: tighten the per-direction concentration via standard Hoeffding/Bernstein — extra logs accumulate.
3. Insight: the right object is *self-normalized* $\|S_t\|_{V_t^{-1}}$, and Pinelis's mixture trick handles the uniformity in direction.
4. Combine with elliptical-potential telescoping (a clever use of matrix-determinant lemma) to bound $\sum \|a_t\|_{V_{t-1}^{-1}}^2$.
5. Verify the regret matches the $\Omega(d\sqrt T)$ lower bound up to logs.

### Transferable Patterns
- **Method of mixtures = "uniform-in-parameter Chernoff for free via Gaussian integration"** — used everywhere in modern online learning, contextual bandits, and confidence-set construction.
- **Elliptical potential lemma** is now a workhorse in linear RL theory (LinUCB, LSVI-UCB, neural tangent bandits).

---

## 4. Catoni's PAC-Bayes Bound (Catoni 2007)

### The Spark
**failure-of-natural-approach** — McAllester's PAC-Bayes bound has a $\sqrt{\mathrm{KL}/n}$ rate, but the constant in front of $\hat R_S$ is 1 only asymptotically; Catoni asked: *can we get a closed-form bound where the empirical-risk multiplier is sharp for any $\lambda > 0$?*

### The Key Insight
The crucial move is to define the random variable $W_S = \mathbb E_{h\sim P} e^{\phi_S(h)}$ — averaging the exponential moment over $h$ *under the prior $P$, not the posterior $Q$*. Then by Fubini, $\mathbb E_S[W_S] \le 1$, so Markov gives a uniform-in-$Q$ event $\{W_S \le 1/\delta\}$ on which Donsker–Varadhan can be applied to *every* posterior simultaneously. This decoupling — controlling moments under $P$ to get a uniform bound for arbitrary $Q$ — is the signature PAC-Bayes move. Prior knowledge: DV variational formula, Markov, sub-Bernoulli MGF. Brute force cannot find the right $\phi_S$ — its precise form $\lambda(R-\hat R) - nR\psi(\lambda/n)$ is engineered so $\mathbb E_S e^{\phi_S(h)} \le 1$ exactly.

### The Technique Chain
- **Sub-Bernoulli cumulant** $\psi(u) = u - 1 + e^{-u}$ — *standard from Bennett/Bernstein theory*; chord bound on $e^{-ux}$ over $[0,1]$.
- **Tensorization across i.i.d. samples** — *standard*, product of MGFs.
- **Donsker–Varadhan variational formula** — *standard*, but its use *as a change-of-measure on the hypothesis* is the PAC-Bayes signature.
- **Fubini-then-Markov** — *standard reordering*, but the *order* matters: averaging under $P$ first guarantees uniform-in-$Q$ validity.

### The Construction
The function $\phi_S(h) = \lambda(R(h) - \hat R_S(h)) - nR(h)\psi(\lambda/n)$ is the construction. The $-nR(h)\psi(\lambda/n)$ correction term is precisely what cancels the bias from the sub-Bernoulli MGF, ensuring $\mathbb E_S e^{\phi_S(h)} \le 1$. Drop this term and the bound becomes loose by a $\Theta(\lambda/n)$ factor.

### The Failure Modes
- **Apply DV directly to $R - \hat R$ without an MGF correction**: gives McAllester's $\sqrt{\mathrm{KL}/n}$ bound but with sub-optimal constants; cannot recover the $\lambda/(1 - e^{-\lambda/n})$ multiplier.
- **Try Hoeffding-style symmetric MGF**: misses the asymmetric Bernoulli structure; Catoni's $\psi$ exploits that losses are in $[0,1]$ from one side.
- **Markov before Fubini**: bound becomes posterior-dependent and loses the simultaneous-over-$Q$ property — the entire point of PAC-Bayes.

### The Discovery Path
1. Observe McAllester PAC-Bayes is tight asymptotically but suboptimal for finite $n$ at small empirical risk.
2. First attempt: just optimize $\lambda$ in McAllester — doesn't sharpen the empirical-risk coefficient.
3. Insight: encode the desired coefficient *in the test function itself* via the sub-Bernoulli correction $-nR(h)\psi(\lambda/n)$.
4. Verify $\mathbb E_S e^{\phi_S(h)} \le 1$, swap with Fubini, apply Markov + DV.
5. Polish: extract the explicit form $R(Q) \le \frac{\lambda/n}{1 - e^{-\lambda/n}}\hat R_S(Q) + \cdots$.

### Transferable Patterns
- **"Engineered exponential moment + DV"** is the master template for any PAC-Bayes-style bound (online MD, mirror descent regret, generalization for stochastic algorithms).
- **Fubini-before-Markov** to get uniform-in-posterior bounds is reused in Xu–Raginsky, MI generalization bounds, and information-theoretic privacy.

---

## 5. Thompson Sampling Bernoulli Regret (Agrawal–Goyal 2013/2017)

### The Spark
**gap-in-literature** — Thompson sampling was a 1933 heuristic with strong empirical performance but no regret guarantee until 2012; Agrawal–Goyal asked: *can we match the UCB $O(\sqrt{KT\log T})$ rate for TS without confidence intervals?*

### The Key Insight
The decisive step is the **posterior-dominance / inflation lemma**: $\Pr(I_t = k, \theta_k < y_k) \le \frac{1-p_t}{p_t}\Pr(I_t = 1, \theta_k < y_k)$, where $p_t = \Pr(\theta_1 > y_k|\mathcal F_{t-1})$. This relates "I pulled bad arm $k$" to "I pulled the optimal arm 1" via the *random* posterior probability $p_t$, exploiting the conditional independence of $\theta_1, \ldots, \theta_K$ given $\mathcal F_{t-1}$. The proof integrates over all coordinates *except* $\theta_1$ to expose the symmetric event. Prior knowledge needed: Beta–Binomial duality + careful conditional-independence accounting + moment bounds for $1/p_t$. Brute force fails — the right pivot $y_k = \mu_k + \Delta_k/2$ and the inflation factor $(1-p_t)/p_t$ are non-obvious.

### The Technique Chain
- **Beta–Binomial duality** $\Pr(\text{Beta}(s+1,f+1) \le y) = \Pr(\text{Binom}(s+f+1, y) \ge s+1)$ — *standard*, via differentiating both sides.
- **Hoeffding on Bernoulli sums** — *standard*, applied to translated Beta concentration.
- **Good-event decomposition** $G_k(t) = E_k^\mu \cap E_k^\theta$ — *standard from UCB analyses*; both empirical mean and posterior sample concentrate.
- **Posterior-dominance/inflation lemma** — *non-standard, this paper's key contribution*; integrates over $K-1$ independent coordinates.
- **Optional-skipping for pulls of arm $k$** — *standard from bandit theory*; rewards observed at random pull times remain i.i.d.
- **Moment bound on $1/p_{(n)}$** (AG 2013 Lemma 4) — *non-standard Beta-moment computation*; conditions on whether $\hat\mu$ is close to or far from $\mu^*$.
- **Gap-balancing** $\Delta^* = \sqrt{K\log T/T}$ to get problem-independent regret — *standard*.

### The Construction
The reference threshold $y_k = \mu_k + \Delta_k/2$ is the key construction. It is precisely the midpoint between $\mu_k$ and $\mu^*$; on the good event, $\theta_k$ concentrates within $\sqrt{L/n}$ of $\mu_k$, so $\theta_k \ge y_k$ requires $n \le 16L/\Delta_k^2$. Move the threshold and either the (a1) bound or the (a2) bound blows up.

### The Failure Modes
- **Apply UCB-style analysis directly**: TS is *Bayesian*, the pulls are not driven by deterministic confidence radii — the standard $\Delta_k^{-2}\log T$ argument doesn't apply.
- **Bound $\Pr(\theta_k > \mu^*)$ by a constant**: gives linear regret; you must use the *random* probability $p_t$ in the inflation lemma.
- **Independence approximation** of $\theta_k(t)$ across $t$: pulls are correlated via shared history $\mathcal F_{t-1}$; the optional-skipping technique is necessary.

### The Discovery Path
1. Observe TS empirically beats UCB but lacks a regret bound matching the lower bound.
2. First attempt: deterministic confidence-ellipsoid analysis fails because TS's "bonus" is random.
3. Insight: relate "pull a bad arm" to "pull the optimal arm" via the inflation factor $(1-p_t)/p_t$ — turning a Bayesian-sample event into a frequentist-counting event.
4. Compute moments of $1/p_{(n)}$ via Beta–Binomial duality + Hoeffding.
5. Sum, balance, verify $O(\sqrt{KT\log T})$ matches lower bound.

### Transferable Patterns
- **The inflation/dominance lemma is reused** for Thompson sampling in linear, contextual, and MDP settings (Russo–Van Roy, Osband–Van Roy).
- **"Decompose by good event $\times$ pivot threshold"** is a master pattern for any randomized algorithm that needs concentration both on the data side (empirical mean) and on the algorithm side (random sample).

---

## 6. Xu–Raginsky MI Generalization Bound (XR 2017 / Bu–Zou–Veeravalli 2020)

### The Spark
**analogy-from-other-field** — Russo–Zou (2016) had used mutual information to bound bias in adaptive data analysis; XR asked: *can the same MI machinery bound the generalization gap of *any* learning algorithm?*

### The Key Insight
The decisive abstraction: the generalization gap is the difference $\mathbb E_{\mathbb P_{W,Z_i}}[\ell] - \mathbb E_{\mathbb P_W \otimes \mathcal D}[\ell]$ — i.e., expectation against the *joint* vs. the *product* law of $(W, Z_i)$. Donsker–Varadhan + sub-Gaussianity (sub-Gaussian transport lemma) immediately translates this difference into $\sqrt{2\sigma^2 \mathrm{KL}(\text{joint}\|\text{product})} = \sqrt{2\sigma^2 I(W; Z_i)}$. The *additional* insight (BZV) is that doing this **per-sample** and then concavity-bounding via Jensen recovers (and strictly tightens) the original XR bound that used $I(W; S)$ for the entire sample. Prior knowledge: DV, sub-Gaussian transport, MI chain rule, joint convexity of KL. Brute force cannot find this — the abstract reframing of "generalization = product-vs-joint" is the discovery.

### The Technique Chain
- **Donsker–Varadhan variational formula** — *standard*, proved via auxiliary measure $Q_f \propto e^f Q$.
- **Sub-Gaussian transport lemma** $|\mathbb E_P f - \mathbb E_Q f| \le \sqrt{2\sigma^2 \mathrm{KL}(P\|Q)}$ — *standard from concentration / large deviations*; obtained by optimizing $\lambda$ in DV.
- **Per-sample decomposition** of the gap via i.i.d. structure and ghost samples $Z_i' \sim \mathcal D$ — *standard symmetrization-style move*.
- **Chain rule + joint convexity of KL** to prove $\sum I(W; Z_i) \le I(W; S)$ — *standard but subtle*; the inequality direction comes from Jensen on the convex KL functional.
- **Jensen on $\sqrt{\cdot}$** (concave) — *standard* final step from per-sample to whole-sample bound.

### The Construction
Not a hard instance — but the *ghost variable* $Z_i' \sim \mathcal D$ independent of $(W, S)$ is a virtual construction. It enables rewriting $\mathbb E[\ell(W, Z_i')] = \mathbb E[R_{\mathcal D}(W)]$ so the gap becomes a sum of "joint vs. product" comparisons.

### The Failure Modes
- **Try uniform convergence**: requires a fixed hypothesis class, fails for data-dependent $W$ — the very problem MI bounds solve.
- **Use scalar Hoeffding on $\ell(W, Z)$**: fails because $W$ depends on $S$, so the i.i.d. structure is broken.
- **Apply DV with $f = \ell$ and $P = \mathbb P_{W,S}$, $Q = \mathbb P_W \otimes \mathcal D^n$ in one shot**: gives the right answer but requires sub-Gaussianity of the *sum* of losses, which is harder to verify than the per-sample version.

### The Discovery Path
1. Russo–Zou (2016) used MI to bound bias from adaptive data analysis.
2. XR notice: generalization is the same kind of statement — output depends on data, want to bound difference of expectations.
3. First attempt: apply DV + sub-Gaussian transport to the *joint*-vs-*product* of $(W, S)$; gives $\sqrt{2\sigma^2 I(W;S)/n}$ after dividing by $n$.
4. BZV refinement: do it per-sample, then use Jensen + chain rule. Both inequalities can be strict.
5. Polish: write up as a strictly stronger result with concrete examples (subsampling).

### Transferable Patterns
- **"Generalization gap = expectation gap between joint and product law"** is a fundamental rewriting; it underlies all information-theoretic generalization bounds (chained MI, conditional MI, $f$-divergence variants).
- **Per-sample decomposition + Jensen** is a meta-technique for tightening any bound that aggregates information across i.i.d. data.

---

## 7. Matrix CE vs Standard CE Generalization (Conditional, ICML 2024-style)

### The Spark
**pattern-spotted** — ICML 2024 paper empirically observed that Matrix Cross-Entropy (MCE) used in SSL pretraining generalizes better than standard CE; the spark was: *what statistical mechanism explains this?*

### The Key Insight
The decisive observation is that MCE is a smooth function of the empirical *covariance matrix* $\hat\Sigma_\theta = \frac{1}{m}\sum_i f_\theta(x_i) f_\theta(x_i)^\top$, while CE is a function of *per-sample scalar losses*. Matrix Bernstein (Tropp) gives concentration of $\|\hat\Sigma - \Sigma\|_{\mathrm{op}}$ at scale $\sqrt{B^2\|\Sigma\|_{\mathrm{op}}/m}$ — replacing dimension by *intrinsic dimension* $r_{\mathrm{eff}}(\Sigma) = \mathrm{tr}\Sigma/\|\Sigma\|_{\mathrm{op}}$. When features are *low-rank* (the SSL regime), $\|\Sigma\|_{\mathrm{op}} \ll B^2$, beating Hoeffding-on-scalars. The price: $\log$ is operator-Lipschitz only with constant $1/\mu$ (spectral floor), forcing Tikhonov regularization. Prior knowledge: matrix Bernstein, operator-Lipschitz of $\log$ via integral resolvent representation, Berry–Esseen for the lower bound.

### The Technique Chain
- **Operator-Lipschitz of matrix log** via $\log A = \int_0^\infty (\frac{1}{1+t}I - (A+tI)^{-1})dt$ + resolvent identity — *standard from Bhatia*; floor $A \succeq \mu I$ gives Lipschitz constant $1/\mu$.
- **Trace–operator-norm Hölder** for bounding the linear-in-$\rho_*$ term — *standard*.
- **Matrix Bernstein with intrinsic dimension** (Tropp 2015 §7.3) — *standard but powerful*; dimension is replaced by $r_{\mathrm{eff}}$, the entire mechanism.
- **Tikhonov regularization** $\hat\Sigma \mapsto \hat\Sigma + \varepsilon I$ to enforce the spectral floor — *standard regularization*, here it is *necessary*, not optional.
- **Standard symmetrization + covering for uniform bound** over $\Theta$ — *standard Rademacher complexity*.
- **Berry–Esseen + lower-tail Gaussian** for the CE *lower bound* on the gap — *standard non-asymptotic CLT*; required to make the comparison strict.

### The Construction
The key "construction" is the loss-function design of MCE itself: by writing $\widehat L_{\mathrm{MCE}}(\theta) = -\mathrm{tr}(\rho_* \log \hat\rho_\theta)$, the loss is a *trace-functional of a matrix mean*, opening the door to matrix concentration. Standard CE is irrevocably a function of scalar per-sample losses. The Tikhonov $\varepsilon I$ is the second construction, bridging $\hat\Sigma$ to the spectral cone where $\log$ is Lipschitz.

### The Failure Modes
- **Compare CE and MCE via the same Hoeffding bound**: both are $O(1/\sqrt m)$, no separation.
- **Drop the spectral floor**: $\log$ is unbounded near zero; Lipschitz constant $\to \infty$; bound becomes vacuous.
- **Use matrix Hoeffding instead of matrix Bernstein**: loses the intrinsic-dimension factor; degrades to dimension-$d$ bound.
- **Bound CE generalization gap from above only**: the comparison is asymmetric — need a *lower* bound on CE gap to get strict inequality.

### The Discovery Path
1. Observe empirical: MCE-pretrained models generalize better on downstream tasks than CE-pretrained.
2. Note: MCE involves trace-of-matrix-log; CE is per-sample softmax-cross-entropy.
3. Insight: the right concentration tool is matrix Bernstein with intrinsic dimension, which replaces $d$ by $r_{\mathrm{eff}}(\Sigma) \le R$.
4. Lift via operator-Lipschitz of $\log$ (need spectral floor $\mu$ from Tikhonov).
5. Lower-bound the CE gap via Berry–Esseen using positive-variance assumption (C5); compare; identify the boxed condition $(\star)$ that guarantees strict separation.

### Transferable Patterns
- **"Intrinsic-dimension matrix concentration beats scalar Hoeffding when features are low-rank"** is a meta-pattern for any loss expressible as a smooth functional of an empirical matrix mean.
- **Lower-bound-the-baseline + upper-bound-the-improvement** is the standard pattern for proving an algorithm is *strictly* better than another, not just *no worse*.

---

## Summary

- **File written:** `C:\Users\12729\Desktop\Math\workspace\discovery_reports\agent_7.md`
- **Proofs analyzed:** 7 (EXP3, Tweedie, OFUL, Catoni PAC-Bayes, Thompson Sampling, Xu–Raginsky/BZV, Matrix CE generalization)
- **Most interesting cross-cutting observation:** Six of the seven proofs share a single meta-template — **"engineer an exponential supermartingale (or its mixture/integral) such that its expectation is bounded by 1, then apply Markov/Ville to get a uniform-in-something tail bound, then unpack via Donsker–Varadhan or completing the square."** This is the unifying skeleton of the method-of-mixtures (OFUL), Catoni PAC-Bayes, Xu–Raginsky/BZV, and even Thompson Sampling's good-event/inflation argument. EXP3 uses the deterministic Hedge potential as its "supermartingale stand-in"; only Tweedie's formula is genuinely outside this family — which is why Tweedie reads as a textbook calculation while the others read as research-level engineering.
