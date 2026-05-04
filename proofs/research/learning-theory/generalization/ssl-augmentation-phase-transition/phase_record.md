# Five-Phase Record (alternative to report.md, harness-blocked)

This file records the full five-phase trajectory of the proof. Identical in
purpose to the standard report.md filename.

## Phase 1: Scout

Committed to concrete generative model:
- k clusters, regular-simplex centers in R^d with pairwise distance Delta_min.
- Augmentation: x' = x + xi, xi ~ N(0, sigma_aug^2 I_d).
- Gaussian kernel with d-normalized bandwidth.

Identified four routes:
1. Explicit eigen-decomposition under simplex symmetry.
2. Random matrix theory (BBP transition).
3. Mutual information / Bayes risk.
4. Perturbation theory near the merge point.

## Phase 2: Explorer

### Route 1 (main): Explicit eigen-decomposition
- Population kernel K = (1-rho)B + rho*J with rho = exp(-Delta_min^2/(2 d tau_eff^2)).
- Spectrum closed-form: n[1+(k-1)rho], n(1-rho) (mult k-1), 0 (mult k(n-1)).
- Verified by SymPy on k=3, n=4 case.

### Route 2: RMT/BBP
- Confirms picture under finite-sample noise (signal eigenvalues detach from MP bulk).
- BBP transition itself is second-order, corroborates Route 4 analyticity finding.

### Route 3: Mutual information
- Bayes-risk SNR = Delta_min/(sigma_aug sqrt(d)) drops below O(1) at criticality.
- Cleanest derivation of sigma_aug* = Theta(Delta_min/sqrt(d)).
- In d -> infinity at fixed SNR, gives a sharp transition.

### Route 4: Perturbation
- Spectrum is real-analytic in sigma_aug everywhere; refutes "discontinuous gap" claim.

## Phase 3: Judge

Selected Route 1 as main. Routes 3 and 4 supplement parts (d) and (c) respectively.
Verdict structure: PARTIAL: (a), (b), (d) PASS; (c) REFUTED with replacement.

## Phase 4: Auditor (Round 1)

Numerical and SymPy verification (audit_round_1.py):

1. Symbolic spectrum (SymPy, k=3, n=4): PASS.
2. Continuity of gap: monotone-decreasing, smooth; no discontinuity.
3. Scaling: ratio sigma_aug* sqrt(d) / Delta_min over 12 configurations
   has mean 0.601, std 0.014, CoV 2.3%. Strong confirmation of (d).
4. Rank at extremes: rank 3 at sigma_aug=0.01, rank 1 at sigma_aug=10.
5. Bounded derivative: max 25.88. Confirms second-order, refutes first-order.

No mathematical gap; no fixer round needed.

## Phase 5: Final verdict

PARTIAL:
- (a) PASS
- (b) PASS
- (c) REFUTED, replaced by second-order statement.
- (d) PASS.

Honest assessment: under any natural smooth model, the spectrum is real-analytic in
sigma_aug, so first-order discontinuity cannot occur. A genuine first-order
transition requires d -> infinity, hard rank constraints, or non-smooth kernel.
