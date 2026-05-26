/-
Result R.400 — In-Context Learning (ICL) as MIP with `K(A)` frozen.

Reference: `~/Desktop/MIP/workspace/theory_unification.md` §R.400
("In-Context Learning (ICL) 作为 A.3 + Cₑ 的直接应用", 2026-05-16).

**Mapping conditions (taken as explicit hypotheses).**
* **(I-frozen)** In-context learning performs *no parameter update*: the
  knowledge set `K(A)` is unchanged by the prompt (`K` is *frozen*).
  The prompt only re-weights which `ω ∈ K(A)` are activated.
* **(I-cover)** A.2 (coverage axiom): the emergence cost `N(p, A)` is
  *finite* **iff** the problem's knowledge demand `R(p)` is covered by
  the agent's knowledge set, `R(p) ⊆ K(A)`.  (When `R(p) ⊄ K(A)`,
  `N = ∞`: no amount of prompting solves an out-of-knowledge task.)
* **(I-prompt)** An in-context example / prompt `e` carries knowledge
  `K(e)`.  By A.3 a prompt can only *activate* knowledge the agent
  already has: an effective expert intervention requires `K(e) ⊆ K(A)`.

**Statement (the degeneration).**  Model `R(p)`, `K(A)` and the prompt
contribution `K(e)` as `Finset`s over a knowledge universe.  With `K`
frozen, the MIP finiteness statement `N(p,A) < ∞` is *equivalent* to the
ICL coverage threshold `R(p) ⊆ K(A)` (the "k-shot becomes effective once
`|K(A)| ⊇ R(p)`" claim).  We encode A.2 as `N < ∞ ↔ R(p) ⊆ K(A)` and
derive:

1. **Degeneration biconditional** — ICL-effective `↔` coverage `↔` MIP
   finite.
2. **Prompt-engineering ceiling** — if coverage fails (`R(p) ⊄ K(A)`),
   then *no* admissible prompt `e` (with `K(e) ⊆ K(A)`, the A.3 premise)
   can repair coverage: `R(p) ⊄ K(A) ∪ K(e)`.  An out-of-knowledge task
   cannot be solved by prompting alone.
3. **Coverage monotone in the frozen set** — enlarging `K(A)` (e.g. a
   larger model) can only turn coverage on, never off; this is the
   "ICL emergence at the `|K(A)| ⊇ R(p)` scale threshold" claim.

We work with an abstract emergence cost in `ℕ∞ = ℕ ∪ {∞}` so that
"`N < ∞`" is literal.

**This file is `axiom`-free.**  It imports only Mathlib.  A.2 enters as
an explicit hypothesis; the equality/biconditional with the ICL
condition is what is proved.
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.ENat.Basic
import Mathlib.Order.Basic

namespace MIP

namespace ICLDegeneration

variable {Ω : Type*} [DecidableEq Ω]

/-- The emergence cost `N(p, A)` lives in `ℕ∞ = ℕ ∪ {∞}` so that the MIP
finiteness statement `N < ∞` is the literal "`N ≠ ∞`". -/
abbrev Cost := ℕ∞

/-- **A.2 (coverage axiom), the frozen-`K` ICL hypothesis bundle.**

`R` is the knowledge demand `R(p)`; `K` is the (frozen) knowledge set
`K(A)`.  `N` is the emergence cost.  `hA2` is the coverage axiom:
finiteness holds *iff* the demand is covered. -/
structure ICL (Ω : Type*) [DecidableEq Ω] where
  /-- Knowledge demand `R(p)` of the problem. -/
  R : Finset Ω
  /-- Frozen knowledge set `K(A)` of the agent (unchanged by the prompt). -/
  K : Finset Ω
  /-- Emergence cost `N(p, A) ∈ ℕ∞`. -/
  N : Cost
  /-- **A.2** — `N(p,A)` is finite iff `R(p) ⊆ K(A)`. -/
  hA2 : N ≠ ⊤ ↔ R ⊆ K

/-- **R.400 (i) — ICL-degeneration biconditional.**

With `K` frozen, the MIP finiteness statement `N(p,A) < ∞` is *exactly*
the ICL coverage threshold `R(p) ⊆ K(A)`.  This is the formal content of
"k-shot becomes effective once `|K(A)| ⊇ R(p)`": effectiveness `↔`
coverage `↔` finite emergence cost. -/
theorem R_400_i_degeneration (D : ICL Ω) :
    D.N ≠ ⊤ ↔ D.R ⊆ D.K :=
  D.hA2

/-- **R.400 (i)′ — effectiveness equals finiteness as propositions.**

The ICL-effective predicate (`coverage`) and the MIP-finite predicate
(`N < ∞`) are the *same* proposition. -/
theorem R_400_i_iff_finite (D : ICL Ω) :
    (D.R ⊆ D.K) ↔ (D.N ≠ ⊤) :=
  D.hA2.symm

/-- **R.400 (ii) — prompt-engineering ceiling.**

If coverage already fails (`R(p) ⊄ K(A)`), then *no* admissible prompt
`e` — i.e. one satisfying the A.3 premise `K(e) ⊆ K(A)` ("a prompt can
only activate knowledge the agent already has") — can repair coverage:
`R(p) ⊄ K(A) ∪ K(e)`.  Because `K(e) ⊆ K(A)` forces `K(A) ∪ K(e) = K(A)`,
adding the prompt does not enlarge the frozen set.  An out-of-knowledge
task cannot be solved by prompting alone. -/
theorem R_400_ii_prompt_ceiling
    (R K Ke : Finset Ω)
    (hAdmissible : Ke ⊆ K)        -- A.3 premise: K(e) ⊆ K(A)
    (hNoCover : ¬ R ⊆ K) :        -- coverage fails
    ¬ R ⊆ K ∪ Ke := by
  -- K(e) ⊆ K(A) ⟹ K(A) ∪ K(e) = K(A), so prompting cannot help.
  have hunion : K ∪ Ke = K := Finset.union_eq_left.mpr hAdmissible
  rwa [hunion]

/-- **R.400 (ii)′ — the prompt-frozen identity behind the ceiling.**

Admissible prompts leave the frozen set unchanged: `K(A) ∪ K(e) = K(A)`.
This is the algebraic kernel of the prompt-engineering ceiling and of
"K is frozen": ICL never adds knowledge. -/
theorem R_400_ii_frozen_identity
    (K Ke : Finset Ω) (hAdmissible : Ke ⊆ K) :
    K ∪ Ke = K :=
  Finset.union_eq_left.mpr hAdmissible

omit [DecidableEq Ω] in
/-- **R.400 (iii) — coverage is monotone in the frozen set (scale → emergence).**

Enlarging the knowledge set `K(A) ⊆ K(A')` (e.g. a larger model) can only
turn coverage *on*, never off: if `R(p) ⊆ K(A)` then `R(p) ⊆ K(A')`.
This is the MIP statement of ICL "emergence" — once a model scales past
the `|K(A)| ⊇ R(p)` threshold it stays effective. -/
theorem R_400_iii_coverage_monotone
    (R K K' : Finset Ω)
    (hScale : K ⊆ K')             -- larger model: K(A) ⊆ K(A')
    (hCover : R ⊆ K) :            -- ICL effective at scale K
    R ⊆ K' :=
  hCover.trans hScale

/-- **R.400 (iii)′ — emergence threshold restated as finiteness transport.**

If a larger model `A'` (frozen set `K'`) extends `A` (`K ⊆ K'`) and ICL is
already effective at `A` (`N < ∞`, hence `R ⊆ K` by A.2), then ICL is
effective at `A'` (`N' < ∞`).  Both agents carry their own A.2. -/
theorem R_400_iii_emergence_transport
    (D D' : ICL Ω)
    (hSameDemand : D.R = D'.R)
    (hScale : D.K ⊆ D'.K)
    (hEffective : D.N ≠ ⊤) :
    D'.N ≠ ⊤ := by
  -- A.2 for A: N ≠ ⊤ ⟹ R ⊆ K.  Scale up.  A.2 for A': R' ⊆ K' ⟹ N' ≠ ⊤.
  have hCover : D.R ⊆ D.K := D.hA2.mp hEffective
  have hCover' : D'.R ⊆ D'.K := by
    rw [← hSameDemand]; exact hCover.trans hScale
  exact D'.hA2.mpr hCover'

end ICLDegeneration

end MIP
