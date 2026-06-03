/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 8
  DIRECTION: A — R.810 (silence collapse) + R.815 (no-injection) ⟹
             silent agents under no-injection regime collapse to trivial
             collective `Ncollab = ⊤`, even when single-agent solvability
             on the post-dialogue receiver is preserved.

  SUMMARY:
    Two-result joint impossibility for the multi-agent family.

    R.815 (`no_injection_solvability_invariant`) says that a knowledge-set-
    preserving dialogue cannot turn an A.2-unsolvable receiver into a
    solvable one. R.810 (`silence_collapse`) says that the receiver `Y`
    cannot break the barrier because of the gap token `ω* ∉ K(Y)`. Compose:
    in the silence-collapse model, every pure dialogue with `Y` leaves
    `K(Y)` unchanged (R.815's iterated form), so `N(p, Y)` is dialogue-
    invariant — it is solvable iff a pre-dialogue solution exists. But
    R.810 forces `Ncollab = ⊤`, so even the dialogue's *whole information
    pipe* is closed for `Y`.

    Concretely we prove:
      1. (R.815) For a silence-collapse model `M`, any out-of-`K(Y)`
         dialogue turn (in particular a turn made entirely of the gap
         token `ω*`) leaves `Y`'s output law unchanged at every history.
      2. (R.815 corollary) If a post-dialogue receiver `Y'` has the same
         knowledge set as `Y`, its A.2 solvability is identical to `Y`'s.
      3. (R.810 ⊕ R.815) Even though `Y` (or `Y'`) could be A.2-solvable
         in isolation, the silence-collapse mechanism still forces
         `Ncollab = ⊤`. So: collaborative collapse persists across any
         no-injection-equivalent receiver.

  R-DEPS:
    • MIP.Results.R810_SilenceCollapse  (CollabModel, Ncollab_top, no_Y_break)
    • MIP.Results.R815_NoInjection      (no_injection_step, no_injection_seq,
                                         no_injection_solvability_invariant)
-/
import MIP.Results.R810_SilenceCollapse
import MIP.Results.R815_NoInjection

namespace MIP

namespace R3_Agent8_SilenceNoInjection

open MIP.Axioms
open MIP.R810_SilenceCollapse

variable {α Ω : Type}

/-! ### Part 1 — A gap-token-only dialogue turn is inert on `Y`.

The silence-collapse model's `gapToken ω* ∉ K(Y)`, so a dialogue turn made of
any list of `ω*` tokens (a "monochrome gap-token turn") is uniformly inert on
`Y` by R.815's iterated `no_injection_seq`. -/

/-- **R.810 ⊕ R.815 — `ω*`-monochrome dialogue turn is inert on `Y`.**

Any history `h` and any list `ωs` of gap-tokens (`∀ ω ∈ ωs, ω = M.gapToken`)
satisfies `Y h = Y (foldr τ ωs h)`. R.815's `no_injection_seq` applied to
`Y` (with `ω ∉ K Y` discharged by `M.gap_out_of_Y`) closes it. -/
theorem gap_turn_inert
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p)
    (ωs : List Ω) (h : Str α)
    (hAll : ∀ ω ∈ ωs, ω = M.gapToken) :
    Y h = Y (ωs.foldr (fun ω hh => tokenReplace ω hh) h) :=
  R815_NoInjection.no_injection_seq (Ω := Ω) Y ωs h
    (fun ω hω => by
      have heq : ω = M.gapToken := hAll ω hω
      rw [heq]
      exact M.gap_out_of_Y)

/-! ### Part 2 — Knowledge-set preservation is invariant across the dialogue.

R.815's `no_injection_solvability_invariant` says that A.2-solvability of `p`
is fixed under any dialogue that fixes `K Y`. So: if a post-dialogue receiver
`Y'` has `K Y' = K Y`, then `N(p, Y') ≠ ⊤ ↔ N(p, Y) ≠ ⊤`. We instantiate this
for the silence-collapse model's `Y`. -/

/-- **R.810 ⊕ R.815 — receiver solvability is dialogue-invariant.**

For any post-dialogue receiver `Y'` with the same knowledge set as the
silence-collapse model's `Y` (the no-injection conclusion), `N(p, Y')`'s
A.2-finiteness matches `N(p, Y)`'s. This is R.815's invariance instantiated
in the R.810 setting. -/
theorem receiver_solvability_invariant
    (X Y Y' : Agent α) (p : Problem α)
    (_M : CollabModel (Ω := Ω) X Y p)
    (h_K : (K Y' : Set Ω) = (K Y : Set Ω)) :
    N p Y' ≠ ⊤ ↔ N p Y ≠ ⊤ :=
  R815_NoInjection.no_injection_solvability_invariant (Ω := Ω) p Y Y' h_K

/-! ### Part 3 — Joint collapse: `Ncollab = ⊤` persists across dialogue.

R.810's `Ncollab_top` says the collaborative emergence degree is `⊤` for the
silence-collapse model. Combined with R.815: even after any pure-dialogue
process (no parameter update), the resulting receiver has the same K and the
collaboration still collapses. So the silence-collapse pathology is robust
to the entire no-injection dialogue equivalence class. -/

/-- **R.810 ⊕ R.815 joint impossibility — silent collapse is dialogue-stable.**

For a silence-collapse model `M`, the collaborative emergence degree is `⊤`
(R.810), and *any* dialogue-equivalent post-dialogue receiver `Y'` (with
`K Y' = K Y`, the no-injection hypothesis from R.815) has its A.2-solvability
status fixed at `Y`'s. In particular, no amount of in-dialogue interaction
can convert the silent collapse into a finite `N` even at the receiver level.

Stated cleanly: `Ncollab = ⊤ ∧ N p X ≠ ⊤ ∧ (N p Y' ≠ ⊤ ↔ N p Y ≠ ⊤)`. -/
theorem silent_no_injection_joint_collapse
    (X Y Y' : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p)
    (h_K : (K Y' : Set Ω) = (K Y : Set Ω)) :
    M.Ncollab = ⊤ ∧ N p X ≠ ⊤ ∧ (N p Y' ≠ ⊤ ↔ N p Y ≠ ⊤) :=
  ⟨Ncollab_top X Y p M,
   N_single_finite X Y p M,
   receiver_solvability_invariant X Y Y' p M h_K⟩

/-- **R.810 ⊕ R.815 — single-token dialogue collapse.**

A *single* `ω*`-token dialogue turn (the elementary atom of a gap-token
dialogue) is inert on `Y`, and the silence collapse `Ncollab = ⊤` persists.
The simplest concrete form of the joint impossibility. -/
theorem single_token_dialogue_collapse
    (X Y : Agent α) (p : Problem α)
    (M : CollabModel (Ω := Ω) X Y p) (h : Str α) :
    Y h = Y (tokenReplace M.gapToken h)
      ∧ M.Ncollab = ⊤ :=
  ⟨R815_NoInjection.no_injection_step (Ω := Ω) Y M.gapToken h M.gap_out_of_Y,
   Ncollab_top X Y p M⟩

end R3_Agent8_SilenceNoInjection

end MIP
