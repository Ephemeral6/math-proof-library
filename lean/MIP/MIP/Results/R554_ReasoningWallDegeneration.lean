/-
Result R.554 / R.557 — The reasoning-length wall degenerates to the
critical-path (DAG longest-path) bound; the AI-pipeline relay refutation.

Reference: `workspace/round3_exploration/slot_035.md` and
`workspace/round3_exploration/work_slot_035.md` (slot 035, A unconditional).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement.**

* **R.554 (Cj.14 degeneration).** Under the derived definitions D.2.11
  (`l := L(G(p))`, the longest dependency-chain length) and D.2.12
  (`L := max_m |{b : m breaks b}|`, the single-step reasoning bound, `L ≥ 1`),
  the conjectured "reasoning-length wall"
  `⌈l / L⌉ − 1 ≤ N` is a *strict weakening* of R.40 (`L(G) ≤ N`):

      ⌈l / L⌉ − 1  ≤  l − 1  <  l = L(G)  ≤  N .

  The lemma L.14.1 ("on a longest dependency chain each operator breaks at
  most one atomic barrier", so `L ≥ 1` on the chain) gives `⌈l / L⌉ ≤ l`, and
  R.40 gives `l ≤ N`.  Hence Cj.14 carries a weaker `−1` constant and is *not
  independent* — it is the R.40 path bound minus one.

* **R.557 (Cj.26 refutation).** For a sequentially-composed pipeline
  `A_1 ∘_seq … ∘_seq A_k`, the intervention count still obeys
  `N(pipeline) ≥ L(G(p))`, *independently of `k`*.  The longest path `L(G(p))`
  is an intrinsic property of the problem's barrier DAG, not of the solver's
  composition.  So "AI relay" cannot break the reasoning-length wall — it can
  only amortize it.  The refutation is literally the exhibition of
  `k`-independence: the same lower bound `L` holds for every `k`.

**Lightweight encoding (reuse R.40 critical-path idea).** As in R.40 we model
"a dependency chain of length `L` whose links each consume a distinct one of
the `N` intervention steps" as an injection `f : Fin L → Fin N`; then `L ≤ N`
by pigeonhole.  The pipeline of `k` agents only changes the *witness*
injection, not the chain length `L`, so the bound is `k`-independent.

**This file is `axiom`-free.**  It imports only Mathlib and reuses the standard
`Fintype.card_le_of_injective` / `Nat.ceil` infrastructure.
-/
import Mathlib.Data.Fintype.Card
import Mathlib.Algebra.Order.Floor.Div
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace ReasoningWallDegeneration

/-- **R.40 kernel (reused).**  An injection of the `L` chain links into the `N`
intervention steps forces `L ≤ N`. -/
theorem critical_path_le_steps {L N : ℕ} (f : Fin L → Fin N)
    (hf : Function.Injective f) : L ≤ N := by
  simpa using Fintype.card_le_of_injective f hf

/-- **R.554 (a) — the ceiling step `⌈l / L⌉ ≤ l` (L.14.1 + L.14.2 content).**

Per L.14.1, on the longest dependency chain each operator breaks at most one
atomic barrier, so the single-step bound satisfies `L ≥ 1`.  With `L ≥ 1` the
ceiling of `l / L` never exceeds the chain length `l`:

    ⌈l / L⌉ ≤ ⌈l / 1⌉ = l .

This is the arithmetic core that collapses Cj.14's `⌈l/L⌉` to `l`. -/
theorem R_554_ceil_le (l L : ℕ) (hL : 1 ≤ L) :
    (l + L - 1) / L ≤ l := by
  -- `(l + L - 1) / L` is the standard `⌈l / L⌉` for `L ≥ 1`.
  rcases Nat.eq_zero_or_pos l with hl0 | hl1
  · -- l = 0: `(L-1)/L = 0 ≤ 0`.
    subst hl0
    have : (0 + L - 1) / L = 0 := Nat.div_eq_of_lt (by omega)
    omega
  · -- l ≥ 1: use `(l+L-1)/L ≤ (l*L)/L = l` since `l + L - 1 ≤ l*L`.
    -- `l + L ≤ l*L + 1` because `(l-1)*(L-1) ≥ 0`, i.e. `l*L + 1 ≥ l + L`.
    obtain ⟨l', rfl⟩ := Nat.exists_eq_add_of_lt hl1  -- l = 0 + l' + 1
    obtain ⟨L', rfl⟩ := Nat.exists_eq_add_of_le hL    -- L = 1 + L'
    have hexp : (0 + l' + 1) * (1 + L') = l' + 1 + L' + l' * L' := by ring
    have hbound : (0 + l' + 1) + (1 + L') - 1 ≤ (0 + l' + 1) * (1 + L') := by
      rw [hexp]; omega
    calc ((0 + l' + 1) + (1 + L') - 1) / (1 + L')
        ≤ ((0 + l' + 1) * (1 + L')) / (1 + L') := Nat.div_le_div_right hbound
      _ = (0 + l' + 1) := Nat.mul_div_cancel _ (by omega)

/-- **R.554 — Cj.14 degenerates to a strict weakening of R.40.**

Given the derived chain length `l := L(G(p))`, the single-step bound `L ≥ 1`
(L.14.1), and an injection `f : Fin l → Fin N` witnessing R.40 (`l ≤ N`),
the conjectured reasoning-length wall holds *with a slack of at least one*:

    ⌈l / L⌉ − 1  ≤  l − 1  <  l  ≤  N         (when `l ≥ 1`)

so `⌈l / L⌉ − 1 ≤ N`, and moreover the bound is *not tight* relative to R.40.
Cj.14 is the R.40 path bound minus one — it is not independent. -/
theorem R_554_cj14_degenerates
    {l L N : ℕ} (hL : 1 ≤ L)
    (f : Fin l → Fin N) (hf : Function.Injective f) :
    (l + L - 1) / L - 1 ≤ N := by
  have hceil : (l + L - 1) / L ≤ l := R_554_ceil_le l L hL
  have hR40 : l ≤ N := critical_path_le_steps f hf
  omega

/-- **R.554 — the strict-weakening chain made explicit.**

When the chain is non-trivial (`l ≥ 1`), the four-term inequality

    ⌈l / L⌉ − 1  ≤  l − 1  <  l  ≤  N

holds.  This exhibits Cj.14 (`⌈l/L⌉ − 1 ≤ N`) as *strictly weaker* than R.40
(`l ≤ N`): there is a `< l` gap, witnessing the `−1` slack. -/
theorem R_554_strict_weakening
    {l L N : ℕ} (hl : 1 ≤ l) (hL : 1 ≤ L)
    (f : Fin l → Fin N) (hf : Function.Injective f) :
    (l + L - 1) / L - 1 ≤ l - 1 ∧ l - 1 < l ∧ l ≤ N := by
  have hceil : (l + L - 1) / L ≤ l := R_554_ceil_le l L hL
  have hR40 : l ≤ N := critical_path_le_steps f hf
  refine ⟨by omega, by omega, hR40⟩

/-- **R.557 — Cj.26 refutation: the pipeline bound `L ≤ N` is `k`-independent.**

Model a length-`k` pipeline `A_1 ∘_seq … ∘_seq A_k` by an intervention budget
`Nbudget : ℕ → ℕ` (the budget may depend on `k`) together with a per-`k`
critical-path injection `f k : Fin L → Fin (Nbudget k)` (the chain
`L = L(G(p))` is intrinsic to the problem, not to the composition).  For
*every* `k : ℕ` the same lower bound `L ≤ Nbudget k` holds, so the *bound on
the right-hand side is always the fixed constant `L`*, independent of `k`.

This is the literal refutation of Cj.26 ("AI relay eliminates the
reasoning-length wall"): the geometric lower bound `L(G(p))` is the same for
all pipeline lengths `k`. -/
theorem R_557_pipeline_bound_k_independent
    {L : ℕ} {Nbudget : ℕ → ℕ}
    (f : ∀ k : ℕ, Fin L → Fin (Nbudget k))
    (hf : ∀ k : ℕ, Function.Injective (f k)) :
    ∀ k : ℕ, L ≤ Nbudget k :=
  fun k => critical_path_le_steps (f k) (hf k)

/-- **R.557 — `k`-independence stated as a constant lower-bound function.**

The map `k ↦ (the guaranteed lower bound on the pipeline's intervention count)`
is the constant function `fun _ => L`.  Exhibiting this constant function *is*
the refutation: the bound `L(G(p))` does not vary with the relay length `k`.
Concretely, for any two pipeline lengths `k₁, k₂` the guaranteed lower bound
`L` is the same and bounds the respective budgets. -/
theorem R_557_lower_bound_constant
    {L : ℕ} {Nbudget : ℕ → ℕ}
    (f : ∀ k : ℕ, Fin L → Fin (Nbudget k))
    (hf : ∀ k : ℕ, Function.Injective (f k)) :
    ∀ k₁ k₂ : ℕ, (L ≤ Nbudget k₁) ∧ ((fun _ : ℕ => L) k₁ = (fun _ : ℕ => L) k₂) :=
  fun k₁ _ => ⟨critical_path_le_steps (f k₁) (hf k₁), rfl⟩

end ReasoningWallDegeneration

end MIP
