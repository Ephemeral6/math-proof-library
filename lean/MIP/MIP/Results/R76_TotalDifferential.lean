/-
Result R.76 (T.12) — Total-differential decomposition of `dN/dt`.

Reference: `proofs/derived/training_dynamics.md` R.76 (A, standard total
differential with smoothness assumed explicitly).

**Statement.** The 4D MIP phase space is `S = (|K|, Z⁻¹, H_K, κ)`.  When
the agent evolves along a smooth trajectory `S(t) = (x₁(t), …, x₄(t))`,
the time rate of change of the emergence cost `N(S)` obeys the total
differential

    dN/dt  =  Σ_i (∂N/∂x_i) · (dx_i/dt) .

**Pure-math content.** The total differential is *exactly* the chain
rule for a linear first-order model.  Take the local first-order model of
`N` around the trajectory point,

    N(S)  =  Σ_i c_i · x_i ,        c_i = ∂N/∂x_i  (constants) ,

(the total-differential / first-order approximation, with the partials
frozen as constants).  Then given component derivatives
`HasDerivAt x_i (x_i' t) t`, the chain rule gives

    HasDerivAt (fun t => Σ_i c_i · x_i t) (Σ_i c_i · x_i' t) t ,

which is the total-differential identity.  This file proves it via
`HasDerivAt.sum` and `HasDerivAt.const_mul`, stated over an arbitrary
finite index set and specialised to `Fin 4` (the MIP phase space).

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul

namespace MIP

namespace TotalDifferential

open scoped BigOperators

/-- **R.76 — total differential over a finite phase space (general form).**

Let `S = (x_i)_{i ∈ ι}` be the component paths of the trajectory, each
with derivative `HasDerivAt (x i) (x' i) t`.  With the linear local model
`N(S) = Σ_i c_i · x_i` (the first-order/total-differential approximation,
`c_i = ∂N/∂x_i` frozen as constants), the time derivative of `N` along
the trajectory is the total differential

    dN/dt  =  Σ_i c_i · x_i' t  =  Σ_i (∂N/∂x_i) · (dx_i/dt). -/
theorem R_76_total_differential
    {ι : Type*} (s : Finset ι)
    (c : ι → ℝ) (x x' : ι → ℝ → ℝ) (t : ℝ)
    (hx : ∀ i ∈ s, HasDerivAt (x i) (x' i t) t) :
    HasDerivAt (fun t => ∑ i ∈ s, c i * x i t)
      (∑ i ∈ s, c i * x' i t) t := by
  have h : HasDerivAt (∑ i ∈ s, fun t => c i * x i t)
      (∑ i ∈ s, c i * x' i t) t := by
    apply HasDerivAt.sum
    intro i hi
    exact (hx i hi).const_mul (c i)
  -- `∑ i ∈ s, (fun t => c i * x i t)` is the pointwise sum; rewrite to the
  -- `fun t => ∑ i ∈ s, c i * x i t` form via `Finset.sum_apply`.
  have h_eq : (∑ i ∈ s, fun t => c i * x i t) = (fun t => ∑ i ∈ s, c i * x i t) := by
    funext u
    rw [Finset.sum_apply]
  rwa [h_eq] at h

/-- **R.76 — total differential over the MIP 4D phase space `Fin 4`.**

Specialisation of `R_76_total_differential` to the concrete phase space
`S = (|K|, Z⁻¹, H_K, κ)` indexed by `Fin 4`.  The four partials
`c 0, …, c 3` are `∂N/∂|K|, ∂N/∂Z⁻¹, ∂N/∂H_K, ∂N/∂κ`, and the four
component derivatives `x' i t` are `d|K|/dt, dZ⁻¹/dt, dH_K/dt, dκ/dt`. -/
theorem R_76_total_differential_4D
    (c : Fin 4 → ℝ) (x x' : Fin 4 → ℝ → ℝ) (t : ℝ)
    (hx : ∀ i, HasDerivAt (x i) (x' i t) t) :
    HasDerivAt (fun t => ∑ i, c i * x i t)
      (∑ i, c i * x' i t) t :=
  R_76_total_differential Finset.univ c x x' t (fun i _ => hx i)

/-- **R.76 — explicit four-term expansion.**

The same identity written out as the four named MIP contributions:

    dN/dt  =  (∂N/∂|K|)·d|K|/dt + (∂N/∂Z⁻¹)·dZ⁻¹/dt
              + (∂N/∂H_K)·dH_K/dt + (∂N/∂κ)·dκ/dt .

Here `c0..c3` are the partials and `xK, xZ, xH, xκ` are the component
paths with derivatives `xK', xZ', xH', xκ'` at `t`. -/
theorem R_76_total_differential_expanded
    (c0 c1 c2 c3 : ℝ)
    (xK xZ xH xκ : ℝ → ℝ) (xK' xZ' xH' xκ' : ℝ) (t : ℝ)
    (hK : HasDerivAt xK xK' t) (hZ : HasDerivAt xZ xZ' t)
    (hH : HasDerivAt xH xH' t) (hκ : HasDerivAt xκ xκ' t) :
    HasDerivAt (fun t => c0 * xK t + c1 * xZ t + c2 * xH t + c3 * xκ t)
      (c0 * xK' + c1 * xZ' + c2 * xH' + c3 * xκ') t := by
  have h0 := hK.const_mul c0
  have h1 := hZ.const_mul c1
  have h2 := hH.const_mul c2
  have h3 := hκ.const_mul c3
  exact (((h0.add h1).add h2).add h3)

end TotalDifferential

end MIP
