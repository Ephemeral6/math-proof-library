# Notes: OT Characterization of Contrastive Representations

## Proof technique
Combined approach: (Route 1) block-structured spectral identification with Eckart-Young + Perron-Frobenius for the PASS direction; (Route 4) explicit numerical counterexample for the FAIL direction.

## Key steps
1. **Brenier identity for OT to Dirac**: W_2^2(nu, delta_z) = integral ||y-z||^2 dnu(y). Reduces OT objective to within-cluster variance.
2. **HaoChen et al. lemma**: L_spec(f) = ||A_tilde - F_bar F_bar^T||_F^2 + const.
3. **Eckart-Young**: F_bar* = U_k Lambda_k^{1/2} R for any rotation R ∈ O(k).
4. **Block-diagonal A_tilde implies disjoint top-k eigenvectors** (Perron-Frobenius per block + spectral gap).
5. **Regular block + uniform prior implies F^{spec} constant on each cluster**, hence J_OT = 0.
6. **Counterexample**: at eps = 0.3, the spectral and cluster-constant optima differ in opposite directions on L_spec and J_OT.

## Audit result
Single audit round; all steps verified by SymPy, NumPy, and Z3. No fixer needed. The conjecture as literally stated is refuted; refined version with explicit hypotheses (H1)-(H3) is proved.

## Related results
- HaoChen, Wei, Gaidon, Ma (NeurIPS 2021): spectral contrastive loss; this proof inverts their analysis to compare with OT.
- Ding & He (2004): k-means as PCA relaxation; same equivalence pattern under different normalization.
- Davis-Kahan theorem: stability of eigenvectors under perturbation; quantifies how the counterexample's gap scales with eps.
- von Luxburg (2007) tutorial: spectral clustering, normalized cut relaxation.
- Already in library: spectral-gap-infonce-downstream, ssl-augmentation-phase-transition, ssl-infonce-minimax-lower-bound — same augmentation graph framework.

## Honest assessment
This is exactly the kind of "almost true under hidden hypotheses" conjecture that benefits from explicit analysis. The intuition (spectral contrastive learns cluster-aligned representations whose centroids are the top eigenvectors) is correct under regular block structure, but the literal claim breaks immediately under any inter-cluster perturbation.
