# Notes — SHB Cycling Critical Momentum β* = (√13 − 3)/2

## Proof technique

A two-step algebraic + monotonicity argument:

1. **Factorization**: The combined feasibility-and-stability inequality $(1-c)(1+\beta^2-2\beta c) \leq 2(\beta-c)(1+\beta)$ algebraically factors as
   $$
   (1+c)\,[\beta^2 + 2(1-c)\beta - 1] \;\geq\; 0,
   $$
   isolating a strictly positive sign-factor $(1+c)$ for $K \geq 3$ and a quadratic in $\beta$ whose positive root determines $\beta_{\min}(c)$.

2. **Monotonicity**: With $u = 1 - c$, the positive root is $\varphi(u) := \sqrt{u^2+1} - u = 1/(\sqrt{u^2+1}+u)$, strictly decreasing on $(0, \infty)$. Since $K \mapsto u_K = 1 - \cos(2\pi/K)$ is strictly decreasing for $K \geq 3$, the composition $K \mapsto \varphi(u_K)$ is strictly increasing. Hence $K = 3$ uniquely minimizes.

## Key steps

- Step A: Take small-κ envelope of GTD-cyc to get $(\star_K)$: $(\beta-c_K)L\eta \geq (1-c_K)(1+\beta^2-2\beta c_K)$.
- Step B: Combine with stability $\eta \leq 2(1+\beta)/L$ to get $(\dagger_K)$: $(1-c_K)(1+\beta^2-2\beta c_K) \leq 2(\beta-c_K)(1+\beta)$.
- Step C: Polynomial factorization (Lemma 1).
- Step D: Quadratic positive root selection.
- Step E: Rationalize $\varphi(u) = 1/(\sqrt{u^2+1} + u)$ to read off monotonicity.
- Step F: Discrete minimum over $K \geq 3$ is achieved at the largest $u_K$, i.e. $K = 3$ with $u_3 = 3/2$.
- Step G: Compute $\varphi(3/2) = \sqrt{13/4} - 3/2 = (\sqrt{13} - 3)/2$.

## Audit result

PASS in 0 rounds. 15 attack vectors all checked clean. SymPy confirms the factorization to identity zero; numerical sweep over $K = 3, \ldots, 1000$ confirms the unique minimum at $K = 3$ matching $(\sqrt{13} - 3)/2$ to $2.2 \times 10^{-16}$ precision.

## Related results

- **OP-2** (`shb-no-acceleration-restricted/proof.md`): The parent theorem. OP-2 proved $\mathcal{F}_3 \neq \emptyset$ for $\beta \geq \beta^\star$ but did NOT prove sharpness over $K$. M3 closes this gap.
- **Goujaud–Taylor–Dieuleveut 2023** (arXiv:2307.11291): The original cycling construction. The K=3 case is highlighted but the K-minimization question is not addressed in the paper.
- **GPT 2025 follow-up**: The strongly-convex regime; our $\kappa \to 0$ envelope is the boundary of their parameter family.

## What's left open

The boundary at $\beta = \beta^\star$ is a degenerate single-point witness (η = stability max). The interior $\mathcal{F}_3$ for $\beta > \beta^\star$ is the genuine 2D feasibility region used in OP-2. M3 says nothing about higher-K geometry; it only confirms that no $K \geq 4$ improves the threshold β. (Higher-K regions $\mathcal{F}_K$ are non-empty for β closer to 1 and play a role only in the upper-β regime.)

## Connection to OP-2

OP-2 stated (`proof.md` line 49): "At larger K, $\mathcal{F}$ expands." This phrase is correct in the sense that $\mathcal{F}_K$ for higher $K$ covers parts of $\mathcal{S}$ near $\beta = 1$ that $\mathcal{F}_3$ doesn't reach (since γ_crit,K(β) for K large can be < γ_crit,3(β) when β is large). But for the threshold-β question, M3 shows the OPPOSITE direction matters: as $K$ increases, $\beta_{\min}(c_K) \uparrow 1$, so higher K cannot lower the threshold below $\beta^\star$. K=3 is the K-cycle that maximizes the size of $u_K$ (and hence minimizes $\beta_{\min}$), and it does so uniquely.

## Use case

This sharpness result is a meta-theorem clarifying the structure of the OP-2 lower-bound region $\mathcal{F}$. It implies that **any future improvement of OP-2's lower bound to cover $\beta < \beta^\star$ cannot use Goujaud's construction** — a non-Goujaud hard instance is required. This formalizes the "structural obstruction" comment in OP-2 §9.2.
