# OT Characterization of Contrastive Representations (Conjecture, refuted-as-stated)

## Source
- Paper / context: spectral contrastive loss (HaoChen, Wei, Gaidon, Ma, NeurIPS 2021), augmentation graph theory, optimal-transport view of representation learning.
- Problem: 7.1 (research-level conjecture).

## Statement (as posed)

Let f*: X -> R^k be the optimal representation under the spectral contrastive loss with similarity matrix W. Let mu_c denote the data distribution restricted to cluster c (c = 1, ..., k).

Claim: f* = argmin_f sum_{c=1}^k W_2^2(f_# mu_c, delta_{z_c}), where z_c are rows of U_k (top-k eigenvectors of W) up to rotation R ∈ O(k).

## Difficulty
conjecture

## Verdict
**PARTIAL.** Literal claim refuted by counterexample (non-block W); refined block-aligned version proved.
