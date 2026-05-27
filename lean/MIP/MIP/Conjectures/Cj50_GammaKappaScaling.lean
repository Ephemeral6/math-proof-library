/-
Conjecture Cj.50 — the training-time κ-scaling exponent γ_κ.

Reference: `~/Desktop/MIP/conjectures/index.md` (Cj.50, lines ~237-259);
detail in `~/Desktop/MIP/workspace/gamma_kappa_rederivation.md`.

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
The combinatorial-closure density κ saturates toward 1 as a power law in the
training data budget / time `t`:

    1 − κ(t) ~ t^(−γ_κ),

and the saturation exponent γ_κ obeys some closed-form relation.

* ORIGINAL form `γ_κ = 2β − 1/s` (Heaps exponent β, "semantic slot count" s):
  RETRACTED.  The source flags it as a B-grade analogy carried over from
  R.411(c) with no MIP-internal derivation, and numerically MISMATCHED with
  Chinchilla's data-scaling exponent α_D ≈ 0.28-0.34 (the 2β−1/s form predicts
  ≈ 0.42-0.51 for plausible (β, s)).
* CURRENT candidate (R.418, A-conditional, partial): `γ_κ = β·η`, where η is
  the residual composable-pair decay exponent.  Derived (workspace §2.4
  candidate IV) from
      |K(t)| = c_K · t^β                       (Heaps),
      |K(t)|² − |R∘ ∩ K(t)²| = c_R·|K(t)|^(2−η) (residual completion),
  giving  1 − κ(t) = c_R·|K(t)|^(−η) = c_R·c_K^(−η)·t^(−βη), hence γ_κ = βη.
  Special value η = 1 ⟹ γ_κ = β ≈ 0.34, MATCHING Chinchilla α_D.

================================================================================
FORMALIZATION CHOICES
================================================================================
Two distinct mathematical claims are extracted and proven sorry-free:

(P1) **Current-form algebraic consistency** (the tractable partial the task
     authorises).  Under the bundled regime equalities (Heaps + residual
     completion, all entering as explicit hypotheses, exactly as in
     `R418_GammaKappa.lean`), the κ-gap obeys the closed power law
     `1 − κ(t) = c_R·c_K^(−η)·t^(−γ_κ)` with the chain identity `γ_κ = β·η`;
     and the Chinchilla special case `η = 1 ⟹ γ_κ = β` holds as clean algebra.

(P2) **Refutation of the OLD 2β−1/s form vs Chinchilla**.  For the
     representative fit values used in the source — Heaps `β = 0.34`, slot
     count `s = 6`, Chinchilla `α_D = 0.34` — the old prediction
     `2β − 1/s = 0.68 − 0.1667 = 0.5133…` differs from `α_D = 0.34`.  We prove
     this strict numerical inconsistency; combined with (P1)'s `η = 1` match,
     it formalizes "the new β·η form is Chinchilla-consistent where the old
     2β−1/s form is not".  We also show the gap is not an isolated coincidence:
     for ALL `β ≥ α_D` and ALL `s > 0`, `2β − 1/s > α_D` strictly whenever
     `β > α_D/2 + 1/(2s)` (and in particular at the source's β = α_D the old
     form exceeds α_D by `β − 1/s` once `β > 1/s`).

================================================================================
VERDICT: OPEN (partial proved: the β·η current form + η=1 Chinchilla-match as
proven algebra, and the old 2β−1/s form's Chinchilla mismatch as a proven
numerical refutation).
================================================================================
The substantive open content — DERIVING η from the ∘-operator algebra — is NOT
formalizable: η remains an external empirical parameter (like β), with no
axiom-internal derivation.  See "BLOCKED AT" at the bottom.  We do NOT claim a
full resolution; only the algebraic consistency of the current form and the
numerical refutation of the retracted form are proven, faithfully.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

namespace MIP

namespace Cj50

open Real

/-! ### The current-form statement (R.418): `γ_κ = β·η` with power-law κ-gap -/

/-- **Cj.50 current-form statement.**

Under Heaps `|K(t)| = c_K·t^β` and residual completion
`1 − κ(t) = c_R·|K(t)|^(−η)`, the κ-gap is a power law in `t` with exponent
`γ_κ = β·η`. We formalize the conjecture (current candidate form) as the
proposition that the gap equals `c_R·c_K^(−η)·t^(−γ_κ)` with `γ_κ = β·η`. -/
def Cj50_Statement (κgap cR cK t β η γκ : ℝ) : Prop :=
  0 < cK → 0 < t →
  κgap = cR * (cK * t ^ β) ^ (-η) →
  γκ = β * η →
  κgap = cR * cK ^ (-η) * t ^ (-γκ)

/-- **Cj.50 (current form) — PROVED algebraic consistency.**

The κ-gap closed form holds: substituting Heaps into the residual-completion
gap and using `γ_κ = β·η` gives the data-budget power law
`1 − κ(t) = c_R·c_K^(−η)·t^(−γ_κ)`. Pure `Real.rpow` substitution; this is the
A-conditional R.418 identity, here packaged as the Cj.50 current-form
statement. -/
theorem Cj50_currentForm_proved (κgap cR cK t β η γκ : ℝ) :
    Cj50_Statement κgap cR cK t β η γκ := by
  intro h_cK h_t h_gap h_γκ
  rw [h_gap, h_γκ,
      Real.mul_rpow (le_of_lt h_cK) (le_of_lt (Real.rpow_pos_of_pos h_t β)),
      ← Real.rpow_mul (le_of_lt h_t)]
  ring_nf

/-- **Cj.50 — Chinchilla special case `η = 1 ⟹ γ_κ = β`.**

With `η = 1` ("linear residual completion") the current form collapses to
`γ_κ = β`. Taking the Heaps fit `β ≈ 0.34` this gives `γ_κ ≈ 0.34 ≈ α_D`, the
Chinchilla data-scaling exponent — the clean algebra the task asks for. -/
theorem Cj50_eta_one_chinchilla_match (β γκ : ℝ) (h_γκ : γκ = β * 1) :
    γκ = β := by rw [h_γκ]; ring

/-- **Cj.50 — explicit Chinchilla numerical match (`β = 0.34, η = 1`).**

Instantiating the current form at the source's representative Heaps fit
`β = 0.34` and `η = 1` yields exactly the Chinchilla exponent `α_D = 0.34`. -/
theorem Cj50_eta_one_value :
    (0.34 : ℝ) * 1 = 0.34 := by norm_num

/-- **Cj.50 — `η = 2 ⟹ γ_κ = 2β`** (independent-pairing "area"-decay regime;
predicts `0.68` for `β = 0.34`, mismatching Chinchilla — recorded for the
comparison). -/
theorem Cj50_eta_two_value (β γκ : ℝ) (h_γκ : γκ = β * 2) :
    γκ = 2 * β := by rw [h_γκ]; ring

/-! ### Refutation of the RETRACTED old form `γ_κ = 2β − 1/s` vs Chinchilla -/

/-- The retracted original prediction `γ_κ^old(β, s) = 2β − 1/s`. -/
noncomputable def gammaOld (β s : ℝ) : ℝ := 2 * β - 1 / s

/-- **Cj.50 — the OLD form is numerically inconsistent with Chinchilla.**

At the source's representative values — Heaps `β = 0.34`, slot count `s = 6` —
the retracted prediction `2β − 1/s = 0.68 − 1/6 ≈ 0.5133` differs from the
Chinchilla data-scaling exponent `α_D = 0.34`. This is the precise numerical
refutation of the retracted form. -/
theorem Cj50_oldForm_chinchilla_mismatch :
    gammaOld 0.34 6 ≠ (0.34 : ℝ) := by
  unfold gammaOld
  norm_num

/-- **Cj.50 — old form strictly exceeds α_D at β = α_D.**

The source takes `β ≈ α_D ≈ 0.34` (the Heaps fit coincides with the Chinchilla
data exponent). At that calibration the old prediction overshoots by exactly
`β − 1/s`, which is strictly positive whenever `β > 1/s` (true for
`β = 0.34, s = 6`: `1/6 ≈ 0.167 < 0.34`). So the old form cannot match α_D when
β is calibrated to α_D — a structural (not coincidental) mismatch. -/
theorem Cj50_oldForm_overshoot (β s : ℝ) (_hs : 0 < s) (hβs : 1 / s < β) :
    (β : ℝ) < gammaOld β s := by
  unfold gammaOld
  linarith

/-- **Cj.50 — generic mismatch direction.**

For any `α_D > 0` (the target) and any `β, s` with `β > α_D/2 + 1/(2s)` and
`s > 0`, the old prediction `2β − 1/s` strictly exceeds `α_D`. Since the
empirical Heaps β are not small relative to α_D, the old form systematically
overpredicts — formalizing "2β − 1/s is Chinchilla-mismatched" beyond the
single point. -/
theorem Cj50_oldForm_generic_overshoot
    (αD β s : ℝ) (hs : 0 < s) (h : αD / 2 + 1 / (2 * s) < β) :
    αD < gammaOld β s := by
  unfold gammaOld
  have hss : 1 / s = 2 * (1 / (2 * s)) := by field_simp
  rw [hss]
  linarith

/-! ### The new form is consistent precisely where the old one is not -/

/-- **Cj.50 — comparison summary (proved).**

There exist parameter choices realizing the source's claim: the NEW form with
`η = 1` matches Chinchilla (`γ_κ = β = α_D = 0.34`), while the OLD form at the
same `β = 0.34` (and `s = 6`) does NOT (`2β − 1/s ≈ 0.5133 ≠ 0.34`). Both facts
are proven algebra. -/
theorem Cj50_new_matches_old_fails :
    ((0.34 : ℝ) * 1 = 0.34) ∧ (gammaOld 0.34 6 ≠ (0.34 : ℝ)) :=
  ⟨Cj50_eta_one_value, Cj50_oldForm_chinchilla_mismatch⟩

/-! ### BLOCKED AT — verdict OPEN for the full conjecture

The genuinely open content of Cj.50 is the AXIOM-INTERNAL DERIVATION of the
residual exponent η (equivalently, deriving γ_κ from first principles rather
than positing it). Concretely:

MISSING (not formalizable sorry-free with the current infrastructure):
  1. A derivation of η from the `∘`-operator algebra (D.3.7). The workspace
     (§5, Appendix C) records η as "an external empirical parameter (like β),
     with NO axiom-internal derivation"; the open question "does η = 1
     correspond to a free-magma property of ∘?" is unresolved (R.450 only
     characterizes the κ-tower upgrade, not the η decay rate).
  2. Reconciling the power-law κ-gap (R.418 / R.95(b), D-domain) with the
     R.98 Gompertz κ-dynamics (t-domain), which are categorically incompatible
     under D ∝ t (exponential vs power-law). The workspace shows they can only
     coexist under a nonlinear D ↔ t schedule; pinning the operative regime is
     open.
  3. Hence γ_κ is NOT a function of the MIP axioms alone — it is fixed only
     after choosing the empirical pair (β, η).

Only the algebraic consistency of the current β·η form (with η = 1 matching
Chinchilla) and the numerical refutation of the retracted 2β−1/s form are
settled above. The mechanistic derivation of η — the heart of subproblem (a)
and (c) — remains OPEN.
-/

end Cj50

end MIP
