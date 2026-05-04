# D19: OT contrastive characterization (PARTIAL — literal REFUTED)

**Source claimed**: Internal Problem 7.1 — HaoChen 2021 (2106.04156) + Brenier OT (textbook).

**Local proof**: Two-part outcome:
1. **Refined theorem (PROVED)** under (H1) block-diagonal $W$ + (H2) spectral gap + (H3) within-cluster regularity: spectral-contrastive minimizer $F^{\text{spec}}$ is constant on each cluster, and $J_{\text{OT}}(F^{\text{spec}}, \{z_c\}) = 0$ for $z_c$ proportional to rotated rows of $U_k$.
2. **Counterexample (REFUTED)**: $n=4$, $k=2$, one inter-cluster edge of weight $\epsilon=0.3$. Computed $\arg\min L_{\text{spec}} \ne \arg\min J_{\text{OT}}$: $L_{\text{spec}}(F^{\text{spec}}) = 1.26 < 1.94 = L_{\text{spec}}(F^{\text{alt}})$ but $J_{\text{OT}}(F^{\text{spec}}) = 0.65 > 0 = J_{\text{OT}}(F^{\text{alt}})$.

**Literature search**:
- HaoChen-Wei-Gaidon-Ma 2021 (2106.04156): spectral contrastive loss characterization via $L_{\text{spec}}(f) = \|A_{\text{tilde}} - F_{\text{bar}}F_{\text{bar}}^\top\|_F^2 + \text{const}$, with optimal rank-$k$ Eckart-Young recovery. Local Lemma 2 cites this exactly.
- Brenier 1991 ("Polar factorization and monotone rearrangement"): canonical OT theorem — $W_2$ pushforward is uniquely determined by gradient of convex potential. Lemma 1 (OT to a Dirac) is elementary.
- *No published claim* of "argmin spectral = argmin OT-to-centroids" exists in this form.

The **refinement** under (H1)+(H2)+(H3) — that block-diagonal $W$ + regular within-cluster structure forces spectral minimizer to be cluster-constant, hence trivially OT-optimal — is true and elementary (Perron-Frobenius gives uniform within-cluster eigenvectors).

The **counterexample** is the more interesting contribution: even with a tiny inter-cluster perturbation ($\epsilon=0.3$), spectral contrastive *strictly* differs from OT-centroid clustering. This is a clean refutation of the literal Internal Problem 7.1 conjecture.

**Verdict**: **NOVEL refutation + restricted positive theorem**.
- Refined theorem (PROVED part): largely textbook (Perron-Frobenius + Eckart-Young), low novelty.
- Counterexample (REFUTED part): the explicit numerical witness disproving "argmin spectral = argmin OT" without block-diagonality is **defensibly novel** as a negative result. The closely-related question — when does spectral contrastive align with optimal cluster centroids? — is genuinely interesting.

**Defensibility as novel**: MEDIUM. The refutation is the main novel content; it cleanly identifies the mathematical obstruction (inter-cluster mixing). Honest restatement places the original conjecture in proper context.

**Caveats**:
- Counterexample is for tiny $n=4$; whether the strict gap persists at scale is empirically untested.
- The "literal conjecture is false" finding is more useful as a *cautionary* result for SSL theorists than as a positive theorem.
- Section 7's "formulation issues" notes correctly identify that the original question was under-specified.
