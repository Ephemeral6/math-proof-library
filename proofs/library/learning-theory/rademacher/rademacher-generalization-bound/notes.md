# Notes: Rademacher Complexity Generalization Bound

## Proof technique
The winning route (Route 3: Two-Step Concentration) uses a clean two-part structure:
- **Part A** (empirical bound): A pointwise symmetrization inequality $\Phi(S) \leq \mathfrak{R}_n + \hat{\mathfrak{R}}_n$ combined with a single McDiarmid application on $\hat{\mathfrak{R}}_n$ to replace $\mathfrak{R}_n$ by $\hat{\mathfrak{R}}_n$.
- **Part B** (population bound): The expectation bound $\mathbb{E}[\Phi] \leq 2\mathfrak{R}_n$ (from symmetrization) plus McDiarmid concentration on $\Phi$, then union bound for the empirical conversion.

The key insight is that the symmetrization lemma gives a **pointwise** inequality (not just in expectation), which allows combining with a single concentration step instead of the less elegant approach of applying McDiarmid to the difference $\Phi - 2\hat{\mathfrak{R}}_n$ (which has bounded differences $3/n$ instead of $1/n$).

## Key steps
1. **Ghost sample + Jensen**: Replace $\mathbb{E}[f]$ with $\mathbb{E}_{S'}[\hat{\mathbb{E}}'_n[f]]$, then move $\sup$ inside $\mathbb{E}_{S'}$.
2. **Rademacher symmetrization**: Since $f(X_i') - f(X_i)$ is symmetric (because $(X_i, X_i')$ are i.i.d.), multiplying by $\sigma_i$ preserves the distribution.
3. **Sub-additivity of sup**: Split the Rademacher sum of differences into two Rademacher sums, one over $S'$ (giving $\mathfrak{R}_n$) and one over $S$ (giving $\hat{\mathfrak{R}}_n$).
4. **McDiarmid on $\hat{\mathfrak{R}}_n$**: The empirical Rademacher complexity has bounded differences $1/n$, giving sharp concentration of $\mathfrak{R}_n$ around $\hat{\mathfrak{R}}_n$.

## Audit result
PASS on first round. All 10 steps verified VALID. Three LOW-severity cosmetic issues:
- Convention on $\ln(2/\delta)$ vs $\ln(4/\delta)$ in the factor-3 bound (standard in literature)
- Precision of the symmetrization distributional argument (correct but could be more explicit)
- The population bound is actually stronger than stated (coefficient 1, not 3)

## Related results
- **McDiarmid's bounded differences inequality** — used as a key tool (proved separately in this library at `proofs/statistics/concentration/mcdiarmid-bounded-differences-inequality/`)
- **Massart's finite class lemma** — gives $\mathfrak{R}_n(\mathcal{F}) \leq \sqrt{2\ln|\mathcal{F}|/n}$ for finite classes
- **Dudley's entropy integral** — upper bounds Rademacher complexity via covering numbers
- **VC dimension bounds** — Rademacher complexity provides tighter, data-dependent alternatives to VC-based bounds
- **Contraction lemma (Talagrand-Ledoux)** — allows bounding Rademacher complexity of composed function classes
- **PAC-Bayes bounds** (proved in this library at `proofs/learning-theory/pac/mcallester-pac-bayes-bound/`) — alternative data-dependent generalization framework
- **SGD uniform stability** (proved in this library at `proofs/learning-theory/stability/sgd-uniform-stability-generalization/`) — algorithm-dependent (rather than complexity-dependent) generalization
