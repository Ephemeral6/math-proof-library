/-
Mathematical Principles of Intelligence (MIP) — Emergence Mechanics
The four axioms A.1–A.4.

Reference: `axioms/three_axioms.md` (current four-axiom version after the
2026-05-18 upgrade of D.1.3.a → A.4).

A.1–A.4 are stated as `axiom` declarations: they are foundational
postulates of Emergence Mechanics, not theorems derivable from a more
primitive layer. Each auxiliary symbol (`N`, `Φ₀`, `K`, `R`, `ℛ`, `M`,
`Kᴹ`, `Cₑ`, `π`, `τ_ω`, `tvDist`) is introduced as an `opaque`
declaration so downstream files can rely on the signatures.
-/
import MIP.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.NNReal.Basic
import Mathlib.Data.ENat.Basic
import Mathlib.Data.ENNReal.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

/-! ## Abstract symbols used by the axioms -/

/-- The candidate-solution projection `π : Σ* → Σ*` (Definition 2.7). -/
opaque solnProj {α : Type} : Str α → Str α

/-- Total-variation distance between two response distributions over `Σ*`. -/
opaque tvDist {α : Type} : PMF (Str α) → PMF (Str α) → NNReal

/-- Definition 2.4 (Knowledge space). `K X ⊆ Ω`. -/
opaque K {α : Type} {Ω : Type} : Agent α → Set Ω

/-- Definition 2.9 (Knowledge demand). `R p ⊆ Ω`. -/
opaque R {α : Type} {Ω : Type} : Problem α → Set Ω

/-- Family ℛ(p) of admissible abductive explanations of `p`
(Definition D.1.4.a v3). -/
opaque demandFamily {α : Type} {Ω : Type} : Problem α → Set (Set Ω)

/-- Definition 2.11 (Meta-cognitive intervention set). `M ⊂ Σ*`. -/
opaque MetaSet {α : Type} : Set (Str α)

/-- Definition 2.11 (meta-knowledge map). `Kᴹ m ⊆ Ω`. -/
opaque metaKnowledge {α : Type} {Ω : Type} : Str α → Set Ω

/-- Knowledge content of an expert intervention `e ∈ Σ* \ M`. -/
opaque expertKnowledge {α : Type} {Ω : Type} : Str α → Set Ω

/-- Knowledge density `Cₑ` of an expert intervention `e` (Definition D.3.6). -/
opaque Cₑ {α : Type} : Str α → NNReal

/-- Emergence degree `N(p, X) ∈ ℕ ∪ {∞}` (Definition 2.10 / A.1). -/
opaque N {α : Type} : Problem α → Agent α → ℕ∞

/-- Opaque "core" emergence potential used by `Phi0` for non-trivial
problems.  Hidden behind `Phi0` so that the always-true problem case
is forced to `0` definitionally (any output is "correct" for
`fun _ => true`, hence trivially solvable). -/
opaque Phi0Raw {α : Type} : Agent α → Problem α → ENNReal

/-- Initial emergence potential `Φ₀(X, p) ∈ [0, ∞]` (Definition 2.10).

Definitionally `0` for the always-true problem (which is trivially
solvable by any output) and `Phi0Raw X p` otherwise.  The signature is
unchanged from the opaque version; only the body is exposed.  All
A.1-based derivations remain valid; in addition, `Phi0_always_true`
now follows directly. -/
noncomputable def Phi0 {α : Type} (X : Agent α) (p : Problem α) : ENNReal :=
  open Classical in
  if (∀ s : Str α, p s = true) then 0 else Phi0Raw X p

/-- `Phi0` of the always-true problem is `0` (by definition). -/
theorem Phi0_always_true {α : Type} (X : Agent α) :
    Phi0 X (fun _ : Str α => true) = 0 := by
  unfold Phi0
  exact if_pos (fun _ => rfl)

/-- Token-replacement operator `τ_ω : Σ* → Σ*` (A.4). -/
opaque tokenReplace {α : Type} {Ω : Type} : Ω → Str α → Str α

/-- Append a meta / expert intervention to a dialogue history. -/
abbrev extendHist {α : Type} : Str α → Str α → Str α := List.append

/-! ## The four axioms -/

namespace Axioms

variable {α : Type} {Ω : Type}

/-- **Axiom A.1 (Autonomy / well-definedness of `N`).**

`N p X = 0  ↔  Φ₀ X p = 0`.

Foundational postulate: zero interventions are required iff the initial
emergence potential is zero. (`axioms/three_axioms.md` A.1, δ→0 limit
of the `N_δ` master form.) -/
axiom A1 (p : Problem α) (X : Agent α) :
    N p X = 0 ↔ Phi0 X p = 0

/-- **Axiom A.2 (Knowledge coverage).**

`N(p, X) < ∞  ⟺  ∃ R ∈ ℛ(p), R ⊆ K(X).` -/
axiom A2 (p : Problem α) (X : Agent α) :
    N p X ≠ ⊤
      ↔
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)

/-- **Axiom A.3 (Expert-knowledge emergibility).**

For any `e ∈ Σ* \ M` with `K(e) ⊆ K(X)` and any ε > 0 there is a
meta-cognitive sequence `(m₁,…,m_k)` of length `k ≤ Cₑ(e) · log(1/ε)`
whose effect on the next response is within total-variation distance ε
of `e`'s effect. -/
axiom A3 (X : Agent α) (e : Str α) (h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω)) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (extendHist h e))
              (X (extendHist h (ms.foldl List.append []))) ≤ ε

/-- **Axiom A.4 (Cognitive boundary).**

Tokens for knowledge elements outside `K X` have no effect on `X`'s
output distribution: `ω ∉ K(X) ⟹ ∀ h, L(X(h)) = L(X(τ_ω(h)))`. -/
axiom A4 (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    X h = X (tokenReplace ω h)

end Axioms

end MIP
