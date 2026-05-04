# Fragment: cocoercivity-yields-nonexpansive-gradient-step

## Statement
Let $g: \mathbb{R}^d \to \mathbb{R}$ be convex and $\beta$-smooth (i.e., $\nabla g$ is $\beta$-Lipschitz). Then $\nabla g$ is **$1/\beta$-cocoercive**:
$$\langle \nabla g(w) - \nabla g(w'),\, w - w'\rangle \;\ge\; \tfrac{1}{\beta}\|\nabla g(w) - \nabla g(w')\|^2.$$
Consequently, for step size $\alpha \le 2/\beta$, the gradient step $T(w) := w - \alpha\nabla g(w)$ is non-expansive:
$$\|T(w) - T(w')\|^2 \;=\; \|w - w'\|^2 - \alpha\bigl(\tfrac{2}{\beta} - \alpha\bigr)\|\nabla g(w) - \nabla g(w')\|^2 \;\le\; \|w - w'\|^2.$$

## Proof
Cocoercivity of $\nabla g$ for convex $\beta$-smooth $g$ is the Baillon-Haddad theorem; equivalently it's the converse of the descent lemma combined with convexity. Given cocoercivity, expand $\|T(w) - T(w')\|^2$:
$$\|w - w' - \alpha(\nabla g(w) - \nabla g(w'))\|^2 = \|w-w'\|^2 - 2\alpha\langle\nabla g(w) - \nabla g(w'), w - w'\rangle + \alpha^2 \|\nabla g(w) - \nabla g(w')\|^2.$$
Apply cocoercivity to the cross term: $-2\alpha\langle\cdot,\cdot\rangle \le -\frac{2\alpha}{\beta}\|\nabla g(w) - \nabla g(w')\|^2$. Combine to get the stated equality with $\alpha(2/\beta - \alpha)\|\nabla g\|^2$ subtracted; this is non-negative iff $\alpha \le 2/\beta$. $\square$

## Source
- `proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/proof.md` — Step 1 ("Non-expansiveness when $i_t \neq j$").

## Status
- **Correctness**: VERIFIED (this is essentially Baillon-Haddad)
- **Used in final proof**: YES (basis for Hardt-Recht-Singer SGD stability)
- **Potential applications**:
  - SGD uniform-stability arguments (Hardt-Recht-Singer 2016)
  - Coupling-based generalization bounds
  - Forward-backward splitting nonexpansiveness
  - Acceleration analyses with averaged gradient updates
  - PEP (performance estimation problem) certificates
  - Showing GD trajectories on different but close functions stay close

## Tags
cocoercivity, baillon-haddad, smooth-convex, stability, nonexpansive
