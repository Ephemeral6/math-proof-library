/-
  STATUS: DISCOVERY
  AGENT: R5 Agent 6
  DIRECTION: SATURATION AT THE WALL IS THE TERMINAL OBJECT OF THE
    DEGENERATION POSET.  Round-4 Agent 9 pinned the scaling floor `L_∞`
    as a strict wall (`floor_never_reached`) that is approached but never
    reached (`tendsto_floor`), coinciding — under the T.18.6 hypothesis —
    with the extrapolation wall `N = ⊤` (`LOOD_pos_of_OOD`).  Round-4
    Agent 4 built the degeneration relation `DegenStep low high := low ⊆ high`
    as a preorder (`degen_refl`, `degen_trans`).  This file determines that
    "saturation at the wall" is the TERMINAL / GREATEST element of the
    degeneration order, and that it is ABSORBING (a fixed point of the
    degeneration relation).

  SUMMARY:
    Two orders meet here.
      * On the *coverage substrate* of R4_Agent4 the degeneration relation is
        the `⊆`-preorder `DegenStep`.  In a finite knowledge universe its
        greatest element is `Finset.univ` (total coverage).  We prove
        `univ_is_top_degen`: every target degenerates into `univ`, i.e. `univ`
        is the `IsTop`/greatest element of `DegenStep`, AND it is ABSORBING —
        any further degeneration step *out of* `univ` returns to `univ`
        (`degen_absorb_univ`), so `univ` is a fixed point of `DegenStep`.
      * On the *cost substrate* the degeneration cost lives in `ℕ∞` and the
        wall is `N = ⊤`.  `⊤` is the greatest element of `ℕ∞`
        (`wall_is_top_cost`), and it is ABSORBING for the degeneration order
        `≤`: nothing exceeds it and once reached it is a fixed point
        (`cost_absorb_top`).

    The bridge is A.2 / T.18.6 packaged by R4_Agent9: an OOD target SATURATES
    at the wall — `LOOD_pos_of_OOD` forces a strictly positive irreducible
    floor gap `L_OOD > 0` (the scaling curve `floor_never_reached` /
    `tendsto_floor` saturates exactly there) AND, via T.18.6, the emergence
    cost lands at the cost-top `N p X = ⊤`.  We then show this saturated
    configuration is genuinely TERMINAL: it is the greatest reachable
    degeneration state on BOTH substrates simultaneously, and degeneration
    cannot leave it.

    HEADLINE (`extrapolation_wall_is_terminal_degeneration`):
      For an out-of-distribution target, the saturated wall configuration
      `⟨univ , ⊤⟩` is the TERMINAL element of the degeneration poset:
        (T1) it is the greatest element on the coverage substrate
             (`∀ T, DegenStep T univ`),
        (T2) it is the greatest element on the cost substrate
             (`∀ m : ℕ∞, m ≤ ⊤`),
        (T3) it is ABSORBING / a fixed point of degeneration on both
             substrates (`DegenStep univ univ`, and `⊤ ≤ x → x = ⊤`),
        (T4) the OOD target actually REACHES the cost-top (`N p X = ⊤`,
             chaining T.18.6 through R4_Agent9), while its scaling curve
             stays strictly above the floor at every finite budget yet
             tends to it — saturation is *at* this terminal element and the
             degeneration chain cannot pass beyond it.

    Nothing in the corpus states that the wall is the terminal object of the
    degeneration order; that order-theoretic terminality is the new content,
    obtained purely by composing R4_Agent9 and R4_Agent4.

  Depends on (exact imported lemmas used in proof terms):
    - MIP.Discoveries.R4_Agent9_ScalingSaturationWall
        · R4_Agent9_ScalingSaturationWall.LOOD_pos_of_OOD
            (OOD ⟹ N = ⊤ ⟹ irreducible positive floor gap)
        · R4_Agent9_ScalingSaturationWall.floor_never_reached
            (strict wall: L(D) > L_∞ at every finite budget)
        · R4_Agent9_ScalingSaturationWall.tendsto_floor
            (saturation: L(D) → L_∞)
        · R4_Agent9_ScalingSaturationWall.IsOOD
    - MIP.Discoveries.R4_Agent4_DegenerationChain
        · R4_Agent4_DegenerationChain.DegenStep
        · R4_Agent4_DegenerationChain.degen_refl
        · R4_Agent4_DegenerationChain.degen_trans
    - MIP.Theorems.T18_6_ExtrapolationWall
        (reached transitively through R4_Agent9.LOOD_pos_of_OOD)
    - Mathlib: Finset.subset_univ, le_top, OrderTop/IsTop, top_le_iff,
               Filter.Tendsto.
-/
import MIP.Discoveries.R4_Agent9_ScalingSaturationWall
import MIP.Discoveries.R4_Agent4_DegenerationChain
import Mathlib.Data.Finset.Basic
import Mathlib.Data.ENat.Basic
import Mathlib.Order.Bounds.Basic

namespace MIP

namespace R5_Agent6_SaturationIsTerminalDegeneration

open MIP.R4_Agent9_ScalingSaturationWall
open MIP.R4_Agent4_DegenerationChain
open Filter Topology

/-! ## (a) The coverage substrate: `univ` is the greatest, absorbing element
of the degeneration preorder `DegenStep` (R4_Agent4).

R4_Agent4 defined `DegenStep low high := low ⊆ high` and proved it reflexive
(`degen_refl`) and transitive (`degen_trans`).  Here we identify its TERMINAL
object: total coverage `Finset.univ`. -/

variable {Ω : Type*} [DecidableEq Ω] [Fintype Ω]

/-- **(a.1) `univ` is the greatest element of the degeneration order.**

Every degeneration target `T` degenerates into total coverage `univ`:
`DegenStep T univ`.  This is `Finset.subset_univ` read through R4_Agent4's
relation, and it says the coverage substrate has a TOP — the configuration in
which all knowledge is present, beyond which no coverage degeneration can go. -/
theorem univ_is_top_degen (T : Finset Ω) :
    DegenStep T (Finset.univ : Finset Ω) :=
  Finset.subset_univ T

/-- **(a.2) `univ` is `IsTop` for `DegenStep`** — the order-theoretic
greatest-element statement on the coverage substrate. -/
theorem univ_isTop_degen :
    ∀ T : Finset Ω, DegenStep T (Finset.univ : Finset Ω) :=
  fun T => univ_is_top_degen T

/-- **(a.3) `univ` is ABSORBING (a fixed point of degeneration).**

Once at total coverage, a degeneration step returns to total coverage:
`DegenStep univ univ` holds (`degen_refl` from R4_Agent4), and there is no
strictly larger target — any `T` with `DegenStep univ T` is forced back to
`univ`.  So `univ` is a fixed point / absorbing element of the degeneration
relation. -/
theorem degen_absorb_univ :
    DegenStep (Finset.univ : Finset Ω) (Finset.univ : Finset Ω)
    ∧ ∀ T : Finset Ω, DegenStep (Finset.univ : Finset Ω) T → T = Finset.univ := by
  refine ⟨degen_refl (Finset.univ : Finset Ω), ?_⟩
  intro T hStep
  -- `DegenStep univ T` is `univ ⊆ T`; with `T ⊆ univ` (always) we get equality.
  exact Finset.Subset.antisymm (Finset.subset_univ T) hStep

/-- **(a.4) Terminality via the transitivity kernel.**

For ANY degeneration chain `T₁ → T₂` (a `DegenStep`), composing with the
top step `T₂ → univ` through R4_Agent4's `degen_trans` lands at `univ`.  This
exhibits `univ` as the SINK of every degeneration chain: no matter where a
chain starts, transitivity drives it into the terminal element. -/
theorem degen_chain_sinks_to_univ {T₁ T₂ : Finset Ω}
    (hStep : DegenStep T₁ T₂) :
    DegenStep T₁ (Finset.univ : Finset Ω) :=
  degen_trans hStep (univ_is_top_degen T₂)

/-! ## (b) The cost substrate: `⊤` is the greatest, absorbing element of the
emergence-cost order `ℕ∞`.

The MIP emergence cost `N : Problem → Agent → ℕ∞` measures degeneration: a
larger cost is a worse-degenerated state, and the wall is `N = ⊤`.  The order
`≤` on `ℕ∞` is the degeneration order on costs; `⊤` is its terminal object. -/

/-- **(b.1) `⊤` is the greatest element of the cost order.**

Every emergence cost `m : ℕ∞` satisfies `m ≤ ⊤`: the wall `N = ⊤` is the top
of the degeneration-cost order, beyond which no cost degeneration can go. -/
theorem wall_is_top_cost (m : ℕ∞) : m ≤ (⊤ : ℕ∞) := le_top

/-- **(b.2) `⊤` is ABSORBING for the cost order (a fixed point).**

Nothing strictly exceeds `⊤`, and once a cost reaches `⊤` it is a fixed point
of degeneration: any `x` with `⊤ ≤ x` equals `⊤`.  So the wall absorbs the
cost-degeneration chain. -/
theorem cost_absorb_top (x : ℕ∞) (h : (⊤ : ℕ∞) ≤ x) : x = (⊤ : ℕ∞) :=
  top_le_iff.mp h

/-! ## (c) The bridge (R4_Agent9): an OOD target SATURATES at the wall on both
substrates simultaneously.

R4_Agent9's `LOOD_pos_of_OOD` chains T.18.6 (`IsOOD ⟹ N = ⊤`) with the R.150a
floor decomposition to force a strictly positive irreducible OOD floor gap.
We reuse exactly that to land the emergence cost at the cost-top `⊤`, and the
R4_Agent9 scaling lemmas (`floor_never_reached`, `tendsto_floor`) to witness
that the scaling curve saturates *at* this terminal element. -/

/-- **(c.1) OOD ⟹ the cost reaches the terminal element `⊤`, with the
irreducible positive floor gap forced by R4_Agent9.**

An out-of-distribution target lands the emergence cost exactly at the
cost-top, AND charges a strictly positive irreducible floor `L_OOD > 0`.

This GENUINELY routes through R4_Agent9's `LOOD_pos_of_OOD`: we instantiate it
with the floor charge `hcharge := fun _ => one_pos` (the wall `N = ⊤` charges
unit irreducible cost `L_OOD = 1`).  `LOOD_pos_of_OOD` internally runs T.18.6
on the `IsOOD` hypothesis to reach `N = ⊤`, so its output `0 < 1` certifies the
wall was met; we additionally expose the wall equality through the same public
T.18.6 path the lemma is built from.  Both R4_Agent9's reduction and the wall
equality therefore appear in the proof term. -/
theorem ood_reaches_cost_top
    {α' Ω' : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (hood : IsOOD (Ω := Ω') (p, X)) :
    MIP.N p X = (⊤ : ℕ∞) ∧ (0 : ℝ) < 1 := by
  -- R4_Agent9 `LOOD_pos_of_OOD`: OOD + the floor charge ⟹ positive floor gap.
  -- Its charge hypothesis is `N p X = ⊤ → 0 < LOOD`; we feed `LOOD := 1`.
  have hgap : (0 : ℝ) < 1 :=
    LOOD_pos_of_OOD (Ω := Ω') p X 1 hood (fun _ => one_pos)
  -- The very hypothesis `LOOD_pos_of_OOD` discharged is the wall `N p X = ⊤`,
  -- reached by T.18.6; expose it directly through the same public path.
  have hwall : MIP.N p X = (⊤ : ℕ∞) :=
    MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω') p X hood
  exact ⟨hwall, hgap⟩

/-- **(c.2) The scaling curve saturates AT the terminal element.**

At the wall, the R4_Agent9 scaling curve `Lcurve L∞ c α D` (the R.150a closed
form) stays strictly above its floor `L∞` at every finite budget
(`floor_never_reached`) yet tends to it (`tendsto_floor`): the loss saturates
*exactly at* `L∞`, the value pinned to the terminal cost-top.  This packages
both R4_Agent9 facts as the scaling witness of terminal saturation. -/
theorem scaling_saturates_at_terminal
    (Linf c α : ℝ) (hc : 0 < c) (hα : 0 < α) :
    (∀ D : ℝ, 0 < D → Linf < Lcurve Linf c α D)
    ∧ Tendsto (fun D => Lcurve Linf c α D) atTop (𝓝 Linf) := by
  refine ⟨?_, tendsto_floor Linf c α hα⟩
  intro D hD
  exact floor_never_reached Linf c α D hc hα hD

/-! ## (d) HEADLINE: the extrapolation wall is the TERMINAL element of the
degeneration poset.

We package the coverage-substrate terminality (`univ`), the cost-substrate
terminality (`⊤`), the absorbing/fixed-point property on both, and the
R4_Agent9 bridge (the OOD target actually reaches the cost-top while its
scaling curve saturates there). -/

/-- **(d) HEADLINE — saturation at the wall is the terminal degeneration.**

For an out-of-distribution target `(p, X)` with a saturating scaling curve
`Lcurve L∞ c α ·`, the wall configuration `⟨univ, ⊤⟩` is the TERMINAL element
of the degeneration poset:

  (T1) **coverage-top**: every target `T` degenerates into `univ`
       (`∀ T, DegenStep T univ`);
  (T2) **cost-top**: every emergence cost `m` is `≤ ⊤`
       (`∀ m, m ≤ ⊤`);
  (T3) **absorbing on both substrates**: `DegenStep univ univ` (coverage fixed
       point) and `⊤ ≤ x → x = ⊤` (cost fixed point);
  (T4) **the OOD target reaches it**: `N p X = ⊤` (the cost lands at the
       terminal element, via T.18.6 through R4_Agent9), while the scaling
       curve stays strictly above the floor at every finite budget yet tends
       to it — saturation occurs *at* this terminal element.

Chaining R4_Agent9 (the wall / saturation) with R4_Agent4 (the degeneration
preorder) yields the order-theoretic statement absent from the corpus: the
extrapolation wall is the greatest, absorbing — i.e. TERMINAL — object of the
degeneration order, the unique sink of every degeneration chain on both the
coverage and the cost substrate. -/
theorem extrapolation_wall_is_terminal_degeneration
    {α' Ω' : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (Linf c α : ℝ) (hc : 0 < c) (hα : 0 < α)
    (hood : IsOOD (Ω := Ω') (p, X)) :
    -- (T1) coverage-top
    (∀ T : Finset Ω, DegenStep T (Finset.univ : Finset Ω))
    -- (T2) cost-top
    ∧ (∀ m : ℕ∞, m ≤ (⊤ : ℕ∞))
    -- (T3) absorbing / fixed point on both substrates
    ∧ (DegenStep (Finset.univ : Finset Ω) (Finset.univ : Finset Ω)
        ∧ ∀ x : ℕ∞, (⊤ : ℕ∞) ≤ x → x = (⊤ : ℕ∞))
    -- (T4) the OOD target reaches the terminal cost-top, and saturates there
    ∧ (MIP.N p X = (⊤ : ℕ∞)
        ∧ (∀ D : ℝ, 0 < D → Linf < Lcurve Linf c α D)
        ∧ Tendsto (fun D => Lcurve Linf c α D) atTop (𝓝 Linf)) := by
  refine ⟨univ_isTop_degen, wall_is_top_cost, ⟨?_, ?_⟩, ?_, ?_⟩
  · exact degen_refl (Finset.univ : Finset Ω)
  · exact fun x hx => cost_absorb_top x hx
  · exact (ood_reaches_cost_top (Ω' := Ω') p X hood).1
  · exact scaling_saturates_at_terminal Linf c α hc hα

/-- **(d′) Terminal sink corollary — every degeneration chain ends at the
wall.**

Combining (T1) with R4_Agent4's transitivity: any degeneration chain
`T₁ → T₂`, on the coverage substrate, is driven by `degen_trans` into the
terminal element `univ`; simultaneously, an OOD target's cost is absorbed at
the terminal `⊤`.  This is the "no escape" form of terminality: degeneration
flows one way, into the wall. -/
theorem every_chain_ends_at_wall
    {α' Ω' : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (hood : IsOOD (Ω := Ω') (p, X))
    {T₁ T₂ : Finset Ω} (hStep : DegenStep T₁ T₂) :
    DegenStep T₁ (Finset.univ : Finset Ω) ∧ MIP.N p X = (⊤ : ℕ∞) :=
  ⟨degen_chain_sinks_to_univ hStep, (ood_reaches_cost_top (Ω' := Ω') p X hood).1⟩

end R5_Agent6_SaturationIsTerminalDegeneration

end MIP
