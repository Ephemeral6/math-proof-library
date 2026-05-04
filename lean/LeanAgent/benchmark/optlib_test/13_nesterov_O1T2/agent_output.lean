import LeanAgent.Generated.prox_iff_subderiv
import LeanAgent.Generated.convex_first_order_condition_prime
import LeanAgent.Generated.descent_lemma_v3
import Mathlib.Analysis.Convex.Function
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic

namespace LeanAgent.Generated

open Set InnerProductSpace

/-! Item 13 — `Nesterov_first_converge`.

O(1/T²) convergence of Nesterov accelerated proximal gradient. Proof uses an
explicit auxiliary "extrapolated" sequence `zSeq` and a Lyapunov potential
`W k = (t_k / γ_k²)(φ(x_{k+1}) - φ(xm)) + (1/2) ‖z_{k+1} - xm‖²`.

Key identities:
  • `xkk1_eq_combine`: `x (k+1) = (1-γ_k) • x_k + γ_k • z_{k+1}` (def of z).
  • `y_eq_combine`:    `y_k = (1-γ_k) • x_k + γ_k • z_k` (oriy/oriγ at k=0; update1 at k≥1).

Per-step lemma (`per_step_ineq`):
  `(t_k/γ_k²)(φ(x_{k+1}) - φ(xm)) + (1/2)‖z_{k+1} - xm‖²
   ≤ ((1-γ_k)t_k/γ_k²)(φ(x_k) - φ(xm)) + (1/2)‖z_k - xm‖²`

Cross-file Tier-3 reuse: imports #03 (descent), #06 (convex FOC), #08 (prox-iff-subderiv).
-/

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

class Nesterov_first (f h : E → ℝ) (f' : E → E) (x0 : E) where
  l : NNReal
  x : ℕ → E
  y : ℕ → E
  t : ℕ → ℝ
  γ : ℕ → ℝ
  hl : (l : ℝ) > 0
  h₁ : ∀ x : E, HasGradientAt f (f' x) x
  convf : ConvexOn ℝ univ f
  h₂ : LipschitzWith l f'
  convh : ConvexOn ℝ univ h
  oriy : y 0 = x 0
  oriγ : γ 0 = 1
  initial : x 0 = x0
  cond : ∀ n : ℕ+, (1 - γ n) * t n / γ n ^ 2 ≤ t (n - 1) / γ (n - 1) ^ 2
  tbound : ∀ k : ℕ, 0 < t k ∧ t k ≤ 1 / l
  γbound : ∀ n : ℕ, 0 < γ n ∧ γ n ≤ 1
  update1 : ∀ k : ℕ+, y k = x k + (γ k * (1 - γ (k - 1)) / γ (k - 1)) • (x k - x (k - 1))
  update2 : ∀ k : ℕ, prox_prop (t k • h) (y k - t k • f' (y k)) (x (k + 1))

variable {f h : E → ℝ} {f' : E → E} {x0 : E}
variable {alg : Nesterov_first f h f' x0}
variable {xm : E}

/-- Auxiliary "extrapolated" sequence `z_k`:
    `z 0 = x 0`, `z (k+1) = x k + (1 / γ k) • (x (k+1) - x k)`. -/
private noncomputable def zSeq (alg : Nesterov_first f h f' x0) : ℕ → E
  | 0 => alg.x 0
  | n + 1 => alg.x n + (1 / alg.γ n) • (alg.x (n + 1) - alg.x n)

/-- Per-step three-point inequality at the extrapolated `y_k`. -/
private lemma phi_three_point_y (k : ℕ) (z : E) :
    f (alg.x (k + 1)) + h (alg.x (k + 1)) ≤ f z + h z
      + (1 / alg.t k) * inner ℝ (alg.y k - alg.x (k + 1)) (alg.x (k + 1) - z)
      + (1 / (2 * alg.t k)) * ‖alg.x (k + 1) - alg.y k‖ ^ 2 := by
  set yk := alg.y k with hyk
  set xk1 := alg.x (k + 1) with hxk1
  obtain ⟨htpos, htle⟩ := alg.tbound k
  have hLpos : (0 : ℝ) < (alg.l : ℝ) := alg.hl
  have hdesc := descent_lemma_gradient_form alg.h₁ alg.h₂ yk xk1
  have h_L_le_inv_t : (alg.l : ℝ) ≤ 1 / alg.t k := by
    rw [le_div_iff₀ htpos]
    have := htle
    rw [le_div_iff₀ hLpos] at this; linarith
  have h_norm_sq_nn : 0 ≤ ‖xk1 - yk‖ ^ 2 := sq_nonneg _
  have hLhalf : (alg.l : ℝ) / 2 ≤ 1 / (2 * alg.t k) := by
    have h_inv_eq : (1 : ℝ) / (2 * alg.t k) = (1 / alg.t k) / 2 := by field_simp
    rw [h_inv_eq]; linarith
  have hdesc' : f xk1 ≤ f yk + inner ℝ (f' yk) (xk1 - yk)
      + (1 / (2 * alg.t k)) * ‖xk1 - yk‖ ^ 2 := by
    have hmul := mul_le_mul_of_nonneg_right hLhalf h_norm_sq_nn
    linarith [hdesc, hmul]
  have hcvx_f := Convex_first_order_condition_prime
    (h := alg.h₁ yk) alg.convf (mem_univ yk) z (mem_univ z)
  have hth_conv : ConvexOn ℝ univ (alg.t k • h) := alg.convh.smul (le_of_lt htpos)
  have hupdate : prox_prop (alg.t k • h) (yk - alg.t k • f' yk) xk1 := alg.update2 k
  rw [prox_iff_subderiv (alg.t k • h) hth_conv xk1] at hupdate
  have hsub_z : (alg.t k • h) xk1 + inner ℝ ((yk - alg.t k • f' yk) - xk1) (z - xk1) ≤
      (alg.t k • h) z := hupdate z
  simp only [Pi.smul_apply, smul_eq_mul] at hsub_z
  have h_inner_split :
      inner ℝ ((yk - alg.t k • f' yk) - xk1) (z - xk1)
        = inner ℝ (yk - xk1) (z - xk1) - alg.t k * inner ℝ (f' yk) (z - xk1) := by
    have hrw : (yk - alg.t k • f' yk) - xk1 = (yk - xk1) - alg.t k • f' yk := by abel
    rw [hrw, inner_sub_left, real_inner_smul_left]
  rw [h_inner_split] at hsub_z
  have h_step_h : h xk1 + (1 / alg.t k) * inner ℝ (yk - xk1) (z - xk1)
      ≤ h z + inner ℝ (f' yk) (z - xk1) := by
    have ht_ne : alg.t k ≠ 0 := ne_of_gt htpos
    have hmul_le : alg.t k * (h xk1 + (1 / alg.t k) * inner ℝ (yk - xk1) (z - xk1))
        ≤ alg.t k * (h z + inner ℝ (f' yk) (z - xk1)) := by
      have hl_eq : alg.t k * (h xk1 + (1 / alg.t k) * inner ℝ (yk - xk1) (z - xk1))
          = alg.t k * h xk1 + inner ℝ (yk - xk1) (z - xk1) := by field_simp
      have hr_eq : alg.t k * (h z + inner ℝ (f' yk) (z - xk1))
          = alg.t k * h z + alg.t k * inner ℝ (f' yk) (z - xk1) := by ring
      rw [hl_eq, hr_eq]; linarith [hsub_z]
    exact le_of_mul_le_mul_left hmul_le htpos
  have h_inner_zero :
      inner ℝ (f' yk) (xk1 - yk) - inner ℝ (f' yk) (z - yk)
        + inner ℝ (f' yk) (z - xk1) = 0 := by
    have h1 : inner ℝ (f' yk) (xk1 - yk) - inner ℝ (f' yk) (z - yk)
        + inner ℝ (f' yk) (z - xk1)
        = inner ℝ (f' yk) ((xk1 - yk) - (z - yk) + (z - xk1)) := by
      rw [← inner_sub_right, ← inner_add_right]
    have hzero : (xk1 - yk) - (z - yk) + (z - xk1) = (0 : E) := by abel
    rw [h1, hzero, inner_zero_right]
  have h_inner_flip : inner ℝ (yk - xk1) (xk1 - z) = - inner ℝ (yk - xk1) (z - xk1) := by
    rw [show (xk1 - z : E) = -(z - xk1) from by abel, inner_neg_right]
  have h_inner_flip_t :
      (1 / alg.t k) * inner ℝ (yk - xk1) (xk1 - z)
        = -(1 / alg.t k) * inner ℝ (yk - xk1) (z - xk1) := by
    rw [h_inner_flip]; ring
  linarith [hdesc', hcvx_f, h_step_h, h_inner_zero, h_inner_flip_t]

/-- `x (k+1) = (1 - γ_k) • x_k + γ_k • z_{k+1}` (immediate from def of `zSeq`). -/
private lemma xkk1_eq_combine (k : ℕ) :
    alg.x (k + 1) = (1 - alg.γ k) • alg.x k + alg.γ k • zSeq alg (k + 1) := by
  have hγ_pos : (0 : ℝ) < alg.γ k := (alg.γbound k).1
  have hγ_ne : alg.γ k ≠ 0 := ne_of_gt hγ_pos
  show alg.x (k + 1) = (1 - alg.γ k) • alg.x k
      + alg.γ k • (alg.x k + (1 / alg.γ k) • (alg.x (k + 1) - alg.x k))
  rw [smul_add, smul_smul, mul_one_div, div_self hγ_ne, one_smul]
  rw [sub_smul, one_smul]
  abel

/-- `update1` reformulated with ℕ index: for `n : ℕ`,
    `y (n + 1) = x (n + 1) + (γ (n + 1) * (1 - γ n) / γ n) • (x (n + 1) - x n)`. -/
private lemma update1_nat (n : ℕ) :
    alg.y (n + 1) = alg.x (n + 1)
      + (alg.γ (n + 1) * (1 - alg.γ n) / alg.γ n) • (alg.x (n + 1) - alg.x n) :=
  alg.update1 ⟨n + 1, n.succ_pos⟩

/-- `cond` reformulated with ℕ index: for `n : ℕ`,
    `(1 - γ (n + 1)) * t (n + 1) / γ (n + 1) ^ 2 ≤ t n / γ n ^ 2`. -/
private lemma cond_nat (n : ℕ) :
    (1 - alg.γ (n + 1)) * alg.t (n + 1) / alg.γ (n + 1) ^ 2
      ≤ alg.t n / alg.γ n ^ 2 :=
  alg.cond ⟨n + 1, n.succ_pos⟩

/-- `y_k = (1 - γ_k) • x_k + γ_k • z_k` for all `k ≥ 0`. -/
private lemma y_eq_combine (k : ℕ) :
    alg.y k = (1 - alg.γ k) • alg.x k + alg.γ k • zSeq alg k := by
  cases k with
  | zero =>
    show alg.y 0 = (1 - alg.γ 0) • alg.x 0 + alg.γ 0 • alg.x 0
    rw [alg.oriy, alg.oriγ, sub_self, zero_smul, zero_add, one_smul]
  | succ n =>
    have hupd := update1_nat (alg := alg) n
    have hγn_pos : (0 : ℝ) < alg.γ n := (alg.γbound n).1
    have hγn_ne : alg.γ n ≠ 0 := ne_of_gt hγn_pos
    show alg.y (n + 1) = (1 - alg.γ (n + 1)) • alg.x (n + 1)
        + alg.γ (n + 1) • (alg.x n + (1 / alg.γ n) • (alg.x (n + 1) - alg.x n))
    rw [hupd]
    -- Both sides are linear combinations of x (n+1) and x n with real coefficients.
    -- Reduce to a vector identity by matching scalars on each basis vector.
    match_scalars
    · field_simp; ring
    · field_simp; ring

/-- Convexity of `f + h` at the convex combination of `x_k` and `xm`. -/
private lemma phi_convex_combine (k : ℕ) (xm : E) :
    f ((1 - alg.γ k) • alg.x k + alg.γ k • xm)
      + h ((1 - alg.γ k) • alg.x k + alg.γ k • xm)
    ≤ (1 - alg.γ k) * (f (alg.x k) + h (alg.x k))
      + alg.γ k * (f xm + h xm) := by
  have hγ_pos := (alg.γbound k).1
  have hγ_le := (alg.γbound k).2
  have h_one_sub_nn : (0 : ℝ) ≤ 1 - alg.γ k := by linarith
  have h_γ_nn : (0 : ℝ) ≤ alg.γ k := le_of_lt hγ_pos
  have h_sum : (1 - alg.γ k) + alg.γ k = 1 := by ring
  have hf := alg.convf.2 (mem_univ (alg.x k)) (mem_univ xm)
    h_one_sub_nn h_γ_nn h_sum
  have hh := alg.convh.2 (mem_univ (alg.x k)) (mem_univ xm)
    h_one_sub_nn h_γ_nn h_sum
  -- hf, hh : f/h ((1-γ) • x_k + γ • xm) ≤ (1-γ) • f/h(x_k) + γ • f/h(xm)
  simp only [smul_eq_mul] at hf hh
  linarith

/-- Per-step Lyapunov inequality:
    `(t_k/γ_k²)(φ(x_{k+1}) - φ(xm)) + (1/2)‖z_{k+1} - xm‖²
     ≤ ((1-γ_k) t_k/γ_k²)(φ(x_k) - φ(xm)) + (1/2)‖z_k - xm‖²` -/
private lemma per_step_ineq (k : ℕ) :
    (alg.t k / alg.γ k ^ 2) * (f (alg.x (k + 1)) + h (alg.x (k + 1)) - f xm - h xm)
      + (1 / 2) * ‖zSeq alg (k + 1) - xm‖ ^ 2
    ≤ ((1 - alg.γ k) * alg.t k / alg.γ k ^ 2) * (f (alg.x k) + h (alg.x k) - f xm - h xm)
      + (1 / 2) * ‖zSeq alg k - xm‖ ^ 2 := by
  set xk := alg.x k with hxk
  set xk1 := alg.x (k + 1) with hxk1
  set yk := alg.y k with hyk
  set zk := zSeq alg k with hzk
  set zk1 := zSeq alg (k + 1) with hzk1
  set γk := alg.γ k with hγk
  set tk := alg.t k with htk
  -- Convex combination z' = (1-γ_k) • x_k + γ_k • xm.
  set zComb := (1 - γk) • xk + γk • xm with hzComb_def
  have hγ_pos : (0 : ℝ) < γk := (alg.γbound k).1
  have hγ_ne : γk ≠ 0 := ne_of_gt hγ_pos
  have hγ_sq_pos : (0 : ℝ) < γk ^ 2 := by positivity
  have htpos : (0 : ℝ) < tk := (alg.tbound k).1
  -- Step (a): apply phi_three_point_y at z = zComb.
  have h_three := phi_three_point_y (alg := alg) k zComb
  -- Step (b): convexity of φ at zComb.
  have h_convex := phi_convex_combine (alg := alg) (xm := xm) k
  rw [show (1 - γk) • xk + γk • xm = zComb from rfl] at h_convex
  -- Step (c): combine — get inequality with (1-γ)φ(x_k) + γ φ(xm).
  have h_step1 : f xk1 + h xk1 - f xm - h xm
      ≤ (1 - γk) * (f xk + h xk - f xm - h xm)
        + (1 / tk) * inner ℝ (yk - xk1) (xk1 - zComb)
        + (1 / (2 * tk)) * ‖xk1 - yk‖ ^ 2 := by
    have hsum : (1 - γk) + γk = 1 := by ring
    have h_combine : (1 - γk) * (f xk + h xk) + γk * (f xm + h xm)
        - (f xm + h xm) = (1 - γk) * (f xk + h xk - f xm - h xm) := by ring
    linarith [h_three, h_convex, h_combine]
  -- Step (d): use the algebra y_k - x_{k+1} = γ_k (z_k - z_{k+1}).
  have h_yk_xk1 : yk - xk1 = γk • (zk - zk1) := by
    have h1 : yk = (1 - γk) • xk + γk • zk := y_eq_combine (alg := alg) k
    have h2 : xk1 = (1 - γk) • xk + γk • zk1 := xkk1_eq_combine (alg := alg) k
    rw [h1, h2]
    rw [smul_sub]; abel
  -- Step (e): x_{k+1} - zComb = γ_k (z_{k+1} - xm).
  have h_xk1_zComb : xk1 - zComb = γk • (zk1 - xm) := by
    have h2 : xk1 = (1 - γk) • xk + γk • zk1 := xkk1_eq_combine (alg := alg) k
    rw [h2]
    show (1 - γk) • xk + γk • zk1 - ((1 - γk) • xk + γk • xm) = γk • (zk1 - xm)
    rw [smul_sub]; abel
  -- Step (f): rewrite the inner product and norm-sq via these identities.
  have h_inner_eq : inner ℝ (yk - xk1) (xk1 - zComb) = γk ^ 2 * inner ℝ (zk - zk1) (zk1 - xm) := by
    rw [h_yk_xk1, h_xk1_zComb, real_inner_smul_left, real_inner_smul_right]; ring
  have h_norm_sq_eq : ‖xk1 - yk‖ ^ 2 = γk ^ 2 * ‖zk - zk1‖ ^ 2 := by
    have h_swap : xk1 - yk = γk • (zk1 - zk) := by
      rw [show (zk1 - zk : E) = -(zk - zk1) from by abel, smul_neg, ← h_yk_xk1]; abel
    rw [h_swap, norm_smul, mul_pow, Real.norm_eq_abs, sq_abs]
    rw [show (zk1 - zk : E) = -(zk - zk1) from by abel, norm_neg]
  rw [h_inner_eq, h_norm_sq_eq] at h_step1
  -- Step (g): polarization identity for ⟨zk - zk1, zk1 - xm⟩.
  have h_polar : 2 * inner ℝ (zk - zk1) (zk1 - xm)
      = ‖zk - xm‖ ^ 2 - ‖zk - zk1‖ ^ 2 - ‖zk1 - xm‖ ^ 2 := by
    have hsum_eq : (zk - zk1) + (zk1 - xm) = zk - xm := by abel
    have hexp := norm_add_sq_real (zk - zk1) (zk1 - xm)
    rw [hsum_eq] at hexp
    linarith
  have h_inner_polar : inner ℝ (zk - zk1) (zk1 - xm)
      = (1 / 2) * (‖zk - xm‖ ^ 2 - ‖zk - zk1‖ ^ 2 - ‖zk1 - xm‖ ^ 2) := by linarith
  -- Step (h): substitute polarization into h_step1 and simplify the RHS.
  -- After all substitutions the RHS becomes:
  --   (1-γ)(φ(x_k) - φ(xm)) + (1/(2 t)) γ² ‖.‖² + (γ²/t)·(1/2)(‖zk-xm‖² - ‖zk-zk1‖² - ‖zk1-xm‖²)
  -- Multiply by t/γ² then close.
  -- Let's compute: (1/t) * γ² * inner = (γ²/t)*(1/2)(‖zk-xm‖² - ‖zk-zk1‖² - ‖zk1-xm‖²)
  --                (1/(2t)) * γ² * ‖.‖² = (γ²/(2t)) ‖zk-zk1‖²
  -- Sum: (γ²/(2t)) (‖zk-xm‖² - ‖zk1-xm‖²)
  -- So:  φ(x_{k+1}) - φ(xm) ≤ (1-γ)(φ(x_k) - φ(xm)) + (γ²/(2t))(‖zk-xm‖² - ‖zk1-xm‖²)
  -- Multiply by t/γ²:
  --     (t/γ²)(φ(x_{k+1}) - φ(xm)) ≤ ((1-γ)t/γ²)(φ(x_k) - φ(xm)) + (1/2)(‖zk-xm‖² - ‖zk1-xm‖²)
  rw [h_inner_polar] at h_step1
  -- Now h_step1 is:
  --   φ(xk1) - φ(xm) ≤ (1-γ)(φ(xk) - φ(xm))
  --                    + (1/t) * γ² * (1/2)(‖zk-xm‖² - ‖zk-zk1‖² - ‖zk1-xm‖²)
  --                    + (1/(2t)) * γ² * ‖zk-zk1‖²
  -- Goal:  (t/γ²)(φ(xk1) - φ(xm)) + (1/2)‖zk1-xm‖² ≤ ((1-γ)t/γ²)(φ(xk) - φ(xm)) + (1/2)‖zk-xm‖²
  -- Multiply h_step1 by t/γ² (positive).
  have h_t_div_γsq_pos : (0 : ℝ) < tk / γk ^ 2 := by positivity
  have h_step1_scaled := mul_le_mul_of_nonneg_left h_step1 (le_of_lt h_t_div_γsq_pos)
  -- Compute RHS of h_step1_scaled.
  have h_simplify :
      (tk / γk ^ 2) * ((1 - γk) * (f xk + h xk - f xm - h xm)
        + 1 / tk * (γk ^ 2 * (1 / 2 *
            (‖zk - xm‖ ^ 2 - ‖zk - zk1‖ ^ 2 - ‖zk1 - xm‖ ^ 2)))
        + 1 / (2 * tk) * (γk ^ 2 * ‖zk - zk1‖ ^ 2))
      = ((1 - γk) * tk / γk ^ 2) * (f xk + h xk - f xm - h xm)
        + (1 / 2) * (‖zk - xm‖ ^ 2 - ‖zk1 - xm‖ ^ 2) := by
    have ht_ne : tk ≠ 0 := ne_of_gt htpos
    have hγsq_ne : γk ^ 2 ≠ 0 := ne_of_gt hγ_sq_pos
    field_simp
    ring
  -- Compute LHS of h_step1_scaled.
  have h_lhs_eq :
      (tk / γk ^ 2) * (f xk1 + h xk1 - f xm - h xm)
        = (tk / γk ^ 2) * (f xk1 + h xk1 - f xm - h xm) := rfl
  rw [h_simplify] at h_step1_scaled
  -- h_step1_scaled : (t/γ²)(φ(xk1) - φ(xm)) ≤ ((1-γ)t/γ²)(φ(xk) - φ(xm)) + (1/2)(‖zk-xm‖² - ‖zk1-xm‖²)
  linarith [h_step1_scaled]

/-- The Lyapunov potential `W k = (t_k/γ_k²)(φ(x_{k+1}) - φ(xm)) + (1/2)‖z_{k+1} - xm‖²`
    is bounded above by `(1/2)‖x_0 - xm‖²` for all `k`. -/
private lemma W_bound (minφ : IsMinOn (f + h) univ xm) (k : ℕ) :
    (alg.t k / alg.γ k ^ 2) * (f (alg.x (k + 1)) + h (alg.x (k + 1)) - f xm - h xm)
      + (1 / 2) * ‖zSeq alg (k + 1) - xm‖ ^ 2
    ≤ (1 / 2) * ‖x0 - xm‖ ^ 2 := by
  induction k with
  | zero =>
    -- Base case: k = 0. With γ 0 = 1 and z 0 = x 0 = x0, per_step_ineq collapses.
    have hps := per_step_ineq (alg := alg) (xm := xm) 0
    rw [alg.oriγ] at hps
    have h_zero_term : (1 - (1 : ℝ)) * alg.t 0 / (1 : ℝ) ^ 2 = 0 := by ring
    rw [h_zero_term, zero_mul] at hps
    have hz0 : zSeq alg 0 = alg.x 0 := rfl
    rw [hz0, alg.initial] at hps
    -- Goal still has `alg.γ 0 ^ 2`; rewrite via `oriγ` directly on the goal.
    rw [show alg.γ 0 ^ 2 = (1 : ℝ) from by rw [alg.oriγ]; ring]
    linarith
  | succ n ih =>
    -- Inductive step: W (n+1) ≤ W n ≤ (1/2)‖x_0 - xm‖².
    have hps := per_step_ineq (alg := alg) (xm := xm) (n + 1)
    have hcond := cond_nat (alg := alg) n
    -- φ(x_{n+1}) - φ(xm) ≥ 0
    have h_min := minφ (mem_univ (alg.x (n + 1)))
    have h_φ_nn : 0 ≤ f (alg.x (n + 1)) + h (alg.x (n + 1)) - f xm - h xm := by
      have hsum : (f + h) xm ≤ (f + h) (alg.x (n + 1)) := h_min
      simp [Pi.add_apply] at hsum
      linarith
    have h_term :
        ((1 - alg.γ (n + 1)) * alg.t (n + 1) / alg.γ (n + 1) ^ 2)
          * (f (alg.x (n + 1)) + h (alg.x (n + 1)) - f xm - h xm)
        ≤ (alg.t n / alg.γ n ^ 2)
          * (f (alg.x (n + 1)) + h (alg.x (n + 1)) - f xm - h xm) :=
      mul_le_mul_of_nonneg_right hcond h_φ_nn
    linarith [hps, h_term, ih]

/-- **Item 13** — `Nesterov_first_converge`. After `k+1` Nesterov steps the cost gap
    is bounded by `γ_k² / (2 t_k) · ‖x_0 - xm‖²`, giving the O(1/k²) rate when
    `γ_k = Θ(1/k)`. -/
theorem Nesterov_first_converge (minφ : IsMinOn (f + h) univ xm) :
    ∀ k : ℕ, f (alg.x (k + 1)) + h (alg.x (k + 1)) -
      f xm - h xm ≤ (alg.γ k) ^ 2 / (2 * alg.t k) * ‖x0 - xm‖ ^ 2 := by
  intro k
  have hW := W_bound (alg := alg) (xm := xm) minφ k
  -- W k = (t_k/γ_k²)(φ(x_{k+1}) - φ(xm)) + (1/2)‖z_{k+1} - xm‖² ≤ (1/2)‖x_0 - xm‖²
  -- Drop the non-negative ‖z_{k+1} - xm‖² and rearrange.
  have hγ_pos : (0 : ℝ) < alg.γ k := (alg.γbound k).1
  have hγ_sq_pos : (0 : ℝ) < (alg.γ k) ^ 2 := by positivity
  have htpos : (0 : ℝ) < alg.t k := (alg.tbound k).1
  have h_t_div_γsq_pos : (0 : ℝ) < alg.t k / (alg.γ k) ^ 2 := by positivity
  have h_norm_sq_nn : 0 ≤ ‖zSeq alg (k + 1) - xm‖ ^ 2 := sq_nonneg _
  have h_drop : (alg.t k / (alg.γ k) ^ 2) * (f (alg.x (k + 1)) + h (alg.x (k + 1)) - f xm - h xm)
      ≤ (1 / 2) * ‖x0 - xm‖ ^ 2 := by
    have h_half_nn : (0 : ℝ) ≤ 1 / 2 * ‖zSeq alg (k + 1) - xm‖ ^ 2 := by
      apply mul_nonneg
      · norm_num
      · exact h_norm_sq_nn
    linarith [hW]
  -- Multiply by (γ_k²/t_k) > 0 to extract.
  have h_γsq_div_t_pos : (0 : ℝ) < (alg.γ k) ^ 2 / alg.t k := by positivity
  have h_mul := mul_le_mul_of_nonneg_left h_drop (le_of_lt h_γsq_div_t_pos)
  have h_t_ne : alg.t k ≠ 0 := ne_of_gt htpos
  have h_γsq_ne : (alg.γ k) ^ 2 ≠ 0 := ne_of_gt hγ_sq_pos
  have h_lhs_eq : (alg.γ k) ^ 2 / alg.t k * ((alg.t k / (alg.γ k) ^ 2)
      * (f (alg.x (k + 1)) + h (alg.x (k + 1)) - f xm - h xm))
      = f (alg.x (k + 1)) + h (alg.x (k + 1)) - f xm - h xm := by
    field_simp
  have h_rhs_eq : (alg.γ k) ^ 2 / alg.t k * ((1 / 2) * ‖x0 - xm‖ ^ 2)
      = (alg.γ k) ^ 2 / (2 * alg.t k) * ‖x0 - xm‖ ^ 2 := by
    field_simp
  rw [h_lhs_eq, h_rhs_eq] at h_mul
  exact h_mul

end LeanAgent.Generated
