# Technical Analysis: B2 — Min-Max Last-Iterate Lower Bound

## Date: 2026-04-28

---

## 1. Proof technique inventory for this problem

### Technique A: Direct cycling / hard instance construction
- **Paradigm**: construct a specific smooth C-C function f(x,y) where GDA/EG/OGDA iterates spiral, then lower-bound the gap.
- **Golowich 2020 approach**: constructed a bilinear-like hard instance where the iterate trajectory forms a spiral with radius not decaying faster than Ω(1/√T). Used Fourier analysis on the rotation matrix of the linear update.
- **Pipeline availability**: The library has `ogda-bilinear-last-iterate` which proved the O(1/T) upper bound for bilinear. The lower bound construction from Golowich (cycling argument for EG) is closely related but not identical.
- **For the closed C-C problem (EG/OGDA)**: Cai-Oikonomou 2022 extended this using a *tangent residual* potential and a tight "anti-norm" lower bound argument.

### Technique B: Le Cam / information-theoretic / oracle lower bounds
- **Paradigm**: Le Cam's method or Fano's inequality applied to the min-max oracle model. Show any algorithm cannot distinguish between two nearby hard instances.
- **Reusability**: OP-2 framework used this for stochastic SHB. The same oracle model (first-order stochastic oracle) applies here.
- **Challenge**: For *deterministic* last-iterate LBs in C-C, oracle-complexity-style Le Cam is less natural than direct construction, because the hard instances for last iterate need to exhibit "cycling near equilibrium," which is harder to encode in a Le Cam pair.
- **For the stochastic last-iterate LB (Gap B from literature)**: Le Cam would be well-suited. Can argue that with stochastic gradient noise, no algorithm can do better than Ω(1/√T) last-iterate (matching deterministic), or potentially Ω(1/T^{1/3}) depending on noise model.

### Technique C: SOS / PEP (Sum-of-Squares / Performance Estimation Problem)
- **Paradigm**: Encode algorithm performance as a semidefinite program; certify lower bounds numerically or via duality.
- Used in "Last-Iterate Convergence in Constrained Min-Max Optimization: SOS to the Rescue" (Simons Berkeley talk, related to Wei-Lee-Yang 2021 ICLR).
- **Pipeline availability**: Not currently in the library. Would need to build SDP infrastructure.

### Technique D: Variational / Lyapunov / potential function argument for tightness
- **Paradigm**: construct a potential Φ_t and show it cannot decrease faster than Ω(rate). Cai-Oikonomou 2022 used tangent residual.
- **Reusability**: The OP-2 SHB lower bound likely used a Lyapunov-style argument for the lower bound trajectory. Similar structure applies here.

---

## 2. Reusable pipeline components

### From `ogda-bilinear-last-iterate` (library):
- The OGDA update analysis for bilinear games: z_{t+1} = z_t - η F(z_t) + η F(z_{t-1}).
- Spectral / condition-number analysis of the rotation matrix.
- Can be re-used as a building block if the target is the *bilinear subcase* of a more general C-C lower bound.
- **Gap**: bilinear is too special — Cai-Oikonomou 2022 already extends to general C-C. The next open problem requires going beyond bilinear hard instances.

### From OP-2 (SHB stochastic non-SC last-iterate LB):
- Oracle complexity lower bound framework (first-order stochastic oracle).
- Cycling / anti-convergence argument for momentum methods.
- Heavy-ball / momentum hard instance construction (ln-cosh potential).
- **Transferability**: The stochastic noise model and the Le Cam framework transfer directly. The cycling argument needs to be adapted from "heavy-ball momentum" to "optimism" (OGDA) — structurally similar but different eigenvalue analysis.

---

## 3. What is NEW / non-trivial for an open sub-problem

### Sub-problem B2a: Stochastic OGDA/EG last-iterate lower bound in smooth C-C
- **Why non-trivial**: The deterministic LB (Cai-Oikonomou) uses a hard instance that requires exact gradient evaluations. With stochastic noise, the anti-cycling argument needs to be coupled with noise lower bounds.
- **Key new ingredient**: Need to show that noise cannot "help" the last iterate converge faster. This requires a stochastic hard instance where noise averages zero but the last iterate is still bounded below Ω(something).
- **Technique**: Le Cam + cycling construction. Construct two nearby stochastic problems where the last iterate cannot distinguish between equilibria at rate better than σ/√T · 1/√T = σ/T? (Unclear — this is the research question.)
- **Difficulty level**: High. The interaction between noise and last-iterate cycling is genuinely non-trivial.

### Sub-problem B2b: Is O(1/T) last-iterate optimal for smooth C-C over ALL first-order methods?
- **Why non-trivial**: Anchored GDA achieves O(1/T). The existing Ω(1/√T) LB applies only to EG/OGDA class, not all methods. Can any first-order method beat O(1/T)?
- **Approach**: Would need a NEW lower bound that applies to a broader class than EG/OGDA — e.g., the oracle complexity class of "deterministic first-order methods."
- **Key challenge**: The hard instance for Ω(1/T) (if it exists) must be resistant to anchoring. Hard to construct — anchoring works precisely by adding a drift term.
- **Prior art**: The Nesterov-style lower bound for minimization shows O(1/T²) is optimal for smooth convex; for min-max the structure is different.
- **Difficulty level**: Very high. Likely publishable at top venue if solved.

---

## 4. Hard instance strategy: bilinear vs. general C-C

For B2's "extend OGDA bilinear to general C-C":

**Bilinear**: f(x,y) = x^T A y. Equilibrium at (0,0). Update is linear: z_{t+1} = Mz_t. Eigenvalues of M control convergence. LB follows from eigenvalue analysis.

**General C-C**: f(x,y) arbitrary smooth C-C. Equilibrium may be non-unique, operator F = (∇_x f, -∇_y f) is monotone but non-linear.

**Hard instance construction strategy** (for stochastic LB):
- Use a "rotated quadratic" family: f_θ(x,y) = (x²-y²)/2 + θ·xy with θ small.
- This family has equilibrium at origin, operator F_θ is near-rotation for small θ.
- Two hypotheses: θ = +ε vs θ = -ε. Oracle cannot distinguish after T queries without seeing the last iterate "land" on correct side.
- This generalizes the bilinear hard instance to a curved landscape.
- **Key difficulty**: ensuring the curvature does not collapse the cycling behavior.

---

## 5. Technical feasibility summary

| Sub-problem | Technique | Pipeline reuse | Novel element | Estimated difficulty |
|---|---|---|---|---|
| Stochastic EG/OGDA LB (B2a) | Le Cam + cycling | OP-2 oracle model | Noise-cycling coupling | High |
| All-methods O(1/T) LB (B2b) | New oracle LB | Nesterov-style | Anti-anchoring hard instance | Very High |
| GDA divergence quantification | Direct cycling | ogda-bilinear | Constant-stepsize regime | Medium |

Most technically accessible angle in 6 weeks: **B2a (stochastic EG/OGDA LB in smooth C-C)** using Le Cam + the OP-2 oracle framework.
