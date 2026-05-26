/-
Result R-SUB.1 — Subdomain mass conservation (re-export).

Reference: `workspace/subdomain_competition.md` §4.1 / §6.1; the conservation
law `Σ π_i = 1` is the statement of theorem T.18.10, which is fully proved
in `MIP.Theorems.T18_10_Conservation`.

R-SUB.1 is the originating "result" form of T.18.10; this file simply
re-exports the packaged theorem under the R-SUB.1 name so downstream files
can cite either label.
-/
import MIP.Theorems.T18_10_Conservation

namespace MIP

open scoped BigOperators

/-- **R-SUB.1 — Subdomain mass conservation law.**

`Σ_i π_i(X) = 1` for any normalised activation distribution `p_X : Ω → ℝ≥0`
under a disjoint-exhaustive subdomain partition.  This is the result-level
restatement of `T18_10_conservation`; the proof is verbatim. -/
theorem R_SUB_1_conservation
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint :
      ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    ∑ S ∈ parts, ∑ ω ∈ S, p_X ω = 1 :=
  T18_10_conservation p_X h_norm parts h_disjoint h_cover

/-- **R-SUB.1 (packaged).** Same statement using `ActivationDist` and
`SubdomainPartition` structures. -/
theorem R_SUB_1_conservation_packaged
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
  T18_10_conservation_packaged d P

end MIP
