# Theorem 3 — Exact rational certificates (β ≤ 0.5)

**Goal.** Replace 1e-8-precision CLARABEL output with mathematically rigorous
rational Lyapunov certificates verified in SymPy exact (QQ) arithmetic.

**Result.** Seven exact QQ certificates produced and verified, covering the
entire required range β ∈ {0, 0.1, 0.2, 0.3, 0.4, 0.5}.

## Certificate table

All entries below are exact rationals; PSD checks done via
`sympy.Matrix.is_positive_semidefinite` in QQ.  L = 1, α = 1.

| β    | η   | W        | a₀       | a₁     | c₀₁     | C(β)     | C(decimal) | denom | strategy            |
| ---- | --- | -------- | -------- | ------ | ------- | -------- | ---------- | ----- | ------------------- |
| 0    | 1   | 1        | 1/2      | 0      | 0       | **1/2**  | 0.5000     | —     | textbook closed form |
| 0    | 3/2 | 1        | 1/3      | 0      | 0       | **1/3**  | 0.3333     | 50    | CLARABEL → round    |
| 1/10 | 1   | 51/50    | 25/44    | 1/55   | -3/22   | **23/50**| 0.4600     | 100   | C-pinned interior   |
| 1/5  | 1   | 26/25    | 61/85    | 2/17   | -37/85  | **21/50**| 0.4200     | 100   | C-pinned interior   |
| 3/10 | 1   | 41/20    | 21/20    | 2/5    | -11/10  | **7/8**  | 0.8750     | 20    | C-pinned interior   |
| 2/5  | 1   | 27/5     | 7/4      | 21/20  | -5/2    | **5/2**  | 2.5000     | 20    | C-pinned interior   |
| 1/2  | 1/2 | 101/50   | 23/8     | 11/8   | -15/4   | **101/100** | 1.0100  | 50    | C-pinned interior   |

In every certificate, a₂ = c₀₂ = c₁₂ = 0 (no Xₚ₂ coupling needed).

## Active multipliers

In **every** verified certificate the only nonzero dual multipliers are

```
  λ_S    = W
  λ_IV_t = 1
```

with all eight other multipliers identically 0 in QQ (β=0 textbook included).
This means the LMI's optimal Sum-of-Squares decomposition uses only:

* one smoothness inequality (`S`: f(x_{t+1}) ≤ f(x_t) + ⟨g_t, dy_t⟩ + (L/2)‖dy_t‖²),
* one interpolation inequality at x_t (`IV_t`: f(x_t) - f* ≥ ⟨g_t, x_t - x*⟩ - (1/(2L))‖g_t‖²
  — equivalently the cocoercivity at x_t with respect to x*),

and *none* of the cross-anchor convexity inequalities (`C_*`) or interpolations
at x_{t-1}, x_{t-2}.  This is a structural simplification visible only after
exact rationalisation: the noisy floating-point CLARABEL output had spurious
multipliers of order 0.05–0.1 on the C_* generators (see e.g. β=0 row in
`11_two_step_lmi_corrected_output.txt`); these are now provably zero.

## Lyapunov function

For every successful row above, the certificate proves the discrete recursion

```
  V_t  =  w_t · (f(x_t) - f*)  +  a₀‖x_t‖² + a₁‖x_{t-1}‖² + c₀₁⟨x_t, x_{t-1}⟩,
  V_{t+1} - V_t  ≤  0  pointwise,
  W = w_{t+1} = w_t + α,    α = 1,
```

so summing yields

```
  W · ( f(x_T) - f* )  +  Q(x_T, x_{T-1})  ≤  V_0
                                          ≤  (W - 1) · (f(x_0) - f*)
                                            + a₀‖x_0‖² + a₁‖x_{-1}‖² + c₀₁⟨x_0, x_{-1}⟩,
```

and the per-step Lyapunov bound contracts the function-error by a constant
C(β) = (W-1)·(L/2) + (a₀+a₁+c₀₁) (since a₂=c₀₂=c₁₂=0):

```
  f(x_T) - f*  ≤  C(β) / T   (asymptotically; with the standard sublinear-rate
                              accumulator argument from 2-step Lyapunov SHB).
```

## Verification details

For each (β, η) the script `40_exact_certificate.py` performs the
following exact QQ checks (all in SymPy):

1. **FE-coefficient identity.** All FE-related coefficients of
   `pos_combo := diff + Σᵢ λᵢ Gᵢ` vanish in QQ.
   *Implemented:* by construction the script solves
   `(λ_IV_t, λ_IV_p1, λ_IV_p2)` from the four FE identities given the seven
   "free" rounded multipliers, so the FE-identities hold by construction.
   Verification then confirms there are no residual FE×v cross monomials
   (there are none, since none of the generators contains FE×X or FE×g
   products — verified at runtime by `Poly.coeff_monomial` returning 0 in QQ).

2. **Residual matrix M ≽ 0.** The (g, X)-quadratic part of `pos_combo` is
   `-vᵀ M v`; M is a 6×6 matrix with QQ entries.  PSD verified via
   `M.is_positive_semidefinite` (exact QQ rank-revealing LDLᵀ).

3. **Coercivity Q ≽ 0.** The 3×3 Lyapunov-coercivity matrix
   `Q = [[a₀, c₀₁/2, c₀₂/2], [c₀₁/2, a₁, c₁₂/2], [c₀₂/2, c₁₂/2, a₂]]`
   is verified PSD in QQ.

4. **Sign and scaling.**  All λᵢ ≥ 0 and W ≥ α = 1 verified in QQ.

## Why naive rounding failed (and the fix)

At each LMI optimum, the residual matrix M is rank-deficient — multiple
eigenvalues are exactly 0.  `fractions.Fraction.limit_denominator(N)` introduces
a rounding error of order 1/N², which lifts those zero eigenvalues by ±O(1/N²);
half the perturbations come out negative, so M loses PSD.  Refining N up to
10⁴ does not help: the rounding margin is 10⁻⁸ but the eigenvalue gap to zero
is also 10⁻⁸ from CLARABEL's optimum.

The fallback is **C-pinned interior solve**: re-solve the LMI with the
constraint `(W-1)·L/2 + S ≤ C_max` for a *slightly relaxed* `C_max`
(C_clarabel + δ for δ ∈ {0.01, 0.02, 0.05, …}), and minimise sum-of-squares
of (a, c) instead of C.  This lands the solution at a strict interior of the
feasibility polytope (M strictly PSD with margin), so rounding to denom
20–100 succeeds and the verifier exits clean in QQ.  The price is a slight
loosening of C(β), which is recorded honestly in the table above.

## Limitations / non-goals

- **β > 0.5** with k=0 baseline LMI is infeasible at η=1.  At η=1/2 we get
  β=1/2, C=101/100 with a clean denom-50 certificate.  β=1/2 at η=7/10 also
  failed under our fallbacks (C-pinned interior solves did not produce a PSD
  rounded certificate).  For β=0.7, 0.9 the baseline is infeasible — the
  k=1 lookahead LMI from `26_lookahead_lmi.py` would be needed, and that's
  outside this script's scope.

- The C(β) values in the table are *certified upper bounds*, not optima.
  The true LMI optimum lies a small δ below (typically δ ≤ 0.01).  The exact
  rationalisation trades that δ for mathematical rigour.

- **β=1/2, η=7/10**:  the rounding was repeatedly blocked by either M not PSD
  or λ_IV_p1 < 0 at the higher-denominator attempts.  The β=1/2, η=1/2
  certificate above is preferred (smaller C and easier rationalisation).

## Files

- `40_exact_certificate.py` — script (verification pipeline + main sweep)
- `40_exact_certificate_results.json` — machine-readable cert table
- `40_exact_certificate_report.md` — this report
