# Notes: McDiarmid's Bounded Differences Inequality

## Proof technique
Exponential supermartingale route won. The key idea is to define $M_k = \exp(\lambda Z_k - \lambda^2 \sum_{j \leq k} c_j^2/8)$ and show it's a supermartingale via Hoeffding's lemma, giving exact cancellation. This avoids the need for explicit iterated conditioning (as in the direct MGF approach) while being more elementary than the entropy/log-Sobolev route.

## Key steps
1. Doob martingale $Z_k = \mathbb{E}[f(X) \mid X_1, \ldots, X_k]$ telescopes $f(X) - \mathbb{E}[f(X)] = \sum D_k$
2. Bounded differences condition implies $D_k$ lies in interval of length $\leq c_k$ (via auxiliary function $g_k$)
3. Hoeffding's lemma: centered bounded r.v. has sub-Gaussian MGF, proved via convexity + $\varphi''(h) = q(1-q) \leq 1/4$
4. Supermartingale property: Hoeffding bound on $\mathbb{E}[e^{\lambda D_k}]$ exactly cancels the compensator $e^{-\lambda^2 c_k^2/8}$
5. Markov on $M_n$ + optimize $\lambda^* = 4t/C$ yields the sharp constant $2t^2/C$

## Audit result
PASS on first round. All 5 steps VALID. Only 4 LOW-severity notational issues.

## Related results
- **Azuma-Hoeffding inequality**: Special case when the martingale differences are directly bounded (McDiarmid reduces to this via the Doob construction)
- **Hoeffding's inequality**: Special case for sums of bounded independent random variables ($f = \sum X_i$)
- **Sub-Gaussian concentration**: McDiarmid shows $f(X) - \mathbb{E}[f(X)]$ is sub-Gaussian with variance proxy $C/4$
- **Entropy method (Bobkov-Ledoux)**: Alternative proof via tensorization of entropy + Herbst argument; yields the same bound but through a fundamentally different mechanism
- **Efron-Stein inequality**: Gives a variance bound $\mathrm{Var}(f) \leq \frac{1}{2}\sum c_i^2$, weaker than the exponential tail but requires only second-moment control
