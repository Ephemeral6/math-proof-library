# PAC-Bayes Bound via Covering Number / Discretization + Union Bound

## Route Outcome: Partial Success

The covering number route ultimately converges to the change-of-measure (Donsker-Varadhan) approach for handling "all Q simultaneously." The pure discretization approach introduces an inherent O(1/n) discretization error when optimizing λ over a finite grid.

## Key Insight

The "covering" in PAC-Bayes is implicit: the prior P defines a covering of hypothesis space, and KL(Q||P) measures the coding cost relative to this covering. The explicit covering number approach:

1. Uses Hoeffding + union bound over a prior-weighted sum of hypotheses
2. Applies Gibbs variational inequality (= Donsker-Varadhan) to pass from P to arbitrary Q
3. Discretizes λ over n grid points, paying ln(n) in the union bound

## Final Result

With a grid of n values for λ and failure probability δ/n per grid point:
- Union bound cost: ln(n)  
- Markov cost: ln(1/δ)
- Combined: ln(n/δ)

$$\mathbb{E}_{h\sim Q}[L_D(h)] \leq \mathbb{E}_{h\sim Q}[L_S(h)] + \sqrt{\frac{\mathrm{KL}(Q\|P) + \ln(n/\delta)}{2n}} + O(1/n)$$

The O(1/n) discretization error is lower-order compared to O(1/√n) main term.

## Status: Route converges to Route 1/2 approach with extra discretization cost
