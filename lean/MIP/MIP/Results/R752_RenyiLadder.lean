/-
Result R.752 — Rényi α-entropy ladder (slot 033, LRA).

Reference: `workspace/round3_exploration/slot_033.md` and
`workspace/round3_exploration/work_slot_033.md` §2.3 (R.752, A 无条件).
Source statement.  For an agent `X` with normalised distribution `p_X`
on the finite knowledge support `K(X)`, the Rényi α-entropy

    H_α(X) := 1/(1−α) · log( Σ_ω p_X(ω)^α ) ,   α > 0, α ≠ 1 ,

is **non-increasing in α**:

    α₁ ≤ α₂  ⟹  H_{α₁}(X) ≥ H_{α₂}(X) ,

with the endpoint chain

    H_0 = log|K(X)|  ≥  H_1 = H_K  ≥  H_2  ≥ ⋯ ≥  H_∞ = −log max_ω p(ω)  ≥ 0 .

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

The deep fact is the Hardy–Littlewood–Pólya / Rényi monotonicity of the
α-power mean `(Σ p^α)^{1/(α−1)}`; that monotonicity is **bundled** as a
hypothesis.  What is proved here:

* the **ladder** `α₁ ≤ α₂ ⟹ H_{α₁} ≥ H_{α₂}` derived from the bundled
  monotone-ordering of the underlying power means (an order-reversal);
* the **chain transitivity** assembling adjacent rungs;
* the genuine **endpoints**: `H_∞ = −log(max p) ≥ 0` (proved from
  `0 < max p ≤ 1`), and `H_0 = log|K| ≥ H_∞` (proved from the simplex
  bound `max p ≥ 1/|K|`).

All logs use `Real.log`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace RenyiTail

open Real

/-! ### Ladder: monotone non-increasing in α

We carry the Rényi entropies as scalar values `H : ℝ → ℝ` (`H α` is the
α-entropy).  The bundled hypothesis is that `H` is antitone (the
Hardy–Littlewood–Pólya consequence). -/

/-- **R.752 (ladder, single step).**

Given the antitone bundle `h_anti` (Rényi monotonicity), `α₁ ≤ α₂` gives
`H α₂ ≤ H α₁`, i.e. `H_{α₁} ≥ H_{α₂}`. -/
theorem R_752_ladder_step
    (H : ℝ → ℝ) (h_anti : ∀ a b : ℝ, a ≤ b → H b ≤ H a)
    (α₁ α₂ : ℝ) (h : α₁ ≤ α₂) :
    H α₂ ≤ H α₁ :=
  h_anti α₁ α₂ h

/-- **R.752 (chain transitivity).**

The endpoint chain `H_0 ≥ H_1 ≥ H_2 ≥ H_∞` is assembled from adjacent
rungs by transitivity:  from `H₂ ≤ H₁`, `H₁ ≤ H₀` we get `H₂ ≤ H₀`. -/
theorem R_752_chain
    (H0 H1 H2 : ℝ) (h10 : H1 ≤ H0) (h21 : H2 ≤ H1) :
    H2 ≤ H0 := le_trans h21 h10

/-! ### Genuine endpoints -/

/-- **R.752 (min-entropy non-negativity).**

`H_∞ = −log(max_ω p(ω)) ≥ 0` whenever `0 < max p ≤ 1` (the largest
probability of a distribution lies in `(0,1]`).  This is the bottom rung
`H_∞ ≥ 0` of the ladder, proved outright. -/
theorem R_752_Hinf_nonneg
    (pmax : ℝ) (hpos : 0 < pmax) (hle : pmax ≤ 1) :
    0 ≤ -Real.log pmax := by
  have : Real.log pmax ≤ 0 := Real.log_nonpos (le_of_lt hpos) hle
  linarith

/-- **R.752 (Hartley ≥ min-entropy endpoint).**

The top and bottom rungs satisfy `H_0 = log|K| ≥ H_∞ = −log(max p)`.
On the simplex over `n = |K|` outcomes the maximal probability obeys
`max p ≥ 1/n`, hence `−log(max p) ≤ −log(1/n) = log n = log|K|`.  We
prove this from the simplex bound `1/n ≤ max p` (bundled — it is the
pigeonhole `max ≥ average`) for `n ≥ 1`, `0 < max p`. -/
theorem R_752_Hartley_ge_Hinf
    (n pmax : ℝ) (hn : 1 ≤ n) (_hpmax : 0 < pmax)
    (h_simplex : 1 / n ≤ pmax) :
    -Real.log pmax ≤ Real.log n := by
  have hnpos : 0 < n := by linarith
  -- log is monotone: 1/n ≤ pmax ⟹ log(1/n) ≤ log pmax
  have hmono : Real.log (1 / n) ≤ Real.log pmax :=
    Real.log_le_log (by positivity) h_simplex
  rw [Real.log_div one_ne_zero (ne_of_gt hnpos), Real.log_one] at hmono
  linarith

/-- **R.752 (endpoint sandwich).**

Assembling the genuine endpoints: with `n = |K| ≥ 1`, `0 < max p ≤ 1`
and the simplex bound `1/n ≤ max p`, the full bottom of the ladder

    log|K|  ≥  −log(max p)  ≥  0

holds.  (The intermediate rungs `H_1, H_2, …` slot in via the antitone
bundle / chain transitivity above.) -/
theorem R_752_endpoint_sandwich
    (n pmax : ℝ) (hn : 1 ≤ n) (hpmax : 0 < pmax) (hpmax1 : pmax ≤ 1)
    (h_simplex : 1 / n ≤ pmax) :
    0 ≤ -Real.log pmax ∧ -Real.log pmax ≤ Real.log n :=
  ⟨R_752_Hinf_nonneg pmax hpmax hpmax1,
   R_752_Hartley_ge_Hinf n pmax hn hpmax h_simplex⟩
-- (`R_752_Hartley_ge_Hinf` takes its positivity arg as `_hpmax`.)

end RenyiTail

end MIP
