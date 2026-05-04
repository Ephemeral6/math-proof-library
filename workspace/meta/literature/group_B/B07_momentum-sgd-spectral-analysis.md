# B7 — Momentum SGD spectral analysis convergence

**Verdict**: CONFIRMED (technique-novel internal route, same scope)

**Source**: Loizou 2021 / Vaswani 2019 same family. Spectral analysis style traces to Loizou-Richtárik 2017-2020 (heavy ball as stochastic linear iteration), Can-Gurbuzbalaban-Zhu 2019 (accelerated SGD via Lyapunov on quadratics).

## OUR statement
Convex $L$-smooth $f_i$, $\mu$-SC $f$, interpolation. SHB with $\gamma=1/(4L)$, $\beta\in[0,\beta_{\max})$, $\beta_{\max}>0$ depending on $\kappa$. Then $\exists C, \rho<1$ with $\mathbb{E}\|x_t-x^*\|^2 \le C\rho^t\|x_0-x^*\|^2$.

Proof: 3-stage — (i) integral Hessian → state-dependent linear system $z_{t+1}=A_{i_t}(x_t)z_t$; (ii) for quadratic case, second-moment operator $\mathcal{T}(S) = \frac{1}{n}\sum A_i S A_i^T$, $\rho(\mathcal{T}) < 1$ via Costa-Fragoso-Marques (Markov jump linear systems); (iii) extension to general convex via integral Hessian.

## Paper statement
- Loizou-Richtárik framework: SGD-momentum on quadratics is exactly a stochastic linear iteration; spectral analysis of $\mathbb{E}[A\otimes A]$ gives optimal rates.
- Can-Gurbuzbalaban-Zhu 2019 (arXiv:1901.08788): Accelerated linear convergence rate for SHB on quadratics via spectral analysis.
- Vaswani 2019 covers the general (non-quadratic) case via co-coercivity Lyapunov, not via spectral analysis.

## Comparison
- Stage 2 (quadratic spectral analysis) matches Loizou-Richtárik and Can et al. exactly. Rate $\rho < 1$ is correct.
- Stage 1+3 reduction (integral Hessian → state-dependent $A_{i_t}(x_t)$) is **internal innovation**: the spectral analysis applies to fixed-Hessian quadratic, but is being lifted to general convex $f_i$ via a state-dependent operator. The reduction is rigorous (Costa-Fragoso-Marques covers Markov jump, but "state-dependent jump" needs more care).
- The qualitative claim (linear convergence for some $\beta>0$) is correct under the stated assumptions; a rate $\rho$ explicit in $\kappa$ is **not** stated — the proof claims existence only.

## Verdict
**CONFIRMED** existential linear convergence. Spectral analysis machinery is the published Loizou-Richtárik / Can et al. method; the integral-Hessian extension to non-quadratic is a careful proof variant rather than a new theorem. No explicit rate, so no constant comparison possible. No contradictions with published results.
