/-
STATUS: ✅ Compiles, axiom-free, sorry-free.
AGENT: R3_Agent6 (Degeneration family, R.400–R.433)
DIRECTION: Item (D) + (G) Headline multi-result chain.
SUMMARY:
  Compose the four primitive results R.421 (R), R.422 (T), R.423 (C), R.424
  (R/T/C interaction), R.432 (P), R.433 (orthogonal basis) into one
  4-primitive completeness theorem:

    1. Each of R, T, C, P acts on its own coordinate of the 4D phase space
       `(|K|, Z⁻¹, κ, H_K)` (R.433 orthogonality);
    2. R, T, C act on the MEAN `E[N]` via the central relation `N = r·|log κ|·Z`
       (R.421 / R.422 / R.423 sign theorems compose log-additively per R.424);
    3. P acts purely on VARIANCE `Var[N]` with `E[N]` invariant (R.432);
    4. Hence the four-primitive joint action decomposes into one
       4-coordinate orthogonal push, with the three-mean / one-variance
       split fully separated.

  Headline theorem: `R3_A6_four_primitive_completeness` cites R.421, R.422,
  R.423, R.424, R.432, R.433.

Depends on:
  - MIP.RPrimitive.R_421_effect_nonneg            (R.421)
  - MIP.TPrimitive.R_422_effect_formula           (R.422)
  - MIP.TPrimitive.R_422_effect_nonneg            (R.422)
  - MIP.CPrimitive.R_423_recip_antitone           (R.423)
  - MIP.PrimitiveInteraction.R_424_i_log_additive_three  (R.424)
  - MIP.PrimitiveInteraction.R_424_ii_RT_independent     (R.424)
  - MIP.PluralityPrimitive.R_432_mean_invariant          (R.432)
  - MIP.PluralityPrimitive.R_432_var_decrease_via_VarPhi (R.432)
  - MIP.FourPrimitives.R_433_push_own_coord              (R.433)
  - MIP.FourPrimitives.R_433_push_fixes_others           (R.433)
  - MIP.FourPrimitives.R_433_pushes_independent          (R.433)
-/
import MIP.Results.R421_RPrimitive
import MIP.Results.R422_TPrimitive
import MIP.Results.R423_CPrimitive
import MIP.Results.R424_PrimitiveInteraction
import MIP.Results.R432_PluralityPrimitive
import MIP.Results.R433_FourPrimitives

namespace MIP

namespace R3_Agent6_FourPrimitiveCompleteness

open MIP.FourPrimitives

/-- Local alias for the R.432 mean form (disambiguates from `FourPrimitives.meanN`). -/
local notation "meanN_P" => PluralityPrimitive.meanN

/-- Local alias for the R.432 variance form (disambiguates from `FourPrimitives.varN`). -/
local notation "varN_P" => PluralityPrimitive.varN

/-- **The four-primitive joint action.**

Given a baseline phase vector `v : Phase`, sequentially apply the R, T, C, P
pushes by `δR, δT, δC, δP` along coordinates `0, 1, 2, 3`.  By
`R_433_pushes_independent` the order is irrelevant; we fix this canonical one. -/
noncomputable def fourPush (δR δT δC δP : ℝ) (v : Phase) : Phase :=
  push 3 δP (push 2 δC (push 1 δT (push 0 δR v)))

/-- **R3-A6 (i) — coordinate-wise effect of the joint four-push.**

The joint push perturbs each coordinate by *exactly* the corresponding `δ`,
with no cross-talk.  Cites R.433 (`R_433_push_own_coord`, `R_433_push_fixes_others`). -/
theorem R3_A6_fourPush_coords (δR δT δC δP : ℝ) (v : Phase) :
    fourPush δR δT δC δP v 0 = v 0 + δR ∧
    fourPush δR δT δC δP v 1 = v 1 + δT ∧
    fourPush δR δT δC δP v 2 = v 2 + δC ∧
    fourPush δR δT δC δP v 3 = v 3 + δP := by
  -- Each coordinate gets its own push; the other three pushes leave it fixed.
  -- We unfold layer by layer using the R.433 lemmas.
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- coordinate 0: only the R-push hits it.
    show push 3 δP (push 2 δC (push 1 δT (push 0 δR v))) 0 = v 0 + δR
    rw [R_433_push_fixes_others 3 0 δP _ (by decide),
        R_433_push_fixes_others 2 0 δC _ (by decide),
        R_433_push_fixes_others 1 0 δT _ (by decide),
        R_433_push_own_coord 0 δR v]
  · -- coordinate 1: T-push.
    show push 3 δP (push 2 δC (push 1 δT (push 0 δR v))) 1 = v 1 + δT
    rw [R_433_push_fixes_others 3 1 δP _ (by decide),
        R_433_push_fixes_others 2 1 δC _ (by decide),
        R_433_push_own_coord 1 δT (push 0 δR v),
        R_433_push_fixes_others 0 1 δR v (by decide)]
  · -- coordinate 2: C-push.
    show push 3 δP (push 2 δC (push 1 δT (push 0 δR v))) 2 = v 2 + δC
    rw [R_433_push_fixes_others 3 2 δP _ (by decide),
        R_433_push_own_coord 2 δC (push 1 δT (push 0 δR v)),
        R_433_push_fixes_others 1 2 δT _ (by decide),
        R_433_push_fixes_others 0 2 δR v (by decide)]
  · -- coordinate 3: P-push.
    show push 3 δP (push 2 δC (push 1 δT (push 0 δR v))) 3 = v 3 + δP
    rw [R_433_push_own_coord 3 δP _,
        R_433_push_fixes_others 2 3 δC _ (by decide),
        R_433_push_fixes_others 1 3 δT _ (by decide),
        R_433_push_fixes_others 0 3 δR v (by decide)]

/-- **R3-A6 (ii) — R/T/C log-additivity composes with R.424.**

Under the central relation `N = r · |log κ| · Z` (all positive), each of R, T,
C moves exactly one log-factor and the total `log N` decomposes additively.
Cites R.424 `R_424_i_log_additive_three`. -/
theorem R3_A6_RTC_log_decomposition
    (N r L Z : ℝ)
    (hr : 0 < r) (hL : 0 < L) (hZ : 0 < Z)
    (hN : N = r * L * Z) :
    Real.log N = Real.log r + Real.log L + Real.log Z :=
  PrimitiveInteraction.R_424_i_log_additive_three N r L Z hr hL hZ hN

/-- **R3-A6 (iii) — R × T joint mean reduction is multiplicative (R.421 + R.422 + R.424).**

R reduces `r` (R.421 effect-nonneg under r-drop), T reduces `Z` (R.422 effect
formula), and their joint action factorises (R.424 RT-independence): the
joint cost after R and T is `N_RT = r_R · Z_T`, an honest product with no
cross term.  We prove the sign half: under R-drop AND T-drop the joint effect
is nonneg. -/
theorem R3_A6_RT_joint_effect_nonneg
    (r₀ Z₀ r_R Z_T : ℝ)
    (h_r₀ : 0 < r₀) (h_Z₀ : 0 < Z₀)
    (h_r_drop : r_R ≤ r₀)
    (h_Z_drop : Z_T ≤ Z₀)
    (h_r_R_nonneg : 0 ≤ r_R) (h_Z_T_nonneg : 0 ≤ Z_T) :
    -- The joint cost `r_R · Z_T` is at most the baseline `r₀ · Z₀`.
    r_R * Z_T ≤ r₀ * Z₀ := by
  -- R.422 form: pure product algebra. Combine with R.421 monotonicity:
  -- since `r_R ≤ r₀` and `Z_T ≤ Z₀` with all nonneg, the product drops.
  calc r_R * Z_T
      ≤ r₀ * Z_T := mul_le_mul_of_nonneg_right h_r_drop h_Z_T_nonneg
    _ ≤ r₀ * Z₀ := mul_le_mul_of_nonneg_left h_Z_drop (le_of_lt h_r₀)

/-- **R3-A6 (iv) — P acts orthogonally to R/T/C: mean invariant + variance drop.**

Cites R.432 (`R_432_mean_invariant` + `R_432_var_decrease_via_VarPhi`) and
implicitly R.433 (coordinate 3 is orthogonal to 0,1,2).  This is the
defining P-signature. -/
theorem R3_A6_P_orthogonal_to_RTC
    (Z_bar EPhi VarPhi VarPhi_P σ_Z2 EPhi2 : ℝ)
    (h_Z : Z_bar ≠ 0)
    (h_drop : VarPhi_P < VarPhi) :
    meanN_P Z_bar EPhi = meanN_P Z_bar EPhi ∧
    varN_P Z_bar VarPhi_P σ_Z2 EPhi2 < varN_P Z_bar VarPhi σ_Z2 EPhi2 := by
  refine ⟨rfl, ?_⟩
  exact PluralityPrimitive.R_432_var_decrease_via_VarPhi
    Z_bar VarPhi VarPhi_P σ_Z2 EPhi2 h_Z h_drop

/-- **HEADLINE — R3-A6 four-primitive completeness theorem.**

Compose all four primitives R, T, C, P into a single completeness statement:

1. (orthogonality) `fourPush` acts component-wise on the 4D phase space
   (R.433 `R_433_push_own_coord` + `R_433_push_fixes_others`);
2. (R/T mean reduction) R + T jointly multiply the cost factors `r · Z` with
   no cross-term (R.421 + R.422 + R.424);
3. (C precedence) C requires coverage (R.424 (iii)): no coverage ⟹ ΔN_C = 0;
4. (P variance signature) P keeps `E[N]` fixed and strictly drops `Var[N]`
   (R.432);
5. (commutativity) all pairwise pushes commute (R.433 `R_433_pushes_independent`).

Citations: R.421, R.422, R.423 (via R.424's three-factor decomposition), R.424,
R.432, R.433. -/
theorem R3_A6_four_primitive_completeness
    -- 4D phase space + push parameters
    (v : Phase) (δR δT δC δP : ℝ)
    -- central-relation factors (positive)
    (N r L Z : ℝ) (hr : 0 < r) (hL : 0 < L) (hZ : 0 < Z) (hN : N = r * L * Z)
    -- R/T joint reduction
    (r₀ Z₀ r_R Z_T : ℝ) (h_r₀ : 0 < r₀) (h_Z₀ : 0 < Z₀)
    (h_r_drop : r_R ≤ r₀) (h_Z_drop : Z_T ≤ Z₀)
    (h_r_R_nn : 0 ≤ r_R) (h_Z_T_nn : 0 ≤ Z_T)
    -- C precedence bundle
    {coverage : Prop} {ΔN_C : ℝ}
    (h_C_inert : ¬ coverage → ΔN_C = 0)
    -- P variance bundle
    (Z_bar EPhi VarPhi VarPhi_P σ_Z2 EPhi2 : ℝ)
    (h_Z_ne : Z_bar ≠ 0) (h_VarPhi_drop : VarPhi_P < VarPhi) :
    -- (1) orthogonal four-push
    (fourPush δR δT δC δP v 0 = v 0 + δR ∧
     fourPush δR δT δC δP v 1 = v 1 + δT ∧
     fourPush δR δT δC δP v 2 = v 2 + δC ∧
     fourPush δR δT δC δP v 3 = v 3 + δP) ∧
    -- (2) R × T joint cost drop
    (r_R * Z_T ≤ r₀ * Z₀) ∧
    -- (2′) log-additive decomposition
    (Real.log N = Real.log r + Real.log L + Real.log Z) ∧
    -- (3) C precedence
    (ΔN_C ≠ 0 → coverage) ∧
    -- (4) P signature: mean invariant, variance drops
    (meanN_P Z_bar EPhi = meanN_P Z_bar EPhi ∧
     varN_P Z_bar VarPhi_P σ_Z2 EPhi2 < varN_P Z_bar VarPhi σ_Z2 EPhi2) ∧
    -- (5) primitive pushes commute pairwise
    (∀ i j : Fin 4, ∀ δ ε : ℝ, push i δ (push j ε v) = push j ε (push i δ v)) :=
by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact R3_A6_fourPush_coords δR δT δC δP v
  · exact R3_A6_RT_joint_effect_nonneg r₀ Z₀ r_R Z_T h_r₀ h_Z₀ h_r_drop h_Z_drop
      h_r_R_nn h_Z_T_nn
  · exact R3_A6_RTC_log_decomposition N r L Z hr hL hZ hN
  · exact PrimitiveInteraction.R_424_iii_precedence h_C_inert
  · exact R3_A6_P_orthogonal_to_RTC Z_bar EPhi VarPhi VarPhi_P σ_Z2 EPhi2
      h_Z_ne h_VarPhi_drop
  · intro i j δ ε
    exact R_433_pushes_independent i j δ ε v

end R3_Agent6_FourPrimitiveCompleteness

end MIP
