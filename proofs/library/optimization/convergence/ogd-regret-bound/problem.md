# Online Gradient Descent Regret Bound with Matching Lower Bound

## Source
- Context: Online Convex Optimization (Zinkevich 2003, Hazan 2016)
- Foundational result in online learning theory

## Statement

OCO setting: convex compact $\mathcal{K} \subseteq \mathbb{R}^d$ with diameter $D$, adversarial convex losses $f_t$ with $\|\nabla f_t\|_2 \leq G$.

OGD update: $x_{t+1} = \Pi_\mathcal{K}(x_t - \eta_t \nabla f_t(x_t))$

**(i)** Fixed $\eta = D/(G\sqrt{T})$: $R_T \leq DG\sqrt{T}$

**(ii)** Decreasing $\eta_t = D/(G\sqrt{t})$: $R_T \leq \frac{3}{2}DG\sqrt{T}$

**(iii)** Lower bound: $\exists$ adversary such that $R_T \geq \frac{DG\sqrt{T}}{2\sqrt{2}}$ for any algorithm

## Difficulty
research
