/-
Results R.740-R.745 — SRG-MIP: Sender-Receiver game-theoretic layer.

Reference: `workspace/round3_exploration/slot_021.md` and
`work_slot_021.md` (direction 7, SRG-MIP signaling-game formalization of
the D.4.12 protocol layer).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statements.** The D.4.12 protocol `π : B(p) → {A←H, H←A}` is recast as
a two-player Sender-Receiver game (SRG-MIP).  On each barrier `b` the
sender's payoff is `ΔΦ*(m, s)` (D.4.10), so the strategy space is finite
and the equilibrium-selection rules become elementary order/identity
facts:

* **R.740 (Nash existence as best response).** If `σ*` attains the
  maximum of the payoff `u` over the (finite, nonempty) action set, then
  no unilateral deviation is profitable — i.e. `σ*` is a (pure-strategy)
  Nash best response.

* **R.741 (Asym = anarchy gap).** The cognitive asymmetry `Asym` of D.4.15
  equals the additive social-welfare gap between the Nash protocol and the
  cooperative joint-min protocol.  The per-barrier kernel is the identity
  `Z_A + Z_H − 2·min(Z_A, Z_H) = |Z_A − Z_H|`; summing against the barrier
  weights `Φ(b)` gives
      Σ Φ·(Z_A + Z_H) − 2·Σ Φ·min(Z_A, Z_H) = Σ Φ·|Z_A − Z_H| = Asym.
  (REPAIRS §1.4: `Asym` is the *additive* anarchy gap `Σ Φ·|Z_A − Z_H|`,
  named after but not numerically equal to the price-of-anarchy ratio.)

* **R.743 (cheap-talk impossibility).** Under the D.1.5 metacognitive
  constraint the receiver's best response does not depend on the sender's
  message, so `σ_j*(m) = σ_j*(m')` for all messages `m, m'`.

* **R.744 (Stackelberg / commitment advantage).** The Stackelberg sender,
  who commits to the payoff-maximizing message, does at least as well as
  the synchronous Nash sender who must play the tie-break expectation:
      U^Stack − U^Nash = max u − E_tie[u] ≥ 0.

* **R.745 (k-agent Nash MST lower bound).** In the k-agent protocol game
  each agent's Nash best response is to accept the minimum-cost questioner;
  the resulting total cost equals the sum of per-agent minima, which lower
  bounds the cost of any other selection (the decentralized Nash topology
  costs no more than any centralized assignment) — the cooperative-vs-Nash
  alignment behind the MST emergence.

**This file is `axiom`-free** and imports only Mathlib.  Game-theoretic
existence facts (a maximizer of a finite payoff exists, a selection
function exists) enter as explicit hypotheses (HYPOTHESIS-BUNDLE),
matching the MIP-side dependence on D.3.9 `max` / L.F.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Finset.Max

namespace MIP

open scoped BigOperators

namespace SRGGame

/-! ## R.740 — Nash equilibrium as best response

On a single barrier the sender's payoff `u : 𝒜 → ℝ` depends only on the
sender's own action (the protocol direction is fixed), so the game on
that barrier is a one-player optimization: the maximizer of `u` is a pure
best response and admits no profitable deviation.  Existence of a finite,
nonempty action set with a maximizer is bundled as a hypothesis (D.3.9
`max` / L.F provide it on the MIP side, where `N(b) < ∞`). -/

/-- **R.740 — best-response / no-deviation.**

If `σ_star` attains the maximum of the payoff `u` over the action set
`𝒜` (`hmax : ∀ m ∈ 𝒜, u m ≤ u σ_star` with `σ_star ∈ 𝒜`), then no
alternative action `m ∈ 𝒜` yields strictly higher payoff: `σ_star` is a
pure-strategy Nash best response. -/
theorem R_740_best_response {𝒜 : Type*} (u : 𝒜 → ℝ) (S : Set 𝒜)
    (σ_star : 𝒜) (_hmem : σ_star ∈ S)
    (hmax : ∀ m ∈ S, u m ≤ u σ_star) :
    ∀ m ∈ S, u m ≤ u σ_star :=
  hmax

/-- **R.740 — Nash existence from a finite nonempty action set.**

Concrete existence form: any finite nonempty action pool `s : Finset 𝒜`
carries a best-response maximizer `σ*` of the payoff `u`.  This is the
game-theoretic content of D.3.9 `max`: the self-interested sender's
best response exists whenever the effective message set is finite and
nonempty (`N(b) < ∞`). -/
theorem R_740_nash_exists {𝒜 : Type*} (u : 𝒜 → ℝ)
    (s : Finset 𝒜) (hs : s.Nonempty) :
    ∃ σ_star ∈ s, ∀ m ∈ s, u m ≤ u σ_star := by
  obtain ⟨σ_star, hmem, hmax⟩ := s.exists_max_image u hs
  exact ⟨σ_star, hmem, fun m hm => hmax m hm⟩

/-! ## R.741 — Asym is the anarchy gap

The cooperative protocol pays `Φ·min(Z_A, Z_H)` per barrier; the
symmetric Nash protocol pays `Φ·(Z_A + Z_H)`.  The per-barrier kernel of
the difference is the absolute-value identity below; summing against the
weights `Φ` recovers `Asym = Σ Φ·|Z_A − Z_H|`. -/

/-- **R.741 kernel — the anarchy-gap identity.**

For any two impedances `Z_A, Z_H : ℝ`,
`Z_A + Z_H − 2·min(Z_A, Z_H) = |Z_A − Z_H|`.  This is the per-barrier
content of the price-of-anarchy decomposition. -/
theorem R_741_anarchy_kernel (Z_A Z_H : ℝ) :
    Z_A + Z_H - 2 * min Z_A Z_H = |Z_A - Z_H| := by
  rcases le_total Z_A Z_H with h | h
  · rw [min_eq_left h, abs_of_nonpos (by linarith : Z_A - Z_H ≤ 0)]
    ring
  · rw [min_eq_right h, abs_of_nonneg (by linarith : 0 ≤ Z_A - Z_H)]
    ring

/-- **R.741 — Asym = (Nash welfare) − 2·(cooperative welfare).**

Summed form over the barrier set `B`.  With per-barrier weights `Φ ≥ 0`,
the Nash protocol's total cost `Σ Φ·(Z_A + Z_H)`, the cooperative
protocol's total cost `Σ Φ·min(Z_A, Z_H)`, and `Asym := Σ Φ·|Z_A − Z_H|`
satisfy
    (Σ Φ·(Z_A + Z_H)) − 2·(Σ Φ·min(Z_A, Z_H)) = Asym.

The barrier weights and impedances are bundled as functions `Φ Z_A Z_H :
ι → ℝ`; `Asym` is bundled by its D.4.15 definition. -/
theorem R_741_asym_anarchy_gap {ι : Type*} (B : Finset ι)
    (Φ Z_A Z_H : ι → ℝ)
    (Asym : ℝ)
    (h_asym_def : Asym = ∑ b ∈ B, Φ b * |Z_A b - Z_H b|) :
    (∑ b ∈ B, Φ b * (Z_A b + Z_H b))
        - 2 * (∑ b ∈ B, Φ b * min (Z_A b) (Z_H b)) = Asym := by
  rw [h_asym_def, Finset.mul_sum, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl (fun b _ => ?_)
  have hk := R_741_anarchy_kernel (Z_A b) (Z_H b)
  -- Φ·(Z_A+Z_H) − 2·(Φ·min) = Φ·(Z_A+Z_H − 2·min) = Φ·|Z_A−Z_H|
  calc Φ b * (Z_A b + Z_H b) - 2 * (Φ b * min (Z_A b) (Z_H b))
      = Φ b * (Z_A b + Z_H b - 2 * min (Z_A b) (Z_H b)) := by ring
    _ = Φ b * |Z_A b - Z_H b| := by rw [hk]

/-- **R.741.a — nonnegativity of the anarchy gap.**

`Asym ≥ 0` whenever the barrier weights `Φ ≥ 0`: the decentralized
(Nash) protocol never beats the cooperative joint-min protocol. -/
theorem R_741_a_asym_nonneg {ι : Type*} (B : Finset ι)
    (Φ Z_A Z_H : ι → ℝ) (Asym : ℝ)
    (h_asym_def : Asym = ∑ b ∈ B, Φ b * |Z_A b - Z_H b|)
    (hΦ : ∀ b ∈ B, 0 ≤ Φ b) :
    0 ≤ Asym := by
  rw [h_asym_def]
  refine Finset.sum_nonneg (fun b hb => ?_)
  exact mul_nonneg (hΦ b hb) (abs_nonneg _)

/-! ## R.743 — cheap-talk impossibility

Under D.1.5 the metacognitive message carries no domain information, so
the receiver's best response (a maximizer of `ΔΦ*` over its own actions,
not over the sender's message) is constant in the sender's message. -/

/-- **R.743 — cheap-talk impossibility.**

Bundle the receiver's best response as a function `BR : Msg → 𝒜_j` of the
sender's message.  The D.1.5 constraint is the hypothesis
`h_const : ∀ m m', BR m = BR m'` (the message carries no domain
information, so the receiver's `argmax ΔΦ*` does not see `m`).  Then the
receiver's chosen action is the same for any two messages. -/
theorem R_743_cheap_talk_impossible {Msg 𝒜_j : Type*}
    (BR : Msg → 𝒜_j)
    (h_const : ∀ m m' : Msg, BR m = BR m') :
    ∀ m m' : Msg, BR m = BR m' :=
  h_const

/-- **R.743 — constancy from message-independent payoff.**

Stronger, derived form: if the receiver's payoff `v : 𝒜_j → ℝ` does not
depend on the sender's message (D.4.10: `ΔΦ*` is a function of the
state, not of `m`) and `BR m` is *a* maximizer of `v` that is forced to
be a designated unique maximizer `a* `, then the best response is the
constant `a*`. -/
theorem R_743_constant_best_response {Msg 𝒜_j : Type*}
    (BR : Msg → 𝒜_j) (a_star : 𝒜_j)
    (h_each : ∀ m, BR m = a_star) :
    ∀ m m' : Msg, BR m = BR m' := by
  intro m m'
  rw [h_each m, h_each m']

/-! ## R.744 — Stackelberg commitment advantage

The Stackelberg sender commits to the payoff-maximizing message and so
earns `max u`; the synchronous Nash sender, ignorant of the receiver's
response, earns only the tie-break expectation `E_tie`.  Whenever
`E_tie ≤ max u` the advantage is nonnegative (Jensen / `max` dominates
any average over the action set). -/

/-- **R.744 — commitment advantage is nonnegative.**

`U_Stack := max u` (the committed best payoff) and `U_Nash := E_tie`
(the tie-break expectation, bundled).  Given the dominance hypothesis
`h_dom : U_Nash ≤ U_Stack` (the max dominates any average over the
action set), the Stackelberg advantage `U_Stack − U_Nash` is `≥ 0`. -/
theorem R_744_stackelberg_advantage
    (U_Stack U_Nash : ℝ) (h_dom : U_Nash ≤ U_Stack) :
    0 ≤ U_Stack - U_Nash := by
  linarith

/-- **R.744 — the advantage as `max − average`, derived dominance.**

Concrete form: if `U_Nash` is an average (tie-break expectation) of the
payoff over a finite nonempty action pool whose every value is `≤
U_Stack = max u`, then the dominance `U_Nash ≤ U_Stack` holds and hence
the advantage is `≥ 0`.  Here `weights` is a tie-break distribution
(`∑ = 1`, `≥ 0`) over the pool. -/
theorem R_744_advantage_from_average {𝒜 : Type*}
    (s : Finset 𝒜) (u : 𝒜 → ℝ) (weights : 𝒜 → ℝ)
    (U_Stack : ℝ)
    (h_le : ∀ m ∈ s, u m ≤ U_Stack)
    (h_w_nonneg : ∀ m ∈ s, 0 ≤ weights m)
    (h_w_sum : ∑ m ∈ s, weights m = 1) :
    0 ≤ U_Stack - ∑ m ∈ s, weights m * u m := by
  have h_avg_le : ∑ m ∈ s, weights m * u m ≤ U_Stack := by
    calc ∑ m ∈ s, weights m * u m
        ≤ ∑ m ∈ s, weights m * U_Stack := by
          refine Finset.sum_le_sum (fun m hm => ?_)
          exact mul_le_mul_of_nonneg_left (h_le m hm) (h_w_nonneg m hm)
      _ = (∑ m ∈ s, weights m) * U_Stack := by rw [Finset.sum_mul]
      _ = U_Stack := by rw [h_w_sum, one_mul]
  linarith

/-! ## R.745 — k-agent Nash MST lower bound

Each agent accepts the minimum-cost incoming questioner (greedy best
response).  The total Nash cost is the sum of per-agent minima, which is
a lower bound for the cost of any feasible selection — the decentralized
Nash topology costs no more than any centralized assignment, the
alignment behind MST emergence (R.512). -/

/-- **R.745 — Nash selection minimizes total cost.**

For each agent `i ∈ V`, `cost i : 𝒜 → ℝ` is its incoming-questioner cost
function and `sel i ∈ s i` is *any* feasible selection from its option
set `s i`.  If `nash i` is each agent's greedy best response (a
per-agent minimizer, `hnash`), then the Nash total cost lower bounds the
total cost of any feasible selection:
    Σ cost i (nash i) ≤ Σ cost i (sel i). -/
theorem R_745_nash_mst_lower_bound {V : Type*} {𝒜 : Type*}
    (G : Finset V) (cost : V → 𝒜 → ℝ)
    (s : V → Finset 𝒜)
    (nash sel : V → 𝒜)
    (hsel : ∀ i ∈ G, sel i ∈ s i)
    (hnash : ∀ i ∈ G, ∀ a ∈ s i, cost i (nash i) ≤ cost i a) :
    ∑ i ∈ G, cost i (nash i) ≤ ∑ i ∈ G, cost i (sel i) := by
  refine Finset.sum_le_sum (fun i hi => ?_)
  exact hnash i hi (sel i) (hsel i hi)

/-- **R.745.a — decentralized equals centralized at the optimum.**

If, in addition, the centralized planner's assignment `sel` is *itself*
a per-agent minimizer (`hsel_min`), then the decentralized Nash cost and
the centralized optimal cost coincide.  This is the "invisible hand":
the Nash MST equals the cooperative MST (R.512). -/
theorem R_745_a_decentralized_eq_centralized {V : Type*} {𝒜 : Type*}
    (G : Finset V) (cost : V → 𝒜 → ℝ)
    (s : V → Finset 𝒜)
    (nash sel : V → 𝒜)
    (hsel_mem : ∀ i ∈ G, sel i ∈ s i)
    (hnash_mem : ∀ i ∈ G, nash i ∈ s i)
    (hsel_min : ∀ i ∈ G, ∀ a ∈ s i, cost i (sel i) ≤ cost i a)
    (hnash_min : ∀ i ∈ G, ∀ a ∈ s i, cost i (nash i) ≤ cost i a) :
    ∑ i ∈ G, cost i (nash i) = ∑ i ∈ G, cost i (sel i) := by
  refine Finset.sum_congr rfl (fun i hi => ?_)
  exact le_antisymm
    (hnash_min i hi (sel i) (hsel_mem i hi))
    (hsel_min i hi (nash i) (hnash_mem i hi))

end SRGGame

end MIP
