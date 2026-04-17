## Proof

**Route**: 1D Reduction + Tensorization

**Theorem.** For any $k \le (d-1)/2$ and any first-order method, there exists an $L$-smooth convex function such that $f(x_k) - f(x^*) \ge \frac{3L\|x_0 - x^*\|^2}{32(k+1)^2}$.

---

### Step 1: 1D base case

Consider the one-dimensional function $g(x) = \frac{L}{2}(x - 1)^2$ restricted to $x \ge 0$ via the smoothed barrier. But this is not clean.

**Better 1D approach**: For $d = 1$, a first-order method has access to $f'(x_0)$ at step 0, and $f'(x_0), f'(x_1)$ at step 1, etc. In 1D with one gradient evaluation, we can find the optimum of a quadratic exactly. So 1D doesn't give a nontrivial lower bound.

The essential mechanism requires multiple dimensions: the tridiagonal structure means each gradient query reveals only one new coordinate direction.

### Step 2: Inductive embedding construction

We construct the worst-case function inductively. For $k = 1$ (need $d \ge 3$), define:

$$f_1(x) = \frac{L}{4}\left(2x_1^2 + 2x_2^2 + 2x_3^2 - 2x_1x_2 - 2x_2x_3 - 2x_1\right)$$

This is the tridiagonal construction for $k=1$ with matrix size $2k+1 = 3$.

For general $k$, embed the $k-1$ case into higher dimensions by adding one tridiagonal coupling.

**However**, this approach essentially reconstructs the tridiagonal matrix one dimension at a time, and the analysis reduces to the same Schur complement calculation as Route 1.

## Route Failure Report
- Route: 1D Reduction + Tensorization
- Failed at: Step 2 (the inductive construction reduces to the tridiagonal construction)
- Obstacle: The 1D base case is trivial (a first-order method solves 1D quadratics exactly), so the lower bound mechanism is inherently multi-dimensional. The "tensorization" or inductive approach doesn't simplify the analysis — it merely rebuilds the tridiagonal construction step by step. The Schur complement computation from Route 1 is still needed to get the correct constant.
- Recommendation: Route 1 (direct tridiagonal construction) is the natural and cleanest approach for this theorem.
