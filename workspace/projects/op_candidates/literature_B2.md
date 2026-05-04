# Literature Survey: B2 — Min-Max Last-Iterate Lower Bound

## Survey date: 2026-04-28
## Keywords: last-iterate convergence, saddle point, GDA/EG/OGDA lower bound, monotone VI, convex-concave

---

## 1. Foundational papers (pre-2023)

### Golowich–Pattathil–Daskalakis–Ozdaglar 2020 (COLT)
**"Last Iterate is Slower than Averaged Iterate in Smooth Convex-Concave Saddle Point Problems"**
- arXiv: 2002.00057
- **Key result**: EG last iterate is Θ(1/√T). Proved Ω(1/√T) lower bound for the last iterate of EG in smooth C-C saddle-point problems, and matching O(1/√T) upper bound.
- **Gap established**: quadratic separation — averaged iterate is O(1/T), last iterate is Ω(1/√T).
- **Scope**: unconstrained smooth convex-concave, EG specifically. Did NOT give tight bounds for GDA or OGDA in general C-C.

### Gorbunov–Loizou–Gidel 2022 (AISTATS)
**"Extragradient Method: O(1/K) Last-Iterate Convergence for Monotone VIs and Connections with Cocoercivity"**
- arXiv: 2110.04261
- **Key result**: EG achieves O(1/K) last-iterate convergence for monotone Lipschitz operators *with Lipschitz Jacobian* (cocoercive-like assumption).
- **Scope**: stronger assumption than plain Lipschitz monotone; not the bare convex-concave setting.

### Gorbunov–Taylor–Horváth–Gidel 2022 (NeurIPS)
**"Last-Iterate Convergence of Optimistic Gradient Method for Monotone Variational Inequalities"**
- arXiv: 2205.08446
- **Key result**: OGDA achieves O(1/K) last-iterate rate for Lipschitz monotone operators *without* Jacobian assumption.
- **Note**: This is the operator-norm version (‖F(z_T)‖²). Does not match the gap/duality-gap formulation of Golowich 2020.

### Cai–Oikonomou–Zheng 2022 (NeurIPS 2022 / published)
**"Tight Last-Iterate Convergence of the Extragradient and the Optimistic Gradient Descent-Ascent Algorithm for Constrained Monotone Variational Inequalities"**
- arXiv: 2204.09228; Yale homepage: http://www.cs.yale.edu/homes/cai/publication/cai-tight-2022/
- **Key result**: **CLOSES** the tight last-iterate gap for EG and OGDA in the *constrained* monotone VI setting.
  - Both EG and OGDA achieve tight O(1/√T) last-iterate rate for arbitrary convex feasible sets.
  - Uses tangent residual as potential function.
  - Lower bound: Ω(1/√T) for both algorithms — matching upper bound.
- **Scope**: constrained smooth monotone VI. Covers convex-concave saddle-point as special case.
- **Impact**: This is the most complete tight result to date for EG/OGDA last-iterate in C-C.

---

## 2. Recent papers 2023–2026

### Cai–Farina–Grand-Clément–Kroer–Lee–Luo–Zheng 2024 (NeurIPS 2024)
**"Fast Last-Iterate Convergence of Learning in Games Requires Forgetful Algorithms"**
- arXiv: 2406.10631
- **Key result**: Negative result for *memory-full* algorithms (OMWU, standard OFTRL family): any algorithm that does not forget the past quickly suffers constant duality gap even after 1/δ rounds in 2×2 matrix games.
- **Scope**: discrete games / finite matrix games, not the continuous smooth C-C setting. Techniques are different.
- **Relevance**: establishes structural lower bounds on algorithm class, extends to 2^n×2^n games. Not a rate-level LB for the C-C smooth setting.

### Cai–Luo–Wei–Zheng 2025 (NeurIPS 2025, arXiv: 2506.03464)
**"From Average-Iterate to Last-Iterate Convergence in Games: A Reduction and Its Applications"**
- **Key result**: Black-box reduction transforming average-iterate convergence of any uncoupled learning dynamics into last-iterate convergence of a new dynamics.
- **Relevance**: positive/upper-bound result, not a lower bound. But shows that if you have O(1/T) average-iterate, you can get last-iterate for free in games. Closes some positive-side gaps.

### Cai et al. 2025 (arXiv: 2503.02825)
**"On Separation Between Best-Iterate, Random-Iterate, and Last-Iterate Convergence of Learning in Games"**
- **Key result**: Lower bounds showing OMWU does not achieve polynomial random-iterate convergence rate. Best-iterate O(T^{-1/6}) for OMWU. First LBs for random-iterate.
- **Scope**: Discrete/game-theoretic setting, OMWU/OFTRL. Not continuous C-C smooth setting.

### Anchored GDA line (2024–2026)
- **"An Improved Last-Iterate Convergence Rate for Anchored Gradient Descent Ascent"** (arXiv: 2604.03782, April 2026):
  Resolves open problem: Anchored GDA achieves O(1/t) last-iterate rate for smooth C-C problems. Discovered autonomously with AI/Lean.
- **"Negative Stepsizes Make Gradient-Descent-Ascent Converge"** (arXiv: 2505.01423, 2025):
  Slingshot stepsize schedule (time-varying, asymmetric, periodically negative) makes vanilla GDA converge in C-C.
- **Relevance**: These are positive/upper-bound results for modified algorithms. They don't provide lower bounds for standard GDA.

### He-Liu 2024 — not located
- Search did not find a specific He-Liu 2024 paper targeting last-iterate LBs in C-C. The complexity LB papers found are He-Yuan (2012, ADMM) and Ouyang-He (bilevel). Likely a false lead or not yet indexed.

### Linear convergence in bilinearly-coupled saddle-points (November 2024)
- arXiv: 2411.14601: Lower bounds and optimal algorithms for smooth C-C *bilinearly-coupled* problems (non-strongly-convex). Different sub-problem class.

---

## 3. What last-iterate lower bounds EXIST as of 2026-04?

| Setting | Algorithm | LB | UB | Tight? | Source |
|---|---|---|---|---|---|
| Smooth C-C unconstrained | EG | Ω(1/√T) | O(1/√T) | YES | Golowich 2020 |
| Smooth C-C constrained | EG + OGDA | Ω(1/√T) | O(1/√T) | YES | Cai-Oikonomou 2022 |
| Smooth C-C constrained | OGDA (operator norm) | O(1/K) | O(1/K) | YES | Gorbunov 2022 |
| Smooth C-C | Anchored GDA | O(1/T) | O(1/T) | Partial | arXiv 2604.03782 |
| Bilinear | OGDA | O(1/T) | O(1/T) | YES | Library: ogda-bilinear-last-iterate |
| Matrix games (discrete) | OMWU / OFTRL | slow (constant duality gap) | — | YES | Cai 2024 NeurIPS |
| SC-SC | GDA | linear | linear | YES | folklore |

## 4. What gaps remain?

### Gap A — Standard GDA last-iterate in smooth C-C: OPEN
- Standard GDA (simultaneous, equal stepsizes) is known to DIVERGE in plain bilinear convex-concave. There is no last-iterate convergence guarantee without modification.
- The slingshot/anchoring modifications converge, but there is no LOWER BOUND specifically bounding the best achievable last-iterate rate for the GDA algorithm class (constant stepsizes).
- **Potential direction**: prove that any constant-stepsize simultaneous GDA must have last-iterate not converging, or give a polynomial lower bound.

### Gap B — Stochastic EG/OGDA last-iterate lower bounds: OPEN/PARTIAL
- Golowich 2020 LB is deterministic. In the stochastic setting (noise in gradient evaluations), tight last-iterate LBs for EG/OGDA in smooth C-C are NOT fully characterized.
- "Revisiting Last-Iterate Convergence of Stochastic Gradient Methods" (arXiv: 2312.08531, ICLR 2024, updated V4 March 2026) addresses SGD minimization, not saddle-point specifically.
- Stochastic Extragradient Flip-Flop Anchoring (NeurIPS 2024) gives upper bounds in SCSC. No matching LB in C-C stochastic setting.

### Gap C — Accelerated last-iterate rates for smooth C-C: PARTIALLY OPEN
- Anchored GDA achieves O(1/T) deterministic. Whether O(1/T) is optimal (i.e., cannot be improved further) for ANY first-order method last-iterate in smooth C-C is **not settled** as of 2026-04.
- The lower bound of Ω(1/√T) applies to EG/OGDA specifically, not to all possible algorithms.
- Whether a last-iterate rate better than O(1/T) is achievable with *any* first-order method is an open question.

### Gap D — Non-smooth / Lipschitz-only C-C setting: PARTIALLY OPEN
- arXiv: 2604.07662 (April 2026) shows o(1/√T) last-iterate for Lipschitz monotone operators with EG-type methods. This appears to push *above* the Golowich 2020 lower bound, which applies specifically to EG — the lower bound construction may not apply to this modified scheme.

---

## 5. Assessment of "envisioned gap" for B2

The original B2 proposal asks: "what is the last-iterate LB for smooth C-C problems, specifically GDA/EG/OGDA?"

- **EG/OGDA in smooth C-C (constrained)**: CLOSED by Cai-Oikonomou 2022. Tight O(1/√T).
- **OGDA in bilinear**: CLOSED. In library.
- **The remaining open sub-questions are**: (A) stochastic EG/OGDA last-iterate LB, (B) whether O(1/T) is the optimal possible rate for *any* first-order method last-iterate in smooth C-C.

The "obvious" version of B2 is CLOSED. Only refined variants remain.
