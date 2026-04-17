# Notes: OGD Regret Bound

## Proof technique
Route 4 (Potential function + combinatorial lower bound) won. Upper bounds use the standard distance-to-comparator potential Φ_t = ||x_t - u||². Lower bound uses Rademacher random linear losses on a ball, with the key Khintchine L¹ bound proved via exact combinatorial formulas and induction on central binomial coefficients.

## Key steps
1. **Projection non-expansiveness**: ||Π_K(y) - x*|| ≤ ||y - x*|| via variational characterization of projection
2. **Per-step bound**: f_t(x_t) - f_t(u) ≤ (||x_t-u||² - ||x_{t+1}-u||²)/(2η_t) + η_t G²/2
3. **Fixed step telescoping**: R_T ≤ D²/(2η) + ηG²T/2, optimized at η = D/(G√T)
4. **Abel summation for decreasing steps**: Regroup varying-coefficient telescope, bound via D² and Σ1/√t ≤ 2√T
5. **Khintchine L¹**: E[|S_{2m}|] = 2m·C(2m,m)/4^m ≥ √m via C(2m,m) ≥ 4^m/(2√m) by induction
6. **Derandomization**: Expected regret bound against all algorithms implies deterministic adversary exists

## Audit result
PASS WITH MINOR FIXES. Only presentational cleanup needed (removed ~250 lines of failed exploration attempts in the original). Zero mathematical errors.

## Related results
- Mirror descent online regret bound (already in library) — generalizes OGD via Bregman divergence
- Entropy-regularized value iteration (already in library) — connected via online-to-batch conversion
- The √T rate is optimal for general convex losses; strongly convex losses achieve O(log T)
- Extends to bandit feedback via gradient estimators (one-point/two-point)
