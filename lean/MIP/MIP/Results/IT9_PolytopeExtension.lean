/-
Result IT.9 (candidate R.524) — Extension complexity of the N-realizability
polytope is superpolynomial: `xc(Q_n) ≥ 2^{Ω(N^{1/4})}`.

Reference: `workspace/round3_exploration/slot_030.md` §产出 1 and
`workspace/round3_exploration/work_slot_030.md` §1 (IT.9, candidate R.524,
A 无条件; deps D.1.2, D.1.3, D.1.4, D.1.6, D.2.8, A.2; external: Yannakakis
1991 extension complexity, Fiorini–Massar–Pokutta–Tiwary–de Wolf 2012 STAB
lower bound, Rothvoss 2014).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement.** Let `Q_n := conv{(N(p_1,A),…,N(p_n,A)) : A realizes |K(A)| ≤ n²}`
be the N-realizability polytope in ambient dimension `N = O(n²)`. Then its
Yannakakis extension complexity satisfies

    xc(Q_n) ≥ 2^{Ω(N^{1/4})},

i.e. there is **no compact (polynomial-size) linear program** describing the
set of reachable N-vectors of the MIP capability space.

**NL core (≥ 7-step reduction).** For each `S ⊆ [n]` one builds an agent `A_S`
with `K(A_S) = {ω_i : i ∈ S}`; pair-problems `p_{i,j}` (one per edge of a graph
`G`) make the finite N-vector of `A_S` equal `(𝟙_S, 𝟙_{ {i,j}⊆S })`. The slice
`x_E = 0` then projects `Q_n^{(G)}` onto `STAB(G)`, and extension-complexity
monotonicity (`xc(P∩H) ≤ xc(P)+1`, `xc(π P) ≤ xc(P)`) gives
`xc(Q_n^{(G)}) ≥ xc(STAB(G)) - 1`. With the classical STAB lower bound
`xc(STAB(G)) ≥ 2^{Ω(√n)}` (Yannakakis 1991; Fiorini et al. 2012) and the
reparametrisation `N = n + |E| ≤ n²`, this yields `xc(Q_n) ≥ 2^{Ω(N^{1/4})}`.

**Formalization strategy (hypothesis bundle, algebraic kernel).** The deep
combinatorial fact — the rectangle-covering / nonnegative-rank lower bound for
`STAB(G)` together with the slice/projection reduction — enters as a bundled
hypothesis `hcover : c * N ^ (1/4 : ℝ) ≤ Real.log (xc) / Real.log 2`
(equivalently `2 ^ (c·N^{1/4}) ≤ xc`). On top of that bundle we prove honestly:
(i) the exponential lower bound in `Real.rpow` form; (ii) the consequence that
`xc → ∞` as `N → ∞` (superpolynomial, hence no compact LP); (iii) that the bound
strictly exceeds *every* polynomial `N^k`, the crisp "no polynomial LP" kernel.
No polytope, lift, or protocol is constructed.

**This file is `axiom`-free.**  It imports only `Mathlib`.
-/
import Mathlib

namespace MIP

namespace PolytopeExtension

open Real Filter Topology

/-- The exponential lower-bound function `f c N = 2 ^ (c · N^{1/4})` written with
`Real.rpow`.  This is the lower bound IT.9 places on `xc(Q_n)` with `N` the
ambient dimension and `c > 0` the reduction constant. -/
noncomputable def expLB (c N : ℝ) : ℝ := (2 : ℝ) ^ (c * N ^ (1 / 4 : ℝ))

/-! ### Step 1 — the bundled lower bound is genuinely exponential -/

/-- **IT.9 — the lower bound exceeds `1` (non-vacuous).**

For `c > 0` and `N > 0` the quantity `2 ^ (c·N^{1/4})` is `> 1`: the exponent
`c·N^{1/4}` is strictly positive, and `2^x > 1` for `x > 0`.  So the bundled
bound is never vacuous on genuine instances. -/
theorem IT_9_expLB_gt_one {c N : ℝ} (hc : 0 < c) (hN : 0 < N) :
    1 < expLB c N := by
  unfold expLB
  have hexp_pos : 0 < c * N ^ (1 / 4 : ℝ) :=
    mul_pos hc (Real.rpow_pos_of_pos hN _)
  exact Real.one_lt_rpow_iff_of_pos (by norm_num) |>.2 (Or.inl ⟨by norm_num, hexp_pos⟩)

/-- **IT.9 core — extension-complexity exponential lower bound.**

Bundled hypothesis `hbound : expLB c N ≤ xc` packages the entire combinatorial
reduction (rectangle covering / nonnegative rank of `STAB(G)`, the `x_E = 0`
slice and projection, and dimension reparametrisation `N ≈ n²`).  The conclusion
restates it as the named lower bound `2^{c·N^{1/4}} ≤ xc(Q_n)`, together with the
fact that this forces `xc > 1` (no trivial LP) on any genuine instance. -/
theorem IT_9_xc_lower {c N xc : ℝ} (hc : 0 < c) (hN : 0 < N)
    (hbound : expLB c N ≤ xc) :
    expLB c N ≤ xc ∧ 1 < xc :=
  ⟨hbound, lt_of_lt_of_le (IT_9_expLB_gt_one hc hN) hbound⟩

/-! ### Step 2 — superpolynomial growth: the lower bound beats every `N^k` -/

/-- **IT.9 — the exponent `c·N^{1/4}` tends to `+∞`.**

As `N → ∞` the term `N^{1/4} → ∞`, so `c·N^{1/4} → ∞` for `c > 0`.  This is the
analytic seed of "no compact LP": the log-of-the-bound grows without bound. -/
theorem IT_9_exponent_tendsto_atTop {c : ℝ} (hc : 0 < c) :
    Tendsto (fun N : ℝ => c * N ^ (1 / 4 : ℝ)) atTop atTop := by
  have hpow : Tendsto (fun N : ℝ => N ^ (1 / 4 : ℝ)) atTop atTop :=
    tendsto_rpow_atTop (by norm_num)
  exact Filter.Tendsto.const_mul_atTop hc hpow

/-- **IT.9 — the extension-complexity lower bound diverges (superpolynomial).**

`expLB c N = 2^{c·N^{1/4}} → ∞` as `N → ∞`.  Hence any valid LP description of
the reachable-N-vector polytope must use an unbounded (superpolynomial) number
of inequalities — there is no compact linear program.  Proof: the exponent goes
to `+∞`, and `2^x = exp(x·log 2) → ∞`. -/
theorem IT_9_xc_tendsto_atTop {c : ℝ} (hc : 0 < c) :
    Tendsto (expLB c) atTop atTop := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  -- The exponent `(c·log 2)·N^{1/4} → +∞`.
  have hexp : Tendsto (fun N : ℝ => Real.log 2 * (c * N ^ (1 / 4 : ℝ))) atTop atTop := by
    have h := IT_9_exponent_tendsto_atTop hc
    exact Filter.Tendsto.const_mul_atTop hlog2 h
  -- `expLB c N = exp((log 2)·(c·N^{1/4}))`, and `exp(→ ∞) → ∞`.
  have hrw : expLB c = fun N : ℝ => Real.exp (Real.log 2 * (c * N ^ (1 / 4 : ℝ))) := by
    funext N
    unfold expLB
    rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 2)]
  rw [hrw]
  exact Real.tendsto_exp_atTop.comp hexp

/-- **IT.9 — "no polynomial LP": the bound eventually beats every `N^k`.**

For every fixed polynomial degree `k`, the extension-complexity lower bound
`2^{c·N^{1/4}}` eventually dominates `N^k`.  This is the crisp impossibility
kernel: no polynomial in `N` (no compact LP of polynomial size) can serve as an
upper bound for `xc(Q_n)`.  Proof: on `N > 0` the ratio equals
`exp(k·log N − c·log 2·N^{1/4})`; the exponent tends to `−∞` because
`log N = o(N^{1/4})` (`Real.isLittleO_log_rpow_atTop`) while the dominant
negative term `−c·log 2·N^{1/4}` tends to `−∞`. -/
theorem IT_9_beats_polynomial {c : ℝ} (hc : 0 < c) (k : ℕ) :
    Tendsto (fun N : ℝ => N ^ (k : ℝ) / expLB c N) atTop (nhds 0) := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  -- Dominant negative term `c·log 2·N^{1/4} → +∞`.
  have hdom : Tendsto (fun N : ℝ => c * Real.log 2 * N ^ (1 / 4 : ℝ)) atTop atTop := by
    have hpow : Tendsto (fun N : ℝ => N ^ (1 / 4 : ℝ)) atTop atTop :=
      tendsto_rpow_atTop (by norm_num)
    exact Filter.Tendsto.const_mul_atTop (mul_pos hc hlog2) hpow
  -- `k·log N = o(N^{1/4})`, hence `o(c·log 2·N^{1/4})`.
  have hklog : (fun N : ℝ => (k : ℝ) * Real.log N) =o[atTop]
      fun N : ℝ => c * Real.log 2 * N ^ (1 / 4 : ℝ) := by
    have hlog : (fun N : ℝ => Real.log N) =o[atTop] fun N : ℝ => N ^ (1 / 4 : ℝ) :=
      isLittleO_log_rpow_atTop (by norm_num)
    have hk : (fun N : ℝ => (k : ℝ) * Real.log N) =o[atTop]
        fun N : ℝ => N ^ (1 / 4 : ℝ) := hlog.const_mul_left _
    have hcne : c * Real.log 2 ≠ 0 := ne_of_gt (mul_pos hc hlog2)
    exact hk.const_mul_right hcne
  -- The full exponent `k·log N − c·log 2·N^{1/4} → −∞`.
  have hexp_neg :
      Tendsto (fun N : ℝ => (k : ℝ) * Real.log N - c * Real.log 2 * N ^ (1 / 4 : ℝ))
        atTop atBot := by
    -- `g - f ~ g` (since `f =o g`), and `g → +∞`, so `g - f → +∞`; negate.
    have hequiv :
        Asymptotics.IsEquivalent atTop
          (fun N : ℝ => c * Real.log 2 * N ^ (1 / 4 : ℝ) - (k : ℝ) * Real.log N)
          (fun N : ℝ => c * Real.log 2 * N ^ (1 / 4 : ℝ)) :=
      (Asymptotics.IsEquivalent.refl).sub_isLittleO hklog
    have hpos : Tendsto
        (fun N : ℝ => c * Real.log 2 * N ^ (1 / 4 : ℝ) - (k : ℝ) * Real.log N)
        atTop atTop := hequiv.symm.tendsto_atTop hdom
    have hneg := (tendsto_neg_atBot_iff).2 hpos
    refine hneg.congr (fun N => by ring)
  -- The ratio equals `exp(exponent)` on `N > 0`.
  have hratio : (fun N : ℝ => N ^ (k : ℝ) / expLB c N)
      =ᶠ[atTop] fun N : ℝ =>
        Real.exp ((k : ℝ) * Real.log N - c * Real.log 2 * N ^ (1 / 4 : ℝ)) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with N hN
    have hNpos : 0 < N := hN
    have h1 : N ^ (k : ℝ) = Real.exp ((k : ℝ) * Real.log N) := by
      rw [Real.rpow_def_of_pos hNpos, mul_comm]
    have h2 : expLB c N = Real.exp (c * Real.log 2 * N ^ (1 / 4 : ℝ)) := by
      unfold expLB
      rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 2)]
      congr 1; ring
    rw [h1, h2, ← Real.exp_sub]
  -- Combine: exp(→ −∞) → 0.
  refine Tendsto.congr' hratio.symm ?_
  exact Real.tendsto_exp_atBot.comp hexp_neg

end PolytopeExtension

end MIP
