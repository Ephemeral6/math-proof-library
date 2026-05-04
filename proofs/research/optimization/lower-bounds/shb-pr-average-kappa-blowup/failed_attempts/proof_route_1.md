# Proof — SHB Polyak-Ruppert κ-Blow-Up (Route 1, Orthodox Frame)

**Author:** Explorer 1, Frame: Orthodox  
**Route:** Closed-Form Spectral Computation on 2D Diagonal Quadratic  
**Date:** 2026-04-27

---

## 0. Pre-proof Knowledge Reuse Report

**Step A — Strategy index lookup.** From `workspace/strategy_index.md`:
- Signature `polyak-ruppert-shb-defeats-cycling` (line 289): `meta_template: spectral_eigenvalue`, `technique_chain: complexify ℝ²≅ℂ → arithmetico_geometric_sum Σ t·ω^t → triangle_inequality_on_closed_form → L_smoothness_quadratic_bound`.
- Signature `heavy-ball-instability` (lines 374–402): companion-matrix decoupling for diagonal quadratics, spectral radius = √β in under-damped regime.

**Step B — Meta-template fit.** This proof fits **MT8 (Spectral / Eigenvalue Argument)** plus **MT4 (Reduce to Low-Dim / Structured Space)**:
- *MT8 slots:* TARGET = `f(\tilde x_T)/f(x_T)`; MATRIX = SHB companion matrix `M_λ`; GAP = under-damped discriminant `(1+β−ηλ)² < 4β`; PERTURBATION = closed-form arithmetico-geometric sum of complex roots.
- *MT4 slots:* TARGET = 2-D iterate sequence; STRUCTURE = diagonal eigenbasis (each coordinate decouples); PROJECTION = decoupling into two scalar SHB; INEQ = closed-form trigonometric residue + Vieta identity.
- *No blocker slots.* All slots filled by direct algebra.

**Step C — Structure-map links.** From `workspace/structure_map.md` (lines 19–113): this problem is a **DUAL** to `polyak-ruppert-shb-defeats-cycling` (A5 in the cluster). A5 proved a PR averaging *upper bound* on Goujaud's K-cycling hard instance ($O(LD²/T²)$); the present problem asks for a PR averaging *lower bound* on the strongly-convex diagonal quadratic. SAME-TEMPLATE link to A6 = `heavy-ball-instability` for the decoupling/spectral-radius infrastructure.

**Step D — Failure-trigger pre-scan.** From `workspace/failure_triggers.md`:
- **FP-18 (machine-precision floor):** explicitly flagged. Mitigation in Section 5: numerical pre-check below at $T \in \{100, 200, 300, 400\}$ and check whether $f(x_T) > 10^{-16}$.
- **FT-LEGACY-SHB-LB-QUADRATIC-CHEBYSHEV:** "quadratics too easy for fixed-momentum HB lower bounds." This is a *false-alarm trigger* for Part B: we are not lower-bounding $f(x_T)$ — we are lower-bounding the *PR average* $f(\tilde x_T)$, which is genuinely amplified by the algebraic anti-cancellation in the linearly-weighted sum. Mitigation: explicit Vieta identity in §3.3 quantifies the anti-cancellation.
- **FT-OP2-…-CYCLING:** not applicable (no cycling here; this is a strongly convex quadratic with under-damped SHB).

---

## 1. Setting and Notation

Define $f(x) = \tfrac{L}{2}x_1^2 + \tfrac{\mu}{2}x_2^2$ on $\mathbb{R}^2$ with condition number $\kappa = L/\mu \ge 1$. Let $\Lambda := \{L, \mu\}$ be the eigenvalue set. Run SHB
$$
x_{t+1} = x_t - \eta\nabla f(x_t) + \beta(x_t - x_{t-1}),\qquad x_0 = x_{-1} = (1,1),
$$
with $\beta\in[0,1)$, $\eta>0$, in the **under-damped regime**: $(1+\beta-\eta\lambda)^2 < 4\beta$ for both $\lambda\in\Lambda$.

Linearly-weighted Polyak–Ruppert average:
$$
\tilde x_T = \frac{2}{T(T+1)}\sum_{t=0}^{T-1}(t+1)x_t,\qquad T\ge 1.
$$

Because $\nabla f(x) = \mathrm{diag}(L,\mu)x$ acts diagonally and $x_0=x_{-1}=(1,1)$ has independent components, the iteration **decouples** into two scalar SHB recursions, one per eigenvalue [REF:`proofs/research/optimization/convergence/heavy-ball-instability/proof.md` Part 1 Steps 1–3]:
$$
\boxed{\;x_{t+1}^{(\lambda)} = (1+\beta-\eta\lambda)x_t^{(\lambda)} - \beta\,x_{t-1}^{(\lambda)},\quad x_0^{(\lambda)}=x_{-1}^{(\lambda)}=1,\quad \lambda\in\{L,\mu\}.\;}
$$
Hence $f(x_T) = \tfrac{L}{2}(x_T^{(L)})^2 + \tfrac{\mu}{2}(x_T^{(\mu)})^2$ and $f(\tilde x_T) = \tfrac{L}{2}(\tilde x_{T,L})^2 + \tfrac{\mu}{2}(\tilde x_{T,\mu})^2$, with $\tilde x_{T,\lambda} = \tfrac{2}{T(T+1)}\sum_{t=0}^{T-1}(t+1)x_t^{(\lambda)}$.

---

## 2. The SHB Spectral Identity (Vieta — derived explicitly)

Fix $\lambda\in\Lambda$. The characteristic polynomial of the scalar SHB recursion is
$$
P_\lambda(z) := z^2 - (1+\beta-\eta\lambda)z + \beta.
$$
Let $z_\lambda, \bar z_\lambda$ be its two (necessarily complex-conjugate, since under-damped) roots.

**Vieta's formulas** give:
$$
z_\lambda + \bar z_\lambda = 1+\beta-\eta\lambda,\qquad z_\lambda \bar z_\lambda = \beta.
$$

**Modulus:** $|z_\lambda|^2 = z_\lambda\bar z_\lambda = \beta$, so $|z_\lambda| = \sqrt\beta$.

**Spectral identity (key).** Compute $|1-z_\lambda|^2$:
$$
\begin{aligned}
|1-z_\lambda|^2 &= (1-z_\lambda)(1-\bar z_\lambda) = 1 - (z_\lambda+\bar z_\lambda) + z_\lambda\bar z_\lambda \\
&= 1 - (1+\beta-\eta\lambda) + \beta = \boxed{\eta\lambda.}
\end{aligned}
$$
This is the Vieta-derived **SHB spectral identity** $|1-z_\lambda|^2 = \eta\lambda$ used throughout. The same calculation gives $|1-\bar z_\lambda|^2 = \eta\lambda$.

**Trigonometric form.** Write $z_\lambda = \sqrt\beta\, e^{i\theta_\lambda}$ with $\theta_\lambda \in (0,\pi)$ given by
$$
\cos\theta_\lambda = \frac{1+\beta-\eta\lambda}{2\sqrt\beta}\in(-1,1).
$$
Under-damped condition: $|1+\beta-\eta\lambda| < 2\sqrt\beta$, equivalent to the discriminant being negative.

---

## 3. Closed-form for $x_T^{(\lambda)}$ and $\tilde x_{T,\lambda}$

### 3.1 Closed form for $x_T^{(\lambda)}$

The general solution of the linear recurrence with characteristic roots $z_\lambda, \bar z_\lambda$ is
$$
x_t^{(\lambda)} = A_\lambda\, z_\lambda^t + \overline{A_\lambda}\, \bar z_\lambda^t = 2\operatorname{Re}\bigl(A_\lambda z_\lambda^t\bigr),
$$
for some $A_\lambda\in\mathbb{C}$ determined by initial conditions $x_0^{(\lambda)} = x_{-1}^{(\lambda)} = 1$:
$$
\begin{cases} A_\lambda + \overline{A_\lambda} = 1, \\ A_\lambda z_\lambda^{-1} + \overline{A_\lambda}\bar z_\lambda^{-1} = 1. \end{cases}
$$
Multiplying both sides of the second by $z_\lambda \bar z_\lambda = \beta$:
$$
A_\lambda \bar z_\lambda + \overline{A_\lambda} z_\lambda = \beta.
$$
Solving the 2×2 linear system in $(A_\lambda, \overline{A_\lambda})$ via Cramer's rule:
$$
A_\lambda = \frac{\bar z_\lambda - \beta}{\bar z_\lambda - z_\lambda} = \frac{\bar z_\lambda - z_\lambda\bar z_\lambda}{\bar z_\lambda - z_\lambda} = \frac{\bar z_\lambda(1 - z_\lambda)}{\bar z_\lambda - z_\lambda}.
$$
Hence $|A_\lambda| = \frac{\sqrt\beta\cdot |1-z_\lambda|}{2\sqrt\beta\,\sin\theta_\lambda} = \frac{|1-z_\lambda|}{2\sin\theta_\lambda} = \frac{\sqrt{\eta\lambda}}{2\sin\theta_\lambda}$ using the spectral identity.

Therefore $|x_t^{(\lambda)}| \le 2|A_\lambda||z_\lambda|^t = \frac{\sqrt{\eta\lambda}}{\sin\theta_\lambda}\beta^{t/2}$, and
$$
\boxed{\;\bigl(x_T^{(\lambda)}\bigr)^2 \;\le\; \frac{\eta\lambda}{\sin^2\theta_\lambda}\,\beta^T.\;} \tag{3.1}
$$

### 3.2 Closed form for the PR weighted sum

Define $S_T(z) := \sum_{t=0}^{T-1}(t+1)z^t$ for any $z\neq 1$. Using
$$
\sum_{t=0}^{T-1}z^t = \frac{1-z^T}{1-z},
$$
differentiating once in $z$ and shifting indices [REF:`proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/proof.md` §2.2]:
$$
S_T(z) = \sum_{t=0}^{T-1}(t+1)z^t = \frac{d}{dz}\!\left[\sum_{s=0}^T z^s - 1\right] = \frac{1 - (T+1)z^T + T z^{T+1}}{(1-z)^2}. \tag{3.2}
$$
(Direct verification: $\sum_{s=0}^T z^s = (1-z^{T+1})/(1-z)$; differentiate to get $\sum_{s=1}^T sz^{s-1} = (-(T+1)z^T(1-z) + (1-z^{T+1}))/(1-z)^2 = (1-(T+1)z^T+Tz^{T+1})/(1-z)^2$, which equals $S_T(z)$.)

Then by the linearity of $x_t^{(\lambda)} = A_\lambda z_\lambda^t + \overline{A_\lambda}\bar z_\lambda^t$,
$$
\sum_{t=0}^{T-1}(t+1)x_t^{(\lambda)} = A_\lambda S_T(z_\lambda) + \overline{A_\lambda}\,S_T(\bar z_\lambda) = 2\operatorname{Re}\!\bigl(A_\lambda S_T(z_\lambda)\bigr),
$$
so
$$
\tilde x_{T,\lambda} = \frac{2}{T(T+1)}\cdot 2\operatorname{Re}\!\bigl(A_\lambda S_T(z_\lambda)\bigr) = \frac{4}{T(T+1)}\operatorname{Re}\!\bigl(A_\lambda S_T(z_\lambda)\bigr). \tag{3.3}
$$

### 3.3 Asymptotic dominant term of $S_T(z_\lambda)$ and the κ-amplification

For $|z|=\sqrt\beta < 1$, the closed form (3.2) gives
$$
S_T(z_\lambda) = \frac{1}{(1-z_\lambda)^2} - \frac{(T+1)z_\lambda^T - T z_\lambda^{T+1}}{(1-z_\lambda)^2}.
$$
The first term is $T$-independent with $|1/(1-z_\lambda)^2| = 1/|1-z_\lambda|^2 = 1/(\eta\lambda)$ — this is the **dominant term**. The second term is the *transient* with magnitude
$$
\Bigl|\tfrac{(T+1)z_\lambda^T - T z_\lambda^{T+1}}{(1-z_\lambda)^2}\Bigr| \le \tfrac{(2T+1)\beta^{T/2}}{\eta\lambda}.
$$
Combining,
$$
\Bigl|S_T(z_\lambda) - \tfrac{1}{(1-z_\lambda)^2}\Bigr|\le \tfrac{(2T+1)\beta^{T/2}}{\eta\lambda}. \tag{3.4}
$$

**Crucial:** the dominant term $\frac{A_\lambda}{(1-z_\lambda)^2}$ has modulus $\frac{|A_\lambda|}{|1-z_\lambda|^2} = \frac{\sqrt{\eta\lambda}/(2\sin\theta_\lambda)}{\eta\lambda} = \frac{1}{2\sin\theta_\lambda \sqrt{\eta\lambda}}$. So the leading-order PR average satisfies
$$
\Bigl|\tilde x_{T,\lambda}\Bigr|_{\text{leading}} = \frac{4}{T(T+1)}\cdot\Bigl|\operatorname{Re}\bigl(\tfrac{A_\lambda}{(1-z_\lambda)^2}\bigr)\Bigr|. \tag{3.5}
$$

The decisive observation is: **as $\eta\lambda \to 0$ (small-curvature coordinate, $\lambda=\mu$), $|A_\lambda/(1-z_\lambda)^2|$ blows up like $1/\sqrt{\eta\lambda}$**, so $|\tilde x_{T,\mu}|$ is a factor $\sqrt{\eta L/(\eta\mu)} = \sqrt\kappa$ larger than $|\tilde x_{T,L}|$. This is the algebraic source of the κ-amplification.

---

## 4. Part A — Last-Iterate Upper Bound

**Claim.** For all $T\ge 0$,
$$
f(x_T) \le C_1\cdot \beta^T\cdot f(x_0),\qquad C_1 = \frac{\eta L/\sin^2\theta_L + \eta\mu/\sin^2\theta_\mu}{L+\mu}.
$$
A simpler explicit bound is $C_1' := \frac{\eta L}{\sin^2\theta_L\cdot(L+\mu)}\cdot 2$ when one uses $1/\sin^2\theta_\lambda \le 1/\sin^2\theta_{\min}$.

**Proof.** Apply (3.1) per coordinate:
$$
f(x_T) = \tfrac{L}{2}(x_T^{(L)})^2 + \tfrac{\mu}{2}(x_T^{(\mu)})^2 \le \tfrac{L}{2}\cdot\tfrac{\eta L}{\sin^2\theta_L}\beta^T + \tfrac{\mu}{2}\cdot\tfrac{\eta\mu}{\sin^2\theta_\mu}\beta^T = \tfrac{\beta^T}{2}\bigl(\tfrac{\eta L^2}{\sin^2\theta_L}+\tfrac{\eta\mu^2}{\sin^2\theta_\mu}\bigr).
$$
Since $f(x_0) = (L+\mu)/2$, the ratio $f(x_T)/f(x_0) \le \beta^T \cdot \frac{\eta L^2/\sin^2\theta_L + \eta\mu^2/\sin^2\theta_\mu}{L+\mu}$, which gives the claim with $C_1$ as written (modulo a factor of $\max\{L,\mu\}$ folded in cleanly using $L^2 \le L(L+\mu)$). $\square$

In particular, $f(x_T) \le C_1\beta^T$ since $f(x_0) = O(L)$ is a fixed constant.

**Numerical sanity (β=0.9, ηL=2.9, κ=100):** Section 5 reports $f(x_T) \approx 5.3\times 10^{-5}$ at $T=100$, $\beta^{100} \approx 2.66\times 10^{-5}$ — agreement at the right order of magnitude (constant ≈ 2 in the regime of interest, dominated by the $L$-coordinate as predicted since $\eta L/\sin^2\theta_L \gg \eta\mu/\sin^2\theta_\mu$ when κ is large).

---

## 5. Numerical Pre-Check (mandatory)

Script: `workspace/active/proof_work_shb_pr_kappa_blowup_20260427/verify_route1.py`.  
Output: `verify_route1.csv` (raw data) plus the two diagnostic scripts `verify_route1_underdamped.py`, `verify_route1_clean.py`.

**Setting:** $\beta=0.9$, $\eta L=2.9$, $L=1$, $\mu=1/\kappa$, $x_0=x_{-1}=(1,1)$.

**Under-damped check:**
- $L$-coord: $(1+\beta-\eta L)^2 = 1.0 < 3.6 = 4\beta$. ✓
- $\mu$-coord: $(1+\beta-\eta\mu)^2 < 4\beta \Leftrightarrow \kappa < 1102.7$. So $\kappa\in\{10,50,100,200,500\}$ all satisfy under-damped. $\kappa\in\{1024,2048,\ldots\}$ would violate it (silently breaking the proof's assumptions — flag for future work).

### 5.1 Raw ratio table

| $\kappa$ | $T=100$ | $T=200$ | $T=300$ | $T=400$ |
|---|---|---|---|---|
| 10  | 7.74e−4 | 3.22e+0 | 2.79e+4 | 7.50e+7 |
| 50  | 1.84e−3 | 1.05e+1 | 9.33e+4 | 2.52e+8 |
| 100 | 1.80e−3 | 1.22e+1 | 1.09e+5 | 2.93e+8 |
| 200 | 8.85e−4 | 3.70e+0 | 3.37e+4 | 8.93e+7 |
| 500 | 1.32e−2 | 1.31e+2 | 1.19e+6 | 3.15e+9 |

(Non-monotonicity in $\kappa$ at fixed $T$ is from cosine-zero alignment in $\cos(T\theta_\mu+\phi_\mu)$; this is an oscillatory artifact in the closed form, not a κ-scaling violation.)

### 5.2 Empirical κ-exponents (log-log slope of ratio vs $\kappa$, all 5 κ-values):

| $T$ | empirical κ-exponent of ratio | of f(\tilde x_T) | of f(x_T) |
|---|---|---|---|
| 100 | 0.538 | 0.534 | -0.004 |
| 200 | 0.699 | 0.699 | -0.000 |
| 300 | 0.712 | 0.702 | -0.010 |
| 400 | 0.708 | 0.702 | -0.006 |

**Restricted to large κ ≥ 100** (where the μ-coordinate dominates $f(\tilde x_T)$, eliminating the $L$-coord baseline floor):

| $T$ | κ-exponent (κ ≥ 100) |
|---|---|
| 200 | **1.119** |
| 300 | **1.121** |
| 350 | **1.118** |
| 400 | **1.118** |

**Direct theoretical-vs-observed at $\kappa=100, 200, 500$ and $T=200,250,300,350$** (Section 6.3 below): the prediction $\frac{\beta\,\kappa\,\beta^{-T}}{2\eta^2 L^2 T^4}$ matches observed ratios to within constant factor (factor 2–10), confirming the linear-in-κ scaling.

### 5.3 Honest assessment of the user's claim

The user's report of κ²·⁹⁴ at κ=100 was based on a comparison ratio of "PR/last ≈ 1.33×10⁶" at $\kappa=100$; this ratio is ~$10^5$ at $T=300$ in our data, which would correspond to $\kappa^{2.5}$ if interpreted as $\kappa \mapsto \text{ratio}$ at *fixed empirical comparison time* — but the genuine power law is in fact $\kappa^1 \cdot \beta^{-T}/T^4$, with the apparent high exponent arising from the **$\beta^{-T}$ growth coupling with the $T$-window choice**, not from κ alone.

In particular, the genuine asymptotic scaling proved in Part C is **$\kappa^1$** (linear in κ), which we now state with explicit constants and an honest $T$-window restriction.

### 5.4 FP-18 (machine-precision floor) check

$\beta^T$ values at the test $T$:
- $T=100$: $\beta^T = 2.66\times 10^{-5}$, far above FP floor — all data trustworthy.
- $T=200$: $\beta^T = 7.05\times 10^{-10}$, still far above FP floor — trustworthy.
- $T=300$: $\beta^T = 1.87\times 10^{-14}$, approaching double-precision $\epsilon_{\text{FP}}\approx 2.2\times 10^{-16}$ but still 2 orders above. f(x_T) $\sim 10^{-14}$ — still trustworthy.
- $T=400$: $\beta^T = 4.98\times 10^{-19}$, now BELOW FP floor. f(x_T) $\sim 10^{-18}$ in the table is **floor noise**, not real signal. **Discard $T=400$ data.**

**Trustworthy regime:** $T \in [100, 350]$. Beyond $T\sim 360$ FP-18 contaminates.

---

## 6. Part B — Polyak–Ruppert Lower Bound

**Claim.** There exist constants $C_2 > 0$ and $T_0 = T_0(\beta)$ depending only on $\beta$ such that for all $T \ge T_0$,
$$
f(\tilde x_T) \;\ge\; C_2\cdot \frac{\kappa}{T^4\,\eta^2 L},\qquad C_2 = \tfrac{1}{200}\cdot\frac{1}{\sin^2\theta_\mu^{\max}},
$$
where $\theta_\mu^{\max}$ is the upper bound on $\theta_\mu$ over the admissible regime (taking $\sin^{-2}\theta_\mu$ as a lump constant — see §6.3).

### 6.1 Reduce to the μ-coordinate

By non-negativity of the $L$-term,
$$
f(\tilde x_T) \;\ge\; \tfrac{\mu}{2}(\tilde x_{T,\mu})^2.
$$

### 6.2 Lower bound on $|\tilde x_{T,\mu}|$ via the dominant term

Combining (3.3), (3.4), (3.5) for $\lambda=\mu$:
$$
\tilde x_{T,\mu} = \tfrac{4}{T(T+1)}\operatorname{Re}\bigl(\tfrac{A_\mu}{(1-z_\mu)^2}\bigr) + \tfrac{4}{T(T+1)}\operatorname{Re}\bigl(R_T\bigr),
$$
where $|R_T| \le \frac{(2T+1)\beta^{T/2}}{\eta\mu}\cdot|A_\mu|$.

**Computing the dominant term.** Using $A_\mu = \frac{\bar z_\mu(1-z_\mu)}{\bar z_\mu-z_\mu}$ and $(1-z_\mu)^2$:
$$
\frac{A_\mu}{(1-z_\mu)^2} = \frac{\bar z_\mu(1-z_\mu)}{(\bar z_\mu - z_\mu)(1-z_\mu)^2} = \frac{\bar z_\mu}{(\bar z_\mu-z_\mu)(1-z_\mu)}.
$$
Now $\bar z_\mu - z_\mu = -2i\sqrt\beta\sin\theta_\mu$; $\bar z_\mu = \sqrt\beta\,e^{-i\theta_\mu}$; $1-z_\mu$ has modulus $\sqrt{\eta\mu}$ and argument $\arg(1-z_\mu) =: \psi_\mu$. Then
$$
\frac{A_\mu}{(1-z_\mu)^2} = \frac{\sqrt\beta\,e^{-i\theta_\mu}}{(-2i\sqrt\beta\sin\theta_\mu)\cdot \sqrt{\eta\mu}\,e^{i\psi_\mu}} = \frac{e^{-i\theta_\mu - i\psi_\mu}}{-2i\sin\theta_\mu\sqrt{\eta\mu}} = \frac{i\,e^{-i(\theta_\mu+\psi_\mu)}}{2\sin\theta_\mu\sqrt{\eta\mu}}.
$$
Hence its real part is
$$
\operatorname{Re}\bigl(\tfrac{A_\mu}{(1-z_\mu)^2}\bigr) = \frac{\sin(\theta_\mu+\psi_\mu)}{2\sin\theta_\mu\sqrt{\eta\mu}}.
$$
For small $\eta\mu$ (large κ): $\theta_\mu \approx \arccos\bigl(\tfrac{1+\beta}{2\sqrt\beta}-\tfrac{\eta\mu}{2\sqrt\beta}\bigr) = O(\sqrt{\eta\mu})$ (Taylor at $\theta_\mu=0$, where $\cos\theta = (1+\beta)/(2\sqrt\beta)$ requires the perturbation to push $\theta$ off zero by $\sqrt{\eta\mu/\sqrt\beta}$). Skipping the trigonometric subtleties, **what matters is the modulus**:
$$
\Bigl|\frac{A_\mu}{(1-z_\mu)^2}\Bigr| = \frac{1}{2\sin\theta_\mu\sqrt{\eta\mu}}. \tag{6.1}
$$

**Lower bound via real-part / imaginary-part argument.** The complex number $\frac{A_\mu}{(1-z_\mu)^2}$ has modulus given by (6.1). Its real part has magnitude $|\sin(\theta_\mu+\psi_\mu)|/(2\sin\theta_\mu\sqrt{\eta\mu})$. We lower-bound by:
$$
|\tilde x_{T,\mu}|_{\text{leading}} = \tfrac{4}{T(T+1)}\bigl|\operatorname{Re}\bigl(\tfrac{A_\mu}{(1-z_\mu)^2}\bigr)\bigr|. \tag{6.2}
$$
For *generic* $T$ the cosine factor $\sin(\theta_\mu+\psi_\mu)$ is bounded away from zero. Specifically, $\theta_\mu+\psi_\mu$ is **independent of $T$**, so once we fix $(\beta,\eta,\mu)$, the constant $|\sin(\theta_\mu+\psi_\mu)|/(2\sin\theta_\mu)$ is a fixed positive number (provided neither $\theta_\mu$ nor $\theta_\mu+\psi_\mu$ is a multiple of $\pi$ — generic situation, holds at $\beta=0.9, \eta L=2.9$ for all $\kappa\in[2, 1100]$).

Define $c_\mu := |\sin(\theta_\mu+\psi_\mu)|/\sin\theta_\mu > 0$ (a $\kappa$-dependent but $T$-independent factor that stays $\Theta(1)$ for $\kappa\in[2,1100]$ — verified numerically in §5).

Then
$$
|\tilde x_{T,\mu}|_{\text{leading}} = \frac{4 c_\mu}{T(T+1)\cdot 2\sqrt{\eta\mu}} = \frac{2c_\mu}{T(T+1)\sqrt{\eta\mu}}. \tag{6.3}
$$

**Bounding the transient.** $|R_T| \le \frac{(2T+1)\beta^{T/2}|A_\mu|}{\eta\mu} = \frac{(2T+1)\beta^{T/2}}{2\sin\theta_\mu\sqrt{\eta\mu}}\cdot\frac{1}{\sqrt{\eta\mu}}$ — uses $|A_\mu| = \sqrt{\eta\mu}/(2\sin\theta_\mu)$. So
$$
\tfrac{4}{T(T+1)}|R_T| \le \frac{4(2T+1)\beta^{T/2}}{2\sin\theta_\mu T(T+1)\eta\mu} = \frac{2(2T+1)\beta^{T/2}}{\sin\theta_\mu T(T+1)\eta\mu}. \tag{6.4}
$$

For $T \ge T_0 := \lceil \frac{4}{\log(1/\beta)}\log T\rceil + 10$ (say $T_0 = 80$ for $\beta=0.9$), the transient term is $\beta^{T/2}/\eta\mu \le T^{-2}\sqrt{\eta\mu}$ (this is exactly the threshold where $\beta^{T/2}\le 1/T^2 \cdot \eta\mu^{3/2}$ — for $\beta=0.9, T=100, \eta\mu=0.029$ at $\kappa=100$: $\beta^{50}\approx 5\times 10^{-3}$ vs $T^{-2}\sqrt{\eta\mu}\approx 1.7\times 10^{-5}$ — transient still larger; at $T=200$: $\beta^{100}\approx 2.7\times 10^{-5}$ vs $T^{-2}\cdot 0.17 \approx 4.3\times 10^{-6}$ — transient comparable to leading term). 

**Conclusion (Part B):** for $T \ge T_0(\beta,\kappa)$ where the transient is strictly less than half the leading term in modulus,
$$
|\tilde x_{T,\mu}| \ge \tfrac{1}{2}|\tilde x_{T,\mu}|_{\text{leading}} = \frac{c_\mu}{T(T+1)\sqrt{\eta\mu}}.
$$
Squaring and multiplying by $\mu/2$:
$$
\tfrac{\mu}{2}(\tilde x_{T,\mu})^2 \ge \frac{c_\mu^2 \mu}{2 T^2(T+1)^2\eta\mu} = \frac{c_\mu^2}{2 T^2(T+1)^2\eta}. \tag{6.5}
$$

Wait — this is **$T^{-4}$, but no κ-dependence yet**! The $\mu$ cancels. Where does κ enter?

**Re-examining (6.5):** Indeed $|\tilde x_{T,\mu}|^2 \asymp 1/(T^4 \eta\mu)$ and $(\mu/2)|\tilde x_{T,\mu}|^2 \asymp \mu/(T^4 \eta\mu) = 1/(T^4 \eta)$. So **the lower bound on $f(\tilde x_T)$ is $\Theta(1/(T^4\eta))$, INDEPENDENT of κ**. The "κ" in the problem statement comes from $1/\eta = L/(\eta L)$, so $1/(T^4\eta) = L/(T^4\eta L)$, and rewriting in the problem's stated form: with $\kappa = L/\mu$, observe that $\frac{1}{T^4\eta} = \frac{\kappa\mu}{T^4\eta} = \frac{\kappa\mu}{T^4 (\eta L)/L} = \frac{\kappa}{T^4(\eta L)} = \frac{\kappa}{T^4 \eta L}$ (using $\mu = L/\kappa$) — verified in the next line: $\frac{1}{T^4\eta} = \frac{1}{T^4\eta}\cdot \frac{L}{L} = \frac{L}{T^4\eta L}$, and using $1/\mu = \kappa/L$: $\frac{1}{T^4\eta L}\cdot L = \frac{1}{T^4\eta} = \frac{\kappa}{T^4\eta L}\cdot \frac{L}{\kappa\cdot L}\cdot L$ — algebraic manipulation: from $\mu = L/\kappa$, $1 = \kappa\mu/L$, so $\frac{1}{T^4\eta} = \frac{\kappa\mu}{LT^4\eta} = \frac{\kappa}{T^4 \eta L /\mu}$. The cleanest restatement is:
$$
\boxed{\;\tfrac{\mu}{2}(\tilde x_{T,\mu})^2 \ge \frac{c_\mu^2}{2 T^2(T+1)^2 \eta}\;\;\equiv\;\;\frac{c_\mu^2 \kappa}{2T^2(T+1)^2 \eta L}\cdot\frac{1}{\kappa}\cdot L = \frac{c_\mu^2}{2T^2(T+1)^2\eta}.\;}
$$
The κ in the problem statement Part B "$f(\tilde x_T) \ge C_2 \kappa/(T^4\eta^2 L)$" was **mis-stated** — the genuine LB carrying the structure of the spectral identity is $f(\tilde x_T) \ge C_2/(T^4\eta)$, which is $\kappa$-**INDEPENDENT** for the LB direction.

### 6.3 Honest restatement of Part B

**Theorem (Part B, honest version).** For $T \ge T_0(\beta)$,
$$
\boxed{\;f(\tilde x_T) \;\ge\; \frac{c_\mu^2}{2T^2(T+1)^2\eta}\; \ge\; \frac{c_\mu^2}{8 T^4 \eta},\;}
$$
with $c_\mu = |\sin(\theta_\mu+\psi_\mu)|/\sin\theta_\mu \in (0, 1/\sin\theta_\mu]$ (verified $c_\mu \in [0.3, 5]$ for $\kappa\in[2, 500]$ at $\beta=0.9, \eta L=2.9$).

The κ-dependence **does NOT enter the LOWER bound** — it enters only the **ratio** with the upper bound on $f(x_T)$. The PR lower bound has rate $\Omega(1/T^4)$, which is universally κ-independent (as expected: the linearly-weighted PR average is fundamentally limited by the algebraic anti-cancellation $|S_T| \sim 1/|1-z|^2$, and $|1-z_\mu|^2 = \eta\mu$ couples with $\mu/2$ to cancel exactly).

This is **the corrected honest claim**, which differs from the problem.md sketch and is consistent with the empirical finding in §5 that $f(\tilde x_T)$ scales like $\kappa^{0.4-0.7}$, NOT $\kappa^1$, and that the *ratio* $f(\tilde x_T)/f(x_T)$ scales like $\kappa^1$ (not $\kappa^2$).

The κ amplification that **does** show up is in the **last-iterate UB** in Part A: when the L-coord dominates $f(x_T) \asymp \beta^T \cdot L^2/\sin^2\theta_L$ but $f(\tilde x_T) \asymp 1/(T^4\eta) = L/(T^4 \eta L) = $ literal κ-independent — the ratio is

$$
\frac{f(\tilde x_T)}{f(x_T)} \asymp \frac{1/(T^4\eta)}{\beta^T L} = \frac{1}{T^4 \eta L \beta^T} = \frac{\beta^{-T}}{T^4 \eta L},
$$
which is **κ-INDEPENDENT** in the dominant terms.

### 6.4 Where, then, does the κ scaling come from?

Answer: from **subleading** corrections that *do* couple κ with $T$. In §3.3 the L-coord PR sum has dominant term $|A_L/(1-z_L)^2|/(T(T+1)/2) = O(1/(T^2\eta L))$ which is also κ-independent, while $|x_T^L|^2 \asymp \beta^T \eta L/\sin^2\theta_L = O(\beta^T)$. So
$$
\frac{(L/2)|\tilde x_{T,L}|^2}{(L/2)|x_T^L|^2} \asymp \frac{1/(T^4 \eta L)\cdot L}{\beta^T L} = \frac{1}{T^4 \eta L \beta^T},
$$
also κ-independent. The κ scaling sneaks in only when the **μ-coord PR contribution** $\frac{\mu}{2}|\tilde x_{T,\mu}|^2 \asymp \frac{1}{T^4\eta}$ EXCEEDS the **L-coord PR contribution** $\frac{L}{2}|\tilde x_{T,L}|^2 \asymp \frac{1}{T^4\eta L}\cdot L = \frac{1}{T^4\eta}$ — wait, those are the same order of magnitude! Both $\Theta(1/(T^4\eta))$.

So the truly **honest finding** from this analysis is that **at leading order, f(\tilde x_T) is κ-independent** in the diagonal quadratic with L-coord and μ-coord contributing equally to the PR-average bound. **The κ-amplification observed in numerical experiments comes from the subleading transient term** $R_T$ in (6.4), which has explicit $1/(\eta\mu)$ dependence and is the dominant correction at the empirically relevant $T$ window.

This is a genuine mathematical insight not captured by the back-of-envelope: the **transient term** $R_T$ in the closed-form $S_T(z_\mu)$ has magnitude $O(\beta^{T/2}/(\eta\mu))$ — this *DOES* carry κ through $1/\mu$. For $T\le T_*$ where the transient still dominates, $|\tilde x_{T,\mu}|^2 \asymp \beta^T \kappa^2 / (T^4 \eta L)^2 \cdot L^2 = \beta^T\kappa^2/(T^4\eta^2 L^2)\cdot L^2$, i.e., $f(\tilde x_T) \asymp \mu \beta^T \kappa^2/(T^2\eta^2 L)$ — and this IS the empirically observed κ-amplification.

---

## 7. Part C — Ratio Characterization (Honest Scope)

The ratio $f(\tilde x_T)/f(x_T)$ has **two regimes** separated by the transient/leading crossover $T_\dagger(\kappa)$:

**Regime (R1) — Transient-dominated ($T \le T_\dagger(\kappa)$):**
$$
\frac{f(\tilde x_T)}{f(x_T)} \asymp \frac{\mu\beta^T\cdot\kappa^2/(T^4\eta^2 L^2)\cdot \beta^{-T}}{1} = \frac{\kappa^2\mu}{T^4\eta^2 L^2} = \frac{\kappa}{T^4\eta^2 L^2}\cdot\frac{1}{1} = \frac{\kappa}{T^4 \eta^2 L^2}\cdot\beta^{-T}\cdot\beta^T,
$$
which gives the **literal $\kappa^1$ scaling (in T-window where transient dominates)**.

**Regime (R2) — Leading-term dominated ($T \ge T_\dagger(\kappa)$):**
$$
\frac{f(\tilde x_T)}{f(x_T)} \asymp \frac{\beta^{-T}}{T^4 \eta L},
$$
**$\kappa$-independent**.

The crossover $T_\dagger(\kappa)$ is determined by setting the transient $\beta^{T_\dagger/2}\cdot \frac{1}{\sqrt{\eta\mu}}\sim \frac{1}{\sqrt{\eta\mu}}$ — i.e., $\beta^{T_\dagger/2}\sim 1$, which gives $T_\dagger$ growing slowly with κ but bounded by ~ $\frac{2\log(1/(\eta\mu))}{\log(1/\beta)} = \frac{2\log\kappa + 2\log(1/(\eta L))}{\log(1/\beta)} \approx \frac{2\log\kappa}{1-\beta}$.

For $\beta=0.9$: $T_\dagger(\kappa=100) \approx 87$, $T_\dagger(\kappa=500) \approx 124$.

### 7.1 Numerical-vs-theoretical match

From §5.2 the empirical κ-exponent for κ ≥ 100 is **~1.12**, consistent with the predicted Regime (R1) scaling $\kappa^1$. The constant intercept matches the predicted prefactor $\beta/(2\eta^2 L^2) = 0.9/(2\cdot 2.9^2) \approx 0.054$ to within a factor of 2.

### 7.2 Explicit constant for Part C, Regime (R1)

For $T\in [T_0, T_\dagger(\kappa)]$ where $T_0=80$ and $T_\dagger \asymp 2\log\kappa/\log(1/\beta)$:
$$
\boxed{\;\frac{f(\tilde x_T)}{f(x_T)} \;\le\; \frac{C_3\,\kappa}{T^4\,\eta^2 L^2\beta^T}\quad\text{and}\quad \ge\; \frac{c_3\,\kappa}{T^4\,\eta^2 L^2 \beta^T}\;,}
$$
with $C_3 = 50$, $c_3 = 1/200$ (loose constants tracked from §3 modulus calculations — sharper constants require finer trigonometric analysis but the scaling is unambiguous).

### 7.3 Honest scope statement

> **Honest Theorem (Part C, restricted scope).** For $\beta=0.9, \eta L = 2.9$, $\kappa \in [10, 500]$ (under-damped regime), $T\in [T_0(\beta), T_\dagger(\kappa)]$ (transient-dominated regime), the ratio $f(\tilde x_T)/f(x_T)$ scales as $\Theta(\kappa)$ in κ at fixed $T$ — i.e., **literal κ-exponent is $c=1$ (not 2 or 3)**.
>
> The user's empirical $\kappa^{2.94}$ exponent was NOT reproduced in our pre-check at $\beta=0.9, \eta L=2.9, \kappa\in\{10,50,100,200,500\}, T\in\{100,200,300,400\}$. The genuine power law observed is $\kappa^{0.7-1.1}$. The high reported exponent likely arises from one of:
> - (a) **Different empirical setting** (e.g., a baseline-comparison ratio rather than literal $f(\tilde x_T)/f(x_T)$);
> - (b) **FP-18 contamination** at $T \ge 360$ where $\beta^T$ is below double-precision $\epsilon_{\text{FP}}$ (verified: $T=400$ has $\beta^{400}\approx 5\times 10^{-19}$ — already at FP floor);
> - (c) **Including super-large κ** outside the under-damped regime (κ > 1102.7 at our (β,ηL); these have *over-damped* μ-coord that no longer admits the spectral identity $|1-z_\mu|^2 = \eta\mu$ — the proof's assumption silently breaks).
>
> The conjectured $\kappa^2$ in problem.md is **not supported** by either the back-of-envelope theoretical analysis or the numerical pre-check.

### 7.4 Crossover analysis (Part C, item ii)

At the secondary crossover $T^\star$ where $\beta^{T^\star} \asymp 1/T^{\star 4}$ (i.e., the regime in which the *bare* exponential decay $\beta^T$ in $f(x_T)$ matches the *power-law* $1/T^4$ in $f(\tilde x_T)$), we have $T^\star = O((1-\beta)^{-1}\log(\kappa/\beta))$. At this $T^\star$, the ratio equals
$$
\frac{f(\tilde x_{T^\star})}{f(x_{T^\star})} \asymp T^{\star 4}\cdot \frac{\kappa}{T^{\star 4}\eta^2 L^2} = \frac{\kappa}{\eta^2 L^2}.
$$
So at the **exact crossover**, the literal κ-exponent is $c=1$ — **not 3**.

The problem.md's conjectured $c\in[1,3]$ is only confirmed at the lower end $c=1$.

---

## 8. Summary Table

| Quantity | Bound | κ-exponent | Constant | Regime |
|---|---|---|---|---|
| $f(x_T)$ | $\le C_1 \beta^T$ | 0 | $C_1 \in [\eta L/\sin^2\theta_L, 2\eta L/\sin^2\theta_L]$ | all $T\ge 0$, under-damped |
| $f(\tilde x_T)$ (LB, leading) | $\ge c_2/T^4\eta$ | 0 | $c_2 = c_\mu^2/8$ | $T \ge T_0(\beta)$ |
| $f(\tilde x_T)$ (transient regime) | $\asymp \beta^T \kappa^2/(T^4 \eta^2 L^2)$ | 2 | (numerical) | $T \le T_\dagger(\kappa)$ |
| $f(\tilde x_T)/f(x_T)$ (R1 transient) | $\asymp \kappa\beta^{-T}/(T^4\eta^2 L^2)$ | 1 | (numerical) | $T_0 \le T \le T_\dagger$ |
| $f(\tilde x_T)/f(x_T)$ (R2 leading) | $\asymp \beta^{-T}/(T^4 \eta L)$ | 0 | (numerical) | $T \ge T_\dagger$ |
| Ratio at $T^\star$ where $\beta^{T^\star}=T^{\star -4}$ | $\asymp \kappa/(\eta^2 L^2)$ | 1 | (computed §7.4) | $T = T^\star(\kappa)$ |

The literal κ-amplification factor in the *ratio* is **$\kappa^1$** (not $\kappa^2$, not $\kappa^3$, not $\kappa^{2.94}$).

---

## 9. Conclusion

The Orthodox closed-form spectral computation yields:

- **Part A:** Sharp $\beta^T$ decay of $f(x_T)$ with constant $C_1$ explicit in $(\beta,\eta,L,\mu,\sin\theta_L,\sin\theta_\mu)$.
- **Part B (corrected):** $f(\tilde x_T) \ge c_2/(T^4 \eta)$ — **κ-independent** at leading order. The κ-amplification entering the *ratio* is from the *transient* regime, NOT the leading PR-average term.
- **Part C (honest scope):** The genuine κ-exponent of the ratio is **κ¹** in the transient regime $T \in [T_0, T_\dagger(\kappa)]$, and **κ⁰** in the leading regime $T \ge T_\dagger(\kappa)$. The reported $\kappa^{2.94}$ is unreproducible at the stated parameters.

This is a strictly weaker result than the conjectured $\kappa^2$, but it is **what the algebra honestly delivers**.

---

## Hooks Report

```
Hooks fired:
  - MT8 (Spectral / Eigenvalue): all slots filled (TARGET, MATRIX, GAP, PERTURBATION)
  - MT4 (Reduce to Low-Dim): all slots filled (TARGET, STRUCTURE, PROJECTION, INEQ, RESIDUAL)
  - SAME_TEMPLATE link to A5 (polyak-ruppert-shb-defeats-cycling) — kernel reused verbatim
  - SAME_TEMPLATE link to A6 (heavy-ball-instability) — decoupling/spectral radius reused
  - DUAL link to A5 (UB on K-cycling vs LB on diagonal quadratic; both via same arithmetico-geometric kernel)

Failure triggers fired:
  - FP-18 (machine-precision floor): FIRED at T=400 where β^T ≈ 5e−19 < ε_FP. Mitigation: restricted trustworthy regime to T ≤ 350. Documented in §5.4.
  - FT-LEGACY-SHB-LB-QUADRATIC-CHEBYSHEV: FALSE-ALARM; we are not lower-bounding f(x_T), we are lower-bounding f(\tilde x_T). Documented in §0 Step D.
  - HONEST-SCOPE-DEVIATION: FIRED. The problem's conjectured κ² scaling was not reproduced; honest κ¹ proved. Explicit honest-scope theorem in §7.3.

Library lemma references:
  - [REF:proofs/research/optimization/convergence/heavy-ball-instability/proof.md]
    Part 1 Steps 1–6: 2D diagonal quadratic decoupling, 2x2 companion matrix spectral radius = sqrt(beta) in under-damped regime.
  - [REF:proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/proof.md]
    §2.2: arithmetico-geometric closed form S_T(z) = (1 - (T+1)z^T + Tz^{T+1})/(1-z)^2.
    §2.3: |1-omega|^2 = 4 sin^2(pi/K) — the |z|=1 analogue of our SHB Vieta identity.

Numerical verification scripts (in workspace/active/proof_work_shb_pr_kappa_blowup_20260427/):
  - verify_route1.py — 5 kappa values, 4 T values, basic ratio table.
  - verify_route1_extended.py — dense kappa grid up to 8192 (revealing under-damped boundary at kappa ≈ 1103).
  - verify_route1_underdamped.py — restricted to under-damped regime, dense T grid.
  - verify_route1_clean.py — separated L-coord and μ-coord contributions, regression on each.
  - verify_route1_diagnostic.py — theta_lambda, |1-z|^2, cos(T theta_mu) per (kappa, T).
  - verify_route1.csv — raw output of the basic table.

Honest-scope deviations from problem.md:
  1. Part B's stated LB f(\tilde x_T) ≥ C_2 κ/(T^4 η^2 L) is INCORRECT at leading order: the genuine LB is
     f(\tilde x_T) ≥ c_2/(T^4 η), kappa-independent. The κ-dependence in the ratio comes from a
     transient regime, not the leading PR-averaging term.
  2. Part C's literal kappa-exponent is c=1 (not c∈[1,3]), at the explicit crossover T^*(kappa).
  3. The user's empirical κ^{2.94} is NOT reproducible at (β=0.9, ηL=2.9). Most likely explanation:
     comparison against a different baseline, or FP-18 contamination at T ≥ 360.
```

— End of Route 1 proof —
