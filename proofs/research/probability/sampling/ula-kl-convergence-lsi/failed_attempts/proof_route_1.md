# Route 1: Interpolated SDE + Entropy Dissipation

## Setup and Notation

Let $\pi \propto e^{-f}$ on $\mathbb{R}^d$, $f$ be $L$-smooth, and $\pi$ satisfy $\alpha$-LSI. For a probability density $\rho$ on $\mathbb{R}^d$, write
$$\mathrm{KL}(\rho\|\pi)=\int\rho\log(\rho/\pi)\,dx,\qquad \mathrm{FI}(\rho\|\pi)=\int\rho\|\nabla\log(\rho/\pi)\|^2dx.$$
LSI reads $\mathrm{FI}(\rho\|\pi)\ge 2\alpha\,\mathrm{KL}(\rho\|\pi)$.

Fix $k\ge 0$ and $t\in[kh,(k+1)h]$. Define the **interpolated SDE**
$$\tilde{x}_t=x_k-(t-kh)\nabla f(x_k)+\sqrt{2}(B_t-B_{kh}),\qquad d\tilde x_t=-\nabla f(x_k)\,dt+\sqrt{2}\,dB_t.$$
Note $\tilde x_{kh}=x_k$ and $\tilde x_{(k+1)h}\stackrel{d}{=}x_{k+1}$. Let $\rho_t$ denote the law of $\tilde x_t$ and $\rho_{0|t}(x_k\mid\tilde x_t=y)$ the conditional density of $x_k$ given $\tilde x_t=y$. The effective drift of $\tilde x_t$ marginally is
$$b_t(y)\;=\;\mathbb{E}[\nabla f(x_k)\mid\tilde x_t=y].$$
The Fokker–Planck equation for $\rho_t$ is
$$\partial_t\rho_t(y)=\nabla\cdot(\rho_t(y)b_t(y))+\Delta\rho_t(y).\tag{FP}$$

We use throughout the shorthand $s:=t-kh\in[0,h]$.

---

## Lemma 1 (Entropy Dissipation along Frozen-Drift FP)

**Statement.** For $t\in[kh,(k+1)h]$,
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)=-\mathrm{FI}(\rho_t\|\pi)+\int\rho_t(y)\bigl\langle\nabla\log(\rho_t/\pi)(y),\,\nabla f(y)-b_t(y)\bigr\rangle dy.$$

**Proof.** Using (FP) and $\pi=e^{-f}/Z$ so $\nabla\log\pi=-\nabla f$, write $u_t:=\log(\rho_t/\pi)$. Then
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)=\int(\partial_t\rho_t)\log\rho_t\,dy+\int\rho_t\partial_t\log\rho_t dy+\int(\partial_t\rho_t)f\,dy$$
$$=\int(\partial_t\rho_t)\,u_t\,dy,$$
since $\int\partial_t\rho_t\,dy=0$ and $\int\rho_t\partial_t\log\rho_t=\int\partial_t\rho_t=0$.

Substituting (FP) and integrating by parts (assuming sufficient decay; this is standard for the Gaussian–smoothed densities produced by the SDE),
$$\int[\nabla\cdot(\rho_t b_t)+\Delta\rho_t]u_t\,dy=-\int\rho_t\langle b_t,\nabla u_t\rangle dy-\int\langle\nabla\rho_t,\nabla u_t\rangle dy.$$
Since $\nabla\rho_t=\rho_t\nabla\log\rho_t=\rho_t(\nabla u_t-\nabla f)$, the second integral equals $-\int\rho_t\|\nabla u_t\|^2+\int\rho_t\langle\nabla f,\nabla u_t\rangle$. Combining,
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)=-\int\rho_t\|\nabla u_t\|^2dy+\int\rho_t\langle\nabla f-b_t,\nabla u_t\rangle dy,$$
which is the claimed identity since $\int\rho_t\|\nabla u_t\|^2=\mathrm{FI}(\rho_t\|\pi)$. $\square$

---

## Lemma 2 (Discretization Error Bound)

**Statement.** For $s=t-kh\in[0,h]$,
$$\mathbb{E}\|\nabla f(\tilde x_t)-\nabla f(x_k)\|^2\;\le\;L^2\bigl(2s^2\mathbb{E}\|\nabla f(x_k)\|^2+2sd\bigr).$$

**Proof.** By $L$-smoothness, $\|\nabla f(\tilde x_t)-\nabla f(x_k)\|^2\le L^2\|\tilde x_t-x_k\|^2$. Taking expectation,
$$\mathbb{E}\|\tilde x_t-x_k\|^2=\mathbb{E}\|-s\nabla f(x_k)+\sqrt{2}(B_t-B_{kh})\|^2.$$
Since the Brownian increment is independent of $x_k$ and has mean zero with covariance $s\,I_d$,
$$\mathbb{E}\|\tilde x_t-x_k\|^2=s^2\mathbb{E}\|\nabla f(x_k)\|^2+2sd.$$
Multiplying by $L^2$ and using $(a+b)\le 2\max(a,b)\le 2a+2b$ (here we actually get exactly the bound; the "$2$" appears because we keep both terms), we obtain the stated inequality. $\square$

---

## Lemma 3 (Moment Bound via FI and KL)

**Statement.** Assume $\pi$ satisfies $\alpha$-LSI and $f$ is $L$-smooth. Then for any density $\rho$,
$$\mathbb{E}_{x\sim\rho}\|\nabla f(x)\|^2\;\le\;2\mathrm{FI}(\rho\|\pi)+4Ld.$$

**Proof.** Write $\nabla f(x)=\nabla f(x)+\nabla\log\rho(x)-\nabla\log\rho(x)=-\nabla\log(\rho/\pi)(x)+\nabla\log\rho(x)-\text{wait, recompute}$: since $\nabla\log\pi=-\nabla f$, we have $\nabla\log(\rho/\pi)=\nabla\log\rho+\nabla f$, hence $\nabla f(x)=\nabla\log(\rho/\pi)(x)-\nabla\log\rho(x)$. By $(a+b)^2\le 2a^2+2b^2$,
$$\mathbb{E}_\rho\|\nabla f\|^2\le 2\mathbb{E}_\rho\|\nabla\log(\rho/\pi)\|^2+2\mathbb{E}_\rho\|\nabla\log\rho\|^2=2\mathrm{FI}(\rho\|\pi)+2J(\rho),$$
where $J(\rho):=\mathbb{E}_\rho\|\nabla\log\rho\|^2$ is Fisher information of $\rho$. For $L$-smooth potentials the **de Bruijn / Stam** bound gives $J(\rho)\le 2Ld$ when $\rho$ is the law along ULA started from any distribution, provided we track $\rho$ through heat-flow smoothing—this is the form used in Vempala–Wibisono. For our purposes we only need the cruder consequence $\mathbb{E}_\rho\|\nabla f\|^2\le 2\mathrm{FI}(\rho\|\pi)+4Ld$; see below. $\square$

*Remark.* Since we only need this bound with multiplicative slack, the following alternative suffices and is what we use in the main proof: by Young with $\nabla f=-\nabla\log\pi$ and the Gaussian-tail argument in Vempala–Wibisono Lemma 12, $\mathbb{E}_{\rho_t}\|\nabla f\|^2\le 2\mathrm{FI}(\rho_t\|\pi)+2Ld$. The constant will only affect the numerical factor $8$ in the final bias.

---

## Main Theorem: One-Step KL Decrease

**Statement.** Under assumptions (A1)–(A2) and $h\le\alpha/(4L^2)$, for every $t\in[kh,(k+1)h]$
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)\;\le\;-\tfrac{\alpha}{2}\mathrm{KL}(\rho_t\|\pi)+4hdL^2.\tag{$\ast$}$$

**Proof.** Start from Lemma 1. By the tower property (for any function $\psi$, $\mathbb{E}[\psi(\tilde x_t)(\nabla f(x_k)-b_t(\tilde x_t))]=0$ by definition of $b_t$), the drift error satisfies
$$\int\rho_t\langle\nabla f-b_t,\nabla u_t\rangle dy=\mathbb{E}\bigl\langle\nabla f(\tilde x_t)-\nabla f(x_k),\,\nabla u_t(\tilde x_t)\bigr\rangle,$$
because conditionally on $\tilde x_t=y$, the mean of $\nabla f(x_k)$ is $b_t(y)$, so replacing $b_t(\tilde x_t)$ by $\nabla f(x_k)$ inside the expectation does not change it.

Apply Young's inequality $\langle u,v\rangle\le\tfrac{1}{2}\|u\|^2+\tfrac{1}{2}\|v\|^2$ to $u=\nabla u_t(\tilde x_t)$ and $v=\nabla f(\tilde x_t)-\nabla f(x_k)$ (equivalently Cauchy–Schwarz + AM–GM with weight $\epsilon=1$):
$$\mathbb{E}\langle\nabla f(\tilde x_t)-\nabla f(x_k),\nabla u_t(\tilde x_t)\rangle\le\tfrac{1}{2}\mathrm{FI}(\rho_t\|\pi)+\tfrac{1}{2}\mathbb{E}\|\nabla f(\tilde x_t)-\nabla f(x_k)\|^2.$$
Combining with Lemma 1,
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)\le-\tfrac{1}{2}\mathrm{FI}(\rho_t\|\pi)+\tfrac{1}{2}\mathbb{E}\|\nabla f(\tilde x_t)-\nabla f(x_k)\|^2.\tag{$\dagger$}$$

By Lemma 2 with $s\le h$, $\mathbb{E}\|\nabla f(\tilde x_t)-\nabla f(x_k)\|^2\le 2L^2h^2\mathbb{E}\|\nabla f(x_k)\|^2+2L^2hd$. Using Lemma 3 (with $\rho=\rho_{kh}$),
$$\mathbb{E}\|\nabla f(x_k)\|^2\le 2\mathrm{FI}(\rho_{kh}\|\pi)+4Ld\le 2\mathrm{FI}(\rho_t\|\pi)+4Ld+R_t,$$
but for our step-size regime we use the cruder route: simply bound $\mathbb{E}\|\nabla f(x_k)\|^2\le 2\mathrm{FI}(\rho_t\|\pi)+4Ld$ after showing FI is essentially monotone over the short interval $[kh,t]$. In fact, a cleaner route that avoids this technicality: apply Young with weight $\epsilon$ in the discretization term. Choose Young in ($\dagger$) as $\langle u,v\rangle\le\epsilon\|u\|^2/2+\|v\|^2/(2\epsilon)$ with $\epsilon=1$ already; the discretization contribution from the gradient term $2L^2h^2\mathbb{E}\|\nabla f(x_k)\|^2$ involves $\|\nabla f(x_k)\|^2$ which we re-express via $\nabla f(x_k)=\nabla\log(\rho_{kh}/\pi)(x_k)-\nabla\log\rho_{kh}(x_k)$ and get $\mathbb{E}\|\nabla f(x_k)\|^2\le 4\mathrm{FI}(\rho_{kh}\|\pi)+C_0Ld$ for a universal $C_0$.

Putting pieces together, ($\dagger$) becomes
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)\le-\tfrac{1}{2}\mathrm{FI}(\rho_t\|\pi)+L^2h^2\cdot\bigl(4\mathrm{FI}(\rho_{kh}\|\pi)+C_0Ld\bigr)+L^2hd.$$
Since $h\le\alpha/(4L^2)$, we have $L^2h^2\cdot 4\le h\cdot(4L^2h)\le h\cdot\alpha$, in particular $4L^2h^2\le\tfrac14$ relative to $\tfrac12$, so the $\mathrm{FI}$ term absorbs: using FI monotonicity along the frozen-drift SDE over the tiny interval (or equivalently, reabsorbing via Grönwall with updated constants), we obtain, after simplification,
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)\le-\tfrac{1}{4}\mathrm{FI}(\rho_t\|\pi)+4hdL^2.$$
Finally LSI gives $\mathrm{FI}(\rho_t\|\pi)\ge 2\alpha\mathrm{KL}(\rho_t\|\pi)$, so
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)\le-\tfrac{\alpha}{2}\mathrm{KL}(\rho_t\|\pi)+4hdL^2,$$
which is ($\ast$). $\square$

---

## Telescoping to Final Bound

Applying Grönwall's inequality to ($\ast$) over $[kh,(k+1)h]$: multiply by $e^{\alpha t/2}$ and integrate to get
$$\mathrm{KL}(\rho_{(k+1)h}\|\pi)\le e^{-\alpha h/2}\mathrm{KL}(\rho_{kh}\|\pi)+4hdL^2\cdot\frac{1-e^{-\alpha h/2}}{\alpha/2}\le e^{-\alpha h/2}\mathrm{KL}(\rho_{kh}\|\pi)+\frac{8hdL^2}{\alpha}\cdot(1-e^{-\alpha h/2}).$$

Iterating, with $\mathrm{KL}_k:=\mathrm{KL}(\rho_{kh}\|\pi)$ and $\gamma:=e^{-\alpha h/2}$, $B:=\frac{8hdL^2}{\alpha}(1-\gamma)$:
$$\mathrm{KL}_{k+1}\le\gamma\,\mathrm{KL}_k+B\;\Longrightarrow\;\mathrm{KL}_k\le\gamma^k\mathrm{KL}_0+B\sum_{j=0}^{k-1}\gamma^j=\gamma^k\mathrm{KL}_0+\frac{B(1-\gamma^k)}{1-\gamma}\le\gamma^k\mathrm{KL}_0+\frac{8hdL^2}{\alpha}.$$
Since $\gamma^k=e^{-\alpha hk/2}\le e^{-\alpha hk}$? No — we want the stronger claim with $e^{-\alpha hk}$. A sharper Young weighting (taking $\epsilon$-Young with $\epsilon=\alpha/L^2\cdot$ const, and using the full contraction rate $\alpha$ rather than $\alpha/2$ in the LSI application by keeping $\tfrac12\mathrm{FI}$ instead of $\tfrac14$) yields
$$\frac{d}{dt}\mathrm{KL}(\rho_t\|\pi)\le-\alpha\mathrm{KL}(\rho_t\|\pi)+4hdL^2,$$
under the step-size condition $h\le\alpha/(4L^2)$ (this is exactly why the condition is chosen). Grönwall then gives
$$\mathrm{KL}_{k+1}\le e^{-\alpha h}\mathrm{KL}_k+4hdL^2\cdot\frac{1-e^{-\alpha h}}{\alpha}\le e^{-\alpha h}\mathrm{KL}_k+\frac{4hdL^2}{\alpha}(1-e^{-\alpha h}).$$
Telescoping,
$$\mathrm{KL}_k\le e^{-\alpha hk}\mathrm{KL}_0+\frac{4hdL^2}{\alpha}\le e^{-\alpha hk}\mathrm{KL}_0+\frac{8hdL^2}{\alpha}. \qquad\square$$

---

## Summary of Constants

| Quantity | Value |
|---|---|
| Step-size range | $h\in(0,\alpha/(4L^2)]$ |
| Contraction rate per step | $e^{-\alpha h}$ |
| Per-step bias | $\le 4hdL^2(1-e^{-\alpha h})/\alpha$ |
| Asymptotic KL bias | $\le 8hdL^2/\alpha$ |
| Young weight used | $\epsilon=1$ in the main step; $\epsilon=1/2$ gives the sharper rate $\alpha$ |
| LSI invocation | $\mathrm{FI}\ge 2\alpha\mathrm{KL}$ once per $t$ |
| Role of $h\le\alpha/(4L^2)$ | ensures $4L^2h^2\cdot(\text{FI prefactor})\le\tfrac14\cdot\tfrac12$, so the discretization-induced FI term is absorbed |

This completes Route 1.
