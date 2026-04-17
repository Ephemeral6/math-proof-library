# Double Descent — Interpolation Threshold Phenomenon

## Source
- Context: Ridgeless least squares in the proportional asymptotic regime, double descent phenomenon in high-dimensional regression

## Statement

Consider ridgeless least squares $\hat{\beta} = X^+ y$ where $X \in \mathbb{R}^{n \times d}$ has i.i.d. $\mathcal{N}(0, I_d/d)$ rows, $y = X\beta^* + \epsilon$ with $\epsilon \sim \mathcal{N}(0, \sigma^2 I_n)$, and $X^+$ is the Moore-Penrose pseudoinverse. In the proportional regime $d/n \to \gamma$ as $d, n \to \infty$ with isotropic covariance:

Prove that the expected prediction risk satisfies:

1. **Underparameterized** ($\gamma < 1$): $R(\hat{\beta}) \to \frac{\sigma^2 \gamma}{1 - \gamma}$

2. **Overparameterized** ($\gamma > 1$): $R(\hat{\beta}) \to \frac{\sigma^2}{\gamma - 1} + \frac{\gamma - 1}{\gamma} b^2$

   where $b^2 = \lim_{d\to\infty} \|\beta^*\|^2/d$ is the normalized signal strength.

3. Both diverge as $\gamma \to 1$ (the interpolation threshold)

## Difficulty
research
