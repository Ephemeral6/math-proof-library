/-
Result R.173 — Information-theoretic (Kolmogorov) lower bound on the emergence
cost `N`.

Reference: `branches/computation/workspace/new_results.md` §R.173
(A 条件性 + B; deps R.61w, Kolmogorov complexity, Levin invariance, D.1.6).

**Statement.**  With `K(·)` the Kolmogorov complexity and `σ*` the optimal
intervention sequence (`D.1.6`):

* (a) upper / description compression: `K(σ*) ≤ K(p) + K(A) + O(log N)`;
* (b) lower / information retention:
      `N(p,A) · log|M| ≥ K(σ*) ≥ K(p|A) − O(log K(p))`;
* (c) information-theoretic Ohm law:
      `N(p,A) ≥ (K(p|A) − O(1)) / log|M_eff|`;
* (d) Levin invariance: for two universal AIs `A_U, A_U'`,
      `|N(p, A_U) − N(p, A_U')| ≤ c_{U,U'}` for all `p`.

(b) holds because `σ*` together with `A` reconstructs `p` (run `A`, see which
`p` is satisfied), so the conditional complexity chains
`K(p|A) ≤ K(σ*) + O(log K(p))`; and `σ*` has `≤ N` symbols from `M`, each
carrying `≤ log|M|` bits, so `K(σ*) ≤ N·log|M|`.  Dividing gives (c).

**Formalization strategy (algebraic kernel).**  The substance is the chain of
inequalities over `ℝ` (or `ℕ`); we carry the Kolmogorov-complexity quantities as
abstract nonnegative reals satisfying the bundled structural inequalities from
the source (the "`σ* + A` reconstructs `p`" chain rule, the "`σ*` is `N` symbols"
counting bound), and *derive* the Ohm-form lower bound and Levin invariance by
honest arithmetic.  No Kolmogorov machine is built; the chain-rule and counting
facts enter as hypotheses, exactly as the MIP-side dependency list specifies.

**This file is `axiom`-free.**  It imports only `Mathlib`.
-/
import Mathlib

namespace MIP

namespace KolmogorovLowerBound

/-! ### (b)+(c) — the information-theoretic Ohm lower bound -/

/-- **R.173(b)(c) — lower bound `N ≥ (K(p|A) − O(1)) / log|M_eff|`.**

Bundled inequalities (source §R.173):
* `hcount : Kσ ≤ N * logM` — `σ*` has `≤ N` symbols from `M`, each `≤ log|M|`
  bits (the counting bound `K(σ*) ≤ N·log|M|`);
* `hchain : KpA - c₀ ≤ Kσ` — `σ* + A` reconstructs `p`, so
  `K(p|A) − O(log K(p)) ≤ K(σ*)` (the retention chain rule), with `c₀ ≥ 0` the
  `O(log K(p))` slack;
* `hlogM_pos : 0 < logM`.

Conclusion: `N ≥ (K(p|A) − c₀) / log|M|` — the information-theoretic Ohm law.
The deterministic source of `N`'s uncomputability (R.83) is now intrinsic:
`N ≥ K(p|A)/log|M|` and `K(p|A)` is itself uncomputable. -/
theorem R_173_info_ohm_lower
    (N logM Kσ KpA c₀ : ℝ)
    (hlogM_pos : 0 < logM)
    (hcount : Kσ ≤ N * logM)
    (hchain : KpA - c₀ ≤ Kσ) :
    (KpA - c₀) / logM ≤ N := by
  -- `K(p|A) − c₀ ≤ K(σ*) ≤ N·logM`, then divide by `logM > 0`.
  have hkey : KpA - c₀ ≤ N * logM := le_trans hchain hcount
  rw [div_le_iff₀ hlogM_pos]
  linarith

/-- **R.173(b) — the full sandwich `K(p|A) − c₀ ≤ K(σ*) ≤ N·log|M|`.**

Records the two-sided information-retention/compression chain as a single
inequality `K(p|A) − c₀ ≤ N·log|M|`, the form used to derive (c). -/
theorem R_173_sandwich
    (N logM Kσ KpA c₀ : ℝ)
    (hcount : Kσ ≤ N * logM)
    (hchain : KpA - c₀ ≤ Kσ) :
    KpA - c₀ ≤ N * logM :=
  le_trans hchain hcount

/-- **R.173(a) — upper bound `K(σ*) ≤ K(p) + K(A) + O(log N)`.**

A universal algorithm reconstructs `σ*` from `(p, A)` by enumeration, so the
description length of `σ*` is at most that of `(p, A)` plus a logarithmic
overhead.  We record the additive-compression structural inequality. -/
theorem R_173_upper
    (Kσ Kp KA oLogN : ℝ)
    (h : Kσ ≤ Kp + KA + oLogN) :
    Kσ ≤ Kp + KA + oLogN := h

/-! ### (d) — Levin invariance across universal AIs -/

/-- **R.173(d) — Levin invariance.**

Two universal AIs `A_U, A_U'` simulate each other with a constant prefix, so
`|N(p, A_U) − N(p, A_U')| ≤ c` for all `p`.  Given the two mutual-simulation
bounds `N_U ≤ N_U' + c` and `N_U' ≤ N_U + c` (the simulation overheads), the
absolute difference is bounded by `c`. -/
theorem R_173_levin_invariance
    (N_U N_U' c : ℝ)
    (h₁ : N_U ≤ N_U' + c)
    (h₂ : N_U' ≤ N_U + c) :
    |N_U - N_U'| ≤ c := by
  rw [abs_sub_le_iff]
  constructor <;> linarith

/-- **R.173(d) — invariance is an equivalence-relation-style symmetric bound.**

The mutual-simulation bound is symmetric in `(A_U, A_U')`: the same constant `c`
bounds `|N_U' − N_U|`.  Confirms the invariance kernel is well-posed. -/
theorem R_173_levin_symm
    (N_U N_U' c : ℝ)
    (h₁ : N_U ≤ N_U' + c)
    (h₂ : N_U' ≤ N_U + c) :
    |N_U' - N_U| ≤ c := by
  rw [abs_sub_comm]
  exact R_173_levin_invariance N_U N_U' c h₁ h₂

end KolmogorovLowerBound

end MIP
