# Route D — Individual-Sample MI Refinement (Bu–Zou–Veeravalli 2020) and the Xu–Raginsky Theorem as Corollary

**Strategy.** We do *not* prove the Xu–Raginsky bound directly. Instead we prove the genuinely stronger **per-sample mutual-information (MI) bound** of Bu–Zou–Veeravalli (BZV, 2020):
$$
\big|\mathbb{E}[R_{\mathcal D}(W) - R_S(W)]\big|
\;\le\; \frac{1}{n}\sum_{i=1}^n \sqrt{2\sigma^2\, I(W;Z_i)}.
\tag{BZV}
$$
The Xu–Raginsky bound
$$
\big|\mathbb{E}[R_{\mathcal D}(W) - R_S(W)]\big|
\;\le\; \sqrt{\frac{2\sigma^2\, I(W;S)}{n}}
\tag{XR}
$$
will then follow by (i) Jensen's inequality applied to the concave function $\sqrt{\cdot}$ and (ii) the chain-rule inequality $\sum_i I(W;Z_i)\le I(W;S)$, which uses the iid structure of $S$.

The per-sample form is *strictly tighter* whenever the algorithm leaks different amounts of information about different samples — which is the typical case for any realistic learner (e.g., SGD: later samples influence $W$ more than earlier ones through path dependence, or any algorithm with subsampling). A numerical example at the end makes this concrete.

---

## 1. Preliminaries

### 1.1 Setup

Let $(\mathcal Z,\mathcal F_Z)$ and $(\mathcal W,\mathcal F_W)$ be measurable spaces. A data distribution $\mathcal D$ on $\mathcal Z$ and a training sample
$$
S=(Z_1,\dots,Z_n)\stackrel{\text{iid}}\sim \mathcal D^{\otimes n}
$$
are fixed. A *learning algorithm* is a Markov kernel $P_{W\mid S}:\mathcal Z^n\to\mathcal P(\mathcal W)$, yielding a joint law $\mathbb P_{W,S}=\mathbb P_{W\mid S}\otimes \mathcal D^{\otimes n}$ on $\mathcal W\times\mathcal Z^n$. Write $\mathbb P_W$ for the $\mathcal W$-marginal. For each $i\in\{1,\dots,n\}$ let $\mathbb P_{W,Z_i}$ be the $(W,Z_i)$-marginal of $\mathbb P_{W,S}$; note $\mathbb P_{Z_i}=\mathcal D$ and the marginal of $W$ inside $\mathbb P_{W,Z_i}$ is $\mathbb P_W$. The *per-sample mutual information* is
$$
I(W;Z_i)\;:=\;D_{\mathrm{KL}}\!\big(\mathbb P_{W,Z_i}\,\big\|\,\mathbb P_W\otimes\mathcal D\big).
$$

### 1.2 Loss and generalization gap

$\ell:\mathcal W\times\mathcal Z\to\mathbb R$ is measurable. Define
$$
R_{\mathcal D}(w)=\mathbb E_{Z\sim\mathcal D}[\ell(w,Z)],\qquad
R_S(w)=\frac1n\sum_{i=1}^n\ell(w,Z_i).
$$
The *generalization gap* is the random quantity $R_{\mathcal D}(W)-R_S(W)$; we bound its *expectation* under $\mathbb P_{W,S}$.

### 1.3 Sub-Gaussian assumption (A1)

Under the product measure $\mathbb P_W\otimes\mathcal D$, the random variable $\ell(W,Z)$ is *$\sigma$-sub-Gaussian*:
$$
\log\mathbb E_{\mathbb P_W\otimes\mathcal D}\!\Big[e^{\lambda(\ell(W,Z)-\mathbb E_{\mathbb P_W\otimes\mathcal D}[\ell(W,Z)])}\Big]\;\le\;\tfrac{\lambda^2\sigma^2}{2},\quad\forall\lambda\in\mathbb R. \tag{A1}
$$

### 1.4 Per-sample decomposition of the gap

Because the $Z_i$ are iid with marginal $\mathcal D$, for each $i$ the marginal $\mathbb P_{Z_i}=\mathcal D$ and
$$
\mathbb E[\ell(W,Z_i)] = \mathbb E_{\mathbb P_{W,Z_i}}[\ell(W,Z_i)].
$$
Introduce, for each $i$, an auxiliary "ghost" variable $Z_i'\sim\mathcal D$ drawn *independently* of $(W,S)$. Then $(W,Z_i')\sim \mathbb P_W\otimes\mathcal D$ (product law) and
$$
\mathbb E_{\mathbb P_W\otimes\mathcal D}[\ell(W,Z_i')] \;=\; \mathbb E_{Z\sim\mathcal D}\,\mathbb E_{W\sim\mathbb P_W}[\ell(W,Z)]\;=\;\mathbb E[R_{\mathcal D}(W)],
$$
where the last equality holds because $W$ and $Z$ are independent under $\mathbb P_W\otimes\mathcal D$, so $\mathbb E[\ell(W,Z)]=\mathbb E_W[R_{\mathcal D}(W)]$. Therefore
$$
\mathbb E[R_{\mathcal D}(W)-R_S(W)]
=\frac1n\sum_{i=1}^n\Big(\mathbb E_{\mathbb P_W\otimes\mathcal D}[\ell(W,Z_i')]-\mathbb E_{\mathbb P_{W,Z_i}}[\ell(W,Z_i)]\Big). \tag{$\star$}
$$
Each summand is the difference of the same functional $\ell$ integrated against two measures — $\mathbb P_W\otimes\mathcal D$ (product) and $\mathbb P_{W,Z_i}$ (joint) — whose KL divergence is precisely $I(W;Z_i)$. This is the hook for the transport lemma.

---

## 2. Lemma 1 (Donsker–Varadhan variational formula)

**Lemma 1 (DV).** Let $P,Q$ be probability measures on a common measurable space with $P\ll Q$. Then
$$
D_{\mathrm{KL}}(P\|Q)\;=\;\sup_{f\in\mathcal L} \Big\{\mathbb E_P[f]-\log\mathbb E_Q[e^f]\Big\},
$$
where $\mathcal L$ is the set of measurable $f$ with $\mathbb E_Q[e^f]<\infty$ and $\mathbb E_P[|f|]<\infty$. Equivalently, for every such $f$,
$$
\mathbb E_P[f]\;\le\;\log\mathbb E_Q[e^f]+D_{\mathrm{KL}}(P\|Q). \tag{DV}
$$

**Proof.** Let $g=dP/dQ$ (Radon–Nikodym derivative, which exists since $P\ll Q$). For $f\in\mathcal L$, define a new probability measure $Q_f$ by $dQ_f/dQ=e^f/\mathbb E_Q[e^f]$ (well-defined since $\mathbb E_Q[e^f]\in(0,\infty)$). Using $P\ll Q\sim Q_f$ we compute
$$
\begin{aligned}
D_{\mathrm{KL}}(P\|Q_f)
&=\mathbb E_P\!\left[\log\frac{dP}{dQ_f}\right]
 =\mathbb E_P\!\left[\log\frac{dP}{dQ}\cdot\frac{dQ}{dQ_f}\right]\\
&=\mathbb E_P[\log g]-\mathbb E_P[f]+\log\mathbb E_Q[e^f]\\
&=D_{\mathrm{KL}}(P\|Q)-\Big(\mathbb E_P[f]-\log\mathbb E_Q[e^f]\Big).
\end{aligned}
$$
Since $D_{\mathrm{KL}}(P\|Q_f)\ge 0$ (Gibbs' inequality), this rearranges to (DV):
$$
\mathbb E_P[f]-\log\mathbb E_Q[e^f]\;\le\;D_{\mathrm{KL}}(P\|Q).
$$

*Remark on tightness.* Only the direction (DV) — the upper bound — is used in the proof of the main theorem. The supremum is attained (or approached) via $f_\varepsilon=\log(g\vee\varepsilon)$ as $\varepsilon\downarrow 0$ (see Dupuis–Ellis, *A Weak Convergence Approach to Large Deviations*, Prop. 1.4.2), but this direction is not needed here. $\blacksquare$

---

## 3. Lemma 2 (Sub-Gaussian transport)

**Lemma 2.** Let $P\ll Q$ on $(\Omega,\mathcal F)$ and let $f:\Omega\to\mathbb R$ be measurable. Assume $f$ is $\sigma$-sub-Gaussian under $Q$:
$$
\log\mathbb E_Q\big[e^{\lambda(f-\mathbb E_Q f)}\big]\;\le\;\tfrac{\lambda^2\sigma^2}{2},\qquad\forall\lambda\in\mathbb R. \tag{SG}
$$
Then (assuming $\mathbb E_P[|f|]<\infty$)
$$
\big|\mathbb E_P[f]-\mathbb E_Q[f]\big|\;\le\;\sqrt{2\sigma^2\,D_{\mathrm{KL}}(P\|Q)}. \tag{ST}
$$

**Proof.** For any $\lambda\in\mathbb R$, apply (DV) to the test function $\lambda(f-\mathbb E_Q f)$:
$$
\mathbb E_P\big[\lambda(f-\mathbb E_Q f)\big]
\;\le\;\log\mathbb E_Q\big[e^{\lambda(f-\mathbb E_Q f)}\big]+D_{\mathrm{KL}}(P\|Q)
\;\stackrel{(\text{SG})}{\le}\;\tfrac{\lambda^2\sigma^2}{2}+D_{\mathrm{KL}}(P\|Q).
$$
The left side equals $\lambda\big(\mathbb E_P[f]-\mathbb E_Q[f]\big)$. Let $\Delta:=\mathbb E_P[f]-\mathbb E_Q[f]$. Then for every $\lambda\in\mathbb R$,
$$
\lambda\Delta-\tfrac{\lambda^2\sigma^2}{2}\;\le\;D_{\mathrm{KL}}(P\|Q).
$$
The left side is a concave quadratic in $\lambda$ with maximum at $\lambda^*=\Delta/\sigma^2$, value $\Delta^2/(2\sigma^2)$. Substituting,
$$
\frac{\Delta^2}{2\sigma^2}\;\le\;D_{\mathrm{KL}}(P\|Q)\quad\Longrightarrow\quad |\Delta|\le\sqrt{2\sigma^2 D_{\mathrm{KL}}(P\|Q)},
$$
which is (ST). $\blacksquare$

*Remark.* The two-sided bound is obtained by optimizing $\lambda$ over all of $\mathbb R$ above (the optimizer $\lambda^* = \Delta/\sigma^2$ takes any sign depending on the sign of $\Delta$), which we did.

---

## 4. Theorem 1 — BZV per-sample bound (the strengthened result)

**Theorem 1 (Bu–Zou–Veeravalli 2020).** Under the setup of §1 and assumption (A1),
$$
\boxed{\;\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|\;\le\;\frac1n\sum_{i=1}^n\sqrt{2\sigma^2\,I(W;Z_i)}.\;}\tag{BZV}
$$

**Proof.** Fix $i\in\{1,\dots,n\}$ and set
$$
P=\mathbb P_{W,Z_i}\quad(\text{joint}),\qquad Q=\mathbb P_W\otimes\mathcal D\quad(\text{product}),\qquad f(w,z)=\ell(w,z).
$$
We verify the hypotheses of Lemma 2.

*(a) $P\ll Q$.* If $I(W;Z_i) = D_{\mathrm{KL}}(\mathbb P_{W,Z_i}\|\mathbb P_W\otimes\mathcal D) = +\infty$, then (BZV) is vacuously true for this term. If $I(W;Z_i)<\infty$, then by definition of KL divergence, $\mathbb P_{W,Z_i}\ll \mathbb P_W\otimes\mathcal D$.

*(b) $f$ is $\sigma$-sub-Gaussian under $Q$.* This is exactly (A1): under $Q=\mathbb P_W\otimes\mathcal D$, the random variable $\ell(W,Z)$ satisfies (SG) with parameter $\sigma$. Note that this is precisely what (A1) assumes — it is the product-measure sub-Gaussianity condition, not any joint-measure condition.

*(c) $D_{\mathrm{KL}}(P\|Q)=I(W;Z_i)$.* By definition of marginal MI.

By Lemma 2,
$$
\big|\mathbb E_{\mathbb P_{W,Z_i}}[\ell(W,Z_i)]-\mathbb E_{\mathbb P_W\otimes\mathcal D}[\ell(W,Z_i')]\big|
\;\le\;\sqrt{2\sigma^2\,I(W;Z_i)}. \tag{$\dagger_i$}
$$
Now apply the decomposition $(\star)$ from §1.4 and the triangle inequality:
$$
\begin{aligned}
\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|
&=\left|\frac1n\sum_{i=1}^n\Big(\mathbb E_{\mathbb P_W\otimes\mathcal D}[\ell(W,Z_i')]-\mathbb E_{\mathbb P_{W,Z_i}}[\ell(W,Z_i)]\Big)\right|\\
&\le\frac1n\sum_{i=1}^n\Big|\mathbb E_{\mathbb P_{W,Z_i}}[\ell(W,Z_i)]-\mathbb E_{\mathbb P_W\otimes\mathcal D}[\ell(W,Z_i')]\Big|\\
&\stackrel{(\dagger_i)}\le\frac1n\sum_{i=1}^n\sqrt{2\sigma^2\,I(W;Z_i)}.
\end{aligned}
$$
This is (BZV). $\blacksquare$

**Why this is a stronger statement, not just a stepping stone.** Theorem 1 produces a *term-by-term* accounting: each sample $Z_i$ contributes in proportion to the mutual information $I(W;Z_i)$ it individually shares with the output. When samples are of unequal "influence" (a generic situation — think of SGD's path-dependence, or algorithms that only look at a random subset of $S$), Theorem 1 can be arbitrarily tighter than (XR); see the Remark in §7.

---

## 5. Lemma 3 — Chain rule under iid: $\sum_i I(W;Z_i)\le I(W;S)$

**Lemma 3.** If $Z_1,\dots,Z_n$ are mutually independent (in particular if they are iid), then for any joint distribution with output $W$,
$$
\sum_{i=1}^n I(W;Z_i)\;\le\;I(W;S), \qquad S=(Z_1,\dots,Z_n). \tag{L3}
$$

**Proof.** We use the chain rule and the fact that *independence of inputs* forces the marginal entropy of the sample to decouple, but *conditioning on $W$ may introduce dependence*, which only decreases entropy further.

*Step 1: Chain rule for mutual information.*
$$
I(W;S)\;=\;\sum_{i=1}^n I(W;Z_i\mid Z_1,\dots,Z_{i-1})
\;=:\;\sum_{i=1}^n I(W;Z_i\mid Z_{1:i-1}). \tag{CR}
$$
This is standard and follows from the chain rule for KL divergence applied to $\mathbb P_{W,Z_{1:i}}$; a direct proof in KL form:
$$
\begin{aligned}
I(W;S) &= D_{\mathrm{KL}}(\mathbb P_{W,S}\|\mathbb P_W\otimes\mathbb P_S)\\
&= \mathbb E\!\left[\log\frac{d\mathbb P_{W,S}}{d(\mathbb P_W\otimes\mathbb P_S)}(W,S)\right]\\
&= \sum_{i=1}^n\mathbb E\!\left[\log\frac{d\mathbb P_{W,Z_i\mid Z_{1:i-1}}}{d(\mathbb P_{W\mid Z_{1:i-1}}\otimes\mathbb P_{Z_i\mid Z_{1:i-1}})}(W,Z_i\mid Z_{1:i-1})\right]\\
&= \sum_{i=1}^n I(W;Z_i\mid Z_{1:i-1}),
\end{aligned}
$$
where the telescoping in the third line uses $\mathbb P_S=\prod_i \mathbb P_{Z_i\mid Z_{1:i-1}}$ (always true) and $\mathbb P_{W,S}=\prod_i\mathbb P_{W,Z_i\mid Z_{1:i-1}}/\mathbb P_{W\mid Z_{1:i-1}}^{\,n-1}$ — more concretely, one verifies term-by-term that the log-Radon–Nikodym derivative splits into the conditional MI densities.

*Step 2: Independence of $Z_i$ from $Z_{1:i-1}$.* Since the $Z_j$ are mutually independent (iid), $Z_i\perp Z_{1:i-1}$, so
$$
\mathbb P_{Z_i\mid Z_{1:i-1}}=\mathbb P_{Z_i}=\mathcal D\quad\text{a.s.} \tag{Ind}
$$

*Step 3: Conditional MI $\ge$ unconditional MI under input independence.* We claim
$$
I(W;Z_i\mid Z_{1:i-1})\;\ge\;I(W;Z_i). \tag{L3.1}
$$
This is the decisive inequality. Unfolding using (Ind):
$$
\begin{aligned}
I(W;Z_i\mid Z_{1:i-1})
&=\mathbb E_{Z_{1:i-1}}\big[D_{\mathrm{KL}}\!\big(\mathbb P_{W,Z_i\mid Z_{1:i-1}}\,\big\|\,\mathbb P_{W\mid Z_{1:i-1}}\otimes\mathbb P_{Z_i\mid Z_{1:i-1}}\big)\big]\\
&\stackrel{(\text{Ind})}=\mathbb E_{Z_{1:i-1}}\big[D_{\mathrm{KL}}\!\big(\mathbb P_{W,Z_i\mid Z_{1:i-1}}\,\big\|\,\mathbb P_{W\mid Z_{1:i-1}}\otimes\mathcal D\big)\big].
\end{aligned}
$$
Now apply the *joint convexity* of $(P,Q)\mapsto D_{\mathrm{KL}}(P\|Q)$ — which follows from joint convexity of $(a,b)\mapsto a\log(a/b)$ for $a,b\ge 0$ on $\mathbb R_+^2$ (with convention $0\log 0=0$), integrated against a reference measure — via Jensen. Precisely, let $\mu_y=\mathbb P_{W,Z_i\mid Z_{1:i-1}=y}$ and $\nu_y=\mathbb P_{W\mid Z_{1:i-1}=y}\otimes\mathcal D$. Then
$$
\int\mu_y\,d\mathbb P_{Z_{1:i-1}}(y)=\mathbb P_{W,Z_i},\qquad \int\nu_y\,d\mathbb P_{Z_{1:i-1}}(y)=\mathbb P_W\otimes\mathcal D,
$$
where the second identity uses (Ind) again: the average of $\mathbb P_{W\mid Z_{1:i-1}}$ over $Z_{1:i-1}$ is $\mathbb P_W$, and $\mathcal D$ does not depend on $y$. Joint convexity of $(P,Q)\mapsto D_{\mathrm{KL}}(P\|Q)$ then yields, by Jensen applied against $P_{Z_{1:i-1}}$:
$$
\mathbb E_y\big[D_{\mathrm{KL}}(\mu_y\|\nu_y)\big]\;\ge\; D_{\mathrm{KL}}\!\Big(\textstyle\int\mu_y\,\Big\|\,\int\nu_y\Big)\;=\;D_{\mathrm{KL}}(\mathbb P_{W,Z_i}\|\mathbb P_W\otimes\mathcal D)\;=\;I(W;Z_i).
$$
This proves (L3.1).

*Step 4: Sum and conclude.*
$$
I(W;S)\stackrel{(\text{CR})}=\sum_{i=1}^n I(W;Z_i\mid Z_{1:i-1})\stackrel{(\text{L3.1})}\ge\sum_{i=1}^n I(W;Z_i),
$$
which is (L3). $\blacksquare$

*Remark (direction of the inequality).* The claim (L3.1) — "conditioning on *independent* coordinates *increases* MI" — is the correct direction here. One must not confuse it with the general (false) statement that conditioning always decreases MI. The asymmetry comes from the fact that we are comparing to the *marginal product* $\mathbb P_W\otimes\mathcal D$, which averages out $Z_{1:i-1}$ in the $W$-coordinate; conditional versions of this product are "less averaged" and thus closer to $\mathbb P_{W,Z_i\mid Z_{1:i-1}}$ only if that conditional is closer to its own product than the marginals are — but convexity of KL goes the other way when we re-average. This is precisely what the proof of (L3.1) exhibits.

---

## 6. Corollary — Xu–Raginsky bound

**Corollary (Xu–Raginsky 2017).** Under (A1) and iid $S$,
$$
\boxed{\;\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|\;\le\;\sqrt{\frac{2\sigma^2\,I(W;S)}{n}}.\;} \tag{XR}
$$

**Proof.** Starting from Theorem 1,
$$
\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|
\;\stackrel{\text{Thm 1}}\le\; \frac1n\sum_{i=1}^n\sqrt{2\sigma^2\,I(W;Z_i)}
\;=\;\sqrt{2\sigma^2}\cdot\frac1n\sum_{i=1}^n\sqrt{I(W;Z_i)}.
$$
The function $\sqrt{\cdot}$ is concave on $[0,\infty)$; by Jensen applied to the uniform probability measure on $\{1,\dots,n\}$,
$$
\frac1n\sum_{i=1}^n\sqrt{I(W;Z_i)}\;\le\;\sqrt{\frac1n\sum_{i=1}^n I(W;Z_i)}. \tag{Jensen}
$$
By Lemma 3,
$$
\frac1n\sum_{i=1}^n I(W;Z_i)\;\stackrel{\text{L3}}\le\;\frac{I(W;S)}{n}. \tag{L3}
$$
Chaining,
$$
\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|
\;\le\;\sqrt{2\sigma^2}\cdot\sqrt{\frac1n\sum_{i=1}^n I(W;Z_i)}
\;\le\;\sqrt{\frac{2\sigma^2\,I(W;S)}{n}}.
$$
This is (XR). $\blacksquare$

---

## 7. Remark — when is BZV *strictly* tighter?

Both inequalities (Jensen) and (L3) can be strict. We record exactly when.

**(i) Strictness of Jensen.** $\sqrt{\cdot}$ is strictly concave on $(0,\infty)$. Jensen's inequality
$$
\frac1n\sum_{i=1}^n\sqrt{I(W;Z_i)}\;\le\;\sqrt{\frac1n\sum_{i=1}^n I(W;Z_i)}
$$
holds with equality iff all $I(W;Z_i)$ are equal. If even two of them differ, the inequality is strict, and the gap scales like the variance of $(I(W;Z_i))_{i=1}^n$ around its mean.

**(ii) Strictness of Lemma 3.** $\sum_i I(W;Z_i)\le I(W;S)$ is strict whenever conditioning on $Z_{1:i-1}$ genuinely reveals information about $Z_i$'s relationship with $W$, i.e., when $I(W;Z_i\mid Z_{1:i-1})>I(W;Z_i)$ for some $i$. This holds as soon as $W$ depends on the *joint* configuration $S$ in a way that cannot be described sample-by-sample — e.g., any algorithm whose output is affected by interactions among the $Z_j$'s (essentially every nontrivial learning algorithm).

**(iii) Concrete example where BZV $\ll$ XR.** Suppose the learner only looks at the first sample: $W=g(Z_1)$. Then $I(W;Z_1)$ may be large but $I(W;Z_i)=0$ for $i\ge 2$, so
$$
\text{BZV bound} = \frac{1}{n}\sqrt{2\sigma^2 I(W;Z_1)} = \Theta\!\Big(\tfrac{1}{n}\Big),
$$
while $I(W;S)=I(W;Z_1)$ and the XR bound is
$$
\text{XR bound} = \sqrt{\frac{2\sigma^2 I(W;Z_1)}{n}} = \Theta\!\Big(\tfrac{1}{\sqrt n}\Big).
$$
For large $n$, BZV is tighter by a factor of $\sqrt n$. More generally, if only $k\le n$ samples have any influence on $W$ (subsampling-based methods, coreset methods, etc.), BZV gives a rate of $\Theta(\sqrt{k}/n)$ whereas XR gives $\Theta(\sqrt{k/n})$ — BZV wins by $\sqrt{n/k}$.

**(iv) When they coincide.** If the algorithm is permutation-invariant in its inputs, exchangeability of $S$ under the iid assumption $\mathcal D^{\otimes n}$ implies that the marginal law $\mathbb P_{W,Z_i}$ is the same for all $i$, hence all per-sample MIs $I(W;Z_i)$ coincide. In that case Jensen is tight. If additionally the $Z_i$ interact with $W$ independently (rare — essentially requires $W$ to be a product of per-sample functions), Lemma 3 is tight, and XR matches BZV.

---

## 8. Summary of the argument

| Step | What is proven | Tool |
|---|---|---|
| §1.4 | $\mathbb E[R_{\mathcal D}(W)-R_S(W)]=\tfrac1n\sum_i(\mathbb E_Q[\ell]-\mathbb E_P[\ell])$ | iid structure |
| Lemma 1 | Donsker–Varadhan: $\mathbb E_P f\le \log\mathbb E_Q e^f+D_{\mathrm{KL}}(P\|Q)$ | Gibbs inequality |
| Lemma 2 | $|\mathbb E_P f-\mathbb E_Q f|\le\sqrt{2\sigma^2 D_{\mathrm{KL}}(P\|Q)}$ | DV + optimize $\lambda$ |
| **Thm 1 (BZV)** | $|\mathbb E[\mathrm{gap}]|\le\tfrac1n\sum_i\sqrt{2\sigma^2 I(W;Z_i)}$ | Lemma 2 + triangle |
| Lemma 3 | $\sum_i I(W;Z_i)\le I(W;S)$ under iid | chain rule + KL joint convexity |
| **Cor (XR)** | $|\mathbb E[\mathrm{gap}]|\le\sqrt{2\sigma^2 I(W;S)/n}$ | Thm 1 + Jensen + L3 |

The per-sample bound (Theorem 1) is the *tight* quantity; Xu–Raginsky is a further relaxation via two concavity/convexity inequalities, each of which can be strict. This is why Bu–Zou–Veeravalli's refinement is a genuine strengthening, not a cosmetic reformulation. $\blacksquare$
