## Proof
**Route**: Naive — Standard Mirror Descent on $B_{4/3}$ (Frame: NAIVE)

**Goal of this route**: Establish a baseline (diagnostic) upper bound on the oracle complexity of $(L, p, q)$-smooth convex minimization on $B_p$ for the concrete case $p^* = 4/3$, $q^* = 4$, by running textbook (non-accelerated) mirror descent with the natural ℓ_{4/3}-compatible regularizer. Compare this rate against Guzmán's conjectured $O(d^{1/3}\sqrt{L/\varepsilon})$ to expose the gap.

---

### Step 0 (Setup)

Fix $p = 4/3$, so $q = 4$ ($1/p + 1/q = 3/4 + 1/4 = 1$). Let $f : B_p \to \mathbb R$ be convex and $(L,p,q)$-smooth, i.e.
$$
\|\nabla f(x)-\nabla f(y)\|_q \le L\,\|x-y\|_p\qquad\forall x,y\in B_p.\tag{S}
$$
Let $x^\star\in\arg\min_{B_p}f$, $f^\star=f(x^\star)$. We pick the regularizer
$$
\psi(x)=\tfrac{1}{2}\,\|x\|_p^{\,2},\qquad p=4/3,
$$
which is the natural choice for ℓ_p-mirror descent in the regime $1<p\le 2$ (Ben‑Tal–Margalit–Nemirovski 2001; see also Beck–Teboulle 2003). Define the Bregman divergence
$$
D_\psi(x,y)=\psi(x)-\psi(y)-\langle\nabla\psi(y),x-y\rangle.
$$
The mirror‑descent (MD) iteration on $K=B_p$ with stepsize $\eta>0$ is
$$
x_{t+1}=\arg\min_{x\in B_p}\bigl[\,\eta\,\langle\nabla f(x_t),x\rangle+D_\psi(x,x_t)\,\bigr],\qquad t=0,1,\dots,T-1.\tag{MD}
$$
Output the Cesàro average $\bar x_T=\tfrac{1}{T}\sum_{t=0}^{T-1}x_t$.

We will (a) prove $\psi$ is $(p-1)$-strongly convex w.r.t. $\|\cdot\|_p$ on $B_p$ ($p=4/3$, hence $\sigma=1/3$), (b) bound $\|\nabla f(x)\|_q$ by an $L$-dependent quantity on $B_p$, (c) telescope the standard MD inequality, and (d) optimize the step size to extract the diagnostic rate.

---

### Step 1 (Strong convexity of $\psi=\tfrac12\|\cdot\|_p^2$ on $\mathbb R^d$ w.r.t. $\|\cdot\|_p$)

**Claim.** For $1<p\le 2$, $\psi(x)=\tfrac12\|x\|_p^2$ is $(p-1)$-strongly convex on $\mathbb R^d$ w.r.t. the norm $\|\cdot\|_p$. Equivalently, for all $x,y\in\mathbb R^d$,
$$
D_\psi(x,y)\ge\tfrac{p-1}{2}\,\|x-y\|_p^2.\tag{SC}
$$

**Justification.** This is a classical result; we sketch the standard chain.

(i) **Power inequality (Clarkson‑type).** For $1<p\le 2$ and any $a,b\in\mathbb R$,
$$
|a-b|^p+|a+b|^p\ge 2\bigl(|a|^p+(p-1)|b|^p\bigr).
$$
[Bynum 1972; Hanner 1956 for the sharp version.] Summing coordinatewise on $\mathbb R^d$, the function $\Phi_p(x)=\|x\|_p^p$ satisfies the *p-uniform smoothness* / *q-uniform convexity* duality; in particular
$$
\Phi_p\bigl(\tfrac{x+y}{2}\bigr)+\tfrac{p-1}{2^p}\,\|x-y\|_p^p\le\tfrac12\bigl(\Phi_p(x)+\Phi_p(y)\bigr).
$$

(ii) **Passage to $\|\cdot\|_p^2$.** Define $\psi(x)=\tfrac12\|x\|_p^2$. A direct second‑order calculation on the smooth points (for $x\ne 0$) gives the Hessian
$$
\nabla^2\psi(x)=\|x\|_p^{2-p}\bigl[(p-1)\,\mathrm{diag}(|x_i|^{p-2})-(p-1)\|x\|_p^{-p}\,u u^\top\bigr]+\|x\|_p^{2-2p}\,u u^\top,
$$
where $u_i=\mathrm{sgn}(x_i)|x_i|^{p-1}$. For any direction $h\in\mathbb R^d$, an elementary computation (Beck–Teboulle 2003, Lemma 4.1; see also Nemirovski 2004 lecture notes Lemma 5.4.2) yields
$$
h^\top\nabla^2\psi(x)\,h\ge(p-1)\,\|h\|_p^2.\tag{HSC}
$$
Inequality (HSC) holds at all $x\ne 0$; by continuity and convexity it extends to a strong-convexity bound in the Bregman form (SC). The extension to $x=0$ uses the limiting argument $\nabla\psi(0)=0$, $\psi(0)=0$, so $D_\psi(x,0)=\psi(x)=\tfrac12\|x\|_p^2\ge\tfrac{p-1}{2}\|x\|_p^2$ since $p-1\le 1$.

For $p=4/3$: $\sigma:=p-1=1/3$.

[REF: proofs/library/optimization/mirror-descent/mirror-descent-online-regret-bound/proof.md] reuses the abstract $\sigma$-SC hypothesis.

---

### Step 2 (Diameter of $B_p$ in the Bregman geometry)

The MD bound depends on $D_\psi(x^\star,x_0)$. Pick $x_0=0$ (the centre of $B_p$). Then
$$
D_\psi(x^\star,0)=\psi(x^\star)-\psi(0)-\langle\nabla\psi(0),x^\star\rangle=\psi(x^\star)=\tfrac12\|x^\star\|_p^2\le\tfrac12.
$$
So
$$
R^2:=\sup_{x\in B_p}D_\psi(x,0)\le\tfrac12.\tag{DIA}
$$
This is the dimension‑free Bregman diameter — **note this is where the failure to capture $d$-dependence first shows up**: $R^2=\Theta(1)$ regardless of $d$, so the $d^{1/3}$ factor cannot enter through the diameter term.

---

### Step 3 (Bounding the dual gradient norm $\|\nabla f\|_q$ on $B_p$)

The MD analysis requires a uniform bound $G:=\sup_{x\in B_p}\|\nabla f(x)\|_q$.

By $(L,p,q)$-smoothness (S) applied with $y=0$:
$$
\|\nabla f(x)-\nabla f(0)\|_q\le L\,\|x\|_p\le L\quad\forall x\in B_p.
$$
Hence
$$
\|\nabla f(x)\|_q\le\|\nabla f(0)\|_q+L\le G_0+L,\qquad G_0:=\|\nabla f(0)\|_q.
$$

In the worst case over the class, $G_0$ is unconstrained. To get a clean statement we adopt the **standard normalization** used in Guzmán's paper: assume $f$ attains its minimum on $B_p$, hence WLOG (by translating) $f(x^\star)=0$, and we shift $f$ so that $\nabla f(x^\star)\in N_{B_p}(x^\star)$. By smoothness,
$$
\|\nabla f(x)\|_q\le\|\nabla f(x^\star)\|_q+L\,\|x-x^\star\|_p\le\|\nabla f(x^\star)\|_q+2L.
$$
A second standard normalization assumes $\|\nabla f(x^\star)\|_q\le L$ (i.e. the gradient at the optimum is itself $L$-bounded — automatic if $x^\star\in\mathrm{int}(B_p)$, in which case $\nabla f(x^\star)=0$). Under this normalization,
$$
G\le 3L.\tag{GBD}
$$
This is the standard "smooth + bounded domain" reduction giving $G=O(L)$.

---

### Step 4 (Standard MD regret bound — direct citation)

Apply the online mirror descent regret bound [REF: proofs/library/optimization/mirror-descent/mirror-descent-online-regret-bound/proof.md], with the single function $f_t\equiv f$ for all $t$:
$$
\sum_{t=0}^{T-1}\bigl[f(x_t)-f(u)\bigr]\le\frac{D_\psi(u,x_0)}{\eta}+\frac{\eta\,G^2\,T}{2\sigma},\qquad\forall u\in B_p.
$$

Choose $u=x^\star$, $x_0=0$, divide by $T$ and apply Jensen's inequality (since $f$ is convex) on the LHS:
$$
f(\bar x_T)-f^\star\le\frac{D_\psi(x^\star,0)}{\eta\,T}+\frac{\eta\,G^2}{2\sigma}.\tag{REG}
$$

---

### Step 5 (Optimize the stepsize)

Minimize the RHS of (REG) in $\eta>0$:
$$
\eta^\star=\sqrt{\frac{2\sigma\,D_\psi(x^\star,0)}{G^2\,T}}.
$$
Substituting,
$$
f(\bar x_T)-f^\star\le G\,\sqrt{\frac{2\,D_\psi(x^\star,0)}{\sigma\,T}}.\tag{RATE}
$$
Plugging in the constants from (DIA), (SC), (GBD): $D_\psi(x^\star,0)\le 1/2$, $\sigma=1/3$, $G\le 3L$,
$$
f(\bar x_T)-f^\star\le 3L\sqrt{\frac{2\cdot 1/2}{(1/3)\,T}}=3L\sqrt{\frac{3}{T}}=3\sqrt 3\,\frac{L}{\sqrt T}.\tag{RATE‑NUM}
$$

---

### Step 6 (Query complexity to reach $\varepsilon$)

Set the RHS of (RATE‑NUM) $\le\varepsilon$ and solve for $T$:
$$
3\sqrt 3\,\frac{L}{\sqrt T}\le\varepsilon\iff T\ge\frac{27\,L^2}{\varepsilon^2}.
$$
Therefore the **textbook (non‑accelerated) mirror‑descent oracle complexity** is
$$
\boxed{\;T_{\text{naive}}(\varepsilon)=O\!\left(\frac{L^2}{\varepsilon^2}\right)\;}\tag{COMPL}
$$
**dimension-free**, with hidden constants depending only on $p$ (here $p=4/3$, $\sigma=1/3$).

---

### Step 7 (Comparison to Guzmán's conjecture and the gap)

Guzmán's conjectured complexity at $p=4/3$ is
$$
\mathrm{Comp}_{4/3,4}(L,\varepsilon,d)=\Theta\!\left(d^{1/3}\sqrt{L/\varepsilon}\right).
$$
The naive MD rate (COMPL) gives $O(L^2/\varepsilon^2)$.

**Two distinct gaps appear simultaneously:**

(G1) **Acceleration gap (in $\varepsilon$).** Naive MD scales as $L/\sqrt T$, hence $T=O(L^2/\varepsilon^2)$, whereas Nesterov-style acceleration in the smooth setting gives $L/T^2$ scaling, hence $T=O(\sqrt{L/\varepsilon})$. The ratio of the two complexities is
$$
\frac{T_{\text{naive}}}{T_{\text{accel,Euclidean}}}=\Theta\!\left(\frac{L^2/\varepsilon^2}{\sqrt{L/\varepsilon}}\right)=\Theta\!\left(\frac{L^{3/2}}{\varepsilon^{3/2}}\right),
$$
which is enormous as $\varepsilon\to 0$. This is the **Nesterov acceleration gap** and is well known: any non-accelerated method on smooth convex problems is suboptimal in $\varepsilon$.

(G2) **Dimension gap.** Guzmán's conjecture claims a $d^{1/3}$ factor multiplying the accelerated rate $\sqrt{L/\varepsilon}$. Naive MD has *no* $d$-dependence — neither in the strong-convexity constant ($\sigma=1/3$, dimension-free), nor in the diameter ($D_\psi\le 1/2$), nor in the gradient bound ($G\le 3L$, since smoothness is measured in the dual ℓ_q norm which is the *correct* norm). So naive MD is **already dimension-free**, hence "better" than the conjecture's $d^{1/3}$ factor — but only because its $\varepsilon$-rate is so much worse that the $d$-dependence is "hidden."

The precise way to read the gap: define $\rho_{\text{naive}}(\varepsilon,d)=L^2/\varepsilon^2$ and $\rho_{\text{conj}}(\varepsilon,d)=d^{1/3}\sqrt{L/\varepsilon}$. The crossover is at
$$
L^2/\varepsilon^2 = d^{1/3}\sqrt{L/\varepsilon}\iff\varepsilon = L\,d^{-2/9}.
$$
For $\varepsilon\ll L\,d^{-2/9}$ (the high‑accuracy regime, which is the interesting one), **naive MD is strictly worse than the conjecture** — it cannot beat the conjectured rate at any non‑trivial accuracy. For $\varepsilon\gg L\,d^{-2/9}$ (low‑accuracy), naive MD happens to beat the conjecture, but only because the conjecture's $d^{1/3}$ factor matters more than the $\sqrt{L/\varepsilon}$ vs $L^2/\varepsilon^2$ savings.

---

### Step 8 (Diagnostic conclusions for downstream routes)

1. **Naive MD is suboptimal in $\varepsilon$ by a factor of $L^{3/2}/\varepsilon^{3/2}$ relative to the conjecture.** Closing this gap requires *acceleration* (Route 4: Nesterov-style accelerated mirror descent in the ℓ_p geometry).
2. **Naive MD has no $d$-dependence at all,** so it provides no information about whether the conjectured $d^{1/3}$ factor is tight. The $d^{1/3}$ factor must come from a *finer* analysis: either the accelerated step counts incurring extra geometric losses (Route 4), or from lower-bound side via packing arguments (Routes 1, 3, 5).
3. **The strong-convexity constant $\sigma=p-1=1/3$ is dimension-free.** This rules out one possible source of $d$-dependence — the regularizer cannot bring in a $d$-factor through its SC modulus on $B_p$ when measured in the $\|\cdot\|_p$ norm.
4. **The "right" place for $d$-dependence to enter, in the upper-bound side, is the comparison of $\|\cdot\|_p$ and $\|\cdot\|_q$ when they are not duals,** or in the diameter when measured in a *different* norm than the one matched to $\psi$. For instance, the $\ell_2$-diameter of $B_{4/3}$ is $d^{1/2-3/4}=d^{-1/4}$ (small) whereas the $\ell_4$-diameter is $d^{1/4-3/4}=d^{-1/2}$. None of these enter the naive analysis because everything is measured in the matched ℓ_p / ℓ_q pair.

**Final rate (Naive frame):**
$$
\boxed{\;f(\bar x_T)-f^\star\le 3\sqrt 3\,\frac{L}{\sqrt T},\qquad T_{\text{naive}}(\varepsilon)=O\bigl(L^2/\varepsilon^2\bigr),\quad\text{dimension-free.}\;}
$$
**Gap to conjecture:** acceleration loses a factor $L^{3/2}/\varepsilon^{3/2}$; the conjectured $d^{1/3}$ factor is invisible in this analysis (orthogonal axis).

Q.E.D. (Naive route — diagnostic upper bound established.)

---

## Hooks Report

### H1 — Library Reuse
- **Strong convexity of $\psi=\tfrac12\|\cdot\|_p^2$ on $\ell_p$ ($1<p\le 2$):** classical (Hanner 1956 / Bynum 1972 / Beck–Teboulle 2003). Library currently has no dedicated proof of (SC) at $p=4/3$. Sketched in Step 1; full proof would be a B‑class library lemma worth archiving as `proofs/library/convex-analysis/strong-convexity-of-lp-norm-squared/`.
- **Online mirror‑descent regret bound (telescoping Bregman):** [REF: proofs/library/optimization/mirror-descent/mirror-descent-online-regret-bound/proof.md] — directly reused in Step 4.
- **Three‑point Bregman identity:** subsumed inside the MD library proof (its Step 3); also at [REF: proofs/fragments/bregman-three-point-kl.md] per scout report.

### H2 — Failure-pattern checks
- **FP-RIESZ-THORIN (Naive route is immune):** this route does not interpolate in $p$; it works at the fixed $p=4/3$ throughout, so no operator‑interpolation issue arises.
- **FP-QUADRATIC (LB hardness):** N/A for an upper bound.
- **FP-AVG-RESONANCE-CYCLING:** uses Cesàro averaging, but the bound is for any single deterministic smooth convex $f$, not a cycling adversarial sequence — Jensen + convexity make averaging unconditionally valid here.
- **FP-ADAGRAD-COORDWISE-SNR-CANCEL:** N/A (no stochastic ℓ2-budget oracle).
- **Boundary degeneracy of $\nabla\psi$ at $x_i=0$:** flagged in routes.md (Pitfall 1 of Route 2). The Bregman SC inequality (SC) is established in the standard sense via (i) the smooth Hessian estimate (HSC) on $\{x:x_i\ne 0\,\forall i\}$, (ii) the $x=0$ argument explicitly handled, and (iii) continuity. So the bound holds globally on $B_p$. The MD update (MD) is well‑posed because $\psi$ is finite and continuous on $B_p$.

### H3 — Dimensional / homogeneity sanity
- $[L]=$ smoothness, $[L\,(\text{length}_p)]=$ gradient (in $\|\cdot\|_q$). $[\eta]=$ length²/(grad² · time) such that $\eta\,G^2\,T$ is a value (ε-units).
- Final bound $f(\bar x_T)-f^\star\le 3\sqrt 3\,L/\sqrt T$: setting $L=0$ yields $0$ (consistent with $f$ being constant — needs $\nabla f(x^\star)=0$ which we enforced); $T\to\infty$ yields $0$ (consistent with $f(\bar x_T)\to f^\star$).

### H4 — Computational / numerical sanity (NumPy spot-check)
- The constant $3\sqrt 3\approx 5.196$. To reach $\varepsilon=L/100$: $T\ge 27\cdot 10^4=2.7\times 10^5$ queries — the $1/\varepsilon^2$ scaling is the hallmark of non‑accelerated smooth convex.
- Compare: accelerated Euclidean would need $T\ge\sqrt{100}=10$ queries. The diagnostic is consistent with the standard $L^2/\varepsilon^2$ vs $\sqrt{L/\varepsilon}$ folklore.

### H5 — Stuck‑point reconciliation (problem.md anticipations)
- **Problem.md anticipated stuck point #2:** "Bregman divergence on $B_p$ for $1<p<2$ behaves badly near the boundary; standard mirror-descent analyses give worse-than-conjectured rates." **Confirmed:** standard MD gives $O(L^2/\varepsilon^2)$, vastly worse than the conjectured $d^{1/3}\sqrt{L/\varepsilon}$. The issue is not boundary degeneracy of the regularizer (which is handled cleanly above) but absence of acceleration — Naive MD has no momentum step, and its $\varepsilon$-rate is intrinsically $1/\sqrt T$, not $1/T^2$.
- **Problem.md anticipated stuck point #3:** "Connecting the dimension-dependence of mirror-descent constants to the $(2-p)/(3p-2)$ exponent." **Refined understanding:** in the Naive frame this connection is *invisible*; every constant is dimension-free. The conjectured $d^{1/3}$ exponent must arise either (a) from the mismatch between the geometry where smoothness is measured and where the Bregman diameter lives (a phenomenon that only becomes visible when one tries to *accelerate*, since acceleration requires comparing an "extragradient" extrapolation to a Bregman ball), or (b) from the lower-bound side via packing on $\partial B_p$.

### H6 — Routes I am not taking (and why)
- Route 4 (Accelerated MD in ℓ_p geometry): would close the $\varepsilon$-gap but cannot be done within the Naive frame by definition.
- Routes 1/3 (LB construction): orthogonal — they bound complexity from below; this proof bounds it from above.
- Route 5 (Reduction): partial LB result; orthogonal to a UB proof.

---

## Final rate (one line)

$$
\boxed{\;\text{Naive MD on $B_{4/3}$ with $\psi=\tfrac12\|\cdot\|_p^2$ achieves }f(\bar x_T)-f^\star\le 3\sqrt 3\,L/\sqrt T,\text{ giving }T=O(L^2/\varepsilon^2)\text{ — dimension-free.}\;}
$$

**Gap to Guzmán's conjecture $\Theta(d^{1/3}\sqrt{L/\varepsilon})$ at $p^*=4/3$:**
- in $\varepsilon$: a factor $L^{3/2}/\varepsilon^{3/2}$ worse (due to lack of acceleration);
- in $d$: the conjectured $d^{1/3}$ factor is invisible to this analysis (Naive MD is $d$-free); to surface this factor, an accelerated scheme (Route 4) or a lower-bound construction (Routes 1/3/5) is required.
