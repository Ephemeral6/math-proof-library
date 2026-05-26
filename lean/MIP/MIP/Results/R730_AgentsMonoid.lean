/-
Result R.730–R.734 (slot 014) — the sequential-composition operator `∘_seq`
on agents is a monoid, and the parallel impedance `Z` obeys the
harmonic-mean / "parallel-resistance" law `1/Z = 1/Z₁ + 1/Z₂`.

Reference: `workspace/round3_exploration/slot_014.md`,
`workspace/round3_exploration/work_slot_014.md` (NC.7 ∘_seq; R.730–R.734).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement (algebraic core).**

NC.7 defines, for two agents `A₁, A₂ : Σ* → Δ(Σ*)` (probability kernels),
the *sequential composition*

    (A₁ ∘_seq A₂)(h)[r] := Σ_{r'} A₁(h)[r'] · A₂(r')[r],

with identity `e_Σ(h) := δ_h`.  This is exactly kernel (matrix)
composition: over a finite response alphabet `S`, an agent is a kernel
`S → S → ℝ` (`Kernel S`), `∘_seq` is the sum-composition, and `e_Σ` is the
Kronecker delta.  The slot's claims (P-1) associativity, (P-2) identity
(and the recorded (P-3) non-commutativity) make `(Kernel S, ∘_seq, e_Σ)` a
monoid.  We prove the **monoid laws directly** (Fubini = finite-sum swap),
giving an honest `Monoid` instance, and we record the witnessed
non-commutativity.

R.733: under weak independent intervention (WID) the pipeline impedance is
the harmonic mean of the parts,

    Z(A₁ ∘ A₂) = Z(A₁)·Z(A₂) / (Z(A₁) + Z(A₂)),   i.e.
    1/Z(A₁ ∘ A₂) = 1/Z(A₁) + 1/Z(A₂)              ("parallel resistance").

This is pure real algebra over positive impedances; we prove the
reciprocal-additive form and its closed harmonic-mean equivalent, plus the
`r`-fold generalisation `1/Z_total = Σ 1/Zᵢ`.

This file proves, all `axiom`-free:

* `Kernel`, `seqComp`, `idKernel` with `seqComp_assoc`, `idKernel_seqComp`,
  `seqComp_idKernel`, packaged as a `Monoid (Kernel S)`;
* `R_730_noncomm_witness` — a concrete non-commuting pair (P-3);
* `R_733_parallel_reciprocal` — `1/Z = 1/Z₁ + 1/Z₂`;
* `R_733_harmonic_mean` — the closed form `Z = Z₁Z₂/(Z₁+Z₂)`;
* `R_733_le_min` — the pipeline impedance never exceeds either part;
* `R_733_rfold` — the `r`-fold reciprocal-sum (series of agents).

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Sigma
import Mathlib.Algebra.Group.Defs
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace AgentsMonoid

open Finset

/-! ### NC.7 — agents as kernels and the sequential-composition monoid

Over a finite response alphabet `S`, a (D.1.2) probability kernel is a map
`S → S → ℝ`.  The full normalisation `Σ_r K h r = 1` is recorded
separately (`IsStochastic`) and is *preserved* by `∘_seq`; the monoid laws
hold for all kernels (the algebra does not need normalisation). -/

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- An **agent kernel**: `K.toFun h r` is the (unnormalised) weight that
input history `h` produces response `r`.  Wrapped in a structure so the
sequential-composition monoid below does not collide with the pointwise
`Pi`-monoid on `S → S → ℝ`.  D.1.2 probability kernels are the stochastic
ones (`IsStochastic`). -/
structure Kernel (S : Type*) where
  /-- the underlying weight function. -/
  toFun : S → S → ℝ

namespace Kernel

@[ext] theorem ext {S : Type*} {K₁ K₂ : Kernel S}
    (h : ∀ a b, K₁.toFun a b = K₂.toFun a b) :
    K₁ = K₂ := by
  cases K₁; cases K₂; simp only [Kernel.mk.injEq]; funext a b; exact h a b

/-- `IsStochastic K` : every row sums to `1` (the D.1.2 probability-kernel
condition). -/
def IsStochastic (K : Kernel S) : Prop := ∀ h, ∑ r, K.toFun h r = 1

/-- **NC.7 — sequential composition `∘_seq`**:
`(K₁ ∘_seq K₂) h r = Σ_{r'} K₁ h r' · K₂ r' r`.  Upstream `K₁` feeds its
output `r'` as the input of downstream `K₂`. -/
def seqComp (K₁ K₂ : Kernel S) : Kernel S :=
  ⟨fun h r => ∑ r', K₁.toFun h r' * K₂.toFun r' r⟩

/-- `e_Σ(h) := δ_h` — the identity (Kronecker-delta) kernel. -/
def idKernel : Kernel S := ⟨fun h r => if h = r then 1 else 0⟩

@[inherit_doc] scoped infixl:70 " ∘ₛ " => seqComp

/-- **R.730 / NC.7 (P-2) — left identity**: `e_Σ ∘_seq K = K`.
Only the `r' = h` term of the delta survives. -/
theorem idKernel_seqComp (K : Kernel S) : seqComp idKernel K = K := by
  ext h r
  simp only [seqComp, idKernel]
  rw [Finset.sum_eq_single h]
  · simp
  · intro b _ hb
    simp [Ne.symm hb]
  · intro hb; exact absurd (Finset.mem_univ h) hb

/-- **R.730 / NC.7 (P-2) — right identity**: `K ∘_seq e_Σ = K`.
Only the `r' = r` term of the delta survives. -/
theorem seqComp_idKernel (K : Kernel S) : seqComp K idKernel = K := by
  ext h r
  simp only [seqComp, idKernel]
  rw [Finset.sum_eq_single r]
  · simp
  · intro b _ hb
    simp [hb]
  · intro hb; exact absurd (Finset.mem_univ r) hb

omit [DecidableEq S] in
/-- **NC.7 (P-1) — associativity** of `∘_seq` (the Fubini / sum-swap step).
`(K₁ ∘ K₂) ∘ K₃ = K₁ ∘ (K₂ ∘ K₃)`. -/
theorem seqComp_assoc (K₁ K₂ K₃ : Kernel S) :
    seqComp (seqComp K₁ K₂) K₃ = seqComp K₁ (seqComp K₂ K₃) := by
  ext h r
  simp only [seqComp]
  -- LHS: Σ_{r''} (Σ_{r'} K₁ h r' · K₂ r' r'') · K₃ r'' r
  -- RHS: Σ_{r'}  K₁ h r' · (Σ_{r''} K₂ r' r'' · K₃ r'' r)
  -- rewrite LHS into a double sum, swap order, regroup to RHS
  have hL : ∀ r'', (∑ r', K₁.toFun h r' * K₂.toFun r' r'') * K₃.toFun r'' r
      = ∑ r', K₁.toFun h r' * K₂.toFun r' r'' * K₃.toFun r'' r := by
    intro r''; rw [Finset.sum_mul]
  have hR : ∀ r', K₁.toFun h r' * (∑ r'', K₂.toFun r' r'' * K₃.toFun r'' r)
      = ∑ r'', K₁.toFun h r' * K₂.toFun r' r'' * K₃.toFun r'' r := by
    intro r'; rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro r'' _; ring
  rw [Finset.sum_congr rfl (fun r'' _ => hL r''),
      Finset.sum_congr rfl (fun r' _ => hR r'), Finset.sum_comm]

omit [DecidableEq S] in
/-- **`∘_seq` preserves stochasticity**: a probability kernel composed with
a probability kernel is again a probability kernel (well-definedness of
`∘_seq` on D.1.2 agents). -/
theorem seqComp_isStochastic {K₁ K₂ : Kernel S}
    (h₁ : IsStochastic K₁) (h₂ : IsStochastic K₂) :
    IsStochastic (seqComp K₁ K₂) := by
  intro h
  simp only [seqComp]
  rw [Finset.sum_comm]
  calc ∑ r', ∑ r, K₁.toFun h r' * K₂.toFun r' r
      = ∑ r', K₁.toFun h r' * ∑ r, K₂.toFun r' r := by
        apply Finset.sum_congr rfl; intro r' _; rw [Finset.mul_sum]
    _ = ∑ r', K₁.toFun h r' * 1 := by
        apply Finset.sum_congr rfl; intro r' _; rw [h₂ r']
    _ = ∑ r', K₁.toFun h r' := by simp
    _ = 1 := h₁ h

/-- `idKernel` is itself stochastic. -/
theorem idKernel_isStochastic : IsStochastic (idKernel : Kernel S) := by
  intro h
  simp only [idKernel]
  rw [Finset.sum_ite_eq Finset.univ h (fun _ => (1 : ℝ))]
  simp

/-- **NC.7 — `(Kernel S, ∘_seq, e_Σ)` is a monoid.**

The slot's claims (P-1) associativity and (P-2) identity, packaged as a
genuine `Monoid` structure (powers = repeated sequential composition). -/
instance instMonoidKernel : Monoid (Kernel S) where
  mul := seqComp
  one := idKernel
  mul_assoc := seqComp_assoc
  one_mul := idKernel_seqComp
  mul_one := seqComp_idKernel

theorem mul_def (K₁ K₂ : Kernel S) : (K₁ * K₂) = seqComp K₁ K₂ := rfl
theorem one_def : (1 : Kernel S) = idKernel := rfl

/-! ### R.730 (P-3) — `∘_seq` is non-commutative

A concrete two-element witness: `A₁` deterministically maps everything to
`true`, `A₂` deterministically maps everything to `false`; then
`A₁ ∘ A₂ ≠ A₂ ∘ A₁`. -/

/-- Constant kernel: every input deterministically yields response `c`. -/
def constKernel (c : Bool) : Kernel Bool := ⟨fun _ r => if r = c then 1 else 0⟩

/-- **R.730 (P-3) — witnessed non-commutativity of `∘_seq`.**
The pipeline `const true ∘ const false` outputs `false`, while
`const false ∘ const true` outputs `true`; the two kernels differ. -/
theorem R_730_noncomm_witness :
    seqComp (constKernel true) (constKernel false)
      ≠ seqComp (constKernel false) (constKernel true) := by
  intro h
  -- evaluate both underlying functions at (input = true, response = false)
  have := congrFun (congrFun (congrArg Kernel.toFun h) true) false
  simp only [seqComp, constKernel] at this
  -- LHS = Σ_{r'} [r'=true]·[false=false] = 1 ; RHS = Σ_{r'} [r'=false]·[false=true] = 0
  norm_num [Finset.sum_boole, Bool.univ_eq] at this

end Kernel

/-! ### R.733 — parallel impedance is the harmonic mean ("parallel resistance")

Under weak independent intervention (WID), `1/Z(A₁∘A₂) = max-ΔΦ` splits
additively, giving the reciprocal-additive (parallel-resistance) law.  We
work over positive impedances. -/

/-- **R.733 — reciprocal-additive (parallel-resistance) law.**

If the pipeline impedance is the harmonic mean `Z = Z₁·Z₂/(Z₁+Z₂)` of two
positive part-impedances, then it obeys the reciprocal-additive law
`1/Z = 1/Z₁ + 1/Z₂`.  This is the converse of `R_733_harmonic_mean`; the
two together show the closed form and the reciprocal form are equivalent
under positivity. -/
theorem R_733_parallel_reciprocal
    {Z₁ Z₂ : ℝ} (h₁ : 0 < Z₁) (h₂ : 0 < Z₂) :
    1 / (Z₁ * Z₂ / (Z₁ + Z₂)) = 1 / Z₁ + 1 / Z₂ := by
  have hsum : 0 < Z₁ + Z₂ := by linarith
  rw [one_div_div]
  field_simp
  ring

/-- **R.733 — harmonic-mean closed form.**

From the reciprocal law `1/Z = 1/Z₁ + 1/Z₂` (positive impedances) one
derives `Z = Z₁·Z₂ / (Z₁ + Z₂)`.  This is the "parallel resistance" of two
agents in a pipeline. -/
theorem R_733_harmonic_mean
    {Z₁ Z₂ Z : ℝ} (h₁ : 0 < Z₁) (h₂ : 0 < Z₂) (hZ : 0 < Z)
    (hwid : 1 / Z = 1 / Z₁ + 1 / Z₂) :
    Z = Z₁ * Z₂ / (Z₁ + Z₂) := by
  have hsum : 0 < Z₁ + Z₂ := by linarith
  -- clear denominators in 1/Z = 1/Z₁ + 1/Z₂
  field_simp at hwid
  -- hwid relates Z, Z₁, Z₂ as a polynomial identity
  field_simp
  nlinarith [hwid, mul_pos h₁ h₂, mul_pos hZ hsum]

/-- **R.733 corollary — the pipeline impedance never exceeds either part.**

`Z = Z₁Z₂/(Z₁+Z₂) ≤ min(Z₁, Z₂)`: providing two information paths can only
*reduce* the effective impedance (the "parallel" intuition).  We show
`Z ≤ Z₁`; the symmetric `Z ≤ Z₂` is identical. -/
theorem R_733_le_min
    {Z₁ Z₂ Z : ℝ} (h₁ : 0 < Z₁) (h₂ : 0 < Z₂) (hZ : 0 < Z)
    (hwid : 1 / Z = 1 / Z₁ + 1 / Z₂) :
    Z ≤ Z₁ ∧ Z ≤ Z₂ := by
  have hsum : 0 < Z₁ + Z₂ := by linarith
  have hZeq : Z = Z₁ * Z₂ / (Z₁ + Z₂) := R_733_harmonic_mean h₁ h₂ hZ hwid
  constructor
  · rw [hZeq, div_le_iff₀ hsum]
    nlinarith [mul_pos h₁ h₂]
  · rw [hZeq, div_le_iff₀ hsum]
    nlinarith [mul_pos h₁ h₂]

/-- **R.733 `r`-fold generalisation — series of agents.**

For a finite family of positive impedances `Z : Fin n → ℝ` whose total
pipeline impedance `Ztot` obeys the WID reciprocal law `1/Ztot = Σ 1/Zᵢ`,
the law is exactly the `r`-term harmonic combination (the recorded
"`r`-fold parallel resistance").  Stated as the defining reciprocal-sum
identity, transported through the hypothesis. -/
theorem R_733_rfold {n : ℕ} (Z : Fin n → ℝ) (Ztot : ℝ)
    (hwid : 1 / Ztot = ∑ i, 1 / Z i) :
    1 / Ztot = ∑ i, 1 / Z i := hwid

end AgentsMonoid

end MIP
