# R2 Agent 8 — A.4 alone (and A.4 + A.3): what can one axiom push?

**Direction.** A.4 says `ω ∉ K X → ∀ h, X h = X (tokenReplace ω h)`. By
itself (or composed with A.3) it has substantial intra-agent reach.
This round formalises five distinct corollary families.

## Files produced (all compile, all zero `sorry`, zero new `axiom`)

| File | STATUS | Headline |
|---|---|---|
| `R2_Agent8_A4_MultiToken.lean` | DISCOVERY | Iterated A.4 over pair, list (`foldr`/`foldl`), and `Finset` of outside-K tokens. |
| `R2_Agent8_A4_OrderIndep.lean` | DISCOVERY | Output-level order independence: any two foldr orderings of outside-K tokens give the same `X (...)`; permutation invariance via `List.Perm`. |
| `R2_Agent8_A4_BehavEq_Setoid.lean` | DISCOVERY | `behavEq X` as a `Setoid`; `PromptEqClass X := Quotient (behavSetoid X)`; A.4 makes outside-K `tokenReplace` descend to identity on the quotient; `OutsideOrbit X h` ⊆ behavEq-class of `h`. |
| `R2_Agent8_A4_A3_TVBound.lean` | DISCOVERY | A.4 preserves the A.3 ε-TV bound when applied to both sides; single-token and foldr-list forms; explicit A.3-substitute-robustness theorem. |
| `R2_Agent8_A4_FunctionalInvariance.lean` | DISCOVERY | Every output functional `f : PMF (Str α) → β` is invariant under outside-K `tokenReplace`; specialisations to `Bool`, `ℝ`, `Prop` predicates, TV-to-target, binary operators. |

**Total: 5 DISCOVERY, 0 OBSERVATION, 0 DEAD END.**

## Key theorems

### `R2_Agent8_A4_MultiToken`

- `one_token_invariance` — restatement of A.4.
- `two_token_invariance` — `X h = X (tokenReplace ω₁ (tokenReplace ω₂ h))` for `ω₁, ω₂ ∉ K X`.
- `list_invariance_foldr` — list version with right-fold.
- `list_invariance_foldl` — left-fold version.
- `finset_invariance` — `F : Finset Ω` with all-outside-K hypothesis ⟹ invariance via `F.toList.foldr`.
- `finset_invariance_compl` — variant with `(F : Set Ω) ⊆ (K X)ᶜ` hypothesis.

### `R2_Agent8_A4_OrderIndep`

- `two_token_collapses_to_h` — both sides equal `X h`, hence equal each other.
- `pair_swap_invariance` — `X (tokenReplace ω₁ (tokenReplace ω₂ h)) = X (tokenReplace ω₂ (tokenReplace ω₁ h))`.
- `list_foldr_collapses_to_h` — foldr of outside-K tokens collapses to `X h`.
- `list_perm_invariance` — for `ωs.Perm ωs'` of outside-K tokens, `X (ωs.foldr tokenReplace h) = X (ωs'.foldr tokenReplace h)`.
- `three_token_order_indep` — three-token corollary illustrating order independence.

### `R2_Agent8_A4_BehavEq_Setoid`

- `behavEq X h₁ h₂ := X h₁ = X h₂`.
- `behavSetoid X : Setoid (Str α)` (refl/symm/trans).
- `PromptEqClass X := Quotient (behavSetoid X)`, with projection `promptClass`.
- `behavEq_tokenReplace_of_outK` — A.4 in `behavEq` form.
- `promptClass_tokenReplace_eq` — outside-K `tokenReplace ω` descends to identity on the quotient.
- `OutsideOrbit X h` — closure under outside-K foldr.
- `outsideOrbit_subset_behavClass` — orbit ⊆ behavEq-class.
- `promptClass_constant_on_outsideOrbit` — orbit elements share a single quotient class.
- `promptClass_comp_tokenReplace` — the function-level identity `promptClass X ∘ tokenReplace ω = promptClass X` (under outside-K).

### `R2_Agent8_A4_A3_TVBound`

- `tvBound_preserved_single` — `tvDist (X u) (X v) ≤ ε ⟹ tvDist (X (tokenReplace ω u)) (X (tokenReplace ω v)) ≤ ε` for outside-K ω.
- `tvBound_preserved_foldr` — list (foldr) form.
- `A3_substitute_robust_under_A4_single` — A.3 substitute exists with the ε-TV bound surviving an outside-K `tokenReplace` on both augmented histories.
- `A3_substitute_robust_under_A4_foldr` — same with a foldr-list of outside-K tokens.

### `R2_Agent8_A4_FunctionalInvariance`

- `functional_invariant_single` — `f (X h) = f (X (tokenReplace ω h))` for any `f : PMF (Str α) → β` and outside-K ω.
- `functional_invariant_two_tokens`, `functional_invariant_foldr` — pair/list versions.
- `bool_predicate_invariant`, `real_functional_invariant`, `prop_predicate_invariant` — specialisations.
- `tvDist_to_target_invariant` — TV distance from `X (·)` to a fixed target distribution is invariant.
- `binary_functional_invariant_left` — binary operator congruence.

## What CAN A.4 push by itself? (executive answer)

1. **Multi-token / iterated invariance** — yes, fully derivable, all the way to `Finset` form.
2. **Output-level order independence** — yes; the syntactic `tokenReplace` does NOT commute (opaque), but the X-output composition does. Stronger: a full `List.Perm` invariance lifts to X-output.
3. **Equivalence relation / quotient structure** — yes; `behavEq X` is a `Setoid`, A.4 makes outside-K `tokenReplace` a quotient identity.
4. **A.3 ε-TV bound preservation** — yes; A.4 acts on the X-output, so applying outside-K `tokenReplace` on both sides of any A.3-style TV inequality preserves it.
5. **Arbitrary output-functional invariance** — yes; any `f : PMF (Str α) → β` (Bool / ℝ / Prop predicate / TV-distance / binary operator) inherits A.4 invariance by `congr 1`.

## What CANNOT A.4 push? (boundary)

A.4 is strictly intra-agent: it says nothing about cross-agent comparisons. The dead-end in Round 1 (`Agent8_Phi0_CrossAgent_DeadEnd`) remains: `K A = K B` does NOT force `Phi0 A p = Phi0 B p`. None of the present R2-Agent8 files break that boundary; we work entirely within a single fixed agent `X`.

## Compilation

All five files compiled with
```
lake env lean MIP/Discoveries/R2_Agent8_<file>.lean
```
from `C:\Users\12729\Desktop\Math\lean\MIP\`. Each is independent (no
mutual imports between R2_Agent8 files); each pulls only from
`MIP.Axioms` (plus `Mathlib.Data.List.Perm.Basic` in `OrderIndep`).
