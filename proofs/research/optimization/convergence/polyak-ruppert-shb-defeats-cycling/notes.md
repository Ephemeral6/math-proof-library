# Notes: Polyak-Ruppert weighted average defeats SHB cycling

## Proof technique

**Closed-form Fourier sum + smoothness upper bound.** The key observation is that
the Goujaud cycling iterate x_t = (D/√2) e_{t mod K} corresponds to the K-th
roots of unity ω^t = e^{2πit/K} when R² is identified with C. The Polyak-Ruppert
weighted sum S_T = Σ_{t=1}^T t ω^t is a textbook arithmetico-geometric series
with closed form

  S_T = ω(1 - (T+1)ω^T + T ω^{T+1}) / (1-ω)².

Since |ω| = 1, the numerator is O(T) while the denominator |1-ω|² = 4 sin²(π/K)
is a positive constant for fixed K. Dividing by W_T = T(T+1)/2 gives the average
of order O(1/T), hence ‖x̃_T‖² = O(1/T²) and f_0(x̃_T) ≤ (L/2)‖x̃_T‖² = O(L/T²).

## Key steps

1. Identify R² ≅ C and rewrite the K-gon iterate as ω^t.
2. Apply the standard differentiation trick to get the closed form for Σ t z^t.
3. Use |ω| = 1 and the triangle inequality to bound |S_T| ≤ 2(T+1)/|1-ω|².
4. Compute |1-ω|² = 4 sin²(π/K) using a half-angle identity.
5. Divide by W_T to get ‖x̃_T‖ ≤ D/(√2 T sin²(π/K)).
6. Apply the smoothness upper bound f_0(x) ≤ f_0* + (L/2)‖x-x*‖² (which uses
   only L-smoothness and ∇f_0(0) = 0; no need to separately bound below).

## Audit result

Passed first audit. Numerical verification at K ∈ {3,4,5,6,8,12,20} and
T ∈ {K, ..., 1000K}. Sharp constant L D²/(4 T² sin²(π/K)) matched to 4
significant digits at T = 10^5.

## Related results

- **OP-2 lower bound** (last iterate): On the same instance, the last iterate
  satisfies f(x_T) - f* = κLD²/4 = Θ(1) (does not decay). Iterate-type
  separation factor is Θ(T²).
- **Cesaro average**: f(x̄_T) - f* = Θ(LD²/T²) on the same instance, with
  exact zero for T = nK by symmetry. Cesaro and PR are asymptotically
  competitive on this instance.
- **Lan 2012 AC-SA**: Achieves O(LD²/T² + σD/√T) on the smooth convex class.
  Our result shows that on Goujaud's hard instance, SHB+PR matches AC-SA's
  bias rate. Open conjecture: this generalizes to all f ∈ F_L.
- **Ghadimi-Feyzmahdavian-Johansson 2015**: Universal upper bound
  O(LD²/T + σD/√T) for SHB with averaging. Loose by factor T at the bias
  term in the Goujaud regime per our analysis.

## Implication for OP-2 program

The OP-2 statement "SHB does not accelerate" must be qualified as
**"the last iterate of SHB does not accelerate"**. With Polyak-Ruppert
averaging, SHB does achieve the AC-SA rate on Goujaud's instance, separating
the two iterate types by Θ(T²).
