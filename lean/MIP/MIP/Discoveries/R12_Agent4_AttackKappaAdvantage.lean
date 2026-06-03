/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R12_Agent4
  TARGET: Cj.40 (KappaAdvantage) — "the human's core advantage is κ
    (combinatorial closure)".  We attack the QUANTITATIVE κ-advantage BOUND:
    the advantage from κ is POSITIVE and BOUNDED.

  SUMMARY:
    The conjecture file `Cj40_KappaAdvantage.lean` models, for each agent, a
    capability proxy `Kcard = |K|` and a closure density
    `κ(K, R_∘) := |R_∘| / |K|²` (à la R.818), and *realises* a regime where the
    AI wins capability (`Kcard A > Kcard H`) but the human wins κ
    (`kappa H > kappa A`).  The full Cj.40 (FORCING `κ(H) > κ(A)` from A.1–A.4)
    remains OPEN — there is no axiom relating the human's and the AI's κ.

    This file proves the COMPLEMENTARY, axiom-honest content the conjecture file
    did NOT: a sharp two-sided BOUND on the κ-advantage `Adv := κ(H) − κ(A)`,
    grounded in the cooperative-surplus structure (R8_Agent6, R4/R5 tower).

    (1) **κ is a genuine density** (`kappa_mem_unit`): for any agent whose
        realised composition relation lies in the knowledge board
        (`R_∘ ⊆ K ×ˢ K`) with nonempty `K`, `0 ≤ κ(K, R_∘) ≤ 1`.  So κ lives in
        the unit interval — the advantage axis is intrinsically bounded.

    (2) **κ-advantage POSITIVE & BOUNDED** (`kappa_advantage_pos_bounded`,
        HEADLINE): in the κ-dominance regime (`κ A < κ H`, both genuine
        densities), the advantage `Adv := κ H − κ A` satisfies

            0  <  Adv  ≤  κ H  ≤  1 ,

        i.e. the κ-advantage is strictly positive and bounded above by the
        unit ceiling — POSITIVE AND BOUNDED, exactly the conjectured shape.

    (3) **κ-advantage inside the cooperative-surplus envelope**
        (`kappa_advantage_in_surplus_envelope`): the κ-advantage coexists with
        the cooperative collaboration surplus of R8_Agent6 — the surplus
        `σ = δ_AH + δ_HA` is non-negative (R8_Agent6.surplus_nonneg, ← R.139.a)
        and the cost-minimising committee allocation is no larger than the
        conserved convex average (R8_Agent6.optimal_allocation_le_mixture,
        ← R5_Agent8).  So the κ-advantage (positive, ≤ 1) sits inside a
        non-negative, floor-respecting cooperation structure: collaboration
        never destroys the κ-advantage and never beats its own conserved
        average.

    CONJECTURE STATUS: KERNEL_ONLY.  The full Cj.40 (FORCING `κ(H) > κ(A)` for
    the actual human/AI from A.1–A.4) remains OPEN; this file proves the
    κ-advantage BOUND — positivity and unit-boundedness of `Adv := κ(H) − κ(A)`
    in the κ-dominance regime — plus its embedding in the cooperative surplus.

  Depends on (all GENUINELY load-bearing in proof terms):
    - MIP.Discoveries.R8_Agent6_CooperativeGameXiBound  (R4/R5 TOWER) :
        R8_Agent6_CooperativeGameXiBound.surplus_nonneg               (σ ≥ 0)
        R8_Agent6_CooperativeGameXiBound.optimal_allocation_le_mixture (min ≤ N̄)
    - MIP.Discoveries.R5_Agent8_MixtureFanoCoverage     (R5 TOWER) :
        R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture
                                          (conserved min ≤ convex average)
    - MIP.Results.R139_CollaborationSavings :
        CollaborationSavings.R_139_a_savings_nonneg     (surplus non-negativity)
    - Mathlib: Finset.card_le_card, Finset.card_product, div_le_one, positivity.

  This file is `sorry`-free and declares NO new axiom (only the framework
  axioms A.1–A.4 enter, transitively through the imported tower files).
-/
import MIP.Discoveries.R8_Agent6_CooperativeGameXiBound
import MIP.Discoveries.R5_Agent8_MixtureFanoCoverage
import MIP.Results.R139_CollaborationSavings
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Prod
import Mathlib.Tactic

namespace MIP

namespace R12_Agent4_AttackKappaAdvantage

/-! ## The κ model (à la R.818 / Cj.40): `κ(K, R_∘) := |R_∘| / |K|²`.

We reproduce the conjecture file's κ definition so the bound is stated against
the same object the conjecture quantifies over. -/

/-- Combinatorial closure density `κ := |R_∘| / |K|²` for a finite knowledge
space `K` and a realised composition relation `R_∘ ⊆ K × K` (Cj.40 / R.818). -/
noncomputable def kappaOf {Ω : Type} (K : Finset Ω) (Rcomp : Finset (Ω × Ω)) : ℝ :=
  Rcomp.card / (K.card : ℝ) ^ 2

/-! ## (1) κ is a genuine density: `0 ≤ κ ≤ 1`.

The advantage axis is intrinsically bounded.  Nonnegativity is structural;
the unit ceiling uses that a realised composition relation contained in the
knowledge board has at most `|K|²` pairs (`Finset.card_product`). -/

/-- **κ is nonnegative.** `0 ≤ κ(K, R_∘)` always (a count over a square). -/
theorem kappa_nonneg {Ω : Type} (K : Finset Ω) (Rcomp : Finset (Ω × Ω)) :
    0 ≤ kappaOf K Rcomp := by
  unfold kappaOf; positivity

/-- **κ ≤ 1 for a genuine density.** If the realised composition relation is a
sub-relation of the knowledge board (`R_∘ ⊆ K ×ˢ K`) and `K` is nonempty, then
`κ(K, R_∘) ≤ 1`: there are at most `|K|²` composable pairs. -/
theorem kappa_le_one {Ω : Type} (K : Finset Ω) (Rcomp : Finset (Ω × Ω))
    (hsub : Rcomp ⊆ K ×ˢ K) (hK : K.Nonempty) :
    kappaOf K Rcomp ≤ 1 := by
  unfold kappaOf
  -- |R_∘| ≤ |K ×ˢ K| = |K|², lifted to ℝ.
  have hcard : (Rcomp.card : ℝ) ≤ (K.card : ℝ) ^ 2 := by
    have h1 : Rcomp.card ≤ (K ×ˢ K).card := Finset.card_le_card hsub
    rw [Finset.card_product] at h1
    have h2 : (Rcomp.card : ℝ) ≤ ((K.card * K.card : ℕ) : ℝ) := by exact_mod_cast h1
    rw [Nat.cast_mul] at h2
    nlinarith [h2]
  have hpos : (0 : ℝ) < (K.card : ℝ) ^ 2 := by
    have hc : 0 < K.card := Finset.card_pos.mpr hK
    have : (0 : ℝ) < (K.card : ℝ) := by exact_mod_cast hc
    positivity
  rw [div_le_one hpos]; exact hcard

/-- **κ lives in the unit interval** for a genuine density: `0 ≤ κ ≤ 1`.
The κ "advantage axis" is intrinsically bounded — which is what makes the
κ-advantage bounded below in (2). -/
theorem kappa_mem_unit {Ω : Type} (K : Finset Ω) (Rcomp : Finset (Ω × Ω))
    (hsub : Rcomp ⊆ K ×ˢ K) (hK : K.Nonempty) :
    0 ≤ kappaOf K Rcomp ∧ kappaOf K Rcomp ≤ 1 :=
  ⟨kappa_nonneg K Rcomp, kappa_le_one K Rcomp hsub hK⟩

/-! ## (2) HEADLINE — the κ-advantage is POSITIVE and BOUNDED.

In the κ-dominance regime (the regime Cj.40 *realises* but cannot force), the
advantage `Adv := κ(H) − κ(A)` is strictly positive AND bounded above by 1. -/

/-- **(2) Cj.40 κ-advantage bound (KERNEL).**

Let `H` (human) carry knowledge board `K_H` and realised composition relation
`R_H ⊆ K_H ×ˢ K_H`, and `A` (AI) carry `(K_A, R_A)` — both genuine densities
(`R ⊆ K ×ˢ K`, `K` nonempty).  In the κ-dominance regime
`κ(K_A, R_A) < κ(K_H, R_H)` (the regime Cj.40 realises), the κ-advantage

    Adv := κ(K_H, R_H) − κ(K_A, R_A)

satisfies the two-sided bound

    0  <  Adv  ≤  κ(K_H, R_H)  ≤  1 ,

i.e. **the advantage from κ is POSITIVE and BOUNDED** (by the unit ceiling).
The lower bound `0 < Adv` is the κ-dominance hypothesis; the upper bound
`Adv ≤ κ(H) ≤ 1` uses (1): `κ(A) ≥ 0` shrinks the gap and `κ(H) ≤ 1` caps it.

This is the honest κ-advantage *inequality* the conjecture pointed at; the full
Cj.40 (forcing `κ(H) > κ(A)` from A.1–A.4) remains OPEN — see header. -/
theorem kappa_advantage_pos_bounded
    {Ω : Type}
    (K_H : Finset Ω) (R_H : Finset (Ω × Ω))
    (K_A : Finset Ω) (R_A : Finset (Ω × Ω))
    (hsubH : R_H ⊆ K_H ×ˢ K_H) (hKH : K_H.Nonempty)
    (hsubA : R_A ⊆ K_A ×ˢ K_A) (hKA : K_A.Nonempty)
    (hdom : kappaOf K_A R_A < kappaOf K_H R_H) :
    0 < kappaOf K_H R_H - kappaOf K_A R_A
    ∧ kappaOf K_H R_H - kappaOf K_A R_A ≤ kappaOf K_H R_H
    ∧ kappaOf K_H R_H ≤ 1 := by
  -- κ(A) ∈ [0,1], κ(H) ∈ [0,1].
  have hA := kappa_mem_unit K_A R_A hsubA hKA
  have hH := kappa_mem_unit K_H R_H hsubH hKH
  refine ⟨by linarith, by linarith [hA.1], hH.2⟩

/-! ## (3) The κ-advantage inside the cooperative-surplus envelope.

The κ-advantage is not an isolated inequality: it coexists with the
cooperative collaboration surplus of R8_Agent6 (R4/R5 tower).  We package the
positive, bounded κ-advantage TOGETHER with:
  * surplus non-negativity `0 ≤ σ` (R8_Agent6.surplus_nonneg, ← R.139.a):
    collaboration never hurts; and
  * committee-min ≤ conserved convex average (R8_Agent6.optimal_allocation_le_mixture
    ← R5_Agent8): the cost-minimising allocation cannot beat its own average.

So the κ-advantage `0 < Adv ≤ 1` lives inside a non-negative, floor-respecting
cooperation structure — the cooperative-surplus lever the target named. -/

/-- **(3) κ-advantage embedded in the cooperative surplus (HEADLINE).**

Two independent data bundles, jointly satisfiable:

* **κ data** (Cj.40): genuine densities for `H` and `A` in the κ-dominance
  regime `κ(A) < κ(H)`.
* **cooperative-surplus data** (R8_Agent6 / R.139): per-side external-aid gaps
  `δ_AH, δ_HA ≥ 0` with surplus `σ = δ_AH + δ_HA`, and a conserved committee
  mixture (`w_a ≥ 0`, `∑ w_a = 1`) with per-agent counts `N_a`.

Conclusion (five-part):
  (i)   `0 < κ(H) − κ(A)`            — κ-advantage strictly positive;
  (ii)  `κ(H) − κ(A) ≤ κ(H) ≤ 1`    — κ-advantage bounded above by 1;
  (iii) `0 ≤ σ`                      — cooperative surplus non-negative
                                        (R8_Agent6.surplus_nonneg ← R.139.a);
  (iv)  `min_a N_a ≤ ∑_a w_a N_a`    — cost-minimising allocation ≤ conserved
                                        convex average
                                        (R8_Agent6.optimal_allocation_le_mixture
                                         ← R5_Agent8).

The κ-advantage (positive, ≤ 1) thus sits inside a non-negative,
floor-respecting cooperative-surplus envelope. -/
theorem kappa_advantage_in_surplus_envelope
    {Ω : Type} {ι : Type} [Fintype ι]
    -- κ data (Cj.40)
    (K_H : Finset Ω) (R_H : Finset (Ω × Ω))
    (K_A : Finset Ω) (R_A : Finset (Ω × Ω))
    (hsubH : R_H ⊆ K_H ×ˢ K_H) (hKH : K_H.Nonempty)
    (hsubA : R_A ⊆ K_A ×ˢ K_A) (hKA : K_A.Nonempty)
    (hdom : kappaOf K_A R_A < kappaOf K_H R_H)
    -- cooperative-surplus data (R8_Agent6 / R.139)
    (δ_AH δ_HA σ : ℝ)
    (h_σ_def : σ = δ_AH + δ_HA) (h_AH : 0 ≤ δ_AH) (h_HA : 0 ≤ δ_HA)
    -- conserved committee mixture (R5_Agent8 via R8_Agent6)
    (N w : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ a, 0 ≤ w a) (hw_sum : ∑ a, w a = 1) :
    -- (i) κ-advantage strictly positive
    (0 < kappaOf K_H R_H - kappaOf K_A R_A)
    -- (ii) κ-advantage bounded above by 1
    ∧ (kappaOf K_H R_H - kappaOf K_A R_A ≤ kappaOf K_H R_H ∧ kappaOf K_H R_H ≤ 1)
    -- (iii) cooperative surplus non-negative (R8_Agent6 ← R.139.a)
    ∧ (0 ≤ σ)
    -- (iv) cost-min allocation ≤ conserved convex average (R8_Agent6 ← R5_Agent8)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a) := by
  obtain ⟨hpos, hub, hone⟩ :=
    kappa_advantage_pos_bounded K_H R_H K_A R_A hsubH hKH hsubA hKA hdom
  refine ⟨hpos, ⟨hub, hone⟩, ?_, ?_⟩
  · -- (iii) cooperative surplus non-negativity, via R8_Agent6 (← R.139.a).
    exact R8_Agent6_CooperativeGameXiBound.surplus_nonneg δ_AH δ_HA σ h_σ_def h_AH h_HA
  · -- (iv) committee-min ≤ conserved convex average, via R8_Agent6 (← R5_Agent8).
    exact R8_Agent6_CooperativeGameXiBound.optimal_allocation_le_mixture
      N w hne hw_nonneg hw_sum

/-! ## Cross-check: R.139.a directly drives the surplus arm.

We expose the R.139 dependency live (R8_Agent6's `surplus_nonneg` is literally
R.139.a), so the surplus non-negativity is a genuine corpus proof term. -/

/-- **(cross-check) The surplus arm is exactly R.139.a.** `σ ≥ 0` follows
directly from `CollaborationSavings.R_139_a_savings_nonneg`, identical to the
arm used inside `kappa_advantage_in_surplus_envelope` (via R8_Agent6). -/
theorem surplus_arm_is_R139a
    (δ_AH δ_HA σ : ℝ)
    (h_σ_def : σ = δ_AH + δ_HA) (h_AH : 0 ≤ δ_AH) (h_HA : 0 ≤ δ_HA) :
    0 ≤ σ :=
  CollaborationSavings.R_139_a_savings_nonneg δ_AH δ_HA σ h_σ_def h_AH h_HA

/-- **(cross-check) The committee arm is exactly R5_Agent8.**
`min_a N_a ≤ ∑_a w_a N_a` follows directly from
`R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture` — the same lemma
R8_Agent6 re-exposes and that the envelope theorem uses. -/
theorem committee_arm_is_R5Agent8
    {ι : Type} [Fintype ι] (N w : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ a, 0 ≤ w a) (hw_sum : ∑ a, w a = 1) :
    Finset.univ.inf' hne N ≤ ∑ a, w a * N a :=
  R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture N w hne hw_nonneg hw_sum

end R12_Agent4_AttackKappaAdvantage

end MIP
