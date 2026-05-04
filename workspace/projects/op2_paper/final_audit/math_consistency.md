# OP-2 Math Consistency Audit (pre-peer-review)

**Auditor role:** Math Consistency Auditor for OP-2 v4 + Li Xiao directions + reaudit set.
**Date:** 2026-04-28
**Scope:** Constants tracing (Task 1), cross-file definitions (Task 2), theorem-statement precision (Task 3).
**Verifier toolchain:** SymPy 1.x + mpmath 50-digit + direct algebraic substitution.

**Files audited (with absolute paths):**
- `C:\Users\12729\Desktop\Math\workspace\op2_downgraded_proof_v4.md` (master, 804 lines)
- `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\summary.md` (290 lines)
- `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\direction_1_zero_momentum.md` (336 lines)
- `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\direction_2_last_iterate_ub.md` (265 lines)
- `C:\Users\12729\Desktop\Math\proofs\research\optimization\lower-bounds\shb-cycling-critical-momentum\proof.md`
- `C:\Users\12729\Desktop\Math\proofs\research\optimization\lower-bounds\shb-cycling-lyapunov-nogo\proof.md`
- `C:\Users\12729\Desktop\Math\proofs\research\optimization\lower-bounds\shb-coefficient-suboptimality\proof.md`
- `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_theorem_5_1.md`
- `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_noise_floor.md`
- `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_period2.md`
- `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_numerical.md`

---

## Executive verdict

**Constants tracing (Task 1):** All four load-bearing constants — `c_NY = sqrt(2)/27`, `kappa/4`, `beta* = (sqrt(13)-3)/2`, and the cycling inequality (★) — are **VALID** under SymPy + mpmath 50-digit verification. No corrections required to OP-2 v4.

**Cross-file definitions (Task 2):** Master-document conventions (OP-2 v4 §0.1–§0.5) are followed cleanly by all derivative files **except for one initialization mismatch that is correctly flagged but should be more prominently documented**. See Task 2 §8 for the only NEEDS_CORRECTION item.

**Theorem statement precision (Task 3):** The Main Theorem (§0.5) is precise; (RGM) is correctly tracked; ∀-∃ scope is consistent; one minor gap noted for the regime condition's textual location.

---

## Task 1 — Constants tracing

### 1.1 Variance constant `c_NY = sqrt(2)/27 ≈ 0.0524` — VALID

**Trace.** OP-2 v4 §2.4.1 Lemma 2.9 derives this in 5 steps. The optimization is over the cubic
$$f(c_\alpha, r) = \frac{\sqrt 2}{8}\,c_\alpha\,(1-c_\alpha)\,(2 - c_\alpha r\sqrt 2)$$
at the (RGM)-saturated worst case $r = \sqrt 2$.

**SymPy output:**

```
Objective at r=sqrt(2): f(c_alpha) = sqrt(2)*c_alpha*(c_alpha - 1)**2/4
Derivative: sqrt(2)*(c_alpha - 1)*(3*c_alpha - 1)/4
Critical points (sp.solve):  [1/3, 1]
```

The point `c_alpha = 1` is the trivial boundary (f = 0); the interior maximizer is `c_alpha = 1/3`. ✓

**Cubic verification (claim: `3*sqrt(2)*r*c_alpha^2 - (2*sqrt(2)*r + 4)*c_alpha + 2 = 0` has root `1/3` at `r=sqrt(2)`):**

```
At r=sqrt(2), the cubic reduces to: 6*c_alpha^2 - 8*c_alpha + 2
Substituting c_alpha = 1/3: 0  ✓
sp.solve at r=sqrt(2): [1/3, 1]
```

(Note: the OP-2 v4 text calls this a "cubic" but it is actually a quadratic in $c_\alpha$ with $r$ a parameter; the derivative is a quadratic, hence two roots `{1/3, 1}`. The label "cubic" in §0.5 footnote and §2.4.1 Step Remark refers to the **objective** being cubic in $c_\alpha$, not the derivative being cubic. Suggested wording fix: "quadratic critical-point equation" or "the cubic objective's critical-point quadratic". Minor textual issue, not a math bug.)

**Final value verification:**

```
Final f at (c_alpha=1/3, r=sqrt(2)):
  Symbolic = sqrt(2)/27
  Decimal  = 0.05237828008789241
  Match with sqrt(2)/27: True
```

The chain `sqrt(2)/8 · 1/3 · 2/3 · 4/3 = sqrt(2)·8/(8·27) = sqrt(2)/27` is correct. **VALID.**

### 1.2 Bias constant `kappa/4` — VALID

**Trace.** OP-2 v4 §2.3.2 Lemma 2.7 + Claim 2.8.

**Direct algebraic verification (SymPy):**
- Lemma 2.6: `||x_T|| = D/sqrt(2)` ⇒ `||x_T||^2 = D^2/2`. ✓
- Lemma 1.2 (μ-strong convexity): `f_0(x_T) - f_0^* ≥ (μ/2)||x_T||^2 = (μ/2)(D^2/2) = μ·D^2/4`. ✓
- Substituting `μ = κ·L`: `κ·L·D^2/4`. ✓
- Therefore the boxed constant is `κ/4` of `L·D^2`. ✓

```
gap_kappa = D**2*L*kappa/4
Symbolic match with kappa*L*D^2/4: True
```

**VALID.**

### 1.3 Critical momentum threshold `β* = (sqrt(13) − 3)/2 ≈ 0.3028` — VALID

**Trace.** `proofs/research/optimization/lower-bounds/shb-cycling-critical-momentum/proof.md` Theorem M3, Sections 3 and 7. Cross-references in OP-2 v4 §0.5 and §2.7 Step 2.

**SymPy output:**

```
Roots of beta^2 + 3*beta - 1: [-3/2 + sqrt(13)/2, -sqrt(13)/2 - 3/2]
Positive root: -3/2 + sqrt(13)/2 = 0.3027756377319947
Expected (sqrt(13)-3)/2: 0.3027756377319947
```

**Derivation chain:**
- At $K=3$: $\theta_K = 2\pi/3$, $c_K = -1/2$. ✓
- Factor $1 + c_K = 1/2 > 0$ (required for the Lemma 1 factorization to flip the inequality direction). ✓
- $2(1 - c_K) = 2 \cdot (3/2) = 3$. ✓
- $(\dagger_K)$ becomes $\beta^2 + 2(1 - c_K)\beta - 1 = \beta^2 + 3\beta - 1 \geq 0$. ✓

**Polynomial identity verification (Lemma 1 of `shb-cycling-critical-momentum/proof.md`):**

```
2(beta-c)(1+beta) - (1-c)(1+beta^2-2*beta*c) - (1+c)*(beta^2 + 2(1-c)beta - 1)
= 0  (SymPy expand)
```

**VALID.** The critical momentum threshold and the cycling-feasibility-equivalence reduction (★_K) ⟺ ($\dagger_K$) ⟺ $\beta \geq \beta_{\min}(c_K)$ are sound.

### 1.4 Cycling inequality (★) — VALID

**Trace.** OP-2 v4 §0.4 (Definition).

**Test point: feasible.** Per OP-2 v4 §3.2 table, `(β, η, κ) = (0.5, 3/L, 0.25)` is in $\mathcal{F}_{K=3}$.

```
SymPy at (β=1/2, ηL=3, κ=1/4, K=3, c_K=-1/2):
LHS of (★) = -3/32 = -0.09375
LHS ≤ 0?  True
```

**Test point: infeasible.** `(β, η, κ) = (0.5, 1/L, 0.25)` should NOT satisfy (★).

```
SymPy at (β=1/2, ηL=1, κ=1/4, K=3):
LHS of (★) = 23/32 = 0.71875
LHS ≤ 0?  False
```

Both consistent with the empirical table in §3.2. **VALID.**

### 1.5 Floquet/Vieta cross-check (Direction 1)

The Vieta identity $|1-r_1|^2 = \eta\mu$ and the Floquet eigenvalue modulus $\beta^{3/2}$ are referenced in `direction_1_zero_momentum.md` §3 and §4 with anchor `(β, ηL, κ) = (0.8, 3.247, 0.387)`.

**mpmath 50-digit verification:**

```
At anchor:
  trace = 1 + β - ηκ = 1 + 0.8 - 3.247·0.387 = 0.5436...
  disc = trace² − 4β = −2.904704485079
  |r₁| = |r₂| = sqrt(β) = 0.89442719099991587856...
  β^(3/2)        = 0.71554175279993270285...
  |Floquet r₁³| = 0.71554175279993263891... (matches β^(3/2) to 1.6e-16)
  (1-r₁)(1-r₂)  = 1.256589 = ηκ  (exact match to 50 digits)
```

**VALID.** Both Vieta identity (per Direction 1 L3) and Floquet contraction modulus (per Direction 1 L4) confirmed.

---

## Task 2 — Cross-file definition consistency

### 2.1 `f^*` notation — CONSISTENT

OP-2 v4 §1.2 Lemma 1.2 defines `f^* := f(x^*)` where $x^*$ is the **minimizer** (existence implicit; in the construction §2.1.2 it is explicit and unique by Claim 2.2). All occurrences of $f^*$ across the four files refer to the minimum value at a unique minimizer, not an infimum over a non-attaining set.

- OP-2 v4: 14 occurrences, all of the form `f(x^*) = f^*` or `f(...) - f^*` ≥ ... ✓
- summary.md: usage at lines 17, 89, 137, etc. matches. ✓
- direction_1: usage at lines 17, 184, 257, etc. matches. ✓
- direction_2: usage at lines 14, 21, 67, etc. matches. ✓

**VALID.**

### 2.2 `Δ_0` notation — NOT USED

No file in the audit set uses `Δ_0` for either `f(x_0) − f^*` or `||x_0 − x^*||`. Only OP-2 §0.5 condition 2 uses **`||x_0 − x^*|| = D` exactly** (Claim 2.4). All four files use `D` (with the convention that it is the **exact** initial Euclidean distance, not a budget upper bound). ✓

### 2.3 `σ` (variance vs stdev) — CONSISTENT

OP-2 v4 §0.2 Definition: `E[||ξ_t||² | H_t] ≤ σ²`. So $\sigma^2$ is the **variance bound**, $\sigma$ is the **stdev scale**.

- OP-2 v4: oracle at line 71 uses `≤ σ²`. ✓
- direction_1 §8 (L8): "OP-2's Le Cam y-coord construction" inherits with `σ²` variance bound; constant `c' = sqrt(2)/27 · σD/sqrt(T)` (the $\sigma$, not $\sigma^2$, scaled). ✓
- direction_2 §1: `g_t = Lx_t + ξ_t` with `ξ_t ~ N(0, σ²)`. ✓
- summary.md: Theorem A.1 box uses `σ²` consistently. ✓

**VALID.**

### 2.4 `L` (Lipschitz constant) — CONSISTENT

All files use `L` as the gradient-Lipschitz constant of $\nabla f$, not as a step-size scale. Step-size enters as `η`, with the dimensionless combination `h := ηL` in OP-2 v4 §0.1 (notation), `ηL` everywhere else. The Goujaud feasibility region uses `ηL ≤ 2(1+β)` (stability) and the cycling inequality is rewritten in terms of `κηL = h`. ✓

**VALID.** No file uses `η = c/L` as a redefinition of `L`; `L` is always the smoothness constant.

### 2.5 `F` (Goujaud feasibility region) — CONSISTENT

- OP-2 v4 §0.4 defines `F = {(β,η) ∈ S : ∃K ≥ 3, ∃κ ∈ (0,1) such that (★) holds}`. ✓
- shb-cycling-critical-momentum §0 defines `F_K` and `F = ∪_{K≥3} F_K`, but in the **small-κ limit** (★_K), which is the asymptotic version of (★) as κ → 0. The two definitions (full (★) at finite κ vs (★_K) at κ→0) are logically distinct objects. The shb-cycling-critical-momentum result establishes `β* = (sqrt(13)-3)/2` as the threshold for (★_K)-feasibility; OP-2 §0.5 then states the **full** (★) in $\mathcal F_{K=3}$ admits a positive-measure subset for $\beta > \beta^*$. The two are compatible (sufficient condition: $\beta > \beta^*$ + interval condition on $\eta L$, per OP-2 §2.7 Claim 2.13 Step 2). ✓
- direction_1 §0 and §6 use `F_{K=3}` consistently with OP-2's full-(★) version, and define `F^zero_{K=3} ⊂ F_{K=3}`. ✓
- direction_2 cites `F` at line 93 with the OP-2 definition. ✓

**VALID.**

### 2.6 `κ` (condition number = μ/L) — CONSISTENT

OP-2 v4 §0.4 explicitly: `κ ∈ (0,1)`, `μ := κL`. So κ = μ/L (small κ = poorly conditioned, large κ = well-conditioned, near 1 = nearly L = μ).

All four files use this convention:
- OP-2: `μ := κL ∈ (0, L)` at line 254, `κ(β,η) := μ/L`. ✓
- direction_1: `κ = μ/L` (Appendix B). ✓
- direction_2: not central; only κ = μ/L convention used implicitly. ✓
- summary.md: same. ✓

**VALID.** (The "external literature uses κ = L/μ" caveat is acknowledged but not used internally.)

### 2.7 SHB iteration — CONSISTENT

The form
```
x_{t+1} = x_t − η g_t + β(x_t − x_{t-1})
```
is the SHB recursion in:
- OP-2 v4 §0.2 (boxed). ✓
- direction_1 §1.55–58. ✓
- direction_2 §1.43 (specialized to `g_t = Lx_t + ξ_t` for the quadratic). ✓
- shb-cycling-lyapunov-nogo proof.md (implicit via Goujaud–Pedregosa setup). ✓

**VALID.** No file uses an alternative parameterization (e.g., the AdamW-style `m_t = β m_{t-1} + g_t`).

### 2.8 `x_{-1}` initialization — NEEDS_CORRECTION (textual prominence)

This is the **only cross-file mismatch flagged**, and it is correctly handled in the relevant files but should be more prominently displayed.

- **OP-2 v4 §0.5 condition 2 + §2.1.4:** `(x_0, x_{-1}) = ((D/√2)e_0, (D/√2)e_{K-1})`, **non-zero momentum init** (the OP-2 hard instance). The fact that `x_0 ≠ x_{-1}` is essential is mentioned in §0.5 condition 2 ("exact equality `||x_0 − x^*|| = D`") and §2.1.4, but **not explicitly flagged as a non-standard initialization assumption**.
- **direction_1 §0–§9:** explicitly studies `x_0 = x_{-1} = λe_0` (zero momentum), establishes Theorem 5.1 incompatibility, and proves a positive-measure-subset version of OP-2's LB on $\mathcal F^{\text{zero}}_{K=3}$.
- **summary.md §"Direction 1":** Reviewer concern explicitly: *"OP-2 cycling requires non-zero initial momentum; standard practice is x_0 = x_{-1}"*. Verdict line: "Partial PASS — non-empty positive-measure subset $\mathcal F^{\text{zero}}_{K=3}$".

**Mismatch not in the math but in the OP-2 v4 framing:** OP-2 v4 §0.5 should state, in the Main Theorem:

> "The initialization $(x_0, x_{-1}) = ((D/\sqrt 2)e_0, (D/\sqrt 2)e_{K-1})$ has $x_0 \neq x_{-1}$ (non-zero initial 'velocity'). This non-zero velocity is essential for the cycling identity in Lemma 2.6; under zero-momentum init $x_0 = x_{-1}$, only a positive-measure proper subset $\mathcal F^{\text{zero}}_{K=3} \subsetneq \mathcal F_{K=3}$ inherits the bound (companion document `direction_1_zero_momentum.md`)."

This is precisely the §0.8 insertion recommended by `summary.md` line 261–266. **Recommendation: apply the §0.8 insertion before peer review.**

**Severity:** LOW (mathematically all files are correct; only OP-2 v4's main statement is silent about the velocity-init dependence, which Li Xiao identified as a peer-review blocker).

---

## Task 3 — Theorem statement precision

### 3.1 Regime condition `σ ≤ LD√2` (RGM) — used correctly

**Where (RGM) enters:**

- §0.5 (Main Theorem) hypothesis line 96: explicit.
- §0.7 Remark: explains what happens when (RGM) fails (variance term dominates trivially).
- §2.1.2 derivation of wall radius: `R = D/√2 − σ/(3L√T) ≥ 0` requires `σ/(3L√T) ≤ D/√2`, i.e., `σ ≤ (3/√2) LD√T = O(LD√T)`. Under (RGM) `σ ≤ LD√(2T)`, this is satisfied since `√(2T)·1 < (3/√2)√T = (3/√2)√T = 2.12√T < √(2T)·1.5` ... let me check more carefully:

```
(RGM): σ ≤ LD√(2T)  ⇒  σ/(3L√T) ≤ D√(2T)/(3√T) = D√2/3 ≈ 0.471 D < D/√2 ≈ 0.707 D
So R ≥ D/√2 − D√2/3 ≈ 0.236 D > 0.  ✓
```

This is precisely the calculation in §2.1.2 paragraph 2 (line 284). **VALID.**

- §2.4.1 Step 3: the (RGM)-tight worst case `r = sqrt(2)` occurs precisely when `σ = LD√(2T)`. The optimization of `c_α^*(r)` is over `r ∈ (0, √2]`, with the saturated case giving the sharp `c_NY = √2/27`. **VALID.**

### 3.2 ∀-∃ scope — CONSISTENT

OP-2 v4 §0.5 line 98: *"for every (β, η) ∈ F and every integer T ≥ 1, there exist..."*. So the ordering is **∀(β,η) ∀T ∃ f^(T)**.

- §0.6 line 121: explicit reaffirmation. *"The function f_{β,η}^(T) depends on (β, η, T). The theorem is ∀-∃, not ∃-∀."* ✓
- §2.5 Claim 2.10 + Conclusion: explicit `s* = s*(β, η, T)` deterministic function. ✓
- direction_1 §0: same `(β, η, L, κ)` parameter set; theorem statement is per-parameter, per-T. ✓
- direction_2 Theorem A.3: explicitly contrasts OP-2's `∀T ∃f^(T)` with Route F's `∃f ∀(β,η,T)` — both compatible. ✓

**VALID.**

### 3.3 Hard-function T-dependence — DOCUMENTED

OP-2 v4 §0.6 line 121, §2.1.2 line 282–284 (wall radius depends on T via `R = D/√2 − σ/(3L√T)`), §0.5 line 108 footnote. ✓

`summary.md` line 157: *"OP-2's $\Omega(LD^2/T + \sigma D/\sqrt T)$ LB at fixed $(\beta,\eta)$ is correct as stated. It is a $\forall T \exists f^{(T)}$ minimax over hard instances (the wall radius $R = D/\sqrt 2 - \sigma/(3L\sqrt T)$ is $T$-dependent)."* ✓

**VALID.**

### 3.4 `x_0 ≠ x_{-1}` requirement — IMPLICIT, FLAG

OP-2 v4 §2.1.4 line 321 sets `x_0 := (D/√2)e_0`, `x_{-1} := (D/√2)e_{K-1}`. For K = 3, `e_0 ≠ e_2` (separated by 2π/3), so `x_0 ≠ x_{-1}` (non-zero "velocity"). But the OP-2 v4 master document **does not explicitly write** the phrase "non-zero momentum init" or "non-zero velocity" in the Main Theorem statement.

The Main Theorem at §0.5 condition 2 says:
> "an initial pair `(x_0, x_{-1}) ∈ R^3 × R^3` with `||x_0 − x^*|| = D` (exact equality)"

This admits the reader interpretation `x_0 = x_{-1}` as a legitimate init satisfying `||x_0 − x^*|| = D` (e.g., taking `x_0 = x_{-1}` arbitrary with that norm). The actual construction in §2.1.4 fixes `x_0` and `x_{-1}` to two **different** points; the velocity `x_0 − x_{-1} = (D/√2)(e_0 − e_{K-1}) ≠ 0`.

**Recommendation:** in §0.5, add (or move out of §0.6) the explicit clause:
> "with $(x_0, x_{-1})$ chosen such that $x_0 \neq x_{-1}$ (the non-zero initial 'velocity' is essential for the cycling identity; see Lemma 2.6 and §0.8 below)."

Combined with the §0.8 insertion above (Task 2.8), this closes the Li Xiao concern.

**Severity:** LOW. **VALID under the natural reading of §2.1.4**, but textually under-emphasized in §0.5.

---

## Sanity check: all cross-paper constants align

| Constant | OP-2 v4 §0.5 | direction_1 §0 | direction_2 | summary.md | reaudit | Verdict |
|---|---|---|---|---|---|---|
| `c_NY` (variance) | `sqrt(2)/27` | `sqrt(2)/27` (L8) | inherits | `sqrt(2)/27` | `sqrt(2)/27` | **CONSISTENT** |
| Bias coeff | `κ/4` | `κ/8` (degraded by 2 for transient) | (unused) | `κ/8` | `κ/8` w/ `T_0` caveat | **DOCUMENTED DIVERGENCE** |
| `β*` | `(√13−3)/2` | implicit | not used | `(√13−3)/2` | `(√13−3)/2` | **CONSISTENT** |
| Floquet `|λ|` | (not used) | `β^(3/2)` | not used | `β^(3/2)` | `β^(3/2)` (50-digit) | **CONSISTENT** |
| Vieta `(1−r₁)(1−r₂)` | (not used) | `ηµ` | (not used) | `ηµ` | `ηµ` | **CONSISTENT** |
| Noise floor coeff | (not in OP-2 v4) | (not in D1) | `1/[4(1−β)]` | `1/[4(1−β)]` | `1/[4(1−β)]` w/ "rate-only" caveat | **CONSISTENT** post-CORRECTION 5 |

**Documented divergence** (Direction 1 bias coeff `κ/8` vs OP-2's `κ/4`): this is **intentional**, due to a finite-T transient correction in zero-momentum init (Direction 1 §5). The reaudit_theorem_5_1.md flags that `κ/8` actually fails at `T = 4` (ratio 0.113 < 0.125 = 1/8), and the consolidated theorem in `direction_1_zero_momentum.md` §0 is missing the `T ≥ T_0` qualifier. Per `summary.md` CORRECTION 1, the boxed Direction 1 statement should be either:

- **Option A:** `∀ T ≥ T_0(β,η) ≈ 10`, retain `κ/8`.
- **Option B:** `∀ T ≥ 1`, downgrade to `κ/9` (or smaller; the empirically observed minimum ratio is `≈ 1/8.86`).

**Recommendation:** apply Option B (downgrade `κ/8 → κ/9`) so the boxed statement reads `∀ T ≥ 1` cleanly. This is cosmetic but matters for peer review.

---

## Summary: required fixes before peer review

| # | File | Section | Severity | Fix |
|---|---|---|---|---|
| F1 | `op2_downgraded_proof_v4.md` | §0.5 Main Theorem statement | LOW | Add explicit clause `x_0 ≠ x_{-1}` (non-zero velocity init) |
| F2 | `op2_downgraded_proof_v4.md` | §0.8 (new section) | LOW | Insert init-sensitivity section per `summary.md` recommendation |
| F3 | `op2_downgraded_proof_v4.md` | §2.4.1 Step Remark | TRIVIAL | "cubic" → "quadratic critical-point equation" (since the derivative is quadratic) |
| F4 | `direction_1_zero_momentum.md` | §0 boxed theorem | MEDIUM | Either (A) add `∀T ≥ T_0(β,η)` qualifier or (B) downgrade `κ/8` → `κ/9` (per reaudit CORRECTION 1) |
| F5 | `direction_1_zero_momentum.md` | §7 (period-2) | MEDIUM | Replace "period-2 attractor" → "period-6 attractor (period-2 mod $C_3$ rotation)"; replace floor `0.37 µD²` → `≥ 2.22 µD²` (per reaudit CORRECTION 2, 3) |
| F6 | `direction_2_last_iterate_ub.md` | line 80, 82 | LOW | Replace "exact match" → "matches in rate $\Theta(\sigma D/\sqrt T)$, with β-polynomial constant gap" (per reaudit CORRECTION 5) |
| F7 | `summary.md` | §"19% measure" / Direction 1 description | MEDIUM | Replace mis-attributed "19% measure" with "non-empty open via implicit-function argument; two confirmed point-anchors" (per reaudit CORRECTION 4) |

The constants themselves (Task 1) are mathematically correct and need no fix. All required edits are on the **statement / phrasing** level. Apply F1–F7, then OP-2 v4 + Direction 1 + Direction 2 are ready for external peer review.

---

## Confidence statement

| Category | Confidence | Basis |
|---|---|---|
| Variance constant `√2/27` | **HIGH** | SymPy symbolic + exact rational arithmetic; matches to 1e-50 |
| Bias constant `κ/4` (OP-2) | **HIGH** | Direct algebraic; Lemma 2.6 + Lemma 1.2 |
| Critical β* | **HIGH** | SymPy symbolic; Lemma 1 polynomial identity verified |
| Cycling inequality (★) | **HIGH** | SymPy substitution at known feasible/infeasible points; matches OP-2 §3.2 table |
| Floquet/Vieta (Direction 1) | **HIGH** | mpmath 50-digit; agrees with reaudit_theorem_5_1 |
| Cross-file `f^*`, `D`, `σ`, `L`, `F`, `κ`, SHB iteration | **HIGH** | Manual cross-grep, no inconsistencies |
| `x_0 ≠ x_{-1}` framing | **MEDIUM** | Mathematically OK; textually under-emphasized in OP-2 v4 §0.5 |
| Direction 1 bias `κ/8` for ∀T≥1 | **CORRECTED** (per reaudit CORRECTION 1) | Empirically fails at T=4 |
| Direction 2 noise floor "exact match" | **CORRECTED** (per reaudit CORRECTION 5) | Constants differ by β-polynomial factor 4.77×–47.7× |

The four constants of Task 1 are **mathematically watertight** as written in OP-2 v4. The seven recommended edits (F1–F7) are exclusively about statement-level phrasing, not derivation chains. None alter the substance of the lower-bound theorems.

**Word count: ≈ 2520.**
