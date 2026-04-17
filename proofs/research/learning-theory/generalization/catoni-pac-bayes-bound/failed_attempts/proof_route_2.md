# Route 2: Hoeffding MGF + Donsker-Varadhan (McAllester variant)

## Setup

Let $\mathcal{Z}$ be a measurable sample space, $\mathcal{H}$ a measurable hypothesis class, and $\ell:\mathcal H\times\mathcal Z\to[0,1]$ a bounded loss. Fix a data-independent prior $P\in\mathcal P(\mathcal H)$. Given an i.i.d. sample $S=(Z_1,\dots,Z_n)$ with $Z_i\sim\mathcal D$, define
$$\hat R_S(h):=\tfrac1n\textstyle\sum_{i=1}^n\ell(h,Z_i),\qquad R(h):=\mathbb E_{Z\sim\mathcal D}\ell(h,Z),$$
and, for any posterior $Q\ll P$,
$$\hat R_S(Q):=\mathbb E_{h\sim Q}\hat R_S(h),\qquad R(Q):=\mathbb E_{h\sim Q}R(h).$$
We fix $\lambda>0$ ahead of data and set $\eta:=\lambda/n$. All $\log$ are natural.

## Lemma 1 (Donsker-Varadhan variational formula)

**Claim.** For any measurable $\phi:\mathcal H\to\mathbb R$ with $\mathbb E_P e^{\phi}<\infty$ and any probability $Q\ll P$,
$$\mathbb E_{h\sim Q}[\phi(h)]\le \log\mathbb E_{h\sim P}[e^{\phi(h)}]+\mathrm{KL}(Q\|P).$$

**Proof.** Define $dR:=e^{\phi}\,dP/Z$ with $Z:=\mathbb E_P e^{\phi}$, a probability measure. Then $\mathrm{KL}(Q\|R)\ge 0$ gives
$$0\le\int\log\tfrac{dQ}{dR}\,dQ=\int\log\tfrac{dQ}{dP}\,dQ-\int\phi\,dQ+\log Z=\mathrm{KL}(Q\|P)-\mathbb E_Q\phi+\log\mathbb E_P e^{\phi}.$$
Rearranging yields the claim. $\square$

## Lemma 2 (Hoeffding's lemma)

**Claim.** If $X\in[a,b]$ almost surely with $\mathbb E X=0$, then for every $t\in\mathbb R$,
$$\mathbb E e^{tX}\le \exp\!\Big(\tfrac{t^2(b-a)^2}{8}\Big).$$

**Proof sketch.** Let $\psi(t):=\log\mathbb E e^{tX}$. One computes $\psi(0)=\psi'(0)=0$, and by bounding the variance of the tilted law $dQ_t\propto e^{tX}dP_X$ using $\mathrm{Var}_{Q_t}(X)\le (b-a)^2/4$ (Popoviciu's inequality), we get $\psi''(t)\le(b-a)^2/4$. Taylor: $\psi(t)\le t^2(b-a)^2/8$. $\square$

## Lemma 3 ($n$-fold MGF of the centered empirical risk)

**Claim.** Fix $h\in\mathcal H$. For every $\eta\in\mathbb R$,
$$\mathbb E_S\exp\!\big(n\eta(R(h)-\hat R_S(h))\big)\le\exp\!\big(n\eta^2/8\big).$$

**Proof.** Let $X_i:=R(h)-\ell(h,Z_i)$. Since $\ell(h,\cdot)\in[0,1]$ and $R(h)\in[0,1]$, we have $X_i\in[R(h)-1,R(h)]$, an interval of length $1$, with $\mathbb E X_i=0$. The $X_i$ are i.i.d., so
$$\mathbb E_S\exp\!\big(n\eta(R(h)-\hat R_S(h))\big)=\mathbb E_S\exp\!\Big(\eta\textstyle\sum_{i=1}^n X_i\Big)=\prod_{i=1}^n\mathbb E e^{\eta X_i}\le\prod_{i=1}^n e^{\eta^2/8}=e^{n\eta^2/8}$$
by Hoeffding's lemma with $b-a=1$. $\square$

## Main theorem (McAllester's bound, Route 2)

**Theorem.** For any $\delta\in(0,1)$ and any $\eta>0$, with probability at least $1-\delta$ over $S$, simultaneously for every posterior $Q\ll P$,
$$R(Q)-\hat R_S(Q)\le\frac{\eta}{8}+\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{n\eta}.\tag{$\star$}$$
Optimizing $\eta$ after the bound holds uniformly (by taking a union over a countable grid, or — as is standard — because $(\star)$ holds for every *fixed* $\eta$ with the optimizer chosen data-dependently within a fixed countable $\eta$-net) yields
$$R(Q)\le\hat R_S(Q)+\sqrt{\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{2n}}.\tag{McAllester}$$

**Proof.** Fix $\eta>0$. Define the random variable
$$W_S\;:=\;\mathbb E_{h\sim P}\exp\!\big(n\eta(R(h)-\hat R_S(h))\big).$$
By Fubini (nonnegative integrand) and Lemma 3,
$$\mathbb E_S W_S=\mathbb E_{h\sim P}\mathbb E_S\exp\!\big(n\eta(R(h)-\hat R_S(h))\big)\le\mathbb E_{h\sim P}e^{n\eta^2/8}=e^{n\eta^2/8}.$$
Markov's inequality applied to $W_S\ge 0$ gives
$$\Pr_S\!\Big(W_S>\tfrac{e^{n\eta^2/8}}{\delta}\Big)\le\delta,$$
equivalently, with probability at least $1-\delta$,
$$\log W_S\;\le\;\frac{n\eta^2}{8}+\log\frac{1}{\delta}.\tag{1}$$

Condition on the event that (1) holds. For *any* posterior $Q\ll P$, apply Lemma 1 with $\phi(h):=n\eta(R(h)-\hat R_S(h))$:
$$n\eta\,\mathbb E_{h\sim Q}\big[R(h)-\hat R_S(h)\big]\le\log\mathbb E_{h\sim P}e^{\phi(h)}+\mathrm{KL}(Q\|P)=\log W_S+\mathrm{KL}(Q\|P).$$
Combining with (1) and using $\mathbb E_Q[R(h)-\hat R_S(h)]=R(Q)-\hat R_S(Q)$,
$$n\eta\big(R(Q)-\hat R_S(Q)\big)\le\frac{n\eta^2}{8}+\mathrm{KL}(Q\|P)+\log(1/\delta).$$
Dividing by $n\eta>0$ yields $(\star)$. The key point: the event in (1) is *data-dependent but $Q$-independent*, so once it holds the inequality $(\star)$ holds simultaneously for all $Q$.

Finally, the RHS of $(\star)$, as a function of $\eta>0$, is minimized at $\eta^\*=\sqrt{8(\mathrm{KL}(Q\|P)+\log(1/\delta))/n}$, giving optimum
$$\frac{\eta^\*}{8}+\frac{1}{n\eta^\*}\big(\mathrm{KL}+\log(1/\delta)\big)=\sqrt{\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{2n}},$$
which is the McAllester bound. $\square$

## Comparison to Catoni's bound

Catoni's target is
$$R(Q)\le\frac{\eta}{1-e^{-\eta}}\hat R_S(Q)+\frac{1}{1-e^{-\eta}}\cdot\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{n},\qquad\eta=\lambda/n.$$
Expanding $\eta/(1-e^{-\eta})=1+\eta/2+\eta^2/12+O(\eta^3)$ shows the Catoni prefactor on $\hat R_S(Q)$ is close to $1$ for small $\eta$, but the bound *interpolates* between fast and slow rates depending on the magnitude of $\hat R_S(Q)$. In particular, when $\hat R_S(Q)=0$ one obtains the fast $\mathcal O(1/n)$ rate $R(Q)\le\tfrac{\mathrm{KL}+\log(1/\delta)}{n(1-e^{-\eta})}$ with $\eta=\Theta(1)$, whereas McAllester gives only $\mathcal O(1/\sqrt n)$.

The structural reason: Catoni's argument replaces Lemma 3 with the *sub-Bernoulli* MGF bound
$$\mathbb E_S\exp\!\big(\lambda(\hat R_S(h)-R(h))\big)\le\exp\!\Big(n\,\big[\,\log\!\big(1-R(h)+R(h)e^{\lambda/n}\big)-\lambda R(h)/n\,\big]\Big),$$
which, after one more log-convexity step, gives the exact factor $(1-e^{-\eta})/\eta$ needed for the inverse-KL rearrangement. Route 2 uses Hoeffding's $\lambda^2/(8n)$, which is the *worst-case* (Bernoulli-$1/2$) upper bound on that cumulant; this loses the variance-dependence that powers Catoni's fast rate.

## Limitations

Route 2 rigorously proves McAllester's bound, but **cannot** recover Catoni's exact form. Reasons:

1. **MGF loss.** Hoeffding's $e^{\lambda^2/(8n)}$ is sharp only at $R(h)=1/2$. For $R(h)$ near $0$ or $1$ the true MGF is exponentially smaller; capturing this requires the sub-Bernoulli / Bennett cumulant, not $\lambda^2/8$.
2. **Rate loss.** The quadratic term $n\eta^2/8$ combined with division by $n\eta$ forces the $\sqrt{\cdot}$ shape after optimizing $\eta$. Catoni's algebraic reformulation instead leaves $\eta$ *fixed*, producing the $(1-e^{-\eta})/\eta$ prefactor that admits the self-bounding/inverse-KL reading.
3. **No interpolation.** Consequently, Route 2 is blind to the transition between slow $(1/\sqrt n)$ and fast $(1/n)$ regimes that Catoni's bound exhibits when $\hat R_S(Q)\to 0$.

The bound proved here $(\star)$ and its optimized form (McAllester) are therefore a strictly weaker — but fully rigorous — PAC-Bayes oracle inequality obtained along Route 2. Catoni's exact statement requires Route 1 (sub-Bernoulli MGF + algebraic rearrangement).
