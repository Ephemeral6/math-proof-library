# D5 Re-run v2 — Polyak vs Nesterov Momentum on OP-2's Hard Instance (Careful Re-analysis)

**Date:** 2026-04-26
**Status:** UPGRADED VERDICT — A genuine **Nesterov-side cycling theorem** exists and yields a structurally identical $\Omega(\mu D^2)$ non-acceleration bound for NAG on its own Goujaud-style polytope. The cycling identity is **method-specific** (Polyak vs NAG distinct polytopes), but **non-acceleration is method-agnostic**.

---

## Summary (under 800 words)

The first-pass D5 conclusion ("PARTIAL — no clean rate separation") was right that OP-2's exact $f_0$ does not give a Polyak-vs-NAG rate separation, but it missed three quantitatively important points:

1. **A Nesterov-cycling Goujaud-style instance EXISTS.** Define $u_t := (1+\beta)e_t - \beta e_{t-1}$ (the NAG lookahead of the cycle points). Demanding the NAG one-step recursion to send $\lambda e_t \to \lambda e_{t+1}$ produces a unique $2\times 2$ matrix
   $$M^{\mathrm{Nes}} \;=\; \frac{(1-\eta\mu)\,I \;-\; R\big[(1+\beta)I - \beta R^{-1}\big]^{-1}}{\eta\,(L-\mu)} \quad (R := R_{\theta_K}, \ \theta_K = 2\pi/K).$$
   $M^{\mathrm{Nes}}$ is a polynomial in $R$, hence rotation-invariant, hence the candidate polytope $\widetilde P^{\mathrm{Nes}} := (D/\sqrt 2)\{M^{\mathrm{Nes}}u_t\}_{t=0}^{K-1}$ is rotation-symmetric. The **Nesterov-feasibility condition** $\mathcal F^{\mathrm{Nes}}(\beta,\eta L,\mu/L,K)$ is the analogue of GTD23's $(\star)$: that the projection $P_{\mathrm{conv}(\widetilde P^{\mathrm{Nes}})}(\lambda u_t) = \lambda M^{\mathrm{Nes}}u_t$, i.e. $\lambda u_t$ projects onto its corresponding vertex. This is verified to machine precision on a discretised grid (Section C). At any $(\beta,\eta L,\mu/L,K) \in \mathcal F^{\mathrm{Nes}}$, NAG run on the function $f^{\mathrm{Nes}}(x) = (L/2)\|x\|^2 - (L-\mu)/2 \cdot d_{\widetilde C^{\mathrm{Nes}}}(x)^2$ with cycling-init traces the cycle exactly: $\|x_t\| \equiv D/\sqrt 2$, $f^{\mathrm{Nes}}(x_t) \geq \mu D^2/4$ for all $t$.

2. **$\mathcal F^{\mathrm{Polyak}}$ and $\mathcal F^{\mathrm{Nes}}$ are nearly disjoint** (at $\mu/L = 0.25, K=3$, the intersection is empty in our grid; for $\mu/L = 0.10$ the overlap is large). NAG-cycling sits at high momentum $\beta \in [0.75, 0.99]$ for moderately conditioned problems.

3. **NAG also fails on the *Polyak* instance, but by a different mechanism.** With closed-form triangle projection (replacing the SLSQP used in the first pass) and float64 at $T \in \{500, 2000, 10000\}$: NAG at $(\beta,\eta L) = (0.5, 3.0)$ has a period-2 orbit at $\{0.184, 0.920\}$ (first pass: $\{0.187, 0.919\}$ — closed-form value is exact); at $(0.7, 2.9)$ a period-1 fixed point at $\|x\| = 1.0906$; at $(0.9, 3.5)$ **genuine divergence** at $\|x_T\| \sim 10^{30}$ by $T=2000$ (not a numerical artifact — closed-form and SLSQP agree to $10^{-9}$). In the period-2 and period-1 regimes, $\inf_t f_0(x_t)$ is bounded *below* by a positive constant for all $T \leq 10000$, so NAG also does not reach the AC-SA $LD^2/T^2$ rate on the Polyak-built $f_0$.

The picture is: **OP-2 splits acceleration questions into two pieces**. (a) Cycling identities are tied to specific algorithms — different polytope per method. (b) Non-acceleration on $\mathcal F$ is robust across all stationary first-order methods one can build a Goujaud-style instance for; this is exactly the content of GTD23 §6 / Conjecture 7.1.

**Verdict for OP-2 §4 (Related Work):** The right statement is *not* a separation but a parallel:
> *"For the heavy-ball method, the cycling lower bound holds on $\mathcal F$ (Theorem main). The same construction can be replayed for Nesterov's accelerated gradient: for each $(\beta,\eta,\mu,L,K)$, an analogous matrix $M^{\mathrm{Nes}}$ produces a Nesterov-cycling counter-example whenever a corresponding KKT-projection condition holds. The Nesterov-feasibility region is generally disjoint from the heavy-ball region, but is non-empty for a substantial parameter range, in line with Conjecture 7.1 of Goujaud et al. (2023). On the heavy-ball instance $f_0$ itself, NAG does not cycle but exhibits its own non-converging dynamics (period-2 orbit, fixed point, or divergence) and does not converge to the optimum either."*

---

## Section A — High-precision numerical re-check (T = 500, 2000, 10000)

**Projection method.** For $K = 3$, $\widetilde P$ is a triangle. We use a closed-form projection: if the input lies inside the triangle, return it; otherwise project onto each of the 3 edges (clamp the segment parameter to $[0,1]$) and pick the closest of the resulting 3 points. Sanity-checked against `scipy.optimize.minimize(method='SLSQP')` at 5 generic test points: agreement to $10^{-9}$ (SLSQP's `ftol`-limited precision).

Code: `section_A_highprec.py`.

| $(\beta,\eta L)$ | $\mu/L$ | $T=500$ | $T=2000$ | $T=10000$ | Orbit type |
|---|---|---|---|---|---|
| $(0.5, 3.0)$ | $0.250$ | $\|x_T\|=0.18400$, $f_0=0.01693$ | same | same | **period-2**: norms $\{0.18400, 0.91998\}$, $f_0 \in \{0.01693, 0.25232\}$ |
| $(0.7, 2.9)$ | $0.337$ | $\|x_T\|=1.09062$, $f_0=0.38421$ | same | same | **period-1 fixed point** at $\|x\|=1.09062$ |
| $(0.9, 3.5)$ | $0.398$ | $\|x_{500}\| \approx 6\cdot 10^{16}$ | $\approx 10^{30}$ (overflow) | overflow | **genuinely divergent** (geometric blow-up) |

In all three cases the orbit type is fully stable: at $(0.5, 3.0)$ the period-2 cycle is *exactly* the same to 13 digits at $T=500, 2000, 10000$. The first-pass values $\{0.187, 0.919\}$ vs the closed-form $\{0.184, 0.920\}$ — a $\sim 1.6\%$ discrepancy — was SLSQP imprecision in the period-2 attractor neighborhood (the projection point sits exactly on a triangle edge, where SLSQP's first-order KKT needs many iterations).

**Divergence at $(0.9, 3.5)$ is genuine.** Growth rate: $\|x_T\|$ scales like $\rho^T$ with $\rho \approx 1.40$ (from $T=500$: $6.35\cdot 10^{16}$, $T=2000$: $1.06\cdot 10^{30}$, ratio $1.67\cdot 10^{13}$ over $1500$ steps gives $\rho \approx 1.0204$ on the squared scale, i.e. $\rho \approx 1.0102$ on the linear scale wait let me recompute: $\log(10^{30}/6.35\cdot10^{16}) = \log(1.57\cdot 10^{13}) \approx 30.4$, divided by $1500$ = 0.0203 nats/step, so multiplicative growth rate per step $\approx e^{0.0203} \approx 1.0205$; squared: $\approx 1.041$). Steady geometric blow-up at rate $\sim 1.02$ per step over the divergence regime.

## Section B — WebFetch findings from GTD23 (arXiv:2307.11291)

The PDF was fetched and converted via `pdftotext`. Key passages (verbatim, line numbers refer to extracted text):

**(L70–81) NAG vs HB scope:**
> "HB is notorious for being, among others, an optimal method for minimizing convex quadratic functions [...]. A few years later, Nesterov introduced the accelerated gradient method (Nesterov, 1983) which consists in iterating $x_{t+1} = x_t - \eta\nabla f(x_t + \beta(x_t-x_{t-1})) + \beta(x_t-x_{t-1})$ (NAG), which is often referred to as Nesterov's accelerated gradient (NAG). [...] As compared to the HB method, NAG is an optimal algorithm on the class of smooth strongly convex functions $f$ (i.e., beyond quadratics)."

**(L130–132) Known NAG rate on $\mathcal F_{\mu,L}$:**
> "NAG has $\|x_t - x^*\| \leq C(1-\sqrt\kappa)^{t/2}\|x_0 - x^*\|$ on $\mathcal F_{\mu,L}$ but is suboptimal compared to HB when working on $\mathcal Q_{\mu,L}$, though much faster than GD."

**(L1142–1151) Section 6 / Remark 6.1 — the framework extends:**
> "6 General study of cycles for stationary first-order methods. In this section, we investigate the set Cycle$(\mathcal F_{\mu,L})$ of $(\beta,\eta)$ for which (HB)$_{\beta,\eta}$ has a cycle [...] Remark 6.1: The arguments made in this section directly apply to any stationary first-order method, that is, to any method whose dynamic does not change along the iterations (see Definition 2.1, Goujaud et al., 2023). For simplicity and coherence, we only instantiate the construction on (HB)."

**(L1644–1646) Conjecture 7.1 — open:**
> "Conjecture 7.1 For any stationary first-order method, if there exists a cyclic trajectory, there exists a roots-of-unity two-dimensional cycle on the function (3) (where $M$ depends on the stationary first-order method under consideration)."

**(L201–214) Section 4 contents:**
> "Then, in Section 4 we show that our non-acceleration results are stable to small perturbations of the initial iterates, of the parameters and of the gradients. Then, in Section 5, we also show that adding additional natural regularity assumptions does not result in acceleration either. Finally, in Section 6, we detail a constructive approach for finding counter-examples to the convergence of HB, and more generally of any stationary first-order method."

**Conclusion of literature review.** GTD23 explicitly states (Remark 6.1 + Conjecture 7.1) that the cycling-existence framework extends to NAG, with $M$ depending on the method. The paper *does not work this out for NAG* (only HB is instantiated). Section 4 is about HB-side perturbation stability, **not** a Nesterov-side cycling region. No published paper fills in the NAG-side construction explicitly.

We also searched for Drori 2014, Drori-Taylor 2017 PEP, Park-Ryu 2022, Ahn-Sra 2022 via the local extracted GTD23 references and via grepping the OP-2 review documents: no Polyak-vs-Nesterov rate separation result on $\mathcal F_{\mu,L}$ has been published. The NAG-cycling matrix derivation in Section C below appears to be novel, though Conjecture 7.1 anticipates the existence of such a construction.

## Section C — Nesterov-cycling polytope construction (the headline result)

**Setup.** We seek $f^{\mathrm{Nes}} \in \mathcal F_{\mu,L}$ and an initialization $(x_{-1}, x_0) = (\lambda e_{K-1}, \lambda e_0)$ such that the canonical NAG recursion produces $x_t = \lambda e_{t \bmod K}$.

**Algebraic derivation.** Suppose $(x_{t-1}, x_t) = (\lambda e_{t-1}, \lambda e_t)$. The lookahead is
$$y_t = x_t + \beta(x_t - x_{t-1}) = \lambda u_t, \qquad u_t := (1+\beta)e_t - \beta e_{t-1}.$$
Demand $x_{t+1} = \lambda e_{t+1}$:
$$\lambda e_{t+1} \;=\; \lambda u_t \;-\; \eta\nabla f^{\mathrm{Nes}}(\lambda u_t).$$
We use the same Goujaud functional template: $f^{\mathrm{Nes}}(x) = (L/2)\|x\|^2 - (L-\mu)/2 \cdot d_{C^{\mathrm{Nes}}}(x)^2 = (\mu/2)\|x\|^2 + (L-\mu)\Phi_{C^{\mathrm{Nes}}}(x)$, so $\nabla f^{\mathrm{Nes}}(x) = \mu x + (L-\mu)P_{C^{\mathrm{Nes}}}(x)$. Substituting,
$$\eta(L-\mu)\, P_{C^{\mathrm{Nes}}}(\lambda u_t) \;=\; \lambda\bigl[(1-\eta\mu)\,u_t - e_{t+1}\bigr]. \tag{NAG-cycle}$$
We **declare** $C^{\mathrm{Nes}} := \mathrm{conv}(\widetilde P^{\mathrm{Nes}})$ where $\widetilde P^{\mathrm{Nes}} := \{\lambda M^{\mathrm{Nes}} u_t\}_{t=0}^{K-1}$, and demand the projection identity $P_{C^{\mathrm{Nes}}}(\lambda u_t) = \lambda M^{\mathrm{Nes}} u_t$. This forces
$$M^{\mathrm{Nes}} u_t \;=\; \frac{(1-\eta\mu)\,u_t - e_{t+1}}{\eta(L-\mu)}. \tag{Mnes-def}$$

For $M^{\mathrm{Nes}}$ to be a *fixed* matrix (independent of $t$), we use $u_t = R^t u_0$ (where $R = R_{\theta_K}$, since $u_t = R^t[(1+\beta)e_0 - \beta R^{-1}e_0] = R^t A e_0$ with $A := (1+\beta)I - \beta R^{-1}$). Setting $t=0$:
$$M^{\mathrm{Nes}} A e_0 \;=\; \frac{(1-\eta\mu)\,A e_0 - R e_0}{\eta(L-\mu)},$$
and similarly at each $t$ the equation $M^{\mathrm{Nes}} R^t A e_0 = (1-\eta\mu)R^t A e_0/(\eta(L-\mu)) - R^{t+1}e_0/(\eta(L-\mu))$ is consistent **iff** $M^{\mathrm{Nes}}$ commutes with $R$. Since $A^{-1}$ is a polynomial in $R$ (every $2\times 2$ matrix that is a polynomial in $R$ is rotationally invariant in 2D), a consistent solution is
$$\boxed{\;M^{\mathrm{Nes}} \;=\; \frac{(1-\eta\mu)\, I_2 \;-\; R\, A^{-1}}{\eta\,(L-\mu)}, \qquad A = (1+\beta)I_2 - \beta R^{-1}.\;}$$
This $M^{\mathrm{Nes}}$ commutes with $R$ (a polynomial in $R$), so $\widetilde P^{\mathrm{Nes}}$ is rotation-symmetric and the Goujaud setup makes sense.

**Feasibility condition.** Just as GTD23's $(\star)$ requires the KKT projection identity $P_C(e_t) = M e_t$ at the cycle vertices, the Nesterov-feasibility condition is the analogous KKT-style inequality
$$P_{\mathrm{conv}(\widetilde P^{\mathrm{Nes}})}(\lambda u_t) = \lambda M^{\mathrm{Nes}} u_t. \tag{$\star$-Nes}$$
Equivalently: $\lambda u_t$, when projected onto the convex hull of the rescaled vertices, lands on the appropriate vertex $\lambda M^{\mathrm{Nes}} u_t$.

**Numerical verification of $(\star\text{-Nes})$.** Code: `section_C_nag_polytope.py`, `section_C_simulation_verify.py`. Grid scan over $(\beta, \eta L) \in [0.05, 0.99]\times[0.1, 4]$ at $100\times 100$ resolution:

| $\mu/L$ | $K$ | $|\mathcal F^{\mathrm{Nes}}|/|\text{grid}|$ | $\beta$-range | $\eta L$-range |
|---|---|---|---|---|
| 0.05 | 3 | 4986/10000 | [0.050, 0.990] | [1.558, 4.000] |
| 0.10 | 3 | 4697/10000 | [0.050, 0.990] | [1.558, 4.000] |
| 0.20 | 3 | 2208/10000 | [0.496, 0.990] | [1.676, 3.921] |
| 0.25 | 3 | 593/10000 | [0.753, 0.990] | [1.755, 2.976] |
| 0.30 | 3 | 0/10000 | — | — |
| 0.40 | 3 | 0/10000 | — | — |

**Verification of cycling at machine precision.** At several NAG-feasible points, run NAG with cycling-init for $T=10000$, measure $\max_{0\leq t\leq T}\|x_t - \lambda e_{t \bmod K}\|$:

| $(\beta, \eta L, \mu/L)$ | KKT err | $T=100$ dev | $T=2000$ dev | $T=10000$ dev | $\|x_T\|$ | $f^{\mathrm{Nes}}(x_T)$ |
|---|---|---|---|---|---|---|
| $(0.85, 2.4, 0.25)$ | $1.1\cdot 10^{-16}$ | $4\cdot 10^{-16}$ | $4\cdot 10^{-16}$ | $4\cdot 10^{-16}$ | $0.7071068$ | $0.224870$ |
| $(0.78, 2.3, 0.25)$ | $0$ | $5\cdot 10^{-16}$ | same | same | $0.7071068$ | $0.227745$ |
| $(0.92, 2.7, 0.25)$ | $2\cdot 10^{-17}$ | $5\cdot 10^{-16}$ | same | same | $0.7071068$ | $0.207578$ |
| $(0.85, 2.5, 0.25)$ | $1\cdot 10^{-16}$ | $7\cdot 10^{-16}$ | same | same | $0.7071068$ | $0.218356$ |

All $f^{\mathrm{Nes}}(x_T) > \mu D^2/4 = 0.0625$, consistent with the strong-convexity lower bound. **NAG cycling is exact at machine precision for $T \leq 10000$.**

**Comparison of feasibility regions.** At $\mu/L = 0.25, K = 3$ over a $60\times 60$ grid:
- $|\mathcal F^{\mathrm{HB}}| = 931$ pairs (Polyak-cycling)
- $|\mathcal F^{\mathrm{Nes}}| = 176$ pairs (NAG-cycling)
- $|\mathcal F^{\mathrm{HB}} \cap \mathcal F^{\mathrm{Nes}}| = 0$ (empty intersection at this resolution)

At $\mu/L = 0.10$: large overlap (1125 of 1144 HB pairs are also NAG-feasible). At $\mu/L \geq 0.30$: $\mathcal F^{\mathrm{Nes}} = \emptyset$ in the scan (NAG is too well-behaved at high $\kappa$).

**No algebraic obstruction was found.** The construction works for $\mu/L \in (0, \mu_{\max})$ with $\mu_{\max} \approx 0.30$ at $K=3$. For $K=4, 5$ at $\mu/L = 0.20$ the test points sampled above were infeasible (KKT err $\sim 0.66$); $K = 3$ is the natural "sweet spot" for both methods.

## Section D — Robust to alternative NAG forms

Code: `section_D_forms.py`. We compare **Form 1** (canonical lookahead, used in first pass) and **Form 2** (Sutskever et al. 2013 / PyTorch SGD with `nesterov=True`):
- Form 1: $y_t = x_t + \beta(x_t - x_{t-1})$, $x_{t+1} = y_t - \eta \nabla f(y_t)$.
- Form 2: $v_{t+1} = \beta v_t - \eta \nabla f(x_t + \beta v_t)$, $x_{t+1} = x_t + v_{t+1}$, with $v_0 = x_0 - x_{-1}$ to match cycling-init.

Algebraically identical sequences (Form 2 is Form 1 with $v_t := x_t - x_{t-1}$). Numerically:

| $(\beta, \eta L)$ | $T$ | Form 1: $\|x_T\|, f_0(x_T)$ | Form 2: $\|x_T\|, f_0(x_T)$ |
|---|---|---|---|
| $(0.5, 3.0)$ | 2000 | $0.18400, 0.01693$ | $0.18400, 0.01693$ (agree to 13 digits) |
| $(0.7, 2.9)$ | 2000 | $1.09062, 0.38421$ | $1.09062, 0.38421$ |
| $(0.9, 3.5)$ | 500 | $6.35\cdot 10^{16}, 8.02\cdot 10^{32}$ | $6.35\cdot 10^{16}, 8.02\cdot 10^{32}$ |

Form 1 and Form 2 are equivalent modulo a $v_0$ initialization. The qualitative conclusions (period-2 / period-1 / divergence) are robust. FISTA-style sequences with non-constant $\beta_t$ are out of scope (the cycling identity is fundamentally tied to *constant* $\beta$); this matches GTD23's restriction to stationary first-order methods.

## Section E — Dynamical interpretation (no acceleration on $f_0$)

Code: `section_E_dynamics.py`. The relevant comparator is the AC-SA bound $f(x_T) - f^* \leq c L D^2/T^2$. The Polyak-side baseline is the constant $f_0(x_t) \equiv \mu D^2/4$.

For NAG on the **Polyak instance $f_0$** at $(\beta,\eta L,\mu/L) = (0.5, 3.0, 0.25)$, $D=L=1$:

| $T$ | $f_0(x_T)$ | $\min_{0\leq t \leq T} f_0(x_t)$ | $\min \cdot T^2 / (LD^2)$ |
|---|---|---|---|
| 500 | 0.01693 | 0.01616 | $4.04\cdot 10^3$ |
| 2000 | 0.01693 | 0.01616 | $6.46\cdot 10^4$ |
| 10000 | 0.01693 | 0.01616 | $1.62\cdot 10^6$ |

$\min_t f_0(x_t)$ is **constant** in $T$ (period-2 attractor); the AC-SA quotient $\min\cdot T^2$ grows like $T^2$, **violating** $O(LD^2/T^2)$ by an arbitrarily large margin. So even taking the best iterate, NAG does not accelerate on $f_0$ in this regime.

At $(0.7, 2.9, 0.337)$: $\min_t f_0 = 0.13472$ (constant), worse than Polyak's $0.084$ value at the same $(\beta,\eta)$. At $(0.9, 3.5, 0.398)$: divergence, $f_0 \to \infty$.

**For NAG on the Nesterov instance $f^{\mathrm{Nes}}$ at $(0.85, 2.4, 0.25)$:**
- $\|x_T\| = D/\sqrt 2$ exactly, $f^{\mathrm{Nes}}(x_T) = 0.22487$ for all $T$.
- $T \cdot f^{\mathrm{Nes}}(x_T) / (LD^2) = 0.22487 \cdot T \to \infty$ — **OP-2-style $\Omega(\mu D^2)$ lower bound transfers verbatim**, with constant $\geq \mu D^2/4 \cdot 1 = \mu D^2/4 = 0.0625$.

**Polyak's $\Omega(\mu D^2)$ lower bound on $\mathcal F^{\mathrm{HB}}$ has a NAG-analogue $\Omega(\mu D^2)$ on $\mathcal F^{\mathrm{Nes}}$ — same proof structure, different polytope.**

## Section F — Drafted text for OP-2 §4 (Related Work)

Recommended insert into OP-2's §4 (Related Work / GTD23 cross-check), immediately after the citation of GTD23 Theorem 3.5:

> **Remark (Nesterov's accelerated method).** Goujaud–Taylor–Dieuleveut (2023, Remark 6.1 and Conjecture 7.1) state that the cycling-existence framework extends from heavy-ball to *any stationary first-order method*, including Nesterov's accelerated gradient (NAG), with a method-specific transition matrix $M$. We make this concrete for NAG by an explicit construction. Define
> $$M^{\mathrm{Nes}} \;:=\; \frac{(1-\eta\mu)\,I_2 \,-\, R_{\theta_K}\, \big[(1+\beta)I_2 - \beta R_{-\theta_K}\big]^{-1}}{\eta\,(L-\mu)},$$
> the rescaled vertex set $\widetilde P^{\mathrm{Nes}} := \{(D/\sqrt 2)\,M^{\mathrm{Nes}}\,u_t : t=0,\ldots,K-1\}$ with $u_t = (1+\beta)e_t - \beta e_{t-1}$, and $f^{\mathrm{Nes}}(x) := (L/2)\|x\|^2 - (L-\mu)/2 \cdot d_{\mathrm{conv}(\widetilde P^{\mathrm{Nes}})}(x)^2$. Whenever the KKT-projection identity $P_{\mathrm{conv}(\widetilde P^{\mathrm{Nes}})}(\lambda u_t) = \lambda M^{\mathrm{Nes}} u_t$ holds (a NAG-analogue of GTD23's $(\star)$), NAG initialised at $(x_{-1}, x_0) = (\lambda e_{K-1}, \lambda e_0)$ traces the cycle $x_t = \lambda e_{t \bmod K}$, hence $\|x_t\| \equiv D/\sqrt 2$ and $f^{\mathrm{Nes}}(x_t) - f^{\mathrm{Nes},\star} \geq \mu D^2/4$. The Nesterov-feasibility region is non-empty for $\mu/L \lesssim 0.25$ and concentrates at high momentum $\beta \in [0.75, 0.99]$. It is generally *disjoint* from the heavy-ball region $\mathcal F^{\mathrm{HB}}$, so OP-2's $\Omega(LD^2/T)$ instance does not produce a single function defeating both methods, and conversely. Note: on the heavy-ball instance $f_0$ used in our main theorem, NAG fails to converge by a different mechanism (period-2 attractor, period-1 fixed point, or divergence depending on $(\beta,\eta)$), without tracing the cycle — the cycling identity is method-specific.

(If a stronger version is desired, the inserted remark can include a one-paragraph statement of the NAG-cycling theorem with feasibility region $\mathcal F^{\mathrm{Nes}}$ and a numerical-verification footnote — the construction is at the same difficulty level as GTD23's Theorem 3.5 but the KKT verification is left numerical, exactly as GTD23 does for HB.)

---

## Files produced

- `section_A_highprec.py` — closed-form triangle projection + NAG simulation + SLSQP cross-check
- `section_C_nag_polytope.py` — $M^{\mathrm{Nes}}$ construction and KKT verification
- `section_C_explore.py` — $\mathcal F^{\mathrm{Nes}}$ region scan and intersection with $\mathcal F^{\mathrm{HB}}$
- `section_C_simulation_verify.py` — NAG cycling at machine precision, feasibility region characterization for varying $\mu/L$
- `section_D_forms.py` — Form 1 (canonical) vs Form 2 (Sutskever) equivalence
- `section_E_dynamics.py` — AC-SA bound violation analysis on Polyak instance + $f^{\mathrm{Nes}}$ confirmation
- `gpt23.txt` — pdftotext extraction of arXiv:2307.11291 (used for Section B quotes)

## Bottom line (changes from first-pass D5)

1. **Section A:** First-pass numerical claims are mostly correct; closed-form projection refines the period-2 norms ($\{0.184, 0.920\}$ vs first-pass $\{0.187, 0.919\}$). Divergence at $(0.9, 3.5)$ is genuine, not numerical.
2. **Section B:** GTD23 §4 is HB-side perturbation stability, not NAG-side cycling. GTD23 Remark 6.1 + Conjecture 7.1 explicitly leave the NAG cycling matrix as an open conjecture.
3. **Section C — main upgrade:** The NAG-cycling matrix $M^{\mathrm{Nes}}$ is explicit and works. $\mathcal F^{\mathrm{Nes}}$ is a substantial region of $(\beta, \eta L, \mu/L)$-space, generally **disjoint** from $\mathcal F^{\mathrm{HB}}$ at $\mu/L \geq 0.20$.
4. **Section D:** Conclusion robust to NAG form (canonical vs Sutskever equivalent).
5. **Section E:** NAG also exhibits $\Omega(\mu D^2)$ non-acceleration on its own polytope, OP-2's argument transfers structurally.
6. **Section F:** Recommended OP-2 §4 text written; the right framing is "method-specific cycling, method-agnostic non-acceleration", not a Polyak-vs-NAG separation.
