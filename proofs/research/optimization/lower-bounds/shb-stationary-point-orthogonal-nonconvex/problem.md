# Fixed-momentum SHB does not match Arjevani's minimax LB on the stationary-point complexity of L-smooth non-convex functions

## Source

- Internal: OP-2 v6 / A2 (2026-04-29). Companion to OP-2 v5 (the convex bias-term LB).
- Upstream:
  - Goujaud–Taylor–Dieuleveut, "Provable non-accelerations of the heavy-ball method", *Math. Prog.* 2025 (arXiv:2307.11291) — the cycling skeleton.
  - Arjevani–Carmon–Duchi–Foster–Srebro–Woodworth, "Lower Bounds for Non-Convex Stochastic Optimization", *Math. Prog.* 2023 (arXiv:1912.02365) — the minimax baseline that A2 strictly dominates on its hard instance.
- Context: practitioners use fixed-momentum SHB on non-convex training objectives. Yan et al. 2018 shows SHB matches SGD's $O(L\Delta/T + L\sigma^2/\sqrt T)$ upper bound. The OPP-style open question is: can a hard-instance separation show SHB strictly worse than SGD on stationary-point complexity? A2 answers YES with an algorithm-specific cycling LB that is constant in T.

## Statement

**Theorem A2.** Let $L, D, \sigma > 0$, $T \geq 1$, $K = 3$, $\mu := 0.01\,L$, and let
$$\mathcal F_{K=3} \;:=\; \bigl\{(\beta, L\eta) \in (0,1)\times(0,\infty)
   \;:\; \gamma_{\mathrm{crit}}(\beta) < L\eta < 2(1+\beta) \bigr\},$$
where $\gamma_{\mathrm{crit}}(\beta) := 3(1+\beta+\beta^2)/(1+2\beta)$.
There exists an $L$-smooth (gradient-Lipschitz) **non-convex** function
$f^{(s)} : \R^4 \to \R$ and an unbiased stochastic gradient oracle with
variance $\leq \sigma^2$ such that for every $(\beta, L\eta) \in \mathcal F_{K=3}$,
the SHB last-iterate
$$x_{t+1} \;=\; x_t \;-\; \eta\, g_t \;+\; \beta\,(x_t - x_{t-1}),
\qquad x_0 = (D/\sqrt 2)\,e_0,\; x_{-1} = (D/\sqrt 2)\,e_{K-1},$$
$y_0 = y_{-1} = 0$, $z_0 = z_{-1} = 0$ (non-zero-velocity init essential)
satisfies
$$\boxed{\;
\max_{s \in \{\pm 1\}}\E_s\bigl[\|\nabla f^{(s)}(x_T, y_T, z_T)\|^2\bigr]
\;\geq\; \max\Bigl\{\,\frac{\sigma^2}{27\,T},\;\; \frac{3 D^2 (1+\beta+\beta^2)}{2\,\eta^2}\,\Bigr\}
\quad \forall\, T \geq 1.\;}$$

The cycling constant $B_{\mathrm{NC}}(\beta, \eta) := 3D^2(1+\beta+\beta^2)/(2\eta^2)$
is **constant in $T$**, **$\mu$-independent**, and positive on $(0, 1)$ in $\beta$;
it vanishes only at $\beta = 0$ (where the feasibility region $\mathcal F_{K=3}$
itself becomes empty: $\beta^\star = (\sqrt{13}-3)/2 \approx 0.303$).

In contrast, SGD ($\beta = 0$, $\eta_{\mathrm{SGD}} \leq 1/L$) on the same
$f^{(s)}$ achieves $\E[\|\nabla f^{(s)}(x_T)\|^2] \to 0$ at the standard
Ghadimi–Lan rate, giving an unbounded SHB/SGD separation as $T \to \infty$.

## Difficulty

**Research.** A-class proof requiring extension of the Goujaud cycling
machinery (originally for convex strongly convex) to non-convex stationary
point complexity, while sidestepping three obstacles from prior literature
(Sun et al. IJCAI 2019, Okamura et al. 2024, Wang–Abernethy 2020).

## Hard instance (Candidate A)

$$f^{(s)}(x, y, z) \;=\; f_0(x) + \alpha_s\, y + w(y) + h(z),$$
where:

- $f_0$ is the rescaled Goujaud polytope-Moreau function (cycling subspace): $\R^2 \to \R$;
- $\alpha_s = s\sigma/(3\sqrt T)$, $R = D/\sqrt 2 - |\alpha_s|/L$, $w(y) = (L/2)(\max(|y|-R, 0))^2$ (Le Cam wall, $\R \to \R$);
- $h(z) = (L/2)\,z^2 e^{-z^2/D^2}$ (orthogonal non-convex bump, $\R \to \R$).

The mechanism is **rotational-symmetry algebraic limit cycling on a convex
polytope boundary** (the $f_0$ subspace), with the non-convex saddle structure
*orthogonal* to the cycling subspace (the $h$ subspace, dynamically inert
because $h'(0) = 0$ and there is no $z$-noise). See `notes.md` for the
"orthogonal non-convexity" framing in detail.

## Non-goals

- NOT a refinement of Arjevani's minimax LB. A2 is **algorithm-specific** to fixed-momentum SHB and gives a **constant-in-T** LB; Arjevani is **algorithm-agnostic** and decays as $1/T$. The two are **orthogonal** (different mathematical content).
- NOT claiming anything about adaptive momentum $\beta_t$ or restart-HB.
- NOT claiming anything for $(\beta, L\eta) \notin \mathcal F_{K=3}$ (where Goujaud cycling fails; SHB then converges geometrically, no separation).
- NOT claiming the Hessian-Lipschitz regime: $f_0$ is $C^{1,1}$ but not $C^2$ — Okamura et al. 2024's $\varepsilon^{-7/4}$ HB-ODE bound does not apply.
- NOT claiming benign-landscape: the cycling structure is the OPPOSITE of "benign". Wang–Abernethy 2020's "HB beats GD on phase retrieval / cubic-reg" does not contradict A2.
