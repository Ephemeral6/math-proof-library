# Agent 9 — Summary: Generalised impossibility theorems

**Direction:** Compound / cross-axis no-go theorems combining T.18.1 –
T.18.10 and axioms A.1–A.4. Hunt for joint failure modes — "no agent
can simultaneously achieve X and Y" — that follow trivially from
combinations of single-axis impossibilities but were never explicitly
stated.

**Method:** Take pairs/triples of single-axis impossibilities and
state their joint contradiction as a crisp `False`-conclusion
theorem.  Most compositions are 1–3 lines once the right shape is
identified; the value is in *exposing* the corollary as a stated
result, not in the proof depth.

---

## Files produced (9)

| File | STATUS | Headline |
|---|---|---|
| `Agent9_ConfigurationTable.lean` | DISCOVERY | **HEADLINE**: 9 of 12 (N-state, Phi0-state, coverage) configurations are derivably impossible; only the 3 trichotomy regimes R0/RP/R∞ are realisable |
| `Agent9_TripleImpossibility.lean` | DISCOVERY | Boolean-cube enumeration of 8 = 2·2·2 (N=0?, Phi0=0?, cov?) cells with 5 impossibility lemmas + `cube_reduces_to_three` headline |
| `Agent9_NPhi0_JointFailures.lean` | DISCOVERY | A.1-induced (N=0?, Phi0=0?) diagonal impossibility — `N_Phi0_dichotomy`: only (=,=) and (≠,≠) realisable |
| `Agent9_T18_CrossCompositions.lean` | DISCOVERY | T.18.5 ⊕ T.18.6 (OOD refutes universal alignment), T.18.3 ⊕ T.18.4 (training breaks self-model), partition mass-bound no-go's |
| `Agent9_T18_5_Sharpened.lean` | DISCOVERY | Sharpened T.18.5: under universal alignment, every problem is bivalent (R0 or RP) — the R∞ regime is universally excluded |
| `Agent9_T18_1_T18_6_OOD_Uncomputable.lean` | DISCOVERY | T.18.1 ⊕ T.18.6: OOD-detection is the configuration-wise complement of FiniteN (via A.2); joint structural identity |
| `Agent9_BData_Phi0_Impossibilities.lean` | DISCOVERY | No agent has `Phi0 = 0 ∧ B_data ≠ ∅`; concrete-model `B_data` non-emptiness forces `0 < N < ⊤` |
| `Agent9_Z_Impossibilities.lean` | DISCOVERY | Concrete-model impedance impossibilities: `Z, Z_min = 0`, `Z_max = ⊤`, no agent in the uniform-impedance regime |
| `Agent9_Partition_NoGo.lean` | DISCOVERY | Partition mass no-go's: no part > 1, no partition has all parts strictly above (or below) average — pigeonhole from T.18.10 |

**Total:** 9 DISCOVERY files. Zero OBSERVATION, zero DEAD END.
All zero-sorry, zero-new-axiom, all compile clean.

---

## Headline result

```lean
-- Agent9_ConfigurationTable.lean
theorem nine_configurations_impossible (p : Problem α) (X : Agent α) :
    -- (cell 2) N = 0 with no coverage:
    (N p X = 0 → (∀ R' ∈ ℛ(p), ¬ R' ⊆ K X) → False)
  ∧ -- (cells 3 & 4) N = 0 with Phi0 ≠ 0:
    (N p X = 0 → Phi0 X p ≠ 0 → False)
  ∧ -- (cells 5 & 6) 0 < N with Phi0 = 0:
    (0 < N p X → Phi0 X p = 0 → False)
  ∧ -- (cell 8) finite positive N with no coverage:
    (N p X < ⊤ → (∀ R' ∈ ℛ(p), ¬ R' ⊆ K X) → False)
  ∧ -- (cells 9 & 10) N = ⊤ with Phi0 = 0:
    (N p X = ⊤ → Phi0 X p = 0 → False)
  ∧ -- (cell 11) N = ⊤ with coverage:
    (N p X = ⊤ → (∃ R' ∈ ℛ(p), R' ⊆ K X) → False)
```

The (N-state, Phi0-state, coverage) configuration space has 3·2·2 = 12
cells.  A.1 + A.2 *jointly* rule out **exactly 9** of them, leaving
the 3 cells of Agent 2's trichotomy.  The trichotomy is *also a
negative result*: it's a count of impossible configurations.

## Most fertile cross-composition

`Agent9_T18_5_Sharpened.lean::T18_5_sharpened_bivalent`:

```lean
theorem T18_5_sharpened_bivalent
    (X : Agent α) (h_perfect : ∀ p : Problem α, N p X ≠ ⊤) :
    ∀ p : Problem α,
      (Phi0 X p = 0 ∧ N p X = 0)
        ∨ (Phi0 X p ≠ 0 ∧ 0 < N p X ∧ N p X < ⊤)
```

The existing `T18_5_alignment_impossible` only concludes coverage from
universal alignment.  Adding A.1 + the Agent-2 trichotomy gives the
**bivalent (Phi0, N) profile**: a universally aligned agent's
`(Phi0, N)` map lies on the diagonal `{(=0,=0), (≠0,0<N<⊤)}` — never
in the `N = ⊤` regime.

## Most useful structural composition

`Agent9_T18_1_T18_6_OOD_Uncomputable.lean::IsOOD_iff_not_FiniteN`:

```lean
theorem IsOOD_iff_not_FiniteN (c : Problem α × Agent α) :
    IsOOD (Ω := Ω) c ↔ ¬ MIP.Uncomputability.FiniteN c
```

The OOD predicate (T.18.6 hypothesis) and the FiniteN predicate
(T.18.1 target) are configuration-wise complements via A.2.  This is
the formal content of "OOD-detection is at least as hard as halting":
they're the same problem up to complementation.

## T.18 file that was easiest to combine

**T.18.6** (extrapolation wall).  Its statement
`(∀ R', ¬ R' ⊆ K X) → N p X = ⊤` is the cleanest single-line
contrapositive of A.2 in the codebase, so it slots cleanly into
T.18.5 (via `T18_5_T18_6_OOD_refutes_alignment`), T.18.1 (via
`IsOOD_iff_not_FiniteN`), and the configuration table (via cell 11).
Three discovery files use it as a pivot.

## Surprises / observations

1. **The cell `(true, false, false) = (N=0, Phi0≠0, ¬cov)` is doubly
   impossible** — refuted by *either* A.1 alone (Phi0 ≠ 0 contradicts
   N = 0) *or* A.2 alone (N = 0 → N ≠ ⊤ → coverage).  The dual
   cell `(N=⊤, Phi0=0, cov)` is similarly doubly impossible.  This
   makes both cells *robust* impossibilities: dropping either axiom
   still rules them out.

2. **T.18.10 (positive law) yields no-go corollaries.** The partition
   mass-bound (`impossible_part_mass_gt_one`, `impossible_all_parts_
   above_average`, etc.) are direct corollaries of T.18.10 + pigeonhole,
   but were never stated as impossibility theorems in the corpus.

3. **The concrete-model `Z` is fully degenerate as a no-go target.**
   Agent 5 already documented this; we restate as crisp
   `False`-conclusion theorems (`impossible_Z_positive`, etc.) for
   future Phase-6 models to "fail" when they replace the trivial
   definitions.

4. **T.18.2 (NP-hardness) does not compose easily.** Its
   `NPHardReduction` structure is a positive reducibility statement,
   not an impossibility.  We did not find a clean joint-impossibility
   composition with the other T.18 theorems.

5. **T.18.7 (metric unification) is already in joint form.** Its
   `PhaseSpaceIndependent` hypothesis is the joint impossibility
   bundle; we did not find a sharper composition.

## Non-findings / dead ends avoided

* Did NOT try to prove "OOD-detection is uncomputable" as a global
  statement.  That requires `enc` surjective (a stronger encoding
  hypothesis); we settle for the configuration-wise complementarity,
  which is the proper structural content.
* Did NOT redo Agent 2's `NTop_Chain` impossibility re-framing — that
  was already in the trichotomy DISCOVERY.
* Did NOT compose T.18.4 (Goodhart) with T.18.5 (alignment) into a
  joint statement; T.18.5 already absorbs T.18.6 (via `T18_5_OOD_failure`),
  so the natural T.18.4-T.18.5 composition would require external
  semantics ("`Intent_H`") that's not in the opaque API.
