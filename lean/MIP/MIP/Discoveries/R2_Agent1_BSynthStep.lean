/-
  STATUS: DISCOVERY
  AGENT: R2-1
  DIRECTION: `(b_synth X p 0).s_pre.step = 0` and friends — regime-agnostic
             step-projection identities used implicitly by Agent 4's
             chain lemmas.
  SUMMARY:
    The briefing asks: "Does each regime force a unique value of
    `(b_synth X p 0).s_pre.step`?  Should be 0 by construction —
    verify and state."  We confirm: the value is `0`, *unconditionally*,
    in every regime (R0, RP, R∞), because `s_pre.step` is read off the
    structure literal `⟨X, p, i⟩` with `i := 0`.  We record this and the
    parallel `s_post.step = 1` as regime-independent identities; the
    "regime conditioning" is therefore vacuous.  We also state the
    `s_pre` / `s_post` step formulas at the boundary index
    `i = (N p X).toNat - 1` in regime RP (where they take the values
    `(N p X).toNat - 1` and `(N p X).toNat` respectively).
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace R2_Agent1_BSynthStep

variable {α : Type}

/-! ## (1) The 0-th synthetic barrier has `s_pre.step = 0`. -/

/-- **Regime-agnostic.** `(b_synth X p 0).s_pre.step = 0`. -/
theorem bsynth_zero_s_pre_step (X : Agent α) (p : Problem α) :
    (b_synth X p 0).s_pre.step = 0 := rfl

/-- **Regime-agnostic.** `(b_synth X p 0).s_post.step = 1`. -/
theorem bsynth_zero_s_post_step (X : Agent α) (p : Problem α) :
    (b_synth X p 0).s_post.step = 1 := rfl

/-! ## (2) Regime-conditional packaging.

The briefing asks if `(b_synth X p 0).s_pre.step` is the *unique* step
in each regime.  Since it's `0` unconditionally, the three regime-
conditional packagings collapse to the same identity. -/

/-- **R0 packaging**: in regime R0, `(b_synth X p 0).s_pre.step = 0`. -/
theorem bsynth_zero_step_in_R0
    (X : Agent α) (p : Problem α) (_h : N p X = 0) :
    (b_synth X p 0).s_pre.step = 0 := rfl

/-- **RP packaging**: in regime RP (0 < N < ⊤),
`(b_synth X p 0).s_pre.step = 0`. -/
theorem bsynth_zero_step_in_RP
    (X : Agent α) (p : Problem α)
    (_h_pos : 0 < N p X) (_h_fin : N p X < ⊤) :
    (b_synth X p 0).s_pre.step = 0 := rfl

/-- **R∞ packaging**: in regime R∞, `(b_synth X p 0).s_pre.step = 0`. -/
theorem bsynth_zero_step_in_Rinf
    (X : Agent α) (p : Problem α) (_h : N p X = ⊤) :
    (b_synth X p 0).s_pre.step = 0 := rfl

/-! ## (3) Top-index facts in regime RP.

When `(N p X).toNat = n ≥ 1` the *last* synthetic barrier in `B_data` has
index `n - 1`, with `s_pre.step = n - 1` and `s_post.step = n`. -/

/-- **RP last-index `s_pre` step.** When `n := (N p X).toNat ≥ 1`,
`(b_synth X p (n - 1)).s_pre.step = n - 1`. -/
theorem bsynth_last_s_pre_step_eq
    (X : Agent α) (p : Problem α) (n : ℕ) (_h : 1 ≤ n) :
    (b_synth X p (n - 1)).s_pre.step = n - 1 := rfl

/-- **RP last-index `s_post` step.** When `n ≥ 1`,
`(b_synth X p (n - 1)).s_post.step = n`. -/
theorem bsynth_last_s_post_step_eq
    (X : Agent α) (p : Problem α) (n : ℕ) (h : 1 ≤ n) :
    (b_synth X p (n - 1)).s_post.step = n := by
  show n - 1 + 1 = n
  omega

end R2_Agent1_BSynthStep

end MIP
