/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Span-restricted oracle helpers

For a span-restricted first-order algorithm queried with the
zero-gradient oracle, the iterate sequence is "frozen" at the initial
point from step 1 onward.  This is the key technical lemma that lets
lower-bound theorems exhibit a *uniform* hard instance: pick `f' ≡ 0`,
and the algorithm has nowhere to go.
-/

import OptExt.OracleModel

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- For a span-restricted algorithm queried with a zero-gradient oracle,
the iterate at any step `T ≥ 1` equals the initial point. -/
lemma iterate_const_zero_eq
    {alg : FirstOrderAlgorithm E}
    (hspan : IsSpanRestricted alg) (x₀ : E) (T : ℕ) (hT : 1 ≤ T) :
    alg.iterate x₀ (fun _ => 0) T = x₀ := by
  obtain ⟨k, rfl⟩ : ∃ k, T = k + 1 := ⟨T - 1, by omega⟩
  have key := hspan (fun _ : E => (0 : E)) x₀ k
  have span_eq : gradientSpan alg (fun _ : E => (0 : E)) x₀ k = ⊥ := by
    unfold gradientSpan
    rw [eq_bot_iff, Submodule.span_le]
    rintro y ⟨_, rfl⟩
    exact Submodule.zero_mem _
  rw [span_eq, Submodule.mem_bot] at key
  exact sub_eq_zero.mp key

end OptExt
