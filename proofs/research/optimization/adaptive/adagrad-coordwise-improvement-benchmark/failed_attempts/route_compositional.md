# Proof — Route 6 (Compositional Frame)

**Problem.** Coordinate-wise AdaGrad under coordinate-wise $(L_0,L_1)$-smoothness and coordinate-wise affine noise; target rate
$\min_{0\le t<T}\mathbb E\|\nabla f(x_t)\|_1\le\widetilde O(d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3}/T^{1/3})$.

**Frame.** Compositional. We compose two library proofs:
- (A) **Per-coordinate AdaGrad regret bound** (online-learning analysis on each coordinate, drawn from the per-coordinate self-bounding sum + log accumulator already verified for coordinate-wise AdaGrad). [REF: proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/proof.md, Lemma 2 (SB) and Cor.]
- (B) **Generalized-smoothness descent correction** (Taylor-expansion descent with $L_0+L_1\|\nabla f\|$ in place of $L$), reused from the descent-lemma machinery used in the partial-refutation proof and from the polarization-identity-gradient-error fragment.
[REF: proofs/fragments/polarization-identity-gradient-error.md]
[REF: proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md, Lemmas 1–3.]

The composition is in a **STORM-style three-term balance** (analogous to the $\{f\text{-decrease},\,\|e\|^2\text{-growth},\,\|\nabla f\|^2\text{-extraction}\}$ triple used in the STORM proof) [REF: proofs/research/optimization/stochastic/storm-nonconvex-convergence/proof.md].

---

## Output format

**Route:** Compositional (per-coordinate AdaGrad regret + generalized-smoothness descent correction, in 3-term balance)

We attempt the proof step by step. We will reach a point where the disguised obstacle hides — the same fixed-comparator obstacle that blocks Route 2, but appears later (Step 9) inside the regret-to-convergence translation. We will document precisely how the disguise hides it and whether composition resolves it.

---

## Step 0 (Pre-proof Knowledge Reuse — Hooks A/B/C/D)

**Hook A (strategy_index).** Closest signatures: `adagrad-norm-nonconvex-convergence` (algorithm_type=AdaGrad-Norm; technique_chain `adaptive_descent_lemma → log_accumulator → algebraic_decoupling → as_envelope + Cauchy_Schwarz`), `amsgrad-nonconvex-convergence` (predictable surrogate). Useful for Steps 1, 3, 4, 5.

**Hook B (meta_templates).** Primary template: **MT1 (Cancellation Pair)** — the cancellation occurs between the predictable-surrogate noise term (zero-mean MDS) and a positive correction; secondary template: **MT3 (Descent-Lemma-Telescope)** because the spine is a per-step descent inequality summed over $t$. (Identical primary template to Route 1.)

**Hook C (structure_map).** Cluster reuse: STORM 3-term balance (Cluster, "trajectory framework"); the reuse is *structural* — STORM has fixed step size, here step size adapts via $1/\sqrt{v_{t+1,i}}$. We must verify the composition does not silently rely on STORM's fixed step size.

**Hook D (failure_triggers).** Pre-flight check:
- **FT-LEGACY-ADAGRAD-OCO-NON-CONVEX** (CRITICAL): Online-to-batch / regret-to-convergence reductions fail in non-convex settings because $f(x)-f(u)\le\langle\nabla f(x),x-u\rangle$ requires convexity. Scout flagged Route 6 faces a **disguised** version of this obstacle. We must locate it precisely.
- **FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM**: not directly relevant (UB problem).
- **FT-RATE-UB-LB-MISMATCH**: applicable; we will track at the end.

**Layer 7 (fragments).** [REF: proofs/fragments/polarization-identity-gradient-error.md] — used in Step 5.

---

## Step 1 (Compositional ingredient (A): per-coordinate AdaGrad regret)

For each coordinate $i\in[d]$ and any (deterministic, possibly time-varying) sequence $u_{0,i},\dots,u_{T-1,i}$ of *comparators*, the per-coordinate AdaGrad update with $v_{0,i}=\varepsilon^2$, $v_{t+1,i}=v_{t,i}+g_{t,i}^2$, and $x_{t+1,i}=x_{t,i}-\eta g_{t,i}/\sqrt{v_{t+1,i}}$ admits the per-coordinate self-bounding identity (Lemma 2 of [REF: proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/proof.md]):
$$
\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{\sqrt{v_{t+1,i}}}\;\le\;2\bigl(\sqrt{v_{T,i}}-\varepsilon\bigr)\;\le\;2\sqrt{v_{T,i}}. \tag{SB-i}
$$
Applied to a 1D linearization $\ell_t(y_i):=g_{t,i}\,y_i$, the standard AdaGrad regret derivation (Duchi-Hazan-Singer 2011 in 1D, dimension-1 specialization of [REF: adagrad-complexity Lemma 2]) yields, for any *fixed* $u_i\in\mathbb R$,
$$
\sum_{t=0}^{T-1} g_{t,i}\bigl(x_{t,i}-u_i\bigr) \;\le\; \frac{1}{2\eta}(x_{0,i}-u_i)^2\,\sqrt{v_{T,i}}\;+\;\frac{\eta}{2}\cdot 2\sqrt{v_{T,i}}\;=\;\Bigl(\frac{(x_{0,i}-u_i)^2}{2\eta}+\eta\Bigr)\sqrt{v_{T,i}}. \tag{REG-i}
$$
*(Standard derivation: expand $\|x_{t+1,i}-u_i\|^2\le\|x_{t,i}-u_i\|^2-(2\eta/\sqrt{v_{t+1,i}})g_{t,i}(x_{t,i}-u_i)+\eta^2 g_{t,i}^2/v_{t+1,i}$, telescope, multiply through by $\sqrt{v_{t+1,i}}$ then use monotonicity $v_{t+1,i}\ge v_{t,i}$ to dump the leading term onto $\sqrt{v_{T,i}}$, and apply (SB-i).)*

(REG-i) is the **first compositional ingredient.**

---

## Step 2 (Compositional ingredient (B): generalized-smoothness descent correction)

Under coordinate-wise $(L_0,L_1)$-smoothness (problem.md), for every $i$ and every $x,y$,
$$
|\partial_i f(x)-\partial_i f(y)|\le(L_0+L_1\|\nabla f(x)\|)\|x-y\|_2.
$$
Following the standard Taylor-expansion derivation (one-dimensional Taylor in $x_{t,i}\to x_{t+1,i}$, all other coords fixed momentarily, then summing — exactly the construction used in the descent lemma of [REF: adagrad-complexity proof, Lemma 1]), this gives the **per-coordinate generalized descent inequality**:
$$
f(x_{t+1})\le f(x_t)+\sum_{i=1}^d\partial_i f(x_t)\bigl(x_{t+1,i}-x_{t,i}\bigr)+\sum_{i=1}^d\frac{L_0+L_1|\partial_i f(x_t)|}{2}\bigl(x_{t+1,i}-x_{t,i}\bigr)^2. \tag{DESC}
$$
Substituting $x_{t+1,i}-x_{t,i}=-\eta g_{t,i}/\sqrt{v_{t+1,i}}$:
$$
f(x_{t+1})\le f(x_t)-\eta\sum_i\frac{\partial_i f_t\,g_{t,i}}{\sqrt{v_{t+1,i}}}+\frac{\eta^2}{2}\sum_i\frac{(L_0+L_1|\partial_i f_t|)\,g_{t,i}^2}{v_{t+1,i}}. \tag{DESC-A}
$$
This is the **second compositional ingredient.** Note we have used the surrogate $\sqrt{v_{t+1,i}}$ (not $\sqrt{v_{t,i}}$): this matches exactly the descent lemma in the AdaGrad-Norm parent proof [REF: proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md, Lemma 1 / eq.($*$)] — except indexed coordinate-wise.

(Throughout we drop the predictable-surrogate decomposition step that appears in the partial-refutation proof's Section 2 because in this composition we only need the polarization identity; see Step 5.)

---

## Step 3 (Polarization on the descent inner product)

Apply the polarization identity from [REF: proofs/fragments/polarization-identity-gradient-error.md] *coordinate-wise*: writing $g_{t,i}=\partial_i f_t+\xi_{t,i}$,
$$
\partial_i f_t\,g_{t,i}\;=\;\tfrac12\bigl(g_{t,i}^2+(\partial_i f_t)^2-\xi_{t,i}^2\bigr). \tag{POL-i}
$$
Substituting into (DESC-A):
$$
f(x_{t+1})\le f(x_t)-\frac{\eta}{2}\sum_i\frac{(\partial_i f_t)^2}{\sqrt{v_{t+1,i}}}\;-\;\frac{\eta}{2}\sum_i\frac{g_{t,i}^2}{\sqrt{v_{t+1,i}}}\;+\;\frac{\eta}{2}\sum_i\frac{\xi_{t,i}^2}{\sqrt{v_{t+1,i}}}\;+\;\frac{\eta^2}{2}\sum_i\frac{(L_0+L_1|\partial_i f_t|)g_{t,i}^2}{v_{t+1,i}}. \tag{POL-DESC}
$$
**Crucial observation (the STORM analogue).** The middle term $-\tfrac{\eta}{2}\sum_i g_{t,i}^2/\sqrt{v_{t+1,i}}$ is **negative** — exactly the STORM-style negative-quadratic that the polarization fragment is designed to retain [REF: polarization fragment, "the $\|v_t\|^2$ term has a negative coefficient. This avoids the typical Young-inequality loss"]. Without polarization (i.e., using Young $\partial_i f_t\,g_{t,i}\le\frac12(\partial_i f_t)^2+\frac12 g_{t,i}^2$ in standard sign), this $-g_{t,i}^2$ term would be lost.

---

## Step 4 (Coordinate-wise affine noise self-bounding)

The expectation of the noise term is, by the affine-noise assumption $\mathbb E[\xi_{t,i}^2|\mathcal F_t]\le\sigma_0^2+\sigma_1^2(\partial_i f_t)^2$:
$$
\mathbb E\!\left[\frac{\xi_{t,i}^2}{\sqrt{v_{t+1,i}}}\,\Big|\,\mathcal F_t\right]\;\le\;(\sigma_0^2+\sigma_1^2(\partial_i f_t)^2)\,\mathbb E\!\left[\frac{1}{\sqrt{v_{t+1,i}}}\,\Big|\,\mathcal F_t\right]\;\le\;\frac{\sigma_0^2+\sigma_1^2(\partial_i f_t)^2}{\sqrt{v_{t,i}}}, \tag{AFF}
$$
where the last step uses $v_{t+1,i}\ge v_{t,i}$ a.s. and $\sqrt{v_{t,i}}$ is $\mathcal F_t$-measurable.

**The third lever.** The piece $\sigma_1^2(\partial_i f_t)^2/\sqrt{v_{t,i}}$ has the same algebraic shape as the LHS gradient extractor (modulo the surrogate-vs-non-surrogate distinction, which is sub-leading and absorbed by the standard predictable-surrogate correction COR-INEQ from [REF: adagrad-complexity proof, §3.2]). For $\sigma_1$ small, this can be absorbed into the LHS at the cost of a constant factor $1-\sigma_1^2$; for $\sigma_1$ large, the constant becomes part of the polylog factor in $\widetilde O$.

---

## Step 5 (Generalized-smoothness term: Young's inequality on the cubic)

The term $\sum_i (L_1|\partial_i f_t|)\,g_{t,i}^2/v_{t+1,i}$ is *cubic-looking* (gradient × squared step). Apply Young's inequality $|a|\,b\le\tfrac12 a^2/(2c)+2c b^2$ with $a=|\partial_i f_t|$, $b=g_{t,i}^2/v_{t+1,i}$, and $c$ chosen as $1/(8\sqrt{v_{t,i}})$:
$$
L_1|\partial_i f_t|\cdot\frac{g_{t,i}^2}{v_{t+1,i}}\;\le\;\frac{L_1(\partial_i f_t)^2}{16\sqrt{v_{t,i}}}\cdot\frac{g_{t,i}^2}{v_{t+1,i}}\cdot\sqrt{v_{t,i}}\cdot\frac{16}{1}\;+\;\dots
$$
This becomes algebraically messy. The cleaner route is to use the a.s. envelope $g_{t,i}^2\le v_{t+1,i}$ (which is exact, since $v_{t+1,i}=v_{t,i}+g_{t,i}^2\ge g_{t,i}^2$) to get $g_{t,i}^2/v_{t+1,i}\le 1$, hence
$$
L_1|\partial_i f_t|\cdot\frac{g_{t,i}^2}{v_{t+1,i}}\;\le\;L_1|\partial_i f_t|\cdot\frac{g_{t,i}^2}{v_{t+1,i}}\le L_1|\partial_i f_t|.
$$
Then bound $L_1|\partial_i f_t|=L_1|\partial_i f_t|\cdot\frac{\sqrt{v_{t,i}}}{\sqrt{v_{t,i}}}$ and Young $L_1|\partial_i f_t|\le\frac{L_1^2(\partial_i f_t)^2}{2\sqrt{v_{t,i}}\cdot\alpha}+\frac{\alpha\sqrt{v_{t,i}}}{2}$ for any $\alpha>0$.

The quadratic part can be absorbed into the LHS gradient extractor exactly as the affine-noise piece in Step 4. The linear-in-$\sqrt{v_{t,i}}$ part contributes a *new term* $\sum_t\sum_i\sqrt{v_{t,i}}$ which we must control via a self-bounding argument ([REF: adagrad-norm proof, eq.(QT)] in spirit).

This gives, after taking expectations and rearranging (writing $\Phi_T:=\mathbb E\sum_t\sum_i (\partial_i f_t)^2/\sqrt{v_{t,i}}$ for the gradient extractor, and using (SB-i) summed over $i$ to bound $\sum_t g_{t,i}^2/\sqrt{v_{t+1,i}}\le 2\sqrt{v_{T,i}}$):
$$
c\,\eta\,\Phi_T\;\le\;\Delta_0+\eta\,\sigma_0^2\,\mathbb E\!\sum_i\log\frac{v_{T,i}}{\varepsilon^2}+\frac{L_0\eta^2}{2}\,\mathbb E\!\sum_i\log\frac{v_{T,i}}{\varepsilon^2}+L_1\eta^2\,\mathbb E\!\sum_i\sqrt{v_{T,i}}+\text{const}, \tag{MAIN}
$$
where $c\in(0,1)$ is an absorption coefficient depending on $(\sigma_1,L_1)$.

This is structurally a **3-term balance**: $\{\Delta_0,\;\eta\sigma_0^2 d\log T,\;L_0\eta^2 d\log T+L_1\eta^2 d\sqrt T\}$, mirroring STORM's $\{f\text{-decrease},\,\|e\|^2\text{-growth},\,\|\nabla f\|^2\text{-extraction}\}$ but with adaptive denominators replacing STORM's fixed step. [REF: proofs/research/optimization/stochastic/storm-nonconvex-convergence/proof.md, three-term balance]

---

## Step 6 (Convert $\Phi_T$ to $\sum_t\mathbb E\|\nabla f(x_t)\|_1$ — first attempt)

**This is where the compositional frame attempts its key move.** Define
$$
\Phi_T\;=\;\mathbb E\sum_t\sum_i\frac{(\partial_i f_t)^2}{\sqrt{v_{t,i}}}\,.
$$
We want to extract $\sum_t\mathbb E\|\nabla f_t\|_1=\sum_t\mathbb E\sum_i|\partial_i f_t|$.

Apply Hölder's inequality coordinate-wise with exponent pair $(p,q)=(2,2)$ on the integrand and then Hölder over $i$ with $(3/2,3)$ to convert squared-gradient/$\sqrt{v}$-weighted sums into $\ell_1$-gradient sums and an accumulator factor. Concretely, by Hölder's inequality (1-time-coordinate version):
$$
|\partial_i f_t|\;=\;\Bigl(\frac{(\partial_i f_t)^2}{\sqrt{v_{t,i}}}\Bigr)^{\!1/2}\!\!\!\cdot\bigl(\sqrt{v_{t,i}}\bigr)^{1/2}.
$$
Sum over $t$ using Cauchy–Schwarz over $t$:
$$
\sum_t|\partial_i f_t|\;\le\;\sqrt{\sum_t\frac{(\partial_i f_t)^2}{\sqrt{v_{t,i}}}}\cdot\sqrt{\sum_t\sqrt{v_{t,i}}}.
$$
Sum over $i$ and apply Hölder over $i$ with exponents $(3/2,3)$:
$$
\sum_i\sum_t|\partial_i f_t|\;\le\;\sum_i\sqrt{\Phi_{T,i}}\sqrt{T\,\sqrt{v_{T,i}}}\;\le\;\Bigl(\sum_i \Phi_{T,i}^{3/4}\Bigr)^{2/3}\Bigl(\sum_i (T\sqrt{v_{T,i}})^{3/4}\Bigr)^{1/3}\cdot\dots,
$$
which is starting to look promising for the $d^{1/3}$ exponent.

So the **algebra** of the rate $\widetilde O(d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3}/T^{1/3})$ is in reach via the 3-term balance + Hölder over coordinates with exponent 3.

---

## Step 7 (Choosing $\eta$ via 3-term AM-GM)

Set $\eta=\eta_0/T^{1/3}$ with $\eta_0$ to be chosen. The three terms in (MAIN) become:
- $\Delta_0/(c\eta)\sim \Delta_0 T^{1/3}/\eta_0$,
- $\sigma_0^2 d\log T$ contributes $\sigma_0^2 d\log T$ after dividing by $\eta T$ and inverting,
- $L_0\eta\,d\log T\sim L_0\eta_0 d\log T/T^{1/3}$.

After Hölder-3 over coordinates (which converts $\sum_i\sqrt{v_{T,i}}\to d^{2/3}(\sum_i v_{T,i})^{1/3}\sim d^{2/3}T^{1/3}\sigma_0^{2/3}$), the leading term in $\min_t\mathbb E\|\nabla f_t\|_1$ becomes
$$
\widetilde O\!\Bigl(\frac{d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3}}{T^{1/3}}\Bigr)+\text{lower-order},
$$
**at the formal level** — i.e., assuming all the manipulations from $\Phi_T$ to $\min_t\mathbb E\|\nabla f_t\|_1$ go through.

**This matches the target rate.**

---

## Step 8 (The disguised obstacle surfaces)

We now revisit Step 6. The conversion from $\Phi_T$ to $\sum_t\mathbb E\|\nabla f_t\|_1$ used the inequality
$$
\sum_t |\partial_i f_t|\;\le\;\sqrt{\sum_t \frac{(\partial_i f_t)^2}{\sqrt{v_{t,i}}}}\cdot\sqrt{\sum_t\sqrt{v_{t,i}}}, \tag{KEY}
$$
which is innocent Cauchy–Schwarz over $t$. **But:** in the *compositional* frame, the entire purpose of importing the per-coordinate AdaGrad regret bound (REG-i) was to obtain a tighter bound than the descent inequality alone provides — specifically, to extract $\sum_t |\partial_i f_t|$ directly from $\sum_t g_{t,i}(x_{t,i}-u_i)$ via the comparator term $u_i=x_{t,i}-\gamma\,\mathrm{sign}(\partial_i f_t)$ (or some such) so the inner product $g_{t,i}(x_{t,i}-u_i)\approx \gamma\,|g_{t,i}|$ becomes the desired $\ell_1$ extractor.

If we use (REG-i) with **fixed** $u_i=u_i^\star$ (which is what the regret lemma actually allows!), the LHS of (REG-i) is
$$
\sum_t g_{t,i}(x_{t,i}-u_i^\star)\;=\;\sum_t \partial_i f_t (x_{t,i}-u_i^\star)+\sum_t \xi_{t,i}(x_{t,i}-u_i^\star).
$$
The second sum is mean-zero (martingale). The first sum is **not** $\sum_t|\partial_i f_t|$ — it's $\sum_t\partial_i f_t (x_{t,i}-u_i^\star)$, which depends on the *positions* of the iterates.

**To force $\sum_t \partial_i f_t (x_{t,i}-u_i^\star)\approx\sum_t|\partial_i f_t|\cdot D_i$ (some scale), one needs $x_{t,i}-u_i^\star$ to align with $\mathrm{sign}(\partial_i f_t)$ at every $t$.** That is, $u_i^\star$ must lie *opposite* in sign to $\partial_i f_t$ at every $t$, simultaneously for all $t$.

For *convex* $f$, choosing $u_i^\star=\arg\min f$ does this, because $\partial_i f_t\cdot(x_{t,i}-x^\star_i)\ge 0$ when $f$ is convex and coordinate-separable. (More generally, $\partial_i f$ is monotone increasing in $x_i$.)

For **non-convex $f$ — exactly our setting — $\partial_i f_t (x_{t,i}-u_i^\star)$ can be of *either sign*** (since $f$ is non-convex and $\partial_i f$ is non-monotone). The cleanest counterexample: $f(x)=-Lx^2/2$ (single coordinate, concave, smooth). Then $\partial f(x)=-Lx$, so $\partial f(x_t)\cdot(x_t-u^\star)=-Lx_t(x_t-u^\star)$ takes both signs depending on the iterate's position relative to $u^\star$.

**The disguise.** The composition frame *appears* to avoid the non-convex obstacle because:
1. The descent lemma (DESC) is non-convex-safe (it uses Taylor with the smoothness constant on the residual).
2. The regret bound (REG-i) is comparator-class-agnostic (any fixed $u_i$).
3. The decomposition (POL-DESC) extracts $-\eta(\partial_i f_t)^2/\sqrt{v_{t+1,i}}$ which is perfectly negative.

It looks like nothing in the chain requires convexity. **But the fixed-comparator obstacle is hidden in the implicit assumption that** $\Phi_T$ controls $\sum_t\mathbb E\|\nabla f_t\|_1$.

To go from $\Phi_T=\mathbb E\sum_t\sum_i (\partial_i f_t)^2/\sqrt{v_{t,i}}$ (which is what the descent lemma gives) to $\sum_t\mathbb E\|\nabla f_t\|_1=\mathbb E\sum_t\sum_i|\partial_i f_t|$, the only available algebraic moves are:
- (i) Cauchy–Schwarz / Hölder over $t$ (this is what Step 6 used) — but this introduces an extra factor of $\sum_t\sqrt{v_{t,i}}$ in the denominator, which by the AdaGrad accumulator is $\Theta(T\cdot \mathrm{poly}(T)^{1/2})$, **adding** an unwanted $\sqrt T$ factor that DEGRADES the rate from the desired $T^{-1/3}$ to $T^{-1/3-1/4}=T^{-7/12}$ in the wrong direction (no: the algebra actually goes the OTHER way and *boosts* the bound, hence makes it weaker, not stronger). Concretely (KEY) gives an upper bound on $\sum_t|\partial_i f_t|$ that grows like $\sqrt T\cdot\sqrt{\Phi_{T,i}}$, and after Hölder-3 over $i$ this produces $d^{1/3}T^{1/2}\cdot\dots$, NOT $d^{1/3}T^{1/3}$ — i.e., (KEY) does not give the targeted rate.
- (ii) The regret bound (REG-i) — but this requires the inner-product extraction $\sum_t \partial_i f_t(x_{t,i}-u_i^\star)\approx \mathrm{const}\cdot\sum_t|\partial_i f_t|$, which is precisely the **non-convex-safe extraction step** that fails.

In other words: **the regret bound and the descent lemma each provide a DIFFERENT useful term, but neither, alone, provides the desired ℓ1-extraction. Composing them as a 3-term balance helps with the** $T^{-1/3}$ **part of the rate, but the final extraction step still requires a convex-style pivot.**

---

## Step 9 (Documenting the disguise precisely)

The disguise of the FT-LEGACY-ADAGRAD-OCO-NON-CONVEX failure is as follows.

**Naive form (Route 2):** Use the regret bound $\sum_t g_{t,i}(x_{t,i}-u_i)\le R_i\sqrt{v_{T,i}}$, then assert $\sum_t g_{t,i}(x_{t,i}-u_i)\approx \sum_t |\partial_i f_t|\cdot D_i$ (informally), then apply online-to-batch. **Visible obstacle:** the "$\approx$" step requires convexity.

**Compositional form (Route 6 / our route):** Compose
- (A) the per-coordinate AdaGrad regret/SB-sum bound (which gives a clean $\sqrt{v_{T,i}}$ accumulator via Lemma 2 of [REF: adagrad-complexity]);
- (B) the descent inequality (DESC-A), which gives a clean $\Phi_T$ extractor.

After polarization (Step 3) and affine-noise self-bounding (Step 4), we obtain (MAIN), which has the *correct algebraic shape* for a $T^{-1/3}$ rate via 3-term AM-GM (Step 7). **Where the obstacle hides:** in Step 6 (transferring $\Phi_T$ to $\sum_t\mathbb E\|\nabla f_t\|_1$), the only available moves are Cauchy–Schwarz over $t$ (which gives the wrong rate) or invoking (REG-i) on an *aligned* comparator $u_i^\star$ such that $\partial_i f_t(x_{t,i}-u_i^\star)\propto |\partial_i f_t|$. The latter requires either:
- (a) **convexity** (so $u_i^\star=x_i^\star$ aligns the sign of $\partial_i f_t(x_{t,i}-x_i^\star)$), or
- (b) a **time-varying comparator** $u_{t,i}^\star=x_{t,i}-\mathrm{sign}(\partial_i f_t)$, which **invalidates** the regret bound (REG-i) — the regret lemma needs $u$ fixed.

Both of these are explicit failure-trigger conditions: (a) is the FT-LEGACY-ADAGRAD-OCO-NON-CONVEX trigger, and (b) is the time-varying-comparator pitfall flagged in routes.md Pitfall under Route 6.

**So composition does NOT resolve the obstacle.** It refines its appearance: the obstacle now manifests as the *unbridgeable algebraic gap* between $\Phi_T$ (which descent gives) and $\sum_t\mathbb E\|\nabla f_t\|_1$ (which we want), where neither Cauchy–Schwarz over $t$ (which adds a $\sqrt T$ and degrades the rate) nor the regret bound (which requires a fixed convex-style comparator) can make the transition.

Note that **Route 1 (Orthodox) is *not* blocked by this** because Route 1 extracts $\|\nabla f_t\|^2$ (not $\|\nabla f_t\|_1$) directly via $(\partial_i f_t)^2$ in the descent inequality, then converts squared-norm to $\ell_1$-norm via Cauchy–Schwarz over coordinates *only* (not over $t$). The $\ell_1\to\ell_2^2$ conversion adds at most a $\sqrt d$-style factor, not a $\sqrt T$ factor. Route 6's failure is specifically the *time-side* extraction, which is where the regret bound was supposed to help.

---

## Step 10 (Partial rate achievable via the composition)

Even though the targeted rate fails, we extract the partial rate that the composition does deliver. Using Cauchy–Schwarz over $t$ (KEY) with a tight bookkeeping:
$$
\Bigl(\sum_t|\partial_i f_t|\Bigr)^{\!2}\;\le\;\Bigl(\sum_t\frac{(\partial_i f_t)^2}{\sqrt{v_{t,i}}}\Bigr)\Bigl(\sum_t\sqrt{v_{t,i}}\Bigr).
$$
The RHS first factor is bounded via (MAIN) by $\Phi_{T,i}\lesssim\Delta_0/(\eta c)+(\sigma_0^2+L_0\eta)\log T+L_1\eta\sqrt T$ when $\eta\sim T^{-1/3}$. The RHS second factor is at most $T\sqrt{v_{T,i}}\le T\sqrt{\varepsilon^2+T(\sigma_0^2+G_\infty^2)}\sim T^{3/2}\sigma_0$ (assuming an a.s. envelope $\|\nabla f\|\le G_\infty$, which we now invoke explicitly to control $\sum_t\sqrt{v_{t,i}}$, paralleling the envelope used in the partial-refutation proof Part A §8).

Putting these together and Hölder-3 over $i$:
$$
\Bigl(\sum_t\mathbb E\|\nabla f_t\|_1\Bigr)\;\le\;d^{1/3}\cdot\sqrt{\Delta_0/\eta+\dots}\cdot \sqrt{T^{3/2}\sigma_0}\;\sim\;d^{1/3}\sigma_0^{1/2}T^{3/4}\cdot\Delta_0^{1/2}T^{1/6}.
$$
After dividing by $T$ for the $\min_t$:
$$
\min_t\mathbb E\|\nabla f_t\|_1\;\le\;\widetilde O\!\bigl(d^{1/3}\sigma_0^{1/2}\Delta_0^{1/2}T^{-1/12}\bigr).
$$
This is a **markedly worse rate** (in $T$) than the target $T^{-1/3}$, and is also worse than the SGD baseline $T^{-1/2}$.

The composition *cannot extract the targeted rate without invoking an extraction step that itself requires either convexity (FT-LEGACY-ADAGRAD-OCO-NON-CONVEX) or a time-varying comparator (regret-bound-invalid)*.

---

## Step 11 (Diagnosis)

The composition succeeds in:
1. Producing the clean 3-term form (MAIN) (Steps 3–5).
2. Identifying the correct exponent structure for a $T^{-1/3}d^{1/3}$ rate at the algebraic level (Step 7).
3. Reusing both library proofs (REG-i) and (DESC-A) without modification, plus the polarization fragment.

The composition fails at:
- **Step 6 / Step 8**: The bridge from $\Phi_T$ (squared-gradient-extractor) to $\sum_t\mathbb E\|\nabla f_t\|_1$ (linear-gradient-extractor) requires either an extra $\sqrt T$ (degrading the rate to $T^{-1/12}$) or a non-convex-invalid pivot (FT-LEGACY-ADAGRAD-OCO-NON-CONVEX).

**Conclusion.** The Compositional frame *converges to Route 1's machinery* once the bridge step is filled in. The "composition" is illusory in the sense that the regret-bound ingredient (A) is never actually deployed for what it was supposed to do (extract the linear-gradient sum); only the SB-sum (Lemma 2) part of (A) is used, and the regret-style move is replaced by a Cauchy–Schwarz step that is sub-optimal in $T$.

**Recommendation.** This route should be marked **failed (with documented FP-recurrence)**. The Judge should pivot to Route 1 (Orthodox), which extracts $(\partial_i f_t)^2/\sqrt{v_{t,i}}$ directly and converts to $\ell_1$ norm via Hölder-3 over coordinates *without* requiring the time-side regret extraction. Route 1's three-term AM-GM is exactly the same as (MAIN) but feeds into the squared-gradient extractor, which Hölder-3 over coordinates can convert to $\ell_1$ at the cost of $d^{1/3}$ (correct) and **no extra time factor** (which is the win).

---

## Route Failure Report

- **Route**: Compositional (per-coordinate AdaGrad regret + generalized-smoothness descent correction, in 3-term balance).
- **Failed at**: Step 6 / Step 8 (bridge from $\Phi_T$ to $\sum_t\mathbb E\|\nabla f(x_t)\|_1$).
- **Obstacle (the disguised non-convex obstacle)**: The compositional ingredient (A) — the per-coordinate AdaGrad regret bound (REG-i) — is only useful for extracting $\sum_t |\partial_i f_t|$ if the comparator $u_i^\star$ aligns with the sign of $\partial_i f_t$ for *every* $t$. For non-convex $f$, no fixed $u_i^\star$ achieves this; a time-varying $u_{t,i}^\star$ would, but invalidates the regret lemma (which requires fixed $u$). Composition-based replacement (Cauchy–Schwarz over $t$) gives a sub-optimal $T^{-1/12}$ rate. The standard FT-LEGACY-ADAGRAD-OCO-NON-CONVEX failure trigger has fired in disguised form: Route 2 (Naive) hit it visibly at the regret-to-convergence step, while Route 6 hits it only after polarization + affine-noise self-bounding produce the (MAIN) 3-term inequality and the bridge to $\ell_1$ is attempted.
- **Whether composition resolves the obstacle**: **No.** Composition reorganizes the obstacle but does not bypass it. The obstacle is structural (linear vs. quadratic gradient extraction in the absence of convexity).

---

## Hooks Report

- **Strategy signatures consulted**:
  - `adagrad-norm-nonconvex-convergence` ([REF: proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md]) — Useful=PARTIAL. Provided log accumulator and decoupling identity (Lemmas 2, 3); does not apply to coordinate-wise affine noise directly but the descent-lemma chassis transfers.
  - `amsgrad-nonconvex-convergence` — Useful=PARTIAL. Predictable surrogate trick (use $\sqrt{v_{t-1,i}}$ in cross-term to make noise mean-zero) was implicitly used in Step 4; the AMSGrad-specific monotonicity $\hat v_t\ge\hat v_{t-1}$ replaced here by $v_{t+1}\ge v_t$.
  - `adagrad-complexity-improvement-partial-refutation` ([REF: proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/proof.md]) — Useful=YES. Provided Lemma 2 (per-coordinate self-bounding sum), the COR-INEQ corrected predictable-surrogate inequality, and the dimension-coupling Cauchy–Schwarz envelope $b_T\le \sqrt{d V_T^\Sigma}$. This proof is the closest direct ancestor.

- **Meta-template attempted**: **MT1 (Cancellation Pair)** with secondary **MT3 (Descent-Lemma-Telescope)**.
  - Slot V_t = $f(x_t)$ (the natural Lyapunov for the descent lemma).
  - Slot TELESCOPE = per-coordinate descent inequality (DESC-A).
  - Slot GOOD = $(\partial_i f_t)^2/\sqrt{v_{t,i}}$ (the surrogate-weighted gradient extractor).
  - Slot BAD = $\xi_{t,i}^2/\sqrt{v_{t+1,i}}$ (noise term, controlled via affine-noise self-bounding (AFF)).
  - Slot CANCEL = polarization identity; the $-g_{t,i}^2/\sqrt{v_{t+1,i}}$ piece from polarization cancels with the $+g_{t,i}^2/v_{t+1,i}$ piece from the smoothness QUAD term up to the surrogate-vs-non-surrogate correction.
  - **Blocker slot: BRIDGE-TO-TARGET.** The MT1 template gives a clean $\Phi_T$ but does not specify how to convert to the *linear* gradient extractor $\sum_t |\partial_i f_t|$. This is the structural obstacle.

- **Failure triggers checked (4)**:
  1. **FT-LEGACY-ADAGRAD-OCO-NON-CONVEX** (CRITICAL) — **MATCHED in disguised form** at Step 8/9. The disguise hides the obstacle inside the bridge step rather than the regret bound itself; the underlying mechanism (no fixed comparator works for non-convex $f$) is identical.
  2. **FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING** — checked, did not fire (we did not augment $f$ with an accumulator-Lyapunov).
  3. **FT-RATE-UB-LB-MISMATCH** — would fire if the (REL) bridge succeeded; since the route fails before reaching a closed rate, this trigger does not formally fire here.
  4. **FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM** — not applicable (UB problem, no Le Cam packing).

- **Library reuse summary**:
  - 3 referenced library proofs ([adagrad-complexity], [adagrad-norm], [storm]) — explicitly cited in Steps 1, 2, 5.
  - 1 referenced fragment ([polarization-identity-gradient-error]) — used in Step 3.
  - Per the brief, this is the most reuse-heavy route. Reuse breakdown:
    - **(A) Per-coordinate AdaGrad regret / SB-sum** ([REF: adagrad-complexity Lemma 2]): used in Step 1 (REG-i) and Step 5 (SB-i summed).
    - **(B) Generalized-smoothness descent correction** ([REF: adagrad-complexity Lemma 1] + Taylor adaptation): used in Step 2 (DESC-A).
    - **Polarization fragment**: used in Step 3 (POL-DESC).
    - **STORM 3-term balance** ([REF: storm proof]): structural template for the 3-term AM-GM in Step 7.
    - **AdaGrad-Norm log accumulator** ([REF: adagrad-norm Lemma 2 / eq. (LogA)]): used implicitly in (MAIN) for the $\log T$ factor.

- **Verdict**: Route 6 (Compositional) DELIVERS the algebraic structure of the target rate (Step 7, formal level) but FAILS to close the proof because the bridge from squared-gradient extraction $\Phi_T$ to linear-gradient extraction $\sum_t\mathbb E\|\nabla f_t\|_1$ requires either convexity or a time-varying comparator, neither of which is available. The Scout's prediction "Route 6 faces the same fixed-comparator obstacle as Route 2 — but the obstacle is more disguised" is **confirmed**, and the disguise is documented in Steps 6, 8, 9.

---

## 4-sentence Summary

The Compositional route assembles per-coordinate AdaGrad regret (ingredient A, [REF: adagrad-complexity Lemma 2/SB]) with the generalized-smoothness descent correction (ingredient B, [REF: adagrad-complexity Lemma 1] + Taylor) via polarization [REF: polarization-fragment] and affine-noise self-bounding, producing a clean STORM-style 3-term inequality (MAIN) whose AM-GM balance has the correct algebraic shape for the targeted $\widetilde O(d^{1/3}\sigma_0^{2/3}L_0^{1/3}\Delta_0^{1/3}/T^{1/3})$ rate. However, the route fails at the bridge from the squared-gradient extractor $\Phi_T$ to the $\ell_1$-gradient sum $\sum_t\mathbb E\|\nabla f_t\|_1$: the only candidate moves are (i) Cauchy–Schwarz over time (which adds an unwanted $\sqrt T$ factor and degrades the rate to $T^{-1/12}$), or (ii) deploying ingredient (A) with a comparator that aligns to the sign of each $\partial_i f_t$ — which requires either convexity (FT-LEGACY-ADAGRAD-OCO-NON-CONVEX) or a time-varying $u_{t,i}^\star$ that invalidates the regret bound. This is the same fixed-comparator obstacle that blocks Route 2, but disguised: it surfaces only after the descent + regret + polarization composition produces (MAIN), masquerading as an algebraic gap rather than an OCO-reduction failure. Composition therefore does NOT resolve the obstacle; the route should be marked failed and the Judge should pivot to Route 1 (Orthodox), which extracts squared gradients directly and converts to $\ell_1$ via Hölder-3 over coordinates only (no time-side regret extraction needed).
