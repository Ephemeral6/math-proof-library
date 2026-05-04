# Notes: CR Compositional Reasoning Depth Lower Bound

## Proof technique

Composite of two complementary arguments:

1. **Part (a):** Yao's minimax + adversary lower bound on Bernoulli hypothesis testing. Per-level: $T_\ell \ge \log(1/2\delta)/\log(1/\varepsilon)$. Summed across $d$ levels: $T \ge d\log(1/\delta)/\log(1/\varepsilon)$ modulo lower-order terms.

2. **Part (b):** Causal-DAG critical-path argument. Under transcript-dependency (each level's verifier requires a verified premise from the previous level), the longest dependency chain has length $d$ in any valid scheduling, so makespan $\ge d$.

3. **Part (c):** Direct numerical evaluation of the stated formula.

## Key steps

- **Step 1 (per-level reduction):** $\Pr[\text{any level fails}] \ge \max_\ell \Pr[\text{level $\ell$ fails}]$, so total failure $\le \delta$ implies per-level failure $\le \delta$. This is what gives the formula $\log(1/\delta)$ (not $\log(d/\delta)$) — it's the worst-level argument, not the union bound.
- **Step 2 (Bayes-error tail):** Among $T_\ell$ Bernoulli$(p)$ samples with $p \in \{\varepsilon, 1-\varepsilon\}$, the Bayes-optimal test errs with probability $\ge \tfrac{1}{2}\varepsilon^{T_\ell}$ (the all-tail event). This is the *information-theoretic* per-level limit.
- **Step 3 (logarithmic inversion):** $\varepsilon^{T_\ell} \le 2\delta \Leftrightarrow T_\ell \ge \log(1/2\delta)/\log(1/\varepsilon)$.

## Audit result

- SymPy verified: $\varepsilon^{T_\ell} = \delta \Rightarrow T_\ell = \log(1/\delta)/\log(1/\varepsilon)$.
- Z3 verified: linearized inequality form `unsat` on negation, confirming bound at sample parameters.
- Numerical: stated formula in (c) evaluates to **3.90**, not **18**. The "18" claim in the original problem is an arithmetic error of factor ~4.6×.

## Honest disclosures

1. **Constant gap in (a).** Adversary argument gives $T_\ell \ge \log(1/2\delta)/\log(1/\varepsilon)$ rather than $\log(1/\delta)/\log(1/\varepsilon)$. For $\delta \le 1/2$, the $-\log 2$ term is non-positive in the right direction, so the claim holds with a sub-leading $O(d)$ correction.

2. **Hypothesis 1 (adversarial alternative)** is necessary. Without it, trivial tasks have $O(1)$ complexity.

3. **Part (b) is model-dependent.** Under a permissive verifier (judges propositions intrinsically, not by transcript dependency), parallel speedup is possible. Our argument requires transcript-based verification — Hypothesis 2.

4. **Part (c)'s claimed "18" is wrong.** Correct value of the stated formula at the stated parameters is $\approx 3.9$. We flag this as an arithmetic error in the original problem; the formula and the bound's derivation are consistent with each other (cluster-step interpretation, $\varepsilon^k$ effective error), but cannot yield "18".

## Related results

- **Cumulative-reasoning compositional reuse** (sibling proof, also under `multi-agent/`): provides the upper bound counterpart — efficient composition of verified sub-derivations.
- **Categorical-functorial error propagation** (sibling proof): error-rate analysis under categorical composition; complements the per-level error analysis here.
- **Ben-David et al., learnability lower bounds** (foundational): similar style of Bayes-error argument for binary classification.
- **Brent's theorem** (parallel computing): formalizes that critical-path length lower-bounds parallel makespan — directly invoked in part (b).

## Verdict

PARTIAL. (a) PASS, (b) PARTIAL (model-dependent), (c) PARTIAL (formula correct, numerical claim "18" is incorrect).
