/-
Mathematical Principles of Intelligence (MIP) — Emergence Mechanics
Basic types: alphabet, strings, knowledge universe, agents, problems.

Reference: Chapter 2 of `涌现力学：AI的数学原理.md`, definitions 2.1–2.9.

Notational note. The book writes `Σ` for the finite alphabet and `Ω` for the
knowledge universe. Lean 4 reserves `Σ` as a binder for sigma types, so we
introduce the alphabet as a `variable` named with the generic identifier
`α : Type` and document the book-level name in comments.
-/
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Set.Basic
import Mathlib.Probability.ProbabilityMassFunction.Basic

namespace MIP

/-! ### 2.1.1 — Strings -/

/-- `Str α` = `Σ*`, the set of finite strings over an alphabet `α`.
(Definition 2.1.) -/
abbrev Str (α : Type) : Type := List α

/-! ### 2.1.2 — Agents -/

/-- Definition 2.1 (Agent). An agent is a conditional probability kernel
`Σ* → Δ(Σ*)` sending dialogue histories to distributions over responses.

We treat an `Agent α` as a function `Str α → PMF (Str α)`. No assumptions
about its internal structure are imposed at this level. -/
def Agent (α : Type) : Type := Str α → PMF (Str α)

/-! ### 2.1.4 — Problems -/

/-- Definition 2.8 (Problem). A problem is a Boolean decision predicate on
strings; `p s = true` indicates that `s` is a correct solution.

(The full book-level definition packages this with an initial query `q₀`
and a knowledge-demand set `R(p)`. Those are introduced in `MIP.Axioms`
as separate abstract symbols.) -/
def Problem (α : Type) : Type := Str α → Bool

/-! ### 2.1.2 — The knowledge universe Ω

The book postulates a countable set `Ω` of indivisible knowledge elements
(Definition 2.2). We treat `Ω` as a `Fintype` for the purposes of this
formalization (the finite-Ω restriction matches the finite-information
regime relevant to all theorems in Part I; the infinite case is left to
future work). -/

-- Membership data type for `Ω` is supplied by the user via a `Fintype`
-- instance. We expose no concrete `Ω` here; downstream files take it as a
-- `variable Ω : Type [Fintype Ω]`.
section AlphabetAndUniverse

-- Σ: a finite alphabet.
variable (α : Type) [Fintype α] [DecidableEq α]

-- Ω: a finite knowledge universe.
variable (Ω : Type) [Fintype Ω] [DecidableEq Ω]

/-- Definition 2.3 (Extract). The map `extract : Σ* → 2^Ω` recovers the
knowledge elements appearing in a string. -/
def Extract : Type := Str α → Finset Ω

end AlphabetAndUniverse

end MIP
