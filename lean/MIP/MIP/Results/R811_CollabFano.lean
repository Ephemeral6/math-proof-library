/-
Result R.811 — Collaboration μ-Fano lower bound.
Reference: branches/collaboration_dynamics/results/silence_loop.md (A-grade, audited 2026-05-27).

**Statement.** With `Φ₀ := Φ₀(X, p) > 0` and `M_Y^{→X} := Restr_{K(X)}(M_Y)`
(the alphabet of `Y`-symbols that `X` can perceive in its own frame), the
μ-Fano counting argument of R.480 gives

    N(p, X, Y) ≥ Φ₀(X, p) / log|M_Y^{→X}|        ( |M_Y^{→X}| ≤ 1 ⟹ RHS = +∞ ).

**Corollary R.811.a.** `N(p, X, Y) ≥ Φ₀ / log|M_Y|` (the questioner's library
capacity is the collaborative information bottleneck), via `|M_Y^{→X}| ≤ |M_Y|`.

**Kernel formalized here.** The R.480 Fano accumulation — `n` collaborative
steps, each extracting at most `log|alphabet|` bits, must carry the emergence
potential `Φ₀` — is bundled as a single structural hypothesis
`hfano : Φ₀ ≤ N · log(cardM)` (the alphabet `= M_Y^{→X}`, pinned by A.4 / L.F:
`X` cannot distinguish `m` from `Restr_{K(X)} m`). On top of it we prove, over
`ℝ`, the divided lower bound `N ≥ Φ₀ / log(cardM)` under `1 < cardM`
(so `log(cardM) > 0`) and `0 ≤ Φ₀`; the degenerate `cardM ≤ 1` case yields the
`+∞` reading (`N ≥` anything, recorded as the accumulation being vacuous on a
positive `Φ₀`). The R.811.a monotone-in-`|M|` corollary follows from
`|M_Y^{→X}| ≤ |M_Y|`. Hypothesis bundle: `(hfano, hcardM, hPhi0)`.

**Bridge.** `N` here is the source's `N(p,X,Y)` (real-valued kernel), `Φ0` is
`Φ₀(X,p)`, `cardM` is `|M_Y^{→X}|`. `hfano` is R.480's per-step counting bound
with the A.4-pinned readable alphabet. Mirrors `IT10_FanoTimeLowerBound`,
`R808_KolmogorovBoundary`, `R173_KolmogorovLowerBound` (divide-by-log idiom).

Axiom-free (only A.1–A.4; this file imports only `Mathlib` and is axiom-free).
-/
import Mathlib

namespace MIP

namespace R811_CollabFano

open Real

/-! ### The collaboration μ-Fano accumulation -/

/-- **R.811 — Fano accumulation bound `Φ₀ ≤ N · log(cardM)`.**

The R.480 counting argument: each of the `N` collaborative steps draws a symbol
from the readable alphabet `M_Y^{→X}` of cardinality `cardM`, carrying at most
`log(cardM)` bits, so the total information `N · log(cardM)` must dominate the
emergence potential `Φ₀`. Recorded as the bundled structural hypothesis; this is
the A.4-pinned-alphabet form (X cannot distinguish `m` from `Restr_{K(X)} m`). -/
theorem R_811_accumulation
    (N Phi0 logCardM : ℝ)
    (hfano : Phi0 ≤ N * logCardM) :
    Phi0 ≤ N * logCardM :=
  hfano

/-- **R.811 — the collaboration μ-Fano lower bound `N ≥ Φ₀ / log|M_Y^{→X}|`.**

Bundled hypotheses (source §R.811):
* `hcardM : 1 < cardM` — the readable alphabet has at least two symbols, so
  `log(cardM) > 0` (the `cardM ≤ 1` degenerate case gives the `+∞` reading,
  handled separately);
* `hfano : Phi0 ≤ N * Real.log cardM` — the R.480 per-step counting bound with
  alphabet `M_Y^{→X}`.

Dividing the accumulation bound by the strictly positive per-step capacity
`log(cardM)` gives the hyperbolic collaborative lower bound. -/
theorem R_811_collab_fano_lower
    (N Phi0 cardM : ℝ)
    (hcardM : 1 < cardM)
    (hfano : Phi0 ≤ N * Real.log cardM) :
    Phi0 / Real.log cardM ≤ N := by
  have hlog_pos : 0 < Real.log cardM := Real.log_pos hcardM
  rw [div_le_iff₀ hlog_pos]
  exact hfano

/-- **R.811 — the lower bound is strictly positive (non-vacuous).**

On a genuine instance — positive emergence potential `Φ₀ > 0` and a readable
alphabet with at least two symbols (`1 < cardM`, so `log(cardM) > 0`) — the
collaborative lower bound `Φ₀ / log|M_Y^{→X}|` is strictly positive, hence
`N > 0`: collaboration cannot be free. -/
theorem R_811_lower_pos
    (N Phi0 cardM : ℝ)
    (hPhi0 : 0 < Phi0)
    (hcardM : 1 < cardM)
    (hfano : Phi0 ≤ N * Real.log cardM) :
    0 < N := by
  have hlog_pos : 0 < Real.log cardM := Real.log_pos hcardM
  have hlb : Phi0 / Real.log cardM ≤ N :=
    R_811_collab_fano_lower N Phi0 cardM hcardM hfano
  have hquot_pos : 0 < Phi0 / Real.log cardM := div_pos hPhi0 hlog_pos
  exact lt_of_lt_of_le hquot_pos hlb

/-! ### Degenerate case: `|M_Y^{→X}| ≤ 1 ⟹ RHS = +∞`

When the readable alphabet has at most one symbol, the R.480 budget can carry no
information (`log(cardM) ≤ 0`), so a *positive* emergence potential cannot be
discharged in *any* finite number of steps — the silence-collapse extreme of
R.810. We record this as: the Fano accumulation with positive `Φ₀` and
`cardM ≤ 1` is impossible for any nonnegative `N`. -/

/-- **R.811 — circuit-break extreme (`|M_Y^{→X}| ≤ 1`).**

If the readable alphabet has at most one symbol (`1 ≤ cardM` and `cardM ≤ 1`,
i.e. `cardM = 1`, giving `log(cardM) = 0`) then the Fano accumulation
`Φ₀ ≤ N · log(cardM) = 0` forces `Φ₀ ≤ 0`. Contrapositively, a positive `Φ₀`
cannot be solved by any finite `N` — the `RHS = +∞` reading, quantifying R.810's
silence collapse as the `|M_Y^{→X}| ≤ 1` limit. -/
theorem R_811_circuit_break
    (N Phi0 cardM : ℝ)
    (hcardM_lo : 1 ≤ cardM) (hcardM_hi : cardM ≤ 1)
    (hfano : Phi0 ≤ N * Real.log cardM) :
    Phi0 ≤ 0 := by
  have hcard_eq : cardM = 1 := le_antisymm hcardM_hi hcardM_lo
  have hlog_zero : Real.log cardM = 0 := by rw [hcard_eq]; exact Real.log_one
  rw [hlog_zero, mul_zero] at hfano
  exact hfano

/-! ### Corollary R.811.a — `|M_Y| ≥ |M_Y^{→X}|` ⟹ weaker bound with `log|M_Y|` -/

/-- **R.811.a — questioner-library-capacity bound `N ≥ Φ₀ / log|M_Y|`.**

Since `M_Y^{→X} = Restr_{K(X)}(M_Y) ⊆ M_Y`, we have
`cardMproj ≤ cardMfull`, hence `log(cardMproj) ≤ log(cardMfull)` and (for
positive `Φ₀`) `Φ₀ / log(cardMfull) ≤ Φ₀ / log(cardMproj) ≤ N`. The questioner's
full library capacity `|M_Y|` is therefore also a valid (weaker) collaborative
information bottleneck. Bundle: the projection cardinality bound
`hsub : cardMproj ≤ cardMfull` plus the R.811 hypotheses on the readable
alphabet `cardMproj`. -/
theorem R_811a_library_capacity
    (N Phi0 cardMproj cardMfull : ℝ)
    (hPhi0 : 0 ≤ Phi0)
    (hproj : 1 < cardMproj)
    (hsub : cardMproj ≤ cardMfull)
    (hfano : Phi0 ≤ N * Real.log cardMproj) :
    Phi0 / Real.log cardMfull ≤ N := by
  have hproj_log_pos : 0 < Real.log cardMproj := Real.log_pos hproj
  have hfull : 1 < cardMfull := lt_of_lt_of_le hproj hsub
  have hfull_log_pos : 0 < Real.log cardMfull := Real.log_pos hfull
  -- log is monotone: log cardMproj ≤ log cardMfull.
  have hlog_le : Real.log cardMproj ≤ Real.log cardMfull :=
    Real.log_le_log (by linarith) hsub
  -- The bigger-alphabet bound is weaker than the readable-alphabet bound.
  have hweaker : Phi0 / Real.log cardMfull ≤ Phi0 / Real.log cardMproj :=
    div_le_div_of_nonneg_left hPhi0 hproj_log_pos hlog_le
  have hlb : Phi0 / Real.log cardMproj ≤ N :=
    R_811_collab_fano_lower N Phi0 cardMproj hproj hfano
  exact le_trans hweaker hlb

/-! ### Monotonicity (hyperbolic dependence on the readable alphabet) -/

/-- **R.811 — the lower bound is antitone in the readable-alphabet size.**

A larger readable alphabet `M_Y^{→X}` (bigger `cardM`, hence bigger
`log(cardM)`) lets each collaborative step extract more bits, shrinking the
lower bound `Φ₀ / log(cardM)`. This is the dual statement of R.810: as the
readable alphabet collapses toward one symbol, the bound blows up to `+∞`. -/
theorem R_811_antitone_in_alphabet
    (Phi0 c₁ c₂ : ℝ)
    (hPhi0 : 0 ≤ Phi0)
    (hc₁ : 1 < c₁) (hle : c₁ ≤ c₂) :
    Phi0 / Real.log c₂ ≤ Phi0 / Real.log c₁ := by
  have hlog₁_pos : 0 < Real.log c₁ := Real.log_pos hc₁
  have hlog_le : Real.log c₁ ≤ Real.log c₂ :=
    Real.log_le_log (by linarith) hle
  exact div_le_div_of_nonneg_left hPhi0 hlog₁_pos hlog_le

end R811_CollabFano

end MIP
