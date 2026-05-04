# Proof of Coordinate-wise AdaGrad Non-Convex Convergence — Route 2

**Route name**: Predictable-Surrogate Denominator via AMSGrad Trick + Per-Coordinate Log-Accumulator + Final Cauchy–Schwarz on Coordinates (MT1 — Cancellation Pair, with AMSGrad-style predictable-surrogate as the cancellation source).

**Scope**: Part A (Upper Bound). Part B is handled separately by the LB explorers (Routes 3/4/6); we mention it only at the end and flag where Route 2 cannot help.

**Theorem (Part A).** Under the assumptions of `problem.md` ($f\colon\mathbb{R}^d\to\mathbb{R}$ is $L$-smooth, $f(x_0)-\inf f =\Delta_0$, $\mathbb{E}[\xi_t\mid\mathcal F_t]=0$, $\mathbb{E}[\|\xi_t\|^2\mid\mathcal F_t]\le\sigma^2$), the coordinate-wise AdaGrad iterates
$$x_{t+1,i}=x_{t,i}-\frac{\eta\,g_{t,i}}{\sqrt{v_{t,i}}},\qquad v_{t,i}=v_{t-1,i}+g_{t,i}^2,\quad v_{0,i}\ge\nu_0>0,$$
with the horizon-tuned step
$$\eta\;=\;\eta_T\;:=\;\Big(\frac{\Delta_0}{L\sqrt{d\sigma^2 T}}\Big)^{1/3},$$
satisfy
$$\min_{0\le t<T}\mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr]\;\le\;\mathcal{O}\!\left(\frac{(d\sigma^2 L\Delta_0)^{1/3}}{T^{2/3}}\right),$$
where the constant absorbs only $\nu_0$, $L$, $\sigma$, $d$, and $\log$-factors of the same.

---

## 0. Knowledge Reuse Pre-Survey

Per the explorer protocol (Steps A–C):

* **Step A (strategy_index.md)**. The signatures `adagrad-norm-nonconvex-convergence` (scalar parent) and `amsgrad-nonconvex-convergence` (predictable-surrogate $\hat v_{t-1}$ trick) are direct cousins. The route plan instructs us to use the *AMSGrad-style predictable surrogate* — i.e., switch the noise denominator from $\sqrt{v_{t,i}}$ (which contains $g_{t,i}^2$, hence is *not* $\mathcal F_t$-measurable in the classical sense — see §1.2 below) to a fully predictable surrogate built from data only up to time $t-1$, exactly as `amsgrad-nonconvex-convergence` does with $\hat v_{t-1}$. This is the route's signature move.
* **Step B (meta_templates.md)**. The hypothesis MT1 (Cancellation Pair) fits: SLOT V is $f(x_t)$; SLOT GOOD is $\sum_t\|\nabla f(x_t)\|^2/\sqrt{v_{t,i}}$ (or its surrogate version, see below); SLOT BAD is the noise cross term $\sum_{t,i}\nabla f(x_t)_i\xi_{t,i}/\sqrt{v_{t,i}}$; SLOT IDENTITY/INEQ is the predictable-surrogate substitution $\sqrt{v_{t,i}}\rightsquigarrow\sqrt{w_{t,i}}$ with $w_{t,i}\in\mathcal F_t$ (the cancellation source). All four MT1 slots are filled. We do not invoke MT2 (exp supermartingale) because the rate $T^{-2/3}$ is in expectation, not high-probability.
* **Step C (structure_map.md)**. The relevant ANALOGY links are `adagrad-norm-nonconvex-convergence` $\to$ this problem (per-coordinate generalization, $d$ enters via final Cauchy–Schwarz) and `amsgrad-nonconvex-convergence` $\to$ this problem (predictable-surrogate denominator).
* **Step D (failure_triggers.md, scanned ahead)**:
    * `FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING` — *flagged*. This route uses an *implicit* rearrangement, not a Lyapunov potential. We will explicitly verify §1.3 that the predictable-surrogate substitution is **not** a cosmetic Lyapunov rewrite: the surrogate $w_{t,i}$ is used to *create* a martingale-difference structure (with strictly $\mathcal F_t$-measurable weights) that did not exist before. Net analytical leverage: the noise cross-term becomes mean-zero exactly, with a quantifiable correction.
    * `FT-LEGACY-ADAGRAD-OCO-NON-CONVEX` — does not apply: we do **not** use any online-to-batch reduction; the descent lemma is invoked directly on the non-convex $f$.
    * `FT-RATE-UB-LB-MISMATCH` — checked at the end of §6. The rate we obtain ($T^{-2/3}$ with $d^{1/3}$) matches the conjectured UB shape exactly.

---

## 1. Setup, notation, and measurability check

### 1.1 Notation

Let $\mathcal F_t:=\sigma(g_0,\dots,g_{t-1})$. Both $x_t$ and $v_{t-1,i}=v_{0,i}+\sum_{s=0}^{t-1}g_{s,i}^2$ for $s\le t-1$ are $\mathcal F_t$-measurable. Importantly, $v_{t,i}=v_{t-1,i}+g_{t,i}^2$ is **not** $\mathcal F_t$-measurable; only its predictable predecessor $v_{t-1,i}$ is.

Write $\nabla f(x_t)=:\nabla_t$ and $\xi_t:=g_t-\nabla_t$. By assumption $\mathbb{E}[\xi_t\mid\mathcal F_t]=0$ and $\mathbb{E}[\|\xi_t\|^2\mid\mathcal F_t]\le\sigma^2$.

**Per-coordinate update**:
$$x_{t+1,i}-x_{t,i}=-\frac{\eta g_{t,i}}{\sqrt{v_{t,i}}}=-\eta\frac{\nabla_{t,i}+\xi_{t,i}}{\sqrt{v_{t,i}}}.$$

Throughout, summations $\sum_i$ run over $i=1,\dots,d$ and $\sum_t$ over $t=0,\dots,T-1$.

### 1.2 The measurability obstacle the AMSGrad trick fixes

The cross term that arises from the descent lemma (§2 below) is
$$N:=\sum_t\sum_i\nabla_{t,i}\cdot\frac{\xi_{t,i}}{\sqrt{v_{t,i}}}.$$
Since $\sqrt{v_{t,i}}=\sqrt{v_{t-1,i}+g_{t,i}^2}=\sqrt{v_{t-1,i}+(\nabla_{t,i}+\xi_{t,i})^2}$ contains $\xi_{t,i}$ inside the square root, the weight $1/\sqrt{v_{t,i}}$ is **not** $\mathcal F_t$-measurable, so $N$ is **not** a martingale-difference sum, and one cannot conclude $\mathbb{E}[N]=0$.

This is the central obstacle. (In the scalar AdaGrad-Norm case [REF: proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md], the analogue $b_k=\sqrt{b_0^2+\sum_{i<k}\|g_i\|^2}$ uses the *predecessor* index $i<k$, so $b_k\in\mathcal F_k$ automatically — measurability is free. In the per-coordinate AdaGrad with $v_{t,i}=v_{t-1,i}+g_{t,i}^2$ as in this problem, the accumulator includes the *current* gradient, so the same trick is no longer free.)

### 1.3 The predictable surrogate (the route's central move)

Define
$$w_{t,i}:=v_{t-1,i}+\nabla_{t,i}^2\cdot\mathbf 1\{t\ge1\}+v_{0,i}\cdot\mathbf 1\{t=0\}.$$
For brevity we write $w_{t,i}=v_{t-1,i}+\nabla_{t,i}^2$ for $t\ge 1$ and $w_{0,i}=v_{0,i}$.

Since $v_{t-1,i}\in\mathcal F_t$ and $\nabla_{t,i}=\nabla f(x_t)_i$ is also $\mathcal F_t$-measurable (because $x_t\in\mathcal F_t$), we have $w_{t,i}\in\mathcal F_t$. So $1/\sqrt{w_{t,i}}$ is a fully predictable weight.

Note also $w_{t,i}\ge v_{t-1,i}\ge v_{0,i}\ge\nu_0>0$, so the weight is bounded.

**Why this is genuine new analytical leverage (anti-FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING).** The legacy failure trigger fires when one *renames* the same quantity; it does NOT fire here because we are doing something different — we are *replacing* the original weight $1/\sqrt{v_{t,i}}$ by a strictly different weight $1/\sqrt{w_{t,i}}$ and then *paying for the difference* via a controlled correction. The replacement is what makes the cross term mean-zero; without it, the term has unknown sign. This is identical in spirit to the AMSGrad trick [REF: proofs/research/optimization/adaptive-methods/amsgrad-nonconvex-convergence/proof.md] where $\sqrt{\hat v_t}\to\sqrt{\hat v_{t-1}}$ creates the predictable structure.

### 1.4 The subadditivity inequality used pervasively

For $a\ge 0$ and $b\ge 0$,
$$\sqrt{a+b}-\sqrt a\le\frac{b}{2\sqrt a}\quad\text{whenever}\quad a>0. \tag{Sub}$$
This follows from the Mean Value Theorem applied to $u\mapsto\sqrt u$ on $[a,a+b]$ (the maximum derivative is $1/(2\sqrt a)$).

A weaker but symmetric version (for use when $a$ may equal $0$) is $\sqrt{a+b}-\sqrt a\le\sqrt b$, which we will not need in the main argument because $w_{t,i}\ge\nu_0>0$.

[CALL:math-verifier] {verify $\sqrt{a+b}-\sqrt a\le b/(2\sqrt a)$ for all $a>0,b\ge 0$ by checking $\sqrt{a+b}\le\sqrt a+b/(2\sqrt a)$, equivalently $a+b\le a+b+b^2/(4a)$, which is true.}

---

## 2. Per-coordinate Descent Lemma (Lemma A)

**Lemma A.** For each $t$,
$$f(x_{t+1})\le f(x_t)-\eta\sum_i\frac{\nabla_{t,i}g_{t,i}}{\sqrt{v_{t,i}}}+\frac{L\eta^2}{2}\sum_i\frac{g_{t,i}^2}{v_{t,i}}.$$

**Proof.** $L$-smoothness applied with $y=x_{t+1}$ and $x=x_t$ gives [REF: proofs/library/optimization/convergence/gd-nonconvex-stationary-point/proof.md]
$$f(x_{t+1})\le f(x_t)+\langle\nabla_t,x_{t+1}-x_t\rangle+\frac{L}{2}\|x_{t+1}-x_t\|^2.$$
Substituting $x_{t+1,i}-x_{t,i}=-\eta g_{t,i}/\sqrt{v_{t,i}}$ and expanding the inner product and norm coordinate-wise:
$$f(x_{t+1})\le f(x_t)+\sum_i\nabla_{t,i}\Big(-\eta\frac{g_{t,i}}{\sqrt{v_{t,i}}}\Big)+\frac{L}{2}\sum_i\eta^2\frac{g_{t,i}^2}{v_{t,i}}.\quad\blacksquare$$

Decompose the linear term using $g_{t,i}=\nabla_{t,i}+\xi_{t,i}$:
$$f(x_{t+1})\le f(x_t)-\eta\sum_i\frac{\nabla_{t,i}^2}{\sqrt{v_{t,i}}}-\eta\sum_i\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{v_{t,i}}}+\frac{L\eta^2}{2}\sum_i\frac{g_{t,i}^2}{v_{t,i}}. \tag{D1}$$

Telescoping (D1) over $t=0,\dots,T-1$ and using $f(x_T)\ge\inf f=f(x_0)-\Delta_0$:
$$\eta\sum_t\sum_i\frac{\nabla_{t,i}^2}{\sqrt{v_{t,i}}}\;\le\;\Delta_0\;-\;\eta\underbrace{\sum_t\sum_i\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{v_{t,i}}}}_{N\;\text{(noise cross-term)}}\;+\;\frac{L\eta^2}{2}\underbrace{\sum_t\sum_i\frac{g_{t,i}^2}{v_{t,i}}}_{Q\;\text{(quadratic accumulator)}}. \tag{D2}$$

Take expectation. The two structural difficulties are (i) showing $\mathbb{E}[N]\le\text{(small)}$ (the AMSGrad trick takes care of this in §3); (ii) bounding $\mathbb{E}[Q]$ logarithmically via the per-coordinate index-shift identity (§4).

---

## 3. Lemma B (AMSGrad Predictable-Surrogate Substitution for the Noise Cross-Term)

**Lemma B.** Under the assumptions of §1.1, with the surrogate $w_{t,i}=v_{t-1,i}+\nabla_{t,i}^2$ (and $w_{0,i}=v_{0,i}$),
$$\mathbb{E}[N]\;\le\;\sum_t\sum_i\mathbb{E}\!\left[\frac{|\nabla_{t,i}\xi_{t,i}|\cdot g_{t,i}^2}{2\sqrt{v_{t-1,i}}\sqrt{v_{t,i}}\sqrt{w_{t,i}}}\right]\;=:\;R^{\text{(corr)}}.$$

**Proof.** Add and subtract the surrogate weight:
$$N=\sum_t\sum_i\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{w_{t,i}}}+\sum_t\sum_i\nabla_{t,i}\xi_{t,i}\!\left(\frac{1}{\sqrt{v_{t,i}}}-\frac{1}{\sqrt{w_{t,i}}}\right). \tag{B1}$$

**Main piece is mean-zero.** Since $\nabla_{t,i}\in\mathcal F_t$ (because $x_t\in\mathcal F_t$) and $w_{t,i}\in\mathcal F_t$ (by §1.3), the weight $\nabla_{t,i}/\sqrt{w_{t,i}}$ is $\mathcal F_t$-measurable. Therefore by the tower property and $\mathbb{E}[\xi_{t,i}\mid\mathcal F_t]=0$,
$$\mathbb{E}\!\left[\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{w_{t,i}}}\right]=\mathbb{E}\!\left[\frac{\nabla_{t,i}}{\sqrt{w_{t,i}}}\,\mathbb{E}[\xi_{t,i}\mid\mathcal F_t]\right]=0. \tag{B2}$$

(Integrability: $|\nabla_{t,i}|/\sqrt{w_{t,i}}\le|\nabla_{t,i}|/\sqrt{\nu_0}$, and $\mathbb{E}[|\xi_{t,i}|]\le\mathbb{E}[\|\xi_t\|]\le\sigma$; these are uniformly bounded in expectation step-by-step.)

**Correction piece.** We bound $|1/\sqrt{v_{t,i}}-1/\sqrt{w_{t,i}}|$ from above. Both $v_{t,i}=v_{t-1,i}+g_{t,i}^2$ and $w_{t,i}=v_{t-1,i}+\nabla_{t,i}^2$ are obtained from $v_{t-1,i}$ by adding a non-negative quantity. Using the algebraic identity
$$\frac{1}{\sqrt a}-\frac{1}{\sqrt b}=\frac{b-a}{\sqrt a\sqrt b(\sqrt a+\sqrt b)}\le\frac{|b-a|}{2\sqrt a\sqrt b\cdot\min(\sqrt a,\sqrt b)},$$
applied with $a=v_{t,i}$, $b=w_{t,i}$, we get
$$\left|\frac{1}{\sqrt{v_{t,i}}}-\frac{1}{\sqrt{w_{t,i}}}\right|\;\le\;\frac{|g_{t,i}^2-\nabla_{t,i}^2|}{2\sqrt{v_{t,i}}\sqrt{w_{t,i}}\cdot\min(\sqrt{v_{t,i}},\sqrt{w_{t,i}})}. \tag{B3}$$

Now $|g_{t,i}^2-\nabla_{t,i}^2|=|g_{t,i}-\nabla_{t,i}|\cdot|g_{t,i}+\nabla_{t,i}|=|\xi_{t,i}|\cdot|2\nabla_{t,i}+\xi_{t,i}|$.

To get a usable bound, we instead use the cleaner estimate (which avoids the $|2\nabla_{t,i}+\xi_{t,i}|$ blow-up) by going through $\sqrt{v_{t,i}}-\sqrt{w_{t,i}}$ directly:
$$|\sqrt{v_{t,i}}-\sqrt{w_{t,i}}|=\frac{|v_{t,i}-w_{t,i}|}{\sqrt{v_{t,i}}+\sqrt{w_{t,i}}}=\frac{|g_{t,i}^2-\nabla_{t,i}^2|}{\sqrt{v_{t,i}}+\sqrt{w_{t,i}}},$$
and then
$$\left|\frac{1}{\sqrt{v_{t,i}}}-\frac{1}{\sqrt{w_{t,i}}}\right|=\frac{|\sqrt{w_{t,i}}-\sqrt{v_{t,i}}|}{\sqrt{v_{t,i}}\sqrt{w_{t,i}}}=\frac{|g_{t,i}^2-\nabla_{t,i}^2|}{(\sqrt{v_{t,i}}+\sqrt{w_{t,i}})\sqrt{v_{t,i}}\sqrt{w_{t,i}}}.$$

So the correction is bounded above by
$$\frac{|g_{t,i}^2-\nabla_{t,i}^2|}{2\sqrt{w_{t,i}}\cdot v_{t,i}}\quad\text{or}\quad\frac{|g_{t,i}^2-\nabla_{t,i}^2|}{2\sqrt{v_{t,i}}\cdot w_{t,i}}\quad\text{(whichever lower bound on $\sqrt{v_{t,i}}+\sqrt{w_{t,i}}$ we use)}.$$

For brevity (we will fold all the messy constants into $R^{\text{(corr)}}$ at the end), bound the correction crudely:
$$|N-N_{\text{main}}|\le\sum_t\sum_i\frac{|\nabla_{t,i}\xi_{t,i}|\cdot|g_{t,i}^2-\nabla_{t,i}^2|}{2\sqrt{w_{t,i}}\cdot v_{t,i}}.$$

Using $|g_{t,i}^2-\nabla_{t,i}^2|\le g_{t,i}^2+\nabla_{t,i}^2\le 2v_{t,i}$ (since both $g_{t,i}^2$ and $\nabla_{t,i}^2$ are at most $v_{t,i}$ when $v_{t-1,i}\ge 0$ — strictly: $g_{t,i}^2=v_{t,i}-v_{t-1,i}\le v_{t,i}$ and $\nabla_{t,i}^2=w_{t,i}-v_{t-1,i}\le w_{t,i}\le v_{t,i}+|w_{t,i}-v_{t,i}|$; the cleanest unified bound is $|g_{t,i}^2-\nabla_{t,i}^2|\le \max(g_{t,i}^2,\nabla_{t,i}^2)\le v_{t,i}\vee w_{t,i}$).

Folding: $|N-N_{\text{main}}|\le\sum_t\sum_i|\nabla_{t,i}\xi_{t,i}|/\sqrt{w_{t,i}}$, which sadly is not better than $N$ itself. **This is the first manifestation of the route's pitfall #2 — see §3.1 for the rescue.**

### 3.1 Rescue: Bound the correction by a smaller-order quantity using Cauchy–Schwarz

Apply Cauchy–Schwarz on the correction sum with weight $1/(2\sqrt{w_{t,i}})$:
$$|N-N_{\text{main}}|\le\sum_t\sum_i|\nabla_{t,i}|\cdot|\xi_{t,i}|\cdot\frac{|g_{t,i}^2-\nabla_{t,i}^2|}{2\sqrt{w_{t,i}}\cdot v_{t,i}}.$$

The numerator $|g_{t,i}^2-\nabla_{t,i}^2|=|g_{t,i}-\nabla_{t,i}|\cdot|g_{t,i}+\nabla_{t,i}|=|\xi_{t,i}|\cdot|g_{t,i}+\nabla_{t,i}|\le|\xi_{t,i}|\cdot(|g_{t,i}|+|\nabla_{t,i}|)\le|\xi_{t,i}|\cdot 2\sqrt{v_{t,i}}$ (since both $|g_{t,i}|\le\sqrt{v_{t,i}}$ and $|\nabla_{t,i}|=|g_{t,i}-\xi_{t,i}|\le|g_{t,i}|+|\xi_{t,i}|$, but the latter doesn't telescope cleanly; we use the more honest bound below).

A cleaner rescue: invoke Young's inequality on the correction (carefully — the failure trigger guidance is to avoid Young's that *kills cancellation*; here Young's is used on the *correction*, where there is no cancellation to kill):
$$|\nabla_{t,i}\xi_{t,i}|\cdot\frac{1}{\sqrt{w_{t,i}}}\le\frac{1}{2}\Big(\frac{\nabla_{t,i}^2}{\sqrt{w_{t,i}}}+\frac{\xi_{t,i}^2}{\sqrt{w_{t,i}}}\Big),$$
and combined with $|g_{t,i}^2-\nabla_{t,i}^2|/v_{t,i}\le 2$, the correction is bounded by
$$|N-N_{\text{main}}|\le\sum_t\sum_i\Big(\frac{\nabla_{t,i}^2}{\sqrt{w_{t,i}}}+\frac{\xi_{t,i}^2}{\sqrt{w_{t,i}}}\Big). \tag{B4}$$

The first sum is $\sum_t\sum_i\nabla_{t,i}^2/\sqrt{w_{t,i}}$, which is *exactly* the descent term $\sum_t\sum_i\nabla_{t,i}^2/\sqrt{v_{t,i}}$ rewritten with $w$ in place of $v$. The second is a noise variance accumulator.

**This is the first sign of trouble**: the correction has the *same order* as the descent term $\sum_t\sum_i\nabla_{t,i}^2/\sqrt{v_{t,i}}$. If the prefactor on the correction is $\ge\eta$, then absorbing the correction into the LHS of (D2) makes the LHS coefficient $\eta-(\text{something of order }\eta)$, which may become non-positive.

**Detection signal — FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING is now firing.** The correction obtained from the AMSGrad-style substitution has the same magnitude as the term we are trying to bound. The "predictable surrogate substitution" is *not* providing genuine analytical leverage in this form, just like the legacy AdaGrad-Norm Lyapunov route. **Pivot recommended.**

---

## 4. Pivot: Use a *cleaner* AMSGrad-style surrogate that decouples from $\nabla_{t,i}$

Instead of $w_{t,i}=v_{t-1,i}+\nabla_{t,i}^2$, use the simpler predictable surrogate
$$\tilde w_{t,i}:=v_{t-1,i}+G_{\max,i}^2\qquad\text{or simply}\qquad \tilde w_{t,i}:=v_{t-1,i},$$
where the second choice (just dropping the current-step contribution from the denominator) is the classical AMSGrad-style move. We adopt $\tilde w_{t,i}=v_{t-1,i}$ throughout the rest of the proof; this is fully $\mathcal F_t$-measurable and has the simple subadditivity bound (Sub):
$$\sqrt{v_{t,i}}-\sqrt{v_{t-1,i}}\;\le\;\frac{g_{t,i}^2}{2\sqrt{v_{t-1,i}}}, \tag{Sub'}$$
valid for $v_{t-1,i}\ge\nu_0>0$.

Equivalently
$$\frac{1}{\sqrt{v_{t-1,i}}}-\frac{1}{\sqrt{v_{t,i}}}=\frac{\sqrt{v_{t,i}}-\sqrt{v_{t-1,i}}}{\sqrt{v_{t-1,i}}\sqrt{v_{t,i}}}\le\frac{g_{t,i}^2}{2v_{t-1,i}\sqrt{v_{t,i}}}. \tag{Sub''}$$

### 4.1 Re-express the descent (D1) via the predictable denominator

Add and subtract $\nabla_{t,i}^2/\sqrt{v_{t-1,i}}$ to get (using also $\xi_{t,i}\nabla_{t,i}/\sqrt{v_{t-1,i}}$ as the surrogate cross-term):
$$f(x_{t+1})-f(x_t)\le-\eta\sum_i\frac{\nabla_{t,i}^2}{\sqrt{v_{t-1,i}}}+\eta\sum_i\nabla_{t,i}^2\Big(\frac{1}{\sqrt{v_{t-1,i}}}-\frac{1}{\sqrt{v_{t,i}}}\Big)$$
$$\quad-\eta\sum_i\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{v_{t-1,i}}}+\eta\sum_i\nabla_{t,i}\xi_{t,i}\Big(\frac{1}{\sqrt{v_{t-1,i}}}-\frac{1}{\sqrt{v_{t,i}}}\Big)+\frac{L\eta^2}{2}\sum_i\frac{g_{t,i}^2}{v_{t,i}}. \tag{D3}$$

(Algebra check: $\nabla_{t,i}g_{t,i}=\nabla_{t,i}^2+\nabla_{t,i}\xi_{t,i}$, and we replaced $1/\sqrt{v_{t,i}}\to1/\sqrt{v_{t-1,i}}-(1/\sqrt{v_{t-1,i}}-1/\sqrt{v_{t,i}})$.)

[CALL:math-verifier] {verify $(\nabla_{t,i}^2+\nabla_{t,i}\xi_{t,i})/\sqrt{v_{t,i}}=(\nabla_{t,i}^2+\nabla_{t,i}\xi_{t,i})/\sqrt{v_{t-1,i}}-(\nabla_{t,i}^2+\nabla_{t,i}\xi_{t,i})\cdot(1/\sqrt{v_{t-1,i}}-1/\sqrt{v_{t,i}})$ as a pure algebra identity.}

Define for clarity:
* **Main descent**: $D_t:=\sum_i\nabla_{t,i}^2/\sqrt{v_{t-1,i}}$.
* **Surrogate noise cross-term**: $\tilde N_t:=\sum_i\nabla_{t,i}\xi_{t,i}/\sqrt{v_{t-1,i}}$.
* **Surrogate-correction (non-noise)**: $S^{(1)}_t:=\sum_i\nabla_{t,i}^2\cdot(1/\sqrt{v_{t-1,i}}-1/\sqrt{v_{t,i}})$.
* **Surrogate-correction (noise)**: $S^{(2)}_t:=\sum_i\nabla_{t,i}\xi_{t,i}\cdot(1/\sqrt{v_{t-1,i}}-1/\sqrt{v_{t,i}})$.
* **Quadratic accumulator**: $Q_t:=\sum_i g_{t,i}^2/v_{t,i}$.

Then (D3) reads
$$f(x_{t+1})-f(x_t)\le-\eta D_t+\eta S^{(1)}_t-\eta\tilde N_t+\eta S^{(2)}_t+\frac{L\eta^2}{2}Q_t. \tag{D3'}$$

### 4.2 Mean of the surrogate cross-term

Since $\nabla_{t,i}/\sqrt{v_{t-1,i}}\in\mathcal F_t$ and $\mathbb{E}[\xi_{t,i}\mid\mathcal F_t]=0$:
$$\mathbb{E}[\tilde N_t\mid\mathcal F_t]=\sum_i\frac{\nabla_{t,i}}{\sqrt{v_{t-1,i}}}\mathbb{E}[\xi_{t,i}\mid\mathcal F_t]=0.\qquad\text{Hence }\mathbb{E}[\tilde N_t]=0. \tag{NZero}$$

This is the step that the AMSGrad surrogate buys us: the dominant noise cross-term is now mean-zero, with a *predictable* weight that is bounded ($1/\sqrt{v_{t-1,i}}\le1/\sqrt{\nu_0}$).

### 4.3 Bounding $S^{(1)}_t$ via (Sub'')

By (Sub''),
$$S^{(1)}_t\le\sum_i\nabla_{t,i}^2\cdot\frac{g_{t,i}^2}{2v_{t-1,i}\sqrt{v_{t,i}}}\le\sum_i\frac{\nabla_{t,i}^2g_{t,i}^2}{2\nu_0\sqrt{v_{t,i}}}\le\frac{1}{2\nu_0}\sum_i\nabla_{t,i}^2\cdot\frac{g_{t,i}^2}{\sqrt{v_{t,i}}}. \tag{S1}$$

The quantity $g_{t,i}^2/\sqrt{v_{t,i}}\le\sqrt{v_{t,i}}-\sqrt{v_{t-1,i}}\cdot 2$ (by Sub'/Sub''-style arithmetic): more precisely,
$$\frac{g_{t,i}^2}{\sqrt{v_{t,i}}}=\frac{v_{t,i}-v_{t-1,i}}{\sqrt{v_{t,i}}}=\sqrt{v_{t,i}}-\frac{v_{t-1,i}}{\sqrt{v_{t,i}}}\le\sqrt{v_{t,i}}.$$
Thus $g_{t,i}^2/\sqrt{v_{t,i}}\le\sqrt{v_{t,i}}$, and taking expectation,
$$\mathbb{E}\!\left[\sum_t S^{(1)}_t\right]\le\frac{1}{2\nu_0}\sum_t\sum_i\mathbb{E}\!\left[\nabla_{t,i}^2\sqrt{v_{t,i}}\right]. \tag{S1bound}$$

This is **still a problem**: the RHS is not obviously small. It contains $\nabla_{t,i}^2\cdot\sqrt{v_{t,i}}$, where $\sqrt{v_{t,i}}$ can be as large as $O(\sqrt{T\sigma^2})$. Summed over $t$ and $i$, this would give $O(d T\sigma\cdot\max_t\|\nabla_t\|^2)$, which is way too large.

**Detection signal — FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING is firing again.** The AMSGrad-style surrogate substitution produces a correction $S^{(1)}_t$ that is *larger* than the descent term, breaking the proof.

### 4.4 Second pivot: only do the substitution on the *noise* cross-term, not on the descent term

The key insight: we do NOT need to substitute $\sqrt{v_{t,i}}\to\sqrt{v_{t-1,i}}$ in the *descent* part (the term $\nabla_{t,i}^2/\sqrt{v_{t,i}}$). We only need it in the *noise* cross-term, where measurability is the obstacle.

So let us re-derive (D3) doing the substitution ONLY on the noise term:
$$f(x_{t+1})-f(x_t)\le-\eta\sum_i\frac{\nabla_{t,i}^2}{\sqrt{v_{t,i}}}-\eta\sum_i\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{v_{t,i}}}+\frac{L\eta^2}{2}\sum_i\frac{g_{t,i}^2}{v_{t,i}}. \tag{D1 unchanged}$$

Then add and subtract the surrogate weight ONLY in the cross-term:
$$\sum_i\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{v_{t,i}}}=\sum_i\frac{\nabla_{t,i}\xi_{t,i}}{\sqrt{v_{t-1,i}}}-\sum_i\nabla_{t,i}\xi_{t,i}\cdot\Big(\frac{1}{\sqrt{v_{t-1,i}}}-\frac{1}{\sqrt{v_{t,i}}}\Big). \tag{Split}$$

The first piece is $\tilde N_t$ which has $\mathbb{E}[\tilde N_t]=0$ by (NZero). The second piece is $S^{(2)}_t$, the *noise correction*.

By Cauchy–Schwarz and (Sub''), and bounding $|\nabla_{t,i}\xi_{t,i}|\le\frac{1}{2}(\nabla_{t,i}^2/\sqrt{v_{t,i}}+\xi_{t,i}^2\sqrt{v_{t,i}})$ (Young's with weight $\sqrt{v_{t,i}}$, applied carefully so the descent absorbs the $\nabla^2$):

$$|S^{(2)}_t|\le\sum_i|\nabla_{t,i}\xi_{t,i}|\cdot\frac{g_{t,i}^2}{2v_{t-1,i}\sqrt{v_{t,i}}}\le\frac{1}{2\nu_0}\sum_i|\nabla_{t,i}\xi_{t,i}|\cdot\frac{g_{t,i}^2}{\sqrt{v_{t,i}}}\le\frac{1}{2\nu_0}\sum_i|\nabla_{t,i}\xi_{t,i}|\cdot\sqrt{v_{t,i}}.$$

Take expectation; we still face the obstruction $\mathbb{E}[|\nabla_{t,i}\xi_{t,i}|\cdot\sqrt{v_{t,i}}]\le|\nabla_{t,i}|\cdot\sigma\cdot\sqrt{v_{t,i}}$, which when summed over $t$ gives $\sigma\cdot\max_t|\nabla|\cdot\sqrt{T\sigma^2}=\sigma^2\sqrt{T}\cdot G$. This is too large to be a "correction".

**Final detection: FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING is decisively firing.** The AMSGrad-predictable-surrogate substitution, in any form considered above, produces correction terms that are at least as large as the descent term itself. The route does **not** close the proof.

---

## 5. Route Failure Report

### 5.1 Summary

Route 2 (Predictable-Surrogate Denominator via AMSGrad Trick) **fails to close** the upper bound for coordinate-wise AdaGrad in the form proposed.

* **Failed at**: the cross-term cancellation step (§3, §4 above).
* **Obstacle**: the AMSGrad-style substitution $\sqrt{v_{t,i}}\rightsquigarrow\sqrt{v_{t-1,i}}$ produces a correction term $S^{(2)}_t$ whose magnitude is governed by $\sqrt{v_{t,i}}-\sqrt{v_{t-1,i}}\le g_{t,i}^2/(2\sqrt{v_{t-1,i}})$. While this looks small, the resulting bound on the noise correction sum involves $\sum_t|\nabla_{t,i}\xi_{t,i}|\sqrt{v_{t,i}}$, which scales as $\Omega(\sqrt T\cdot G\sigma)$ per coordinate — strictly larger than the per-coordinate descent contribution $O(\sqrt T)$ on the LHS that we are trying to extract.
* **Why this is real (not a calculational error)**: in scalar AdaGrad-Norm [REF: proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/proof.md], no AMSGrad substitution is needed because $b_k:=\sqrt{b_0^2+\sum_{i<k}\|g_i\|^2}\in\mathcal F_k$ already, so the cross-term is mean-zero for free. The per-coordinate AdaGrad uses $v_{t,i}=v_{t-1,i}+g_{t,i}^2$, which contains the *current* gradient, breaking measurability. The AMSGrad trick that fixes this in the original AMSGrad context [REF: proofs/research/optimization/adaptive-methods/amsgrad-nonconvex-convergence/proof.md] succeeds only because AMSGrad's update uses $\hat v_t:=\max(\hat v_{t-1},v_t)$, which has the cushion $1-\beta_2$ to absorb the correction. In coordinate-wise AdaGrad without the AMSGrad max+EMA cushion, the correction has no small-multiplier in front of it, and it dominates.

### 5.2 Failure trigger fired

* **`FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING`** — fired (decisively). The predictable-surrogate substitution in this setting is a cosmetic rearrangement that does not produce genuine analytical leverage. The recommended pivot from the trigger ("use direct decoupling identity + log accumulator from Route 1") is consistent with what the Route 1 explorer is doing.
* **`FT-RATE-UB-LB-MISMATCH`** — checked: not directly applicable to a failed route (the route did not produce any final rate to compare).

### 5.3 What partial result Route 2 does establish

The proof DID rigorously establish the following partial results, which are reusable by other explorers:

1. **(Lemma A) Per-coordinate descent inequality** (§2): for coordinate-wise AdaGrad,
$$f(x_{t+1})-f(x_t)\le-\eta\sum_i\frac{\nabla_{t,i}g_{t,i}}{\sqrt{v_{t,i}}}+\frac{L\eta^2}{2}\sum_i\frac{g_{t,i}^2}{v_{t,i}}.$$
This is a clean per-coordinate generalization of the scalar AdaGrad-Norm descent lemma.

2. **(Measurability gap)** $\sqrt{v_{t,i}}\notin\mathcal F_t$ for coordinate-wise AdaGrad (because $v_{t,i}=v_{t-1,i}+g_{t,i}^2$ contains the current gradient), unlike scalar AdaGrad-Norm. This is the central obstacle distinguishing the per-coordinate setting from the scalar setting and motivates Route 1's per-coordinate self-bounding-sum strategy (which sidesteps measurability by working with the deterministic identity $\sum_t g_{t,i}^2/\sqrt{v_{t,i}}\le 2\sqrt{v_{T,i}}$ rather than trying to make the noise cross-term mean-zero).

3. **(Rescue path)** The AMSGrad substitution does NOT close on its own, but a *one-sided* version — substitute the surrogate $\sqrt{v_{t-1,i}}$ in the cross-term (the noise correction $S^{(2)}_t$ is then bounded by $O(g_{t,i}^2/\sqrt{v_{t-1,i}})\cdot|\nabla_{t,i}\xi_{t,i}|$, and we use Young's to absorb it into a $G^2\sigma^2/\nu_0$ term plus a contribution that telescopes via the per-coordinate self-bounding sum) MAY close if combined with the per-coordinate self-bounding sum identity from Route 1. This suggests a **hybrid Route 1 + Route 2** that the Judge may want to consider after seeing both reports.

### 5.4 Why Part B is not addressed

This route is, by problem-design, a UB attack only. Part B (lower bound) should be handled by Routes 3 (Le Cam $d$-point needle), 4 (adversarial polytope), or 6 (bandit analogy). Route 2 does NOT engage with Part B.

---

## 6. Final Cross-check: rate sanity (for the hybrid that would close)

If Route 1 closes successfully and the hybrid Route 1+2 absorption works, the resulting rate would be $T^{-2/3}\cdot d^{1/3}\cdot(L\Delta_0\sigma^2)^{1/3}$, matching the conjectured form in `problem.md`. This matches the LB from Route 3 (which gives $\sqrt d/\varepsilon^{3/2}$, equivalent to the same UB sample complexity up to constants — verified in `routes.md` §Route 3 pitfalls).

`FT-RATE-UB-LB-MISMATCH` does **not** fire (the conjectured rates match in expectation).

---

## Hooks Report

- **Strategy signatures consulted**: `adagrad-norm-nonconvex-convergence` (scalar parent — informed §1.2 measurability check and §2 descent lemma; useful=YES, gave the deterministic envelope and the measurability framing). `amsgrad-nonconvex-convergence` (predictable-surrogate analog — informed §1.3 surrogate construction and §3 cross-term analysis; useful=PARTIALLY, the substitution structure transferred but the AMSGrad cushion (1-β₂) is missing in vanilla coordinate-wise AdaGrad, which is why the route fails).
- **Meta-template attempted**: MT1 (Cancellation Pair). Slots filled: SLOT V_t = $f(x_t)$; SLOT TELESCOPE = (D1)/(D2); SLOT GOOD = $\sum_t\sum_i\nabla_{t,i}^2/\sqrt{v_{t,i}}$ (or its surrogate version); SLOT BAD = noise cross-term $N$. Blocker slot: SLOT IDENTITY/INEQ. Reason: the predictable-surrogate substitution provides a candidate cancellation source ($\tilde N_t$ has zero mean), but the resulting correction term $S^{(2)}_t$ has the same magnitude as the descent term, so the cancellation is cosmetic — there is no net analytical leverage in this route alone. The correct cancellation source for this problem is the per-coordinate self-bounding-sum identity (Route 1's job), not the predictable surrogate.
- **Structure map links used**: `adagrad-norm-nonconvex-convergence` → coordinate-wise AdaGrad (per-coordinate generalization with $d$ entering via final Cauchy–Schwarz, planned but not reached in this route). `amsgrad-nonconvex-convergence` → coordinate-wise AdaGrad (predictable-surrogate transfer attempted, *fails* because of missing $1-\beta_2$ cushion).
- **Failure triggers checked**: 3 (FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING, FT-LEGACY-ADAGRAD-OCO-NON-CONVEX, FT-RATE-UB-LB-MISMATCH). Matched: [FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING] (the predictable-surrogate substitution fails for the same reason the legacy Lyapunov recast failed: it is cosmetic re-bookkeeping, with the correction magnitude matching the descent magnitude). Pivots taken: attempted to pivot from "substitute on both descent and noise" (§4.1–§4.3) to "substitute on noise only" (§4.4) — second pivot also fails for the same root cause; final pivot is to declare route failure and recommend hybrid with Route 1 in §5.3.
