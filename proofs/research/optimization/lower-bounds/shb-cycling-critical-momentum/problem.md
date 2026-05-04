# SHB Cycling Critical Momentum — Sharp Threshold β* = (√13 − 3)/2

## Source
- Paper: meta-result on Goujaud–Taylor–Dieuleveut 2023 (arXiv:2307.11291).
- Context: Companion to OP-2 (`proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/`). OP-2 establishes that $\mathcal{F}_3 \neq \emptyset$ when $\beta \geq \beta^\star := (\sqrt{13}-3)/2$, but does not prove that this $\beta^\star$ is the sharp infimum over all $K \geq 3$. M3 closes that gap.

## Statement

Fix $L > 0$. Let
$$
\mathcal{S} \;=\; \{(\beta,\eta) \in [0,1) \times \mathbb{R}_{>0} : \eta \leq 2(1+\beta)/L\},
$$
let $c_K = \cos(2\pi/K)$, and define the Goujaud cycling feasibility region (small-κ envelope) at the K-cycle as
$$
\mathcal{F}_K \;=\; \{(\beta,\eta) \in \mathcal{S} : \beta > c_K \text{ and } (\beta - c_K)L\eta \geq (1 - c_K)(1 + \beta^2 - 2\beta c_K)\},
$$
and $\mathcal{F} = \bigcup_{K \geq 3} \mathcal{F}_K$. Define
$$
\beta^\star \;=\; \inf\{\beta \in [0,1) : \exists\, K \geq 3,\ \exists\, \eta > 0 \text{ with } (\beta,\eta) \in \mathcal{F}_K\}.
$$

**Theorem.** $\beta^\star = (\sqrt{13} - 3)/2 \approx 0.3027756377$, the infimum is a minimum, and the witnessing $K$ is uniquely $K = 3$.

Concretely:
- For $\beta > \beta^\star$, the set $\{\eta : (\beta,\eta) \in \mathcal{F}_3\} = [\gamma_3(\beta)/L, 2(1+\beta)/L]$ is a non-degenerate closed interval, with $\gamma_3(\beta) = 3(1+\beta+\beta^2)/(1+2\beta)$.
- For $\beta < \beta^\star$ and any $K \geq 3$, $\mathcal{F}_K \cap (\{\beta\} \times \mathbb{R}_{>0}) = \emptyset$.
- At $\beta = \beta^\star$, $K = 3$, $\eta = 2(1+\beta^\star)/L$, the feasibility inequality holds with equality (single-point boundary witness).

## Difficulty
research (algebraic / monotonicity meta-theorem on a 2023 construction).
