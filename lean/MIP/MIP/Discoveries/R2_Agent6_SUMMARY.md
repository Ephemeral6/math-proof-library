# R2 Agent 6 — Multi-agent N-transitivity under K-containment

**Territory.** Extending Agent 8's three-agent N-finiteness chain
(`Agent8_ThreeAgent_Chain.ne_top_chain`) to longer chains, intersection
forms, finset-indexed forms, and the structural picture of
K-equivalence vs. N-stability.

**Setting.** Round 1 (Agent 8) established `K A ⊆ K B ⊆ K C → N p A ≠ ⊤
→ N p B ∧ N p C ≠ ⊤` and the numeric triangle obstruction. Round 2
sharpens by adding:

  - 4-agent and indexed-family chains,
  - K-containment → coverage transfer as a named lemma,
  - the `realisers` set with monotonicity, equality, and chain laws,
  - K-equality paired with the A.1 Phi0 bridge,
  - the Kpreorder / Kequiv structure with class-stability analysis,
  - intersection-form `K A ⊆ K B ∩ K C` finiteness transfer.

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `R2_Agent6_KChainFiniteness.lean` | DISCOVERY | 4-agent chain + indexed-family chain `ne_top_indexed_chain` (induction on chain length n). Star form `ne_top_of_dominates_finset`. |
| `R2_Agent6_KContainmentCoverage.lean` | DISCOVERY | Named `coverage_transfer_of_subset`, demand-witness transfer, and the set-level characterisation `K A ⊆ K B ↔ ∀ R', R' ⊆ K A → R' ⊆ K B`. |
| `R2_Agent6_RealisersTransport.lean` | DISCOVERY | `realisers p X := {R' ∈ ℛ(p) | R' ⊆ K X}`; monotonicity, A.2 restated as `N_finite_iff_realisers_nonempty`, K-equality gives `realisers` equality, triple-intersection identity. |
| `R2_Agent6_KEqualityNFiniteness.lean` | DISCOVERY | K-eq → N-finiteness biconditional + paired A.1 form + N-zero biconditional under Phi0 bridge. Trivial-problem unconditional N-equality. |
| `R2_Agent6_KPreorderQuotient.lean` | DISCOVERY | `Kpreorder` + `Kequiv` with reflexivity/transitivity/antisymmetry. Class-stable predicates: `N = ⊤`, `N ≠ ⊤`, the A.1 biconditional. Non-class-stable: `N = 0`, `Phi0 = 0`, numerical `N` value. |
| `R2_Agent6_InterFiniteness.lean` | DISCOVERY | Intersection form: `K A ⊆ K B ∩ K C → N p A ≠ ⊤ → N p B ∧ N p C ≠ ⊤`. Single shared witness via A.2. Four-agent and finset-indexed extensions. |

**Total: 6 DISCOVERY.** All compile, zero `sorry`, zero new `axiom`.

---

## Single most interesting result

`R2_Agent6_KChainFiniteness.ne_top_indexed_chain`:

> Given `f : ℕ → Agent α` with `K (f i) ⊆ K (f (i+1))` for every
> `i < n`, if `N p (f 0) ≠ ⊤`, then `N p (f k) ≠ ⊤` for every `k ≤ n`.

This is the clean generalisation of Agent 8's 3-agent chain to arbitrary
length. The proof is by induction on `n`, using `ne_top_of_subset` at
each step. Companion `R2_Agent6_KChainFiniteness.ne_top_of_dominates_finset`
gives the "star" form: one finite source, many K-dominators, all of
which inherit finiteness via the same A.2 witness.

`R2_Agent6_RealisersTransport.realisers_mono` is the structural lemma:
the realiser set `realisers p X := {R' ∈ ℛ(p) | R' ⊆ K X}` is monotone
in K, and via `N_finite_iff_realisers_nonempty` we have a clean
membership-vs.-emptiness reformulation of A.2.

---

## Per-question results (matching the prompt structure)

### (1) K-chain → N-finiteness transitivity (extended)

  * **4-agent chain:** `R2_Agent6_KChainFiniteness.ne_top_chain_four` —
    `K A ⊆ K B ⊆ K C ⊆ K D → N p A ≠ ⊤ → N p B ∧ N p C ∧ N p D ≠ ⊤`.
  * **k-agent indexed family:** `R2_Agent6_KChainFiniteness.ne_top_indexed_chain` —
    induction on chain length over `ℕ → Agent α`.
  * **Star form:** `R2_Agent6_KChainFiniteness.ne_top_of_dominates_finset` —
    one A0, finset of K-dominators, all finite.

### (2) K-containment → coverage transfer

  * **Single demand:** `R2_Agent6_KContainmentCoverage.coverage_transfer_of_subset` —
    `K A ⊆ K B → R' ⊆ K A → R' ⊆ K B` (1-line `.trans`).
  * **2-agent specialisation:** `R2_Agent6_KContainmentCoverage.ne_top_of_subset_two_agent`
    derived via the coverage-transfer named lemma; cross-checked with
    `ne_top_of_subset_via_chain` showing it's the length-2 case of the
    Agent 8 chain.

### (3) "Demand-realiser" containment

  * **Definition:** `R2_Agent6_RealisersTransport.realisers`.
  * **Monotonicity:** `realisers_mono`.
  * **A.2 restatement:** `N_finite_iff_realisers_nonempty`.
  * **Empty/top:** `realisers_empty_iff_top` (the reverse direction).

### (4) N-EQUALITY under K-equality + Phi0 bridge

  * **K-eq → N-finiteness iff:** `R2_Agent6_KEqualityNFiniteness.N_ne_top_iff_under_K_eq`
    (re-derivation of Agent 1's result).
  * **Paired A.1:** `K_eq_paired_A1` packages both A.1 instances under
    K-equality.
  * **Phi0-bridge form:** `N_zero_iff_under_K_eq_with_Phi0_bridge` and
    `K_eq_Phi0_bridge_full` — the conditional that delivers
    `N p A = 0 ↔ N p B = 0` *assuming* the missing
    `Phi0 A p = Phi0 B p` bridge (which Agent 8's DEAD END showed is
    NOT derivable from A.1–A.4).
  * **Trivial problem:** `N_eq_at_trivial_problem` — unconditional
    N-equality at the always-true problem.
  * **OBSERVATION:** numeric `N p A = N p B` from `K A = K B` alone is
    NOT derivable; documented in
    `R2_Agent6_KPreorderQuotient.N_eq_conditional_from_K_eq` (trivial
    statement that captures the obstruction).

### (5) Containment-equivalence quotient

  * **Kpreorder:** `R2_Agent6_KPreorderQuotient.Kpreorder` with
    `Kpreorder_refl`, `Kpreorder_trans`.
  * **Kequiv:** `Kequiv` with `Kequiv_refl`, `Kequiv_symm`,
    `Kequiv_trans`, `Kequiv_of_Kpreorder_antisymm`.
  * **Class-stable lifts:** `N_top_lifts_to_K_classes`,
    `N_ne_top_lifts_to_K_classes`, `A1_biconditional_class_stable`,
    `N_ne_top_lifts_triple`.
  * **Non-class-stable (conditional forms):**
    `N_zero_class_stable_under_Phi0_bridge`,
    `Phi0_zero_class_stable_under_Phi0_bridge`.

### (6) Three-agent intersection (positive cases)

  * **Inclusion form:** `R2_Agent6_InterFiniteness.inter_finiteness_transfer` —
    `K A ⊆ K B ∩ K C → N p A ≠ ⊤ → N p B ∧ N p C ≠ ⊤`.
  * **Witness form:** `inter_coverage_witness` — A's single A.2
    demand-witness covers both `K B` and `K C`.
  * **K-equality form:** `inter_finiteness_transfer_K_eq` — adds
    nothing extra over inclusion (intersection-equality just gives the
    inclusion direction we need).
  * **Four-agent:** `inter_finiteness_transfer_four`.
  * **Finset-indexed:** `inter_finiteness_transfer_finset` and
    `inter_coverage_witness_finset`.
  * **Backward:** `A_top_of_any_inter_top` — contrapositive form.

---

## What is NOT derivable (documented obstructions)

1. **Numeric N-equality from K-equality.** `K A = K B → N p A = N p B`
   is not derivable; Agent 8's `Phi0_CrossAgent_DeadEnd` confirms.
   We package the conditional statement (which is a vacuous identity).
2. **`Phi0 A p = Phi0 B p` from `K A = K B`.** Same DEAD END; A.4 only
   swaps tokens within a fixed agent.
3. **Numeric triangle `N p A ≤ N p B + N p C`.** Agent 8's
   `TriangleInequality_Obstruction` — requires an agent-merge operator
   not in the opaque signature.

These are stated as conditional bridges or OBSERVATIONs — never
introduced as new axioms.

---

## Compilation

All 6 files compiled with
`lake env lean MIP/Discoveries/R2_Agent6_*.lean` from
`C:\Users\12729\Desktop\Math\lean\MIP\`. Each file is independent of
the other R2 Agent 6 files; each pulls only from `MIP.Axioms` and
standard Mathlib set / finset utilities.
