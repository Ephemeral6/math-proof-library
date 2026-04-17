# Depth Separation: 2-Layer ReLU Networks Require Exponential Width for Radial Functions

## Source
- Paper: Eldan & Shamir (2016, COLT); Daniely (2017)
- Context: Depth separation in neural network expressivity — 2-layer vs 3-layer

## Statement

**Theorem A (Polynomial lower bound, fully rigorous):** The normalized radial quadratic $f^*(x) = (\|x\|^2 - d)/\sqrt{2d}$ satisfies: any 2-layer ReLU network of width $m$ with $\|w_j\| = 1$ approximating $f^*$ in $L^2(\mathcal{N}(0,I_d))$ to error $\epsilon$ must have $m \geq c\sqrt{d}(1-\epsilon)^2$.

**Theorem B (Exponential lower bound, structural):** The unit ball indicator $\mathbf{1}[\|x\|^2 \leq d]$ requires $m \geq \exp(\Omega(\sqrt{d}\log d))$ for 2-layer ReLU $L^2(\mathcal{N}(0,I_d))$ approximation to constant error.

## Difficulty
conjecture
