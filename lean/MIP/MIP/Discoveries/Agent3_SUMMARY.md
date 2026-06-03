# Agent 3 — Conservation-law consequences: Summary

**Goal.** From the conservation law T.18.10 (Σ_S π_S = 1) derive all the
elementary bounds and entropy/variance characterisations of the subdomain-
mass profile `π = (π_S)_{S ∈ parts}` of a `SubdomainPartition Ω` under a
normalised `ActivationDist Ω`. Tier the work as Tier A (moment/extremal
bounds), Tier B (entropy), Tier C (KL-to-uniform), Tier D (variance).

**Methodology.** First scanned existing R-SUB / Conjectures / Theorems
files for π-bound content:

| Existing | Statement |
|---|---|
| R-SUB.1 | `Σ π = 1` (T.18.10 conservation, the input). |
| R-SUB.2 | `π ≤ π'` pointwise + both sum to 1 ⟹ `π = π'` (Pareto). |
| R-SUB.3 | `π_{K₁∪K₂} ≤ π_{K₁} + π_{K₂}` (Boole / overlap). |
| R-SUB.7 | Chain rule: `H_K = H(π) + Σ π_S H_S`. |
| R-SUB.8 | `Σ π log π = 0 ⟺ each π_S ∈ {0,1}` (entropy-min vertex iff). |
| R-SUB.13 | KL chain rule. |
| Cj.NEW-13 | `H(q) ≤ log m` and uniform attains, but only for `q : ι → ℝ` abstractly. |

**Conclusion.** Tier A bounds (pointwise `π_S ≤ 1`, mean pigeonhole,
`∑ π²` brackets), Tier C (KL to uniform), and Tier D (variance form,
Bhatia-Davis) were *entirely absent* from the project. Tier B (entropy
bounds) was abstract-only — I specialised CjNEW13 to the partition
setting. R-SUB.8's vertex iff was extended to the *full Hpi* function on
partitions (not the per-term form).

---

## Files produced (all compile, zero `sorry`, zero new `axiom`)

| File | Tier | STATUS | Headline result |
|---|---|---|---|
| `Agent3_PiMassBounds.lean` | A | DISCOVERY | `0 ≤ π_S ≤ 1` for every part (the foundational unit-interval bound, needed by every downstream entropy/KL/variance result). Includes coerced-to-ℝ form. |
| `Agent3_PiPigeonhole.lean` | A | DISCOVERY | `max_S π_S ≥ 1/m` and `min_S π_S ≤ 1/m` (mean pigeonhole), packaged as `exists_pi_ge_mean` and `exists_pi_le_mean`, plus a combined `pi_mean_dichotomy`. |
| `Agent3_PiSqBounds.lean` | A | DISCOVERY | `1/m ≤ Σ π_S² ≤ 1` (collision-probability bracket). Upper bound from `π_S ≤ 1`; lower from Cauchy-Schwarz (`sq_sum_le_card_mul_sum_sq`). |
| `Agent3_PiEntropyBounds.lean` | B | DISCOVERY | `0 ≤ H_π ≤ log m` for the partition-mass Shannon entropy `H_π := -Σ π_S log π_S`. Includes the `Hpi = 0 ⟺ vertex` characterisation (full partition-level statement; R-SUB.8 only did the per-term form). |
| `Agent3_KLToUniform.lean` | C | DISCOVERY | KL-to-uniform `KL_to_uniform := log m - H_π`, with `0 ≤ KL ≤ log m`, saturation at vertex, zero at uniform. Pinsker NOT attempted (out of reach). |
| `Agent3_PiVariance.lean` | D | DISCOVERY | Population variance `Var_π := (1/m) Σ (π_S - 1/m)²`. Identity `Var_π = (1/m) Σ π_S² - 1/m²`, nonnegativity, full `Var_π = 0 ⟺ uniform` iff, Bhatia-Davis upper bound `Var_π ≤ (m-1)/m²`. |
| `Agent3_VertexKLMax.lean` | B+C | DISCOVERY | **HEADLINE**: three-way equivalence `Hpi = 0 ⟺ vertex partition ⟺ KL_to_uniform = log m`. The "catastrophic specialisation" structural fact. |
| `Agent3_Renyi2.lean` | B+ | DISCOVERY | Renyi-2 / collision entropy `H₂ := -log Σ π_S²`. Bracket `0 ≤ H₂ ≤ log m` (same range as Shannon), with the upper bound saturated iff `Σ π² = 1/m` (uniform). |

**Total: 8 DISCOVERY files. 0 OBSERVATION, 0 DEAD END.**

---

## Single most interesting result

**`Agent3_VertexKLMax.vertex_iff_KL_max`** — the headline catastrophic-
specialisation characterisation:

```lean
theorem vertex_iff_KL_max
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    (∀ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 0
      ∨ ((P.subdomainMass d S : NNReal) : ℝ) = 1)
    ↔ KL_to_uniform d P = Real.log (P.parts.card : ℝ)
```

A partition is "point-mass / vertex" (every part has mass 0 or 1) iff
its KL divergence to the uniform profile equals `log m`. Combined with
`catastrophic_specialisation` this gives the full three-way iff:

  `H_π = 0  ⟺  every π_S ∈ {0, 1}  ⟺  KL_to_uniform = log m`.

This is the cleanest formalisation of "specialist extreme = maximally
divergent from generalist" in the MIP subdomain-mass framework.

---

## Tier-by-tier richness observations

- **Tier A** was the most fertile by volume (3 files): pointwise `π ≤ 1`,
  mean pigeonhole (both directions), and `∑ π²` brackets. None of these
  were anywhere in the project despite all being direct consequences of
  the central conservation law.
- **Tier B** required bridging an abstract CjNEW13 statement (on `q : ι → ℝ`)
  to the partition setting via `Finset.attach` and `Fintype.card_coe`.
  Once the bridge was built, the upper bound `H_π ≤ log m` and the
  `H_π = 0 ⟺ vertex` characterisations followed cleanly.
- **Tier C** is the most "framing-novel" tier: `KL_to_uniform` is
  algebraically equivalent to `log m - H_π`, but the framing as a
  *divergence* (Gibbs inequality, with `0` at uniform and `log m` at
  vertex) gives a single number measuring "distance from generalist".
- **Tier D** required the variance *identity* `Var_π = (1/m) Σ π² - 1/m²`,
  then composed with the Tier A `∑ π² ≤ 1` bound to get the Bhatia-Davis
  upper bound `Var_π ≤ (m-1)/m²`. Tier D's `Var_π = 0 ⟺ uniform` is the
  variance-form counterpart of B's `H_π = log m ⟺ uniform` (the latter
  not formalised here in its converse direction, as it requires concavity
  equality case via Jensen — beyond clean Mathlib reach).

**Most fertile:** Tier A (3 file, plus implicit reuse in B/C/D).
**Most paper-novel:** Tier C `KL_to_uniform` framing — the
"specialisation index" `log m - H_π` is the natural single-number
measure of how far attention has collapsed.

---

## Strategy notes for downstream

- All eight files use the strict-NNReal `p : Ω → NNReal` plus a generic
  `SubdomainPartition Ω`, with no specialisation to any concrete model.
  They are fully reusable.
- The "inlined `pi_le_one_aux`" pattern (copying the proof verbatim into
  every file that needs `π ≤ 1` as a hypothesis) avoids the `lake build`
  dependency chain issue (each file compiles standalone via
  `lake env lean MIP/Discoveries/<file>.lean`).
- The `Finset.attach` / `Fintype.card_coe` bridge in
  `Agent3_PiEntropyBounds.lean` (specialising `q : ι → ℝ` to the
  partition's index subtype) is a general technique reusable for any
  abstract Mathlib result on probability vectors.
- Numerical sanity checks deliberately skipped (the Lean types enforce
  algebraic correctness; explicit small-`m` examples add noise without
  catching real bugs given the constructive nature of the proofs).

---

## File-naming and compilation

All files match `MIP/Discoveries/Agent3_*.lean`. All compile from
`C:\Users\12729\Desktop\Math\lean\MIP` via:
```
lake env lean MIP/Discoveries/Agent3_<topic>.lean
```
All exit code 0, only deprecation/linter warnings (no errors).
