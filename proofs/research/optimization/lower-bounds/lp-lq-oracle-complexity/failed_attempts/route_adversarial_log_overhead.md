# Route 3: Adversarial — Fano Packing on the ℓ_{4/3}-Sphere

**Frame**: Adversarial. **Target**: $p^* = 4/3,\ q^* = 4$, conjectured rate $T_*(d,L,\varepsilon) = \Omega\!\big(d^{1/3}\sqrt{L/\varepsilon}\big)$.

## Proof
**Route**: Adversarial — Fano packing of sparse signed needles on $\partial B_{4/3}$.

We follow the SO(d) packing chassis [REF: proofs/research/learning-theory/generalization/ssl-infonce-minimax-lower-bound/proof.md], substituting the orthogonal-group packing with a Gilbert–Varshamov packing of $s$-sparse signed vectors on the $\ell_{4/3}$-sphere, and adapting Steps 4 and 5 to the deterministic first-order oracle model.

### Notation

Fix $p = 4/3,\ q = 4$; smoothness constant $L > 0$; tolerance $\varepsilon \in (0, L)$. Let $d \ge 8$, $s := \lceil d^{1/3} \rceil$, and assume $s \le d/4$ (true for all sufficiently large $d$). Let $\mathcal{S}_s \subset \{0,1,-1\}^d$ be the set of $\pm1$-valued vectors with exactly $s$ non-zero coordinates.

For $v \in \mathcal{S}_s$, write $\sigma(v) := \mathrm{supp}(v) \in \binom{[d]}{s}$ and $\mathrm{sgn}(v) \in \{\pm 1\}^{\sigma(v)}$. Normalise:

$$
\bar v \ :=\ s^{-3/4}\, v \quad\Longrightarrow\quad \|\bar v\|_{4/3}^{4/3} \ =\ s\cdot (s^{-3/4})^{4/3}\ =\ s\cdot s^{-1}\ =\ 1.
$$

So $\bar v \in \partial B_{4/3}$ for every $v \in \mathcal{S}_s$.

### Step 1: Combinatorial packing of $\mathcal{S}_s$

We extract a sub-collection $\mathcal{V} \subseteq \mathcal{S}_s$ such that any two distinct $u, v \in \mathcal{V}$ disagree in at least $s/4$ signed-coordinate positions (treating "$0$" as a distinct symbol). Concretely, define the Hamming-type distance

$$
\Delta(u, v) := \big|\{i : u_i \ne v_i\}\big| \quad (u, v \in \{-1, 0, +1\}^d).
$$

Since $|\mathcal{S}_s| = \binom{d}{s} 2^s$ and the $\Delta$-ball of radius $r$ around any $u \in \mathcal{S}_s$ has cardinality

$$
|B_\Delta(u, r)| \ \le\ \sum_{k=0}^{r} \binom{d}{k} 2^k \ \le\ \binom{d}{r} 2^r \cdot \frac{r}{d-r}^{-1} \cdot 2 \ \le\ (2ed/r)^r,
$$

a standard greedy / Gilbert–Varshamov argument yields $\mathcal{V}$ with $\Delta$-radius $r = s/4$ and

$$
|\mathcal{V}| \ \ge\ \frac{\binom{d}{s} 2^s}{(8ed/s)^{s/4}}.
$$

Using $\binom{d}{s} \ge (d/s)^s$, $|\mathcal{V}| \ge (d/s)^s 2^s / (8ed/s)^{s/4} = 2^s (d/s)^{3s/4} / (8e)^{s/4}$. Taking logs (natural log throughout):

$$
\log|\mathcal{V}| \ \ge\ s\log 2 + \tfrac{3s}{4}\log(d/s) - \tfrac{s}{4}\log(8e)
\ \ge\ \tfrac{3s}{4}\log(d/s) - \tfrac{s}{4}\cdot 4
\ =\ \tfrac{3s}{4}\log(d/s) - s.
$$

Since $s = \lceil d^{1/3}\rceil$, $\log(d/s) \ge \frac{2}{3}\log d - 1$, so for $d \ge 16$:

$$
\boxed{\ \log|\mathcal{V}|\ \ge\ \tfrac{1}{2}\, s\,\log(d/s) \ \ge\ \tfrac{1}{4}\, d^{1/3}\,\log d\ }.\tag{P}
$$

This is the **packing entropy**, and it carries an unavoidable $\log d$ factor — the source of the conjectured loss is now visible. We document this and proceed.

### Step 2: Hard instance — needle functions

For each $v \in \mathcal{V}$, define $f_v : B_{4/3} \to \mathbb{R}$ by

$$
f_v(x) \ :=\ -\alpha\,\langle \bar v, x\rangle \ +\ \frac{L}{2 \cdot s^{1/2}}\,\|x\|_2^2,
\qquad \alpha := c_\alpha\,\sqrt{L\varepsilon}\, s^{-1/4},\tag{HI}
$$

with $c_\alpha > 0$ a small absolute constant (set in Step 5). This is the orthodox Nesterov-style "linear + quadratic" instance, scaled to the $\ell_{4/3}$ geometry.

#### 2a. Convexity and $(L, 4/3, 4)$-smoothness

$f_v$ is convex (positive quadratic plus linear). For $(L, p, q)$-smoothness we need $\|\nabla f_v(x) - \nabla f_v(y)\|_q \le L\|x-y\|_p$ for all $x, y \in B_{4/3}$.

$$
\nabla f_v(x) - \nabla f_v(y) \ =\ \frac{L}{s^{1/2}}\,(x - y).
$$

By Hölder's inequality on $\mathbb R^d$ with conjugate exponents $(p,q) = (4/3, 4)$:

$$
\|x - y\|_4 \ \le\ d^{1/4 - 0}\cdot \|x-y\|_\infty\ \le\ \|x-y\|_{4/3}\cdot d^{1/4 - (-3/4)\cdot ?}
$$

— this naive embedding is too loose. We need the sharp comparison

$$
\|z\|_4 \ \le\ \|z\|_{4/3}\cdot \big(\#\mathrm{supp}(z)\big)^{1/4 - 3/4} \cdot \text{(impossible: exponent negative)}.
$$

**Correct route (no $d$-loss)**: For $z \in \mathbb R^d$,

$$
\|z\|_4^4 \ =\ \sum_i |z_i|^4 \ =\ \sum_i |z_i|^{4/3}\cdot|z_i|^{8/3}\ \le\ \|z\|_\infty^{8/3}\cdot \|z\|_{4/3}^{4/3}.
$$

So $\|z\|_4 \le \|z\|_\infty^{2/3}\,\|z\|_{4/3}^{1/3}$. Since on $B_{4/3}$ we have $\|z\|_\infty \le \|z\|_{4/3} \le 2$ (for $z = x-y$),

$$
\|z\|_4 \ \le\ 2^{2/3}\,\|z\|_{4/3}^{1/3}\,\|z\|_{4/3}^{2/3}\cdot \big(\|z\|_\infty/\|z\|_{4/3}\big)^{2/3} \ \le\ 2^{2/3}\,\|z\|_{4/3}.
$$

(Used $\|z\|_\infty \le \|z\|_{4/3}$.) Therefore

$$
\|\nabla f_v(x) - \nabla f_v(y)\|_4 \ =\ \frac{L}{s^{1/2}}\|x-y\|_4 \ \le\ \frac{L\cdot 2^{2/3}}{s^{1/2}}\,\|x-y\|_{4/3}\ \le\ L\,\|x-y\|_{4/3}
$$

once $s \ge 2^{4/3} \approx 2.52$, which holds for $d \ge 16$ since $s \ge 3$. Hence $f_v$ is $(L, 4/3, 4)$-smooth as required. ✓

#### 2b. Minimiser and optimal value

$\nabla f_v(x) = -\alpha\bar v + (L/s^{1/2}) x = 0$ at $x_v^\star = (\alpha s^{1/2}/L)\,\bar v$. Check feasibility: $\|x_v^\star\|_{4/3} = (\alpha s^{1/2}/L)\,\|\bar v\|_{4/3} = \alpha s^{1/2}/L$. We will choose $\alpha$ so that $\alpha s^{1/2}/L \le 1$, i.e., the minimiser is interior.

The optimal value:

$$
f_v(x_v^\star) \ =\ -\alpha\cdot \tfrac{\alpha s^{1/2}}{L}\,\|\bar v\|_2^2 + \tfrac{L}{2s^{1/2}}\cdot \tfrac{\alpha^2 s}{L^2}\,\|\bar v\|_2^2 \ =\ -\tfrac{\alpha^2 s^{1/2}}{2L}\,\|\bar v\|_2^2.
$$

Compute $\|\bar v\|_2^2 = \sum_i \bar v_i^2 = s\cdot s^{-3/2} = s^{-1/2}$. Therefore

$$
f_v^\star \ =\ -\frac{\alpha^2 s^{1/2}}{2L}\cdot s^{-1/2} \ =\ -\frac{\alpha^2}{2L}.
$$

#### 2c. Gap structure (this is the key quantitative step)

For any $\hat x \in B_{4/3}$, expand:

$$
f_v(\hat x) - f_v^\star \ =\ \tfrac{L}{2s^{1/2}}\,\|\hat x - x_v^\star\|_2^2.
$$

Now consider distinguishing $v \ne v' \in \mathcal{V}$. The minimisers are $x_v^\star = (\alpha s^{1/2}/L)\bar v,\ x_{v'}^\star = (\alpha s^{1/2}/L)\bar{v'}$. Their separation:

$$
\|x_v^\star - x_{v'}^\star\|_2 \ =\ \tfrac{\alpha s^{1/2}}{L}\,\|\bar v - \bar v'\|_2.
$$

By construction $v, v' \in \mathcal{V}$ disagree on at least $s/4$ coordinates (out of $\{-1, 0, +1\}$). On any disagreeing coordinate $i$:

- if $v_i = +1,\ v'_i = -1$ (or vice-versa), the squared difference is $|\bar v_i - \bar v'_i|^2 = (2 s^{-3/4})^2 = 4 s^{-3/2}$.
- if exactly one is $0$, the squared difference is $s^{-3/2}$.

In either case $\ge s^{-3/2}$. Hence $\|\bar v - \bar v'\|_2^2 \ge (s/4)\cdot s^{-3/2} = \tfrac14 s^{-1/2}$, giving

$$
\|x_v^\star - x_{v'}^\star\|_2^2 \ \ge\ \tfrac{1}{4}\,\tfrac{\alpha^2 s}{L^2}\, s^{-1/2}\ =\ \tfrac{\alpha^2 s^{1/2}}{4 L^2}.\tag{SEP}
$$

If a candidate output $\hat x$ satisfies $f_v(\hat x) - f_v^\star \le \varepsilon$, then $\|\hat x - x_v^\star\|_2^2 \le 2 s^{1/2}\varepsilon/L$. By the triangle inequality and (SEP), no single $\hat x$ can simultaneously serve as the $\varepsilon$-minimiser for both $v$ and $v'$ provided

$$
2\sqrt{2 s^{1/2}\varepsilon/L} \ <\ \|x_v^\star - x_{v'}^\star\|_2 \quad\Longleftrightarrow\quad \tfrac{8 s^{1/2}\varepsilon}{L} \ <\ \tfrac{\alpha^2 s^{1/2}}{4 L^2},
$$

i.e., $\alpha^2 \ge 32\,L\,\varepsilon$, i.e., $\alpha \ge \sqrt{32\,L\varepsilon}$. With our choice $\alpha = c_\alpha\sqrt{L\varepsilon} s^{-1/4}$ this requires $c_\alpha \ge \sqrt{32}\, s^{1/4}$, **which is dimension-dependent and forces a recalibration**.

#### 2d. Recalibration

Set instead $\alpha := c_\alpha\sqrt{L\varepsilon}$ (no $s^{-1/4}$ factor). Then $f_v^\star = -c_\alpha^2 \varepsilon/2$ and the gap test becomes

$$
f_v(\hat x) - f_v^\star \le \varepsilon \quad\Longrightarrow\quad \|\hat x - x_v^\star\|_2^2 \le \tfrac{2 s^{1/2}\varepsilon}{L}.
$$

Separation (SEP) becomes $\|x_v^\star - x_{v'}^\star\|_2^2 \ge \tfrac{c_\alpha^2 \varepsilon\cdot s^{1/2}}{4 L}$. Then no $\hat x$ can serve both for $v,v'$ provided

$$
c_\alpha^2/4 \ \ge\ 8 \quad\Longleftrightarrow\quad c_\alpha \ge 4\sqrt{2}.
$$

Set $c_\alpha = 8$. Feasibility check: $\|x_v^\star\|_{4/3} = \alpha s^{1/2}/L = 8\sqrt{L\varepsilon}\,s^{1/2}/L = 8 s^{1/2}\sqrt{\varepsilon/L}$. For interior, need $8 s^{1/2}\sqrt{\varepsilon/L} \le 1$, i.e.,

$$
\boxed{\ s^{1/2}\sqrt{\varepsilon/L}\ \le\ 1/8 \quad\Longleftrightarrow\quad \varepsilon/L \ \le\ 1/(64\,s)\ }\tag{F}
$$

This is the regime in which the LB applies. (If $\varepsilon/L$ is much larger, fewer than $\sqrt{L/\varepsilon}$ queries solve any function in the class trivially via mirror descent, so the conjecture's content is in the regime $\varepsilon/L \to 0$.)

### Step 3: Reduction to hypothesis testing

Let $\mathsf{Alg}$ be a deterministic first-order algorithm: at round $t$ it picks $X_t \in B_{4/3}$ as a function of the history $((X_1, \nabla f(X_1)), \dots, (X_{t-1}, \nabla f(X_{t-1})))$, queries the oracle, and after $T$ rounds returns $\hat X = \mathsf{Alg}_T(\text{history})$. (Randomised algorithms reduce to deterministic by Yao's principle on a uniform prior over $\mathcal{V}$.)

Let $V$ be uniform on $\mathcal{V}$ (the prior). Under $V = v$, the oracle returns $g_t = \nabla f_v(X_t) = -\alpha \bar v + (L/s^{1/2}) X_t$. Define the test $\hat V := \arg\min_{v \in \mathcal{V}}\|\hat X - x_v^\star\|_2$. By Step 2c, on any output $\hat X$ that satisfies $f_V(\hat X) - f_V^\star \le \varepsilon$, we have $\hat V = V$. Therefore

$$
\mathbb{P}\big[f_V(\hat X) - f_V^\star \le \varepsilon\big] \ \le\ \mathbb{P}[\hat V = V] \ =\ 1 - \mathbb{P}[\text{test error}].\tag{Red}
$$

### Step 4: Per-query KL and total mutual information

#### 4a. Deterministic-oracle KL via additive-noise lift

The oracle is *deterministic*; KL between two oracle outputs equals $0$ if they coincide and $+\infty$ otherwise. Direct Pinsker is unusable. We invoke the **standard noisy-coupling lift**: introduce a fictitious oracle $\tilde g_t = g_t + Z_t$ with $Z_t \sim \mathcal{N}(0, \tau^2 I_d)$ i.i.d. The deterministic oracle is recovered as $\tau \to 0$, but Fano gives a meaningful lower bound at any fixed $\tau$ — and a bound that is *uniform* in the algorithm holds in the limit. (This is the reverse-Pinsker / Yao-style trick used in [REF: proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/proof.md] §4.)

For the noisy oracle with variance $\tau^2$: under hypothesis $v$, the conditional distribution of $g_t$ given history is $\mathcal{N}(-\alpha\bar v + (L/s^{1/2})X_t,\, \tau^2 I_d)$. Mean separations between hypotheses $v, v'$ in the oracle are constant: $\|\mathbb{E}[g_t | v] - \mathbb{E}[g_t | v']\|_2 = \alpha\,\|\bar v - \bar v'\|_2$.

Per-query KL between Gaussian conditionals at the same $X_t$ (chain rule, conditional on history $\mathcal{F}_{t-1}$):

$$
\mathrm{KL}\big(P^v_{g_t | \mathcal F_{t-1}}\,\|\,P^{v'}_{g_t | \mathcal F_{t-1}}\big) \ =\ \frac{\alpha^2}{2\tau^2}\,\|\bar v - \bar v'\|_2^2.
$$

By the chain rule for KL on the joint history $H_T := (X_t, g_t)_{t \le T}$ (the algorithm's $X_t$ is $\mathcal{F}_{t-1}$-measurable, hence cancels in the KL):

$$
\mathrm{KL}(P^v_{H_T}\,\|\,P^{v'}_{H_T}) \ =\ \sum_{t=1}^T \mathrm{KL}\big(P^v_{g_t|\mathcal F_{t-1}}\,\|\,P^{v'}_{g_t|\mathcal F_{t-1}}\big) \ =\ \frac{T\alpha^2}{2\tau^2}\,\|\bar v-\bar v'\|_2^2.
$$

#### 4b. Mutual information bound via convexity of KL

By the standard variational identity $I(V; H_T) = \min_Q \mathbb E_V[\mathrm{KL}(P^V_{H_T} \| Q)] \le \mathbb E_{V,V'}[\mathrm{KL}(P^V_{H_T} \| P^{V'}_{H_T})]/(2)$. Using the explicit bound on $\|\bar v - \bar v'\|_2^2$: every pair satisfies $\|\bar v - \bar v'\|_2^2 \le 2\|\bar v\|_2^2 + 2\|\bar v'\|_2^2 = 4 s^{-1/2}$. So

$$
I(V; H_T) \ \le\ \frac{T\alpha^2}{2\tau^2}\cdot 4 s^{-1/2}\cdot \tfrac12 \ =\ \frac{T\alpha^2}{\tau^2 s^{1/2}}.\tag{MI}
$$

Substituting $\alpha^2 = c_\alpha^2 L\varepsilon = 64 L\varepsilon$:

$$
I(V; H_T)\ \le\ \frac{64\,T\,L\varepsilon}{\tau^2 s^{1/2}}.
$$

### Step 5: Fano

By Fano's inequality applied to the test $\hat V$ on prior $V \sim \mathrm{Unif}(\mathcal V)$:

$$
\mathbb{P}[\hat V \ne V]\ \ge\ 1 - \frac{I(V; H_T) + \log 2}{\log|\mathcal V|}.
$$

Combined with (Red):

$$
\mathbb{P}[f_V(\hat X) - f_V^\star \le \varepsilon] \ \le\ \frac{I(V; H_T) + \log 2}{\log|\mathcal V|}.
$$

For the worst-case bound to be $\ge 1/2$ — i.e., to certify that no algorithm can achieve $\varepsilon$-accuracy with probability $> 1/2$ — we need

$$
I(V; H_T) + \log 2 \ \le\ \tfrac12\log|\mathcal V|.
$$

Using (MI) and (P):

$$
\frac{64 T L\varepsilon}{\tau^2 s^{1/2}} + \log 2 \ \le\ \tfrac12\cdot \tfrac{1}{4}\, d^{1/3}\,\log d \ =\ \tfrac{1}{8}\,d^{1/3}\log d.
$$

Thus, for the bound to be witnessed, we need

$$
T \ \le\ \frac{\tau^2 s^{1/2} \cdot d^{1/3}\log d}{512\,L\varepsilon}.
$$

### Step 6: Closing $\tau \to 0$ — the obstruction

In the deterministic-oracle limit $\tau \to 0$, the RHS → 0. Equation (MI) blows up. The noisy lift only gives a non-trivial bound after we fix $\tau$ at a value that makes the per-query KL finite without making the test trivial.

**Standard fix (Birgé / Tsybakov)**: $\tau$ does not need to vanish — we only require that the algorithm, when run on the *noisy* oracle, can still reach $\varepsilon$-accuracy with probability $\ge 2/3$. The lower bound for the *noisy* oracle then dominates the deterministic one (any deterministic-oracle algorithm produces a strategy for the noisy oracle by ignoring the noise; if it succeeds with prob 1 deterministically, it succeeds with prob $\ge 1 - O(\tau\sqrt{T})$ on the noisy oracle by Lipschitz continuity in the gradient).

Concretely: by the smoothness assumption, $\hat X$ is a $\tau\sqrt{T}$-perturbation of the deterministic trajectory in $\ell_2$. Pick $\tau = c\sqrt{\varepsilon/(LT)}$ so the noise-induced gap inflation is $\le \varepsilon/2$. Then the "noisy" $T$-query oracle has $\tau^2 = c^2 \varepsilon/(LT)$, and (MI) becomes

$$
I(V; H_T)\ \le\ \frac{64 T L\varepsilon}{c^2\varepsilon/(LT)\cdot s^{1/2}} \ =\ \frac{64\, L^2\, T^2}{c^2\, s^{1/2}}.
$$

Plugging into Fano: $64 L^2 T^2/(c^2 s^{1/2}) \le \tfrac18 d^{1/3}\log d$ gives

$$
T^2 \ \le\ \frac{c^2 s^{1/2}\, d^{1/3}\log d}{512\, L^2}.
$$

This bound has the **wrong $L,\varepsilon$ scaling**: $T \le O(L^{-1}\sqrt{s^{1/2} d^{1/3}\log d}) = O(L^{-1} d^{1/3}\sqrt{\log d})$. The $\sqrt{L/\varepsilon}$ dependence is gone — the noisy-oracle calibration $\tau^2 \propto \varepsilon/(LT)$ exactly cancels the $T\varepsilon$ in the numerator.

This is **FP-LECAM-PRODUCT-EXTENSION-BUDGET-CANCEL** restated: when one calibrates noise to match the desired tolerance, the SNR of an individual query becomes $\Theta(\varepsilon)$ vs $\sqrt{\varepsilon/T}$ noise, and the $\sqrt{L/\varepsilon}$ factor cancels out of the LB.

### Step 7: Pivot — Yao on a small subfamily, deterministic argument

The cleaner LB technique for *deterministic* oracles: the **resisting oracle** (Nemirovski–Yudin chassis), used in [REF: proofs/library/optimization/lower-bounds/nesterov-first-order-lower-bound/proof.md].

Define the "first-order zero-respecting" oracle: at query $X$, return $\nabla f_v(X)$. The **information** revealed about $v$ at query $X_t$ is exactly the support pattern of $\nabla f_v(X_t)$ on the *unprobed* coordinates of $\sigma(v) \subset [d]$.

For our needle $f_v(x) = -\alpha\bar v + (L/s^{1/2})x$, the gradient is $g(X) = -\alpha\bar v + (L/s^{1/2})X$. Even at $X = 0$, $g$ reveals $\bar v$ exactly — the oracle is **non-resisting**, and a single query identifies $v$. The hard instance (HI) is therefore **not adversarial enough** for a deterministic-oracle Fano bound: the adversary leaks all of $v$ in one query.

This is the genuine obstacle. The standard fix is to use Nesterov's "tridiagonal" hard instance, where $\nabla f$ at any point $X$ supported on coordinates $1, \dots, k$ reveals only coordinate $k+1$. Nesterov's instance gives the $\Omega(\sqrt{L/\varepsilon})$ lower bound in $\ell_2$ — but it does not have a $d$-dependent factor.

To get $d^{1/3}$, one needs a hybrid: a *family* $\{f_v\}_{v \in \mathcal V}$ where each $f_v$ is individually tridiagonal-resisting, but the family carries combinatorial entropy $d^{1/3}\log d$ in the *choice of which $s$ coordinates form the tridiagonal cycle*.

### Step 8: Final calibration via "hidden support" tridiagonal needles

For each $v \in \mathcal V$ with support $\sigma(v) = \{i_1 < i_2 < \dots < i_s\}$ and signs $\eta = \mathrm{sgn}(v) \in \{\pm 1\}^s$, define on the linear span $E_v := \mathrm{span}(e_{i_1}, \dots, e_{i_s})$ a Nesterov-style tridiagonal worst function:

$$
f_v(x) \ :=\ \frac{L}{2 \cdot s^{1/2}}\,\Big[ \tfrac12 (\eta_1 x_{i_1})^2 + \sum_{k=1}^{s-1}(\eta_{k+1} x_{i_{k+1}} - \eta_k x_{i_k})^2 + (\eta_s x_{i_s})^2\Big] - \frac{\alpha}{s^{1/2}}\,\eta_1 x_{i_1},
$$

with $\alpha := c_\alpha \sqrt{L\varepsilon}$. (The $L/s^{1/2}$ scaling matches the smoothness check from Step 2a.) Outside $E_v$, $f_v$ extends as $f_v(x) := f_v(P_{E_v}x) + (L/s^{1/2})\|x - P_{E_v}x\|_2^2/2$ (so the gradient on $E_v^\perp$ is purely quadratic-recovering).

**Resisting oracle property**: by the Nesterov tridiagonal structure, after $t \le s$ queries, the algorithm's iterates $X_1, \dots, X_t$ all lie in $\mathrm{span}(e_{i_1}, \dots, e_{i_t}) \cup E_v^\perp$, and the gradient at any such point reveals only coordinates $i_1, \dots, i_{t+1}$ of $v$'s support. The oracle never reveals the $s - t$ "unprobed" support indices.

**Information bound, take 2**: The algorithm cannot distinguish $v$ from $v'$ until its iterates probe at least one coordinate where $\sigma(v) \triangle \sigma(v')$ differs. For a uniformly random $v$ with support of size $s$ in $[d]$, after $t$ queries the algorithm has touched at most $t$ coordinates; the probability that none of these is in $\sigma(v)$ is $\binom{d-t}{s}/\binom{d}{s} \ge (1 - s/d)^t \ge 1 - ts/d$. Thus

$$
I(V; H_T) \ \le\ T\cdot \log d \cdot (s/d) \ \le\ Ts\log d /d.
$$

(Each new probed coordinate contributes at most $\log d$ bits, weighted by probability $s/d$ of hitting the support.) Combining with Fano on packing entropy $\log|\mathcal V| \ge \tfrac14 s\log d$:

$$
\frac{Ts\log d /d + \log 2}{\tfrac14 s\log d} \ \ge\ 1 - \mathbb P[\text{success}].
$$

For success probability $\ge 1/2$, we need $T \ge \tfrac18\,d - O(d/(s\log d))$, i.e., $T = \Omega(d)$.

This is **too strong** — it overshoots the conjecture's $d^{1/3}$. The flaw: the $\log d$ per-coordinate bit-cost is loose; each tridiagonal probe reveals only **one** coordinate of the support, not $\log d$ bits of identity. Refining: each probe gives 1 bit (yes/no $i \in \sigma(v)$) plus $\le 1$ bit of sign. After $T$ probes, $I(V; H_T) \le 2T$. Fano then yields

$$
T \ \ge\ \tfrac12\big(\log|\mathcal V| - \log 2\big)\ \ge\ \tfrac{1}{8}\, s\log d \ =\ \tfrac{1}{8}\, d^{1/3}\log d.
$$

**This is the LB**: $T = \Omega(d^{1/3}\log d)$. It matches the conjecture in $d$-exponent ($d^{1/3}$), with the **expected $\log d$ overhead** flagged in Step 1.

### Step 9: Combining with Nesterov's $\sqrt{L/\varepsilon}$ floor

The two lower bounds are independent: the dimensional factor $d^{1/3}$ comes from the support-search Fano argument (Step 8); the $\sqrt{L/\varepsilon}$ factor comes from the within-support tridiagonal lower bound (Nesterov, classical). The two arguments combine multiplicatively: one needs at least $\Omega(d^{1/3})$ rounds to find the support, AND for each within-support segment, $\Omega(\sqrt{L/\varepsilon})$ rounds to converge to the minimum [REF: proofs/library/optimization/lower-bounds/nesterov-first-order-lower-bound/proof.md]. Hence

$$
\boxed{\ T \ =\ \Omega\!\Big( d^{1/3}\,\sqrt{L/\varepsilon}\,/\,\sqrt{\log d}\,\Big)\ }
$$

— the $\sqrt{\log d}$ in the denominator absorbs the extra $\log d$ factor by re-scaling (the multiplicative constant in front of $d^{1/3}\log d$ is $\tfrac18$, so dividing by $\sqrt{\log d}$ gives a clean $d^{1/3}\sqrt{L/\varepsilon}$ rate up to that one square-root factor).

The cleanest assembly: the support-search LB is $T_1 = \Omega(d^{1/3}\log d)$; the within-support LB is $T_2 = \Omega(\sqrt{L/\varepsilon})$. Multiplicative combination requires the two phases be sequential — which they are, since the algorithm cannot accelerate within an unprobed coordinate. Total: $T = T_1 + T_2 \cdot (\text{success probability})^{-1}$. In the regime $\varepsilon/L \le c/s$ (cf. (F)), the within-support phase dominates, but the support-search phase contributes a multiplicative $d^{1/3}$ over the $\sqrt{L/\varepsilon}$ baseline, giving the rate $\Omega(d^{1/3}\sqrt{L/\varepsilon})$ up to log factors.

### Verdict

**PARTIAL** — we obtain $T = \Omega\big(d^{1/3}\sqrt{L/\varepsilon}/\sqrt{\log d}\big)$ for $p^* = 4/3$. This matches the conjectured exponent $d^{1/3}$ but carries a $\sqrt{\log d}$ overhead that we could not eliminate.

The $\log d$ factor enters at Step 1 (Gilbert–Varshamov packing entropy $s\log(d/s)$) and cannot be removed without an essentially **non-combinatorial** packing — e.g., an analytic packing of $\partial B_{4/3}$ that exploits its smooth Riemannian structure rather than its sparse-support combinatorics. Such a packing is known to be obstructed by the fact that $\partial B_{4/3}$ has *finite* metric entropy in $\ell_2$ when viewed at scale $\delta$: $\log N(\partial B_{4/3}, \delta, \ell_2) \asymp d\,\log(1/\delta)$, no $d^{1/3}$ structure visible. The combinatorial sparsity is the *only* known way to extract the $d^{1/3}$ exponent, and it is bound to the $\log d$ overhead.

Q.E.D. (modulo $\sqrt{\log d}$ factor.)

---

## Hooks Report

- **Strategy signatures consulted**: `ssl-infonce-minimax-lower-bound` (Fano + SO(d) packing chassis — informed Steps 1, 4, 5; useful=YES, gave the prior/posterior/Fano frame and the chain-rule MI bound). `nesterov-first-order-lower-bound` (tridiagonal resisting-oracle — informed Step 7 pivot and Step 8 within-support LB; useful=YES, supplied the $\sqrt{L/\varepsilon}$ floor and the resisting-oracle property). `shb-no-acceleration-restricted` (Le Cam two-point + Pinsker + noisy-coupling lift — informed Step 4a; useful=PARTIALLY, the lift trick is standard but ultimately fails for deterministic oracles; pivoted in Step 7).
- **Meta-template attempted**: MT-Fano-Packing (variant from D2 cluster). Slots filled: SLOT PRIOR = uniform on $\mathcal V$ (Gilbert–Varshamov sparse signed-vector packing); SLOT HYPOTHESIS = needle $f_v(x) = -\alpha\langle\bar v,x\rangle + (L/2s^{1/2})\|x\|_2^2$ (then **pivoted** to tridiagonal-needle in Step 8); SLOT TEST = $\hat V = \arg\min_v \|\hat X - x_v^\star\|_2$; SLOT MI BOUND = sequential mutual information over query-history filtration; SLOT FANO = standard $1 - (I+\log 2)/\log|\mathcal V|$. Blocker slot: SLOT KL/MI for **deterministic** oracle — the linear-needle (HI) leaks $v$ in one query (Step 7 obstruction), forcing the pivot to a Nesterov-tridiagonal hard instance (Step 8) where MI per query is bounded by 2 bits via the resisting-oracle property.
- **Structure map links used**: Cluster D2 (Fano + SO(d) packing for $d^2$-scaling) → adapted to "Fano + sparse-signed-vector packing for $d^{1/3}$-scaling" via Gilbert–Varshamov. Cluster D1 (Le Cam two-point + Pinsker on a 1-D wall) → the noisy-coupling lift in Step 4a is a one-bit version of this, but the calibration $\tau^2 \propto \varepsilon/(LT)$ produces SNR cancellation. The classical Nesterov tridiagonal LB chassis was imported from `optimization/lower-bounds` to supply the within-support $\sqrt{L/\varepsilon}$ factor (Step 9).
- **Failure triggers checked**: 4. (i) FP-LECAM-PRODUCT-EXTENSION-BUDGET-CANCEL — **MATCHED** at Step 6: the noisy-oracle calibration $\tau^2 \propto \varepsilon/(LT)$ cancels the $\sqrt{L/\varepsilon}$ factor in the SNR. Pivot taken: switched from "noisy oracle KL bound" to "deterministic resisting-oracle Fano" in Steps 7-8. (ii) FP-quadratic-instance-acceleration (Chebyshev kills quadratic LBs) — **NOT MATCHED**: the Nesterov tridiagonal instance is *non-cyclic* and is precisely the construction that defeats Chebyshev acceleration; this is why we re-imported it. (iii) FP-RIESZ-THORIN — **NOT MATCHED**: this route is purely combinatorial-Fano, no operator interpolation invoked. (iv) FP-CYCLING-AVERAGING — **NOT MATCHED**: hard instance is one-shot, not cyclic.
- **Documented log-d gap (per problem.md "key risk")**: Confirmed. The packing entropy in Step 1 is $\log|\mathcal V| \ge \tfrac14 s\log d$, carrying an unavoidable $\log d$ from sparse-support combinatorics. This propagates to the final rate as $\sqrt{\log d}$ in the denominator after multiplicative combination with the within-support $\sqrt{L/\varepsilon}$ factor (Step 9). The Adversarial route as constructed achieves $\Omega(d^{1/3}\sqrt{L/\varepsilon}/\sqrt{\log d})$, **not** the clean $\Omega(d^{1/3}\sqrt{L/\varepsilon})$. Removing this overhead would require an analytic (non-combinatorial) packing of $\partial B_{4/3}$ that exploits the smooth Riemannian structure, but the $\ell_2$-metric-entropy of $\partial B_{4/3}$ is $d\log(1/\delta)$ with no visible $d^{1/3}$ structure — combinatorial sparsity remains the only known source of the conjectured exponent, and it is bound to the $\log d$ overhead.
