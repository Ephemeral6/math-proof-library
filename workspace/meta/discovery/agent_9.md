# Discovery Report — Agent 9
**Scope:** Stability (5 proofs) + High-Dimensional Statistics (2 proofs)

---

## Proof 1: SGD Uniform Stability and Generalization (Hardt-Recht-Singer 2016)

### Spark
**failure-of-natural-approach** — Classical uniform-convergence (VC / Rademacher) bounds say nothing about *which* algorithm produced the model, yet practitioners observed that SGD generalizes far better than its hypothesis class would predict.

### Key Insight
Bound the *parameter distance* between two SGD trajectories on neighboring datasets by tracking it step-by-step under shared randomness, then convert parameter stability to loss stability via Lipschitzness. The non-obvious leap is the **coupling**: refuse to let randomness work against you by sharing the index sequence between the two SGD runs, so that on `(1-1/n)` of steps the two iterates are processed by the *same* gradient operator. Co-coercivity (Baillon-Haddad) then makes that operator *non-expansive* in `w` exactly when `α ≤ 2/β`. Prior knowledge: convex analysis (co-coercivity), Bousquet-Elisseeff stability framework.

### Technique Chain
- **Algorithmic stability framework** — Bousquet-Elisseeff 2002, standard.
- **Coupling under shared sample sequence** — non-standard at the time; HRS's key device.
- **Co-coercivity / Baillon-Haddad** — classical convex analysis, novel use here.
- **Telescoping + linearity of expectation** — standard.

### Failure Modes
- **Uniform convergence on the full hypothesis class:** vacuous in overparametrized regimes — SGD's implicit bias is invisible.
- **Independent coupling (different index sequences):** loses non-expansiveness; the recursion cannot close.
- **Gradient-norm Lyapunov instead of distance-Lyapunov:** captures optimization but not *between-trajectory* drift.

### Discovery Path
1. Note empirical generalization mystery for SGD beyond VC theory.
2. Try Bousquet-Elisseeff for ERM — works only for strongly convex problems with closed-form minimizer; doesn't capture *runtime* effect.
3. Insight: stability is about *trajectories*, not minimizers — track `‖w_t − w_t'‖` step by step.
4. Engineer a coupling so `(n-1)/n` of steps are non-expansive (co-coercivity); the bad `1/n` events accumulate linearly.
5. Convert to `ε_stab ≤ 2L²·αT/n` via Lipschitz; verify with experiments.

### Transferable Patterns
- **Couple-and-track pattern:** when comparing two stochastic procedures, share noise to expose contractivity. Reused in MCMC mixing, SGD privacy, federated learning.
- **Operator-theoretic Lyapunov:** "this map is non-expansive" is a powerful surrogate for descent lemmas in randomized analyses.

---

## Proof 2: Differential Privacy Implies Generalization

### Spark
**analogy-from-other-field** — Differential privacy's `(ε,δ)` guarantee on neighboring datasets *is structurally identical* to the algorithmic-stability requirement, suggesting DP should buy generalization for free.

### Key Insight
The hockey-stick decomposition `dμ = min(dμ, eᵉdν) + (dμ − eᵉdν)₊` cleanly splits a DP guarantee into a "bounded-likelihood-ratio" piece (controlled by `eᵉ`) and a "rare-event leakage" piece (controlled by `δ`). With this decomposition, one can apply DP to *expectations of bounded test functions*, not just events. Then leave-one-out symmetrization (already classical from Bousquet-Elisseeff) immediately converts this to a generalization bound. This is essentially a translation theorem; the creativity is recognizing the analogy and finding the right divergence.

### Technique Chain
- **Hockey-stick divergence decomposition** — DP literature (Dwork-Roth, Kairouz et al.), standard.
- **Post-processing on expectations** — generalization of standard DP post-processing from events to bounded functions.
- **Bousquet-Elisseeff leave-one-out symmetrization** — borrowed wholesale from stability literature.

### Failure Modes
- **Apply DP only to indicator events:** gives no direct loss bound, must be lifted via union over thresholds (loose).
- **Use `e^ε ≈ 1+ε` linearization too early:** loses the `δ` term and obscures the additive structure.

### Discovery Path
1. Observe: DP's neighboring-dataset language matches stability's neighboring-dataset language.
2. Try direct: `|E[f(A(S))] − E[f(A(S'))]| ≤ ε` — almost works, but `δ` doesn't fit.
3. Use hockey-stick: split the measure into a bounded-ratio part and a small-mass part.
4. Combine with the existing Bousquet-Elisseeff template — proof writes itself.
5. Observe: bound `(eᵉ − 1) + δ ≤ 2ε + δ` for `ε ≤ 1`, matching Dwork-Feldman-Pitassi-Reingold-Roth-Vadhan style.

### Transferable Patterns
- **Divergence-based stability:** any algorithm whose output distribution is close in some divergence (TV, KL, Rényi, hockey-stick) on neighboring datasets generalizes — the technique is divergence-agnostic.

---

## Proof 3: SGD Signal-Noise Generalization Decomposition (Zhang et al. ICLR 2022 spirit)

### Spark
**gap-in-literature** — HRS gives `O(L²ηT/n)` using a single uniform Lipschitz constant `L`, but in practice the *stochastic-noise* part of `∇ℓ` is what really controls generalization; the deterministic part `∇L_S` is "free." Can the bound be split?

### Key Insight
Inside the leave-one-out coupling, decompose the *gradient itself* as `∇ℓ = ∇L_S + ∇L_N` (signal + zero-mean noise). On the swap step, the signal part is annihilated by the same non-expansiveness HRS used (`I − η∇L_S` is non-expansive); only the noise part `η(∇L_N − ∇L_N')` perturbs the trajectory. This converts an `L²` bound into a `(G_S² + σ_N²)` bound where `σ_N²` is variance, not max — a strict improvement when `σ_N ≪ L`. The non-obvious move is *applying the signal-noise split inside the per-step recursion*, not just at the outcome.

### Technique Chain
- **HRS coupling** — re-used as scaffold.
- **Doob-style decomposition of gradient** — `∇L_N` is mean-zero, enabling variance bounds instead of supremum bounds.
- **Quadratic recursion `Δ_{t+1} = Δ_t + a√Δ_t + b`** — solved by power-law ansatz + induction.
- **Cauchy-Schwarz on cross term** in the squared distance recursion.

### Failure Modes
- **Apply HRS directly with `L = G_S + σ_N`:** loses the noise-vs-signal asymmetry; gives `(G_S+σ_N)²` not `G_S² + σ_N²`.
- **PAC-Bayes from scratch:** harder to set up the data-dependent prior; the proof correctly notes *strict tightness* is unattainable via stability alone.

### Discovery Path
1. Compare HRS bound to empirical SGD gap in noise-dominated regimes — HRS is loose by a factor.
2. Hypothesis: only noise (not signal) drives stability divergence.
3. Try splitting `∇ℓ` post hoc: doesn't help at the outcome level.
4. Push the split *into* the per-step recursion `δ_{t+1} = δ_t − η(S_t + N_t)`; signal contributes via non-expansiveness, noise via variance.
5. Solve the resulting `Δ_{t+1} ≤ Δ_t + (1/m)(4ησ√Δ_t + 4η²σ²)` recursion by induction with ansatz `Δ_t ≤ c·t/m + c·t²/m²`.

### Transferable Patterns
- **Push the decomposition inside the recursion:** any time a quantity is decomposed at the *outcome* level, ask whether the same split applied *per-step* yields tighter rates.

---

## Proof 4: Adversarial Trajectory Tradeoff (Internal Conjecture 7.10)

### Spark
**question-asked** — Given the signal-noise decomposition (proof 3), can one quantify the tradeoff between adversarial robustness and generalization, and show the *optimal early-stopping time shrinks* under adversarial training?

### Key Insight
The mixed Hessian `H = sup ‖∇_θ∇_x L‖_op` is the bridge between *parameter motion* (which the trajectory framework controls via `‖θ_T − θ_0‖ ≤ G√(Tη)`) and *data-gradient growth* (which controls adversarial loss inflation `r·‖∇_x L‖`). Composition gives an adversarial penalty linear in `r·H·√(Tη)` — strictly increasing in `T`. Adding any strictly-increasing penalty to a U-shaped clean-loss curve shifts the argmin strictly left (argmin-shift lemma). This is *qualitatively rigorous* but the literal formula `T* / (1 + r²H²η)` turns out to be a structural shape, not an exact identity (the natural parametrization gives `(β/(β+crH))^{2/3}`).

### Construction
The Penalty function is *forced* by Cauchy-Schwarz on first-order Taylor (`r·‖∇_x L‖`) plus a Lipschitz transfer of `‖∇_x L‖` along the trajectory using the mixed Hessian. The square-root `√(Tη)` is inherited from canonical SGD trajectory length — anything weaker fails to track the data-gradient drift; anything stronger over-pays.

### Failure Modes
- **Try to force the literal `1/(1+r²H²η)` form:** intrinsic obstruction — natural exponent is `2/3`, not `1`. Only honest "structural shape" claim survives.
- **Bound adversarial loss by Lipschitz at fixed θ:** misses the trajectory-length dependence — the whole point of the result is that *training longer* makes the model more sensitive.

### Discovery Path
1. Observe: adversarial training requires earlier stopping.
2. Try: bound `R_adv − R_clean` at fixed θ — gets `r·G + ½M_x r²`, no T-dependence.
3. Insight: data-gradient norm grows during training; Lipschitz-transfer it along the trajectory using the mixed Hessian.
4. Combine with U-shaped clean loss + argmin-shift lemma to get strict `T*_adv < T*_clean`.
5. Try to match literal formula `1/(1+r²H²η)` — fails; honest "structural shape" verdict.

### Transferable Patterns
- **Argmin-shift lemma:** any time a strictly-increasing penalty is added to a U-shaped curve, optimal stopping/regularization moves strictly inward. Useful template for *implicit regularization* arguments.
- **Mixed-Hessian as bridge** between parameter-space and data-space Lipschitz analyses.

---

## Proof 5: Heavy-Tailed Trajectory Decomposition (Internal Conjecture 7.6)

### Spark
**gap-in-literature** — All stability bounds (HRS, signal-noise) assume sub-Gaussian gradients. What if only `p`-th moments exist (`1 < p < 2`), as in heavy-tailed deep-learning gradients?

### Key Insight
Three pieces compose: (i) raise the HRS distance recursion to the `p`-th power using `(a+b)^p ≤ 2^{p-1}(a^p+b^p)`; (ii) replace classical BDG (variance-based) by **Marcinkiewicz-Zygmund / one-sided Burkholder for `p ∈ (1,2)`**, which gives `E‖Σ N_t‖^p ≤ C_p Σ E‖N_t‖^p` — sub-additivity rather than `√T` aggregation; (iii) pay for the heavy tail with **gradient clipping** at `τ = G·T^{1/p − 1/2}`, balancing truncation bias `G^p/τ^{p-1}` against truncated variance `G^p τ^{2-p}`. The non-obvious leap is recognizing that the negative exponent `T^{(p-2)/2}` from MZ is exactly what allows the rate `G·T^{1−1/p}/√m` to match the minimax lower bound.

### Technique Chain
- **HRS coupling at the `p`-th moment level** — non-standard; the convexity-based non-expansive lemma still works for `‖·‖`, raised to `p`.
- **Marcinkiewicz-Zygmund for `p ∈ (1,2)`** — classical probability (Burkholder), reused in heavy-tailed mean estimation (Brownlees-Joly-Lugosi 2015).
- **Truncation bias-variance balance** — standard in trimmed-mean / median-of-means.
- **Polyak-Ruppert averaging** — contracts noise by extra `1/√T`, modifying the optimal `τ`.

### Failure Modes
- **Sub-Gaussian BDG/Doob:** infinite under heavy-tail assumptions — the variance is the gateway and it doesn't exist.
- **Skip clipping:** the noise contribution is unbounded; no rate.
- **Unclipped `τ = G·T^{1/p}`:** correct for last-iterate but misses the `√T` improvement available from Polyak-Ruppert averaging.

### Discovery Path
1. Question: extend HRS/signal-noise to heavy-tailed gradients.
2. Naive attempt: try variance-based BDG — fails (variance infinite).
3. Search the heavy-tailed concentration literature; find Marcinkiewicz-Zygmund gives `E‖S_n‖^p ≤ C_p Σ E‖X_i‖^p` for `p ∈ (1,2)`.
4. Plug into HRS recursion raised to `p`-th power; signal/noise split survives.
5. Add clipping; balance bias vs variance via calculus; verify the rate matches Wang-Mao 2021.

### Transferable Patterns
- **Moment-level coupling:** lift any `L²` recursion to `L^p` by `(a+b)^p ≤ 2^{p-1}(a^p+b^p)` — works whenever the underlying contractivity is at the norm level, not the squared-norm level.
- **MZ as a heavy-tail BDG substitute:** universal trick in heavy-tailed stochastic analysis.

---

## Proof 6: Double Descent — Interpolation Threshold (Belkin-Hsu-Ma-Mandal 2019)

### Spark
**pattern-spotted** — Empirically, neural networks (and even ridgeless linear models) showed test error *peaking* at `n ≈ p` and then *descending again* into the overparametrized regime — directly contradicting the classical U-shaped bias-variance curve.

### Key Insight
The peak at `γ = d/n = 1` is *not* a model-complexity phenomenon; it is a **conditioning catastrophe** of the empirical Gram matrix. At `γ = 1`, the smallest singular value of `Z^T Z/d` collapses (Marchenko-Pastur edge `(1-√γ)² → 0`), and the pseudo-inverse `(X^T X)^+` blows up via `tr((Z^T Z)^{-1}) = d/(n-d-1)`. Variance diverges from *both* sides because the Wishart inverse-trace formula `1/(n-d-1)` (under) and `1/(d-n-1)` (over) both have a pole at `n = d`. Once you accept this, the proof is "just" inverse-Wishart moment computation plus Haar invariance for the bias.

### Technique Chain
- **Bias-variance decomposition with `X^+`** — standard.
- **Inverse Wishart first moment** `E[(Z^T Z)^{-1}] = I/(n-d-1)` — classical (Anderson, Multivariate Statistical Analysis); needs `n > d+1`.
- **Haar invariance of Gaussian random matrices** — for `E[I − P_X] = (d-n)/d · I`, exploiting orthogonal-invariance.
- **Marchenko-Pastur asymptotics** — physical interpretation of the singular-value collapse at `γ = 1`.

### Failure Modes
- **Concentration of measure / VC bounds:** completely silent on this regime — the function class is identical above and below the threshold.
- **Heuristic "more parameters → more overfitting":** predicts monotone curve; misses the second descent entirely.
- **Forget the `1/n` correction in `n − d − 1`:** misses the divergence as `d → n`.

### Discovery Path
1. Observe Belkin et al.'s empirical double-descent curves (2018-2019).
2. Try classical Rademacher/VC analysis — vacuous, no `γ`-dependence.
3. Insight: in the linear-regression toy model, switch to *direct moment computation* — `‖β̂ − β*‖²` has a closed form via `X^+`.
4. Apply inverse-Wishart formulas; observe the explicit pole at `n = d` from *both* sides.
5. Use Haar invariance to evaluate `E[I − P_X]` for the overparametrized bias term.

### Transferable Patterns
- **"Closed-form-and-pray" on toy linear models** to diagnose phenomena that escape uniform-convergence bounds — same template later used for benign overfitting (Bartlett-Long-Lugosi-Tsigler), implicit bias of GD, etc.
- **Haar invariance + trace-of-projection** is the universal one-line argument for `E[I − P_X]`.

---

## Proof 7: LASSO Restricted-Eigenvalue Prediction Error (Bickel-Ritov-Tsybakov 2009)

### Spark
**gap-in-literature** — Naive `ℓ_1`-penalized regression in `p ≫ n` regime *should* be ill-posed, yet LASSO predicts and recovers sparse signals successfully. What property of `X` is actually doing the work?

### Key Insight
The **cone constraint**: on the high-probability event `‖X^T w‖_∞/n ≤ λ/2`, the LASSO error `Δ̂` lives in `C(S, 3) = {Δ : ‖Δ_{S^c}‖_1 ≤ 3‖Δ_S‖_1}`, i.e., the off-support `ℓ_1` mass is controlled by the on-support mass. This means `X` only needs *Restricted Eigenvalue* — `‖XΔ‖² ≥ κ‖Δ‖²` for `Δ ∈ C(S,3)` — not full eigenvalue lower bound (impossible in `p > n`). The two pieces (cone derivation + RE on the cone) are honestly classical "heavy calculation" — the conceptual leap is *naming* the cone as the right restricted geometry. Prior knowledge: Hölder's inequality, sub-Gaussian tail bounds, basic convex optimality.

### Construction
The `λ ≥ 2σ√(2log p / n)` choice is forced by union-bounding the per-coordinate Gaussian tail of `(X^T w)_j/n` over `p` columns (with the well-known constant-factor headache the proof openly grapples with). The "3" in `C(S, 3)` traces to the algebra `λ‖β*‖_1 − λ‖β̂‖_1 ≤ λ‖Δ_S‖_1 − λ‖Δ_{S^c}‖_1` plus the Hölder bound `(λ/2)‖Δ‖_1`, giving `(3λ/2)‖Δ_S‖_1 − (λ/2)‖Δ_{S^c}‖_1`.

### Failure Modes
- **Demand full RE on all of `R^p`:** vacuous when `p > n` — `X^T X` has nullspace.
- **Apply Hölder without splitting `S` and `S^c`:** loses the cone structure; cannot apply RE.
- **Forget column normalization `‖X_j‖_2² ≤ n`:** the `λ` calibration breaks.

### Discovery Path
1. Note empirical success of LASSO in `p ≫ n` with sparse ground truth.
2. Try standard least-squares analysis — fails because `X^T X` not invertible.
3. Write KKT/optimality basic inequality `‖y − X β̂‖² + 2nλ‖β̂‖_1 ≤ ‖y − X β*‖² + 2nλ‖β*‖_1`; expand.
4. Insight: the regularizer difference *automatically* generates a cone constraint on the error — `X` doesn't need to be invertible everywhere, only on this cone.
5. Define RE condition matched to the cone; combine with sub-Gaussian tail for `‖X^T w‖_∞`.

### Transferable Patterns
- **Restricted-geometry conditions:** instead of demanding nice geometry everywhere, identify the *constraint cone* the algorithm's error inhabits (LASSO → `C(S, 3)`; group LASSO → group cone; nuclear-norm → low-rank tangent cone). Universal template across modern high-dim statistics (Negahban-Ravikumar-Wainwright-Yu 2012 unified framework).
- **`λ` calibration via dual-norm sub-Gaussian maximal inequality** — also universal.

---

## Cross-cutting observation

The five stability proofs are a single technical phylogeny radiating from one 2016 invention: **Hardt-Recht-Singer's couple-and-track-distance template**. HRS itself supplies the chassis (proof 1). Proof 3 pushes the gradient decomposition *inside* the per-step recursion to convert an `L²` bound to a variance bound. Proofs 4 and 5 show the chassis can absorb entirely new ingredients — a mixed-Hessian *bridge* to data-space (adversarial), and `L^p` lifting + Marcinkiewicz-Zygmund (heavy-tailed) — without changing the underlying `(n−1)/n` non-expansive vs `1/n` shock decomposition. Proof 2 (DP→generalization) reveals the chassis is even *abstractly* portable: stability is a statement about divergence between output distributions on neighboring inputs, and the leave-one-out symmetrization is divergence-agnostic. The Bickel-Ritov-Tsybakov LASSO and Belkin-Hsu-Ma-Mandal double-descent proofs sit outside this lineage and exhibit a different aesthetic: BRT discovered the *cone constraint* is generated for free by `ℓ_1`-regularization, while BHMM showed that closed-form Wishart calculus is enough to expose phenomena that uniform-convergence theory cannot see — both are exemplars of the "name the right restricted geometry, then compute" school.
