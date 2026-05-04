# Audit 1 — Step-by-step rigor classification of gap1_proof.md

For each step in the 7-step DAG, classify as **STRICT PROOF** (logically self-contained derivation) or **NUMERICAL EVIDENCE** (conclusion depends on the output of a numerical experiment).

| # | Lemma | Content | Verification | Rigor |
|---|-------|---------|--------------|-------|
| L1 | kinematic | $x_1^{\text{zero}} = \lambda(-\beta e_0 + e_1 + \beta e_2)$, $\|x_1\|^2 = \lambda^2(1+3\beta^2)$ | SymPy (S1) | **STRICT.** Algebraic identity, given the OP-2 cycling identity $\eta\nabla f_0(\lambda e_0)=\lambda((1+\beta)e_0-e_1-\beta e_2)$ on $\mathcal F_{K=3}$. |
| L2 | polytope-exit | $x_1^{\text{zero}}$ exits $\operatorname{conv}(\widetilde P)$ on an open subset $\mathcal R_2 \subset \mathcal F_{K=3}$ of positive 3-D Lebesgue measure | algebraic anchor + grid M3 | **STRICT openness/measure**, but **does NOT prove cycling.** L2 only diagnoses one *necessary* condition (polytope-exit). |
| L3 | Vieta amplitude | $\|A_\mu^{\text{zero}}\|^2 = v^2\eta\mu/(4\beta\sin^2\theta_\mu)$; linear analysis predicts decay | SymPy (S2) | **STRICT.** Algebraic. Diagnostic only — says cycling must come from nonlinearity. |
| L4 | Floquet | Floquet operator $J^3 = M_\mu^3 \otimes I_2$ has spectrum $\{\beta^{3/2}e^{\pm 3i\theta_\mu}\}$ at vertex Hessian $\mu I$ | mpmath (M2) | **STRICT modulo vertex projection.** The Hessian $=\mu I$ assertion is rigorous *if* $P_{\widetilde P}(\lambda e_0)$ falls on a vertex. M2 confirms eigenvalues equal $\beta^{3/2}$ (a sanity check, not extra evidence). The Floquet calculation gives **local** attractiveness only. |
| L5 | basin | Zero-momentum init lies in basin; $\|x_T\| \ge \lambda(1-C\beta^{3T/2})$; $f_0(x_T)-f_0^* \ge \kappa LD^2/(23T)$ | mpmath (M1) | **PARTIAL — primarily numerical.** The Floquet stable-manifold theorem gives $r > 0$ exists (rigorous). But $r$ is **not computed**; the assertion "the zero-momentum init is inside this basin" is supported only by the numerical observation (M1) that the orbit at the anchor reaches the cycle to 50 digits. The constant $1/23$ for $\forall T \ge 1$ is also purely empirical (binding $t=4$ in the M1 sweep). |
| L6 | non-emptiness witness | Anchor lies in an open ball $B(\text{anchor}, r^*) \subset \mathcal R_2 \cap \mathcal R_4 \cap \{\text{basin}\}$, hence $\operatorname{Leb}_3(\mathcal F^{\text{cycle}}_{K=3}) > 0$ | mpmath (M1, M3) | **PARTIAL.** Existence of *some* open neighborhood is rigorous from continuity (basin radius is continuous in parameters for hyperbolic fixed points). But the proof does **not produce a quantitative size**; the "30% of grid" figure is purely empirical. |
| L7 | period-6 complement | Period-6 attractor at $(0.9, 3.78, 0.05)$ with floor $\ge 2.22\mu D^2$ | mpmath (M4) | **NUMERICAL.** All support is a single anchor witness. The "by OP-2 affine characterization … spectral radius $\beta^3 < 1$" sentence is asserted, not derived; the piecewise-linear region containment is a numerical observation. |
| L8 | variance transfer | $\mathbb E[g(y_T)] \ge \sqrt 2 \sigma D /(27\sqrt T)$ inherits unchanged | (none — algebraic) | **STRICT.** $x$- and $y$-coordinates decouple; the Le Cam two-point bound on $y$ is unaffected by the $x_{-1}$ change. |

## Specific check: the three claims the user flagged

### 1. "Positive measure $F_{\text{usable}}$ on which cycling holds" — strict or numerical?

**NUMERICAL.** Two things must hold for cycling: (a) polytope-exit (L2, $\mathcal R_2$, rigorous open/positive measure), and (b) zero-momentum init lies inside the K=3 basin of attraction. (b) is *not* derived in closed form. The proof structure is:

- Floquet (L4): cycle is hyperbolically attracting → some basin radius $r > 0$ exists by the stable-manifold theorem. Rigorous.
- Zero-momentum init at *anchor* enters that basin: verified only by numerical orbit simulation (M1).
- Continuity: there is *some* open neighborhood of the anchor where orbit also enters basin. Rigorous existence but **not constructive**.

So "positive measure" is rigorous in principle but carries no quantitative content beyond "non-empty open ball around the anchor exists." The 30% figure (16/54 grid points) is not a measure-theoretic statement — it is a count of how often the *numerical* simulation classified a grid cell as cycling.

### 2. "Orbit converges to a cycle" — convergence proof or numerical only?

**NUMERICAL.** The proof contains *no* quantitative convergence theorem. The closest claim is L5's "transient correction" $\|x_T\| \ge \lambda(1-C\beta^{3T/2})$ for "an explicit $C$ depending continuously on $(\beta,\eta L,\kappa)$" — but $C$ is never computed and depends on the basin radius which is also never computed. The actual support for "orbit reaches cycle" is the M1 simulation showing $\|x_{10000}\| - \lambda$ vanishes to $30$ digits at the anchor, plus the M3 grid finding 16/54 grid points where the simulated $\|x_{5000}\|$ is within 1% of $\lambda$.

### 3. Floquet stability — strict or numerical?

**STRICT (the eigenvalue derivation), with a numerical sanity check.** The derivation $J = M_\mu \otimes I_2$ at vertex Hessian $\mu I$, hence $\operatorname{spec}(J^3) = \{\beta^{3/2}e^{\pm 3i\theta_\mu}\}$, is closed-form and rigorous. M2 just numerically evaluates the eigenvalues at the anchor and confirms they all equal $\beta^{3/2} = 0.7155\ldots$. No extra information beyond the symbolic derivation.

**However**, "the Hessian at the cycle vertex equals $\mu I$" assumes the projection $P_{\widetilde P}(\lambda e_0)$ falls on the vertex, not on an edge. That this *vertex*-projection condition holds is asserted to be open and to contain the anchor — rigorous by continuity, but the *anchor membership* itself is verified only at the anchor (numerically/algebraically).

## Verdict on Audit 1

The proof has a clean rigorous skeleton (L1, L2, L3, L4, L8) and a numerically-supported core (L5, L6, L7). The skeleton establishes:

- The first iterate has a closed form (L1).
- The exit condition defines an open positive-measure set (L2).
- The cycle is hyperbolically attracting if it exists at vertex projection (L4).
- The variance term inherits unchanged (L8).

The core is what does the actual cycling work, and it is numerical:

- L5: zero-momentum lies in basin → mpmath simulation at anchor.
- L6: positive measure of cycling → continuity argument (rigorous existence, no quantitative bound) + grid M3 (16/54 numerical).
- L7: period-6 complement → one anchor witness (M4), no analysis.

**This is normal for a result of this type** (existence of a nonempty open set is hard to make constructive), but it is *not* the airtight closed proof that the v5 §0.8 gap envisaged. The proof's true content is:

> "The K=3 cycle is hyperbolically attracting; the zero-momentum initialization is empirically observed to enter its basin at the anchor and at 16/54 nearby grid points; therefore by continuity there is *some* nonempty open positive-measure subset of $\mathcal F_{K=3}$ on which zero-momentum init produces cycling."

This is honest enough to be called a Route A proof, **provided** the reader accepts that "lies in basin" is verified numerically and that the constants ($1/23$, the size of the open subset) are anchor-specific empirical figures.

## Open questions for downstream audits

- Is "16/54 cycling" robust to a stricter cycling criterion? (Audit 2)
- Does the cycling survive in the *stochastic* setting that OP-2 actually targets? (Audit 3)
- Is the $t=4$ transient (where $\|x_4\|/\lambda \approx 0.21$) a real vulnerability under stochastic perturbation? (Audit 4)
