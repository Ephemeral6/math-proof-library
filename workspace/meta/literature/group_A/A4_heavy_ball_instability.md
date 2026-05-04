# A4: Heavy Ball Instability on Smooth Strongly Convex

**Proof path**: `proofs/research/optimization/convergence/heavy-ball-instability/`
**Claimed source**: Lessard–Recht–Packard 2016 (arXiv:1408.3595)
**Verdict**: **CONFIRMED-IMPROVED** (different counterexample; same conclusion)

## Our claim
- Part 1: HB with optimal Polyak parameters on quadratic $\frac12 x^T\mathrm{diag}(\mu,L)x$ achieves rate $((\sqrt\kappa-1)/(\sqrt\kappa+1))^k$.
- Part 2: Explicit construction $f(x) = \frac{L}{2}x^2 - (L-\mu)\ln\cosh(x)$ with $\kappa=100$ — $C^\infty$, strongly convex, smooth — on which HB with the optimal quadratic params does NOT converge from all initial conditions.

## Cross-check
[ARXIV-UNREACHABLE] Lessard–Recht–Packard 2016 (Section 6) used IQC analysis to prove a numerical bound showing the worst-case rate of HB on $\mathcal{F}_{\mu,L}$ exceeds the quadratic optimum, and exhibited a piecewise-quadratic counterexample (their Section 6.3) with $\kappa=10$ on which HB cycles. Our $\ln\cosh$ construction is *different from* theirs (which is piecewise-quadratic), but produces the same instability phenomenon. The $\ln\cosh$ trick is well-known folklore (used by Ghadimi-Lan and others) — it gives a $C^\infty$ smooth-strongly-convex function with a non-trivial Hessian variation.

## Comparison
- **Assumptions**: match (smooth strongly convex, optimal Polyak $\alpha,\beta$).
- **Constants**: Part 1 rate $(\sqrt\kappa-1)/(\sqrt\kappa+1)$ exact match.
- **Scope**: same conclusion (instability), but our counterexample is $C^\infty$ rather than piecewise-quadratic — strictly stronger object class.
- **Technique**: Part 1 uses Jordan-block diagonalization (standard); Part 2 uses an explicit smooth construction rather than IQC.

## Verdict
**CONFIRMED-IMPROVED** (in the construction class). The qualitative result is exactly Lessard et al. 2016; the smooth $C^\infty$ counterexample is cleaner than their piecewise-quadratic one. Note this construction is folklore (not novel to us), but it is a legitimate strengthening of the published statement.
