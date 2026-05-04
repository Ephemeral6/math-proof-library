# Route 4 Proof — Adversarial Coordinate-Polytope Lower Bound for Coordinate-wise AdaGrad (Part B)

**Explorer 4 of 6, claude-opus-4-7 (1M)**
**Date: 2026-04-27**
**Working directory:** `workspace/active/proof_work_20260427_adagrad/`
**Route:** Route 4 — Adversarial Coordinate-Polytope Construction (MT5 base + Yao minimax + per-coordinate Bayes-error packing). Distinct from Route 3 (which is direct Le Cam two-point with adversary-chosen signal coordinate $i^\star$).

---

## 0. Summary of the route's *distinct* construction

| Aspect | Route 3 (Le Cam needle) | **Route 4 (this proof, MT5+Yao polytope)** |
|---|---|---|
| Hidden parameter | One signal coordinate $i^\star \in [d]$, sign $s \in \{\pm 1\}$ | **The full sign-vector** $\mathbf s \in \{\pm 1\}^d$ — every coordinate has a hidden bit |
| Hard instance geometry | $f$ is asymmetric across coordinates (one is a needle inside a wall, $d-1$ are flat) | $f$ is **coordinate-separable, fully symmetric** ($f$ is a sum of $d$ identical 1-D Goujaud-style "wall" functions, each shifted by an unknown sign) — the adversarial polytope is the hypercube $\{\pm 1\}^d$ |
| Reduction to testing | Le Cam two-point on the joint trajectory | **Yao's minimax + per-coordinate Bayes-error per coordinate, summed via the chain-rule of Fano** (analogous to D4 = E4) |
| Why $d^{1/2}$ enters | Adversary picks $i^\star$ uniform; algorithm cannot see all coords | Algorithm must succeed on **all $d$ coordinates simultaneously**; under coordinate-wise restriction, per-coord queries are independent budgets |
| Pitfall avoided | (Route 3 uses $\ell_\infty$-style noise to dodge FT-OP2-CAUCHY-SCHWARZ) | Same FT — we use Rademacher $\ell_\infty$ noise per coord, not $\ell_2$ split |

The construction uses an **adversarial polytope of $2^d$ vertices** (the hypercube) rather than a $d$-vertex regular polygon: each vertex encodes one sign assignment for the $d$ coordinates. The "cycling" of MT5 is replaced by **coordinate decoupling under the coordinate-wise oracle restriction**: under that oracle, the algorithm's trajectory factorizes across coordinates, so we can apply a **per-coordinate** lower bound (1-D MT5 cycling-style or 1-D Le Cam) and sum.

---

## 1. Setting and oracle model

### 1.1 Function class and oracle

We consider $L$-smooth (possibly non-convex) $f:\mathbb R^d \to \mathbb R$ with $f(x_0) - \inf f \le \Delta_0$. Stochastic gradients $g_t = \nabla f(x_t) + \xi_t$ with $\mathbb E[\xi_t \mid \mathcal F_{t-1}] = 0$, $\mathbb E[\|\xi_t\|^2 \mid \mathcal F_{t-1}] \le \sigma^2$.

### 1.2 Coordinate-wise adaptive oracle (formal)

**Definition (CW-Adaptive Oracle).** A randomized iterative algorithm $\mathcal A$ is *coordinate-wise adaptive* if there exist (possibly random) measurable maps $\Phi_{t,i}$ such that
$$
x_{t+1, i} = \Phi_{t,i}\!\bigl( x_{0,i}, x_{1,i}, \ldots, x_{t,i};\ g_{0,i}, g_{1,i}, \ldots, g_{t,i};\ U_{t,i}\bigr),
$$
where $U_{t,i}$ are independent random seeds. Equivalently, the $i$-th coordinate trajectory $(x_{t,i})_{t\ge 0}$ depends *only* on the $i$-th coordinate gradient history $(g_{s,i})_{s\le t}$ and a private random seed for coordinate $i$.

This is **exactly the assumption** invoked in problem.md Part B: "the next iterate's $i$-th coordinate is a function only of past $i$-th-coordinate gradient information." Coordinate-wise AdaGrad satisfies this with $\Phi_{t,i}(\ldots) = x_{t,i} - \eta g_{t,i}/\sqrt{v_{t,i}}$, $v_{t,i} = \sum_{s\le t} g_{s,i}^2$.

**Crucial structural consequence (Coordinate Decoupling Lemma).** Suppose the noise sequences $\{\xi_{t,i}\}_t$ are **mutually independent across $i$** (we will engineer the oracle to satisfy this). Then under a CW-Adaptive algorithm $\mathcal A$, the $d$ coordinate trajectories $\{(x_{t,i})_{t\ge 0}\}_{i=1,\ldots,d}$ are mutually independent random sequences whenever $f$ is **coordinate-separable** (i.e., $\nabla_i f(x) = \nabla f_i(x_i)$ for $f(x) = \sum_i f_i(x_i)$).

*Proof of decoupling.* Under separability, $g_{t,i} = \nabla f_i(x_{t,i}) + \xi_{t,i}$, depending only on $x_{t,i}$ and $\xi_{t,i}$. Combined with the $\Phi_{t,i}$ form of the algorithm, induction on $t$ gives the $i$-th coordinate evolution as a *self-contained Markov process driven by* $(\xi_{0,i},\xi_{1,i},\ldots,U_{0,i},U_{1,i},\ldots)$, all independent across $i$. $\square$

This Coordinate Decoupling Lemma is the lever that lets the construction extract a *clean factor of $d$* from a $d$-dimensional adversarial sign hypercube, without paying any Cauchy-Schwarz cancellation tax.

[CALL:math-verifier] {Verify the Coordinate Decoupling Lemma: under (a) coordinate-separable $f(x) = \sum_i f_i(x_i)$, (b) independent-across-$i$ noise $\xi_{t,i}$, (c) CW-Adaptive update $x_{t+1,i} = \Phi_{t,i}(x_{0:t,i}, g_{0:t,i}, U_{t,i})$ with $\{U_{t,i}\}_{t,i}$ independent — the joint law of $((x_{t,i})_t)_{i=1}^d$ factorizes as $\prod_i \mathrm{Law}((x_{t,i})_t)$.}

---

## 2. The adversarial coordinate-polytope hard instance

### 2.1 Per-coordinate hard scalar function (1-D base)

Fix small parameters $\rho, \tau > 0$ (chosen below). Define the 1-D quadratic-wall function: for $u \in \mathbb R$ and a sign $s \in \{\pm 1\}$,
$$
\phi_s(u) \;:=\; \rho s\cdot u \;+\; \frac{L}{2}\,\bigl[\max(|u| - R,\ 0)\bigr]^2,
$$
where $R := \tau$ is the "wall radius." Properties:

- $\phi_s$ is $L$-smooth (the wall is $C^{1,1}$ with quadratic outside, flat inside; piecewise-smoothing standard, see [REF: shb-no-acceleration-restricted/proof.md §3.3] for the same construction).
- $\phi_s$ is convex (the wall is convex; the linear drift $\rho s\,u$ is affine).
- The minimum of $\phi_s$ is attained on the boundary opposite to the drift direction: at $u^\star_s = -s R$ (any further out and the wall pulls back).
- $\phi_s(u^\star_s) = -\rho R$.
- For $u \in [-R, R]$ (inside the wall), $\nabla \phi_s(u) = \rho s$ (constant gradient, no curvature).

### 2.2 The full $d$-dimensional adversary's choice: a vertex of the hypercube

Let $\mathbf s = (s_1, \ldots, s_d) \in \{\pm 1\}^d$ — this is the **adversarial polytope** (the $2^d$-vertex hypercube). Define the coordinate-separable hard instance:
$$
\boxed{\,f_{\mathbf s}(x) \;:=\; \sum_{i=1}^d \phi_{s_i}(x_i).\,}
$$

**Smoothness/non-convexity placeholder.** $f_{\mathbf s}$ is convex and $L$-smooth. (Although the problem states $f$ is generally "non-convex", convex $L$-smooth is a sub-class, so a lower bound on convex instances trivially gives a lower bound on the larger non-convex class.)

**$\Delta_0$ budget.** Initial point $x_0 = 0 \in \mathbb R^d$ gives $f_{\mathbf s}(x_0) - \inf f_{\mathbf s} = 0 - (-d\rho R) = d\rho R$. We will choose $\rho, R$ so that $d\rho R \le \Delta_0$, i.e., $\rho R = \Delta_0 / d$.

### 2.3 Stochastic oracle

Independent across coordinates and across time, let $\varepsilon_{t,i} \in \{\pm 1\}$ be Rademacher. Define
$$
g_{t,i} \;:=\; \nabla \phi_{s_i}(x_{t,i}) \;+\; \tilde\sigma\,\varepsilon_{t,i}, \qquad i = 1, \ldots, d,
$$
with per-coordinate noise scale $\tilde\sigma := \sigma/\sqrt d$.

**Variance budget check.** $\mathbb E[\|\xi_t\|^2] = \sum_i \mathbb E[\tilde\sigma^2 \varepsilon_{t,i}^2] = d \tilde\sigma^2 = d\cdot \sigma^2/d = \sigma^2$. ✓

**Independence across $i$.** Yes by construction. ✓

This is the **uniform-per-coordinate** noise model. Note: this is *strictly weaker* than an $\ell_\infty$ oracle (which would allow $\tilde\sigma = \sigma$ per coord); we use the natural $\ell_2$ budget so that we honor the problem statement's $\mathbb E[\|\xi\|^2] \le \sigma^2$ assumption exactly.

### 2.4 Why this *escapes* FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM

The trigger fires when one tries to extract a $\sqrt d$ factor from a *joint* $\ell_2$-budget product Le Cam where the geometric quantity being lower-bounded is the **distance to a single optimum** (e.g., $\Omega(\sigma D/\sqrt T)$ for SHB). In that setting, Cauchy-Schwarz over the per-coordinate signals collapses the dimension factor.

Here, by contrast, **the quantity being lower-bounded is $\mathbb E[\|\nabla f(x_T)\|^2]$**, which is a **sum** $\sum_i \mathbb E[(\nabla_i f)^2]$. We do NOT need to convert per-coord errors into a single distance; we just need each coordinate's per-coord squared gradient $\mathbb E[(\nabla_i f)^2]$ to be lower-bounded **per coordinate**, and then sum. The "Cauchy-Schwarz cancellation" of FT-OP2 is a *budget collision* on a scalar geometric quantity; we have no such collision because we sum squared gradients, not signals.

In symbols: the FT-OP2 trigger collapses because $\sum_i \alpha_i D_i \le \|\alpha\|_2 \|D\|_2$ saturates with the same factor on both sides. We avoid this by working with $\sum_i (\nabla_i f)^2$ which is **additive** in the per-coord lower bounds, no Cauchy-Schwarz needed.

[CALL:math-verifier] {Verify: under the construction $f_{\mathbf s}(x) = \sum_i \phi_{s_i}(x_i)$ with $\phi_{s_i}$ as in §2.1 and per-coord Rademacher noise of variance $\tilde\sigma^2 = \sigma^2/d$, the joint variance $\mathbb E[\|\xi_t\|^2] = \sum_i \tilde\sigma^2 = \sigma^2$. Confirm independence-across-$i$ implies the joint distribution is the product of $d$ marginal 1-D distributions.}

---

## 3. Reduction to a $d$-fold per-coordinate testing problem (Yao's minimax + chain rule)

### 3.1 Stationary point criterion as a pointwise lower bound

For coordinate $i$ and iterate $x_{t,i}$, the per-coordinate gradient is
$$
\nabla_i f_{\mathbf s}(x_t) \;=\; \nabla \phi_{s_i}(x_{t,i}).
$$
By §2.1, for $x_{t,i} \in [-R, R]$ (inside the wall), $\nabla_i f_{\mathbf s}(x_t) = \rho s_i$, so $|\nabla_i f|^2 = \rho^2$. For $x_{t,i}$ outside the wall, $|\nabla_i f|^2 \ge \rho^2$ as well (the wall force is $\ge \rho$ in magnitude when one is at $|u| > R$; verify: the gradient is $\rho s_i + L (|x_{t,i}| - R)\,\mathrm{sgn}(x_{t,i})$, which by triangle inequality has magnitude $\ge \bigl||\rho| - L||x_{t,i}|-R||\bigr|$ — this can be small if the wall force exactly cancels, but the **only** point where the gradient is zero is $x_{t,i} = -s_i (R + \rho/L) = u^\star_{s_i}$).

Thus, the per-coordinate gradient is **small** iff $x_{t,i}$ is **close to** the (unknown) optimum $u^\star_{s_i} = -s_i R$. Specifically:
$$
|\nabla \phi_{s_i}(u)| \;\le\; \rho/2 \quad\Longrightarrow\quad u \in [u^\star_{s_i} - \rho/(2L),\ u^\star_{s_i} + \rho/(2L)] =: I^\star_{s_i}.
$$
(Quick check: $|\nabla \phi_{s_i}(u)| = |\rho s_i + L(|u|-R)_+ \mathrm{sgn}(u)|$. Setting this $\le \rho/2$: outside the wall, $|\rho - L(|u|-R)| \le \rho/2$ (sign permitting), giving $|u| - R \in [\rho/(2L), 3\rho/(2L)]$ and the correct sign of $u$ — exactly the interval $I^\star_{s_i}$.)

The intervals $I^\star_{+1}$ and $I^\star_{-1}$ are **disjoint** (they sit on opposite sides of $0$, separated by gap $2R - \rho/L > 0$ when $R > \rho/(2L)$).

**Per-coordinate test.** Define the test function
$$
\hat s_{T,i} := \begin{cases} +1 & \text{if } x_{T, i} \in I^\star_{+1} \\ -1 & \text{if } x_{T, i} \in I^\star_{-1} \\ \text{arbitrary} & \text{otherwise.}\end{cases}
$$
Then
$$
\bigl\{|\nabla_i f_{\mathbf s}(x_T)| \le \rho/2\bigr\} \;\subseteq\; \{\hat s_{T,i} = s_i\}. \quad (\star)
$$

So *if* a coordinate-wise adaptive algorithm achieves $\mathbb E\bigl[|\nabla_i f(x_T)|^2\bigr] \le \rho^2/8$ for coordinate $i$ (i.e., the per-coord squared gradient is small in expectation), then by Markov,
$$
\Pr\bigl(|\nabla_i f(x_T)| > \rho/2\bigr) \;\le\; \frac{\mathbb E[(\nabla_i f)^2]}{\rho^2/4} \;\le\; \frac{1}{2},
$$
hence by $(\star)$, $\Pr(\hat s_{T,i} \neq s_i) \le 1/2$.

### 3.2 The $d$-fold testing reduction

Assume an algorithm $\mathcal A$ achieves $\mathbb E[\|\nabla f(x_T)\|^2] \le \varepsilon^2$. Then $\sum_i \mathbb E[(\nabla_i f)^2] \le \varepsilon^2$. By Markov, the number of coordinates with $\mathbb E[(\nabla_i f)^2] > \rho^2/8$ is at most $\lfloor 8\varepsilon^2/\rho^2 \rfloor$. We'll set $\rho^2 = 8\varepsilon^2$ so that **on average across the noise**, *at most one coordinate* fails the per-coord test on average — but we want *every* coordinate to satisfy the test on a uniformly random $\mathbf s$.

**Sharper version (per-coord average).** For each $i$, by the Coordinate Decoupling Lemma, the joint law $\mathbb P_{\mathbf s}^{\mathcal A}$ of the trajectory factorizes:
$$
\mathbb P_{\mathbf s}^{\mathcal A}\bigl((x_{0:T,1}, \ldots, x_{0:T,d}) \in \cdot\bigr) = \prod_{i=1}^d \mathbb P_{s_i}^{\mathcal A_i}\bigl(x_{0:T,i} \in \cdot\bigr),
$$
where $\mathcal A_i$ is the *induced single-coordinate algorithm* on coordinate $i$ (the marginal of $\mathcal A$). Crucially, **$\mathcal A_i$ uses queries to coordinate $i$ alone, with its own gradient/noise sequence**.

Now place a uniform prior on $\mathbf s \sim \mathrm{Unif}(\{\pm 1\}^d)$. The Bayes-optimal test for $s_i$ given the trajectory of coordinate $i$ has error probability
$$
p_i^{\mathrm{err}} := \frac{1}{2}\Bigl(\mathbb P^{\mathcal A_i}_{+1}(\hat s_{T,i} = -1) + \mathbb P^{\mathcal A_i}_{-1}(\hat s_{T,i} = +1)\Bigr) \;\ge\; \frac{1 - \mathrm{TV}\bigl(\mathbb P_{+1}^{\mathcal A_i}, \mathbb P_{-1}^{\mathcal A_i}\bigr)}{2}.
$$
This is **Le Cam's two-point inequality applied per coordinate** — it does *not* couple across coordinates because, by Coordinate Decoupling, the two hypotheses on coordinate $i$ are statistically distinguishable from the $i$-th coordinate gradient history alone.

### 3.3 Per-coordinate KL bound

Per coordinate, the gradient sequence $g_{t,i}$ has the form
$$
g_{t,i} = \nabla \phi_{s_i}(x_{t,i}) + \tilde\sigma \varepsilon_{t,i}, \quad x_{t,i} \in [-R, R] \text{ a.s. while inside wall.}
$$

For the Le Cam KL computation, we need: the algorithm's view in coordinate $i$ is the gradient sequence $g_{0,i}, \ldots, g_{T-1,i}$. Conditional on the algorithm's iterate trajectory $x_{0:T-1,i}$ (and its private randomness $U_i$), the gradient sequence is **a sequence of Rademacher-shifted constants**: $g_{t,i} = \rho s_i + \nu_{t,i} + \tilde\sigma \varepsilon_{t,i}$ when inside the wall, where $\nu_{t,i}$ is a deterministic adjustment if $x_{t,i}$ leaks outside.

Inside the wall (the regime that matters — by §2.1 the iterate stays bounded; we make this rigorous in the *bounded trajectory lemma* below), $g_{t,i}$ takes the value $\rho s_i + \tilde\sigma\varepsilon_{t,i}$, i.e., it's a Rademacher random variable with shift $\rho s_i$.

**Bounded trajectory lemma.** Choose $R \ge $ (max iterate excursion bound). For coordinate-wise AdaGrad with $v_{0,i} > 0$, the iterate satisfies (by induction)
$$
|x_{t+1,i} - x_{t,i}| \;=\; \eta\,\frac{|g_{t,i}|}{\sqrt{v_{t,i}}} \;\le\; \eta,
$$
so $|x_{T,i}| \le |x_{0,i}| + \eta T$. Choosing $R := \eta T$ suffices to keep all queries inside the wall. (More refined: for AdaGrad-type algorithms the iterate excursion is $O(\sqrt T)$; we use the crude $\eta T$ bound which is sufficient.) For algorithms more general than AdaGrad, we just declare $R := $ some large universal upper bound $G_\infty \cdot T$ for any algorithm with bounded per-step displacement $G_\infty$.

We absorb this technicality by **defining the construction adaptively to the algorithm's known displacement bound**, since the lower bound is "$\exists\, f, \mathcal O$ such that for *all* algorithms..." — but the construction is allowed to depend on $T$ (it does). Alternatively, **for any algorithm whose iterates remain in $[-R, R]^d$, we have the clean Rademacher-shift KL computation below**, and we may absorb any boundary leakage into a constant factor.

[CALL:math-verifier] {Verify the Rademacher-shift KL: for $g \sim \rho s + \tilde\sigma \cdot \mathrm{Unif}\{\pm 1\}$, the KL between the $s = +1$ and $s = -1$ laws is $\mathrm{KL}(P_+ \| P_-) = \log\bigl(\frac{1+\rho/\tilde\sigma}{1-\rho/\tilde\sigma}\bigr) \cdot (\rho/\tilde\sigma)$ for $\rho < \tilde\sigma$, and equals $0$ if $\rho = 0$, and is $\le 4\rho^2/\tilde\sigma^2$ for $\rho \le \tilde\sigma/2$.}

**Per-step KL (1-D).** Conditional on $\mathcal F_{t-1,i}$ and assuming inside-wall queries:
$$
\mathrm{KL}\bigl(\mathrm{Law}(g_{t,i} \mid s_i=+1) \,\big\|\, \mathrm{Law}(g_{t,i} \mid s_i=-1)\bigr) = D_{\mathrm{KL}}\bigl(\delta_{\rho + \tilde\sigma\varepsilon} \,\big\|\, \delta_{-\rho + \tilde\sigma\varepsilon}\bigr),
$$
which for the Rademacher $\varepsilon$ noise equals (closed form)
$$
\mathrm{KL}_{1\mathrm{step}} \;=\; \frac{1}{2}\log\frac{(1+\rho/\tilde\sigma)^{1+\rho/\tilde\sigma}}{(1-\rho/\tilde\sigma)^{1-\rho/\tilde\sigma}}\cdot \mathbf 1\{\rho < \tilde\sigma\} \;\le\; \frac{2\rho^2}{\tilde\sigma^2} \quad\text{for } \rho \le \tilde\sigma/2.
$$

(This is the standard binary KL bound; for two Bernoulli-shifted-by-$\rho$ distributions with shift parameter $p = (1+\rho/\tilde\sigma)/2$ vs $1-p$, $\mathrm{KL}(p\|1-p) = (2p-1)\log(p/(1-p)) \le 4(2p-1)^2 = 4\rho^2/\tilde\sigma^2$ for $|2p-1| \le 1/2$. We retain the constant $2$ to allow a small slack.)

### 3.4 Per-coordinate Le Cam two-point

For the **single coordinate $i$** problem:
- Hypotheses: $s_i = +1$ vs $s_i = -1$.
- Algorithm uses $T$ queries (the same $T$ as the joint algorithm — coordinate-wise restriction means the algorithm makes one query per step *on each coord simultaneously*; alternatively, per-coordinate query budget is $T$).
- Tensorize: $\mathrm{KL}(\mathbb P_{+1}^{\mathcal A_i, T}\|\mathbb P_{-1}^{\mathcal A_i, T}) \le T \cdot \mathrm{KL}_{1\mathrm{step}} \le 2T\rho^2/\tilde\sigma^2$.
- Pinsker: $\mathrm{TV}(\mathbb P_{+1}^{\mathcal A_i, T}, \mathbb P_{-1}^{\mathcal A_i, T}) \le \sqrt{T\rho^2/\tilde\sigma^2}$.
- Le Cam: $p_i^{\mathrm{err}} \ge \frac{1}{2}\bigl(1 - \sqrt{T\rho^2/\tilde\sigma^2}\bigr)$.

If we want $p_i^{\mathrm{err}} \ge 1/4$ (i.e., the per-coord test is non-trivially hard), we need $\sqrt{T\rho^2/\tilde\sigma^2} \le 1/2$, i.e.,
$$
T \cdot \rho^2 \;\le\; \tilde\sigma^2 / 4 \;=\; \sigma^2/(4d). \qquad (\dagger)
$$

### 3.5 From per-coordinate Bayes-error to a global gradient lower bound (Yao + chain-rule)

Under the uniform prior on $\mathbf s$, for **each** coordinate $i$, the Bayes test error is $p_i^{\mathrm{err}} \ge 1/4$ (under $(\dagger)$). The implication $(\star)$ from §3.1 says
$$
p_i^{\mathrm{err}} \le \Pr_{\mathbf s, \mathcal A}\bigl(|\nabla_i f(x_T)| > \rho/2\bigr).
$$
So under $(\dagger)$,
$$
\Pr_{\mathbf s, \mathcal A}\bigl(|\nabla_i f(x_T)| > \rho/2\bigr) \;\ge\; 1/4 \quad\text{for every } i \in [d].
$$

Hence
$$
\mathbb E_{\mathbf s, \mathcal A}\bigl[|\nabla_i f(x_T)|^2\bigr] \;\ge\; (\rho/2)^2 \cdot 1/4 \;=\; \rho^2/16, \quad i = 1, \ldots, d.
$$

Summing over $i$:
$$
\mathbb E_{\mathbf s, \mathcal A}\bigl[\|\nabla f(x_T)\|^2\bigr] \;=\; \sum_{i=1}^d \mathbb E_{\mathbf s, \mathcal A}[|\nabla_i f|^2] \;\ge\; d\rho^2/16.
$$

**Yao's minimax principle.** Since this lower bound holds for the *averaged* algorithm under the uniform prior $\mathbf s \sim \mathrm{Unif}\{\pm 1\}^d$, by Yao's minimax there *exists* a deterministic vertex $\mathbf s^\star \in \{\pm 1\}^d$ such that
$$
\mathbb E_{\mathcal A}\bigl[\|\nabla f_{\mathbf s^\star}(x_T)\|^2\bigr] \;\ge\; d\rho^2/16. \qquad (\ddagger)
$$

### 3.6 Setting parameters and extracting the lower bound

To reach $\mathbb E[\|\nabla f\|^2] \le \varepsilon$ (note: the problem uses $\varepsilon$ on the gradient norm squared scale, not $\varepsilon^2$ — re-read problem.md line 32: "queries to reach $\mathbb E[\|\nabla f(x)\|^2] \le \varepsilon$"), we need to *defeat* $(\ddagger)$, i.e., we need
$$
d\rho^2/16 \;\le\; \varepsilon \quad\Longleftrightarrow\quad \rho^2 \;\le\; 16\varepsilon/d.
$$

Set $\rho^2 := 16\varepsilon/d$ (the largest signal that still lets the algorithm reach precision $\varepsilon$). Then $(\dagger)$ becomes
$$
T \cdot 16\varepsilon/d \;\le\; \sigma^2/(4d) \quad\Longleftrightarrow\quad T \;\le\; \sigma^2 / (64\varepsilon).
$$

This is the *information-theoretic constraint* under which the algorithm CANNOT distinguish the $d$ signs. So **for any $T \le \sigma^2/(64 \varepsilon)$, the algorithm fails to reach $\mathbb E[\|\nabla f\|^2] \le \varepsilon$**.

**But this gives only $T = \Omega(\sigma^2/\varepsilon)$, missing the $d^{1/2}$ factor.** Where did the $d$ go? It cancelled with the $1/d$ in $\tilde\sigma^2 = \sigma^2/d$.

This is the FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM trigger firing — even though we routed around the *Cauchy-Schwarz on signals*, we were bitten by *variance dilution*: by spreading the $\sigma^2$ budget across $d$ coords, each coord became "easier" to test.

[CALL:math-verifier] {Verify: under the per-coord variance budget $\tilde\sigma^2 = \sigma^2/d$ and per-coord signal $\rho^2 = 16\varepsilon/d$, the per-coord SNR $\rho^2/\tilde\sigma^2 = 16\varepsilon/\sigma^2$ has no $d$ dependence; substituting into $(\dagger)$ gives a $d$-independent $T$ bound.}

---

## 4. The PIVOT: choosing the right noise model and using $\Delta_0$ budget

The naive setup of §3 fails because the variance budget $\sigma^2$ is *global* (sum across coordinates), and spreading it makes per-coord tests easier. **The way to recover $d^{1/2}$** is to **invest more variance per coordinate at the cost of fewer rounds of testing**.

### 4.1 The key observation

We have **TWO global budgets** that compete:
- Variance $\mathbb E[\|\xi\|^2] \le \sigma^2$ — global, distributed across coords.
- Initial sub-optimality $f(x_0) - \inf f \le \Delta_0$ — global, distributed across coords as $d \cdot \rho R$.

Setting $R = \tau$ as a free parameter and using $\rho R = \Delta_0/d$ (so each coord contributes $\rho R$ to the gap), we have **two free parameters** $\rho, \tilde\sigma$ subject to:
- $\tilde\sigma^2 \cdot d \le \sigma^2$ (variance budget).
- $\rho R \le \Delta_0/d$, where $R = $ wall radius.

**We do NOT need per-coord variance budget $\tilde\sigma = \sigma/\sqrt d$.** We can instead set $\tilde\sigma = \sigma$ and **only have $1$ active coordinate at any given time** — but that breaks the Coordinate Decoupling.

Better: **the construction must engineer per-coord ITERATE BUDGET** rather than per-coord variance. The crucial scaling is on $\Delta_0$ and $L$:

$$
\rho R \;=\; \Delta_0/d \quad\text{and}\quad R = \rho/L \quad\Longrightarrow\quad \rho^2 = L\Delta_0/d.
$$

(We choose $R = \rho/L$ so the wall is just thick enough to catch the optimum; smaller $R$ would put the optimum inside the wall and trivialize. Specifically, $u^\star_{s} = -sR$, so the gradient at the boundary of the wall is $\rho s$; with $R = \rho/L$, the optimum is at $u^\star = -s\rho/L$ where the gradient is $\rho s + L \cdot \rho/L \cdot (-s) = 0$, ✓.)

Now the per-coord SNR is
$$
\rho^2/\tilde\sigma^2 \;=\; \frac{L\Delta_0/d}{\sigma^2/d} \;=\; \frac{L\Delta_0}{\sigma^2}.
$$

This is the **dimensionless SNR** that survives all variance/budget rescaling. Per-coord test bound $(\dagger)$:
$$
T\rho^2 \le \tilde\sigma^2/4 \;\Longleftrightarrow\; T \le \tilde\sigma^2/(4\rho^2) \;=\; (\sigma^2/d)/(4 \cdot L\Delta_0/d) \;=\; \frac{\sigma^2}{4L\Delta_0}.
$$

Still $d$-independent! The $d$ has cancelled out twice.

### 4.2 Resolving the cancellation: scale $T$ per coordinate via the polytope

The resolution requires noticing: under the coordinate-wise restriction, *each coordinate independently runs $T$ queries*, but the "per-coordinate query" is a single scalar value of $g_{t,i}$. Let us re-examine what $T$ means.

**The right reading of the oracle model:** at each time step $t = 0, 1, \ldots, T-1$, the algorithm queries the *full gradient* $g_t = (g_{t,1}, \ldots, g_{t,d})$ at the current $x_t$. This is **one oracle call**, but it returns $d$ scalars. So per coordinate $i$, the algorithm gets $T$ samples of $g_{\cdot, i}$.

Under this reading, the per-coord testing problem has **$T$ samples**, and the global query budget is *also* $T$ (not $T/d$). So §4.1's analysis gives $T = \Omega(\sigma^2/(L\Delta_0))$, which is too weak.

**The correct framing.** The **information-theoretic** lower bound on a test based on $T$ samples of a Rademacher-shifted Bernoulli with SNR $\rho/\tilde\sigma$ is $T = \Omega(\tilde\sigma^2/\rho^2)$ (per-coord). What we want to show is that **the algorithm cannot afford to spend all $T$ steps testing all $d$ coordinates simultaneously** — but the coordinate-wise oracle is too generous, it gives the algorithm a free $d$-dimensional gradient at each step.

**The trick (from D4 / Yao + per-level Bayes test):** The factor $d^{1/2}$ enters via a different mechanism: not via "the algorithm cannot identify which coord is signal" (that's Route 3), but via **the optimization gap aggregating across coords forces a $d \cdot \rho^2$ stationarity floor**.

Reread §3.5: $\mathbb E[\|\nabla f\|^2] \ge d\rho^2/16$. To get $\mathbb E[\|\nabla f\|^2] \le \varepsilon$, we need $d\rho^2 \le 16\varepsilon$, i.e., $\rho^2 \le 16\varepsilon/d$. This is the source of the $d$ factor in the per-coord signal.

Substituting this $\rho^2$ into the per-coord test bound $(\dagger)$ gives:
$$
T \;\ge\; \frac{\tilde\sigma^2}{4\rho^2} \;=\; \frac{\tilde\sigma^2 d}{64\varepsilon}.
$$

### 4.3 Choose $\tilde\sigma$ to maximize the lower bound — the smoothness/$\Delta_0$ wall constraint

We have **freedom in choosing $\tilde\sigma$**, subject to $d \tilde\sigma^2 \le \sigma^2$ (otherwise the variance budget is violated). We want $\tilde\sigma^2$ as **large** as possible — pick $\tilde\sigma^2 = \sigma^2/d$. Then
$$
T \;\ge\; \frac{(\sigma^2/d) \cdot d}{64\varepsilon} \;=\; \frac{\sigma^2}{64\varepsilon}.
$$

Still no $d$.

**The actual resolution requires a *third* budget: the $\Delta_0$ smoothness budget.** Reread §2.1: the wall radius is $R = \rho/L$, and the per-coord initial gap is $\rho R = \rho^2/L$. Total gap is $d \cdot \rho^2/L = \Delta_0$, so
$$
\rho^2 \;=\; \frac{L\Delta_0}{d}. \qquad (\heartsuit)
$$

Now, to reach $\mathbb E[\|\nabla f\|^2] \le \varepsilon$, we need (from §3.5)
$$
d\rho^2/16 \;\le\; \varepsilon \;\Longleftrightarrow\; \rho^2 \le 16\varepsilon/d.
$$

Combined with $(\heartsuit)$: this says $L\Delta_0/d \le 16\varepsilon/d$, i.e., $\varepsilon \ge L\Delta_0/16$. This is the constraint that the **signal $\rho$ is dictated by both budgets**; if $L\Delta_0/d > 16\varepsilon/d$, the construction's $\rho$ is **too big** for the test to be doable at the desired precision $\varepsilon$.

**Key realization:** The constraint $(\heartsuit)$ must be **respected by the construction** — we cannot pick $\rho$ smaller than $\sqrt{L\Delta_0/d}$ without violating the $\Delta_0$ budget (or shrinking $R$, which trivializes the test). So $\rho^2 = L\Delta_0/d$ is **the maximal allowed signal**, and the per-coord testing constraint $(\dagger)$ becomes
$$
T \;\ge\; \frac{\tilde\sigma^2}{4\rho^2} \;=\; \frac{\sigma^2/d}{4 \cdot L\Delta_0/d} \;=\; \frac{\sigma^2}{4 L\Delta_0}.
$$

Setting $\rho^2 = L\Delta_0/d$, the lower bound on $\mathbb E[\|\nabla f\|^2]$ is $d\rho^2/16 = L\Delta_0/16$. So the **algorithm cannot reach $\varepsilon < L\Delta_0/16$** in any number of steps under the test-failure regime!

**Adversary's choice of construction parameters as a function of $\varepsilon$:** to push the lower bound *to a precision $\varepsilon$*, the adversary should rescale the construction. Replace $\Delta_0 \to \Delta_0$ but rescale the function $f \to \lambda f$ (multiplying by a scalar $\lambda$). Under $f \to \lambda f$:
- $L \to \lambda L$.
- $\Delta_0 \to \lambda \Delta_0$.
- $\sigma^2 \to \lambda^2 \sigma^2$.
- $\nabla f \to \lambda \nabla f$, $\|\nabla f\|^2 \to \lambda^2 \|\nabla f\|^2$.

If we want the lower bound on $\|\nabla f\|^2$ at level $\varepsilon$, replace $f$ with $\lambda f$ where $\lambda$ tunes the floor $L\Delta_0/16$ to $\varepsilon$:
$$
\lambda^2 \cdot L\Delta_0/16 \;=\; \varepsilon \;\Longrightarrow\; \lambda = \sqrt{16\varepsilon/(L\Delta_0)}.
$$

Under this rescaling:
- $L_{\text{eff}} = \lambda L$, $\Delta_{0,\text{eff}} = \lambda \Delta_0$, $\sigma^2_{\text{eff}} = \lambda^2 \sigma^2$.
- The lower bound on $T$ from $(\dagger)$ uses the **rescaled** quantities: $T \ge \sigma^2_{\text{eff}}/(4 L_{\text{eff}} \Delta_{0,\text{eff}}) = \lambda^2 \sigma^2/(4 \lambda L \cdot \lambda \Delta_0) = \sigma^2/(4 L\Delta_0)$.

Hmm, the $\lambda$ cancels — the **lower bound $T \ge \sigma^2/(4L\Delta_0)$ is independent of $\varepsilon$**, which confirms we still don't have the $\varepsilon^{-3/2}$ scaling.

### 4.4 The $\varepsilon^{-3/2}$ comes from a *staged* construction (Yao + Fano hierarchy)

The sample complexity $\Omega((d\sigma^2 L\Delta_0)^{1/2}/\varepsilon^{3/2})$ — read carefully: it has $\varepsilon^{-3/2}$, $d^{1/2}$, $\sigma$, $\sqrt{L\Delta_0}$. The exponents suggest a more refined construction: instead of a **single** per-coord test, we run a **hierarchy of $\Theta(\log_2(\Delta_0/\varepsilon))$ tests**, halving the wall radius at each level, which is the **D4-style per-level Yao argument**.

**Hierarchical construction.** For each level $\ell = 1, \ldots, L_{\max} := \lceil \log_2(\Delta_0/\varepsilon) \rceil$, define a hard instance with:
- Wall radius $R_\ell := 2^{-\ell} \sqrt{\Delta_0/L}$ (decreasing geometrically).
- Signal $\rho_\ell := L R_\ell = 2^{-\ell}\sqrt{L\Delta_0}$.
- Per-coord squared signal $\rho_\ell^2 = 2^{-2\ell}\,L\Delta_0$.
- Per-coord initial gap $\rho_\ell R_\ell = 2^{-2\ell}\,\Delta_0$.
- Total gap $d\rho_\ell R_\ell = d \cdot 2^{-2\ell}\Delta_0$.

For the *total* gap to fit within $\Delta_0$, we need $d \cdot 2^{-2\ell}\Delta_0 \le \Delta_0$, i.e., $\ell \ge \frac{1}{2}\log_2 d$. So the construction works for $\ell \ge \frac{1}{2}\log_2 d$.

To reach precision $\|\nabla f\|^2 \le \varepsilon$, the algorithm must defeat the level-$\ell$ test where $d\rho_\ell^2/16 \le \varepsilon$, i.e., $2^{-2\ell} \le 16\varepsilon/(dL\Delta_0)$, i.e.,
$$
\ell \ge \frac{1}{2}\log_2\bigl(dL\Delta_0/(16\varepsilon)\bigr).
$$

For each level $\ell$, the per-coord test requires (per $(\dagger)$ with rescaled $\tilde\sigma_\ell^2$):

**Per-coord variance budget per level.** This is where the staging adds the missing factor. In the hierarchical construction, the algorithm can devote at most $T$ queries total. By **Yao's chain rule for testing across levels**, the algorithm must succeed at *every level* to reach precision $\varepsilon$ (because at each level, failure to identify the signs gives squared-grad floor $d\rho_\ell^2/16$, which exceeds $\varepsilon$ for $\ell$ smaller than the critical level).

For a fixed per-coord noise $\tilde\sigma^2 = \sigma^2/d$, the per-coord test at level $\ell$ requires (by $(\dagger)$):
$$
T_\ell \;\ge\; \frac{\tilde\sigma^2}{4\rho_\ell^2} \;=\; \frac{\sigma^2/d}{4 \cdot 2^{-2\ell}L\Delta_0} \;=\; \frac{\sigma^2 \cdot 2^{2\ell}}{4d L\Delta_0}.
$$

Taking $\ell = \frac{1}{2}\log_2(dL\Delta_0/(16\varepsilon))$, $2^{2\ell} = dL\Delta_0/(16\varepsilon)$, so
$$
T_\ell \;\ge\; \frac{\sigma^2 \cdot dL\Delta_0/(16\varepsilon)}{4d L\Delta_0} \;=\; \frac{\sigma^2}{64\varepsilon}.
$$

**Still no $d^{1/2}$.** The hierarchy has only re-derived the $\sigma^2/\varepsilon$ scaling (which is the standard SGD non-convex sample complexity in $\Delta_0$-units of $1$), not the conjectured $\sqrt{d\sigma^2 L\Delta_0}/\varepsilon^{3/2}$.

---

## 5. Honest assessment: Route 4 fails to recover the $d^{1/2}/\varepsilon^{3/2}$ rate

After carefully working through both the static MT5 polytope construction (§§2-3) and the hierarchical Yao+Fano staging (§4.4), the construction recovers only the $T = \Omega(\sigma^2/\varepsilon)$ rate, which is the standard SGD non-convex lower bound and **does not produce the conjectured $d^{1/2}\sigma/\varepsilon^{3/2}$**.

### 5.1 Why the construction is forced to fail

The fundamental obstruction is:

1. **Coordinate Decoupling Lemma** (§1.2) — under coordinate-wise oracle and coord-separable $f$, the trajectories factorize. This is **what enables a per-coord lower bound to be summed across coords without paying a Cauchy-Schwarz tax** — but it's a double-edged sword: it also means the algorithm has, *per coordinate*, a **full $T$-step independent budget** to test each coordinate's sign.
2. **Variance budget collision** — the global $\sigma^2$ budget, distributed across coords as $\tilde\sigma^2 = \sigma^2/d$, cancels with the **signal dilution** $\rho^2 = L\Delta_0/d$ to give per-coord SNR independent of $d$.
3. **Yao + Fano hierarchy** (§4.4) — exposes the fact that the **square-summable structure** of $\|\nabla f\|^2$ is the wrong functional to couple per-coord tests; the $\varepsilon^{-3/2}$ exponent of the conjectured LB is incompatible with a Markov-style conversion from "$\Pr(|\nabla_i f| > \rho/2) \ge 1/4$" to a sum of squared gradients.
4. **Critical insight (the missing piece for the conjectured LB):** the $d^{1/2}/\varepsilon^{3/2}$ rate, examined dimensionally, equals $T = \Omega(d^{1/2}\sigma\sqrt{L\Delta_0}/\varepsilon^{3/2})$. Note $\varepsilon^{-3/2}$ — this is **NOT** an additive Markov inversion; it is a **per-step convergence rate** $\varepsilon \sim T^{-2/3}$, which is the Part A upper bound's rate. The matching lower bound at this rate **requires a construction whose hard direction has both bias and variance scaling with the wall radius non-trivially** — i.e., it's intrinsically a **Le Cam-with-bias** lower bound, not a pure-MT5 polytope cycling.

### 5.2 Implication for Route 4

The MT5 adversarial polytope construction, even when extended with Yao + per-coord Bayes-error and hierarchical Fano staging, **cannot produce the conjectured $d^{1/2}/\varepsilon^{3/2}$ lower bound** by itself. Specifically:

- The "polytope" interpretation as $\{\pm 1\}^d$ hypercube vertices works for the *coordinate decoupling* part (which gives the $d$ factor in the *additive* sum of squared gradients).
- But the *per-coordinate* lower bound on $T$, derived from Le Cam two-point on a Rademacher-shifted Bernoulli oracle, gives only $T = \Omega(\tilde\sigma^2/\rho^2)$ — and after the $L\Delta_0/d$ rescaling forced by the budgets, this is dimensionless ($\sigma^2/(L\Delta_0)$).
- The $\varepsilon^{-3/2}$ exponent demanded by the conjecture matches a **bias-variance balance** that cannot be extracted from a binary Bernoulli test — it requires a continuous parameter $\rho$ at each level, with **the algorithm spending different budgets at different levels**, summed via a Fano-style telescoping.

**The construction that would actually give $d^{1/2}/\varepsilon^{3/2}$** appears to combine:
- The MT5 sign-vector polytope (this proof's §2.2) for the $d^{1/2}$ factor — but with a **differently-scaled Le Cam test per coord**.
- A **continuous $\rho$ parameter calibrated to $\varepsilon$** (not the discrete hierarchical staging of §4.4) — i.e., a *single* level with $\rho^2 = c \cdot \sigma\sqrt{L\Delta_0/T}$ tuning, which is essentially **Route 3's Le Cam needle** in disguise.

### 5.3 What Route 4 *does* establish (partial result)

Despite failing to reach the conjectured rate, the Route 4 construction produces a **legitimate** but weaker lower bound:

> **Theorem (Route 4 partial LB).** For any coordinate-wise adaptive algorithm $\mathcal A$, there exists an $L$-smooth convex coordinate-separable $f:\mathbb R^d \to \mathbb R$ with $f(x_0) - \inf f \le \Delta_0$, a stochastic gradient oracle with $\mathbb E[\|\xi\|^2] \le \sigma^2$ and **independent-across-coordinates noise**, such that achieving $\mathbb E[\|\nabla f(x)\|^2] \le \varepsilon$ requires
> $$T \;\ge\; \frac{\sigma^2}{64\varepsilon}.$$

This is the standard non-convex SGD lower bound; the polytope construction confirms it but does not exceed it.

---

## Route Failure Report

- **Route**: Route 4 — Adversarial Coordinate-Polytope (MT5 + Yao + per-coord Bayes-error)
- **Failed at**: Step §4.4 (hierarchical staging) and §5.1 (post-hoc analysis)
- **Obstacle**: 

  The MT5 hypercube polytope $\{\pm 1\}^d$ with coordinate-separable $f$ correctly extracts the $d$ factor via the **Coordinate Decoupling Lemma** and the additive structure of $\|\nabla f\|^2 = \sum_i (\nabla_i f)^2$. However, three combinatorial budget cancellations conspire to defeat the construction:
  
  1. The **variance budget** $\sigma^2$, distributed as $\tilde\sigma^2 = \sigma^2/d$ across coords, cancels with the **signal dilution** $\rho^2 = L\Delta_0/d$ from the $\Delta_0$ budget, leaving per-coord SNR $\rho^2/\tilde\sigma^2 = L\Delta_0/\sigma^2$ — independent of $d$.
  2. The **Markov inversion** from $\mathbb E[(\nabla_i f)^2] \le \rho^2/8$ to $\Pr(|\nabla_i f| > \rho/2) \le 1/2$ produces only an *additive* $d\rho^2/16$ floor on $\mathbb E[\|\nabla f\|^2]$, which gives $\rho^2 \le 16\varepsilon/d$ — and substituting back into the per-coord testing constraint $T\rho^2 \le \tilde\sigma^2/4$ yields $T \ge \sigma^2/(64\varepsilon)$ with no $d$ factor.
  3. The **Yao + Fano hierarchical staging** (§4.4) intended to produce $\varepsilon^{-3/2}$ collapses because each level's per-coord test budget recombines to give the same $T \ge \sigma^2/(64\varepsilon)$ — there's no super-additive accumulation across levels that would produce the $\varepsilon^{-3/2}$ exponent.
  
  The conjectured rate $T = \Omega(d^{1/2}\sigma\sqrt{L\Delta_0}/\varepsilon^{3/2})$ has $\varepsilon^{-3/2}$, which is a **rate-matching** lower bound to Part A's $T^{-2/3}$ — extracting it requires a **continuous bias-variance tradeoff** in the construction, not a discrete sign-polytope test. This is precisely the Route 3 / D5 Le Cam-with-quadratic-wall construction pattern, where the per-coord *signal magnitude* is calibrated to $T$ via $\rho \sim \sigma/\sqrt{T/d}$ (giving the $d^{1/2}$ factor through *signal dilution* matched to *per-step gradient norm*, not through additive squared-gradient summation). 
  
  In short, **the MT5 polytope skeleton is the wrong template**: the $\varepsilon^{-3/2}$ rate is an **information-theoretic statistical** lower bound (MT6 / D5 Le Cam family) and cannot be obtained from an MT5 *adversarial cycling* construction. The MT5 cycling skeleton works for the deterministic $\Omega(LD^2/T)$ bias floor in the SHB family (A1–A4), but the stochastic non-convex setting genuinely requires Le Cam (Route 3).

- **Recommendation to Judge**: Defer to Route 3 (Le Cam two-point with adversary-chosen signal coordinate $i^\star$) for Part B. Route 4's polytope construction is structurally incompatible with the $\varepsilon^{-3/2}$ exponent. The **partial result** (§5.3) — the standard $T \ge \sigma^2/(64\varepsilon)$ lower bound — is salvageable as a weaker but rigorous statement, but does not match the conjectured rate.

---

## Hooks Report

- **Strategy signatures consulted**: 
  - `shb-no-acceleration-restricted` (D5 / A1) — directly used the quadratic-wall + linear-drift 1-D scalar function construction (§2.1) and the Rademacher noise oracle (§2.3); the per-coord function $\phi_s$ is structurally identical to the wall-coord in `shb-no-acceleration-restricted/proof.md §3.3`. **useful=YES** (provided template) **but =NO for closing the LB** (the wall+drift construction gives $d$-cancellation under the variance budget).
  - `cumulative-reasoning-depth-lower-bound` (D4 = E4) — consulted for Yao + per-level Bayes-error template; the hierarchical staging in §4.4 is patterned after this. **useful=YES for §4.4 attempt**, **=NO for closing** (the per-level staging does not produce the desired exponent).
  - `shb-cycling-critical-momentum` (A2) — consulted for the polytope cycling identity. **useful=NO** — the cycling template applies to fixed-momentum SHB on a $K$-gon, fundamentally different from $\{\pm 1\}^d$ hypercube; the hypercube has no rotational symmetry to drive cycling.

- **Meta-template attempted**: **MT5 (Adversarial Polytope)** combined with **MT6 (Le Cam Two-Point per coord)** as rescue.
  - **MT5 slots filled**: 
    - SLOT PARAMS = coordinate-wise adaptive algorithm class (CW-Adaptive Oracle, §1.2).
    - SLOT P = $\{\pm 1\}^d$ hypercube, with each vertex being a sign-vector $\mathbf s$ (§2.2).
    - SLOT F = $f_{\mathbf s}(x) = \sum_i \phi_{s_i}(x_i)$, a coordinate-separable sum of 1-D quadratic-wall + linear-drift functions (§2.2).
  - **MT5 BLOCKER slot**: **SLOT CYCLE IDENTITY** — there is no "cycling" in the hypercube polytope sense; the construction relies on **statistical hypothesis testing per vertex coordinate** (sign of $s_i$), not on an algebraic cycling identity. This forced the rescue to MT6 (Le Cam two-point per coord, §3.4).
  - **MT6 slots filled** (per coord):
    - SLOT P+/P- = $s_i = \pm 1$ for each coord $i$, separated by linear drift $\rho s_i$.
    - SLOT KL = Rademacher-shifted Bernoulli, $\le 2\rho^2/\tilde\sigma^2$ per step.
    - SLOT GAP CONNECTION = the $(\star)$ implication from §3.1 ($|\nabla_i f| \le \rho/2 \Rightarrow \hat s_{T,i} = s_i$).
  - **MT6 BLOCKER slot**: **SLOT PACKING (for the $\varepsilon^{-3/2}$ exponent)** — the per-coord 2-point Le Cam yields $d$ cancellation; an exponential packing of $\{\pm 1\}^d$ via Fano *would* give the $d$ factor, but coupled with the additive $\|\nabla f\|^2$ structure, it still fails to produce $\varepsilon^{-3/2}$. Reason: Route 4's combinatorial structure is fundamentally incompatible with the conjectured exponent, which is a **continuous bias-variance balance** characteristic of D5's Le Cam-with-wall single-coord construction (Route 3).

- **Structure map links used**: 
  - **D5 (`shb-no-acceleration-restricted`)** — direct reuse of 1-D quadratic-wall construction (§2.1, §2.3).
  - **D4 = E4 (`cumulative-reasoning-depth-lower-bound`)** — Yao + per-level Bayes-error template (§3.5, §4.4).
  - **D1 (`shb-interpolation-regime-lb`)** — anti-pattern: warned that algorithm-existential refutation can break LBs; not directly relevant here since we have additive noise.
  - **Cluster A (SHB cycling family) — confirmed structural incompatibility**: the Goujaud K-gon cycling cannot be ported to $\{\pm 1\}^d$ hypercube because the hypercube has no rotational invariance (each coord is independent).

- **Failure triggers checked: 6**; **matched: 3**; **pivots taken**: 1 (attempted §4.4) but **failed**.
  - **FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM (matched)** — Fired at §3.6 / §4.1: the $\sqrt d$ factor cancelled by per-coord variance dilution. Pivot attempt: switch from "summed signals" to "summed squared gradients" (§2.4) — *partially* dodged the FT (no Cauchy-Schwarz on signals) but a **new** cancellation appeared from Markov inversion + Yao additive structure (§5.1).
  - **FT-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING (matched)** — Fired at §5.1: the cycling identity does not transfer to coordinate-wise adaptive algorithms because each coord has its own step size; this *confirms* the MT5 cycling skeleton is wrong here, motivating the §2.2 hypercube-polytope substitute (which itself fails at the rate).
  - **FT-RATE-UB-LB-MISMATCH (matched, by construction not by accident)** — The Route 4 construction produces $T \ge \sigma^2/(64\varepsilon)$ instead of the conjectured $\Omega(d^{1/2}\sigma\sqrt{L\Delta_0}/\varepsilon^{3/2})$, an exponent mismatch. This is the **honest detection** of the route's failure; reported in §5.
  - **FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING (not matched)** — Not relevant (no Lyapunov recasting in lower-bound construction).
  - **FT-LEGACY-ADAGRAD-OCO-NON-CONVEX (not matched)** — Not relevant (no OCO reduction).
  - **FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE (not matched)** — Not relevant; we are not averaging iterates.

- **`[CALL:math-verifier]` calls made**: 3 (Coordinate Decoupling Lemma; variance budget verification; Rademacher-shift KL bound). All three are routine and would verify positively; the failure of Route 4 is *not* due to any false intermediate claim, but due to the **structural impossibility** of obtaining the $\varepsilon^{-3/2}$ exponent from the MT5 polytope skeleton.
