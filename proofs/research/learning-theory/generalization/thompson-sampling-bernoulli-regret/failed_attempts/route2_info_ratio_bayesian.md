## Proof
**Route**: Route 2 — Information Ratio (Russo–Van Roy), then frequentist conversion.

We prove the target theorem in two stages. Stage A establishes a **Bayesian** regret bound for Thompson Sampling (TS) on Bernoulli bandits via the information-ratio method. Stage B converts the Bayesian bound to a **frequentist** bound via a prior-perturbation / minimax reduction argument, producing the desired $O(\sqrt{KT\log T})$.

---

### Notation and setup

Throughout, $K$ denotes the number of arms and $T$ the horizon. Rewards are Bernoulli: $r_t\in\{0,1\}$ with $\Pr(r_t=1\mid I_t,\mu)=\mu_{I_t}$. We write $\Delta_k=\mu^*-\mu_k$ with $\mu^*=\max_k\mu_k$. For the Bayesian analysis we will introduce a prior $P_0$ on $\mu\in[0,1]^K$ and write $\mathbb{E}_{P_0}[\cdot]$ for expectation averaging over $\mu\sim P_0$ as well as all algorithmic/environmental randomness.

Let $\mathcal{F}_{t-1}=\sigma(I_1,r_1,\ldots,I_{t-1},r_{t-1})$ be the history $\sigma$-algebra before round $t$. Conditional expectation $\mathbb{E}_{t-1}[\cdot]:=\mathbb{E}[\cdot\mid\mathcal{F}_{t-1}]$ is taken under the joint law of $(\mu,I_1,r_1,\ldots)$ induced by $P_0$ and the TS policy.

**Key fact about TS (posterior-matching property).** For Thompson sampling started with prior $P_0$, at each round $t$ the conditional distribution of $I_t$ given $\mathcal{F}_{t-1}$ equals the conditional distribution of $A^*:=\arg\max_k\mu_k$ given $\mathcal{F}_{t-1}$:
$$\Pr(I_t=k\mid\mathcal{F}_{t-1})=\Pr(A^*=k\mid\mathcal{F}_{t-1}),\qquad \forall k\in[K]. \tag{$\star$}$$
This is because TS samples $\theta\sim P(\mu\mid\mathcal{F}_{t-1})$ and plays $I_t=\arg\max_k\theta_k$, which by definition of the posterior makes $I_t$ distributed as $A^*\mid\mathcal{F}_{t-1}$ (assuming ties have posterior measure zero, which holds for Beta posteriors because the posterior is absolutely continuous).

Let $\alpha_k:=\Pr(A^*=k\mid\mathcal{F}_{t-1})=\Pr(I_t=k\mid\mathcal{F}_{t-1})$. By $(\star)$, $I_t$ and $A^*$ have the same marginal under $\mathcal{F}_{t-1}$, though they are not independent.

Let $\mu_k^{(j)}:=\mathbb{E}[\mu_k\mid\mathcal{F}_{t-1},A^*=j]$ be the conditional mean of arm $k$'s reward given the history and that arm $j$ is optimal, and let $\bar\mu_k:=\mathbb{E}[\mu_k\mid\mathcal{F}_{t-1}]=\sum_j\alpha_j\mu_k^{(j)}$.

The **instantaneous Bayesian expected regret** is
$$\Delta_t:=\mathbb{E}_{t-1}[\mu^*-\mu_{I_t}]=\sum_j\alpha_j\mu_j^{(j)}-\sum_k\alpha_k\bar\mu_k. \tag{1}$$

The **instantaneous information gain** about $A^*$ from $(I_t,r_t)$ is
$$g_t:=I_{t-1}\!\left(A^*;(I_t,r_t)\right):=H(A^*\mid\mathcal{F}_{t-1})-\mathbb{E}_{t-1}\bigl[H(A^*\mid\mathcal{F}_{t-1},I_t,r_t)\bigr]. \tag{2}$$

The **information ratio** at round $t$ is
$$\Gamma_t:=\frac{\Delta_t^2}{g_t}. \tag{3}$$
(If $g_t=0$ we also have $\Delta_t=0$; define $\Gamma_t:=0$ by convention.)

---

### Step 1. Pointwise bound on the information ratio: $\Gamma_t\le K/2$.

We show the deterministic bound $\Delta_t^2\le \tfrac{K}{2}g_t$ at every round $t$, conditionally on $\mathcal{F}_{t-1}$.

**Step 1a. Numerator expansion.** Because $I_t$ and $A^*$ are conditionally identically distributed (with mass $\alpha_k$), using (1),
$$\Delta_t=\sum_k\alpha_k(\mu_k^{(k)}-\bar\mu_k)=\sum_k\alpha_k\bigl(\mathbb{E}[\mu_k\mid A^*=k,\mathcal{F}_{t-1}]-\mathbb{E}[\mu_k\mid\mathcal{F}_{t-1}]\bigr). \tag{4}$$

By Cauchy–Schwarz on $\mathbb{R}^K$ with weights $\sqrt{\alpha_k}\cdot\sqrt{\alpha_k}$:
$$\Delta_t^2=\left(\sum_k \sqrt{\alpha_k}\cdot \sqrt{\alpha_k}(\mu_k^{(k)}-\bar\mu_k)\right)^2\le\Bigl(\sum_k\alpha_k\Bigr)\cdot\sum_k\alpha_k(\mu_k^{(k)}-\bar\mu_k)^2=\sum_k\alpha_k(\mu_k^{(k)}-\bar\mu_k)^2. \tag{5}$$

**Step 1b. Denominator expansion via Bernoulli mutual information.**
Because observing $(I_t,r_t)$ when $I_t=k$ is equivalent (given $\mathcal{F}_{t-1}$) to observing a Bernoulli draw with conditional success probability determined by $A^*$, we have
$$g_t=\sum_k\alpha_k\cdot I_{t-1}(A^*; r_t\mid I_t=k). \tag{6}$$
This is the standard identity $I(X;(Y,Z))=I(X;Y)+I(X;Z\mid Y)$ combined with $I(A^*;I_t\mid\mathcal{F}_{t-1})=0$ (the sampling $I_t$ depends on $\mathcal{F}_{t-1}$ only, via independent Thompson sampling that marginalizes $A^*$—in fact $I_t$ and $A^*$ share the same marginal but the identity only uses that the sampler of $I_t$ does not receive extra info beyond $\mathcal{F}_{t-1}$).

Now condition also on $I_t=k$. Under this conditioning $r_t\sim\mathrm{Bernoulli}(\mu_k)$ with $\mu_k\mid\mathcal{F}_{t-1}$ a mixture: conditional on $\mathcal{F}_{t-1}$ and $A^*=j$, $r_t$ has mean $\mu_k^{(j)}$. Therefore
- Marginal law of $r_t$ given $(\mathcal{F}_{t-1},I_t=k)$ is $\mathrm{Bernoulli}(\bar\mu_k)$.
- Conditional law of $r_t$ given $(\mathcal{F}_{t-1},I_t=k,A^*=j)$ is $\mathrm{Bernoulli}(\mu_k^{(j)})$.

Using the standard identity for mutual information of a discrete conditional,
$$I_{t-1}(A^*;r_t\mid I_t=k)=\sum_j\alpha_j\,D_{\mathrm{KL}}\bigl(\mathrm{Bernoulli}(\mu_k^{(j)})\,\big\|\,\mathrm{Bernoulli}(\bar\mu_k)\bigr), \tag{7}$$
where the $\alpha_j$ weights come from the marginal $\Pr(A^*=j\mid\mathcal{F}_{t-1})$ being independent of $I_t$ (since $I_t$ is drawn using only $\mathcal{F}_{t-1}$-measurable data, $A^*\perp\!\!\!\perp I_t\mid\mathcal{F}_{t-1}$ fails in distribution but we are using the decomposition $I(X;Y\mid Z,W)$ written in KL form; (7) follows because given $I_t=k$ the posterior over $A^*$ is still $\alpha$ since $I_t$ is $\mathcal{F}_{t-1}$-measurable in law).

More rigorously: because $I_t$ is a measurable function of $\mathcal{F}_{t-1}$ and exogenous randomness independent of $(\mu, A^*)$, we have $A^*\perp\!\!\!\perp I_t\mid\mathcal{F}_{t-1}$. Hence the conditional distribution of $A^*$ given $(\mathcal{F}_{t-1},I_t=k)$ equals the one given $\mathcal{F}_{t-1}$, namely $(\alpha_j)_j$, and (7) is the definition of mutual information between $A^*$ (with prior $\alpha$) and $r_t$ with likelihood $\mathrm{Bernoulli}(\mu_k^{(A^*)})$.

**Step 1c. Pinsker-type lower bound.** By **Pinsker's inequality** applied to Bernoulli distributions,
$$D_{\mathrm{KL}}\bigl(\mathrm{Bernoulli}(p)\,\|\,\mathrm{Bernoulli}(q)\bigr)\ge 2(p-q)^2, \qquad p,q\in[0,1]. \tag{8}$$
This is the Bernoulli form of Pinsker [REF: proofs/library/statistics/concentration/pinsker-inequality]. Applying (8) with $p=\mu_k^{(j)},q=\bar\mu_k$,
$$I_{t-1}(A^*;r_t\mid I_t=k)\ge 2\sum_j\alpha_j(\mu_k^{(j)}-\bar\mu_k)^2. \tag{9}$$

Hence from (6) and (9),
$$g_t\ge 2\sum_{k}\alpha_k\sum_j\alpha_j(\mu_k^{(j)}-\bar\mu_k)^2. \tag{10}$$

**Step 1d. Isolating the diagonal term.** The right-hand side of (10) is at least $2$ times the diagonal term (keeping only $j=k$):
$$g_t\ge 2\sum_{k}\alpha_k\cdot \alpha_k(\mu_k^{(k)}-\bar\mu_k)^2=2\sum_k\alpha_k^2(\mu_k^{(k)}-\bar\mu_k)^2. \tag{11}$$

**Step 1e. Cauchy–Schwarz on the numerator (refined).** Return to (4). By Cauchy–Schwarz with weights $(\sqrt{\alpha_k},\sqrt{\alpha_k})$,
$$\Delta_t=\sum_k \alpha_k(\mu_k^{(k)}-\bar\mu_k)\le \sqrt{\sum_k 1}\cdot\sqrt{\sum_k \alpha_k^2(\mu_k^{(k)}-\bar\mu_k)^2}=\sqrt{K}\cdot\sqrt{\sum_k\alpha_k^2(\mu_k^{(k)}-\bar\mu_k)^2}. \tag{12}$$

(Here we split $\alpha_k=1\cdot\alpha_k$ and apply Cauchy–Schwarz to the two vectors $(1,\ldots,1)$ and $(\alpha_k(\mu_k^{(k)}-\bar\mu_k))_k$.)

**Step 1f. Combining.** Squaring (12) and using (11),
$$\Delta_t^2\le K\cdot\sum_k\alpha_k^2(\mu_k^{(k)}-\bar\mu_k)^2\le K\cdot\tfrac{1}{2}g_t=\tfrac{K}{2}\,g_t,$$
which is precisely $\Gamma_t\le K/2$. $\quad\square_{\text{Step 1}}$

**Remark (why Pinsker suffices).** In Russo–Van Roy (2016) the sharper refined Pinsker $D_{\mathrm{KL}}(\mathrm{Bern}(p)\|\mathrm{Bern}(q))\ge 2(p-q)^2$ already appears; the bound $K/2$ is tight up to constants for independent Beta priors.

---

### Step 2. Bayesian regret bound via Cauchy–Schwarz.

Total Bayesian regret is
$$\mathcal{R}^{\mathrm{Bay}}(T;P_0):=\mathbb{E}_{P_0}\!\left[\sum_{t=1}^T(\mu^*-\mu_{I_t})\right]=\mathbb{E}_{P_0}\!\left[\sum_{t=1}^T\Delta_t\right]. \tag{13}$$

Applying Cauchy–Schwarz to $\sum_t\Delta_t=\sum_t\sqrt{\Gamma_t g_t}$,
$$\sum_{t=1}^T\Delta_t\le\sqrt{\sum_{t=1}^T\Gamma_t}\cdot\sqrt{\sum_{t=1}^T g_t}\le\sqrt{T\cdot\max_t\Gamma_t}\cdot\sqrt{\sum_{t=1}^T g_t}. \tag{14}$$

By Step 1, $\Gamma_t\le K/2$ pointwise, hence $\sqrt{T\max_t\Gamma_t}\le\sqrt{KT/2}$.

---

### Step 3. Total information gain is bounded by $\log K$.

**Claim.** $\sum_{t=1}^T\mathbb{E}_{P_0}[g_t]\le H(A^*)\le\log K$.

**Proof.** Each $g_t=I_{t-1}(A^*;(I_t,r_t))=H(A^*\mid\mathcal{F}_{t-1})-\mathbb{E}[H(A^*\mid\mathcal{F}_t)\mid\mathcal{F}_{t-1}]$ using $\mathcal{F}_t=\sigma(\mathcal{F}_{t-1},I_t,r_t)$. Taking outer expectation and telescoping,
$$\sum_{t=1}^T\mathbb{E}[g_t]=\mathbb{E}\!\left[\sum_{t=1}^T\bigl(H(A^*\mid\mathcal{F}_{t-1})-H(A^*\mid\mathcal{F}_t)\bigr)\right]=H(A^*\mid\mathcal{F}_0)-\mathbb{E}[H(A^*\mid\mathcal{F}_T)]. \tag{15}$$

Since $\mathcal{F}_0$ is trivial, $H(A^*\mid\mathcal{F}_0)=H(A^*)\le\log K$ (entropy of a variable on $K$ values). The final entropy is $\ge 0$. Therefore
$$\sum_{t=1}^T\mathbb{E}[g_t]\le H(A^*)\le\log K. \tag{16}$$
$\square_{\text{Step 3}}$

---

### Step 4. Bayesian regret bound.

Taking expectation in (14) and using Cauchy–Schwarz again (this time in expectation — note (14) is itself pathwise, and since $\Gamma_t\le K/2$ deterministically, we may pull the bound out),
$$\mathcal{R}^{\mathrm{Bay}}(T;P_0)\le\mathbb{E}_{P_0}\!\left[\sqrt{\tfrac{KT}{2}\cdot\sum_{t=1}^T g_t}\right]\le\sqrt{\tfrac{KT}{2}\cdot\sum_{t=1}^T\mathbb{E}_{P_0}[g_t]}\le\sqrt{\tfrac{KT\log K}{2}}, \tag{17}$$
by Jensen ($\sqrt{\cdot}$ concave) in the second step and (16) in the last.

So for **any** prior $P_0$ on $[0,1]^K$,
$$\boxed{\mathcal{R}^{\mathrm{Bay}}(T;P_0)\le\sqrt{KT(\log K)/2}\le \sqrt{KT\log K}.} \tag{18}$$

In particular this holds when $P_0=\mathrm{Beta}(1,1)^{\otimes K}$ (the uniform prior used by TS), which is the prior matching TS's sampling rule.

---

### Step 5. Conversion to a frequentist bound.

We must pass from the Bayesian statement (18) to the frequentist statement
$$\mathcal{R}(T;\mu)\le C\sqrt{KT\log T}\qquad\text{uniformly in }\mu\in[0,1]^K.$$
We use a **prior-perturbation / minimax duality** argument.

**Step 5a. Minimax value.** Define
$$R^*(T):=\sup_{\mu\in[0,1]^K}\mathcal{R}(T;\mu),$$
the worst-case frequentist regret of the **specific** TS algorithm with $\mathrm{Beta}(1,1)$ prior. This is a function of $(T,K)$ only.

**Step 5b. Covering the parameter space.** Fix $T$ and set
$$\varepsilon:=\sqrt{\tfrac{\log T}{T}}. \tag{19}$$
Let $\mathcal{G}=\{\tfrac{i}{\lceil 1/\varepsilon\rceil}:i=0,1,\ldots,\lceil1/\varepsilon\rceil\}^K\subset[0,1]^K$ be an $\varepsilon$-grid in $\ell_\infty$ distance. Its cardinality is $|\mathcal{G}|\le(1+\lceil1/\varepsilon\rceil)^K\le(2\sqrt{T/\log T})^K$.

For any $\mu\in[0,1]^K$ let $\mu^{(\varepsilon)}\in\mathcal{G}$ be the closest grid point, so $\|\mu-\mu^{(\varepsilon)}\|_\infty\le\varepsilon$.

**Step 5c. Lipschitz continuity of regret in $\mu$ (at fixed algorithm).** The TS algorithm is a fixed (randomized) measurable policy from history to action; let $\pi=(\pi_t)_{t\ge1}$ denote it. For two reward parameters $\mu,\nu\in[0,1]^K$, let $\mathbb{P}_\mu^\pi,\mathbb{P}_\nu^\pi$ be the induced laws over length-$T$ trajectories $(I_1,r_1,\ldots,I_T,r_T)$.

The regret functional $R(\mu):=\mathbb{E}_\mu^\pi[\sum_t(\mu^*-\mu_{I_t})]$ satisfies
$$|R(\mu)-R(\nu)|\le\underbrace{T\cdot\|\mu-\nu\|_\infty}_{\text{change in integrand}}+\underbrace{T\cdot\|\mathbb{P}_\mu^\pi-\mathbb{P}_\nu^\pi\|_{\mathrm{TV}}}_{\text{change in measure}} . \tag{20}$$

The first term is bounded because the integrand $\sum_t(\mu^*-\mu_{I_t})$ is always in $[0,T]$ and the mapping $\mu\mapsto \mu^*-\mu_{I_t}$ is $2$-Lipschitz in $\|\cdot\|_\infty$ per $t$, giving $T\cdot 2\varepsilon$.

For the TV term: by Pinsker + tensorization of KL (chain rule),
$$2\|\mathbb{P}_\mu^\pi-\mathbb{P}_\nu^\pi\|_{\mathrm{TV}}^2\le D_{\mathrm{KL}}(\mathbb{P}_\mu^\pi\|\mathbb{P}_\nu^\pi)=\mathbb{E}_\mu^\pi\!\left[\sum_{t=1}^T D_{\mathrm{KL}}(\mathrm{Bern}(\mu_{I_t})\|\mathrm{Bern}(\nu_{I_t}))\right]. \tag{21}$$

For $p,q\in[\tfrac14,\tfrac34]$ we have $D_{\mathrm{KL}}(\mathrm{Bern}(p)\|\mathrm{Bern}(q))\le 4(p-q)^2$. Without loss of generality (else shift to this range; in general we get $D_{\mathrm{KL}}(\mathrm{Bern}(p)\|\mathrm{Bern}(q))\le (p-q)^2/(q(1-q))$) the KL is at most $c(p-q)^2$ on any closed subinterval of $(0,1)$. A slight technical point: if some $\nu_k\in\{0,1\}$ the KL may be infinite. Handled by restricting the grid to $\mathcal{G}\cap[\tfrac1T,1-\tfrac1T]^K$ and noting the correction is absorbed into $O(1)$.

Assuming the regime $\mu,\nu\in[\tfrac1T,1-\tfrac1T]^K$,
$$D_{\mathrm{KL}}(\mathbb{P}_\mu^\pi\|\mathbb{P}_\nu^\pi)\le cT\cdot\varepsilon^2=cT\cdot\tfrac{\log T}{T}=c\log T, \tag{22}$$
so $\|\mathbb{P}_\mu^\pi-\mathbb{P}_\nu^\pi\|_{\mathrm{TV}}\le\sqrt{(c/2)\log T}$. Combining with the first term of (20),
$$|R(\mu)-R(\nu)|\le 2T\varepsilon+T\sqrt{(c/2)\log T}=2\sqrt{T\log T}+T\sqrt{(c/2)\log T}. \tag{23}$$

This bound is too loose (grows as $T\sqrt{\log T}$): the TV-distance approach controls the whole measure but we only need to control the regret integrand, so we proceed differently.

**Step 5c' (better).** Use the **data-processing argument** directly on regret, which is itself a bounded functional:
$$\Bigl|R(\mu)-R(\mu^{(\varepsilon)})\Bigr|\le T\cdot\|\mu-\mu^{(\varepsilon)}\|_\infty+T\cdot\|\mathbb{P}_\mu^\pi-\mathbb{P}_{\mu^{(\varepsilon)}}^\pi\|_{\mathrm{TV}}. \tag{24}$$

Rather than covering once at scale $\varepsilon\asymp\sqrt{\log T/T}$, we instead use a **prior-concentration** argument as originally suggested.

**Step 5d. Sliding prior.** Fix an arbitrary target $\mu\in(0,1)^K$ (boundary handled by limits). Define a prior
$$P_0^\mu:=\bigotimes_{k=1}^K\mathrm{Beta}(a_k,b_k),\qquad a_k:=1+T\mu_k,\quad b_k:=1+T(1-\mu_k). \tag{25}$$
Under $P_0^\mu$, the coordinate $\mu_k$ is concentrated around $\mu_k$ with variance $\Theta(1/T)$: standard Beta variance formula gives $\mathrm{Var}(\mu_k)=\tfrac{a_kb_k}{(a_k+b_k)^2(a_k+b_k+1)}\le\tfrac{1}{4(T+2)}$.

Unfortunately, *this* sliding prior is not exactly the prior used by TS (which runs with $\mathrm{Beta}(1,1)$), so we cannot directly plug it into (18).

**Step 5e. Reduction via re-labelling the algorithm.** Key trick: the information-ratio bound (18) holds for the TS policy with **any** chosen prior $P_0$ — call this algorithm $\mathrm{TS}_{P_0}$. And for *any* fixed $\mu\in(0,1)^K$ and any prior $P_0$ with density $p_0>0$ on a neighborhood of $\mu$, the frequentist regret of $\mathrm{TS}_{P_0}$ at $\mu$ and at the prior mean get related via a likelihood-ratio (Radon–Nikodym) argument.

However, the target algorithm in the theorem is $\mathrm{TS}_{\mathrm{Beta}(1,1)}$, not $\mathrm{TS}_{P_0^\mu}$. So we need an argument that works with a fixed algorithm.

We use the following direct approach:

**Step 5f. Frequentist via Bayesian + discretization.** For any prior $P_0$,
$$\mathbb{E}_{\mu\sim P_0}[R(\mu)]=\mathcal{R}^{\mathrm{Bay}}(T;P_0)\le\sqrt{KT(\log K)/2}. \tag{26}$$

In particular, choose $P_0$ to be uniform over an $\varepsilon$-net $\mathcal{G}_\varepsilon\subset[0,1]^K$ of size $N=|\mathcal{G}_\varepsilon|\le(1+1/\varepsilon)^K$. Then
$$\min_{\nu\in\mathcal{G}_\varepsilon}R(\nu)\le\tfrac{1}{N}\sum_{\nu\in\mathcal{G}_\varepsilon}R(\nu)\le\sqrt{KT(\log K)/2}. \tag{27}$$

But (27) only bounds the *minimum* frequentist regret over the grid; we need the *supremum*.

**Step 5g. Supremum via worst-prior duality (minimax theorem).** The frequentist maximum regret of the TS algorithm equals the worst-case Bayesian regret over all priors — this is the standard statistical-decision minimax–Bayes duality *only when we are allowed to choose the algorithm in response to the prior*. For a **fixed** algorithm, Bayesian regret under any prior is a *lower* bound on worst-case frequentist regret, not an upper bound. So Route 2 does not yield a frequentist bound without further structure.

We reach here the core obstacle: **the information-ratio technique produces a Bayesian regret bound for TS run with a specific prior $P_0$; deriving a frequentist bound requires an auxiliary argument (e.g., a uniform-in-$\mu$ concentration of Beta posteriors used in Route 1).**

The literature resolves this as follows (Russo–Van Roy "An Information-Theoretic Analysis of Thompson Sampling" and "Learning to Optimize via Information-Directed Sampling"): the frequentist bound for TS is proved by **separate arguments** (the original Agrawal–Goyal frequentist proof), while the information-ratio machinery is presented as giving the Bayesian bound. A frequentist extraction is possible via the following trick.

**Step 5h. Frequentist via prior-concentration argument.** We prove

> **Lemma (prior-concentration).** For any $\mu^\star\in[0,1]^K$ and any $\delta\in(0,1/2)$, there is a prior $P_0$ on $[0,1]^K$ (depending on $\mu^\star,\delta$) such that:
> (a) under $P_0$, with probability $\ge 1-\delta$ we have $\|\mu-\mu^\star\|_\infty\le\delta$;
> (b) the frequentist regret of $\mathrm{TS}_{P_0}$ at parameter $\mu^\star$ satisfies
> $$\mathcal{R}(T;\mu^\star;\mathrm{TS}_{P_0})\le\tfrac{1}{1-\delta}\Bigl(\mathcal{R}^{\mathrm{Bay}}(T;P_0)+2T\delta\Bigr).$$

*Proof sketch of lemma.* Take $P_0$ to be $\mathrm{Beta}(1+n\mu^\star_k,1+n(1-\mu^\star_k))$ independently with $n=\lceil 4\log(1/\delta)/\delta^2\rceil$. Under $P_0$, $\mu_k$ has mean $\mu^\star_k$ and concentration $|\mu_k-\mu^\star_k|\le\delta$ with probability $\ge 1-\delta/K$ per arm (by a Hoeffding/Beta tail). Union bound gives (a).

For (b): let $E=\{\|\mu-\mu^\star\|_\infty\le\delta\}$. Then
$$\mathcal{R}^{\mathrm{Bay}}(T;P_0)\ge \mathbb{E}_{P_0}[R(\mu)\mathbb{1}_E]\ge\Pr(E)\cdot\bigl(\mathcal{R}(T;\mu^\star;\mathrm{TS}_{P_0})-2T\delta\bigr),$$
where $2T\delta$ accounts for the change of integrand on the event $E$ (regret functional is $2$-Lipschitz in $\|\mu\|_\infty$ per round, $T$ rounds). Rearranging,
$$\mathcal{R}(T;\mu^\star;\mathrm{TS}_{P_0})\le\tfrac{\mathcal{R}^{\mathrm{Bay}}(T;P_0)}{\Pr(E)}+2T\delta\le\tfrac{\sqrt{KT\log K}}{1-\delta}+2T\delta.$$

**However**, the lemma gives a frequentist bound on $\mathrm{TS}_{P_0}$, not on $\mathrm{TS}_{\mathrm{Beta}(1,1)}$. The target theorem is stated for TS with the specific Beta(1,1) prior.

**Step 5i. Comparing $\mathrm{TS}_{P_0}$ to $\mathrm{TS}_{\mathrm{Beta}(1,1)}$.** These two algorithms differ only in initial prior; after roughly $n$ steps their posteriors merge. Formally, by a change-of-measure / contiguity argument, letting $P_0^{(n)}$ be the $n$-step pseudo-observations embedded in the Beta prior parameters,
$$\|\mathcal{L}^{\mathrm{TS}_{P_0}}-\mathcal{L}^{\mathrm{TS}_{\mathrm{Beta}(1,1)}}\|_{\mathrm{TV}}\le O(\sqrt{n K/T})$$
on $T$-step trajectories, but this blows up unless $n\ll T/K$, which is consistent with our choice $n=O(\log T)$.

The full argument requires tracking these TV distances carefully (done in Agrawal–Goyal 2017, but not via the information-ratio route).

---

### Partial success / fallback.

Route 2 succeeds cleanly in proving the **Bayesian** bound:
$$\boxed{\mathcal{R}^{\mathrm{Bay}}(T;P_0)\le\sqrt{KT\log K/2}\quad\text{for any prior }P_0.}$$

The conversion to a **frequentist** bound for the *specific* algorithm $\mathrm{TS}_{\mathrm{Beta}(1,1)}$ requires a change-of-algorithm argument (Steps 5h–5i) that is technically separate from the information-ratio machinery and is most cleanly done via Route 1 (Agrawal–Goyal's direct frequentist proof).

**Where Route 2 gets stuck.** The information-ratio bound is fundamentally a *Bayesian* statement. The standard "frequentist extraction" via sliding priors (Step 5h) yields the frequentist regret of $\mathrm{TS}_{P_0^{\mu^\star}}$ at $\mu^\star$, not of $\mathrm{TS}_{\mathrm{Beta}(1,1)}$. Bridging these two algorithms re-introduces the full Agrawal–Goyal machinery (Route 1), defeating the simplification the information-ratio route was meant to provide.

Consequently, I record the **Bayesian bound** (18) as the complete, rigorous deliverable of Route 2, and report the frequentist bridge as the obstacle.

---

## Route Failure Report (partial)
- **Route**: Route 2 — Information Ratio / Russo–Van Roy.
- **Succeeded**: Steps 1–4 — complete rigorous proof of the Bayesian bound
  $$\mathcal{R}^{\mathrm{Bay}}(T;P_0)\le\sqrt{KT\log K/2}$$
  for Thompson Sampling with **any** prior $P_0$ on $[0,1]^K$, including $\mathrm{Beta}(1,1)^{\otimes K}$.
- **Failed at**: Step 5 (Frequentist Conversion).
- **Obstacle**: The information-ratio technique bounds *Bayesian* regret $\mathbb{E}_{\mu\sim P_0}R(\mu)$, which is a *weighted average* of frequentist regrets. Converting to a uniform-in-$\mu$ frequentist bound requires either:
  (i) a **minimax–Bayes duality** that applies only when the algorithm is allowed to depend on the prior (does not apply to the fixed $\mathrm{Beta}(1,1)$ TS), or
  (ii) a **sliding-prior** argument that concentrates a family $\{P_0^{\mu^\star}\}_{\mu^\star}$ near each $\mu^\star$ at scale $\delta$, yielding a frequentist bound for $\mathrm{TS}_{P_0^{\mu^\star}}$ but **not** for $\mathrm{TS}_{\mathrm{Beta}(1,1)}$; bridging these two algorithms requires an algorithm-comparison (change-of-prior) step which is essentially as involved as Route 1 (Agrawal–Goyal) itself.
- **What *can* be rescued**: the Bayesian bound (18) is sharper in $K$ than the target ($\sqrt{KT\log K}$ vs $\sqrt{KT\log T}$) and is a complete, clean theorem in its own right. It matches Russo–Van Roy (2016) Proposition 3.
- **Recommendation**: For the **frequentist** $O(\sqrt{KT\log T})$ bound, defer to Route 1 (Agrawal–Goyal direct proof via Beta-posterior concentration and good-event decomposition).

Q.E.D. (for the Bayesian half).
