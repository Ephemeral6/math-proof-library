# Notes: SHB interpolation-regime lower bound (S4)

## Proof technique

**Two-part theorem combining two clean arguments:**

1. **Part (A) — Bias survival via noiseless-oracle inclusion.** The OP-2 bias term $\Omega(LD^2/T)$ is established by Goujaud cycling — a purely *deterministic* phenomenon. Since the noiseless oracle is trivially in any interpolation noise class $\mathcal{N}_{\mathrm{int}}(\sigma^2; \rho)$ (zero variance is bounded above by anything non-negative), the OP-2 construction transfers verbatim to the interpolation regime. Constant sharpens from $\kappa/4$ (OP-2) to $\kappa/2$ because the $D$-budget no longer needs to be split with a $y$-coordinate.

2. **Part (B) — Variance impossibility via direct counterexample.** The classical Le Cam $\Omega(\sigma D/\sqrt T)$ argument requires uniformly bounded *below* noise variance, which is incompatible with $\rho(0) = 0$. We exhibit linear convergence on the quadratic $f(x) = (L/2)\|x\|^2$ with multiplicative noise $\xi_t = \sigma\|x_t\|\varepsilon_t$, SHB at $(\beta=0, \eta=1/(2L))$. Direct second-moment recursion gives $\mathbb{E}\|x_T\|^2 = \rho^T D^2$ with $\rho = (1+\sigma^2/L^2)/4$. Exponential decay refutes any polynomial $\Omega(\sigma D/\sqrt T)$ for $T$ large.

## Key steps

1. State $\mathcal{N}_{\mathrm{int}}(\sigma^2; \rho)$ precisely with $\rho(0) = 0$.
2. Note $\rho_0 \equiv 0$ (noiseless oracle) is in every $\mathcal{N}_{\mathrm{int}}$ vacuously.
3. For (A), use OP-2's Goujaud function $f_{\beta,\eta} = D^2\psi(\cdot/D)$, noiseless oracle, full $D$-budget on the 2-D cycling subspace. Get $f(x_T) - f^\star \geq \kappa LD^2/2$ from $\mu$-SC.
4. For (B), set up $f(x) = (L/2)\|x\|^2$, multiplicative oracle. Compute $\mathbb{E}\|x_{t+1}\|^2 = ((1-\eta L)^2 + \sigma^2\eta^2)\mathbb{E}\|x_t\|^2$ — the cross term vanishes by independence and zero-mean.
5. At $(\beta=0, \eta=1/(2L))$: $\rho = (1+\sigma^2/L^2)/4 < 1$ for $\sigma < L\sqrt 3$. For all $\sigma > 0$: optimal tuning $\eta^\star = L/(L^2+\sigma^2)$ gives $\rho^\star = \sigma^2/(L^2+\sigma^2) < 1$.
6. Refutation: $\rho^T \to 0$ exponentially beats $1/\sqrt T$ polynomially.

## Audit result

**Round 1: PASS** with one sharpening fix (FIX-1: constant $\kappa/4 \to \kappa/2$ in Part (A) since no $y$-budget split). All algebra verified. Numerical: 20000-trajectory simulation at $L=D=1$, $d=10$, $T=50$, $\sigma \in \{0, 0.5, 1.0, 1.5\}$. Empirical contraction rates match theoretical $\rho = (1+\sigma^2/L^2)/4$ to 4 decimal places. At $\sigma=1.0, T=50$: empirical $f(x_T) \approx 4.2\cdot 10^{-16}$ vs comparator $\sigma D/\sqrt T \approx 0.14$, ratio $\sim 10^{-15}$.

## Related results

- **OP-2** (`proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/`): the parent theorem in the bounded-variance regime. S4 strictly refines OP-2 by separating the bias and variance terms under interpolation.
- **Vaswani–Bach–Schmidt 2019** (AISTATS, "Fast and faster convergence of SGD for over-parameterized models"): linear convergence of constant-stepsize SGD on smooth strongly-convex functions under interpolation. Matches Part (B) for the quadratic case.
- **Bach 2014** ("Adaptivity of averaged SGD to local strong convexity"): direct second-moment analysis on quadratics with multiplicative noise, providing the template for Part (B).
- **Gower, Loizou, Qian, Sailanbayev, Shulgin, Richtárik 2019** ("SGD: General Analysis and Improved Rates"): expected smoothness framework, broader interpolation rates.
- **Loizou, Vaswani, Laradji, Lacoste-Julien 2021** ("Stochastic polyak step-size for SGD: An adaptive learning rate for fast convergence"): SGD with momentum under interpolation; UB for SHB analogs that complement Part (A).
- **Ghadimi–Feyzmahdavian–Johansson 2015** (arXiv:1412.7457): matching $O(LD^2/T + \sigma D/\sqrt T)$ UB for SHB. Combined with S4 Part (A), the bias rate $\Theta(LD^2/T)$ is tight on $\mathcal{F}$ in the interpolation regime; the variance term is provably absent.

## What's left open

- **(A) with active interpolation noise.** Our (A) uses noiseless oracle for cleanest argument. A perturbation analysis showing the cycle is stable in expectation under small active multiplicative noise would strengthen (A) to a "non-trivial" survival result. Conjecturally true for $\sigma$ small relative to $\kappa L$.
- **(B) for non-multiplicative interpolation models.** Verified for $\rho_1(r) = r^2$. Other models (e.g., $\rho(r) = r$ sub-linear) may admit fractional LBs $\Omega(\sigma^{2/3}(LD^2)^{1/3}/T^{2/3})$ or similar. Open characterization.
- **Universal LB across all algorithms in interpolation regime.** Known results (Liu–Belkin 2020, etc.): accelerated methods achieve $O(LD^2/T^2)$ under interpolation. Our $\Omega(LD^2/T)$ for SHB confirms SHB is sub-optimal — but a tight LB for accelerated methods under interpolation is a separate question.

## Historical context

S4 is the **first interpolation-regime extension** of the OP-2 lower bound family (S1–S5 series). It demonstrates that the bias-vs-variance decomposition in lower bounds is more subtle than it appears: the bias term is invariant to noise model perturbations (because it's purely deterministic), but the variance term collapses when the noise vanishes at the optimum. This is the cleanest "extension" result in the OP-2 series so far — both halves are essentially one-page arguments combining standard tools (OP-2 for bias, Bach 2014 / Vaswani et al. 2019 for variance).
