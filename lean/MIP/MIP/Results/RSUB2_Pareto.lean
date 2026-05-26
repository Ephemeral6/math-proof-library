/-
Result R-SUB.2 — Subdomain Pareto frontier is the simplex face.

Reference: `workspace/subdomain_competition.md` §6.2 (A 无条件).

**Statement (geometric form).** Two subdomain-mass vectors `π, π' : Fin m → ℝ≥0`
both summing to 1 (R-SUB.1) and satisfying `π ≤ π'` pointwise must be equal:
you cannot Pareto-improve all subdomains simultaneously.  Geometrically, the
Pareto frontier of the simplex `Δ^{m-1}` is the simplex face itself — any
attempted `dπ_i > 0` forces `Σ_{j≠i} dπ_j < 0`.

**Proof.** Pure algebra: if `π i₀ < π' i₀` strictly somewhere, then
`Finset.sum_lt_sum` gives `Σπ < Σπ'`, contradicting the normalisation
`Σπ = Σπ' = 1` (R-SUB.1).
-/
import MIP.Results.RSUB1_Conservation

namespace MIP

open scoped BigOperators

/-- **Algebraic core (R-SUB.2 pointwise form).**

Two nonnegative mass functions on a finite type with equal totals and
pointwise dominance are equal. -/
theorem pareto_pointwise_eq
    {ι : Type} [Fintype ι] (f g : ι → NNReal)
    (h_sum : ∑ i, f i = ∑ i, g i)
    (h_dom : ∀ i, f i ≤ g i) :
    ∀ i, f i = g i := by
  intro i
  by_contra hne
  have h_lt : f i < g i := lt_of_le_of_ne (h_dom i) hne
  have h_sum_lt : ∑ j, f j < ∑ j, g j := by
    apply Finset.sum_lt_sum (fun j _ => h_dom j)
    exact ⟨i, Finset.mem_univ i, h_lt⟩
  exact (ne_of_lt h_sum_lt) h_sum

/-- **R-SUB.2 — Pareto frontier of the subdomain simplex.**

If two normalised subdomain-mass profiles `π, π' : Fin m → ℝ≥0` satisfy
`π ≤ π'` pointwise, they coincide.  Hence no proper Pareto improvement of
all subdomains is possible — increasing one `π_i` necessarily decreases
some `π_j`. -/
theorem R_SUB_2_pareto_simplex
    {m : ℕ} (π π' : Fin m → NNReal)
    (h_sum_π : ∑ i, π i = 1)
    (h_sum_π' : ∑ i, π' i = 1)
    (h_dom : ∀ i, π i ≤ π' i) :
    π = π' := by
  funext i
  exact pareto_pointwise_eq π π' (h_sum_π.trans h_sum_π'.symm) h_dom i

/-- **R-SUB.2 (partition form).**

Stated against a `SubdomainPartition` and two activation distributions on the
same finite universe.  If the second distribution's subdomain mass dominates
the first's on every part, they are equal as subdomain-mass functions. -/
theorem R_SUB_2_pareto_partition
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (P : SubdomainPartition Ω) (d d' : ActivationDist Ω)
    (h_dom : ∀ S ∈ P.parts, P.subdomainMass d S ≤ P.subdomainMass d' S) :
    ∀ S ∈ P.parts, P.subdomainMass d S = P.subdomainMass d' S := by
  -- Both subdomain-mass profiles sum to 1 by R-SUB.1.
  have h_sum_d : ∑ S ∈ P.parts, P.subdomainMass d S = 1 :=
    R_SUB_1_conservation_packaged d P
  have h_sum_d' : ∑ S ∈ P.parts, P.subdomainMass d' S = 1 :=
    R_SUB_1_conservation_packaged d' P
  intro S hS
  by_contra hne
  have h_lt : P.subdomainMass d S < P.subdomainMass d' S :=
    lt_of_le_of_ne (h_dom S hS) hne
  have h_sum_lt :
      ∑ T ∈ P.parts, P.subdomainMass d T
        < ∑ T ∈ P.parts, P.subdomainMass d' T :=
    Finset.sum_lt_sum h_dom ⟨S, hS, h_lt⟩
  have h_one_lt_one : (1 : NNReal) < 1 :=
    calc (1 : NNReal)
        = ∑ T ∈ P.parts, P.subdomainMass d T := h_sum_d.symm
      _ < ∑ T ∈ P.parts, P.subdomainMass d' T := h_sum_lt
      _ = 1 := h_sum_d'
  exact (lt_irrefl _) h_one_lt_one

end MIP
