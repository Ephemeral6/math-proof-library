# Generalization-Robustness Tradeoff in the Trajectory Framework

## Source
- Context: Trajectory-based stability analysis (signal-noise generalization decomposition à la Zhang et al. 2022 ICLR) extended to ℓ₂ adversarial perturbations of size r (Madry et al. 2018-style robustness, certified-radius-style analysis).
- Paper: Problem 7.10 from internal research-problem set; not a single published reference but a synthesis of trajectory-stability + adversarial-perturbation analysis.

## Statement

In the signal-noise trajectory framework where the standard generalization gap satisfies
   |E[L(θ_T)] − L̂(θ_T)|  ≤  G_S(T) + G_N(T)
(with G_S(T) the "signal" term and G_N(T) the "noise" term), define the adversarially robust generalization gap as
   R_adv(θ) := E[ max_{||δ||₂ ≤ r} L(θ; X + δ) ] − L̂(θ).

**Claim 1 (decomposition).** Under bounded mixed-Hessian curvature H = sup_{θ,x} ||∇_θ∇_x L(θ;x)||_op and the canonical SGD trajectory bound ||θ_T − θ_0|| ≤ G·√(Tη),

   R_adv(θ_T)  ≤  G_S(T) + G_N(T) + Penalty(r),
   
where  Penalty(r) = O(r · H · √(T·η)).

**Claim 2 (early stopping).** The optimal early-stopping time under adversarial perturbation T*_adv is **strictly less** than the clean optimum T*_clean. Asymptotically (and up to absorption of physical units),
   T*_adv  ≈  T*_clean / (1 + r² · H² · η).
The literal exponents are parameterization-dependent; under the natural (G_S = α/T, G_N = β√(Tη)) the exact ratio is (β/(β+crH))^{2/3}.

## Difficulty
research (PARTIAL on the literal Claim 2 quantitative formula; PASS on Claim 1 and on the strict inequality T*_adv < T*_clean)
