# OP-2 Divergent Directions — Final Summary

**Date:** 2026-04-26
**Scope:** Five parallel research directions (D1–D5) branching from OP-2's technical toolkit (Goujaud cycling + Le Cam two-point + KL chain rule + 3D coordinate decoupling).
**Process:** 5 Explore agents in parallel, each ~5–10 min depth, with full numerical verification.

---

## Final scoreboard

| Problem | Direction | Status | Core Technique | Key Finding |
|---|---|---|---|---|
| **D1** | Adam/RMSProp non-acceleration | **FAIL** | Adam on Goujaud + 3D decouple | Bias LB does NOT extend; per-coord $\hat v_t$ scaling breaks cycling at $t=1$ via sign-SGD-magnitude blow-up. Variance LB likely transfers (separate theorem). |
| **D2** | Polyak step-size SHB | **OPEN** | Closed-form Polyak step $\eta_*$ on cycle | Polyak step on cycling orbit lies $3$–$5\times$ outside $\mathcal{F}$; cycling broken at iter 1. But no acceleration UB known either (literature ceiling: $O(1/T)$). Whether SHB-Polyak truly accelerates is OPEN. |
| **D3** | Sharp variance constant | **PASS** | Optimize $c_\alpha$ in Le Cam chain | $c_{\mathrm{NY}}^\star = \sqrt 2/27 \approx 0.0524$ at $c_\alpha = 1/3$ under (RGM)-tight; $1/(8\sqrt 2)$ is asymptotic limit only. **5.87× improvement over OP-2's $1/112$.** |
| **D4** | High-dimensional $d \geq 3$ | **NEGATIVE** | Product Le Cam + Fano on $\{\pm 1\}^{d-2}$ | Cauchy–Schwarz cancellation: $\sum_i \alpha_i D_i \le \|\alpha\|_2 \|D\|_2$ is dimension-independent under §0.2 oracle. No $\sqrt{d-2}$, no $\sqrt{\log d}$ within OP-2 framework. |
| **D5** | Polyak vs Nesterov separation | **UPGRADED PASS (parallel, not separation)** [see `D5_nesterov/rerun_v2.md`] | Explicit NAG cycling matrix $M^{\mathrm{Nes}} = \frac{(1-\eta\mu)I - R_{\theta_K}A^{-1}}{\eta(L-\mu)}$ where $A := (1+\beta)I - \beta R_{-\theta_K}$; verified cycling at machine precision for $T = 10000$ at $(\beta, \eta L, \mu/L) = (0.85, 2.4, 0.25)$. NAG analogue of $\Omega(\mu D^2)$ transfers structurally. $\mathcal{F}^{\mathrm{HB}}$ and $\mathcal{F}^{\mathrm{Nes}}$ are **disjoint** at $\mu/L \ge 0.20$ in the grid scan. **Right framing: "method-specific cycling, method-agnostic non-acceleration"** — partially resolves GTD23 Conjecture 7.1 for NAG. |

**Net:** 2 clean PASSes (D3 + D5-rerun), 1 negative result (D4), 1 FAIL (D1), 1 OPEN (D2).

**D5 careful re-run finding (2026-04-26):** The first pass concluded "no clean separation"; the careful re-run with WebFetch + closed-form triangle projection upgrades the verdict. **A NAG-cycling Goujaud-style instance exists** with explicit matrix $M^{\mathrm{Nes}}$, partially answering GTD23 Conjecture 7.1 (Goujaud-Taylor-Dieuleveut 2023, arXiv:2307.11291). The framing is "parallel non-acceleration" — both methods have method-specific cycling regions and a $\Omega(\mu D^2)$ lower bound transfers structurally. This is **publication-ready** as a §4 remark in OP-2's paper or potentially as a standalone note "Cycling-feasibility region for Nesterov's accelerated gradient (partial answer to GTD23 Conjecture 7.1)".

---

## D3 (PASS) — implementation-ready

D3 is the only direction that gives a publication-ready improvement.

### Headline result

**Replace OP-2's $c_{\mathrm{NY}} = 1/112$ with $c_{\mathrm{NY}} = \sqrt 2/27 \approx 0.0524$** (factor $\approx 5.87$ improvement).

### Mechanism

Reparametrize $\alpha = c_\alpha \sigma/\sqrt T$ and optimize $c_\alpha$ to maximize the product
$$c_{\mathrm{NY}}(c_\alpha, r) = \frac{\sqrt 2}{8} c_\alpha (1-c_\alpha)\bigl(2 - c_\alpha r\sqrt 2\bigr),$$
where $r = \sigma/(LD\sqrt T)$ is the (RGM)-tightness ratio. At the (RGM)-tight worst case $r = \sqrt 2$, the cubic $\partial_{c_\alpha} = 0$ has rational root $c_\alpha^\star = 1/3$, yielding $c_{\mathrm{NY}}^\star = \sqrt 2/27$.

### Required edits to `op2_downgraded_proof_v3_final.md`

1. §0.5: $c_{\mathrm{NY}} = 1/112 \to \sqrt 2/27$.
2. §2.1.2 (ALPHA): $\alpha := \sigma/(2\sqrt{2T}) \to \alpha := \sigma/(3\sqrt T)$.
3. §2.1.2 (R-def): $R := D/\sqrt 2 - \sigma/(3L\sqrt T)$.
4. Lemma 1.4 (KL chain): KL per step $1/(4T) \to 1/(9T)$, total $1/4 \to 2/9$, TV $\le 1/3$, $p_\min \ge 1/3$.
5. Lemma 2.9 Step 3: replace loose $\alpha^2/(2L) \le \alpha D/4$ by **exact** $\alpha^2/(2L) = c_\alpha r/\sqrt 2 \cdot \alpha D/\sqrt 2$, giving $\rho = \sqrt 2/3$ at $r=\sqrt 2$.
6. Lemma 2.9 Step 4: $(\alpha D)\cdot(\sqrt 2/3)\cdot(1/3) = \sqrt 2\,\sigma D/(27\sqrt T)$.
7. Footnote: rephrase "$1/(8\sqrt 2)$ achievable" as "$1/(8\sqrt 2)$ is asymptotic limit as $\sigma/(LD\sqrt T) \to 0$; under saturated (RGM), sharp Pinsker constant is $\sqrt 2/27$. Hellinger gives further $\sim 1\%$."

Files: `D3_sharp_constant/proof.md`.

---

## D1, D4 (FAIL/NEGATIVE) — failure patterns to archive

Each direction documents a specific obstruction worth recording for future research:

### D1 obstruction: Adam's per-coord $\hat v_t$

OP-2's bias term needs three structural properties:
(i) coord-wise homogeneity ($\nabla f_0(\lambda e_t) = \lambda\nabla\psi(e_t)$) — broken by per-coord scaling
(ii) initialization symmetry — broken by asymmetric $\hat v_t$ values
(iii) clean SHB recursion — replaced by sign-SGD-magnitude step at $t=1$ from bias correction

Per-coord ratio of $g_t^2$ across the $K=3$ cycle is up to **27:1**, ensuring asymmetric scaling regardless of $(\beta_1, \beta_2, \epsilon)$.

### D4 obstruction: Cauchy–Schwarz cancellation

Under §0.2 oracle ($\mathbb{E}\|\xi_t\|^2 \le \sigma^2$ globally):
$$\sum_i \alpha_i D_i \le \|\alpha\|_2 \|D\|_2 \le \frac{\sigma D}{\sqrt{2T}},$$
**dimension-independent** regardless of allocation strategy or decoder (direct sum, Fano, Gilbert–Varshamov packing). The $\sqrt{d-2}$ from extra tests cancels exactly with $1/\sqrt{d-2}$ from variance dilution. The $\sqrt{\log d}$ NY/Agarwal bound exists but requires non-product (coupled) hypothesis tests not realizable by separable walls.

### D5 obstruction: Cycling-vs-Lookahead structural gap

Polyak's cycling identity uses (a) GTD23 vertex projection $P_C(e_t) = M e_t$ (only at vertices) + (b) Polyak's algebraic identity (gradient at $x_t = $ vertex). Nesterov's lookahead $y_t = (1+\beta)e_t - \beta e_{t-1}$ is non-vertex, so (a) doesn't apply. **Cycling identity is provably Polyak-specific.**

But Nesterov also fails to converge on OP-2 instance (own non-zero attractor), so no clean rate separation.

---

## What survives: the OP-2 paper after D1–D5

OP-2's claim must be scoped as:

> **Theorem (OP-2, fully scoped).** For $L, \sigma, D > 0$ with $\sigma \le LD\sqrt 2$ and $(\beta, \eta) \in \mathcal{F}$, there exists a 3-D smooth convex non-strongly-convex hard instance $f^{(T)}_{\beta,\eta}$, an adversarial cycling-compatible initialization, and an $\ell_2$-bounded stochastic oracle of variance $\sigma^2$, such that the **last iterate** of *fixed-momentum Polyak heavy-ball* SHB satisfies
> $$\mathbb{E}[f^{(T)}(x_T) - f^{(T),\star}] \geq \frac{\kappa(\beta,\eta)}{4}\frac{LD^2}{T} + \frac{\sqrt 2}{27}\frac{\sigma D}{\sqrt T}.$$

**Three qualifiers are essential** (and all three came out of this divergent-direction exploration):
1. **last iterate** (collapses on Cesàro average, per upgrade attempt)
2. **adversarial cycling-init** (collapses on zero-momentum init for some $(\beta,\eta) \in \mathcal{F}$, per upgrade attempt)
3. **fixed-momentum Polyak heavy-ball specifically** — NOT Adam/RMSProp (D1), NOT Polyak step-size SHB (D2), NOT Nesterov (D5)

The variance constant is sharpened from $1/112$ to $\sqrt 2/27$ (D3, factor $\sim 5.87$).

The dimension is fixed at $d = 3$; no improvement from high-dim is available within this framework (D4).

---

## Failure patterns to archive

Three new failure patterns to append to `workspace/failure_patterns.md`:

1. **FP-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING-2026-04-26**
2. **FP-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM-2026-04-26**
3. **FP-OP2-NESTEROV-LOOKAHEAD-OFF-VERTEX-2026-04-26**

(Detailed below in `failure_patterns.md` append.)

---

## Recommendations for next steps

| Priority | Action |
|---|---|
| **HIGH** | Apply D3's $\sqrt 2/27$ improvement to `op2_downgraded_proof_v3_final.md` → produce v4. Single concrete edit; clean publication win. |
| MEDIUM | Add a paragraph in OP-2 §4 (Related Work) on D5's Polyak-vs-Nesterov qualitative observation: "Nesterov's lookahead $y_t$ is generically non-vertex, so the cycling identity is Polyak-specific. Numerically Nesterov on the same instance has different non-cycling dynamics; a Nesterov-side cycling instance would need to be constructed separately." |
| MEDIUM | Add D2's literature citation (Schaipp et al. 2024 ICLR 2025) to OP-2 §4: "fixed Polyak step-size SHB has no $O(1/T^2)$ upper bound in the literature; whether it accelerates is open." |
| LOW | Document D1 (Adam) and D4 (high-dim) negative results in failure-pattern archive. |
| FUTURE | If further research budget: D2 is the most exciting open direction. A new hard-instance construction surviving step-size adaptation would be a genuinely novel contribution. |
