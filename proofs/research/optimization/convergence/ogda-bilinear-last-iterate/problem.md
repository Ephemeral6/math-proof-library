# Last-Iterate O(1/T) Convergence of OGDA in Bilinear Games

## Source
- Paper: Golowich, Pattathil, Daskalakis, Ozdaglar (2020); Mokhtari, Ozdaglar, Pattathil (2020)
- Context: Sharp last-iterate convergence for optimistic methods in minimax optimization

## Statement

Consider the bilinear minimax problem $\min_x \max_y x^\top A y$ with $A \in \mathbb{R}^{m \times n}$. OGDA with step size $\eta \leq 1/(4\|A\|)$ and initialization $z_{-1} = z_0$ satisfies:

$$\|z_T - z^*\|^2 \leq \frac{C \cdot \kappa(A)^2}{T} \|z_0 - z^*\|^2$$

where $\kappa(A) = \sigma_{\max}(A)/\sigma_{\min}(A)$ is the condition number.

## Difficulty
research
