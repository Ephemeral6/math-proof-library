# Route 1: Sub-Bernoulli MGF + Donsker-Varadhan

## Setup

Let $(\mathcal{Z}, \mathcal{F}, \mathcal{D})$ be a probability space of data, $\mathcal{H}$ a measurable hypothesis space, and $\ell : \mathcal{H}\times\mathcal{Z} \to [0,1]$ a measurable loss. For $h\in\mathcal{H}$ define
$$R(h) := \mathbb{E}_{Z\sim\mathcal{D}}[\ell(h,Z)], \qquad \hat R_S(h) := \frac{1}{n}\sum_{i=1}^n \ell(h,Z_i),$$
with $S = (Z_1,\dots,Z_n) \sim \mathcal{D}^{\otimes n}$. For a probability measure $Q$ on $\mathcal{H}$ absolutely continuous w.r.t. the prior $P$, set
$$R(Q) := \mathbb{E}_{h\sim Q}[R(h)], \qquad \hat R_S(Q) := \mathbb{E}_{h\sim Q}[\hat R_S(h)].$$
Fix $\lambda > 0$ and $\delta \in (0,1)$. Let $\lambda' := \lambda/n$. Define
$$\psi(u) := u - 1 + e^{-u}, \qquad u\ge 0.$$
Note $\psi(0)=0$, $\psi'(u)=1-e^{-u}\ge 0$, so $\psi(u)\ge 0$.

## Lemma 1 (Donsker-Varadhan variational formula)

Let $P, Q$ be probability measures on a measurable space $(\mathcal{H},\mathcal{G})$ with $Q \ll P$, and let $\phi : \mathcal{H}\to\mathbb{R}$ be measurable with $\mathbb{E}_P[e^{\phi}] < \infty$. Then
$$\mathbb{E}_Q[\phi] \le \log \mathbb{E}_P[e^{\phi}] + \mathrm{KL}(Q\|P),$$
with the convention $\mathrm{KL}(Q\|P) = +\infty$ if $Q\not\ll P$ (in which case the inequality is trivial).

**Proof.** Assume $Q\ll P$ with density $q := dQ/dP$, and $\mathbb{E}_P[e^\phi]<\infty$. Define the tilted probability measure $\tilde P$ by $d\tilde P/dP = e^\phi / Z$, where $Z := \mathbb{E}_P[e^\phi]$. Then
$$\mathrm{KL}(Q\|\tilde P) = \mathbb{E}_Q\!\left[\log\frac{dQ}{d\tilde P}\right] = \mathbb{E}_Q\!\left[\log\frac{q\cdot Z}{e^\phi}\right] = \mathrm{KL}(Q\|P) + \log Z - \mathbb{E}_Q[\phi].$$
By Gibbs' inequality $\mathrm{KL}(Q\|\tilde P)\ge 0$, hence $\mathbb{E}_Q[\phi] \le \log Z + \mathrm{KL}(Q\|P)$. $\blacksquare$

*Remark on measurability.* When applied below with $\phi$ also depending on the random sample $S$, the inequality holds pointwise in $S$ after applying Fubini-Tonelli; all integrands are $\mathcal{G}\otimes\mathcal{F}^{\otimes n}$-measurable since $\ell$ is jointly measurable.

## Lemma 2 (Sub-Bernoulli MGF bound)

Let $X$ be a random variable with $X\in[0,1]$ and $\mathbb{E}[X] = p$. For every $u \ge 0$,
$$\mathbb{E}[e^{-uX}] \le \exp\!\bigl(-p(1-e^{-u})\bigr) = \exp\!\bigl(-p\,\psi'(u)\bigr).$$
Equivalently, $e^{up}\mathbb{E}[e^{-uX}] \le \exp(p\,\psi(u))$.

**Proof.** The map $x\mapsto e^{-ux}$ is convex. For $x\in[0,1]$, convexity at the endpoints gives
$$e^{-ux} \le (1-x)\cdot e^0 + x\cdot e^{-u} = 1 - x(1-e^{-u}).$$
Taking expectation: $\mathbb{E}[e^{-uX}] \le 1 - p(1-e^{-u})$. Using $\log(1-t)\le -t$ for $t = p(1-e^{-u})\in[0,1)$,
$$\log\mathbb{E}[e^{-uX}] \le -p(1-e^{-u}).$$
Multiplying by $e^{up}$,
$$\log\bigl(e^{up}\mathbb{E}[e^{-uX}]\bigr) \le up - p(1-e^{-u}) = p(u - 1 + e^{-u}) = p\,\psi(u). \quad\blacksquare$$

## Lemma 3 ($n$-fold MGF product)

Let $Z_1,\dots,Z_n$ be i.i.d. and fix $h\in\mathcal{H}$. Write $X_i := \ell(h,Z_i)\in[0,1]$ and $p := R(h) = \mathbb{E}[X_i]$. Let $\hat R_S(h) = \frac{1}{n}\sum_i X_i$. Then
$$\mathbb{E}_S\exp\!\bigl(\lambda(R(h) - \hat R_S(h))\bigr) \le \exp\!\bigl(n\,R(h)\,\psi(\lambda/n)\bigr).$$

**Proof.** Since $\lambda(R(h)-\hat R_S(h)) = \sum_{i=1}^n \lambda'(p - X_i)$ with $\lambda' = \lambda/n$, and the $X_i$ are independent,
$$\mathbb{E}\exp\!\Bigl(\sum_i \lambda'(p-X_i)\Bigr) = \prod_{i=1}^n \mathbb{E}\bigl[e^{\lambda'p}e^{-\lambda' X_i}\bigr] = \prod_{i=1}^n e^{\lambda' p}\mathbb{E}[e^{-\lambda' X_i}].$$
By Lemma 2 each factor is $\le \exp(p\,\psi(\lambda'))$, so the product is $\le \exp(n p\,\psi(\lambda')) = \exp(n R(h)\,\psi(\lambda/n))$. $\blacksquare$

## Main theorem

**Theorem (Catoni).** For every $\lambda > 0$ and $\delta\in(0,1)$, with probability at least $1-\delta$ over $S\sim\mathcal{D}^{\otimes n}$, simultaneously for all posteriors $Q\ll P$,
$$R(Q) \le \frac{\lambda/n}{1-e^{-\lambda/n}}\,\hat R_S(Q) + \frac{1}{1-e^{-\lambda/n}}\cdot\frac{\mathrm{KL}(Q\|P) + \log(1/\delta)}{n}.$$

**Proof.** Define, for each fixed $h$ and $S$,
$$\phi_S(h) := \lambda\bigl(R(h) - \hat R_S(h)\bigr) - n R(h)\,\psi(\lambda/n).$$
This is jointly measurable in $(h,S)$ since $\ell$ is measurable.

*Step 1 (per-hypothesis MGF normalization).* By Lemma 3,
$$\mathbb{E}_S\bigl[e^{\phi_S(h)}\bigr] = e^{-n R(h)\psi(\lambda/n)}\cdot \mathbb{E}_S e^{\lambda(R(h)-\hat R_S(h))} \le 1 \quad\text{for every }h.$$

*Step 2 (Fubini).* Define $W_S := \mathbb{E}_{h\sim P}[e^{\phi_S(h)}]$. By Tonelli (integrand nonnegative),
$$\mathbb{E}_S[W_S] = \mathbb{E}_{h\sim P}\mathbb{E}_S[e^{\phi_S(h)}] \le \mathbb{E}_{h\sim P}[1] = 1.$$

*Step 3 (Markov).* $W_S\ge 0$, hence $\mathbb{P}_S(W_S > 1/\delta) \le \delta\mathbb{E}_S[W_S]\le \delta$. Let $\mathcal{E}$ be the event $\{W_S \le 1/\delta\}$; then $\mathbb{P}(\mathcal{E})\ge 1-\delta$, and on $\mathcal{E}$,
$$\log W_S \le \log(1/\delta).$$

*Step 4 (Donsker-Varadhan, uniform over $Q$).* Fix $S$ on the event $\mathcal{E}$. For any $Q\ll P$, Lemma 1 with $\phi = \phi_S$ gives
$$\mathbb{E}_Q[\phi_S] \le \log W_S + \mathrm{KL}(Q\|P) \le \log(1/\delta) + \mathrm{KL}(Q\|P).$$
Expanding the LHS by linearity of expectation in $h$,
$$\lambda\bigl(R(Q) - \hat R_S(Q)\bigr) - n R(Q)\,\psi(\lambda/n) \le \mathrm{KL}(Q\|P) + \log(1/\delta). \tag{$\ast$}$$
Crucially, Lemma 1 is applied *after* fixing $S\in\mathcal{E}$: the bound $\log W_S \le\log(1/\delta)$ is a single event controlling $W_S$ uniformly for all $Q$ simultaneously (since $W_S$ does not depend on $Q$). This delivers the "for all $Q$" quantifier.

## Rearrangement verification

Rewrite $(\ast)$ by grouping $R(Q)$ terms:
$$R(Q)\bigl[\lambda - n\,\psi(\lambda/n)\bigr] \le \lambda\,\hat R_S(Q) + \mathrm{KL}(Q\|P) + \log(1/\delta).$$
Compute the coefficient:
$$\lambda - n\,\psi(\lambda/n) = \lambda - n\!\left(\frac{\lambda}{n} - 1 + e^{-\lambda/n}\right) = \lambda - \lambda + n - n e^{-\lambda/n} = n\bigl(1 - e^{-\lambda/n}\bigr).$$
Since $\lambda > 0$ implies $e^{-\lambda/n}<1$, the coefficient is strictly positive. Dividing,
$$R(Q) \le \frac{\lambda\,\hat R_S(Q) + \mathrm{KL}(Q\|P) + \log(1/\delta)}{n(1-e^{-\lambda/n})}.$$
Splitting the numerator and using $\lambda/[n(1-e^{-\lambda/n})] = (\lambda/n)/(1-e^{-\lambda/n})$,
$$R(Q) \le \frac{\lambda/n}{1-e^{-\lambda/n}}\,\hat R_S(Q) + \frac{1}{1-e^{-\lambda/n}}\cdot\frac{\mathrm{KL}(Q\|P) + \log(1/\delta)}{n}.$$
This holds on the event $\mathcal{E}$ for every $Q\ll P$; for $Q\not\ll P$ the bound is vacuous as $\mathrm{KL}(Q\|P)=+\infty$. Since $\mathbb{P}(\mathcal{E})\ge 1-\delta$, the theorem is proved. $\blacksquare$

## Remarks on rigor

1. **Joint measurability.** The map $(h,S)\mapsto\ell(h,Z_i)$ is measurable by assumption, so $\phi_S(h)$ is jointly measurable and Fubini/Tonelli applies.
2. **Integrability.** $\phi_S(h)\le\lambda\cdot 1 + 0 = \lambda$ (since $R(h)-\hat R_S(h)\le 1$ and $\psi\ge 0$, $R(h)\ge 0$), so $e^{\phi_S(h)}\le e^\lambda$, guaranteeing all integrals are finite.
3. **Uniformity over $Q$.** The event $\mathcal{E}$ is defined solely through $W_S = \mathbb{E}_P[e^{\phi_S}]$, which is $Q$-free. On $\mathcal{E}$, Lemma 1 is then invoked for every $Q$.
4. **Sharpness of Lemma 2.** Equality in the first step holds for $X\in\{0,1\}$ (Bernoulli), which is why the resulting bound is tight for Bernoulli losses — the origin of the name "sub-Bernoulli".
