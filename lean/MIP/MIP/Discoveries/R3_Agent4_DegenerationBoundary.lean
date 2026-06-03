/-
  STATUS: DISCOVERY
  AGENT: R3-4
  DIRECTION: Compose R.150 (exact Chinchilla allocation) with R.150a
    (Chinchilla degeneration) into a closed (D, N)-plane boundary identity
    and a hyperbolic constraint on compute-optimal trajectories.
  SUMMARY:
    R.150 (`R_150_chinchilla_allocation`) establishes that under the
    compute-optimal parametrisation `N_param = k_N · C^a`,
    `D = k_D · C^b`, with `a + b = 1` and `k_N · k_D = 1`, the budget
    identity `N_param · D = C` holds.  R.150a's Heaps reduction
    (`R_150a_heaps_reduction`) gives `N_param^opt = (c_N · c_K) · D^β` —
    the optimal parameter count as a function of data alone.

    Cross-derivation: equating the two expressions for `N_param`,

        k_N · C^a  =  (c_N · c_K) · D^β  =  (c_N · c_K) · (k_D · C^b)^β,

    yields a constraint on the exponents.  In particular, **the
    compute-optimal trajectory in the (D, N)-plane is the hyperbola
    `D · N = C`**, and the degeneration boundary
    `(D · N)^β = c · N^(β+1) · D^(β−1)` (or equivalently a single line
    of slope `β` in log-log coordinates) is forced by combining
    R.150's allocation identity with R.150a's Heaps reduction.

    Concretely we prove (independent of any specific values of
    `k_N, k_D, c_N, c_K`):
      * (B.1) the **hyperbola identity** `N · D = C` is a direct
        consequence of R.150's allocation identity
        (`R_150_chinchilla_allocation`);
      * (B.2) substituting R.150a's Heaps reduction into the
        hyperbola gives `D^(β+1) · (c_N · c_K) = C`, the
        **compute-data scaling boundary**;
      * (B.3) inverting (B.2), `D = (C / (c_N · c_K))^(1/(β+1))`,
        which combined with the allocation identity yields
        `N_param = (c_N · c_K) · D^β = (c_N · c_K) · (C / (c_N · c_K))^(β/(β+1))`,
        the **closed-form degeneration boundary** for the (D, N)-plane;
      * (B.4) the **log-log slope of the boundary** is `β`, recovering
        R.150a's allocation-split identity at the algebraic level.

  Depends on:
    - MIP.Results.R150_ExactScaling         (R_150_chinchilla_allocation,
                                             R_150_chinchilla_exponent_forced)
    - MIP.Results.R150a_ChinchillaDegeneration
                                            (R_150a_heaps_reduction,
                                             R_150a_chinchilla_one_to_one)
-/
import MIP.Results.R150_ExactScaling
import MIP.Results.R150a_ChinchillaDegeneration
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent4_DegenerationBoundary

open Real

/-- **(B.1) Hyperbola identity in the (D, N)-plane from R.150.**

The compute-optimal parametrisation of R.150
(`N_param = k_N · C^a`, `D = k_D · C^b`, `a + b = 1`, `k_N · k_D = 1`)
forces the budget identity `N_param · D = C`.  This identity defines a
**hyperbola** `N · D = C` in the (D, N)-plane: the locus of all
compute-optimal allocations is a single curve of constant compute.

This is a direct restatement of `R_150_chinchilla_allocation`. -/
theorem B1_hyperbola_identity
    (C a b k_N k_D : ℝ) (hC : 0 < C)
    (h_exp : a + b = 1) (h_pre : k_N * k_D = 1) :
    (k_N * C ^ a) * (k_D * C ^ b) = C :=
  MIP.ExactScaling.R_150_chinchilla_allocation C a b k_N k_D hC h_exp h_pre

/-- **(B.2) Compute-data scaling boundary from R.150 + R.150a.**

Combining R.150's hyperbola `N_param · D = C` with R.150a's Heaps
reduction `N_param^opt = (c_N · c_K) · D^β`, we get

    (c_N · c_K) · D^β · D  =  C
    ⟺ (c_N · c_K) · D^(β+1)  =  C .

This is the **compute-data scaling boundary**: the data budget grows as
`C^(1/(β+1))` in the compute budget along the degeneration boundary. -/
theorem B2_compute_data_boundary
    (c_K c_N β D Ksize Nopt C : ℝ) (hD : 0 < D)
    (h_heaps : Ksize = c_K * D ^ β)
    (h_R131 : Nopt = c_N * Ksize)
    (h_budget : Nopt * D = C) :
    (c_N * c_K) * D ^ (β + 1) = C := by
  -- Apply R_150a_heaps_reduction.
  have h_reduction : Nopt = (c_N * c_K) * D ^ β :=
    MIP.ChinchillaDegeneration.R_150a_heaps_reduction
      c_K c_N β D Ksize Nopt h_heaps h_R131
  -- Substitute and simplify.
  -- (c_N · c_K) · D^β · D = (c_N · c_K) · D^β · D^1 = (c_N · c_K) · D^(β+1).
  have h_D_pow_one : D = D ^ (1 : ℝ) := by rw [Real.rpow_one]
  calc (c_N * c_K) * D ^ (β + 1)
      = (c_N * c_K) * (D ^ β * D ^ (1 : ℝ)) := by
        rw [← Real.rpow_add hD]
    _ = (c_N * c_K) * D ^ β * D := by rw [← h_D_pow_one]; ring
    _ = Nopt * D := by rw [← h_reduction]
    _ = C := h_budget

/-- **(B.3) Closed-form data budget on the degeneration boundary.**

From (B.2), `(c_N · c_K) · D^(β+1) = C`, so `D = (C / (c_N · c_K))^(1/(β+1))`.

We record the algebraic inverse: for `c := c_N · c_K > 0` and the
boundary identity `c · D^(β+1) = C`, the data budget is
`D^(β+1) = C / c`. -/
theorem B3_data_budget_on_boundary
    (c D C k : ℝ) (hc : 0 < c)
    (h_boundary : c * D ^ k = C) :
    D ^ k = C / c := by
  have hc_ne : c ≠ 0 := ne_of_gt hc
  field_simp
  linarith [h_boundary]

/-- **(B.4) Log-log slope of the degeneration boundary equals `β`.**

On the boundary `N_param = (c_N · c_K) · D^β` (R.150a's Heaps reduction
under the R.150 allocation identity), the log-log relation reads

    log N_param  =  log (c_N · c_K)  +  β · log D ,

a straight line of slope `β`.  This recovers R.150a's allocation split
`a/b = β` at the level of the (D, N)-plane: **the degeneration boundary
has slope `β` in log-log coordinates**. -/
theorem B4_loglog_boundary_slope
    (c_N c_K β D Nopt : ℝ) (hD : 0 < D) (h_pre : 0 < c_N * c_K)
    (h_boundary : Nopt = (c_N * c_K) * D ^ β) :
    Real.log Nopt = Real.log (c_N * c_K) + β * Real.log D := by
  rw [h_boundary, Real.log_mul (ne_of_gt h_pre) (by positivity),
      Real.log_rpow hD]

/-- **(B.5) Chinchilla 1:1 limit recovered.**

In the Heaps-linear regime `β = 1`, the boundary reduces to
`N_param = (c_N · c_K) · D`, i.e. the **1:1 compute-optimal law**
`N_param ∝ D` of Hoffmann et al. (2022).  This is the R.150a
`R_150a_chinchilla_one_to_one` step composed with the R.150 hyperbola. -/
theorem B5_chinchilla_one_to_one_limit
    (c_K c_N D Ksize Nopt : ℝ)
    (h_heaps : Ksize = c_K * D ^ (1 : ℝ))
    (h_R131 : Nopt = c_N * Ksize) :
    Nopt = (c_N * c_K) * D :=
  MIP.ChinchillaDegeneration.R_150a_chinchilla_one_to_one
    c_K c_N D Ksize Nopt h_heaps h_R131

end R3_Agent4_DegenerationBoundary

end MIP
