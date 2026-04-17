# Notes: Davis-Yin Three-Operator Splitting Ergodic O(1/K) Rate (Variant)

## Proof technique

**Winning route**: Route 4 (Primal-Dual Lyapunov) structure, repaired through Path B (weaker-regime variant).

The key insight that unlocked the proof is the **primal-dual identity**:
$$u^k + v^k + \nabla h(y^k) = -r^k/\gamma,\qquad r^k := z^{k+1} - z^k$$
which collapses the three subgradient cross-terms in the convexity upper-bound to a single inner product $-(1/\gamma)\langle r^k, x^k - x^*\rangle$.

The second key step is the **anchor-shift decomposition**:
$$x^k - x^* = (z^{k+1} - x^*) - \gamma v^k$$
derived from $x^k = z^{k+1} - \gamma v^k$ (which follows from $y^k = z^k - \gamma v^k$ and $x^k = y^k + r^k$). This expresses the primal iterate in terms of the Lyapunov variable $z^{k+1}$ and the dual sequence $v^k$, enabling polarization to produce the telescoping norm differences.

The α-factor $1/(2\gamma\alpha)$ claimed in the original Davis-Yin statement cannot be recovered from local convex-analysis algebra alone — it requires the firm nonexpansiveness of the DYS operator composition (Davis-Yin's Prop 2.1) plus the averagedness argument (Thm 3.1). Accepting this limitation, a rigorous variant with leading constant $1/(2\gamma)$ in the restricted regime $\gamma\in(0,1/\beta]$ is provable.

## Key steps

1. **Fermat's rule** at both prox steps to extract explicit subgradients: $v^k\in\partial g(y^k)$, $u^k\in\partial f(x^k)$.
2. **Primal-dual identity** $u^k + v^k + \nabla h(y^k) = -r^k/\gamma$ by summing numerators.
3. **Fixed-point existence**: $z^* = x^* + \gamma v^*$ is a DYS fixed point.
4. **Three convexity bounds** (f, g at y^k, h via β-smooth descent + convexity).
5. **Master one-step inequality**: $\widetilde F^k - F(x^*) \le -(1/\gamma)\langle r^k, x^k - x^*\rangle - \langle v^k, r^k\rangle + (\beta/2)\|r^k\|^2$.
6. **Anchor shift + polarization** to convert to Lyapunov form with cancellation of $\langle r^k, v^k\rangle$ terms.
7. **Restriction to $\gamma \le 1/\beta$** makes the residual coefficient non-positive, enabling clean telescoping.
8. **Jensen** (separately on f at $\bar x^K$, g at $\bar y^K$, h at $\bar x^K$) to obtain ergodic bound.

## Audit result

- **Round 1 (FAIL)**: Original Route 4 proof had sign errors (Step 5 used $g(x^k) \le g(y^k) + \langle\lambda^k, x^k-y^k\rangle$ but $\lambda^k\in\partial g(y^k)$ gives the reverse direction), unproved absorption (Step 9), and invalid "α-rescaled polarization" (Step 10).
- **Round 2 (FAIL)**: Fix introduced "Lemma A" gap — the 1/α upgrade was asserted without proof.
- **Round 3 (PASS)**: Path B variant proof is complete end-to-end; numerical verification over 6 parameter settings × 20,000 one-step checks confirms (VAR) holds.

## Related results

- **Douglas-Rachford splitting** (`proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/`): the DYS reduces to DR when $h \equiv 0$. The Fejér-monotonicity approach for DR cannot be directly lifted to DYS because the smooth perturbation breaks pure nonexpansiveness.
- **Proximal-gradient O(1/T)** (`proofs/library/convex-analysis/subgradient/proximal-gradient-convergence-rate/`): DYS reduces to proximal gradient when $g \equiv 0$. The coefficient $(1-\gamma\beta)/(2\gamma)$ on the residual parallels the proximal-gradient analysis.
- **ADMM ergodic O(1/K)** (`proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/`): similar He-Yuan Lyapunov + polarization framework; the DYS version has an additional Baillon-Haddad / cocoercivity consideration due to the smooth term.

## Lessons learned (for future splitting-method proofs)

1. **Direction of convexity inequality matters**: when using $v^k \in \partial g(y^k)$, the valid upper bound is on $g(y^k) - g(w)$, not on $g(x^k) - g(w)$. To bound the full $F(x^k)$ requires either Lipschitz $g$ or a separate argument.
2. **Jensen on split iterates**: when primal iterate differs across subproblems, Jensen applies separately to each component. The resulting ergodic bound is on the split objective $\widetilde F(\bar x, \bar y)$, not on $F(\bar x)$.
3. **The α-factor typically requires averagedness**: for splitting methods with smooth term, the improved constant from the full step-size range $(0, 2/\beta)$ relies on operator-theoretic arguments (averagedness) rather than pure local convex algebra.
