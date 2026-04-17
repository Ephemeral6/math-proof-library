# Route 3: Fubini-First + Direct Change-of-Measure

We prove Catoni's PAC-Bayes bound by constructing a scalar random variable $W_S$ (defined as an integral over the prior $P$), controlling its expectation via Fubini, applying Markov's inequality, and only afterwards invoking the Donsker–Varadhan (DV) variational formula to pull the bound inside $Q$.

## Setup

Let $P$ be a data-independent prior on $\mathcal H$, let $S=(Z_1,\dots,Z_n)$ be i.i.d.~$\mathcal D$, and let $\ell(h,\cdot)\in[0,1]$. Write
$$R(h):=\mathbb E_{Z\sim\mathcal D}\ell(h,Z),\qquad \hat R_S(h):=\frac1n\sum_{i=1}^n\ell(h,Z_i).$$
For posterior $Q\ll P$, define $R(Q):=\mathbb E_{h\sim Q}R(h)$ and $\hat R_S(Q):=\mathbb E_{h\sim Q}\hat R_S(h)$ (Fubini/linearity of expectation, applicable since $R,\hat R_S\in[0,1]$ are bounded and measurable).

Fix $\lambda>0$ and define the **sub-Bernoulli cumulant**
$$\psi(u):=u-1+e^{-u},\qquad u\ge 0.$$
Note $\psi(0)=0$ and $\psi'(u)=1-e^{-u}\ge 0$, so $\psi(u)\ge 0$.

## Lemma 1 (Sub-Bernoulli MGF via convexity)

*Claim.* For each fixed $h$ and every $u>0$,
$$\mathbb E_{Z\sim\mathcal D}\bigl[e^{-u\,\ell(h,Z)}\bigr]\le 1-R(h)\bigl(1-e^{-u}\bigr).$$

*Proof.* The map $x\mapsto e^{-ux}$ is convex on $\mathbb R$. On the interval $[0,1]$, convexity gives the chord bound
$$e^{-ux}\le (1-x)\cdot e^{0}+x\cdot e^{-u}=1-x(1-e^{-u}),\qquad x\in[0,1].$$
Since $\ell(h,Z)\in[0,1]$ a.s., apply this pointwise with $x=\ell(h,Z)$ and take expectation:
$$\mathbb E\bigl[e^{-u\ell(h,Z)}\bigr]\le 1-\mathbb E[\ell(h,Z)](1-e^{-u})=1-R(h)(1-e^{-u}).\qquad\square$$

**Sub-lemma: $\log(1-x)\le -x$ for $x\in[0,1)$.** Define $f(x)=\log(1-x)+x$. Then $f(0)=0$ and $f'(x)=-\tfrac{1}{1-x}+1=\tfrac{-x}{1-x}\le 0$ for $x\in[0,1)$. Hence $f$ is non-increasing on $[0,1)$ with $f(0)=0$, giving $f(x)\le 0$, i.e., $\log(1-x)\le -x$.

Applying this sub-lemma with $x=R(h)(1-e^{-u})\in[0,1)$ (since $R(h)\in[0,1]$ and $1-e^{-u}\in[0,1)$ for $u>0$; when $R(h)=0$ or $u=0$ the bound is trivial):
$$\log\mathbb E\bigl[e^{-u\ell(h,Z)}\bigr]\le -R(h)(1-e^{-u}).\tag{1}$$

**$n$-fold tensorization.** Since $Z_1,\dots,Z_n$ are i.i.d., for each $h$ and $u=\lambda/n$,
$$\mathbb E_S\exp\!\Bigl(-\tfrac{\lambda}{n}\sum_{i=1}^n\ell(h,Z_i)\Bigr)=\prod_{i=1}^n\mathbb E\bigl[e^{-(\lambda/n)\ell(h,Z_i)}\bigr]\le \exp\!\bigl(-nR(h)(1-e^{-\lambda/n})\bigr),$$
using (1) in each factor. Multiplying out, since $\tfrac{\lambda}{n}\sum_i\ell(h,Z_i)=\lambda\hat R_S(h)$,
$$\mathbb E_S\exp\!\bigl(-\lambda\hat R_S(h)\bigr)\le \exp\!\bigl(-nR(h)(1-e^{-\lambda/n})\bigr).\tag{2}$$

## Lemma 2 (Change-of-measure functional)

Define the integrand
$$\phi_S(h):=\lambda\bigl(R(h)-\hat R_S(h)\bigr)-nR(h)\psi(\lambda/n),$$
and the scalar-valued (in $S$) random variable
$$W_S:=\mathbb E_{h\sim P}\,e^{\phi_S(h)}.$$

*Claim.* For every fixed $h$,
$$\mathbb E_S\bigl[e^{\phi_S(h)}\bigr]\le 1.$$

*Proof.* The factor $e^{\lambda R(h)-nR(h)\psi(\lambda/n)}$ is non-random ($R(h)$ does not depend on $S$), so
$$\mathbb E_S e^{\phi_S(h)}=e^{\lambda R(h)-nR(h)\psi(\lambda/n)}\cdot\mathbb E_S e^{-\lambda\hat R_S(h)}.$$
By (2), this is bounded by $\exp\!\bigl(E(h)\bigr)$ where
$$E(h):=\lambda R(h)-nR(h)\psi(\lambda/n)-nR(h)(1-e^{-\lambda/n}).$$
Factor $R(h)$:
$$E(h)=R(h)\Bigl[\lambda-n\psi(\lambda/n)-n(1-e^{-\lambda/n})\Bigr].$$
Expand $n\psi(\lambda/n)=n(\lambda/n-1+e^{-\lambda/n})=\lambda-n+ne^{-\lambda/n}$:
$$\lambda-n\psi(\lambda/n)=\lambda-\lambda+n-ne^{-\lambda/n}=n(1-e^{-\lambda/n}).$$
Therefore
$$E(h)=R(h)\bigl[n(1-e^{-\lambda/n})-n(1-e^{-\lambda/n})\bigr]=0.$$
Hence $\mathbb E_S e^{\phi_S(h)}\le e^0=1$. $\square$

## Lemma 3 (Fubini + Markov)

*Fubini step.* Since $e^{\phi_S(h)}\ge 0$ is jointly measurable in $(S,h)$, Tonelli's theorem permits swapping expectations:
$$\mathbb E_S[W_S]=\mathbb E_S\mathbb E_{h\sim P}e^{\phi_S(h)}=\mathbb E_{h\sim P}\mathbb E_S e^{\phi_S(h)}\le \mathbb E_{h\sim P}[1]=1.\tag{3}$$

*Markov step.* $W_S\ge 0$, so for any $\delta\in(0,1)$,
$$\mathbb P_S(W_S>1/\delta)\le \delta\,\mathbb E_S[W_S]\le \delta.$$
Thus, with probability at least $1-\delta$ over $S$,
$$W_S\le 1/\delta,\qquad\text{i.e.,}\qquad \log W_S\le \log(1/\delta).\tag{4}$$

## Lemma 4 (Donsker–Varadhan variational formula)

*Claim.* For any probability $Q\ll P$ and any measurable $\phi:\mathcal H\to\mathbb R$ with $\mathbb E_P e^{\phi}<\infty$,
$$\mathbb E_Q[\phi]\le \log\mathbb E_P[e^\phi]+\mathrm{KL}(Q\Vert P).$$

*Proof.* Define the probability measure $dP_\phi:=e^\phi/\mathbb E_P[e^\phi]\,dP$ (a genuine probability since $e^\phi/\mathbb E_P e^\phi$ is non-negative and integrates to $1$ under $P$). Since $Q\ll P\ll P_\phi$ on the support of $e^\phi$, the chain rule gives
$$\log\frac{dQ}{dP}=\log\frac{dQ}{dP_\phi}+\log\frac{dP_\phi}{dP}=\log\frac{dQ}{dP_\phi}+\phi-\log\mathbb E_P e^\phi.$$
Taking $\mathbb E_Q$:
$$\mathrm{KL}(Q\Vert P)=\mathrm{KL}(Q\Vert P_\phi)+\mathbb E_Q[\phi]-\log\mathbb E_P e^\phi.$$
Since $\mathrm{KL}(Q\Vert P_\phi)\ge 0$ (Gibbs' inequality, from Jensen applied to $-\log$), rearranging yields the claim. $\square$

## Main theorem

Apply Lemma 4 with $\phi=\phi_S$:
$$\mathbb E_Q[\phi_S]\le \log W_S+\mathrm{KL}(Q\Vert P).$$
Combined with (4), on the $(1-\delta)$-event we have, **for all $Q\ll P$ simultaneously**,
$$\mathbb E_Q[\phi_S(h)]\le \log(1/\delta)+\mathrm{KL}(Q\Vert P).\tag{5}$$

Expand the left side by linearity of $\mathbb E_Q$:
$$\mathbb E_Q[\phi_S(h)]=\lambda R(Q)-\lambda\hat R_S(Q)-n\psi(\lambda/n)R(Q).$$

Substituting into (5):
$$\bigl[\lambda-n\psi(\lambda/n)\bigr]R(Q)-\lambda\hat R_S(Q)\le \mathrm{KL}(Q\Vert P)+\log(1/\delta),$$
so
$$\bigl[\lambda-n\psi(\lambda/n)\bigr]R(Q)\le \lambda\hat R_S(Q)+\mathrm{KL}(Q\Vert P)+\log(1/\delta).\tag{6}$$

**Final algebra.** We computed in Lemma 2 that
$$\lambda-n\psi(\lambda/n)=n(1-e^{-\lambda/n}).$$
For $\lambda>0$, $1-e^{-\lambda/n}>0$, so the coefficient is strictly positive and we may divide:
$$R(Q)\le \frac{\lambda\hat R_S(Q)+\mathrm{KL}(Q\Vert P)+\log(1/\delta)}{n(1-e^{-\lambda/n})}.$$
Splitting the numerator into the empirical-risk term and the complexity term:
$$\boxed{\;R(Q)\le \frac{\lambda/n}{1-e^{-\lambda/n}}\,\hat R_S(Q)+\frac{1}{1-e^{-\lambda/n}}\cdot\frac{\mathrm{KL}(Q\Vert P)+\log(1/\delta)}{n}.\;}$$

This holds simultaneously for all posteriors $Q\ll P$ on the $(1-\delta)$-event over $S$, which is Catoni's PAC-Bayes bound. $\blacksquare$

## Remarks on rigor

- **Measurability.** $\phi_S(h)$ is jointly measurable in $(S,h)$ since $\ell$ is measurable and $R,\hat R_S$ are measurable in their respective arguments; exponentiation preserves measurability, so $W_S$ is a measurable scalar random variable.
- **Tonelli vs. Fubini.** The swap in (3) uses Tonelli (integrand is non-negative), so no integrability hypothesis is required beyond measurability.
- **Uniformity in $Q$.** The $(1-\delta)$-event $\{W_S\le 1/\delta\}$ depends only on $S$, not on $Q$; DV then applies *after* conditioning on this event, producing a bound valid for **all** $Q\ll P$ simultaneously.
- **Sub-lemma $\log(1-x)\le -x$.** Verified above via monotonicity of $f(x)=\log(1-x)+x$ on $[0,1)$.
- **Case $\lambda=0$.** Excluded by hypothesis; both sides reduce to a vacuous identity as $\lambda\to 0^+$.
