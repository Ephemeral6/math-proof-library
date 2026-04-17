# Notes: Heavy Ball Instability

## Proof technique
**Part 1** used direct spectral analysis of the 2x2 companion (iteration) matrix. The key insight is that the optimal Heavy Ball parameters create a **double eigenvalue** (zero discriminant) for both the $\mu$-eigenvalue and $L$-eigenvalue, yielding non-diagonalizable Jordan blocks with spectral radius $r = (\sqrt{\kappa}-1)/(\sqrt{\kappa}+1)$.

**Part 2** used a novel log-cosh counterexample construction. Route 3 (Direct Spectral + Log-Cosh) won over Routes 1 (Huber-type, too many false starts), 2 (Chebyshev + piecewise quadratic, Part 2 failed), 4 and 5 (both failed on Part 2).

## Key steps

1. **Part 1, Step 4**: The algebraic verification that the discriminant vanishes with optimal parameters is the core computation. The factorization $\kappa - 1 = (\sqrt{\kappa}-1)(\sqrt{\kappa}+1)$ is crucial.

2. **Part 1, Step 5**: Recognizing the Jordan block structure matters — it explains the polynomial prefactor $(k+1)$ in the bound.

3. **Part 2, Construction**: The function $f(x) = \frac{L}{2}x^2 - (L-\mu)\ln\cosh(x)$ is remarkably clean. It has:
   - $f''(x) = L - (L-\mu)\operatorname{sech}^2(x) \in [\mu, L]$
   - Low curvature ($\mu$) at origin, high curvature ($L$) far away
   - $C^\infty$ smoothness
   
4. **Part 2, Mechanism**: The curvature profile (low near optimum, high far away) is essential. The opposite profile (high near optimum, Huber-type) does NOT cause divergence. The low-curvature-near-optimum design creates a "momentum trap" where the iterate's kinetic energy cannot be dissipated.

## Audit result
PASS on first round. All 11 steps valid. Three LOW-severity observations about the computational nature of the period-4 cycle verification. The cycle's attracting nature was confirmed analytically via the Jacobian of $T^4$ (spectral radius 0.448 < 1).

## Related results
- **Nesterov's accelerated gradient (1983)**: Converges on ALL smooth strongly convex functions at rate $r^k$, unlike Heavy Ball. The "lookahead" gradient evaluation provides implicit curvature adaptation.
- **Lessard, Recht, Packard (2016)**: Used Integral Quadratic Constraints (IQC) to show Heavy Ball's spectral analysis does not generalize beyond quadratics. Our counterexample is more explicit than their IQC argument.
- **Polyak (1964)**: Original Heavy Ball paper proves optimal rate on quadratics.
- **GD on strongly convex functions**: Converges at rate $(1-1/\kappa)^k$ — slower than Heavy Ball on quadratics, but universally convergent.
- This result shows that the $(\sqrt{\kappa}-1)/(\sqrt{\kappa}+1)$ rate of Heavy Ball is **quadratic-specific**, while Nesterov AGD achieves the same rate universally — a fundamental distinction in optimization theory.

## Discovery log
- Failed attempts: Simple counterexamples (piecewise quadratic, smoothstep-based curvature variation) all converge. The key insight was that the curvature must be LOW at the origin and HIGH far away (not the reverse).
- The log-cosh construction was discovered by systematically testing $f''(x) = L - (L-\mu)\operatorname{sech}^2(ax)$ and $f''(x) = \mu + (L-\mu)\operatorname{sech}^2(ax)$.
- Critical condition number for divergence ($\kappa \approx 76.5$ with $a=1$) found via binary search.
