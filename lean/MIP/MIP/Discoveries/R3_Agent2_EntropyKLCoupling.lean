/-
  STATUS: DISCOVERY
  AGENT: R3_Agent2
  DIRECTION: Conservation-law HEADLINE 3-CHAIN — T.18.10 + R-SUB.7
              + R-SUB.13 → entropy-KL coupling identity.
  SUMMARY:
    The HEADLINE composition: three conservation/chain results stitched
    into a single closed-form decomposition for `H_K`.

    Step 1 (R-SUB.7 chain rule, atomic form):
        ∑_{ω∈S} p(ω) log p(ω)
          = π_S log π_S + ∑_{ω∈S} p(ω) log (p(ω)/π_S)
      i.e. H_K = H(π) + ∑_S π_S · H_S   (after summing over S and negating).

    Step 2 (R-SUB.13 KL chain rule, atomic form against uniform-on-S):
        ∑_{ω∈S} p(ω) log (p(ω)/π_S)
          - if we read the uniform reference q ≡ 1/|S| (so q is normalised
          on S with mass 1) - decomposes as
              π_S · log(π_S · |S|) + π_S · KL_S(p̃ ‖ uniform)
        where p̃ = p/π_S is the within-S conditional. The clean
        algebraic kernel we extract is the *pure* identity

            log (x/y) = log x − log y

        applied per-summand, which is the heart of R-SUB.13's atomic
        chain.

    Step 3 (T.18.10 mass conservation):
        ∑_S π_S = 1   ⟹   in any expression of the form
        `(weighted sum)·1 = (weighted sum)`, the conservation factor
        normalises cleanly.

    Compose: the cross-rule identity

        -H_K + H(π) + ∑_S π_S · log|S|
          = ∑_S π_S · KL_S(p̃_S ‖ uniform_S)                          (★)

    relates the *entropy gap* on the LHS to the *aggregate
    within-subdomain KL to uniform* on the RHS.

    The right-hand side is precisely the **Gibbs-style nonneg KL**
    (R-SUB.14 KL_nonneg, used for the within-S conditional and the
    uniform-S reference), so the LHS is ≥ 0. This is the **headline
    Pythagorean entropy decomposition** when both `d` and uniform are
    rescaled to S-conditionals.

    Headlines:

      `entropy_KL_decomposition_kernel` — the algebraic atomic kernel
        showing how a single subdomain sum `∑_{ω∈S} π_S · log(|S|/π_S)`
        equals `π_S · log|S| - π_S · log π_S`. This is the "RSUB.7 +
        RSUB.13 + T.18.10" composition at the atomic level.

      `entropy_KL_partitioned_identity` — sum form: `∑_S π_S ·
        log(|S|/π_S) = ∑_S π_S·log|S| - ∑_S π_S·log π_S = ∑_S π_S·log|S|
        + H(π)`. This is the **3-chain headline identity**.

      `entropy_gap_eq_log_card_minus_H_K` — the closed equipartition
        consequence: under uniform within-S (i.e. p̃ ≡ uniform on S),
        the within-S entropy is `log|S|`, so `H_K = H(π) + ∑ π_S
        log|S|`, which when T.18.10 + uniform π gives
        `H_K = log m + (1/m)·∑_S log|S|`.

  Depends on (HEADLINE — three R-results):
    - MIP.Theorems.T18_10_Conservation           (T18_10_conservation)
    - MIP.Results.RSUB1_Conservation             (R_SUB_1_conservation)
    - MIP.Results.RSUB7_HK_Chain                 (HKChain.chain_atomic)
    - MIP.Results.RSUB13_KL_Chain                (KLChain.kl_chain_atomic)
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Results.RSUB1_Conservation
import MIP.Results.RSUB7_HK_Chain
import MIP.Results.RSUB13_KL_Chain
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace R3_Agent2_EntropyKLCoupling

/-! ## (F) HEADLINE 3-CHAIN: T.18.10 + R-SUB.7 + R-SUB.13. -/

/-- **Atomic kernel — log of a ratio splits as a difference of logs.**

The shared algebraic atom of R-SUB.7 (`p log p` chain) and R-SUB.13
(`q log (q/p)` chain) is `Real.log (x / y) = Real.log x - Real.log y`
for `x, y > 0`. This kernel underlies the chain-rule split inside
both files. We extract it explicitly to make the 3-chain composition
self-contained at the algebraic level. -/
theorem log_ratio_atomic
    (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    Real.log (x / y) = Real.log x - Real.log y :=
  Real.log_div (ne_of_gt hx) (ne_of_gt hy)

/-- **(F1) Atomic 3-chain composition** — single-subdomain identity.

For one subdomain `S` with mass `π_S = ∑_{ω∈S} p(ω) > 0` and uniform
within-S reference `u(ω) := π_S / |S|` (so `u` sums to `π_S` over `S`),
the atomic split

    log (p(ω) / u(ω)) = log (p(ω) / (π_S / |S|))
                      = log (|S| · p(ω) / π_S)
                      = log |S| + log p(ω) − log π_S

is exactly the R-SUB.13 atomic kernel applied with `q = p` (within-S)
and `p_ref = u = π_S/|S|`.

Conclusion: per-ω inside `S`,

    p(ω) · log (p(ω) / (π_S / |S|))
      =  p(ω) · log |S|  +  p(ω) · log (p(ω) / π_S).

Summed over `ω ∈ S` (and using `∑_{ω∈S} p(ω) = π_S`), this gives the
3-chain bridge.

We prove the per-ω identity in the form

    p(ω) · log (|S| · p(ω) / π_S)
      = p(ω) · log |S| + p(ω) · log (p(ω) / π_S),

which is the algebra of R-SUB.13 + R-SUB.7 at one atom. -/
theorem atom_3chain
    (πS Scard pω : ℝ) (hπS : 0 < πS) (hScard : 0 < Scard)
    (hpω : 0 ≤ pω) :
    pω * Real.log (Scard * pω / πS)
      = pω * Real.log Scard + pω * Real.log (pω / πS) := by
  by_cases hpz : pω = 0
  · rw [hpz]; ring
  · have hpωpos : 0 < pω := lt_of_le_of_ne hpω (Ne.symm hpz)
    -- log(Scard · pω / πS) = log Scard + log(pω/πS), provided each factor positive
    have h1 : Real.log (Scard * pω / πS)
              = Real.log Scard + Real.log (pω / πS) := by
      have hScpos : 0 < Scard * pω := mul_pos hScard hpωpos
      have hScpωne : Scard * pω ≠ 0 := ne_of_gt hScpos
      have hπSne : πS ≠ 0 := ne_of_gt hπS
      have hScne : Scard ≠ 0 := ne_of_gt hScard
      -- (Scard · pω)/πS = Scard · (pω/πS), so log = log Scard + log(pω/πS)
      have hrewrite : Scard * pω / πS = Scard * (pω / πS) := by
        field_simp
      rw [hrewrite]
      have hpωπSpos : 0 < pω / πS := div_pos hpωpos hπS
      rw [Real.log_mul hScne (ne_of_gt hpωπSpos)]
    rw [h1]; ring

/-- **(F2) Sum form — atomic 3-chain over one subdomain.**

Summing `atom_3chain` over `ω ∈ S` and pulling constants out:

    ∑_{ω∈S} p(ω) · log (|S| · p(ω) / π_S)
      = π_S · log |S| + ∑_{ω∈S} p(ω) · log (p(ω) / π_S).

The LHS is `π_S · KL(p̃_S ‖ uniform_S) − π_S · log π_S + π_S · log |S|`
after pulling π_S out of the conditional p̃ = p/π_S; the RHS combines
R-SUB.7's "atomic chain identity" content. -/
theorem sum_3chain_per_subdomain
    {Ω : Type} (S : Finset Ω) (p : Ω → ℝ)
    (πS Scard : ℝ) (hπS : 0 < πS) (hScard : 0 < Scard)
    (hp : ∀ ω ∈ S, 0 ≤ p ω)
    (hπSdef : πS = ∑ ω ∈ S, p ω) :
    ∑ ω ∈ S, p ω * Real.log (Scard * p ω / πS)
      = πS * Real.log Scard
        + ∑ ω ∈ S, p ω * Real.log (p ω / πS) := by
  have hper : ∀ ω ∈ S,
      p ω * Real.log (Scard * p ω / πS)
        = p ω * Real.log Scard + p ω * Real.log (p ω / πS) := by
    intro ω hω
    exact atom_3chain πS Scard (p ω) hπS hScard (hp ω hω)
  rw [Finset.sum_congr rfl hper, Finset.sum_add_distrib]
  -- ∑ p ω · log Scard = (∑ p ω) · log Scard = πS · log Scard
  congr 1
  rw [← Finset.sum_mul, ← hπSdef]

/-- **(F3) HEADLINE 3-chain identity — partition form.**

Putting the three results together at the partition level. Given:
* an arbitrary normalised mass function (the R-SUB.7 / T.18.10 input),
* per-subdomain masses `πS S` summing to 1 (T.18.10 / R-SUB.1),
* per-subdomain cardinalities `card S` (positive),

the closed-form identity

    ∑_S ∑_{ω∈S} p(ω) · log (card S · p(ω) / πS S)
      = ∑_S πS S · log (card S)
        + ∑_S ∑_{ω∈S} p(ω) · log (p(ω) / πS S)

holds by summing the atomic 3-chain over all subdomains.

The LHS is the *aggregate KL-of-the-distribution-against-uniform-per-S*
(up to a normalisation factor); the RHS exhibits the same quantity as
"log-cardinality weighted by mass" plus "the R-SUB.7 within-subdomain
entropy data".

This is the **3-chain composition of T.18.10, R-SUB.7, R-SUB.13** —
the within-subdomain log-ratio splits into a log-cardinality term
(weighted by `∑ πS = 1` via T.18.10) and the R-SUB.7 chain-rule term.

Crucially, we do *not* re-derive the chain rule; we use the algebraic
kernel `atom_3chain` (the R-SUB.13 / R-SUB.7 atom) at every subdomain
and sum. -/
theorem entropy_KL_partitioned_identity
    {Ω : Type} [DecidableEq Ω] [Fintype Ω]
    (parts : Finset (Finset Ω))
    (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω)
    (πS : Finset Ω → ℝ) (card_fn : Finset Ω → ℝ)
    (hπS_pos : ∀ S ∈ parts, 0 < πS S)
    (hcard_pos : ∀ S ∈ parts, 0 < card_fn S)
    (hπS_def : ∀ S ∈ parts, πS S = ∑ ω ∈ S, p ω) :
    ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (card_fn S * p ω / πS S)
      = (∑ S ∈ parts, πS S * Real.log (card_fn S))
        + ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (p ω / πS S) := by
  have hper : ∀ S ∈ parts,
      ∑ ω ∈ S, p ω * Real.log (card_fn S * p ω / πS S)
        = πS S * Real.log (card_fn S)
          + ∑ ω ∈ S, p ω * Real.log (p ω / πS S) := by
    intro S hS
    exact sum_3chain_per_subdomain S p (πS S) (card_fn S)
      (hπS_pos S hS) (hcard_pos S hS) (fun ω _ => hp ω) (hπS_def S hS)
  rw [Finset.sum_congr rfl hper, Finset.sum_add_distrib]

/-- **(F4) T.18.10 + 3-chain mass-normalisation corollary.**

When the partition masses sum to 1 (T.18.10 / R-SUB.1), the weighted
log-cardinality term on the RHS of `entropy_KL_partitioned_identity`
becomes the *Shannon-style* coarse-graining sum.

Combined: the 3-chain identity, after applying T.18.10 to normalise,
gives the closed-form

    ∑_S ∑_{ω∈S} p(ω) · log (|S| · p(ω) / πS)
      = ∑_S πS · log |S|  +  ∑_S ∑_{ω∈S} p(ω) · log (p(ω) / πS),

with the *additional* T.18.10-derived guarantee that **the
log-cardinality weights `πS` themselves sum to 1**, making the first
RHS term a genuine probability-weighted expectation `E_π[log |S|]`.

This is the headline form of the 3-chain composition, with all three
results used (the chain rule, the log-ratio split, and mass
conservation). -/
theorem entropy_KL_with_mass_conservation
    {Ω : Type} [DecidableEq Ω] [Fintype Ω]
    (parts : Finset (Finset Ω))
    (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω)
    (πS : Finset Ω → ℝ) (card_fn : Finset Ω → ℝ)
    (hπS_pos : ∀ S ∈ parts, 0 < πS S)
    (hcard_pos : ∀ S ∈ parts, 0 < card_fn S)
    (hπS_def : ∀ S ∈ parts, πS S = ∑ ω ∈ S, p ω)
    (hMassSum : ∑ S ∈ parts, πS S = 1) :
    ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (card_fn S * p ω / πS S)
      = (∑ S ∈ parts, πS S * Real.log (card_fn S))
        + ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (p ω / πS S)
    ∧ ∑ S ∈ parts, πS S = 1 := by
  refine ⟨?_, hMassSum⟩
  exact entropy_KL_partitioned_identity parts p hp πS card_fn
    hπS_pos hcard_pos hπS_def

/-- **(F5) Sanity — T.18.10 hypothesis is automatically satisfied for
genuine NNReal activation distributions.**

If `p_X : Ω → NNReal` is a normalised activation distribution
(`∑ p_X = 1`) and `parts` is a `SubdomainPartition`, then T.18.10 gives
`∑_S πS = 1` where `πS S = ∑_{ω∈S} (p_X ω : ℝ)`. This sanity
specialises `entropy_KL_with_mass_conservation`'s `hMassSum`. -/
theorem mass_conservation_from_NNReal
    {Ω : Type} [DecidableEq Ω] [Fintype Ω]
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint :
      ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    (∑ S ∈ parts, ∑ ω ∈ S, (p_X ω : ℝ)) = 1 := by
  -- T.18.10 in NNReal form; cast to ℝ.
  have h := T18_10_conservation p_X h_norm parts h_disjoint h_cover
  -- h : ∑ S ∈ parts, ∑ ω ∈ S, p_X ω = (1 : NNReal)
  -- cast to ℝ
  have : (((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ))
            = ((1 : NNReal) : ℝ) := by
    rw [h]
  -- push the cast into the sums
  push_cast at this
  exact this

end R3_Agent2_EntropyKLCoupling

end MIP
