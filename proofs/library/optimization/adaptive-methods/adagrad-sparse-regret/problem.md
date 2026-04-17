# AdaGrad Convergence for Sparse Gradients

## Source
- Paper: Duchi, Hazan, Singer 2011 (JMLR)
- Problem Bank: A8
- Context: Adaptive learning rate method exploiting gradient sparsity in OCO

## Statement

Online convex optimization on $\mathcal{X} \subseteq \mathbb{R}^d$ with $\ell_\infty$-diameter $D$, convex losses $f_t$, subgradients $g_t$ with $\|g_t\|_\infty \leq G$.

AdaGrad (coordinate-wise): $x_{t+1,i} = \Pi_{\mathcal{X},i}(x_{t,i} - \eta g_{t,i}/\sqrt{\sum_{s=1}^t g_{s,i}^2})$

Regret bound: $\text{Regret}_T \leq O(D)\sum_{i=1}^d \sqrt{\sum_{t=1}^T g_{t,i}^2}$

- Worst-case: $O(DGd\sqrt{T})$ under $\|g_t\|_\infty \leq G$
- Sparse ($s$-sparse gradients): $O(DGs\sqrt{T})$

## Difficulty
research
