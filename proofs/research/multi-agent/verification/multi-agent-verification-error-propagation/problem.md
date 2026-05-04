# Error Propagation Bounds for Multi-Agent Verification Systems

## Source
- Paper inspiration: Zhang, Yang, Yuan, Yao, "Cumulative Reasoning with Large Language Models", arXiv:2308.04371
- Direction: Cumulative Reasoning / Multi-agent verification theory
- Context: This result quantifies the theoretical advantage of an Auditor-Fixer (reject-and-re-propose) loop over single-shot CR-style verification — the key differentiator between our framework and CR.

## Statement

**Setup (M1)–(M3).** A reasoning chain proceeds for $T$ rounds. At round $t$, a Proposer emits a candidate $p_t$, a Verifier judges it, and (in the $k$-retry version) the Verifier may judge up to $k$ independent candidates per round. Each Verifier judgment errs (combining false-accept and false-reject) with probability $\varepsilon$, i.i.d. across both rounds and intra-round retries. The chain is *correct* iff every accepted proposition is in fact true.

**(a) Single-shot lower bound, with tightness.** With no retries,
$$
\Pr[\text{chain correct}] \ge (1-\varepsilon)^T,
$$
and there exists an adversarial (honest-Proposer) instance attaining equality.

**(b) k-retry lower bound (Auditor–Fixer).** With up to $k$ independent Verifier judgments per round, where each round succeeds if at least one judgment is non-erroneous,
$$
\Pr[\text{chain correct}] \ge (1 - \varepsilon^k)^T.
$$

**(c) Numerical instantiation.** $\varepsilon = 0.14$, $k = 3$, $T = 10$:
- per-step error: $14\% \to 0.27\%$
- chain reliability: $22.1\% \to 97.3\%$
- absolute reliability gap: at least $0.752$.

## Difficulty
research (the math is elementary; the novelty is in the careful modeling and in providing a quantitative theoretical underpinning for the Auditor–Fixer architecture)
