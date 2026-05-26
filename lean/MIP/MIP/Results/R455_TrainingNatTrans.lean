/-
Result R.455 — Training as a natural transformation `F₀ ⇒ F_t` between
functors `Prob → ℕ`; naturality on the zero-cost reduction subcategory.

Reference: `workspace/categorical_formalization.md` R.455 (B).

**Statement (formalized kernel).** Training is a path of natural
transformations `η_t : F₀ ⇒ F_t` in the functor category `[Prob, ℕ]`,
where `F_t(p) := N(p, A_t)` counts the cost of solving problem `p` at
training time `t`. We formalize the **naturality square as a commuting
numeric equation**.

* **(b) naturality square.** A problem reduction `r : p₁ → p₂` is sent by
  each functor to a monotone map on costs, `F₀(r), F_t(r) : ℕ → ℕ`. The
  components `η p₁, η p₂ : ℕ → ℕ` give a natural transformation iff the
  square commutes:

        F_t(r) ∘ η p₁  =  η p₂ ∘ F₀(r).

  (c) states this holds on the **zero-cost reduction subcategory**
  `Prob⁰`: when `r` carries no extra reduction cost, `F₀(r) = F_t(r)`
  (training does not change a free reduction's behaviour) and the
  components are *uniform*, `η p₁ = η p₂ =: e`. The square then collapses
  to `f ∘ e = e ∘ f`, which holds because `e` and `f` commute on the
  zero-cost subcategory (bundled hypothesis).

* **(d) three-layer structure (T.30).** `η_t` factors in `t` into three
  layers: a constant-`∞` cover layer (`F_t ≡ ⊤`), a monotone-decreasing
  collaboration layer, and a constant-`0` autonomy layer (`F_t ≡ 0`). We
  encode the two constant endpoints and the naturality of a constant
  natural transformation.

* **(e) Gompertz norm.** The completion gap `‖F₀ − F_t‖` decays at the
  Gompertz rate (carried over from R.98 via R.452); here we record the
  monotone-decrease relation across the collaboration layer.

**What was reduced to a kernel.** The genuine category `Prob` (objects =
problems, morphisms = complexity reductions, e.g. Karp reductions) is
*not* formalized — it depends on the open NC.2 (problem-reduction
category), as documented in the source (grade B). We bundle the relevant
data as explicit hypotheses (the functor actions on a reduction, the
components, and the zero-cost condition) and prove the naturality square
commutes exactly under them. This is the strongest defensible algebraic
fragment of R.455.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Nat.Basic
import Mathlib.Data.ENat.Basic
import Mathlib.Logic.Function.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace TrainingNatTrans

/-! ### Part 1 — The naturality square as a commuting equation. -/

/-- **R.455 (b) — general naturality square (commuting condition).**

Given a reduction `r : p₁ → p₂` sent by the functors to cost maps
`F0r, Ftr : ℕ → ℕ`, and natural-transformation components
`η₁, η₂ : ℕ → ℕ`, `η_t` is natural at `r` iff the square commutes. We
state the commuting equation; the hypothesis `hcomm` records exactly when
it holds. The theorem confirms that under `hcomm` the two composites
agree pointwise. -/
theorem R_455_b_naturality_square
    (F0r Ftr η₁ η₂ : ℕ → ℕ)
    (hcomm : ∀ n, Ftr (η₁ n) = η₂ (F0r n)) :
    Ftr ∘ η₁ = η₂ ∘ F0r := by
  funext n
  exact hcomm n

/-- **R.455 (c) — naturality on the zero-cost reduction subcategory `Prob⁰`.**

On `Prob⁰` a reduction `r` is *free*: training does not change its action,
so `F₀(r) = F_t(r) =: f`, and the natural-transformation components are
*uniform* across the (cost-preserving) reduction, `η p₁ = η p₂ =: e`.
The naturality square then reduces to `f ∘ e = e ∘ f`, which holds
precisely because a zero-cost reduction commutes with the training
component (bundled hypothesis `hfe`). -/
theorem R_455_c_zero_cost_naturality
    (f e : ℕ → ℕ)
    (hfe : ∀ n, f (e n) = e (f n)) :
    f ∘ e = e ∘ f := by
  funext n
  exact hfe n

/-- **R.455 (c) — concrete zero-cost case: the training component is a
uniform shift.**

A canonical zero-cost reduction component: training subtracts the same
saved amount at every problem, `e n = n - k` (truncated subtraction), and
a free reduction `f n = n` is the identity on costs. The naturality
square `f ∘ e = e ∘ f` holds trivially, witnessing that uniform-savings
training is natural on `Prob⁰`. -/
theorem R_455_c_uniform_shift_natural (k : ℕ) :
    (fun n : ℕ => n) ∘ (fun n => n - k) = (fun n => n - k) ∘ (fun n : ℕ => n) := by
  funext n
  rfl

/-! ### Part 2 — Three-layer structure (T.30). -/

/-- **R.455 (d) — cover layer: `F_t` is the constant `∞`-cost functor.**

For `t < t_cov`, no problem is solvable: `F_t p = ∞` for all `p` (encoded
in `ℕ∞ = ℕ ∪ {∞}` as `⊤`). The natural transformation `η : F₀ ⇒ F_t`
into a constant functor is automatically natural — every component is the
constant map to `⊤`, and constant maps commute with everything. -/
theorem R_455_d_cover_layer_natural
    (F0r : ℕ∞ → ℕ∞) (η₁ η₂ : ℕ∞ → ℕ∞)
    (hconst₂ : ∀ x, η₂ x = ⊤) :
    (fun _ : ℕ∞ => (⊤ : ℕ∞)) ∘ η₁ = η₂ ∘ F0r := by
  funext x
  simp only [Function.comp_apply, hconst₂]

/-- **R.455 (d) — autonomy layer: `F_t` is the constant `0` functor.**

For `t > t_aut`, all problems are solved autonomously: `F_t p = 0` for all
`p`. The collapse natural transformation `η : F₀ ⇒ 0` sends every cost to
`0`. Naturality holds: both composites are the constant-`0` map. -/
theorem R_455_d_autonomy_layer_natural
    (F0r : ℕ → ℕ) (η₁ η₂ : ℕ → ℕ)
    (hzero₂ : ∀ n, η₂ n = 0) :
    (fun _ : ℕ => 0) ∘ η₁ = η₂ ∘ F0r := by
  funext n
  simp only [Function.comp_apply, hzero₂]

/-! ### Part 3 — Gompertz / monotone decrease across the collaboration layer. -/

/-- **R.455 (e) — collaboration layer: `η_t` decreases the cost monotonically.**

For `t_cov < t < t_aut`, `F_t` takes finite values and `η_t` lowers cost:
each component `η p : F₀ p → F_t p` satisfies `η_t(p) ≤ F₀(p)`
(training never increases cost). Across two training times `s ≤ t` the gap
shrinks: `F_s p ≥ F_t p` — the monotone descent whose rate is Gompertz
(R.98 / R.452). Stated as: if the per-time cost is antitone in `t`, the
completion gap `F₀ p − F_t p` is monotone nondecreasing in `t`. -/
theorem R_455_e_gap_monotone
    (F : ℕ → ℕ) (hF_antitone : Antitone F)
    {s t : ℕ} (hst : s ≤ t) :
    F 0 - F s ≤ F 0 - F t := by
  have h1 : F t ≤ F s := hF_antitone hst
  omega

end TrainingNatTrans

end MIP
