# Conjecture: Polyak–Ruppert κ²-amplification over Cesàro averaging for SHB on SC quadratics

## Setting

Let $f : \mathbb{R}^d \to \mathbb{R}$ be the strongly convex separable quadratic
$$
  f(x) \;=\; \tfrac{1}{2} \sum_{i=1}^{d} \lambda_i \, x_i^2,
  \qquad 0 < \mu := \lambda_{\min} \le \lambda_{\max} =: L,
  \qquad \kappa := L/\mu,
$$
with optimum $f^* = 0$ at $x^* = 0$. Run the deterministic stochastic-heavy-ball (SHB) iteration with constant step $\eta > 0$ and momentum $\beta \in (0,1)$:
$$
  x_{t+1} \;=\; x_t \;-\; \eta\,\nabla f(x_t) \;+\; \beta\,(x_t - x_{t-1}),
  \qquad t = 0, 1, 2, \dots,
$$
with prescribed initial pair $(x_0, x_{-1}) \in \mathbb{R}^{d} \times \mathbb{R}^d$ such that the slow-eigenmode component is non-degenerate (precise condition stated below as Assumption A).

Assume the **stable regime**: for every eigenvalue $\lambda \in [\mu, L]$, the per-coordinate characteristic polynomial $r^2 - (1+\beta - \eta\lambda)\, r + \beta = 0$ has both roots in the open unit disc. Equivalently:
$$
  0 \;<\; \eta\lambda \;<\; 2(1+\beta) \qquad \text{for all } \lambda \in [\mu, L]. \tag{S}
$$

**Important regime clarification.** The asymptotic identity below holds in the **over-damped slow-mode regime**, defined by $\eta\mu < (1-\sqrt\beta)^2$, in which the slow-mode roots are real with the slow root
$$
  r_{1,\mu} \;=\; 1 \;-\; \frac{\eta\mu}{1-\beta}\,(1 + O(\eta\mu/(1-\beta))).
$$
This is the regime numerically validated. (The fast mode at $\lambda=L$ may simultaneously be under-damped without affecting the leading-order analysis, since the L-mode contribution to both averages is $\kappa$-times smaller than the slow-mode contribution.) Under-damped slow-mode (i.e., $\eta\mu \in [(1-\sqrt\beta)^2, (1+\sqrt\beta)^2]$) is **outside the scope** of the present conjecture; numerics suggest a weaker κ-scaling there (PR exponent < 4).

The strong asymptotic regime additionally requires $T \to \infty$ with
$$
  T \cdot \frac{\eta\mu}{1-\beta} \;\to\; \infty
  \quad \text{(slow-mode multiplier $r_{1,\mu}^T \to 0$)}.
$$
Within this regime, the discriminant of the L-mode polynomial may be negative (under-damped fast mode); this does not affect the leading-order asymptotic of either average because $|r_{j,L}| \le \sqrt\beta < 1$ uniformly.

Define two averaged iterates:
$$
  \bar{x}_T \;:=\; \frac{1}{T} \sum_{t=0}^{T-1} x_t, \qquad
  \tilde{x}_T \;:=\; \frac{\sum_{t=0}^{T-1} (t+1)\, x_t}{\sum_{t=0}^{T-1} (t+1)}
  \;=\; \frac{2}{T(T+1)} \sum_{t=0}^{T-1} (t+1)\, x_t.
$$

## Assumption A (slow-mode non-degeneracy)

Let $E_\mu \subseteq \mathbb{R}^d$ be the eigenspace of $\nabla^2 f$ corresponding to the smallest eigenvalue $\mu$ (i.e. the span of $\{e_i : \lambda_i = \mu\}$). Let $P_\mu : \mathbb{R}^d \to E_\mu$ denote the orthogonal projection onto $E_\mu$. Assumption A states:
$$
  P_\mu(x_0 - r_{2,\mu}\, x_{-1}) \;\ne\; 0,
$$
where $r_{1,\mu}, r_{2,\mu}$ are the two roots of the slow-mode characteristic polynomial $r^2 - (1 + \beta - \eta\mu)\,r + \beta = 0$ (in the over-damped slow-mode regime they are real with $r_{1,\mu} > r_{2,\mu}$ and $r_{1,\mu} \to 1$ as $\eta\mu \to 0$).

This rules out exactly cancelling initializations and ensures the slow-mode amplitude $A_\mu \in \mathbb{C} \setminus \{0\}$ in the spectral decomposition.

## Theorem to prove

Under the under-damped stability condition (UD) and Assumption A, the following ratio identity holds:

**Main claim.** As $T \to \infty$ with $(\beta, \eta, \mu, L)$ fixed:
$$
\boxed{\quad
  \frac{f(\tilde{x}_T)}{f(\bar{x}_T)}
  \;=\; \frac{4\,(1 - \beta)^2}{T^2 \, (\eta L)^2}\,\kappa^2 \;\bigl(1 + o(1)\bigr).
\quad}
$$

In particular, $f(\bar{x}_T) = \Theta(\kappa^2 / T^2)$ and $f(\tilde{x}_T) = \Theta(\kappa^4 / T^4)$, so PR averaging is **κ² worse** than Cesàro averaging in the asymptotic constant.

## Proof strategy hint (verify independently — may contain errors)

The conjecture decomposes into 4 lemmas:

**L1 (Spectral decomposition):** Per-coordinate, the recurrence $x_{t+1}^{(\lambda)} = (1+\beta - \eta\lambda) x_t^{(\lambda)} - \beta\, x_{t-1}^{(\lambda)}$ has characteristic roots $r_{1,\lambda}, r_{2,\lambda}$. Under (UD) they are complex conjugates of modulus $|r_{j,\lambda}| = \sqrt{\beta}$. Solution: $x_t^{(\lambda)} = A_\lambda r_{1,\lambda}^t + B_\lambda r_{2,\lambda}^t = 2\,\mathrm{Re}\!\bigl[A_\lambda r_{1,\lambda}^t\bigr]$ for some complex $A_\lambda$ depending on initialization.

**L2 (Cesàro asymptotic for slow mode):** $\bar{x}_T^{(\mu)} = \tfrac{1}{T} \sum_{t=0}^{T-1} 2\mathrm{Re}[A_\mu r_{1,\mu}^t] = \tfrac{2}{T} \mathrm{Re}\!\left[A_\mu \tfrac{r_{1,\mu}^T - 1}{r_{1,\mu} - 1}\right]$. Slow mode dominates: $|1 - r_{1,\mu}|^2 = 1 - 2\sqrt{\beta}\cos\theta_\mu + \beta = \eta\mu$ exactly (a key identity, since $|r_{1,\mu}|^2 = \beta$). Hence $|\bar{x}_T^{(\mu)}| = \Theta(1/(T\sqrt{\eta\mu}))$, giving $f(\bar{x}_T) = \Theta(\mu \cdot 1/(T^2 \eta\mu)) = \Theta(1/(T^2 \eta))$. Substituting $\eta = \eta L / L$ and using $L = \kappa\mu$: $f(\bar{x}_T) = \Theta(\kappa/(T^2 \eta L \mu))$. Wait — this looks dimensionally odd; the κ² in the answer requires careful accounting.

**L3 (PR asymptotic for slow mode):** The weighted sum $\sum_{t=0}^{T-1}(t+1) r^t = \tfrac{1 - (T+1) r^T + T r^{T+1}}{(1-r)^2}$, so $\tilde{x}_T^{(\mu)} = \tfrac{2}{T(T+1)} \cdot \tfrac{2\mathrm{Re}[A_\mu \cdot (1 - (T+1) r_{1,\mu}^T + T r_{1,\mu}^{T+1})/(1-r_{1,\mu})^2]}{1}$. Since $|r_{1,\mu}| = \sqrt\beta < 1$, the $r^T, r^{T+1}$ terms decay; the leading order is $|\tilde{x}_T^{(\mu)}| = \Theta(1/(T^2 |1-r_{1,\mu}|^2)) = \Theta(1/(T^2 \eta\mu))$. Hence $f(\tilde{x}_T) = \Theta(\mu \cdot 1/(T^4 \eta^2 \mu^2)) = \Theta(1/(T^4 \eta^2 \mu))$.

**L4 (Ratio):** $\tfrac{f(\tilde{x}_T)}{f(\bar{x}_T)} = \tfrac{1/(T^4 \eta^2 \mu)}{1/(T^2 \eta)} = \tfrac{1}{T^2 \eta \mu}$. Using $\eta\mu = (\eta L)/\kappa$: ratio $= \kappa / (T^2 \eta L)$.

**WARNING — the hint above is set up for the under-damped regime where $|1-r_{1,\mu}|^2 = \eta\mu$ (exact, by Vieta), and produces $\kappa^1$ for the ratio. The numerical evidence (κ²) is for the OVER-damped slow-mode regime, where $r_{1,\mu}$ is REAL and $1-r_{1,\mu} \approx \eta\mu/(1-\beta)$, giving $(1-r_{1,\mu})^2 \approx (\eta\mu)^2/(1-\beta)^2$. This second-order-in-$\eta\mu$ scaling is what produces the $\kappa^2$ amplification: the slow-mode contribution to the Cesàro average is $\Theta(A/(T(1-r_{1,\mu})))$, scaling as $\kappa$, and to the PR average is $\Theta(A/(T^2(1-r_{1,\mu})^2))$, scaling as $\kappa^2$ — squared in $f$ gives κ² and κ⁴ respectively. Each Explorer must independently verify the over-damped expansion of $1-r_{1,\mu}$ and confirm $r_{1,\mu}^T \to 0$ in the asymptotic regime.

## Numerical evidence

50-digit mpmath sweep across $\kappa \in \{10, 100, 1000, 10000\}$, $\beta \in \{0.5, 0.7, 0.9, 0.95, 0.99\}$, $\eta L \in \{0.5, \dots, 2.9\}$, $T \in \{100, 1000, 10000\}$, two function classes (2-D quadratic and 10-D quadratic with logspaced spectrum), two initializations.

For T = 10000, alt-momentum init (Assumption A holds), 2-D quadratic:
- $f(\bar{x}_T) - f^* \sim \kappa^{1.998 \pm 0.001}$ (R² = 1.000 across 4 decades of κ, every (β, ηL) cell)
- $f(\tilde{x}_T) - f^* \sim \kappa^{3.83 \pm 0.20}$ (R² ≥ 0.99)

Verification at β=0.7, ηL=2.0, T=10000:

| κ | f(Cesàro) | f(PR) | observed PR/Ces | predicted $4(1-\beta)^2 \kappa^2 / (T \eta L)^2$ |
|---|---|---|---|---|
| 10 | 3.62×10⁻⁷ | 5.30×10⁻¹⁴ | 1.46×10⁻⁷ | 9.0×10⁻⁸ |
| 100 | 3.61×10⁻⁵ | 3.43×10⁻¹⁰ | 9.49×10⁻⁶ | 9.0×10⁻⁶ |
| 1000 | 3.61×10⁻³ | 3.27×10⁻⁶ | 9.05×10⁻⁴ | 9.0×10⁻⁴ |
| 10000 | 3.60×10⁻¹ | 3.19×10⁻² | 8.85×10⁻² | 9.0×10⁻² |

Agreement at κ ≥ 100 is within 5%. Predicted constant matches the boxed claim's leading-order term.

## Domain

optimization / lower-bounds (iterate-type κ-separation for averaging schemes).

## Difficulty

**Research-level**. Requires careful spectral analysis of the heavy-ball recurrence in the under-damped regime, exact tracking of the leading-order asymptotic constant in $|1 - r_{1,\mu}|$, and verification that the slow-mode contribution dominates the L-mode contribution to f for both averages.

## Library cross-references

- `proofs/research/optimization/convergence/polyak-ruppert-shb-defeat/` — related result on PR vs cycling for SHB
- `proofs/research/optimization/convergence/shb-pr-average-kappa-blowup/` — related κ-blowup phenomenon (Rank 1 in research index)
- See also: numerical search log at `workspace/proposer/kappa_blowup_search/`
