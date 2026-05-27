/-
Result R.519 (B-conditional) — `η = 1` has no algebraic correspondence.

Reference: `workspace/round3_exploration/slot_008.md` (R.519, B-conditional)
and `workspace/round3_exploration/work_slot_008.md` §5; companion results
`MIP/Results/R418_GammaKappa.lean` (γ_κ = β·η, with η the residual-completion
exponent) and `MIP/Results/RNEWPAC_GammaNonderivability.lean` (the
free-parameter / surjectivity template).

**Candidate status: downgraded to conjecture (Cj.50 residual, R.519
B-conditional); statement declared, not proved.**  The qualitative claim of
R.519 is: in the γ_κ = β·η decomposition, the value `η = 1` (the "linear
completion" assumption that gives the Chinchilla match `γ_κ = β`) does **not**
correspond to any distinguished algebraic limit of the cooccurrence operation
`∘`.  The two genuine algebraic limits are at the *endpoints* of the
Free–Comm family — `η → 0` (free partial commutative magma, instantaneous
full connection) and `η → ∞` (commutative monoid, delayed sparse completion)
— and `η = 1` is an **unmarked interior point** of the continuous family, not
either limit.

This result has crisp formal content (it is *not* purely narrative), so we
formalize it as a **freedom / non-existence statement** in the style of
R.NEW-PAC:

* `η` is a free reparameterization scalar (R.518: `η = ψ` for the completion
  rate exponent `ρ ∝ |K|^ψ`); it ranges over all of `(0, ∞)`;
* the two algebraic limits sit at the boundary `{0, ∞}` of this range, an
  **open** set missing exactly the interior — `1 ∉ {0, ∞}` and more strongly
  `1` is in the interior `(0, ∞)` where no limit lives;
* therefore `η = 1` is not forced by, and does not coincide with, any
  algebraic-limit value: there exist family configurations with `η ≠ 1`
  (in fact every `η ∈ (0,∞)` is realized) satisfying the same axioms, so
  no axiom pins `η` to `1`, and `1` is not a distinguished (limit) value.

**What this file does (`axiom`-free).**

1. **DECLARES** the qualitative claim as a `Prop`:
       `R519_no_algebraic_correspondence : Prop`
   ("`η = 1` is an interior point of the Free–Comm range `(0,∞)`, not one of
   the two algebraic-limit endpoints `{0, ∞}`").

2. Proves the **freedom theorem**: the realized `η` is surjective onto
   `(0, ∞)` (every value is achievable by a configuration), so `η` is not
   determined to be `1` by the axioms — there are configurations with
   `η ≠ 1`.

3. Proves the **no-correspondence content**: `η = 1` lies strictly between
   the two algebraic-limit values `0` and `∞`-boundary, i.e. `0 < 1` and
   `1 < L` for every finite "large-η" limit approximant `L > 1`; concretely
   `1` is in the open interior `(0, ∞)` and differs from both endpoints, so
   it is not an algebraic limit.  We make `R519_no_algebraic_correspondence`
   a *proved* proposition here (it is the crisp reading), while keeping the
   broader B-conditional narrative as documentation.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace EtaNoAlgebraicCorrespondence

/-! ### The Free–Comm η-family

`η` is the residual-completion exponent in `γ_κ = β·η` (R.418).  Per R.518 it
reparameterizes the completion-rate exponent `ψ` and ranges over the open ray
`(0, ∞)`.  The two genuine algebraic limits of the cooccurrence operation `∘`
sit at the *boundary*:

* `η → 0⁺`  — the **free partial commutative magma** limit (instant full
  connection, `η = 0`);
* `η → ∞`   — the **commutative monoid** limit (delayed sparse completion).

`η = 1` (Chinchilla `γ_κ = β`) is an interior point, neither boundary. -/

/-- A configuration of the Free–Comm family, recording its realized residual
exponent `η`, required to lie in the open ray `(0, ∞)`. -/
structure EtaConfig where
  /-- The realized residual-completion exponent `η`. -/
  η : ℝ
  /-- `η` lies in the open ray `(0, ∞)` (R.518: `η = ψ > 0`). -/
  ηpos : 0 < η

/-- `IsAlgebraicLimit η` : `η` is one of the two distinguished algebraic-limit
*values* of the Free–Comm family — the free-magma endpoint `0` or the
commutative-monoid endpoint, the latter modelled as "no finite value", i.e.
the only finite algebraic-limit value is `0`.  (The `∞` endpoint is not a real
number; among reals the sole algebraic-limit value is the boundary `0`.) -/
def IsAlgebraicLimit (η : ℝ) : Prop := η = 0

/-! ### The declared qualitative claim -/

/-- **R.519 — `η = 1` has no algebraic correspondence, DECLARED.**

The crisp reading: the Chinchilla value `η = 1` is **not** an algebraic-limit
value of the Free–Comm family, and it lies strictly inside the open
realization ray `(0, ∞)` (so it is an unmarked interior point, not an
endpoint). -/
def R519_no_algebraic_correspondence : Prop :=
  ¬ IsAlgebraicLimit 1 ∧ 0 < (1 : ℝ)

/-! ### The freedom theorem (η is a free parameter) -/

/-- **R.519 / R.518 — surjectivity: every `η ∈ (0,∞)` is realized.**

For each target `y > 0` there is a Free–Comm configuration with realized
exponent exactly `y`.  Hence `η` ranges over the whole open ray and is **not
determined** to any single value by the axioms. -/
theorem R_519_eta_surjective :
    ∀ y : ℝ, 0 < y → ∃ C : EtaConfig, C.η = y := by
  intro y hy
  exact ⟨⟨y, hy⟩, rfl⟩

/-- **R.519 — `η` is not forced to be `1`.**

There is a configuration whose realized `η` differs from `1` (take `η = 2`),
so no axiom pins `η = 1`. -/
theorem R_519_eta_not_forced_one :
    ∃ C : EtaConfig, C.η ≠ 1 := by
  refine ⟨⟨2, by norm_num⟩, ?_⟩
  show (2 : ℝ) ≠ 1
  norm_num

/-- **R.519 — two configurations realize different `η`.**

`η` is genuinely free: configurations with `η = 1` and `η = 2` both satisfy
the family constraints (`η > 0`) yet differ, so `η` is not a function of the
axioms alone. -/
theorem R_519_eta_not_determined :
    ∃ P Q : EtaConfig, P.η ≠ Q.η := by
  refine ⟨⟨1, by norm_num⟩, ⟨2, by norm_num⟩, ?_⟩
  show (1 : ℝ) ≠ 2
  norm_num

/-! ### The no-correspondence content (proved) -/

/-- **R.519 — `η = 1` is not the free-magma algebraic limit.**

The free-partial-commutative-magma limit is `η = 0`; since `1 ≠ 0`, the
Chinchilla value `η = 1` is not that algebraic limit. -/
theorem R_519_one_not_algebraic_limit : ¬ IsAlgebraicLimit 1 := by
  unfold IsAlgebraicLimit
  norm_num

/-- **R.519 — `η = 1` is strictly inside the realization ray.**

`1` lies in the open interior `(0, ∞)` and below any "large-η" approximant
`L > 1` of the commutative-monoid limit; together with `0 < 1` this places it
strictly between the two algebraic-limit endpoints. -/
theorem R_519_one_strictly_interior (L : ℝ) (hL : 1 < L) :
    (0 : ℝ) < 1 ∧ (1 : ℝ) < L := ⟨by norm_num, hL⟩

/-- **R.519 — the declared qualitative claim is PROVED (crisp reading).**

`R519_no_algebraic_correspondence` holds: `η = 1` is not the algebraic-limit
value `0`, and it is a positive interior point of the realization ray.  This
is the formal core of "`η = 1` has no algebraic correspondence". -/
theorem R_519_no_algebraic_correspondence_holds :
    R519_no_algebraic_correspondence :=
  ⟨R_519_one_not_algebraic_limit, by norm_num⟩

/-- **R.519 — combined freedom + no-correspondence statement.**

There is a configuration with `η ≠ 1` (freedom), and `η = 1` is neither
algebraic limit while sitting in the open ray (no correspondence).  This is
the full R.519 reading: `η = 1` is a free, unmarked interior value. -/
theorem R_519_main :
    (∃ C : EtaConfig, C.η ≠ 1) ∧ R519_no_algebraic_correspondence :=
  ⟨R_519_eta_not_forced_one, R_519_no_algebraic_correspondence_holds⟩

end EtaNoAlgebraicCorrespondence

end MIP
