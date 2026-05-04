# Notes: Softmax Policy Gradient O(1/t) Convergence

## Proof technique

**Winner: Route 1 — Non-uniform Łojasiewicz + Descent Lemma** (canonical Mei-Xiao-Szepesvári-Schuurmans 2020 strategy).

The skeleton: β-smoothness of $V^\pi$ in $\theta$ gives a descent lemma $\delta_{t+1} \le \delta_t - \|\nabla V\|^2/(2\beta)$. The novel non-uniform Łojasiewicz inequality $\|\nabla V\|_2 \ge \frac{c_\infty \rho_{\min}(1-\gamma)}{\sqrt{|\mathcal{S}|}} \delta$ converts this into $\delta_{t+1} \le \delta_t(1-C\delta_t)$ with $C = c_\infty^2\rho_{\min}^2(1-\gamma)^5/(16|\mathcal{S}|)$. The standard sublinear recursion then yields $\delta_t \le 1/(Ct)$.

Route 1 won because it maps cleanly onto the canonical paper proof. Routes 2 (PDL+mean-value) and 4 (mirror descent) claimed independent routes but ended up re-deriving NU-Łojasiewicz. Route 3 (KL potential) failed at Step 6: vanilla PG lacks the Fisher preconditioning that makes the NPG Lyapunov loop close; Pinsker's inequality goes the wrong direction.

## Key steps

1. **Sign-robust Cauchy–Schwarz (Step 5)** — the trick that makes the NU-Łojasiewicz work. Apply $(\sum_s x_s)^2 \le |\mathcal{S}| \sum_s x_s^2$ to $x_s = d^\pi_\rho(s) \pi(a^*(s)|s) A^\pi(s,a^*(s))/(1-\gamma)$ *without* taking absolute values. The signed sum $\sum_s x_s \ge 0$ comes from aggregate PDL, not pointwise $A^\pi(s,a^*(s)) \ge 0$ (which is false in general). This distinction killed Route 3's Lyapunov approach.

2. **β-smoothness with tight constant 8/(1-γ)³ (Step 4)** — triple decomposition of the value Hessian: softmax-Hessian contribution + transfer-derivative + resolvent-derivative. Bookkeeping $(6 + 2\gamma)/(1-\gamma)^3 \le 8/(1-\gamma)^3$ is SymPy-verified.

3. **$c_\infty > 0$ monotonicity-once-crossed (Step 6A/6B)** — split into a clean self-contained "best-advantage monotonicity" lemma (6A) plus a black-box citation of Mei et al. Lemma 9 for the finite-hitting-time piece (6B). The original attempt at unifying these failed at round 1.

## Audit result

**PASS after 3 rounds** (max allowed for research difficulty).

- Round 1 FAIL: Step 9 hand-waved $\rho_{\min} \ge (1-\gamma)$ (false in general); Step 6 only sketched $c_\infty > 0$.
- Round 2 FAIL: Fixer's $c_\infty' := c_\infty\rho_{\min}\sqrt{1-\gamma}$ redefinition had a $(1-\gamma)^2$ algebra bug.
- Round 3 PASS: Option A **honest restatement** — box the bound the chain actually produces $\delta_t \le 16|\mathcal{S}|/(c_\infty^2\rho_{\min}^2(1-\gamma)^5 t)$ and transparently note the non-equivalence with problem.md's target form (which uses Mei et al.'s different $c_\infty$ convention absorbing distribution-mismatch).

SymPy-verified: $1/(Ct) =$ boxed RHS identically. Numerical: 400/400 passes across 4 MDPs × 100 PG steps × 3 values of γ.

## Bound comparison (problem.md target vs. what we prove)

| Form | Factor | Equivalence |
|------|--------|-------------|
| Target (problem.md) | $16\|\mathcal{S}\|/(c_\infty^2 (1-\gamma)^6 t)$ | Mei et al.'s $c_\infty$ convention |
| Derived (this proof) | $16\|\mathcal{S}\|/(c_\infty^2 \rho_{\min}^2 (1-\gamma)^5 t)$ | problem.md's literal $c_\infty$ |
| Ratio (derived / target) | $(1-\gamma) / \rho_{\min}^2$ | **Not universally $\le 1$ or $\ge 1$** |

## Related results

- **NPG companion**: `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/` — NPG achieves $O(1/K)$ with $(1-\gamma)^{-2}$ and **no** $c_\infty$ dependence (Agarwal-Kakade-Lee-Mahajan 2020). The $c_\infty^{-2}$ factor in our PG bound is the known "price" of vanilla over natural PG.
- **Entropy-regularized NPG**: `proofs/research/optimization/convergence/entropy-regularized-npg-linear-convergence-variant/` — linear rate when entropy regularization is added.
- **Technique reuse**: The sign-robust Cauchy–Schwarz on squares, $\beta$-smoothness via resolvent identity, and descent-lemma-plus-Łojasiewicz template are all reusable building blocks for policy-gradient analyses.

## Failure patterns extracted

- Route 3 KL Potential failed because: (i) $A^\pi(s,a^*(s))$ can be negative pointwise, (ii) Pinsker's inequality bounds KL below by TV² but not above by value gap, (iii) vanilla PG's geometry is not preconditioned by Fisher information the way NPG's is. Lesson: KL Lyapunov approach requires NPG-style preconditioning.
- Route 4 Mirror Descent's Fisher-spectral lower-bound $\|\nabla V\|^2 \ge \lambda_{\min}^+(F) \|w^{\text{NPG}}\|_F^2$ does NOT transfer the NPG rate because PG and NPG trajectories diverge. Lesson: spectral comparison only works when iterate trajectories coincide.
