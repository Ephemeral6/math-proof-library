# Discovery Report — Agent 1 (Optimization/Convergence Part 1)

Seven research-level proofs analyzed. Below: reverse-engineered discovery paths for each.

---

## Proof 1: NPG Softmax Tabular Convergence

### 1. The Spark
**analogy-from-other-field.** Researchers noticed that softmax-NPG iterates look exactly like exponentiated gradient / mirror descent updates from online convex optimization, suggesting that decades-old regret bounds should transfer to RL.

### 2. The Key Insight
The non-obvious leap is the *cancellation* in Step 4e: the per-state improvement bound from Hoeffding/Donsker–Varadhan produces a `+KL(π_{k+1}||π_k)` term that exactly cancels the `−KL(π_{k+1}||π_k)` term from the mirror-descent three-point identity. This requires recognizing that the same KL-to-current-iterate object appears with opposite signs from two completely different inequalities (one a deterministic identity, the other a variational concentration bound). Prior knowledge needed: Bregman three-point identity, log-partition variational principle, and Hoeffding's lemma. Brute force cannot find this — the cancellation is only visible once you write both bounds in the same units.

### 3. The Technique Chain
- **Performance Difference Lemma** — standard policy-gradient tool (Kakade & Langford 2002).
- **NPG = exponentiated update** — standard since Kakade 2001; reinterpreted here as KL-mirror-descent.
- **Bregman / KL three-point identity** — standard from convex analysis, lifted to per-state form.
- **Donsker–Varadhan variational formula** — non-standard import from large deviations / information theory; used to express log-partition as KL-regularized maximization.
- **Hoeffding's lemma** — textbook concentration; applied to the (mean-zero, bounded-range) advantage random variable.
- **Telescoping + monotone improvement** — standard; combined to convert average-iterate to last-iterate.

### 4. The Construction
No hard-instance construction; this is an upper-bound proof.

### 5. The Failure Modes
- A textbook student would treat NPG as gradient descent on a non-convex objective `V(θ)` and try smoothness/Polyak–Łojasiewicz arguments — fails because `V(θ)` has flat saddles for softmax and no global PL constant.
- They might try direct potential `‖θ_k − θ*‖²` — fails because optimal `θ*` can be at infinity for softmax.

### 6. The Discovery Path
1. Observe NPG-softmax update is equivalent to exponentiated gradient on the simplex per state.
2. First attempt: directly apply standard mirror-descent regret O(√K) — gives O(1/√K), not O(1/K).
3. Key insight: the "non-cancelled" `KL(π_{k+1}||π_k)` term in the mirror-descent identity can be matched and absorbed by a Donsker–Varadhan / Hoeffding bound on the per-state improvement.
4. Execute: split advantage into C+G terms, apply both inequalities, watch the KL terms cancel, telescope, use monotonicity.
5. Polish: state-distribution mismatch handled via comparator distribution `d^{π*}_ρ` so the `Σ d=1` lets the bias term be dimension-free.

### 7. Transferable Patterns
- **"Two-bound cancellation"** template: when one bound (identity) gives `−φ` and another (concentration) gives `+φ`, the pair yields a clean telescoping inequality. This recurs in mirror-descent + log-Sobolev arguments and in primal-dual analysis.
- **Average-to-last-iterate via monotonicity** is broadly applicable whenever the algorithm has a monotone improvement guarantee.

---

## Proof 2: Entropy-Regularized Value Iteration

### 1. The Spark
**pattern-spotted.** The log-sum-exp operator looks like a smooth max, and softmax policies are its gradient — suggesting the entropy-regularized Bellman operator might inherit contraction from the standard one almost for free.

### 2. The Key Insight
The non-obvious leap is recognizing that LSE is *exactly* 1-Lipschitz in `ℓ∞` (not just smooth-max) and that the `1/τ` scaling inside, paired with `τ` outside, makes the contraction factor exactly `γ` — independent of `τ`. This means entropy regularization preserves the contraction modulus completely. Prior knowledge needed: Banach fixed-point theorem, LSE's variational form (Donsker–Varadhan flavor), and the fact that LSE is the convex conjugate of negative entropy.

### 3. The Technique Chain
- **LSE 1-Lipschitz in `ℓ∞`** — standard, proven by direct exponential-bound argument.
- **Banach fixed-point theorem** — textbook.
- **Variational form of LSE** = max over simplex with entropy regularization — standard from convex duality / Fenchel.
- **Sandwich `T_τ V` between `TV` and `TV + τ log A`** — the only "research" step, by direct LSE bounds.
- **Monotonicity + sub/super-fixed-point** argument for approximation error — standard from monotone-operator theory.

### 4. The Construction
No construction; the result is structural.

### 5. The Failure Modes
- A student would try to bound `‖V_τ* − V*‖` via "perturbing the Bellman fixed point" using implicit-function-theorem style arguments — fails because the standard `T` is non-smooth (max).
- They might try Hilbert metric / span seminorm contractions — works but obscures the clean `τ log A / (1−γ)` constant.

### 6. The Discovery Path
1. Observe softmax policy is Gibbs distribution; entropy-regularized value should be smooth max.
2. First attempt: bound LSE − max ≤ log A pointwise, push through fixed-point iteration directly — works for one step, but transferring to fixed point is unclear.
3. Key insight: use monotonicity of `T_τ` with the constant-shifted vector `W = V* + (τ log A/(1−γ))·1` as a super-fixed-point.
4. Execute: contraction (i), Banach (ii), Gibbs optimality from LSE variational formula (iii), sandwich + monotonicity (iv).
5. Polish: confirm both `V_τ* ≥ V*` and `V_τ* ≤ V* + τ log A/(1−γ)` directions.

### 7. Transferable Patterns
- **Smooth-max regularization preserves contraction modulus** — applies broadly: minimax with entropy, soft-Q-learning, MaxEnt RL.
- **Sub/super-fixed-point sandwich** is a standard but underused tool whenever you have a monotone operator and want to compare two fixed points.

---

## Proof 3: SGD Last-Iterate Averaged Baseline

### 1. The Spark
**pattern-spotted / question-asked.** Why does the textbook SGD bound always carry a `log T` factor — is it intrinsic, or an artifact of the decreasing step-size schedule?

### 2. The Key Insight
Switching from decreasing `η_t = c/√t` (which gives `Σ η_t² = O(log T)`) to **constant** `η = D/(G√T)` makes `Σ η_t² = T·η² = D²/G² = O(1)`, eliminating the log. The discovery is essentially algebraic: the `log T` is purely an artifact of the harmonic sum, not anything about SGD itself. The proof is otherwise standard. Almost no prior knowledge is needed beyond the textbook descent lemma + Jensen + martingale zero-mean argument.

### 3. The Technique Chain
- **Projection non-expansiveness** — textbook.
- **Subgradient inequality + convexity** — textbook.
- **Martingale decomposition `g_t = s_t + ξ_t`** — standard.
- **Telescoping potential `δ_t² = (x_t − x*)²`** — textbook.
- **Jensen's inequality for averaged iterate** — textbook.
- **Constant step size choice `η = D/(G√T)`** — the only "trick", chosen by balancing the two terms.

### 4. The Construction
No construction.

### 5. The Failure Modes
- Textbook student uses `η_t = D/(G√t)` and gets `O(DG log T / √T)`. They accept the log factor as "the price you pay".
- Trying to prove last-iterate `E[f(x_T) − f*] = O(1/√T)` (instead of averaged) fails — see the three barriers section: no contraction without strong convexity, no concentration of x_T around x̄_T, slow Markov mixing.

### 6. The Discovery Path
1. Read textbook proof, notice `log T` traces to `Σ 1/t`.
2. First attempt: try to tighten the harmonic bound — `Σ 1/t ≥ ln T` is tight, dead end.
3. Key insight: use **constant** step size depending on horizon `T`. This requires knowing T in advance but eliminates the harmonic sum entirely.
4. Execute: standard telescoping with the new step size; the two terms balance exactly.
5. Polish: include the "three barriers" discussion explaining why this trick doesn't work for last-iterate without strong convexity.

### 7. Transferable Patterns
- **"Constant horizon-aware step size" trick** — recurs in any analysis where decreasing step gives an extra log factor; works whenever T is known.
- **Decompose `g_t = grad + martingale`, telescope second moment** is the canonical SGD analysis template.

This proof is borderline textbook material; the "discovery" is more pedagogical clarification than a research result.

---

## Proof 4: Heavy Ball Instability

### 1. The Spark
**failure-of-natural-approach.** Polyak's 1964 Heavy Ball method achieves the optimal rate on quadratics, so for decades it was assumed the same parameters would work on smooth strongly convex functions — until someone tried a hand-crafted non-quadratic and saw cycling.

### 2. The Key Insight
The non-obvious leap is constructing `f(x) = (L/2)x² − (L−μ) ln cosh(x)`, whose Hessian is `L − (L−μ) sech²(x)`: it is **exactly μ at the origin** and **exactly L at infinity**, with smooth interpolation. This forces Heavy Ball (tuned for global condition number κ = L/μ) to overshoot the low-curvature center, get whipped back by high curvature, and enter a stable period-4 limit cycle. The construction requires knowing (a) momentum is a "bullet" carrying kinetic energy, (b) constant-curvature analyses miss the resonance, and (c) ln cosh is the canonical smooth function with exactly two curvature regimes.

### 3. The Technique Chain
- **Decoupling diagonal quadratics + state-space formulation** — standard from linear-systems analysis (Polyak 1964).
- **Characteristic polynomial of 2×2 companion matrix** — textbook.
- **Discriminant = 0 → Jordan block** — standard linear algebra; gives the `k·σ^k` factor explaining "near-tight" convergence.
- **Construction `(L/2)x² − (L−μ) ln cosh(x)`** — non-standard; the `ln cosh` trick comes from logistic regression / soft-bound literature.
- **Computational verification of period-4 cycle and Jacobian eigenvalues** — non-standard; uses numerical bifurcation analysis to confirm cycle attractivity.

### 4. The Construction
The form `(L/2)x² − (L−μ) ln cosh(ax)` is essentially forced: you need `f''(0) = μ, f''(∞) = L`, smooth, strongly convex, simple closed form. Quadratic-plus-log-cosh is the unique "soft step" function with these properties (and `tanh(0) = 0` automatically places the minimizer at 0). Simplifying to a piecewise-quadratic would lose `C^∞` and obscure the resonance. Reducing the curvature ratio below ≈76.5 destroys the cycle (Remark 3).

### 5. The Failure Modes
- Textbook student assumes Heavy Ball generalizes from quadratics; tries to prove convergence via the same eigenvalue argument and gets stuck because the linearization changes with `x`.
- They try Lyapunov function `V_k = a‖x_k − x*‖² + b‖x_k − x_{k−1}‖²` — no such quadratic Lyapunov exists for Heavy Ball on general smooth strongly convex (Lessard–Recht–Packard 2016 IQC analysis).

### 6. The Discovery Path
1. Question: does Heavy Ball converge on all smooth strongly convex `f`?
2. First attempt: try to extend Polyak's quadratic analysis via local linearization — fails because momentum couples successive linearizations.
3. Key insight: deliberately design `f` with a curvature *transition* — if `f''(0) ≠ f''(∞)`, momentum tuned to the wrong regime will misbehave. Pick `ln cosh` for smoothness.
4. Execute: prove regularity (cosh > 0 everywhere → C^∞), strong convexity/smoothness (`sech² ∈ (0,1]`), then numerically locate the period-4 orbit and verify its Jacobian eigenvalues lie inside unit disk.
5. Polish: contrast with Nesterov, which uses a "lookahead" point and adapts to local curvature.

### 7. Transferable Patterns
- **"Curvature-transition counterexample"** template: any algorithm with a fixed parameter tuned to a single condition number can be broken by a function whose local condition number varies.
- **`ln cosh` (or quadratic + smooth step)** is the canonical building block for constructing C^∞ counterexamples with prescribed global vs local curvature.
- **Period-N limit-cycle construction + linearized Jacobian < 1** is a transferable proof template for "non-convergence to a fixed point".

---

## Proof 5: SAM Convergence to Flat Minima

### 1. The Spark
**gap-in-literature.** SAM (Foret et al. 2021) was empirically successful but had no clean non-convex convergence rate; existing bounds either required strong convexity or didn't match the SAM objective `f^SAM(x) = max_{‖δ‖≤ρ} f(x+δ)`.

### 2. The Key Insight
The non-obvious leap is realizing that the SAM update uses the *normalized* gradient `ρ ∇f(x)/‖∇f(x)‖` as an *approximation* to the true maximizer `δ*(x) = arg max f(x+δ)`, and that this approximation error is bounded by `2ρ` in `‖δ‖`. By `L`-smoothness this translates to `‖g_t − ∇f^SAM(x_t)‖ ≤ 2Lρ`, giving a quantifiable bias. Prior knowledge needed: Danskin's theorem to define `∇f^SAM`, the descent lemma, and Young's inequality. The cleverness is choosing `η = 1/(2L)` and `ρ ≤ 1/(2L)` so the bias terms exactly absorb into the `O(1/T) + O(L²ρ²)` two-term structure.

### 3. The Technique Chain
- **Descent lemma from L-smoothness** — textbook.
- **Danskin's theorem** for `∇f^SAM` — standard from minimax / robust optimization.
- **Young's inequality** to handle inner product `⟨∇f, g⟩` — textbook.
- **Two-step gradient approximation `‖g_t − ∇f^SAM‖ ≤ 2Lρ`** — the SAM-specific step.
- **Telescoping summation** — textbook.
- **Diminishing radius `ρ = ρ_0/√T`** to get exact O(1/T) — standard variance-decay trick.

### 4. The Construction
No construction.

### 5. The Failure Modes
- Textbook student treats SAM as GD on `f^SAM` and tries to apply standard non-convex GD theory directly — fails because `∇f^SAM(x)` is not what SAM uses; it uses `∇f(x + ρ·∇f(x)/‖∇f(x)‖)`, a different vector.
- They might try to bound `f^SAM` − `f^SAM(x*)` directly via convexity — fails because we're in non-convex land.

### 6. The Discovery Path
1. Observe SAM update is "GD with perturbed gradient at an `O(ρ)`-shifted point".
2. First attempt: assume `g_t ≈ ∇f(x_t)` and apply standard non-convex GD analysis — gives no relation to flat minima / SAM objective.
3. Key insight: the shifted point `x_t + ρ ∇f(x_t)/‖∇f(x_t)‖` is `O(ρ)` away from the true `δ*(x_t)`, so by L-smoothness `g_t` is `O(Lρ)` away from `∇f^SAM(x_t)`. Use Danskin to connect.
4. Execute: descent lemma → Young → `‖g_t − ∇f^SAM‖ ≤ 2Lρ` → triangle inequality → telescoping.
5. Polish: tune `η = 1/(2L)` to make `1 − Lη = 1/2`, and split bound into optimization term + bias term.

### 7. Transferable Patterns
- **"Approximate gradient + Young's"** template: whenever an algorithm uses an approximation to a target gradient with bounded error `ε`, one gets `O(L/T) + O(ε²)` two-term bound.
- **Danskin + descent lemma** combination is the canonical recipe for proving convergence on minimax-defined objectives.
- **Diminishing perturbation radius `ρ_0/√T`** is a transferable trick to recover exact rates from biased methods.

---

## Proof 6: Lookahead Optimizer Convergence

### 1. The Spark
**question-asked.** The Lookahead optimizer (Zhang et al. 2019) empirically reduces variance, but is the variance reduction provably `α²k` (interpolation-squared times step-splitting), and what is the deterministic rate?

### 2. The Key Insight
The non-obvious leap is recognizing that on quadratics the *whole* outer iteration is `M = (1−α)I + α(I−ηA)^k` — a polynomial in the symmetric matrix `A`, which is itself symmetric and diagonalizes with `A`. This collapses the analysis to one scalar function `m(λ) = 1 − α(1 − (1−ηλ)^k)`, whose spectral radius is attained at the smallest eigenvalue. The variance argument is even cleaner: the noise in the outer step is a sum of `k` shrunk noises, with prefactor `α`, giving `α² · k · η²σ²d` — and the comparison to "equivalent single step" `α k η` reveals factor-`k` variance reduction.

### 3. The Technique Chain
- **Diagonalize quadratic, derive scalar contraction** — textbook spectral analysis.
- **Polynomial-in-matrix evaluates eigenvalue-wise** — textbook linear algebra.
- **Unroll noise through inner loop, sum independent variances** — standard SGD analysis.
- **Equivalent single-step comparison** — non-standard reframing; explicitly compares to single-step method with effective step `α k η`.

### 4. The Construction
No construction.

### 5. The Failure Modes
- Textbook student tries to analyze Lookahead via Lyapunov functions for non-convex SGD — fails because Lookahead's structure is hidden inside the inner loop.
- They might try to compute `M^t` directly without diagonalization — works on 1D but not in `d` dimensions cleanly.

### 6. The Discovery Path
1. Observe outer Lookahead step on quadratic = polynomial in `(I − ηA)`.
2. First attempt: bound `‖M‖` via operator norm submultiplicativity — gives loose bound.
3. Key insight: `M` is symmetric (polynomial in symmetric `A`), so spectral radius = operator norm exactly. Reduce to scalar `m(λ)`.
4. Execute: minimize `m(λ)` over `[μ, L]`, find max at `λ = μ`, get `ρ = 1 − α(1 − (1−ημ)^k)`. For variance, unroll `k` noise terms, sum, compare to single-step.
5. Polish: identify the two sources of variance reduction (interpolation `α²` and step-splitting `1/k`).

### 7. Transferable Patterns
- **Polynomial-in-symmetric-matrix collapses to scalar analysis** — transferable to any optimizer with structural commutativity (Polyak averaging, Nesterov, momentum on quadratics).
- **"Equivalent single step" comparison** is a useful framing for any inner-loop method (Lookahead, FedAvg local steps, SAGA inner loops).

This is an elegant but largely linear-algebraic / textbook-flavored proof; the "discovery" is the clean factor decomposition `α² × 1/k`.

---

## Proof 7: Synchronous Q-Learning Finite-Time

### 1. The Spark
**gap-in-literature.** Q-learning's asymptotic convergence (Watkins 1989, Tsitsiklis 1994) had been known for decades, but a tight finite-time `Õ(1/((1−γ)^4 ε²))` sample-complexity bound matching the lower bound required separating bias, MDS concentration, and the nonlinear coupling residual cleanly.

### 2. The Key Insight
The single hardest step is the **linearization-and-coupling argument** in Step 5c: define a fictitious linear process `L_t` that satisfies the same recursion as `Δ_t` but *without* the max-induced nonlinearity. Then `R_t := Δ_t − L_t` satisfies a recursion driven by a coupling residual `φ_t` of size `O(γ e_t)`. This decouples the random part (`L_t`, where Azuma–Hoeffding applies cleanly because the weights are deterministic) from the deterministic-but-nonlinear part (`R_t`), allowing each to be controlled separately. Without this trick, the random weights `w_{k,t}` would entangle with `e_k`, killing entry-wise martingale concentration.

### 3. The Technique Chain
- **Bellman `γ`-contraction** — textbook.
- **Polynomial learning rate `α_t = (H+1)/(H+t)`** with telescoping product — non-standard; specifically chosen so `Π ρ_j` telescopes to `(H−1)/(H+t−1)`.
- **Bias/variance/coupling decomposition** `e_t ≤ β_t + max_{s,a} |M_t(s,a)| + ‖R_t‖_∞` — non-standard, central to the proof.
- **Linearization trick `Δ_t = L_t + R_t`** — non-standard, the key technical innovation.
- **Azuma–Hoeffding inequality** for entry-wise MDS sums with deterministic weights — standard concentration.
- **Union bound over `SA` pairs** — textbook; gives `log(SA/δ)` factor.

### 4. The Construction
The polynomial learning rate `α_t = (H+1)/(H+t)` is a "construction" in the sense that it's hand-tuned: any other power-law schedule would either fail to give enough contraction (too slow decay) or kill the noise (too fast decay). The +1 in the numerator is exactly what makes the telescoping product collapse to a clean closed form. This was likely found by trial-and-error or by reading Wainwright (2019)'s related synchronous analysis.

### 5. The Failure Modes
- Textbook student applies Azuma–Hoeffding directly to `Σ w_{k,t} ξ_{k+1}` where `w_{k,t}` depends on the realized `Q_k` (via `α_t` if data-dependent) — fails because weights become random.
- They try Markov chain mixing arguments (since this is RL) — fails because the generative model decouples sampling, but the max nonlinearity still couples errors across `(s,a)` pairs.
- They use ODE-method asymptotics (Borkar) — gives convergence but not a finite-time rate.

### 6. The Discovery Path
1. Question: tight finite-time bound for synchronous Q-learning.
2. First attempt: standard contraction + recursion `e_{t+1} ≤ (1 − α_t(1−γ))e_t + α_t‖ξ_{t+1}‖_∞`, then try Azuma on `Σ w_{k,t}‖ξ_{k+1}‖_∞` — fails because `‖ξ_{k+1}‖_∞ = max_{s,a} |ξ_{k+1}(s,a)|` doesn't fit MDS framework cleanly.
3. Key insight: linearize. Define `L_t` (linear, has clean MDS sums per entry) and `R_t` (deterministic-bound coupling residual driven by `e_k`). Bound them separately.
4. Execute: bias bound via telescoping, MDS bound via Azuma–Hoeffding entry-wise + union bound, coupling bound via crude `e_k ≤ H` estimate refined by `e_k ≤ β_k`.
5. Polish: choose constants so coupling and bias are absorbed by variance condition; assemble into final `T = O((1−γ)^{−4} ε^{−2} log(SA/δ))`.

### 7. Transferable Patterns
- **Linearize-then-couple** template: for nonlinear stochastic recursions, separate into a linear stochastic process (where concentration is clean) plus a deterministic coupling residual (bounded in terms of the original error). This recurs in TD-learning, SGD on smooth non-convex functions, and stochastic approximation generally.
- **Polynomial learning rate `(H+1)/(H+t)` with telescoping product** is reusable in any contraction-based stochastic approximation.
- **Entry-wise MDS + union bound** is the canonical workaround for `‖·‖_∞`-control of vector-valued martingale-like sums.

---

# Summary

- **File written:** `C:/Users/12729/Desktop/Math/workspace/discovery_reports/agent_1.md`
- **Proofs analyzed:** 7 (NPG-softmax, entropy-reg VI, SGD-averaged, heavy-ball-instability, SAM, Lookahead, sync-Q-learning)
- **Most interesting cross-cutting observation:** Five of the seven proofs share the same meta-template — *write the same quantity from two different angles (one identity, one inequality), then watch the cross terms cancel*. NPG cancels `KL(π_{k+1}‖π_k)` between Bregman three-point and Hoeffding/DV; SAM cancels `‖g_t − ∇f^SAM‖` between descent lemma and Danskin; sync-Q-learning cancels nonlinearity between `L_t` (linear MDS) and `R_t` (coupling residual); entropy-reg VI cancels `τ` factors between LSE and `1/τ` scaling inside; heavy-ball-instability is the inverse — it deliberately *prevents* such cancellation by mismatching local and global curvature. The "creative leap" in convergence-rate proofs is almost always identifying *which two quantities can be set equal so that subtracting them gives a telescoping inequality*.
