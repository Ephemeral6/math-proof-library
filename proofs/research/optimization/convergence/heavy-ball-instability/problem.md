# Heavy Ball Momentum: Instability on Smooth Strongly Convex Functions

## Source
- Paper: Polyak 1964 (original Heavy Ball); Lessard, Recht, Packard 2016 (IQC analysis showing instability)
- Context: Heavy Ball is optimal on quadratics but can diverge on general smooth strongly convex functions

## Statement

Consider the Heavy Ball method:
$$x_{k+1} = x_k - \alpha \nabla f(x_k) + \beta(x_k - x_{k-1})$$

**Part 1**: Prove that with the "optimal" parameters $\alpha = \frac{4}{(\sqrt{L}+\sqrt{\mu})^2}$, $\beta = \left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^2$ on the quadratic $f(x) = \frac{1}{2}x^T \mathrm{diag}(\mu, L) x$, the iterates converge at rate $\left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^k$.

**Part 2**: Construct an explicit $L$-smooth $\mu$-strongly convex function (not a quadratic) where Heavy Ball with these parameters does **not** converge.

## Difficulty
conjecture
