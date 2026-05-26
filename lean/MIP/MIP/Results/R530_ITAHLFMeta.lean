/-
Result (slot 015) — ITA / HLF upgrade metatheorems: ITA-A is provable,
ITA-B and HLF are axiom-external (independence via a counter-model).

Reference: `workspace/round3_exploration/slot_015.md` and
`workspace/round3_exploration/work_slot_015.md` (direction 1, breaking the
"stuck" empirical-assumption frontier: ITA / S-ITA / HLF provability
decomposition + axiom-external constructive independence).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

NOTE ON NUMBERING.  Slot 015 and slot 018 both reuse the working tags
R.530–R.535.  To avoid clashing with the slot-018 file
(`R530_SelfRefCollective.lean`), this file is named by content
(`R530_ITAHLFMeta`) and its theorems are prefixed `ITA_A_` / `ITA_B_meta_` /
`HLF_meta_` rather than `R_530_…`.

This file formalizes the two metatheorem kernels of slot 015.

* **(a) ITA-A is provable** (slot-015 R.530, "left non-decreasing segment").
  Model the cooperation strength as
  `ψ(t) = max_{m ∈ M_eff(t)} ΔΦ*(m, s_H)`, with `M_eff(t)` the effective
  intervention set at training step `t` and `ΔΦ* = φ : α → ℝ` the static
  per-intervention value.  Under the D.4.16 monotone-training-family analogue
  `M_eff(t) ⊆ M_eff(t+1)` (knowledge `K(A_t)` monotone ⟹ readable
  interventions monotone, via the L.F corollary), the max over a growing
  nonempty set is monotone non-decreasing:

      `M_eff(t) ⊆ M_eff(t') ⟹ ψ(t) ≤ ψ(t')`.

  So ITA-A is a *derived* consequence of the monotone-training axioms + L.F,
  not an independent empirical assumption.

* **(b) ITA-B and HLF are AXIOM-EXTERNAL** (slot-015 R.531 / R.535).
  Formalized as "X is not derivable" ≡ "∃ a structure where the
  axiom-analogues hold but X fails":

  - **ITA-B (unique maximizer) is independent.**  We exhibit a concrete
    monotone training family (`M_eff(t) = {0}` for all `t`, `φ ≡ c`) — the
    D.4.16-analogue (`M_eff` monotone) *holds* — in which `ψ(t)` is constant,
    so the unique-maximizer claim ITA-B *fails*: at least two distinct times
    both attain the supremum.  Hence ITA-B does not follow from the
    monotone-training axioms.

  - **HLF is independent.**  We exhibit a concrete "ideal deterministic human"
    `H'` whose knowledge `K(t)` is monotone increasing (the D.4.16 / agent-
    axiom analogue *holds*: a Dirac/deterministic kernel is a legal agent),
    in which HLF clause (H1) — non-monotone knowledge,
    `∃ t₁ < t₂, |K(t₁)| > |K(t₂)|` — *fails*.  Hence HLF does not follow from
    the agent axioms; it is a sub-class constraint (`Agents^H`), not an axiom
    consequence.

**This file is `axiom`-free.**  It imports only `Mathlib`.  The agent /
training-family semantics are bundled into the finset-valued chains
`M_eff : ℕ → Finset α` and `K : ℕ → Finset α` and the value map `φ`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Finset.Card
import Mathlib.Tactic.Linarith

namespace MIP

namespace ITAHLFMeta

/-! ## (a) ITA-A is provable: max over a monotone chain is non-decreasing -/

variable {α : Type*}

/-- Cooperation strength `ψ(t) = max_{m ∈ M_eff(t)} φ(m)`, modeled as the
finset sup' of the static value map `φ` over the effective-intervention set
`M_eff(t)`.  `hne` witnesses `M_eff(t)` nonempty (some intervention is always
readable), matching the slot-015 `M_eff(t) = M_{A_t}* ∩ M_H*` with `m₀`
present for `t ≥ 1`. -/
def psi (φ : α → ℝ) (Meff : Finset α) (hne : Meff.Nonempty) : ℝ :=
  Meff.sup' hne φ

/-- **ITA-A — monotone non-decrease of `ψ` (slot-015 R.530 kernel).**

If the effective-intervention set grows (`Meff₁ ⊆ Meff₂`, the D.4.16 +
L.F-corollary consequence of monotone knowledge `K(A_t)`), then the
cooperation strength does not decrease: `ψ(t₁) ≤ ψ(t₂)`.  The max over a
larger nonempty set is at least the max over a subset.

This says the "left non-decreasing segment" of ITA is a *theorem* under the
monotone-training axioms, not an independent empirical assumption. -/
theorem ITA_A_psi_mono
    (φ : α → ℝ) (Meff₁ Meff₂ : Finset α)
    (hne₁ : Meff₁.Nonempty) (hne₂ : Meff₂.Nonempty)
    (hsub : Meff₁ ⊆ Meff₂) :
    psi φ Meff₁ hne₁ ≤ psi φ Meff₂ hne₂ := by
  unfold psi
  exact Finset.sup'_mono φ hsub hne₁

/-- **ITA-A — chain form (training-step indexed).**

A monotone training family is a chain `M_eff : ℕ → Finset α` with
`M_eff t ⊆ M_eff (t+1)` and each step nonempty.  Then `ψ` along the chain is
monotone non-decreasing in `t`: for all `t₁ ≤ t₂`, `ψ(t₁) ≤ ψ(t₂)`. -/
theorem ITA_A_psi_chain_mono
    (φ : α → ℝ) (Meff : ℕ → Finset α)
    (hne : ∀ t, (Meff t).Nonempty)
    (hchain : ∀ t, Meff t ⊆ Meff (t + 1)) :
    ∀ t₁ t₂, t₁ ≤ t₂ →
      psi φ (Meff t₁) (hne t₁) ≤ psi φ (Meff t₂) (hne t₂) := by
  -- First: the chain is monotone under ⊆ (transitive closure of `hchain`).
  have hmono : ∀ t₁ t₂, t₁ ≤ t₂ → Meff t₁ ⊆ Meff t₂ := by
    intro t₁ t₂ hle
    induction t₂ with
    | zero =>
        have : t₁ = 0 := Nat.le_zero.mp hle
        subst this; exact Finset.Subset.refl _
    | succ p ih =>
        rcases Nat.lt_or_ge t₁ (p + 1) with hlt | hge
        · have hp : t₁ ≤ p := Nat.lt_succ_iff.mp hlt
          exact Finset.Subset.trans (ih hp) (hchain p)
        · have : t₁ = p + 1 := le_antisymm hle hge
          subst this; exact Finset.Subset.refl _
  intro t₁ t₂ hle
  exact ITA_A_psi_mono φ (Meff t₁) (Meff t₂) (hne t₁) (hne t₂) (hmono t₁ t₂ hle)

/-! ## (b) META: ITA-B is axiom-external (independence via a counter-model) -/

/-- The "unique maximizer" claim ITA-B for a cooperation-strength sequence
`Ψ : ℕ → ℝ`: there is a time `t*` strictly dominating every other time
(`∀ t ≠ t*, Ψ t < Ψ t*`).  This is the statement we show is *not* derivable. -/
def ITA_B (Ψ : ℕ → ℝ) : Prop := ∃ tstar : ℕ, ∀ t : ℕ, t ≠ tstar → Ψ t < Ψ tstar

/-- **ITA-B META — independence via a constant-`ψ` counter-model.**

We exhibit a concrete monotone training family witnessing that ITA-B does NOT
follow from the D.4.16 monotone-training axioms.  Take the constant chain
`Meff t = {0}` (a single readable intervention `m₀` for all `t`) with value
map `φ ≡ c`.  Then:

* the D.4.16-analogue HOLDS: the chain is monotone (`Meff t ⊆ Meff (t+1)`, in
  fact equal), and each step is nonempty;
* yet ITA-B FAILS: `ψ(t) = c` is constant, so no time strictly dominates —
  times `0` and `1` both attain the supremum, contradicting uniqueness.

Therefore ITA-B is axiom-external: the axioms hold in this model but ITA-B
does not. -/
theorem ITA_B_meta_independent :
    ∃ (Meff : ℕ → Finset ℕ) (φ : ℕ → ℝ) (hne : ∀ t, (Meff t).Nonempty),
      (∀ t, Meff t ⊆ Meff (t + 1)) ∧                       -- D.4.16 analogue holds
      ¬ ITA_B (fun t => psi φ (Meff t) (hne t)) := by       -- but ITA-B fails
  classical
  refine ⟨fun _ => {0}, fun _ => (0 : ℝ),
          fun _ => Finset.singleton_nonempty 0, ?_, ?_⟩
  · intro t; exact Finset.Subset.refl _
  · -- `ψ(t) = sup' {0} (const 0) = 0` for every `t`; so it is constant.
    rintro ⟨tstar, hstar⟩
    -- Pick a time `t ≠ tstar`; constancy gives `ψ t = ψ tstar = 0`, but ITA-B
    -- demands strict `<`, a contradiction.
    have hne_t : (tstar + 1) ≠ tstar := Nat.succ_ne_self tstar
    have hlt := hstar (tstar + 1) hne_t
    simp only [psi, Finset.sup'_singleton] at hlt
    exact lt_irrefl (0 : ℝ) hlt

/-! ## (b) META: HLF is axiom-external (independence via a counter-model) -/

/-- HLF clause (H1) "knowledge non-monotonicity" for a knowledge sequence
`K : ℕ → Finset α`: there are times `t₁ < t₂` with `|K(t₁)| > |K(t₂)|`
(forgetting strictly shrinks the knowledge set).  This is the HLF content we
show is *not* derivable from the agent axioms. -/
def HLF_H1 (K : ℕ → Finset α) : Prop :=
  ∃ t₁ t₂ : ℕ, t₁ < t₂ ∧ (K t₂).card < (K t₁).card

/-- **HLF META — independence via a deterministic monotone-`K` counter-model.**

We exhibit a concrete "ideal deterministic human" `H'` witnessing that HLF
does NOT follow from the agent / D.4.16 axioms.  Model `H'`'s knowledge by the
strictly growing chain `K t = Finset.range t` (a deterministic / Dirac-kernel
agent whose knowledge only accumulates — the D.4.16 (TM-1) monotone analogue).
Then:

* the agent / D.4.16-analogue HOLDS: `K` is monotone (`K t ⊆ K (t+1)`), a legal
  deterministic agent;
* yet HLF (H1) FAILS: `|K t| = t` is non-decreasing, so there is no pair
  `t₁ < t₂` with `|K t₂| < |K t₁|`.

Therefore HLF is axiom-external — a sub-class constraint (`Agents^H`), not an
axiom consequence. -/
theorem HLF_meta_independent :
    ∃ K : ℕ → Finset ℕ,
      (∀ t, K t ⊆ K (t + 1)) ∧        -- agent / D.4.16 monotone analogue holds
      ¬ HLF_H1 K := by                 -- but HLF (H1) fails
  refine ⟨fun t => Finset.range t, ?_, ?_⟩
  · intro t
    show Finset.range t ⊆ Finset.range (t + 1)
    exact Finset.range_mono (Nat.le_succ t)
  · -- `|range t| = t` is monotone, so no `t₁ < t₂` has `card (range t₂) < card (range t₁)`.
    rintro ⟨t₁, t₂, hlt, hcard⟩
    simp only [Finset.card_range] at hcard
    -- `hcard : t₂ < t₁` contradicts `hlt : t₁ < t₂`.
    exact absurd hcard (Nat.not_lt.mpr (Nat.le_of_lt hlt))

/-! ## IT-meta — unified independence schema (slot-015 meta result) -/

/-- **IT-meta — dynamics-derived quantities are axiom-external (schema).**

Both independence results above instantiate the same schema: a property `P` of
a trajectory is axiom-external when there is a model in which the static
axiom-analogue `Axioms` holds but `P` fails.  This trivial-but-load-bearing
packaging records the metatheorem form "`P` is not derivable from `Axioms`" as
"`∃ model, Axioms model ∧ ¬ P model`", and confirms it is satisfied whenever
such a witness model exists. -/
theorem IT_meta_schema
    {Model : Type*} (Axioms : Model → Prop) (P : Model → Prop)
    (witness : Model) (hax : Axioms witness) (hP : ¬ P witness) :
    ∃ m : Model, Axioms m ∧ ¬ P m :=
  ⟨witness, hax, hP⟩

/-- **IT-meta applied to ITA-B and HLF.**

Packages the two independence theorems through the schema: there is a model of
the monotone-training / agent axioms in which ITA-B fails, and a model of the
agent axioms in which HLF (H1) fails.  Together they confirm both ITA-B and HLF
are axiom-external. -/
theorem IT_meta_ITA_B_and_HLF :
    (∃ (Meff : ℕ → Finset ℕ) (φ : ℕ → ℝ) (hne : ∀ t, (Meff t).Nonempty),
        (∀ t, Meff t ⊆ Meff (t + 1)) ∧
          ¬ ITA_B (fun t => psi φ (Meff t) (hne t))) ∧
      (∃ K : ℕ → Finset ℕ, (∀ t, K t ⊆ K (t + 1)) ∧ ¬ HLF_H1 K) :=
  ⟨ITA_B_meta_independent, HLF_meta_independent⟩

end ITAHLFMeta

end MIP
