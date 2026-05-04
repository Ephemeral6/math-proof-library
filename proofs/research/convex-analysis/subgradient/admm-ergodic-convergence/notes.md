# Notes: ADMM Ergodic O(1/T) Convergence (He–Yuan 2012 SIOPT)

## Proof technique

**Winning route**: Route 3 — Direct augmented-Lagrangian saddle analysis (no VI / operator-theoretic machinery).

The core mechanism is the *exact* splitting of two dual cross-terms into a single perfect square at each step. Starting from the subgradient inequalities from the $x$- and $z$-subproblem optimality conditions and the dual update $\lambda^{k+1}=\lambda^k+\beta r^{k+1}$:

$$\widehat\Phi^{k+1} \;\le\; \underbrace{\langle\tilde\lambda-\lambda^k,\,r^{k+1}\rangle}_{\text{dual cross-term}} \;+\; \underbrace{\beta\langle B(z^k-z^{k+1}),\,B(\tilde z-z^{k+1})\rangle}_{\text{primal cross-term}} \;+\;\beta\langle s^{k+1},d\rangle,$$

where $s^{k+1}:=Ax^{k+1}+Bz^k-c$ is the *intermediate primal residual*. The key algebraic fact is $r^{k+1}+B(z^k-z^{k+1})=s^{k+1}$, which allows the two $d$-linear terms to combine. Then:

1. **Dual-ID** (polarization on $\lambda^k/\beta$): the dual cross-term splits into a telescoping $\|\tilde\lambda-\lambda^k\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2$ plus a residual $-\tfrac{\beta}{2}\|r^{k+1}\|^2$.
2. **B-pol** (polarization on $Bz^k$): the primal cross-term splits into a telescoping $\beta\|B(\tilde z-z^k)\|^2-\beta\|B(\tilde z-z^{k+1})\|^2$ plus a residual $-\tfrac{\beta}{2}\|B(z^k-z^{k+1})\|^2$.
3. **Sq** (perfect square): the two residuals combine with a cross-term $\beta\langle r^{k+1}, B(z^k-z^{k+1})\rangle$ (from a mixed-form A-B split) into $-\tfrac{\beta}{2}\|s^{k+1}\|^2 \le 0$, which can be discarded.

The result is the key one-step inequality $\widehat\Phi^{k+1} \le \mathcal E^k - \mathcal E^{k+1}$ with Lyapunov $\mathcal E^k = \tfrac{1}{2\beta}\|\tilde\lambda-\lambda^k\|^2 + \tfrac{\beta}{2}\|B(\tilde z-z^k)\|^2$. Telescope and apply Jensen on $\theta=f+g$ (convexity, upper bound on $\theta(\bar u_T)$) with linearity on the dual pairing (exact average) to get the ergodic bound.

**Indexing subtlety**: the problem defines $\bar\lambda_T = \tfrac{1}{T}\sum_{k=0}^{T-1}\lambda^k$ (lagged). Route 3 handles this natively by aligning the per-step gap to the lagged dual $\lambda^k$ throughout, which is why it beat Route 1's otherwise-equivalent VI framing in the Judge's tie-break.

## Key steps

1. **Optimality**: $(O_x)$ $\exists\xi_f^{k+1}\in\partial f(x^{k+1})$ with $\xi_f^{k+1}=-A^\top\lambda^{k+1}-\beta A^\top B(z^k-z^{k+1})$. $(O_z)$ $\exists\xi_g^{k+1}\in\partial g(z^{k+1})$ with $\xi_g^{k+1}=-B^\top\lambda^{k+1}$.
2. **Per-step inequality** $\widehat\Phi^{k+1} \le \mathcal E^k-\mathcal E^{k+1} - \tfrac\beta 2\|s^{k+1}\|^2 + \beta\langle s^{k+1},d\rangle$ — where $d=A\tilde x+B\tilde z-c$ is the test-point residual.
3. **Telescope + Jensen**: under feasibility $d=0$, the last term vanishes; summing over $k$ and dividing by $T$ yields $\Phi(\bar w_T;\tilde w)\le \mathcal E^0/T$.
4. **RHS expansion**: $\mathcal E^0 = \tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2 + \tfrac\beta 2\|B(\tilde z-z^0)\|^2$, matching the stated constants.

## Audit result

PASS on audit round 1. All 11 steps VALID. 7 numerical check families passed (ergodic bound at $T\in\{1,5,10,50\}$; per-step key inequality at $k=0..4$ with consistent margin ~0.25; five algebraic identities — A-split, Cross-split, Sq, Dual-ID, B-pol — verified to machine precision; Appendix counterexample reproduced to confirm feasibility hypothesis is necessary). Cross-verification with the full-rank library version (`proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/`) and Chambolle-Pock ergodic proof: CONSISTENT (same Lyapunov, same rate, same constants). No HIGH/MEDIUM issues, only LOW-severity readability nits. No Fix round needed.

## Important theorem-scope correction

**The theorem as originally stated was false for infeasible test points.** All 4 Explorers independently identified this; Route 3 produced an explicit counterexample ($f=g=0$, $A=B=I$, $c=0$, $z^0=0$, $\lambda^0=-\beta$, $\tilde x=1$, $\tilde z=\tilde\lambda=0$) where LHS $=\beta/T$ but the stated RHS $=\beta/(2T)$. Without feasibility $A\tilde x+B\tilde z=c$, an unbounded term $\beta\langle B(z^0-z^T),\tilde r\rangle$ appears on the LHS. The problem statement was amended (mid-workflow) to add the feasibility constraint, which matches the original He-Yuan 2012 formulation and the problem's own corollary remark.

This kind of problem-statement bug was caught purely through *independent convergence of 4 proof attempts* — a strong argument for running multiple routes in parallel rather than just one.

## Related results

- **Douglas-Rachford splitting O(1/k) convergence** (`proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/`): ADMM is equivalent to DR on the dual problem (Gabay 1983); Route 2 made this equivalence explicit but couldn't close the gap for infeasible test points.
- **Chambolle-Pock PDHG O(1/N) ergodic convergence** (`proofs/research/convex-analysis/subgradient/chambolle-pock-pdhg-ergodic-convergence/`): uses the same H-weighted distance template with preconditioning. Direct structural sibling.
- **Davis-Yin 3-op splitting ergodic rate** (`proofs/research/convex-analysis/subgradient/davis-yin-three-operator-splitting-ergodic-variant/`): 3-block generalization with anchor-shift technique.
- **ADMM ergodic O(1/T) full-rank** (`proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/`): the pre-existing full-rank version; this theorem is its rank-free generalization with identical constants.

## Route outcomes (for learning)

- Route 1 (He-Yuan VI framework): **valid**, 29/40, tied with Route 3. Lost tie-break because it required a separate Step 5a to handle the lagged-dual indexing, whereas Route 3 handled it natively.
- Route 2 (DR-on-dual equivalence): **partial**, 18/40. The Gabay ADMM↔DR correspondence was derived from first principles (identifying $s^k=\lambda^k+\beta Bz^k$ as the DR running iterate), but the $H$-Lyapunov absorption for arbitrary test points leaves a residue $-\tfrac{\beta}{T}\langle B(z^T-z^0),\tilde r\rangle$ that Route 1/3's VI framework kills via $-\tfrac12\|v^{k+1}-v^k\|_H^2$ — a genuine structural gap.
- Route 3 (Direct Lagrangian): **selected**, 29/40.
- Route 4 (Proximal-point in H-semi-norm): **valid but overcomplicated**, 25/40. Factored cleanly into an abstract ergodic theorem + ADMM-satisfies-hypothesis verification. The abstract theorem was genuinely proved in a PSD (not PD) semi-norm, avoiding the scout-warned circularity. But added an extra layer of abstraction without new insight.

## The 4-parallel-routes payoff

This problem is a strong case study for the value of launching 4 Explorers in parallel rather than sequentially: not only did we get 2 valid proofs (Routes 1, 3) and 2 informative partial failures (Routes 2, 4), but **all 4 independently flagged the same bug in problem.md** (the missing feasibility constraint). A single route might have silently "proved" the false theorem by overlooking the $d$-linear term. Diversity catches errors that individual rigor may miss.
