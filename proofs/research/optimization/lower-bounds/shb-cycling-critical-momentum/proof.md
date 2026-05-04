# Proof — Sharp threshold β* = (√13 − 3)/2 for Goujaud cycling feasibility

## 0. Setup

Fix $L > 0$. The SHB stability region is
$$
\mathcal{S} \;:=\; \{(\beta, \eta) \in [0, 1) \times \mathbb{R}_{>0} \,:\, \eta \leq 2(1+\beta)/L\}.
$$
For each integer $K \geq 3$, set $\theta_K := 2\pi/K$ and $c_K := \cos\theta_K$. The
small-$\kappa$ limit of the Goujaud–Taylor–Dieuleveut 2023 cycling inequality (GTD-cyc),
restricted to the $K$-cycle, is
$$
(\star_K)\qquad (\beta - c_K)\,L\,\eta \;\geq\; (1 - c_K)(1 + \beta^2 - 2\beta\, c_K),
$$
together with the implicit assumption $\beta > c_K$ (so the LHS coefficient is positive and the inequality is non-degenerate). The cycling-feasibility region at $K$ is
$$
\mathcal{F}_K \;:=\; \{(\beta, \eta) \in \mathcal{S} \,:\, \beta > c_K \text{ and } (\star_K) \text{ holds}\},
\qquad \mathcal{F} \;:=\; \bigcup_{K \geq 3} \mathcal{F}_K.
$$
Define
$$
\beta^\star \;:=\; \inf\{\beta \in [0, 1) \,:\, \exists\, K \geq 3,\ \exists\,\eta > 0\ \text{with}\ (\beta, \eta) \in \mathcal{F}_K\}.
$$

## 1. Theorem

> **Theorem (M3).** $\beta^\star = (\sqrt{13} - 3)/2 \approx 0.3027756377$, the infimum is attained (i.e.\ it is a minimum), and the witnessing $K$ is $K = 3$.
>
> Concretely:
> 1. (Achievability above $\beta^\star$). For every $\beta > \beta^\star$, the closed interval $[\gamma_3(\beta)/L,\ 2(1+\beta)/L]$ is non-empty, and every $\eta$ in it satisfies $(\beta, \eta) \in \mathcal{F}_3 \subset \mathcal{F}$, where
>    $$\gamma_3(\beta) := \frac{(1 - c_3)(1 + \beta^2 - 2\beta c_3)}{\beta - c_3} = \frac{3(1 + \beta + \beta^2)}{1 + 2\beta}.$$
> 2. (Infeasibility below $\beta^\star$). For every $\beta < \beta^\star$ and every $K \geq 3$, $\mathcal{F}_K \cap (\{\beta\} \times \mathbb{R}_{>0}) = \emptyset$. Hence $\mathcal{F} \cap ([0, \beta^\star) \times \mathbb{R}_{>0}) = \emptyset$.
> 3. (Sharpness at the threshold). At $\beta = \beta^\star$, $K = 3$, $\eta = 2(1 + \beta^\star)/L$, the inequality $(\star_3)$ holds with equality; this single boundary point is the unique witness at $\beta = \beta^\star$.

## 2. Reduction to a one-variable algebraic inequality

For fixed $K \geq 3$ and $\beta > c_K$, the smallest $\eta > 0$ that satisfies $(\star_K)$ is
$$
\eta_{\min}(\beta, K) \;=\; \frac{(1 - c_K)(1 + \beta^2 - 2\beta c_K)}{(\beta - c_K)\,L}.
$$
$(\beta, \eta) \in \mathcal{F}_K$ for some $\eta \in (0, 2(1+\beta)/L]$ iff $\eta_{\min}(\beta, K) \leq 2(1+\beta)/L$, i.e.
$$
(\dagger_K)\qquad (1 - c_K)(1 + \beta^2 - 2\beta c_K) \;\leq\; 2(\beta - c_K)(1 + \beta).
$$

## 3. Polynomial factorization (key algebraic identity)

**Lemma 1.** For all $\beta, c \in \mathbb{R}$,
$$
2(\beta - c)(1 + \beta) \;-\; (1 - c)(1 + \beta^2 - 2\beta c) \;=\; (1 + c)\,\bigl[\beta^2 + 2(1 - c)\beta - 1\bigr].
$$

*Proof.* Direct expansion. The LHS expands to
$$
2\beta + 2\beta^2 - 2c - 2c\beta \;-\; \bigl[(1 + \beta^2 - 2\beta c) - c(1 + \beta^2 - 2\beta c)\bigr]
$$
$$
= 2\beta + 2\beta^2 - 2c - 2c\beta - 1 - \beta^2 + 2\beta c + c + c\beta^2 - 2\beta c^2
$$
$$
= (1 + c)\beta^2 + 2(1 - c^2)\beta - (1 + c) \;=\; (1 + c)\bigl[\beta^2 + 2(1 - c)\beta - 1\bigr],
$$
using $1 - c^2 = (1 - c)(1 + c)$. $\square$

(Verified symbolically by SymPy in `verify.py` step 1: difference is identically zero.)

**Corollary 2.** For $K \geq 3$, since $c_K \in [-1/2, 1) \subset (-1, 1)$, the factor $1 + c_K > 0$. Hence
$$
(\dagger_K) \;\Longleftrightarrow\; Q_K(\beta) \;:=\; \beta^2 + 2(1 - c_K)\beta - 1 \;\geq\; 0.
$$

## 4. Solving $Q_c(\beta) \geq 0$

For any $c \in (-1, 1)$, set $u := 1 - c > 0$. The roots of $Q_c(\beta) = \beta^2 + 2u\beta - 1$ are
$$
\beta_\pm(c) \;=\; -u \pm \sqrt{u^2 + 1}.
$$
Since $\sqrt{u^2 + 1} > u > 0$, $\beta_-(c) < 0 < \beta_+(c)$. Therefore, for $\beta \geq 0$,
$$
Q_c(\beta) \geq 0 \;\Longleftrightarrow\; \beta \geq \beta_+(c) \;=\; \sqrt{u^2 + 1} - u.
$$
Define
$$
\beta_{\min}(c) \;:=\; \sqrt{(1 - c)^2 + 1} - (1 - c).
$$

## 5. Monotonicity

**Lemma 3.** The function $\varphi : (0, \infty) \to \mathbb{R}$, $\varphi(u) := \sqrt{u^2 + 1} - u$, is strictly decreasing.

*Proof.* Rationalize:
$$
\varphi(u) \;=\; \frac{(\sqrt{u^2 + 1} - u)(\sqrt{u^2 + 1} + u)}{\sqrt{u^2 + 1} + u} \;=\; \frac{1}{\sqrt{u^2 + 1} + u}.
$$
The denominator $\sqrt{u^2 + 1} + u$ is strictly increasing in $u > 0$ (both summands are), so $\varphi$ is strictly decreasing. Equivalently, $\varphi'(u) = u/\sqrt{u^2 + 1} - 1 < 0$ since $u < \sqrt{u^2 + 1}$. $\square$

## 6. Minimization over $K \geq 3$

The map $K \mapsto c_K = \cos(2\pi/K)$ is strictly increasing on $\{3, 4, 5, \ldots\}$ (for $K \geq 3$, $2\pi/K \in (0, 2\pi/3]$ is decreasing in $K$ and lies in $(0, \pi)$ where cosine is strictly decreasing). Hence $u_K := 1 - c_K$ is strictly **decreasing** in $K$ on $\{3, 4, 5, \ldots\}$:
$$
u_3 = \tfrac{3}{2} > u_4 = 1 > u_5 = 1 - \cos(2\pi/5) > \cdots > 0,\qquad u_K \downarrow 0\ \text{as}\ K \to \infty.
$$
By Lemma 3, $\beta_{\min}(c_K) = \varphi(u_K)$ is strictly **increasing** in $K$ on $\{3, 4, 5, \ldots\}$. Therefore
$$
\inf_{K \geq 3} \beta_{\min}(c_K) \;=\; \beta_{\min}(c_3) \;=\; \varphi(3/2) \;=\; \sqrt{(3/2)^2 + 1} - \tfrac{3}{2} \;=\; \sqrt{13/4} - \tfrac{3}{2} \;=\; \frac{\sqrt{13} - 3}{2}.
$$
This minimum is attained uniquely at $K = 3$.

## 7. Stitching: the threshold value

Combining Sections 2–6:

For each $K \geq 3$, the slice $\mathcal{F}_K \cap (\{\beta\} \times \mathbb{R}_{>0})$ is non-empty iff $\beta > c_K$ **and** $(\dagger_K)$ holds, iff $\beta > c_K$ **and** $\beta \geq \beta_{\min}(c_K)$. Since $\beta_{\min}(c_K) > c_K$ for all $c_K \in (-1, 1)$ (from $\beta^2 + 2(1-c)\beta - 1 = 0$ at $\beta = \beta_{\min}$, while at $\beta = c$ one gets $c^2 + 2(1-c)c - 1 = 2c - c^2 - 1 = -(1-c)^2 < 0$, hence $\beta_{\min} > c$), the binding constraint is just $\beta \geq \beta_{\min}(c_K)$.

Hence
$$
\beta^\star \;=\; \inf_{K \geq 3}\,\beta_{\min}(c_K) \;=\; \beta_{\min}(c_3) \;=\; \frac{\sqrt{13} - 3}{2},
$$
attained at $K = 3$.

## 8. Achievability above $\beta^\star$ (Theorem part 1)

For $K = 3$, $c_3 = -1/2$, so
$$
\gamma_3(\beta) \;=\; \frac{(1 - (-1/2))(1 + \beta^2 - 2\beta(-1/2))}{\beta - (-1/2)} \;=\; \frac{(3/2)(1 + \beta + \beta^2)}{\beta + 1/2} \;=\; \frac{3(1 + \beta + \beta^2)}{1 + 2\beta}.
$$
By Section 2, $(\beta, \eta) \in \mathcal{F}_3$ iff $\beta > -1/2$ (always true for $\beta \geq 0$) and $\eta \in [\gamma_3(\beta)/L, 2(1+\beta)/L]$. The interval is non-empty iff $\gamma_3(\beta) \leq 2(1+\beta)$, iff (by Lemma 1 and Corollary 2) $\beta \geq \beta^\star$. Strict $\beta > \beta^\star$ gives a non-degenerate interval; equality $\beta = \beta^\star$ collapses the interval to the single point $\eta = 2(1+\beta^\star)/L = \gamma_3(\beta^\star)/L$.

## 9. Infeasibility below $\beta^\star$ (Theorem part 2)

For any $\beta < \beta^\star$ and any $K \geq 3$:
- If $\beta \leq c_K$, then $(\star_K)$ is infeasible (LHS $\leq 0$, RHS $> 0$ unless $\beta = c_K = $ root of $1 + \beta^2 - 2\beta c_K$; but $1 + \beta^2 - 2\beta c_K \geq (1 - c_K^2) + (\beta - c_K)^2 \geq 1 - c_K^2 > 0$ for $c_K < 1$).
- If $\beta > c_K$, by Section 4 the slice is non-empty iff $\beta \geq \beta_{\min}(c_K) \geq \beta^\star > \beta$ — contradiction.

In both cases, $(\beta, \eta) \notin \mathcal{F}_K$ for any $\eta$. Hence $\mathcal{F} \cap ([0, \beta^\star) \times \mathbb{R}_{>0}) = \emptyset$.

## 10. Sharpness at the threshold (Theorem part 3)

Plug $\beta = \beta^\star = (\sqrt{13} - 3)/2$ and $K = 3$ into $(\star_3)$ at $\eta = 2(1 + \beta^\star)/L$:

$\beta^\star + 1/2 = (\sqrt{13} - 2)/2$, so $(\beta^\star - c_3)L\eta = ((\sqrt{13} - 2)/2)\cdot 2(1 + \beta^\star) = (\sqrt{13} - 2)(1 + \beta^\star)$.

$1 + \beta^\star = (\sqrt{13} - 1)/2$, so $(\sqrt{13} - 2)(1 + \beta^\star) = (\sqrt{13} - 2)(\sqrt{13} - 1)/2 = (13 - 3\sqrt{13} + 2)/2 = (15 - 3\sqrt{13})/2$.

For the RHS, $1 + (\beta^\star)^2 - 2\beta^\star c_3 = 1 + (\beta^\star)^2 + \beta^\star$. Using $\beta^\star$'s defining equation $(\beta^\star)^2 + 3\beta^\star - 1 = 0$ (from $Q_{c_3}(\beta^\star) = (\beta^\star)^2 + 3\beta^\star - 1 = 0$):
$1 + (\beta^\star)^2 + \beta^\star = 1 + (1 - 3\beta^\star) + \beta^\star = 2 - 2\beta^\star = 2(1 - \beta^\star) = 2(1 - (\sqrt{13}-3)/2) = 5 - \sqrt{13}$.

Then $(1 - c_3)(1 + (\beta^\star)^2 - 2\beta^\star c_3) = (3/2)(5 - \sqrt{13}) = (15 - 3\sqrt{13})/2$.

LHS $= (15 - 3\sqrt{13})/2 = $ RHS. Equality holds. $\square$

The verification script `verify.py` step 5 confirms this numerically to machine precision: LHS − RHS $= -4.4 \times 10^{-16}$.

## 11. Numerical confirmation (`verify.py`)

| $K$ | $c_K$ | $\beta_{\min}(c_K)$ |
|----:|------:|--------------------:|
|   3 | $-0.5000000000$ | $0.302775637732$ |
|   4 | $\phantom{-}0.0000000000$ | $0.414213562373$ |
|   5 | $\phantom{-}0.3090169944$ | $0.524524095984$ |
|   6 | $\phantom{-}0.5000000000$ | $0.618033988750$ |
|  10 | $\phantom{-}0.8090169944$ | $0.827090915285$ |
|  50 | $\phantom{-}0.9921147013$ | $0.992145789799$ |
| 100 | $\phantom{-}0.9980267284$ | $0.998028675327$ |
| 1000 | $\phantom{-}0.9999802609$ | $0.999980261051$ |

Confirms (i) $K = 3$ gives the unique minimum, (ii) $\beta_{\min}(K) \to 1$ monotonically as $K \to \infty$, (iii) $\beta_{\min}(3) = (\sqrt{13} - 3)/2$ to $10^{-16}$ precision.

The script's negative control (β slightly below $\beta^\star$, all $K$ up to $1000$) finds no feasibility, and the positive control (β slightly above $\beta^\star$, $K = 3$) finds a non-empty $\eta$-interval, both as predicted.

$\blacksquare$
