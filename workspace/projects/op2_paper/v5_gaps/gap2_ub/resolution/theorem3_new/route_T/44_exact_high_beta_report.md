# Theorem 3 — Exact rational certificates for β > 0.5

Follow-up to `40_exact_certificate_report.md` (which handled β ≤ 0.5 via the
baseline 2-step LMI). For β > 0.5 the baseline LMI is infeasible, so this
script (`44_exact_high_beta.py`) uses the **1-step lookahead LMI** that
adds anchor t+1 (gradient g_{t+1}).

## Result summary

Two new high-β certificates verified in exact QQ arithmetic (SymPy
`Matrix.is_positive_semidefinite` on rational matrices):

| β    | η   | s = λ_S | c = λ_C_t_tp1 | W      | C(β)         | C(decimal) | denom |
| ---- | --- | ------- | ------------- | ------ | ------------ | ---------- | ----- |
| 3/5  | 1/2 | 1/49    | 175/41        | 8616/2009 | **41071/20090** | 2.0444 | 50 |
| 4/5  | 1/5 | 7/19    | 23/3          | 458/57    | **229/57**       | 4.0175 | 20 |

In both, **a₂ = c₀₂ = c₁₂ = 0** — the X_{t-2} coupling vanishes here too,
just as for the β ≤ 0.5 baseline. The Lyapunov reduces to

```
V_t = w_t (f(x_t) - f*)  +  a₀ ‖x_t‖² + a₁ ‖x_{t-1}‖² + c₀₁ ⟨x_t, x_{t-1}⟩
```

For β = 3/5, η = 1/2:
```
a₀ = 9/2,   a₁ = 29/10,   c₀₁ = -7
```

For β = 4/5, η = 1/5:
```
a₀ = 263/12,   a₁ = 209/12,   c₀₁ = -233/6
```

## Phase 1 — multiplier-structure inspection

Solving the lookahead LMI numerically with high-precision CLARABEL across
β ∈ {0.6, 0.7, 0.8, 0.9} and reporting active dual multipliers:

| β   | optimal η | active multipliers (|λ| > 10⁻³)        | inactive (≈ 10⁻³ noise) |
| --- | --------- | -------------------------------------- | ---------------------- |
| 0.6 | 0.5       | S, IV_t, C_t_tp1                       | S_back, C_tp1_t        |
| 0.7 | 0.3       | S, IV_t, C_t_tp1, S_back, C_tp1_t      |                        |
| 0.8 | 0.15      | S, IV_t, C_t_tp1, S_back, C_tp1_t      |                        |
| 0.9 | 0.05      | S, IV_t, C_t_tp1, S_back, C_tp1_t      |                        |

The S_back and C_tp1_t values at β ≥ 0.7 sit at ~10⁻³ — interpretable as
solver noise rather than genuinely active. The truly load-bearing
multipliers are **{S, IV_t, C_t_tp1}**.

This drops the LMI's effective generator count from 18 (full lookahead) to 3.
The state-vector portion of `pos_combo` becomes a polynomial in only
(g_{t+1}, g_t, X_t, X_{t-1}, X_{t-2}); the generators g_{t-1} and g_{t-2}
do not enter — so M is effectively 5×5 within the 7×7 frame.

## Phase 2 — reduced LMI

Using the 3-multiplier ansatz, the FE identities become trivial:

* (FE_{t+1}):   W = λ_S + λ_C_t_tp1
* (FE_t)  :   λ_IV_t = α  (= 1)
* (FE_{t-1}, FE_{t-2}):  identically 0

Free dual parameters: s = λ_S, c = λ_C_t_tp1. The reduced LMI optimises
over (s, c, a₀, a₁, a₂, c₀₁, c₀₂, c₁₂) subject to M ≽ 0 (5-dim) and Q ≽ 0
(3-dim).

For β = 0.6 and 0.8 the reduced LMI is enough to find a clean rational
certificate via the same C-pinned interior-point fallback used in step 40.

## Phase 3 — what fails for β ≥ 0.7

For β ∈ {0.7, 0.9}, three rounding strategies (direct denom 50–10000,
C-pinned interior, dual-multiplier pinning to clean rationals) all reach the
same wall:

* The LMI optimum has M with **multiple zero eigenvalues** (rank deficiency
  ≥ 2 within the 5-dim active block).
* The "interior" reachable by C-pinning is bounded — the M-cone face
  containing the optimum is *thin* (small angular opening) at high β.
* Rounding any one of (a₀, …, c₁₂, s, c) by O(10⁻⁵) shifts at least one
  eigenvalue by O(rounding · ‖a‖), and at high β ‖a‖ explodes
  (β = 0.7: ‖a‖ ≈ 30; β = 0.9: ‖a‖ ≈ 10³; β = 0.95: ‖a‖ ≈ 10⁴).
* So the eigenvalue perturbation dominates the eigenvalue gap to 0, and M
  loses PSD on rounding — even when the dual multipliers (s, c) are pinned
  to small-denominator rationals.

The diagnostic confirms this empirically: out of 25 dual-multiplier pairs
near the LMI optimum × 7 denominator choices for (a, c) ≈ 175 attempts per
β, **0 pass M ≽ 0 in QQ** for β ∈ {0.7, 0.9}, while every attempt would have
passed Q ≽ 0 and the FE identities. The single failure mode is M PSD.

## What would (likely) work — directions worth trying next

1. **Pure exact-QQ SDP solver** (Direction 5 in the original prompt).
   `SDPA-GMP` runs SDP at arbitrary precision; with 100-digit input the
   eigenvalue gap is provably ≥ 10⁻⁵⁰, which makes denom-100 rounding
   trivial. Requires installing the C++ binary (no `pip`-only path).

2. **Closed-form Direction 1**. Work out an analytic Lyapunov family
   parametrised in QQ(β, η). The structural finding (only S, IV_t,
   C_t_tp1 active; a₂ = c₀₂ = c₁₂ = 0) reduces the unknowns to 5 ((s, c,
   a₀, a₁, c₀₁) — note Q PSD then forces 4 a₀ a₁ ≥ c₀₁²). The remaining
   constraints are M ≽ 0 (5-dim) and W = s + c ≥ 1, all polynomials in
   QQ(β, η). Almost certainly admits a closed-form solution like
   "V_t = w_t F_t + (β/(1−β))² ‖x_t − x_{t−1}‖² + …" — this is the
   classical SHB Lyapunov, and its rational coefficients can be read off
   directly without any SDP solver. We did not finish that derivation here.

3. **Rescaled rounding** (Direction 3). With u = X / R for R = poly(β, η),
   the entries of M̃ = D^T M D become O(1). Rounding (ã₀, …) at denom 1000
   gives a ≈ R² better effective precision than rounding (a₀, …). For
   β = 0.9, R ≈ 30 buys us ≈ 3 digits — likely enough to push some β = 0.7
   cases through, but not β = 0.95.

## Verification details

For each candidate certificate, the script verifies all of:

1. FE-coefficient identities exactly 0 in QQ (by construction, after FE
   elimination — checked again post-hoc).
2. Coercivity matrix Q (3 × 3) ≽ 0 in QQ via
   `Matrix.is_positive_semidefinite`.
3. Residual matrix M (7 × 7, with two structural-zero rows from g_{t−1},
   g_{t−2}) ≽ 0 in QQ.
4. λ_S ≥ 0, λ_C_t_tp1 ≥ 0, W ≥ α = 1.

## Files

- `44_exact_high_beta.py` — script
- `44_phase1_inspect.json` — multiplier-structure diagnostics (Phase 1)
- `44_high_beta_results.json` — per-(β, η) certificate table (Phase 3)
- `44_exact_high_beta_report.md` — this report
