# Notes: RIP Sparse Recovery Guarantee

## Proof technique
The winning route (Route 3) uses a **refined inner product analysis with RIP and ROP**. The key idea is:
1. Decompose the error $h = \hat{x} - x^*$ into blocks by magnitude
2. Use $Ah = 0$ to set up inner product identities
3. Apply ROP to pairs $(T_0, T_j)$ and $(T_1, T_j)$ separately (avoiding the $3s$-support problem)
4. Reduce to a quadratic infeasibility argument in the ratio $t = \|h_{T_1}\|/\|h_{T_0}\|$

Three other routes failed: naive Cauchy-Schwarz (too loose), NSP via RIP (same issue), and dual certificate (s-dependent bound).

## Key steps
1. **Cone constraint**: ℓ₁ optimality gives $\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1$
2. **Tail bound via block decomposition**: $\beta = \sum_{j \geq 2}\|h_{T_j}\|_2 \leq \|h_{T_0}\|_2$
3. **ROP decomposition trick**: Split $\langle Ah_{T_{01}}, Ah_{T_j}\rangle$ into two terms, each with support $\leq 2s$
4. **Quadratic argument**: The inequality $(1-\delta)t^2 - \delta t + (1-2\delta) \leq 0$ has discriminant $-7\delta^2 + 12\delta - 4 < 0$ for $\delta < (6-2\sqrt{2})/7$, making it unsatisfiable
5. **The ROP lemma** requires a rescaling trick ($\lambda u$, $v/\lambda$, optimize $\lambda$) for the tight bound $\delta\|u\|\|v\|$

## Audit result
- Round 1: FAIL — ROP lemma proof had wrong AM-GM direction
- Round 2: PASS — Fixed via rescaling argument; all steps validated
- Numerical verification confirmed discriminant $\approx -0.2304$ at $\delta = \sqrt{2}-1$

## Related results
- **Candès & Tao 2005**: Original RIP recovery with condition $\delta_s + \theta_{s,2s} + \theta_{s,3s} < 1$
- **Candès 2008**: Introduced the cleaner condition $\delta_{2s} < \sqrt{2}-1$
- **Cai & Zhang 2014**: Sharp threshold $\delta_{2s} < \sqrt{2}-1$ is tight (matching lower bound)
- **Johnson-Lindenstrauss lemma**: Random projections satisfy RIP with high probability (connects to our JL proof in the library)
- **Basis Pursuit / Dantzig Selector**: Alternative formulations for sparse recovery
- **Sub-Gaussian covariance concentration**: Used to prove random matrices satisfy RIP (connects to our sub-Gaussian concentration proof)
- Our proof actually establishes recovery under the weaker condition $\delta_{2s} < (6-2\sqrt{2})/7 \approx 0.4525$
