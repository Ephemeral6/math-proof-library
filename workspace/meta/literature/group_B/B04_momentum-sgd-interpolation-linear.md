# B4 — Momentum SGD interpolation linear convergence

**Verdict**: CONFIRMED-WEAKER

**Source**: Loizou et al. 2021 (arXiv:2002.10542) §5; Vaswani et al. 2019 (arXiv:1810.07288). [ARXIV-UNREACHABLE detailed theorem; using training-data knowledge.]

## OUR statement
Convex $L$-smooth $f_i$, $\mu$-SC $f$, interpolation. Polyak momentum with $\gamma=1/(2L\kappa)$, $\beta=1/(4\kappa^2)$, $\kappa\ge 3$:
$$\mathbb{E}\|x_t-x^*\|^2 \le (1-1/(16\kappa^2))^t \|x_0-x^*\|^2.$$

## Paper statement (Loizou et al. Thm 5.1 / Vaswani Thm)
For SHB under interpolation, Loizou et al. give linear convergence with rate $1-c/\kappa$ for explicit $c>0$ when $\beta < 1$ small and $\gamma \le \frac{1-\beta}{L_{\max}}$. Vaswani 2019 (Thm 4) achieves $1-c\sqrt{\mu/L}$ Nesterov-style for quadratic-like settings under SGC.

## Comparison
- Setting (interpolation+SC+individually convex+smooth $f_i$) matches.
- Step size: ours $\gamma = \Theta(1/(L\kappa))$ — paper allows up to $\Theta(1/L)$; ours **conservative**.
- Momentum: ours $\beta = \Theta(1/\kappa^2)$ — paper allows larger $\beta = O(1/\kappa)$; ours **conservative**.
- Rate: ours $1-1/(16\kappa^2)$ — paper achieves $1-1/\kappa$ (vanilla SGD level) and Vaswani up to $1-1/\sqrt{\kappa}$ (accelerated). Ours is **$\kappa^2$ slower than vanilla SGD**.

## Verdict
**CONFIRMED-WEAKER**: linear convergence is correct, but the rate $1-1/(16\kappa^2)$ is far from the published $1-1/\kappa$ (or accelerated $1-1/\sqrt\kappa$). The proof's choice of conservative $\beta=1/(4\kappa^2)$ makes momentum a small perturbation rather than an active accelerator. Honest reading: this is not a momentum-acceleration result, it's a "momentum doesn't break SGD" result with a 16× margin.
