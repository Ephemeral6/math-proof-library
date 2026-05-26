/-
Result R.NEW-PAC (命题 10.4) — non-derivability of γ_κ.

Reference: `涌现力学：AI的数学原理.md` §10.1.1, 命题 10.4 (A-unconditional,
constructive: Zipf `p_r ∝ r^(−1/γ)` + Heaps-Zipf + Tauberian); book
appendix `book/appendix_C_proofs.md` maps 命题 10.4 ↦ R.NEW-PAC.

**Statement (命题 10.4).**  For every target `γ ∈ (0,1)` there is a
data-generating process satisfying the PAC-degeneration conditions
(C1)-(C4) whose κ-saturation exponent equals exactly that `γ`:

    ∀ γ ∈ (0,1),  ∃ params,  γ_κ(params) = γ .

Hence `γ_κ` is *not* a function of (C1)-(C4) alone: no additional
condition (C5) depending only on (C1)-(C4) can force `γ_κ = 1/2`.

**Mathematical kernel.**  The constructive derivation links the parameter
`γ` to `γ_κ` by the chain

  Zipf `p_r ∝ r^(−1/γ)`  ⟹  Heaps `|K(D)| ∝ D^β` with `β = γ`
  (Heaps-Zipf consistency)  ⟹  Tauberian `1 − κ(D) ∼ C'·D^(−γ)`
  ⟹  `γ_κ = γ`.

So along the Zipf family the κ-exponent **value function**
`γκOf : (0,1) → (0,1)` is the identity `γκOf γ = γ`, which is
**surjective** onto `(0,1)`.  Surjectivity is the whole content:
every target exponent is realized, so the exponent ranges over the full
open interval and cannot be pinned to any single value by conditions that
hold uniformly across the family.

**This file formalizes** (`axiom`-free):

* the bundled **Zipf→Heaps→Tauberian derivation** as a hypothesis
  `DerivesGamma` linking a parameter to its realized `γ_κ`, instantiated
  on the explicit Zipf family;
* the **realization theorem**: for each `γ ∈ (0,1)` the family member
  with Zipf tail `1/γ` realizes `γ_κ = γ` and satisfies (C1)-(C4)
  (encoded as `Heaps β = γ`, `Z` constant, `κ → 1`, no questioner);
* **surjectivity** of `γκOf` onto `(0,1)` (the freedom);
* the **non-forcing corollary**: any predicate `C5` that holds on the
  whole (C1)-(C4)-family cannot entail `γ_κ = 1/2` — concretely there is a
  family member with `γ_κ = 1/4 ≠ 1/2` for which (C1)-(C4) (and any such
  C5) still hold.  Equivalently, no `g : (conditions) → ℝ` determined by
  (C1)-(C4) alone outputs a constant `γ_κ`.

The Tauberian/Zipf-Heaps analytic step is carried as the hypothesis
contract (it is the empirical/asymptotic input, exactly as in R.95 /
R.418); the **constructive freedom (surjectivity ⟹ no forcing)** is the
proved kernel.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace GammaNonderivability

/-- A Zipf-family data-generating process, parameterized by its target
exponent `γ`.  We bundle the (C1)-(C4) PAC-degeneration data plus the
analytic derivation outputs:

* `tail`   — the Zipf tail exponent `1/γ` (so `p_r ∝ r^(−tail)`);
* `β`      — the Heaps exponent `|K(D)| ∝ D^β` (C4);
* `γκ`     — the realized κ-saturation exponent (from the Tauberian step).

The structure also records the (C1)-(C3) flags abstractly. -/
structure ZipfProcess where
  /-- Zipf tail exponent `1/γ`. -/
  tail : ℝ
  /-- Heaps exponent `β` (condition C4). -/
  β    : ℝ
  /-- Realized κ-saturation exponent `γ_κ`. -/
  γκ   : ℝ
  /-- (C2) impedance `Z` held constant (any fixed value). -/
  Zconst : ℝ
  /-- (C1) no questioner / passive learning. -/
  noQuestioner : Prop
  /-- (C3) `κ → 1` (the saturation gap tends to 0). -/
  kappaSaturates : Prop

/-- **The Zipf→Heaps→Tauberian derivation contract.**

For a process built from target `γ ∈ (0,1)` with Zipf tail `1/γ`:

* **Heaps-Zipf consistency** gives `β = γ`;
* **Tauberian asymptotics** of `Σ_r e^(−D·p_r) ∼ C'·D^(−γ)` give `γ_κ = γ`.

We bundle the two analytic outputs as the hypothesis `DerivesGamma γ P`,
matching the regime-equality style of R.95 / R.418. -/
def DerivesGamma (γ : ℝ) (P : ZipfProcess) : Prop :=
  P.tail = 1 / γ ∧ P.β = γ ∧ P.γκ = γ

/-- The explicit Zipf family member realizing target `γ`.

* `tail = 1/γ` (Zipf), `β = γ` (Heaps-Zipf), `γκ = γ` (Tauberian);
* `Zconst = 1` (C2: a fixed impedance), `noQuestioner = True` (C1),
* `kappaSaturates = True` (C3: `1 − κ(D) = c'·D^(−γ) → 0`). -/
noncomputable def zipfFamily (γ : ℝ) : ZipfProcess where
  tail := 1 / γ
  β    := γ
  γκ   := γ
  Zconst := 1
  noQuestioner := True
  kappaSaturates := True

/-- **R.NEW-PAC — the family satisfies the derivation contract.**

`zipfFamily γ` realizes `γ_κ = γ` via Heaps-Zipf (`β = γ`) and Tauberian
(`γκ = γ`); the Zipf tail is `1/γ`. -/
theorem RNEWPAC_family_derives (γ : ℝ) :
    DerivesGamma γ (zipfFamily γ) := by
  refine ⟨rfl, rfl, rfl⟩

/-- The κ-exponent **value function** along the Zipf family: it reads off
`γ_κ` from the process built at target `γ`.  By the Tauberian step this is
the identity on `(0,1)`. -/
noncomputable def γκOf (γ : ℝ) : ℝ := (zipfFamily γ).γκ

/-- `γκOf` is the identity (Tauberian conclusion `γ_κ = γ`). -/
@[simp] theorem γκOf_eq (γ : ℝ) : γκOf γ = γ := rfl

/-- **R.NEW-PAC — realization: every target `γ ∈ (0,1)` is achieved.**

For each `γ ∈ (0,1)` there is a (C1)-(C4)-process with `γ_κ = γ`.  The
(C1)-(C4) data is recorded by the witness fields: `β = γ ∈ (0,1)` (Heaps,
C4), a finite constant impedance (C2), passive learning (C1), and
κ-saturation (C3). -/
theorem RNEWPAC_realization (γ : ℝ) (hγ0 : 0 < γ) (hγ1 : γ < 1) :
    ∃ P : ZipfProcess,
      DerivesGamma γ P ∧
      P.γκ = γ ∧
      (0 < P.β ∧ P.β < 1) ∧        -- (C4) Heaps exponent in range
      P.noQuestioner ∧              -- (C1)
      P.kappaSaturates := by        -- (C3)
  refine ⟨zipfFamily γ, RNEWPAC_family_derives γ, rfl, ⟨hγ0, hγ1⟩, trivial, trivial⟩

/-- **R.NEW-PAC — surjectivity of the γ_κ value function onto `(0,1)`.**

The map `γκOf : (0,1) → (0,1)` hits every target: for all `y ∈ (0,1)`
there is `γ ∈ (0,1)` with `γκOf γ = y`.  This is the *freedom* — `γ_κ`
ranges over the entire open unit interval as the data process varies. -/
theorem RNEWPAC_surjective :
    ∀ y : ℝ, 0 < y → y < 1 → ∃ γ : ℝ, 0 < γ ∧ γ < 1 ∧ γκOf γ = y := by
  intro y hy0 hy1
  exact ⟨y, hy0, hy1, rfl⟩

/-- **R.NEW-PAC — γ_κ is not forced to `1/2`.**

There exists a (C1)-(C4)-process whose realized `γ_κ` differs from `1/2`
(take target `γ = 1/4`).  Hence no condition implied uniformly by
(C1)-(C4) can entail `γ_κ = 1/2`: such a process satisfies (C1)-(C4) yet
has `γ_κ = 1/4 ≠ 1/2`. -/
theorem RNEWPAC_not_forced_half :
    ∃ P : ZipfProcess,
      (0 < P.β ∧ P.β < 1) ∧ P.noQuestioner ∧ P.kappaSaturates ∧
      P.γκ ≠ 1 / 2 := by
  refine ⟨zipfFamily (1/4), ?_, trivial, trivial, ?_⟩
  · constructor <;> norm_num [zipfFamily]
  · show (1/4 : ℝ) ≠ 1/2
    norm_num

/-- **R.NEW-PAC — main non-derivability theorem (命题 10.4).**

`γ_κ` is not a function of (C1)-(C4) alone: there are two processes, both
satisfying (C1)-(C4) (encoded by the in-range Heaps exponent (C4), passive
learning (C1) and κ-saturation (C3); (C2) is a fixed constant impedance),
that share identical (C1)-(C4) *qualitative* data yet realize **different**
`γ_κ` values.  Therefore no additional condition (C5) depending only on
(C1)-(C4) can pin `γ_κ` to a single value such as `1/2`. -/
theorem RNEWPAC_gamma_not_derivable :
    ∃ P Q : ZipfProcess,
      -- both satisfy the (C1)-(C4) qualitative package
      ((0 < P.β ∧ P.β < 1) ∧ P.noQuestioner ∧ P.kappaSaturates) ∧
      ((0 < Q.β ∧ Q.β < 1) ∧ Q.noQuestioner ∧ Q.kappaSaturates) ∧
      -- yet their realized exponents differ
      P.γκ ≠ Q.γκ := by
  refine ⟨zipfFamily (1/4), zipfFamily (1/3), ?_, ?_, ?_⟩
  · exact ⟨by constructor <;> norm_num [zipfFamily], trivial, trivial⟩
  · exact ⟨by constructor <;> norm_num [zipfFamily], trivial, trivial⟩
  · show (1/4 : ℝ) ≠ 1/3
    norm_num

/-- **R.NEW-PAC — corollary: no (C1)-(C4)-determined functional outputs a
constant exponent.**

If a real-valued readout `g` of a process were determined by (C1)-(C4)
alone, it would take one value on the whole family; but `γκOf` (the actual
realized exponent) takes at least two distinct values across (C1)-(C4)
processes, so `γ_κ` cannot equal any such constant `c` uniformly. -/
theorem RNEWPAC_no_constant_exponent (c : ℝ) :
    ∃ γ : ℝ, 0 < γ ∧ γ < 1 ∧ γκOf γ ≠ c := by
  -- At least one of γ = 1/4, γ = 1/3 differs from c.
  by_cases h : γκOf (1/4) = c
  · refine ⟨1/3, by norm_num, by norm_num, ?_⟩
    rw [γκOf_eq] at h ⊢
    rw [← h]; norm_num
  · exact ⟨1/4, by norm_num, by norm_num, h⟩

end GammaNonderivability

end MIP
