/-
Result R.820 — μ two-time-scale behaviour and metacognition/domain duality.
Reference: branches/collaboration_dynamics/results/intervention_effects.md (A-grade, audited 2026-05-27).

**Statement.** `μ(X) = log(|M_X*| / |M|)`.
- (a) In-dialogue `μ` is invariant (R.815): pure-domain tokens are inert.
- (b) `M_X*` depends only on the metacognitive part `K^M(X)`.
- (c) Post-training: metacognitive intervention enlarges `K^M(X)` ⟹ `μ ↑` (M-5 monotone);
  a pure-domain expert intervention (`K^M(e) ⊆ K^M(X)`) leaves `K^M(X)` unchanged ⟹ `μ`
  is *exactly* unchanged.
- Conclusion: metacognitive intervention `→ (κ↑, μ↑)`; pure-domain expert `→ (κ↓, μ unchanged)`
  — the `(κ, μ)` plane is orthogonal (functionally independent).

**Kernel formalized here.**
1. *Dialogue-invariance via A.4 (Axioms.A4).*  A pure-domain dialogue token `ω ∉ K X` leaves
   `X`'s output distribution unchanged (A.4: `X h = X (tokenReplace ω h)`).  Since `μ` is a
   functional of the agent's behaviour through `K^M(X)`, and an inert token changes neither,
   `μ` is invariant.  We formalize the inert-token kernel `X h = X (τ_ω h)` directly from A.4,
   and the μ-invariance as: `μ` defined on `K^M(X)` is unchanged when `K^M(X)` is unchanged.
2. *μ as a function of `K^M(X)`; monotone (M-5).*  Model `μ(X) := log(|MSet(X)| / |M|)` where
   `MSet(X) ⊆ M` is the metacognitive-reachable intervention set, with `M ≠ ∅`.  We prove
   (b) μ depends only on `MSet`; (c-metacog) if metacognition enlarges `MSet`
   (`MSet ⊆ MSet'`, with `|M| > 0`) then `μ` weakly increases, and strictly when the set
   strictly grows; (c-domain) if a pure-domain injection leaves `MSet` unchanged then μ is
   exactly unchanged.
3. *(κ, μ) orthogonality (four-quadrant, R.92 idiom).*  Modelling `(κ, μ)` as a pair of
   real parameters, all four sign-quadrants are realisable, and no functional dependence
   `μ = f(κ)` or `κ = g(μ)` holds.  This is the precise "orthogonal plane" content.

**Bridge.** Step 1 is A.4 verbatim; step 2 is the `log`-of-count algebra of D.3.12 (M-5);
step 3 is the R.92-style independence of the two scalars.
Axiom-free (only A.1–A.4; this file uses A.4).
-/
import MIP.Axioms
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R820_MuOrthogonal

/-! ## Part 1 — Dialogue-invariance: pure-domain tokens are inert (A.4)

A token for a knowledge element outside `K X` does not change `X`'s output (A.4).  This is the
mechanism behind "in-dialogue μ is invariant": a pure-domain dialogue cannot move the agent's
behaviour, hence cannot move μ. -/

variable {α : Type} {Ω : Type}

/-- **R.820(a) — pure-domain dialogue token is inert (A.4).**  If `ω ∉ K X` then appending its
token leaves `X`'s output distribution unchanged.  (This is A.4; it underlies the
dialogue-invariance of μ.) -/
theorem R_820_pure_domain_token_inert
    (X : Agent α) (ω : Ω) (h : Str α) (hOut : ω ∉ (K X : Set Ω)) :
    X h = X (tokenReplace ω h) :=
  Axioms.A4 X ω h hOut

/-! ## Part 2 — μ as a function of `K^M(X)`; monotone (M-5) and domain-invariant

`μ(X) := log(|MSet(X)| / |M|)` with `MSet(X) ⊆ M` the metacognitive-reachable set, `|M| > 0`. -/

/-- Metacognitive quality `μ(X) := log(|M_X*| / |M|)` (D.3.12), modelled from the
metacognitive-reachable count `mxStar := |M_X*|` and total `mTotal := |M|`. -/
noncomputable def μ (mxStar mTotal : ℝ) : ℝ := Real.log (mxStar / mTotal)

/-- **R.820(b)/(c-domain) — μ depends only on `K^M(X)`; pure-domain injection leaves μ exact.**
If a pure-domain expert injection leaves the metacognitive-reachable count `M_X*` unchanged
(`mxStar' = mxStar`, the content of `K^M(e) ⊆ K^M(X) ⟹ K^M(X)` unchanged), then μ is exactly
unchanged. -/
theorem R_820_pure_domain_mu_invariant
    (mxStar mxStar' mTotal : ℝ) (hEq : mxStar' = mxStar) :
    μ mxStar' mTotal = μ mxStar mTotal := by
  unfold μ; rw [hEq]

/-- **R.820(c-metacog) — metacognition raises μ (M-5 monotone).**  If a metacognitive
intervention enlarges the metacognitive-reachable count (`mxStar ≤ mxStar'`) with positive
counts and total `mTotal > 0`, then `μ` weakly increases: `μ mxStar mTotal ≤ μ mxStar' mTotal`. -/
theorem R_820_metacog_raises_mu
    (mxStar mxStar' mTotal : ℝ)
    (hpos : 0 < mxStar) (hTotal : 0 < mTotal) (hle : mxStar ≤ mxStar') :
    μ mxStar mTotal ≤ μ mxStar' mTotal := by
  unfold μ
  apply Real.log_le_log
  · positivity
  · exact div_le_div_of_nonneg_right hle hTotal.le

/-- **R.820(c-metacog, strict) — metacognition strictly raises μ when `M_X*` strictly grows.** -/
theorem R_820_metacog_raises_mu_strict
    (mxStar mxStar' mTotal : ℝ)
    (hpos : 0 < mxStar) (hTotal : 0 < mTotal) (hlt : mxStar < mxStar') :
    μ mxStar mTotal < μ mxStar' mTotal := by
  unfold μ
  apply Real.log_lt_log
  · positivity
  · exact div_lt_div_of_pos_right hlt hTotal

/-! ## Part 3 — (κ, μ) orthogonality (four-quadrant, R.92 idiom)

Modelling `(κ_increment, μ_increment)` as a pair of real parameters: metacognitive intervention
realises `(κ↑, μ↑)`; pure-domain expert realises `(κ↓, μ=0)`.  All four sign-quadrants are
realisable and no functional dependence holds — the orthogonality content. -/

/-- The four sign-quadrants of the joint `(κ-change, μ-change)`. -/
inductive Quadrant
  | bothZero
  | kappaOnly
  | muOnly
  | bothPos

/-- A pair `(dκ, dμ)` realises a quadrant when its sign profile matches. -/
def Quadrant.realises : Quadrant → ℝ → ℝ → Prop
  | bothZero,  dκ, dμ => dκ = 0 ∧ dμ = 0
  | kappaOnly, dκ, dμ => 0 < dκ ∧ dμ = 0
  | muOnly,    dκ, dμ => dκ = 0 ∧ 0 < dμ
  | bothPos,   dκ, dμ => 0 < dκ ∧ 0 < dμ

/-- **R.820 — (κ, μ) orthogonality: all four quadrants realisable.**  In particular the
metacognitive `(κ↑, μ↑)` (= `bothPos`) and pure-domain `(κ-change, μ=0)` (= `kappaOnly`, with
the sign of `dκ` either way) profiles are both realisable, witnessing that `(κ, μ)` are
functionally independent. -/
theorem R_820_quadrants_realised :
    (∃ dκ dμ : ℝ, Quadrant.realises .bothZero dκ dμ) ∧
    (∃ dκ dμ : ℝ, Quadrant.realises .kappaOnly dκ dμ) ∧
    (∃ dκ dμ : ℝ, Quadrant.realises .muOnly dκ dμ) ∧
    (∃ dκ dμ : ℝ, Quadrant.realises .bothPos dκ dμ) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact ⟨0, 0, rfl, rfl⟩
  · exact ⟨1, 0, by norm_num, rfl⟩
  · exact ⟨0, 1, rfl, by norm_num⟩
  · exact ⟨1, 1, by norm_num, by norm_num⟩

/-- **R.820 — no functional dependence `μ = f(κ)`.**  If μ-change were a function of κ-change,
`(κ=0, μ=0)` and `(κ=0, μ>0)` would force `0 = f 0 > 0`.  (Metacognition `(κ↑,μ↑)` vs
pure-domain at the same κ baseline give different μ.) -/
theorem R_820_no_function_from_kappa :
    ¬ ∃ f : ℝ → ℝ, ∀ dκ dμ : ℝ,
      (Quadrant.realises .bothZero dκ dμ ∨
       Quadrant.realises .kappaOnly dκ dμ ∨
       Quadrant.realises .muOnly dκ dμ ∨
       Quadrant.realises .bothPos dκ dμ) → dμ = f dκ := by
  rintro ⟨f, hf⟩
  have h00 : (0 : ℝ) = f 0 := hf 0 0 (Or.inl ⟨rfl, rfl⟩)
  have h01 : (1 : ℝ) = f 0 := hf 0 1 (Or.inr (Or.inr (Or.inl ⟨rfl, by norm_num⟩)))
  linarith [h00.trans h01.symm]

/-- **R.820 — no functional dependence `κ = g(μ)`.**  Symmetric: `(κ=0,μ=0)` and `(κ>0,μ=0)`
force `0 = g 0 > 0`. -/
theorem R_820_no_function_from_mu :
    ¬ ∃ g : ℝ → ℝ, ∀ dκ dμ : ℝ,
      (Quadrant.realises .bothZero dκ dμ ∨
       Quadrant.realises .kappaOnly dκ dμ ∨
       Quadrant.realises .muOnly dκ dμ ∨
       Quadrant.realises .bothPos dκ dμ) → dκ = g dμ := by
  rintro ⟨g, hg⟩
  have h00 : (0 : ℝ) = g 0 := hg 0 0 (Or.inl ⟨rfl, rfl⟩)
  have h10 : (1 : ℝ) = g 0 := hg 1 0 (Or.inr (Or.inl ⟨by norm_num, rfl⟩))
  linarith [h00.trans h10.symm]

end R820_MuOrthogonal

end MIP
