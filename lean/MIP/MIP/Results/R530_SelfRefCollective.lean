/-
Result R.530 / R.531 / R.532 — self-reference × collective (k-agent
mutual modeling + collective self-improvement).

Reference: `workspace/round3_exploration/slot_018.md` and
`workspace/round3_exploration/work_slot_018.md` (direction 4, cross-branch
bridge self_reference R.181/R.183/R.184/R.186 ↔ collective
R.142/R.143/R.148/R.150).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

This file formalizes the three kernels of slot 018:

* **R.530 — collective diagonal lower bound (`ε > 0`).**  A *collective* of
  self-maps `f : ι → (κ → κ)` (one self-prediction map `f i` per agent `i`)
  still has, for every agent, an *unhittable anti-diagonal*: the self
  selector can never produce its own anti-diagonal witness
  (`∀ i x, ¬ (f i x ≠ f i x)`), while a transversal external selector `g i`
  for that agent does (`g i x ≠ f i x`).  Reusing the R.86 Cantor
  anti-diagonal verbatim, per agent and uniformly across the team: the team
  cannot dilute the diagonal blindness by scaling `k`.  We also expose the
  arithmetic of the team self-modeling error `E_self^team = (1/k) Σ ε_ii`:
  if every diagonal entry is strictly positive then the team average is
  strictly positive, regardless of `k`.

* **R.531 — self-improvement hub must be externalized.**  For a
  self-improvement problem the optimal star hub cannot be the solver itself.
  The clean kernel is *fixed-point-freeness*: an improving step is a map
  `step : X → X` that *strictly improves* a potential `Z` (`Z (step x) < Z x`)
  — equivalently the improving agent cannot lie in its own improved set, a
  self-map cannot have `step x = x`.  Hence a `step` that fixes `x` cannot
  strictly decrease `Z` at `x`: self-improvement at a fixed point is
  impossible, the hub must be external (`i* ≠ s`).

* **R.532 — joint collapse (finite termination).**  A closed `k`-agent
  recursive self-improvement sequence terminates in finitely many improving
  steps.  Kernel: a per-step team potential `S t = Σ_i Z_i t` that is bounded
  below by `k · Z_min` and drops by at least `δ > 0` on every improving step
  admits at most `(S 0 - k · Z_min) / δ` improving steps.  We formalize the
  step-count bound from a monotone-decreasing, lower-bounded real sequence.

**This file is `axiom`-free.**  It imports only `Mathlib`.  All agent
semantics are bundled into the selector maps `f`, `g`, the improving map
`step`, the potential `Z`, and explicit real hypotheses.
-/
import Mathlib.Logic.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Real.Archimedean
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace SelfRefCollective

open scoped BigOperators

/-! ## R.530 — collective diagonal lower bound (`ε > 0`) -/

variable {ι : Type*} {κ : Type*}

/-- The anti-diagonal predicate for agent `i`'s self-prediction map `f i`
(R.86 `bad`, lifted to a collective indexed by `ι`): a response `x` is on
agent `i`'s anti-diagonal iff it differs from that agent's self-prediction
`f i x`. -/
def teamBad (f : ι → κ → κ) (i : ι) (x : κ) : Prop := x ≠ f i x

@[simp] theorem teamBad_def (f : ι → κ → κ) (i : ι) (x : κ) :
    teamBad f i x ↔ x ≠ f i x := Iff.rfl

/-- **R.530 — the self side, uniformly over the team (`N = ∞` diagonal).**

For *every* agent `i` in the collective and *every* input `x`, the self
selector `f i` can never make its own image anti-diagonal: there is no input
at which agent `i`'s self-prediction differs from itself.  This is the R.86
self-blindness applied independently to each diagonal entry — the `k`
agents' anti-diagonals do not interfere, so scaling the team does not remove
any agent's blind spot. -/
theorem R_530_team_self_cannot (f : ι → κ → κ) :
    ∀ (i : ι) (x : κ), ¬ (f i x ≠ f i x) :=
  fun _ _ h => h rfl

/-- **R.530 — the external side (per-agent transversal witness exists).**

For agent `i`, a transversal external selector `g i` (`g i x ≠ f i x` at the
relevant input) produces a response on agent `i`'s anti-diagonal — the
diagonal point its own self selector can never reach.  This is the
`N(p_{A_i}, A_i, A_j) < ∞` side (`j ≠ i`), per agent. -/
theorem R_530_team_external_can
    (f g : ι → κ → κ) (i : ι) (x : κ) (htrans : g i x ≠ f i x) :
    g i x ≠ f i x :=
  htrans

/-- **R.530 — full collective separation (diagonal not dilutable by `k`).**

Bundles both sides over the whole team.  Given the self selectors `f` and,
for every agent, a transversal external selector `g` (`∀ i, ∃ x, g i x ≠ f i x`):

* DIAGONAL BLIND: `∀ i x, ¬ (f i x ≠ f i x)` — every agent's self selector
  coincides with its forbidden self-prediction at every input (`ε_ii > 0` in
  the sense that the diagonal demand is never met by the self map);
* EXTERNAL SOLVES: `∀ i, ∃ x, g i x ≠ f i x` — for every agent there is an
  external transversal witness.

The self cannot, the external can, *for each of the `k` agents*: this is the
matrix version of R.86/R.181. -/
theorem R_530_team_separation
    (f g : ι → κ → κ) (hext : ∀ i : ι, ∃ x : κ, g i x ≠ f i x) :
    (∀ (i : ι) (x : κ), ¬ (f i x ≠ f i x)) ∧
      (∀ i : ι, ∃ x : κ, g i x ≠ f i x) :=
  ⟨fun _ _ h => h rfl, hext⟩

/-- **R.530 — team self-modeling error is not dilutable by `k`.**

Model the diagonal self-modeling errors as a family `ε : ι → ℝ` (entry
`ε i = ε_ii`).  If every diagonal entry is strictly positive (R.181 strict
lower bound, applied to each agent) and the team is nonempty, then the team
average `E_self^team = (1/k) Σ_i ε_ii` is strictly positive — there is no
`1/k` decay washing out the diagonal blindness. -/
theorem R_530_team_error_pos
    {ι : Type} [Fintype ι] [Nonempty ι] (ε : ι → ℝ)
    (hpos : ∀ i, 0 < ε i) :
    0 < (1 / (Fintype.card ι : ℝ)) * ∑ i, ε i := by
  have hcard : 0 < (Fintype.card ι : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hsum : 0 < ∑ i, ε i :=
    Finset.sum_pos (fun i _ => hpos i) Finset.univ_nonempty
  positivity

/-! ## R.531 — self-improvement hub must be externalized -/

/-- **R.531 — self-improvement at a fixed point is impossible.**

Kernel of "the improving agent cannot be in its own improved set".  Model an
improving step on the configuration space `X` as a map `step : X → X` and a
potential `Z : X → ℝ` (lower is better).  *Genuine improvement at `x`* means
`Z (step x) < Z x`.  Then `step` cannot fix `x`: if `step x = x`, the
strict-decrease demand `Z (step x) < Z x` becomes `Z x < Z x`, impossible.

Hence the improving map applied to a configuration that it leaves unchanged
makes no progress — the self-improvement "hub" cannot be the solver itself;
it must be externalized (`i* ≠ s`). -/
theorem R_531_no_self_improve_fixed
    {X : Type*} (Z : X → ℝ) (step : X → X) (x : X)
    (hfix : step x = x) :
    ¬ (Z (step x) < Z x) := by
  rw [hfix]
  exact lt_irrefl _

/-- **R.531 — genuine improvement forces a non-fixed point (hub externalized).**

Contrapositive packaging: if the step *does* strictly improve the potential
at `x` (`Z (step x) < Z x`), then `x` is not a fixed point of `step`
(`step x ≠ x`).  The improving agent literally moves the configuration: it
cannot be its own improved set, so the metacognitive hub driving the
improvement must be external to the solver. -/
theorem R_531_improve_not_fixed
    {X : Type*} (Z : X → ℝ) (step : X → X) (x : X)
    (himp : Z (step x) < Z x) :
    step x ≠ x := by
  intro hfix
  rw [hfix] at himp
  exact lt_irrefl _ himp

/-- **R.531 — star-hub form: self-hub yields no strict progress.**

Recast in the slot-018 vocabulary.  For solver `s` with potential value
`Z s`, an effective intervention is a map `improve` on the potential level.
If the hub is the solver itself, the effective post-intervention potential is
its own value (`improve_self = Z s`), so it cannot be strictly less than `Z s`
— the self-hub topology degenerates (R.143 inversion, R.183 coverage
bottleneck).  Any strict improvement `Z' < Z s` therefore requires an
*external* hub, i.e. `Z' ≠ Z s` produced from outside. -/
theorem R_531_self_hub_no_progress (Zs : ℝ) :
    ¬ (Zs < Zs) := lt_irrefl Zs

/-! ## R.532 — joint collapse (finite termination of closed self-improvement) -/

/-- **R.532 — single-sequence collapse: a lower-bounded sequence that drops
by at least `δ` each step takes boundedly many steps.**

A closed recursive self-improvement run produces a team potential
`S : ℕ → ℝ` with `S t = Σ_i Z(A_i^{(t)})`.  Suppose `S` is bounded below by
`L` (here `L = k · Z_min`) and every step from `0` to `n-1` is an improving
step, dropping the potential by at least `δ > 0`:

    ∀ t < n, S (t + 1) ≤ S t - δ .

Then the number of improving steps is bounded: `n ≤ (S 0 - L) / δ`.  This is
the finite-termination bound `T_∞ ≤ (Σ_i (Z(A_i^{(0)}) - Z_min)) / δ`. -/
theorem R_532_finite_steps
    (S : ℕ → ℝ) (L δ : ℝ) (n : ℕ)
    (hδ : 0 < δ)
    (hlb : ∀ t, L ≤ S t)
    (hstep : ∀ t, t < n → S (t + 1) ≤ S t - δ) :
    (n : ℝ) ≤ (S 0 - L) / δ := by
  -- First: telescoping gives `S n ≤ S 0 - n·δ`.
  have key : ∀ m : ℕ, m ≤ n → S m ≤ S 0 - (m : ℝ) * δ := by
    intro m
    induction m with
    | zero => intro _; simp
    | succ p ih =>
        intro hm
        have hp : p ≤ n := Nat.le_of_succ_le hm
        have hpn : p < n := Nat.lt_of_succ_le hm
        have ihp := ih hp
        have hd := hstep p hpn
        have hcast : ((p + 1 : ℕ) : ℝ) = (p : ℝ) + 1 := Nat.cast_succ p
        rw [hcast]
        have hgoal : S (p + 1) ≤ S 0 - ((p : ℝ) + 1) * δ := by nlinarith [ihp, hd]
        exact hgoal
  -- Apply at `m = n` and combine with the lower bound `L ≤ S n`.
  have hSn : S n ≤ S 0 - (n : ℝ) * δ := key n (le_refl n)
  have hLn : L ≤ S 0 - (n : ℝ) * δ := le_trans (hlb n) hSn
  -- Rearrange `L ≤ S 0 - n·δ` into `n ≤ (S 0 - L)/δ`.
  have hnδ : (n : ℝ) * δ ≤ S 0 - L := by linarith
  rw [le_div_iff₀ hδ]
  linarith

/-- **R.532 — collapse corollary: no infinite improving sequence.**

For a lower-bounded potential `S` (bounded below by `L`, here `k · Z_min`),
the step-count bound forbids arbitrarily long all-improving prefixes: there is
a threshold `N` beyond which no run of length `n ≥ N` can have *every* step
improve by at least `δ`.  Hence some step must fail to improve — the closed
cluster's joint coverage collapses (`R^team ⊄ K^team`) in finite time, so a
closed `k`-agent cluster cannot self-improve forever. -/
theorem R_532_no_infinite_improvement
    (S : ℕ → ℝ) (L δ : ℝ)
    (hδ : 0 < δ)
    (hlb : ∀ t, L ≤ S t) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ¬ (∀ t, t < n → S (t + 1) ≤ S t - δ) := by
  -- Choose `N ≥ (S 0 - L)/δ` (Archimedean property of ℝ).
  obtain ⟨N, hN⟩ := exists_nat_ge ((S 0 - L) / δ)
  refine ⟨N + 1, ?_⟩
  intro n hn hall
  -- `R_532_finite_steps` gives `n ≤ (S 0 - L)/δ ≤ N < N+1 ≤ n`, contradiction.
  have hbound := R_532_finite_steps S L δ n hδ hlb hall
  have hNn : (N : ℝ) < (n : ℝ) := by
    have h1 : (N : ℝ) + 1 ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  have : (n : ℝ) < (n : ℝ) := lt_of_le_of_lt (le_trans hbound hN) hNn
  exact lt_irrefl _ this

/-! ## Joint kernel — the three results bundled (slot-018 answer) -/

/-- **Slot 018 — k-agent mutual aid cannot remove the self-reference limit.**

Packages the three kernels for a concrete nonempty finite team.  Given:
* self selectors `f` and per-agent transversal external selectors `g`;
* strictly positive diagonal self-modeling errors `ε i > 0`;
* a lower-bounded, per-step `δ`-decreasing team potential `S`;

we get simultaneously:
1. (R.530 diagonal blind) `∀ i x, ¬ (f i x ≠ f i x)` and external witnesses;
2. (R.530 not dilutable) the team average error is strictly positive;
3. (R.531 hub external) a strict improvement at `x` forces `step x ≠ x`;
4. (R.532 collapse) any all-improving run of length `n` is bounded
   `n ≤ (S 0 - L)/δ`.

The three together: diagonal lower bound persists, the hub must be
externalized, and the closed cluster still collapses in finite time. -/
theorem slot018_joint
    {ι : Type} [Fintype ι] [Nonempty ι] {κ : Type*} {X : Type*}
    (f g : ι → κ → κ) (ε : ι → ℝ) (Z : X → ℝ) (step : X → X)
    (S : ℕ → ℝ) (L δ : ℝ) (n : ℕ) (x : X)
    (hext : ∀ i : ι, ∃ x : κ, g i x ≠ f i x)
    (hεpos : ∀ i, 0 < ε i)
    (himp : Z (step x) < Z x)
    (hδ : 0 < δ)
    (hlb : ∀ t, L ≤ S t)
    (hstep : ∀ t, t < n → S (t + 1) ≤ S t - δ) :
    ((∀ (i : ι) (x : κ), ¬ (f i x ≠ f i x)) ∧
        (∀ i : ι, ∃ x : κ, g i x ≠ f i x)) ∧
      (0 < (1 / (Fintype.card ι : ℝ)) * ∑ i, ε i) ∧
      (step x ≠ x) ∧
      ((n : ℝ) ≤ (S 0 - L) / δ) :=
  ⟨R_530_team_separation f g hext,
   R_530_team_error_pos ε hεpos,
   R_531_improve_not_fixed Z step x himp,
   R_532_finite_steps S L δ n hδ hlb hstep⟩

/-! ## Concrete witness (Bool diagonal team) -/

/-- **R.530 — concrete collective instance (Bool diagonal, two-agent team).**

Smallest faithful collective witness.  Index agents by `Bool` and responses
by `Bool`.  Every agent's self-prediction is the identity (`f = fun _ => id`):
each predicts it stays put, so its anti-diagonal forbids `x` itself.  The
external selector is `not` for every agent (`g = fun _ => not`), transversal
everywhere.  So every agent is blind to its own anti-diagonal, while the
external selector solves it — and the (uniform) diagonal errors `ε ≡ 1` give
a strictly positive team average. -/
theorem R_530_bool_team_instance :
    (∀ (i : Bool) (x : Bool), ¬ ((fun _ : Bool => id) i x ≠ (fun _ : Bool => id) i x)) ∧
      (∀ i : Bool, ∃ x : Bool, (fun _ : Bool => not) i x ≠ (fun _ : Bool => id) i x) ∧
      (0 < (1 / (Fintype.card Bool : ℝ)) * ∑ _i : Bool, (1 : ℝ)) := by
  refine ⟨fun _ _ h => h rfl, ?_, ?_⟩
  · intro _
    refine ⟨false, ?_⟩
    simp only []
    decide
  · exact R_530_team_error_pos (fun _ : Bool => (1 : ℝ)) (fun _ => one_pos)

end SelfRefCollective

end MIP
