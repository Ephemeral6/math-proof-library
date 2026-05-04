# Failed/deferred Candidate C — Cubic perturbation in (x, y) (mean-shifted Goujaud)

## What was attempted

Add a small cubic perturbation directly to $f_0(x)$ to make it non-convex
without introducing a new coordinate:
$$f_C(x, y) := f_0(x) + \alpha_s y + w(y) + \varepsilon\, g(x), \qquad
g(x) := -\|x\|^3 \cdot \chi(x/D)$$
with $\chi$ a smooth cutoff and $\varepsilon$ small.

## Status

**Deferred, not failed.** Candidate A's clean separation made C unnecessary.

## Why deferred

- **Positive homogeneity broken**: the cubic $g$ violates positive homogeneity, so OP-2 v5's Lemma 1.7 (used in Claim 2.1) does NOT carry over. Re-deriving $L$-smoothness on the perturbed $f_0 + \varepsilon g$ requires non-trivial additional work.
- **Cycling identity becomes approximate**: $x_t \approx (D/\sqrt 2) e_t + \mathcal O(\varepsilon T)$, accumulating. The cycling LB constant becomes $T$-dependent: $B_{\mathrm{NC}}(\beta, \eta) (1 - c T \varepsilon)$.
- **Trade-off**: for a useful LB, need $\varepsilon \leq 1/T$ (so cycling drift stays $O(1)$). But then the non-convexity is so weak that the Hessian's negative direction has eigenvalue $\sim \varepsilon \to 0$, which is borderline degenerate. Sun 2019's strict-saddle escape result might not apply but the proof becomes fragile.

## Conditions under which C might be needed

- If a future auditor argues that A's "decorative" non-convexity is unsatisfying because it lives in an orthogonal coordinate, and demands a non-convexity in the same subspace as the cycling.
- If the proof is challenged on grounds that "the iterate sees only the convex sub-function on its trajectory" — C addresses this directly.

## Numerical sketch (not pursued)

For $\varepsilon = 1/T$, $T = 100$: the cycling drift is $O(0.01 \cdot 100) = O(1)$, comparable to the cycle radius $D/\sqrt 2$. So the cycle is destroyed at this scale. Need $\varepsilon \leq 1/T^2$ for $T = 100$, i.e., $\varepsilon = 10^{-4}$. At this perturbation, the negative-curvature direction has eigenvalue $\sim 10^{-4}$, essentially indistinguishable from zero. Sun 2019's escape rate is then $O(\sigma^{-2}/\varepsilon)$, which is huge — comparable to or exceeding $T$. The proof would need a finite-$T$ escape-time analysis; this is significantly more involved than Candidate A.
