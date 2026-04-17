# Notes: SPIDER Nonconvex Gradient Complexity

## Proof technique
**Route 1 (Lyapunov / Polarization absorption)** won. The polarization identity $\langle \nabla f, v\rangle = \frac{1}{2}(\|v\|^2 + \|\nabla f\|^2 - \|e\|^2)$ extracts a negative $\|v_t\|^2$ term from the smoothness descent, which absorbs the cumulative variance error without any lossy inequality.

## Key steps
1. **Variance tracking:** $e_{t+1} = e_t + \delta_{t+1}$ with $\delta_{t+1}$ zero-mean, giving $\sum\|e_t\|^2 \leq \frac{L^2\eta^2 q}{b}\sum\|v_t\|^2$.
2. **Polarization descent:** $f(x_{t+1}) \leq f(x_t) - \frac{\eta}{2}\|\nabla f\|^2 + \frac{\eta}{2}\|e_t\|^2 - \frac{\eta(1-L\eta)}{2}\|v_t\|^2$.
3. **Absorption:** With $\eta = 1/(2L)$ and $b = q$, the coefficient $\gamma = 1 - L\eta - L^2\eta^2 q/b = 1/4 > 0$, so variance is fully absorbed.
4. **Clean telescoping:** Last-iterate epoch output enables $\sum_k(F_k - F_{k+1}) = F_1 - F_{K+1} \leq \Delta_0$.

## Audit result
All steps verified. Key verification points:
- $\gamma = 1/4 > 0$ confirmed with $\eta = 1/(2L)$, $b = q$
- Telescoping is clean with last-iterate (not uniform) epoch output
- Cost accounting: $n + bq = 2n$ per epoch, $K = O(1/(\sqrt{n}\epsilon^2))$ epochs
- Final complexity $O(n + \sqrt{n}/\epsilon^2)$ matches the Fang et al. 2018 lower bound

## Related results
- **SVRG** (Johnson & Zhang 2013): Uses full gradient snapshots but achieves $O(n^{2/3}/\epsilon^2)$ for nonconvex, $O((n + n^{2/3}/\epsilon)\log(1/\epsilon))$ for strongly convex
- **SARAH** (Nguyen et al. 2017): Similar recursive gradient estimator, same $O(\sqrt{n}/\epsilon^2)$ rate
- **PAGE** (Li et al. 2021): Probabilistic gradient estimator achieving the same optimal rate with simpler analysis
- **Lower bound** (Fang et al. 2018): $\Omega(\sqrt{n}/\epsilon^2)$ for finite-sum nonconvex optimization, matched by SPIDER
- **SpiderBoost** (Wang et al. 2019): Extension handling the online (non-finite-sum) case with $O(1/\epsilon^3)$ rate

## Important subtlety: step size choice
The problem statement suggests $\eta = O(1/(L\sqrt{q}))$, which is correct for the general case where $b$ and $q$ are decoupled. With $b = q = \sqrt{n}$, the larger step size $\eta = 1/(2L)$ is valid and necessary to achieve the $\sqrt{n}$ rate. Using the smaller $\eta = 1/(L\sqrt{q}) = 1/(Ln^{1/4})$ would give the weaker $n^{3/4}$ rate.
