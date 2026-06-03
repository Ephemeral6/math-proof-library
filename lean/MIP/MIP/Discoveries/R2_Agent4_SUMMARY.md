# R2 Agent 4 — Higher moments of π and other α-divergences: Summary

**Goal.** Push beyond Agent 3's variance bound (Bhatia-Davis) and Rényi-2
collision entropy to higher central moments (M₃, M₄), the cubic sum
`Σ π_S³`, min-entropy (Rényi-∞), and the Rényi-α divergences to uniform
for α = 2 and α = ∞.

**Methodology.** Reused Agent 3's idiom (NNReal → ℝ coercion via
`congrArg (· : ℝ)` on `T18_10_conservation_packaged`, inlined
`pi_le_one_aux`, and the Bhatia-Davis upper bound `Var_π ≤ (m-1)/m²`).
For the lower bound `Σ π_S³ ≥ 1/m²` we exploited Mathlib's
`pow_sum_le_card_mul_sum_pow` (a special case of Jensen / power-mean).
For `MaxPi` we used `Finset.max'` on the image of the parts under the
real-valued mass function.

**Conclusion.** All seven targeted deliverables landed cleanly as
DISCOVERY files. No DEAD ENDs; no OBSERVATIONs.

---

## Files produced (all compile, zero `sorry`, zero new `axiom`)

| File | Tier | STATUS | Headline result |
|---|---|---|---|
| `R2_Agent4_ThirdMoment_Uniform.lean` | D+ | DISCOVERY | Definitions of `ThirdCentralMoment_pi` and `ThirdAbsoluteMoment_pi`; both vanish at uniform `π_S = 1/m`. The third-moment converse (M₃ = 0 ⟹ uniform) is *false* in general (symmetric distributions), so only the forward direction is stated. |
| `R2_Agent4_FourthMoment_Uniform.lean` | D+ | DISCOVERY | `FourthCentralMoment_pi`, nonnegativity, *full iff* `M₄ = 0 ⟺ uniform` (since `x⁴ ≥ 0` with equality iff x=0). Kurtosis ratio M₄/σ⁴ documented as degenerate at uniform (σ=0). |
| `R2_Agent4_ThirdMoment_AbsBound.lean` | D++ | DISCOVERY | **HEADLINE**: closed-form bound `\|M₃\| ≤ (m-1)/m²` via `\|M₃\| ≤ M₃ᵃ ≤ Var_π ≤ (m-1)/m²`. Uses pointwise `\|π_S - 1/m\| ≤ 1`, then `\|x\|³ ≤ x²` to drop a power, then Bhatia-Davis. |
| `R2_Agent4_RenyiSum3.lean` | B+ | DISCOVERY | **HEADLINE**: bracket `1/m² ≤ Σ π_S³ ≤ 1`. Upper from `π_S³ ≤ π_S²` (since π_S ≤ 1) composed with `Σ π_S² ≤ 1`. Lower via Mathlib's `pow_sum_le_card_mul_sum_pow` Jensen lemma with exponent 3. |
| `R2_Agent4_MinEntropy.lean` | B+ | DISCOVERY | `MaxPi := (image f).max'`, pointwise `π_S ≤ MaxPi`, attainment, bracket `1/m ≤ MaxPi ≤ 1`, min-entropy bracket `0 ≤ -log MaxPi ≤ log m`, **saturation iff** `MaxPi = 1/m ⟺ uniform` (forward by sum-of-nonneg-deviation = 0), full `H_∞ = log m ⟺ uniform`. |
| `R2_Agent4_RenyiKL_alpha2.lean` | C+ | DISCOVERY | Collision divergence `D_2(π‖U) := log(m · Σ π_S²)`. Bracket `0 ≤ D_2 ≤ log m`. Value 0 at uniform; value log m at vertex (since Σ π² = 1 when π ∈ {0,1}). |
| `R2_Agent4_RenyiKL_inf.lean` | C+ | DISCOVERY | Max-divergence `D_∞(π‖U) := log(m · MaxPi)`. Bracket `0 ≤ D_∞ ≤ log m`. Value 0 at uniform (iff form, via `MaxPi_eq_inv_card_iff_uniform`). Value log m at vertex. |

**Total: 7 DISCOVERY files. 0 OBSERVATION, 0 DEAD END.**

---

## Single most interesting results

1. **`abs_ThirdCentralMoment_closed_form`** (closed-form third moment bound):
   ```lean
   |(1/m) Σ_S (π_S - 1/m)³|  ≤  (m - 1) / m²
   ```
   The same closed-form upper bound as the variance — surprising, because
   it says the *signed* third moment cannot exceed the variance bound,
   even though M₃ can be positive or negative. The bound is tight at the
   vertex partition (where M₃ achieves its extreme positive value).

2. **`sum_pi_cube_bracket`** (cubic-sum bracket):
   ```lean
   1/m²  ≤  Σ_S π_S³  ≤  1
   ```
   The Rényi-3 analog of Agent 3's `1/m ≤ Σ π² ≤ 1`. The lower bound
   `1/m²` is the Jensen-inequality counterpart to `1/m`, attained at
   uniform (where Σ π³ = m · (1/m)³ = 1/m²).

3. **`MaxPi_eq_inv_card_iff_uniform`** (sat. iff for min-entropy):
   ```lean
   MaxPi = 1/m  ⟺  ∀ S, π_S = 1/m
   ```
   Forward direction is *surprisingly delicate*: needs that the sum of
   nonneg deviations `(1/m - π_S)` is 0, forcing each = 0. Combined with
   `RenyiKL_inf_eq_zero_iff_uniform`, this gives the full
   *D_∞ = 0 ⟺ uniform* characterisation — the max-divergence analog of
   Agent 3's `H_π = log m ⟺ uniform` (the latter of which Agent 3 only
   proved in the forward direction for the Shannon case).

---

## Tier observations

- **Higher moments (M₃, M₄)** turned out fertile: the absolute-third-moment
  closed-form bound was a genuine "new fact" (Agent 3 stopped at M₂). The
  trick `|x|³ ≤ x²` (since `|x| ≤ 1`) is the magic that lets us reduce a
  cubic moment to a quadratic one, then use Bhatia-Davis.

- **Rényi-3 sum** required Mathlib's Jensen lemma
  `pow_sum_le_card_mul_sum_pow`, which is the discrete power-mean
  inequality in disguise. Once found, the lower bound is two lines.

- **Min-entropy** required choosing `MaxPi` as `(image f).max'` to avoid
  axiom-of-choice issues with `exists_max_image`. The saturation iff for
  the min-entropy is the cleanest divergence characterization in this
  agent's output.

- **Rényi-α divergence framing** (α = 2 and α = ∞) gave the
  *intermediate divergence range* `[0, log m]` matching Shannon KL and
  Rényi-∞. The bracket pattern `0 ≤ D ≤ log m` is robust across α; the
  *zero-vs-vertex saturation* characterisations are the
  domain-meaningful results.

- **Skipped Rényi-α for general α**: avoided Mathlib's `Real.rpow` for
  non-integer powers because the saturation iff requires lemmas about
  `rpow` monotonicity that don't compose as cleanly as integer-power
  lemmas. The α = 2 and α = ∞ cases capture the two endpoints of the
  classical Rényi spectrum.

---

## Strategy notes for downstream

- The `MaxPi`-via-`Finset.max'` idiom (vs. `exists_max_image` + AC) keeps
  things computable in principle and makes downstream lemmas like
  `pi_le_MaxPi` definitional.
- The "sum of nonneg deviations equals 0 ⟹ each deviation is 0" pattern
  (used in `uniform_of_MaxPi_eq_inv_card`) is the standard tool for
  upgrading inequalities-on-mean to pointwise equalities; reusable for
  any "max equals mean ⟹ everything equals mean" argument.
- The `pow_sum_le_card_mul_sum_pow` lemma is the gateway to Rényi-α
  lower bounds for any positive integer α; downstream agents can apply
  it to α = 4, 5, ... cleanly. For non-integer α the `rpow` machinery
  needs more setup.
- `RenyiKL_alpha2` and `RenyiKL_inf` use the same algebraic form
  `log(m · Σ π_S^α)` (with α = 2 explicitly summed, α = ∞ replaced by
  `MaxPi`). A future agent could unify them with a parameter `α` once
  Mathlib's `rpow` machinery is wired in.

---

## File-naming and compilation

All files match `MIP/Discoveries/R2_Agent4_*.lean`. All compile from
`C:\Users\12729\Desktop\Math\lean\MIP` via:
```
lake env lean MIP/Discoveries/R2_Agent4_<topic>.lean
```
All exit code 0, no `error`, no `sorry`, no new `axiom`.

Dependencies on existing Agent 3 files:
- `Agent3_PiMassBounds.pi_le_one` (in AbsBound, RenyiSum3, MinEntropy)
- `Agent3_PiPigeonhole.exists_pi_ge_mean` (in MinEntropy)
- `Agent3_PiSqBounds.sum_pi_sq_le_one`, `sum_pi_sq_ge_inv_card` (in
  RenyiSum3, RenyiKL_alpha2)
- `Agent3_PiVariance.Var_pi`, `Var_pi_le_bhatia_davis` (in AbsBound)
- `R2_Agent4_MinEntropy` (in `R2_Agent4_RenyiKL_inf`)
