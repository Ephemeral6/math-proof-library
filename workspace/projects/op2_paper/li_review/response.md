# OP-2 Peer Review Response — Three Technical Challenges by Xiao Li (CUHK Shenzhen)

**Date:** 2026-04-26
**Reviewer:** Xiao Li (Assistant Professor, CUHK Shenzhen)
**Target document:** `workspace/op2_downgraded_proof_v3_final.md`
**Auditor (this response):** Claude Code, post-final-audit reassessment
**Verification scripts:** `workspace/op2_li_review/verify_challenge1_cesaro.py`, `verify_challenge2_init.py`, `verify_challenge2_thorough.py`

---

## TL;DR

Li raises three challenges. The verdict on each is:

| # | Challenge | Verdict |
|---|-----------|---------|
| 1 | Last iterate vs ergodic rate | **VALID** — bias term collapses to $O(1/T^2)$ on Cesàro average. The LB is genuinely a last-iterate bound. |
| 2 | Initialization ($x_0=x_{-1}$) | **VALID** — for some $(\beta,\eta) \in \mathcal{F}$ (e.g., $\beta=0.7, \eta L=2.9$), zero-momentum init triggers geometric decay; the LB fails for 191/200 tested $T$ values. |
| 3 | Non-strongly-convex precision | **PARTIALLY VALID** — math is correct (global $\mu = 0$ is honestly proved in Claim 2.12), but framing should explicitly disclose the coordinate-decomposition structure. |

**The core OP-2 claim survives, but the title and scope statements need tightening.** Specifically, the result is not an "oracle complexity lower bound for SHB" simpliciter — it is a **last-iterate lower bound for fixed-momentum SHB under a specifically chosen two-point initialization, in the smooth-convex globally-non-SC setting where strong convexity is concentrated in a 2-D coordinate block**. Each of the three qualifiers is essential and was previously implicit.

---

## 质疑 1：Last iterate vs ergodic rate

### 审查结论
**VALID** — Li is correct. The bias term $\Omega(LD^2/T)$ does **not** transfer to the Cesàro-averaged iterate; on $\bar x_T$ the gap collapses to $O(1/T^2)$, which exactly matches the AC-SA acceleration rate.

### 详细分析

OP-2's proof (Lemma 2.6, Claim 2.8, Claim 2.10) proves $f_0(x_T) - f_0^\star \geq \kappa L D^2 / 4$ via the cycling identity $x_T = (D/\sqrt 2) e_{T \bmod K}$, and then converts this constant gap to the rate $(\kappa/4)\,L D^2/T$ for $T \geq 1$. The conversion is purely a "constant $\geq$ constant/$T$" argument and works only for the **last iterate** $x_T$.

For the Cesàro average $\bar x_T := (1/T)\sum_{t=1}^T x_t$, the cycling structure is **destructive of the bias term**:

For $K = 3$: vertices $e_0 = (1,0)$, $e_1 = (-1/2, \sqrt 3/2)$, $e_2 = (-1/2, -\sqrt 3/2)$ satisfy
$$e_0 + e_1 + e_2 = 0$$
exactly. So when $T$ is a multiple of $K=3$,
$$\bar x_T = \frac{D/\sqrt 2}{T}\sum_{t=1}^T e_{t \bmod 3} = 0\quad \text{exactly}.$$

For arbitrary $T$, the partial sum has at most $\|e_0\| + \|e_1\| = 2$ leftover vertex contributions, so
$$\|\bar x_T\| \leq \frac{D/\sqrt 2}{T}\cdot 2 = \frac{D\sqrt 2}{T}.$$

Since $f_0$ is $L$-smooth with $f_0(0) = 0$ and $\nabla f_0(0) = 0$,
$$f_0(\bar x_T) - f_0^\star \leq \frac{L}{2}\|\bar x_T\|^2 \leq \frac{L}{2}\cdot \frac{2 D^2}{T^2} = \frac{L D^2}{T^2}.$$

Compare with OP-2's last-iterate LB $(\kappa/4)\,LD^2/T$ — the Cesàro rate is **factor $T$ better in the bias term**, exactly the AC-SA acceleration that OP-2 is supposed to rule out.

### 数值验证结果

`verify_challenge1_cesaro.py` confirms:

| $T$ | last-iter $f_0(x_T)$ LB target | $f_0(\bar x_T)$ (numerical) | ratio |
|---|---|---|---|
| 100 | $6.25 \times 10^{-2}$ | $2.50 \times 10^{-5}$ | $4.0\times 10^{-4}$ |
| 1000 | $6.25 \times 10^{-2}$ | $2.50 \times 10^{-7}$ | $4.0\times 10^{-6}$ |
| 10000 | $6.25 \times 10^{-2}$ | $2.50 \times 10^{-9}$ | $4.0\times 10^{-8}$ |
| 100000 | $6.25 \times 10^{-2}$ | $2.50 \times 10^{-11}$ | $4.0\times 10^{-10}$ |

Moreover for $T \in \{99, 999, 9999, 99999\}$ (multiples of 3): $\bar x_T = 0$ to machine precision, so $f_0(\bar x_T) \approx 3.4 \times 10^{-33}$, *zero* up to floating-point error.

[VERIFIED: The Cesàro bias decay $f_0(\bar x_T) \in O(LD^2/T^2)$ on the cycling instance. This matches AC-SA's optimal bias rate.]

### Variance term: status under averaging

The variance term $\sigma D/\sqrt T$ on the $y$-coordinate is more nuanced. OP-2 proves it for the last iterate $y_T$ via Le Cam (Lemma 2.9). For the averaged iterate $\bar y_T$, the same construction does **not** directly give $\Omega(\sigma D/\sqrt T)$ — the misidentification event $\hat s \neq s$ defined as $\{\mathrm{sgn}(y_T) = s\}$ uses the last iterate's sign, not the average's sign. A more careful argument would use $\hat s := -\mathrm{sgn}(\bar y_T)$ and re-derive a gap bound.

For the algorithm-ignorant minimax bound, Agarwal et al. 2012 give $\Omega(\sigma D/\sqrt T)$ on the *output* of any first-order stochastic algorithm regardless of how it's constructed (last iterate, average, best iterate, etc.). So the variance lower bound on $\bar y_T$ holds for free via Agarwal et al., **but it is not algorithm-specific to fixed-momentum SHB** — it just says no algorithm can improve on $\sigma D/\sqrt T$.

### 对 OP-2 的影响

**The claim must be retitled and rescoped.**

- The current Main Theorem (§0.5) describes the bound as an "oracle complexity lower bound for fixed-momentum SHB". This wording is misleading because most SHB analyses report the *averaged* iterate (e.g., GFJ15 itself bounds $f(\bar x_T)$, not $f(x_T)$).
- The bound is genuinely an *algorithm-specific last-iterate lower bound* — and the gap between last-iterate and averaged-iterate is exactly the $T$ factor that distinguishes "non-acceleration" (claimed) from "acceleration via averaging" (achieved by averaging on the same trajectory).

This significantly weakens the headline claim. OP-2 does **not** rule out that, on cycling instances, *fixed-momentum SHB with Cesàro averaging* achieves $O(LD^2/T^2 + \sigma D/\sqrt T)$ — i.e., the AC-SA rate. In fact, our analysis above suggests this *does* happen on the bias term.

This is a substantive scope correction, not a wording fix. The "non-acceleration" claim should be downgraded to "non-acceleration of last-iterate fixed-momentum SHB on $\mathcal{F}$".

### 建议的修正措辞

Replace the title and §0.5 with:

> **Theorem (Main, restated).** ... such that the **last** SHB iterate $x_T$ generated by $(\beta,\eta)$ on this instance satisfies
> $$\mathbb{E}[f_{\beta,\eta}^{(T)}(x_T) - f_{\beta,\eta}^{(T),\star}] \geq c(\beta,\eta) \cdot \frac{LD^2}{T} + c_{\mathrm{NY}} \cdot \frac{\sigma D}{\sqrt T}.$$

Add a new **Remark 0.6.5** (Last-iterate vs averaged iterate) [insert before §0.6 Scope]:

> The bound is for the **last iterate** $x_T$. It does **not** apply to the Cesàro average $\bar x_T = (1/T)\sum_{t=1}^T x_t$. On the Goujaud cycling instance constructed in §2.1, the cycling identity $x_t = (D/\sqrt 2) e_{t \bmod K}$ together with $\sum_{t=0}^{K-1} e_t = 0$ implies
> $$\|\bar x_T\| \leq \frac{D\sqrt 2}{T}, \qquad f_0(\bar x_T) - f_0^\star \leq \frac{LD^2}{T^2},$$
> which **matches the AC-SA acceleration rate** in the bias term. Consequently, the non-acceleration conclusion of this paper is restricted to last-iterate SHB; the Cesàro-averaged iterate of fixed-momentum SHB on $\mathcal{F}$ may achieve the AC-SA rate $O(LD^2/T^2 + \sigma D/\sqrt T)$.
>
> This restriction is consistent with the line of work on last-iterate momentum lower bounds (Li–Liu–Orabona 2022 in the non-smooth setting; this paper in the smooth non-SC setting). For averaged iterates, GFJ15's deterministic upper bound is $O(LD^2/T)$, and our LB does not rule out a matching $\Omega(LD^2/T)$ on $\bar x_T$ — but the cycling construction does not establish it.

Update §4.6 (novelty summary) item 1 from:
> **First** rigorous lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$ for fixed-momentum SHB ...

to:
> **First** rigorous **last-iterate** lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$ for fixed-momentum SHB ...

---

## 质疑 2：Initialization condition (zero-momentum $x_0 = x_{-1}$)

### 审查结论
**VALID** — Li is correct. OP-2's cycling construction critically depends on the special two-point initialization $x_0 = (D/\sqrt 2) e_0$, $x_{-1} = (D/\sqrt 2) e_{K-1}$, where $e_0 \neq e_{K-1}$ implies a non-zero initial momentum $x_0 - x_{-1}$. Under the standard zero-momentum initialization $x_0 = x_{-1}$ (as used by SGD, Adam, and the GFJ15 upper-bound theorem), the cycling identity **does not start**, and for at least one $(\beta, \eta) \in \mathcal{F}$ tested, SHB **converges geometrically** rather than cycling.

### 详细分析

#### Failure of cycling at $t = 1$ under zero-momentum init

With $x_0 = x_{-1} = (D/\sqrt 2) e_0$, the SHB recursion gives
$$x_1 = x_0 - \eta \nabla f_0(x_0) + \beta(x_0 - x_{-1}) = x_0 - \eta \nabla f_0(x_0).$$
Using OP-2's gradient formula $\eta \nabla f_0(\lambda e_t) = \lambda[(1+\beta)e_t - e_{t+1} - \beta e_{t-1}]$ at $t=0$ (with $e_{-1} = e_{K-1}$):
$$x_1 = \lambda e_0 - \lambda[(1+\beta) e_0 - e_1 - \beta e_{K-1}] = \lambda[-\beta e_0 + e_1 + \beta e_{K-1}].$$

For cycling we need $x_1 = \lambda e_1$, but the actual value differs by $\lambda \beta(e_{K-1} - e_0) \neq 0$ for $\beta > 0$.

In OP-2's construction $(\beta, \eta, K) = (0.5, 3/L, 3)$:
$$e_0 - e_2 = (1,0) - (-1/2, -\sqrt 3/2) = (3/2, \sqrt 3/2),$$
so the initial deviation is $\lambda \cdot 0.5 \cdot \|e_2 - e_0\| = (D/\sqrt 2) \cdot 0.5 \cdot \sqrt 3 \neq 0$. Cycling fails at $t = 1$.

#### Two regimes empirically observed

`verify_challenge2_thorough.py` runs deterministic HB with **zero-momentum initialization** $x_0 = x_{-1} = (D/\sqrt 2) e_0$ for three feasible $(\beta, \eta) \in \mathcal{F}$ pairs and tracks $f_0(x_T)$ vs the OP-2 target $(\kappa/4)\,LD^2/T$ for $T = 1, \ldots, 200$:

**Case A: $(\beta, \eta L, \kappa) = (0.5, 3, 0.25)$** — orbit attracted to cycle, LB satisfied:
| $T$ | $f_0(x_T)$ zero-mom | target | ratio |
|---|---|---|---|
| 1 | $0.260$ | $0.0625$ | $4.15$ |
| 5 | $0.119$ | $0.0125$ | $9.55$ |
| 50 | $0.222$ | $0.00125$ | $178$ |
| 200 | $0.222$ | $0.000312$ | $711$ |

LB satisfied for **all $T \in [1, 200]$**. The orbit is attracted into the cycling orbit (||x_t|| → D/√2) within ~30 steps.

**Case B: $(\beta, \eta L, \kappa) = (0.9, 3.5, 0.45)$** — attracted to cycle but LB briefly fails:
| $T$ | $f_0(x_T)$ zero-mom | target | ratio |
|---|---|---|---|
| 4 | $0.00603$ | $0.0281$ | **0.21 (FAIL)** |
| 6 | $0.00854$ | $0.0188$ | **0.45 (FAIL)** |
| 10 | $0.0869$ | $0.0113$ | $7.72$ |
| 200 | $0.234$ | $0.000563$ | $416$ |

LB **fails for $T \in \{4, 6\}$**; for all other $T \in [1, 200]$ the LB holds. The orbit is briefly close to the origin during the transient before being kicked back to the cycling amplitude.

**Case C: $(\beta, \eta L, \kappa) = (0.7, 2.9, 0.336)$** — orbit converges geometrically, LB FAILS for nearly all $T$:
| $T$ | $f_0(x_T)$ zero-mom | target | ratio |
|---|---|---|---|
| 5 | $0.149$ | $0.0168$ | $8.88$ |
| 10 | $0.00756$ | $0.00840$ | **0.90 (FAIL)** |
| 50 | $1.37 \times 10^{-8}$ | $0.00168$ | **$10^{-5}$ (CATASTROPHIC FAIL)** |
| 100 | $2.04 \times 10^{-14}$ | $0.000840$ | **$10^{-11}$** |
| 200 | $1.75 \times 10^{-31}$ | $0.000420$ | **$10^{-28}$** |

LB **fails for 191 of 200 tested $T$ values**. SHB on the Goujaud function with zero-momentum init at this parameter exhibits **geometric convergence to the global minimum** — the cycling orbit is not even attractive.

[VERIFIED: For $(\beta, \eta) = (0.7, 2.9/L) \in \mathcal{F}_{K=3}$ (per OP-2's Step 1 sufficiency in §2.7) but with zero-momentum initialization, fixed-momentum HB on the OP-2 hard instance $f_0$ converges as $f_0(x_T) \in O(\rho^T)$ for some $\rho < 1$. The OP-2 lower bound $(\kappa/4)\,LD^2/T$ is violated for almost all $T$.]

#### Why this happens

The cycling orbit is a **fixed point of the SHB dynamics on $f_0$** (a $K$-periodic limit cycle). It exists as a closed invariant set, but it may or may not be attracting from generic initial conditions. Under the special two-point init $(\lambda e_0, \lambda e_{K-1})$, you start *on* the cycle — by construction. Under zero-momentum init, you start at $(\lambda e_0, \lambda e_0)$, which is *not* on the cycle and may flow either toward the cycle (Cases A, B) or toward the global minimum at $0$ (Case C).

The dichotomy depends on the spectral structure of the SHB linearization around the cycle vs around the origin. A rigorous characterization of which subset of $\mathcal{F}$ has cycling as an *attractor* (vs the origin) under generic initialization is an open question — and is exactly the gap that Li's challenge exposes.

### 对 OP-2 的影响

**This is the most damaging of the three challenges.**

The OP-2 theorem is technically valid in $\forall$-$\exists$ form because the existential quantifier covers $(x_0, x_{-1})$ — so the construction is permitted to choose a special initialization. But:

1. **Zero-momentum initialization is the de facto standard.** Every implementation of SHB / SGDM / Adam initializes with zero momentum $m_0 = 0$, equivalent to $x_0 = x_{-1}$. The community-relevant question — "does fixed-momentum SHB accelerate as actually deployed?" — is a question about zero-momentum initialization.

2. **OP-2's cycling-init is unphysical.** No practitioner runs SHB by setting $x_{-1} := $ rotation of $x_0$ by $2\pi/K$ at scale $D/\sqrt 2$, with $K$ chosen via cycling-feasibility analysis. This is a synthetic adversarial input chosen to *force* cycling.

3. **The $T$-dependence of the construction**: OP-2 already needs to choose the function $f^{(T)}_{\beta,\eta}$ as a function of $T$ (via wall radius $R = D/\sqrt 2 - \alpha/L$). Adding $T$-dependence (or $(\beta,\eta)$-dependence) of the initialization to make the construction work is acceptable in $\forall$-$\exists$, but increases the gap between "what the LB actually rules out" and "what the LB is colloquially claimed to rule out".

4. **GFJ15 and most upper bounds use zero-momentum init.** GFJ15's upper bound $f(\bar x_T) - f^\star \leq O(LD^2/T)$ for deterministic HB is stated for any initial $x_0$ with $\|x_0 - x^\star\| \leq D$; in their analysis, they implicitly assume zero momentum. So the "tightness" claim in §4.2 (that OP-2 + GFJ15 give matching $\Theta(LD^2/T)$) requires that **both** bounds hold in the same regime — which is true for the cycling-init *and* averaged iterate (where GFJ15 is upper bound, OP-2 is lower bound) only if OP-2's lower bound also covers averaged iterate (it doesn't, see Challenge 1) **and** standard initialization (it doesn't always, see Case C above).

The net result: **the "tight $\Theta(LD^2/T)$" claim in §4.2 (deterministic case) is partially broken**. It works for cycling-init last-iterate, but GFJ15's upper bound is for zero-momentum-init averaged iterate. The two bounds are not in the same regime.

### 建议的修正措辞

1. **Add explicit initialization scope to the Main Theorem statement.** Replace §0.5 line 82–86 with:

> Then for every $(\beta, \eta) \in \mathcal{F}$ and every integer $T \geq 1$, there exist:
> 1. a function $f^{(T)}_{\beta,\eta}: \mathbb{R}^3 \to \mathbb{R}$ ...
> 2. an **adversarially chosen** initial pair $(x_0, x_{-1}) \in \mathbb{R}^3 \times \mathbb{R}^3$ with $\|x_0 - x^\star\| = D$ and **non-zero initial momentum** $x_0 - x_{-1} \neq 0$ (specifically $x_0 = (D/\sqrt 2)(e_0, 0)$, $x_{-1} = (D/\sqrt 2)(e_{K-1}, 0)$);
> 3. an unbiased stochastic gradient oracle ...

2. **Add a Remark on zero-momentum initialization** [new Remark 0.7.1, after Remark 0.7]:

> **Remark 0.7.1 (Zero-momentum initialization).** The SHB cycling identity used in the proof critically requires the two-point initialization $(x_0, x_{-1}) = (\lambda e_0, \lambda e_{K-1})$ with $\lambda = D/\sqrt 2$ and $e_0 \neq e_{K-1}$, so that the initial momentum $x_0 - x_{-1}$ is non-zero. Under the **standard zero-momentum initialization** $x_0 = x_{-1}$ (used in SGDM, Adam, and most upper-bound analyses including GFJ15), the cycling identity does not start: the iterate does not lie on the periodic orbit at $t = 0, 1$. Empirically (Part 3, **NEW** §3.6), under zero-momentum init the dynamics fall into one of two regimes depending on $(\beta, \eta)$: (a) **attracted to cycling**, in which case the lower bound asymptotically holds modulo a transient (Cases A, B); (b) **attracted to origin** (geometric convergence), in which case the lower bound fails. Case (b) was observed at $(\beta, \eta L) = (0.7, 2.9)$, where the OP-2 LB target $(\kappa/4)\,LD^2/T$ is violated for 95% of $T \in [1, 200]$.
>
> **Open question.** Characterize the subset $\mathcal{F}_{\text{attract}} \subset \mathcal{F}$ on which the Goujaud cycling orbit is attracting under zero-momentum initialization. The OP-2 theorem statement is, strictly speaking, *only* about $\mathcal{F}$ with cycling-init — not necessarily $\mathcal{F}_{\text{attract}}$ with zero-momentum init.

3. **Add §3.6 Numerical evidence under zero-momentum initialization** to Part 3, showing the three cases above.

4. **Soften the §4.2 deterministic tightness claim**:

> ~~Combined: $\Theta(LD^2/T)$ for deterministic HB's Cesàro-average iterate on $\mathcal{F}$, with matching lower and upper bounds.~~

Replace with:

> Combined: For **last-iterate deterministic HB with cycling initialization**, OP-2 provides the lower bound $\Omega(LD^2/T)$. For **averaged-iterate deterministic HB with zero-momentum initialization**, GFJ15 provides the upper bound $O(LD^2/T)$. **These are different regimes**: the OP-2 LB does not directly imply tightness of GFJ15, and the true tightness picture for SHB depends jointly on initialization and aggregation rule (last vs averaged). A unified $\Theta(LD^2/T)$ tightness statement awaits either an averaged-iterate LB or a last-iterate UB matching the respective other regime.

---

## 质疑 3：Non-strongly-convex precision

### 审查结论
**PARTIALLY VALID** — the math is correct, but Li's reading is sharp: cycling fundamentally requires $\mu > 0$, and OP-2's "non-SC" claim is achieved via a coordinate-decomposition trick that should be foregrounded, not buried in Claim 2.12.

### 详细分析

#### What OP-2 actually proves

Claim 2.12 of OP-2 rigorously shows: $f^{(s)}(x, y) = f_0(x) + \alpha_s y + w(y)$ has Hessian
$$\nabla^2 f^{(s)}(0, 0) = \mathrm{diag}(L, L, 0)$$
at the origin (since $0 \in \mathrm{int}(\mathrm{conv}(\widetilde P))$, $\nabla P_{\widetilde P}(0) = I$, and $w''(0) = 0$). Hence the global strong-convexity constant — defined as the largest $\mu' \geq 0$ with $\nabla^2 f \succeq \mu' I$ a.e. — is $\mu' = 0$. Mathematically, "$f^{(s)}$ is convex but not strongly convex" is a true statement.

#### Where the strong convexity goes

The cycling argument of Lemma 2.6, however, **uses** $\mu > 0$ in two places:
1. (M-def) of the matrix $M$ has denominator $(L - \mu)\eta$, which would be undefined if $\mu = L$ but more importantly — $\mu > 0$ enters the cycling inequality (★) on which feasibility of $\mathcal{F}$ depends.
2. The gradient formula $\nabla f_0(x) = \mu x + (L - \mu) P_{\widetilde C}(x)$ separates a $\mu$-Tikhonov term and an $L-\mu$ projection term; the cycling identity is essentially $(\mu I + (L - \mu) M) e_t = $ rotational-shifted version, which is a $\mu$-dependent algebraic identity.

So strong convexity *of the $x$-block* is a **structural ingredient** of the proof. It is destroyed at the global level only by adding the non-strongly-convex $y$-direction with the wall function $w$, which contributes Hessian $0$ in a neighborhood of the optimum.

#### Reading Li's challenge

Li's question — "should this be more precise?" — is asking: a reader of the abstract or the Main Theorem might think OP-2 holds for "general non-strongly-convex smooth convex functions in 3-D". But it really holds for functions of a *very special form*: a $\mu$-strongly-convex 2-D function tensored with a non-SC 1-D wall function, where $\mu > 0$ is induced from the cycling-feasibility constraint. The phrase "L-smooth convex function with global strong-convexity constant exactly 0" is mathematically correct but glosses over this structural feature.

This is not a mathematical error — it's a **disclosure issue**.

#### Comparing with Li–Liu–Orabona 2022

It's worth noting that Li–Liu–Orabona's non-smooth LB has no analogous structure: their hard instance is a single non-smooth Lipschitz function in $d = T$ dimensions, not a coordinate decomposition. So OP-2's "non-SC via coordinate split" is a distinguishing structural feature that should be explicitly disclosed for readers comparing the two results.

### 数值验证结果

[VERIFIED algebraically:]
- $\nabla^2 f_0(0) = LI_2$ (since $0 \in \mathrm{int}(\widetilde P)$ implies $P_{\widetilde P} = \mathrm{id}$ near $0$, so $\nabla^2 f_0(x) = \mu I + (L-\mu) I = LI$ at $x = 0$).
- $w''(0) = 0$ (since $|0| < R$, $w \equiv 0$ in flat region).
- Hence $\nabla^2 f^{(s)}(0, 0) = \mathrm{diag}(L, L, 0)$, with smallest eigenvalue $0$. Global $\mu' = 0$ confirmed.
- Restricted to the $x$-subspace $\{(x, 0)\}$: $\nabla^2 f^{(s)}|_{x\text{-subspace}}(0, 0) = LI_2$, so the $x$-block is $\mu$-strongly convex (since $\nabla f_0$ has Hessian $\succeq \mu I_2$ everywhere in $x$).

### 对 OP-2 的影响

**Math is fine; framing should be sharpened.** The phrase "global strong-convexity constant exactly 0" is correct but should be paired with "the construction uses a coordinate decomposition; the $x$-block carries $\mu$-strong convexity needed for cycling, while the $y$-block kills global strong convexity".

### 建议的修正措辞

1. **Add a single sentence to the Main Theorem (§0.5)** after "globally 0-strongly-convex":

> ... a function $f^{(T)}_{\beta,\eta} : \mathbb{R}^3 \to \mathbb{R}$ which is convex and $L$-smooth (globally 0-strongly-convex; specifically, $f^{(T)}_{\beta,\eta} = f_0 \oplus (\alpha_s y + w(y))$ where $f_0$ is $\mu(\beta,\eta)$-strongly convex on $\mathbb{R}^2$ with $\mu(\beta,\eta) = \kappa(\beta,\eta) L > 0$, and $\alpha_s y + w(y)$ is convex but not strongly convex on $\mathbb{R}$; see Claim 2.12),

2. **Strengthen the Remark after Claim 2.12** to include a structural-honesty statement:

> **Remark (structural disclosure).** Although $f^{(s)}$ has global strong-convexity constant zero — fulfilling the hypothesis of `problem.md` — the construction is **not** an arbitrary smooth convex function. It decomposes as a tensor product of (a) a 2-D $\mu$-strongly-convex Goujaud function $f_0$, where $\mu = \kappa(\beta,\eta) L > 0$ is structurally needed for the cycling identity; and (b) a 1-D non-strongly-convex wall function $\alpha_s y + w(y)$, used to embed the Le Cam two-point construction. This decomposition is essential: any attempt to extend the LB to an *arbitrary* non-SC smooth convex function would require a non-Goujaud cycling argument, which does not exist in the literature for $\mu = 0$. The statement of the theorem is therefore "$\exists$ a non-SC smooth convex function with this structure ...", not "$\forall$ non-SC smooth convex functions".

3. **§4.6 novelty bullet 1** should be edited to reflect this:

> First rigorous **last-iterate** lower bound $\Omega(LD^2/T + \sigma D/\sqrt T)$ for fixed-momentum SHB on a structurally-decomposable hard instance (2-D strongly-convex $\oplus$ 1-D non-SC wall, globally 0-strongly-convex), under cycling-compatible two-point initialization.

---

## 综合判断

The three challenges are not independent — together they reveal that OP-2's claim, as currently stated, is significantly stronger than what the proof actually establishes. The honest statement of the result is:

> **Theorem (Main, fully scoped).** Let $L, \sigma, D > 0$ satisfy (RGM). For every $(\beta, \eta) \in \mathcal{F}$ and every integer $T \geq 1$, there exist a smooth convex function $f^{(T)}_{\beta,\eta}: \mathbb{R}^3 \to \mathbb{R}$ with global strong-convexity constant 0 (specifically, a tensor product of a 2-D $\kappa L$-strongly-convex Goujaud function and a 1-D non-SC wall), an **adversarially chosen** initial pair $(x_0, x_{-1})$ with non-zero initial momentum, and an unbiased stochastic oracle of variance $\sigma^2$, such that the **last** SHB iterate $x_T$ satisfies $\mathbb{E}[f(x_T) - f^\star] \geq (\kappa/4)\,LD^2/T + (1/112)\,\sigma D/\sqrt T$.

The three qualifiers — **last-iterate**, **adversarial init**, **structural non-SC** — are each necessary, and were each implicit in the previous statement.

### Severity assessment

| Challenge | Damage to claim | Fix difficulty |
|---|---|---|
| 1 (last-iterate) | Substantive — title/scope must change; "non-acceleration" claim must be downgraded | Medium — requires retitling and a new remark; bound itself unchanged |
| 2 (initialization) | Substantive — opens up an honest gap between OP-2 and "deployed SHB"; partially breaks §4.2 tightness picture | High — requires a new §3.6 numerical section and an honest scope remark; potentially leaves the $\mathcal{F}_{\text{attract}} \subsetneq \mathcal{F}$ as an open question |
| 3 (non-SC precision) | Cosmetic — math is right, framing needs sharpening | Low — single-sentence additions to theorem statement and one remark |

**Net verdict on OP-2:** The mathematical content is correct (no actual proof error). But the **headline claim** — "fixed-momentum SHB does not accelerate on a positive-measure region of stability" — is too strong. The honestly-scoped claim is "fixed-momentum SHB's *last iterate* under *cycling-init* does not accelerate on $\mathcal{F}$", which is significantly more restrictive but still novel and publishable.

### Recommended action

1. **Implement the Challenge-1 and Challenge-2 fixes immediately** (substantive scope corrections).
2. **Implement the Challenge-3 fix as a paper-polish edit**.
3. **Add new §3.6** "Sensitivity to initialization" with the three numerical cases.
4. **Retitle the paper** if the original title contained "lower bound for fixed-momentum SHB" without "last-iterate" or "cycling-init". Suggest:
   > "Last-iterate lower bound for fixed-momentum SHB on the Goujaud feasibility region: $\Omega(LD^2/T + \sigma D/\sqrt T)$ under cycling-compatible initialization"
5. **Revise the abstract** to lead with the qualifications.
6. **Acknowledge Li by name** in the acknowledgements if/when the corrections are implemented.

### Honesty note

Two of the three challenges (1 and 2) are genuinely substantive and were missed in the four-track final audit (`op2_audit_final.md`). The audit's confidence rating "HIGH" should be revised to "MEDIUM, conditional on scope tightening". The Track 4 framing — "what would a GTD23 author notice?" — was the wrong reference frame; an SHB-upper-bound author (like GFJ15) would have caught the averaged-iterate gap immediately, since that's the canonical aggregation in their analysis. Future audits should explicitly probe initialization and aggregation-rule scope.

---

*End of response.*
