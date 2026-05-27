/-
Corollary C.10 — Bidirectional strict advantage.  Reference:
`corollaries/index.md` row C.10 (dep. T.6).

**Statement.** If both directional barrier sets are nonempty
(`B_A ≠ ∅ ∧ B_H ≠ ∅`) then the bidirectional protocol is strictly
cheaper than either unidirectional cost:

    B_A ≠ ∅ ∧ B_H ≠ ∅  ⟹  N_bi < min(N→, N←).

Structurally (T.6): the unidirectional cost `N→` pays for *every*
barrier (including the `|B_H| ≥ 1` barriers that the forward direction
cannot break efficiently), while `N_bi` assigns each barrier to its
cheaper direction.  When `B_A` and `B_H` are both nonempty, the
bidirectional protocol strictly saves on at least the misassigned
barriers, so `N_bi < N→` and `N_bi < N←`.

**Kernel formalized here.** The ℕ strict-inequality kernel under the
T.6 cost-decomposition hypotheses.  Writing `a := |B_A|`, `h := |B_H|`,
`s := |B_S|`, `b := |B|= a+h+s`, and using the structural facts:
* `N_bi = b`            (T.6.iii saturation: each barrier broken once),
* `N→ ≥ b + h`          (forward overpays by the `h` reverse-only
  barriers it must re-derive — strictly, `N→ ≥ b + (extra ≥ h)`),
* `N← ≥ b + a`          (dual),
we get, when `a ≥ 1` and `h ≥ 1`, `N_bi = b < b + h ≤ N→` and
`N_bi = b < b + a ≤ N←`, hence `N_bi < min(N→, N←)`.

We formalize the clean ℕ kernel `Nbi < N_fwd ∧ Nbi < N_bwd` from the
hypotheses `Nbi = b`, `b + h ≤ N_fwd`, `b + a ≤ N_bwd`, `1 ≤ a`,
`1 ≤ h`, and derive `Nbi < min N_fwd N_bwd`.

Axiom-free (only A.1–A.4).
-/
import Mathlib.Data.Nat.Basic
import Mathlib.Order.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace Corollary_C10

/-- **C.10 — bidirectional strict-advantage kernel (ℕ).**

With barrier counts `a, h, s` and total `b = a + h + s`, and the T.6
structural bounds
* `Nbi = b`           (bidirectional saturation),
* `b + h ≤ N_fwd`     (forward pays for the `h` reverse-only barriers),
* `b + a ≤ N_bwd`     (dual),
nonempty directional sets `1 ≤ a`, `1 ≤ h` force

    Nbi < N_fwd   ∧   Nbi < N_bwd. -/
theorem bidirectional_strict
    (a h s b Nbi N_fwd N_bwd : ℕ)
    (hb : b = a + h + s)
    (h_bi : Nbi = b)
    (h_fwd : b + h ≤ N_fwd)
    (h_bwd : b + a ≤ N_bwd)
    (ha : 1 ≤ a) (hh : 1 ≤ h) :
    Nbi < N_fwd ∧ Nbi < N_bwd := by
  refine ⟨?_, ?_⟩
  · -- Nbi = b < b + h ≤ N_fwd  (h ≥ 1)
    have : b < N_fwd := by omega
    omega
  · -- Nbi = b < b + a ≤ N_bwd  (a ≥ 1)
    have : b < N_bwd := by omega
    omega

/-- **C.10 (`< min` form).**

The strict advantage stated against the unidirectional minimum:
`N_bi < min(N→, N←)`. -/
theorem bidirectional_strict_min
    (a h s b Nbi N_fwd N_bwd : ℕ)
    (hb : b = a + h + s)
    (h_bi : Nbi = b)
    (h_fwd : b + h ≤ N_fwd)
    (h_bwd : b + a ≤ N_bwd)
    (ha : 1 ≤ a) (hh : 1 ≤ h) :
    Nbi < min N_fwd N_bwd := by
  obtain ⟨h1, h2⟩ :=
    bidirectional_strict a h s b Nbi N_fwd N_bwd hb h_bi h_fwd h_bwd ha hh
  exact lt_min h1 h2

end Corollary_C10

end MIP
