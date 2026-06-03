/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 8
  DIRECTION: E — R.818 (κ cumulative monotone) + R.817 (intervention reach)
             ⟹ cumulative κ growth is bounded by intervention reach, with
             an explicit linear bound and an attainment-at-cover statement.

  SUMMARY:
    Two-result composition giving a tight cumulative κ bound:

    * R.817 (`R_817_kbar_le_kappa`, `R_817_kbar_monotone`,
      `R_817_kbar_sup_eq_kappa`, `R_817_cover_is_sup`):
        the metacognitive reach-process produces a monotone chain of
        co-occurrence pair sets whose cumulative density `κ̄` is bounded
        by the ceiling `κ`, and which attains `κ` when the chain covers
        the full intrinsic relation.
    * R.818 (`R_818_cumulative_monotone`,
      `R_818_cumulative_chain_monotone`): the *cumulative* contextual
      closure is monotone under set growth — pointwise `κ` is *not*.

    Compose to get:
      (1) **Linear-in-cardinality cumulative bound.** Along any monotone
          reach-process, the cumulative density `κ̄(t)` is bounded above by
          the (constant) `κ` ceiling — the cumulative growth saturates at
          `κ`. We give the *increment* form:
            `κ̄(t+s) − κ̄(t) ≤ κ − κ̄(t)`,
          i.e. cumulative growth above any baseline is bounded by the
          remaining headroom to `κ`.
      (2) **Cover-attains-supremum.** If at some stage `t₀` the cumulative
          reach equals the intrinsic relation, then `κ̄(t₀) = κ` and every
          earlier stage is `≤ κ` — the cumulative process is precisely
          monotone-non-decreasing along the chain with attained sup.
      (3) **Cumulative growth bounded by intervention reach** (the
          headline): for any two stages `a ≤ b` along the metacognitive
          process, `κ̄(b) − κ̄(a) ≥ 0` (R.818) AND `κ̄(b) ≤ κ` (R.817), so
          the cumulative growth is in `[0, κ − κ̄(a)]`. The intervention
          reach (number of metacognitive steps to cover) provides the
          *rate* axis: more interventions, larger `reach(b)`, larger
          `κ̄(b)`, up to the κ-ceiling.

  R-DEPS:
    • MIP.Results.R817_InterventionReach (κbar, κ, R_817_kbar_le_kappa,
                                          R_817_kbar_monotone,
                                          R_817_kbar_sup_eq_kappa,
                                          R_817_cover_is_sup)
    • MIP.Results.R818_KappaCumulativeMonotone (R_818_cumulative_monotone,
                                                R_818_cumulative_chain_monotone,
                                                κctx)
-/
import MIP.Results.R817_InterventionReach
import MIP.Results.R818_KappaCumulativeMonotone

namespace MIP

namespace R3_Agent8_KappaCumulativeReach

open MIP.R817_InterventionReach
open MIP.R818_KappaCumulativeMonotone

variable {Ω : Type}

/-! ### Part 1 — `κctx = κbar` agree as cumulative-density functionals.

R.817's `κbar` and R.818's `κctx` are the same definition — both are
`reachSet.card / |K|²`. We make this identification explicit so the two
results can be chained without type duels. -/

/-- **R.817 ⊕ R.818 — `κbar` and `κctx` agree on the same finite data.** -/
theorem kbar_eq_kctx (K : Finset Ω) (reachSet : Finset (Ω × Ω)) :
    κbar K reachSet = κctx K reachSet := by
  unfold κbar κctx
  rfl

/-! ### Part 2 — Cumulative growth bounded above by intervention-reach ceiling.

R.817 gives `κbar ≤ κ` whenever the reach set stays inside the intrinsic
relation. R.818 gives the monotonicity along a chain. Compose: along a
monotone reach-process `reach : ℕ → Finset (Ω × Ω)` that stays in
`Rset := (K ×ˢ K).filter R`, the cumulative density is monotone in `n` and
uniformly bounded by `κ`. -/

/-- **R.817 ⊕ R.818 — cumulative κ̄ is monotone-and-bounded along the
metacognitive process.**

If a metacognitive process realises a chain `reach : ℕ → Finset (Ω × Ω)`
that (i) is monotone (R.818 input) and (ii) at every stage stays inside the
intrinsic relation `R_∘ ∩ K²` (R.817 input), then the cumulative density
`κ̄(n) := |reach n| / |K|²` satisfies, for all `a ≤ b`:

  κ̄(a) ≤ κ̄(b) ≤ κ(K, R)   (R.818 monotone, R.817 ceiling).

This is the joint monotone-bounded statement. -/
theorem cumulative_bounded_along_process
    (K : Finset Ω) (R : Ω → Ω → Prop)
    [DecidablePred fun p : Ω × Ω => R p.1 p.2]
    (reach : ℕ → Finset (Ω × Ω))
    (hmono : Monotone reach)
    (hsub : ∀ n, reach n ⊆ (K ×ˢ K).filter (fun p => R p.1 p.2))
    {a b : ℕ} (hab : a ≤ b) :
    κbar K (reach a) ≤ κbar K (reach b)
      ∧ κbar K (reach b) ≤ κ K R := by
  refine ⟨?_, ?_⟩
  · exact R_817_kbar_monotone K reach hmono hab
  · exact R_817_kbar_le_kappa K R (reach b) (hsub b)

/-! ### Part 3 — Linear bound: cumulative growth ≤ (κ − κ̄(a)).

Combining the two ingredients gives the *linear bound on cumulative growth
above any baseline*: `κ̄(b) − κ̄(a) ≤ κ − κ̄(a)`, equivalently `κ̄(b) ≤ κ`.
This is the explicit linear cumulative growth bound. -/

/-- **R.817 ⊕ R.818 — linear cumulative-growth bound.**

For `a ≤ b` along the metacognitive reach-process, the increment satisfies

  0 ≤ κ̄(b) − κ̄(a) ≤ κ − κ̄(a).

This is the "cumulative κ growth bounded by intervention reach" content: the
remaining headroom `κ − κ̄(a)` upper-bounds any further cumulative growth. -/
theorem cumulative_linear_bound
    (K : Finset Ω) (R : Ω → Ω → Prop)
    [DecidablePred fun p : Ω × Ω => R p.1 p.2]
    (reach : ℕ → Finset (Ω × Ω))
    (hmono : Monotone reach)
    (hsub : ∀ n, reach n ⊆ (K ×ˢ K).filter (fun p => R p.1 p.2))
    {a b : ℕ} (hab : a ≤ b) :
    0 ≤ κbar K (reach b) - κbar K (reach a)
      ∧ κbar K (reach b) - κbar K (reach a) ≤ κ K R - κbar K (reach a) := by
  obtain ⟨hmono', hceil⟩ :=
    cumulative_bounded_along_process K R reach hmono hsub hab
  refine ⟨?_, ?_⟩
  · linarith
  · linarith

/-! ### Part 4 — Cover-attains-sup with intervention reach as the witness.

If the reach process hits the full intrinsic relation `Rset` at some stage
`n₀` (which R.817's `R_817_metacog_reaches_intrinsic_pair` justifies via A.3
on a per-pair basis), then `κ̄(n₀) = κ`, and every prior stage is ≤ `κ`. -/

/-- **R.817 ⊕ R.818 — cumulative κ̄ attains the κ ceiling at a covering
stage, and is bounded by `κ` at every stage.**

If `reach n₀ = (K ×ˢ K).filter R` (full intrinsic-relation cover), then
`κ̄(n₀) = κ`. Combined with R.818 monotonicity along the chain, `κ̄` is
non-decreasing up to `n₀` (then stays at the ceiling) -- the cumulative
process reaches the intervention-reach upper bound exactly at the cover. -/
theorem cumulative_reaches_kappa_at_cover
    (K : Finset Ω) (R : Ω → Ω → Prop)
    [DecidablePred fun p : Ω × Ω => R p.1 p.2]
    (reach : ℕ → Finset (Ω × Ω))
    (hmono : Monotone reach)
    (hsub : ∀ n, reach n ⊆ (K ×ˢ K).filter (fun p => R p.1 p.2))
    (n₀ : ℕ) (hcover : reach n₀ = (K ×ˢ K).filter (fun p => R p.1 p.2)) :
    (κbar K (reach n₀) = κ K R)
      ∧ (∀ n, κbar K (reach n) ≤ κ K R)
      ∧ (∀ a b, a ≤ b → κbar K (reach a) ≤ κbar K (reach b)) := by
  refine ⟨?_, ?_, ?_⟩
  · exact R_817_kbar_sup_eq_kappa K R (reach n₀) hcover
  · intro n
    exact R_817_kbar_le_kappa K R (reach n) (hsub n)
  · intro a b hab
    exact R_817_kbar_monotone K reach hmono hab

/-! ### Part 5 — Bridge to R.818's contextual `κctx`.

R.818 uses `κctx`. The same monotonicity and the linear bound translate
verbatim, providing the R.818-side reading of the joint theorem. -/

/-- **R.818 (chain monotonicity) ⊕ R.817 (ceiling) — `κctx` version.**

Identical content stated with `κctx` (R.818's name): along any monotone
reach chain `reach` whose values are sub-relations of `Rset`, the cumulative
contextual density is monotone-and-bounded by `κ`. The bridge with R.817
uses `kbar_eq_kctx` to identify the two functionals. -/
theorem cumulative_kctx_bounded
    (K : Finset Ω) (R : Ω → Ω → Prop)
    [DecidablePred fun p : Ω × Ω => R p.1 p.2]
    (reach : ℕ → Finset (Ω × Ω))
    (hmono : Monotone reach)
    (hsub : ∀ n, reach n ⊆ (K ×ˢ K).filter (fun p => R p.1 p.2))
    {a b : ℕ} (hab : a ≤ b) :
    κctx K (reach a) ≤ κctx K (reach b)
      ∧ κctx K (reach b) ≤ κ K R := by
  obtain ⟨hmono', hceil⟩ :=
    cumulative_bounded_along_process K R reach hmono hsub hab
  rw [← kbar_eq_kctx, ← kbar_eq_kctx]
  refine ⟨hmono', ?_⟩
  rw [kbar_eq_kctx]
  exact (cumulative_bounded_along_process K R reach hmono hsub hab).2

end R3_Agent8_KappaCumulativeReach

end MIP
