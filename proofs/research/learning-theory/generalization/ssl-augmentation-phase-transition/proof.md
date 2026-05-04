# Proof: SSL Augmentation Phase Transition

**Verdict: PARTIAL.** Parts (a), (b), (d) PASS. Part (c) is REFUTED for the natural Gaussian model — the transition is second-order (continuous gap closure), not first-order.

## 1. Generative model

We commit to a concrete model so spectral computations are explicit.

- Cluster centers μ_1, ..., μ_k ∈ ℝ^d form a regular simplex on the unit sphere with pairwise distance Δ_min.
- Each cluster is a Dirac at μ_c (we absorb σ_data² into bandwidth; the same arguments hold for σ_data ≪ Δ_min).
- Augmentation: x' = x + ξ with ξ ~ N(0, σ_aug² I_d).
- Kernel: k(u,v) = exp(-||u-v||² / (2dτ²)) with bandwidth τ. (The factor 1/d is the standard d-normalization that makes the kernel non-degenerate as d → ∞.)
- Each cluster has n samples; total N = kn.

## 2. Population kernel matrix

After Gaussian convolution, the augmented kernel is again Gaussian with effective per-coordinate variance τ_eff² := τ² + 2σ_aug²:

E_{ξ,ξ'}[exp(-||μ_c+ξ - μ_{c'}-ξ'||² / (2dτ²))] ∝ exp(-||μ_c-μ_{c'}||² / (2d τ_eff²)).

Define ρ := exp(-Δ_min² / (2d τ_eff²)) ∈ (0, 1). The data-level kernel matrix K (kn×kn) has entries
K_{ij} = 1 if c(i)=c(j), else ρ.
Equivalently, K = (1-ρ) B + ρ J, where B = block-diag(J_n, ..., J_n) (k blocks of all-ones n×n matrices) and J = 1_{kn}1_{kn}^T.

## 3. Spectrum of K (closed form)

**Claim.** The spectrum of K is:
- λ_1 = n[1 + (k-1)ρ] (mult 1, eigenvector v_1 = 1_{kn}/√(kn))
- λ_2 = ... = λ_k = n(1-ρ) (mult k-1, eigenspace = "between-cluster zero-sum" vectors)
- λ_{k+1} = ... = λ_{kn} = 0 (mult k(n-1), eigenspace = "within-cluster zero-sum" vectors)

**Proof.** Let v_1 = (1,1,...,1)/√(kn). Then K v_1 has each entry = (1-ρ)·n + ρ·kn/(kn ·1)... directly, K v_1 = [n(1-ρ) + ρ·kn]/√(kn) · 1 = n[1+(k-1)ρ] v_1.

For the between-cluster space: take any vector α ∈ ℝ^k with Σ_c α_c = 0, and lift to w_α with w_α restricted to cluster c equal to α_c · 1_n /√n (constant per cluster). Then K w_α: the i-th entry (in cluster c) equals
Σ_j K_{ij} (w_α)_j = (1-ρ)·n·(α_c/√n) + ρ·n·Σ_{c'} α_{c'}/√n = (1-ρ)·√n·α_c + 0 = (1-ρ)·n·(w_α)_i.
So K w_α = n(1-ρ) w_α, with k-1 such vectors (since {α : Σ α_c = 0} has dim k-1).

For the within-cluster zero-sum space: take w with Σ_{i in cluster c} w_i = 0 for each c. Then for i in cluster c:
(K w)_i = Σ_j K_{ij} w_j = (1-ρ) Σ_{j in c} w_j + ρ Σ_j w_j = 0 + 0 = 0.
This space has dimension k(n-1).

Total: 1 + (k-1) + k(n-1) = kn. ✓ (SymPy verification of the k=3, n=4 case confirms exact eigenvalues; see report.md Test 1.) ∎

## 4. Part (a): rank-k regime

For σ_aug small, ρ < 1, so λ_k = n(1-ρ) > 0 = λ_{k+1}. There is a non-zero gap, and the top-k eigenspace is the span of {v_1} ∪ {w_α : Σα = 0}, which is exactly the subspace of vectors that are constant on each cluster. The optimal rank-k representation under spectral contrastive loss (HaoChen-Wei-Gaidon-Ma 2021, Theorem 4.2) is the top-k eigenspace, so the optimal representation distinguishes the k clusters: it has effective rank k. ∎

## 5. Part (b): rank-1 collapse

As σ_aug → ∞, τ_eff² → ∞, ρ → 1. Then λ_2 = ... = λ_k = n(1-ρ) → 0, while λ_1 = n[1+(k-1)ρ] → kn. Only one eigenvalue stays bounded away from zero, and its eigenvector is the constant vector — i.e. the representation maps every input to the same point. Effective rank = 1: collapse. ∎

## 6. Part (c) — Honest analysis (REFUTED)

The gap g(σ_aug) = λ_k - λ_{k+1} = n(1 - ρ(σ_aug)) = n(1 - exp(-Δ_min² / (2d(τ²+2σ_aug²)))) is a smooth (real-analytic) function of σ_aug for σ_aug ∈ [0, ∞):
- σ_aug → 0: g → n(1 - exp(-Δ_min²/(2dτ²))).
- σ_aug → ∞: g → n · Δ_min²/(2d·2σ_aug²) → 0 polynomially.

The derivative dg/dσ_aug is bounded everywhere (numerically max ≈ 25.88 for k=3, d=10, Δ_min=1). There is **NO** discontinuity.

**Therefore the original claim "first-order phase transition with discontinuous gap" is FALSE under the chosen model.** What we can prove instead:

**Theorem (sharper second-order statement).** g(σ_aug) is monotone-decreasing, real-analytic, and decays at rate O(1/σ_aug²) as σ_aug → ∞. The transition is **second-order**: the gap closes continuously.

To recover sharpness, one can take the d → ∞ limit at fixed SNR Δ_min/(σ_aug√d), where concentration of measure produces a sharp Bayes-risk transition (Route 3 of explorer phase). But this is a high-dimensional limit, not a discontinuity at any single (k,d,Δ_min). ∎

## 7. Part (d): σ_aug* = Θ(Δ_min/√d)

Define σ_aug* by the criterion g(σ_aug*) = c · g(0) for some fixed c ∈ (0,1) (e.g., c = 1/2). Solving:
1 - exp(-Δ_min²/(2d τ_eff*²)) = c · (1 - exp(-Δ_min²/(2dτ²))).
For τ ≪ Δ_min/√d (signal-dominated regime), the right side ≈ c · 1, so:
Δ_min²/(2d τ_eff*²) = -log(1-c) =: λ_c (a constant)
⇒ τ_eff*² = Δ_min² / (2 d λ_c)
⇒ σ_aug*² = (τ_eff*² - τ²)/2 ≈ Δ_min² / (4 d λ_c) (for τ ≪)
⇒ **σ_aug* = Θ(Δ_min/√d)**.

Equivalently, the heuristic interpretation: in d dimensions, isotropic Gaussian augmentation has typical norm σ_aug · √d. Collapse onset is when this typical augmentation norm matches Δ_min:
σ_aug · √d ~ Δ_min ⇒ σ_aug* ~ Δ_min/√d.

**Numerical verification** (auditor_round_1.md, Test 3) over 12 (d, Δ_min) configurations in {4,10,25,50,100} × {0.5,1,2}: ratio σ_aug* · √d / Δ_min has mean 0.601 with std 0.014 (CoV 2.3%) — extremely stable across a 25× range of d and 4× range of Δ_min. ∎

## 8. Summary

- (a) **PASS** by §4.
- (b) **PASS** by §5.
- (c) **REFUTED** as stated; **second-order replacement PROVEN** in §6.
- (d) **PASS** by §7, with strong numerical corroboration.

Overall: **PARTIAL** verdict with honest refutation of (c).
