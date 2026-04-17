# Route 4: Gibbs Posterior + Convex Duality

## Setup

Let $\mathcal{H}$ be a measurable hypothesis space and let $P$ be a probability measure on $\mathcal{H}$ (the prior). Let $\ell:\mathcal{H}\times\mathcal{Z}\to[0,1]$ be measurable. Given an i.i.d. sample $S=(Z_1,\dots,Z_n)\sim\mathcal{D}^{\otimes n}$, define
$$\hat R_S(h):=\tfrac{1}{n}\textstyle\sum_{i=1}^n \ell(h,Z_i),\quad R(h):=\mathbb{E}_{Z\sim\mathcal{D}}[\ell(h,Z)]\in[0,1].$$
For any posterior $Q\ll P$, write $\hat R_S(Q)=\mathbb{E}_{h\sim Q}\hat R_S(h)$, $R(Q)=\mathbb{E}_{h\sim Q}R(h)$, and $\mathrm{KL}(Q\|P)=\mathbb{E}_Q\log\frac{dQ}{dP}$. Fix $\lambda>0$ and $\delta\in(0,1)$.

The core strategy is: (i) Donsker–Varadhan duality reduces the problem to controlling a single scalar $\log\mathbb{E}_P[e^{\phi(h)}]$ for an appropriately chosen $\phi$; (ii) choosing $\phi$ to absorb the sub-Bernoulli MGF makes the resulting deterministic inequality sharp; (iii) Fubini + Markov controls the scalar with probability $1-\delta$.

## Lemma 1 (Donsker–Varadhan variational formula)

**Claim.** Let $\phi:\mathcal{H}\to\mathbb{R}$ be measurable with $\mathbb{E}_P[e^{\phi}]<\infty$. Then
$$\log\mathbb{E}_P[e^{\phi(h)}]=\sup_{Q\ll P}\bigl\{\mathbb{E}_Q[\phi]-\mathrm{KL}(Q\|P)\bigr\},$$
and the supremum is attained uniquely at $Q^*(dh)=\frac{e^{\phi(h)}}{\mathbb{E}_P[e^{\phi}]}\,P(dh)$ (the **Gibbs posterior** with potential $\phi$).

**Proof.** Define $Q^*$ as above; it is a probability measure since the normalizer is finite and positive. For any $Q\ll P$ with $\mathrm{KL}(Q\|P)<\infty$, we have $Q\ll Q^*$ (since $\frac{dQ^*}{dP}>0$ $P$-a.s.) and
$$\log\frac{dQ}{dQ^*}=\log\frac{dQ}{dP}-\log\frac{dQ^*}{dP}=\log\frac{dQ}{dP}-\phi+\log\mathbb{E}_P[e^{\phi}].$$
Integrating against $Q$:
$$\mathrm{KL}(Q\|Q^*)=\mathrm{KL}(Q\|P)-\mathbb{E}_Q[\phi]+\log\mathbb{E}_P[e^{\phi}].$$
Since $\mathrm{KL}(Q\|Q^*)\ge 0$ with equality iff $Q=Q^*$ (Gibbs' inequality, a consequence of Jensen applied to $-\log$), we get
$$\mathbb{E}_Q[\phi]-\mathrm{KL}(Q\|P)\le\log\mathbb{E}_P[e^{\phi}],\tag{DV}$$
with equality iff $Q=Q^*$. Taking sup over $Q$ gives the claim. $\square$

Inequality (DV) is the only consequence we use below.

## Lemma 2 (Sub-Bernoulli MGF product)

**Claim.** For every $h\in\mathcal{H}$ and every $\lambda>0$,
$$\mathbb{E}_S\exp\bigl(-\lambda\hat R_S(h)\bigr)\le\exp\bigl(-n(1-e^{-\lambda/n})R(h)\bigr).$$

**Proof.** Since $S=(Z_1,\dots,Z_n)$ is i.i.d. and $\hat R_S(h)=\tfrac{1}{n}\sum_i\ell(h,Z_i)$,
$$\mathbb{E}_S e^{-\lambda\hat R_S(h)}=\prod_{i=1}^n\mathbb{E}\bigl[e^{-(\lambda/n)\ell(h,Z_i)}\bigr].$$
Fix $i$ and let $X=\ell(h,Z_i)\in[0,1]$ with mean $R(h)$. By **convexity of $t\mapsto e^{-at}$** for $a>0$, on $[0,1]$ the chord lies above the curve:
$$e^{-aX}\le(1-X)\cdot e^{0}+X\cdot e^{-a}=1-X(1-e^{-a}).$$
Taking expectation with $a=\lambda/n$:
$$\mathbb{E}[e^{-(\lambda/n)X}]\le 1-R(h)(1-e^{-\lambda/n}).$$
Now use the elementary inequality $1-y\le e^{-y}$ (valid for all $y\in\mathbb{R}$, with equality iff $y=0$; proof: $f(y)=e^{-y}-1+y$ has $f(0)=0$, $f'(y)=1-e^{-y}\ge 0$ iff $y\ge 0$, so $f$ attains its minimum $0$ at $y=0$). With $y=R(h)(1-e^{-\lambda/n})\in[0,1]$:
$$\mathbb{E}[e^{-(\lambda/n)X}]\le\exp\bigl(-R(h)(1-e^{-\lambda/n})\bigr).$$
Multiplying over $i=1,\dots,n$ gives the claim. (Equivalently, $(1-y)^n\le e^{-ny}$ for $y\in[0,1]$.) $\square$

## Lemma 3 (Auxiliary scalar $T_S$; Fubini + Markov)

For $\lambda>0$ fixed, define the **random scalar** (measurable in $S$)
$$T_S:=\mathbb{E}_{h\sim P}\exp\bigl(-\lambda\hat R_S(h)+n(1-e^{-\lambda/n})R(h)\bigr).$$

**Claim.** (a) $\mathbb{E}_S[T_S]\le 1$; (b) $\Pr_S(T_S\le 1/\delta)\ge 1-\delta$.

**Proof.** The integrand is non-negative and jointly measurable in $(h,S)$, so Tonelli/Fubini applies:
$$\mathbb{E}_S[T_S]=\mathbb{E}_{h\sim P}\Bigl[e^{n(1-e^{-\lambda/n})R(h)}\cdot\mathbb{E}_S e^{-\lambda\hat R_S(h)}\Bigr]\stackrel{\text{L2}}{\le}\mathbb{E}_{h\sim P}[1]=1.$$
This proves (a). For (b), since $T_S\ge 0$, Markov's inequality gives
$$\Pr_S(T_S>1/\delta)\le\delta\cdot\mathbb{E}_S[T_S]\le\delta,$$
hence with probability $\ge 1-\delta$, $T_S\le 1/\delta$, i.e., $\log T_S\le\log(1/\delta)$. $\square$

Define the $(1-\delta)$-event $\mathcal{E}:=\{\log T_S\le\log(1/\delta)\}$.

## Main Theorem

**Theorem (Catoni).** For every fixed $\lambda>0$ and $\delta\in(0,1)$, with probability $\ge 1-\delta$ over $S$, **simultaneously for all posteriors** $Q\ll P$:
$$R(Q)\le\frac{\lambda/n}{1-e^{-\lambda/n}}\hat R_S(Q)+\frac{1}{1-e^{-\lambda/n}}\cdot\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{n}.\tag{$\star$}$$

**Proof.** Work on the event $\mathcal{E}$ from Lemma 3, which has $\Pr_S(\mathcal{E})\ge 1-\delta$.

*Step 1 — Apply DV with a data-dependent potential.* Fix (deterministically, on the event $\mathcal{E}$) the potential
$$\phi(h):=-\lambda\hat R_S(h)+n(1-e^{-\lambda/n})R(h).$$
Then $\mathbb{E}_P[e^{\phi}]=T_S<\infty$ on $\mathcal{E}$. By Lemma 1, for **every** $Q\ll P$,
$$\mathbb{E}_Q[\phi]-\mathrm{KL}(Q\|P)\le\log T_S\le\log(1/\delta).$$

*Step 2 — Expand $\mathbb{E}_Q[\phi]$.* By linearity of expectation under $Q$:
$$\mathbb{E}_Q[\phi]=-\lambda\mathbb{E}_Q\hat R_S(h)+n(1-e^{-\lambda/n})\mathbb{E}_Q R(h)=-\lambda\hat R_S(Q)+n(1-e^{-\lambda/n})R(Q).$$

*Step 3 — Rearrange.* Combining Steps 1–2:
$$-\lambda\hat R_S(Q)+n(1-e^{-\lambda/n})R(Q)-\mathrm{KL}(Q\|P)\le\log(1/\delta),$$
i.e.,
$$n(1-e^{-\lambda/n})R(Q)\le\lambda\hat R_S(Q)+\mathrm{KL}(Q\|P)+\log(1/\delta).$$
Since $\lambda>0$ implies $1-e^{-\lambda/n}>0$, divide by $n(1-e^{-\lambda/n})$:
$$R(Q)\le\frac{\lambda\hat R_S(Q)}{n(1-e^{-\lambda/n})}+\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{n(1-e^{-\lambda/n})},$$
which is exactly ($\star$). The inequality holds simultaneously for all $Q\ll P$ because DV (Lemma 1) is a universal inequality valid for every such $Q$ on the single random scalar $\log T_S$. $\square$

## Remark: Gibbs Posterior Optimality

The DV inequality in Step 1 is **tight** at the empirical Gibbs posterior
$$Q^*_S(dh)\;\propto\;\exp\!\bigl(-\lambda\hat R_S(h)+n(1-e^{-\lambda/n})R(h)\bigr)P(dh).$$
However, $Q^*_S$ depends on the unknown $R(h)$, so it is not computable. The **practically relevant** minimizer of the right-hand side of ($\star$) is the computable empirical Gibbs posterior
$$\tilde Q_S(dh)\;\propto\;e^{-\lambda\hat R_S(h)}P(dh),$$
which minimizes $\lambda\hat R_S(Q)+\mathrm{KL}(Q\|P)$ (attained value: $-\log\mathbb{E}_P e^{-\lambda\hat R_S(h)}$, by Lemma 1 applied to $\phi=-\lambda\hat R_S$). Plugging $\tilde Q_S$ into ($\star$) gives the **Gibbs bound**
$$R(\tilde Q_S)\le\frac{1}{n(1-e^{-\lambda/n})}\Bigl[-\log\mathbb{E}_P e^{-\lambda\hat R_S(h)}+\log(1/\delta)\Bigr],$$
which is the classical Catoni oracle inequality. The slack between $Q^*_S$ and $\tilde Q_S$ is precisely the amount lost by replacing the population term $n(1-e^{-\lambda/n})R(h)$ by Markov's $\log(1/\delta)$ concentration penalty — the unavoidable statistical cost of not knowing $\mathcal{D}$.

**Asymptotics.** As $\lambda\to 0^+$, $\frac{\lambda/n}{1-e^{-\lambda/n}}\to 1$ and $\frac{1}{1-e^{-\lambda/n}}\sim\frac{n}{\lambda}$, so $R(Q)\lesssim\hat R_S(Q)+\frac{\mathrm{KL}+\log(1/\delta)}{\lambda}$; optimizing $\lambda\asymp\sqrt{n(\mathrm{KL}+\log(1/\delta))}$ recovers McAllester's $1/\sqrt{n}$ bound. When $\hat R_S(Q)=0$, taking $\lambda=n$ gives $R(Q)\le\frac{e}{e-1}\cdot\frac{\mathrm{KL}+\log(1/\delta)}{n}$, the fast $1/n$ rate. $\blacksquare$
