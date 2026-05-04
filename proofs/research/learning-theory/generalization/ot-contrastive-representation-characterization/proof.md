# OT-Contrastive Representation Characterization — Proof (PARTIAL)

## Outcome

The literal conjecture fails. We prove a **restricted** theorem and exhibit a **counterexample** to the unrestricted version.

---

## Notation

- X finite, |X| = n. Cluster partition C_1,...,C_k of X, with c(x) ∈ {1,...,k} the label of x.
- p ∈ R^n_>0 the data prior (sum p_x = 1). pi_c = sum_{x ∈ C_c} p_x.
- mu_c = mu restricted to C_c, normalized: mu_c({x}) = p_x / pi_c for x ∈ C_c.
- W ∈ R^{n x n} symmetric nonneg similarity. D = diag(deg). A_tilde := D^{-1/2} W D^{-1/2}.
- f: X -> R^k encoded as F ∈ R^{n x k} with rows F_x. Set F_bar = diag(sqrt(p)) F.

## Lemma 1 (Brenier identity for OT to a Dirac)

For any probability measure nu on R^k and any z ∈ R^k:
  W_2^2(nu, delta_z) = integral ||y - z||^2 dnu(y).

Proof: there is exactly one transport plan from nu to delta_z (push all mass to z). Z3 verified the linear identity (verify_z3_simple.py: unsat for negation).

Corollary: J_OT(f, {z_c}) := sum_c W_2^2(f_# mu_c, delta_{z_c}) = sum_c integral ||F_x - z_c||^2 dmu_c(x).

## Lemma 2 (HaoChen, Wei, Gaidon, Ma 2021, Lemma 3.2)

The spectral contrastive loss satisfies
  L_spec(f) = ||A_tilde - F_bar F_bar^T||_F^2 + const.

Therefore (Eckart-Young, applied to symmetric A_tilde restricted to its nonneg-eigenvalue cone):
  argmin L_spec ⊇ {F: F_bar F_bar^T = U_k Lambda_k U_k^T},
which is achieved by F_bar* = U_k Lambda_k^{1/2} R for any R ∈ O(k), where U_k contains the top-k eigenvectors of A_tilde.

Z3 (verify_z3_simple.py) verified the underlying Ky Fan inequality
  trace(F^T A F) <= sum_{i=1}^k lambda_i(A)
for the test matrix A = diag(3, 1, 0), k = 2 (unsat for the negation; sat for equality at F = [e_1, e_2]).

## Refined Theorem (PROVED)

**Hypotheses.**
- (H1) W is block-diagonal w.r.t. (C_c): W_{ij} = 0 whenever c(i) ≠ c(j). Each block is connected.
- (H2) Spectral gap: lambda_k(A_tilde) > lambda_{k+1}(A_tilde).
- (H3) Within-cluster regularity: each block of W is a regular graph; the prior p is constant on each cluster (p_x = pi_{c(x)} / |C_{c(x)}|).

**Conclusion.** The minimizer F^{spec} of L_spec satisfies:
1. F^{spec}_x depends only on c(x), i.e., F^{spec} is constant on each cluster.
2. Letting z_c := F^{spec}(x) for any x ∈ C_c: J_OT(F^{spec}, {z_c}) = 0, the global minimum.
3. z_c is proportional to the row of (U_k R) at any x ∈ C_c, with scalar factor sqrt(lambda_c^*) * sqrt(|C_c| / pi_c) (where lambda_c^* is the Perron eigenvalue of block c). In particular, the centroid set {z_c} is contained in the row space of U_k rotated by R.

**Proof.**
- (H1) ⇒ A_tilde block-diagonal. Each block A_c is symmetric PSD; by Perron-Frobenius (H1's connectedness), it has a simple top eigenvalue lambda_c^* with strictly positive eigenvector v^{(c)}.
- (H2) ⇒ top-k eigenvalues of A_tilde are exactly {lambda_1^*,...,lambda_k^*}; eigenvectors are zero-padded extensions of v^{(c)}.
- (H3) ⇒ each v^{(c)} is uniform: v^{(c)}_x = 1/sqrt(|C_c|) for x ∈ C_c (Perron eigenvector of a regular block is uniform).
- Hence (U_k)_{x,c} = (1/sqrt(|C_c|)) * 1[c(x) = c]. The c(x)-th row of U_k has only one nonzero entry, equal to 1/sqrt(|C_{c(x)}|).
- F_bar*_x = (U_k Lambda_k^{1/2} R)_x = (1/sqrt(|C_{c(x)}|)) sqrt(lambda_{c(x)}^*) R_{c(x), :}.
- F^{spec}_x = (1/sqrt(p_x)) F_bar*_x. By (H3), p_x = pi_{c(x)}/|C_{c(x)}|, so sqrt(p_x) = sqrt(pi_{c(x)}/|C_{c(x)}|), giving:
    F^{spec}_x = sqrt(|C_{c(x)}|/pi_{c(x)}) * (1/sqrt(|C_{c(x)}|)) * sqrt(lambda_{c(x)}^*) * R_{c(x), :}
              = sqrt(lambda_{c(x)}^*/pi_{c(x)}) * R_{c(x), :}.
- This depends only on c(x), proving (1).
- Set z_c := sqrt(lambda_c^*/pi_c) R_{c,:}. Then F^{spec}_x = z_{c(x)}, so J_OT(F^{spec}, {z_c}) = 0, proving (2).
- The proportionality with row of (U_k R) at any x ∈ C_c is by direct computation: (U_k R)_{x,:} = v^{(c(x))}_x R_{c(x),:} = (1/sqrt(|C_{c(x)}|)) R_{c(x),:}. So z_c = sqrt(|C_c| lambda_c^* / pi_c) * (U_k R)_{x,:} for any x ∈ C_c. This proves (3). ∎

Numerical verification:
- verify_spectral_block.py (n=6, two 3-cliques): rows of F^{spec} are constant within cluster; J_OT = 6.57e-32.
- SymPy (n=4 block edges): F^{spec} = [[sqrt(2), 0], [sqrt(2), 0], [0, sqrt(2)], [0, sqrt(2)]], J_OT = 0 exactly.

## Counterexample to the literal conjecture

Take n=4, k=2, p uniform, W with one inter-cluster edge of weight eps = 0.3:
  W = [[0,1,0.3,0],[1,0,0.3,0],[0.3,0.3,0,1],[0,0,1,0]].

Computed (verify_counterexample.py):
- F^{spec} (top-2 eigenvector embedding):
    [[1.0000, -0.7530],
     [1.0000, -0.7530],
     [1.1094,  0.6578],
     [0.8771,  0.8851]]
- z_c set as rows of U_k at one representative per cluster (rows 0, 2): z_1 = (0.5, -0.491), z_2 = (0.555, 0.429).
- F^{alt}: cluster-constant equal to z_c.

Results:
- L_spec(F^{spec}) = 1.2613  (lowest possible)
- L_spec(F^{alt})  = 1.9351
- J_OT(F^{spec}, z=conj-rows) = 0.6545
- J_OT(F^{alt},  z=conj-rows) = 0.0000

Therefore F^{spec} ≠ F^{alt}, F^{spec} = argmin L_spec, F^{alt} achieves a strictly lower J_OT. Hence
  argmin L_spec ≠ argmin J_OT
when W is not block-diagonal. The literal conjecture is FALSE without (H1).

## Why the literal conjecture also has formulation issues

(a) Without a constraint on f (e.g., orthonormality F^T diag(p) F = I_k), J_OT is degenerate: any cluster-constant f achieves J_OT = 0 with z_c chosen accordingly. The "argmin" is non-unique and the spectral optimum is generically not in this argmin set.

(b) The phrase "z_c are rows of U_k" is dimensionally ambiguous: U_k ∈ R^{n x k} has n rows of dim k. The natural reading is one of the |C_c| rows in cluster c, but generally these rows differ (only equal under H1+H3). The corrected reading is that {z_c} spans the row space of U_k after rotation, with proper scalar factors.

## Final verdict

PARTIAL: refined theorem PROVED; literal conjecture REFUTED.
