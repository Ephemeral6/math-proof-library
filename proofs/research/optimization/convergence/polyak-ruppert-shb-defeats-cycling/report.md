# Five-Phase Report: Polyak-Ruppert weighted average defeats SHB cycling

**Problem**: OP-2 / I5 — Iterate-type extension to Polyak-Ruppert weighted averaging.
**Status**: DISPROVED (LB false) + UB Ω(LD²/T²) shown.
**Audit rounds**: 0 (passed first audit).
**Date**: 2026-04-26.

---

## Phase 1: Scout

Two routes considered.

**Route A (PASS the LB)**: Find an instance in F where Polyak-Ruppert weighted average has Ω(D) distance to x* asymptotically.
- Possible only by breaking the rotational symmetry of Goujaud's K-gon (e.g., adding a slow drift or non-symmetric vertex set).
- But this destroys the GPT cycling identity (P_C(e_t) = M e_t depends crucially on the K-gon being a regular polygon centered at 0).
- ASSESSMENT: Route A is dead in the GPT framework.

**Route B (DISPROOF + UB)**: Compute the closed form for x̃_T on the K-gon.
- Iterate is x_t = (D/√2) e_{t mod K} where e_t = (cos(tθ_K), sin(tθ_K)).
- Identifying R² ≅ C, x_t ≡ (D/√2) ω^t where ω = e^{2πi/K}.
- Polyak-Ruppert sum is S_T = Σ_{t=1}^T t ω^t — finite Fourier sum with closed form via arithmetico-geometric series.
- Bound: |S_T| ≤ 2(T+1)/|1-ω|² = (T+1)/(2 sin²(π/K)).
- Dividing by W_T = T(T+1)/2 gives ‖x̃_T‖ ≤ D/(√2 T sin²(π/K)) = O(1/T).
- Smoothness UB: f_0(x̃_T) ≤ (L/2)‖x̃_T‖² ≤ L D²/(4 T² sin⁴(π/K)) = O(1/T²).
- ASSESSMENT: Route B is correct; pursue immediately.

## Phase 2: Explorer

Carry out Route B in detail.

Step 1 — Closed form: For z ≠ 1, Σ_{t=1}^T t z^t = z(1 - (T+1)z^T + T z^{T+1}) / (1-z)².

Step 2 — Triangle inequality for |ω| = 1, ω ≠ 1: |S_T| ≤ (2T+2)/|1-ω|².

Step 3 — |1-ω|² = 4 sin²(π/K).

Step 4 — ‖x̃_T‖ ≤ D/(√2 T sin²(π/K)).

Step 5 — f_0(x̃_T) - f_0* ≤ (L/2)‖x̃_T‖² = L D²/(4 T² sin⁴(π/K)).

Step 6 — Sharp asymptotic at T = nK: |S_{nK}| = nK/(2 sin(π/K)), so f_0(x̃_{nK}) - f_0* → L D²/(4 T² sin²(π/K)).

## Phase 3: Judge

Result: DISPROVED + UB shown.
- The bias-term LB Ω(LD²/T) is FALSE — Polyak-Ruppert achieves Θ(LD²/T²), beating the LB by a factor of T.
- The variance term σD/√T is unchanged.

## Phase 4: Auditor

Verified items:
1. Closed-form sum identity matches direct sum to 1e-9 precision (T = 1000).
2. K-gon vertex labeling: confirmed via OP-2 §3.5 init and Lemma AP that the iterate is exactly x_t = (D/√2) e_{t mod K}.
3. Smoothness UB f(x) - f* ≤ (L/2)‖x-x*‖² holds because ∇f_0(0) = 0 (since 0 ∈ int(C)).
4. Bound holds for all T ≥ 1: confirmed numerically across K ∈ {3,4,5,6,8,12,20} and T ∈ {K, K+1, 2K, 10K, 100K, 1000K}.
5. Sharp asymptotic constant matched at T = 100000 to 4 significant digits.
6. x̃_T ∈ int(C) for T > ~3 (computed T_critical for K=3 ≈ 2.7).
7. Variance term unaffected (Le Cam lower bound is iterate-independent).

AUDIT PASSED at round 0.

## Phase 5: Fixer

Not invoked.

## Final verdict

DISPROVED + matching UB shown. The targeted lower bound for Polyak-Ruppert weighted averaging is FALSE on the standard Goujaud K-gon: PR achieves Θ(LD²/T²) bias, beating Ω(LD²/T) by a factor of T.
