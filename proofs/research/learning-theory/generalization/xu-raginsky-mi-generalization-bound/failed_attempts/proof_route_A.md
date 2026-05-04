# Proof of the Xu–Raginsky Mutual Information Generalization Bound

**Route A: Donsker–Varadhan + Sub-Gaussian Transport + KL Chain Rule.**

We prove

$$
\big|\,\mathbb{E}[R_{\mathcal D}(W) - R_S(W)]\,\big|
\;\le\; \sqrt{\frac{2\sigma^{2}\,I(W;S)}{n}} .
$$

---

## 1. Preliminaries

### 1.1 Notation

- $(\mathcal Z,\mathcal F,\mathcal D)$ is the data space with distribution $\mathcal D$.
- $S=(Z_1,\dots,Z_n)$, with $Z_1,\dots,Z_n$ i.i.d. $\sim\mathcal D$, so $\mathbb P_S=\mathcal D^{\otimes n}$.
- $W\in\mathcal W$ is the output of a (possibly randomized) learning algorithm $A:\mathcal Z^n\to\mathcal W$, so the joint law $\mathbb P_{W,S}$ is a Markov kernel from $S$ to $W$ composed with $\mathcal D^{\otimes n}$.
- Marginals: $\mathbb P_W$, $\mathbb P_{Z_i}=\mathcal D$, and joint $\mathbb P_{W,Z_i}$ is the pushforward of $\mathbb P_{W,S}$ onto $(W,Z_i)$.
- $\ell:\mathcal W\times\mathcal Z\to\mathbb R$ is a measurable loss function.
- Population and empirical risks:
 $$R_{\mathcal D}(w):=\mathbb E_{Z\sim\mathcal D}[\ell(w,Z)],\qquad R_S(w):=\tfrac1n\sum_{i=1}^n\ell(w,Z_i).$$

### 1.2 KL divergence and mutual information

For probability measures $P,Q$ on the same measurable space with $P\ll Q$ and Radon–Nikodym derivative $g=\mathrm d P/\mathrm dQ$,
$$
D_{\mathrm{KL}}(P\|Q):=\int\log g\,\mathrm dP=\int g\log g\,\mathrm dQ\in[0,\infty].
$$
If $P\not\ll Q$, we set $D_{\mathrm{KL}}(P\|Q):=+\infty$. With the convention $0\log 0:=0$ this is well defined and nonnegative (Jensen).

For random variables $X,Y$ with joint law $\mathbb P_{X,Y}$ and marginals $\mathbb P_X,\mathbb P_Y$, the mutual information is
$$
I(X;Y):=D_{\mathrm{KL}}\!\big(\mathbb P_{X,Y}\,\|\,\mathbb P_X\otimes\mathbb P_Y\big).
$$
Conditional mutual information is defined via the disintegration: if $\mathbb P_{X,Y\mid Z=z}$ denotes the regular conditional given $Z=z$, then
$$
I(X;Y\mid Z):=\int D_{\mathrm{KL}}\!\big(\mathbb P_{X,Y\mid Z=z}\,\|\,\mathbb P_{X\mid Z=z}\otimes\mathbb P_{Y\mid Z=z}\big)\,\mathbb P_Z(\mathrm dz).
$$
When all entropies are finite, one has the equivalent formula $I(X;Y)=H(X)+H(Y)-H(X,Y)=H(Y)-H(Y\mid X)$. We will only use the KL-based definition.

### 1.3 Sub-Gaussian assumption (A1)

Let $Q:=\mathbb P_W\otimes\mathcal D$ on $\mathcal W\times\mathcal Z$, and $f(w,z):=\ell(w,z)$. We assume $f$ is $\sigma$-sub-Gaussian under $Q$, i.e.
$$
\log\mathbb E_{(W,Z)\sim Q}\!\big[e^{\lambda(f-\mathbb E_Q[f])}\big]\;\le\;\frac{\lambda^{2}\sigma^{2}}{2},\qquad\forall\lambda\in\mathbb R. \tag{A1}
$$
Equivalently, writing $\bar f:=f-\mathbb E_Q f$, the MGF of $\bar f$ under $Q$ is bounded by $e^{\lambda^{2}\sigma^{2}/2}$ for every $\lambda$. Since $W$ and $Z$ are independent under $Q$, this sub-Gaussianity is a joint condition on the product distribution.

---

## 2. Lemma 1 (Donsker–Varadhan variational formula)

**Lemma 1.** *Let $P,Q$ be probability measures on a measurable space $(\Omega,\mathcal F)$. Then*
$$
D_{\mathrm{KL}}(P\|Q)\;=\;\sup_{f\in\mathcal G}\big\{\mathbb E_P[f]-\log\mathbb E_Q[e^{f}]\big\},
$$
*where $\mathcal G:=\{f:\Omega\to\mathbb R\text{ measurable},\ \mathbb E_Q[e^f]<\infty\}$, with the conventions that the supremum is $+\infty$ whenever $P\not\ll Q$ and that $\mathbb E_P[f]-\log\mathbb E_Q[e^f]:=-\infty$ when $\mathbb E_P[f^{-}]=\infty$.*

### Proof of Lemma 1

We prove the two inequalities.

**(i) Upper bound: $\mathbb E_P[f]-\log\mathbb E_Q[e^f]\le D_{\mathrm{KL}}(P\|Q)$ for every $f\in\mathcal G$.**

*Case 1: $P\not\ll Q$.* Then $D_{\mathrm{KL}}(P\|Q)=+\infty$ and the inequality is trivial.

*Case 2: $P\ll Q$.* Let $g=\mathrm dP/\mathrm dQ$ and let $f\in\mathcal G$. Define the *tilted measure* $Q_f$ by
$$
\mathrm dQ_f:=\frac{e^f}{\mathbb E_Q[e^f]}\,\mathrm dQ .
$$
This is a probability measure equivalent to $Q$ on $\{e^f>0\}=\Omega$ (since $e^f>0$). Its Radon–Nikodym derivative with respect to $Q$ is $\mathrm dQ_f/\mathrm dQ=e^f/\mathbb E_Q[e^f]$, so
$$
\log\frac{\mathrm dP}{\mathrm dQ_f}=\log g-f+\log\mathbb E_Q[e^f].
$$
(This identity is $P$-a.s.; on the set where $g=0$, the left side is taken as $-\infty$, but that set has $P$-measure zero.)

Taking the $P$-expectation:
$$
D_{\mathrm{KL}}(P\|Q_f)=\mathbb E_P\!\left[\log\frac{\mathrm dP}{\mathrm dQ_f}\right]
=\mathbb E_P[\log g]-\mathbb E_P[f]+\log\mathbb E_Q[e^f]
=D_{\mathrm{KL}}(P\|Q)-\mathbb E_P[f]+\log\mathbb E_Q[e^f].
$$

(We used $\mathbb E_P[\log g]=D_{\mathrm{KL}}(P\|Q)$; when $\mathbb E_P[f^{-}]=\infty$ the decomposition is unambiguous because the left side is nonnegative, forcing the right side to also be $+\infty$; we tacitly require $\mathbb E_P[f]$ to be well defined for the inequality to be nontrivial.)

Since KL divergence is nonnegative, $D_{\mathrm{KL}}(P\|Q_f)\ge 0$, which rearranges to
$$
\mathbb E_P[f]-\log\mathbb E_Q[e^f]\;\le\;D_{\mathrm{KL}}(P\|Q). \tag{1}
$$
Taking the supremum over $f\in\mathcal G$ gives $\sup_{f\in\mathcal G}\{\mathbb E_P[f]-\log\mathbb E_Q[e^f]\}\le D_{\mathrm{KL}}(P\|Q)$.

**(ii) Lower bound: there is an $f^\star\in\mathcal G$ attaining (or approaching) equality, so that the supremum equals $D_{\mathrm{KL}}(P\|Q)$.**

Assume $P\ll Q$ with $g=\mathrm dP/\mathrm dQ$; the case $P\not\ll Q$ is argued separately below.

*Choice of $f^\star$.* Formally, set $f^\star:=\log g$ on $\{g>0\}$ and $f^\star:=-\infty$ on $\{g=0\}$. Because $f^\star$ may take the value $-\infty$, we truncate: for each $M>0$ define
$$
f_M(\omega):=\max(\log g(\omega),-M)\quad\text{on }\{g>0\},\qquad f_M(\omega):=-M\quad\text{on }\{g=0\}.
$$
Then $f_M$ is bounded below by $-M$ and
$$
\mathbb E_Q[e^{f_M}]=\int_{\{g>0\}}e^{\max(\log g,-M)}\,\mathrm dQ+\int_{\{g=0\}}e^{-M}\,\mathrm dQ
=\int_{\{g>0\}}\max(g,e^{-M})\,\mathrm dQ+e^{-M}Q(\{g=0\}).
$$
Since $g\in L^1(Q)$ ($\int g\,\mathrm dQ=1$) and $\max(g,e^{-M})\le g+e^{-M}$, we get $\mathbb E_Q[e^{f_M}]\le 1+e^{-M}<\infty$, so $f_M\in\mathcal G$.

Moreover, using $\int e^{-M}\,\mathrm dQ=e^{-M}$,
$$
\mathbb E_Q[e^{f_M}]
=\int_{\{g\ge e^{-M}\}}g\,\mathrm dQ+\int_{\{g< e^{-M}\}}e^{-M}\,\mathrm dQ
\le \int g\,\mathrm dQ+e^{-M}=1+e^{-M}.
$$
Thus $\log\mathbb E_Q[e^{f_M}]\le\log(1+e^{-M})\le e^{-M}$ by $\log(1+x)\le x$ for $x\ge 0$.

*Computing $\mathbb E_P[f_M]$.* Since $P\ll Q$, $P(\{g=0\})=\int_{\{g=0\}}g\,\mathrm dQ=0$. Hence
$$
\mathbb E_P[f_M]=\int_{\{g>0\}}\max(\log g,-M)\,\mathrm dP
=\int_{\{g>0\}}\max(\log g,-M)\,g\,\mathrm dQ .
$$
As $M\to\infty$, $\max(\log g,-M)\to\log g$ monotonically from below on $\{g>0\}$, and
$\max(\log g,-M)\cdot g\ge (\log g)\cdot g\wedge 0\ge -e^{-1}$ (since $x\log x\ge -e^{-1}$). By monotone convergence for the positive part and dominated convergence for the negative part (dominated by $e^{-1}\mathbf 1_{\{g>0\}}\in L^1(Q)$),
$$
\lim_{M\to\infty}\mathbb E_P[f_M]=\int_{\{g>0\}}g\log g\,\mathrm dQ=D_{\mathrm{KL}}(P\|Q).
$$
(If $D_{\mathrm{KL}}(P\|Q)=+\infty$, monotone convergence gives $\mathbb E_P[f_M]\to+\infty$.)

*Combining.* Therefore
$$
\liminf_{M\to\infty}\big\{\mathbb E_P[f_M]-\log\mathbb E_Q[e^{f_M}]\big\}\;\ge\;D_{\mathrm{KL}}(P\|Q)-0=D_{\mathrm{KL}}(P\|Q),
$$
so $\sup_{f\in\mathcal G}\{\mathbb E_P[f]-\log\mathbb E_Q[e^f]\}\ge D_{\mathrm{KL}}(P\|Q)$.

*Case $P\not\ll Q$.* Then there exists a measurable $A$ with $P(A)>0$ and $Q(A)=0$. Take $f_N:=N\mathbf 1_A$ for $N>0$: $\mathbb E_Q[e^{f_N}]=e^{N}Q(A)+Q(A^c)=0+1=1$, so $\log\mathbb E_Q[e^{f_N}]=0$, and $\mathbb E_P[f_N]=N\,P(A)\to\infty$. Hence the supremum is $+\infty=D_{\mathrm{KL}}(P\|Q)$.

Combining (i) and (ii) proves the lemma. $\blacksquare$

**Remark.** Inequality (1) alone—*the upper bound of Lemma 1*—is what we will use in the next lemma; the lower direction is included for completeness and to justify calling this a "variational formula."

---

## 3. Lemma 2 (Sub-Gaussian transport)

**Lemma 2.** *Let $P,Q$ be probability measures on $(\Omega,\mathcal F)$ with $P\ll Q$, and let $f:\Omega\to\mathbb R$ be measurable. Suppose $f$ is $\sigma$-sub-Gaussian under $Q$:*
$$
\log\mathbb E_Q\!\big[e^{\lambda(f-\mathbb E_Q f)}\big]\le\frac{\lambda^{2}\sigma^{2}}{2},\qquad\forall\lambda\in\mathbb R. \tag{2}
$$
*Then*
$$
\big|\mathbb E_P[f]-\mathbb E_Q[f]\big|\;\le\;\sqrt{2\sigma^{2}\,D_{\mathrm{KL}}(P\|Q)}.
$$

### Proof of Lemma 2

Sub-Gaussianity (2) implies $\mathbb E_Q f$ is finite (it appears in the definition), and $\mathbb E_Q[e^{\lambda f}]=e^{\lambda \mathbb E_Q f}\mathbb E_Q[e^{\lambda(f-\mathbb E_Q f)}]<\infty$ for every $\lambda\in\mathbb R$. So $\lambda f\in\mathcal G$ of Lemma 1 for every $\lambda$.

Fix $\lambda\ge 0$. Apply the upper bound (1) of Lemma 1 to $\lambda f$:
$$
\mathbb E_P[\lambda f]-\log\mathbb E_Q[e^{\lambda f}]\;\le\;D_{\mathrm{KL}}(P\|Q).
$$
By (2),
$$
\log\mathbb E_Q[e^{\lambda f}]=\lambda\mathbb E_Q f+\log\mathbb E_Q[e^{\lambda(f-\mathbb E_Q f)}]\le \lambda\mathbb E_Q f+\frac{\lambda^{2}\sigma^{2}}{2}.
$$
Substituting,
$$
\lambda\mathbb E_P[f]-\lambda\mathbb E_Q f-\frac{\lambda^{2}\sigma^{2}}{2}\le D_{\mathrm{KL}}(P\|Q),
$$
i.e., for every $\lambda>0$,
$$
\mathbb E_P[f]-\mathbb E_Q[f]\le\frac{D_{\mathrm{KL}}(P\|Q)}{\lambda}+\frac{\lambda\sigma^{2}}{2}. \tag{3}
$$

*Optimization in $\lambda$.* The right-hand side of (3) is a function $\lambda\mapsto a/\lambda+b\lambda$ with $a=D_{\mathrm{KL}}(P\|Q)\ge 0$, $b=\sigma^{2}/2\ge 0$. If $a=0$, the infimum (as $\lambda\to 0^{+}$) is $0$ and we conclude $\mathbb E_P[f]-\mathbb E_Q[f]\le 0$; actually by symmetry with $-f$ below we will obtain equality. If $a>0$ and $b>0$, AM–GM gives $a/\lambda+b\lambda\ge 2\sqrt{ab}$, with equality at $\lambda^\star=\sqrt{a/b}=\sqrt{2D_{\mathrm{KL}}(P\|Q)/\sigma^{2}}>0$. Hence
$$
\mathbb E_P[f]-\mathbb E_Q[f]\;\le\;2\sqrt{ab}\;=\;\sqrt{2\sigma^{2}\,D_{\mathrm{KL}}(P\|Q)}. \tag{4}
$$
(If $\sigma=0$, (2) forces $f$ to be $Q$-a.s. equal to $\mathbb E_Q f$, hence $P$-a.s. the same (since $P\ll Q$), so both sides are $0$.)

*Lower bound on $\mathbb E_P f-\mathbb E_Q f$.* Apply the argument to $-f$, which is also $\sigma$-sub-Gaussian under $Q$ (replace $\lambda$ by $-\lambda$ in (2)). This gives
$$
\mathbb E_P[-f]-\mathbb E_Q[-f]\le\sqrt{2\sigma^{2}D_{\mathrm{KL}}(P\|Q)},
$$
i.e., $-(\mathbb E_P f-\mathbb E_Q f)\le\sqrt{2\sigma^{2}D_{\mathrm{KL}}(P\|Q)}$, so
$$
\mathbb E_Q[f]-\mathbb E_P[f]\;\le\;\sqrt{2\sigma^{2}D_{\mathrm{KL}}(P\|Q)}. \tag{5}
$$
Combining (4) and (5) yields $|\mathbb E_P f-\mathbb E_Q f|\le\sqrt{2\sigma^{2}D_{\mathrm{KL}}(P\|Q)}$. $\blacksquare$

---

## 4. Lemma 3 (Chain rule $\Rightarrow\sum_i I(W;Z_i)\le I(W;S)$ for i.i.d. $Z_i$)

**Lemma 3.** *Let $S=(Z_1,\dots,Z_n)$ with $Z_1,\dots,Z_n$ independent, and let $W$ be a random variable jointly distributed with $S$. Then*
$$
\sum_{i=1}^n I(W;Z_i)\;\le\;I(W;S).
$$

We give two proofs: the first purely via the KL definition (works with no finiteness assumption on entropies); the second via Shannon entropies, which is shorter but assumes the discrete/finite-entropy setting. The main argument uses the first.

### 4.1 Proof via the KL definition (general case)

By the **chain rule of KL divergence**: for any two joint distributions $\mu(\mathrm dx,\mathrm dy)=\mu_X(\mathrm dx)\mu_{Y\mid X}(\mathrm dy\mid x)$ and $\nu(\mathrm dx,\mathrm dy)=\nu_X(\mathrm dx)\nu_{Y\mid X}(\mathrm dy\mid x)$ with $\mu\ll\nu$,
$$
D_{\mathrm{KL}}(\mu\|\nu)=D_{\mathrm{KL}}(\mu_X\|\nu_X)+\int D_{\mathrm{KL}}(\mu_{Y\mid X=x}\|\nu_{Y\mid X=x})\,\mu_X(\mathrm dx). \tag{6}
$$
(This is a direct calculation from $\log(\mathrm d\mu/\mathrm d\nu)=\log(\mathrm d\mu_X/\mathrm d\nu_X)+\log(\mathrm d\mu_{Y\mid X}/\mathrm d\nu_{Y\mid X})$ and Fubini.)

Apply (6) iteratively to $\mathbb P_{W,S}$ versus $\mathbb P_W\otimes\mathbb P_S$, with $S=(Z_1,\dots,Z_n)$ decomposed step by step. Set $Z_{1:k}:=(Z_1,\dots,Z_k)$, $Z_{1:0}:=\emptyset$.

Under the **joint** $\mathbb P_{W,S}$, conditioning on $Z_{1:i-1}$ and $W$ gives the conditional law of $Z_i$; under the **product** $\mathbb P_W\otimes\mathbb P_S$, $W\perp S$ and the $Z_i$'s have their $\mathbb P_S$-marginal (which equals $\mathcal D^{\otimes n}$, with $Z_i$'s independent). Applying (6) to the decomposition
$$
(W,S)=(W,Z_1,Z_2,\dots,Z_n)
$$
split as $(W,Z_{1:i-1})$ vs. $Z_i$, we get by induction on $i$:

$$
I(W;S)=D_{\mathrm{KL}}(\mathbb P_{W,S}\|\mathbb P_W\otimes\mathbb P_S)=\sum_{i=1}^n I(W;Z_i\mid Z_{1:i-1}), \tag{7}
$$

where the **conditional mutual information** is defined as
$$
I(W;Z_i\mid Z_{1:i-1})
:=\int D_{\mathrm{KL}}\!\big(\mathbb P_{W,Z_i\mid Z_{1:i-1}=z}\,\|\,\mathbb P_{W\mid Z_{1:i-1}=z}\otimes\mathbb P_{Z_i\mid Z_{1:i-1}=z}\big)\,\mathbb P_{Z_{1:i-1}}(\mathrm dz).
$$

*Detailed derivation of (7).* We do the case $n=2$ in detail; the general case is the same induction. With $\mu=\mathbb P_{W,Z_1,Z_2}$ and $\nu=\mathbb P_W\otimes\mathbb P_{Z_1,Z_2}=\mathbb P_W\otimes\mathbb P_{Z_1}\otimes\mathbb P_{Z_2}$ (using $Z_1\perp Z_2$),
$$
\frac{\mathrm d\mu}{\mathrm d\nu}(w,z_1,z_2)
=\frac{\mathrm d\mathbb P_{W,Z_1}}{\mathrm d(\mathbb P_W\otimes\mathbb P_{Z_1})}(w,z_1)\cdot\frac{\mathrm d\mathbb P_{W,Z_2\mid Z_1=z_1}}{\mathrm d(\mathbb P_{W\mid Z_1=z_1}\otimes\mathbb P_{Z_2})}(w,z_2),
$$
using $\mathbb P_{Z_2\mid Z_1}=\mathbb P_{Z_2}$ by independence. Taking logs and integrating under $\mu$:
$$
I(W;Z_1,Z_2)=I(W;Z_1)+I(W;Z_2\mid Z_1).
$$
Iterating,
$$
I(W;S)=\sum_{i=1}^n I(W;Z_i\mid Z_{1:i-1}).
$$

*Key step: each conditional term is $\ge I(W;Z_i)$ when $Z_i\perp Z_{1:i-1}$.* Since $Z_1,\dots,Z_n$ are independent, $\mathbb P_{Z_i\mid Z_{1:i-1}=z}=\mathbb P_{Z_i}=\mathcal D$ for $\mathbb P_{Z_{1:i-1}}$-a.e. $z$. Hence
$$
I(W;Z_i\mid Z_{1:i-1})
=\int D_{\mathrm{KL}}\!\big(\mathbb P_{W,Z_i\mid Z_{1:i-1}=z}\,\|\,\mathbb P_{W\mid Z_{1:i-1}=z}\otimes\mathcal D\big)\,\mathbb P_{Z_{1:i-1}}(\mathrm dz). \tag{8}
$$

We now show
$$
I(W;Z_i\mid Z_{1:i-1})\;\ge\; I(W;Z_i). \tag{9}
$$

*Proof of (9).* Let $Y:=Z_i$ and $X:=Z_{1:i-1}$ for brevity. Both $\mathbb P_{W,Y}$ and $\mathbb P_W\otimes\mathbb P_Y$ can be obtained from the joint $\mathbb P_{X,W,Y}$ by marginalizing over $X$. We use the following general fact.

**Fact (convexity/marginalization of KL).** *For probability measures $\mu,\nu$ on $\mathcal X\times\mathcal Y$ with marginals $\mu_Y,\nu_Y$ on $\mathcal Y$,*
$$
D_{\mathrm{KL}}(\mu_Y\|\nu_Y)\le D_{\mathrm{KL}}(\mu\|\nu).
$$

*Proof of Fact.* This is the data processing inequality for the "drop $X$" deterministic channel; or directly from Jensen. Let $\pi:\mathcal X\times\mathcal Y\to\mathcal Y$ be the projection. If $\mu\ll\nu$ with $g=\mathrm d\mu/\mathrm d\nu$, then $\mathrm d\mu_Y/\mathrm d\nu_Y(y)=\mathbb E_{\nu}[g\mid Y=y]$. By Jensen's inequality applied to $\phi(t)=t\log t$ (which is convex) and the conditional expectation,
$$
\phi\big(\mathbb E_\nu[g\mid Y]\big)\le \mathbb E_\nu[\phi(g)\mid Y].
$$
Taking $\nu_Y$-expectations,
$$
D_{\mathrm{KL}}(\mu_Y\|\nu_Y)=\mathbb E_{\nu_Y}[\phi(\mathrm d\mu_Y/\mathrm d\nu_Y)]\le \mathbb E_\nu[\phi(g)]=D_{\mathrm{KL}}(\mu\|\nu). \quad\square$$

Now apply the Fact with
$$
\mu=\mathbb P_{X,W,Y}=\mathbb P_{X,W,Z_i},\qquad \nu=\mathbb P_X\otimes\mathbb P_W\otimes\mathbb P_{Y}=\mathbb P_{Z_{1:i-1}}\otimes\mathbb P_W\otimes\mathcal D,
$$
and "drop $X$," i.e. project onto $(W,Y)$:
$$
\mu_{W,Y}=\mathbb P_{W,Z_i},\qquad \nu_{W,Y}=\mathbb P_W\otimes\mathcal D .
$$
Then $D_{\mathrm{KL}}(\mu_{W,Y}\|\nu_{W,Y})=I(W;Z_i)$. We compute $D_{\mathrm{KL}}(\mu\|\nu)$:

Using the chain rule (6) with the split "condition on $X$":
$$
D_{\mathrm{KL}}(\mu\|\nu)
=D_{\mathrm{KL}}(\mu_X\|\nu_X)+\int D_{\mathrm{KL}}\!\big(\mu_{W,Y\mid X=x}\,\|\,\nu_{W,Y\mid X=x}\big)\,\mu_X(\mathrm dx).
$$
Under our choice, $\mu_X=\mathbb P_{Z_{1:i-1}}=\nu_X$, so $D_{\mathrm{KL}}(\mu_X\|\nu_X)=0$. For $\mu_X$-a.e. $x$,
$$
\mu_{W,Y\mid X=x}=\mathbb P_{W,Z_i\mid Z_{1:i-1}=x},\qquad
\nu_{W,Y\mid X=x}=\mathbb P_W\otimes\mathcal D
$$
(because under the product $\nu$, $W$ and $Y$ are independent of $X$ and have marginals $\mathbb P_W$ and $\mathcal D$).

**A small adjustment.** We need $\nu_{W,Y\mid X=x}=\mathbb P_{W\mid Z_{1:i-1}=x}\otimes\mathcal D$ in order to recognize the integrand as the conditional mutual information from (8). But our chosen $\nu$ has $W\perp X$, so $\mathbb P_{W\mid Z_{1:i-1}=x}$ under $\nu$ equals $\mathbb P_W$. To match (8) exactly, change $\nu$ to
$$
\tilde\nu:=\mathbb P_{Z_{1:i-1},W}\otimes\mathcal D,
$$
the joint of $(Z_{1:i-1},W)$ tensored with an independent copy of $Z_i\sim\mathcal D$. Then (i) $\tilde\nu_{W,Y}=\mathbb P_W\otimes\mathcal D$ still, (ii) $\tilde\nu_X=\mathbb P_{Z_{1:i-1}}$, (iii) $\tilde\nu_{W,Y\mid X=x}=\mathbb P_{W\mid Z_{1:i-1}=x}\otimes\mathcal D$ for $\mathbb P_{Z_{1:i-1}}$-a.e. $x$.

Then the chain rule gives
$$
D_{\mathrm{KL}}(\mu\|\tilde\nu)=0+\int D_{\mathrm{KL}}\!\big(\mathbb P_{W,Z_i\mid Z_{1:i-1}=x}\,\|\,\mathbb P_{W\mid Z_{1:i-1}=x}\otimes\mathcal D\big)\,\mathbb P_{Z_{1:i-1}}(\mathrm dx)
\stackrel{(8)}{=} I(W;Z_i\mid Z_{1:i-1}),
$$
and the Fact applied to $\mu$ vs. $\tilde\nu$ under the projection $(X,W,Y)\mapsto(W,Y)$ yields
$$
I(W;Z_i)=D_{\mathrm{KL}}(\mu_{W,Y}\|\tilde\nu_{W,Y})\le D_{\mathrm{KL}}(\mu\|\tilde\nu)=I(W;Z_i\mid Z_{1:i-1}),
$$
which is (9). $\square$

*Summation.* By (7) and (9),
$$
I(W;S)=\sum_{i=1}^n I(W;Z_i\mid Z_{1:i-1})\ge\sum_{i=1}^n I(W;Z_i). \tag{10}
$$
$\blacksquare$

### 4.2 Alternative: entropy proof (discrete/finite-entropy case)

Assume all entropies below are finite and standard Shannon identities apply. Since $Z_1,\dots,Z_n$ are independent, $H(S)=\sum_{i=1}^n H(Z_i)$. Also
$$
H(S\mid W)=\sum_{i=1}^n H(Z_i\mid Z_{1:i-1},W)\le\sum_{i=1}^n H(Z_i\mid W),
$$
the inequality being "conditioning reduces entropy." Therefore
$$
I(W;S)=H(S)-H(S\mid W)\ge\sum_{i=1}^n\!\big(H(Z_i)-H(Z_i\mid W)\big)=\sum_{i=1}^n I(W;Z_i).
$$

---

## 5. Main Argument

### 5.1 Decomposition of the expected gap

Write $\mathbb E$ for expectation under the joint $\mathbb P_{W,S}$. By linearity,
$$
\mathbb E[R_S(W)]=\frac1n\sum_{i=1}^n\mathbb E_{(W,Z_i)\sim\mathbb P_{W,Z_i}}[\ell(W,Z_i)].
$$
For the population risk: let $Z'\sim\mathcal D$ be independent of $W$. Since $W$ is a function of $S$ and its law is $\mathbb P_W$, we have
$$
\mathbb E[R_{\mathcal D}(W)]=\mathbb E_W\!\big[\mathbb E_{Z'\sim\mathcal D}[\ell(W,Z')]\big]=\mathbb E_{(W,Z')\sim\mathbb P_W\otimes\mathcal D}[\ell(W,Z')].
$$
This is the same quantity for every $i$, so
$$
\mathbb E[R_{\mathcal D}(W)]=\frac1n\sum_{i=1}^n \mathbb E_{(W,Z')\sim\mathbb P_W\otimes\mathcal D}[\ell(W,Z')].
$$
Subtracting,
$$
\mathbb E[R_{\mathcal D}(W)-R_S(W)]
=\frac1n\sum_{i=1}^n\!\Big(\mathbb E_{\mathbb P_W\otimes\mathcal D}[\ell]-\mathbb E_{\mathbb P_{W,Z_i}}[\ell]\Big). \tag{11}
$$

### 5.2 Per-sample sub-Gaussian transport bound

Fix $i\in\{1,\dots,n\}$. Set
$$
P_i:=\mathbb P_{W,Z_i},\qquad Q:=\mathbb P_W\otimes\mathcal D,\qquad f(w,z):=\ell(w,z).
$$

We check $P_i\ll Q$. By construction, the $W$-marginal of $P_i$ is $\mathbb P_W$, which is the $W$-marginal of $Q$. The $Z$-marginal of $P_i$ is $\mathbb P_{Z_i}=\mathcal D$ (because $Z_i\sim\mathcal D$ marginally), which is the $Z$-marginal of $Q$. If $P_i$ is not absolutely continuous w.r.t. $Q$, then $I(W;Z_i)=D_{\mathrm{KL}}(P_i\|Q)=+\infty$ and the bound (12) below is trivial. Assume $P_i\ll Q$.

By assumption (A1), $f$ is $\sigma$-sub-Gaussian under $Q$. Apply Lemma 2:
$$
\big|\mathbb E_{P_i}[\ell]-\mathbb E_{Q}[\ell]\big|\;\le\;\sqrt{2\sigma^{2}\,D_{\mathrm{KL}}(P_i\|Q)}\;=\;\sqrt{2\sigma^{2}\,I(W;Z_i)}. \tag{12}
$$

### 5.3 Triangle inequality and concavity of square root

By (11) and the triangle inequality,
$$
\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|\;\le\;\frac1n\sum_{i=1}^n\big|\mathbb E_{Q}[\ell]-\mathbb E_{P_i}[\ell]\big|\;\stackrel{(12)}{\le}\;\frac1n\sum_{i=1}^n\sqrt{2\sigma^{2}\,I(W;Z_i)}. \tag{13}
$$

The function $t\mapsto\sqrt t$ is concave on $[0,\infty)$. Jensen's inequality (for the uniform average) yields
$$
\frac1n\sum_{i=1}^n\sqrt{a_i}\;\le\;\sqrt{\frac1n\sum_{i=1}^n a_i},\qquad a_i\ge 0. \tag{14}
$$
Applying (14) with $a_i:=2\sigma^{2}I(W;Z_i)\ge 0$ to (13):
$$
\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|\;\le\;\sqrt{\frac1n\sum_{i=1}^n 2\sigma^{2}I(W;Z_i)}\;=\;\sqrt{\frac{2\sigma^{2}}{n}\sum_{i=1}^n I(W;Z_i)}. \tag{15}
$$

### 5.4 Chain-rule step

By Lemma 3 (with $Z_1,\dots,Z_n$ i.i.d., hence independent),
$$
\sum_{i=1}^n I(W;Z_i)\;\le\;I(W;S).
$$
Plugging into (15) and using monotonicity of $\sqrt\cdot$:
$$
\big|\mathbb E[R_{\mathcal D}(W)-R_S(W)]\big|\;\le\;\sqrt{\frac{2\sigma^{2}\,I(W;S)}{n}}.
$$

---

## 6. Conclusion

$$
\boxed{\;\big|\,\mathbb E[R_{\mathcal D}(W)-R_S(W)]\,\big|\;\le\;\sqrt{\dfrac{2\sigma^{2}\,I(W;S)}{n}}\;}
$$

This is the Xu–Raginsky (2017, NeurIPS) information-theoretic generalization bound. The two nontrivial ingredients are (a) the Donsker–Varadhan upper bound (Lemma 1, (1)) applied with $\lambda\ell$ to convert KL into an MGF-style inequality (Lemma 2), and (b) the independence-plus-chain-rule step (Lemma 3) that aggregates per-sample KL into the global mutual information $I(W;S)$. The $1/n$ rate inside the square root reflects the averaging across samples combined with the concavity of the square root. $\blacksquare$

---

## Appendix: verification of edge cases

1. **$I(W;S)=\infty$.** Both sides are $+\infty$ or the left is finite and the right is $+\infty$; the inequality holds.
2. **$I(W;S)=0$.** Then $W\perp S$, so all $P_i=Q$, giving $\mathbb E[R_{\mathcal D}(W)]=\mathbb E[R_S(W)]$ (left side zero), consistent with the bound.
3. **$\sigma=0$.** Loss is $Q$-a.s. constant $c$; by absolute continuity also $P_i$-a.s. equal to $c$ when $P_i\ll Q$, so both risks equal $c$.
4. **Non-dominated case $P_i\not\ll Q$.** $I(W;Z_i)=+\infty$, so (12) is vacuous, but summing is still dominated by $I(W;S)\ge\sum_i I(W;Z_i)=+\infty$; bound trivially holds. (If $I(W;S)=\infty$ from some $i$ but the true gap is finite, the bound is loose but valid.)
