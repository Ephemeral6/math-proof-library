/-
  STATUS: DISCOVERY
  AGENT: R2_Agent3
  DIRECTION: Adding `(B_data p X).card` as a "configuration axis" gives no
    independent impossibility — it is functionally coupled to the N-axis.
  SUMMARY:
    A naive 4th axis-extension to the Agent 9 configuration table would be
    `B_data.card ∈ {= 0, > 0 ∧ < ⊤, = ⊤}`, multiplying the 12-cell space
    by 3 to give 36 cells.  But Agent 4's `B_data_card_eq_toNat` proves
    `(B_data p X).card = (N p X).toNat` UNCONDITIONALLY: the B_data axis
    is a *function* of the N axis, not an independent axis.  Every cell
    where the B_data-state is inconsistent with the N-state is
    impossible — but those impossibilities are *identities*, not new
    information.

    We catalogue:
      * the coupled identity `B_data.card = (N p X).toNat`,
      * the 6 "inconsistent (N, B_data)" cells, each impossible,
      * the corollary that B_data.card is NEVER `= ⊤` (it is a `ℕ`, so
        the "= ⊤" state is type-trivially unreachable as a `ℕ`-valued
        quantity, but if reinterpreted as `(B_data.card : ℕ∞)` then
        `= ⊤` holds iff `N = ⊤`).

    Honest accounting: adding B_data as an axis yields ZERO new genuine
    impossibilities beyond the Round-1 9.  The cells it appears to rule
    out are tautological identifications with N-cells.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Discoveries.Agent4_BData_Card_Unconditional

namespace MIP

namespace R2_Agent3_BData_NCoupled

open Agent4_BData_Card_Unconditional

variable {α : Type}

/-! ## The coupled identity

The B_data and N axes are not independent: the B_data card is a
*function* of (N p X).toNat. -/

/-- **Coupled identity (restated).** `(B_data p X).card = (N p X).toNat`,
unconditionally.  This is the entire content of the "B_data axis": it
is determined by N. -/
theorem B_data_card_coupled_to_N (p : Problem α) (X : Agent α) :
    (B_data p X).card = (N p X).toNat :=
  B_data_card_eq_toNat p X

/-- **Coupled identity in `ℕ∞`-form when N is finite.** -/
theorem B_data_card_eq_N_finite (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤) :
    ((B_data p X).card : ℕ∞) = N p X := by
  rw [B_data_card_coupled_to_N]
  exact ENat.coe_toNat hFin

/-! ## Inconsistent (N, B_data) cells — impossibilities by identity

We enumerate the cells where the B_data-state contradicts the N-state.
Each is impossible BUT only because B_data.card is *defined* by N — they
are not independent constraints. -/

/-- **(N = 0) but (B_data.card ≥ 1) — impossible.** B_data.card = 0
when N = 0. -/
theorem impossible_N0_BDataNonempty
    (p : Problem α) (X : Agent α)
    (hN : N p X = 0) (hCard : 1 ≤ (B_data p X).card) : False := by
  rw [B_data_card_coupled_to_N] at hCard
  rw [hN] at hCard
  simp at hCard

/-- **(N finite > 0) but (B_data.card = 0) — impossible.** -/
theorem impossible_NfinPos_BDataEmpty
    (p : Problem α) (X : Agent α)
    (hPos : 0 < N p X) (hFin : N p X ≠ ⊤)
    (hCard : (B_data p X).card = 0) : False := by
  rw [B_data_card_coupled_to_N] at hCard
  have hToNatPos : 0 < (N p X).toNat := by
    have : (((N p X).toNat : ℕ∞)) = N p X := ENat.coe_toNat hFin
    have hLt : (0 : ℕ∞) < N p X := hPos
    have : (0 : ℕ∞) < ((N p X).toNat : ℕ∞) := by rw [this]; exact hLt
    exact_mod_cast this
  omega

/-- **(N = ⊤) but (B_data.card ≥ 1) — impossible.** When N = ⊤,
B_data.card = (⊤ : ℕ∞).toNat = 0. -/
theorem impossible_NTop_BDataNonempty
    (p : Problem α) (X : Agent α)
    (hN : N p X = ⊤) (hCard : 1 ≤ (B_data p X).card) : False := by
  rw [B_data_card_coupled_to_N] at hCard
  rw [hN] at hCard
  simp at hCard

/-! ## The B_data axis "= ⊤" cell is type-trivially unreachable

`B_data.card : ℕ` cannot equal `⊤`; the maximum is just the cardinality
of the underlying type's image.  If reinterpreted as `(·.card : ℕ∞)`,
then `= ⊤` requires the cast to take the value `⊤`, which never happens
for a `ℕ`-valued quantity. -/

/-- **The B_data.card is always finite.** As a `ℕ∞`, `(B_data.card : ℕ∞)`
is never `⊤`.  -/
theorem B_data_card_ne_top (p : Problem α) (X : Agent α) :
    ((B_data p X).card : ℕ∞) ≠ ⊤ := by
  exact ENat.coe_ne_top _

/-- **Impossible: `B_data.card = ⊤` (in ℕ∞).** Cast of a ℕ is never ⊤. -/
theorem impossible_BData_top (p : Problem α) (X : Agent α)
    (h : ((B_data p X).card : ℕ∞) = ⊤) : False :=
  B_data_card_ne_top p X h

/-! ## Headline: B_data axis yields no new independent impossibility

We state explicitly: every (N, B_data) cell that is inconsistent is
ruled out by the IDENTITY `B_data.card = (N p X).toNat`, not by a new
axiom or principle.  No new impossibility theorem genuinely depends on
the B_data axis. -/

/-- **Headline (negative result).** The B_data axis is a tautological
function of the N axis: `(B_data p X).card = (N p X).toNat`.  In
particular, every (N, B_data) cell with `B_data.card ≠ (N p X).toNat`
is impossible — but this is a single identity, not an independent
constraint.

Formal statement: the only realisable (N-state, B_data-card) configurations
are those where the card EQUALS `(N p X).toNat`. -/
theorem BData_axis_is_NAxis_function
    (p : Problem α) (X : Agent α) :
    ∀ k : ℕ, ((B_data p X).card = k) ↔ ((N p X).toNat = k) := by
  intro k
  rw [B_data_card_coupled_to_N]

/-- **No-new-impossibility headline.** ANY (N-state, B_data-state) cell
where the B_data state is inconsistent with N is impossible *by the
coupling identity*. -/
theorem inconsistent_NBData_impossible
    (p : Problem α) (X : Agent α)
    (k : ℕ) (hMismatch : (B_data p X).card = k ∧ (N p X).toNat ≠ k) :
    False := by
  have h := hMismatch.1
  rw [B_data_card_coupled_to_N] at h
  exact hMismatch.2 h

end R2_Agent3_BData_NCoupled

end MIP
