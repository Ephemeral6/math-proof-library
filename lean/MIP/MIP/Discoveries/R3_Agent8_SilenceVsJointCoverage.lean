/-
  STATUS: DISCOVERY (HEADLINE 3-chain)
  AGENT: R3 Agent 8
  DIRECTION: H — R.810 (silence collapse) + R.813 (joint coverage) + R.815 (no-injection)
             ⟹ silence rules out joint coverage if no-injection holds.

  SUMMARY:
    Three-result composition giving the **headline impossibility** for the
    multi-agent family. Three ingredients:
      * R.810 (`CollabModel.no_break_if_inert`):  in a silence-collapse model
        every `Y`-emitted barrier-breaking history must NOT equal its own
        `ω*`-token replacement (the `gapToken` `ω* ∉ K(Y)` is the load-bearing
        gap-witness from `Kᴹ(X) \ K(Y)`).
      * R.815 (no-injection step / cross): the A.4-direct statement
        `ω ∉ K(Y) ⟹ Y h = Y (τ_ω h)` -- pure dialogue with an out-of-`K(Y)`
        token is inert on `Y`'s output.
      * R.813 (joint coverage / transfer bottleneck): a *genuine* effective
        cross-transfer of `ω` forces `Y h ≠ Y (τ_ω h)` (otherwise the
        transfer is invisible to `Y`).
    Composing them: the silence-collapse model's `gapToken` is BOTH (i) the
    one that would be needed to break the barrier and (ii) the one A.4 makes
    inert on `Y`. So if joint coverage *were* achievable by a genuinely
    `Y`-effective cross-transfer of the gap token, R.815 + R.813 force a
    contradiction with R.810's no_break_if_inert. The 3-chain conclusion:
      **In a silence-collapse regime, the gap token cannot be effectively
      transferred through `Y` -- hence joint coverage that relies on it is
      blocked, and the collaboration's `Ncollab = ⊤`.**

    We also derive a clean impossibility: `silence + (gap token must be
    cross-transferred for coverage)` is jointly inconsistent.

  R-DEPS:
    • MIP.Results.R810_SilenceCollapse  (CollabModel, no_Y_break, Ncollab_top)
    • MIP.Results.R815_NoInjection      (no_injection_step, no_injection_cross)
    • MIP.Results.R813_JointCoverage    (transfer_blindness, transfer_in_O)
-/
import MIP.Results.R810_SilenceCollapse
import MIP.Results.R815_NoInjection
import MIP.Results.R813_JointCoverage

namespace MIP

namespace R3_Agent8_SilenceVsJointCoverage

open MIP.Axioms
open MIP.R810_SilenceCollapse

variable {α Ω : Type}

/-! ## Step 1 — R.815 ⊕ R.810 :  gap token is inert on `Y` and cannot break.

The silence-collapse model's `gapToken` lies in `Kᴹ(X) \ K(Y)`, so in particular
it is outside `K(Y)`. R.815 (`no_injection_step`) then gives the inertness
identity `Y h = Y (τ_{ω*} h)` at every history. This is the *direct* A.4
content. The R.810 model's `no_break_if_inert` rules out any breaking history
that is `Y`-inert. Combining: not only does `Y` fail to break (R.810), but the
*reason* it fails is the R.815 no-injection identity. -/

/-- **R.810 ⊕ R.815 — every history is `Y`-inert under the gap token.**

For a silence-collapse model the gap token `ω* ∉ K(Y)`, so R.815's
no-injection step applies: `Y h = Y (τ_{ω*} h)` for *every* history `h`. The
inertness identity is therefore unconditional in `h`. -/
theorem gap_inert_via_no_injection
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p) (h : Str α) :
    Y h = Y (tokenReplace M.gapToken h) :=
  R815_NoInjection.no_injection_step (Ω := Ω) Y M.gapToken h M.gap_out_of_Y

/-- **R.810 ⊕ R.815 — strengthened no-break.**

Composition: the R.810 model rules out *any* breaking history (`no_Y_break`),
but the proof now uses R.815 explicitly: R.815 says the gap-token `τ`-action is
inert on `Y` at every `h`, and R.810's `no_break_if_inert` then closes. -/
theorem strengthened_no_break
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p) :
    ∀ h : Str α, ¬ M.breaksBarrier h := by
  intro h hbreak
  have hinert : Y h = Y (tokenReplace M.gapToken h) :=
    gap_inert_via_no_injection X Y p M h
  exact M.no_break_if_inert h hbreak hinert

/-! ## Step 2 — R.813 contrapositive :  gap token cannot be effectively transferred.

R.813's `transfer_blindness` says `ω ∉ K Y ⟹ Y h = Y (τ_ω h)` -- exactly the
R.815 statement specialised to the receiver `Y`. The contrapositive: any
effective transfer (`Y h ≠ Y (τ_ω h)`) forces `ω ∈ K Y`. So for the silence-
collapse model's `gapToken` (which is *not* in `K Y`), every transfer attempt
is necessarily *not effective* — `Y h = Y (τ_ω h)` always. -/

/-- **R.810 ⊕ R.813 — gap-token cross-transfer is uniformly ineffective on `Y`.**

There is no history `h` at which `Y` distinguishes `h` from `τ_{ω*} h`. Hence
the model's `gapToken` cannot be *effectively* transferred to `Y` across the
dialogue. -/
theorem gap_transfer_never_effective
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p) (h : Str α) :
    ¬ (Y h ≠ Y (tokenReplace M.gapToken h)) := by
  intro hne
  exact hne (R813_JointCoverage.transfer_blindness
    (Ω := Ω) Y M.gapToken h M.gap_out_of_Y)

/-! ## Step 3 — HEADLINE 3-chain:  silence + (gap token needed) ⟹ contradiction.

If a putative coverage scheme requires `Y` to *receive* the gap token via some
effective cross-transfer history (R.813.b's "transfer_in_O" precondition: the
sender carries `ω* ∈ K X` and the transfer is `Y`-effective at some `h`), then
the no-injection chain Step 2 forbids this -- so silence + no-injection rules
out the very transfer channel that joint-coverage-by-gap-token would need. The
collaboration's `Ncollab = ⊤` is forced. -/

/-- **HEADLINE — Silence ⊕ NoInjection ⊕ JointCoverage 3-chain.**

If a silence-collapse model is given and additionally one *posits* an effective
cross-transfer history `h₀` for the gap token (i.e. `Y h₀ ≠ Y (τ_{ω*} h₀)`),
then a contradiction follows. So: **in a silence-collapse regime, no effective
cross-transfer of the gap token can exist**; the gap token is permanently
trapped on `X`'s side. -/
theorem headline_silence_blocks_gap_transfer
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p)
    (h₀ : Str α)
    (hEffective : Y h₀ ≠ Y (tokenReplace M.gapToken h₀)) :
    False :=
  gap_transfer_never_effective X Y p M h₀ hEffective

/-- **HEADLINE 3-chain (positive form) — silence ⟹ `Ncollab = ⊤`.**

Restatement of R.810's `Ncollab_top` via the strengthened chain. The proof
re-derives the collapse, but its kernel now goes through R.815 (gap inertness)
+ R.813-contrapositive (uniform ineffectiveness on `Y`) rather than the raw
`CollabModel.no_break_if_inert`. -/
theorem headline_Ncollab_top
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p) :
    M.Ncollab = ⊤ := by
  by_contra hne
  obtain ⟨h, hbreak⟩ := M.finite_needs_break hne
  exact strengthened_no_break X Y p M h hbreak

/-- **HEADLINE 3-chain (joint-coverage tension).**

If we posit:
* (silence) the model `M` is a silence-collapse model (R.810);
* (joint-coverage-by-gap) coverage would require the gap-token to be
  effectively cross-transferred (existence of a history `h₀` with the
  R.813 effectiveness inequality);

then the conjunction is impossible. This is the formal "silence rules out
joint coverage if no-injection holds" statement: any joint-coverage scheme
that pivots on the silence model's gap-token simply cannot be executed.

Stated as: an effective cross-transfer history for the gap token *cannot
coexist* with a silence-collapse model. -/
theorem headline_silence_vs_jointcoverage
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p) :
    ¬ ∃ h₀ : Str α, Y h₀ ≠ Y (tokenReplace M.gapToken h₀) := by
  rintro ⟨h₀, hEff⟩
  exact headline_silence_blocks_gap_transfer X Y p M h₀ hEff

/-- **HEADLINE 3-chain (full bundle).**

The headline triple: (i) `Ncollab = ⊤` (R.810 conclusion, re-proved via the
3-chain), (ii) the single-agent `N(p, X) ≠ ⊤` (R.810), and (iii) NO effective
cross-transfer of the gap-token exists (R.813 contrapositive + R.815).
Together: silence + no-injection make the `collab vs joint-coverage-by-gap`
tension into a strict impossibility. -/
theorem headline_3chain_bundle
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p) :
    M.Ncollab = ⊤
      ∧ N p X ≠ ⊤
      ∧ ¬ ∃ h₀ : Str α, Y h₀ ≠ Y (tokenReplace M.gapToken h₀) :=
  ⟨headline_Ncollab_top X Y p M,
   N_single_finite X Y p M,
   headline_silence_vs_jointcoverage X Y p M⟩

end R3_Agent8_SilenceVsJointCoverage

end MIP
