# Failed/Unused Attempt: Route A — Davis-Kahan sin-Θ

## Approach

Treat the InfoNCE optimum $F^*$ as a perturbed eigenmatrix: form the
"effective Gram matrix" $G^* = F^* (F^*)^\top / \|F^*\|^2$ and view it as
a perturbation of $W$. Apply the Davis-Kahan sin-Θ theorem:
$$
\|\sin \Theta(F^*, U_k)\|_F \le \frac{\|G^* - W\|_F}{\delta}.
$$

## Why we didn't pursue this further

1. The "effective Gram matrix" interpretation requires that $F^*$ be
   approximately rank-$k$ with structure encoding $W$ — but this is
   precisely what we're trying to prove, so the argument is circular at
   the entry point.

2. The cleaner version: bound $\|WF^* - F^* M\|_F$ for some $k\times k$
   matrix $M$ (residual / approximate eigenvector). Davis-Kahan then gives
   $\|\sin\Theta\|_F \le \text{residual}/\delta$. But the residual itself
   needs to be controlled via the gradient $\nabla \mathcal{L}_{\mathrm{spec}}(F^*)$,
   which after explicit computation gives the SAME $\delta\|B\|^2 \le \text{excess}$
   inequality as Route B — without the additional machinery.

3. Davis-Kahan gives the rate $1/\delta$ which matches our Route B, so it
   would give the same final bound but with a less direct argument.

## Conclusion

Route A is correct but redundant given Route B's directness. We chose
Route B for the clean closed-form $A$-minimization, which gives an
analytic rather than perturbation-theoretic derivation of the sharpness.
