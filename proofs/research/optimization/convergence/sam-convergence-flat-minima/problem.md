# SAM Convergence to Flat Minima

## Source
- Paper: Andriushchenko & Flammarion 2022 (ICML) — "Towards Understanding Sharpness-Aware Minimization" (theoretical convergence analysis used here); original SAM proposed by Foret et al. 2021 (ICLR) — "Sharpness-Aware Minimization for Efficiently Improving Generalization" (empirical / PAC-Bayes)
- Context: Convergence analysis of SAM in the non-convex setting; proves that SAM finds approximate stationary points of the worst-case (sharpness-aware) objective

## Statement

Let $f:\mathbb{R}^d\to\mathbb{R}$ be $L$-smooth and bounded below. Consider the SAM update:

$$x_{t+1} = x_t - \eta \nabla f\!\left(x_t + \rho \frac{\nabla f(x_t)}{\|\nabla f(x_t)\|}\right).$$

Define the SAM objective:

$$f^{\mathrm{SAM}}(x) = \max_{\|\delta\| \leq \rho} f(x+\delta).$$

Then with $\eta = O(1/L)$ and $\rho = O(\eta)$:

$$\min_{0 \leq t < T} \|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \leq \frac{16L(f(x_0)-f^*)}{T} + 12L^2\rho^2 = O\!\left(\frac{1}{T}\right) + O(L^2\rho^2).$$

With diminishing $\rho = \rho_0/\sqrt{T}$: exact $O(1/T)$ convergence.

## Difficulty
Research
