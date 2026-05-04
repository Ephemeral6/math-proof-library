# Route C — PAC-Bayesian Reduction (Expected-KL = MI)

**Target.** Under Assumption (A1) (joint $\sigma$-sub-Gaussianity of $\ell(W, Z)$ under $\mathbb{P}_W \otimes \mathcal{D}$),
$$
\bigl|\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]\bigr| \;\le\; \sqrt{\frac{2\sigma^2 \, I(W; S)}{n}}.
$$

The Route-C strategy views $\mathbb{P}_{W\mid S}$ as a **data-dependent posterior** and $\mathbb{P}_W$ as the **marginal prior**, and derives the bound through an **expectation-form PAC-Bayes inequality** under the sub-Gaussian assumption, closing the loop via the identity $\mathbb{E}_S[D_{\mathrm{KL}}(\mathbb{P}_{W\mid S}\|\mathbb{P}_W)] = I(W; S)$.

---

## 1. Preliminaries

**Setup.** $S = (Z_1, \dots, Z_n)$, $Z_i \stackrel{\mathrm{iid}}{\sim} \mathcal{D}$. Algorithm $A : \mathcal{Z}^n \to \mathcal{W}$ produces $W = A(S)$, with joint law $\mathbb{P}_{W, S}$ on $\mathcal{W} \times \mathcal{Z}^n$. Marginals $\mathbb{P}_W$, $\mathbb{P}_S = \mathcal{D}^{\otimes n}$. Conditional law of $W$ given $S$ is the regular conditional $\mathbb{P}_{W \mid S}$ (standard Borel assumption on $(\mathcal{W}, \mathcal{Z})$ is assumed throughout).

**Loss and risks.** $\ell : \mathcal{W} \times \mathcal{Z} \to \mathbb{R}$ measurable.
$$
R_\mathcal{D}(w) := \mathbb{E}_{Z \sim \mathcal{D}}[\ell(w, Z)], \qquad R_S(w) := \frac{1}{n}\sum_{i=1}^n \ell(w, Z_i).
$$

**Assumption (A1).** Under $\mathbb{P}_W \otimes \mathcal{D}$, $\ell(W, Z)$ is $\sigma$-sub-Gaussian:
$$
\log \mathbb{E}_{W \otimes Z}\bigl[e^{\lambda(\ell(W, Z) - \mu_0)}\bigr] \;\le\; \frac{\lambda^2 \sigma^2}{2}, \qquad \forall \lambda \in \mathbb{R},
$$
where $\mu_0 := \mathbb{E}_{W \otimes Z}[\ell(W, Z)]$.

**KL divergence.** For $P \ll Q$, $D_{\mathrm{KL}}(P\|Q) = \int \log \frac{dP}{dQ} \, dP \ge 0$.

**Donsker–Varadhan (DV) variational formula.** For $P \ll Q$ and any measurable $f$ with $\mathbb{E}_Q[e^f] < \infty$,
$$
\mathbb{E}_P[f] \;\le\; D_{\mathrm{KL}}(P \| Q) + \log \mathbb{E}_Q[e^f]. \tag{DV}
$$
This is classical; proof sketch: $\log \mathbb{E}_Q[e^f] - \mathbb{E}_P[f] = D_{\mathrm{KL}}(P\|Q) - D_{\mathrm{KL}}(P \| Q_f) \ge -D_{\mathrm{KL}}(P\|Q)$ where $dQ_f = e^f\,dQ / \mathbb{E}_Q[e^f]$.

---

## 2. Lemma 1 (MI = expected KL — disintegration).

**Claim.** Under the standard-Borel hypothesis giving a regular conditional $\mathbb{P}_{W\mid S}$,
$$
I(W; S) \;=\; \mathbb{E}_{S \sim \mathbb{P}_S}\!\bigl[ D_{\mathrm{KL}}(\mathbb{P}_{W\mid S=s} \,\|\, \mathbb{P}_W) \bigr].
$$

**Proof.** By definition, $I(W; S) = D_{\mathrm{KL}}(\mathbb{P}_{W, S} \| \mathbb{P}_W \otimes \mathbb{P}_S)$. When $\mathbb{P}_{W, S} \ll \mathbb{P}_W \otimes \mathbb{P}_S$, the Radon–Nikodym derivative factorises via disintegration as
$$
\frac{d\mathbb{P}_{W, S}}{d(\mathbb{P}_W \otimes \mathbb{P}_S)}(w, s) \;=\; \frac{d\mathbb{P}_{W\mid S=s}}{d\mathbb{P}_W}(w) \qquad \text{($\mathbb{P}_W \otimes \mathbb{P}_S$-a.e.).}
$$
(If no dominance holds, $I(W; S) = +\infty$ and the inequality is vacuous.) Taking logs and integrating,
$$
I(W; S) = \int \!\!\int \log \frac{d\mathbb{P}_{W\mid S=s}}{d\mathbb{P}_W}(w) \, d\mathbb{P}_{W\mid S=s}(w)\, d\mathbb{P}_S(s) = \mathbb{E}_S\bigl[D_{\mathrm{KL}}(\mathbb{P}_{W\mid S}\|\mathbb{P}_W)\bigr]. \qquad \blacksquare
$$

---

## 3. Key MGF Lemma (sub-Gaussianity of $R_\mathcal{D}(\cdot) - R_S(\cdot)$ under the prior).

**Lemma 2a.** Fix $\lambda \in \mathbb{R}$. Define
$$
F_\lambda(s) \;:=\; \log \mathbb{E}_{W \sim \mathbb{P}_W}\!\Bigl[ \exp\!\bigl( \lambda \bigl[ R_\mathcal{D}(W) - R_s(W) \bigr] \bigr)\Bigr], \qquad s \in \mathcal{Z}^n.
$$
Then
$$
\mathbb{E}_{S \sim \mathcal{D}^{\otimes n}}\!\bigl[ e^{F_\lambda(S)} \bigr] \;=\; \mathbb{E}_W \mathbb{E}_S\!\Bigl[ e^{\lambda (R_\mathcal{D}(W) - R_S(W))} \Bigr] \;\le\; \exp\!\Bigl( \frac{\lambda^2 \sigma^2}{2n} \Bigr). \tag{MGF}
$$

**Proof.** Fubini (both integrands are non-negative) gives the first equality. For the bound, fix $w \in \mathcal{W}$ and put $X_i(w) := R_\mathcal{D}(w) - \ell(w, Z_i)$, so $R_\mathcal{D}(w) - R_S(w) = \tfrac{1}{n}\sum_i X_i(w)$, and under $\mathcal{D}^{\otimes n}$ the $X_i(w)$ are iid (in $i$) with mean zero. Independence in $i$ gives
$$
\mathbb{E}_S\bigl[ e^{\lambda (R_\mathcal{D}(w) - R_S(w))} \bigr] \;=\; \prod_{i=1}^n \mathbb{E}_{Z_i \sim \mathcal{D}}\!\Bigl[ e^{(\lambda/n) X_i(w)} \Bigr] \;=\; \Bigl(\varphi_w(\lambda/n)\Bigr)^{n},
$$
where $\varphi_w(t) := \mathbb{E}_{Z \sim \mathcal{D}}\bigl[ e^{t(R_\mathcal{D}(w) - \ell(w, Z))}\bigr]$.

Now take $\mathbb{E}_W$ on both sides and again apply Fubini:
$$
\mathbb{E}_{W, S}\!\bigl[ e^{\lambda (R_\mathcal{D}(W) - R_S(W))}\bigr] \;=\; \mathbb{E}_W\bigl[\varphi_W(\lambda/n)^n\bigr].
$$

To bound this by the joint sub-Gaussian hypothesis we exploit the product structure. Write $Z_1,\dots,Z_n$ iid $\sim \mathcal{D}$, independent of $W \sim \mathbb{P}_W$. Set $U := R_\mathcal{D}(W) - R_S(W) = \frac{1}{n}\sum_i (R_\mathcal{D}(W) - \ell(W, Z_i))$. Note that under $\mathbb{P}_W \otimes \mathcal{D}^{\otimes n}$, the $n$ random variables
$$
Y_i := R_\mathcal{D}(W) - \ell(W, Z_i)
$$
are **conditionally iid given $W$** (they are iid across $i$ once $W$ is frozen) and each has conditional mean $0$ given $W$. Crucially the sub-Gaussian hypothesis (A1) is on the *joint* distribution of $(W, Z)$ under $\mathbb{P}_W \otimes \mathcal{D}$, i.e.
$$
\mathbb{E}_{W \otimes Z}\bigl[ e^{\lambda (\ell(W, Z) - \mu_0)}\bigr] \le e^{\lambda^2 \sigma^2/2}. \tag{A1}
$$
Subtracting and adding $R_\mathcal{D}(W)$ and using that $R_\mathcal{D}(W) - \mu_0$ has a deterministic part in $W$, one obtains (after integrating over $Z$ first to kill the $R_\mathcal{D}(W)$ centering, using that $\mathbb{E}_Z[\ell(W, Z)\mid W] = R_\mathcal{D}(W)$):
$$
\mathbb{E}_{W \otimes Z}\bigl[ e^{\lambda (R_\mathcal{D}(W) - \ell(W, Z))}\bigr] \;=\; \mathbb{E}_{W \otimes Z}\bigl[ e^{-\lambda(\ell(W, Z) - R_\mathcal{D}(W))}\bigr]. \tag{$\star$}
$$
However, (A1) controls the MGF around $\mu_0$, **not** around $R_\mathcal{D}(W)$. This is the **central obstruction of Route C** — we flag it honestly rather than hide it:

> **Obstruction (★).** The hypothesis (A1) states $\ell(W, Z)$ is $\sigma$-sub-Gaussian under $\mathbb{P}_W \otimes \mathcal{D}$ **as a single random variable centered at $\mu_0$**. It does **not** automatically imply per-sample sub-Gaussianity of $\ell(W, Z) - R_\mathcal{D}(W)$ for a.e. $W$ (which would be a stronger conditional statement).

**Resolution.** We proceed through the DV + per-sample route (essentially Route A/D arithmetic), re-assembled to expose the expected KL. This is done in Lemma 2 below. In short, Route C does **not** yield a new MGF lemma of the form (MGF) directly from (A1) — it **reduces** to applying DV one sample at a time.

---

## 4. Lemma 2 (Expectation-form sub-Gaussian PAC-Bayes).

**Statement.**
$$
\mathbb{E}_S\!\Bigl[\,\mathbb{E}_{W \sim \mathbb{P}_{W\mid S}}\!\bigl[ R_\mathcal{D}(W) - R_S(W)\bigr]\Bigr] \;\le\; \mathbb{E}_S\!\left[ \sqrt{\tfrac{2\sigma^2}{n}\, D_{\mathrm{KL}}(\mathbb{P}_{W\mid S} \,\|\, \mathbb{P}_W)\cdot n/n}\,\right].
$$

Because the clean square-root-inside-expectation form cannot be established under (A1) alone (obstruction (★)), we prove instead the following weaker but sufficient statement that still closes the theorem via Jensen (Section 5).

**Lemma 2 (per-sample DV form).** For each $i \in \{1,\dots, n\}$,
$$
\mathbb{E}_{W, Z_i}[\ell(W, Z_i)] - \mathbb{E}_{W \otimes Z}[\ell(W, Z)] \;\le\; \sqrt{2\sigma^2\, I(W; Z_i)},
$$
where $\mathbb{E}_{W, Z_i}$ is under the marginal joint $\mathbb{P}_{W, Z_i}$ and $\mathbb{E}_{W\otimes Z}$ is under $\mathbb{P}_W \otimes \mathcal{D}$.

**Proof.** Let $P := \mathbb{P}_{W, Z_i}$ and $Q := \mathbb{P}_W \otimes \mathcal{D}$. Note $Q$ is the product measure with the same marginals. (A1) states that $f(w, z) := \ell(w, z)$ is $\sigma$-sub-Gaussian under $Q$. Apply (DV) with $\lambda f$:
$$
\lambda (\mathbb{E}_P[f] - \mathbb{E}_Q[f]) \;\le\; D_{\mathrm{KL}}(P\|Q) + \log \mathbb{E}_Q\bigl[e^{\lambda(f - \mathbb{E}_Q[f])}\bigr] \;\le\; D_{\mathrm{KL}}(P\|Q) + \frac{\lambda^2 \sigma^2}{2}.
$$
Minimising the right side over $\lambda > 0$ (quadratic in $\lambda$, minimiser $\lambda^\star = \sqrt{2 D_{\mathrm{KL}}(P\|Q)}/\sigma$) yields
$$
\mathbb{E}_P[f] - \mathbb{E}_Q[f] \;\le\; \sqrt{2 \sigma^2 \, D_{\mathrm{KL}}(P \| Q)}.
$$
Applying the same argument with $-\lambda$ gives the absolute value. Finally $D_{\mathrm{KL}}(\mathbb{P}_{W, Z_i} \| \mathbb{P}_W \otimes \mathcal{D}) = D_{\mathrm{KL}}(\mathbb{P}_{W, Z_i} \| \mathbb{P}_W \otimes \mathbb{P}_{Z_i}) = I(W; Z_i)$ because $\mathbb{P}_{Z_i} = \mathcal{D}$. $\blacksquare$

---

## 5. Lemma 3 (Jensen for concave $\sqrt{\cdot}$).

**Statement.** For any non-negative random variable $X$ and finitely many non-negative numbers $x_1,\dots,x_n$,
$$
\mathbb{E}[\sqrt{X}] \le \sqrt{\mathbb{E}[X]}, \qquad \frac{1}{n}\sum_{i=1}^n \sqrt{x_i} \le \sqrt{\frac{1}{n}\sum_{i=1}^n x_i}.
$$
**Proof.** $t \mapsto \sqrt{t}$ is concave on $[0,\infty)$; both statements are instances of Jensen's inequality (the second takes $X$ uniform on $\{x_1,\dots, x_n\}$). $\blacksquare$

---

## 6. Main Proof (assembly via expected KL).

**Step 1 (decomposition).** Using iid structure of $S$, the symmetrisation identity (take $Z_i'$ an independent copy of $Z_i$ so that $(W, Z_i')$ has law $\mathbb{P}_W \otimes \mathcal{D}$):
$$
\mathbb{E}[R_\mathcal{D}(W) - R_S(W)] \;=\; \frac{1}{n}\sum_{i=1}^n \Bigl( \mathbb{E}_{W, Z_i'}[\ell(W, Z_i')] - \mathbb{E}_{W, Z_i}[\ell(W, Z_i)]\Bigr).
$$
Here $\mathbb{E}_{W, Z_i'}$ uses $(W, Z_i') \sim \mathbb{P}_W \otimes \mathcal{D}$ and $\mathbb{E}_{W, Z_i}$ uses $(W, Z_i) \sim \mathbb{P}_{W, Z_i}$. This holds because (i) $\mathbb{E}[R_\mathcal{D}(W)] = \mathbb{E}_W[R_\mathcal{D}(W)] = \mathbb{E}_{W \otimes Z}[\ell(W, Z)]$, independent of the sample index, and (ii) $\mathbb{E}[R_S(W)] = \frac{1}{n}\sum_i \mathbb{E}_{W, Z_i}[\ell(W, Z_i)]$.

**Step 2 (per-sample DV).** By Lemma 2 (and the sign-flipped version),
$$
\bigl|\mathbb{E}_{W, Z_i'}[\ell(W, Z_i')] - \mathbb{E}_{W, Z_i}[\ell(W, Z_i)]\bigr| \;\le\; \sqrt{2\sigma^2 \, I(W; Z_i)}.
$$

**Step 3 (Jensen to pool the per-sample MIs).**
$$
\bigl|\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]\bigr| \;\le\; \frac{1}{n}\sum_i \sqrt{2\sigma^2 I(W; Z_i)} \;\stackrel{\text{Lem 3}}{\le}\; \sqrt{\frac{2\sigma^2}{n} \sum_{i=1}^n I(W; Z_i)}.
$$

**Step 4 (chain rule + iid ⇒ $\sum_i I(W; Z_i) \le I(W; S)$).**

By the chain rule for mutual information,
$$
I(W; S) \;=\; I(W; Z_1, \dots, Z_n) \;=\; \sum_{i=1}^n I(W; Z_i \mid Z_{1:i-1}).
$$
We show $I(W; Z_i) \le I(W; Z_i \mid Z_{1:i-1})$ for each $i$. Indeed, since the $Z_j$'s are iid, $Z_i$ is independent of $Z_{1:i-1}$, so $I(Z_i; Z_{1:i-1}) = 0$. By the chain rule on the pair $(W, Z_{1:i-1})$ with variable $Z_i$:
$$
I(Z_i; W, Z_{1:i-1}) \;=\; I(Z_i; Z_{1:i-1}) + I(Z_i; W \mid Z_{1:i-1}) \;=\; I(W; Z_i \mid Z_{1:i-1}),
$$
and also $I(Z_i; W, Z_{1:i-1}) = I(Z_i; W) + I(Z_i; Z_{1:i-1} \mid W) \ge I(Z_i; W) = I(W; Z_i)$ (by non-negativity of conditional MI and symmetry). Combining,
$$
I(W; Z_i) \le I(W; Z_i \mid Z_{1:i-1}),
$$
and summing,
$$
\sum_{i=1}^n I(W; Z_i) \;\le\; \sum_{i=1}^n I(W; Z_i \mid Z_{1:i-1}) \;=\; I(W; S). \tag{iid-pooling}
$$

**Step 5 (main bound + expected KL identification).** Combining Steps 1–4:
$$
\boxed{\;\bigl|\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]\bigr| \;\le\; \sqrt{\frac{2\sigma^2 \, I(W; S)}{n}}.\;}
$$

**Expected-KL interpretation (the Route-C "payoff").** By Lemma 1,
$$
I(W; S) \;=\; \mathbb{E}_S\!\bigl[ D_{\mathrm{KL}}(\mathbb{P}_{W\mid S} \| \mathbb{P}_W) \bigr],
$$
so the main bound can be rewritten as
$$
\bigl|\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]\bigr| \;\le\; \sqrt{\frac{2\sigma^2\,\mathbb{E}_S\!\bigl[ D_{\mathrm{KL}}(\mathbb{P}_{W\mid S}\|\mathbb{P}_W)\bigr]}{n}},
$$
which is exactly the sub-Gaussian **expectation-form PAC-Bayes** statement (posterior = $\mathbb{P}_{W\mid S}$, prior = $\mathbb{P}_W$, bounded $\ell$ replaced by $\sigma$-sub-Gaussian $\ell$). $\blacksquare$

---

## 7. Remark: is this really PAC-Bayes, or Route A/D in disguise?

**Honest assessment.** Route C as executed above is **a re-assembly of Route A/D arithmetic**, not a genuinely new proof.

Two concrete observations:

1. **The MGF input is per-sample.** The decisive analytic step is Lemma 2, which invokes DV + (A1) per sample, bounding $|\mathbb{E}_P[f] - \mathbb{E}_Q[f]| \le \sqrt{2\sigma^2 D_{\mathrm{KL}}(P\|Q)}$ with $P = \mathbb{P}_{W, Z_i}$ and $Q = \mathbb{P}_W \otimes \mathcal{D}$. This is **identical** to the core change-of-measure step in Route A (DV + sub-Gaussian transport), and also to Route D (direct per-sample MI bound of Bu–Zou–Veeravalli).

2. **A genuine PAC-Bayes proof would give a joint MGF.** To truly "PAC-Bayesianize" the argument we would need the joint MGF bound
   $$
   \mathbb{E}_{W, S}\bigl[ e^{\lambda(R_\mathcal{D}(W) - R_S(W))}\bigr] \le e^{\lambda^2 \sigma^2 / (2n)} \tag{JointMGF}
   $$
   (so that DV applied to $P = \mathbb{P}_{W, S}$, $Q = \mathbb{P}_W \otimes \mathbb{P}_S$ with $f = \lambda(R_\mathcal{D}(\cdot) - R_S(\cdot))$ would immediately yield the theorem). Section 3's obstruction (★) shows that (JointMGF) does **not** follow from (A1) alone — we would need the stronger per-$W$ conditional sub-Gaussianity
   $$
   \log \mathbb{E}_{Z \sim \mathcal{D}}\bigl[ e^{\lambda (\ell(w, Z) - R_\mathcal{D}(w))}\bigr] \le \frac{\lambda^2 \sigma^2}{2} \qquad \text{for $\mathbb{P}_W$-a.e. } w,
   $$
   and then Hoeffding-type product MGF would give (JointMGF) with the factor $1/n$. Under that stronger hypothesis Route C would be **genuinely PAC-Bayesian** (one DV step on $\mathbb{P}_{W, S}$ vs $\mathbb{P}_W \otimes \mathbb{P}_S$, no per-sample decomposition).

3. **The iid-pooling identity $\sum_i I(W; Z_i) \le I(W; S)$** (Step 4) is exactly the same closure step used in Route A/D. It is not specific to the PAC-Bayes framing.

**Conclusion.** Under the **theorem's stated assumption** (A1 = *joint* sub-Gaussianity), Route C cannot avoid the per-sample DV decomposition and therefore **collapses to Route A/D**, with the minor cosmetic addition of rewriting the final $I(W; S)$ as $\mathbb{E}_S[D_{\mathrm{KL}}(\mathbb{P}_{W\mid S}\|\mathbb{P}_W)]$ via Lemma 1. Under a **strengthened hypothesis** (per-$w$ conditional sub-Gaussianity of $Z \mapsto \ell(w, Z)$), Route C becomes a genuine one-shot PAC-Bayes proof via DV on the joint with the (JointMGF) bound — but that is outside the scope of Xu–Raginsky (2017) as stated.

The value of the Route-C presentation is therefore **conceptual** (exposing the MI = expected KL identity as a PAC-Bayes lens on the Xu–Raginsky bound), not technical.

---

## Summary of bound chain

$$
\begin{aligned}
\bigl|\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]\bigr|
&\le \frac{1}{n}\sum_{i=1}^n \sqrt{2\sigma^2 I(W; Z_i)} && \text{(Lemma 2, per-sample DV)}\\
&\le \sqrt{\frac{2\sigma^2}{n}\sum_{i=1}^n I(W; Z_i)} && \text{(Lemma 3, Jensen)}\\
&\le \sqrt{\frac{2\sigma^2}{n}\, I(W; S)} && \text{(iid-pooling)}\\
&= \sqrt{\frac{2\sigma^2}{n}\, \mathbb{E}_S[D_{\mathrm{KL}}(\mathbb{P}_{W\mid S}\|\mathbb{P}_W)]} && \text{(Lemma 1, MI = expected KL)}.
\end{aligned}
$$
