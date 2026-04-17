# Strong Duality via Slater's Condition

## Source
- Paper: Slater 1950; Boyd & Vandenberghe 2004 "Convex Optimization" Section 5.2.3
- Context: Fundamental result ensuring zero duality gap in convex optimization. Slater's constraint qualification is the most widely-used sufficient condition for strong duality.

## Statement

**Theorem (Slater's Condition implies Strong Duality).** Consider the convex optimization problem:

$$\min_{x} \quad f_0(x) \quad \text{s.t.} \quad f_i(x) \leq 0, \; i = 1, \ldots, m, \quad Ax = b$$

where $f_0, f_1, \ldots, f_m$ are convex functions and the domain $\mathcal{D} = \bigcap_{i=0}^m \text{dom}(f_i)$ is nonempty.

**Slater's condition**: There exists a point $\hat{x} \in \text{relint}(\mathcal{D})$ such that:
$$f_i(\hat{x}) < 0, \quad i = 1, \ldots, m, \quad A\hat{x} = b.$$

**Conclusion**: If Slater's condition holds and $p^* = \inf f_0(x) > -\infty$, then:
1. Strong duality holds: $p^* = d^*$ where $d^* = \sup_{\lambda \geq 0, \nu} \inf_x L(x, \lambda, \nu)$
2. The dual optimum is attained: there exist $\lambda^*, \nu^*$ achieving $d^*$

## Difficulty
research
