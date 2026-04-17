# Notes: Azuma-Hoeffding Inequality

## Proof technique
The winning route was a **self-contained proof from first principles**, combining:
1. Hoeffding's Lemma (proved via convexity of exponentials + Taylor remainder bound)
2. Chernoff method (exponential Markov inequality)
3. Tower property of conditional expectation for MGF factorization
4. Optimization over the Chernoff parameter $s$

This route won over the pure Chernoff-tower approach (Route 1) and the supermartingale construction (Route 3) because it is fully self-contained — no external lemmas cited without proof.

## Key steps
1. **Hoeffding's Lemma**: The crucial ingredient. Uses convexity of $e^{sx}$ to get a chord bound, then the auxiliary function $\varphi(h) = -\theta h + \ln(1-\theta+\theta e^h)$ satisfies $\varphi(0)=\varphi'(0)=0$ and $\varphi''(h) \leq 1/4$, giving $\varphi(h) \leq h^2/8$ by Taylor's theorem.
2. **Conditional application**: Hoeffding's lemma applies conditionally because the martingale differences $D_k$ are centered ($\mathbb{E}[D_k|\mathcal{F}_{k-1}]=0$) and bounded ($|D_k| \leq c_k$) conditionally.
3. **Tower property iteration**: The factorization $\mathbb{E}[e^{s\sum D_k}] = \mathbb{E}[e^{s\sum_{k<n} D_k} \cdot \mathbb{E}[e^{sD_n}|\mathcal{F}_{n-1}]]$ allows peeling off one term at a time, each contributing $e^{s^2c_k^2/2}$.
4. **Chernoff optimization**: The quadratic $-st + s^2\sigma^2/2$ is minimized at $s^* = t/\sigma^2$, yielding the Gaussian tail $e^{-t^2/(2\sigma^2)}$.

## Audit result
**PASS** on first round. All 11 proof steps verified as VALID. Three LOW-severity notes (all expository, no logical gaps):
- Conditional Hoeffding's lemma measurability could be more explicit
- Iteration step could be expanded
- Two-sided bound not explicitly derived in main proof (added as remark)

## Related results
- **Hoeffding's inequality** (1963): The special case for independent bounded random variables (not just martingale differences). Azuma-Hoeffding generalizes this to the martingale setting.
- **McDiarmid's bounded differences inequality** (1989): A corollary of Azuma-Hoeffding applied to functions of independent random variables via the Doob martingale. Already in our library at `proofs/statistics/concentration/mcdiarmid-bounded-differences-inequality/`.
- **Freedman's inequality**: Sharpens Azuma-Hoeffding by incorporating the conditional variance (predictable quadratic variation) instead of worst-case bounds $c_k$.
- **Bennett's inequality / Bernstein's inequality**: Related concentration bounds that incorporate variance information for independent summands.
- **Matrix Azuma inequality** (Tropp 2012): Matrix-valued extension. Related to the matrix Bernstein inequality in our library at `proofs/statistics/concentration/matrix-bernstein-inequality/`.
- **Sub-Gaussian covariance concentration**: In our library at `proofs/statistics/concentration/sub-gaussian-covariance-concentration/`, uses similar MGF bounding techniques.
