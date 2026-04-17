# Notes: Implicit Bias of GD — Max-Margin Convergence

## Proof technique
The winning route (Route 1: Logarithmic Growth + KKT Residual Decomposition) combines:
1. **Descent lemma** to establish $\|\nabla L(w_t)\| \to 0$
2. **Conic hull contradiction** to prove norm divergence
3. **Sigmoid asymptotic expansion** ($\sigma(-m) \approx e^{-m}$) to simplify the gradient
4. **Iterate telescoping** to express $w_T$ as a weighted sum of data vectors
5. **$O(1/t)$ loss decay** (self-bounding gradient trick) to pin down margin growth rates
6. **KKT identification**: the limiting coefficients satisfy SVM KKT conditions by the structure of the exponential weighting

The core insight is that the exponential tail of the logistic loss creates a "soft" version of the support vector mechanism — data points with small margins receive exponentially more gradient attention, and the self-consistent steady state of this dynamics is exactly the SVM solution.

## Key steps
1. **No finite critical points**: The positive conic hull of $\{z_i\}$ cannot contain the origin when data is separable. This forces $\|w_t\| \to \infty$.
2. **Inner product lower bound**: $\langle -\nabla L, w^*\rangle \geq \frac{1}{n}\sum_i \sigma(-m_i)$ prevents any margin from stagnating.
3. **Self-bounding property**: $L \leq 2S_t$ and $\|\nabla L\| \geq S_t/\|w^*\|$ combine to give $L(w_{t+1}) \leq L(w_t) - cL(w_t)^2$, yielding $O(1/t)$ decay.
4. **Exponential separation of margin growth rates**: Data points with larger margin ratios have summable cumulative weights ($\bar{\beta}_i = O(1)$), while minimum-margin points have $\bar{\beta}_i = \Theta(\log T)$. This makes only the support vectors contribute to the limiting direction.
5. **KKT emergence**: The conditions on the limiting coefficients are algebraically identical to the SVM dual feasibility + complementary slackness conditions.

## Audit result
- Round 1: FAIL (1 HIGH: self-consistent ansatz not proved convergent; 2 MEDIUM: unjustified $L \to 0$, circular SV classification)
- Round 2 (after fix): PASS (8/8 steps VALID, 6 numerical checks passed, all constants traceable, 3 LOW notes)

Key fix: Replaced the heuristic "ansatz" argument with a rigorous derivation via limiting normalized coefficients $\hat{\beta}_i^\infty$, which avoids circularity and directly identifies the SVM KKT conditions.

## Related results
- **Soudry et al. 2018 (JMLR)**: Original paper. Also shows $\|w_t\| = \Theta(\log t)$ and the convergence rate of direction is $O(1/\log t)$.
- **Ji & Telgarsky 2018**: Extended to general homogeneous models, showing implicit bias toward max-margin in feature space.
- **Gunasekar et al. 2018**: Studied implicit bias for matrix factorization — GD converges to minimum nuclear norm solution.
- **Lyu & Li 2020**: Extended to homogeneous neural networks, showing convergence to KKT points of the max-margin problem in parameter space.
- **Nacson et al. 2019**: Showed similar results for steepest descent with different norms (e.g., $\ell_1$ norm leads to $\ell_1$ max-margin).
- This proof technique (telescoping + exponential weighting + KKT identification) is specific to losses with exponential tails. For losses with polynomial tails (e.g., $\ell(z) = 1/(1+z)^p$), the implicit bias is different.
