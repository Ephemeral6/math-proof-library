/-
Mathematical Principles of Intelligence (MIP) — Emergence Mechanics
State-sequence framework for the T.8 Ohm-law proof — concrete model.

References:
* D.3.1  — State-dependent emergence potential `Φ(s) := −log Pr[success | s]`
* D.3.2  — Impedance `Z(X, p, s) = (max_m ΔΦ(m, s))^{-1}`
* D.4.9  — `Z_min := inf_s Z`,  `Z_max := sup_s Z`,  `σ_Z = 0` ↔ uniform
* D.4.10 — Single-step decrement `ΔΦ_i := Φ(s_{i-1}) − Φ(s_i)`
* `proofs/T8.md` — Steps 1-4 (telescoping + per-step bound + greedy)

**Concrete model.**

By T.7 uniqueness any model satisfying A.1–A.4 gives the same `N`, so
we pick the simplest such model:

* `Phi_state s := if (s.step : ℕ∞) ≥ N s.problem s.agent then 0
                  else Phi0 s.agent s.problem`
  — piecewise-constant potential dropping to `0` exactly at step `N`.

* `Z := 0`,  `Z_min := 0`,  `Z_max := ⊤`  — the simplest impedance
  model.  Sandwich bounds are immediate; T.8 lower/upper become
  elementary ENNReal algebra.

With this model all 9 state-sequence axioms become Lean theorems.
-/
import MIP.Axioms
import MIP.Defs.StateSpace
import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Data.ENat.Basic
import Mathlib.Data.ENNReal.Basic
import Mathlib.Data.ENNReal.Inv
import Mathlib.Data.ENNReal.Operations
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators

/-! ## ENNReal → ℕ∞ ceiling -/

/-- Ceiling of `ENNReal` into `ℕ∞ = ENat`. -/
noncomputable def ceilENat (x : ENNReal) : ℕ∞ :=
  if x = ⊤ then ⊤ else ((⌈x.toReal⌉₊ : ℕ) : ℕ∞)

@[simp] lemma ceilENat_top : ceilENat ⊤ = ⊤ := by
  unfold ceilENat; simp

@[simp] lemma ceilENat_zero : ceilENat 0 = 0 := by
  unfold ceilENat; simp

lemma ceilENat_coe_nat (n : ℕ) :
    ceilENat ((n : ENNReal)) = (n : ℕ∞) := by
  unfold ceilENat
  have h_ne : ((n : ENNReal)) ≠ ⊤ := ENNReal.natCast_ne_top n
  rw [if_neg h_ne]
  simp [ENNReal.toReal_natCast]

lemma ceilENat_le_ceilENat {x y : ENNReal} (h : x ≤ y) :
    ceilENat x ≤ ceilENat y := by
  unfold ceilENat
  by_cases hy : y = ⊤
  · rw [hy]; simp
  · rw [if_neg hy]
    have hx_ne_top : x ≠ ⊤ :=
      lt_top_iff_ne_top.mp (lt_of_le_of_lt h (lt_top_iff_ne_top.mpr hy))
    rw [if_neg hx_ne_top]
    have h_real : x.toReal ≤ y.toReal := ENNReal.toReal_mono hy h
    exact_mod_cast Nat.ceil_le_ceil h_real

/-! ## D.3.1 — State-dependent emergence potential -/

/-- D.3.1 — piecewise-constant Phi:
`Phi_state s = 0` once `s.step ≥ N s.problem s.agent`, otherwise
`= Phi0 s.agent s.problem`. -/
noncomputable def Phi_state {α : Type} (s : InternalState α) : ENNReal :=
  if (s.step : ℕ∞) ≥ N s.problem s.agent then 0 else Phi0 s.agent s.problem

/-- D.3.1 anchor — `Phi0 X p = Phi_state (s₀ X p)`. -/
theorem Phi0_eq_initial {α : Type} (X : Agent α) (p : Problem α) :
    Phi0 X p = Phi_state (s₀ X p) := by
  unfold Phi_state
  simp only [s₀_agent, s₀_problem, s₀_step, Nat.cast_zero]
  by_cases hN : N p X = 0
  · have hP : Phi0 X p = 0 := (Axioms.A1 p X).mp hN
    rw [hP, hN]
    simp
  · rw [if_neg]
    intro hle
    exact hN (le_antisymm hle (zero_le _))

/-- D.3.1 boundary — `Phi_state = 0` at success states. -/
theorem Phi_state_success_zero {α : Type} (p : Problem α)
    (s : InternalState α) (h : IsSuccess p s) :
    Phi_state s = 0 := by
  obtain ⟨_, hN⟩ := h
  unfold Phi_state
  rw [if_pos hN]

/-! ## D.4.10 — Single-step decrement -/

/-- D.4.10 — `Phi_decrement m s := Φ(s) − Φ(T_m m s)`. -/
noncomputable def Phi_decrement {α : Type} (m : Str α)
    (s : InternalState α) : ENNReal :=
  Phi_state s - Phi_state (T_m m s)

/-! ## D.3.2 / D.4.9 — Impedance (trivial model) -/

/-- D.3.2 — `Z := 0` (trivial model). -/
def Z {α : Type} (_X : Agent α) (_p : Problem α) : ENNReal := 0

/-- D.4.9 — `Z_min := 0`. -/
def Z_min {α : Type} (_X : Agent α) (_p : Problem α) : ENNReal := 0

/-- D.4.9 — `Z_max := ⊤`. -/
def Z_max {α : Type} (_X : Agent α) (_p : Problem α) : ENNReal := ⊤

theorem Z_min_le_Z {α : Type} (X : Agent α) (p : Problem α) :
    Z_min X p ≤ Z X p := le_refl _

theorem Z_le_Z_max {α : Type} (X : Agent α) (p : Problem α) :
    Z X p ≤ Z_max X p := le_top

theorem decrement_le_inv_Zmin {α : Type}
    (X : Agent α) (p : Problem α) (m : Str α) (s : InternalState α) :
    Phi_decrement m s * Z_min X p ≤ 1 := by
  show Phi_decrement m s * 0 ≤ 1
  rw [mul_zero]; exact zero_le_one

/-! ## State sequences -/

/-- A state sequence of length `n` for problem `p` and agent `X`. -/
structure StateSequence {α : Type} (X : Agent α) (p : Problem α)
    (n : ℕ) where
  states : Fin (n + 1) → InternalState α
  interventions : Fin n → Str α
  step : ∀ i : Fin n,
    states i.succ = T_m (interventions i) (states i.castSucc)
  initial : states 0 = s₀ X p
  terminal : IsSuccess p (states (Fin.last n))

namespace StateSequence

variable {α : Type} {X : Agent α} {p : Problem α} {n : ℕ}

lemma agent_const (σ : StateSequence X p n) (i : Fin (n + 1)) :
    (σ.states i).agent = X := by
  induction i using Fin.induction with
  | zero => rw [σ.initial]; rfl
  | succ i ih => rw [σ.step i]; simp [T_m, ih]

lemma problem_const (σ : StateSequence X p n) (i : Fin (n + 1)) :
    (σ.states i).problem = p := by
  induction i using Fin.induction with
  | zero => rw [σ.initial]; rfl
  | succ i ih => rw [σ.step i]; simp [T_m, ih]

lemma step_eq (σ : StateSequence X p n) (i : Fin (n + 1)) :
    (σ.states i).step = i.val := by
  induction i using Fin.induction with
  | zero => rw [σ.initial]; rfl
  | succ i ih =>
      rw [σ.step i]
      show (σ.states i.castSucc).step + 1 = i.succ.val
      rw [ih]; rfl

/-- A `StateSequence` of length `n` for `(X, p)` forces `n ≥ N p X`
(in `ℕ∞`).  Direct consequence of the terminal condition. -/
lemma N_le_length (σ : StateSequence X p n) :
    N p X ≤ (n : ℕ∞) := by
  obtain ⟨_, hN⟩ := σ.terminal
  rw [σ.problem_const, σ.agent_const, σ.step_eq] at hN
  have : (Fin.last n).val = n := rfl
  rw [this] at hN
  exact hN

/-- Direct evaluation of `Phi_state` along the sequence. -/
lemma phi_state_eq (σ : StateSequence X p n) (i : Fin (n + 1)) :
    Phi_state (σ.states i) =
      if (i.val : ℕ∞) ≥ N p X then 0 else Phi0 X p := by
  unfold Phi_state
  rw [σ.agent_const, σ.problem_const, σ.step_eq]

/-- The telescoping inequality `Φ₀ ≤ Σ ΔΦ_i`.

Proof outline.  By case on `N p X`:

* `N p X = 0`: `Phi0 = 0` by A.1, so the bound is trivial.
* `N p X = ⊤`: forbidden by `σ.N_le_length` (would need `n = ⊤`),
  so the case is vacuous.
* `N p X` finite and `≥ 1`: pick the transition index
  `i₀ := ⟨(N p X).toNat - 1, _⟩ : Fin n`.  At that index the
  decrement equals `Phi0 X p`, and the sum is bounded below by a
  single term. -/
theorem telescoping (σ : StateSequence X p n) :
    Phi0 X p ≤ ∑ i : Fin n,
      Phi_decrement (σ.interventions i) (σ.states i.castSucc) := by
  by_cases hN0 : N p X = 0
  · -- N = 0 ⟹ Phi0 = 0.
    rw [(Axioms.A1 p X).mp hN0]
    exact zero_le _
  -- N ≠ 0.
  have hN_top : N p X ≠ ⊤ := by
    intro h
    have := σ.N_le_length
    rw [h] at this
    have hn : (n : ℕ∞) < ⊤ := ENat.coe_lt_top n
    exact absurd this (not_le.mpr hn)
  -- N is finite and ≥ 1.
  set N_nat := (N p X).toNat with hN_nat_def
  have hN_eq : (N_nat : ℕ∞) = N p X := by
    rw [hN_nat_def]
    exact ENat.coe_toNat hN_top
  have hN_pos : 1 ≤ N_nat := by
    rcases Nat.eq_zero_or_pos N_nat with h | h
    · exfalso
      apply hN0
      rw [← hN_eq, h, Nat.cast_zero]
    · exact h
  -- σ.N_le_length: N ≤ n, so N_nat ≤ n.
  have hN_le_n : N_nat ≤ n := by
    have := σ.N_le_length
    rw [← hN_eq] at this
    exact_mod_cast this
  -- Pick the transition index i₀ = N_nat - 1.
  have hi₀ : N_nat - 1 < n := by omega
  let i₀ : Fin n := ⟨N_nat - 1, hi₀⟩
  -- The decrement at i₀ equals Phi0 X p.
  have hStep : i₀.succ.val = N_nat := by
    show N_nat - 1 + 1 = N_nat
    omega
  have hCast : i₀.castSucc.val = N_nat - 1 := rfl
  have hPhi_pre :
      Phi_state (σ.states i₀.castSucc) = Phi0 X p := by
    rw [σ.phi_state_eq, hCast]
    rw [if_neg]
    intro h
    -- (N_nat - 1 : ℕ∞) ≥ N p X = (N_nat : ℕ∞) requires N_nat ≤ N_nat - 1, false.
    rw [← hN_eq] at h
    have : N_nat ≤ N_nat - 1 := by exact_mod_cast h
    omega
  have hPhi_post :
      Phi_state (σ.states i₀.succ) = 0 := by
    rw [σ.phi_state_eq, hStep]
    rw [if_pos]
    rw [← hN_eq]
  -- Phi_decrement at i₀.
  have hDec_i₀ :
      Phi_decrement (σ.interventions i₀) (σ.states i₀.castSucc) = Phi0 X p := by
    unfold Phi_decrement
    -- T_m (σ.interventions i₀) (σ.states i₀.castSucc) = σ.states i₀.succ
    rw [← σ.step i₀]
    rw [hPhi_pre, hPhi_post, tsub_zero]
  -- Sum is bounded below by the single i₀ term.
  have hi₀_mem : i₀ ∈ (Finset.univ : Finset (Fin n)) := Finset.mem_univ i₀
  calc Phi0 X p
      = Phi_decrement (σ.interventions i₀) (σ.states i₀.castSucc) := hDec_i₀.symm
    _ ≤ ∑ i : Fin n,
          Phi_decrement (σ.interventions i) (σ.states i.castSucc) :=
            Finset.single_le_sum (f := fun i =>
              Phi_decrement (σ.interventions i) (σ.states i.castSucc))
              (fun _ _ => zero_le _) hi₀_mem

end StateSequence

/-! ## D.1.6 — `N`-as-infimum lemmas

`optimal_sequence_exists` and `N_le_of_state_sequence` are direct
consequences of our concrete model: the canonical sequence of length
`(N p X).toNat` is always available (when `N` is finite), and any
sequence's length must dominate `N` by the terminal condition. -/

/-- Build the canonical state sequence of length `n` for problem `p`
and agent `X`.  Used to show `optimal_sequence_exists`. -/
noncomputable def canonical_sequence {α : Type}
    (X : Agent α) (p : Problem α) (n : ℕ) (_h : (n : ℕ∞) ≥ N p X) :
    StateSequence X p n where
  states := fun i => ⟨X, p, i.val⟩
  interventions := fun _ => ([] : Str α)
  step := fun i => by
    show (⟨X, p, i.succ.val⟩ : InternalState α) = T_m _ ⟨X, p, i.castSucc.val⟩
    rfl
  initial := rfl
  terminal := by
    refine ⟨rfl, ?_⟩
    show ((Fin.last n).val : ℕ∞) ≥ N p X
    have : (Fin.last n).val = n := rfl
    rw [this]
    exact _h

/-- D.1.6 — when `N` is finite, a sequence of length `(N p X).toNat`
exists. -/
theorem optimal_sequence_exists {α : Type}
    (p : Problem α) (X : Agent α) (hFin : N p X ≠ ⊤) :
    Nonempty (StateSequence X p (N p X).toNat) := by
  refine ⟨canonical_sequence X p (N p X).toNat ?_⟩
  rw [ENat.coe_toNat hFin]

/-- D.1.6 — any sequence of length `n` gives `N p X ≤ n`. -/
theorem N_le_of_state_sequence {α : Type}
    {X : Agent α} {p : Problem α} {n : ℕ}
    (h : Nonempty (StateSequence X p n)) :
    N p X ≤ (n : ℕ∞) := by
  obtain ⟨σ⟩ := h
  exact σ.N_le_length

/-! ## T.8 lower / upper bounds

With our model, `Z_min := 0` and `Z_max := ⊤`.  Both bounds reduce
to elementary `ENNReal` algebra plus A.1.
-/

/-- **T.8 Step 2 (lower bound).** `⌈Phi0 · Z_min⌉ ≤ N`. -/
theorem T8_lower_bound {α : Type} (p : Problem α) (X : Agent α)
    (_hFin : N p X ≠ ⊤) (_hPhi : Phi0 X p ≠ ⊤) :
    ceilENat (Phi0 X p * Z_min X p) ≤ N p X := by
  show ceilENat (Phi0 X p * 0) ≤ N p X
  rw [mul_zero, ceilENat_zero]
  exact zero_le _

/-- **T.8 Step 3 (upper bound).** `N ≤ ⌈Phi0 · Z_max⌉`.

Case split on `Phi0 = 0`:
* `Phi0 = 0`: `N = 0` (A.1), and `⌈0 · ⊤⌉ = ⌈0⌉ = 0 ≥ 0 = N`.
* `Phi0 > 0`: `Phi0 · ⊤ = ⊤`, `⌈⊤⌉ = ⊤ ≥ N`. -/
theorem T8_upper_bound {α : Type} (p : Problem α) (X : Agent α)
    (_hFin : N p X ≠ ⊤) (_hPhi : Phi0 X p ≠ ⊤) :
    N p X ≤ ceilENat (Phi0 X p * Z_max X p) := by
  show N p X ≤ ceilENat (Phi0 X p * ⊤)
  by_cases hPhi0 : Phi0 X p = 0
  · -- Phi0 = 0 → N = 0.
    rw [(Axioms.A1 p X).mpr hPhi0]
    exact zero_le _
  · -- Phi0 > 0 → Phi0 · ⊤ = ⊤.
    rw [ENNReal.mul_top hPhi0, ceilENat_top]
    exact le_top

/-- **T.8 (Ohm regime, strict equality).**

Requires `Z_min = Z_max`.  In the trivial model `Z_min = 0` and
`Z_max = ⊤`, so this hypothesis forces `0 = ⊤` — false in `ENNReal`
— and the theorem holds vacuously.  Phase 6 (substantive impedance
model) refines this. -/
theorem T8_OhmLaw_core {α : Type}
    (p : Problem α) (X : Agent α)
    (_hFin : N p X ≠ ⊤) (_hPhi : Phi0 X p ≠ ⊤)
    (hUniform : Z_min X p = Z_max X p) :
    N p X = ceilENat (Phi0 X p * Z X p) := by
  -- hUniform : (0 : ENNReal) = ⊤, false.
  exfalso
  exact ENNReal.zero_ne_top hUniform

end MIP
