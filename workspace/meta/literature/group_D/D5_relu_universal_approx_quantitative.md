# D5: Quantitative ReLU universal approximation

**Source claimed**: Yarotsky 2017 (1610.01145) / Bach 2017 (1611.01491).

**Local proof**: For $L$-Lipschitz $f$ on $[0,1]^d$, construct piecewise-affine interpolant via Kuhn triangulation on grid of mesh $\delta = 1/\lceil L/\epsilon\rceil$. Apply CPL-to-ReLU theorem (Wang-Sun 2005 / Arora et al. 2018). Result: $N = O((L/\epsilon)^d)$ neurons.

**Literature**:
- Yarotsky 2017: shows $\epsilon$-approximation of $W^{n,\infty}([0,1]^d)$ functions in two-layer ReLU networks with $N = O(\epsilon^{-d/n} \log(1/\epsilon))$. For Lipschitz ($n=1$) Yarotsky's bound is $O(\epsilon^{-d}\log(1/\epsilon))$, matching the local bound up to a $\log$ factor.
- Bach 2017 ("Breaking the Curse of Dimensionality with Convex Neural Networks") uses different tools (variation norm) and gets dimension-free rates only under harmonic-analysis smoothness, not Lipschitzness.
- The classical bound "Lipschitz with constant $L$ in $L^\infty([0,1]^d)$ needs $N=\Theta((L/\epsilon)^d)$" is a folklore consequence of $\epsilon$-net + linear-region counting; appears in many references (DeVore et al. 1989 for general approximation; Anthony-Bartlett 1999 for ReLU specifically).

**Verdict**: REPRODUCED (matches Yarotsky-style construction). The technique (Kuhn triangulation + CPL-to-ReLU) is standard. Local bound $O((L/\epsilon)^d)$ is the optimal rate for arbitrary Lipschitz functions — this matches the curse-of-dimensionality lower bound.

**Discrepancies**: None.

**Honest classification**: B-class textbook approximation result.
