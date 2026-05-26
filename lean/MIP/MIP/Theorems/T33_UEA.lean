/-
Theorem T.33 — Universal Expert Accessibility (UEA).

Reference: `proofs/derived/A4_grade.md` R.801 ＝ T.33 (A 无条件).

**Statement.** A.3's hypothesis "`K(e) ⊆ K(A)`" can be removed under A.4.
For every `e ∈ Σ* \ M`, every history `h`, and every `ε > 0`, there is a
meta-cognitive sequence of length `≤ C_{e'} · log(1/ε)` whose effect on
the next response is `ε`-close (in total-variation) to that of `e`,
where `e'` is the `K(X)`-projection of `e`.

**Proof.**
1. A.4 iteration: `𝓛(π(r) | h·e) = 𝓛(π(r) | h·e')`.
2. Apply A.3 to `e'` (which satisfies `K(e') ⊆ K(A)`).
3. Compose to conclude.

**STATUS: PARTIAL.** Step 1 (A.4 iteration on the K(X)-projection) and
Step 2 (use of A.3) both require structures not yet in the opaque
signatures: an `extract` function returning `tokens(s) \ K(X)`, the
projection operator `Restr_{K(X)}`, and a "meta-cognitive concatenation"
operator chaining the `(m_i)` sequence as in A.3's conclusion. The
chaining is `ms.foldl (· ++ ·) []` in the existing axiom statement.

We state T.33 at the same opaque level as A.3, with a `sorry` to be
discharged once `Restr_{K(X)}` is in the signatures.
-/
import MIP.Axioms

namespace MIP

open MIP.Axioms

namespace UEA

variable {α : Type} {Ω : Type}

/-- **Restriction to `K(X)`**: the operator that drops every `K(X)`-outside
token in a string. Opaque at the current signature level. -/
opaque Restr (X : Agent α) (s : Str α) : Str α

/-- **Restr specification bundle (Path B form).**

The three properties of `Restr` required by T.33 — `K(X)`-cover, A.4
collapse, and non-meta preservation — are bundled as a `Prop`
predicate so they can be carried as a single hypothesis on the T.33
theorem instead of being asserted as three separate axioms.

Concrete callers establish this bundle by appealing to the
formalisation of `extract` / token-projection / L.F corollaries (1)
and (3), which lie beyond the current opaque signature layer. -/
def RestrSpec {α : Type} (Ω : Type) (X : Agent α) : Prop :=
  (∀ s : Str α,
      (expertKnowledge (Ω := Ω) (Restr X s)) ⊆ (K X : Set Ω))
  ∧
  (∀ (h s : Str α),
      X (extendHist h s) = X (extendHist h (Restr X s)))
  ∧
  (∀ s : Str α,
      s ∉ (MetaSet : Set (Str α)) → Restr X s ∉ (MetaSet : Set (Str α)))

/-- **T.33 (UEA).** A.3's `K(e) ⊆ K(A)` premise can be removed under the
`RestrSpec` bundle (which formalises the joint statement of `Restr`'s
K-cover, A.4 collapse, and non-meta preservation).

For any `e ∈ Σ* \ M`, history `h`, and `ε > 0`, there is a meta-cognitive
sequence of length `≤ Cₑ(Restr X e) · log(1/ε)` whose effect on the next
response is `ε`-close (in total-variation) to `e`'s effect on `X`.

Proof outline:
* (Step 1, `hSpec.2.1` = A.4 collapse): `X(h · e) = X(h · Restr X e)`.
* (Step 2, A.3 applied to `Restr X e`): such a sequence exists.
* (Step 3, transitivity): conclude. -/
theorem T33_UEA {Ω : Type} (X : Agent α) (e : Str α) (h : Str α) (ε : NNReal)
    (hε : 0 < ε) (hMem : e ∉ (MetaSet : Set (Str α)))
    (hSpec : RestrSpec (α := α) Ω X) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ (Restr X e) : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (extendHist h e))
              (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  obtain ⟨hKnow, hColl, hNonMeta⟩ := hSpec
  -- Apply A.4 collapse to replace `e` with `Restr X e`.
  have hcollapse : X (extendHist h e) = X (extendHist h (Restr X e)) :=
    hColl h e
  -- Apply A.3 to `Restr X e` (which satisfies the K(X)-cover premise).
  have hRestrNotMeta : Restr X e ∉ (MetaSet : Set (Str α)) :=
    hNonMeta e hMem
  have hCover : (expertKnowledge (Restr X e) : Set Ω) ⊆ (K X : Set Ω) :=
    hKnow e
  obtain ⟨ms, hmsM, hlen, htv⟩ :=
    Axioms.A3 (Ω := Ω) X (Restr X e) h ε hε hRestrNotMeta hCover
  refine ⟨ms, hmsM, hlen, ?_⟩
  -- Substitute `X(h · e) = X(h · Restr X e)` using `hcollapse`.
  rw [hcollapse]
  exact htv

end UEA

end MIP
