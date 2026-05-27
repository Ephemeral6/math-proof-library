/-
Corollary C.3 — Framework value (nonnegativity).  Reference: `proofs/corollaries.md` C.3.

**Statement.** For the framework value
`Δ(F, p, A) := N(p, A, ∅) − N(p, A, F)`,

    Δ(F, p, A) ≥ 0    and    N(p, A, F) ≥ 0.

**NL content.** By D.4.7 a framework `F` replaces the initial prompt
`q₀` by `q₀^F = F(q₀)`, injecting extra information equivalent to
prepending the first `j` interventions of an optimal frameworkless
sequence (`0 ≤ j ≤ n`).  Hence the residual optimal sequence has length
`n − j`, giving `N(p, A, F) ≤ n = N(p, A, ∅)`, i.e. `Δ ≥ 0`.  And by
D.1.6, `N ∈ ℕ₀`, so `N(p, A, F) ≥ 0`.

**Kernel formalized here.** The two inequalities as an algebra kernel
over `ℕ∞`:

* `N_F ≥ 0` is unconditional (`bot_le`).
* The framework-monotonicity hypothesis `N_F ≤ N_∅` (the D.4.7 content
  "a framework never increases the minimal intervention count") makes
  the framework value `Δ := N_∅ − N_F` (truncated `ℕ∞` subtraction)
  satisfy `Δ ≥ 0` (unconditional) **and**, more sharply,
  `N_F + Δ = N_∅` (the value exactly accounts for the gap).  We also
  give the contrapositive sanity form `Δ = 0 ↔ N_∅ ≤ N_F`.

We carry the saturation index `j ≤ n` model explicitly via
`framework_value_eq_gap`, showing `Δ` equals the number of interventions
the framework "pre-pays".

Axiom-free (only A.1–A.4); pure `ℕ∞` algebra, no axiom used.
-/
import MIP.Axioms
import Mathlib.Data.ENat.Basic

namespace MIP

namespace Corollary_C3

/-- The **framework value** `Δ(F) := N(p, A, ∅) − N(p, A, F)` as a
truncated subtraction in `ℕ∞`.  We model the three quantities abstractly
as `N_empty, N_F : ℕ∞`; their MIP meaning is fixed by D.4.5/D.4.7. -/
def frameworkValue (N_empty N_F : ℕ∞) : ℕ∞ := N_empty - N_F

/-- **C.3 (b) — `N(p, A, F) ≥ 0`.**  Unconditional in `ℕ∞`
(`0` is the bottom element). -/
theorem N_F_nonneg (N_F : ℕ∞) : 0 ≤ N_F := bot_le

/-- **C.3 (a) — `Δ(F) ≥ 0`.**  The framework value is always `≥ 0`
in `ℕ∞` (truncated subtraction is bottomed at `0`). -/
theorem frameworkValue_nonneg (N_empty N_F : ℕ∞) :
    0 ≤ frameworkValue N_empty N_F := bot_le

/-- **C.3 (a, exact accounting).**  Under the D.4.7 framework-monotonicity
content `N(p, A, F) ≤ N(p, A, ∅)`, the framework value exactly closes the
gap: `N_F + Δ(F) = N_∅`.

This is the substantive form of `Δ ≥ 0`: not only is `Δ` nonnegative, it
equals the genuine reduction `N_∅ − N_F` with no `ℕ∞`-truncation loss. -/
theorem framework_value_eq_gap
    {N_empty N_F : ℕ∞} (hMono : N_F ≤ N_empty) :
    N_F + frameworkValue N_empty N_F = N_empty := by
  unfold frameworkValue
  -- `add_tsub_cancel_of_le` : a ≤ b → a + (b - a) = b, in ℕ∞ (CanonicallyOrderedSub).
  exact add_tsub_cancel_of_le hMono

/-- **C.3 (a, saturation-index model).**  If the framework "pre-pays"
exactly `j` of the `n := N(p, A, ∅)` interventions (`0 ≤ j ≤ n`), so
that `N(p, A, F) = n − j`, then the framework value equals `j`.

This realizes the NL proof's `σ*[j+1:n]` residual-sequence argument. -/
theorem framework_value_eq_saturation (n j : ℕ) (hj : j ≤ n) :
    frameworkValue (n : ℕ∞) ((n - j : ℕ) : ℕ∞) = (j : ℕ∞) := by
  unfold frameworkValue
  -- Goal: (↑n : ℕ∞) - ↑(n - j) = ↑j.  Fold the ℕ∞ subtraction back to a ℕ one.
  rw [← ENat.coe_sub]
  congr 1
  omega

/-- **C.3 (a, criterion).**  The framework value is exactly `0` iff the
framework gives no improvement, `N(p, A, ∅) ≤ N(p, A, F)`.  (Useful
sanity contrapositive: `Δ > 0 ↔ N_F < N_∅`.) -/
theorem frameworkValue_eq_zero_iff (N_empty N_F : ℕ∞) :
    frameworkValue N_empty N_F = 0 ↔ N_empty ≤ N_F := by
  unfold frameworkValue
  exact tsub_eq_zero_iff_le

end Corollary_C3

end MIP
