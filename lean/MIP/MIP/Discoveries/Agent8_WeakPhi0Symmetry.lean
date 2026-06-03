/-
  STATUS: DISCOVERY
  AGENT: 8
  DIRECTION: Weak Phi0 symmetry — Phi0 X p = 0 ∧ Phi0 Y p = 0 forces
             N p X = N p Y = 0, even without any cross-agent bridge.
  SUMMARY:
    `Agent1_A1A4_Phi0Invariance.phi0_zero_iff_N_zero_across_A4_orbit` is
    a *bridged* statement: it needs `hPhiBridge : Phi0 X p = Phi0 X' p`
    to conclude `Phi0 X p = 0 ↔ N p X' = 0`. Without that bridge, no such
    iff is derivable across two unrelated agents — because A.4 only swaps
    tokens, it never compares Phi0 between two agents.

    But the *one-way symmetric* statement `Phi0 X p = 0 ∧ Phi0 Y p = 0
    → N p X = 0 ∧ N p Y = 0` is bridge-free: A.1.mpr at each agent
    independently. We package this as the "weak symmetry" lemma.

    We also state the three-agent extension and note (as theorems, not
    OBSERVATIONs) what is NOT derivable: A.1 yields no positive-finite
    cross-agent matching, only the zero/nonzero biconditional at each
    agent's own Phi0.
-/
import MIP.Axioms

namespace MIP

namespace Agent8_WeakPhi0Symmetry

variable {α : Type} {Ω : Type}

/-! ## (1) Weak Phi0 symmetry — both N = 0. -/

/-- **Weak Phi0 symmetry (two-agent).** If both `X` and `Y` have
`Phi0 · p = 0`, then both have `N p · = 0`. A.1.mpr at each agent. -/
theorem N_zero_both_of_phi0_zero_both
    (p : Problem α) (X Y : Agent α)
    (hX : Phi0 X p = 0) (hY : Phi0 Y p = 0) :
    N p X = 0 ∧ N p Y = 0 :=
  ⟨(Axioms.A1 p X).mpr hX, (Axioms.A1 p Y).mpr hY⟩

/-- **Weak Phi0 symmetry consequence: N equal at zero.** From the
two-agent version, `N p X = N p Y` (both being `0`). The cleanest
"symmetry of N across agents" statement that is bridge-free. -/
theorem N_eq_of_phi0_zero_both
    (p : Problem α) (X Y : Agent α)
    (hX : Phi0 X p = 0) (hY : Phi0 Y p = 0) :
    N p X = N p Y := by
  have ⟨hNx, hNy⟩ := N_zero_both_of_phi0_zero_both p X Y hX hY
  rw [hNx, hNy]

/-! ## (2) Three-agent extension. -/

/-- **Weak Phi0 symmetry (three-agent).** If all three agents have
`Phi0 · p = 0`, then all three have `N p · = 0`. -/
theorem N_zero_three_of_phi0_zero_three
    (p : Problem α) (A B C : Agent α)
    (hA : Phi0 A p = 0) (hB : Phi0 B p = 0) (hC : Phi0 C p = 0) :
    N p A = 0 ∧ N p B = 0 ∧ N p C = 0 :=
  ⟨(Axioms.A1 p A).mpr hA, (Axioms.A1 p B).mpr hB, (Axioms.A1 p C).mpr hC⟩

/-- **Three-agent equal-N at zero.** All three agents share the same
`N p · = 0` value. -/
theorem N_eq_three_of_phi0_zero_three
    (p : Problem α) (A B C : Agent α)
    (hA : Phi0 A p = 0) (hB : Phi0 B p = 0) (hC : Phi0 C p = 0) :
    N p A = N p B ∧ N p B = N p C := by
  have ⟨hNa, hNb, hNc⟩ := N_zero_three_of_phi0_zero_three p A B C hA hB hC
  refine ⟨?_, ?_⟩
  · rw [hNa, hNb]
  · rw [hNb, hNc]

/-! ## (3) Trivial-problem corollary. -/

/-- **All agents have N = 0 on the always-true problem.** Direct
application of weak Phi0 symmetry: `Phi0_always_true` gives Phi0 = 0 for
every agent, so A.1.mpr makes `N p · = 0` for every agent. -/
theorem N_zero_all_on_trivial
    (X Y : Agent α) :
    N (fun _ : Str α => true) X = 0 ∧ N (fun _ : Str α => true) Y = 0 :=
  N_zero_both_of_phi0_zero_both _ X Y (Phi0_always_true X) (Phi0_always_true Y)

/-- **Three-agent trivial-problem version.** -/
theorem N_zero_all_three_on_trivial
    (A B C : Agent α) :
    N (fun _ : Str α => true) A = 0
      ∧ N (fun _ : Str α => true) B = 0
      ∧ N (fun _ : Str α => true) C = 0 :=
  N_zero_three_of_phi0_zero_three _ A B C
    (Phi0_always_true A) (Phi0_always_true B) (Phi0_always_true C)

/-! ## (4) Contrapositive form. -/

/-- **Contrapositive: if some agent has `N p · > 0`, some agent has
`Phi0 · p ≠ 0`.** This is a "no free lunch" form of the weak symmetry. -/
theorem some_phi0_ne_zero_of_some_N_ne_zero
    (p : Problem α) (X Y : Agent α)
    (h : N p X ≠ 0 ∨ N p Y ≠ 0) :
    Phi0 X p ≠ 0 ∨ Phi0 Y p ≠ 0 := by
  rcases h with hX | hY
  · left; intro hPhi; exact hX ((Axioms.A1 p X).mpr hPhi)
  · right; intro hPhi; exact hY ((Axioms.A1 p Y).mpr hPhi)

end Agent8_WeakPhi0Symmetry

end MIP
