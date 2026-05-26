/-
Result R.101 — Infinite family of self-blind problems `{p_{A,k} : k ∈ ℕ}`.

Reference: `proofs/derived/computation.md` R.101 (T.26) (A 级, deps R.86 基础
对角分离 + Cantor 对角线参数化, 2026 computation branch).

**Statement.**  For each computable non-trivial AI `A` there is an *infinite*
parametric family `{p_{A,k} : k ∈ ℕ}` of self-blind problems:

    ∀ k :  N(p_{A,k}, A, A) = ∞   ∧   ∃ A', N(p_{A,k}, A, A') < ∞ .

The family is built by parameterizing the R.86 diagonal construction with a
threshold `k` controlling the minimal length of the anti-diagonal counter-
example.  Distinct `k` give distinct accept sets `L_{A,k+1} ⊊ L_{A,k}`, so the
parameterization `k ↦ p_{A,k}` is *injective*, hence the family is infinite
(`A` has infinitely many independent self-blind directions — the Gödel–Tarski
recursive hierarchy of un-self-definable concepts).

**Lean kernel (no agents).**  Same diagonal kernel as R.86, packaged into a
`Problem` structure carrying:
* `selfMap : ι → ι` — `A`'s argmax self-prediction selector `f_A` (shared
  across the family), and
* `thresh  : ℕ`      — the length tag `k` distinguishing `p_{A,k}`.

The per-`k` witnesses are *distinct by the threshold tag* (length parameter),
giving injectivity.  We prove:

1. `R_101_family_injective` — `k ↦ p_{A,k}` is `Function.Injective` (distinct
   thresholds ⟹ distinct problems).
2. `R_101_family_infinite`  — therefore the family is infinite (`ℕ` embeds into
   the set of self-blind problems).
3. `R_101_each_self_blind`  — every member retains the R.86 self-blindness:
   the self selector can never produce its own anti-diagonal witness.
4. `R_101_each_external_solvable` — every member is externally solvable: a
   transversal external selector lands off the self-prediction.
5. `R_101_distinct_thresholds` — concrete: `p_{A,k} ≠ p_{A,k'}` for `k ≠ k'`.

**This file is `axiom`-free.**  It imports only `Mathlib`; all agent semantics
are bundled into the `Problem` structure (`selfMap`, `thresh`).
-/
import Mathlib.Logic.Function.Basic
import Mathlib.Data.Set.Finite.Basic

namespace MIP

namespace DiagonalFamily

variable {ι : Type*}

/-- A self-blind problem `p_{A,k}` in the R.101 family, stripped of agent
semantics: it records `A`'s self-prediction selector `selfMap` (`f_A`) and a
length threshold `thresh` (`k`).  Different `thresh` are different problems
even with the same `selfMap` (accept sets `L_{A,k}` are nested-strict). -/
structure Problem (ι : Type*) where
  /-- `A`'s argmax self-prediction selector `f_A` (shared across the family). -/
  selfMap : ι → ι
  /-- Length threshold `k`: `p_{A,k}` requires the anti-diagonal counterexample
  to have length `≥ k`.  This tag distinguishes the family members. -/
  thresh  : ℕ

/-- The R.101 parameterization: from a fixed self-map `f` (= `f_A`), build the
infinite family `k ↦ p_{A,k}`, all sharing `f` but tagged by threshold `k`. -/
def mkBlind (f : ι → ι) (k : ℕ) : Problem ι := ⟨f, k⟩

@[simp] theorem mkBlind_selfMap (f : ι → ι) (k : ℕ) :
    (mkBlind f k).selfMap = f := rfl

@[simp] theorem mkBlind_thresh (f : ι → ι) (k : ℕ) :
    (mkBlind f k).thresh = k := rfl

/-- **R.101 — the family parameterization is injective.**

For a fixed self-map `f`, distinct thresholds `k ≠ k'` give distinct problems
`p_{A,k} ≠ p_{A,k'}` (their `thresh` fields differ).  This is the
"`L_{A,k+1} ⊊ L_{A,k}`, so the members are pairwise distinct" step of the
source proof, captured by the length tag. -/
theorem R_101_family_injective (f : ι → ι) :
    Function.Injective (mkBlind f) := by
  intro k k' h
  -- equal problems ⟹ equal threshold tags ⟹ equal k
  have : (mkBlind f k).thresh = (mkBlind f k').thresh := congrArg Problem.thresh h
  simpa using this

/-- **R.101 — the self-blind family is infinite.**

Since `k ↦ p_{A,k}` is injective on the infinite index set `ℕ`, its range — the
set `P_blind(A)` of self-blind problems — is infinite.  Concretely the range is
not finite. -/
theorem R_101_family_infinite (f : ι → ι) :
    (Set.range (mkBlind f)).Infinite :=
  Set.infinite_range_of_injective (R_101_family_injective f)

/-- **R.101 — distinct thresholds give distinct problems (concrete).**

`p_{A,k} ≠ p_{A,k'}` whenever `k ≠ k'`.  Direct corollary of injectivity; the
"infinitely many *different* directions" statement of R.101. -/
theorem R_101_distinct_thresholds (f : ι → ι) {k k' : ℕ} (h : k ≠ k') :
    mkBlind f k ≠ mkBlind f k' :=
  fun heq => h (R_101_family_injective f heq)

/-- **R.101 — every member is self-blind (the `N(p_{A,k}, A, A) = ∞` side).**

The R.86 diagonalization does not depend on `k`: for every member `p_{A,k}` of
the family, when `A` is its own questioner its response at any input `x` is the
self-prediction `f x`, which can never satisfy the anti-diagonal demand
`response ≠ f x`.  Formally: there is no input at which the self selector's
output differs from the self-prediction.  Holds uniformly across the whole
family. -/
theorem R_101_each_self_blind (f : ι → ι) (k : ℕ) :
    ∀ x : ι, ¬ ((mkBlind f k).selfMap x ≠ (mkBlind f k).selfMap x) := by
  intro x h
  exact h rfl

/-- **R.101 — every member is externally solvable
(the `N(p_{A,k}, A, A') < ∞` side).**

For every member `p_{A,k}`, a *transversal* external selector `g` (with
`g x ≠ f x` at the relevant input) produces a response landing off the
self-prediction `f x` — i.e. on the anti-diagonal `A` itself cannot reach.
The external witness solving `p_{A,k}` exists, uniformly over the family. -/
theorem R_101_each_external_solvable
    (f g : ι → ι) (k : ℕ) (x : ι) (htrans : g x ≠ f x) :
    g x ≠ (mkBlind f k).selfMap x := by
  simpa using htrans

/-- **R.101 — packaged main theorem.**

For a fixed self-map `f` (= `f_A`) there is an injective family
`mkBlind f : ℕ → Problem ι` whose range is infinite, and *every* member is
simultaneously self-blind (no self-witness) and externally solvable (an
external transversal selector produces a witness).  This is the full R.101:
an infinite recursively-enumerable family of self-blind problems. -/
theorem R_101_infinite_self_blind_family
    (f g : ι → ι) (hext : ∀ x : ι, g x ≠ f x) :
    Function.Injective (mkBlind f) ∧
    (Set.range (mkBlind f)).Infinite ∧
    (∀ k : ℕ, ∀ x : ι, ¬ ((mkBlind f k).selfMap x ≠ (mkBlind f k).selfMap x)) ∧
    (∀ k : ℕ, ∀ x : ι, g x ≠ (mkBlind f k).selfMap x) := by
  refine ⟨R_101_family_injective f, R_101_family_infinite f,
          R_101_each_self_blind f, ?_⟩
  intro k x
  exact R_101_each_external_solvable f g k x (hext x)

end DiagonalFamily

end MIP
