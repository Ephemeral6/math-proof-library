# Agent 5 — Z–κ Relationship at the Formal Layer

**Direction.** Relationships between the impedance `Z` (and its
companions `Z_min`, `Z_max`, `Z⁻¹`) and a "transmission/learning-rate"
coefficient `κ` in the formal MIP development.

**Headline.** The Z–κ relationship is *unreachable* from `A.1–A.4`
alone: there is **no global opaque `κ`** in the codebase — every R-file
introduces its own file-local `kappa` as a plain real-valued
trajectory (R.105 Gompertz, R.110 estimable, R.114 reciprocal-impedance,
R.201 Fisher metric, R.818 contextual κ̄, etc.) — and the global
`MIP.Z` is the constant function `0` in the concrete state-sequence
model. So at the formal layer, all "coupled" Ohm-form quantities
(`Phi0 · Z`, `Phi0 · Z⁻¹`, `Z · κ`, `Z⁻¹ · κ`) collapse to
extreme `ENNReal` values (either `0` or `⊤`), and the book-level
nuance of the Z–κ interplay is invisible.

This is itself a structural contribution: it tells the reader exactly
which book-level statements need a richer impedance model (Phase 6 in
the MIP roadmap) to be Lean-formalisable.

## What κ turned out to be

Searching `MIP/` for `def kappa | opaque kappa | noncomputable def κ | opaque κ` yields **eleven** file-local
definitions, each with its own signature:

| File | Signature | Meaning |
|---|---|---|
| R.105 | `kappa (κ₀ α t : ℝ) : ℝ := exp(log κ₀ · exp(-α t))` | Gompertz κ-trajectory |
| R.110 | (uses `κ` as a hypothetical real-valued estimand) | estimable κ statistic |
| R.114 | (uses `Z, κ` as plain real hypothesis variables) | Z⁻¹ vs |K| sign-indefiniteness |
| R.201 | (uses `ζ = Z⁻¹` and `κ`-dual mention) | Fisher metric on `Z⁻¹` |
| R.410, R.429, R.452, R.98 | Gompertz forms | trajectory variants |
| R.450 | `κ_witness : ℕ → ℝ` | tower-magma kappa |
| R.470 | `kappaSat` | saturation cardinality |
| R.518 | `kappaInf` | grokking-suppression kappa |
| R.817, R.818 | `κctx / κ̄ : Finset (Ω×Ω) → ℝ` | contextual closure density |

There is **no global `MIP.κ`**. The opaque symbols in `MIP/Axioms.lean`
related to κ are `K` (knowledge space) and `Cₑ` (knowledge density),
neither of which admits a derivable algebraic relation to `MIP.Z`.

## Output

Six compile-clean files (zero `sorry`, zero new `axiom`).

| File | Status | Headline |
|---|---|---|
| `Agent5_Z_Constancy.lean` | DISCOVERY | `Z = 0`, `Z_min = 0`, `Z_max = ⊤`; global constancy over `(X, p)` |
| `Agent5_Z_Sandwich.lean` | DISCOVERY | `Z_sandwich`, `Z_min_ne_Z_max` — uniform-impedance regime of D.4.9 is **empty** in the formal model |
| `Agent5_T8_Collapse.lean` | DISCOVERY | `⌈Φ₀ · Z⌉ = 0` always; T.8 Ohm-equality holds iff `Phi0 = 0`; strict undershoot whenever `Phi0 ≠ 0` |
| `Agent5_Z_Inversion.lean` | DISCOVERY | `Z⁻¹ = ⊤`, `Z_min⁻¹ = ⊤`, `Z_max⁻¹ = 0`; reversed sandwich; product/quotient dichotomies |
| `Agent5_Kappa_Indep.lean` | OBSERVATION | No algebraic Z–κ relation derivable from A.1–A.4; R.114 regime-distinguishability lost at this layer |
| `Agent5_Z_Dynamics_DeadEnd.lean` | DEAD END | Time-derivative `dZ/dt = ?` direction unreachable: `MIP.Z` has no time index, A.1–A.4 contain no time variable |

## Most fertile group

`Agent5_T8_Collapse.lean` produced the sharpest formal statement:

```lean
theorem T8_Ohm_holds_iff_Phi0_zero (X : Agent α) (p : Problem α) :
    N p X = ceilENat (Phi0 X p * Z X p) ↔ Phi0 X p = 0
```

This is the formal counterpart of the book's "T.8 strict-equality Ohm
law" — in the concrete model it holds *exactly on the trivially-solved
problems*, by A.1. The dual, "strict undershoot whenever `Phi0 ≠ 0`",
quantifies the model's degeneracy.

## Most useful negative result

`Agent5_Z_Sandwich.lean::Z_min_ne_Z_max`: the *uniform-impedance regime*
`Z_min X p = Z_max X p` of D.4.9 — which T.8 Step 4 needs to fire — is
**empty** in the formal model. This is why `T8_OhmLaw_core` in
`StateSequence.lean` proves the Ohm law vacuously by deriving `0 = ⊤`
from the uniform-impedance hypothesis. Future Phase-6 models must
re-engineer this regime.

## Why no DISCOVERY-class Z–κ coupling exists

The OBSERVATION file proves three "no-go" facts:

1. `Z_indep_of_R105_kappa` — `Z X p` does not depend on the R.105
   `(κ₀, α, t)` parameters at all.
2. `Phi0_Z_times_kappa_eq_zero` — the natural coupling
   `(Phi0 · Z) · κ_e` is identically zero in `ENNReal`.
3. `R114_regime_distinguishability_lost` — the two R.114 training
   regimes (balanced vs overfit) become indistinguishable when
   translated into the global `MIP.Z`.

The structural reason: `MIP/Axioms.lean` introduces no opaque symbol
that *both* depends on `Z X p` *and* is real-valued. So even granting
any extra hypothesis on `κ`, the impedance side of the equation is
forced to `0`, and the equation degenerates.

## Reachability of the Z–κ relationship from A.1–A.4

**Not reachable.** This direction is structurally blocked by the
concrete state-sequence model's degenerate impedance definition.
Phase-6 (substantive impedance model) is required.
