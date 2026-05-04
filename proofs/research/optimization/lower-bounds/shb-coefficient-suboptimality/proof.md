# Problem 26 — OP-2 Approach 1 Coefficient Suboptimality

## Setup
SHB iterate has the form
$$x_T = x_0 - \sum_{s=0}^{T-1}\alpha_{T,s}^{SHB} g_s,$$
where $g_s = \nabla f(x_s)$ and $\alpha_{T,s}^{SHB}$ are the **exponentially-weighted** coefficients implicitly determined by $\beta$. Specifically, unrolling SHB:
$$\alpha_{T,s}^{SHB} = \eta\sum_{k=s}^{T-1} \beta^{k-s} \cdot[\text{combinatorial factor}] = \eta\cdot\frac{1-\beta^{T-s}}{1-\beta}.$$

Optimal first-order method (e.g., AGD) uses **polynomial weights** $\alpha_{T,s}^{opt}\sim$ Chebyshev-like polynomial coefficients to achieve $O(LD^2/T^2)$.

## Goal
Construct a smooth convex $f$ on which exponential weights are $\Omega(LD^2/T)$ but polynomial weights achieve $O(LD^2/T^2)$, with **the same Krylov subspace** for both.

## Construction

### Step 1. Quadratic instance
Take $f(x) = \tfrac{1}{2}x^\top H x$ with $H = \mathrm{diag}(\lambda_1,\ldots,\lambda_n)$, $\lambda_i\in[\mu,L]$, $\mu/L=\kappa^{-1}$. Initial $x_0 = D\cdot v$ where $v$ is a vector of mass equally distributed on Chebyshev nodes of the spectrum.

Gradients: $g_s = H x_s$. Iterates lie in Krylov subspace $\mathcal K_T = \mathrm{span}(x_0, Hx_0, H^2 x_0,\ldots,H^{T-1}x_0)$ — same for SHB and AGD.

### Step 2. Iterate as polynomial in $H$
For any first-order method, $x_T = p_T(H)x_0$ for some polynomial $p_T$ with $p_T(0)=1$ (consistency).
- For SHB: $p_T^{SHB}(\lambda) = $ polynomial determined by exponential-momentum recurrence; specifically $p_T^{SHB}(\lambda) = (1-\eta\lambda) p_{T-1}^{SHB}(\lambda) + \beta(p_{T-1}^{SHB}(\lambda) - p_{T-2}^{SHB}(\lambda))$ — a quadratic-recurrence polynomial.
- For Chebyshev (optimal): $p_T^{cheb}(\lambda) = T_T((L+\mu-2\lambda)/(L-\mu))/T_T((L+\mu)/(L-\mu))$, the shifted Chebyshev polynomial of degree $T$.

### Step 3. Sub-optimality of exponential weights
$$f(x_T) - f^\star = \tfrac{1}{2}\sum_i \lambda_i (p_T(\lambda_i))^2 (x_0^{(i)})^2.$$
For Chebyshev: $\sup_{\lambda\in[\mu,L]}|p_T^{cheb}(\lambda)| = O((1-\sqrt{\mu/L})^T) \approx O(\exp(-T/\sqrt\kappa))$ for SC case. For convex case ($\mu=0$): $|p_T^{cheb}(\lambda)|\le 4/((T+1)^2 \lambda)$ in suitable scaling, giving $O(LD^2/T^2)$.

For SHB exponential: with optimally-tuned $\beta = (1-\sqrt{\mu/L})/(1+\sqrt{\mu/L})$, $\eta=4/(\sqrt L+\sqrt\mu)^2$:
$p_T^{SHB}(\lambda)$ has the form $\beta^{T/2}\cdot(\text{Chebyshev-like})$ — actually, for quadratic problems, **HB recovers Chebyshev exactly!** Both iterates land at the same point.

This is bad for our construction: HB *equals* Chebyshev on quadratics, so we cannot separate them by **polynomial form** on quadratics.

### Step 4. Non-quadratic separation
**The separation must come from a non-quadratic function** where the algorithm cannot exploit the spectrum.

Consider $f(x_1,x_2) = \tfrac{L}{2}(x_1)^2 + h(x_2)$ where $h$ is a Huber-like function with curvature 0 on $[-D,D]$ and $L$ outside. Optimum at 0.

For $T$ steps, SHB on this function: the $x_2$ component is updated only by gradient + momentum, and since gradient is 0 in the flat region, momentum cycles and SHB converges only slowly.

### Step 5. Honest assessment
The "coefficient suboptimality" framing is delicate:
- On quadratics, fixed-$\beta$ HB **matches** Chebyshev (Polyak's original result), so no separation by coefficients.
- On non-quadratics, both HB and AGD achieve $O(LD^2/T^2)$ if AGD uses $\beta_t = (t-1)/(t+2)$ (time-varying) — but this is changing the algorithm, not just the coefficients.
- For **fixed-$\beta$** HB vs AGD with **polynomial weights** as test points (not the algorithm), the separation comes from the OP-2 cycling lower bound: any *fixed-coefficient* (i.e., not Krylov-adaptive) method is $\Omega(LD^2/T)$ on cycling instances.

### Step 6. Construction (non-quadratic)
Take Goujaud–Taylor–Dieuleveut's hard convex function $f^{(s)}$ used in OP-2 cycling lower bound. On this function:
- SHB with fixed $(\beta,\eta)\in\mathcal F$: $\Omega(LD^2/T)$ by OP-2.
- AGD with $\beta_t = (t-1)/(t+2)$: $O(LD^2/T^2)$ by Nesterov's classical result.

The Krylov subspaces are the same (both are first-order methods), and the polynomial $p_T^{AGD}$ has **polynomially-distributed roots** (matching Chebyshev for $\mu>0$ or the constant-step polynomial for $\mu=0$), while $p_T^{SHB}$ has **exponentially-distributed weights** that fail on non-quadratic.

## Status: PARTIAL

The clean separation requires either:
1. A specific non-quadratic where exponential coefficients fail by $T$-factor (this is what OP-2 achieves via cycling),
2. Showing that on quadratics, both achieve the same rate — so the question only makes sense on non-quadratics.

### Final theorem (PARTIAL form)
**Claim**: On the OP-2 hard instance $f^{(s)}$, fixed-$\beta$ SHB has rate $\Omega(LD^2/T)$ while AGD with time-varying $\beta_t = (t-1)/(t+2)$ has rate $O(LD^2/T^2)$. Both methods generate iterates in the Krylov subspace $\mathcal K_T$, so the separation is by coefficient structure (exponential vs polynomial).

The exponential coefficients $\alpha_{T,s}^{SHB}\sim \beta^{T-s}/(1-\beta)$ saturate quickly (most weight on recent gradients), while polynomial coefficients $\alpha_{T,s}^{AGD}\sim s$ (linear weight on early gradients) allow Nesterov's "negative momentum" cancellation that achieves $1/T^2$.

**Proof of the rate gap** is via OP-2 (LB) + Nesterov 1983 (UB) — both established. $\blacksquare$ (mod citations)

**Status**: PARTIAL — separation theorem stated and reduced to known results, but a fully self-contained proof of the OP-2 LB and Nesterov UB on the same instance is beyond the budget.
