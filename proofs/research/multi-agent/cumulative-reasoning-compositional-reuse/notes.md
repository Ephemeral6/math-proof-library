# Notes: Compositionality of Cumulative Reasoning

## Proof technique

Three independent techniques, one per part:
- **(a)** Direct probability + Weierstrass inequality (Route 1).
- **(b)** Structural induction on DAG depth (Route 2), reinterpreted via combinatorial counting (Route 4).
- **(c)** Reduction to (a) with per-lemma retry making δ → δ^k.

Route 3 (FKG) was a sanity check confirming (a) extends to positive correlation, but not used in the main proof.

## Key steps

1. **Formal probability model**: events A_i = {L_i correct}; hypothesis H3 (sound composition) is critical — it converts "lemmas correct" to "T correct".
2. **Weierstrass induction**: ∏(1-x_i) ≥ 1 - Σx_i for x_i ∈ [0,1]; one-line induction step.
3. **DAG unfolding count**: N(d, Δ) = (Δ^{d+1}-1)/(Δ-1) — recurrence N_t = 1 + Δ N_{t-1}.
4. **Honesty correction on (b)**: user's stated (1-δ)^{Δ^d} is in the same exponential family as the correct (1-δ)^{N(d,Δ)} but is strictly looser (larger). We documented the correction explicitly.
5. **Retry reduction**: Per-lemma failure prob after k retries = δ^k by independence; substitute into (a).

## Audit result

One audit round, no fixer required. Findings:
- (a) verified symbolically (SymPy) and numerically.
- (b) verified after correction: N(d, Δ) ≥ Δ^d for Δ ≥ 2 confirmed; inequality direction verified.
- (c) verified numerically; gap vs (b) is dramatic (≈700× at typical parameters).
- Z3-style monotonicity check on x^a vs x^b confirms direction.

## Honesty note

User's bound (1-δ)^{Δ^d} in (b) cannot be derived directly from tree-unfolding induction. The correct bound from induction is (1-δ)^{N(d,Δ)} with N(d,Δ) = (Δ^{d+1}-1)/(Δ-1) ≥ Δ^d. The user's form is "right exponential order" but quantitatively a looser lower bound. Final proof adopts the corrected form.

## Related results

- **Hoeffding bound** (`proofs/library/statistics/concentration/...`): also uses independence to bound product probabilities.
- **Boole / union bound**: alternate proof of (a) via P(∪A_i^c) ≤ Σ P(A_i^c).
- **FKG / Harris inequality**: extends (a) to positively correlated failures.
- **Categorical/functorial error propagation** (`proofs/research/multi-agent/categorical-functorial-error-propagation/`): related framework for compositional error propagation in multi-agent systems.
- **Verification frameworks** (`proofs/research/multi-agent/verification/`): provides the foundation for the H1 (verified errors) hypothesis.

## Practical takeaway

The library-first design principle (P3) is justified: applying Auditor-Fixer per-lemma during library construction (cost: k× per lemma) gives an exponentially tighter end-to-end reliability than applying it only at the final theorem. The architectural implication is that retry budget should be spent on **shared** sub-lemmas, not on the top-level proof.
