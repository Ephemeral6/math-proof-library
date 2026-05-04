# Polyak-Ruppert weighted average defeats SHB cycling on Goujaud's hard instance

## Source
- Paper: Iterate-type extension of OP-2 lower bound (Goujaud-Taylor-Dieuleveut 2023)
- Context: OP-2 proved that on Goujaud's cycling region F, the LAST iterate of
  SHB satisfies E[f(x_T) - f*] >= c (LD^2/T + sigma D / sqrt T). Cesaro averaging
  collapses the K-gon to x*. Question: does Polyak-Ruppert weighted averaging
  with linear weights w_t ∝ t still allow Ω(LD^2/T) (because later iterates are
  weighted more), or does the bias also collapse?

## Statement (DISPROVED + matching upper bound)

For every (β, η) ∈ F (Goujaud cycling region) and every K ≥ 3 with the
corresponding deterministic SHB iterate x_t = (D/√2) e_{t mod K} on the OP-2
construction f_0, the Polyak-Ruppert weighted average

  x̃_T := Σ_{t=1}^T t · x_t  /  W_T,    W_T = T(T+1)/2

satisfies the upper bound

  f_0(x̃_T) - f_0*  ≤  L D² / (4 T² sin⁴(π/K))   for all T ≥ 1,

with sharp leading-order constant L D² / (4 T² sin²(π/K)) as T → ∞.

In particular, the targeted lower bound Ω(LD²/T) is FALSE — Polyak-Ruppert beats
the targeted rate by a factor of T at the bias term.

## Difficulty
research

## Implication

Iterate-type separation: on the same hard instance,
- Last iterate: f(x_T) - f* = Θ(LD²)  (constant, no decay)
- Cesaro average: f(x̄_T) - f* = Θ(LD²/T²)  (period averaging)
- Polyak-Ruppert: f(x̃_T) - f* = Θ(LD²/T²)  (this work)

Polyak-Ruppert achieves the AC-SA acceleration rate at the bias term on
Goujaud's instance, while the last iterate is stuck at Θ(1).
