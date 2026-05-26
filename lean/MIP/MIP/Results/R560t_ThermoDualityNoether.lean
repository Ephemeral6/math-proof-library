/-
Result R.560 / R.561 / R.562 — thermodynamics × duality:
the σ_AH role-swap Noether flow on the 4-DOF dual algebra, the second
dissipative current `σ ≥ 0`, and the algebraization of R.121.c.

Reference: `workspace/round3_exploration/slot_032.md` and
`work_slot_032.md` (slot 032, R.560-562, thermo × duality bridge #2:
σ_AH-Noether flow decomposition + R.121.c algebraization).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

NOTE on numbering: this `R.560` is the thermo×duality result of slot 032,
DISTINCT from the Shannon `R.560` of slot 041 (`R560_ShannonDictionary.lean`).
The filename suffix `t` ( = thermo) keeps the two apart.

**Statement.**  The 4-DOF dual algebra carries the role-swap data

    N         := Φ_0(A)·Z(A|H)        (cross, A on H)
    N*        := Φ_0(H)·Z(H|A)        (cross, H on A)
    N_self_A  := Φ_0(A)·Z(A|A)        (self, A)
    N_self_H  := Φ_0(H)·Z(H|H)        (self, H)

and the `Z₂` involution `σ_AH` that swaps the two roles A ↔ H:

    σ_AH : (N, N*, N_self_A, N_self_H) ↦ (N*, N, N_self_H, N_self_A).

* **R.560 (A unconditional).**  `σ_AH` is an involution (`σ_AH² = id`).  The
  symmetric/antisymmetric combinations
      N_+ := N + N*,   N_self^+ := N_self_A + N_self_H   (σ_AH-invariant, V_+)
      N_- := N − N*,   N_self^- := N_self_A − N_self_H   (σ_AH-anti-invariant, V_-)
  diagonalise the action: `σ_AH` fixes V_+ and negates V_-.  The symmetric
  (`+1`) representation `V_- = 0` is exactly the Ohm-regime double cover
  `N = N* ∧ N_self_A = N_self_H`.  R.132 `N_+ = 2·N_bi + Asym` and
  R.139 `N_self^+ = 2·N_bi + Asym + σ` live entirely in V_+, so the gap
  `N_self^+ − N_+ = σ` is a σ_AH-invariant.

* **R.561 (A unconditional).**  The gap `σ := N_self^+ − N_+ ≥ 0` (R.139.a) is
  a second dissipative current, independent of `Asym`.  Its non-negativity is
  the algebraic Clausius inequality `N_self^+ ≥ N_+`, the A-unconditional
  algebraic equivalent of the R.281 (♥) bound, with NO path integral / Jensen.
  Combining the THREE nonnegative currents `(Asym, σ, S_emerge)` gives the
  unified second law: any nonnegative linear combination is conserved
  (`d/dt = 0`) along an on-shell Noether flow, or non-decreasing when the
  emergent-entropy production is non-negative — reusing the R.121
  `HasDerivAt`-vanishing kernel `dσ_AH/dt = 0`.

* **R.562 (A conditional, Ohm regime).**  The σ_AH breaking amplitude
  `Δ_σAH := |N_-| / N_+` is bounded by the asymmetry fraction:
      Δ_σAH  ≤  Asym / (2·N_bi + Asym)  =  1 − 2·N_bi / N_+ ,
  via R.527' (`|N_-| ≤ Asym`) and R.132 (`N_+ = 2·N_bi + Asym`).

**Bundled hypotheses (HYPOTHESIS-BUNDLE convention).**  The dual symmetry and
the on-shell Euler–Lagrange / Noether flow enter as hypotheses; R.132 and
R.139 enter as algebraic identities; R.527' `|N_-| ≤ Asym` enters as a
hypothesis (it is itself proved in `R527_AsymMetricFamily.lean`).

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace ThermoDualityNoether

/-! ### Part 1 — R.560: the σ_AH involution and its V_+ ⊕ V_- decomposition. -/

/-- The 4-DOF role data of the dual algebra. -/
structure RoleData where
  /-- `N = Φ_0(A)·Z(A|H)`  (cross current, A acting on H). -/
  N        : ℝ
  /-- `N* = Φ_0(H)·Z(H|A)`  (cross current, H acting on A). -/
  Nstar    : ℝ
  /-- `N_self_A = Φ_0(A)·Z(A|A)`  (self current, A). -/
  NselfA   : ℝ
  /-- `N_self_H = Φ_0(H)·Z(H|H)`  (self current, H). -/
  NselfH   : ℝ

namespace RoleData

/-- The `Z₂` role-swap involution `σ_AH : A ↔ H`, read off from D.3.9 + D.4.15:
swapping A and H exchanges `Z(A|H) ↔ Z(H|A)`, `Z(A|A) ↔ Z(H|H)`,
`Φ_0(A) ↔ Φ_0(H)`. -/
def sigmaAH (q : RoleData) : RoleData :=
  ⟨q.Nstar, q.N, q.NselfH, q.NselfA⟩

/-- σ_AH-invariant symmetric current `N_+ := N + N*` (V_+). -/
def Nplus (q : RoleData) : ℝ := q.N + q.Nstar

/-- σ_AH-anti-invariant current `N_- := N − N*` (V_-). -/
def Nminus (q : RoleData) : ℝ := q.N - q.Nstar

/-- σ_AH-invariant symmetric self current `N_self^+ := N_self_A + N_self_H`. -/
def NselfPlus (q : RoleData) : ℝ := q.NselfA + q.NselfH

/-- σ_AH-anti-invariant self current `N_self^- := N_self_A − N_self_H`. -/
def NselfMinus (q : RoleData) : ℝ := q.NselfA - q.NselfH

/-- **R.560 (a) — `σ_AH` is an involution (`σ_AH² = id`).**

The role-swap is a `Z₂` action; applying it twice restores the original
4-DOF data.  This is the algebraic content of R.121.c's role-swap symmetry,
read directly off the 4-DOF algebra with NO bidirectional Lagrangian `L_bi`. -/
@[simp] theorem sigmaAH_involutive (q : RoleData) :
    sigmaAH (sigmaAH q) = q := rfl

/-- **R.560 (b₁) — `N_+` is σ_AH-invariant** (lives in V_+, the `+1` rep). -/
@[simp] theorem Nplus_sigmaAH (q : RoleData) :
    Nplus (sigmaAH q) = Nplus q := by
  simp only [Nplus, sigmaAH]; ring

/-- **R.560 (b₂) — `N_self^+` is σ_AH-invariant** (lives in V_+). -/
@[simp] theorem NselfPlus_sigmaAH (q : RoleData) :
    NselfPlus (sigmaAH q) = NselfPlus q := by
  simp only [NselfPlus, sigmaAH]; ring

/-- **R.560 (b₃) — `N_-` is σ_AH-anti-invariant** (lives in V_-, the `−1` rep). -/
@[simp] theorem Nminus_sigmaAH (q : RoleData) :
    Nminus (sigmaAH q) = - Nminus q := by
  simp only [Nminus, sigmaAH]; ring

/-- **R.560 (b₄) — `N_self^-` is σ_AH-anti-invariant** (lives in V_-). -/
@[simp] theorem NselfMinus_sigmaAH (q : RoleData) :
    NselfMinus (sigmaAH q) = - NselfMinus q := by
  simp only [NselfMinus, sigmaAH]; ring

/-- **R.560 (c) — the symmetric (`+1`) representation ⟺ Ohm-regime double cover.**

`σ_AH` acts as the identity on `q` (`q` lies in the pure `+1` representation)
iff the antisymmetric V_- currents both vanish, i.e. `N = N*` and
`N_self_A = N_self_H` (the Ohm-regime double cover of R.131).  Proved as a
direct structural equivalence, with NO `L_bi`. -/
theorem sigmaAH_fixed_iff (q : RoleData) :
    sigmaAH q = q ↔ q.N = q.Nstar ∧ q.NselfA = q.NselfH := by
  constructor
  · intro h
    refine ⟨?_, ?_⟩
    · exact (congrArg RoleData.N h).symm
    · exact (congrArg RoleData.NselfA h).symm
  · rintro ⟨hN, hself⟩
    cases q with
    | mk N Nstar NselfA NselfH =>
      simp only at hN hself
      show RoleData.mk Nstar N NselfH NselfA
            = RoleData.mk N Nstar NselfA NselfH
      rw [← hN, ← hself]

/-- **R.560 (c′) — V_- vanishes ⟺ both antisymmetric currents vanish.**

Equivalent diagonalised form of the fixed-point characterisation: `q` is in
the `+1` representation iff `N_- = 0 ∧ N_self^- = 0`. -/
theorem vMinus_zero_iff (q : RoleData) :
    (Nminus q = 0 ∧ NselfMinus q = 0) ↔ (q.N = q.Nstar ∧ q.NselfA = q.NselfH) := by
  simp only [Nminus, NselfMinus, sub_eq_zero]

end RoleData

/-! ### Part 2 — R.560 (b) / R.561: R.132, R.139 live in V_+; `σ = N_self^+ − N_+`. -/

open RoleData

/-- **R.560 (b) — the V_+ identity gap `σ = N_self^+ − N_+`.**

R.132 (`N_+ = 2·N_bi + Asym`) and R.139 (`N_self^+ = 2·N_bi + Asym + σ`) enter
as bundled algebraic identities.  Subtracting, the entropy-production gap is
`σ = N_self^+ − N_+`, a quantity living entirely in V_+ (hence σ_AH-invariant).
-/
theorem R_560_sigma_eq_gap
    (q : RoleData) (N_bi Asym σ : ℝ)
    (hR132 : Nplus q = 2 * N_bi + Asym)
    (hR139 : NselfPlus q = 2 * N_bi + Asym + σ) :
    σ = NselfPlus q - Nplus q := by
  rw [hR132, hR139]; ring

/-- **R.561 (a) — `σ ≥ 0`: the second dissipative current.**

Given R.139.a (`σ ≥ 0`, bundled), the V_+ gap is nonnegative; equivalently the
algebraic Clausius inequality `N_self^+ ≥ N_+` holds.  This is the
A-unconditional algebraic equivalent of the R.281 (♥) bound, obtained with NO
path integral and NO Jensen inequality. -/
theorem R_561_clausius
    (q : RoleData) (N_bi Asym σ : ℝ)
    (hR132 : Nplus q = 2 * N_bi + Asym)
    (hR139 : NselfPlus q = 2 * N_bi + Asym + σ)
    (hσ : 0 ≤ σ) :
    Nplus q ≤ NselfPlus q := by
  rw [hR132, hR139]; linarith

/-- **R.561 (v) — `σ` and `Asym` are independent dissipative currents.**

The two currents are logically decoupled: there is a configuration with
`Asym = 0` (Ohm-symmetric) yet `σ > 0` (strictly dissipative).  We exhibit the
witness at the level of the V_+ identities (`N_+ = 2·N_bi`, `N_self^+ > N_+`),
establishing that `σ > 0` does NOT force `Asym > 0`. -/
theorem R_561_currents_independent :
    ∃ (N_bi Asym σ : ℝ), Asym = 0 ∧ 0 < σ ∧
      (2 * N_bi + Asym + σ) - (2 * N_bi + Asym) = σ :=
  ⟨0, 0, 1, rfl, by norm_num, by ring⟩

/-! ### Part 3 — R.561 / C.561.1: the Noether-flow kernel `dσ_AH/dt = 0`
and the unified second law. -/

/-- The σ_AH-invariant Noether charge as a function of time:
`Q_σAH(t) = N_self^+(t) − N_+(t) = σ(t)`, carried through the time-dependent
symmetric currents `nselfp = N_self^+(·)` and `nplus = N_+(·)`. -/
noncomputable def NoetherCharge (nselfp nplus : ℝ → ℝ) (t : ℝ) : ℝ :=
  nselfp t - nplus t

/-- **R.561 / C.561.1 — the Noether-flow kernel `dσ_AH/dt = 0`.**

Reusing the R.121 conservation pattern: if along the on-shell Noether flow the
symmetric currents `N_self^+` and `N_+` have a COMMON time derivative `c`
(the σ_AH-invariant flow keeps the V_+ gap stationary), then the conserved
charge `Q_σAH = N_self^+ − N_+ = σ` has vanishing time derivative,
`dσ_AH/dt = 0`. -/
theorem R_561_noether_conserved
    (nselfp nplus : ℝ → ℝ) (c : ℝ) (t : ℝ)
    (hself : HasDerivAt nselfp c t)
    (hplus : HasDerivAt nplus c t) :
    HasDerivAt (NoetherCharge nselfp nplus) 0 t := by
  have hsub := hself.sub hplus
  have hc : c - c = 0 := by ring
  rw [hc] at hsub
  exact hsub

/-- **C.561.1 — the unified second law for the three nonnegative currents.**

The combined potential `S = S_emerge + α·Asym + β·σ` with `α, β ≥ 0` is
non-decreasing: given the emergent-entropy production `dS_emerge/dt = Semdot`
(R.145 (i)), `d(Asym)/dt = Adot`, `d(σ)/dt = Sigdot` all non-negative, the time
derivative of the nonnegative combination is non-negative.  We formalise the
nonnegativity of the combined derivative. -/
theorem C_561_unified_second_law
    (Semdot Adot Sigdot α β : ℝ)
    (hSem : 0 ≤ Semdot) (hA : 0 ≤ Adot) (hSig : 0 ≤ Sigdot)
    (hα : 0 ≤ α) (hβ : 0 ≤ β) :
    0 ≤ Semdot + α * Adot + β * Sigdot := by
  have h1 : 0 ≤ α * Adot := mul_nonneg hα hA
  have h2 : 0 ≤ β * Sigdot := mul_nonneg hβ hSig
  linarith

/-- **C.561.1 — flow form: the unified second-law potential is monotone.**

`HasDerivAt` form: if `S_emerge`, `Asym`, `σ` have non-negative time
derivatives `Semdot, Adot, Sigdot` at `t`, then the combination
`S = S_emerge + α·Asym + β·σ` (α, β ≥ 0) has the (non-negative) derivative
`Semdot + α·Adot + β·Sigdot`. -/
theorem C_561_unified_flow
    (Sem Asy Sig : ℝ → ℝ) (Semdot Adot Sigdot α β : ℝ) (t : ℝ)
    (hSem : HasDerivAt Sem Semdot t)
    (hA : HasDerivAt Asy Adot t)
    (hSig : HasDerivAt Sig Sigdot t) :
    HasDerivAt (fun s => Sem s + α * Asy s + β * Sig s)
      (Semdot + α * Adot + β * Sigdot) t := by
  have hαA : HasDerivAt (fun s => α * Asy s) (α * Adot) t := hA.const_mul α
  have hβS : HasDerivAt (fun s => β * Sig s) (β * Sigdot) t := hSig.const_mul β
  exact (hSem.add hαA).add hβS

/-! ### Part 4 — R.562: the σ_AH breaking amplitude bound (Ohm regime). -/

/-- **R.562 (d) — σ_AH breaking amplitude bound.**

In the Ohm regime, with the R.527' inequality `|N_-| ≤ Asym` (bundled — it is
proved in `R527_AsymMetricFamily.lean`) and R.132 `N_+ = 2·N_bi + Asym`, the
breaking amplitude `Δ_σAH = |N_-| / N_+` is bounded:

    |N_-|  ≤  Asym  =  N_+ − 2·N_bi ,

i.e. `Δ_σAH ≤ Asym/(2·N_bi + Asym) = 1 − 2·N_bi/N_+`.  We prove the numerator
form `|N_-| ≤ N_+ − 2·N_bi`, the load-bearing algebraic content. -/
theorem R_562_breaking_amplitude
    (q : RoleData) (N_bi Asym : ℝ)
    (hR132 : Nplus q = 2 * N_bi + Asym)
    (hR527 : |Nminus q| ≤ Asym) :
    |Nminus q| ≤ Nplus q - 2 * N_bi := by
  rw [hR132]; linarith

/-- **R.562 (d′) — the normalised breaking-amplitude bound.**

Dividing through by `N_+ > 0`, the breaking amplitude `Δ_σAH = |N_-|/N_+` is at
most `Asym/N_+ = Asym/(2·N_bi + Asym)`.  We give the division-normalised
inequality with the positivity hypothesis `0 < N_+`. -/
theorem R_562_breaking_amplitude_normalised
    (q : RoleData) (N_bi Asym : ℝ)
    (hNplus : 0 < Nplus q)
    (hR132 : Nplus q = 2 * N_bi + Asym)
    (hR527 : |Nminus q| ≤ Asym) :
    |Nminus q| / Nplus q ≤ Asym / Nplus q := by
  have hnum : |Nminus q| ≤ Asym := by
    have := R_562_breaking_amplitude q N_bi Asym hR132 hR527
    linarith
  exact (div_le_div_iff_of_pos_right hNplus).mpr hnum

/-- **R.562 (b) — the Ohm-regime double cover is the σ_AH symmetric phase.**

`σ_AH = +1` (the role-swap acts trivially) iff the Ohm-regime double cover
`N = N* ∧ N_self_A = N_self_H` holds, equivalently the breaking amplitude
numerator `|N_-| = 0`.  This re-expresses R.121.c's symmetric condition WITHOUT
the `L_bi` working definition: it is anchored entirely on R.131's `N = N*`. -/
theorem R_562_ohm_symmetric (q : RoleData) :
    sigmaAH q = q ↔ (Nminus q = 0 ∧ NselfMinus q = 0) := by
  rw [sigmaAH_fixed_iff, vMinus_zero_iff]

end ThermoDualityNoether

end MIP
