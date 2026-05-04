# Failure Triggers — machine-readable predictions

> Each block names a failure mode and the conditions under which the Explorer is likely
> to walk into it. Scan this file (a) before starting a proof, (b) after each major step
> of a draft, and (c) during audit. If a trigger fires, follow the recommended pivot OR
> document why the trigger doesn't apply in this case.

---

## FT-18-AUDITOR-MISSES-UB-LB-CONTRADICTION: Auditor fails to flag a draft whose proven UB is asymptotically smaller than the problem-stated LB

### Trigger Condition
WHEN problem involves: a research-level theorem whose `problem.md` simultaneously states an upper bound, a matching lower bound, and a tightness claim
AND proof attempt uses: any route whose final bound is strictly tighter than the stated LB (e.g., proves $O(\log T/\sqrt T)$ when LB is $\Omega(1/T^{1/4})$)
THEN this failure is likely because: the auditor only verified forward consistency (algorithm satisfies bound) and never ran a reverse consistency check against the LB / tightness statement.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a final UB whose rate exponent does not equal the LB rate exponent stated elsewhere in `problem.md`; or the draft applies suffix-averaging / Shamir-Zhang style results to a `last iterate` quantity (these bounds only hold for averaged iterates).

### Recommended Pivot
Instead of accepting the tighter UB, run a reverse-consistency check: write down both rates symbolically, compare exponents, and if UB beats LB then either (a) the LB in `problem.md` is wrong and must be re-examined, or (b) the UB proof contains a hidden mis-application (commonly: averaged-iterate bound applied to last iterate). Auditor should return FAIL_CONTRADICTION; Judge should return REJECT_ALL.

### Source
FP-18 (AdaGrad-Norm last-iterate blind test, 2026-04-17)

---

## FT-KAUFFMAN-CONVENTION: Kauffman bracket derived from Jones polynomial via wrong q/t convention substitution

### Trigger Condition
WHEN problem involves: low-dimensional-topology, deriving one knot invariant (Kauffman bracket) from a stored value of another (Jones polynomial) via a convention-sensitive identity
AND proof attempt uses: substitution like `V.subs(q, A^{-4})` without verifying which convention (q = t or q = t^{-1}) the source table uses
THEN this failure is likely because: two invariants related by `<D> = (-A)^{3w(D)} V_L(t)|_{t = A^{-4}}` require the t-convention; if the table stores V in the q-convention, the substitution sign flips and produces a polynomial whose every exponent is wrong.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `V.subs(q, A^{-4})` or `V.subs(q, A^{4})` without an accompanying convention-contract docstring; or `kauffman_bracket("trefoil")` returns a polynomial with positive-only or large-exponent monomials (textbook trefoil bracket is $-A^5 - A^{-3} + A^{-7}$).

### Recommended Pivot
Instead of trusting a single substitution, write an explicit convention contract in both the table's docstring and the derivation formula. Verify against one worked textbook example (Kauffman 1987 trefoil 3_1, or Lickorish Ch. 3 figure-eight 4_1) before propagating. Gate the module with an assert-based self-test; the high-confidence tag must reflect answer-correctness, not code-path-correctness.

### Source
FP-KAUFFMAN-CONVENTION-2026-04-20

---

## FT-SPIRAL-BLOCK-CIRCULANT-BASIS: Cyclic diagrammatic symmetry destroyed by a tree (rooted) basis choice on the Seifert surface

### Trigger Condition
WHEN problem involves: a periodic knot family (e.g., spiral knots S(p,q,ε), torus knots, q-fold braid closures) whose diagrammatic symmetry is cyclic ($\mathbb{Z}/q$)
AND proof attempt uses: the natural Seifert spanning-tree basis $\alpha_{k,i} = b_{k,i} - b_{1,i}$, rooted at one distinguished iteration
THEN this failure is likely because: rooting the basis at one iteration breaks the cyclic group action, producing all-to-all coupling instead of the desired block-circulant structure.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a basis with a single distinguished index (e.g., `_ - b_{1,i}` or `relative to iteration 1`) while claiming to exploit `cyclic symmetry`; or a Seifert matrix that ought to be block-circulant but exhibits dense cross-block entries.

### Recommended Pivot
Instead of a rooted/tree basis, use the cyclic-difference basis $\beta_{k,i} = b_{k,i} - b_{k+1,i}$ which respects the $\mathbb{Z}/q$ action; OR sidestep the basis-choice issue entirely by using the algebraic Burau representation in $\mathbb{Z}[t,t^{-1}]^{p-1}$, where the full $B_p$ action is available without choosing a basis.

### Source
FP-SPIRAL-BLOCK-CIRCULANT-BASIS-2026-04-20

---

## FT-SPIRAL-SKEIN-LEAVES-FAMILY: Skein relation induction on a periodic knot family lands outside the family

### Trigger Condition
WHEN problem involves: induction on the period q of a tightly-structured knot family (spiral knots S(p,q,ε), $q$-fold braid closures with gcd(p,q)=1)
AND proof attempt uses: skein resolution $\Delta_{L_+} - \Delta_{L_-} = (t^{1/2}-t^{-1/2}) \Delta_{L_0}$ at a seam crossing
THEN this failure is likely because: the resolution $L_-$ has an aperiodic braid word (one $\sigma_i^{\epsilon_i}$ removed) and $L_0$ splits the p-cycle into $(p{-}1)$-cycle + fixed point, producing a 2-component link — neither $L_-$ nor $L_0$ remains in the original family, so the inductive hypothesis cannot be applied.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: phrases like `apply skein at a seam crossing of $w_\epsilon^q$`; or claims that `$L_-$ is again a spiral knot` without verifying the braid word remains periodic.

### Recommended Pivot
Instead of skein induction, either (i) widen the family to all closures of length-pq braid words (loses most structure), or (ii) abandon skein and use representation-theoretic methods (Burau, reduced Burau) that respect the periodic structure — see FT-SPIRAL-PRINCIPAL-MINOR-MISFRAMING for the correct Burau induction setup.

### Source
FP-SPIRAL-SKEIN-LEAVES-FAMILY-2026-04-20

---

## FT-SPIRAL-PRINCIPAL-MINOR-MISFRAMING: Inducting on the principal minor of a Burau matrix in B_p instead of the intrinsic image in B_{k+1}

### Trigger Condition
WHEN problem involves: inducting on the size k of a Burau / reduced-Burau matrix to prove an identity like $\det(I - y B_\epsilon) = t^{e(\epsilon)} C_{p-1}(y,t)$
AND proof attempt uses: induction variable $D_k := \det(I_k - y \cdot B_\epsilon^{[k]})$ where $B_\epsilon^{[k]}$ is the leading $k\times k$ principal minor of the full $(p{-}1)\times(p{-}1)$ matrix in $B_p$
THEN this failure is likely because: `principal minor of the full matrix in B_p` is not the same object as `the full matrix of the partial word in B_{k+1}`; they coincide only at $k = p{-}1$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: notation like `$B_\epsilon^{[k]}$` defined as a principal-minor restriction; or base cases $D_1, D_2$ that fail to match the conjectured closed form while $D_{p-1}$ does match.

### Recommended Pivot
Instead of principal-minor restriction, use the intrinsic induction variable $F_k := \det(I_k - y \cdot A'_k)$ where $A'_k \in B_{k+1}$ is the partial word *re-instantiated in the smaller braid group*. Then prove a Block Structure Lemma showing the full image of a word using only $\sigma_1,\ldots,\sigma_k$ ($k \leq p{-}2$) has the form $\bigl(\begin{smallmatrix} A'_k & c_k \\ 0 & 1 \end{smallmatrix}\bigr)$ — last-row preservation makes induction close.

### Source
FP-SPIRAL-PRINCIPAL-MINOR-MISFRAMING-2026-04-20

---

## FT-SPIRAL-PARAMSWAP-MIXED-CASE-LEVEL1-GAP: Mixed-sign spiral-knot parameter swap blocked by missing level-1 lemmas

### Trigger Condition
WHEN problem involves: a paper-chained LDT theorem that depends on internal lemmas of the source paper (e.g., Blackwell et al. 2025 Theorem 4.4 on $S(p,q,\epsilon) \cong S(q,p,\epsilon')$)
AND proof attempt uses: only the level-1 library entries that have been pre-registered (Theorem 3.5, Corollary 3.10, Proposition 4.3) without §4 Lemmas 4.1/4.2
THEN this failure is likely because: registered lemmas suffice for uniform-sign and pure-torus subcases, but the `both ε mixed` subcase needs the unregistered refined Alexander classification or a closed-form spiral-knot signature/$\det(V_\epsilon)$ formula.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: STRATEGIC-STUCK at the `mixed ε` subcase; or arguments comparing block-cyclic Seifert matrices of mismatched size $q(p{-}1)$ vs $p(q{-}1)$ which (correctly) cannot conclude because S-equivalence permits stabilization.

### Recommended Pivot
Instead of attempting a patch, return PARTIAL with [REUSABLE-FRAGMENT: status=verified-as-counterexample] and request that level1_lemmas/ be populated with Blackwell §4 Lemma 4.1/4.2 (or the spiral-signature formula) before re-attempt. Preserve the three cross-pollination fragments (uniform-arm handler, asymmetric-case elimination via genus, Seifert-matrix dimension hook) as re-entry points.

### Source
FP-SPIRAL-PARAMSWAP-MIXED-CASE-LEVEL1-GAP-2026-04-21

---

## FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE: Time-average of a Goujaud rotational cycling orbit collapses to the optimum by Birkhoff symmetry

### Trigger Condition
WHEN problem involves: extending a cycling-style lower bound (Goujaud-Taylor-Dieuleveut rotational K-cycling) for fixed-momentum SHB from last iterate $x_T$ to averaged iterate $\bar x_T = (1/T)\sum x_t$
AND proof attempt uses: the same Goujaud cycling identity (★) on the regular K-gon, optionally adding stochastic noise (A3) or non-periodic orbit (A1)
THEN this failure is likely because: the regular K-gon vertex sum vanishes ($\sum_{t=0}^{K-1} e_t = 0$), so by Birkhoff ergodic theorem $\bar x_T \to 0 = x^\star$ deterministically, giving $f_0(\bar x_T) \leq LD^2/T^2$ — exactly AC-SA's bias rate, NOT $\Omega(LD^2/T)$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a target rate $\Omega(LD^2/T)$ on $\bar x_T$ together with reuse of `Goujaud cycling`, `regular polygon vertex sum`, `K-cycling` identity (★), or any rotation-equivariant orbit construction.

### Recommended Pivot
Instead of cycling-based reuse, switch to a fundamentally non-cycling lower-bound technique (e.g., HB-vs-AC-SA information-separation construction in $d=T$). If no such technique is available in the toolbox, restate the theorem honestly as a last-iterate bound and do NOT relabel as `oracle-complexity LB`. Adding stochastic noise gives at most $\Omega(\sigma_x^2/T)$, dominated by the standard $\sigma D/\sqrt T$ variance term.

### Source
FP-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE-2026-04-26

---

## FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE: Cycling lower-bound orbit not attractive under generic zero-momentum init

### Trigger Condition
WHEN problem involves: extending a cycling-based lower bound to standard zero-momentum initialization $x_0 = x_{-1}$
AND proof attempt uses: assuming the cycling orbit is automatically the attractor of zero-momentum SHB on the Goujaud hard instance for all $(\beta, \eta L) \in \mathcal F$
THEN this failure is likely because: attractiveness of a periodic limit cycle depends on the spectral structure of the linearization at the origin vs at the cycle; numerical sweeps show roughly 26/45 of $(\beta, \eta L)$ pairs fall in a DECAY regime where the orbit converges to $x^\star = 0$ and the LB fails.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a claim of LB validity for `all $(\beta, \eta) \in \mathcal F$` under zero-momentum init without an attractiveness check; or absence of an `$\mathcal F_{\mathrm{usable}}$` characterization.

### Recommended Pivot
Instead of a global $\forall (\beta,\eta) \in \mathcal F$ claim, either (a) state the LB with $\forall \exists$ initialization (mathematically correct), or (b) characterize the attractive subset $\mathcal F_{\mathrm{usable}} \subsetneq \mathcal F$ via Lyapunov / eigenvalue analysis of the linearization, then state a weaker version on $\mathcal F_{\mathrm{usable}}$ with zero-momentum init. Numerical heuristic: high $\beta \geq 0.7$ and $\eta L$ near the upper stability boundary tend to give attract regimes; low $\beta$ tends to give decay.

### Source
FP-OP2-CYCLING-INIT-BASIN-DEPENDENCE-2026-04-26

---

## FT-PEP-WITNESS-INEXPLICITNESS: Trying to extract a clean closed-form witness function from a PEP SDP solution

### Trigger Condition
WHEN problem involves: building an explicit lower-bound witness for a fixed-hyperparameter algorithm with non-trivial state (HB, Nesterov with momentum, etc.) using PEP (Drori-Taylor performance estimation problem)
AND proof attempt uses: solving the PEP SDP and trying to read off an explicit polynomial / piecewise-quadratic / named function family that realizes the SDP-tight bound
THEN this failure is likely because: PEP optimizes over the cone of co-coercive gradient sequences and yields an *implicit* worst-case (parameterized by SDP dual variables); the corresponding interpolated function generically has many discontinuous gradient pieces and lacks a clean parametric form.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `read off the worst-case function from PEP`, `extract closed-form witness from SDP dual`, or any plan that treats PEP-tight rate extraction as a one-step task for non-symmetric algorithms.

### Recommended Pivot
Instead of expecting a quick reverse-engineering, treat witness extraction as a separate research project. Existing successful examples are limited (Drori-Teboulle gradient-descent worst-case quadratic). For HB-zero-init and other algorithms with state, no published reverse-engineered witness exists — plan for substantial extra effort, or pivot to a different framework (cycling, information-theoretic, oracle-complexity Le Cam).

### Source
FP-PEP-WITNESS-INEXPLICITNESS-2026-04-26

---

## FT-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING: SHB cycling identity destroyed by Adam's per-coordinate scaling

### Trigger Condition
WHEN problem involves: extending an SHB lower bound (e.g., OP-2's $\Omega(LD^2/T)$ bias) to fixed-hyperparameter Adam / RMSProp
AND proof attempt uses: running Adam on the same Goujaud cycling instance with cycling-init and assuming the cycling identity persists
THEN this failure is likely because: the SHB cycling identity requires (a) the same step on every coordinate and (b) a clean SHB recursion; Adam's $\hat v_t$-denominator scaling violates (a) because cycle gradients have asymmetric per-coord squared magnitudes (up to 27:1 within one $K=3$ cycle), and bias correction at small $t$ produces an unavoidable order-1 sign-SGD transient.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: claims of `Adam inherits the SHB cycling LB`, or rebrands the OP-2 result as `non-acceleration of fixed-hyperparameter momentum methods` (it is fixed-momentum-SHB-specific).

### Recommended Pivot
Instead of inheriting the bias term, scope OP-2's $\Omega(LD^2/T)$ bias LB strictly to fixed-momentum SHB (the bias mechanism is the deterministic algebraic cycling identity tied to SHB's affine-equivariant update). The variance term $\Omega(\sigma D/\sqrt T)$ likely transfers to Adam via decoupled $y$-coordinate Le Cam, but it is a separate theorem with constants depending on $(\beta_1, \beta_2, \epsilon, \eta L)$. Verify numerically: in the deterministic setting Adam achieves $f_0(x_T) \to 0$ on the OP-2 instance, so the bias LB is not just hard to extend — it is genuinely false for Adam.

### Source
FP-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING-2026-04-26

---

## FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM: Naive product Le Cam under $\ell_2$ variance budget collapses to dimension-independent rate

### Trigger Condition
WHEN problem involves: extending a 1-D variance lower bound (e.g., $\Omega(\sigma D/\sqrt T)$) to dimension $d \geq 3$ via $d-2$ independent Le Cam two-point tests on a product instance, under an $\ell_2$-bounded oracle ($\mathbb E\|\xi_t\|^2 \leq \sigma^2$)
AND proof attempt uses: any decoder among direct sum / Fano on $\{\pm 1\}^{d-2}$ / Gilbert-Varshamov packing with per-coord variance budget $\sigma_i = \sigma/\sqrt{d-2}$
THEN this failure is likely because: per-coord signal $\alpha_i \propto \sigma/\sqrt{T(d-2)}$ and Cauchy-Schwarz gives $\sum_i \alpha_i D_i \leq \|\alpha\|_2 \|D\|_2 = \sigma D/(4\sqrt T)$ — the $\sqrt{d-2}$ from extra tests cancels exactly with $1/\sqrt{d-2}$ from per-coord variance dilution under the global $\ell_2$ budget.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `product extension`, `independent Le Cam tests`, `$\sum \sigma_i^2 \leq \sigma^2$` budget split, plus a hoped-for $\sqrt{d-2}$ factor in the final bound.

### Recommended Pivot
Instead of replicating 1-D Le Cam in parallel under an $\ell_2$ budget, either (a) require an $\ell_\infty$-bounded oracle ($\|\xi_t\|_\infty \leq \sigma$, which is strictly more permissive — total variance $d\sigma^2$), or (b) redesign the wall to *couple* all coordinates (the Nemirovski-Yudin / Agarwal 2012 arXiv:1009.0571 $\sqrt{\log d}$ bound uses such coupling — but it is algorithm-agnostic and incompatible with separable wall structure).

### Source
FP-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM-2026-04-26

---

## FT-OP2-NESTEROV-LOOKAHEAD-OFF-VERTEX: Goujaud cycling identity does not transfer to Nesterov because lookahead $y_t$ is not a polytope vertex

### Trigger Condition
WHEN problem involves: porting a Polyak/SHB cycling lower bound to Nesterov with the goal of either inheriting the bound or showing rate separation
AND proof attempt uses: the GTD23 vertex projection identity $P_C(e_t) = M e_t$ at Nesterov's lookahead point $y_t = x_t + \beta(x_t - x_{t-1})$
THEN this failure is likely because: $y_t = \lambda[(1+\beta)e_t - \beta e_{t-1}]$ is NOT a vertex of the rescaled polytope $\widetilde P$ (it lies far outside, e.g., $\|y_0\| = 1.275$ vs vertex norm $\approx 0.49$); the projection identity has no closed form at non-vertex points, and Polyak's cycling closure fails.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: applying GTD23 projection identity at $y_t$ rather than $x_t$; or assuming `Nesterov inherits Polyak's cycling LB on the same instance`.

### Recommended Pivot
Instead of inheritance, accept that cycling LBs via Goujaud are inherently algorithm-specific to gradient queries at polytope vertices. To establish a Polyak-vs-Nesterov rate separation, construct a different cycling instance designed for Nesterov's lookahead structure, OR provide a positive convergence proof for Nesterov on the Polyak-hard instance. Note: "instance-X is hard for Polyak" does NOT imply "instance-X is easy for Nesterov" — Nesterov can have its own non-cycling-but-non-converging behavior (period-2 attractors, fixed points, divergence at high $\beta$).

### Source
FP-OP2-NESTEROV-LOOKAHEAD-OFF-VERTEX-2026-04-26

---

## FT-OP2-I4-SUFFIX-AVG-RESONANCE: Suffix average of length $\geq K$ over a $K$-cycle annihilates by rotational symmetry

### Trigger Condition
WHEN problem involves: extending a cycling lower bound (Goujaud K-gon polytope-Moreau, period $K$ bounded by the cycling inequality) from last iterate to a suffix average $\widehat y_{T,k} = (1/k)\sum_{t=T-k+1}^T x_t$ with $k = \sqrt T$ (or any window comparable to / larger than $K$)
AND proof attempt uses: routes (a) growing $K = K(T)$ with $T$, (b) $K = \sqrt T$ exactly, or (c) continuous orbit on a smooth circle
THEN this failure is likely because: as $K \to \infty$ the GPT cycling inequality fails ($c_K \to 1$, LHS becomes positive); empirically $K_{\max}$ is bounded for every $(\beta,\eta) \in \mathcal F$ (e.g. $K_{\max}(0.5,3/L)=4$, $K_{\max}(0.99,3.9/L)=44$); for fixed $K$, sums over multiples of $K$ vertices vanish (geometric sum of $K$-th roots of unity), so at $T = (jK)^2$ the suffix average is exactly $x^\star$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: suffix-averaged iterate $\widehat y_{T,\sqrt T}$ over a Goujaud cycling instance; or any plan to grow $K$ with $T$ to keep the suffix in a sub-arc.

### Recommended Pivot
Instead of extending cycling LBs to averaged iterates, check the resonance condition $k = \lceil$averaging-horizon$\rceil \in K\mathbb N$ FIRST as an $O(1)$-work go/no-go test. To get a genuine averaging LB, either (i) find a non-cycling, non-Goujaud hard instance (open since 2015+), or (ii) restrict to $k < K$ (i.e. $T < K^2$, finite-$T$ regime, which defeats the asymptotic interpretation). Cesàro and exponential-moving-average extensions all die by the same resonance mechanism.

### Source
FP-OP2-I4-SUFFIX-AVG-RESONANCE-2026-04-26

---

## FT-LEGACY-CD-EUCLIDEAN-NORM: Coordinate descent O(nL̄/ε) lost to Euclidean-vs-weighted-norm conversion factor

### Trigger Condition
WHEN problem involves: coordinate descent on a separable / smooth objective with non-uniform per-coordinate Lipschitz constants $L_i$, target rate $O(n\bar L/\varepsilon)$
AND proof attempt uses: a Euclidean-norm Lyapunov $\|x_0 - x^\star\|^2$ + descent lemma + Cauchy-Schwarz
THEN this failure is likely because: the natural Lyapunov analysis produces the $L$-weighted norm $\|x_0 - x^\star\|_L^2$; converting via $\sum L_i (x_{0,i} - x_i^\star)^2 \leq n\bar L \|x_0 - x^\star\|^2$ introduces an extra factor of $n$, yielding $n^2 \bar L$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a step `$\|\cdot\|_L^2 \leq n\bar L \|\cdot\|^2$` or similar weighted-to-Euclidean rebound, with target rate $n\bar L$ but obtained $n^2 \bar L$.

### Recommended Pivot
Instead of forcing Euclidean norm, either (a) state the rate in the natural $L$-weighted norm, or (b) use importance sampling (sampling coordinate $i$ with probability $L_i / \sum_j L_j$) which removes the conversion factor. Accept that Euclidean-norm results require one of these two routes.

### Source
Coordinate Descent O(nL̄/ε) — Route 1 (legacy, 2026-04-11)

---

## FT-LEGACY-CD-ESTIMATE-SEQUENCE-OVERKILL: Nesterov estimate sequence over-engineering for a problem solvable by direct Lyapunov

### Trigger Condition
WHEN problem involves: a standard convergence-rate proof (e.g., coordinate descent $O(n\bar L/\varepsilon)$) where a direct Lyapunov approach already works
AND proof attempt uses: Nesterov's estimate-sequence framework + separable upper-bound construction
THEN this failure is likely because: estimate sequences are over-complicated for problems without acceleration / interpolation requirements; the Lyapunov route achieves the same rate more directly.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `set up the estimate sequence with parameters $\alpha_k, \lambda_k, \phi_k$` for a proof whose target rate is non-accelerated.

### Recommended Pivot
Instead of estimate sequences, use a direct Lyapunov function (Route 2/4 of the same problem). Reserve estimate sequences for genuinely accelerated methods (Nesterov AGD, accelerated CD).

### Source
Coordinate Descent O(nL̄/ε) — Route 3 (legacy, 2026-04-11)

---

## FT-LEGACY-IMPLICIT-BIAS-AGGREGATE-GRADIENT: Aggregate gradient direction analysis fails to capture per-data-point margin dynamics

### Trigger Condition
WHEN problem involves: implicit bias of GD on logistic / exponential loss converging to the max-margin direction
AND proof attempt uses: aggregate gradient direction analysis (gradient direction at $w_t$ converging implies cumulative iterate direction converges)
THEN this failure is likely because: gradient direction at $w_t$ depends on per-data-point margins which depend on $w_t$, creating circularity; aggregate analysis cannot break this coupling.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a step linking `$\hat g_t \to \hat w$` to `$\hat w_t \to \hat w$` without per-data-point margin tracking; or arguments based solely on inner-product growth comparison.

### Recommended Pivot
Instead of aggregate gradient analysis, track per-data-point margin dynamics individually. The exponential weighting structure of the loss is essential — use the primal KKT analysis (Route 1 of the same problem) which makes this explicit.

### Source
Implicit Bias of GD Max Margin — Route 3 (legacy, 2026-04-12)

---

## FT-LEGACY-IMPLICIT-BIAS-COSINE-LYAPUNOV: Angular cosine potential gives constant lower bound but not convergence

### Trigger Condition
WHEN problem involves: max-margin implicit bias of GD
AND proof attempt uses: Lyapunov $\cos\theta_t = \langle w_t, \hat w\rangle/\|w_t\|$ + norm growth comparison
THEN this failure is likely because: the norm upper bound $\|w_{t+1}\| - \|w_t\| \leq \eta R S_t$ is too loose (ignores alignment improvement); tightening requires analyzing the orthogonal gradient component which itself needs per-data-point margin analysis.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a Lyapunov $\cos\theta_t$ that yields $\cos\theta_T \geq \gamma^\star/R$ (a constant) but cannot upgrade to $\to 1$.

### Recommended Pivot
Instead of cosine potentials, use the primal KKT framework with margin-level analysis. Simple angular Lyapunovs do not capture the loss's exponential weighting structure.

### Source
Implicit Bias of GD Max Margin — Route 4 (legacy, 2026-04-12)

---

## FT-LEGACY-IMPLICIT-BIAS-DUAL-CIRCULAR: Dual implicit bias argument circularly assumes margin growth from primal

### Trigger Condition
WHEN problem involves: max-margin implicit bias
AND proof attempt uses: dual-variable interpretation + implicit regularization path, attempting margin equalization
THEN this failure is likely because: proving $C_i = \alpha_i^\star$ (cumulative gradient contributions equal SVM dual variables) is circular without first establishing margin growth from the primal analysis.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `dual variable $\alpha_i^\star$`, `margin equalization`, but no separate primal proof of margin growth.

### Recommended Pivot
Instead of treating the dual as self-contained, accept that dual is intuition-only and ultimately requires the primal KKT analysis (Route 1).

### Source
Implicit Bias of GD Max Margin — Route 2 (legacy, 2026-04-12)

---

## FT-LEGACY-FENCHEL-SURJECTIVITY: Assuming $\nabla f$ surjective when proving Fenchel smoothness-strong-convexity duality

### Trigger Condition
WHEN problem involves: Fenchel duality between L-smooth convex $f$ and $(1/L)$-strongly-convex $f^\star$
AND proof attempt uses: surjectivity of $\nabla f$ as a step in proving the duality
THEN this failure is likely because: $\nabla f$ is not surjective in general — counterexample $f(x_1, x_2) = (L/2) x_1^2$ has $\nabla f$ ranging over $\{(Lx_1, 0)\}$. The route implicitly assumes strict convexity.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a step `$\nabla f$ is surjective onto $\mathbb R^n$` for general L-smooth convex $f$ without strict-convexity hypothesis.

### Recommended Pivot
Instead of asserting surjectivity, restrict the duality statement to $\text{dom}(f^\star)$, and use cocoercivity of $\nabla f$ (proved from the two-point quadratic upper bound) — this is the standard correct route.

### Source
Fenchel Smoothness-Strong Convexity Duality — Route 1 (legacy, 2026-04-12)

---

## FT-LEGACY-FENCHEL-DOMAIN-RESTRICTION: Domain analysis of $f^\star$ does not close the strong-convexity argument

### Trigger Condition
WHEN problem involves: Fenchel smoothness-strong-convexity duality
AND proof attempt uses: domain restriction + structural analysis of $f^\star$ on $\text{int}(\text{dom}(f^\star))$
THEN this failure is likely because: correctly identifying that $f^\star$ may fail to be differentiable everywhere is necessary but not sufficient — the right tool is cocoercivity of $\nabla f$, not direct domain analysis.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: extensive analysis of $\text{dom}(f^\star)$ structure but no use of cocoercivity.

### Recommended Pivot
Instead of domain analysis, derive cocoercivity of $\nabla f$ from the two-point quadratic upper bound and use it directly — this gives strong convexity of $f^\star$ on the relevant domain.

### Source
Fenchel Smoothness-Strong Convexity Duality — Route 3 (legacy, 2026-04-12)

---

## FT-LEGACY-BERNSTEIN-BENNETT-EYEBALL: Eyeballing the Bennett→Bernstein function inequality

### Trigger Condition
WHEN problem involves: deriving Bernstein's inequality from Bennett's lemma
AND proof attempt uses: the standard reduction $h(u) = (1+u)\log(1+u) - u \geq u^2/(2 + 2u/3)$ via informal/eyeball algebra
THEN this failure is likely because: the elementary bound on Bennett's function requires careful Taylor expansion or convexity argument; informal simplification produces algebraic confusion.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `simplifying $h(u) \geq u^2/(2+2u/3)$` without explicit Taylor or convexity steps.

### Recommended Pivot
Instead of eyeballing, write out a careful Taylor expansion of $h$ around $u=0$ or use convexity of $h$ explicitly. The Bennett→Bernstein step is standard but algebra-dense.

### Source
Bernstein's Inequality — Route 1 (legacy, 2026-04-12)

---

## FT-LEGACY-BERNSTEIN-NOVEL-ROUTE: Searching for an "independent" approach to a classical concentration inequality

### Trigger Condition
WHEN problem involves: a classical concentration inequality (Bernstein, Hoeffding, Bennett, Chernoff)
AND proof attempt uses: a deliberately novel route avoiding MGF / Chernoff
THEN this failure is likely because: for classical concentration the MGF/Chernoff route is essentially unique; novelty searches collapse back to Chernoff or fail.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: phrases like `independent approach`, `novel non-MGF proof`, or attempts to avoid moment-generating functions for classical inequalities.

### Recommended Pivot
Instead of seeking novelty, accept the standard MGF/Chernoff route as essentially canonical for classical inequalities. Do not waste an Explorer on `find a different approach` for this class.

### Source
Bernstein's Inequality — Route 3 (legacy, 2026-04-12)

---

## FT-LEGACY-SAM-PERTURBATION-LYAPUNOV: SAM Lyapunov via perturbation point produces loose constants

### Trigger Condition
WHEN problem involves: SAM (Sharpness-Aware Minimization) convergence, target tight constants
AND proof attempt uses: Lyapunov $f(\tilde x_t)$ where $\tilde x_t = x_t + \rho \nabla f(x_t)/\|\nabla f(x_t)\|$ + crude bound $\|\hat g_{t+1} - \hat g_t\| \leq 2$
THEN this failure is likely because: the crude direction-change bound is loose, leading to constants 10-20x worse than the direct $f^{\mathrm{SAM}}$ descent route.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: Lyapunov on $f(\tilde x_t)$ + bound $\|\hat g_{t+1} - \hat g_t\| \leq 2$.

### Recommended Pivot
Instead of perturbation-point Lyapunov, use direct descent on $f^{\mathrm{SAM}}$ via approximate Danskin (Route 1 of the same problem) — much tighter constants.

### Source
SAM Convergence — Route 2 (legacy, 2026-04-12)

---

## FT-LEGACY-CLIPPED-SGD-NO-PROXY: Heavy-tail clipped SGD without a proxy stationarity measure

### Trigger Condition
WHEN problem involves: clipped SGD convergence under heavy-tailed (e.g., $\alpha$-th moment, $\alpha \in (1,2]$) gradient noise
AND proof attempt uses: standard descent lemma + telescoping on $\|\nabla f\|^2$
THEN this failure is likely because: the clipping bias does not telescope cleanly with $\|\nabla f\|^2$; case analysis (small vs large gradient) and a proxy measure are needed.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: descent lemma + telescoping on $\|\nabla f\|^2$ with no case split, no clipping-region analysis, no proxy measure.

### Recommended Pivot
Instead of standard descent + telescoping, use the proxy stationarity measure $\phi = \min(\|\nabla f\|^2, \tau \|\nabla f\|)$ and case-split between $\|\nabla f\| \leq \tau$ and $\|\nabla f\| > \tau$.

### Source
Gradient Clipping Heavy-Tail — All Routes initial (legacy, 2026-04-04)

---

## FT-LEGACY-NTK-NO-SCHUR-PRODUCT: NTK concentration without invoking the Schur product lemma

### Trigger Condition
WHEN problem involves: NTK / kernel concentration in operator norm $\|K - K^\star\|_{\mathrm{op}}$ for infinite-width networks
AND proof attempt uses: entry-wise analysis, Markov/Chebyshev, or epsilon-net
THEN this failure is likely because: entry-wise gives Frobenius not operator norm, Markov is too loose, and epsilon-nets over-complicate; the key insight is the Schur product lemma $\|M \circ G\|_{\mathrm{op}} \leq \|M\|_{\mathrm{op}}$ which absorbs the Gram structure into Matrix Bernstein.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: entry-wise NTK error bounds without operator-norm conversion; or epsilon-net constructions for NTK concentration.

### Recommended Pivot
Instead of entry-wise / Markov / epsilon-net, apply the Schur product lemma to absorb the Gram matrix structure, then use standard Matrix Bernstein. This gives the clean $O(n/\sqrt m)$ bound.

### Source
NTK Infinite-Width Convergence — Routes 1-3 (legacy, 2026-04-07)

---

## FT-LEGACY-PAC-BAYES-NO-LAMBDA-GRID: PAC-Bayes optimization of $\lambda$ per-Q without a grid union bound

### Trigger Condition
WHEN problem involves: PAC-Bayes generalization bounds, target uniformity over all posteriors $Q$
AND proof attempt uses: Donsker-Varadhan + MGF + optimizing the free parameter $\lambda$ separately for each $Q$
THEN this failure is likely because: per-$Q$ optimization of $\lambda$ does not give a uniform bound; the correct fix is to discretize $\lambda$ on a grid and pay a union bound over grid points.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `optimal $\lambda^\star(Q)$` claimed uniformly, with no grid / union bound on $\lambda$.

### Recommended Pivot
Instead of per-$Q$ $\lambda$, discretize $\lambda \in \{2^k : k = 0, 1, \ldots, K\}$ and union-bound over the grid. This is the standard data-dependent yet uniform PAC-Bayes trick.

### Source
PAC-Bayes Bound — Route 1 (legacy, 2026-04-07)

---

## FT-LEGACY-SGD-PL-PHASE-TRANSITION: Standard SGD analysis fails to capture PL+interpolation two-phase dynamics

### Trigger Condition
WHEN problem involves: SGD on a PL (Polyak-Lojasiewicz) objective with interpolation (multiplicative noise proportional to $f(x) - f^\star$), target $1/t^2$ averaged-iterate rate
AND proof attempt uses: standard SGD descent + averaging, vanilla Lyapunov, or epoch-doubling — treating the trajectory uniformly
THEN this failure is likely because: PL+interpolation has a natural phase transition (early exponential decay when $f - f^\star$ dominates, then $1/t^2$ polynomial when noise dominates); uniform analyses cannot separate the two phases.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a single Lyapunov tracked uniformly across all $t$ for SGD under PL+interpolation; absence of a phase split.

### Recommended Pivot
Instead of uniform analysis, use a direct recursive inequality with polynomial induction on $f(x_t) - f^\star$. The multiplicative noise structure is the key.

### Source
SGD PL+Interpolation Averaging — Routes 1-4 (legacy, 2026-04-08)

---

## FT-LEGACY-STORM-YOUNG-DISCARDS-DESCENT: Young's inequality on the cross-term ⟨∇f, e⟩ throws away the descent's negative ‖d‖² term

### Trigger Condition
WHEN problem involves: STORM (variance-reduced non-convex SGD) Lyapunov analysis, target tight coefficient
AND proof attempt uses: Young's inequality on the cross-term $\langle \nabla f, e\rangle$ when the descent retains a $-\|d\|^2$ term
THEN this failure is likely because: Young's discards the negative $\|d\|^2$ from descent; expanding then re-using Young's loses the structure, giving $c = 8L_1^2$ (2x larger than needed).

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `Young's inequality on $\langle \nabla f, d\rangle$` together with a descent step retaining $-\|d\|^2$.

### Recommended Pivot
Instead of Young's, use the polarization identity $\langle \nabla f, d\rangle = \tfrac12(\|\nabla f\|^2 + \|d\|^2 - \|\nabla f - d\|^2)$ to keep the negative $\|d\|^2$ from descent.

### Source
STORM Non-Convex Convergence — Route 1 (legacy, 2026-04-16)

---

## FT-LEGACY-STORM-TWO-STAGE-CIRCULAR: Sum-then-combine variance recursion creates circular gradient-coefficient absorption

### Trigger Condition
WHEN problem involves: STORM Lyapunov, separating variance summation from descent combination
AND proof attempt uses: two-stage approach — sum variance recursion $S_e$ first, then combine with descent via coefficient absorption requiring $\mu/4 < 1$
THEN this failure is likely because: the two-stage approach creates a circular $G$ dependency, forcing $c = 16 L_1^2$ and messy constants.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `sum $S_e = \sum_t E_t$ first, then combine with descent`, leading to a coefficient absorption inequality.

### Recommended Pivot
Instead of sum-then-combine, use a *joint* Lyapunov approach (combine descent and variance in a single potential) — cleaner for coupled variance-descent systems.

### Source
STORM Non-Convex Convergence — Route 2 (legacy, 2026-04-16)

---

## FT-LEGACY-STORM-LUMP-L-L1: Lumping $L$ (smoothness) and $L_1$ (mean-squared smoothness) into a single constant inflates STORM coefficients

### Trigger Condition
WHEN problem involves: STORM-type variance-reduced estimators that involve both standard smoothness $L$ and mean-squared smoothness $L_1$
AND proof attempt uses: a unified constant like $\tilde L^2 = 4(L_1^2 + L^2)$ in the Lyapunov framework
THEN this failure is likely because: $L$ and $L_1$ play different structural roles; lumping is over-conservative, yielding $c = 20\tilde L^2$ and a gradient coefficient only $\eta/40$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a definition like `$\tilde L^2 := L^2 + L_1^2$` used uniformly.

### Recommended Pivot
Instead of lumping, keep $L_1$ (mean-squared smoothness) separate from $L$ (smoothness) throughout the analysis. Each plays a distinct role in the variance vs descent terms.

### Source
STORM Non-Convex Convergence — Route 3 (legacy, 2026-04-16)

---

## FT-LEGACY-SHB-LB-QUADRATIC-CHEBYSHEV: Quadratic instances cannot witness a non-acceleration LB against fixed-momentum HB

### Trigger Condition
WHEN problem involves: lower bound $\Omega(LD^2/T)$ for fixed-momentum SHB on smooth convex objectives
AND proof attempt uses: a quadratic worst-case (e.g., Nesterov tridiagonal zero-chain) as the hard instance
THEN this failure is likely because: Polyak 1964 shows HB with optimal fixed $\beta$ achieves $O(LD^2/T^2)$ on *any* quadratic via Chebyshev acceleration; quadratics are too easy. Empirical: $(\beta=0.5, \eta=1/L)$ gives $\mathrm{gap}\cdot T^2 = O(1)$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a quadratic hard instance + claim of $\Omega(LD^2/T)$ against fixed-momentum HB.

### Recommended Pivot
Instead of quadratics, choose an instance with $\nabla^2 f(x^\star) = 0$ globally in a neighborhood, non-quadratic, and not too easy for plain GD. Note: no such explicit smooth convex function is currently known in the literature — see FT-OP2-* for current obstructions.

### Source
SHB Bias-Term LB Ω(LD²/T) — Route C Arjevani+Nesterov (legacy, 2026-04-17)

---

## FT-LEGACY-SHB-LB-LOCAL-CHEBYSHEV: "Flat at the origin" smooth potential admits local Chebyshev acceleration

### Trigger Condition
WHEN problem involves: lower bound for fixed-momentum SHB, target hard instance with $\nabla^2 f(x^\star) = 0$ at the optimum
AND proof attempt uses: a smooth convex potential like hyperbola / log-cosh $\widetilde\Phi_D(u) = LD^2(\sqrt{1 + (u/D)^2} - 1)$ where the Hessian vanishes only at the single point $x^\star$
THEN this failure is likely because: $\widetilde\Phi''(0) = L > 0$ (locally strongly convex near $x^\star$); once iterates enter the curvature region, Polyak's local Chebyshev acceleration kicks in and SHB converges at $O(1/T^2)$, reaching machine zero by $T = 100$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: smooth convex potential with $\nabla^2 f$ vanishing only at one point; numerical SHB on the instance reaching machine precision quickly.

### Recommended Pivot
Instead of point-flat instances, require $\nabla^2 f(x) = 0$ on a *neighborhood* of $x^\star$, not just at one point. Second-order Taylor expansion at $x^\star$ reveals local strong convexity for any single-point-flat instance.

### Source
SHB Bias-Term LB Ω(LD²/T) — Route A hyperbola (legacy, 2026-04-17)

---

## FT-LEGACY-SHB-LB-GOUJAUD-MU-TO-ZERO: Goujaud cycling at $\mu \to 0$ has quantifier-order gap and plain-GD annihilation

### Trigger Condition
WHEN problem involves: convex lower bound for fixed-momentum SHB
AND proof attempt uses: Goujaud-Taylor-Dieuleveut 2023 cycling construction $\psi = (L/2)\|x\|^2 - ((L-\mu)/2) d(x, \mathrm{conv}(P))^2$ taken to $\mu = 0$
THEN this failure is likely because: (i) Goujaud proves $\forall (\beta, \gamma) \exists f_{\beta,\gamma}$ but the target needs $\exists f \forall (\beta,\gamma)$ — the operator $M$ depends on $(\beta,\gamma)$; (ii) plain GD with $\eta = 1/L$ annihilates the function in one step in the interior-of-conv(P) regime ($f(x_{100}) = 2.6 \times 10^{-131}$).

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: Goujaud cycling construction reused at $\mu = 0$ with a quantifier order that swaps $\forall (\beta,\gamma)$ and $\exists f$.

### Recommended Pivot
Instead of $\mu \to 0$ cycling, accept that cycling constructions from the strongly-convex setting do not pass to convex in a quantifier-stable way. A uniform-over-$\beta$ hard instance requires a fundamentally different idea. Alternatives: weaken to $\forall \beta \exists f_\beta$ (then Goujaud + $\mu \to 0$ works), or restrict to fixed step size $\eta$ and use PEP/IQC, or exploit stochastic-oracle non-determinism (heavy-tailed $\sigma^2$).

### Source
SHB Bias-Term LB Ω(LD²/T) — Goujaud cycling at μ→0 (legacy, 2026-04-17)

---

## FT-LEGACY-SHB-LB-META-NO-MAN-LAND: No known smooth convex function lies in the SHB-LB no-man's-land

### Trigger Condition
WHEN problem involves: convex $\Omega(LD^2/T)$ LB for fixed-momentum SHB requiring an instance that simultaneously is non-quadratic, has $\nabla^2 f(x^\star) = 0$ in a neighborhood, and is not annihilated by plain GD
AND proof attempt uses: any explicit smooth convex function from the existing literature
THEN this failure is likely because: no such explicit function is currently known.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a search for "non-quadratic, locally-flat, non-trivially-hard-for-GD" instances without acknowledging the gap in the literature.

### Recommended Pivot
Instead of seeking the missing instance, switch alternative direction: (a) weaken to $\forall \beta \exists f_\beta$ via Goujaud + $\mu \to 0$; (b) restrict to fixed step $\eta_t \equiv \eta$ (LTI low-frequency response, PEP/IQC tractable); (c) use stochastic oracle with heavy-tailed variance to block Chebyshev cancellation.

### Source
SHB Bias-Term LB — Meta-failure (legacy, 2026-04-17)

---

## FT-LEGACY-BLLT-NO-GORDON: Min-norm interpolator bias bound without Gordon-Slepian comparison

### Trigger Condition
WHEN problem involves: benign overfitting (Bartlett-Long-Lugosi-Tsigler 2020) min-norm interpolator excess risk in anisotropic $\Sigma$, target the bias half $\|\beta^\star\|_\Sigma^2 \cdot \max\{\sqrt{r_0/n}, r_0/n, \sqrt{\log n / n}\}$
AND proof attempt uses: Matrix Bernstein, whitening + Hanson-Wright, Weyl + Woodbury, or leave-one-out / Sherman-Morrison
THEN this failure is likely because: BLLT 2020 Lemma 11 requires Gordon-Slepian Gaussian comparison; the obstacle is that $\xi = G\widetilde\beta^\star$ is *coupled* with $A = G\Lambda G^\top$, so Hanson-Wright cannot be applied directly and operator-norm bounds give only $B^2$ (losing $\sqrt{r_0/n}$).

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: Matrix Bernstein / Hanson-Wright / Weyl / LOO attempt that produces the variance half $\sigma^2(k^\star/n + n/R_{k^\star}(\Sigma))$ but cannot reach the bias half's $\sqrt{r_0/n}$ factor.

### Recommended Pivot
Instead of concentration-only routes, either (a) introduce Gordon's theorem as a black-box lemma into the library and apply BLLT Lemma 11 directly, (b) weaken to isotropic $\Sigma = I$, or (c) prove only the variance half as a stand-alone theorem. Note: in $p \geq n$ regime, Route 4 (LOO leverage scores) is dimensionally ill-posed.

### Source
Benign Overfitting BLLT 2020 — Meta-failure (legacy, 2026-04-17)

---

## FT-LEGACY-SOFTMAX-PG-RELABELED-PDL: PDL+mean-value "novel" route for softmax PG is algebraically equivalent to NU-Lojasiewicz

### Trigger Condition
WHEN problem involves: softmax policy gradient $O(1/t)$ convergence, target a route avoiding the NU-Lojasiewicz inequality
AND proof attempt uses: Performance Difference Lemma + mean-value theorem, claiming independence from NU-Lojasiewicz
THEN this failure is likely because: the Cauchy-Schwarz computation in the PDL+MVT approach is algebraically equivalent to NU-Lojasiewicz; the sign-nonnegativity sub-lemma is the same Mei-Lemma-9 dependency Route 1 has.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: claim of `independent route avoiding NU-Lojasiewicz` for softmax PG that still ends up deferring to Mei-Lemma-9 for sign nonnegativity.

### Recommended Pivot
Instead of relabeled routes, check algebraic equivalence before declaring novelty. For softmax PG $O(1/t)$, accept that NU-Lojasiewicz is the essential ingredient.

### Source
Softmax PG O(1/t) — Route 2 (legacy, 2026-04-18)

---

## FT-LEGACY-SOFTMAX-PG-KL-POTENTIAL: KL divergence Lyapunov is for NPG, not vanilla PG

### Trigger Condition
WHEN problem involves: vanilla softmax policy gradient convergence
AND proof attempt uses: KL divergence potential $\Psi_t = \mathrm{KL}(\pi^\star \| \pi_t)$ + Pinsker-style lower bound
THEN this failure is likely because: (a) advantages $A^\pi(s, a^\star(s))$ can be negative pointwise, breaking the potential-decrease inequality; (b) Pinsker bounds KL from below by $\mathrm{TV}^2$, NOT above by value gap; (c) vanilla PG lacks Fisher-information preconditioning that NPG has.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: KL Lyapunov $\mathrm{KL}(\pi^\star \| \pi_t)$ on vanilla (non-natural) PG.

### Recommended Pivot
Instead of distance-based KL Lyapunov, use a gradient-norm-based Lojasiewicz inequality (NU-Lojasiewicz). Reserve KL Lyapunov for NPG where Fisher preconditioning closes the loop.

### Source
Softmax PG O(1/t) — Route 3 (legacy, 2026-04-18)

---

## FT-LEGACY-SOFTMAX-PG-MD-NPG-COMPARISON: One-step Fisher-spectral comparison does not transfer NPG rate to PG

### Trigger Condition
WHEN problem involves: softmax PG convergence, attempting to transfer NPG's rate to vanilla PG
AND proof attempt uses: Fisher-information spectral lower bound $\|\nabla V\|^2 \geq \lambda_{\min}^+(F) \|w^{\mathrm{NPG}}\|_F^2$ + NPG rate transfer
THEN this failure is likely because: Fisher-spectral comparison bounds gradient norm in terms of NPG direction AT THE SAME ITERATE, but PG and NPG trajectories diverge over time; Route 4 ends up re-deriving NU-Lojasiewicz.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `compare $\nabla V$ and NPG direction at iterate $\theta_t$` followed by claim of rate transfer.

### Recommended Pivot
Instead of one-step spectral comparison, accept that two algorithms sharing one-step geometry do not share asymptotic rates unless trajectories coincide. Use NU-Lojasiewicz directly for vanilla PG.

### Source
Softmax PG O(1/t) — Route 4 (legacy, 2026-04-18)

---

## FT-LEGACY-SOFTMAX-PG-CONST-RENAME: Restating a bound via constant renaming without symbolic algebra check

### Trigger Condition
WHEN problem involves: matching a derived bound to `problem.md`'s target form via constant renaming (e.g., $c'_\infty := c_\infty \cdot \rho_{\min} \cdot \sqrt{1-\gamma}$)
AND proof attempt uses: handwave absorption of factors into a renamed constant
THEN this failure is likely because: the renamed form's algebra rarely matches; here $(c'_\infty)^2 (1-\gamma)^6 = c_\infty^2 \rho_{\min}^2 (1-\gamma)^7$ but the honest bound has $(1-\gamma)^5$ — off by $(1-\gamma)^2$.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `define $c' := c \cdot$ stuff` followed by claim of bound `$\leq c'^2 \cdot$ target-power-of-$(1-\gamma)$` without SymPy verification.

### Recommended Pivot
Instead of renamed-constant form, prefer honest restatement (Option A) of the actual derived bound. If the renamed form is required, verify algebraic equivalence symbolically (SymPy) before submitting.

### Source
Softmax PG O(1/t) — Route 1 Fix Round 1 (legacy, 2026-04-18)

---

## FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING: Lyapunov reorganization for adaptive stepsize doesn't bring new analytical power

### Trigger Condition
WHEN problem involves: AdaGrad-Norm $O(\log T/\sqrt T)$ convergence with $\mathcal F_k$-measurable stepsize $\eta/b_k$
AND proof attempt uses: Lyapunov potential $V_k = W_k + (L\eta^2/2) \sum_{i<k}\|g_i\|^2/b_i^2$ to seek a one-step descent inequality
THEN this failure is likely because: the cross-term $\langle \nabla f, \xi\rangle$ already has zero conditional expectation (because $\eta/b_k$ is $\mathcal F_k$-measurable), so Lyapunov reorganization is just re-bookkeeping — it still requires the decoupling identity + log accumulator from Route 1.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: a Lyapunov $V_k$ for AdaGrad-Norm whose drift requires the same `decoupling identity + log accumulator` step as the direct route.

### Recommended Pivot
Instead of Lyapunov recasting, use the direct decoupling identity + $\sum 1/b_k = O(\log T)$ accumulator (Route 1). Lyapunov here is cosmetic.

### Source
AdaGrad-Norm O(log T/√T) — Route 3 (legacy, 2026-04-18)

---

## FT-LEGACY-ADAGRAD-OCO-NON-CONVEX: Online-to-batch reduction requires convexity (or PL); fails non-convex

### Trigger Condition
WHEN problem involves: non-convex $f$, AdaGrad-Norm convergence
AND proof attempt uses: AdaGrad regret bound + online-to-batch reduction
THEN this failure is likely because: in non-convex $f$, the inequality $f(x_k) - f(u) \leq \langle \nabla f(x_k), x_k - u\rangle$ fails (counterexample $f = -Lx^2/2$); the descent-step comparator $u_k = x_k - (\eta/b_k)\nabla f(x_k)$ varies with $k$, breaking single-comparator telescoping.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `AdaGrad regret + online-to-batch` for non-convex $f$.

### Recommended Pivot
Instead of OCO reduction, use direct descent lemma in the non-convex setting. The regret framework is at most a side-result (the AdaGrad-norm regret bound) — archive separately.

### Source
AdaGrad-Norm O(log T/√T) — Route 4 (legacy, 2026-04-18)

---

## FT-LEGACY-XR-PAC-BAYES-JOINT-VS-PER-HYPOTHESIS: PAC-Bayes reduction for Xu-Raginsky needs per-hypothesis sub-Gaussianity

### Trigger Condition
WHEN problem involves: Xu-Raginsky mutual information generalization bound under joint sub-Gaussianity hypothesis (only $P_W \otimes \mathcal D$ is sub-Gaussian)
AND proof attempt uses: McAllester / Catoni PAC-Bayes + the identity $I(W;S) = \mathbb E_S[\mathrm{KL}(P_{W|S} \| P_W)]$
THEN this failure is likely because: PAC-Bayes joint MGF bound requires per-hypothesis conditional MGF bound (`for fixed $W$, $\ell(W,Z)$ sub-Gaussian in $Z$`), strictly stronger than joint sub-Gaussianity.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: PAC-Bayes reduction applied under only joint sub-Gaussianity assumption.

### Recommended Pivot
Instead of PAC-Bayes, retreat to Donsker-Varadhan per-sample — at this point Route C degenerates back into Route A/D, which is the genuine route.

### Source
Xu-Raginsky MI Bound — Route C (legacy, 2026-04-18)

---

## FT-LEGACY-ADMM-DR-EQUIVALENCE-MISSING-B: Dual Douglas-Rachford equivalence misses the primal $B$-weighted residual

### Trigger Condition
WHEN problem involves: ADMM ergodic $O(1/T)$ rate (He-Yuan 2012) for arbitrary test point (not necessarily feasible)
AND proof attempt uses: ADMM-as-DR-on-dual equivalence (Gabay 1983) and applying DR's ergodic $O(1/T)$
THEN this failure is likely because: DR's natural metric on the dual is Euclidean ($\beta^{-1} I$), insensitive to the primal $B$-weighted residual; for infeasible test points, $H$-Lyapunov absorption leaves $-(\beta/T)\langle B(z^T - z^0), \tilde r\rangle$ + indexing-shift junk.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: ADMM-DR equivalence + telescoping for infeasible test point, with leftover $B$-residual cross terms.

### Recommended Pivot
Instead of dual DR, use the primal VI route (Route 3): the residual $-\tfrac12 \|v^{k+1} - v^k\|_H^2$ kills the indexing-shift term directly. The dual route only captures the $\lambda$ part natively.

### Source
ADMM ergodic O(1/T) (He-Yuan 2012) — Route 2 (legacy, 2026-04-18)

---

## FT-LEGACY-ADMM-PROX-ABSTRACTION-NO-GAIN: Proximal-point abstraction layer adds nothing for a single ADMM problem

### Trigger Condition
WHEN problem involves: ADMM ergodic $O(1/T)$, target a `clean abstract framework`
AND proof attempt uses: viewing ADMM as a proximal-point step in $H$-semi-norm and invoking abstract ergodic PP
THEN this failure is likely because: $H$ is only PSD (not PD), so the standard PP ergodic theorem must be reproved; once reproved, the abstract proof reduces to Route 3's `telescope + Jensen + skew-affine` — no new insight, just an extra abstraction layer.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `view ADMM as PP in $H$-semi-norm` plus invocation of an abstract PP ergodic theorem.

### Recommended Pivot
Instead of abstraction, use the direct primal VI route (Route 3). Abstract PP is only worth doing if the library has 3+ PSD-semi-norm PP applications.

### Source
ADMM ergodic O(1/T) (He-Yuan 2012) — Route 4 (legacy, 2026-04-18)

---

## FT-LEGACY-ADMM-FEASIBILITY-IMPLICIT-IN-TEMPLATE: ADMM ergodic bound silently requires feasibility

### Trigger Condition
WHEN problem involves: ADMM ergodic $O(1/T)$ rate claimed for arbitrary test point
AND proof attempt uses: a single Route based on a mature VI template
THEN this failure is likely because: the bound implicitly requires feasibility $A\widetilde x + B\widetilde z = c$; mature templates hide this assumption, and a single-route proof can miss it. Multi-route parallel exploration (4 independent Explorers) revealed the constraint convergently.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: ADMM ergodic bound for arbitrary $(\widetilde x, \widetilde z, \widetilde\lambda)$ with no feasibility hypothesis.

### Recommended Pivot
Instead of single-route reliance, run 4 parallel Explorers and check for consistency. Add the feasibility hypothesis explicitly. Multi-route convergence is a powerful problem-statement validation tool.

### Source
Problem 3 meta-lesson — ADMM 4-Explorer convergence (legacy, 2026-04-18)

---

## FT-LEGACY-Q-LEARNING-AZUMA-BEFORE-INDUCTION: "Concentration before pathwise analysis" costs an extra √H in RL

### Trigger Condition
WHEN problem involves: Q-learning regret (Jin-Allen-Zhu-Bubeck-Jordan 2018), target $\sqrt{H^3 SAT}$
AND proof attempt uses: building a global Azuma-Hoeffding high-probability event $\mathcal E$ first, then doing pathwise Optimism induction + regret decomposition on $\mathcal E$
THEN this failure is likely because: pathwise decomposition $\delta_h^k \leq \phi_h^k + \delta_{h+1}^k + \eta_h^k$ requires explicit $\sum_h$ expansion missing the visit-count exchange identity (L4) — gives an extra $\sqrt H$ vs the JABJ-optimal interleaved analysis.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: clean separation `first build event $\mathcal E$, then do pathwise analysis on $\mathcal E$`.

### Recommended Pivot
Instead of clean concentration-then-analysis separation, interleave Azuma concentration with the recursive Q-error expansion (Lemma A) so each layer's bonus eats the corresponding noise via the $(1+1/H)$ visit-count exchange. Ugly but tight.

### Source
UCB-Hoeffding Q-learning regret (JABJ 2018) — Route B (legacy, 2026-04-18)

---

## FT-LEGACY-Q-LEARNING-ADVANTAGE-RELABEL: Advantage decomposition for Q-learning is just a renamed value-difference identity

### Trigger Condition
WHEN problem involves: Q-learning regret, attempting a `new` route via advantage decomposition $\delta_h^k = \phi_h^k + A_h^{\pi_k,\star}$
AND proof attempt uses: optimism to kill $A \geq 0$, then Bellman expansion of $A$
THEN this failure is likely because: after Bellman expansion, $\delta_h^k \leq \phi_h^k + \delta_{h+1}^k + \zeta_h^k$ is identical to Route A's value-difference identity. The visit-count exchange that wins the rate happens inside the inner $\phi_h^k$ recursion, unaffected by outer renaming.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: advantage-based outer decomposition that ends up as $\phi_h^k + \delta_{h+1}^k + \zeta_h^k$ (identical to value-difference).

### Recommended Pivot
Instead of advantage relabeling, locate the rate-determining step (here: visit-count exchange in $\phi_h^k$ recursion) and check whether the new framing actually changes that inner step. If not, the route is a relabel.

### Source
UCB-Hoeffding Q-learning regret (JABJ 2018) — Route C (legacy, 2026-04-18)

---

## FT-LEGACY-Q-LEARNING-OCO-NONCONVEX: Online-to-batch / expert reduction fails for RL with horizon $H \geq 2$

### Trigger Condition
WHEN problem involves: Q-learning regret with horizon $H \geq 2$
AND proof attempt uses: online-to-batch via per-cell OGD, adversarial $V_{h+1}$, global Bellman-error OCO, or expert advice
THEN this failure is likely because: Bellman equation $V_{h+1}(s) = \min\{H, \max_a Q_{h+1}(s,a)\}$ has a nested $\max$ that makes any global OCO loss non-convex; online-to-batch requires convexity. Bandit ($H=1$) works, but $H \geq 2$ immediately fails.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: `view Q-learning as OCO`, `expert reduction`, `Bellman residual as OCO loss` for $H \geq 2$.

### Recommended Pivot
Instead of OCO reduction for full RL, accept that horizon structure cannot be reduced to bandit + OCO. Use the JABJ-style interleaved Azuma + backward induction directly. (Same obstacle as AdaGrad-Norm Route 4 in non-convex setting.)

### Source
UCB-Hoeffding Q-learning regret (JABJ 2018) — Route D (legacy, 2026-04-18)

---

## FT-LEGACY-Q-LEARNING-BONUS-SCALE-WRONG: Q-learning bonus scale in problem.md too small

### Trigger Condition
WHEN problem involves: Q-learning regret $\sqrt{H^4 SAT}$ (or similar)
AND proof attempt uses: any route that respects the stated bonus scale $b_t = c H \sqrt{\iota / t}$
THEN this failure is likely because: stated scale is too small; JABJ 2018 actually requires $c H^{3/2} \sqrt{\iota / t}$. Multi-route Explorers (B, C) independently flagged this gap.

### Detection Signal
The Explorer is probably hitting this pattern if the draft contains: target rate $\sqrt{H^4 SAT}$ + bonus $b_t \propto H \sqrt{\iota/t}$ (linear in $H$).

### Recommended Pivot
Instead of accepting the stated bonus, fix the scale to $c H^{3/2} \sqrt{\iota / t}$ before continuing. Use multi-Explorer convergence as a problem-statement validation tool.

### Source
Problem 4 meta-lesson — Q-learning bonus scale (legacy, 2026-04-18)

---

## Skipped Entries

- **FP-N (template)**: schema-only, not a real failure entry.
- (No legacy entries were too vague to extract a useful trigger; all 30+ entries produced an actionable trigger block.)

---

## Index by Category

| FT-id | category | one-line trigger summary |
|---|---|---|
| FT-18-AUDITOR-MISSES-UB-LB-CONTRADICTION | hypothesis-too-weak | Auditor doesn't check proven UB against stated LB. |
| FT-KAUFFMAN-CONVENTION | technique-mismatch | Wrong q/t convention substitution in Jones→Kauffman derivation. |
| FT-SPIRAL-BLOCK-CIRCULANT-BASIS | scope-mismatch | Tree basis breaks cyclic symmetry on Seifert surface. |
| FT-SPIRAL-SKEIN-LEAVES-FAMILY | scope-mismatch | Skein resolution lands outside the periodic knot family. |
| FT-SPIRAL-PRINCIPAL-MINOR-MISFRAMING | scope-mismatch | Principal-minor of full Burau ≠ intrinsic image in smaller braid group. |
| FT-SPIRAL-PARAMSWAP-MIXED-CASE-LEVEL1-GAP | hypothesis-too-weak | Mixed-ε spiral parameter swap blocked by missing level-1 lemmas. |
| FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE | averaging-collapse | Goujaud cycling vertex sum vanishes → averaged iterate hits optimum. |
| FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE | hypothesis-too-weak | Cycling orbit not attractive under generic zero-momentum init. |
| FT-PEP-WITNESS-INEXPLICITNESS | technique-mismatch | PEP yields implicit SDP witnesses, no clean closed-form function. |
| FT-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING | scope-mismatch | Adam's per-coord scaling kills SHB cycling identity. |
| FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM | averaging-collapse | Product Le Cam under ℓ₂ budget collapses dim factor by Cauchy-Schwarz. |
| FT-OP2-NESTEROV-LOOKAHEAD-OFF-VERTEX | scope-mismatch | Nesterov lookahead $y_t$ not a polytope vertex; cycling identity fails. |
| FT-OP2-I4-SUFFIX-AVG-RESONANCE | averaging-collapse | Suffix average of length $\geq K$ over $K$-cycle annihilates by symmetry. |
| FT-LEGACY-CD-EUCLIDEAN-NORM | norm-mismatch | Weighted-norm to Euclidean conversion loses factor $n$. |
| FT-LEGACY-CD-ESTIMATE-SEQUENCE-OVERKILL | technique-mismatch | Estimate sequences over-engineered for non-accelerated CD. |
| FT-LEGACY-IMPLICIT-BIAS-AGGREGATE-GRADIENT | induction-circularity | Aggregate gradient direction is circular without per-data-point margins. |
| FT-LEGACY-IMPLICIT-BIAS-COSINE-LYAPUNOV | technique-mismatch | Cosine potential gives constant lower bound but not convergence. |
| FT-LEGACY-IMPLICIT-BIAS-DUAL-CIRCULAR | induction-circularity | Dual margin equalization circularly assumes primal margin growth. |
| FT-LEGACY-FENCHEL-SURJECTIVITY | hypothesis-too-weak | Assumes $\nabla f$ surjective for general L-smooth convex $f$. |
| FT-LEGACY-FENCHEL-DOMAIN-RESTRICTION | technique-mismatch | Domain analysis cannot replace cocoercivity in Fenchel duality. |
| FT-LEGACY-BERNSTEIN-BENNETT-EYEBALL | constant-blowup | Eyeballing Bennett→Bernstein function inequality. |
| FT-LEGACY-BERNSTEIN-NOVEL-ROUTE | technique-mismatch | Searching for non-MGF route to classical concentration. |
| FT-LEGACY-SAM-PERTURBATION-LYAPUNOV | constant-blowup | SAM perturbation-point Lyapunov gives 10-20x worse constants. |
| FT-LEGACY-CLIPPED-SGD-NO-PROXY | technique-mismatch | Heavy-tail clipped SGD without proxy stationarity measure. |
| FT-LEGACY-NTK-NO-SCHUR-PRODUCT | technique-mismatch | NTK concentration without Schur product lemma. |
| FT-LEGACY-PAC-BAYES-NO-LAMBDA-GRID | hypothesis-too-weak | PAC-Bayes per-Q λ optimization without grid union bound. |
| FT-LEGACY-SGD-PL-PHASE-TRANSITION | technique-mismatch | Uniform SGD analysis misses PL+interpolation phase transition. |
| FT-LEGACY-STORM-YOUNG-DISCARDS-DESCENT | constant-blowup | Young's inequality discards STORM descent's negative ‖d‖² term. |
| FT-LEGACY-STORM-TWO-STAGE-CIRCULAR | induction-circularity | Sum-then-combine STORM creates circular gradient absorption. |
| FT-LEGACY-STORM-LUMP-L-L1 | constant-blowup | Lumping L and L₁ inflates STORM coefficient. |
| FT-LEGACY-SHB-LB-QUADRATIC-CHEBYSHEV | scope-mismatch | Quadratic worst-case too easy for fixed-momentum HB (Chebyshev). |
| FT-LEGACY-SHB-LB-LOCAL-CHEBYSHEV | scope-mismatch | Single-point-flat smooth potential admits local Chebyshev acceleration. |
| FT-LEGACY-SHB-LB-GOUJAUD-MU-TO-ZERO | scope-mismatch | Goujaud cycling at μ→0 has quantifier-order gap and plain-GD annihilation. |
| FT-LEGACY-SHB-LB-META-NO-MAN-LAND | scope-mismatch | No known smooth convex function in SHB-LB no-man's-land. |
| FT-LEGACY-BLLT-NO-GORDON | technique-mismatch | Min-norm interpolator bias bound needs Gordon-Slepian, not Bernstein. |
| FT-LEGACY-SOFTMAX-PG-RELABELED-PDL | technique-mismatch | PDL+MVT route algebraically equivalent to NU-Lojasiewicz. |
| FT-LEGACY-SOFTMAX-PG-KL-POTENTIAL | technique-mismatch | KL Lyapunov is for NPG, not vanilla PG. |
| FT-LEGACY-SOFTMAX-PG-MD-NPG-COMPARISON | scope-mismatch | One-step Fisher comparison doesn't transfer NPG rate to PG. |
| FT-LEGACY-SOFTMAX-PG-CONST-RENAME | constant-blowup | Restating bound via constant rename without algebra check. |
| FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING | technique-mismatch | Lyapunov recast for adaptive stepsize gains nothing. |
| FT-LEGACY-ADAGRAD-OCO-NON-CONVEX | scope-mismatch | Online-to-batch fails non-convex (no convexity). |
| FT-LEGACY-XR-PAC-BAYES-JOINT-VS-PER-HYPOTHESIS | hypothesis-too-weak | Joint sub-Gaussianity insufficient for PAC-Bayes per-hypothesis MGF. |
| FT-LEGACY-ADMM-DR-EQUIVALENCE-MISSING-B | norm-mismatch | Dual DR's Euclidean metric misses primal $B$-weighted residual. |
| FT-LEGACY-ADMM-PROX-ABSTRACTION-NO-GAIN | technique-mismatch | PP abstraction layer adds nothing for a single ADMM problem. |
| FT-LEGACY-ADMM-FEASIBILITY-IMPLICIT-IN-TEMPLATE | hypothesis-too-weak | ADMM ergodic bound implicitly needs feasibility, hidden in template. |
| FT-LEGACY-Q-LEARNING-AZUMA-BEFORE-INDUCTION | technique-mismatch | "Concentration before pathwise" costs extra √H in RL. |
| FT-LEGACY-Q-LEARNING-ADVANTAGE-RELABEL | technique-mismatch | Advantage outer framing is identical to value-difference identity. |
| FT-LEGACY-Q-LEARNING-OCO-NONCONVEX | scope-mismatch | RL with $H \geq 2$ has non-convex Bellman, OCO fails. |
| FT-LEGACY-Q-LEARNING-BONUS-SCALE-WRONG | hypothesis-too-weak | Q-learning bonus scale stated too small. |
