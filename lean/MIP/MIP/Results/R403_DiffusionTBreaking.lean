/-
Result R.403 — Diffusion forward/reverse process as time-symmetry breaking.

Reference: `C:/Users/12729/Desktop/MIP/workspace/theory_unification.md` §R.403
("Diffusion Models 训练动力学"; deps R.105, R.97, R.122, R.135, R.146, R.62,
T.5, D.4.4, D.3.3, D.1.2).

**Candidate / conditional note.**  The source marks R.403 as **C → B**: MIP has
no native "forward destruction" process, so the diffusion forward pass must be
modelled by an *externally introduced forgetting operator* `F_t` (a primitive
the MIP axiom system lacks — flagged for introduction as a new definition
`D.1.x`).  This file is therefore a **conditional formalization** that bundles
`F_t` as a given map and encodes only the time-asymmetry kernel; it does not
construct the forgetting operator.

**Statement (kernel).**  In diffusion (Sohl-Dickstein 2015 / DDPM Ho 2020 /
Song 2020):
* the **forward** process adds noise, raising the knowledge entropy toward
  uniform — `H_K(F_t A₀) → log|K(A₀)|` — i.e. it *forgets*;
* the **reverse** process is MIP training, lowering entropy toward the target
  (`dH_K/dt < 0`, concentrating).

The pair is **not** invariant under time reversal `t → -t`: forward ≠ reverse.
This is the R.105-style T-breaking (R.135 "looks reversible"): the diffusion
pair is mathematically invertible per step yet the *process direction* is
distinguished — `F_forward ≠ F_reverse`.

**HYPOTHESIS-BUNDLE.**  The un-formalizable primitive — the forgetting/noise
operator `F_t` — enters as an explicit bundled map (here, its effect on the
entropy coordinate `H_K`).  We model the forward step as a real-valued entropy
*increment* `fwd` and the reverse step as `rev`, with the bundled physical
signs: `0 < fwd` (entropy rises toward uniform) and `rev < 0` (entropy falls
toward the target).  The kernel proves the strict irreversibility
`fwd ≠ rev` and the time-reversal map sending `fwd ↦ -fwd` does NOT recover
`rev` unless the process is trivial.  No SDE, no Gaussian channel.

**This file is `sorry`-free and `axiom`-free.**  It imports only `Mathlib`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace DiffusionTBreaking

/- The forward (forgetting / noising) entropy-rate effect of the bundled
operator `F_t`: in MIP coordinates it raises `H_K` toward `log|K|` (toward the
uniform distribution), carried as a real entropy increment `fwd`.  The reverse
(denoising) effect is MIP training, lowering `H_K` toward the concentrated
target, carried as `rev`.  Both enter as parameters of each theorem. -/

/-- **R.403 — forward/reverse time-symmetry breaking (core).**

The bundled physical signs of the forgetting operator `F_t` (forward) versus
MIP training (reverse) are opposite:

* `0 < fwd` — forward forgetting raises `H_K` (toward uniform);
* `rev < 0` — reverse training lowers `H_K` (toward the target).

Hence the forward and reverse entropy rates are *unequal*: `fwd ≠ rev`.  The
process is **not** time-reversal invariant — this is R.403's T-breaking kernel,
the diffusion analogue of R.105(b). -/
theorem R_403_forward_ne_reverse
    (fwd rev : ℝ) (hfwd : 0 < fwd) (hrev : rev < 0) :
    fwd ≠ rev := by
  intro h
  rw [h] at hfwd
  linarith

/-- **R.403 — time reversal does not recover the reverse process (non-triviality).**

Time reversal `t → -t` flips the sign of the entropy rate, sending the forward
rate `fwd` to `-fwd`.  Recovering the reverse process would require
`-fwd = rev`, i.e. `fwd = -rev`.  But with the bundled signs `0 < fwd` and
`rev < 0`, this forces nothing contradictory in general — yet whenever the two
*magnitudes* differ (`fwd ≠ -rev`, the realistic non-symmetric schedule), the
naive time-reversal of forward does NOT reproduce the reverse process.

We record the equivalent algebraic statement: under `0 < fwd`, `rev < 0`, the
time-reversed forward rate `-fwd` equals the reverse rate `rev` **iff** the
schedule is symmetric (`fwd = -rev`); generically it is not. -/
theorem R_403_time_reversal_iff_symmetric
    (fwd rev : ℝ) :
    (-fwd = rev) ↔ (fwd = -rev) := by
  constructor
  · intro h; linarith
  · intro h; linarith

/-- **R.403 — strict irreversibility under an asymmetric schedule.**

For the realistic (non-symmetric) noise schedule the forward and reverse
magnitudes differ, `fwd ≠ -rev`; combined with the time-reversal flip this
yields the strict statement that the time-reversed forward process `-fwd`
differs from the reverse process `rev`:

    `-fwd ≠ rev`,

i.e. you cannot obtain reverse diffusion by merely running forward backward in
time.  This is the sharp form of R.135's "pseudo-reversibility": the apparent
per-step invertibility does not make the *direction* reversible. -/
theorem R_403_strict_irreversible
    (fwd rev : ℝ) (hasym : fwd ≠ -rev) :
    -fwd ≠ rev := by
  intro h
  exact hasym ((R_403_time_reversal_iff_symmetric fwd rev).mp h)

/-- **R.403 — entropy-direction dichotomy (bundled `F_t` effect on `H_K`).**

State the two MIP coordinates explicitly.  Let `Hfwd` be `H_K` after the
forward forgetting step and `Hrev` after the reverse training step, both
measured from a common pre-step entropy `H₀`.  The bundled operator gives
`H₀ < Hfwd` (forgetting raises entropy) and `Hrev < H₀` (training lowers it),
so `Hrev < Hfwd`: the two processes drive `H_K` in strictly opposite
directions — time symmetry is broken at the level of the entropy coordinate. -/
theorem R_403_entropy_direction_split
    (H₀ Hfwd Hrev : ℝ)
    (hfwd : H₀ < Hfwd) (hrev : Hrev < H₀) :
    Hrev < Hfwd := lt_trans hrev hfwd

/-- **R.403 — packaged irreversibility statement.**

Bundles the kernel: with the forgetting operator's forward sign `0 < fwd`,
training's reverse sign `rev < 0`, and an asymmetric schedule `fwd ≠ -rev`, the
forward and reverse entropy rates differ AND the time-reversed forward process
fails to reproduce the reverse process.  This is the full R.403 T-breaking
conclusion. -/
theorem R_403_T_breaking
    (fwd rev : ℝ) (hfwd : 0 < fwd) (hrev : rev < 0) (hasym : fwd ≠ -rev) :
    (fwd ≠ rev) ∧ (-fwd ≠ rev) :=
  ⟨R_403_forward_ne_reverse fwd rev hfwd hrev,
   R_403_strict_irreversible fwd rev hasym⟩

end DiffusionTBreaking

end MIP
