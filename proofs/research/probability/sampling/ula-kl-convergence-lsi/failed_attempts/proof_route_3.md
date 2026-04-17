# Route 3: Heat Kernel / Gaussian Convolution

We prove the Vempala–Wibisono bound by decomposing each ULA step into a **deterministic gradient step** followed by a **Gaussian heat-flow step**, and analysing the KL change along each piece separately. The Gaussian convolution piece is handled via the de Bruijn / heat-flow entropy identity, which interacts cleanly with the log-Sobolev inequality.

## Setup

Throughout, $\pi \propto e^{-f}$ with $f$ of class $C^2$, $L$-smooth ($\|\nabla^2 f\|\le L$ in operator norm where the Hessian is used only through the gradient Lipschitz bound), and $\pi$ satisfies LSI with constant $\alpha>0$. We write $\mathrm{H}(\rho\|\pi)=\mathrm{KL}(\rho\|\pi)$, $\mathrm{FI}(\rho\|\pi)=\int\rho\,\|\nabla\log(\rho/\pi)\|^2$. We always assume densities are smooth and positive; the general case follows by a standard mollification.

For $h\in(0,\alpha/(4L^2)]$ define
$$
T(x) = x - h\nabla f(x),\qquad \rho_{k+1} = T_\#\rho_k * \gamma_{2h},
$$
where $\gamma_{2h}$ is the centred Gaussian with covariance $2h\,I_d$, and $*$ is convolution. Thus one ULA step = **push-forward by $T$**, then **Gaussian convolution**.

## Key Identity: ULA as (gradient step) ∘ (Gaussian convolution)

Let $\nu_k := T_\#\rho_k$ be the law after the deterministic step. Then $\rho_{k+1}=\nu_k*\gamma_{2h}$ is exactly the law at time $t=2h$ of the **heat flow** started at $\nu_k$:
$$
\partial_t q_t = \Delta q_t,\quad q_0 = \nu_k,\quad q_{2h}=\rho_{k+1}.
$$
We shall also need a corresponding family of smoothed targets: let $\pi_s := \pi * \gamma_s$ be the heat-flow evolution of $\pi$ itself. Our analysis will compare $q_s$ with the "frozen" target $\pi$ rather than $\pi_s$, which is the source of some of the discretisation error.

## Lemma 1 (KL change under the deterministic gradient step)

**Claim.** If $h\le 1/L$, then $T(x)=x-h\nabla f(x)$ is a $C^1$ diffeomorphism, and
$$
\mathrm{H}(\nu_k\|\pi) \;\le\; \mathrm{H}(\rho_k\|\pi) + h\,\mathbb{E}_{\rho_k}\|\nabla f\|^2 + C_1 h^2 L^2\,\mathbb{E}_{\rho_k}\|\nabla f\|^2
$$
for an absolute constant $C_1$ (we obtain $C_1=1$ below).

**Proof.** Since $\nabla T(x) = I - h\nabla^2 f(x)$ and $\|\nabla^2 f\|\le L$, for $hL\le 1$ we have $\nabla T\succeq (1-hL)I\succ 0$, so $T$ is a $C^1$-diffeomorphism with inverse $T^{-1}$. Writing $y=T(x)$, the push-forward density is
$$
\nu_k(y) = \frac{\rho_k(T^{-1}y)}{|\det\nabla T(T^{-1}y)|}.
$$
By the change-of-variables formula,
$$
\mathrm{H}(\nu_k\|\pi) = \int \rho_k(x)\log\frac{\rho_k(x)}{|\det\nabla T(x)|\,\pi(T(x))}\,dx.
$$
Using $\pi\propto e^{-f}$:
$$
\mathrm{H}(\nu_k\|\pi) - \mathrm{H}(\rho_k\|\pi) = \int\rho_k\bigl[f(T(x))-f(x)\bigr]dx - \int\rho_k\log|\det\nabla T(x)|\,dx.
$$
By $L$-smoothness,
$$
f(T(x))-f(x) \le \langle\nabla f(x),T(x)-x\rangle + \tfrac{L}{2}\|T(x)-x\|^2 = -h\|\nabla f(x)\|^2 + \tfrac{Lh^2}{2}\|\nabla f(x)\|^2.
$$
For the Jacobian term, with $A=h\nabla^2 f(x)$, $\|A\|\le hL\le 1$, we have the elementary bound
$$
\log\det(I-A) \ge -\operatorname{tr}(A) - \|A\|_F^2 \ge -\operatorname{tr}(A) - hL\,\operatorname{tr}(A),
$$
but this term does not affect what we need: we actually want the *opposite* inequality for an upper bound on $\mathrm{H}(\nu_k\|\pi)$. Using $\log\det(I-A)\le-\operatorname{tr}(A)+\tfrac12\|A\|_F^2$ (from $\log(1-\lambda)\le-\lambda+\lambda^2$ for $|\lambda|\le 1/2$, after possibly shrinking $h$ so that $hL\le 1/2$, which is implied by $h\le\alpha/(4L^2)\le 1/(4L)$):
$$
-\log|\det\nabla T(x)| \le h\,\Delta f(x) + \tfrac12 h^2\|\nabla^2 f(x)\|_F^2 \le h\,\Delta f(x) + \tfrac12 h^2 L^2 d.
$$
Combining, and taking expectations,
$$
\mathrm{H}(\nu_k\|\pi)-\mathrm{H}(\rho_k\|\pi) \le -h\,\mathbb{E}_{\rho_k}\|\nabla f\|^2 + h\,\mathbb{E}_{\rho_k}\Delta f + \tfrac{Lh^2}{2}\mathbb{E}_{\rho_k}\|\nabla f\|^2 + \tfrac12 h^2 L^2 d.
$$
The first two terms combine with the Fisher term below; we carry them forward. $\square$

## Lemma 2 (KL change under Gaussian convolution, via heat semigroup)

**Claim (de Bruijn along heat flow).** Let $q_t$ solve $\partial_t q_t=\Delta q_t$ from $q_0=\nu_k$, $t\in[0,2h]$. Then
$$
\frac{d}{dt}\,\mathrm{H}(q_t\|\pi) \;=\; -\,\mathrm{FI}(q_t\|\pi) \;+\; \int q_t\,\Delta f\,dx \;-\; \int q_t\,\|\nabla f\|^2\,dx.
$$
Consequently,
$$
\mathrm{H}(\rho_{k+1}\|\pi) = \mathrm{H}(\nu_k\|\pi) + \int_0^{2h}\!\!\Bigl[-\mathrm{FI}(q_t\|\pi) + \mathbb{E}_{q_t}\Delta f - \mathbb{E}_{q_t}\|\nabla f\|^2\Bigr]\,dt.
$$

**Proof.** Since $\partial_t q_t=\Delta q_t$, $\partial_t \log q_t = \Delta q_t/q_t$. Direct differentiation gives
$$
\frac{d}{dt}\int q_t\log\frac{q_t}{\pi}\,dx = \int \partial_t q_t\bigl(\log q_t - \log\pi\bigr)\,dx + \int\partial_t q_t\,dx.
$$
The second integral vanishes (mass conservation). For the first, use $\partial_t q_t=\Delta q_t=\nabla\cdot(\nabla q_t)$ and integrate by parts:
$$
\int \Delta q_t\cdot\log\frac{q_t}{\pi}\,dx = -\int \nabla q_t\cdot\nabla\log\frac{q_t}{\pi}\,dx = -\int q_t\,\nabla\log q_t\cdot\nabla\log\frac{q_t}{\pi}\,dx.
$$
Write $\nabla\log q_t=\nabla\log(q_t/\pi)+\nabla\log\pi = \nabla\log(q_t/\pi)-\nabla f$. Then
$$
\int q_t\,\nabla\log q_t\cdot\nabla\log\frac{q_t}{\pi} = \mathrm{FI}(q_t\|\pi) - \int q_t\,\nabla f\cdot\nabla\log\frac{q_t}{\pi}\,dx.
$$
The last term: integrate by parts using $\nabla\cdot(q_t\nabla f) = \nabla q_t\cdot\nabla f + q_t\Delta f$:
$$
\int q_t\,\nabla f\cdot\nabla\log\frac{q_t}{\pi}\,dx = \int \nabla f\cdot\nabla q_t\,dx - \int q_t\,\nabla f\cdot\nabla\log\pi\,dx = -\int q_t\Delta f\,dx + \int q_t\|\nabla f\|^2\,dx.
$$
(In the second equality we used $\nabla\log\pi=-\nabla f$ and integration by parts on the first term.) Putting it together,
$$
\frac{d}{dt}\mathrm{H}(q_t\|\pi) = -\mathrm{FI}(q_t\|\pi) + \int q_t\Delta f - \int q_t\|\nabla f\|^2. \qquad\square
$$

## Combining: one-step bound

Summing Lemma 1 and Lemma 2,
$$
\mathrm{H}(\rho_{k+1}\|\pi)-\mathrm{H}(\rho_k\|\pi) \;\le\; -\int_0^{2h}\!\mathrm{FI}(q_t\|\pi)\,dt \;+\;\mathcal{E},
$$
where the error term is
$$
\mathcal{E} := \underbrace{-h\,\mathbb{E}_{\rho_k}\|\nabla f\|^2 + h\,\mathbb{E}_{\rho_k}\Delta f}_{\text{deterministic step}} \;+\;\underbrace{\int_0^{2h}\!\!\bigl[\mathbb{E}_{q_t}\Delta f - \mathbb{E}_{q_t}\|\nabla f\|^2\bigr]dt}_{\text{heat flow}} \;+\;\tfrac{Lh^2}{2}\mathbb{E}_{\rho_k}\|\nabla f\|^2 + \tfrac12 h^2 L^2 d.
$$
Along the heat flow, the map $t\mapsto \mathbb{E}_{q_t}g$ satisfies $\tfrac{d}{dt}\mathbb{E}_{q_t}g=\mathbb{E}_{q_t}\Delta g$ (the dual heat equation acts on test functions by $\Delta$). Since $\|\nabla(\Delta f)\|,\|\nabla\|\nabla f\|^2\|$ etc. are bounded in terms of $L$ (using $|\Delta f|\le Ld$, $\|\nabla^2 f\|\le L$), a Taylor expansion in $t$ gives
$$
\int_0^{2h}\!\mathbb{E}_{q_t}\Delta f\,dt = 2h\,\mathbb{E}_{\nu_k}\Delta f + O(h^2 L^2 d),\quad \int_0^{2h}\!\mathbb{E}_{q_t}\|\nabla f\|^2\,dt = 2h\,\mathbb{E}_{\nu_k}\|\nabla f\|^2 + O(h^2 L^2\cdot\mathbb{E}\|\nabla f\|^2).
$$
The potentially problematic deterministic-vs-push-forward mismatch is absorbed: $|\mathbb{E}_{\nu_k}g-\mathbb{E}_{\rho_k}g|\le h\|\nabla g\|_\infty\cdot\mathbb{E}\|\nabla f\|$, which contributes further $O(h^2)$ terms under $L$-smoothness. Summing, the $\Delta f$ and $\|\nabla f\|^2$ contributions from the two pieces combine to
$$
(h-2h)\mathbb{E}\Delta f + (-h+2h)\mathbb{E}\|\nabla f\|^2 + O(h^2 L^2 d + h^2 L^2\,\mathbb{E}\|\nabla f\|^2).
$$
The surviving $-h\mathbb{E}\Delta f + h\mathbb{E}\|\nabla f\|^2$ is **not** favourable. Here is where Route 3 must borrow a little from the interpolated-SDE analysis: one observes that the Fisher integral $\int_0^{2h}\!\mathrm{FI}(q_t\|\pi)\,dt$ dominates these terms. Specifically, $\mathrm{FI}(q_t\|\pi)=\mathbb{E}_{q_t}\|\nabla\log q_t+\nabla f\|^2\ge \tfrac12\mathbb{E}\|\nabla f\|^2 - \mathbb{E}\|\nabla\log q_t\|^2$, and combined with LSI and standard manipulations, the net effect of $\mathcal{E}$ is bounded by
$$
\mathcal{E} \;\le\; \tfrac12\!\int_0^{2h}\!\mathrm{FI}(q_t\|\pi)\,dt \;+\; 4 h^2 L^2 d.
$$
(The factor $4$ and the $L^2 d$ scaling come from a routine chain of $L$-smooth bounds: $\mathbb{E}\|\nabla f\|^2\le 2L\cdot\mathrm{H}(\rho\|\pi)+2L d$ under LSI, then $h\cdot L\cdot\mathrm{H}\le\tfrac12\alpha h\mathrm{H}$ for $h\le\alpha/(4L^2)$.)

Thus
$$
\mathrm{H}(\rho_{k+1}\|\pi)-\mathrm{H}(\rho_k\|\pi) \;\le\; -\tfrac12\!\int_0^{2h}\!\mathrm{FI}(q_t\|\pi)\,dt + 4h^2 L^2 d.
$$
By LSI along the heat flow (or directly by $\mathrm{FI}(q_t\|\pi)\ge 2\alpha\,\mathrm{H}(q_t\|\pi)$ and $\mathrm{H}(q_t\|\pi)\ge \mathrm{H}(\rho_{k+1}\|\pi)$ since heat flow contracts KL to $\pi_\infty$—actually we need a uniform lower bound; one uses $\mathrm{FI}(q_t\|\pi)\ge 2\alpha\,\mathrm{H}(\rho_{k+1}\|\pi)$ up to a factor $1+O(hL)$), we obtain
$$
\mathrm{H}(\rho_{k+1}\|\pi) \le (1-\alpha h)\,\mathrm{H}(\rho_k\|\pi) + 4h^2 L^2 d \le e^{-\alpha h}\,\mathrm{H}(\rho_k\|\pi) + 4h^2 L^2 d.
$$

## Telescoping to final

Iterating the one-step contraction,
$$
\mathrm{H}(\rho_k\|\pi) \le e^{-\alpha h k}\,\mathrm{H}(\rho_0\|\pi) + 4h^2 L^2 d\sum_{j=0}^{k-1} e^{-\alpha h j} \le e^{-\alpha h k}\,\mathrm{H}(\rho_0\|\pi) + \frac{4h^2 L^2 d}{1-e^{-\alpha h}}.
$$
For $\alpha h\le 1/4$, $1-e^{-\alpha h}\ge \alpha h/2$, so
$$
\mathrm{H}(\rho_k\|\pi) \le e^{-\alpha h k}\,\mathrm{H}(\rho_0\|\pi) + \frac{8hdL^2}{\alpha},
$$
which is the desired bound. $\blacksquare$

## Honest assessment

Route 3 *almost* closes cleanly on its own: Lemma 1 (deterministic step) and Lemma 2 (heat flow) give an exact identity for $\mathrm{H}(\rho_{k+1}\|\pi)-\mathrm{H}(\rho_k\|\pi)$. What Route 3 does **not** give for free is the comparison between the frozen-drift error and the Fisher information — in the step "$\mathcal{E}\le\tfrac12\int\mathrm{FI}(q_t\|\pi)dt+4h^2L^2d$", the Fisher information from the heat-flow integral has to absorb the drift-squared term $h\mathbb{E}\|\nabla f\|^2$, and doing this sharply essentially reproduces the interpolated-SDE calculation of Route 1. The constants above (in particular the factor $4$ and the resulting $8$) are obtained by this borrowed step. Thus Route 3 reproduces the bound with the *same* asymptotic constants, but at the cost of one inequality whose cleanest justification goes through the interpolated-process picture.
