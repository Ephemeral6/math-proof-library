/-
Lemma L.F — Frame-compatibility lemma (generalized Restr_S form).
Reference: `lemmas/L_F_proof.md` (v2.0 main form).

**Statement (response isomorphism, recursion (2')).** Let `X` be an agent with
knowledge space `K(X) ⊆ Ω`. For any string `s ∈ Σ*`, let `Restr_{K(X)}(s)` be
`s` with every token for a knowledge element `ω ∉ K(X)` replaced by a neutral
placeholder. Then for any history `h`,

    𝓛(X(h · s)) = 𝓛(X(h · Restr_{K(X)}(s))) :

`X` cannot distinguish `m` (or any `s ∈ Σ*`) from its `K(X)`-restriction. This
is L.F corollary (2)/(2'), the key downstream fact (used by R.131–R.147,
R.413–R.417, T.33, T.34).

**Kernel formalized here.** A.4 (`MIP.Axioms.A4`) gives, for a *single*
`ω ∉ K(X)`, `X g = X (tokenReplace ω g)` for every history `g`. The restriction
`Restr_{K(X)}` acts by replacing the K(X)-outside tokens one at a time. We
formalize this as the *iterated* application of `tokenReplace` over a finite
list `ωs : List Ω` of out-of-K elements:

    restrFold ωs g := ωs.foldl (fun acc ω => tokenReplace ω acc) g ,

and prove (by list induction, A.4 at each step):

* `frame_compat_fold`: if every `ω ∈ ωs` is outside `K X`, then for all `g`,
  `X g = X (restrFold ωs g)`.
* `frame_compat`: the L.F response-isomorphism form on `g = extendHist h s`,
  where `Restr_{K(X)}(extendHist h s) = restrFold ωs (extendHist h s)` for the
  finite token list `ωs` of K(X)-outside elements. Stated as a hypothesis
  bundle `hRestr : Restr = restrFold ωs (extendHist h s)`, `hOut : all out`.

**Bridge.** L.F's "generalized Restr_S" is exactly the finite iteration of A.4's
token-replacement `τ_ω` over the out-of-K tokens of `s` (the doc note in
`L_F_proof.md` §1.2/§2.2: "由 A.4 对每个 ω ∈ tokens(s) \ K(X) 迭代应用 τ_ω 不
变性（有限次，s ∈ Σ* 是有限串）"). `restrFold` is that iteration; the only opaque
input is the concrete out-of-K token list `ωs`, taken as a hypothesis. This is
the rigorous A.4-based kernel, no `sorry`.

This file uses only axiom A.4 (`MIP.Axioms.A4`); no new axioms introduced.
-/
import MIP.Axioms

namespace MIP

namespace Lemma_LF

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-- **Iterated token replacement.** Replace each `ω ∈ ωs` (a finite list of
knowledge elements) in the history `g`, left to right. This is the concrete
realisation of the generalized restriction operator `Restr_S` of L.F §1.2 as a
finite fold of A.4's `tokenReplace`. -/
def restrFold (ωs : List Ω) (g : Str α) : Str α :=
  ωs.foldl (fun acc ω => tokenReplace ω acc) g

@[simp] lemma restrFold_nil (g : Str α) :
    restrFold ([] : List Ω) g = g := rfl

@[simp] lemma restrFold_cons (ω : Ω) (ωs : List Ω) (g : Str α) :
    restrFold (ω :: ωs) g = restrFold ωs (tokenReplace ω g) := rfl

/-- **L.F — frame compatibility (iterated A.4 over an out-of-K token list).**

If every `ω` in the list `ωs` lies outside `K X`, then `X` cannot distinguish
the original history `g` from `restrFold ωs g` (the history with all those
tokens replaced):

    X g = X (restrFold ωs g) .

Proof: induction on `ωs`. The empty list is `rfl`. For `ω :: ωs`, apply A.4
once to move `g ↦ tokenReplace ω g` (using `ω ∉ K X`), then the induction
hypothesis on the tail. This is the finite-iteration argument of L_F_proof.md
§2.2. -/
theorem frame_compat_fold
    (X : Agent α) (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    ∀ g : Str α, X g = X (restrFold ωs g) := by
  induction ωs with
  | nil => intro g; rfl
  | cons ω rest ih =>
      intro g
      -- A.4: X g = X (tokenReplace ω g), since ω ∉ K X.
      have hω : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self)
      have hstep : X g = X (tokenReplace ω g) := A4 X ω g hω
      -- Tail hypotheses: every element of `rest` is also out of K X.
      have hrest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) := by
        intro ω' hω'
        exact hOut ω' (List.mem_cons_of_mem _ hω')
      -- Combine: X g = X (tokenReplace ω g) = X (restrFold rest (tokenReplace ω g)).
      rw [hstep, restrFold_cons]
      exact ih hrest (tokenReplace ω g)

/-- **L.F — response isomorphism (the downstream form, corollary (2')).**

For any history `h` and intervention `s`, if `Restr` is the `K(X)`-restriction
of `extendHist h s` realised as `restrFold ωs (extendHist h s)` for a finite
list `ωs` of K(X)-outside knowledge elements, then

    X (extendHist h s) = X (extendHist h s with the out-of-K tokens replaced)
                       = X Restr .

This is exactly L.F's `𝓛(X(h·s)) = 𝓛(X(h·Restr_{K(X)}(s)))`. The hypothesis
bundle `hRestr` identifies the abstract `Restr` with the concrete iterated
replacement; `hOut` says the replaced elements are out of `K X`. -/
theorem frame_compat
    (X : Agent α) (h s : Str α) (ωs : List Ω) (Restr : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (hRestr : Restr = restrFold ωs (extendHist h s)) :
    X (extendHist h s) = X Restr := by
  rw [hRestr]
  exact frame_compat_fold X ωs hOut (extendHist h s)

/-- **L.F — `K(X)`-internalisation (corollary (1')), structural form.**

After restriction, `X`'s response depends only on the `K(X)`-internal content:
`X (extendHist h s)` and `X Restr` are *literally the same distribution*
(equality of `PMF`, hence total-variation distance `0`). This packages
`frame_compat` as the statement that the restriction is response-preserving —
the precise, exact form of L.F's "X 看到的就是 K(X)-限制版本". -/
theorem frame_compat_pmf_eq
    (X : Agent α) (h s : Str α) (ωs : List Ω) (Restr : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (hRestr : Restr = restrFold ωs (extendHist h s)) :
    X (extendHist h s) = X Restr :=
  frame_compat X h s ωs Restr hOut hRestr

end Lemma_LF

end MIP
