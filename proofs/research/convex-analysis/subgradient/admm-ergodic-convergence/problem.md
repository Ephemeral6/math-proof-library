# ADMM Ergodic O(1/T) Convergence Rate

## Source
- Paper: He & Yuan (2012), "On the $O(1/n)$ convergence rate of the Douglas–Rachford alternating direction method", SIAM J. Numer. Anal. 50(2): 700–709.
- Context: Classical 2-block ADMM for linearly constrained convex composite optimization. The ergodic (averaged-iterate) $O(1/T)$ rate on the primal–dual gap is one of the most cited results in modern first-order methods and the template for many later splitting analyses (Chambolle–Pock, Davis–Yin). The library currently has Douglas–Rachford, Chambolle–Pock, and Davis–Yin 3-op splitting but is missing the flagship ADMM rate — this fills the gap.

## Setup

Consider the convex composite problem with a linear coupling constraint:
$$\min_{x \in \mathbb{R}^{n_1},\, z \in \mathbb{R}^{n_2}} \ f(x) + g(z) \qquad \text{subject to}\qquad A x + B z = c,$$
where
- $f : \mathbb{R}^{n_1} \to \mathbb{R} \cup \{+\infty\}$ is proper, closed, convex;
- $g : \mathbb{R}^{n_2} \to \mathbb{R} \cup \{+\infty\}$ is proper, closed, convex;
- $A \in \mathbb{R}^{m \times n_1}$, $B \in \mathbb{R}^{m \times n_2}$, $c \in \mathbb{R}^m$;
- The feasible set is nonempty and the KKT system admits at least one saddle point $(x^\star, z^\star, \lambda^\star)$ of the augmented Lagrangian
$$\mathcal{L}_\beta(x,z,\lambda) = f(x) + g(z) + \langle \lambda,\, A x + B z - c \rangle + \tfrac{\beta}{2}\|Ax+Bz-c\|^2.$$

Fix a penalty parameter $\beta > 0$. The standard 2-block ADMM iteration is
$$\begin{aligned}
x^{k+1} &= \arg\min_{x}\; f(x) + \tfrac{\beta}{2}\big\|Ax + Bz^k - c + \lambda^k/\beta\big\|^2,\\
z^{k+1} &= \arg\min_{z}\; g(z) + \tfrac{\beta}{2}\big\|Ax^{k+1} + Bz - c + \lambda^k/\beta\big\|^2,\\
\lambda^{k+1} &= \lambda^k + \beta\big(Ax^{k+1} + Bz^{k+1} - c\big).
\end{aligned}$$
Let the ergodic averages after $T$ iterations be
$$\bar{x}_T = \frac{1}{T}\sum_{k=1}^{T} x^{k}, \qquad \bar{z}_T = \frac{1}{T}\sum_{k=1}^{T} z^{k}, \qquad \bar{\lambda}_T = \frac{1}{T}\sum_{k=1}^{T} \lambda^{k-1}.$$

## Statement (to be proved)

Define the primal–dual gap function at a triple $(x,z,\lambda)$ against an arbitrary test point $(\tilde x,\tilde z,\tilde\lambda)$:
$$\Phi\big((x,z,\lambda);(\tilde x,\tilde z,\tilde\lambda)\big) \;=\; \big[f(x) + g(z) - f(\tilde x) - g(\tilde z)\big] + \big\langle \tilde\lambda,\, Ax + Bz - c\big\rangle - \big\langle \lambda,\, A\tilde x + B\tilde z - c\big\rangle.$$

(At a saddle point this vanishes; for feasible $(\tilde x,\tilde z)$ with $A\tilde x + B\tilde z = c$ and optimal $\tilde\lambda$, a nonnegative gap upper-bounds the objective suboptimality plus a constraint-violation duality term.)

**Theorem.** For every $T \ge 1$, every $\tilde\lambda \in \mathbb{R}^m$, and every **feasible** test point $(\tilde x, \tilde z)$ satisfying $A\tilde x + B\tilde z = c$,
$$\Phi\big((\bar x_T, \bar z_T, \bar\lambda_T);\,(\tilde x, \tilde z, \tilde\lambda)\big) \;\le\; \frac{1}{T}\left[\,\frac{\beta}{2}\|B(\tilde z - z^0)\|^2 + \frac{1}{2\beta}\|\tilde\lambda - \lambda^0\|^2\,\right].$$

(Feasibility of the test point is the He–Yuan 2012 standing convention and matches the theorem's own corollary: plugging in feasible $(x^\star, z^\star)$ and taking $\sup_{\tilde\lambda}$ over a bounded set recovers the standard ergodic $O(1/T)$ rate on the primal–dual gap. Without this feasibility, an extra term $\beta\langle B(z^0-z^T), A\tilde x+B\tilde z-c\rangle$ appears on the RHS that is unbounded in $\tilde x$.)

## Difficulty

**research**

## Key intermediate results to establish

1. **Variational inequality (VI) reformulation.** Recast ADMM iterates as a monotone VI: find $w = (x,z,\lambda)$ such that
$$F(w) \in -\partial\theta(w), \qquad \theta(w) = f(x) + g(z), \quad F(w) = \begin{pmatrix} -A^\top \lambda \\ -B^\top \lambda \\ Ax + Bz - c \end{pmatrix},$$
with $F$ skew-linear hence monotone and the VI operator $T = F + \partial\theta$ maximal monotone.

2. **One-step per-iterate VI inequality.** For every test point $\tilde w = (\tilde x,\tilde z,\tilde\lambda)$ in the domain,
$$\theta(u^{k+1}) - \theta(\tilde u) + \big\langle w^{k+1} - \tilde w,\; F(w^{k+1})\big\rangle \;\le\; \tfrac{1}{2}\big(\|\tilde v - v^k\|_H^2 - \|\tilde v - v^{k+1}\|_H^2\big) - \tfrac{1}{2}\|v^{k+1} - v^k\|_H^2,$$
where $v = (z,\lambda)$, $u = (x,z)$, and $H = \operatorname{diag}(\beta B^\top B,\; \beta^{-1} I)$ is symmetric positive semidefinite (positive definite on the relevant subspace of $\operatorname{range}(B)\oplus \mathbb{R}^m$).

3. **Telescoping the VI inequalities.** Sum from $k=0$ to $T-1$:
$$\sum_{k=0}^{T-1}\big[\theta(u^{k+1}) - \theta(\tilde u)\big] + \sum_{k=0}^{T-1}\big\langle w^{k+1} - \tilde w,\; F(w^{k+1})\big\rangle \;\le\; \tfrac{1}{2}\|\tilde v - v^0\|_H^2.$$

4. **Convexity + monotonicity ⇒ ergodic gap.** Using Jensen's inequality on $\theta$ (convexity) and the fact that $F$ is skew-affine so $\langle w - \tilde w, F(w)\rangle = \langle w - \tilde w, F(\tilde w)\rangle$ (equivalently, the ergodic average inherits the linear part exactly), convert the $T$-sum into a single inequality on the ergodic average $\bar w_T$:
$$T\cdot\Phi(\bar w_T;\tilde w) \;\le\; \tfrac{1}{2}\|\tilde v - v^0\|_H^2.$$

5. **Final rate.** Divide by $T$ and expand the $H$-norm into the two explicit quadratic terms $\tfrac{\beta}{2}\|B(\tilde z - z^0)\|^2$ and $\tfrac{1}{2\beta}\|\tilde\lambda - \lambda^0\|^2$.

## Notation & conventions

- Inner products $\langle\cdot,\cdot\rangle$ are Euclidean; $\|\cdot\|$ is the induced 2-norm.
- $\|v\|_H^2 = \langle v, H v\rangle$ for a symmetric PSD $H$. For $v = (z,\lambda)$ and $H = \operatorname{diag}(\beta B^\top B, \beta^{-1} I)$, $\|v\|_H^2 = \beta\|Bz\|^2 + \beta^{-1}\|\lambda\|^2$.
- Subgradients are in the sense of convex analysis (Rockafellar).
- The VI $F(w) \in -\partial\theta(w)$ means $0 \in F(w) + \partial\theta(w) + N_{\text{dom}\,\theta}(w)$ in the standard sense.

## What is allowed

- Any identity among the ADMM iterates that follows from the optimality conditions of the $x$- and $z$-subproblems and the dual update.
- Standard convex-analysis tools: subgradient inequality, monotonicity of $\partial\theta$, Jensen's inequality, Cauchy–Schwarz, Young's inequality.
- Matrix algebra for rearranging the cross terms into the $H$-weighted squared-distance form.

## What is NOT required

- No strong convexity, no smoothness, no full-rank assumption on $A$ or $B$.
- No bounded-domain assumption. The bound is against an arbitrary test point and the RHS depends only on $\|\tilde v - v^0\|_H^2$.
- No special structure for the coupling (beyond linear $Ax+Bz=c$).
