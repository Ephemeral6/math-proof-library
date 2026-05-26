/-
Result R.802 — Questioner anonymity (QA).

Reference: `proofs/derived/A4_grade.md` R.802 (A 无条件).

**Statement.** Let `Y, Y'` be two questioner-identity agents whose inserted
tokens differ only outside `K(X)`.  Then, conditioned on the
`K(X)`-projection of the input, the questioner's identity (`Y` vs `Y'`) is
independent of `X`'s output distribution:

    I( 𝟙{questioner ∈ {Y, Y'}} ; L(π(X(input))) | Restr_{K(X)}(input) ) = 0 .

**Proof (same mechanism as N.7).**  By A.4, replacing any single token
`ω ∉ K(X)` in a history leaves `L(X(·))` unchanged.  If two questioner
insertions share the same `K(X)`-projection, then one is obtained from the
other by a finite sequence of out-of-`K(X)` token-replacements; iterating
A.4 over that sequence gives `L(X(h · I_Y)) = L(X(h · I_{Y'}))`, i.e. the
conditional distributions coincide, so the conditional mutual information
vanishes.

**Lean kernel.** The file is self-contained: it re-introduces the
out-of-`K` replacement fold locally (`replaceOutside`), proves that
applying it never changes `X`'s output (`anonymity_fold`), and states the
two-questioner anonymity corollary `anonymity` (two histories related by an
out-of-`K` replacement sequence are output-indistinguishable to `X`).

**This file is `axiom`-free** apart from the project's foundational
`MIP.Axioms.A4`.
-/
import MIP.Axioms

namespace MIP

namespace QuestionerAnonymity

open MIP.Axioms

variable {α Ω : Type}

/-- Self-contained out-of-`K` replacement fold (mirrors N.7's
`applyReplacements`, redefined locally so this file stands alone).

`replaceOutside h ωs` applies `τ_{ω₁} ∘ ⋯ ∘ τ_{ωₙ}` to the history `h`. -/
def replaceOutside (h : Str α) (ωs : List Ω) : Str α :=
  List.foldr tokenReplace h ωs

@[simp] theorem replaceOutside_nil (h : Str α) :
    replaceOutside h ([] : List Ω) = h := rfl

@[simp] theorem replaceOutside_cons (h : Str α) (ω : Ω) (ωs : List Ω) :
    replaceOutside h (ω :: ωs) = tokenReplace ω (replaceOutside h ωs) := rfl

/-- **R.802 core — output invariance under out-of-`K` replacements.**

If every token in `ωs` lies outside `K(X)`, then `X`'s output on `h`
agrees with its output on the replaced history.  This is the A.4 iteration
that underlies questioner anonymity. -/
theorem anonymity_fold
    (X : Agent α) (h : Str α) (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X h = X (replaceOutside h ωs) := by
  induction ωs with
  | nil => rfl
  | cons ω rest ih =>
    have hOut_rest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
      fun ω' hω' => hOut ω' (List.mem_cons_of_mem ω hω')
    have hOut_head : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
    calc
      X h = X (replaceOutside h rest) := ih hOut_rest
      _ = X (tokenReplace ω (replaceOutside h rest)) :=
            Axioms.A4 X ω (replaceOutside h rest) hOut_head
      _ = X (replaceOutside h (ω :: rest)) := by rw [replaceOutside_cons]

/-- **R.802 (QA) — questioner anonymity.**

If two questioner-identity histories `h₁` and `h₂` differ only by a finite
sequence `ωs` of token-replacements outside `K(X)` (i.e. `h₂` is `h₁` with
those out-of-`K` tokens substituted), then `X` produces the *same* output
distribution on both: `X h₁ = X h₂`.

Hence `X` cannot distinguish the two questioners from its output — only the
`K(X)`-projected content of the input is visible to `X`.  This is the
"metaphysical blind spot" of R.802. -/
theorem anonymity
    (X : Agent α) (h₁ h₂ : Str α) (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (h_rel : h₂ = replaceOutside h₁ ωs) :
    X h₁ = X h₂ := by
  rw [h_rel]
  exact anonymity_fold X h₁ ωs hOut

/-- **R.802 (QA) — projection form.**

If two questioner insertions `I_Y, I_{Y'}` (appended after a common prefix
`h`) project equally under `Restr_{K(X)}` — modelled here by the
hypotheses that both extended histories reduce, via out-of-`K`
replacements, to one common `K(X)`-projected history `c` — then `X` is
output-indistinguishable on them:

    X (h ++ I_Y) = X (h ++ I_{Y'}).

This is the conditional-distribution equality of R.802 whose conditional
mutual information is therefore `0`. -/
theorem anonymity_projection
    (X : Agent α) (hY hY' c : Str α) (ωs ωs' : List Ω)
    (hOut  : ∀ ω ∈ ωs,  ω ∉ (K X : Set Ω))
    (hOut' : ∀ ω ∈ ωs', ω ∉ (K X : Set Ω))
    (hProj  : c = replaceOutside hY ωs)
    (hProj' : c = replaceOutside hY' ωs') :
    X hY = X hY' := by
  -- Both project to the common K(X)-image `c`, with equal X-output.
  have e1 : X hY = X c := by rw [hProj]; exact anonymity_fold X hY ωs hOut
  have e2 : X hY' = X c := by rw [hProj']; exact anonymity_fold X hY' ωs' hOut'
  rw [e1, e2]

end QuestionerAnonymity

end MIP
