# Route E — Gibbs-Tilting / Primal KL Identity Proof of the Xu–Raginsky Bound

**Theorem (Xu–Raginsky 2017).** Under assumption (A1) — $\ell(W,Z)$ is $\sigma$-sub-Gaussian under the product measure $\mathbb{P}_W\otimes\mathcal{D}$ — the generalization gap of any randomized algorithm $A:Z^n\to\mathcal{W}$ obeys
$$
\Big|\,\mathbb{E}\!\left[R_{\mathcal{D}}(W)-R_S(W)\right]\Big|\;\le\;\sqrt{\tfrac{2\sigma^2\,I(W;S)}{n}}.
$$

The proof below follows Route E: the change-of-measure step is derived from a **direct Radon–Nikodym identity** (Gibbs tilting), not from the Donsker–Varadhan supremum.

---

## 1. Preliminaries

Fix a measurable space $(\Omega,\mathcal{F})$. Let $P,Q$ be probability measures on $(\Omega,\mathcal{F})$ with $P\ll Q$, and let $p:=\frac{dP}{dQ}$ be a version of the Radon–Nikodym density. The Kullback–Leibler divergence is
$$
D_{\mathrm{KL}}(P\|Q)\;:=\;\int_{\Omega}\log p\,dP\;=\;\int_{\Omega} p\log p\,dQ\;\in[0,\infty],
$$
with the convention $0\log 0:=0$. Gibbs' inequality gives $D_{\mathrm{KL}}(P\|Q)\ge 0$, with equality iff $P=Q$.

**Gibbs tilt.** Given a measurable $\varphi:\Omega\to\mathbb{R}$ with $Z_\varphi:=\mathbb{E}_Q[e^\varphi]=\int e^\varphi\,dQ\in(0,\infty)$, define the **tilted measure** $Q^\varphi$ by
$$
\frac{dQ^\varphi}{dQ}\;:=\;\frac{e^\varphi}{Z_\varphi}.
$$
This is a probability measure (integral equals $1$) and $Q^\varphi\sim Q$ (mutually absolutely continuous), because $e^\varphi>0$ everywhere.

**Sub-Gaussian function.** A measurable $f:\Omega\to\mathbb{R}$ is $\sigma$-sub-Gaussian under $Q$ (with $\mathbb{E}_Q|f|<\infty$) if
$$
\log\mathbb{E}_Q\!\big[e^{\lambda(f-\mathbb{E}_Q[f])}\big]\;\le\;\tfrac{\lambda^2\sigma^2}{2},\qquad\forall\lambda\in\mathbb{R}. \tag{SG}
$$

**Mutual information.** For jointly distributed $(X,Y)$ on $(\mathcal{X}\times\mathcal{Y},\mathcal{B}(\mathcal{X})\otimes\mathcal{B}(\mathcal{Y}))$ with joint law $\mathbb{P}_{X,Y}$ and marginals $\mathbb{P}_X,\mathbb{P}_Y$,
$$
I(X;Y)\;:=\;D_{\mathrm{KL}}(\mathbb{P}_{X,Y}\,\|\,\mathbb{P}_X\otimes\mathbb{P}_Y).
$$

---

## 2. Lemma 1 (Gibbs-Tilting Identity)

**Lemma 1.** Let $P\ll Q$ on $(\Omega,\mathcal{F})$ and let $\varphi:\Omega\to\mathbb{R}$ be measurable with $Z_\varphi:=\mathbb{E}_Q[e^\varphi]\in(0,\infty)$. Assume additionally $\mathbb{E}_P[\varphi^-]<\infty$ so that $\mathbb{E}_P[\varphi]\in(-\infty,\infty]$ is well defined. Then
$$
\boxed{\;D_{\mathrm{KL}}(P\|Q^\varphi)\;=\;D_{\mathrm{KL}}(P\|Q)\;-\;\mathbb{E}_P[\varphi]\;+\;\log Z_\varphi\;}\tag{GT}
$$
as an identity in $[-\infty,\infty]$ (both sides are simultaneously finite or the identity is read in the extended reals with the non-negativity of the left-hand side enforced).

**Proof.** Since $P\ll Q$ and $Q^\varphi\sim Q$ (with strictly positive density $e^\varphi/Z_\varphi$ w.r.t. $Q$), we have $P\ll Q^\varphi$. Let $p:=dP/dQ$. By the Radon–Nikodym chain rule,
$$
\frac{dP}{dQ^\varphi}
\;=\;\frac{dP}{dQ}\cdot\frac{dQ}{dQ^\varphi}
\;=\;p(\omega)\cdot\frac{Z_\varphi}{e^{\varphi(\omega)}}
\qquad P\text{-a.s.},\tag{1}
$$
because the reciprocal of $dQ^\varphi/dQ=e^\varphi/Z_\varphi$ is $Z_\varphi e^{-\varphi}$, which is $Q$-a.s. finite (hence $P$-a.s. finite).

Taking logarithms on both sides of (1),
$$
\log\!\frac{dP}{dQ^\varphi}\;=\;\log p\;-\;\varphi\;+\;\log Z_\varphi\qquad P\text{-a.s.}\tag{2}
$$

Integrate (2) with respect to $P$:
$$
\int\log\!\frac{dP}{dQ^\varphi}\,dP
\;=\;\int\log p\,dP\;-\;\int\varphi\,dP\;+\;\log Z_\varphi\cdot P(\Omega),
$$
i.e.,
$$
D_{\mathrm{KL}}(P\|Q^\varphi)\;=\;D_{\mathrm{KL}}(P\|Q)\;-\;\mathbb{E}_P[\varphi]\;+\;\log Z_\varphi.
$$
(The integrability of $\log(dP/dQ^\varphi)$ follows because each of $\log p$ and $\varphi$ is integrable in the same extended-real sense under the stated hypotheses; no term has ambiguous sign cancellation since $D_{\mathrm{KL}}\ge 0$ forces $\int(\log p)^-\,dP<\infty$.) $\square$

**Remark 2.1.** Identity (GT) is *purely algebraic*: it is the statement that, at the level of Radon–Nikodym derivatives, $p = (dP/dQ^\varphi)(e^\varphi/Z_\varphi)$, and taking $\log$ and integrating against $P$. No variational step, no supremum, no convex duality.

---

## 3. Lemma 2 (Primal KL Inequality)

**Lemma 2.** Under the hypotheses of Lemma 1 and with $D_{\mathrm{KL}}(P\|Q)<\infty$,
$$
\mathbb{E}_P[\varphi]\;\le\;D_{\mathrm{KL}}(P\|Q)\;+\;\log\mathbb{E}_Q[e^\varphi]. \tag{PKL}
$$

**Proof.** Rearrange (GT) as
$$
\mathbb{E}_P[\varphi]\;=\;D_{\mathrm{KL}}(P\|Q)\;+\;\log Z_\varphi\;-\;D_{\mathrm{KL}}(P\|Q^\varphi).
$$
By Gibbs' inequality, $D_{\mathrm{KL}}(P\|Q^\varphi)\ge 0$. Therefore
$$
\mathbb{E}_P[\varphi]\;\le\;D_{\mathrm{KL}}(P\|Q)\;+\;\log Z_\varphi\;=\;D_{\mathrm{KL}}(P\|Q)\;+\;\log\mathbb{E}_Q[e^\varphi].\qquad\square
$$

**Remark 3.1.** (PKL) is the same numerical inequality that appears in the Donsker–Varadhan upper bound $D_{\mathrm{KL}}(P\|Q)\ge\mathbb{E}_P[\varphi]-\log\mathbb{E}_Q[e^\varphi]$. Route E *derives* it without ever writing a supremum: it comes directly from the fact that KL of $P$ against the Gibbs tilt $Q^\varphi$ is non-negative. The $\sup_\varphi$ in DV corresponds (under mild conditions) to the tilt that makes $Q^\varphi=P$, i.e., saturates (GT); but for our purposes we do *not* need attainment of that supremum.

---

## 4. Lemma 3 (Sub-Gaussian Transport via the Primal Identity)

**Lemma 3.** Let $P\ll Q$ with $D_{\mathrm{KL}}(P\|Q)<\infty$, and let $f$ be $\sigma$-sub-Gaussian under $Q$ in the sense of (SG), with $\mathbb{E}_Q|f|<\infty$ and $\mathbb{E}_P|f|<\infty$. Then
$$
\big|\,\mathbb{E}_P[f]-\mathbb{E}_Q[f]\,\big|\;\le\;\sqrt{2\sigma^2\,D_{\mathrm{KL}}(P\|Q)}. \tag{SGT}
$$

**Proof.** Fix $\lambda>0$ and apply Lemma 2 with the test function
$$
\varphi_\lambda\;:=\;\lambda\big(f-\mathbb{E}_Q[f]\big).
$$
Under (SG), $\mathbb{E}_Q[e^{\varphi_\lambda}]\le\exp(\lambda^2\sigma^2/2)<\infty$, so Lemma 2 applies. We get
$$
\lambda\big(\mathbb{E}_P[f]-\mathbb{E}_Q[f]\big)\;=\;\mathbb{E}_P[\varphi_\lambda]\;\le\;D_{\mathrm{KL}}(P\|Q)\;+\;\log\mathbb{E}_Q[e^{\varphi_\lambda}]\;\le\;D_{\mathrm{KL}}(P\|Q)\;+\;\tfrac{\lambda^2\sigma^2}{2}.
$$
Dividing by $\lambda>0$,
$$
\mathbb{E}_P[f]-\mathbb{E}_Q[f]\;\le\;\frac{D_{\mathrm{KL}}(P\|Q)}{\lambda}\;+\;\frac{\lambda\sigma^2}{2}.
$$
Minimizing the right-hand side over $\lambda>0$ via AM-GM gives the stationary value $\lambda^\star=\sqrt{2D_{\mathrm{KL}}(P\|Q)/\sigma^2}$ (if $D_{\mathrm{KL}}(P\|Q)=0$ the bound is trivially $0$ by letting $\lambda\downarrow 0$), yielding
$$
\mathbb{E}_P[f]-\mathbb{E}_Q[f]\;\le\;\sqrt{2\sigma^2\,D_{\mathrm{KL}}(P\|Q)}.\tag{3}
$$
Repeat the argument with $f$ replaced by $-f$ (which is also $\sigma$-sub-Gaussian under $Q$, since (SG) is symmetric in $\lambda$):
$$
\mathbb{E}_Q[f]-\mathbb{E}_P[f]\;\le\;\sqrt{2\sigma^2\,D_{\mathrm{KL}}(P\|Q)}.\tag{4}
$$
Combining (3) and (4) yields (SGT). $\square$

---

## 5. Lemma 4 (Chain Rule and Per-Sample MI Summation)

**Lemma 4.** Let $W$ be a random element of $\mathcal{W}$ and $S=(Z_1,\dots,Z_n)$ with $Z_1,\dots,Z_n\stackrel{\text{iid}}{\sim}\mathcal{D}$, independent of the algorithm's internal randomness. Then
$$
\sum_{i=1}^n I(W;Z_i)\;\le\;I(W;S). \tag{CR}
$$

**Proof.** The Shannon chain rule for mutual information (valid on general measurable spaces via the KL chain rule for conditional distributions) gives
$$
I(W;S)\;=\;I(W;Z_1,\dots,Z_n)\;=\;\sum_{i=1}^n I(W;Z_i\mid Z_1,\dots,Z_{i-1}). \tag{5}
$$
Because $Z_1,\dots,Z_n$ are mutually independent, for each $i$ we have $Z_i\perp Z_{1:i-1}$. Hence
$$
I(W;Z_i\mid Z_{1:i-1})\;=\;I(W,Z_{1:i-1};Z_i)\;\ge\;I(W;Z_i), \tag{6}
$$
where the first equality uses $I(A;B\mid C)=I(A,C;B)-I(C;B)$ together with $I(Z_{1:i-1};Z_i)=0$ (independence), and the inequality is the data-processing / monotonicity bound $I(X,Y;Z)\ge I(X;Z)$ (since adding a random variable to the "input" can only increase the KL divergence from the corresponding product marginal, by the KL chain rule).

Summing (6) over $i$ and using (5) gives $\sum_{i=1}^n I(W;Z_i)\le I(W;S)$. $\square$

**Remark 5.1 (direct derivation of (6)).** Writing $\pi_i:=\mathbb{P}_{Z_i}$, $\mu_i:=\mathbb{P}_{W,Z_{1:i-1}}$, and using independence $\mathbb{P}_{W,Z_{1:i}}=\mathbb{P}_{W,Z_{1:i-1},Z_i}$:
$$
I(W,Z_{1:i-1};Z_i)
=D_{\mathrm{KL}}\big(\mathbb{P}_{W,Z_{1:i}}\,\|\,\mu_i\otimes\pi_i\big)
\ge D_{\mathrm{KL}}\big(\mathbb{P}_{W,Z_i}\,\|\,\mathbb{P}_W\otimes\pi_i\big)=I(W;Z_i),
$$
where the inequality is the KL data-processing inequality applied to the measurable projection $(w,z_{1:i-1},z_i)\mapsto(w,z_i)$.

---

## 6. Main Proof

We assemble the pieces.

### 6.1 Per-sample decomposition of the generalization gap

By Fubini (applied to the joint law of $W$ and each $Z_i$),
$$
\mathbb{E}[R_S(W)]
=\frac{1}{n}\sum_{i=1}^n\mathbb{E}_{\mathbb{P}_{W,Z_i}}[\ell(W,Z_i)].\tag{7}
$$
For the population risk, let $Z'\sim\mathcal{D}$ be an independent copy (drawn under the product $\mathbb{P}_W\otimes\mathcal{D}$). By the tower rule,
$$
\mathbb{E}[R_\mathcal{D}(W)]
=\mathbb{E}_W\!\big[\mathbb{E}_{Z'\sim\mathcal{D}}\ell(W,Z')\big]
=\mathbb{E}_{\mathbb{P}_W\otimes\mathcal{D}}[\ell(W,Z')].\tag{8}
$$
Since the marginal of $(W,Z_i)$ under $\mathbb{P}_W\otimes\mathcal{D}$ does not depend on $i$, we may rewrite (8) as
$$
\mathbb{E}[R_\mathcal{D}(W)]
=\frac{1}{n}\sum_{i=1}^n\mathbb{E}_{\mathbb{P}_W\otimes\mathcal{D}}[\ell(W,Z_i')]. \tag{9}
$$
Subtracting (7) from (9),
$$
\mathbb{E}[R_\mathcal{D}(W)-R_S(W)]
=\frac{1}{n}\sum_{i=1}^n\Big(\mathbb{E}_{\mathbb{P}_W\otimes\mathcal{D}}[\ell(W,Z_i')]-\mathbb{E}_{\mathbb{P}_{W,Z_i}}[\ell(W,Z_i)]\Big). \tag{10}
$$

### 6.2 Applying the sub-Gaussian transport bound per-sample

Fix $i\in\{1,\dots,n\}$ and set
$$
P_i:=\mathbb{P}_{W,Z_i},\qquad Q_i:=\mathbb{P}_W\otimes\mathcal{D},\qquad f_i(w,z):=\ell(w,z).
$$
By construction, both $P_i$ and $Q_i$ are probability measures on $\mathcal{W}\times Z$, they share the same $W$-marginal $\mathbb{P}_W$, and $Q_i$'s $Z$-marginal is $\mathcal{D}$. Since the $Z$-marginal of $P_i$ is also $\mathcal{D}$ (each $Z_i$ is marginally distributed as $\mathcal{D}$, by the iid assumption), $P_i\ll Q_i$ whenever the conditional law $\mathbb{P}_{Z_i\mid W}$ is absolutely continuous w.r.t.\ $\mathcal{D}$ $\mathbb{P}_W$-a.s.; this holds automatically when $I(W;Z_i)<\infty$ (otherwise the bound (MI) below is vacuous and the conclusion is trivial).

Assumption (A1) states that $\ell(W,Z)$ is $\sigma$-sub-Gaussian under $\mathbb{P}_W\otimes\mathcal{D}=Q_i$, hence (SG) holds with $f=f_i$ under $Q=Q_i$. Lemma 3 therefore gives
$$
\Big|\,\mathbb{E}_{P_i}[\ell(W,Z_i)]-\mathbb{E}_{Q_i}[\ell(W,Z_i')]\,\Big|
\;\le\;\sqrt{2\sigma^2\,D_{\mathrm{KL}}(P_i\|Q_i)}
\;=\;\sqrt{2\sigma^2\,I(W;Z_i)}. \tag{MI}
$$

### 6.3 Assembly

Combining (10) with the triangle inequality and (MI),
$$
\big|\,\mathbb{E}[R_\mathcal{D}(W)-R_S(W)]\,\big|
\;\le\;\frac{1}{n}\sum_{i=1}^n\sqrt{2\sigma^2\,I(W;Z_i)}. \tag{11}
$$

Apply Cauchy–Schwarz to the sum on the right of (11):
$$
\frac{1}{n}\sum_{i=1}^n\sqrt{2\sigma^2\,I(W;Z_i)}
=\frac{1}{n}\sum_{i=1}^n 1\cdot\sqrt{2\sigma^2\,I(W;Z_i)}
\;\le\;\frac{1}{n}\sqrt{n}\cdot\sqrt{\sum_{i=1}^n 2\sigma^2\,I(W;Z_i)}
=\sqrt{\frac{2\sigma^2}{n}\sum_{i=1}^n I(W;Z_i)}. \tag{12}
$$

Finally, invoke Lemma 4 (chain-rule inequality $\sum_i I(W;Z_i)\le I(W;S)$) in the right-hand side of (12):
$$
\sqrt{\frac{2\sigma^2}{n}\sum_{i=1}^n I(W;Z_i)}
\;\le\;\sqrt{\frac{2\sigma^2\,I(W;S)}{n}}. \tag{13}
$$

Chaining (11)–(13),
$$
\big|\,\mathbb{E}[R_\mathcal{D}(W)-R_S(W)]\,\big|
\;\le\;\sqrt{\frac{2\sigma^2\,I(W;S)}{n}},
$$
which is the claimed Xu–Raginsky bound. $\blacksquare$

---

## 7. Remark: Structural Advantage of the Primal Derivation

Route E differs from the canonical Donsker–Varadhan route (Route A) only in how the key inequality
$$
\mathbb{E}_P[\varphi]\le D_{\mathrm{KL}}(P\|Q)+\log\mathbb{E}_Q[e^\varphi]\qquad(\text{PKL})
$$
is obtained. Three concrete benefits of the primal derivation:

1. **No supremum / no attainment issue.** The DV variational formula states
$$
D_{\mathrm{KL}}(P\|Q)=\sup_{\varphi}\big\{\mathbb{E}_P[\varphi]-\log\mathbb{E}_Q[e^\varphi]\big\}.
$$
Deriving (PKL) from this supremum is a tautology, but *proving* the DV formula requires showing that the supremum is tight. Tightness is typically obtained by plugging in $\varphi^\star=\log(dP/dQ)$, which requires $\log(dP/dQ)$ to be an admissible test function — a condition that is clean in finite/discrete settings but subtle when $D_{\mathrm{KL}}(P\|Q)=\infty$ or when one wants to restrict $\varphi$ to bounded continuous functions. Route E sidesteps these technicalities: we only use the identity (GT) and non-negativity of KL.

2. **Extends to non-$\sigma$-finite or singular reference measures.** Identity (GT) only requires $P\ll Q$ and $Z_\varphi<\infty$; no further regularity on $Q$. In contrast, several standard proofs of DV rely on approximation by bounded measurable $\varphi$ and dominated convergence, which requires $\sigma$-finiteness of $Q$ to justify Fubini-type steps.

3. **Transparent equality case.** (PKL) is an equality iff $D_{\mathrm{KL}}(P\|Q^\varphi)=0$, i.e.\ $P=Q^\varphi$. This directly exhibits the saturating distribution as the Gibbs tilt of $Q$ by $\varphi$, rather than leaving it implicit inside a supremum. Consequently, the bound (SGT) is tight exactly when $P$ is a Gibbs tilt of $Q$ by a linear function of $f$.

In short, Route E trades a variational supremum for an algebraic identity plus Gibbs' inequality, obtaining the same quantitative bound with a shorter and more robust proof.
