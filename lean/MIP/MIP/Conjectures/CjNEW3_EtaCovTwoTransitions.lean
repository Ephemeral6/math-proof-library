/-
Conjecture Cj.NEW-3 — η_cov two-phase-transition structure.

Reference: `~/Desktop/MIP/conjectures/index.md` (Cj.NEW-3, lines ~458-482);
`workspace/partition_function_theorem.md` §5.3.

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
Under the D.4.16 TM-family training dynamics, the coverage efficiency

    η_cov(p, X_D) = |{R ∈ ℛ(p) : R ⊆ K(X_D)}| / |ℛ(p)|

undergoes TWO phase transitions as training depth `D` grows:

  * Transition I  (A.2 boundary crossing):  η_cov : 0 → > 0
        the first `D` at which `X_D` covers *some* `R ∈ ℛ(p)`
        ("X can first solve p").
  * Transition II (full path coverage):     η_cov : < 1 → ≈ 1
        the first `D` at which `X_D` covers *all* `R ∈ ℛ(p)`
        ("X fully masters every explanation path of p").

The gap Δ_cov := D_II − D_I is the "path-robustness saturation period".

================================================================================
FORMALIZATION CHOICES
================================================================================
TM-family training dynamics is not in `MIP.Axioms`. We model the *substantive
order-theoretic content* directly: the knowledge sets form a MONOTONE family of
Finsets `K : ℕ → Finset Ω` (training only adds knowledge: `K D ⊆ K (D+1)`).
`ℛ` is the fixed finite family of explanation paths (a `Finset (Finset Ω)`,
nonempty since `p ∈ P_sol`). Define

    covered D := {R ∈ ℛ : R ⊆ K D}        (a Finset)
    etaCov  D := covered D . card / ℛ.card  (a rational in [0,1])

The conjecture's mathematical core is: `etaCov` is monotone nondecreasing, takes
value `0` before the first crossing and `> 0` at/after it (Transition I), and
reaches `1` at the full-coverage index (Transition II), and these two indices
can be genuinely distinct.

We PROVE, in this monotone model:
  (1) monotonicity of `covered` and hence of `etaCov`;
  (2) existence of Transition I: a least index `D_I` with `etaCov D_I > 0`,
      given that *some* path is eventually covered;
  (3) existence of Transition II: a least index `D_II` with `etaCov D_II = 1`,
      given that *all* paths are eventually covered;
  (4) ordering `D_I ≤ D_II` always, and a concrete witness where `D_I < D_II`
      strictly (the two transitions are genuinely distinct).

================================================================================
VERDICT: PROVED (existence of the two crossings in the monotone-coverage model).
================================================================================
The two transition indices exist, are correctly ordered, and are demonstrably
distinct in a concrete instance — all sorry-free. This faithfully captures the
order-theoretic content the source flags as the clean tractable kernel ("model
coverage as a monotone family of Finsets; prove two distinct threshold indices
exist"). The link to *actual* TM-family training dynamics (that real `X_D`
knowledge sets are monotone and that `D_I < D_II` for natural training curves)
is OPEN — see "BLOCKED AT". We do not claim the dynamical conjecture, only its
monotone-kernel skeleton, which is the stated tractable target.
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Nat.Lattice
import Mathlib.Order.Bounds.Basic
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Positivity.Basic
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.NormNum.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace CjNEW3

variable {Ω : Type*} [DecidableEq Ω]

/-- A monotone training trajectory of knowledge sets: `K D ⊆ K (D+1)`. -/
structure MonotoneCoverage (Ω : Type*) [DecidableEq Ω] where
  /-- Knowledge at training depth `D`. -/
  K : ℕ → Finset Ω
  /-- Training only adds knowledge. -/
  mono : Monotone K

/-- The set of explanation paths covered by `K D`. -/
def covered (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) (D : ℕ) :
    Finset (Finset Ω) :=
  paths.filter (fun R => R ⊆ mc.K D)

/-- `η_cov(D) = |covered D| / |ℛ|` as a rational. -/
def etaCov (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) (D : ℕ) : ℚ :=
  (covered mc paths D).card / paths.card

/-! ### (1) Monotonicity -/

/-- `covered` is monotone nondecreasing in `D` (as a Finset under `⊆`). -/
theorem covered_mono (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) :
    Monotone (covered mc paths) := by
  intro D₁ D₂ hD R hR
  rw [covered, Finset.mem_filter] at hR ⊢
  exact ⟨hR.1, hR.2.trans (mc.mono hD)⟩

/-- The covered-count `|covered D|` is monotone nondecreasing in `D`. -/
theorem coveredCard_mono (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) :
    Monotone (fun D => (covered mc paths D).card) := by
  intro D₁ D₂ hD
  exact Finset.card_le_card (covered_mono mc paths hD)

/-- `etaCov` is monotone nondecreasing in `D`. -/
theorem etaCov_mono (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) :
    Monotone (etaCov mc paths) := by
  intro D₁ D₂ hD
  unfold etaCov
  have hnum : ((covered mc paths D₁).card : ℚ) ≤ (covered mc paths D₂).card := by
    exact_mod_cast coveredCard_mono mc paths hD
  have hden : (0 : ℚ) ≤ (paths.card : ℚ) := by positivity
  gcongr

/-! ### Bounds: `etaCov ∈ [0, 1]`. -/

/-- `0 ≤ etaCov D`. -/
theorem etaCov_nonneg (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (D : ℕ) : 0 ≤ etaCov mc paths D := by
  unfold etaCov; positivity

/-- `etaCov D ≤ 1` (the covered set is a subset of `paths`). -/
theorem etaCov_le_one (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty) (D : ℕ) : etaCov mc paths D ≤ 1 := by
  unfold etaCov
  rw [div_le_one (by exact_mod_cast Finset.card_pos.mpr hne)]
  exact_mod_cast Finset.card_le_card (Finset.filter_subset _ _)

/-- `etaCov D = 1 ↔ all paths are covered at depth D`. -/
theorem etaCov_eq_one_iff (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty) (D : ℕ) :
    etaCov mc paths D = 1 ↔ covered mc paths D = paths := by
  unfold etaCov
  rw [div_eq_one_iff_eq (by exact_mod_cast (Finset.card_pos.mpr hne).ne')]
  constructor
  · intro h
    exact Finset.eq_of_subset_of_card_le (Finset.filter_subset _ _)
      (by exact_mod_cast h.ge)
  · intro h; rw [h]

/-- `etaCov D > 0 ↔ some path is covered at depth D`. -/
theorem etaCov_pos_iff (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty) (D : ℕ) :
    0 < etaCov mc paths D ↔ (covered mc paths D).Nonempty := by
  unfold etaCov
  have hden : (0 : ℚ) < (paths.card : ℚ) := by
    exact_mod_cast Finset.card_pos.mpr hne
  rw [div_pos_iff_of_pos_right hden, ← Finset.card_pos, Nat.cast_pos]

/-! ### (2) Transition I — first depth at which `etaCov` becomes positive. -/

/-- The least depth `D` at which `etaCov D > 0` (some path first covered),
given that some path is eventually covered. Uses `Nat.find`. -/
noncomputable def transitionI (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    [DecidablePred (fun D => (covered mc paths D).Nonempty)]
    (hev : ∃ D, (covered mc paths D).Nonempty) : ℕ :=
  Nat.find hev

/-- **Transition I exists.** At `D_I := transitionI`, `etaCov > 0`, and for every
`D < D_I`, `etaCov = 0`. So `etaCov` genuinely crosses `0 → > 0` at `D_I`. -/
theorem transitionI_spec (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty)
    [DecidablePred (fun D => (covered mc paths D).Nonempty)]
    (hev : ∃ D, (covered mc paths D).Nonempty) :
    0 < etaCov mc paths (transitionI mc paths hev) ∧
      ∀ D < transitionI mc paths hev, etaCov mc paths D = 0 := by
  refine ⟨?_, ?_⟩
  · rw [etaCov_pos_iff mc paths hne]
    exact Nat.find_spec hev
  · intro D hD
    have hempty : ¬ (covered mc paths D).Nonempty := Nat.find_min hev hD
    rw [Finset.not_nonempty_iff_eq_empty] at hempty
    unfold etaCov
    rw [hempty]; simp

/-! ### (3) Transition II — first depth at which `etaCov` reaches 1. -/

/-- The least depth `D` at which `etaCov D = 1` (all paths covered), given full
coverage is eventually reached. -/
noncomputable def transitionII (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    [DecidablePred (fun D => covered mc paths D = paths)]
    (hfull : ∃ D, covered mc paths D = paths) : ℕ :=
  Nat.find hfull

/-- **Transition II exists.** At `D_II := transitionII`, `etaCov = 1`, and for
every `D < D_II`, `etaCov < 1`. So `etaCov` crosses `< 1 → 1` at `D_II`. -/
theorem transitionII_spec (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty)
    [DecidablePred (fun D => covered mc paths D = paths)]
    (hfull : ∃ D, covered mc paths D = paths) :
    etaCov mc paths (transitionII mc paths hfull) = 1 ∧
      ∀ D < transitionII mc paths hfull, etaCov mc paths D < 1 := by
  refine ⟨?_, ?_⟩
  · rw [etaCov_eq_one_iff mc paths hne]
    exact Nat.find_spec hfull
  · intro D hD
    have hlt1 : covered mc paths D ≠ paths := Nat.find_min hfull hD
    have hle := etaCov_le_one mc paths hne D
    rcases lt_or_eq_of_le hle with h | h
    · exact h
    · exact absurd ((etaCov_eq_one_iff mc paths hne D).mp h) hlt1

/-! ### (4) Ordering and genuine distinctness of the two transitions. -/

/-- **`D_I ≤ D_II` always.** Full coverage at `D_II` implies some path covered
there (paths nonempty), so the first-positive index is ≤ the first-full index. -/
theorem transitionI_le_transitionII (mc : MonotoneCoverage Ω)
    (paths : Finset (Finset Ω)) (hne : paths.Nonempty)
    [DecidablePred (fun D => (covered mc paths D).Nonempty)]
    [DecidablePred (fun D => covered mc paths D = paths)]
    (hev : ∃ D, (covered mc paths D).Nonempty)
    (hfull : ∃ D, covered mc paths D = paths) :
    transitionI mc paths hev ≤ transitionII mc paths hfull := by
  unfold transitionI transitionII
  apply Nat.find_le
  -- At D_II, covered = paths is nonempty, hence covered is nonempty.
  have h := Nat.find_spec hfull
  rw [h]
  exact hne

/-- The concrete witness knowledge curve over `Ω = Fin 2`:
`K 0 = ∅`, `K 1 = {0}`, `K D = {0,1}` for `D ≥ 2`. -/
def witnessK : ℕ → Finset (Fin 2) := fun D =>
  if D = 0 then ∅ else if D = 1 then {0} else {0, 1}

/-- `witnessK` is monotone: `∅ ⊆ {0} ⊆ {0,1}` as `D` climbs across `0,1,≥2`. -/
theorem witnessK_mono : Monotone witnessK := by
  intro a b hab
  unfold witnessK
  by_cases ha0 : a = 0
  · subst ha0; simp
  by_cases ha1 : a = 1
  · subst ha1
    -- a = 1: b ≥ 1, so b ≠ 0; K a = {0} ⊆ K b ∈ {{0},{0,1}}.
    simp only [ha0, if_false]
    have hb0 : b ≠ 0 := by omega
    by_cases hb1 : b = 1
    · subst hb1; simp
    · simp only [hb0, hb1, if_false]; decide
  · -- a ≥ 2: b ≥ a ≥ 2, so K a = K b = {0,1}.
    have hb0 : b ≠ 0 := by omega
    have hb1 : b ≠ 1 := by omega
    simp only [ha0, ha1, hb0, hb1, if_false, le_refl]

/-- The witness coverage trajectory. -/
def witnessMC : MonotoneCoverage (Fin 2) := ⟨witnessK, witnessK_mono⟩

/-- The witness explanation-path family `ℛ = {{0}, {1}}`. -/
def witnessPaths : Finset (Finset (Fin 2)) := {{0}, {1}}

/-- **Genuine two-transition witness (strict distinctness `D_I < D_II`).**

For the concrete instance `witnessMC` / `witnessPaths`:
  * `etaCov 0 = 0`        (nothing covered),
  * `etaCov 1 = 1/2 > 0`  (path `{0}` covered, `{1}` not) — Transition I at D=1,
  * `etaCov 2 = 1`        (both covered) — Transition II at D=2.
Hence the two transitions are strictly distinct: `0 < etaCov 1 < 1 = etaCov 2`,
giving a nonempty path-robustness saturation period. -/
theorem witness_two_transitions :
    etaCov witnessMC witnessPaths 0 = 0 ∧
    0 < etaCov witnessMC witnessPaths 1 ∧
    etaCov witnessMC witnessPaths 1 < 1 ∧
    etaCov witnessMC witnessPaths 2 = 1 := by
  -- Total number of paths is 2.
  have hpaths : witnessPaths.card = 2 := by decide
  -- Covered cardinalities at D = 0, 1, 2 are 0, 1, 2.
  have hc0 : (covered witnessMC witnessPaths 0).card = 0 := by decide
  have hc1 : (covered witnessMC witnessPaths 1).card = 1 := by decide
  have hc2 : (covered witnessMC witnessPaths 2).card = 2 := by decide
  refine ⟨?_, ?_, ?_, ?_⟩
  · unfold etaCov; rw [hc0, hpaths]; norm_num
  · unfold etaCov; rw [hc1, hpaths]; norm_num
  · unfold etaCov; rw [hc1, hpaths]
    rw [show ((1 : ℕ) : ℚ) / ((2 : ℕ) : ℚ) = 1/2 by norm_num]
    linarith
  · unfold etaCov; rw [hc2, hpaths]; norm_num

end CjNEW3

end MIP
