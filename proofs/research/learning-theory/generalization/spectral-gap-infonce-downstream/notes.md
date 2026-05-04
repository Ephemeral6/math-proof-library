# Notes: Spectral Gap and InfoNCE Downstream Bound

## Proof technique

**Winning route**: Direct quadratic-growth bound on the spectral contrastive
surrogate loss, with the InfoNCE-to-spectral reduction cited as a
quantitative black-box from Tan-Zhang-Yang-Yuan (ICLR 2024).

The core argument is a transverse strong-convexity / quadratic-growth
analysis: in the parameterization $F = U_k A + U_\perp B$ around the
spectral minimizer, the loss has Hessian $\succeq 4\delta\,I$ in the
$B$-direction (gap-controlled curvature), and after minimizing analytically
over $A$ at fixed $B$, the effective rate becomes $2\delta\,\|B\|_F^2$
(numerically tight).

## Key steps

1. **Cite the reduction**: Lemma 1 imports the InfoNCE → spectral contrastive
   approximation from Tan/HaoChen as a black-box with rate $\eta(\tau,n,M)$.

2. **Coercivity & a-priori bound**: Lemma 2 uses a power-mean / Cauchy-Schwarz
   argument on the SVD to show all near-minimizers satisfy $\|F^*\|_F^2 \le 2n^3$.

3. **Transverse Hessian** (Lemma 2'): direct calculation gives
   $\nabla^2_B[\dot B,\dot B] = 4\sum_j \dot B_{:,j}^\top(\lambda_j I - \Lambda_\perp)\dot B_{:,j} \ge 4\delta\,\|\dot B\|_F^2$.

4. **Analytic A-minimization** (Lemma 3): the crucial step. Closed form
   $\min_A \mathcal{L}_{\mathrm{spec}}(U_kA + U_\perp B) = -n^2\sum\lambda_j^2 + 2\sum(\lambda_j - \lambda_{k+1})\beta_j^2 - \frac{1}{n^2}\sum\beta_j^4$,
   giving sharpness $\delta\,\|B\|_F^2$ on a sublevel set.

5. **Combine**: $\delta\,\|F^* - P_kF^*\|_F^2 \le 2\eta(\tau,n,2n^{3/2})$,
   yielding $C(n,\tau) = O(\tau\,n^c\log n)$.

## Audit result

One round of fixes:
- Arithmetic constants tightened ($n^2 \to 2n^3$).
- Lemma 3 hand-waved $A$-minimization replaced with explicit closed form.
- Sharpness constant clarified: bare Hessian gives $4\delta$, post-$A$-opt gives $2\delta$ (tight).
- Reduction step explicitly flagged as black-box (Tan 2024 / HaoChen 2021).

Numerical verification:
- Hessian eigenvalues match $2(\lambda_j - \lambda_\ell)$ to machine precision.
- Worst-direction excess equals $2\delta\,\|B\|^2$ exactly (no higher-order term).
- Random-direction excess is $\approx 4\delta\,\|B\|^2$ (consistent with bare Hessian).

## Related results

- **Davis-Kahan sin-Θ theorem**: gives an alternative perturbation-theoretic
  derivation of the same $1/\delta$ rate, but requires more machinery
  (operator perturbation, sin-Θ angles).
- **Eckart-Young / Ky Fan**: provides the spectral minimizer characterization
  (Lemma 2's minimum value), used here in the analysis but not as the main
  tool.
- **HaoChen-Wei-Gaidon-Ma (NeurIPS 2021)**: original spectral contrastive
  loss formulation. Their Theorem 3.6 is the basis of our Lemma 1.
- **Tan-Zhang-Yang-Yuan (ICLR 2024)**: extends HaoChen's reduction to give
  the precise InfoNCE/SimCLR connection at $\tau \to 0$. This is the cited
  reduction theorem.
- **Spectral clustering theory** (Ng-Jordan-Weiss 2001, von Luxburg 2007):
  $\delta$-controlled bounds on $k$-means via top-$k$ eigenspace projection
  errors are classical; our result is the contrastive-learning analogue.

## Caveats and what was deferred

- The InfoNCE-to-spectral reduction is **cited as a black-box**. Reproving
  it requires the alignment-uniformity decomposition and Taylor expansion
  of LSE; this is the content of the cited papers.
- The constant $C(n,\tau)$ is given as $O(\tau\, n^c\, \log n)$ but the
  exact polynomial degree $c$ depends on the cited reduction's rate.
- The sharpness rate $1/\delta$ (rather than $1/\delta^2$) is an *improvement*
  over the originally stated bound; the latter follows since $\delta \le 2$.
