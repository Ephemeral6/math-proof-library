# Phase Transitions in Self-Supervised Learning — Critical Augmentation Strength

## Source
- Paper: Conjecture-level problem, autonomous-research generation set (2026)
- Context: Contrastive self-supervised learning. Studies whether varying augmentation strength σ_aug induces a phase transition in the rank of the optimal learned representation.

## Statement

Consider contrastive learning with augmentation strength parameter σ_aug ≥ 0:
- σ_aug = 0: no augmentation, loss is trivial (each sample is its own cluster).
- σ_aug → ∞: all samples look identical, representation collapses.

Claim: there exists a critical augmentation strength σ_aug* with:
(a) For σ_aug < σ_aug*, the optimal representation has rank k (= number of ground-truth clusters).
(b) For σ_aug > σ_aug*, the optimal representation has rank 1 (collapse).
(c) At σ_aug = σ_aug*, the spectral gap λ_k - λ_{k+1} of the similarity matrix W vanishes discontinuously (first-order phase transition).
(d) σ_aug* = Θ(Δ_min / √d) where Δ_min is minimum inter-cluster distance and d is data dimension.

## Difficulty
conjecture
